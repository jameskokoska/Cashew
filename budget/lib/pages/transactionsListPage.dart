import 'dart:developer';

import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/budgetContainer.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/popupFramework.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:budget/main.dart';
import 'package:budget/colors.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

List<Widget> getTransactionsSlivers(DateTime startDay, DateTime endDay,
    {search = "", List<int> categoryFks = const []}) {
  List<Widget> transactionsWidgets = [];
  List<DateTime> dates = [];
  for (DateTime indexDay = startDay;
      indexDay.millisecondsSinceEpoch <= endDay.millisecondsSinceEpoch;
      indexDay = indexDay.add(Duration(days: 1))) {
    dates.add(indexDay);
  }
  for (DateTime date in dates.reversed) {
    transactionsWidgets.add(
      StreamBuilder<List<TransactionWithCategory>>(
        stream: database.getTransactionCategoryWithDay(date,
            search: search, categoryFks: categoryFks),
        builder: (context, snapshot) {
          if (snapshot.hasData && (snapshot.data ?? []).length > 0) {
            double totalSpentForDay = 0;
            snapshot.data!.forEach((transaction) {
              totalSpentForDay += transaction.transaction.amount;
            });
            return SliverStickyHeader(
              header: DateDivider(
                  date: date,
                  info: snapshot.data!.length > 1
                      ? convertToMoney(totalSpentForDay)
                      : ""),
              sticky: true,
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return TransactionEntry(
                      category: snapshot.data![index].category,
                      openPage: AddTransactionPage(
                        title: "Edit Transaction",
                        transaction: snapshot.data![index].transaction,
                      ),
                      transaction: snapshot.data![index].transaction,
                    );
                  },
                  childCount: snapshot.data?.length,
                ),
              ),
            );
          }
          return SliverToBoxAdapter(child: SizedBox());
        },
      ),
    );
  }
  return transactionsWidgets;
}

class TransactionsListPage extends StatefulWidget {
  const TransactionsListPage({Key? key}) : super(key: key);

  @override
  State<TransactionsListPage> createState() => _TransactionsListPageState();
}

class _TransactionsListPageState extends State<TransactionsListPage> {
  late Color selectedColor = Colors.red;
  late List<Widget> transactionWidgets = [];
  @override
  void initState() {
    super.initState();
    transactionWidgets = getTransactionsSlivers(
        DateTime(2022, 01, 1),
        new DateTime(
            DateTime.now().year, DateTime.now().month + 1, DateTime.now().day));
  }

  searchTransaction(String search) {
    setState(() {
      transactionWidgets = getTransactionsSlivers(
          DateTime(2022, 01, 1),
          new DateTime(DateTime.now().year, DateTime.now().month + 1,
              DateTime.now().day),
          search: search);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        //Minimize keyboard when tap non interactive widget
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: PageFramework(
        title: "Transactions",
        backButton: false,
        appBarBackgroundColor: Theme.of(context).colorScheme.accentColor,
        appBarBackgroundColorStart: Theme.of(context).canvasColor,
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: 10)),
          ...transactionWidgets
        ],
        subtitle: TextInput(
          labelText: "Search",
          bubbly: true,
          icon: Icons.search_rounded,
          onSubmitted: (value) {
            searchTransaction(value);
          },
          onChanged: (value) => searchTransaction(value),
        ),
        subtitleSize: 20,
        subtitleAnimationSpeed: 4.5,
      ),
    );
  }
}
