import 'package:budget/database/tables.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/budgetContainer.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/popupFramework.dart';
import 'package:budget/widgets/selectColor.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:budget/main.dart';
import 'package:budget/colors.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

class TransactionsListPage extends StatefulWidget {
  const TransactionsListPage({Key? key}) : super(key: key);

  @override
  State<TransactionsListPage> createState() => _TransactionsListPageState();
}

class _TransactionsListPageState extends State<TransactionsListPage> {
  late Color selectedColor = Colors.red;

  @override
  Widget build(BuildContext context) {
    List<Widget> transactionsWidgets = [];
    List<DateTime> dates = [];
    for (DateTime indexDay = DateTime(2022, 01, 1);
        indexDay.month <= 09;
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
                header: DateDivider(date: date),
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
              );
            }
            return SliverToBoxAdapter(child: SizedBox());
          },
        ),
      );
    }
    return PageFramework(
      title: "Transactions",
      backButton: false,
      appBarBackgroundColor: Theme.of(context).colorScheme.accentColor,
      appBarBackgroundColorStart: Theme.of(context).canvasColor,
      slivers: [...transactionsWidgets],
    );
  }
}
