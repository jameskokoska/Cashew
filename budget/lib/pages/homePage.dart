import 'package:budget/struct/budget.dart';
import 'package:budget/widgets/budgetContainer.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:flutter/material.dart';
import "../struct/budget.dart";

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
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFont(text: "test"),
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
            TransactionEntry(openPage: OpenTestPage()),
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
    );
  }
}
