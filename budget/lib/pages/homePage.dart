import 'package:budget/struct/budget.dart';
import 'package:budget/struct/transaction.dart';
import 'package:budget/widgets/budgetContainer.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/pieChart.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:flutter/material.dart';
import "../struct/budget.dart";
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Container(height: 100),
                Container(
                    width: 200,
                    height: 200,
                    child: Stack(
                      children: [
                        PieChartSample3(),
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
          SliverStickyHeader(
            header: TextHeader(
              text: "Home",
            ),
            sliver: SliverPadding(
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
          ),

          SliverStickyHeader(
            header: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextHeader(
                  text: "Transactions",
                ),
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
                        tagIDs: ["id1", "id2"],
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
          // SliverPadding(
          //   padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          //   sliver: SliverGrid(
          //     gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          //       maxCrossAxisExtent: 650,
          //       mainAxisExtent: 95,
          //       mainAxisSpacing: 15,
          //       crossAxisSpacing: 15,
          //     ),
          //     delegate: SliverChildBuilderDelegate(
          //       (BuildContext context, int index) {
          //         return TransactionEntry(
          //           openPage: OpenTestPage(),
          //           transaction: Transaction(
          //             title: "Uber",
          //             amount: 50,
          //             categoryID: "id",
          //             date: DateTime.now(),
          //             note: "this is a transaction",
          //             tagIDs: ["id1", "id2"],
          //           ),
          //         );
          //       },
          //       childCount: 20,
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }
}
