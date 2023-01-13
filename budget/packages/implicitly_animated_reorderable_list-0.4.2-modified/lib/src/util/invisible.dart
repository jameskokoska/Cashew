import 'package:flutter/material.dart';

class Invisible extends StatelessWidget {
  final bool invisible;
  final Widget? child;
  const Invisible({
    Key? key,
    this.child,
    this.invisible = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: !invisible,
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      child: child!,
    );
  }
}
