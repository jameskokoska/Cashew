import 'dart:math';

import 'package:flutter/material.dart';

class AnimatedCircularProgress extends StatefulWidget {
  final double percent;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? overageColor;
  final Color? overageShadowColor;
  final double strokeWidth;
  final double valueStrokeWidth;

  AnimatedCircularProgress({
    Key? key,
    required this.percent,
    required this.backgroundColor,
    required this.foregroundColor,
    this.overageColor,
    this.overageShadowColor,
    this.strokeWidth = 3.5,
    this.valueStrokeWidth = 4,
  }) : super(key: key);

  @override
  _AnimatedCircularProgressState createState() =>
      _AnimatedCircularProgressState();
}

class _AnimatedCircularProgressState extends State<AnimatedCircularProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  double capPercentage(double percent) {
    if (percent > 3) {
      return 3;
    } else
      return percent;
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2500),
    );
    _animation = Tween<double>(begin: 0, end: capPercentage(widget.percent))
        .animate(new CurvedAnimation(
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
      _animation = Tween<double>(
              begin: oldWidget.percent, end: capPercentage(widget.percent))
          .animate(new CurvedAnimation(
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
            overageColor: widget.overageColor ?? Colors.transparent,
            overageShadowColor: widget.overageShadowColor ?? Colors.transparent,
            strokeWidth: widget.strokeWidth,
            valueStrokeWidth: widget.valueStrokeWidth,
            cornerRadius: widget.valueStrokeWidth,
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
  final Color overageColor;
  final Color overageShadowColor;
  final double strokeWidth;
  final double valueStrokeWidth;
  final double cornerRadius;

  _RoundedCircularProgressPainter({
    required this.value,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.overageColor,
    required this.overageShadowColor,
    required this.strokeWidth,
    required this.valueStrokeWidth,
    required this.cornerRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = min(size.width, size.height) / 2;
    final startAngle = -pi / 2;
    final progressSweepAngle = 2 * pi * value.clamp(0.0, 1.0);
    final overageSweepAngle = 2 * pi * (value - 1);
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
    final overagePaint = Paint()
      ..color = overageColor
      ..strokeWidth = valueStrokeWidth + 1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final overagePaintShadow = Paint()
      ..color = overageShadowColor
      ..strokeWidth = valueStrokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2);

    final startAngleRadians = startAngle;
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
        rect, startAngleRadians, backgroundSweepAngle, false, backgroundPaint);
    canvas.drawArc(
        rect, startAngleRadians, progressSweepAngle, false, valuePaint);
    if (value > 1.0) {
      if (value < 2.0)
        canvas.drawArc(rect, progressSweepAngle - startAngleRadians * 3,
            overageSweepAngle, false, overagePaintShadow);
      canvas.drawArc(rect, progressSweepAngle - startAngleRadians * 3,
          overageSweepAngle, false, overagePaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
