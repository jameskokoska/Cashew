# Implicitly Animated Reorderable List

[![pub package](https://img.shields.io/pub/v/implicitly_animated_reorderable_list.svg)](https://pub.dartlang.org/packages/implicitly_animated_reorderable_list)
[![GitHub Stars](https://img.shields.io/github/stars/bxqm/implicitly_animated_reorderable_list.svg?logo=github)](https://github.com/bxqm/implicitly_animated_reorderable_list)

A Flutter `ListView` that implicitly calculates the changes between two lists using the `MyersDiff` algorithm and animates between them for you. The `ImplicitlyAnimatedReorderableList` adds reordering support to its items with fully custom animations.

<p style="text-align:center">
    <img width="356px" alt="Demo" src="https://raw.githubusercontent.com/bxqm/implicitly_animated_reorderable_list/master/assets/demo.gif"/>
</p>

Click [here](https://github.com/bxqm/implicitly_animated_reorderable_list/blob/master/example/lib/ui/) to view the full example.

## Installing

Add it to your `pubspec.yaml` file:
```yaml
dependencies:
  implicitly_animated_reorderable_list: ^0.4.2
```
Install packages from the command line
```
flutter packages get
```
If you like this package, consider supporting it by giving it a star on [GitHub](https://github.com/bxqm/implicitly_animated_reorderable_list) and a like on [pub.dev](https://pub.dev/packages/implicitly_animated_reorderable_list) :heart:

## Usage

The package contains two `ListViews`: `ImplicitlyAnimatedList` which is the base class and offers implicit animation for item `insertions`, `removals` as well as `updates`, and `ImplicitlyAnimatedReorderableList` which extends the `ImplicitlyAnimatedList` and adds reordering support to its items. See examples below on how to use them.

### ImplicitlyAnimatedList

`ImplicitlyAnimatedList` is based on `AnimatedList` and uses the `MyersDiff` algorithm to calculate the difference between two lists and calls `insertItem` and `removeItem` on the `AnimatedListState` for you. 

#### Example

```dart
// Specify the generic type of the data in the list.
ImplicitlyAnimatedList<MyGenericType>(
  // The current items in the list.
  items: items,
  // Called by the DiffUtil to decide whether two object represent the same item.
  // For example, if your items have unique ids, this method should check their id equality.
  areItemsTheSame: (a, b) => a.id == b.id,
  // Called, as needed, to build list item widgets.
  // List items are only built when they're scrolled into view.
  itemBuilder: (context, animation, item, index) {
    // Specifiy a transition to be used by the ImplicitlyAnimatedList.
    // See the Transitions section on how to import this transition.
    return SizeFadeTransition(
      sizeFraction: 0.7,
      curve: Curves.easeInOut,
      animation: animation,
      child: Text(item.name),
    ); 
  },
  // An optional builder when an item was removed from the list.
  // If not specified, the List uses the itemBuilder with 
  // the animation reversed.
  removeItemBuilder: (context, animation, oldItem) {
    return FadeTransition(
      opacity: animation,
      child: Text(oldItem.name),
    );
  },
);
```

> If you have a `CustomScrollView` you can use the `SliverImplicitlyAnimatedList`.

> As `AnimatedList` doesn't support item moves, a move is handled by removing the item from the old index and inserting it at the new index.

### ImplicitlyAnimatedReorderableList

`ImplicitlyAnimatedReorderableList` is based on `ImplicitlyAnimatedList` and adds reordering support to the list.

#### Example

```dart
ImplicitlyAnimatedReorderableList<MyGenericType>(
  items: items,
  areItemsTheSame: (oldItem, newItem) => oldItem.id == newItem.id,
  onReorderFinished: (item, from, to, newItems) {
    // Remember to update the underlying data when the list has been
    // reordered.
    setState(() {
      items
        ..clear()
        ..addAll(newItems);
    });
  },
  itemBuilder: (context, itemAnimation, item, index) {
    // Each item must be wrapped in a Reorderable widget.
    return Reorderable(
      // Each item must have an unique key.
      key: ValueKey(item),
      // The animation of the Reorderable builder can be used to
      // change to appearance of the item between dragged and normal
      // state. For example to add elevation when the item is being dragged.
      // This is not to be confused with the animation of the itemBuilder.
      // Implicit animations (like AnimatedContainer) are sadly not yet supported.
      builder: (context, dragAnimation, inDrag) {
        final t = dragAnimation.value;
        final elevation = lerpDouble(0, 8, t);
        final color = Color.lerp(Colors.white, Colors.white.withOpacity(0.8), t);

        return SizeFadeTransition(
          sizeFraction: 0.7,
          curve: Curves.easeInOut,
          animation: itemAnimation,
          child: Material(
            color: color,
            elevation: elevation,
            type: MaterialType.transparency,
            child: ListTile(
              title: Text(item.name),
              // The child of a Handle can initialize a drag/reorder.
              // This could for example be an Icon or the whole item itself. You can
              // use the delay parameter to specify the duration for how long a pointer
              // must press the child, until it can be dragged.
              trailing: Handle(
                delay: const Duration(milliseconds: 100),
                child: Icon(
                  Icons.list,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        );
      },
    );
  },
  // Since version 0.2.0 you can also display a widget
  // before the reorderable items...
  header: Container(
    height: 200,
    color: Colors.red,
  ),
  // ...and after. Note that this feature - as the list itself - is still in beta!
  footer: Container(
    height: 200,
    color: Colors.green,
  ),
  // If you want to use headers or footers, you should set shrinkWrap to true
  shrinkWrap: true,
);
```
> For a more in depth example click [here](https://github.com/bxqm/implicitly_animated_reorderable_list/blob/master/example/lib/ui/lang_page.dart).

### Transitions

You can use some custom transitions (such as the `SizeFadeTransition`) for item animations by importing the transitions pack:

```dart
import 'package:implicitly_animated_reorderable_list/transitions.dart';
```

If you want to contribute your own custom transitions, feel free to make a pull request.

### Caveats

Note that this package is still in its very early phase and not enough testing has been done to guarantee stability.  

Also note that computing the diff between two very large lists may take a significant amount of time (the computation is done on a background isolate though unless `spawnIsolate` is set to `false`).

### Acknowledgements

The diff algorithm that `ImplicitlyAnimatedList` uses was written by [Dawid Bota](https://gitlab.com/otsoaUnLoco) at [GitLab](https://gitlab.com/otsoaUnLoco/animated-stream-list).

### Roadmap

You can take a look at the [Roadmap](https://github.com/bxqm/implicitly_animated_reorderable_list/blob/master/roadmap.md) to see which featues I am working on or plan to implement in future versions.
