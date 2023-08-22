import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/currencyFunctions.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/countNumber.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';

class TransactionEntryAmount extends StatelessWidget {
  const TransactionEntryAmount({
    required this.transaction,
    required this.textColor,
    required this.showOtherCurrency,
    super.key,
  });
  final Transaction transaction;
  final Color textColor;
  final bool showOtherCurrency;

  @override
  Widget build(BuildContext context) {
    double count = transaction.amount.abs() *
        (amountRatioToPrimaryCurrencyGivenPk(
                Provider.of<AllWallets>(context), transaction.walletFk) ??
            1);
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
                    Transform.translate(
                      offset: Offset(3, 0),
                      child: AnimatedSizeSwitcher(
                        child: ((transaction.type ==
                                        TransactionSpecialType.credit ||
                                    transaction.type ==
                                        TransactionSpecialType.debt) &&
                                transaction.paid == false)
                            ? SizedBox.shrink()
                            : AnimatedRotation(
                                duration: Duration(milliseconds: 2000),
                                curve: ElasticOutCurve(0.5),
                                turns: transaction.income ? 0.5 : 0,
                                child: Icon(
                                  Icons.arrow_drop_down_rounded,
                                  color: textColor,
                                ),
                              ),
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
                      textColor: textColor,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        AnimatedSizeSwitcher(
          child: showOtherCurrency
              ? Padding(
                  key: ValueKey(1),
                  padding: const EdgeInsets.only(top: 1),
                  child: TextFont(
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
                    textColor: transaction.paid
                        ? textColor.withOpacity(0.6)
                        : textColor.withOpacity(0.35),
                  ),
                )
              : Container(
                  key: ValueKey(0),
                ),
        ),
      ],
    );
  }
}
