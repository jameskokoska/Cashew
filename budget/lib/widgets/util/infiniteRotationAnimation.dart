import 'package:flutter/material.dart';

class InfiniteRotationAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  InfiniteRotationAnimation({
    required this.child,
    this.duration = const Duration(milliseconds: 2000),
  });

  @override
  _InfiniteRotationAnimationState createState() =>
      _InfiniteRotationAnimationState();
}

class _InfiniteRotationAnimationState extends State<InfiniteRotationAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    animation = Tween<double>(
      begin: 0,
      end: -12.5664, // 2Radians (360 degrees)
    ).animate(animationController);
    animationController.forward();
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationController.repeat();
      }
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) => Transform.rotate(
        angle: animation.value,
        child: widget.child,
      ),
    );
  }
}
