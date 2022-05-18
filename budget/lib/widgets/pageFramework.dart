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
  @override
  State<PageFramework> createState() => _PageFrameworkState();
}

class _PageFrameworkState extends State<PageFramework>
    with TickerProviderStateMixin {
  bool showElevation = false;
  late ScrollController _scrollController;
  late AnimationController _animationControllerShift;
  late AnimationController _animationControllerOpacity;
  late AnimationController _animationController0at50;
  void initState() {
    super.initState();
    _animationControllerShift = AnimationController(vsync: this);
    _animationControllerOpacity = AnimationController(vsync: this, value: 0.5);
    _animationController0at50 = AnimationController(vsync: this, value: 1);

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
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
    double percent = _scrollController.offset / (200 - 65);
    if (widget.backButton == true ||
        widget.subtitle != null && percent >= 0 && percent <= 1) {
      _animationControllerShift.value = (_scrollController.offset / (200 - 65));
      _animationControllerOpacity.value =
          0.5 + (_scrollController.offset / (200 - 65) / 2);
    }
    if (widget.subtitle != null && percent <= 0.75 && percent >= 0) {
      _animationController0at50.value =
          1 - (_scrollController.offset / (200 - 65)) * 1.75;
    }
    if (widget.showElevationAfterScrollPast != null &&
        showElevation == false &&
        _scrollController.offset <
            widget.showElevationAfterScrollPast! + 200 - 65) {
      setState(() {
        showElevation = true;
      });
    } else if (widget.showElevationAfterScrollPast != null &&
        showElevation == true &&
        _scrollController.offset >
            widget.showElevationAfterScrollPast! + 200 - 65) {
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
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          ),
          ...widget.slivers,
          widget.listWidgets != null
              ? SliverList(
                  delegate: SliverChildListDelegate([
                    ...widget.listWidgets!,
                    widget.navbar ? Container(height: 67) : Container(),
                  ]),
                )
              : SliverToBoxAdapter(
                  child: widget.navbar ? Container(height: 67) : Container(),
                ),
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      leading: backButton == true && animationControllerOpacity != null
          ? Container(
              padding: EdgeInsets.only(top: 12.5),
              child: FadeTransition(
                opacity: animationControllerOpacity!,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
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
          ? Theme.of(context).canvasColor
          : appBarBackgroundColor,
      floating: false,
      pinned: pinned,
      expandedHeight: 200.0,
      collapsedHeight: 65,
      elevation: showElevation == true ? 0 : 5,
      actions: actions,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.symmetric(vertical: 15, horizontal: 18),
        title: animationControllerShift == null
            ? titleWidget ??
                TextFont(
                  text: title,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
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
                        ),
                  )
                : customTitleBuilder!(animationControllerShift!),
        background: Stack(
          children: [
            Container(
              color: appBarBackgroundColorStart,
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
                          child: child);
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