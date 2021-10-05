import 'package:flutter/material.dart';
import '../colors.dart';

class Tappable extends StatelessWidget {
  Tappable(
      {Key? key,
      this.onTap,
      this.onHighlightChanged,
      this.borderRadius = 0,
      this.color,
      required this.child})
      : super(key: key);

  final double borderRadius;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onHighlightChanged;
  final Color? color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: onTap,
        onHighlightChanged: onHighlightChanged,
        child: child,
      ),
    );
  }
}
