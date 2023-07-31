import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/currencyFunctions.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/countNumber.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/src/material/icons.dart';
import 'package:flutter/src/widgets/animated_size.dart';
import 'package:flutter/src/widgets/basic.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/icon.dart';
import 'package:flutter/src/widgets/implicit_animations.dart';
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
              dynamicDecimals: true,
              initialCount: count,
              textBuilder: (number) {
                return Row(
                  children: [
                    Transform.translate(
                      offset: Offset(3, 0),
                      child: AnimatedSize(
                        curve: Curves.easeInOutCubicEmphasized,
                        duration: Duration(milliseconds: 1000),
                        child: (transaction.type ==
                                        TransactionSpecialType.credit ||
                                    transaction.type ==
                                        TransactionSpecialType.debt) &&
                                transaction.paid == false
                            ? Container(width: 5)
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
                        showCurrency: false,
                        finalNumber: count,
                      ),
                      fontSize: 19 - (showOtherCurrency ? 1 : 0),
                      fontWeight: FontWeight.bold,
                      textColor: textColor,
                      walletPkForCurrency: appStateSettings["selectedWallet"],
                      onlyShowCurrencyIcon: true,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        AnimatedSize(
          duration: Duration(milliseconds: 500),
          child: showOtherCurrency
              ? Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: TextFont(
                    text: convertToMoney(
                      Provider.of<AllWallets>(context),
                      transaction.amount.abs(),
                      showCurrency: false,
                      decimals: Provider.of<AllWallets>(context)
                              .indexedByPk[transaction.walletFk]
                              ?.decimals ??
                          2,
                    ),
                    fontSize: 12,
                    textColor: textColor.withOpacity(0.6),
                    walletPkForCurrency: transaction.walletFk,
                    onlyShowCurrencyIcon: transaction.walletFk ==
                        appStateSettings["selectedWallet"],
                  ),
                )
              : SizedBox.shrink(),
        ),
      ],
    );
  }
}
