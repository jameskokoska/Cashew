import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

class TransactionEntry extends StatelessWidget {
  TransactionEntry({Key? key, required this.openPage}) : super(key: key);

  final Widget openPage;

  double fabSize = 50;
  @override
  Widget build(BuildContext context) {
    return OpenContainer<bool>(
      transitionType: ContainerTransitionType.fade,
      openBuilder: (BuildContext context, VoidCallback _) {
        return openPage;
      },
      onClosed: () {
        print("hello");
      }(),
      tappable: false,
      closedShape: const RoundedRectangleBorder(),
      closedElevation: 0.0,
      closedBuilder: (BuildContext _, VoidCallback openContainer) {
        return ListTile(
          leading: FlutterLogo(),
          onTap: openContainer,
          title: const Text('Test'),
          subtitle: const Text('Test'),
        );
      },
    );
  }
}
