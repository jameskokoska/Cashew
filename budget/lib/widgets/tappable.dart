import 'package:flutter/material.dart';
import '../colors.dart';

class Tappable extends StatelessWidget {
  Tappable({
    Key? key,
    this.onTap,
    this.onHighlightChanged,
    this.borderRadius = 0,
    this.color,
    this.type = MaterialType.canvas,
    required this.child,
    this.onLongPress,
  }) : super(key: key);

  final double borderRadius;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onHighlightChanged;
  final Color? color;
  final Widget child;
  final MaterialType type;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      type: type,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        splashFactory: InkSparkle.constantTurbulenceSeedSplashFactory,
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: onTap,
        onHighlightChanged: onHighlightChanged,
        child: child,
        onLongPress: onLongPress,
      ),
    );
  }
}
