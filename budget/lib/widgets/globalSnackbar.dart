import 'dart:async';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import '../colors.dart';
import 'package:pausable_timer/pausable_timer.dart';

class GlobalSnackbar extends StatefulWidget {
  const GlobalSnackbar({Key? key}) : super(key: key);

  @override
  State<GlobalSnackbar> createState() => GlobalSnackbarState();
}

class SnackbarMessage {
  final String title;
  String? description;
  IconData? icon;
  Duration timeout;
  VoidCallback? onTap;

  SnackbarMessage({
    this.title = "",
    this.description,
    this.icon,
    this.timeout = const Duration(milliseconds: 3500),
    this.onTap,
  });
}

class GlobalSnackbarState extends State<GlobalSnackbar>
    with TickerProviderStateMixin {
  PausableTimer? currentTimeout;
  late AnimationController _animationControllerY;
  late AnimationController _animationControllerX;
  double totalMovedNegative = 0;
  List<SnackbarMessage> currentQueue = [];
  SnackbarMessage? currentMessage;

  post(SnackbarMessage message, {bool postIfQueue = true}) {
    if (currentQueue.length >= 1 && !postIfQueue) return;
    currentQueue.add(message);
    if (currentQueue.length <= 1) animateIn(message);
  }

  animateIn(SnackbarMessage message) {
    setState(() {
      currentMessage = currentQueue[0];
    });
    _animationControllerX.animateTo(0.5, duration: Duration.zero);
    _animationControllerY.animateTo(0.5,
        curve: ElasticOutCurve(0.8),
        duration: Duration(
            milliseconds:
                ((_animationControllerY.value - 0.5).abs() * 800 + 900)
                    .toInt()));
    currentTimeout = PausableTimer(message.timeout, () {
      animateOut();
    });
    currentTimeout!.start();
  }

  animateOut() {
    currentTimeout?.cancel();
    _animationControllerY.animateTo(0,
        curve: Curves.elasticOut,
        duration: Duration(
            milliseconds:
                ((_animationControllerY.value - 0.5).abs() * 800 + 2000)
                    .toInt()));
    if (currentQueue.length >= 1) {
      currentQueue.removeAt(0);
    }
    if (currentQueue.length >= 1) {
      Future.delayed(Duration(milliseconds: 150), () {
        animateIn(currentQueue[0]);
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _animationControllerY = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
    _animationControllerX = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
  }

  _onPointerMove(PointerMoveEvent ptr) {
    if (ptr.delta.dy <= 0) {
      totalMovedNegative += ptr.delta.dy;
    }
    if (_animationControllerY.value <= 0.5) {
      _animationControllerY.value += ptr.delta.dy / 400;
    } else {
      _animationControllerY.value +=
          ptr.delta.dy / (2000 * _animationControllerY.value * 8);
    }
    _animationControllerX.value +=
        ptr.delta.dx / (1000 + (_animationControllerX.value - 0.5).abs() * 100);

    currentTimeout!.pause();
  }

  _onPointerUp(PointerUpEvent event) {
    if (totalMovedNegative <= -200) {
      // if user drags it around but has a net negative, swipe up
      animateOut();
    } else if (_animationControllerY.value <= 0.4) {
      // it is swiped up
      animateOut();
    } else {
      _animationControllerY.animateTo(0.5,
          curve: Curves.elasticOut,
          duration: Duration(
              milliseconds:
                  ((_animationControllerY.value - 0.5).abs() * 800 + 700)
                      .toInt()));

      currentTimeout!.start();
    }

    _animationControllerX.animateTo(0.5,
        curve: Curves.elasticOut,
        duration: Duration(
            milliseconds:
                ((_animationControllerX.value - 0.5).abs() * 800 + 700)
                    .toInt()));
    totalMovedNegative = 0;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationControllerX,
      builder: (context, child) {
        return child!;
      },
      child: AnimatedBuilder(
        animation: _animationControllerY,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
                (_animationControllerX.value - 0.5) * 100,
                (_animationControllerY.value - 0.5) * 400 +
                    MediaQuery.viewPaddingOf(context).top +
                    10),
            child: child,
          );
        },
        child: Listener(
          onPointerMove: (ptr) => {_onPointerMove(ptr)},
          onPointerUp: (ptr) => {_onPointerUp(ptr)},
          child: Center(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.light
                        ? getColor(context, "shadowColorLight")
                        : getColor(context, "shadowColor").withOpacity(0.1),
                    blurRadius: 15,
                    offset: Offset(0, 0),
                    spreadRadius: 2,
                  ),
                ]),
                child: Tappable(
                    hasOpacity: false,
                    onTap: () {
                      if (currentMessage?.onTap != null)
                        currentMessage?.onTap!();
                      animateOut();
                    },
                    borderRadius: 13,
                    color: appStateSettings["materialYou"]
                        ? dynamicPastel(context,
                            Theme.of(context).colorScheme.secondaryContainer,
                            amountLight: 1, amountDark: 0.4)
                        : getColor(context, "lightDarkAccent"),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              currentMessage?.icon == null
                                  ? SizedBox.shrink()
                                  : Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Icon(
                                        currentMessage?.icon,
                                        size: 33,
                                      ),
                                    ),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment:
                                      currentMessage?.icon == null
                                          ? CrossAxisAlignment.center
                                          : CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      currentMessage?.icon == null
                                          ? MainAxisAlignment.center
                                          : MainAxisAlignment.start,
                                  children: [
                                    TextFont(
                                      text: currentMessage?.title ?? "",
                                      textAlign: currentMessage?.icon == null
                                          ? TextAlign.center
                                          : TextAlign.left,
                                      fontSize: 15,
                                      maxLines: 3,
                                    ),
                                    currentMessage?.description == null
                                        ? SizedBox.shrink()
                                        : TextFont(
                                            maxLines: 5,
                                            text: currentMessage?.description ??
                                                "",
                                            textAlign:
                                                currentMessage?.icon == null
                                                    ? TextAlign.center
                                                    : TextAlign.left,
                                            fontSize: 13,
                                          ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
