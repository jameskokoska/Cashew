import 'dart:math';

import 'package:budget/functions.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/foundation.dart';
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
      child: widget.child,
    );
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
    this.animate = true,
  });

  final Widget child;
  final double offset;
  final Curve curve;
  final Direction direction;
  final Duration delayStart;
  final Duration animationDuration;
  final bool reverse;
  final bool animate;

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
    if (widget.animate == false) {
      return widget.child;
    }
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
    if (kIsWeb) {
      return TextFont(
        text: widget.prefix +
            ((widget.count * pow(10, widget.decimals)).toInt()).toString() +
            widget.suffix,
        fontSize: widget.fontSize,
        fontWeight: widget.fontWeight,
        textAlign: widget.textAlign,
        textColor: widget.textColor,
        maxLines: widget.maxLines,
      );
    }
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
    this.curve = Curves.easeOutQuint,
    this.initialCount = 0,
    this.decimals = 2,
    this.dynamicDecimals = false,
    this.lazyFirstRender = true,
  }) : super(key: key);

  final double count;
  final Function(double) textBuilder;
  final double fontSize;
  final Duration duration;
  final Curve curve;
  final double initialCount;
  final int decimals;
  final bool dynamicDecimals;
  final bool lazyFirstRender;

  @override
  State<CountNumber> createState() => _CountNumberState();
}

class _CountNumberState extends State<CountNumber> {
  double previousAmount = 0;
  int decimals = 2;
  bool lazyFirstRender = true;
  @override
  void initState() {
    super.initState();
    previousAmount = widget.initialCount;
    decimals = widget.decimals;
    lazyFirstRender = widget.lazyFirstRender;
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return widget.textBuilder(
        (widget.count * pow(10, decimals)).toInt().toDouble(),
      );
    }

    if (lazyFirstRender && widget.initialCount == widget.count) {
      lazyFirstRender = false;
      return widget.textBuilder(
        widget.initialCount,
      );
    }

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

class AnimatedScaleDelayed extends StatefulWidget {
  const AnimatedScaleDelayed({
    Key? key,
    required this.child,
    this.delay = const Duration(milliseconds: 250),
  }) : super(key: key);

  final Widget child;
  final Duration delay;

  @override
  State<AnimatedScaleDelayed> createState() => _AnimatedScaleDelayedState();
}

class _AnimatedScaleDelayedState extends State<AnimatedScaleDelayed> {
  bool scaleIn = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      setState(() {
        scaleIn = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: Duration(milliseconds: 1100),
      scale: scaleIn ? 1 : 0,
      curve: ElasticOutCurve(0.8),
      child: widget.child,
    );
  }
}

class ShakeAnimation extends StatelessWidget {
  const ShakeAnimation({
    Key? key,
    this.duration = const Duration(milliseconds: 2500),
    this.deltaX = 20,
    this.curve = const ElasticInOutCurve(0.19),
    required this.child,
    this.animate = true,
  }) : super(key: key);

  final Duration duration;
  final double deltaX;
  final Widget child;
  final Curve curve;
  final bool animate;

  double shakeAnimation(double animation) =>
      0.3 * (0.5 - (0.5 - curve.transform(animation)).abs());

  @override
  Widget build(BuildContext context) {
    if (animate == false) {
      return child;
    }
    return TweenAnimationBuilder<double>(
      key: key,
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      duration: duration,
      builder: (context, animation, child) => Transform.translate(
        offset: Offset(deltaX * shakeAnimation(animation), 0),
        child: child,
      ),
      child: child,
    );
  }
}
