import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/noResults.dart';
import 'package:budget/widgets/scrollbarWrap.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/transactionsSearchPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/shareBudget.dart';
import 'package:budget/widgets/selectedTransactionsActionBar.dart';
import 'package:budget/widgets/monthSelector.dart';
import 'package:budget/widgets/cashFlow.dart';
import 'package:budget/widgets/ghostTransactions.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:implicitly_animated_reorderable_list/transitions.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:budget/widgets/util/sliverPinnedOverlapInjector.dart';
import 'package:budget/widgets/util/multiDirectionalInfiniteScroll.dart';
import 'dart:math';
import 'package:budget/struct/currencyFunctions.dart';

Widget getTransactionsSlivers(
  DateTime? startDay,
  DateTime? endDay, {
  search = "",
  List<int> categoryFks = const [],
  List<int> walletFks = const [],
  Function(Transaction, bool)? onSelected,
  String? listID,
  bool? income,
  bool sticky = true,
  bool slivers = true,
  List<BudgetTransactionFilters>? budgetTransactionFilters,
  List<String>? memberTransactionFilters,
  String? member,
  int? onlyShowTransactionsBelongingToBudget,
  bool simpleListRender = false,
  Budget? budget,
  Color? dateDividerColor,
  Color? transactionBackgroundColor,
  Color? categoryTintColor,
  bool useHorizontalPaddingConstrained = true,
  int? limit,
  bool showNoResults = true,
  ColorScheme? colorScheme,
  bool noSearchResultsVariation = false,
  String? noResultsMessage,
  SearchFilters? searchFilters,
}) {
  Random random = new Random();
  return StreamBuilder<List<DateTime?>>(
    stream: database.getUniqueDates(
      start: startDay,
      end: endDay,
      search: search,
      categoryFks: categoryFks,
      walletFks: walletFks,
      income: income,
      budgetTransactionFilters: budgetTransactionFilters,
      memberTransactionFilters: memberTransactionFilters,
      member: member,
      onlyShowTransactionsBelongingToBudget:
          onlyShowTransactionsBelongingToBudget,
      budget: budget,
      limit: limit,
      searchFilters: searchFilters,
    ),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        if (snapshot.data!.length <= 0 && showNoResults == true) {
          if (slivers) {
            return SliverToBoxAdapter(
              child: NoResults(
                message: noResultsMessage ??
                    "no-transactions-within-time-range".tr() + ".",
                tintColor: colorScheme != null
                    ? colorScheme.primary.withOpacity(0.6)
                    : null,
                noSearchResultsVariation: noSearchResultsVariation,
              ),
            );
          } else {
            return NoResults(
              message: noResultsMessage ??
                  "no-transactions-within-time-range".tr() + ".",
              tintColor: colorScheme != null
                  ? colorScheme.primary.withOpacity(0.6)
                  : null,
              noSearchResultsVariation: noSearchResultsVariation,
            );
          }
        }
        List<Widget> transactionsWidgets = [];
        DateTime previousDate = DateTime(1900);
        for (DateTime? dateNullable in snapshot.data!.reversed) {
          DateTime date = dateNullable ?? DateTime.now();
          if (previousDate.day == date.day &&
              previousDate.month == date.month &&
              previousDate.year == date.year) {
            continue;
          }
          // return SliverToBoxAdapter(
          //   child: GhostTransactions(i: random.nextInt(100)),
          // );
          previousDate = date;
          transactionsWidgets.add(
            StreamBuilder<List<TransactionWithCategory>>(
              stream: database.getTransactionCategoryWithDay(
                date,
                search: search,
                categoryFks: categoryFks,
                walletFks: walletFks,
                income: income,
                budgetTransactionFilters: budgetTransactionFilters,
                memberTransactionFilters: memberTransactionFilters,
                member: member,
                onlyShowTransactionsBelongingToBudget:
                    onlyShowTransactionsBelongingToBudget,
                searchFilters: searchFilters,
              ),
              builder: (context, snapshot) {
                if (snapshot.data != null && snapshot.hasData) {
                  if (slivers == false && snapshot.data!.length <= 0) {
                    return SizedBox.shrink();
                  }
                  List<TransactionWithCategory> transactionList =
                      snapshot.data!.reversed.toList();
                  double totalSpentForDay = 0;
                  transactionList.forEach((transaction) {
                    if (transaction.transaction.paid)
                      totalSpentForDay += transaction.transaction.amount *
                          (amountRatioToPrimaryCurrencyGivenPk(
                                  Provider.of<AllWallets>(context),
                                  transaction.transaction.walletFk) ??
                              0);
                  });
                  if (slivers == false) {
                    List<Widget> children = [];
                    for (int index = 0;
                        index < transactionList.length + 1;
                        index++) {
                      int realIndex = index - 1;
                      if (realIndex == -1) {
                        children.add(
                          DateDivider(
                            useHorizontalPaddingConstrained:
                                useHorizontalPaddingConstrained,
                            color: dateDividerColor,
                            date: date,
                            info: transactionList.length > 1
                                ? convertToMoney(
                                    Provider.of<AllWallets>(context),
                                    totalSpentForDay)
                                : "",
                          ),
                        );
                      } else {
                        children.add(
                          AnimatedSwitcher(
                            duration: Duration(milliseconds: 300),
                            child: TransactionEntry(
                              categoryTintColor: categoryTintColor,
                              useHorizontalPaddingConstrained:
                                  useHorizontalPaddingConstrained,
                              containerColor: transactionBackgroundColor,
                              key: ValueKey(transactionList[realIndex]
                                  .transaction
                                  .transactionPk),
                              category: transactionList[realIndex].category,
                              openPage: AddTransactionPage(
                                title: "Edit Transaction",
                                transaction:
                                    transactionList[realIndex].transaction,
                              ),
                              transaction:
                                  transactionList[realIndex].transaction,
                              onSelected:
                                  (Transaction transaction, bool selected) {
                                if (onSelected != null)
                                  onSelected(transaction, selected);
                              },
                              listID: listID,
                            ),
                          ),
                        );
                      }
                    }
                    return Column(
                      children: children,
                    );
                  }
                  Widget sliverList;
                  if (appStateSettings["batterySaver"] == true ||
                      simpleListRender == true) {
                    sliverList = SliverList(
                      delegate: SliverChildBuilderDelegate(
                        childCount: transactionList.length + 1,
                        (BuildContext context, int index) {
                          int realIndex = index - 1;
                          if (realIndex == -1) {
                            if (sticky)
                              return SizedBox.shrink();
                            else
                              return DateDivider(
                                useHorizontalPaddingConstrained:
                                    useHorizontalPaddingConstrained,
                                color: dateDividerColor,
                                date: date,
                                info: transactionList.length > 1
                                    ? convertToMoney(
                                        Provider.of<AllWallets>(context),
                                        totalSpentForDay)
                                    : "",
                              );
                          }
                          return TransactionEntry(
                            categoryTintColor: categoryTintColor,
                            useHorizontalPaddingConstrained:
                                useHorizontalPaddingConstrained,
                            containerColor: transactionBackgroundColor,
                            key: ValueKey(transactionList[realIndex]
                                .transaction
                                .transactionPk),
                            category: transactionList[realIndex].category,
                            openPage: AddTransactionPage(
                              title: "Edit Transaction",
                              transaction:
                                  transactionList[realIndex].transaction,
                            ),
                            transaction: transactionList[realIndex].transaction,
                            onSelected:
                                (Transaction transaction, bool selected) {
                              if (onSelected != null)
                                onSelected(transaction, selected);
                            },
                            listID: listID,
                          );
                        },
                      ),
                    );
                  } else {
                    sliverList =
                        SliverImplicitlyAnimatedList<TransactionWithCategory>(
                      items: transactionList,
                      areItemsTheSame: (a, b) =>
                          a.transaction.transactionPk ==
                          b.transaction.transactionPk,
                      insertDuration: Duration(milliseconds: 500),
                      removeDuration: Duration(milliseconds: 500),
                      updateDuration: Duration(milliseconds: 500),
                      itemBuilder: (BuildContext context,
                          Animation<double> animation,
                          TransactionWithCategory item,
                          int index) {
                        return SizeFadeTransition(
                          sizeFraction: 0.7,
                          curve: Curves.easeInOut,
                          animation: animation,
                          child: TransactionEntry(
                            categoryTintColor: categoryTintColor,
                            useHorizontalPaddingConstrained:
                                useHorizontalPaddingConstrained,
                            containerColor: transactionBackgroundColor,
                            key: ValueKey(item.transaction.transactionPk),
                            category: item.category,
                            openPage: AddTransactionPage(
                              title: "Edit Transaction",
                              transaction: item.transaction,
                            ),
                            transaction: item.transaction,
                            onSelected:
                                (Transaction transaction, bool selected) {
                              if (onSelected != null)
                                onSelected(transaction, selected);
                            },
                            listID: listID,
                          ),
                        );
                      },
                    );
                  }
                  if (sticky) {
                    return SliverStickyHeader(
                      header: appStateSettings["batterySaver"] == true ||
                              simpleListRender == true
                          ? transactionList.length > 0
                              ? DateDivider(
                                  useHorizontalPaddingConstrained:
                                      useHorizontalPaddingConstrained,
                                  color: dateDividerColor,
                                  key: ValueKey(date),
                                  date: date,
                                  info: transactionList.length > 1
                                      ? convertToMoney(
                                          Provider.of<AllWallets>(context),
                                          totalSpentForDay)
                                      : "")
                              : SizedBox.shrink()
                          : AnimatedSize(
                              duration: Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                              child: transactionList.length > 0
                                  ? AnimatedSwitcher(
                                      duration: Duration(milliseconds: 300),
                                      child: DateDivider(
                                          useHorizontalPaddingConstrained:
                                              useHorizontalPaddingConstrained,
                                          color: dateDividerColor,
                                          key: ValueKey(date),
                                          date: date,
                                          info: transactionList.length > 1
                                              ? convertToMoney(
                                                  Provider.of<AllWallets>(
                                                      context),
                                                  totalSpentForDay)
                                              : ""),
                                    )
                                  : Container(
                                      key: ValueKey(2),
                                    ),
                            ),
                      sticky: true,
                      sliver: sliverList,
                    );
                  } else {
                    return sliverList;
                  }
                }
                if (slivers == false) {
                  return GhostTransactions(
                    i: random.nextInt(100),
                    useHorizontalPaddingConstrained: true,
                  );
                }
                return SliverToBoxAdapter(
                  child: GhostTransactions(
                    i: random.nextInt(100),
                    useHorizontalPaddingConstrained: true,
                  ),
                );
              },
            ),
          );
        }
        if (slivers) {
          return MultiSliver(
            children: transactionsWidgets,
          );
        } else {
          return Column(
            children: transactionsWidgets,
          );
        }
      }
      if (slivers) {
        return SliverToBoxAdapter(child: SizedBox.shrink());
      } else {
        return SizedBox.shrink();
      }
    },
  );
}

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
                              Widget transactionWidgets =
                                  getTransactionsSlivers(
                                startDate,
                                new DateTime(startDate.year,
                                    startDate.month + 1, startDate.day - 1),
                                onSelected: onSelected,
                                listID: "Transactions",
                              );

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
                                      transactionWidgets,
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
                      getWidthNavigationSidebar(context) <= 0
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
                      getWidthNavigationSidebar(context) <= 0
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
