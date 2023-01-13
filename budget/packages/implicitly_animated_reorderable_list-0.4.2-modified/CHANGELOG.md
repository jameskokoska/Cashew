## 0.4.2
* **Fixed** #54, #72

## 0.4.0
* **Added** NNBD support
* **Fixed** #19, #49, #50, #52
* **Improved** `Handle` is now able to capture pointer events which allows an `ImplicitlyAnimatedReorderableList` to be placed inside another scrollable without any workarounds.
* **Breaking** Renamed `dragDuration` to `reorderDuration`
* **Added** Field `liftDuration`
* **Added** Field `settleDuration`

## 0.3.2

* **Fixed** #47

## 0.3.1

* **Fixed** #43
* **Fixed** Changelog

## 0.3.0

* **Fixed** #23

## 0.2.5

* **Fixed** #14

## 0.2.1

* **Improved** `ImplicitlyAnimatedList` now always uses the latest items, even if `listEquals()` is `true`.

## 0.2.0

* **Added** support for headers and footers on the `ImplicitlyAnimatedReorderableList`.
* **Added** `child` property on `Reorderable` that can be used instead off the `builder` that will use a default elevation animation instead of being forced to specify your own custom animation.

## 0.1.10

* **Fixed** Bugs

## 0.1.4

* **Improved** `Handle` is now scroll aware and only initiates a drag when the scroll position didn't change.
* **Added** horizontal scrollDirection support for `ImplicitlyAnimatedReorderableList`

## 0.1.0

* Initial release
