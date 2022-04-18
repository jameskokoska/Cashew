import 'package:budget/database/tables.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/transactionsListPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/budgetContainer.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/lineGraph.dart';
import 'package:budget/widgets/pieChart.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:budget/widgets/walletEntry.dart';
import 'package:flutter/material.dart';
import "../struct/budget.dart";
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:budget/colors.dart';

class HomePage extends StatefulWidget {
  HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  void refreshState() {
    setState(() {});
  }

  @override
  bool get wantKeepAlive => true;

  GlobalKey<_HomeAppBarState> _appBarKey = GlobalKey();
  double setTitleHeight = 0;

  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 48),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            leading: Container(),
            backgroundColor: Theme.of(context).colorScheme.accentColor,
            floating: false,
            pinned: true,
            expandedHeight: 200.0,
            collapsedHeight: 65,
            shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(25),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.symmetric(vertical: 15, horizontal: 18),
              title: HomeAppBar(
                key: _appBarKey,
                defaultTitle: "Hello James",
                scrollController: _scrollController,
                firstTitle: "Overview",
              ),
              background: Container(
                color: Theme.of(context).canvasColor,
              ),
            ),
          ),
          SliverPadding(
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
                      })),
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
            ),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                bool cumulative = true;
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
          SliverAppBar(
            leading: Container(),
            backgroundColor: Colors.transparent,
            expandedHeight: 65.1,
            collapsedHeight: 65,
            flexibleSpace: LayoutBuilder(builder: (
              BuildContext context,
              BoxConstraints constraints,
            ) {
              if (setTitleHeight == 0)
                setTitleHeight = constraints.biggest.height;
              print(setTitleHeight);
              if (constraints.biggest.height < setTitleHeight) {
                //occur when title disappears (scrolling down)
                //add delay to wait for layout of children widgets first
                Future.delayed(Duration.zero, () async {
                  _appBarKey.currentState?.changeTitle("Budgets", 1);
                });
              } else {
                //occur when title appears (scrolling up)
                Future.delayed(Duration.zero, () async {
                  _appBarKey.currentState?.changeTitle("Summary", -1);
                });
              }
              return FlexibleSpaceBar(
                titlePadding:
                    EdgeInsets.symmetric(vertical: 15, horizontal: 18),
                title: TextFont(
                  text: "Budgets",
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              );
            }),
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
          SliverAppBar(
            leading: Container(),
            backgroundColor: Colors.transparent,
            expandedHeight: 65.1,
            collapsedHeight: 65,
            flexibleSpace: LayoutBuilder(builder: (
              BuildContext context,
              BoxConstraints constraints,
            ) {
              if (setTitleHeight == 0)
                setTitleHeight = constraints.biggest.height;
              print(setTitleHeight);
              if (constraints.biggest.height < setTitleHeight) {
                //occur when title disappears (scrolling down)
                //add delay to wait for layout of children widgets first
                Future.delayed(Duration.zero, () async {
                  _appBarKey.currentState?.changeTitle("Transactions", 1);
                });
              } else {
                //occur when title appears (scrolling up)
                Future.delayed(Duration.zero, () async {
                  _appBarKey.currentState?.changeTitle("Budgets", -1);
                });
              }
              return FlexibleSpaceBar(
                titlePadding: EdgeInsets.only(bottom: 8, left: 18, right: 18),
                title: TextFont(
                  text: "Transactions",
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              );
            }),
          ),
          ...getTransactionsSlivers(
              DateTime(DateTime.now().year, DateTime.now().month - 1,
                  DateTime.now().day),
              DateTime.now()),
          SliverToBoxAdapter(child: Container(height: 15)),
        ],
      ),
    );
  }
}

class HomeAppBar extends StatefulWidget {
  HomeAppBar(
      {Key? key,
      required this.defaultTitle,
      required this.firstTitle,
      required this.scrollController})
      : super(key: key);
  final String defaultTitle;
  final String firstTitle;
  final ScrollController scrollController;

  @override
  _HomeAppBarState createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> with TickerProviderStateMixin {
  late String title = "";
  late int direction = -1;
  bool switchDefaultTitle = false;
  int skipFirstChangeRequests = 0;

  @override
  void initState() {
    widget.scrollController.addListener(_scrollListener);
  }

  void changeTitle(newTitle, newDirection) {
    if (skipFirstChangeRequests < 2) {
      skipFirstChangeRequests = skipFirstChangeRequests + 1;
      Future.delayed(Duration(milliseconds: 0), () async {
        changeTitle(widget.defaultTitle, -1);
      });
      return;
    }
    setState(() {
      title = newTitle;
      direction = newDirection;
    });
  }

  _scrollListener() {
    double percent = widget.scrollController.offset / (200 - 65);
    if (percent >= 0 && percent <= 1 && switchDefaultTitle == false) {
      setState(() {
        switchDefaultTitle = true;
      });
      changeTitle(widget.defaultTitle, -1);
    } else if (percent >= 1 && switchDefaultTitle) {
      setState(() {
        switchDefaultTitle = false;
      });
      changeTitle(widget.firstTitle, 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 500),
      switchInCurve: Curves.easeInOutCubic,
      switchOutCurve: Curves.easeInOutCubic,
      transitionBuilder: (Widget child, Animation<double> animation) {
        final inAnimation = Tween<Offset>(
                begin: Offset(0.0, direction == -1 ? -1 : 1),
                end: Offset(0.0, 0.0))
            .animate(animation);
        final outAnimation = Tween<Offset>(
                begin: Offset(0.0, direction == -1 ? 1 : -1),
                end: Offset(0.0, 0.0))
            .animate(animation);

        return ClipRect(
          child: SlideTransition(
            position: child.key == ValueKey(title) ? inAnimation : outAnimation,
            child: child,
          ),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        key: ValueKey(title),
        child: TextFont(
          text: title,
          fontSize: 26,
          fontWeight: FontWeight.bold,
          textAlign: TextAlign.left,
        ),
      ),
    );
  }
}
