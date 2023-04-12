import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

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
      color: color ?? Theme.of(context).canvasColor,
      type: type,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        splashFactory: kIsWeb
            ? InkRipple.splashFactory
            : InkSparkle.constantTurbulenceSeedSplashFactory,
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
    // return ContextMenuRegion(
    //   contextMenu: ContextMenuButton(
    //     ContextMenuButtonConfig(
    //       "test",
    //       icon: Icon(Icons.edit),
    //       onPressed: () {
    //         return;
    //       },
    //     ),
    //     style: ContextMenuButtonStyle(
    //       bgColor: Theme.of(context).colorScheme.secondaryContainer,
    //     ),
    //   ),
    //   child: tappable,
    // );
    Future<void> _onPointerDown(PointerDownEvent event) async {
      // Check if right mouse button clicked
      if (event.kind == PointerDeviceKind.mouse &&
          event.buttons == kSecondaryMouseButton) {
        if (onLongPress != null) onLongPress!();
      }
    }

    return Listener(
      child: tappable,
      onPointerDown: _onPointerDown,
    );
  }
}
