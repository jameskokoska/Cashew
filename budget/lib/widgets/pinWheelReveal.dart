import 'dart:math';
import 'package:flutter/material.dart';

class PinWheelReveal extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;

  const PinWheelReveal({
    Key? key,
    required this.child,
    required this.duration,
    this.delay = Duration.zero,
    this.curve = Curves.easeInOutCubic,
  }) : super(key: key);

  @override
  _PinWheelRevealState createState() => _PinWheelRevealState();
}

class _PinWheelRevealState extends State<PinWheelReveal>
    with SingleTickerProviderStateMixin {
  double? _fraction = 0.0;
  late Animation<double> _animation;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = Tween(begin: 0.0, end: 1.0)
        .animate(new CurvedAnimation(parent: _controller, curve: widget.curve))
      ..addListener(() {
        setState(() {
          _fraction = _animation.value;
        });
      });

    Future.delayed(widget.delay, () {
      _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: CirclePainter(fraction: _fraction!),
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class CirclePainter extends CustomClipper<Path> {
  final double? fraction;

  CirclePainter({this.fraction});

  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.addArc(
        Rect.fromCircle(
            center: Offset(size.width / 2, size.height / 2),
            radius: size.width + 500),
        _degreesToRadians(-90).toDouble(),
        (_degreesToRadians(360 * fraction!).toDouble()));
    path.arcTo(
        Rect.fromCircle(
            center: Offset(size.width / 2, size.height / 2), radius: 0),
        _degreesToRadians(269.999 * fraction!).toDouble(),
        _degreesToRadians(-90).toDouble() -
            _degreesToRadians((269.999) * fraction!).toDouble(),
        false);
    return path;
  }

  @override
  bool shouldReclip(CirclePainter oldClipper) {
    return oldClipper.fraction != fraction;
  }
}

num _degreesToRadians(num deg) => deg * (pi / 180);
