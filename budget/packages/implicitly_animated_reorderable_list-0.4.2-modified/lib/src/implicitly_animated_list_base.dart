import 'dart:async';

import 'package:async/async.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide AnimatedItemBuilder;
import 'package:implicitly_animated_reorderable_list/src/custom_sliver_animated_list.dart';

import 'src.dart';

typedef AnimatedItemBuilder<W extends Widget, E> = W Function(
    BuildContext context, Animation<double> animation, E item, int i);

typedef RemovedItemBuilder<W extends Widget, E> = W Function(
    BuildContext context, Animation<double> animation, E item);

typedef UpdatedItemBuilder<W extends Widget, E> = W Function(
    BuildContext context, Animation<double> animation, E item);

abstract class ImplicitlyAnimatedListBase<W extends Widget, E extends Object>
    extends StatefulWidget {
  /// Called, as needed, to build list item widgets.
  ///
  /// List items are only built when they're scrolled into view.
  final AnimatedItemBuilder<W, E> itemBuilder;

  /// An optional builder when an item was removed from the list.
  ///
  /// If not specified, the [ImplicitlyAnimatedList] uses the [itemBuilder] with
  /// the animation reversed.
  final RemovedItemBuilder<W, E>? removeItemBuilder;

  /// An optional builder when an item in the list was changed but not its position.
  ///
  /// The [UpdatedItemBuilder] animation will run from 1 to 0 and back to 1 again, while
  /// the item parameter will be the old item in the first half of the animation and the new item
  /// in the latter half of the animation. This allows you for example to fade between the old and
  /// the new item.
  ///
  /// If not specified, changes will appear instantaneously.
  final UpdatedItemBuilder<W, E>? updateItemBuilder;

  /// The data that this [ImplicitlyAnimatedList] should represent.
  final List<E> items;

  /// Called by the DiffUtil to decide whether two object represent the same Item.
  /// For example, if your items have unique ids, this method should check their id equality.
  final ItemDiffUtil<E> areItemsTheSame;

  /// The duration of the animation when an item was inserted into the list.
  final Duration insertDuration;

  /// The duration of the animation when an item was removed from the list.
  final Duration removeDuration;

  /// The duration of the animation when an item changed in the list.
  final Duration updateDuration;

  /// Whether to spawn a new isolate on which to calculate the diff on.
  ///
  /// Usually you wont have to specify this value as the MyersDiff implementation will
  /// use its own metrics to decide, whether a new isolate has to be spawned or not for
  /// optimal performance.
  final bool? spawnIsolate;
  const ImplicitlyAnimatedListBase({
    Key? key,
    required this.items,
    required this.areItemsTheSame,
    required this.itemBuilder,
    required this.removeItemBuilder,
    required this.updateItemBuilder,
    required this.insertDuration,
    required this.removeDuration,
    required this.updateDuration,
    required this.spawnIsolate,
  }) : super(key: key);
}

abstract class ImplicitlyAnimatedListBaseState<W extends Widget,
        B extends ImplicitlyAnimatedListBase<W, E>, E extends Object>
    extends State<B> with DiffCallback<E>, TickerProviderStateMixin {
  @protected
  GlobalKey<CustomSliverAnimatedListState> animatedListKey = GlobalKey();

  @nonVirtual
  @protected
  CustomSliverAnimatedListState get list => animatedListKey.currentState!;

  late final DiffDelegate _delegate = DiffDelegate(this);
  CancelableOperation? _diffOperation;

  // Animation controller for custom animation that are not supported
  // by the [AnimatedList], like updates.
  late final updateAnimController = AnimationController(vsync: this);
  late final Animation<double> updateAnimation = TweenSequence([
    TweenSequenceItem(
      tween: Tween(begin: 1.0, end: 0.0),
      weight: 0.5,
    ),
    TweenSequenceItem(
      tween: Tween(begin: 0.0, end: 1.0),
      weight: 0.5,
    ),
  ]).animate(updateAnimController);

  // The currently active items.
  late List<E> _data = List<E>.from(widget.items);
  List<E> get data => _data;
  // The items that have newly come in that
  // will get diffed into the dataset.
  late List<E> _newItems = List<E>.from(widget.items);
  // The previous dataSet.
  late List<E> _oldItems = List<E>.from(data);
  //
  Completer<int>? _mutex;

  @nonVirtual
  @override
  List<E> get newList => _newItems;

  @nonVirtual
  @override
  List<E> get oldList => _oldItems;

  final Map<E, E> _changes = {};

  @nonVirtual
  @protected
  Map<E, E> get changes => _changes;

  @nonVirtual
  @protected
  AnimatedItemBuilder<W, E> get itemBuilder => widget.itemBuilder;
  @nonVirtual
  @protected
  RemovedItemBuilder<W, E>? get removeItemBuilder => widget.removeItemBuilder;
  @nonVirtual
  @protected
  UpdatedItemBuilder<W, E>? get updateItemBuilder => widget.updateItemBuilder;

  @override
  void initState() {
    super.initState();

    didUpdateWidget(widget);
  }

  @override
  void didUpdateWidget(ImplicitlyAnimatedListBase oldWidget) {
    super.didUpdateWidget(oldWidget as B);

    updateAnimController.duration = widget.updateDuration;

    _updateList();
  }

  Future<void> _updateList() async {
    await _mutex?.future;

    _newItems = List<E>.from(widget.items);
    _oldItems = List<E>.from(data);

    _calcDiffs();
  }

  Future<void> _calcDiffs() async {
    if (!mounted) return;

    // Don't check for too long lists the list equality as
    // this would begin to take longer than the diff
    // algorithm itself.
    final areListsShortEnoughForEqualityCheck =
        _oldItems.length < 100 && _newItems.length < 100;
    final areListsEqual =
        areListsShortEnoughForEqualityCheck && listEquals(_oldItems, _newItems);

    if (!areListsEqual) {
      _changes.clear();

      await _diffOperation?.cancel();
      _diffOperation = CancelableOperation.fromFuture(
        MyersDiff.withCallback<E>(this, spawnIsolate: widget.spawnIsolate),
      );

      _diffOperation?.then((diffs) {
        // diffs is null when the operation
        // gets canceled.
        if (diffs == null || !mounted) {
          return;
        }

        _delegate.applyDiffs(diffs);
        _data = List<E>.from(_newItems);

        updateAnimController
          ..reset()
          ..forward();

        setState(() {});
      });
    } else {
      // Always update the list with the newest data,
      // even if the lists have the same value equality.
      _data = List<E>.from(_newItems);
    }
  }

  @nonVirtual
  @protected
  @override
  bool areContentsTheSame(E oldItem, E newItem) => true;

  @nonVirtual
  @protected
  @override
  bool areItemsTheSame(E oldItem, E newItem) =>
      widget.areItemsTheSame(oldItem, newItem);

  @mustCallSuper
  @protected
  @override
  void onInserted(int index, E item) =>
      list.insertItem(index, duration: widget.insertDuration);

  @mustCallSuper
  @protected
  @override
  void onRemoved(int index) {
    if (index >= oldList.length) return;

    final item = oldList[index];

    list.removeItem(
      index,
      (context, animation) =>
          removeItemBuilder?.call(context, animation, item) ??
          itemBuilder(context, animation, item, index),
      duration: widget.removeDuration,
    );
  }

  @mustCallSuper
  @protected
  @override
  void onChanged(int startIndex, List<E> itemsChanged) {
    int i = 0;
    for (final item in itemsChanged) {
      final index = startIndex + i;
      if (index >= data.length) continue;

      _changes[item] = data[index];
      i++;
    }
  }

  @nonVirtual
  @protected
  Widget buildItem(
      BuildContext context, Animation<double> animation, E item, int index) {
    if (updateItemBuilder != null && changes[item] != null) {
      return buildUpdatedItemWidget(item);
    }

    return itemBuilder(context, animation, item, index);
  }

  @protected
  Widget buildUpdatedItemWidget(E newItem) {
    final oldItem = _changes[newItem];

    return AnimatedBuilder(
      animation: updateAnimation,
      builder: (context, _) {
        final value = updateAnimController.value;
        final item = value < 0.5 ? oldItem : newItem;

        return updateItemBuilder!(context, updateAnimation, item!);
      },
    );
  }

  @override
  void dispose() {
    updateAnimController.dispose();
    super.dispose();
  }
}
