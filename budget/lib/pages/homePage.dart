import 'package:budget/database/tables.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/budgetContainer.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/pieChart.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:flutter/material.dart';
import "../struct/budget.dart";
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:budget/colors.dart';

class HomePage extends StatefulWidget {
  HomePage({
    Key? key,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  GlobalKey<_HomeAppBarState> _appBarKey = GlobalKey();
  double setTitleHeight = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> transactionsWidgets = [];
    List<DateTime> dates = [];
    for (DateTime indexDay = DateTime(2022, 03, 1);
        indexDay.month == 03;
        indexDay = indexDay.add(Duration(days: 1))) {
      dates.add(indexDay);
    }
    for (DateTime date in dates.reversed) {
      transactionsWidgets.add(
        StreamBuilder<List<Transaction>>(
          stream: database.getTransactionWithDay(date),
          builder: (context, snapshot) {
            if (snapshot.hasData && (snapshot.data ?? []).length > 0) {
              return SliverStickyHeader(
                header: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DateDivider(date: date),
                  ],
                ),
                sliver: SliverPadding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return TransactionEntry(
                          openPage: AddTransactionPage(
                            title: "Edit Transaction",
                            transaction: snapshot.data![index],
                          ),
                          transaction: Transaction(
                            transactionPk: snapshot.data![index].transactionPk,
                            name: snapshot.data![index].name,
                            amount: snapshot.data![index].amount,
                            note: snapshot.data![index].note,
                            budgetFk: snapshot.data![index].budgetFk,
                            categoryFk: snapshot.data![index].categoryFk,
                            dateCreated: snapshot.data![index].dateCreated,
                          ),
                        );
                      },
                      childCount: snapshot.data?.length,
                    ),
                  ),
                ),
              );
            }
            return SliverToBoxAdapter(child: SizedBox());
          },
        ),
      );
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(bottom: 48),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              leading: Container(),
              backgroundColor: Theme.of(context).colorScheme.accentColor,
              floating: false,
              pinned: true,
              expandedHeight: 200.0,
              collapsedHeight: 65,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding:
                    EdgeInsets.symmetric(vertical: 15, horizontal: 18),
                title: HomeAppBar(key: _appBarKey, defaultTitle: "Home"),
                background: Container(
                  color: Theme.of(context).canvasColor,
                ),
              ),
            ),
            StreamBuilder<List<Budget>>(
              stream: database.watchAllPinnedBudgets(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return SliverPadding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          return BudgetContainer(
                            budget: snapshot.data![index],
                          );
                        },
                        childCount:
                            snapshot.data?.length, //snapshot.data?.length
                      ),
                    ),
                  );
                } else {
                  return SliverToBoxAdapter(child: SizedBox());
                }
              },
            ),

            // SliverList(
            //   delegate: SliverChildListDelegate(
            //     [
            //       BudgetContainer(
            //         budget: Budget(
            //           title: "Budget Name",
            //           color: Color(0xFF51833D),
            //           total: 500,
            //           spent: 210,
            //           endDate: DateTime.now(),
            //           startDate: DateTime.now(),
            //           period: "month",
            //           periodLength: 10,
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
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
                    _appBarKey.currentState?.changeTitle("Home", -1);
                  });
                }
                return FlexibleSpaceBar(
                  titlePadding:
                      EdgeInsets.symmetric(vertical: 15, horizontal: 18),
                  title: TextFont(
                    text: "Transactions",
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }),
            ),
            ...transactionsWidgets,
          ],
        ),
      ),
    );
  }
}

class HomeAppBar extends StatefulWidget {
  HomeAppBar({Key? key, required this.defaultTitle}) : super(key: key);
  final String defaultTitle;

  @override
  _HomeAppBarState createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  late String title = "";
  late int direction = -1;

  @override
  void initState() {
    title = widget.defaultTitle;
  }

  void changeTitle(newTitle, newDirection) {
    setState(() {
      title = newTitle;
      direction = newDirection;
    });
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
