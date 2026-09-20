## 0.0.4

* **Refactor:** Improved constraint detection, DRY scrollview instantiation, and structured layout logic using `_EzCustomScrollViewHelper`.
* **Feature:** Added `fallbackHeight`, `fallbackWidth`, and `showDebugIndicator` properties for customizable defensive behavior.
* **Feature:** Added `onUnboundedDetected` diagnostic callback and enhanced ancestor culprit detection (`Column`, `Row`, `Flex`, `Wrap`, `UnconstrainedBox`).
* **Feature:** Added `hitTestBehavior` and Flutter 3.41+ `scrollCacheExtent` forward compatibility.
* **Test:** Added comprehensive unit and widget test suite covering bounded/unbounded layouts, custom sizing, debug indicators, and drop-in properties.
* **Docs:** Aligned documentation with Effective Dart standards.

## 0.0.3

* Refactor: Improve code formatting and repository links

## 0.0.2

* **Docs:** Added `FUNDING.yml` and updated `pubspec.yaml` metadata.
* **Docs:** Refined `README.md` for better clarity and SEO.
* **Example:** Added comprehensive example app with Forms and validation.

## 0.0.1

* Initial release: A defensive, self-aware version of `CustomScrollView` that handles unbounded constraints.
