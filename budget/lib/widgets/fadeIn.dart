import 'dart:math';

import 'package:budget/main.dart';
import 'package:budget/widgets/navigationFramework.dart';
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
    if (!appStateSettings["batterySaver"]) {
      Future.delayed(Duration(milliseconds: 0), () {
        setState(() {
          widgetOpacity = 1;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (appStateSettings["batterySaver"]) {
      return widget.child;
    }
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
    if (!appStateSettings["batterySaver"]) {
      if (widget.reverse == true) {}

      if (widget.direction == Direction.vertical) {
        _animationSlide = Tween<Offset>(
                begin:
                    Offset(0, widget.reverse ? -widget.offset : widget.offset),
                end: Offset(0, 0))
            .animate(CurvedAnimation(
          curve: widget.curve,
          parent: _animationController,
        ));
      } else {
        _animationSlide = Tween<Offset>(
                begin:
                    Offset(widget.reverse ? -widget.offset : widget.offset, 0),
                end: Offset(0, 0))
            .animate(CurvedAnimation(
          curve: widget.curve,
          parent: _animationController,
        ));
      }

      _animationFade =
          Tween<double>(begin: 0, end: 1.0).animate(CurvedAnimation(
        curve: widget.curve,
        parent: _animationController,
      ));

      Timer(widget.delayStart, () {
        _animationController.forward();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (appStateSettings["batterySaver"] || widget.animate == false) {
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
    this.walletPkForCurrency,
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
  final int? walletPkForCurrency;

  @override
  State<CountUp> createState() => _CountUpState();
}

class _CountUpState extends State<CountUp> {
  @override
  Widget build(BuildContext context) {
    if (appStateSettings["batterySaver"]) {
      return TextFont(
        text: widget.prefix +
            (widget.count).toStringAsFixed(widget.decimals) +
            widget.suffix,
        fontSize: widget.fontSize,
        fontWeight: widget.fontWeight,
        textAlign: widget.textAlign,
        textColor: widget.textColor,
        maxLines: widget.maxLines,
        walletPkForCurrency: widget.walletPkForCurrency,
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
          walletPkForCurrency: widget.walletPkForCurrency,
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
    if (widget.dynamicDecimals) {
      if (widget.count % 1 == 0) {
        decimals = 0;
      } else {
        decimals = widget.decimals;
      }
    }

    if (appStateSettings["batterySaver"]) {
      return widget.textBuilder(
        double.parse((widget.count).toStringAsFixed(widget.decimals)),
      );
    }

    if (lazyFirstRender && widget.initialCount == widget.count) {
      lazyFirstRender = false;
      return widget.textBuilder(
        widget.initialCount,
      );
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

class AnimateFABDelayed extends StatefulWidget {
  const AnimateFABDelayed({
    Key? key,
    required this.fab,
    this.delay = const Duration(milliseconds: 250),
  }) : super(key: key);

  final Widget fab;
  final Duration delay;

  @override
  State<AnimateFABDelayed> createState() => _AnimateFABDelayedState();
}

class _AnimateFABDelayedState extends State<AnimateFABDelayed> {
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
    return AnimateFAB(
      condition: scaleIn,
      fab: widget.fab,
    );
  }
}

class ShakeAnimation extends StatefulWidget {
  const ShakeAnimation({
    Key? key,
    this.duration = const Duration(milliseconds: 2500),
    this.deltaX = 20,
    this.curve = const ElasticInOutCurve(0.19),
    required this.child,
    this.animate = true,
    this.delay,
  }) : super(key: key);

  final Duration duration;
  final double deltaX;
  final Widget child;
  final Curve curve;
  final bool animate;
  final Duration? delay;

  @override
  State<ShakeAnimation> createState() => _ShakeAnimationState();
}

class _ShakeAnimationState extends State<ShakeAnimation> {
  bool startAnimation = false;
  Future? _future;
  @override
  void initState() {
    if (widget.delay != null) {
      _future = Future.delayed(widget.delay!, () {
        if (mounted)
          setState(() {
            startAnimation = true;
          });
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    _future = null;
    super.dispose();
  }

  double shakeAnimation(double animation) =>
      0.3 * (0.5 - (0.5 - widget.curve.transform(animation)).abs());

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: widget.key,
      tween: Tween(
        begin: 0.0,
        end: widget.animate == false || startAnimation == false ? 0 : 1,
      ),
      curve: Curves.easeOut,
      duration: widget.duration,
      builder: (context, animation, child) => Transform.translate(
        offset: Offset(widget.deltaX * shakeAnimation(animation), 0),
        child: child,
      ),
      child: widget.child,
    );
  }
}

class AnimatedClipRRect extends StatelessWidget {
  const AnimatedClipRRect({
    required this.duration,
    this.curve = Curves.linear,
    required this.borderRadius,
    required this.child,
    Key? key,
  }) : super(key: key);

  final Duration duration;
  final Curve curve;
  final BorderRadius borderRadius;
  final Widget child;

  static Widget _builder(
      BuildContext context, BorderRadius radius, Widget? child) {
    return ClipRRect(borderRadius: radius, child: child);
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<BorderRadius>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: BorderRadius.zero, end: borderRadius),
      builder: _builder,
      child: child,
    );
  }
}
