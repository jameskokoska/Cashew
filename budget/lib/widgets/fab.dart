import 'package:budget/widgets/tappable.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:budget/colors.dart';

class FAB extends StatelessWidget {
  FAB({Key? key, required this.openPage, this.tooltip = ""}) : super(key: key);

  final Widget openPage;
  final String tooltip;

  final double fabSize = 60;
  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      transitionType: ContainerTransitionType.fade,
      openBuilder: (BuildContext context, VoidCallback _) {
        return openPage;
      },
      tappable: false,
      transitionDuration: Duration(milliseconds: 350),
      closedElevation: 6.0,
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(fabSize / 2),
        ),
      ),
      closedColor: Theme.of(context).colorScheme.secondary,
      closedBuilder: (BuildContext context, VoidCallback openContainer) {
        return Tooltip(
          message: tooltip,
          child: Tappable(
            color: Theme.of(context).colorScheme.secondary,
            onTap: () {
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
        onDoubleTap: () {
          print("hello");
        },
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
