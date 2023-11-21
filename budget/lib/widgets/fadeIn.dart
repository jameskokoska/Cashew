import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class FadeIn extends StatefulWidget {
  FadeIn({Key? key, required this.child, this.duration}) : super(key: key);

  final Widget child;
  final Duration? duration;

  @override
  _FadeInState createState() => _FadeInState();
}

class _FadeInState extends State<FadeIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration ?? Duration(milliseconds: 500),
      vsync: this,
    );

    if (!appStateSettings["batterySaver"]) {
      _controller.forward();
    }

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (appStateSettings["batterySaver"]) {
      return widget.child;
    }
    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class ScaleIn extends StatefulWidget {
  ScaleIn({
    Key? key,
    required this.child,
    this.duration,
    this.curve = const ElasticOutCurve(0.5),
    this.delay = Duration.zero,
  }) : super(key: key);

  final Widget child;
  final Duration? duration;
  final Curve curve;
  final Duration delay;

  @override
  _ScaleInState createState() => _ScaleInState();
}

class _ScaleInState extends State<ScaleIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration ?? Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    if (!appStateSettings["batterySaver"]) {
      Future.delayed(widget.delay, () {
        if (mounted) {
          // Check if the widget is still mounted
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (appStateSettings["batterySaver"]) {
      return widget.child;
    }
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class ScalingWidget extends StatefulWidget {
  final String keyToWatch;
  final Widget child;

  ScalingWidget({required this.keyToWatch, required this.child});

  @override
  _ScalingWidgetState createState() => _ScalingWidgetState();
}

class _ScalingWidgetState extends State<ScalingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isAnimating = false;
  String _currentKey = '';

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant ScalingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.keyToWatch != _currentKey && !_isAnimating) {
      _currentKey = widget.keyToWatch;
      _isAnimating = true;
      _controller.forward().then((value) {
        _controller.reverse().then((value) {
          _isAnimating = false;
        });
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (BuildContext context, Widget? child) {
        return Transform.scale(
          scale: _isAnimating ? _scaleAnimation.value : 1.0,
          child: widget.child,
        );
      },
    );
  }
}

class ScaledAnimatedSwitcher extends StatelessWidget {
  const ScaledAnimatedSwitcher({
    required this.keyToWatch,
    required this.child,
    this.duration = const Duration(milliseconds: 450),
    Key? key,
  }) : super(key: key);

  final String keyToWatch;
  final Widget child;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeInOutCubic,
      switchOutCurve: Curves.easeOut,
      transitionBuilder: (Widget child, Animation<double> animation) {
        final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: Interval(0.5, 1),
          ),
        );

        final scaleAnimation = Tween<double>(begin: 0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: Interval(0, 1.0),
          ),
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            alignment: Alignment.center,
            scale: scaleAnimation,
            child: child,
          ),
        );
      },
      child: SizedBox(key: ValueKey(keyToWatch), child: child),
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

class AnimateFABDelayed extends StatefulWidget {
  const AnimateFABDelayed({
    Key? key,
    required this.fab,
    this.delay = const Duration(milliseconds: 250),
    this.enabled,
  }) : super(key: key);

  final Widget fab;
  final Duration delay;
  final bool? enabled;

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
      condition: widget.enabled ?? scaleIn,
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
