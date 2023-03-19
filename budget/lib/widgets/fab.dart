import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:budget/colors.dart';

class FAB extends StatelessWidget {
  FAB(
      {Key? key,
      required this.openPage,
      this.onTap,
      this.tooltip = "",
      this.color,
      this.colorPlus})
      : super(key: key);

  final Widget openPage;
  final String tooltip;
  final Function()? onTap;
  final Color? color;
  final Color? colorPlus;

  @override
  Widget build(BuildContext context) {
    double fabSize = getWidthNavigationSidebar(context) <= 0 ? 60 : 70;
    return OpenContainerNavigation(
      closedElevation: 10,
      borderRadius: getWidthNavigationSidebar(context) <= 0 ? 18 : 22,
      closedColor:
          color != null ? color : Theme.of(context).colorScheme.secondary,
      button: (openContainer) {
        return Tooltip(
          message: tooltip,
          child: Tappable(
            color:
                color != null ? color : Theme.of(context).colorScheme.secondary,
            onTap: () {
              if (onTap != null)
                onTap!();
              else
                openContainer();
            },
            child: SizedBox(
              height: fabSize,
              width: fabSize,
              child: Center(
                child: Icon(
                  Icons.add_rounded,
                  color: colorPlus != null
                      ? colorPlus
                      : Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ),
          ),
        );
      },
      openPage: openPage,
    );
  }
}

class OpenTestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test page'),
      ),
      body: GestureDetector(
        onDoubleTap: () {},
        onPanUpdate: (details) {
          if (details.delta.dy > 10 || details.delta.dx > 10) {
            Navigator.of(context).pop();
          }
        },
        child: Container(color: Colors.blueGrey),
      ),
    );
  }
}
