import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart' hide AnimatedItemBuilder;
import 'package:implicitly_animated_reorderable_list/src/custom_sliver_animated_list.dart';

import 'src.dart';

typedef ReorderStartedCallback<E> = void Function(E item, int index);

typedef ReorderFinishedCallback<E> = void Function(
    E item, int from, int to, List<E> newItems);

/// A Flutter ListView that implicitly animates between the changes of two lists with
/// the support to reorder its items.
class ImplicitlyAnimatedReorderableList<E extends Object>
    extends ImplicitlyAnimatedListBase<Reorderable, E> {
  /// Whether the scroll view scrolls in the reading direction.
  ///
  /// Defaults to false.
  final bool reverse;

  /// The axis along which the scroll view scrolls.
  ///
  /// Defaults to [Axis.vertical].
  final Axis scrollDirection;

  /// An object that can be used to control the position to which this scroll
  /// view is scrolled.
  ///
  /// Must be null if [primary] is true.
  ///
  /// A [ScrollController] serves several purposes. It can be used to control
  /// the initial scroll position (see [ScrollController.initialScrollOffset]).
  /// It can be used to control whether the scroll view should automatically
  /// save and restore its scroll position in the [PageStorage] (see
  /// [ScrollController.keepScrollOffset]). It can be used to read the current
  /// scroll position (see [ScrollController.offset]), or change it (see
  /// [ScrollController.animateTo]).
  final ScrollController? controller;

  /// Whether this is the primary scroll view associated with the parent
  /// [PrimaryScrollController].
  ///
  /// On iOS, this identifies the scroll view that will scroll to top in
  /// response to a tap in the status bar.
  ///
  /// Defaults to true when [scrollDirection] is [Axis.vertical] and
  /// [controller] is null.
  final bool? primary;

  /// How the scroll view should respond to user input.
  ///
  /// For example, determines how the scroll view continues to animate after the
  /// user stops dragging the scroll view.
  ///
  /// Defaults to matching platform conventions.
  final ScrollPhysics? physics;

  /// Whether the extent of the scroll view in the [scrollDirection] should be
  /// determined by the contents being viewed.
  ///
  /// If the scroll view does not shrink wrap, then the scroll view will expand
  /// to the maximum allowed size in the [scrollDirection]. If the scroll view
  /// has unbounded constraints in the [scrollDirection], then [shrinkWrap] must
  /// be true.
  ///
  /// Shrink wrapping the content of the scroll view is significantly more
  /// expensive than expanding to the maximum allowed size because the content
  /// can expand and contract during scrolling, which means the size of the
  /// scroll view needs to be recomputed whenever the scroll position changes.
  ///
  /// Defaults to false.
  final bool shrinkWrap;

  /// The amount of space by which to inset the children.
  final EdgeInsetsGeometry? padding;

  /// The duration of the animation when an item is being translated
  /// to a new position in the list, i.e. when the item is reordered.
  final Duration reorderDuration;

  /// The duration of the animation when a reorder has been initiated
  /// by the [Handle] of the item.
  ///
  /// Defaults to [reorderDuration].
  final Duration liftDuration;

  /// The duration of the animation when an item is released and settles
  /// to its final destination in the list.
  ///
  /// Defaults to [liftDuration].
  final Duration settleDuration;

  /// Called in response to when an item changed from normal to dragged
  /// state and may be reordered.
  final ReorderStartedCallback<E>? onReorderStarted;

  /// Called in response to when the dragged item has been released
  /// and animated to its final destination. Here you should update
  /// the underlying data in your model/bloc/database etc.
  ///
  /// The `item` parameter of the callback is the item that has been reordered
  /// `from` index `to` index. The `data` parameter represents the new data with
  /// the item already being correctly reordered.
  ///
  /// Note that this will also be called when the item didn't change its index in
  /// the list (i.e. the user canceled the reorder).
  ///
  /// This parameter should not be null.
  final ReorderFinishedCallback<E> onReorderFinished;

  /// A non-reorderable widget displayed at the top.
  ///
  /// This can be useful if you want to show content before
  /// the reorderable items without needing to nest the
  /// list in another `Scrollable` and thereby loose out
  /// on performance and autoscrolling.
  final Widget? header;

  /// A non-reorderable widget displayed at the bottom.
  ///
  /// This can be useful if you want to show content after
  /// the reorderable items without needing to nest the
  /// list in another `Scrollable` and thereby loose out
  /// on performance and autoscrolling.
  final Widget? footer;

  /// Creates a Flutter ListView that implicitly animates between the changes of two lists with
  /// the support to reorder its items.
  ///
  /// The [items] parameter represents the current items that should be displayed in
  /// the list.
  ///
  /// The [itemBuilder] callback is used to build each child as needed. The parent must
  /// be a [Reorderable] widget.
  ///
  /// The [areItemsTheSame] callback is called by the DiffUtil to decide whether two objects
  /// represent the same item. For example, if your items have unique ids, this method should
  /// check their id equality.
  ///
  /// The [onReorderFinished] callback is called in response to when the dragged item has
  /// been released and animated to its final destination. Here you should update
  /// the underlying data in your model/bloc/database etc.
  ///
  /// The [spawnIsolate] flag indicates whether to spawn a new isolate on which to
  /// calculate the diff between the lists. Usually you wont have to specify this
  /// value as the MyersDiff implementation will use its own metrics to decide, whether
  /// a new isolate has to be spawned or not for optimal performance.
  const ImplicitlyAnimatedReorderableList({
    Key? key,
    required List<E> items,
    required AnimatedItemBuilder<Reorderable, E> itemBuilder,
    required ItemDiffUtil<E> areItemsTheSame,
    RemovedItemBuilder<Reorderable, E>? removeItemBuilder,
    UpdatedItemBuilder<Reorderable, E>? updateItemBuilder,
    Duration insertDuration = const Duration(milliseconds: 500),
    Duration removeDuration = const Duration(milliseconds: 500),
    Duration updateDuration = const Duration(milliseconds: 500),
    Duration? liftDuration,
    Duration? settleDuration,
    bool? spawnIsolate,
    this.reverse = false,
    this.scrollDirection = Axis.vertical,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.reorderDuration = const Duration(milliseconds: 300),
    this.onReorderStarted,
    required this.onReorderFinished,
    this.header,
    this.footer,
  })  : liftDuration = liftDuration ?? reorderDuration,
        settleDuration = settleDuration ?? liftDuration ?? reorderDuration,
        assert(
          reorderDuration <= const Duration(milliseconds: 1500),
          'The drag duration should not be longer than 1500 milliseconds.',
        ),
        super(
          key: key,
          items: items,
          itemBuilder: itemBuilder,
          areItemsTheSame: areItemsTheSame,
          removeItemBuilder: removeItemBuilder,
          updateItemBuilder: updateItemBuilder,
          insertDuration: insertDuration,
          removeDuration: removeDuration,
          updateDuration: updateDuration,
          spawnIsolate: spawnIsolate,
        );

  @override
  ImplicitlyAnimatedReorderableListState<E> createState() =>
      ImplicitlyAnimatedReorderableListState<E>();

  static ImplicitlyAnimatedReorderableListState? of(BuildContext context) {
    return context
        .findAncestorStateOfType<ImplicitlyAnimatedReorderableListState>();
  }
}

class ImplicitlyAnimatedReorderableListState<E extends Object>
    extends ImplicitlyAnimatedListBaseState<Reorderable,
        ImplicitlyAnimatedReorderableList<E>, E> {
  // The key of the custom scroll view.
  final GlobalKey _listKey = GlobalKey(debugLabel: 'list_key');
  // The key of the draggedItem.
  final GlobalKey _dragKey = GlobalKey(debugLabel: 'drag_key');

  // The key of the header.
  final GlobalKey _headerKey = GlobalKey(debugLabel: 'header_key');
  bool get hasHeader => widget.header != null;
  double _headerHeight = 0.0;

  // The key of the footer.
  final GlobalKey _footerKey = GlobalKey(debugLabel: 'footer_key');
  bool get hasFooter => widget.footer != null;
  double _footerHeight = 0.0;

  Timer? _scrollAdjuster;
  ScrollController? _controller;
  ScrollController? get scrollController => _controller;

  _Item? dragItem;
  Widget? _dragWidget;
  VoidCallback? _onDragEnd;

  bool get isVertical => widget.scrollDirection != Axis.horizontal;

  double _listSize = 0.0;
  double get scrollOffset => _canScroll ? _controller!.offset : 0.0;
  double get _maxScrollOffset => _controller?.position.maxScrollExtent ?? 0.0;
  double get _scrollDelta => scrollOffset - _dragStartScrollOffset;
  bool get _canScroll => _maxScrollOffset > 0.0;

  bool get _up => _dragDelta.isNegative;

  // Whether there is an item in the list that is currently being
  // dragged/reordered.
  bool _inDrag = false;
  bool get inDrag => _inDrag;
  // Whether there is an item in the list that is currently being
  // reordered or moving towards its destination position.
  bool _inReorder = false;
  bool get inReorder => _inReorder;

  double _dragStartOffset = 0.0;
  double _dragStartScrollOffset = 0.0;
  Key? get dragKey => dragItem?.key;
  int? get _dragIndex => dragItem?.index;
  double get _dragStart => dragItem!.start + _dragDelta;
  double get _dragEnd => dragItem!.end + _dragDelta;
  // double get _dragCenter => dragItem.middle + _dragDelta;
  double get _dragSize => isVertical ? dragItem!.height : dragItem!.width;

  final ValueNotifier<double> _dragDeltaNotifier = ValueNotifier(0.0);
  double get _dragDelta => _dragDeltaNotifier.value;
  set _dragDelta(double value) => _dragDeltaNotifier.value = value;

  final ValueNotifier<double> _pointerDeltaNotifier = ValueNotifier(0.0);
  double get _pointerDelta => _pointerDeltaNotifier.value;
  set _pointerDelta(double value) => _pointerDeltaNotifier.value = value;

  final Map<Key?, GlobalKey> _keys = {};
  final Map<Key?, ReorderableState> _items = {};
  final Map<Key?, AnimationController> _itemTranslations = {};
  final Map<Key?, _Item> _itemBoxes = {};

  @override
  void initState() {
    super.initState();
    // The list must have a ScrollController in order to adjust the
    // scroll position when the user drags an item outside the
    // current viewport.
    _controller = widget.controller ?? ScrollController();

    _addReorderableUpdateAnimationSupport();
  }

  @override
  void didUpdateWidget(ImplicitlyAnimatedReorderableList<E> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != null && widget.controller != _controller) {
      _controller = widget.controller;
    }
  }

  void onDragStarted(Key? key) {
    _onDragEnd?.call();

    _measureChild(key);
    dragItem = _itemBoxes[key];

    if (_dragIndex != null) {
      final offset = _itemOffset(key);
      _dragStartOffset = isVertical ? offset!.dy : offset!.dx;
      _dragStartScrollOffset = scrollOffset;

      _items[key]?.duration = widget.liftDuration;

      setState(() {
        _inDrag = true;
        _inReorder = true;
      });

      widget.onReorderStarted?.call(data[_dragIndex!], _dragIndex!);

      _adjustScrollPositionWhenNecessary();
    }
  }

  void onDragUpdated(double delta) {
    if (dragKey == null || dragItem == null) return;

    // Allow the dragged item to be overscrolled to allow for
    // continous scrolling while in drag.
    final overscrollBound =
        _canScroll && !(hasHeader || hasFooter) ? _dragSize : 0;
    // Constrain the dragged item to the bounds of the list.
    const epsilon = 2.0;
    final minDelta = (_headerHeight - (dragItem!.start + overscrollBound)) -
        _scrollDelta -
        epsilon;
    final maxDelta = ((_maxScrollOffset + _listSize + overscrollBound) -
            (dragItem!.bottom + _footerHeight)) -
        _scrollDelta +
        epsilon;

    _pointerDelta = delta.clamp(minDelta, maxDelta);
    _dragDelta = _pointerDelta + _scrollDelta;

    _adjustItemTranslations();
  }

  /// Adjust translations for all items that are not being dragged.
  ///
  /// All non-drag items can be in one of two states:
  /// 1. Not translated (original position)
  /// 2. Translated (to up or down)
  ///
  /// If some items index is smaller than _dragIndex,
  /// the position of the item can move to 1 space down or stay in place.
  ///
  /// If some items index is bigger than _dragIndex,
  /// the position of the item can move to 1 space up or stay in place.
  void _adjustItemTranslations() {
    for (final item in _itemBoxes.values) {
      if (item == dragItem) continue;

      final key = item.key;
      if (_itemTranslations[key]?.isAnimating == true) continue;

      final translation = getTranslation(key);

      final index = item.index!;
      final itemStart = item.start + translation;
      final itemEnd = item.end + translation;

      if (index < _dragIndex!) {
        if (itemStart >= _dragStart && translation == 0) {
          _dispatchMove(key, _dragSize);
        } else if (itemEnd <= _dragEnd && translation != 0) {
          _dispatchMove(key, 0);
        }
      } else if (index > _dragIndex!) {
        if (itemStart >= _dragStart && translation != 0) {
          _dispatchMove(key, 0);
        } else if (itemEnd <= _dragEnd && translation == 0) {
          _dispatchMove(key, -_dragSize);
        }
      }
    }
  }

  void _dispatchMove(Key? key, double delta,
      {VoidCallback? onEnd, Duration? duration}) {
    double value = 0.0;

    // Remove and stop the old controller if there was one
    // and start from the value where it left off.
    final oldController = _itemTranslations.remove(key);
    if (oldController != null) {
      value = oldController.value;

      oldController
        ..stop()
        ..dispose();
    }

    final start = min(value, delta);
    final end = max(value, delta);

    final controller = AnimationController(
      vsync: this,
      value: value,
      lowerBound: start,
      upperBound: end,
      duration: duration ?? widget.reorderDuration,
    );

    if (controller.upperBound == controller.lowerBound) {
      onEnd?.call();
      return;
    }

    _items[key]?.setTranslation(controller);
    _itemTranslations[key] = controller;

    // ignore: avoid_single_cascade_in_expression_statements
    controller.animateTo(
      delta,
      curve: Curves.easeInOut,
    )..whenCompleteOrCancel(
        () => onEnd?.call(),
      );
  }

  void _adjustScrollPositionWhenNecessary() {
    if (!_canScroll) return;

    _scrollAdjuster?.cancel();
    _scrollAdjuster = Timer.periodic(const Duration(milliseconds: 16), (_) {
      final start = _headerHeight;
      final end = _maxScrollOffset - _footerHeight;
      final isAtStart = _up && scrollOffset < start;
      final isAtEnd = !_up && scrollOffset > end;
      if (isAtStart || isAtEnd) {
        return;
      }

      final dragBox = _dragKey.renderBox;
      if (dragBox == null) return;

      final dragOffset =
          dragBox.localToGlobal(Offset.zero, ancestor: context.renderBox);
      final dragItemStart = isVertical ? dragOffset.dy : dragOffset.dx;
      final dragItemEnd = dragItemStart + _dragSize;

      double? delta;
      if (dragItemStart <= 0) {
        delta = dragItemStart;
      } else if (dragItemEnd >= _listSize) {
        delta = dragItemEnd - _listSize;
      }

      if (delta != null) {
        final atLowerBound = dragItemStart <= 0;
        delta = (delta.abs() / _dragSize).clamp(0.1, 1.0);

        const maxSpeed = 20;
        final max = atLowerBound ? -maxSpeed : maxSpeed;
        var newOffset = scrollOffset + (max * delta);

        if (!(scrollOffset < start) && !(scrollOffset > end)) {
          newOffset = newOffset.clamp(start, end);
        }

        _controller!.jumpTo(newOffset);
        onDragUpdated(_pointerDelta);
      }
    });
  }

  void onDragEnded() {
    if (dragKey == null) return;

    final target = findDropTargetItem();

    _onDragEnd = () {
      if (_dragIndex != null) {
        if (!_itemBoxes.containsKey(target!.key)) {
          _measureChild(target.key);
        }

        final toIndex = _itemBoxes[target.key]?.index;
        if (toIndex != null) {
          final E item = data.removeAt(_dragIndex!);
          data.insert(toIndex, item);

          widget.onReorderFinished(
            item,
            _dragIndex!,
            toIndex,
            List<E>.from(data),
          );
        }
      }

      _cancelReorder();
    };

    _items[dragKey]?.duration = widget.settleDuration;

    final delta = () {
      if (target == dragItem) {
        return -_pointerDelta;
      } else if (_up) {
        return target!.start - _dragStart;
      } else {
        return target!.end - _dragEnd;
      }
    }();

    _dispatchMove(
      dragKey,
      // Make sure not to pass a zero delta (i.e. the item didn't move)
      // as this would lead to the same upper and lower bound on the animation
      // controller, which is not allowed.
      delta != 0.0 ? delta : 0.5,
      onEnd: _onDragEnd,
      duration: widget.settleDuration,
    );

    avoidConflictingMoves(target);

    _scrollAdjuster?.cancel();

    setState(() => _inDrag = false);
  }

  _Item? findDropTargetItem() {
    _Item? target = dragItem;

    // Boxes are in the order in which they are build, not
    // necessarily index based.
    final boxes = _itemBoxes.values.toList()
      ..sort((a, b) => a.index!.compareTo(b.index!));

    for (final box in boxes) {
      // Dont apply any translation to the currently dragged
      // item (#56)
      final t = box == dragItem ? 0.0 : getTranslation(box.key);

      if (_up) {
        if (_dragStart <= (box.start + t)) {
          return box;
        }
      } else {
        if (_dragEnd >= (box.end + t)) {
          target = box;
        }
      }
    }

    return target;
  }

  void avoidConflictingMoves(_Item? target) {
    _itemTranslations.forEach((key, controller) {
      final item = _itemBoxes[key];

      if (item != dragItem && item != target) {
        if (item!.index! < target!.index!) {
          controller.reverse();
        } else {
          controller.forward();
        }
      }
    });
  }

  @override
  void onRemoved(int index) {
    super.onRemoved(index);

    // When the item that is being reordered is removed,
    // cancel the reorder operation.
    if (index == _dragIndex) {
      _cancelReorder();
    }
  }

  void _cancelReorder() {
    setState(() {
      _inDrag = false;
      _inReorder = false;
      dragItem = null;
      _onDragEnd = null;
      _dragWidget = null;
      _dragDelta = 0.0;
      _pointerDelta = 0.0;
      _scrollAdjuster?.cancel();

      for (final key in _itemTranslations.keys) {
        _items[key]?.setTranslation(null);
      }

      _itemTranslations.clear();
      _disposeDrag();
    });
  }

  void _disposeDrag() {
    _controller!.jumpTo(_controller!.position.pixels);
  }

  double getTranslation(Key? key) =>
      key == dragKey ? _dragDelta : _itemTranslations[key]?.value ?? 0.0;

  void registerItem(ReorderableState item) {
    _items[item.key] = item;
  }

  Offset? _itemOffset(Key? key) {
    return _items[key]?.context.renderBox?.localToGlobal(
          Offset.zero,
          ancestor: context.renderBox,
        );
  }

  bool _prevInDrag = false;

  void _onRebuild() {
    _itemBoxes.clear();

    final needsRebuild = _listSize == 0 || inDrag != _prevInDrag;
    _prevInDrag = inDrag;

    double getSizeOfKey(GlobalKey key) =>
        (isVertical ? key.height : key.width) ?? 0.0;

    postFrame(() {
      _listSize = getSizeOfKey(_listKey);
      _headerHeight = hasHeader ? getSizeOfKey(_headerKey) : 0.0;
      _footerHeight = hasFooter ? getSizeOfKey(_footerKey) : 0.0;

      if (needsRebuild && mounted) {
        setState(() {});
      }
    });
  }

  void _measureChild(Key? key, [int? index]) {
    final item = _items[key];
    if (item == null || !mounted || !item.mounted) {
      return;
    }

    final box = item.context.renderBox;
    final offset = _itemOffset(key)?.translate(
      isVertical ? 0 : scrollOffset,
      isVertical ? scrollOffset : 0,
    );

    if (box != null && offset != null) {
      final i = index ?? _itemBoxes[key]?.index;
      _itemBoxes[key] = _Item(key, box, i, offset, isVertical);
    }
  }

  @override
  Widget build(BuildContext context) {
    _onRebuild();

    final scrollView = CustomScrollView(
      key: _listKey,
      controller: _controller,
      scrollDirection: widget.scrollDirection,
      physics: inDrag ? const NeverScrollableScrollPhysics() : widget.physics,
      primary: widget.primary,
      reverse: widget.reverse,
      shrinkWrap: widget.shrinkWrap,
      slivers: <Widget>[
        if (hasHeader)
          SliverToBoxAdapter(
            child: Container(
              key: _headerKey,
              child: widget.header,
            ),
          ),
        SliverPadding(
          padding: widget.padding ?? EdgeInsets.zero,
          sliver: CustomSliverAnimatedList(
            // Assign the animation key to the sliver
            key: animatedListKey,
            initialItemCount: newList.length,
            itemBuilder: (context, index, animation) {
              final Reorderable reorderable = buildItem(
                context,
                animation,
                data[index],
                index,
              ) as Reorderable;

              postFrame(() => _measureChild(reorderable.key, index));

              // Assign a new GlobalKey to the Reorderable
              // so we can move it in and out of the list
              // without losing it's state.
              if (!_keys.containsKey(reorderable.key)) {
                _keys[reorderable.key] = GlobalKey(
                  debugLabel: reorderable.key.toString(),
                );
              }

              final child = KeyedSubtree(
                key: _keys[reorderable.key],
                child: reorderable,
              );

              if (dragKey != null && index == _dragIndex) {
                final size = dragItem?.size;

                // Determine if the dragged widget should be hidden
                // immidiately, or with on frame delay in order to
                // avoid item flash.
                final mustRebuild = _dragWidget == null;

                _dragWidget = child;
                if (mustRebuild) postFrame(() => setState(() {}));

                // The placeholder of the dragged item.
                //
                // Make sure not to use the actual widget but only its size
                // when they have been determined, as a widget is only allowed
                // to be laid out once.
                return Invisible(
                  invisible: !mustRebuild,
                  child: mustRebuild ? child : SizedBox.fromSize(size: size),
                );
              } else {
                return child;
              }
            },
          ),
        ),
        if (hasFooter)
          SliverToBoxAdapter(
            child: Container(
              key: _footerKey,
              child: widget.footer,
            ),
          ),
      ],
    );

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        scrollView,
        if (_dragWidget != null) _buildDraggedItem(),
      ],
    );
  }

  Widget _buildDraggedItem() {
    final EdgeInsets listPadding =
        widget.padding as EdgeInsets? ?? EdgeInsets.zero;

    return ValueListenableBuilder<double>(
      // ignore: sort_child_properties_last
      child: _dragWidget,
      valueListenable: _pointerDeltaNotifier,
      builder: (context, pointer, dragWidget) {
        final delta = _dragStartOffset + pointer;
        final dx = isVertical ? 0.0 : delta;
        final dy = isVertical ? delta : 0.0;

        return Transform.translate(
          offset: Offset(dx, dy),
          child: Container(
            key: _dragKey,
            // Set a fixed width on the dragged item in horizontal
            // lists to prevent it from expanding.
            width: !isVertical ? dragItem?.width : null,
            // Add the horizontal padding in a vertical list as
            // a padding, to prevent the item from filling the lists insets.
            padding: EdgeInsets.only(
              left: isVertical ? listPadding.left : 0.0,
              right: isVertical ? listPadding.right : 0.0,
            ),
            // In horizontal lists, add the top padding as a margin
            // to offset the item from the top edge.
            margin: EdgeInsets.only(top: !isVertical ? listPadding.top : 0.0),
            child: dragWidget,
          ),
        );
      },
    );
  }

  @override
  Widget buildUpdatedItemWidget(E newItem) {
    assert(updateItemBuilder != null);

    // We need to override this method, as AnimatedBuilder is not
    // supported as a top-level item widget in reorderable lists.

    final value = updateAnimController.value;

    final oldItem = changes[newItem];
    final item = value < 0.5 ? oldItem : newItem;

    return updateItemBuilder!(context, updateAnimation, item!);
  }

  // A more complex and less efficient update animation support implementation.
  void _addReorderableUpdateAnimationSupport() {
    bool didUpdateList = false;

    updateAnimController
      ..addListener(() {
        if (updateAnimController.isAnimating) {
          if (!didUpdateList && updateAnimController.value > 0.5) {
            setState(() {});
            didUpdateList = true;
          }

          if (updateItemBuilder != null) {
            changes.keys.forEach(buildUpdatedItemWidget);
          }
        }
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed ||
            status == AnimationStatus.dismissed) {
          didUpdateList = false;
        }
      });
  }

  @override
  void dispose() {
    _scrollAdjuster?.cancel();

    if (widget.controller == null) {
      _controller?.dispose();
    }

    super.dispose();
  }
}

// A class that holds meta information about items in the list such as position and size.
class _Item extends Rect implements Comparable<_Item> {
  final RenderBox box;
  final Key? key;
  final int? index;
  final Offset offset;
  final bool _isVertical;
  _Item(
    this.key,
    this.box,
    this.index,
    this.offset,
    // ignore: avoid_positional_boolean_parameters
    this._isVertical,
  ) : super.fromLTWH(
          offset.dx,
          offset.dy,
          box.size.width,
          box.size.height,
        );

  double get start => _isVertical ? top : left;
  double get end => _isVertical ? bottom : right;
  double get middle => _isVertical ? center.dy : center.dx;

  double? distance;

  @override
  int compareTo(_Item other) => distance != null && other.distance != null
      ? distance!.compareTo(other.distance!)
      : -1;

  @override
  String toString() => '_Item key: $key, index: $index';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is _Item && o.key == key;
  }

  @override
  int get hashCode => key.hashCode;
}
