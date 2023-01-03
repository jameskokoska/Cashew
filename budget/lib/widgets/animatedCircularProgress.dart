import 'dart:math';

import 'package:flutter/material.dart';

class AnimatedCircularProgress extends StatefulWidget {
  final double percent;
  final Color backgroundColor;
  final Color foregroundColor;

  AnimatedCircularProgress({
    Key? key,
    required this.percent,
    required this.backgroundColor,
    required this.foregroundColor,
  }) : super(key: key);

  @override
  _AnimatedCircularProgressState createState() =>
      _AnimatedCircularProgressState();
}

class _AnimatedCircularProgressState extends State<AnimatedCircularProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2500),
    );
    _animation = Tween<double>(begin: 0, end: widget.percent).animate(
        new CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOutCubicEmphasized));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AnimatedCircularProgress oldWidget) {
    if (oldWidget.percent != widget.percent) {
      _animationController.forward(from: 0);
      _animation = Tween<double>(begin: 0, end: widget.percent).animate(
          new CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeInOutCubicEmphasized));
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _RoundedCircularProgressPainter(
            value: _animation.value,
            backgroundColor: widget.backgroundColor,
            foregroundColor: widget.foregroundColor,
            strokeWidth: 3.5,
            valueStrokeWidth: 5,
            cornerRadius: 4,
          ),
        );
      },
    );
  }
}

class _RoundedCircularProgressPainter extends CustomPainter {
  final double value;
  final Color backgroundColor;
  final Color foregroundColor;
  final double strokeWidth;
  final double valueStrokeWidth;
  final double cornerRadius;

  _RoundedCircularProgressPainter({
    required this.value,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.strokeWidth,
    required this.valueStrokeWidth,
    required this.cornerRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = min(size.width, size.height) / 2;
    final startAngle = -pi / 2;
    final progressSweepAngle = 2 * pi * value;
    final backgroundSweepAngle = 2 * pi;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;
    final valuePaint = Paint()
      ..color = foregroundColor
      ..strokeWidth = valueStrokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final startAngleRadians = startAngle;
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
        rect, startAngleRadians, backgroundSweepAngle, false, backgroundPaint);
    canvas.drawArc(
        rect, startAngleRadians, progressSweepAngle, false, valuePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
