import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/addWalletPage.dart';
import 'package:budget/pages/budgetPage.dart';
import 'package:budget/pages/subscriptionsPage.dart';
import 'package:budget/pages/transactionsListPage.dart';
import 'package:budget/pages/upcomingOverdueTransactionsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/shareBudget.dart';
import 'package:budget/widgets/SelectedTransactionsActionBar.dart';
import 'package:budget/widgets/budgetContainer.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/globalSnackBar.dart';
import 'package:budget/widgets/lineGraph.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/pieChart.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:budget/widgets/walletEntry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:budget/widgets/scrollbarWrap.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  void refreshState() {
    setState(() {});
  }

  void scrollToTop() {
    _scrollController.animateTo(0,
        duration: const Duration(milliseconds: 1200), curve: Curves.elasticOut);
  }

  @override
  bool get wantKeepAlive => true;
  bool showElevation = false;
  late ScrollController _scrollController;
  late AnimationController _animationControllerHeader;
  late AnimationController _animationControllerHeader2;
  int selectedSlidingSelector = 1;

  void initState() {
    super.initState();
    _animationControllerHeader = AnimationController(vsync: this, value: 1);
    _animationControllerHeader2 = AnimationController(vsync: this, value: 1);

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  _scrollListener() {
    double percent = _scrollController.offset / (200);
    if (percent >= 0 && percent <= 1) {
      _animationControllerHeader.value = 1 - _scrollController.offset / (200);
      _animationControllerHeader2.value =
          1 - _scrollController.offset * 2 / (200);
    }
  }

  @override
  void dispose() {
    _animationControllerHeader.dispose();
    _animationControllerHeader2.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool showUsername = appStateSettings["username"] != "" &&
        getWidthNavigationSidebar(context) <= 0;
    return SwipeToSelectTransactions(
      listID: "0",
      child: SharedBudgetRefresh(
        scrollController: _scrollController,
        child: Stack(
          children: [
            Scaffold(
              resizeToAvoidBottomInset: false,
              body: ScrollbarWrap(
                child: ListView(
                  controller: _scrollController,
                  children: [
                    // Wipe all remaining pixels off - sometimes graphics artifacts are left behind
                    Container(
                        height: 1,
                        color: Theme.of(context).colorScheme.background),
                    Container(
                      // Subtract one (1) here because of the thickness of the wiper above
                      height: 179 - 1 + MediaQuery.of(context).padding.top,
                      alignment: Alignment.bottomLeft,
                      padding: EdgeInsets.only(left: 18, bottom: 22, right: 18),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              !showUsername
                                  ? SizedBox()
                                  : AnimatedBuilder(
                                      animation: _animationControllerHeader,
                                      builder: (_, child) {
                                        return Transform.translate(
                                          offset: Offset(
                                              0,
                                              20 -
                                                  20 *
                                                      (_animationControllerHeader
                                                          .value)),
                                          child: child,
                                        );
                                      },
                                      child: FadeTransition(
                                        opacity: _animationControllerHeader2,
                                        child: TextFont(
                                          text: getWelcomeMessage(),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                              AnimatedBuilder(
                                animation: _animationControllerHeader,
                                builder: (_, child) {
                                  return Transform.scale(
                                    alignment: Alignment.bottomLeft,
                                    scale: _animationControllerHeader.value <
                                            0.5
                                        ? 0.25 + 0.5
                                        : (_animationControllerHeader.value) *
                                                0.5 +
                                            0.5,
                                    child: child,
                                  );
                                },
                                child: TextFont(
                                  text: !showUsername
                                      ? "Home"
                                      : appStateSettings["username"],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 39,
                                  textColor: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                          // Profile icon
                          // AnimatedBuilder(
                          //   animation: _animationControllerHeader,
                          //   builder: (_, child) {
                          //     return Transform.scale(
                          //       alignment: Alignment.bottomRight,
                          //       scale: _animationControllerHeader.value < 0.5
                          //           ? 0.25 + 0.5
                          //           : (_animationControllerHeader.value) * 0.5 +
                          //               0.5,
                          //       child: child,
                          //     );
                          //   },
                          //   child: Container(
                          //     width: 50,
                          //     height: 50,
                          //     color: Colors.red,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    appStateSettings["showWalletSwitcher"] == true
                        ? KeepAlive(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 13.0),
                              child: Container(
                                height: 85.0,
                                child: StreamBuilder<List<TransactionWallet>>(
                                  stream: database.watchAllWallets(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return ListView(
                                        addAutomaticKeepAlives: true,
                                        clipBehavior: Clip.none,
                                        scrollDirection: Axis.horizontal,
                                        padding:
                                            EdgeInsets.symmetric(horizontal: 7),
                                        children: [
                                          for (TransactionWallet wallet
                                              in snapshot.data!)
                                            WalletEntry(
                                              selected: appStateSettings[
                                                      "selectedWallet"] ==
                                                  wallet.walletPk,
                                              wallet: wallet,
                                            ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 6, right: 6 + 8),
                                            child: AddButton(
                                              onTap: () {},
                                              height: null,
                                              width: 110,
                                              openPage: AddWalletPage(
                                                title: "Add Wallet",
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                    return Container();
                                  },
                                ),
                              ),
                            ),
                          )
                        : SizedBox.shrink(),
                    KeepAlive(
                      child: StreamBuilder<List<Budget>>(
                        stream: database.watchAllPinnedBudgets(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data!.length == 0) {
                              return SizedBox.shrink();
                            }
                            // if (snapshot.data!.length == 1) {
                            //   return Padding(
                            //     padding: const EdgeInsets.only(
                            //         left: 13, right: 13, bottom: 13),
                            //     child: BudgetContainer(
                            //       budget: snapshot.data![0],
                            //     ),
                            //   );
                            // }
                            List<Widget> budgetItems = [
                              ...(snapshot.data?.map((Budget budget) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 3),
                                      child: BudgetContainer(
                                        budget: budget,
                                      ),
                                    );
                                  }).toList() ??
                                  []),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 3, right: 3),
                                child: AddButton(
                                  onTap: () {},
                                  height: null,
                                  width: null,
                                  padding: EdgeInsets.all(5),
                                  openPage: AddBudgetPage(title: "Add Budget"),
                                ),
                              ),
                            ];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 13),
                              child: getIsFullScreen(context)
                                  ? SizedBox(
                                      height: 183,
                                      child: ListView(
                                        addAutomaticKeepAlives: true,
                                        clipBehavior: Clip.none,
                                        scrollDirection: Axis.horizontal,
                                        children: [
                                          for (Widget widget in budgetItems)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 7),
                                              child: SizedBox(
                                                width: 500,
                                                child: widget,
                                              ),
                                            )
                                        ],
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                        ),
                                      ),
                                    )
                                  : CarouselSlider(
                                      options: CarouselOptions(
                                        height: 183,
                                        enableInfiniteScroll: false,
                                        enlargeCenterPage: true,
                                        enlargeStrategy:
                                            CenterPageEnlargeStrategy.height,
                                        viewportFraction: 0.95,
                                        clipBehavior: Clip.none,
                                        // onPageChanged: (index, reason) {
                                        //   if (index == snapshot.data!.length) {
                                        //     pushRoute(context,
                                        //         AddBudgetPage(title: "Add Budget"));
                                        //   }
                                        // },
                                        enlargeFactor: 0.3,
                                      ),
                                      items: budgetItems,
                                    ),
                            );
                          } else {
                            return SizedBox.shrink();
                          }
                        },
                      ),
                    ),

                    !appStateSettings["showOverdueUpcoming"]
                        ? SizedBox.shrink()
                        : KeepAlive(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 13, left: 13, right: 13),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(child: UpcomingTransactions()),
                                  SizedBox(width: 13),
                                  Expanded(
                                    child: UpcomingTransactions(
                                      overdueTransactions: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    KeepAlive(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 13),
                        child: Container(
                          padding: EdgeInsets.only(
                              left: 10, right: 10, bottom: 10, top: 20),
                          margin: EdgeInsets.symmetric(horizontal: 13),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            color: Theme.of(context)
                                .colorScheme
                                .lightDarkAccentHeavyLight,
                            boxShadow:
                                boxShadowCheck(boxShadowGeneral(context)),
                          ),
                          child: appStateSettings[
                                      "lineGraphReferenceBudgetPk"] ==
                                  null
                              ? StreamBuilder<List<Transaction>>(
                                  stream: database
                                      .getTransactionsInTimeRangeFromCategories(
                                          DateTime(
                                            DateTime.now().year,
                                            DateTime.now().month - 1,
                                            DateTime.now().day,
                                          ),
                                          DateTime(
                                            DateTime.now().year,
                                            DateTime.now().month,
                                            DateTime.now().day,
                                          ),
                                          [],
                                          true,
                                          true,
                                          selectedSlidingSelector == 2
                                              ? false
                                              : selectedSlidingSelector == 3
                                                  ? true
                                                  : null,
                                          SharedTransactionsShow.fromEveryone),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      bool cumulative = appStateSettings[
                                          "showCumulativeSpending"];
                                      double cumulativeTotal = 0;
                                      List<Pair> points = [];
                                      for (DateTime indexDay = DateTime(
                                        DateTime.now().year,
                                        DateTime.now().month - 1,
                                        DateTime.now().day,
                                      );
                                          indexDay.compareTo(DateTime.now()) <
                                              0;
                                          indexDay = DateTime(
                                              indexDay.year,
                                              indexDay.month,
                                              indexDay.day + 1)) {
                                        //can be optimized...
                                        double totalForDay = 0;
                                        for (Transaction transaction
                                            in snapshot.data!) {
                                          if (indexDay.year ==
                                                  transaction
                                                      .dateCreated.year &&
                                              indexDay.month ==
                                                  transaction
                                                      .dateCreated.month &&
                                              indexDay.day ==
                                                  transaction.dateCreated.day) {
                                            if (transaction.income) {
                                              totalForDay += transaction.amount
                                                      .abs() *
                                                  (amountRatioToPrimaryCurrencyGivenPk(
                                                          transaction
                                                              .walletFk) ??
                                                      0);
                                            } else {
                                              totalForDay -= transaction.amount
                                                      .abs() *
                                                  (amountRatioToPrimaryCurrencyGivenPk(
                                                          transaction
                                                              .walletFk) ??
                                                      0);
                                            }
                                          }
                                        }
                                        cumulativeTotal += totalForDay;
                                        points.add(Pair(
                                            points.length.toDouble(),
                                            cumulative
                                                ? cumulativeTotal
                                                : totalForDay));
                                      }
                                      return LineChartWrapper(
                                          points: [points], isCurved: true);
                                    }
                                    return SizedBox.shrink();
                                  },
                                )
                              : StreamBuilder<Budget>(
                                  stream: database.getBudget(appStateSettings[
                                      "lineGraphReferenceBudgetPk"]),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      Budget budget = snapshot.data!;
                                      ColorScheme budgetColorScheme =
                                          ColorScheme.fromSeed(
                                        seedColor: HexColor(budget.colour,
                                            defaultColor: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                        brightness:
                                            determineBrightnessTheme(context),
                                      );
                                      return Column(
                                        children: [
                                          BudgetLineGraph(
                                            key: ValueKey(budget.budgetPk),
                                            budget: budget,
                                            budgetColorScheme:
                                                budgetColorScheme,
                                            dateForRange: DateTime.now(),
                                            budgetRange: getBudgetDate(
                                                budget, DateTime.now()),
                                            isPastBudget: false,
                                            selectedCategory: null,
                                            selectedCategoryPk: -1,
                                            showPastSpending: false,
                                          ),
                                        ],
                                      );
                                    }
                                    return SizedBox.shrink();
                                  },
                                ),
                        ),
                      ),
                    ),
                    KeepAlive(
                      child: SlidingSelector(onSelected: (index) {
                        setState(() {
                          selectedSlidingSelector = index;
                        });
                      }),
                    ),
                    KeepAlive(
                      child: Container(height: 8),
                    ),
                    KeepAlive(
                      child: AnimatedSize(
                        duration: Duration(milliseconds: 600),
                        curve: Curves.easeInOutCubicEmphasized,
                        child: AnimatedSwitcher(
                          duration: Duration(milliseconds: 300),
                          child: StreamBuilder<List<Transaction>>(
                            stream: database.watchAllUpcomingTransactions(
                                // upcoming in 3 days
                                endDate: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day + 4)),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                if (snapshot.data!.length <= 0) {
                                  return SizedBox.shrink();
                                }
                                List<Widget> children = [];
                                for (Transaction transaction
                                    in snapshot.data!) {
                                  children.add(Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      UpcomingTransactionDateHeader(
                                          transaction: transaction,
                                          small: true),
                                      TransactionEntry(
                                        openPage: AddTransactionPage(
                                          title: "Edit Transaction",
                                          transaction: transaction,
                                        ),
                                        transaction: transaction,
                                      ),
                                      SizedBox(height: 5),
                                    ],
                                  ));
                                }
                                return Column(children: children);
                              } else {
                                return SizedBox.shrink();
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    AnimatedSize(
                      duration: Duration(milliseconds: 600),
                      curve: Curves.easeInOutCubicEmphasized,
                      child: AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        child: SizedBox(
                          key: ValueKey(selectedSlidingSelector),
                          child: getTransactionsSlivers(
                            DateTime(
                              DateTime.now().year,
                              DateTime.now().month,
                              DateTime.now().day - 7,
                            ),
                            DateTime(
                              DateTime.now().year,
                              DateTime.now().month,
                              DateTime.now().day,
                            ),
                            income: selectedSlidingSelector == 1
                                ? null
                                : selectedSlidingSelector == 2
                                    ? false
                                    : true,
                            sticky: false,
                            slivers: false,
                            dateDividerColor: Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                    Container(height: 7),
                    Center(
                      child: Tappable(
                        color: Theme.of(context).colorScheme.lightDarkAccent,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 8),
                          child: TextFont(
                            text: "View All Transactions",
                            textAlign: TextAlign.center,
                            fontSize: 16,
                            textColor: Theme.of(context).colorScheme.textLight,
                          ),
                        ),
                        onTap: () {
                          PageNavigationFramework.changePage(context, 1,
                              switchNavbar: true);
                        },
                        borderRadius: 10,
                      ),
                    ),
                    SizedBox(height: 65),
                    // Wipe all remaining pixels off - sometimes graphics artifacts are left behind
                    Container(
                        height: 1,
                        color: Theme.of(context).colorScheme.background),
                  ],
                ),
              ),
            ),
            SelectedTransactionsActionBar(
              pageID: "0",
            ),
          ],
        ),
      ),
    );
  }
}

class SlidingSelector extends StatelessWidget {
  const SlidingSelector({
    Key? key,
    required this.onSelected,
    this.alternateTheme = false,
  }) : super(key: key);

  final Function(int) onSelected;
  final bool alternateTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(boxShadow: boxShadowCheck(boxShadowGeneral(context))),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: getHorizontalPaddingConstrained(context)),
        child: Padding(
          padding: alternateTheme
              ? const EdgeInsets.symmetric(horizontal: 20)
              : const EdgeInsets.symmetric(horizontal: 13),
          child: DefaultTabController(
            length: 3,
            child: SizedBox(
              height: alternateTheme ? 40 : 45,
              child: Material(
                borderRadius: BorderRadius.circular(15),
                color: Theme.of(context).colorScheme.lightDarkAccentHeavyLight,
                child: Theme(
                  data: ThemeData().copyWith(
                    splashColor: Theme.of(context).splashColor,
                  ),
                  child: TabBar(
                    splashFactory: Theme.of(context).splashFactory,
                    splashBorderRadius: BorderRadius.circular(15),
                    onTap: (value) {
                      onSelected(value + 1);
                    },
                    dividerColor: Colors.transparent,
                    indicatorColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      color: appStateSettings["materialYou"]
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.3)
                          : Theme.of(context)
                              .colorScheme
                              .black
                              .withOpacity(0.15),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    labelColor: Theme.of(context).colorScheme.black,
                    unselectedLabelColor:
                        Theme.of(context).colorScheme.textLight,
                    tabs: [
                      Tab(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Text(
                            'All',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Avenir',
                            ),
                          ),
                        ),
                      ),
                      Tab(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Text(
                            'Expense',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Avenir',
                            ),
                          ),
                        ),
                      ),
                      Tab(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Text(
                            'Income',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Avenir',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class UpcomingTransactions extends StatelessWidget {
  const UpcomingTransactions({
    Key? key,
    bool this.overdueTransactions = false,
  }) : super(key: key);
  final overdueTransactions;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(boxShadow: boxShadowCheck(boxShadowGeneral(context))),
      child: OpenContainerNavigation(
        closedColor: Theme.of(context).colorScheme.lightDarkAccentHeavyLight,
        openPage: UpcomingOverdueTransactions(
            overdueTransactions: overdueTransactions),
        borderRadius: 15,
        button: (openContainer) {
          return Tappable(
            color: Theme.of(context).colorScheme.lightDarkAccentHeavyLight,
            onTap: () {
              openContainer();
            },
            child: Container(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 17),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFont(
                      text: overdueTransactions ? "Overdue" : "Upcoming",
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(height: 6),
                    WatchAllWallets(
                      childFunction: (wallets) => StreamBuilder<double?>(
                        stream: database.watchTotalOfUpcomingOverdue(
                            overdueTransactions, wallets),
                        builder: (context, snapshot) {
                          return CountNumber(
                            count: snapshot.hasData == false ||
                                    snapshot.data == null
                                ? 0
                                : (snapshot.data ?? 0).abs(),
                            duration: Duration(milliseconds: 2500),
                            dynamicDecimals: true,
                            initialCount: (0),
                            textBuilder: (number) {
                              return TextFont(
                                text: convertToMoney(number,
                                    finalNumber: snapshot.hasData == false ||
                                            snapshot.data == null
                                        ? 0
                                        : (snapshot.data ?? 0).abs()),
                                fontSize: 24,
                                textColor: overdueTransactions
                                    ? Theme.of(context).colorScheme.unPaidRed
                                    : Theme.of(context)
                                        .colorScheme
                                        .unPaidYellow,
                                fontWeight: FontWeight.bold,
                              );
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 5),
                    StreamBuilder<List<int?>>(
                      stream: overdueTransactions
                          ? database.watchCountOfOverdue()
                          : database.watchCountOfUpcoming(),
                      builder: (context, snapshot) {
                        return TextFont(
                          text: snapshot.hasData == false ||
                                  snapshot.data![0] == null
                              ? "/"
                              : snapshot.data![0].toString() +
                                  pluralString(
                                      snapshot.data![0] == 1, " transaction"),
                          fontSize: 13,
                          textColor: Theme.of(context).colorScheme.textLight,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class KeepAlive extends StatefulWidget {
  const KeepAlive({super.key, required this.child});

  final Widget child;

  @override
  State<KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<KeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
