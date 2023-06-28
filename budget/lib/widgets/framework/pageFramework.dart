import 'package:budget/functions.dart';
import 'package:budget/struct/shareBudget.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/scrollbarWrap.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry.dart';
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
    this.customTitleBuilder,
    this.onScroll,
    this.floatingActionButton,
    this.textColor,
    this.dragDownToDismiss = false,
    this.dragDownToDismissEnabled = true,
    this.dragDownToDissmissBackground,
    this.onBackButton,
    this.onDragDownToDissmiss,
    this.actions,
    this.expandedHeight = 200,
    this.listID,
    this.sharedBudgetRefresh = false,
    this.horizontalPadding = 0,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = false,
    this.overlay,
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
  final Function(AnimationController _animationController)? customTitleBuilder;
  final Function(double position)? onScroll;
  final Widget? floatingActionButton;
  final Color? textColor;
  final bool dragDownToDismiss;
  final bool dragDownToDismissEnabled;
  final Color? dragDownToDissmissBackground;
  final VoidCallback? onBackButton;
  final VoidCallback? onDragDownToDissmiss;
  final List<Widget>? actions;
  final double expandedHeight;
  final String? listID;
  final bool? sharedBudgetRefresh;
  final double horizontalPadding;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final Widget? overlay;

  @override
  State<PageFramework> createState() => PageFrameworkState();
}

class PageFrameworkState extends State<PageFramework>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late ScrollController _scrollController;
  late AnimationController _animationControllerShift;
  late AnimationController _animationControllerOpacity;
  late AnimationController _animationController0at50;
  late AnimationController _animationControllerDragY;
  // late AnimationController _animationControllerDragX;

  void scrollToTop({duration = 1200}) {
    _scrollController.animateTo(0,
        duration: Duration(milliseconds: duration), curve: Curves.elasticOut);
  }

  void scrollToBottom({duration = 1200}) {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: duration), curve: Curves.elasticOut);
  }

  void scrollTo(double position, {duration = 1200}) {
    _scrollController.animateTo(position,
        duration: Duration(milliseconds: duration), curve: Curves.easeInOut);
  }

  void initState() {
    super.initState();
    _animationControllerShift = AnimationController(
        vsync: this, value: widget.expandedHeight - 65 == 0 ? 1 : 0);
    _animationControllerOpacity = AnimationController(vsync: this, value: 0.5);
    _animationController0at50 = AnimationController(vsync: this, value: 1);
    _animationControllerDragY = AnimationController(vsync: this, value: 0);
    _animationControllerDragY.duration = Duration(milliseconds: 1000);
    // _animationControllerDragX = AnimationController(vsync: this, value: 0.5);
    // _animationControllerDragX.duration = Duration(milliseconds: 1000);
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
    if (widget.expandedHeight - 65 == 0) {
      percent = 100;
    } else {
      percent = _scrollController.offset / (widget.expandedHeight - 65);
    }
    if (widget.backButton == true ||
        widget.subtitle != null && percent >= 0 && percent <= 1) {
      _animationControllerShift.value =
          (_scrollController.offset / (widget.expandedHeight - 65));
      _animationControllerOpacity.value =
          0.5 + (_scrollController.offset / (widget.expandedHeight - 65) / 2);
    }
    if (widget.subtitle != null && percent <= 0.75 && percent >= 0) {
      _animationController0at50.value =
          1 - (_scrollController.offset / (widget.expandedHeight - 65)) * 1.75;
    }
  }

  @override
  void dispose() {
    _animationControllerShift.dispose();
    _animationControllerOpacity.dispose();
    _animationController0at50.dispose();
    _animationControllerDragY.dispose();
    // _animationControllerDragX.dispose();

    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  double keyboardOpenedPrevious = 0;

  double totalDragY = 0;
  double totalDragX = 0;
  bool swipeDownToDismiss = false;

  _onPointerMove(PointerMoveEvent ptr) {
    if (widget.dragDownToDismissEnabled && selectingTransactionsActive == 0) {
      if (swipeDownToDismiss) {
        totalDragX = totalDragX + ptr.delta.dx;
        totalDragY = totalDragY + ptr.delta.dy;
        //How far you need to drag to track drags - for animation
        _animationControllerDragY.value = totalDragY / 500;
        // _animationControllerDragX.value = 0.5 + totalDragX / 500;
      }
    }
  }

  _onPointerUp(PointerUpEvent event) async {
    //How far you need to drag to dismiss
    if (widget.dragDownToDismissEnabled) {
      if (totalDragY >= 125 && !(ModalRoute.of(context)?.isFirst ?? true)) {
        if (widget.onDragDownToDissmiss != null) {
          widget.onDragDownToDissmiss!();
        } else {
          await Navigator.of(context).maybePop();
        }
      }
      totalDragX = 0;
      totalDragY = 0;
      _animationControllerDragY.reverse();
      // _animationControllerDragX.animateTo(0.5);
    }
  }

  _onPointerDown(PointerDownEvent event) {
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
                PageFrameworkSliverAppBar(
                  title: widget.title,
                  titleWidget: widget.titleWidget,
                  appBarBackgroundColor: widget.appBarBackgroundColor,
                  appBarBackgroundColorStart: widget.backgroundColor == null ||
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
                  customTitleBuilder: widget.customTitleBuilder,
                  animationControllerOpacity: _animationControllerOpacity,
                  animationControllerShift: _animationControllerShift,
                  animationController0at50: _animationController0at50,
                  textColor: widget.textColor,
                  onBackButton: widget.onBackButton,
                  actions: widget.actions,
                  expandedHeight: widget.expandedHeight,
                ),
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
                            SizedBox(
                                height:
                                    MediaQuery.of(context).padding.bottom + 15),
                          ]),
                        ),
                      )
                    : SliverToBoxAdapter(
                        child: SizedBox(
                            height: MediaQuery.of(context).padding.bottom + 15),
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
        child: Scaffold(
          resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
          backgroundColor: widget.dragDownToDissmissBackground,
          body: Stack(
            children: [
              AnimatedBuilder(
                // animation: _animationControllerDragX,
                // builder: (_, child) {
                //   return Transform.translate(
                //     offset: Offset((_animationControllerDragX.value - 0.5) * 70, 0),
                //     child: Scaffold(
                //       backgroundColor: widget.dragDownToDissmissBackground,
                //       body: AnimatedBuilder(
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
            ],
          ),
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
              child: widget.floatingActionButton ?? Container(),
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
    this.customTitleBuilder,
    this.animationControllerOpacity,
    this.animationControllerShift,
    this.animationController0at50,
    this.actions,
    this.textColor,
    this.onBackButton,
    this.expandedHeight = 200,
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
  final Function(AnimationController _animationController)? customTitleBuilder;
  final AnimationController? animationControllerOpacity;
  final AnimationController? animationControllerShift;
  final AnimationController? animationController0at50;
  final List<Widget>? actions;
  final Color? textColor;
  final VoidCallback? onBackButton;
  final double expandedHeight;
  final double collapsedHeight = 65;
  final PreferredSizeWidget? bottom;
  @override
  Widget build(BuildContext context) {
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
      shadowColor: Theme.of(context).shadowColor.withAlpha(130),
      leading: backButtonEnabled == true && animationControllerOpacity != null
          ? Container(
              padding: EdgeInsets.only(top: 12.5),
              child: FadeTransition(
                opacity: animationControllerOpacity!,
                child: IconButton(
                  onPressed: () {
                    if (onBackButton != null)
                      onBackButton!();
                    else
                      Navigator.of(context).maybePop();
                  },
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: getColor(context, "black"),
                  ),
                ),
              ),
            )
          : Container(),
      backgroundColor: appBarBackgroundColor == null
          ? Theme.of(context).colorScheme.secondaryContainer
          : appBarBackgroundColor,
      floating: false,
      pinned: enableDoubleColumn(context) ? true : pinned,
      expandedHeight: expandedHeight,
      collapsedHeight: collapsedHeight,
      actions: [
        for (Widget action in actions ?? [])
          Padding(padding: EdgeInsets.only(top: 12.5, right: 5), child: action)
      ],
      flexibleSpace: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        // print('constraints=' + constraints.toString());
        double percent = 1 -
            (constraints.biggest.height -
                    collapsedHeight -
                    MediaQuery.of(context).padding.top) /
                (expandedHeight - collapsedHeight);
        if (collapsedHeight == expandedHeight) percent = 1;
        return ClipRRect(
          borderRadius: BorderRadius.vertical(
            bottom: getWidthNavigationSidebar(context) > 0
                ? Radius.circular(0)
                : Radius.circular(15),
          ),
          child: FlexibleSpaceBar(
            centerTitle: enableDoubleColumn(context) ? true : false,
            titlePadding: EdgeInsets.symmetric(vertical: 15, horizontal: 18),
            title: animationControllerShift == null
                ? MediaQuery(
                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                    child: titleWidget ??
                        TextFont(
                          text: title,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          textColor: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                          textAlign: enableDoubleColumn(context)
                              ? TextAlign.center
                              : TextAlign.left,
                        ),
                  )
                : customTitleBuilder == null
                    ? Transform.translate(
                        offset: enableDoubleColumn(context)
                            ? Offset(0, 0)
                            //  Offset(0, -(1 - percent) * 40)
                            : Offset(
                                backButtonEnabled ? 40 * percent : 0,
                                -(subtitleSize ?? 0) * (1 - percent),
                              ),
                        child: MediaQuery(
                          data: MediaQuery.of(context)
                              .copyWith(textScaleFactor: 1.0),
                          child: titleWidget ??
                              TextFont(
                                text: title,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                textColor: textColor == null
                                    ? Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer
                                    : textColor,
                                textAlign: enableDoubleColumn(context)
                                    ? TextAlign.center
                                    : TextAlign.left,
                              ),
                        ),
                      )
                    : customTitleBuilder!(animationControllerShift!),
            background: Stack(
              children: [
                Container(
                  color: appBarBackgroundColorStart == null
                      ? Theme.of(context).canvasColor
                      : appBarBackgroundColorStart,
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: getWidthNavigationSidebar(context) > 0
              ? Radius.circular(0)
              : Radius.circular(15),
        ),
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