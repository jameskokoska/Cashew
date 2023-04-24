import 'package:flutter/material.dart';

class BreathingWidget extends StatefulWidget {
  final Widget child;

  const BreathingWidget({Key? key, required this.child}) : super(key: key);

  @override
  _BreathingWidgetState createState() => _BreathingWidgetState();
}

class _BreathingWidgetState extends State<BreathingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..repeat(
        reverse: true,
      );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 1.3).animate(
        new CurvedAnimation(
          parent: _animationController,
          curve: Curves.ease,
        ),
      ),
      child: widget.child,
    );
  }
}
