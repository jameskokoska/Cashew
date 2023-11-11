import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';

class TransactionLabel extends StatelessWidget {
  const TransactionLabel({
    required this.transaction,
    this.category,
    required this.fontSize,
    super.key,
  });
  final Transaction transaction;
  final TransactionCategory? category;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return transaction.name != ""
        ? TextFont(
            text: transaction.name.capitalizeFirst,
            fontSize: fontSize,
          )
        : category == null
            ? StreamBuilder<TransactionCategory>(
                stream: database.getCategory(transaction.categoryFk).$1,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return TextFont(
                      text: snapshot.data!.name,
                      fontSize: fontSize,
                    );
                  }
                  return Container();
                },
              )
            : TextFont(
                text: category!.name,
                fontSize: fontSize,
              );
  }
}

Future<String> getTransactionLabel(Transaction transaction,
    {TransactionCategory? category}) async {
  if (transaction.name.trim() == "") {
    if (category == null) {
      TransactionCategory categorySearch =
          await database.getCategory(transaction.categoryFk).$2;
      return categorySearch.name.capitalizeFirst;
    } else {
      return category.name.capitalizeFirst;
    }
  } else {
    return transaction.name.capitalizeFirst;
  }
}

String getTransactionLabelSync(
    Transaction transaction, TransactionCategory? category) {
  if (transaction.name.trim() == "") {
    return category?.name.capitalizeFirst ?? transaction.name.capitalizeFirst;
  } else {
    return transaction.name.capitalizeFirst;
  }
}
