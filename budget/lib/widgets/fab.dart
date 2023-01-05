import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:budget/colors.dart';

class FAB extends StatelessWidget {
  FAB({Key? key, required this.openPage, this.onTap, this.tooltip = ""})
      : super(key: key);

  final Widget openPage;
  final String tooltip;
  final Function()? onTap;

  final double fabSize = 60;
  @override
  Widget build(BuildContext context) {
    return OpenContainerNavigation(
      closedElevation: 10,
      borderRadius: 18,
      closedColor: Theme.of(context).colorScheme.secondary,
      button: (openContainer) {
        return Tooltip(
          message: tooltip,
          child: Tappable(
            color: Theme.of(context).colorScheme.secondary,
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
                  color: Theme.of(context).colorScheme.onSecondary,
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
