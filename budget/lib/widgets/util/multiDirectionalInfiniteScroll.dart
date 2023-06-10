import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/noResults.dart';
import 'package:budget/widgets/scrollbarWrap.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/budgetPage.dart';
import 'package:budget/pages/transactionsSearchPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/shareBudget.dart';
import 'package:budget/widgets/selectedTransactionsActionBar.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:budget/main.dart';
import 'package:budget/colors.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'dart:math';
import 'package:flutter/rendering.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:implicitly_animated_reorderable_list/transitions.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:budget/widgets/util/sliverPinnedOverlapInjector.dart';

ValueNotifier<bool> cancelParentScroll = ValueNotifier<bool>(false);

class MultiDirectionalInfiniteScroll extends StatefulWidget {
  const MultiDirectionalInfiniteScroll({
    Key? key,
    required this.itemBuilder,
    this.initialItems,
    this.overBoundsDetection = 50,
    this.startingScrollPosition = 0,
    this.duration = const Duration(milliseconds: 100),
    this.height = 40,
    this.onTopLoaded,
    this.onBottomLoaded,
    this.onScroll,
  }) : super(key: key);
  final int? initialItems;
  final int overBoundsDetection;
  final Function(int index) itemBuilder;
  final double startingScrollPosition;
  final Duration duration;
  final double height;
  final Function? onTopLoaded;
  final Function? onBottomLoaded;
  final Function? onScroll;
  @override
  State<MultiDirectionalInfiniteScroll> createState() =>
      MultiDirectionalInfiniteScrollState();
}

class MultiDirectionalInfiniteScrollState
    extends State<MultiDirectionalInfiniteScroll> {
  late ScrollController _scrollController;
  List<int> top = [1];
  List<int> bottom = [-1, 0];

  void initState() {
    super.initState();
    if (widget.initialItems != null) {
      top = [];
      bottom = [0];
      for (int i = 1; i < widget.initialItems!; i++) {
        top.insert(0, -(widget.initialItems! - i));
        bottom.add(i);
      }
    }
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        widget.startingScrollPosition,
        duration: widget.duration,
        curve: ElasticOutCurve(0.7),
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  scrollTo(duration, {double? position}) {
    _scrollController.animateTo(
      position == null ? widget.startingScrollPosition : position,
      duration: duration,
      curve: Curves.fastOutSlowIn,
    );
  }

  _scrollListener() {
    if (_scrollController.offset >=
        _scrollController.position.maxScrollExtent -
            widget.overBoundsDetection) {
      _onEndReached();
      if (widget.onTopLoaded != null) {
        widget.onTopLoaded!();
      }
    }
    if (_scrollController.offset <=
        _scrollController.position.minScrollExtent +
            widget.overBoundsDetection) {
      _onStartReached();
      if (widget.onBottomLoaded != null) {
        widget.onBottomLoaded!();
      }
    }
    if (widget.onScroll != null) {
      widget.onScroll!(_scrollController.offset);
    }
  }

  _onEndReached() {
    setState(() {
      bottom.add(bottom.length);
    });
  }

  _onStartReached() {
    setState(() {
      top.add(-top.length - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        cancelParentScroll.value = true;
        cancelParentScroll.notifyListeners();
      },
      onExit: (_) {
        cancelParentScroll.value = false;
        cancelParentScroll.notifyListeners();
      },
      child: Listener(
        onPointerSignal: (event) {
          if (event is PointerScrollEvent) {
            _scrollController.animateTo(
              _scrollController.offset + event.scrollDelta.dy,
              curve: Curves.linear,
              duration: Duration(milliseconds: 100),
            );
          }
        },
        child: Container(
          height: widget.height,
          child: CustomScrollView(
            scrollDirection: Axis.horizontal,
            controller: _scrollController,
            center: ValueKey('second-sliver-list'),
            slivers: <Widget>[
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return widget.itemBuilder(top[index]);
                  },
                  childCount: top.length,
                ),
              ),
              SliverList(
                key: ValueKey('second-sliver-list'),
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return widget.itemBuilder(bottom[index]);
                  },
                  childCount: bottom.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
