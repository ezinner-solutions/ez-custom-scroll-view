# EZ Custom Scroll View

A **crash-safe, self-aware** replacement for `CustomScrollView` that prevents layout errors in `Column`, `Row`, `Flex`, and nested scroll views.

## 🛑 The Problem

Flutter's `CustomScrollView` tries to expand to fill all available space in its scroll direction. When placed inside a parent with **unbounded constraints**, it breaks the layout.

Common scenarios that cause this crash:
*   Placing a vertical scroll view inside a **`Column`**.
*   Placing a horizontal scroll view inside a **`Row`**.
*   Nesting it inside another **`ListView`**, **`CustomScrollView`**, or **`SingleChildScrollView`** (NestedListView scenario).
*   Using it inside a **`Flex`** or unconstrained **`Card`**.

Instead of a simple error, this often breaks the build process, causing the UI to vanish and spamming the console with:
> "Vertical viewport was given unbounded height."
> "RenderBox was not laid out: RenderViewport... NEEDS-PAINT NEEDS-COMPOSITING-BITS-UPDATE"
> "Failed assertion: ... 'hasSize'"

## ✅ The EZ Solution

`EzCustomScrollView` is a defensive wrapper that detects these unbounded constraints before they cause damage:

*   **Auto-Detection:** Instantly identifies if it's in a `Column`, `Row`, or other unbounded parent.
*   **Crash Prevention:** Automatically applies a safe, bounded size to ensure the widget renders visible content instead of breaking.
*   **Developer Feedback:**
    *   **Debug Mode:** Displays a **red border** and logs a clear warning identifying the exact parent causing the issue (e.g., "Unbounded height detected in Column").
    *   **Release Mode:** Silently fixes the layout so your users never see a broken screen.

## ✨ Features

*   **Drop-in Replacement:** Same API as `CustomScrollView`.
*   **Omni-Directional Safety:** Handles both unbounded height (Vertical) and width (Horizontal).
*   **SEO & Discoverability:** Solves issues with `Column`, `Row`, `NestedListView`, `Flex`, and `Card`.
*   **Zero Dependencies:** Lightweight and pure Flutter.

## 📦 Installation

```shell
flutter pub add ez_custom_scroll_view
```

## 🚀 Usage

Simply replace `CustomScrollView` with `EzCustomScrollView`.

### Vertical Example (Safe in Column)
```dart
Column(
  children: [
    Text('Header'),
    EzCustomScrollView(
      slivers: [
        SliverList(delegate: SliverChildListDelegate([])),
      ],
    ),
  ],
)
```

### Horizontal Example (Safe in Row)
```dart
Row(
  children: [
    Text('Label'),
    EzCustomScrollView(
      scrollDirection: Axis.horizontal,
      slivers: [
        SliverList(delegate: SliverChildListDelegate([])),
      ],
    ),
  ],
)
```

## 🤝 Contributing

Contributions are welcome! Please feel free to open an issue or submit a pull request on [GitHub](https://github.com/Evgenii-Zinner/ez_custom_scroll_view).

## 📜 License

MIT License - see the [LICENSE](LICENSE) file for details.
