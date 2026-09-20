# EZ Custom Scroll View

A **crash-safe, self-aware** drop-in replacement for Flutter's `CustomScrollView` that automatically handles unbounded constraints in `Column`, `Row`, `Flex`, and nested scroll views.

## 🛑 The Problem

Flutter's standard `CustomScrollView` attempts to expand to fill all available space along its scrolling axis. When placed inside a parent with **unbounded constraints**, Flutter throws a fatal runtime exception that crashes your app with a red screen:

*   Placing a vertical scroll view directly inside a **`Column`** or **`Flex`**.
*   Placing a horizontal scroll view directly inside a **`Row`** or **`Flex`**.
*   Nesting inside an unconstrained parent such as **`UnconstrainedBox`** or another unconstrained scroll view.

Common fatal errors in standard Flutter:
> "Vertical viewport was given unbounded height."  
> "Horizontal viewport was given unbounded width."  
> "RenderBox was not laid out: RenderViewport... NEEDS-PAINT NEEDS-COMPOSITING-BITS-UPDATE"

## ✅ The EZ Solution

`EzCustomScrollView` intercepts unbounded constraints before they cause a crash:

*   **Defensive Fallback Sizing:** Automatically calculates a safe, bounded dimension (e.g., 50% of available screen height/width) so the widget renders visibly and cleanly.
*   **Developer Diagnostics (Debug Mode):**
    *   Logs a structured, actionable `FlutterError` explaining the exact parent culprit (e.g., `Column`, `Row`, `UnconstrainedBox`) and how to permanently fix it.
    *   Highlights the problematic widget with a visible **red outline border** so developers instantly spot layout errors during development.
*   **Silent Protection (Release Mode):** Silently applies the fallback size so your end users never experience a red screen of death in production.
*   **100% Drop-in Parity:** Supports all standard `CustomScrollView` properties (`slivers`, `physics`, `controller`, `shrinkWrap`, `hitTestBehavior`, etc.).

## ✨ Features

*   **Omni-Directional Crash Prevention:** Safeguards both vertical (height) and horizontal (width) unbounded viewports.
*   **Culprit Ancestor Inspection:** Automatically inspects the widget tree to inform you which widget (`Column`, `Row`, `Flex`, etc.) caused the constraint violation.
*   **Customizable Fallbacks:** Override default screen-percentage fallback sizing with `fallbackHeight` and `fallbackWidth`.
*   **Diagnostic Telemetry:** Optional `onUnboundedDetected` callback for custom logging, analytics, or assertions.
*   **Zero External Dependencies:** Built entirely with Flutter framework primitives.

## 📦 Installation

```shell
flutter pub add ez_custom_scroll_view
```

## 🚀 Usage

Simply replace `CustomScrollView` with `EzCustomScrollView`.

### 1. Vertical Example (Safe inside Column)
In standard Flutter, this causes an instant crash. With `EzCustomScrollView`, it safely renders and alerts you in the debug console:
```dart
Column(
  children: [
    const Text('Header'),
    EzCustomScrollView(
      slivers: [
        SliverList.builder(
          itemCount: 20,
          itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
        ),
      ],
    ),
  ],
)
```

### 2. Horizontal Example (Safe inside Row)
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

### 3. Recommended Production Fix
While `EzCustomScrollView` prevents crashes, best practice in production is to provide bounded constraints using `Expanded` or explicit dimensions:
```dart
Column(
  children: [
    const Text('Header'),
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
```

### 4. Custom Fallback & Diagnostic Callback
```dart
EzCustomScrollView(
  fallbackHeight: 300.0,
  fallbackWidth: 250.0,
  showDebugIndicator: true,
  onUnboundedDetected: ({required isWidthUnbounded, required isHeightUnbounded, required culprit}) {
    debugPrint('Layout warning: Unbounded dimension in $culprit');
  },
  slivers: [
    SliverToBoxAdapter(child: Text('Custom bounded scroll')),
  ],
)
```

## 🤝 Contributing

Contributions are welcome! Please feel free to open an issue or submit a pull request on [GitHub](https://github.com/Evgenii-Zinner/ez-custom-scroll-view).

## 📜 License

MIT License - see the [LICENSE](LICENSE) file for details.
