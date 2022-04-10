import 'package:budget/widgets/tappable.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

class OpenContainerNavigation extends StatelessWidget {
  OpenContainerNavigation({
    Key? key,
    required this.openPage,
    required this.button,
    this.closedColor,
    this.borderRadius = 250,
  }) : super(key: key);

  final Widget openPage;
  final Widget Function(VoidCallback) button;
  final Color? closedColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      transitionType: ContainerTransitionType.fade,
      openBuilder: (BuildContext context, VoidCallback _) {
        return openPage;
      },
      tappable: false,
      transitionDuration: Duration(milliseconds: 350),
      closedElevation: 0,
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
