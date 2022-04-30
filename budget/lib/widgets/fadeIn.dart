import 'dart:math';

import 'package:budget/functions.dart';
import 'package:budget/widgets/textWidgets.dart';
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
    this.fontSize = 16,
    this.prefix = "",
    this.suffix = "",
    this.fontWeight = FontWeight.normal,
    this.textAlign = TextAlign.left,
    this.textColor,
    this.maxLines = null,
    this.duration = const Duration(milliseconds: 3000),
    this.decimals = 2,
    this.curve = Curves.easeOutExpo,
  }) : super(key: key);

  final double count;
  final double fontSize;
  final String prefix;
  final String suffix;
  final FontWeight fontWeight;
  final Color? textColor;
  final TextAlign textAlign;
  final int? maxLines;
  final Duration duration;
  final int decimals;
  final Curve curve;

  @override
  State<CountUp> createState() => _CountUpState();
}

class _CountUpState extends State<CountUp> {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(
          begin: 0, end: (widget.count * pow(10, widget.decimals)).toInt()),
      duration: widget.duration,
      curve: widget.curve,
      builder: (BuildContext context, int animatedCount, Widget? child) {
        String countString = animatedCount.toString();
        return TextFont(
          text: widget.prefix +
              (countString.length >= widget.decimals + 1
                  ? countString.substring(
                      0, countString.length - widget.decimals)
                  : "0") +
              (widget.decimals > 0 ? "." : "") +
              (countString.length >= widget.decimals
                  ? countString.substring(countString.length - widget.decimals)
                  : countString.substring(countString.length - 1)) +
              widget.suffix,
          fontSize: widget.fontSize,
          fontWeight: widget.fontWeight,
          textAlign: widget.textAlign,
          textColor: widget.textColor,
          maxLines: widget.maxLines,
        );
      },
    );
  }
}

class CountNumber extends StatefulWidget {
  const CountNumber({
    Key? key,
    required this.count,
    required this.textBuilder,
    this.fontSize = 16,
    this.duration = const Duration(milliseconds: 3000),
    this.curve = Curves.easeOutExpo,
    this.initialCount = 0,
    this.decimals = 2,
    this.dynamicDecimals = false,
  }) : super(key: key);

  final double count;
  final Function(double) textBuilder;
  final double fontSize;
  final Duration duration;
  final Curve curve;
  final double initialCount;
  final int decimals;
  final bool dynamicDecimals;

  @override
  State<CountNumber> createState() => _CountNumberState();
}

class _CountNumberState extends State<CountNumber> {
  double previousAmount = 0;
  int decimals = 2;
  @override
  void initState() {
    super.initState();
    previousAmount = widget.initialCount;
    decimals = widget.decimals;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dynamicDecimals) {
      if (widget.count % 1 == 0) {
        decimals = 0;
      } else {
        decimals = widget.decimals;
      }
    }

    Widget builtWidget = TweenAnimationBuilder<int>(
      tween: IntTween(
        begin: (previousAmount * pow(10, decimals)).toInt(),
        end: (widget.count * pow(10, decimals)).toInt(),
      ),
      duration: widget.duration,
      curve: widget.curve,
      builder: (BuildContext context, int animatedCount, Widget? child) {
        return widget.textBuilder(
          animatedCount / pow(10, decimals).toDouble(),
        );
      },
    );

    previousAmount = widget.count;
    return builtWidget;
  }
}
