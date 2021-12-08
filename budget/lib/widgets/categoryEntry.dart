import 'package:budget/functions.dart';
import 'package:budget/struct/transactionCategory.dart';
import 'package:budget/struct/transactionTag.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:flutter/material.dart';
import '../colors.dart';

class CategoryEntry extends StatelessWidget {
  CategoryEntry({Key? key, required this.category}) : super(key: key);

  final TransactionCategoryOld category;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 1),
      child: Container(
        margin: EdgeInsets.only(left: 14, right: 25, top: 6, bottom: 6),
        child: Row(
          children: [
            // CategoryIcon(
            //   category: category,
            //   size: 30,
            //   margin: EdgeInsets.zero,
            // ),
            Container(
              width: 15,
            ),
            Expanded(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFont(
                      text: category.title,
                      fontSize: 20,
                    ),
                    TextFont(
                      text: "15 transactions",
                      fontSize: 15,
                    )
                  ],
                ),
              ),
            ),
            //TODO: add total amount of this category within time period
            TextFont(
              text: convertToMoney(500),
              fontSize: 23,
            ),
          ],
        ),
      ),
    );
  }
}
