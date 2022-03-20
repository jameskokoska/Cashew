import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';

class PageFramework extends StatefulWidget {
  const PageFramework({
    Key? key,
    required this.title,
    this.slivers = const [],
    this.listWidgets,
    this.navbar = true,
    this.appBarBackgroundColor,
    this.showElevationAfterScrollPast,
    this.backButton = true,
  }) : super(key: key);

  final String title;
  final List<Widget> slivers;
  final List<Widget>? listWidgets;
  final bool navbar;
  final Color? appBarBackgroundColor;
  final double? showElevationAfterScrollPast;
  final bool backButton;

  @override
  State<PageFramework> createState() => _PageFrameworkState();
}

class _PageFrameworkState extends State<PageFramework>
    with TickerProviderStateMixin {
  bool showElevation = false;
  late ScrollController _scrollController;
  late AnimationController _animationControllerShift;
  late AnimationController _animationControllerOpacity;
  void initState() {
    super.initState();
    _animationControllerShift = AnimationController(
      vsync: this,
    );
    _animationControllerOpacity = AnimationController(vsync: this, value: 0.5);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  _scrollListener() {
    double percent = _scrollController.offset / (200 - 65);
    if (percent >= 0 && percent <= 1) {
      _animationControllerShift.value = (_scrollController.offset / (200 - 65));
      _animationControllerOpacity.value =
          0.5 + (_scrollController.offset / (200 - 65) / 2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(bottom: widget.navbar ? 48 : 0),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              leading: widget.backButton == true
                  ? Container(
                      padding: EdgeInsets.only(top: 12.5),
                      child: FadeTransition(
                        opacity: _animationControllerOpacity,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.arrow_back_rounded),
                        ),
                      ),
                    )
                  : Container(),
              backgroundColor: widget.appBarBackgroundColor == null
                  ? Theme.of(context).canvasColor
                  : widget.appBarBackgroundColor,
              floating: false,
              pinned: true,
              expandedHeight: 200.0,
              collapsedHeight: 65,
              elevation: showElevation ? 0 : 5,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding:
                    EdgeInsets.symmetric(vertical: 15, horizontal: 18),
                title: AnimatedBuilder(
                  animation: _animationControllerShift,
                  builder: (_, child) {
                    return Transform.translate(
                      offset: Offset(40 * _animationControllerShift.value, 0),
                      child: child,
                    );
                  },
                  child: TextFont(
                    text: widget.title,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(25),
                ),
              ),
            ),
            ...widget.slivers,
            widget.listWidgets != null
                ? SliverList(
                    delegate: SliverChildListDelegate([
                      ...widget.listWidgets!,
                      widget.navbar ? Container(height: 17) : Container(),
                    ]),
                  )
                : SliverToBoxAdapter(
                    child: widget.navbar ? Container(height: 17) : Container(),
                  ),
          ],
        ),
      ),
    );
  }
}
