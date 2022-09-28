import 'dart:async';
import 'dart:developer';

import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import '../colors.dart';
import 'package:intl/intl.dart';

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

  SnackbarMessage({
    this.title = "",
    this.description,
    this.icon,
    this.timeout = const Duration(milliseconds: 3500),
  });
}

class GlobalSnackbarState extends State<GlobalSnackbar>
    with TickerProviderStateMixin {
  Timer? currentTimeout;
  late AnimationController _animationControllerY;
  late AnimationController _animationControllerX;
  double totalMovedNegative = 0;
  List<SnackbarMessage> currentQueue = [];
  SnackbarMessage? currentMessage;

  post(SnackbarMessage message) {
    currentQueue.add(message);
    if (currentQueue.length <= 1) animateIn(message);
  }

  animateIn(SnackbarMessage message) {
    setState(() {
      currentMessage = currentQueue[0];
    });
    _animationControllerX.animateTo(0.5, duration: Duration.zero);
    _animationControllerY.animateTo(0.5,
        curve: ElasticOutCurve(0.7),
        duration: Duration(
            milliseconds:
                ((_animationControllerY.value - 0.5).abs() * 800 + 700)
                    .toInt()));
    currentTimeout = Timer(message.timeout, () {
      animateOut();
    });
  }

  animateOut() {
    currentTimeout?.cancel();
    _animationControllerY.animateTo(0,
        curve: Curves.elasticOut,
        duration: Duration(
            milliseconds:
                ((_animationControllerY.value - 0.5).abs() * 800 + 1000)
                    .toInt()));
    if (currentQueue.length >= 1) {
      currentQueue.removeAt(0);
    }
    if (currentQueue.length >= 1) {
      Future.delayed(Duration(milliseconds: 100), () {
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
      _animationControllerY.value += ptr.delta.dy / 200;
    } else {
      _animationControllerY.value +=
          ptr.delta.dy / (2000 * _animationControllerY.value * 4);
    }
    _animationControllerX.value +=
        ptr.delta.dx / (1000 + (_animationControllerX.value - 0.5).abs() * 100);
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
                (_animationControllerY.value - 0.5) * 200 +
                    MediaQuery.of(context).viewPadding.top +
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
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadowColorLight,
                    blurRadius: 20,
                    offset: Offset(0, 0),
                    spreadRadius: 8,
                  ),
                ]),
                child: Tappable(
                    onTap: () {},
                    borderRadius: 13,
                    color: Theme.of(context).colorScheme.lightDarkAccent,
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
                                    ),
                                    currentMessage?.description == null
                                        ? SizedBox.shrink()
                                        : TextFont(
                                            maxLines: 1,
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
