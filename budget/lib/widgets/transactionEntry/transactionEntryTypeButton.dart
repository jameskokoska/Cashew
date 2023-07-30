import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/struct/upcomingTransactionsFunctions.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/src/material/colors.dart';
import 'package:flutter/src/material/theme.dart';
import 'package:flutter/src/widgets/basic.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class TransactionEntryTypeButton extends StatelessWidget {
  const TransactionEntryTypeButton({required this.transaction, super.key});
  final Transaction transaction;
  @override
  Widget build(BuildContext context) {
    return transaction.type != null
        ? Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 3.0),
                child: Tappable(
                  color: Colors.transparent,
                  borderRadius: 10,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 3),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 7),
                      decoration: BoxDecoration(
                          color: appStateSettings["materialYou"]
                              ? Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.1)
                              : getColor(context, "lightDarkAccent"),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: TextFont(
                        text: getTransactionActionNameFromType(transaction),
                        fontSize: 14,
                        textColor: getColor(context, "textLight"),
                      ),
                    ),
                  ),
                  onTap: () {
                    openTransactionActionFromType(context, transaction);
                  },
                ),
              ),
            ],
          )
        : SizedBox();
  }
}

void openTransactionActionFromType(
    BuildContext context, Transaction transaction) {
  if (transaction.paid == false &&
      (transaction.type == TransactionSpecialType.credit ||
          transaction.type == TransactionSpecialType.debt)) {
    openUnpayDebtCreditPopup(context, transaction);
  } else if (transaction.paid == true &&
      (transaction.type == TransactionSpecialType.credit ||
          transaction.type == TransactionSpecialType.debt)) {
    openPayDebtCreditPopup(context, transaction);
  } else if (transaction.paid == true) {
    openUnpayPopup(context, transaction);
  } else if (transaction.skipPaid == true) {
    openRemoveSkipPopup(context, transaction);
  } else {
    openPayPopup(context, transaction);
  }
}

bool isTransactionActionDealtWith(Transaction transaction) {
  return transaction.type == TransactionSpecialType.credit
      ? transaction.paid
          ? false
          : true
      : transaction.type == TransactionSpecialType.debt
          ? transaction.paid
              ? false
              : true
          : transaction.income
              ? (transaction.paid
                  ? true
                  : transaction.skipPaid
                      ? true
                      : false)
              : (transaction.paid
                  ? true
                  : transaction.skipPaid
                      ? true
                      : false);
}

String getTransactionActionNameFromType(Transaction transaction) {
  return transaction.type == TransactionSpecialType.credit
      ? transaction.paid
          ? "collect".tr() + "?"
          : "collected".tr()
      : transaction.type == TransactionSpecialType.debt
          ? transaction.paid
              ? "settle".tr() + "?"
              : "settled".tr()
          : transaction.income
              ? (transaction.paid
                  ? "deposited".tr()
                  : transaction.skipPaid
                      ? "skipped".tr()
                      : "deposit".tr() + "?")
              : (transaction.paid
                  ? "paid".tr()
                  : transaction.skipPaid
                      ? "skipped".tr()
                      : "pay".tr() + "?");
}
