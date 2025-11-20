import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// A defensive, self-aware version of [CustomScrollView].
///
/// If it detects that its parent is providing unbounded constraints (e.g., inside
/// a Column or a Row), it automatically imposes bounded dimensions to prevent
/// a layout crash.
///
/// In debug mode, it also:
/// 1. Renders a red border around itself to visually identify that a fix was applied.
/// 2. Reports a detailed error to the console with the specific fix required.
class EzCustomScrollView extends StatelessWidget {
  /// See [CustomScrollView.scrollDirection].
  final Axis scrollDirection;

  /// See [CustomScrollView.reverse].
  final bool reverse;

  /// See [CustomScrollView.controller].
  final ScrollController? controller;

  /// See [CustomScrollView.primary].
  final bool? primary;

  /// See [CustomScrollView.physics].
  final ScrollPhysics? physics;

  /// See [CustomScrollView.scrollBehavior].
  final ScrollBehavior? scrollBehavior;

  /// See [CustomScrollView.shrinkWrap].
  final bool shrinkWrap;

  /// See [CustomScrollView.center].
  final Key? center;

  /// See [CustomScrollView.anchor].
  final double anchor;

  /// See [CustomScrollView.cacheExtent].
  final double? cacheExtent;

  /// See [CustomScrollView.slivers].
  final List<Widget> slivers;

  /// See [CustomScrollView.semanticChildCount].
  final int? semanticChildCount;

  /// See [CustomScrollView.dragStartBehavior].
  final DragStartBehavior dragStartBehavior;

  /// See [CustomScrollView.keyboardDismissBehavior].
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// See [CustomScrollView.restorationId].
  final String? restorationId;

  /// See [CustomScrollView.clipBehavior].
  final Clip clipBehavior;

  /// Creates a defensive, self-aware version of [CustomScrollView].
  ///
  /// This widget automatically detects unbounded constraints and applies a fix
  /// to prevent layout crashes, providing detailed debugging information in
  /// debug mode.
  const EzCustomScrollView({
    super.key,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.scrollBehavior,
    this.shrinkWrap = false,
    this.center,
    this.anchor = 0.0,
    this.cacheExtent,
    this.slivers = const <Widget>[],
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isUnboundedHeight = constraints.maxHeight.isInfinite;
        final bool isUnboundedWidth = constraints.maxWidth.isInfinite;

        // If constraints are fine, just build the CustomScrollView.
        if (!isUnboundedHeight && !isUnboundedWidth) {
          return CustomScrollView(
            scrollDirection: scrollDirection,
            reverse: reverse,
            controller: controller,
            primary: primary,
            physics: physics,
            scrollBehavior: scrollBehavior,
            shrinkWrap: shrinkWrap,
            center: center,
            anchor: anchor,
            cacheExtent: cacheExtent,
            slivers: slivers,
            semanticChildCount: semanticChildCount,
            dragStartBehavior: dragStartBehavior,
            keyboardDismissBehavior: keyboardDismissBehavior,
            restorationId: restorationId,
            clipBehavior: clipBehavior,
          );
        }

        // --- Apply safe fallback for unbounded constraints ---
        Widget fixedScrollView = CustomScrollView(
          scrollDirection: scrollDirection,
          reverse: reverse,
          controller: controller,
          primary: primary,
          physics: physics,
          scrollBehavior: scrollBehavior,
          shrinkWrap: shrinkWrap,
          center: center,
          anchor: anchor,
          cacheExtent: cacheExtent,
          slivers: slivers,
          semanticChildCount: semanticChildCount,
          dragStartBehavior: dragStartBehavior,
          keyboardDismissBehavior: keyboardDismissBehavior,
          restorationId: restorationId,
          clipBehavior: clipBehavior,
        );

        final mediaQuery = MediaQuery.of(context);

        final double fixedHeight;
        if (isUnboundedHeight) {
          // Calculate a reasonable default height based on the screen size.
          final calculatedSafeHeight =
              mediaQuery.size.height - mediaQuery.padding.top - kToolbarHeight;
          fixedHeight = calculatedSafeHeight * 0.5; // Use 50% as a default
        } else {
          fixedHeight = constraints.maxHeight;
        }

        final double fixedWidth;
        if (isUnboundedWidth) {
          fixedWidth = mediaQuery.size.width * 0.5; // Use 50% as a default
        } else {
          fixedWidth = constraints.maxWidth;
        }

        if (kDebugMode) {
          // Identify the parent widget causing the issue and report a detailed error.
          _reportError(context, isUnboundedWidth, isUnboundedHeight);

          // Wrap with a visual indicator to highlight the problematic widget.
          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red, width: 2.5),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: SizedBox(
              width: fixedWidth,
              height: fixedHeight,
              child: fixedScrollView,
            ),
          );
        }

        // In release mode, apply the fix silently to prevent a crash.
        return SizedBox(
          width: fixedWidth,
          height: fixedHeight,
          child: fixedScrollView,
        );
      },
    );
  }

  /// Reports a detailed error about which dimension was unbounded.
  void _reportError(BuildContext context, bool badWidth, bool badHeight) {
    String culprit = "an unknown parent";
    context.visitAncestorElements((element) {
      if (element.widget is Flex ||
          element.widget is ScrollView) { // Generalized to ScrollView
        culprit = element.widget.runtimeType.toString();
        return false;
      }
      return true;
    });

    String problematicDimension = "unknown";
    if (badWidth && badHeight) {
      problematicDimension = "width and height";
    } else if (badWidth) {
      problematicDimension = "width";
    } else {
      problematicDimension = "height";
    }

    FlutterError.reportError(
      FlutterErrorDetails(
        exception: 'EzCustomScrollView: Unbounded $problematicDimension detected.',
        library: 'EzCustomScrollView',
        context: ErrorDescription('while building EzCustomScrollView'),
        informationCollector: () => [
          ErrorSummary('EzCustomScrollView has applied an automatic layout fix.'),
          ErrorDescription(
            'This widget was placed directly inside a $culprit, which provides infinite $problematicDimension. '
            'This would normally cause a layout crash.',
          ),
          ErrorHint(
            'ACTION REQUIRED: For a permanent fix, you must wrap EzCustomScrollView in a widget that provides bounded constraints, such as an Expanded or a SizedBox.',
          ),
        ],
      ),
    );
  }
}
