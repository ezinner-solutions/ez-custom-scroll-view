# EzCustomScrollView

A defensive, crash-safe drop-in replacement for Flutter's `CustomScrollView` that automatically handles unbounded constraints in `Column`, `Row`, `Flex`, and nested scroll views.

[![pub package](https://img.shields.io/pub/v/ez_custom_scroll_view.svg)](https://pub.dev/packages/ez_custom_scroll_view)
[![likes](https://img.shields.io/pub/likes/ez_custom_scroll_view.svg)](https://pub.dev/packages/ez_custom_scroll_view)
[![popularity](https://img.shields.io/pub/popularity/ez_custom_scroll_view.svg)](https://pub.dev/packages/ez_custom_scroll_view)
[![pub points](https://img.shields.io/pub/points/ez_custom_scroll_view.svg)](https://pub.dev/packages/ez_custom_scroll_view)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## Problem Statement

In Flutter, standard `CustomScrollView` widgets expand to fill all available space along their scrolling axis. When placed inside an unconstrained parent (such as a vertical `Column` or horizontal `Row`), Flutter's viewport layout cannot compute finite dimensions, resulting in an immediate crash and the red error screen:

* Placing a vertical `CustomScrollView` inside a `Column` or `Flex` without `Expanded` or `Flexible`.
* Placing a horizontal `CustomScrollView` inside a `Row` without explicit width constraints.
* Nesting inside unconstrained wrappers like `UnconstrainedBox` or floating cards.

### Targeted Error Signatures
`EzCustomScrollView` catches and prevents the following Flutter layout runtime exceptions:
* `"Vertical viewport was given unbounded height"`
* `"Horizontal viewport was given unbounded width"`
* `"RenderBox was not laid out: RenderViewport #... NEEDS-PAINT NEEDS-COMPOSITING-BITS-UPDATE"`
* `"Failed assertion: line ... pos ...: 'hasSize'"`
* `"A RenderFlex overflowed by ... pixels on the bottom"`

## Technical Solution

`EzCustomScrollView` intercepts incoming constraints before the `RenderViewport` can throw a fatal layout exception:

1. **Defensive Layout Fallback:** Uses `LayoutBuilder` to detect infinite constraints along the scrolling or cross axes. When detected, it calculates a responsive fallback size (50% of available screen height/width via `MediaQuery`/`View`) so the slivers render visibly.
2. **Debug Diagnostics:** In debug mode, highlights the widget with a visible red outline border and logs an actionable `FlutterError` identifying the exact parent widget (`Column`, `Row`, `Flex`, etc.) causing the violation.
3. **Silent Release Protection:** In release mode, silently applies the fallback dimensions so end users never experience a crash or red screen.
4. **100% Drop-in Parity:** Supports all standard `CustomScrollView` properties (`slivers`, `physics`, `controller`, `shrinkWrap`, `hitTestBehavior`, etc.).

## Installation

```shell
flutter pub add ez_custom_scroll_view
```

## Quick Migration

Replace standard `CustomScrollView` with `EzCustomScrollView`:

```diff
- CustomScrollView(
+ EzCustomScrollView(
    slivers: [
      SliverList.builder(
        itemCount: 20,
        itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
      ),
    ],
  )
```

## Usage Examples

### 1. Crash Prevention inside a Column

In standard Flutter, placing `CustomScrollView` directly inside a `Column` throws `"Vertical viewport was given unbounded height"`. `EzCustomScrollView` prevents the crash:

```dart
Column(
  children: [
    const Text('Header'),
    // Does not crash. Renders safely with a red diagnostic outline in debug mode:
    EzCustomScrollView(
      slivers: [
        SliverList.builder(
          itemCount: 20,
          itemBuilder: (context, index) => ListTile(
            title: Text('Item $index'),
          ),
        ),
      ],
    ),
  ],
)
```

### 2. Horizontal Scroll inside a Row

```dart
Row(
  children: [
    const Text('Sidebar'),
    EzCustomScrollView(
      scrollDirection: Axis.horizontal,
      slivers: [
        SliverToBoxAdapter(
          child: Container(width: 300, color: Colors.blue),
        ),
      ],
    ),
  ],
)
```

### 3. Custom Fallback Dimensions & Telemetry Callback

```dart
EzCustomScrollView(
  fallbackHeight: 300.0,
  fallbackWidth: 250.0,
  showDebugIndicator: false, // Disables red border in debug mode
  onUnboundedDetected: ({
    required bool isWidthUnbounded,
    required bool isHeightUnbounded,
    required String culprit,
  }) {
    // Send diagnostics to your logging or telemetry service
    debugPrint('Unbounded layout caught in $culprit: width=$isWidthUnbounded, height=$isHeightUnbounded');
  },
  slivers: [
    SliverToBoxAdapter(child: Text('Custom bounded scroll')),
  ],
)
```

## Permanent Architectural Resolution

While `EzCustomScrollView` safely handles constraint failures, the recommended structural patterns in Flutter include:

```dart
// Option A: Provide flex expansion inside Column or Row
Column(
  children: [
    Expanded(
      child: EzCustomScrollView(
        slivers: [
          SliverGrid.count(
            crossAxisCount: 2,
            children: List.generate(20, (index) => Card(child: Center(child: Text('$index')))),
          ),
        ],
      ),
    ),
  ],
)

// Option B: Provide explicit bounding dimensions
SizedBox(
  height: 400,
  child: EzCustomScrollView(slivers: [...]),
)

// Option C: Use shrinkWrap for small, finite sliver sets
EzCustomScrollView(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  slivers: [...],
)
```

## API Reference

| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `slivers` | `List<Widget>` | `const <Widget>[]` | The slivers to place inside the viewport. |
| `scrollDirection` | `Axis` | `Axis.vertical` | Scrolling direction (`Axis.vertical` or `Axis.horizontal`). |
| `reverse` | `bool` | `false` | Whether to reverse scroll direction. |
| `controller` | `ScrollController?` | `null` | Controls the scroll position. |
| `primary` | `bool?` | `null` | Whether this is the primary scroll view. |
| `physics` | `ScrollPhysics?` | `null` | Scroll physics configuration. |
| `shrinkWrap` | `bool` | `false` | Whether the extent should wrap the contents. |
| `center` | `Key?` | `null` | First child in the growth direction. |
| `anchor` | `double` | `0.0` | Relative position of the zero scroll offset. |
| `showDebugIndicator` | `bool` | `true` | Shows a red outline border in debug mode when unbounded. |
| `fallbackWidth` | `double?` | `null` | Explicit fallback width when horizontal dimension is unbounded. |
| `fallbackHeight` | `double?` | `null` | Explicit fallback height when vertical dimension is unbounded. |
| `onUnboundedDetected` | `Function?` | `null` | Diagnostic callback invoked when an unbounded parent is encountered. |

## Sponsoring & Support

If this package saved you debugging time, consider supporting ongoing maintenance:
* [GitHub Sponsors](https://github.com/sponsors/Evgenii-Zinner/)
* [Thanks.dev](https://thanks.dev/u/gh/evgenii-zinner)
* [Buy Me a Coffee](https://buymeacoffee.com/evgeniizinner)

## License

MIT License. See [LICENSE](LICENSE) for details.
