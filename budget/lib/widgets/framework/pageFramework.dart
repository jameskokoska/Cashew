import 'dart:math';
import 'dart:ui';

import 'package:budget/functions.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/struct/shareBudget.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/openBottomSheet.dart';
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
    this.subtitleAnimationSpeed,
    this.onBottomReached,
    this.pinned = true,
    this.subtitleAlignment = Alignment.bottomCenter,
    // this.customTitleBuilder,
    this.onScroll,
    this.floatingActionButton,
    this.textColor,
    this.dragDownToDismiss = false,
    this.dragDownToDismissEnabled = true,
    this.dragDownToDismissBackground,
    this.onBackButton,
    this.onDragDownToDismiss,
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
    this.scrollPhysics,
    this.belowAppBarPaddingWhenCenteredTitleSmall,
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
  final double? subtitleAnimationSpeed;
  final VoidCallback? onBottomReached;
  final bool pinned;
  final Alignment subtitleAlignment;
  // final Function(AnimationController _animationController)? customTitleBuilder;
  final Function(double position)? onScroll;
  final Widget? floatingActionButton;
  final Color? textColor;
  final bool dragDownToDismiss;
  final bool dragDownToDismissEnabled;
  final Color? dragDownToDismissBackground;
  final VoidCallback? onBackButton;
  final VoidCallback? onDragDownToDismiss;
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
  final ScrollPhysics? scrollPhysics;
  final double? belowAppBarPaddingWhenCenteredTitleSmall;

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
    if (widget.backButton == true || widget.subtitle != null && percent <= 1) {
      double offset = _scrollController.offset;
      if (percent < 0) offset = 0;
      _animationControllerShift.value = (offset /
          (getExpandedHeaderHeight(context, widget.expandedHeight) - 56));
      _animationControllerOpacity.value = 0.5 +
          (offset /
              (getExpandedHeaderHeight(context, widget.expandedHeight) - 56) /
              2);
    }
    if (widget.subtitle != null && percent <= 0.75) {
      double offset = _scrollController.offset;
      if (percent < 0) offset = 0;
      _animationController0at50.value = 1 -
          (offset /
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
  double calculatedYOffsetForX = 0;
  double calculatedYOffsetForY = 0;

  _onPointerMove(PointerMoveEvent ptr) {
    if ((widget.onDragDownToDismiss != null ||
            Navigator.of(context).canPop()) &&
        widget.dragDownToDismissEnabled &&
        selectingTransactionsActive == 0) {
      if (isBackSideSwiping) {
        totalDragX = totalDragX + ptr.delta.dx;
        calculatedYOffsetForX = totalDragX / 500;
      }
      if (swipeDownToDismiss) {
        totalDragY = totalDragY + ptr.delta.dy;
        calculatedYOffsetForY = totalDragY / 500;
      }
      _animationControllerDragY.value =
          max(calculatedYOffsetForX, calculatedYOffsetForY);
    }
  }

  _onPointerUp(PointerUpEvent event) async {
    //How far you need to drag to dismiss
    if (widget.dragDownToDismissEnabled) {
      if ((totalDragX >= 90 || totalDragY >= 125) &&
          !(ModalRoute.of(context)?.isFirst ?? true)) {
        if (widget.onDragDownToDismiss != null) {
          widget.onDragDownToDismiss!();
        } else {
          await Navigator.of(context).maybePop();
        }
      }
      // This cannot be in an else statement
      // If a popup comes e.g. discard changes and user hits cancel
      // we need to already have had this reset!
      totalDragX = 0;
      totalDragY = 0;
      calculatedYOffsetForY = 0;
      calculatedYOffsetForX = 0;
      isBackSideSwiping = false;
      _animationControllerDragY.reverse();
    }
  }

  _onPointerDown(PointerDownEvent event) {
    if (event.position.dx < leftBackSwipeDetectionWidth &&
        isBackSideSwiping == false) {
      isBackSideSwiping = true;
    }

    if (_scrollController.offset > 0) {
      swipeDownToDismiss = false;
    } else {
      swipeDownToDismiss = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool backButtonEnabled =
        ModalRoute.of(context)?.isFirst == false && widget.backButton;
    bool centeredTitle = getPlatform() == PlatformOS.isIOS && backButtonEnabled
        ? true
        : enableDoubleColumn(context)
            ? true
            : false;
    bool centeredTitleSmall =
        getPlatform() == PlatformOS.isIOS && backButtonEnabled;

    Widget scaffold = Scaffold(
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
      backgroundColor: widget.backgroundColor,
      body: Stack(
        children: [
          ScrollbarWrap(
            child: CustomScrollView(
              physics: widget.scrollPhysics,
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
                          centeredTitle: centeredTitle,
                          centeredTitleSmall: centeredTitleSmall,
                          belowAppBarPaddingWhenCenteredTitleSmall:
                              widget.belowAppBarPaddingWhenCenteredTitleSmall,
                        ),
                        if (centeredTitleSmall)
                          SliverToBoxAdapter(
                            child: Center(child: widget.subtitle),
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
            Stack(
              children: [
                ...getAppBarBackgroundColorLayers(
                  animationControllerOpacity: _animationControllerOpacity,
                  appBarBackgroundColor: widget.appBarBackgroundColor,
                  appBarBackgroundColorStart: widget.appBarBackgroundColorStart,
                  centeredTitle: centeredTitle,
                  centeredTitleSmall: centeredTitleSmall,
                  context: context,
                  printValues: true,
                ),
                AnimatedBuilder(
                  animation: _animationControllerDragY,
                  builder: (_, child) {
                    return Transform.translate(
                      offset: Offset(
                          0,
                          _animationControllerDragY.value *
                              ((1 + 1 - _animationControllerDragY.value) * 50)),
                      child: scaffold,
                    );
                  },
                ),
                widget.overlay ?? SizedBox.shrink(),
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
          ],
        ),
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

    child = MediaQuery.removePadding(
      context: context,
      removeLeft: true,
      removeRight: true,
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
    this.subtitleAnimationSpeed,
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
    this.centeredTitle,
    this.centeredTitleSmall,
    this.belowAppBarPaddingWhenCenteredTitleSmall,
  }) : super(key: key);

  final String title;
  final Widget? titleWidget;
  final Color? appBarBackgroundColor;
  final bool backButton;
  final Color? appBarBackgroundColorStart;
  final Widget? subtitle;
  final double? subtitleSize;
  final double? subtitleAnimationSpeed;
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
  final bool? centeredTitle;
  final bool? centeredTitleSmall;
  final double? belowAppBarPaddingWhenCenteredTitleSmall;
  @override
  Widget build(BuildContext context) {
    bool backButtonEnabled =
        ModalRoute.of(context)?.isFirst == false && backButton;
    bool centeredTitleWithDefault =
        centeredTitle ?? getPlatform() == PlatformOS.isIOS && backButtonEnabled
            ? true
            : enableDoubleColumn(context)
                ? true
                : false;
    bool centeredTitleSmallWithDefault = centeredTitleSmall ??
        getPlatform() == PlatformOS.isIOS && backButtonEnabled;

    Widget appBar = SliverAppBar(
      surfaceTintColor: Colors.transparent,
      bottom: bottom,
      shadowColor: getPlatform() == PlatformOS.isIOS
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
      backgroundColor: calculateAppBarBGColor(
        context: context,
        appBarBackgroundColor: appBarBackgroundColor,
        centeredTitleSmall: centeredTitleSmallWithDefault,
      ),
      floating: false,
      pinned: enableDoubleColumn(context) ? true : pinned,
      expandedHeight: centeredTitleSmallWithDefault
          ? 0
          : getExpandedHeaderHeight(context, expandedHeight),
      collapsedHeight: collapsedHeight,
      actions: pushActionsTogether(actions),
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
        String titleString = title.capitalizeFirst;
        return FlexibleSpaceBar(
          centerTitle: centeredTitleWithDefault,
          titlePadding: EdgeInsets.symmetric(vertical: 15, horizontal: 18),
          title: MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: Transform.translate(
              offset: centeredTitleWithDefault
                  ? Offset(0, centeredTitleSmallWithDefault ? -3.3 : 0)
                  //  Offset(0, -(1 - percent) * 40)
                  : Offset(
                      backButtonEnabled ? 46 * percent : 10 * percent,
                      -(subtitleSize ?? 0) * (1 - percent) + -0.5 * percent,
                    ),
              child: Transform.scale(
                scale: percent * 0.15 + 1,
                child: titleWidget ??
                    TextFont(
                      text: getIsFullScreen(context) == false &&
                              titleString.length > 20
                          ? titleString.split(" ")[0]
                          : titleString,
                      fontSize: centeredTitleSmallWithDefault ? 16 : 22,
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
              ...getAppBarBackgroundColorLayers(
                animationControllerOpacity: animationControllerOpacity,
                appBarBackgroundColor: appBarBackgroundColor,
                appBarBackgroundColorStart: appBarBackgroundColorStart,
                centeredTitle: centeredTitleWithDefault,
                centeredTitleSmall: centeredTitleSmallWithDefault,
                context: context,
              ),
              subtitle != null &&
                      animationControllerShift != null &&
                      animationController0at50 != null &&
                      centeredTitleSmallWithDefault == false
                  ? AnimatedBuilder(
                      animation: animationControllerShift!,
                      builder: (_, child) {
                        double expandedHeightHeaderPercent =
                            getExpandedHeaderHeight(context, expandedHeight);
                        expandedHeightHeaderPercent =
                            (expandedHeightHeaderPercent - 100) / 100;
                        // print(expandedHeightHeaderPercent * 150 + 50);
                        return Transform.translate(
                          offset: Offset(
                            0,
                            -(animationControllerShift!.value) *
                                (subtitleAnimationSpeed ?? 100) *
                                (expandedHeightHeaderPercent * 150 + 50) /
                                200,
                          ),
                          child: child,
                        );
                      },
                      child: Align(
                        alignment: centeredTitleWithDefault
                            ? Alignment.bottomCenter
                            : subtitleAlignment,
                        child: FadeTransition(
                          opacity: animationController0at50!,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 0),
                            child: Transform.translate(
                              offset: Offset(0, -4),
                              child: subtitle,
                            ),
                          ),
                        ),
                      ),
                    )
                  : SizedBox(),
            ],
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

    if (belowAppBarPaddingWhenCenteredTitleSmall == 0 ||
        belowAppBarPaddingWhenCenteredTitleSmall == null) {
      return appBar;
    }
    return SliverPadding(
      padding: EdgeInsets.only(
          bottom: centeredTitleSmallWithDefault
              ? belowAppBarPaddingWhenCenteredTitleSmall ?? 10
              : 0),
      sliver: appBar,
    );
  }
}

Color calculateAppBarBGColor({
  required BuildContext context,
  required Color? appBarBackgroundColor,
  required bool centeredTitleSmall,
}) {
  Color appBarBGColorCalculated = appBarBackgroundColor == null
      ? Theme.of(context).colorScheme.secondaryContainer
      : appBarBackgroundColor;
  if (centeredTitleSmall && getPlatform() == PlatformOS.isIOS) {
    appBarBGColorCalculated =
        appBarBackgroundColor ?? Theme.of(context).canvasColor;
  }
  return appBarBGColorCalculated;
}

List<Widget> getAppBarBackgroundColorLayers({
  required BuildContext context,
  required AnimationController? animationControllerOpacity,
  required Color? appBarBackgroundColor,
  required Color? appBarBackgroundColorStart,
  required bool centeredTitle,
  required bool centeredTitleSmall,
  bool? printValues = false,
}) {
  Color appBarBGColorCalculated = calculateAppBarBGColor(
    context: context,
    appBarBackgroundColor: appBarBackgroundColor,
    centeredTitleSmall: centeredTitleSmall,
  );
  return [
    animationControllerOpacity != null && centeredTitleSmall
        ? AnimatedBuilder(
            animation: animationControllerOpacity,
            builder: (_, child) {
              return Opacity(
                opacity: (animationControllerOpacity.value - 0.5) / 0.5,
                child: child,
              );
            },
            child: Container(
              color: appBarBackgroundColor ??
                  dynamicPastel(
                      context, Theme.of(context).colorScheme.secondaryContainer,
                      amount: appStateSettings["materialYou"] ? 0.4 : 0.55),
            ),
          )
        : SizedBox.shrink(),
    animationControllerOpacity != null && centeredTitleSmall
        ? AnimatedBuilder(
            animation: animationControllerOpacity,
            builder: (_, child) {
              return Opacity(
                opacity: (animationControllerOpacity.value - 0.5) / 0.5,
                child: child,
              );
            },
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 1.2,
                color: dynamicPastel(
                  context,
                  appBarBackgroundColor != null
                      ? appBarBackgroundColor
                      : dynamicPastel(context,
                          Theme.of(context).colorScheme.secondaryContainer,
                          amount: appStateSettings["materialYou"] ? 0.4 : 0.55),
                  inverse: true,
                  amount: 0.05,
                ),
              ),
            ),
          )
        : SizedBox.shrink(),
    animationControllerOpacity != null && centeredTitleSmall == false
        ? AnimatedBuilder(
            animation: animationControllerOpacity,
            builder: (_, child) {
              return Opacity(
                opacity: (animationControllerOpacity.value - 0.5) / 0.5,
                child: child,
              );
            },
            child: Container(
              height: 1.2,
              color: appBarBGColorCalculated,
            ),
          )
        : SizedBox.shrink(),
    centeredTitleSmall
        ? SizedBox.shrink()
        : Container(
            color: appBarBackgroundColorStart == null
                ? Theme.of(context).canvasColor
                : appBarBackgroundColorStart,
          ),
    animationControllerOpacity != null && centeredTitleSmall == false
        ? AnimatedBuilder(
            animation: animationControllerOpacity,
            builder: (_, child) {
              if (printValues == true)
                print((animationControllerOpacity.value - 0.5) / 0.5);
              return Opacity(
                opacity: (animationControllerOpacity.value - 0.5) / 0.5,
                child: child,
              );
            },
            child: Container(
              color: appBarBGColorCalculated,
            ),
          )
        : SizedBox.shrink(),
  ];
}

List<Widget> pushActionsTogether(List<Widget>? actions) {
  return (actions ?? []).asMap().entries.map((action) {
    int idx = action.key;
    int length = (actions ?? []).length;
    Widget widget = action.value;
    double offsetX = (length - 1 - idx) * 7;
    return Transform.translate(
      offset: Offset(offsetX, 0),
      child: widget,
    );
  }).toList();
}

// Only blur if iOS
class BlurBehindAppBar extends StatelessWidget {
  const BlurBehindAppBar({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (getPlatform() != PlatformOS.isIOS || appStateSettings["disableBlur"])
      return child;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: child,
      ),
    );
  }
}

// Small blur, used behind popups on iOS
class BlurBehind extends StatelessWidget {
  const BlurBehind({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (getPlatform() != PlatformOS.isIOS || appStateSettings["disableBlur"])
      return child;
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
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
    BuildContext context, double? expandedHeightPassed,
    {bool? isHomePageSpace}) {
  if (expandedHeightPassed != null) return expandedHeightPassed;
  double height = MediaQuery.of(context).size.height;
  double minHeight = 682.37;
  double maxHeight = 853.33;

  double minHeaderHeight = getPlatform() == PlatformOS.isIOS
      ? isHomePageSpace == true
          ? 0
          : 100
      : 100;
  double maxHeaderHeight = getPlatform() == PlatformOS.isIOS
      ? isHomePageSpace == true
          ? 0
          : 100
      : 200;

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
