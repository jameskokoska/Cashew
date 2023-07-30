import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/scrollbarWrap.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/transactionsSearchPage.dart';
import 'package:budget/struct/shareBudget.dart';
import 'package:budget/widgets/selectedTransactionsActionBar.dart';
import 'package:budget/widgets/monthSelector.dart';
import 'package:budget/widgets/cashFlow.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/transactionEntries.dart';
import 'package:budget/widgets/transactionEntry/swipeToSelectTransactions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:budget/widgets/util/sliverPinnedOverlapInjector.dart';
import 'package:budget/widgets/util/multiDirectionalInfiniteScroll.dart';

class TransactionsListPage extends StatefulWidget {
  const TransactionsListPage({Key? key}) : super(key: key);

  @override
  State<TransactionsListPage> createState() => TransactionsListPageState();
}

class TransactionsListPageState extends State<TransactionsListPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  void refreshState() {
    setState(() {});
  }

  void scrollToTop() {
    _scrollController.animateTo(0,
        duration: const Duration(milliseconds: 1200), curve: Curves.elasticOut);
  }

  @override
  bool get wantKeepAlive => true;

  bool showAppBarPaddingOffset = false;
  bool alreadyChanged = false;

  bool scaleInSearchIcon = false;

  late ScrollController _scrollController;
  late AnimationController _animationControllerSearch;
  late PageController _pageController;
  late List<int> selectedTransactionIDs = [];

  GlobalKey<MonthSelectorState> monthSelectorStateKey = GlobalKey();

  onSelected(Transaction transaction, bool selected) {
    // print(transaction.transactionPk.toString() + " selected!");
    // print(globalSelectedID["Transactions"]);
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _animationControllerSearch = AnimationController(vsync: this, value: 1);
    _pageController = PageController(initialPage: 1000000);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationControllerSearch.dispose();
    _pageController.dispose();
    super.dispose();
  }

  _scrollListener() {
    double percent = _scrollController.offset /
        (MediaQuery.of(context).padding.top + 65 + 50);
    if (percent >= 0 && percent <= 1) {
      _animationControllerSearch.value = 1 - percent;
    }
    if (percent >= 1 && scaleInSearchIcon == false) {
      setState(() {
        scaleInSearchIcon = true;
      });
    } else if (percent < 1 && scaleInSearchIcon == true) {
      setState(() {
        scaleInSearchIcon = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: cancelParentScroll,
      builder: (context, value, widget) {
        return SharedBudgetRefresh(
          scrollController: _scrollController,
          child: Stack(
            children: [
              GestureDetector(
                onTap: () {
                  //Minimize keyboard when tap non interactive widget
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                },
                child: NestedScrollView(
                  controller: _scrollController,
                  physics: value ? NeverScrollableScrollPhysics() : null,
                  headerSliverBuilder:
                      (BuildContext contextHeader, bool innerBoxIsScrolled) {
                    return <Widget>[
                      SliverOverlapAbsorber(
                        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                            contextHeader),
                        sliver: MultiSliver(
                          children: [
                            PageFrameworkSliverAppBar(
                              title: "transactions".tr(),
                              actions: [
                                IconButton(
                                  padding: EdgeInsets.all(15),
                                  tooltip: "search-transactions".tr(),
                                  onPressed: () {
                                    pushRoute(
                                        context, TransactionsSearchPage());
                                  },
                                  icon: Icon(Icons.search_rounded),
                                ),
                              ],
                            ),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: MonthSelector(
                                  key: monthSelectorStateKey,
                                  setSelectedDateStart:
                                      (DateTime currentDateTime, int index) {
                                    if (((_pageController.page ?? 0) -
                                                index -
                                                _pageController.initialPage)
                                            .abs() ==
                                        1) {
                                      _pageController.animateToPage(
                                        _pageController.initialPage + index,
                                        duration: Duration(milliseconds: 1000),
                                        curve: Curves.easeInOutCubicEmphasized,
                                      );
                                    } else {
                                      _pageController.jumpToPage(
                                        _pageController.initialPage + index,
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ];
                  },
                  body: Stack(
                    children: [
                      Builder(
                        builder: (contextPageView) {
                          return PageView.builder(
                            controller: _pageController,
                            onPageChanged: (int index) {
                              final int pageOffset =
                                  index - _pageController.initialPage;
                              DateTime startDate = DateTime(DateTime.now().year,
                                  DateTime.now().month + pageOffset);
                              monthSelectorStateKey.currentState
                                  ?.setSelectedDateStart(startDate, pageOffset);
                              double middle = -(MediaQuery.of(context)
                                              .size
                                              .width -
                                          getWidthNavigationSidebar(context)) /
                                      2 +
                                  100 / 2;
                              monthSelectorStateKey.currentState?.scrollTo(
                                  middle + (pageOffset - 1) * 100 + 100);
                              // transactionsListPageStateKey.currentState!
                              //     .scrollToTop();
                            },
                            itemBuilder: (BuildContext context, int index) {
                              final int pageOffset =
                                  index - _pageController.initialPage;
                              DateTime startDate = DateTime(DateTime.now().year,
                                  DateTime.now().month + pageOffset);

                              return SwipeToSelectTransactions(
                                listID: "Transactions",
                                child: ScrollbarWrap(
                                  child: CustomScrollView(
                                    slivers: [
                                      SliverPinnedOverlapInjector(
                                        handle: NestedScrollView
                                            .sliverOverlapAbsorberHandleFor(
                                                contextPageView),
                                      ),
                                      TransactionEntries(
                                        startDate,
                                        new DateTime(
                                            startDate.year,
                                            startDate.month + 1,
                                            startDate.day - 1),
                                        onSelected: onSelected,
                                        listID: "Transactions",
                                        noResultsMessage: "no-transactions-for"
                                                .tr() +
                                            " " +
                                            getMonth(startDate.month) +
                                            (startDate.year !=
                                                    DateTime.now().year
                                                ? " " +
                                                    startDate.year.toString()
                                                : "") +
                                            ".",
                                      ),
                                      SliverToBoxAdapter(
                                        child: CashFlow(
                                          startDate,
                                          new DateTime(
                                            startDate.year,
                                            startDate.month + 1,
                                            startDate.day - 1,
                                          ),
                                        ),
                                      ),

                                      // Wipe all remaining pixels off - sometimes graphics artifacts are left behind
                                      SliverToBoxAdapter(
                                        child: SizedBox(
                                          height: 90 +
                                              MediaQuery.of(context)
                                                      .padding
                                                      .bottom /
                                                  4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      getIsFullScreen(context) == false
                          ? SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: IconButton(
                                  padding: EdgeInsets.all(15),
                                  icon: Icon(
                                    Icons.arrow_left_rounded,
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    _pageController.animateToPage(
                                      (_pageController.page ??
                                                  _pageController.initialPage)
                                              .round() -
                                          1,
                                      duration: Duration(milliseconds: 1000),
                                      curve: Curves.easeInOutCubicEmphasized,
                                    );
                                  },
                                ),
                              ),
                            ),
                      getIsFullScreen(context) == false
                          ? SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  padding: EdgeInsets.all(15),
                                  icon: Icon(
                                    Icons.arrow_right_rounded,
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    _pageController.animateToPage(
                                      (_pageController.page ??
                                                  _pageController.initialPage)
                                              .round() +
                                          1,
                                      duration: Duration(milliseconds: 1000),
                                      curve: Curves.easeInOutCubicEmphasized,
                                    );
                                  },
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
              SelectedTransactionsActionBar(
                pageID: "Transactions",
              ),
            ],
          ),
        );
      },
    );
  }
}
