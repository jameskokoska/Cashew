import 'package:budget/widgets/button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../colors.dart';
import 'package:context_menus/context_menus.dart';

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
    Widget tappable = Material(
      color: color ?? Theme.of(context).colorScheme.background,
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
    if (!kIsWeb) {
      return tappable;
    }
    return ContextMenuRegion(
      contextMenu: ContextMenuButton(
        ContextMenuButtonConfig(
          "test",
          icon: Icon(Icons.edit),
          onPressed: () {
            return;
          },
        ),
        style: ContextMenuButtonStyle(
          bgColor: Theme.of(context).colorScheme.secondaryContainer,
        ),
      ),
      child: tappable,
    );
  }
}
