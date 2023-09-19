import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/struct/upcomingTransactionsFunctions.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/material/colors.dart';
import 'package:flutter/src/material/theme.dart';
import 'package:flutter/src/widgets/basic.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class TransactionEntryActionButton extends StatelessWidget {
  const TransactionEntryActionButton(
      {required this.transaction,
      required this.iconColor,
      this.containerColor,
      super.key});
  final Transaction transaction;
  final Color iconColor;
  final Color? containerColor;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: getTransactionActionNameFromType(transaction),
      child: GestureDetector(
        onTap: () {
          openTransactionActionFromType(context, transaction);
        },
        child: Padding(
          padding: const EdgeInsets.only(
            left: 6,
            top: 5.5,
            bottom: 5.5,
            right: 6,
          ),
          child: Transform.scale(
            scale: isTransactionActionDealtWith(transaction) ? 0.92 : 1,
            child: Tappable(
              color: !isTransactionActionDealtWith(transaction)
                  ? Theme.of(context)
                      .colorScheme
                      .secondaryContainer
                      .withOpacity(0.6)
                  : iconColor.withOpacity(0.7),
              onTap: () {
                openTransactionActionFromType(context, transaction);
              },
              borderRadius: 100,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  getTransactionTypeIcon(transaction.type),
                  color: isTransactionActionDealtWith(transaction)
                      ? (containerColor == null
                          ? Theme.of(context).canvasColor
                          : containerColor)
                      : iconColor.withOpacity(0.8),
                  size: 23,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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

Future openTransactionActionFromType(
  BuildContext context,
  Transaction transaction, {
  Function? runBefore,
}) {
  if (transaction.paid == false &&
      (transaction.type == TransactionSpecialType.credit ||
          transaction.type == TransactionSpecialType.debt)) {
    return openUnpayDebtCreditPopup(context, transaction, runBefore: runBefore);
  } else if (transaction.paid == true &&
      (transaction.type == TransactionSpecialType.credit ||
          transaction.type == TransactionSpecialType.debt)) {
    return openPayDebtCreditPopup(context, transaction, runBefore: runBefore);
  } else if (transaction.paid == true) {
    return openUnpayPopup(context, transaction, runBefore: runBefore);
  } else if (transaction.skipPaid == true) {
    return openRemoveSkipPopup(context, transaction, runBefore: runBefore);
  } else {
    return openPayPopup(context, transaction, runBefore: runBefore);
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
