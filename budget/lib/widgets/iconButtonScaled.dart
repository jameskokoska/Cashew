import 'package:budget/widgets/tappable.dart';
import 'package:flutter/material.dart';

class IconButtonScaled extends StatelessWidget {
  const IconButtonScaled({
    this.tooltip,
    required this.iconData,
    required this.iconSize,
    required this.scale,
    required this.onTap,
    this.padding = const EdgeInsetsDirectional.all(8.0),
    super.key,
  });
  final String? tooltip;
  final IconData iconData;
  final double iconSize;
  final double scale;
  final VoidCallback onTap;
  final EdgeInsetsDirectional padding;

  @override
  Widget build(BuildContext context) {
    Widget widget = Transform.scale(
      scale: scale,
      child: ClipRRect(
        borderRadius: BorderRadiusDirectional.circular(100),
        child: Tappable(
          color: Colors.transparent,
          child: Padding(
            padding: padding,
            child: Icon(
              iconData,
              size: iconSize,
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
    if (tooltip != null) {
      return Tooltip(
        message: tooltip,
        child: widget,
      );
    } else {
      return widget;
    }
  }
}
