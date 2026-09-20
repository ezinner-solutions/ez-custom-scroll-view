import 'package:ez_custom_scroll_view/ez_custom_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EzCustomScrollView', () {
    testWidgets('renders normally when constraints are bounded',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 400,
              child: EzCustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Container(
                      height: 100,
                      color: Colors.blue,
                      child: const Text('Bounded Item'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Bounded Item'), findsOneWidget);
      expect(find.byType(CustomScrollView), findsOneWidget);

      // Should not be wrapped in debug border container
      final redContainers = find.byWidgetPredicate((widget) {
        if (widget is Container && widget.decoration is BoxDecoration) {
          final decoration = widget.decoration as BoxDecoration;
          return decoration.border?.top.color == Colors.red;
        }
        return false;
      });
      expect(redContainers, findsNothing);
    });

    testWidgets('prevents crash when placed inside Column (unbounded height)',
        (WidgetTester tester) async {
      final List<FlutterErrorDetails> errors = [];
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) => errors.add(details);

      String? detectedCulprit;
      bool? wasHeightUnbounded;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const Text('Header Above Scroll'),
                EzCustomScrollView(
                  onUnboundedDetected: (
                      {required isHeightUnbounded,
                      required isWidthUnbounded,
                      required culprit}) {
                    wasHeightUnbounded = isHeightUnbounded;
                    detectedCulprit = culprit;
                  },
                  slivers: [
                    SliverToBoxAdapter(
                      child: Container(
                        height: 100,
                        color: Colors.green,
                        child: const Text('Unbounded Scroll Item'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      // Verify that no exception crashed the tree and widgets rendered
      expect(find.text('Header Above Scroll'), findsOneWidget);
      expect(find.text('Unbounded Scroll Item'), findsOneWidget);

      // Verify culprit detection
      expect(wasHeightUnbounded, isTrue);
      expect(detectedCulprit, 'Column');

      // Verify error was reported to FlutterError
      expect(errors, isNotEmpty);
      expect(
        errors.any(
            (e) => e.exceptionAsString().contains('Unbounded height detected')),
        isTrue,
      );

      // Verify red debug border was rendered in debug mode
      final redBorder = find.byWidgetPredicate((widget) {
        if (widget is Container && widget.decoration is BoxDecoration) {
          final decoration = widget.decoration as BoxDecoration;
          return decoration.border?.top.color == Colors.red;
        }
        return false;
      });
      expect(redBorder, findsOneWidget);

      FlutterError.onError = originalOnError;
    });

    testWidgets('prevents crash when placed inside Row (unbounded width)',
        (WidgetTester tester) async {
      final List<FlutterErrorDetails> errors = [];
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) => errors.add(details);

      String? detectedCulprit;
      bool? wasWidthUnbounded;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 300,
              child: Row(
                children: [
                  const Text('Sidebar'),
                  EzCustomScrollView(
                    scrollDirection: Axis.horizontal,
                    onUnboundedDetected: (
                        {required isHeightUnbounded,
                        required isWidthUnbounded,
                        required culprit}) {
                      wasWidthUnbounded = isWidthUnbounded;
                      detectedCulprit = culprit;
                    },
                    slivers: [
                      SliverToBoxAdapter(
                        child: Container(
                          width: 150,
                          color: Colors.orange,
                          child: const Text('Horizontal Scroll Item'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Sidebar'), findsOneWidget);
      expect(find.text('Horizontal Scroll Item'), findsOneWidget);

      expect(wasWidthUnbounded, isTrue);
      expect(detectedCulprit, 'Row');

      expect(errors, isNotEmpty);
      expect(
        errors.any(
            (e) => e.exceptionAsString().contains('Unbounded width detected')),
        isTrue,
      );

      FlutterError.onError = originalOnError;
    });

    testWidgets('respects custom fallbackHeight and fallbackWidth',
        (WidgetTester tester) async {
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (_) {};

      const double customHeight = 275.0;
      const double customWidth = 320.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UnconstrainedBox(
              child: EzCustomScrollView(
                fallbackHeight: customHeight,
                fallbackWidth: customWidth,
                slivers: [
                  SliverToBoxAdapter(
                    child: Container(
                      height: 50,
                      child: const Text('Custom Dimensions Item'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Custom Dimensions Item'), findsOneWidget);

      final sizedBoxes = find.byType(SizedBox);
      bool foundMatchingSizedBox = false;
      for (var element in tester.widgetList<SizedBox>(sizedBoxes)) {
        if (element.height == customHeight && element.width == customWidth) {
          foundMatchingSizedBox = true;
        }
      }
      expect(foundMatchingSizedBox, isTrue);
      FlutterError.onError = originalOnError;
    });

    testWidgets('hides debug border when showDebugIndicator is false',
        (WidgetTester tester) async {
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (_) {};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                EzCustomScrollView(
                  showDebugIndicator: false,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Container(
                        height: 50,
                        child: const Text('No Border Item'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('No Border Item'), findsOneWidget);

      final redContainers = find.byWidgetPredicate((widget) {
        if (widget is Container && widget.decoration is BoxDecoration) {
          final decoration = widget.decoration as BoxDecoration;
          return decoration.border?.top.color == Colors.red;
        }
        return false;
      });
      expect(redContainers, findsNothing);
      FlutterError.onError = originalOnError;
    });

    testWidgets('passes through controller, physics, reverse, and shrinkWrap',
        (WidgetTester tester) async {
      final controller = ScrollController();
      const physics = BouncingScrollPhysics();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 400,
              child: EzCustomScrollView(
                controller: controller,
                physics: physics,
                reverse: true,
                shrinkWrap: true,
                slivers: const [
                  SliverToBoxAdapter(child: Text('Pass-through Item')),
                ],
              ),
            ),
          ),
        ),
      );

      final customScrollView =
          tester.widget<CustomScrollView>(find.byType(CustomScrollView));
      expect(customScrollView.controller, controller);
      expect(customScrollView.physics, physics);
      expect(customScrollView.reverse, isTrue);
      expect(customScrollView.shrinkWrap, isTrue);
    });
  });
}
