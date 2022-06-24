import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/transactionsListPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/budgetContainer.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/lineGraph.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/pieChart.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:budget/widgets/walletEntry.dart';
import 'package:flutter/material.dart';
import "../struct/budget.dart";
import 'package:budget/colors.dart';
import 'package:carousel_slider/carousel_slider.dart';

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

  @override
  bool get wantKeepAlive => true;
  bool showElevation = false;
  late ScrollController _scrollController;
  late AnimationController _animationControllerHeader;
  late AnimationController _animationControllerHeader2;

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
    super.dispose();
    _animationControllerHeader.dispose();
    _animationControllerHeader2.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Container(
                  height: 207 + MediaQuery.of(context).padding.top,
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
                          AnimatedBuilder(
                            animation: _animationControllerHeader,
                            builder: (_, child) {
                              return Transform.translate(
                                offset: Offset(
                                    0,
                                    20 -
                                        20 *
                                            (_animationControllerHeader.value)),
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
                                scale: _animationControllerHeader.value < 0.5
                                    ? 0.25 + 0.5
                                    : (_animationControllerHeader.value) * 0.5 +
                                        0.5,
                                child: child,
                              );
                            },
                            child: TextFont(
                              text: appStateSettings["username"],
                              fontWeight: FontWeight.bold,
                              fontSize: 39,
                            ),
                          ),
                        ],
                      ),
                      AnimatedBuilder(
                        animation: _animationControllerHeader,
                        builder: (_, child) {
                          return Transform.scale(
                            alignment: Alignment.bottomRight,
                            scale: _animationControllerHeader.value < 0.5
                                ? 0.25 + 0.5
                                : (_animationControllerHeader.value) * 0.5 +
                                    0.5,
                            child: child,
                          );
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          appStateSettings["showWalletSwitcher"] == true
              ? SliverToBoxAdapter(
                  child: Container(
                    height: 85.0,
                    child: StreamBuilder<List<TransactionWallet>>(
                      stream: database.watchAllWallets(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return ListView.builder(
                            addAutomaticKeepAlives: true,
                            clipBehavior: Clip.none,
                            scrollDirection: Axis.horizontal,
                            itemCount: snapshot.data!.length + 1,
                            itemBuilder: (context, index) {
                              bool lastIndex = index == snapshot.data!.length;
                              if (lastIndex) {
                                return WalletEntryAdd();
                              }
                              return Padding(
                                padding: EdgeInsets.only(
                                  left: (index == 0 ? 8 : 0.0),
                                ),
                                child: WalletEntry(
                                  selected:
                                      appStateSettings["selectedWallet"] ==
                                          snapshot.data![index].walletPk,
                                  wallet: snapshot.data![index],
                                ),
                              );
                            },
                          );
                        }
                        return Container();
                      },
                    ),
                  ),
                )
              : SliverToBoxAdapter(),
          SliverToBoxAdapter(
            child: Container(height: 15),
          ),
          StreamBuilder<List<Budget>>(
            stream: database.watchAllPinnedBudgets(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.length == 0) {
                  return SliverToBoxAdapter(child: SizedBox());
                }
                if (snapshot.data!.length == 1) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: BudgetContainer(
                        budget: snapshot.data![0],
                      ),
                    ),
                  );
                }
                return SliverToBoxAdapter(
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: 183,
                      enableInfiniteScroll: false,
                      enlargeCenterPage: true,
                      enlargeStrategy: CenterPageEnlargeStrategy.height,
                      viewportFraction: 0.93,
                      clipBehavior: Clip.none,
                    ),
                    items: snapshot.data?.map((Budget budget) {
                      return BudgetContainer(
                        budget: budget,
                      );
                    }).toList(),
                  ),
                );
              } else {
                return SliverToBoxAdapter(child: SizedBox());
              }
            },
          ),
          SliverToBoxAdapter(
            child: Container(height: 15),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 15),
                  Expanded(child: UpcomingTransactions()),
                  SizedBox(width: 10),
                  Expanded(
                      child: UpcomingTransactions(
                    overdueTransactions: true,
                  )),
                  SizedBox(width: 15),
                ],
              ),
            ),
          ),
          StreamBuilder<List<Transaction>>(
            stream: database.getTransactionsInTimeRangeFromCategories(
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
            ),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                bool cumulative = appStateSettings["showCumulativeSpending"];
                double cumulativeTotal = 0;
                List<Pair> points = [];
                for (DateTime indexDay = DateTime(
                  DateTime.now().year,
                  DateTime.now().month - 1,
                  DateTime.now().day,
                );
                    indexDay.compareTo(DateTime.now()) < 0;
                    indexDay = indexDay.add(Duration(days: 1))) {
                  //can be optimized...
                  double totalForDay = 0;
                  snapshot.data!.forEach((transaction) {
                    if (indexDay.year == transaction.dateCreated.year &&
                        indexDay.month == transaction.dateCreated.month &&
                        indexDay.day == transaction.dateCreated.day) {
                      totalForDay += transaction.amount;
                    }
                  });
                  cumulativeTotal += totalForDay;
                  points.add(Pair(points.length.toDouble(),
                      cumulative ? cumulativeTotal : totalForDay));
                }
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Container(
                        padding: EdgeInsets.only(
                            left: 10, right: 10, bottom: 10, top: 20),
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          color: Theme.of(context).colorScheme.lightDarkAccent,
                        ),
                        child:
                            LineChartWrapper(points: points, isCurved: true)),
                  ),
                );
              }
              return SliverToBoxAdapter(child: SizedBox());
            },
          ),
          ...getTransactionsSlivers(
              DateTime(DateTime.now().year, DateTime.now().month - 1,
                  DateTime.now().day),
              DateTime.now()),
          SliverToBoxAdapter(child: Container(height: 105)),
        ],
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
    return OpenContainerNavigation(
      closedColor: Theme.of(context).colorScheme.lightDarkAccent,
      openPage: PageFramework(
        subtitle: Padding(
          padding: const EdgeInsets.only(left: 20, bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StreamBuilder<List<double?>>(
                stream: overdueTransactions
                    ? database.watchTotalOfOverdue()
                    : database.watchTotalOfUpcoming(),
                builder: (context, snapshot) {
                  return CountNumber(
                    count:
                        snapshot.hasData == false || snapshot.data![0] == null
                            ? 0
                            : snapshot.data![0] ?? 0,
                    duration: Duration(milliseconds: 2500),
                    dynamicDecimals: true,
                    initialCount: (0),
                    textBuilder: (number) {
                      return TextFont(
                        text: convertToMoney(number),
                        fontSize: 25,
                        textColor: overdueTransactions
                            ? Theme.of(context).colorScheme.unPaidRed
                            : Theme.of(context).colorScheme.unPaidYellow,
                        fontWeight: FontWeight.bold,
                      );
                    },
                  );
                },
              ),
              SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: StreamBuilder<List<int?>>(
                  stream: overdueTransactions
                      ? database.watchCountOfOverdue()
                      : database.watchCountOfUpcoming(),
                  builder: (context, snapshot) {
                    return TextFont(
                      text:
                          snapshot.hasData == false || snapshot.data![0] == null
                              ? "/"
                              : snapshot.data![0].toString() + " transactions",
                      fontSize: 15,
                      textColor: Theme.of(context).colorScheme.textLight,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        subtitleSize: 18,
        title: overdueTransactions ? "Overdue" : "Upcoming",
        dragDownToDismiss: true,
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(height: 10),
          ),
          StreamBuilder<List<Transaction>>(
            stream: overdueTransactions
                ? database.watchAllOverdueTransactions()
                : database.watchAllUpcomingTransactions(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.length <= 0) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding:
                            const EdgeInsets.only(top: 85, right: 15, left: 15),
                        child: TextFont(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            text: "No " +
                                (overdueTransactions ? "overdue" : "upcoming") +
                                " transactions."),
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      Transaction transaction = snapshot.data![index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 20.0, bottom: 6),
                            child: TextFont(
                              text: getWordedDateShortMore(
                                  transaction.dateCreated),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TransactionEntry(
                            openPage: AddTransactionPage(
                              title: "Edit Transaction",
                              transaction: transaction,
                            ),
                            transaction: transaction,
                          ),
                          SizedBox(height: 10),
                        ],
                      );
                    },
                    childCount: snapshot.data?.length,
                  ),
                );
              } else {
                return SliverToBoxAdapter(child: SizedBox());
              }
            },
          ),
        ],
      ),
      borderRadius: 15,
      button: (openContainer) {
        return Tappable(
          color: Theme.of(context).colorScheme.lightDarkAccent,
          onTap: () {
            openContainer();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 17),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFont(
                  text: overdueTransactions ? "Overdue" : "Upcoming",
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: 6),
                StreamBuilder<List<double?>>(
                  stream: overdueTransactions
                      ? database.watchTotalOfOverdue()
                      : database.watchTotalOfUpcoming(),
                  builder: (context, snapshot) {
                    return CountNumber(
                      count:
                          snapshot.hasData == false || snapshot.data![0] == null
                              ? 0
                              : snapshot.data![0] ?? 0,
                      duration: Duration(milliseconds: 2500),
                      dynamicDecimals: true,
                      initialCount: (0),
                      textBuilder: (number) {
                        return TextFont(
                          text: convertToMoney(number),
                          fontSize: 25,
                          textColor: overdueTransactions
                              ? Theme.of(context).colorScheme.unPaidRed
                              : Theme.of(context).colorScheme.unPaidYellow,
                          fontWeight: FontWeight.bold,
                        );
                      },
                    );
                  },
                ),
                SizedBox(height: 5),
                StreamBuilder<List<int?>>(
                  stream: overdueTransactions
                      ? database.watchCountOfOverdue()
                      : database.watchCountOfUpcoming(),
                  builder: (context, snapshot) {
                    return TextFont(
                      text:
                          snapshot.hasData == false || snapshot.data![0] == null
                              ? "/"
                              : snapshot.data![0].toString() + " transactions",
                      fontSize: 15,
                      textColor: Theme.of(context).colorScheme.textLight,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
