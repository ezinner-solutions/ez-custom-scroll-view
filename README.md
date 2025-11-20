# EzCustomScrollView

A defensive, self-aware version of `CustomScrollView` that won't crash when placed in an unbounded-height or unbounded-width parent.

## Problem

Flutter's `CustomScrollView` (and `ListView`, `GridView`) requires a bounded height (or width, depending on scroll direction) to function correctly. If you place it inside a widget that provides infinite constraints, such as a `Column`, `Row`, or an unbounded `Flex`, it will cause a layout crash.

This is a common issue, especially for developers new to Flutter. The standard fix is to wrap the scroll view in an `Expanded` or `SizedBox` widget.

## Solution

`EzCustomScrollView` is a drop-in replacement for `CustomScrollView` that automatically detects when it is placed in an unbounded environment (height or width).

-   **In Debug Mode:** It displays a red border around the widget and prints a detailed error message to the console, explaining exactly what is wrong and how to fix it (e.g., "Wrap EzCustomScrollView in an Expanded widget").
-   **In Release Mode:** It silently applies a safe fallback (rendering a `SizedBox` with a default or calculated size) to prevent the app from crashing.

## Features

-   **Crash Prevention:** Automatically handles unbounded height and width constraints.
-   **Debug-Friendly:** Provides visual feedback (red border) and detailed error messages in the console.
-   **Drop-in Replacement:** Supports the same properties as `CustomScrollView` (`slivers`, `controller`, `physics`, etc.).
-   **Zero Dependencies:** Lightweight and easy to include in any project.

## Usage

Replace `CustomScrollView` with `EzCustomScrollView`:

```dart
// Before (might crash in a Column)
CustomScrollView(
  slivers: [
    SliverAppBar(title: Text('Title')),
    SliverList(delegate: SliverChildBuilderDelegate(...)),
  ],
);

// After (safe)
EzCustomScrollView(
  slivers: [
    SliverAppBar(title: Text('Title')),
    SliverList(delegate: SliverChildBuilderDelegate(...)),
  ],
);
```

### Example: The "Correct" Fix

While `EzCustomScrollView` prevents crashes, the best practice is still to provide bounded constraints. The widget helps you identify where this is needed.

```dart
Column(
  children: [
    Text('Header'),
    // Use Expanded to give the scroll view the remaining space
    Expanded(
      child: EzCustomScrollView(
        slivers: [
          // ... your slivers
        ],
      ),
    ),
  ],
)
```

## Contributing

Contributions are welcome! Please feel free to open an issue or submit a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
