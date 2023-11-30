import 'package:budget/colors.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timer_builder/timer_builder.dart';

bool enableSwipeDownToRefresh(BuildContext context) {
  return runningCloudFunctions == false &&
      appStateSettings["hasSignedIn"] != false &&
      appStateSettings["backupSync"] == true &&
      getIsFullScreen(context) == false;
}

class PullDownToRefreshSync extends StatefulWidget {
  const PullDownToRefreshSync({
    required this.child,
    required this.scrollController,
    Key? key,
  }) : super(key: key);

  final Widget child;
  final ScrollController scrollController;

  @override
  State<PullDownToRefreshSync> createState() => _PullDownToRefreshSyncState();
}

class _PullDownToRefreshSyncState extends State<PullDownToRefreshSync>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  double totalDragY = 0;
  double totalDragX = 0;
  bool swipeDownToRefresh = false;
  double maxDrag = 35;
  double speed = 0.35;
  late double dragAmountForRefresh = maxDrag;
  // Amount to scroll down to cancel the refresh operation
  double scrollDownToDismissThreshold = 10;
  // Amount to swipe down before the refresh starts sliding down.
  // Increasing this will create responsiveness 'lag' but will prevent accidental swipe downs when interacting with horizontal scrolls in the UI
  double swipeDownThreshold = 10;
  //Amount of dragging in X direction to cancel swipe down;
  double totalDragXToCancel = 40;

  bool thresholdReached = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
      reverseDuration: Duration(milliseconds: 300),
    );
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _animationController.dispose();
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  _onScroll() {
    if (widget.scrollController.offset > scrollDownToDismissThreshold) {
      if (swipeDownToRefresh == true) {
        setState(() {
          swipeDownToRefresh = false;
          _animationController.reverse();
        });
      }
    }
  }

  _onPointerMove(PointerMoveEvent ptr) {
    if (enableSwipeDownToRefresh(context)) {
      if (swipeDownToRefresh) {
        if (totalDragX > totalDragXToCancel) return;
        totalDragY = totalDragY + ptr.delta.dy * speed;
        if (totalDragY > swipeDownThreshold) {
          _animationController.value =
              (totalDragY - swipeDownThreshold) / maxDrag;
        } else {
          // Only increase the total drag X if we have not reached the threshold for swiping down
          // (i.e. we aren't in a swiping down to refresh)
          totalDragX = totalDragX + ptr.delta.dx.abs();
        }
        if ((totalDragY - swipeDownThreshold) > dragAmountForRefresh) {
          if (thresholdReached == false) {
            HapticFeedback.heavyImpact();
            thresholdReached = true;
          }
        }
      }
    }
  }

  _onPointerUp(PointerUpEvent event) {
    if ((totalDragY - swipeDownThreshold) > dragAmountForRefresh &&
        swipeDownToRefresh) {
      _refreshBudgets();
      HapticFeedback.heavyImpact();
    } else {
      _animationController.reverse();
    }
    thresholdReached = false;
    totalDragY = 0;
    totalDragX = 0;
  }

  _onPointerDown(PointerDownEvent event) {
    if (widget.scrollController.offset > 0) {
      swipeDownToRefresh = false;
    } else {
      swipeDownToRefresh = true;
    }
  }

  _refreshBudgets() async {
    _animationController.reverse();
    if (runningCloudFunctions == false) await runAllCloudFunctions(context);
  }

  @override
  Widget build(BuildContext context) {
    final CurvedAnimation curvedAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    final CurvedAnimation curvedAnimationSlow = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInCubic,
    );

    return Stack(
      children: [
        AnimatedBuilder(
          animation: curvedAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                0,
                maxDrag * curvedAnimation.value,
              ),
              child: Listener(
                onPointerMove: (ptr) => {_onPointerMove(ptr)},
                onPointerUp: (ptr) => {_onPointerUp(ptr)},
                onPointerDown: (ptr) => {_onPointerDown(ptr)},
                behavior: HitTestBehavior.opaque,
                child: widget.child,
              ),
            );
          },
        ),
        AnimatedBuilder(
          animation: curvedAnimationSlow,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                  0,
                  -(maxDrag + MediaQuery.viewPaddingOf(context).top) *
                      (1 - curvedAnimation.value)),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(
                        top: MediaQuery.viewPaddingOf(context).top),
                    height: maxDrag + MediaQuery.viewPaddingOf(context).top,
                    width: double.infinity,
                    color: appStateSettings["materialYou"]
                        ? dynamicPastel(context,
                            Theme.of(context).colorScheme.secondaryContainer,
                            amountLight: 0.3, amountDark: 0.65)
                        : dynamicPastel(
                            context, getColor(context, "lightDarkAccent"),
                            amountLight: 0.1, amountDark: 0.3),
                    child: TimerBuilder.periodic(
                      Duration(seconds: 5),
                      builder: (context) {
                        return Center(
                          child: TextFont(
                            textAlign: TextAlign.center,
                            textColor: getColor(context, "textLight"),
                            fontSize: 13,
                            maxLines: 3,
                            text: "synced".tr() +
                                " " +
                                (getTimeLastSynced() == null
                                    ? "never".tr()
                                    : getTimeAgo(getTimeLastSynced()!)),
                          ),
                        );
                      },
                    ),
                  ),
                  Transform.scale(
                    alignment: Alignment.topCenter,
                    scaleX: curvedAnimationSlow.value,
                    child: Container(
                      height: 2,
                      color: dynamicPastel(
                          context, Theme.of(context).colorScheme.primary,
                          amountLight: 0.5, amountDark: 0.55),
                      child: Container(),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
