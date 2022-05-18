import 'package:budget/database/tables.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/transactionsListPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/budgetContainer.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/lineGraph.dart';
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
          SliverToBoxAdapter(
            child: Container(
              height: 236,
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
                            offset: Offset(0,
                                20 - 20 * (_animationControllerHeader.value)),
                            child: child,
                          );
                        },
                        child: FadeTransition(
                          opacity: _animationControllerHeader2,
                          child: TextFont(
                            text: "Hello",
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
                          text: "James",
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
                            : (_animationControllerHeader.value) * 0.5 + 0.5,
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
          ),
          appStateSettings["showWalletSwitcher"] == true
              ? SliverPadding(
                  padding: EdgeInsets.only(top: 0, bottom: 25),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                        height: 85.0,
                        child: StreamBuilder<List<TransactionWallet>>(
                            stream: database.watchAllWallets(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: snapshot.data!.length + 1,
                                  itemBuilder: (context, index) {
                                    bool lastIndex =
                                        index == snapshot.data!.length;
                                    if (lastIndex) {
                                      return WalletEntryAdd();
                                    }
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        left: (index == 0 ? 8 : 0.0),
                                      ),
                                      child: WalletEntry(
                                        selected: appStateSettings[
                                                "selectedWallet"] ==
                                            snapshot.data![index].walletPk,
                                        wallet: snapshot.data![index],
                                      ),
                                    );
                                  },
                                );
                              }
                              return Container();
                            })),
                  ),
                )
              : SliverToBoxAdapter(),
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
                  child: LineChartWrapper(points: points, isCurved: false),
                );
              }
              return SliverToBoxAdapter(child: SizedBox());
            },
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  EdgeInsets.only(left: 18, bottom: 22, right: 18, top: 10),
              child: TextFont(
                text: "Budgets",
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          StreamBuilder<List<Budget>>(
            stream: database.watchAllPinnedBudgets(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return SliverPadding(
                  padding: EdgeInsets.symmetric(vertical: 0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 18.0),
                          child: BudgetContainer(
                            budget: snapshot.data![index],
                          ),
                        );
                      },
                      childCount: snapshot.data?.length, //snapshot.data?.length
                    ),
                  ),
                );
              } else {
                return SliverToBoxAdapter(child: SizedBox());
              }
            },
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  EdgeInsets.only(left: 18, bottom: 10, right: 18, top: 10),
              child: TextFont(
                text: "Transactions",
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
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
