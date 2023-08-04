import 'dart:math';
import 'dart:ui';

import 'package:budget/functions.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/struct/shareBudget.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/scrollbarWrap.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry/swipeToSelectTransactions.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';
import 'package:flutter/services.dart';

class PageFramework extends StatefulWidget {
  const PageFramework({
    Key? key,
    this.title = "",
    this.titleWidget,
    this.slivers = const [],
    this.listWidgets,
    this.appBarBackgroundColor,
    this.appBarBackgroundColorStart,
    this.backButton = true,
    this.subtitle = null,
    this.subtitleSize = null,
    this.subtitleAnimationSpeed = 5,
    this.onBottomReached,
    this.pinned = true,
    this.subtitleAlignment = Alignment.bottomCenter,
    // this.customTitleBuilder,
    this.onScroll,
    this.floatingActionButton,
    this.textColor,
    this.dragDownToDismiss = false,
    this.dragDownToDismissEnabled = true,
    this.dragDownToDissmissBackground,
    this.onBackButton,
    this.onDragDownToDissmiss,
    this.actions,
    this.expandedHeight,
    this.listID,
    this.sharedBudgetRefresh = false,
    this.horizontalPadding = 0,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = false,
    this.overlay,
    this.scrollToTopButton = false,
    this.bottomPadding = true,
    this.enableHeader = true,
  }) : super(key: key);

  final String title;
  final Widget? titleWidget;
  final List<Widget> slivers;
  final List<Widget>? listWidgets;
  final Color? appBarBackgroundColor;
  final bool backButton;
  final Color? appBarBackgroundColorStart;
  final Widget? subtitle;
  final double? subtitleSize;
  final double subtitleAnimationSpeed;
  final VoidCallback? onBottomReached;
  final bool pinned;
  final Alignment subtitleAlignment;
  // final Function(AnimationController _animationController)? customTitleBuilder;
  final Function(double position)? onScroll;
  final Widget? floatingActionButton;
  final Color? textColor;
  final bool dragDownToDismiss;
  final bool dragDownToDismissEnabled;
  final Color? dragDownToDissmissBackground;
  final VoidCallback? onBackButton;
  final VoidCallback? onDragDownToDissmiss;
  final List<Widget>? actions;
  final double? expandedHeight;
  final String? listID;
  final bool? sharedBudgetRefresh;
  final double horizontalPadding;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final Widget? overlay;
  final bool scrollToTopButton;
  final bool bottomPadding;
  final bool enableHeader;

  @override
  State<PageFramework> createState() => PageFrameworkState();
}

class PageFrameworkState extends State<PageFramework>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  double leftBackSwipeDetectionWidth = 50;

  late ScrollController _scrollController;
  late AnimationController _animationControllerShift =
      AnimationController(vsync: this);
  late AnimationController _animationControllerOpacity;
  late AnimationController _animationController0at50;
  late AnimationController _animationControllerDragY;
  late AnimationController _scrollToTopAnimationController =
      AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 500),
  );

  void scrollToTop({int duration = 1200}) {
    _scrollController.animateTo(0,
        duration: Duration(
            milliseconds:
                (getPlatform() == PlatformOS.isIOS ? duration * 0.2 : duration)
                    .round()),
        curve: getPlatform() == PlatformOS.isIOS
            ? Curves.easeInOut
            : Curves.elasticOut);
  }

  void scrollToBottom({int duration = 1200}) {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: Duration(
            milliseconds:
                (getPlatform() == PlatformOS.isIOS ? duration * 0.2 : duration)
                    .round()),
        curve: getPlatform() == PlatformOS.isIOS
            ? Curves.easeInOut
            : Curves.elasticOut);
  }

  void scrollTo(double position, {int duration = 1200}) {
    _scrollController.animateTo(position,
        duration: Duration(milliseconds: duration), curve: Curves.easeInOut);
  }

  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      double expandedHeaderHeight =
          getExpandedHeaderHeight(context, widget.expandedHeight);
      _animationControllerShift = AnimationController(
        vsync: this,
        value: expandedHeaderHeight - 56 == 0 ? 1 : 0,
      );
    });

    _animationControllerOpacity = AnimationController(vsync: this, value: 0.5);
    _animationController0at50 = AnimationController(vsync: this, value: 1);
    _animationControllerDragY = AnimationController(vsync: this, value: 0);
    _animationControllerDragY.duration = Duration(milliseconds: 1000);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addObserver(this);
  }

  // double measurement = 0;
  // @override
  // void didChangeMetrics() {
  //   // should be changed to the new method:
  //   // print(EdgeInsets.fromWindowPadding(WidgetsBinding.instance.window.viewInsets,WidgetsBinding.instance.window.devicePixelRatio));
  //   if (MediaQuery.of(context).viewInsets.bottom < measurement) {
  //     // keyboard closed
  //     _scrollListener();
  //   }
  //   measurement = MediaQuery.of(context).viewInsets.bottom;
  // }

  _scrollListener() {
    if (widget.onScroll != null) {
      widget.onScroll!(_scrollController.offset);
    }
    if (widget.onBottomReached != null &&
        _scrollController.offset >=
            _scrollController.position.maxScrollExtent) {
      widget.onBottomReached!();
    }
    double percent;
    if (getExpandedHeaderHeight(context, widget.expandedHeight) - 56 == 0) {
      percent = 100;
    } else {
      percent = _scrollController.offset /
          (getExpandedHeaderHeight(context, widget.expandedHeight) - 56);
    }
    if (widget.backButton == true ||
        widget.subtitle != null && percent >= 0 && percent <= 1) {
      _animationControllerShift.value = (_scrollController.offset /
          (getExpandedHeaderHeight(context, widget.expandedHeight) - 56));
      _animationControllerOpacity.value = 0.5 +
          (_scrollController.offset /
              (getExpandedHeaderHeight(context, widget.expandedHeight) - 56) /
              2);
    }
    if (widget.subtitle != null && percent <= 0.75 && percent >= 0) {
      _animationController0at50.value = 1 -
          (_scrollController.offset /
                  (getExpandedHeaderHeight(context, widget.expandedHeight) -
                      56)) *
              1.75;
    }
    if (_scrollController.offset > 400 &&
        _scrollToTopAnimationController.value == 0) {
      _scrollToTopAnimationController.forward();
    } else if (_scrollController.offset < 400 &&
        _scrollToTopAnimationController.value == 1) {
      _scrollToTopAnimationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationControllerShift.dispose();
    _animationControllerOpacity.dispose();
    _animationController0at50.dispose();
    _animationControllerDragY.dispose();
    _scrollToTopAnimationController.dispose();

    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  double keyboardOpenedPrevious = 0;

  double totalDragY = 0;
  double totalDragX = 0;
  bool swipeDownToDismiss = false;
  bool isBackSideSwiping = false;

  _onPointerMove(PointerMoveEvent ptr) {
    if ((widget.onDragDownToDissmiss != null ||
            Navigator.of(context).canPop()) &&
        widget.dragDownToDismissEnabled &&
        selectingTransactionsActive == 0) {
      if (isBackSideSwiping) {
        totalDragX = totalDragX + ptr.delta.dx;
        double calculatedYOffset = totalDragX / 500;
        if (calculatedYOffset > _animationControllerDragY.value)
          _animationControllerDragY.value = calculatedYOffset;
      }
      if (swipeDownToDismiss) {
        totalDragY = totalDragY + ptr.delta.dy;
        double calculatedYOffset = totalDragY / 500;
        if (calculatedYOffset > _animationControllerDragY.value)
          _animationControllerDragY.value = calculatedYOffset;
      }
    }
  }

  _onPointerUp(PointerUpEvent event) async {
    //How far you need to drag to dismiss
    if (widget.dragDownToDismissEnabled) {
      if ((totalDragX >= 90 || totalDragY >= 125) &&
          !(ModalRoute.of(context)?.isFirst ?? true)) {
        if (widget.onDragDownToDissmiss != null) {
          widget.onDragDownToDissmiss!();
        } else {
          await Navigator.of(context).maybePop();
        }
      } else {
        totalDragX = 0;
        totalDragY = 0;
        isBackSideSwiping = false;
        _animationControllerDragY.reverse();
      }
    }
  }

  _onPointerDown(PointerDownEvent event) {
    if (event.position.dx < leftBackSwipeDetectionWidth &&
        isBackSideSwiping == false) {
      isBackSideSwiping = true;
    }

    if (_scrollController.offset != 0) {
      swipeDownToDismiss = false;
    } else {
      swipeDownToDismiss = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget scaffold = Scaffold(
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
      backgroundColor: widget.backgroundColor,
      body: Stack(
        children: [
          ScrollbarWrap(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                ...(widget.enableHeader
                    ? [
                        PageFrameworkSliverAppBar(
                          title: widget.title,
                          titleWidget: widget.titleWidget,
                          appBarBackgroundColor: widget.appBarBackgroundColor,
                          appBarBackgroundColorStart:
                              widget.backgroundColor == null ||
                                      widget.appBarBackgroundColorStart != null
                                  ? widget.appBarBackgroundColorStart
                                  : widget.backgroundColor,
                          backButton: widget.backButton,
                          subtitle: widget.subtitle,
                          subtitleSize: widget.subtitleSize,
                          subtitleAnimationSpeed: widget.subtitleAnimationSpeed,
                          onBottomReached: widget.onBottomReached,
                          pinned: widget.pinned,
                          subtitleAlignment: widget.subtitleAlignment,
                          // customTitleBuilder: widget.customTitleBuilder,
                          animationControllerOpacity:
                              _animationControllerOpacity,
                          animationControllerShift: _animationControllerShift,
                          animationController0at50: _animationController0at50,
                          textColor: widget.textColor,
                          onBackButton: widget.onBackButton,
                          actions: widget.actions,
                          expandedHeight: getExpandedHeaderHeight(
                              context, widget.expandedHeight),
                        )
                      ]
                    : []),
                for (Widget sliver in widget.slivers)
                  widget.horizontalPadding == 0
                      ? sliver
                      : SliverPadding(
                          padding: EdgeInsets.symmetric(
                              horizontal: widget.horizontalPadding),
                          sliver: sliver),
                widget.listWidgets != null
                    ? SliverPadding(
                        padding: EdgeInsets.symmetric(
                            horizontal: widget.horizontalPadding),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            ...widget.listWidgets!,
                            widget.bottomPadding
                                ? SizedBox(
                                    height:
                                        MediaQuery.of(context).padding.bottom +
                                            15)
                                : SizedBox.shrink(),
                          ]),
                        ),
                      )
                    : SliverToBoxAdapter(
                        child: widget.bottomPadding
                            ? SizedBox(
                                height:
                                    MediaQuery.of(context).padding.bottom + 15)
                            : SizedBox.shrink(),
                      ),
              ],
            ),
          ),
          widget.overlay ?? SizedBox.shrink(),
        ],
      ),
    );
    Widget? dragDownToDissmissScaffold = null;
    if (widget.dragDownToDismiss) {
      dragDownToDissmissScaffold = Listener(
        onPointerMove: (ptr) => {_onPointerMove(ptr)},
        onPointerUp: (ptr) => {_onPointerUp(ptr)},
        onPointerDown: (ptr) => {_onPointerDown(ptr)},
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            Scaffold(
              resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
              backgroundColor: widget.dragDownToDissmissBackground,
              body: Stack(
                children: [
                  AnimatedBuilder(
                    animation: _animationControllerDragY,
                    builder: (_, child) {
                      return Transform.translate(
                        offset: Offset(
                            0,
                            _animationControllerDragY.value *
                                ((1 + 1 - _animationControllerDragY.value) *
                                    50)),
                        child: scaffold,
                      );
                    },
                  ),
                  widget.overlay ?? SizedBox.shrink(),
                ],
              ),
            ),
            // Catch any horizontal drag starts, we catch these so the use cannot scroll while back swiping
            appStateSettings["iOSNavigation"]
                ? SizedBox.shrink()
                : Container(
                    width: leftBackSwipeDetectionWidth,
                    child: GestureDetector(
                      onHorizontalDragStart: (details) => {},
                    ),
                  ),
          ],
        ),
        //       );
        //     },
        //   ),
        // ),
      );
    }

    Widget child;
    if (widget.floatingActionButton != null) {
      child = Stack(
        children: [
          dragDownToDissmissScaffold ?? scaffold,
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 15, right: 15),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  widget.scrollToTopButton
                      ? AnimatedBuilder(
                          animation: _scrollToTopAnimationController,
                          builder: (_, child) {
                            return IgnorePointer(
                              ignoring:
                                  _scrollToTopAnimationController.value <= 0.1,
                              child: Transform.translate(
                                offset: Offset(
                                  0,
                                  10 *
                                      (1 -
                                          CurvedAnimation(
                                                  parent:
                                                      _scrollToTopAnimationController,
                                                  curve: Curves.easeInOut)
                                              .value),
                                ),
                                child: child,
                              ),
                            );
                          },
                          child: FadeTransition(
                            opacity: CurvedAnimation(
                                parent: _scrollToTopAnimationController,
                                curve: Curves.easeInOut),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(right: 7, bottom: 1),
                              child: Transform.rotate(
                                angle: pi / 2,
                                child: ButtonIcon(
                                  icon: Icons.chevron_left_rounded,
                                  onTap: () {
                                    scrollToTop();
                                  },
                                ),
                              ),
                            ),
                          ),
                        )
                      : SizedBox.shrink(),
                  widget.floatingActionButton ?? Container(),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      child = dragDownToDissmissScaffold ?? scaffold;
    }

    child = SwipeToSelectTransactions(
      listID: widget.listID ?? "0",
      child: child,
    );

    if (widget.sharedBudgetRefresh == true) {
      return SharedBudgetRefresh(
        child: child,
        scrollController: _scrollController,
      );
    } else {
      return child;
    }
  }
}

class PageFrameworkSliverAppBar extends StatelessWidget {
  const PageFrameworkSliverAppBar({
    Key? key,
    this.title = "",
    this.titleWidget,
    this.appBarBackgroundColor,
    this.appBarBackgroundColorStart,
    this.backButton = true,
    this.subtitle = null,
    this.subtitleSize = null,
    this.subtitleAnimationSpeed = 5,
    this.onBottomReached,
    this.pinned = true,
    this.subtitleAlignment = Alignment.bottomCenter,
    // this.customTitleBuilder,
    this.animationControllerOpacity,
    this.animationControllerShift,
    this.animationController0at50,
    this.actions,
    this.textColor,
    this.onBackButton,
    this.expandedHeight,
    this.bottom,
  }) : super(key: key);

  final String title;
  final Widget? titleWidget;
  final Color? appBarBackgroundColor;
  final bool backButton;
  final Color? appBarBackgroundColorStart;
  final Widget? subtitle;
  final double? subtitleSize;
  final double subtitleAnimationSpeed;
  final VoidCallback? onBottomReached;
  final bool pinned;
  final Alignment subtitleAlignment;
  // final Function(AnimationController _animationController)? customTitleBuilder;
  final AnimationController? animationControllerOpacity;
  final AnimationController? animationControllerShift;
  final AnimationController? animationController0at50;
  final List<Widget>? actions;
  final Color? textColor;
  final VoidCallback? onBackButton;
  final double? expandedHeight;
  final double collapsedHeight = 56;
  final PreferredSizeWidget? bottom;
  @override
  Widget build(BuildContext context) {
    bool safeToIgnoreBG = appBarBackgroundColorStart == null ||
        appBarBackgroundColorStart == Theme.of(context).canvasColor;
    Color? appBarBGColorCalculated = appBarBackgroundColor == null
        ? Theme.of(context).colorScheme.secondaryContainer
        : appBarBackgroundColor;
    if (appBarBGColorCalculated != null &&
        safeToIgnoreBG &&
        getPlatform() == PlatformOS.isIOS) {
      appBarBGColorCalculated =
          dynamicPastel(context, appBarBGColorCalculated, amount: 0.7)
              .withOpacity(0.8);
    }
    bool backButtonEnabled =
        ModalRoute.of(context)?.isFirst == false && backButton;
    return SliverAppBar(
      bottom: bottom,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarIconBrightness:
            determineBrightnessTheme(context) == Brightness.light
                ? Brightness.dark
                : Brightness.light,
      ),
      shadowColor: safeToIgnoreBG && getPlatform() == PlatformOS.isIOS
          ? Colors.transparent
          : Theme.of(context).shadowColor.withAlpha(130),
      leading: backButtonEnabled == true && animationControllerOpacity != null
          ? FadeTransition(
              opacity: animationControllerOpacity!,
              child: IconButton(
                onPressed: () {
                  if (onBackButton != null)
                    onBackButton!();
                  else
                    Navigator.of(context).maybePop();
                },
                icon: Icon(
                  getPlatform() == PlatformOS.isIOS
                      ? Icons.chevron_left_rounded
                      : Icons.arrow_back_rounded,
                  color: getColor(context, "black"),
                ),
              ),
            )
          : Container(),
      backgroundColor: appBarBGColorCalculated,
      floating: false,
      pinned: enableDoubleColumn(context) ? true : pinned,
      expandedHeight: getExpandedHeaderHeight(context, expandedHeight),
      collapsedHeight: collapsedHeight,
      actions: [
        ...(actions ?? []).asMap().entries.map((action) {
          int idx = action.key;
          int length = (actions ?? []).length;
          Widget widget = action.value;
          double offsetX = (length - 1 - idx) * 7;
          return Transform.translate(
            offset: Offset(offsetX, 0),
            child: widget,
          );
        })
      ],
      flexibleSpace: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        // print('constraints=' + constraints.toString());
        double expandedHeightCalculated =
            getExpandedHeaderHeight(context, expandedHeight);
        double percent = 1 -
            (constraints.biggest.height -
                    collapsedHeight -
                    MediaQuery.of(context).padding.top) /
                (expandedHeightCalculated - collapsedHeight);
        if (collapsedHeight == expandedHeightCalculated) percent = 1;
        return BlurBehindAppBar(
          child: FlexibleSpaceBar(
            centerTitle: enableDoubleColumn(context) ? true : false,
            titlePadding: EdgeInsets.symmetric(vertical: 15, horizontal: 18),
            title: MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: Transform.translate(
                offset: enableDoubleColumn(context)
                    ? Offset(0, 0)
                    //  Offset(0, -(1 - percent) * 40)
                    : Offset(
                        backButtonEnabled ? 46 * percent : 10 * percent,
                        -(subtitleSize ?? 0) * (1 - percent) + -0.5 * percent,
                      ),
                child: Transform.scale(
                  scale: percent * 0.15 + 1,
                  child: titleWidget ??
                      TextFont(
                        text: title,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        textColor: textColor == null
                            ? Theme.of(context).colorScheme.onSecondaryContainer
                            : textColor,
                        textAlign: enableDoubleColumn(context)
                            ? TextAlign.center
                            : TextAlign.left,
                      ),
                ),
              ),
            ),
            background: Stack(
              children: [
                Container(
                  color: appBarBackgroundColorStart == null
                      ? Theme.of(context).canvasColor
                      : appBarBackgroundColorStart,
                ),
                Opacity(
                  opacity: percent,
                  child: Container(
                    color: appBarBGColorCalculated,
                  ),
                ),
                subtitle != null &&
                        animationControllerShift != null &&
                        animationController0at50 != null
                    ? AnimatedBuilder(
                        animation: animationControllerShift!,
                        builder: (_, child) {
                          return Transform.translate(
                            offset: Offset(
                              0,
                              -(subtitleSize ?? 0) *
                                  (animationControllerShift!.value) *
                                  subtitleAnimationSpeed,
                            ),
                            child: child,
                          );
                        },
                        child: Align(
                          alignment: enableDoubleColumn(context)
                              ? Alignment.center
                              : subtitleAlignment,
                          child: FadeTransition(
                            opacity: animationController0at50!,
                            child: subtitle,
                          ),
                        ),
                      )
                    : SizedBox(),
              ],
            ),
          ),
        );
      }),
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.vertical(
      //     bottom: getWidthNavigationSidebar(context) > 0
      //         ? Radius.circular(0)
      //         : Radius.circular(15),
      //   ),
      // ),
    );
  }
}

// Only blur if iOS
class BlurBehindAppBar extends StatelessWidget {
  const BlurBehindAppBar({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (getPlatform() != PlatformOS.isIOS) return child;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: child,
      ),
    );
  }
}

// customTitleBuilder: (_animationControllerShift) {
//   return AnimatedBuilder(
//     animation: _animationControllerShift,
//     builder: (_, child) {
//       return Transform.translate(
//         offset: Offset(
//           _animationControllerShift.value * 10,
//           0,
//         ),
//         child: child,
//       );
//     },
//     child: TextFont(
//       text: "Test",
//       fontSize: 26,
//       fontWeight: FontWeight.bold,
//     ),
//   );
// },

double getExpandedHeaderHeight(
    BuildContext context, double? expandedHeightPassed) {
  if (expandedHeightPassed != null) return expandedHeightPassed;
  double height = MediaQuery.of(context).size.height;
  double minHeight = 682.37;
  double maxHeight = 853.33;

  double minHeaderHeight = 100;
  double maxHeaderHeight = 200;

  if (height >= maxHeight) {
    return maxHeaderHeight;
  } else if (height <= minHeight) {
    return minHeaderHeight;
  } else {
    double heightPercentage = (height - minHeight) / (maxHeight - minHeight);
    double expandedHeaderHeight = minHeaderHeight +
        heightPercentage * (maxHeaderHeight - minHeaderHeight);
    return expandedHeaderHeight;
  }
}
