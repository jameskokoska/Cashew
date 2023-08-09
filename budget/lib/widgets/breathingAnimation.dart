import 'package:flutter/material.dart';

class BreathingWidget extends StatefulWidget {
  final Widget child;
  final Curve curve;
  final Duration duration;
  final double endScale;
  const BreathingWidget({
    Key? key,
    required this.child,
    this.curve = Curves.ease,
    this.duration = const Duration(milliseconds: 3000),
    this.endScale = 1.3,
  }) : super(key: key);

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
      duration: widget.duration,
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
      scale: Tween(begin: 1.0, end: widget.endScale).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: widget.curve,
        ),
      ),
      child: widget.child,
    );
  }
}
