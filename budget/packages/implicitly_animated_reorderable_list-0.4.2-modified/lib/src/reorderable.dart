
import 'package:flutter/material.dart';

import 'src.dart';

typedef ReorderableBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
  bool inDrag,
);

/// The parent widget of every item in an [ImplicitlyAnimatedReorderableList].
class Reorderable extends StatefulWidget {
  /// Called, as needed, to build the child this Reorderable.
  ///
  /// The [ReorderableBuilder] `animation` parameter supplies you with an animation you can use to
  /// transition between the normal and the dragged state of the item. The `inDrag` parameter
  /// indicates whether this item is currently being dragged/reordered.
  final ReorderableBuilder? builder;

  /// Used, as needed, to build the child this Reorderable.
  ///
  /// This can be used to show a child that should not have
  /// any animation when being dragged or dropped.
  final Widget? child;

  /// Creates a reorderable widget that must be the parent of every
  /// item in an [ImplicitlyAnimatedReorderableList].
  ///
  /// A [key] must be specified that uniquely identifies this Reorderable
  /// in the list. The value of the key should not change throughout
  /// the lifecycle of the item. For example if your item has a unique id,
  /// you could use that with a `ValueKey`.
  ///
  /// Either [builder] or [child] must be specified. The [builder]
  /// can be used for custom animations when the item should be animated
  /// between dragged and normal state. If you don't want to show any
  /// animation between dragged and normal state, you can also use the
  /// [child] as a shorthand instead.
  const Reorderable({
    required Key key,
    this.builder,
    this.child,
  })  : assert(builder != null || child != null),
        super(key: key);

  @override
  ReorderableState createState() => ReorderableState();

  static ReorderableState? of(BuildContext context) {
    return context.findAncestorStateOfType<ReorderableState>();
  }
}

class ReorderableState extends State<Reorderable>
    with SingleTickerProviderStateMixin {
  late Key key = widget.key ?? UniqueKey();

  late final _dragController = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  );

  late final _dragAnimation = CurvedAnimation(
    parent: _dragController,
    curve: Curves.linear,
  );

  Animation<double>? _translation;

  bool _isVertical = true;

  bool _inDrag = false;
  bool get inDrag => _inDrag;
  set inDrag(bool value) {
    if (value != inDrag) {
      _inDrag = value;
      value ? _dragController.animateTo(1.0) : _dragController.animateBack(0.0);
    }
  }

  // ignore: avoid_setters_without_getters
  set duration(Duration value) => _dragController.duration = value;

  void setTranslation(Animation<double>? animation) {
    if (mounted) {
      setState(() {
        _translation = animation;
      });
    }
  }

  void rebuild() {
    if (mounted) {
      setState(() {});
    }
  }

  void _registerItem() {
    final list = ImplicitlyAnimatedReorderableList.of(context)!;

    list.registerItem(this);
    _dragController.duration = list.widget.settleDuration;

    inDrag = list.dragItem?.key == key && list.inDrag;
    _isVertical = list.isVertical;
  }

  @override
  Widget build(BuildContext context) {
    _registerItem();

    final child = () {
      if (widget.child != null) {
        return widget.child;
      } else {
        return widget.builder!(context, _dragAnimation, _inDrag);
      }
    }();

    return AnimatedBuilder(
      child: child,
      animation: _translation ?? const AlwaysStoppedAnimation(0.0),
      builder: (context, child) {
        final offset = _translation?.value ?? 0.0;

        return Transform.translate(
          offset: Offset(
            _isVertical ? 0.0 : offset,
            _isVertical ? offset : 0.0,
          ),
          child: child,
        );
      },
    );
  }

  @override
  void dispose() {
    _dragController.dispose();
    super.dispose();
  }
}
