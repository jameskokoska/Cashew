import 'package:budget/functions.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';

class PageFramework extends StatefulWidget {
  const PageFramework({
    Key? key,
    this.title = "",
    this.titleWidget,
    this.slivers = const [],
    this.listWidgets,
    this.navbar = true,
    this.appBarBackgroundColor,
    this.appBarBackgroundColorStart,
    this.showElevationAfterScrollPast,
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
  }) : super(key: key);

  final String title;
  final Widget? titleWidget;
  final List<Widget> slivers;
  final List<Widget>? listWidgets;
  final bool navbar;
  final Color? appBarBackgroundColor;
  final double? showElevationAfterScrollPast;
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

  @override
  State<PageFramework> createState() => PageFrameworkState();
}

class PageFrameworkState extends State<PageFramework>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  bool showElevation = false;
  late ScrollController _scrollController;
  late AnimationController _animationControllerShift;
  late AnimationController _animationControllerOpacity;
  late AnimationController _animationController0at50;
  late AnimationController _animationControllerDragY;
  // late AnimationController _animationControllerDragX;

  void scrollToTop() {
    _scrollController.animateTo(0,
        duration: const Duration(milliseconds: 1200), curve: Curves.elasticOut);
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

  double measurement = 0;
  @override
  void didChangeMetrics() {
    if (MediaQuery.of(context).viewInsets.bottom < measurement) {
      // keyboard closed
      _scrollListener();
    }
    measurement = MediaQuery.of(context).viewInsets.bottom;
  }

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
    if (widget.showElevationAfterScrollPast != null &&
        showElevation == false &&
        _scrollController.offset <
            widget.showElevationAfterScrollPast! + widget.expandedHeight - 65) {
      setState(() {
        showElevation = true;
      });
    } else if (widget.showElevationAfterScrollPast != null &&
        showElevation == true &&
        _scrollController.offset >
            widget.showElevationAfterScrollPast! + widget.expandedHeight - 65) {
      setState(() {
        showElevation = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _animationControllerShift.dispose();
    _animationControllerOpacity.dispose();
    _animationController0at50.dispose();
    _animationControllerDragY.dispose();
    // _animationControllerDragX.dispose();

    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  double keyboardOpenedPrevious = 0;

  double totalDragY = 0;
  double totalDragX = 0;
  bool swipeDownToDismiss = false;

  _onPointerMove(PointerMoveEvent ptr) {
    if (widget.dragDownToDismissEnabled) {
      if (swipeDownToDismiss) {
        totalDragX = totalDragX + ptr.delta.dx;
        totalDragY = totalDragY + ptr.delta.dy;
        //How far you need to drag to track drags - for animation
        _animationControllerDragY.value = totalDragY / 500;
        // _animationControllerDragX.value = 0.5 + totalDragX / 500;
      }
    }
  }

  _onPointerUp(PointerUpEvent event) {
    //How far you need to drag to dismiss
    if (widget.dragDownToDismissEnabled) {
      if (totalDragY >= 125) {
        if (widget.onDragDownToDissmiss != null) {
          widget.onDragDownToDissmiss!();
        } else {
          Navigator.of(context).pop();
          return;
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
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          PageFrameworkSliverAppBar(
            title: widget.title,
            titleWidget: widget.titleWidget,
            appBarBackgroundColor: widget.appBarBackgroundColor,
            appBarBackgroundColorStart: widget.appBarBackgroundColorStart,
            showElevationAfterScrollPast: widget.showElevationAfterScrollPast,
            backButton: widget.backButton,
            subtitle: widget.subtitle,
            subtitleSize: widget.subtitleSize,
            subtitleAnimationSpeed: widget.subtitleAnimationSpeed,
            onBottomReached: widget.onBottomReached,
            pinned: widget.pinned,
            subtitleAlignment: widget.subtitleAlignment,
            customTitleBuilder: widget.customTitleBuilder,
            showElevation: showElevation,
            animationControllerOpacity: _animationControllerOpacity,
            animationControllerShift: _animationControllerShift,
            animationController0at50: _animationController0at50,
            textColor: widget.textColor,
            onBackButton: widget.onBackButton,
            actions: widget.actions,
            expandedHeight: widget.expandedHeight,
          ),
          ...widget.slivers,
          widget.listWidgets != null
              ? SliverList(
                  delegate: SliverChildListDelegate([
                    ...widget.listWidgets!,
                    widget.navbar
                        ? SizedBox(height: 87 + bottomPaddingSafeArea)
                        : SizedBox(height: bottomPaddingSafeArea),
                  ]),
                )
              : SliverToBoxAdapter(
                  child: widget.navbar
                      ? SizedBox(height: 87 + bottomPaddingSafeArea)
                      : SizedBox.shrink(),
                ),
        ],
      ),
    );
    Widget? dragDownToDissmissScaffold = null;
    if (widget.dragDownToDismiss) {
      dragDownToDissmissScaffold = Scaffold(
        body: Listener(
          onPointerMove: (ptr) => {_onPointerMove(ptr)},
          onPointerUp: (ptr) => {_onPointerUp(ptr)},
          onPointerDown: (ptr) => {_onPointerDown(ptr)},
          behavior: HitTestBehavior.opaque,
          child: Scaffold(
            backgroundColor: widget.dragDownToDissmissBackground,
            body: AnimatedBuilder(
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
          ),
        ),
        //       );
        //     },
        //   ),
        // ),
      );
    }

    if (widget.floatingActionButton != null) {
      return Stack(
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
      return dragDownToDissmissScaffold ?? scaffold;
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
    this.showElevationAfterScrollPast,
    this.backButton = true,
    this.subtitle = null,
    this.subtitleSize = null,
    this.subtitleAnimationSpeed = 5,
    this.onBottomReached,
    this.pinned = true,
    this.subtitleAlignment = Alignment.bottomCenter,
    this.customTitleBuilder,
    this.showElevation,
    this.animationControllerOpacity,
    this.animationControllerShift,
    this.animationController0at50,
    this.actions,
    this.textColor,
    this.onBackButton,
    this.expandedHeight,
  }) : super(key: key);

  final String title;
  final Widget? titleWidget;
  final Color? appBarBackgroundColor;
  final double? showElevationAfterScrollPast;
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
  final bool? showElevation;
  final List<Widget>? actions;
  final Color? textColor;
  final VoidCallback? onBackButton;
  final double? expandedHeight;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      shadowColor: Theme.of(context).shadowColor.withAlpha(130),
      leading: backButton == true && animationControllerOpacity != null
          ? Container(
              padding: EdgeInsets.only(top: 12.5),
              child: FadeTransition(
                opacity: animationControllerOpacity!,
                child: IconButton(
                  onPressed: () {
                    if (onBackButton != null)
                      onBackButton!();
                    else
                      Navigator.of(context).pop();
                  },
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: Theme.of(context).colorScheme.black,
                  ),
                ),
              ),
            )
          : Container(),
      backgroundColor: appBarBackgroundColor == null
          ? Theme.of(context).colorScheme.secondaryContainer
          : appBarBackgroundColor,
      floating: false,
      pinned: pinned,
      expandedHeight: expandedHeight ?? 200,
      collapsedHeight: 65,
      elevation: showElevation == true ? 0 : 5,
      actions: actions,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: EdgeInsets.symmetric(vertical: 15, horizontal: 18),
        title: animationControllerShift == null
            ? titleWidget ??
                TextFont(
                  text: title,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  textColor: Theme.of(context).colorScheme.onSecondaryContainer,
                  textAlign: TextAlign.left,
                )
            : customTitleBuilder == null
                ? AnimatedBuilder(
                    animation: animationControllerShift!,
                    builder: (_, child) {
                      return Transform.translate(
                        offset: Offset(
                          backButton ? 40 * animationControllerShift!.value : 0,
                          -(subtitleSize ?? 0) *
                              (1 - animationControllerShift!.value),
                        ),
                        child: child,
                      );
                    },
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
                          textAlign: TextAlign.left,
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
                      alignment: subtitleAlignment,
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
      shape: ContinuousRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
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