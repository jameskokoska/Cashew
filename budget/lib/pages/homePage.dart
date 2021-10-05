import 'package:budget/struct/budget.dart';
import 'package:budget/struct/transaction.dart';
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

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey<_HomeAppBarState> _appBarKey = GlobalKey();
  double setTitleHeight = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
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
                )),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Container(height: 100),
                Button(
                  label: "button",
                  width: 120,
                  height: 40,
                  onTap: () {},
                ),
                Container(height: 100),
                CountUp(
                  count: 1,
                  duration: Duration(seconds: 100),
                ),
                Container(
                    width: 200,
                    height: 200,
                    child: Stack(
                      children: [
                        PieChartDisplay(
                          data: [50, 10, 40],
                        ),
                        IgnorePointer(
                          child: Center(
                            child: Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                  color: Colors.black, shape: BoxShape.circle),
                            ),
                          ),
                        ),
                        IgnorePointer(
                          child: Center(
                            child: Container(
                              width: 115,
                              height: 115,
                              decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.2),
                                  shape: BoxShape.circle),
                            ),
                          ),
                        ),
                      ],
                    )),
                Container(height: 100),
                TextInput(labelText: "labelText"),
              ],
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(vertical: 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  BudgetContainer(
                    budget: Budget(
                      title: "Budget Name",
                      color: Color(0x4F6ECA4A),
                      total: 500,
                      spent: 210,
                      endDate: DateTime.now(),
                      startDate: DateTime.now(),
                      period: "month",
                      periodLength: 10,
                    ),
                  ),
                ],
              ),
            ),
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
          SliverStickyHeader(
            header: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DateDivider(date: DateTime.now()),
              ],
            ),
            sliver: SliverPadding(
              padding: EdgeInsets.symmetric(vertical: 10),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return TransactionEntry(
                      openPage: OpenTestPage(),
                      transaction: Transaction(
                        title: "Uber",
                        amount: 50,
                        categoryID: "id",
                        date: DateTime.now(),
                        note: "this is a transaction",
                        tagIDs: ["id1"],
                      ),
                    );
                  },
                  childCount: 40,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                TransactionEntry(
                  openPage: OpenTestPage(),
                  transaction: Transaction(
                    title: "",
                    amount: 50,
                    categoryID: "id",
                    date: DateTime.now(),
                    note: "this is a transaction",
                    tagIDs: ["id1", "id2"],
                  ),
                ),
                TransactionEntry(
                  openPage: OpenTestPage(),
                  transaction: Transaction(
                    title: "Uber",
                    amount: 50,
                    categoryID: "id",
                    date: DateTime.now(),
                    note: "this is a transaction",
                    tagIDs: ["id1", "id2"],
                  ),
                ),
              ],
            ),
          ),
        ],
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
