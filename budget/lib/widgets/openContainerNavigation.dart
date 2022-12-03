import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

class OpenContainerNavigation extends StatelessWidget {
  OpenContainerNavigation({
    Key? key,
    required this.openPage,
    required this.button,
    this.closedColor,
    this.borderRadius = 250,
    this.closedElevation,
  }) : super(key: key);

  final Widget openPage;
  final Widget Function(VoidCallback) button;
  final Color? closedColor;
  final double borderRadius;
  final double? closedElevation;

  @override
  Widget build(BuildContext context) {
    if (appStateSettings["batterySaver"]) {
      Widget child = button(() {
        pushRoute(
          context,
          openPage,
        );
      });
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          color: closedColor ?? Colors.transparent,
          child: child,
        ),
      );
    }
    return OpenContainer(
      transitionType: ContainerTransitionType.fade,
      openBuilder: (BuildContext context, VoidCallback _) {
        return openPage;
      },
      tappable: false,
      transitionDuration: Duration(milliseconds: 350),
      closedElevation: closedElevation ?? 0,
      openColor: closedColor ?? Colors.transparent,
      closedColor: closedColor ?? Colors.transparent,
      closedBuilder: (BuildContext context, VoidCallback openContainer) {
        return button(openContainer);
      },
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(borderRadius),
        ),
      ),
    );
  }
}
