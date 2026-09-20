library ez_custom_scroll_view;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// A defensive, self-aware drop-in replacement for [CustomScrollView] that prevents
/// layout crashes when placed inside parents with unbounded constraints.
///
/// In standard Flutter, placing a [CustomScrollView] inside a [Column], [Row],
/// [Flex], or nested scroll view results in a fatal layout exception:
/// * `"Vertical viewport was given unbounded height"`
/// * `"Horizontal viewport was given unbounded width"`
///
/// [EzCustomScrollView] intercepts these unbounded constraints before they cause
/// a crash:
///
/// * **Crash Prevention:** Automatically detects unbounded dimensions in the scrolling
///   or cross axes and applies a sensible, bounded fallback size.
/// * **Developer Feedback:** In debug mode, displays a visible red indicator and logs
///   a detailed, actionable [FlutterError] explaining the exact parent culprit
///   (e.g., [Column], [Row]) and how to permanently fix it.
/// * **Silent Protection:** In release mode, silently resolves the layout so users
///   never experience a red screen of death.
/// * **Drop-in Parity:** Accepts all parameters supported by standard [CustomScrollView].
///
/// ## Layout algorithm
///
/// 1. Uses a [LayoutBuilder] to inspect incoming box constraints.
/// 2. If constraints are bounded in both the scrolling and cross axes (or if [shrinkWrap] is true),
///    renders standard [CustomScrollView] directly.
/// 3. If unbounded constraints are detected:
///    - Calculates a safe fallback size based on available screen space via [MediaQuery] or [View].
///    - Reports a structured error with culprit diagnosis via [_EzCustomScrollViewHelper.reportUnboundedError] in debug mode.
///    - Invokes [onUnboundedDetected] callback if provided.
///    - Wraps the [CustomScrollView] in a [SizedBox] with bounded dimensions.
///    - When [showDebugIndicator] is true and running in debug mode, applies a red outline border.
///
/// ## Examples
///
/// ### Safe inside a Column (Crash Prevention)
///
/// ```dart
/// Column(
///   children: [
///     const Text('Header'),
///     // Won't crash! Automatically constrained with a debug warning.
///     EzCustomScrollView(
///       slivers: [
///         SliverList.builder(
///           itemCount: 20,
///           itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
///         ),
///       ],
///     ),
///   ],
/// )
/// ```
///
/// ### Horizontal scroll inside a Row
///
/// ```dart
/// Row(
///   children: [
///     const Text('Sidebar'),
///     EzCustomScrollView(
///       scrollDirection: Axis.horizontal,
///       slivers: [
///         SliverToBoxAdapter(
///           child: Container(width: 300, color: Colors.blue),
///         ),
///       ],
///     ),
///   ],
/// )
/// ```
///
/// See also:
///
///  * [CustomScrollView], the standard Flutter scroll view.
///  * [SliverList] and [SliverGrid], common sliver building blocks.
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
  @Deprecated('Use scrollCacheExtent in Flutter 3.41+.')
  final double? cacheExtent;

  /// See [CustomScrollView.scrollCacheExtent].
  final double? scrollCacheExtent;

  /// The slivers to place inside the viewport.
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

  /// How to behave during hit testing.
  final HitTestBehavior hitTestBehavior;

  /// Whether to display a red border indicator in debug mode when unbounded constraints are detected.
  ///
  /// Defaults to `true`. Has no effect in release mode.
  final bool showDebugIndicator;

  /// Optional custom fallback height to use when unbounded height is detected.
  ///
  /// If `null`, defaults to 50% of available screen height.
  final double? fallbackHeight;

  /// Optional custom fallback width to use when unbounded width is detected.
  ///
  /// If `null`, defaults to 50% of available screen width.
  final double? fallbackWidth;

  /// Optional callback invoked when unbounded constraints are detected.
  ///
  /// Useful for automated telemetry, testing, or custom diagnostic logging.
  final void Function({
    required bool isWidthUnbounded,
    required bool isHeightUnbounded,
    required String? culprit,
  })? onUnboundedDetected;

  /// Creates a defensive, self-aware version of [CustomScrollView].
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
    @Deprecated('Use scrollCacheExtent in Flutter 3.41+.') this.cacheExtent,
    this.scrollCacheExtent,
    this.slivers = const <Widget>[],
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.hitTestBehavior = HitTestBehavior.opaque,
    this.showDebugIndicator = true,
    this.fallbackHeight,
    this.fallbackWidth,
    this.onUnboundedDetected,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isUnboundedHeight = constraints.maxHeight.isInfinite;
        final bool isUnboundedWidth = constraints.maxWidth.isInfinite;

        // Determine whether scrolling or cross axis would crash standard viewport
        final bool isScrollAxisUnbounded =
            (scrollDirection == Axis.vertical && isUnboundedHeight) ||
                (scrollDirection == Axis.horizontal && isUnboundedWidth);

        final bool isCrossAxisUnbounded =
            (scrollDirection == Axis.vertical && isUnboundedWidth) ||
                (scrollDirection == Axis.horizontal && isUnboundedHeight);

        final bool needsFix =
            (isScrollAxisUnbounded && !shrinkWrap) || isCrossAxisUnbounded;

        final Widget scrollView = _buildScrollView();

        if (!needsFix) {
          return scrollView;
        }

        // Calculate safe fallback dimensions
        final fallbackDimensions =
            _EzCustomScrollViewHelper.calculateFallbackDimensions(
          context: context,
          constraints: constraints,
          isUnboundedWidth: isUnboundedWidth,
          isUnboundedHeight: isUnboundedHeight,
          customFallbackWidth: fallbackWidth,
          customFallbackHeight: fallbackHeight,
        );

        if (kDebugMode) {
          final culprit = _EzCustomScrollViewHelper.findCulprit(context);

          _EzCustomScrollViewHelper.reportUnboundedError(
            badWidth: isUnboundedWidth,
            badHeight: isUnboundedHeight,
            scrollDirection: scrollDirection,
            culprit: culprit,
          );

          if (onUnboundedDetected != null) {
            onUnboundedDetected!(
              isWidthUnbounded: isUnboundedWidth,
              isHeightUnbounded: isUnboundedHeight,
              culprit: culprit,
            );
          }

          if (showDebugIndicator) {
            return Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 2.5),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: SizedBox(
                width: fallbackDimensions.width,
                height: fallbackDimensions.height,
                child: scrollView,
              ),
            );
          }
        }

        return SizedBox(
          width: fallbackDimensions.width,
          height: fallbackDimensions.height,
          child: scrollView,
        );
      },
    );
  }

  Widget _buildScrollView() {
    final effectiveCacheExtent = scrollCacheExtent ?? cacheExtent;
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
      // ignore: deprecated_member_use
      cacheExtent: effectiveCacheExtent,
      slivers: slivers,
      semanticChildCount: semanticChildCount,
      dragStartBehavior: dragStartBehavior,
      keyboardDismissBehavior: keyboardDismissBehavior,
      restorationId: restorationId,
      clipBehavior: clipBehavior,
      hitTestBehavior: hitTestBehavior,
    );
  }
}

/// Internal helper for [EzCustomScrollView] layout diagnostics and fallback size calculation.
abstract final class _EzCustomScrollViewHelper {
  /// Calculates fallback dimensions when unbounded constraints are encountered.
  static Size calculateFallbackDimensions({
    required BuildContext context,
    required BoxConstraints constraints,
    required bool isUnboundedWidth,
    required bool isUnboundedHeight,
    required double? customFallbackWidth,
    required double? customFallbackHeight,
  }) {
    final mediaQuery = MediaQuery.maybeOf(context);
    final view = View.maybeOf(context);

    final Size screenSize;
    if (mediaQuery != null) {
      screenSize = mediaQuery.size;
    } else if (view != null && view.devicePixelRatio > 0) {
      screenSize = view.physicalSize / view.devicePixelRatio;
    } else {
      screenSize = const Size(360.0, 640.0);
    }

    final double availableHeight = (screenSize.height -
            (mediaQuery?.padding.top ?? 0) -
            (mediaQuery?.padding.bottom ?? 0) -
            kToolbarHeight)
        .clamp(100.0, double.infinity);

    final double effectiveHeight = isUnboundedHeight
        ? (customFallbackHeight ?? (availableHeight * 0.5))
        : constraints.maxHeight;

    final double effectiveWidth = isUnboundedWidth
        ? (customFallbackWidth ??
            (screenSize.width * 0.5).clamp(100.0, double.infinity))
        : constraints.maxWidth;

    return Size(effectiveWidth, effectiveHeight);
  }

  /// Traverses ancestors to find the widget responsible for the unbounded constraint.
  static String findCulprit(BuildContext context) {
    String culprit = 'an unknown parent';
    context.visitAncestorElements((element) {
      final widget = element.widget;
      if (widget is Flex ||
          widget is ScrollView ||
          widget is Wrap ||
          widget is UnconstrainedBox) {
        culprit = widget.runtimeType.toString();
        return false;
      }
      return true;
    });
    return culprit;
  }

  /// Reports a detailed error to [FlutterError] explaining the exact cause and resolution.
  static void reportUnboundedError({
    required bool badWidth,
    required bool badHeight,
    required Axis scrollDirection,
    required String culprit,
  }) {
    final String problematicDimension;
    if (badWidth && badHeight) {
      problematicDimension = 'width and height';
    } else if (badWidth) {
      problematicDimension = 'width';
    } else {
      problematicDimension = 'height';
    }

    final String axisName =
        scrollDirection == Axis.vertical ? 'vertical' : 'horizontal';

    FlutterError.reportError(
      FlutterErrorDetails(
        exception:
            'EzCustomScrollView: Unbounded $problematicDimension detected in $axisName scroll direction.',
        library: 'EzCustomScrollView',
        context: ErrorDescription('while building EzCustomScrollView'),
        informationCollector: () => [
          ErrorSummary(
              'EzCustomScrollView has applied an automatic layout fallback to prevent a crash.'),
          ErrorDescription(
            'This widget was placed inside a $culprit with infinite $problematicDimension. '
            'In standard Flutter, this causes a fatal "Vertical/Horizontal viewport was given unbounded height/width" exception.',
          ),
          ErrorHint(
            'ACTION REQUIRED: To provide permanent bounded constraints, wrap EzCustomScrollView in an Expanded or Flexible (inside Flex/Column/Row), or a SizedBox with explicit dimensions.',
          ),
        ],
      ),
    );
  }
}
