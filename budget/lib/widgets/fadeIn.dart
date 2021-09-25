import 'package:budget/functions.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class FadeIn extends StatefulWidget {
  FadeIn({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  _FadeInState createState() => _FadeInState();
}

class _FadeInState extends State<FadeIn> {
  double widgetOpacity = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 0), () {
      setState(() {
        widgetOpacity = 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
        opacity: widgetOpacity,
        duration: Duration(milliseconds: 500),
        child: widget.child);
  }
}

enum Direction { vertical, horizontal }

class SlideFadeTransition extends StatefulWidget {
  SlideFadeTransition({
    required this.child,
    this.offset = 1,
    this.curve = Curves.decelerate,
    this.direction = Direction.vertical,
    this.delayStart = const Duration(seconds: 0),
    this.animationDuration = const Duration(milliseconds: 500),
    this.reverse = false,
  });

  final Widget child;
  final double offset;
  final Curve curve;
  final Direction direction;
  final Duration delayStart;
  final Duration animationDuration;
  final bool reverse;

  @override
  _SlideFadeTransitionState createState() => _SlideFadeTransitionState();
}

class _SlideFadeTransitionState extends State<SlideFadeTransition>
    with SingleTickerProviderStateMixin {
  late Animation<Offset> _animationSlide;
  late AnimationController _animationController;
  late Animation<double> _animationFade;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    if (widget.reverse == true) {}

    if (widget.direction == Direction.vertical) {
      _animationSlide = Tween<Offset>(
              begin: Offset(0, widget.reverse ? -widget.offset : widget.offset),
              end: Offset(0, 0))
          .animate(CurvedAnimation(
        curve: widget.curve,
        parent: _animationController,
      ));
    } else {
      _animationSlide = Tween<Offset>(
              begin: Offset(widget.reverse ? -widget.offset : widget.offset, 0),
              end: Offset(0, 0))
          .animate(CurvedAnimation(
        curve: widget.curve,
        parent: _animationController,
      ));
    }

    _animationFade = Tween<double>(begin: 0, end: 1.0).animate(CurvedAnimation(
      curve: widget.curve,
      parent: _animationController,
    ));

    Timer(widget.delayStart, () {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animationFade,
      child: SlideTransition(
        position: _animationSlide,
        child: widget.child,
      ),
    );
  }
}

class CountUp extends StatefulWidget {
  const CountUp({
    Key? key,
    required this.count,
  }) : super(key: key);

  final double count;

  @override
  State<CountUp> createState() => _CountUpState();
}

class _CountUpState extends State<CountUp> {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
          begin: widget.count - widget.count * 0.1, end: widget.count),
      duration: const Duration(seconds: 4),
      curve: Curves.easeOutExpo,
      builder: (BuildContext context, double animatedCount, Widget? child) {
        return Column(
          children: [
            Text(convertToMoney(animatedCount).toString()),
          ],
        );
      },
    );
  }
}

class CountUpInt extends StatefulWidget {
  const CountUpInt({
    Key? key,
    required this.count,
  }) : super(key: key);

  final int count;

  @override
  State<CountUpInt> createState() => _CountUpIntState();
}

class _CountUpIntState extends State<CountUpInt> {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: widget.count),
      duration: const Duration(seconds: 4),
      curve: Curves.easeOutExpo,
      builder: (BuildContext context, int animatedCount, Widget? child) {
        return Column(
          children: [
            Text(animatedCount.toString()),
          ],
        );
      },
    );
  }
}
