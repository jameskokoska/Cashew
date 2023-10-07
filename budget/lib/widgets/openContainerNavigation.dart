import 'package:budget/functions.dart';
import 'package:budget/struct/settings.dart';
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
    this.customBorderRadius,
    this.onClosed,
    this.onOpen,
  }) : super(key: key);

  final Widget openPage;
  final Widget Function(VoidCallback openContainer) button;
  final Color? closedColor;
  final double borderRadius;
  final double? closedElevation;
  final BorderRadiusGeometry? customBorderRadius;
  final VoidCallback? onClosed;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    if (appStateSettings["batterySaver"] || appStateSettings["iOSNavigation"]) {
      Widget child = button(() async {
        if (onOpen != null) onOpen!();
        await pushRoute(context, openPage);
        if (onClosed != null) onClosed!();
      });
      return ClipRRect(
        borderRadius: customBorderRadius ?? BorderRadius.circular(borderRadius),
        child: Container(
          color: closedColor ?? Colors.transparent,
          child: child,
        ),
      );
    }
    return OpenContainer(
      onClosed: (_) async {
        if (onClosed != null) onClosed!();
      },
      transitionType: ContainerTransitionType.fade,
      openBuilder: (BuildContext context, VoidCallback _) {
        return openPage;
      },
      tappable: false,
      transitionDuration: getPlatform() == PlatformOS.isIOS
          ? Duration(milliseconds: 475)
          : Duration(milliseconds: 400),
      closedElevation: closedElevation ?? 0,
      openColor: closedColor ?? Colors.transparent,
      closedColor: closedColor ?? Colors.transparent,
      openElevation: 0,
      closedBuilder: (BuildContext context, VoidCallback openContainer) {
        return button(() {
          if (onOpen != null) onOpen!();
          openContainer();
        });
      },
      closedShape: RoundedRectangleBorder(
        borderRadius: customBorderRadius ??
            BorderRadius.all(
              Radius.circular(borderRadius),
            ),
      ),
    );
  }
}
