import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/currencyFunctions.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/countNumber.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';

import 'incomeAmountArrow.dart';

class TransactionEntryAmount extends StatelessWidget {
  const TransactionEntryAmount({
    required this.transaction,
    required this.showOtherCurrency,
    super.key,
  });
  final Transaction transaction;
  final bool showOtherCurrency;

  @override
  Widget build(BuildContext context) {
    double count = transaction.amount.abs() *
        (amountRatioToPrimaryCurrencyGivenPk(
            Provider.of<AllWallets>(context), transaction.walletFk));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            CountNumber(
              count: count,
              duration: Duration(milliseconds: 1000),
              initialCount: count,
              textBuilder: (number) {
                return Row(
                  children: [
                    AnimatedSizeSwitcher(
                      child:
                          ((transaction.type == TransactionSpecialType.credit ||
                                      transaction.type ==
                                          TransactionSpecialType.debt) &&
                                  transaction.paid == false)
                              ? SizedBox.shrink()
                              : IncomeOutcomeArrow(
                                  isIncome: transaction.income,
                                  color: getTransactionAmountColor(
                                    context,
                                    transaction,
                                  ),
                                  width: 15,
                                ),
                    ),
                    TextFont(
                      text: convertToMoney(
                        Provider.of<AllWallets>(context),
                        number,
                        finalNumber: count,
                      ),
                      fontSize: 19 - (showOtherCurrency ? 1 : 0),
                      fontWeight: FontWeight.bold,
                      textColor:
                          getTransactionAmountColor(context, transaction),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        AnimatedSizeSwitcher(
          child: showOtherCurrency
              ? TextFont(
                  key: ValueKey(1),
                  text: convertToMoney(
                    Provider.of<AllWallets>(context),
                    transaction.amount.abs(),
                    decimals: Provider.of<AllWallets>(context)
                            .indexedByPk[transaction.walletFk]
                            ?.decimals ??
                        2,
                    currencyKey: Provider.of<AllWallets>(context)
                        .indexedByPk[transaction.walletFk]
                        ?.currency,
                    addCurrencyName: true,
                  ),
                  fontSize: 12,
                  textColor: getTransactionAmountColor(context, transaction),
                )
              : Container(
                  key: ValueKey(0),
                ),
        ),
      ],
    );
  }
}

Color getTransactionAmountColor(BuildContext context, Transaction transaction) {
  Color color = (transaction.type == TransactionSpecialType.credit ||
              transaction.type == TransactionSpecialType.debt) &&
          transaction.paid
      ? transaction.type == TransactionSpecialType.credit
          ? getColor(context, "unPaidUpcoming")
          : transaction.type == TransactionSpecialType.debt
              ? getColor(context, "unPaidOverdue")
              : getColor(context, "textLight")
      : (transaction.type == TransactionSpecialType.credit ||
                  transaction.type == TransactionSpecialType.debt) &&
              transaction.paid == false
          ? getColor(context, "textLight")
          : transaction.paid
              ? transaction.income == true
                  ? getColor(context, "incomeAmount")
                  : getColor(context, "expenseAmount")
              : transaction.skipPaid
                  ? getColor(context, "textLight")
                  : transaction.dateCreated.millisecondsSinceEpoch <=
                          DateTime.now().millisecondsSinceEpoch
                      ? getColor(context, "textLight")
                      // getColor(context, "unPaidOverdue")
                      : getColor(context, "textLight");
  if (transaction.categoryFk == "0") {
    return dynamicPastel(context, color,
        inverse: true, amountLight: 0.3, amountDark: 0.25);
  }
  return color;
}
