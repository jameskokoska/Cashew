import 'package:flutter/material.dart';

/// A transition that fades the `child` in or out before shrinking or expanding
/// to the `childs` size along the `axis`.
///
/// This can be used as a item transition in an [ImplicitlyAnimatedReorderableList].
class SizeFadeTransition extends StatefulWidget {
  /// The animation to be used.
  final Animation<double> animation;

  /// The curve of the animation.
  final Curve curve;

  /// How long the [Interval] for the [SizeTransition] should be.
  ///
  /// The value must be between 0 and 1.
  ///
  /// For example a `sizeFraction` of `0.66` would result in `Interval(0.0, 0.66)`
  /// for the size animation and `Interval(0.66, 1.0)` for the opacity animation.
  final double sizeFraction;

  /// [Axis.horizontal] modifies the width,
  /// [Axis.vertical] modifies the height.
  final Axis axis;

  /// Describes how to align the child along the axis the [animation] is
  /// modifying.
  ///
  /// A value of -1.0 indicates the top when [axis] is [Axis.vertical], and the
  /// start when [axis] is [Axis.horizontal]. The start is on the left when the
  /// text direction in effect is [TextDirection.ltr] and on the right when it
  /// is [TextDirection.rtl].
  ///
  /// A value of 1.0 indicates the bottom or end, depending upon the [axis].
  ///
  /// A value of 0.0 (the default) indicates the center for either [axis] value.
  final double axisAlignment;

  /// The child widget.
  final Widget? child;
  const SizeFadeTransition({
    Key? key,
    required this.animation,
    this.sizeFraction = 2 / 3,
    this.curve = Curves.linear,
    this.axis = Axis.vertical,
    this.axisAlignment = 0.0,
    this.child,
  })  : assert(sizeFraction >= 0.0 && sizeFraction <= 1.0),
        super(key: key);

  @override
  _SizeFadeTransitionState createState() => _SizeFadeTransitionState();
}

class _SizeFadeTransitionState extends State<SizeFadeTransition> {
  late Animation size;
  late Animation opacity;

  @override
  void initState() {
    super.initState();
    didUpdateWidget(widget);
  }

  @override
  void didUpdateWidget(SizeFadeTransition oldWidget) {
    super.didUpdateWidget(oldWidget);

    final curve =
        CurvedAnimation(parent: widget.animation, curve: widget.curve);
    size = CurvedAnimation(
        curve: Interval(0.0, widget.sizeFraction), parent: curve);
    opacity = CurvedAnimation(
        curve: Interval(widget.sizeFraction, 1.0), parent: curve);
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: size as Animation<double>,
      axis: widget.axis,
      axisAlignment: widget.axisAlignment,
      child: FadeTransition(
        opacity: opacity as Animation<double>,
        child: widget.child,
      ),
    );
  }
}
