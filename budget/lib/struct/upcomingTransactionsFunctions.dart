import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/globalSnackBar.dart';
import 'package:budget/struct/initializeNotifications.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/selectAmount.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:budget/widgets/openBottomSheet.dart';

createNewSubscriptionTransaction(context, Transaction transaction) async {
  if (transaction.createdAnotherFutureTransaction == false) {
    if (transaction.type == TransactionSpecialType.subscription ||
        transaction.type == TransactionSpecialType.repetitive) {
      int yearOffset = 0;
      int monthOffset = 0;
      int dayOffset = 0;
      if (transaction.reoccurrence == BudgetReoccurence.yearly) {
        yearOffset = transaction.periodLength ?? 0;
      } else if (transaction.reoccurrence == BudgetReoccurence.monthly) {
        monthOffset = transaction.periodLength ?? 0;
      } else if (transaction.reoccurrence == BudgetReoccurence.weekly) {
        dayOffset = (transaction.periodLength ?? 0) * 7;
      } else if (transaction.reoccurrence == BudgetReoccurence.daily) {
        dayOffset = transaction.periodLength ?? 0;
      }
      DateTime newDate = DateTime(
        transaction.dateCreated.year + yearOffset,
        transaction.dateCreated.month + monthOffset,
        transaction.dateCreated.day + dayOffset,
      );
      Transaction newTransaction = transaction.copyWith(
        paid: false,
        transactionPk: DateTime.now().millisecondsSinceEpoch,
        dateCreated: newDate,
        createdAnotherFutureTransaction: Value(false),
      );
      await database.createOrUpdateTransaction(newTransaction);

      if (context != null) {
        openSnackbar(
          SnackbarMessage(
            title: "Created New Subscription",
            description: "On " + getWordedDateShort(newDate),
            icon: Icons.event_repeat_rounded,
            onTap: () {
              pushRoute(
                context,
                AddTransactionPage(
                    title: "Edit Transaction", transaction: newTransaction),
              );
            },
          ),
        );
      }
    }
  }
}

void openPayPopup(BuildContext context, Transaction transaction) {
  openPopup(
    context,
    icon: Icons.check_circle_rounded,
    title: transaction.income ? "Deposit?" : "Pay?",
    description: transaction.income
        ? "Deposit this amount?"
        : "Add payment on this transaction?",
    onCancelLabel: "Cancel",
    onCancel: () {
      Navigator.pop(context);
    },
    onExtraLabel: "Skip",
    onExtra: () async {
      Navigator.pop(context);
      Transaction transactionNew = transaction.copyWith(
        skipPaid: true,
        dateCreated: DateTime.now(),
        createdAnotherFutureTransaction: Value(true),
      );
      await database.createOrUpdateTransaction(transactionNew);
      await createNewSubscriptionTransaction(context, transaction);
      setUpcomingNotifications(context);
    },
    onSubmitLabel: transaction.income ? "Deposit" : "Pay",
    onSubmit: () async {
      Navigator.pop(context);
      double amount = transaction.amount;
      if (transaction.amount == 0) {
        amount = await openBottomSheet(
          context,
          PopupFramework(
            title: "Enter Amount",
            underTitleSpace: false,
            child: SelectAmount(
              setSelectedAmount: (_, __) {},
              nextLabel: "Set Amount",
              popWithAmount: true,
            ),
          ),
        );
      }
      Transaction transactionNew = transaction.copyWith(
        amount: amount,
        paid: true,
        dateCreated: DateTime.now(),
        createdAnotherFutureTransaction: Value(true),
      );
      await database.createOrUpdateTransaction(transactionNew);
      await createNewSubscriptionTransaction(context, transaction);
      setUpcomingNotifications(context);
    },
  );
}

void openPayDebtCreditPopup(BuildContext context, Transaction transaction) {
  openPopup(
    context,
    icon: Icons.check_circle_rounded,
    title: transaction.type == TransactionSpecialType.credit
        ? "Collect?"
        : transaction.type == TransactionSpecialType.debt
            ? "Settled?"
            : "",
    description: transaction.type == TransactionSpecialType.credit
        ? "Have you collected amount you lent?"
        : transaction.type == TransactionSpecialType.debt
            ? "Have you paid and settled your debt?"
            : "",
    onCancelLabel: "Cancel",
    onCancel: () {
      Navigator.pop(context);
    },
    onSubmitLabel: transaction.type == TransactionSpecialType.credit
        ? "Collect"
        : transaction.type == TransactionSpecialType.debt
            ? "Settle"
            : "",
    onSubmit: () async {
      Navigator.pop(context);
      Transaction transactionNew = transaction.copyWith(
        //we don't want it to count towards the total - net is zero now
        paid: false,
      );
      await database.createOrUpdateTransaction(transactionNew);
    },
  );
}

void openRemoveSkipPopup(BuildContext context, Transaction transaction) {
  openPopup(context,
      icon: Icons.unpublished_rounded,
      title: "Remove Skip?",
      description: "Remove the skipped payment on this transaction?",
      onCancelLabel: "Cancel",
      onCancel: () {
        Navigator.pop(context);
      },
      onSubmitLabel: "Remove",
      onSubmit: () async {
        Navigator.pop(context);
        Transaction transactionNew = transaction.copyWith(skipPaid: false);
        await database.createOrUpdateTransaction(transactionNew);
        setUpcomingNotifications(context);
      });
}

void openUnpayPopup(BuildContext context, Transaction transaction) {
  openPopup(context,
      icon: Icons.unpublished_rounded,
      title: "Remove Payment?",
      description: "Remove the payment on this transaction?",
      onCancelLabel: "Cancel",
      onCancel: () {
        Navigator.pop(context);
      },
      onSubmitLabel: "Remove",
      onSubmit: () async {
        Navigator.pop(context);
        await database.deleteTransaction(transaction.transactionPk);
        Transaction transactionNew = transaction.copyWith(
          paid: false,
          sharedKey: Value(null),
          transactionOriginalOwnerEmail: Value(null),
          sharedDateUpdated: Value(null),
          sharedStatus: Value(null),
        );
        await database.createOrUpdateTransaction(transactionNew);
        setUpcomingNotifications(context);
      });
}

void openUnpayDebtCreditPopup(BuildContext context, Transaction transaction) {
  openPopup(context,
      icon: Icons.unpublished_rounded,
      title: "Remove Payment?",
      description: "Remove the payment on this transaction?",
      onCancelLabel: "Cancel",
      onCancel: () {
        Navigator.pop(context);
      },
      onSubmitLabel: "Remove",
      onSubmit: () async {
        Navigator.pop(context);
        Transaction transactionNew = transaction.copyWith(
          //we want it to count towards the total now - net is not zero
          paid: true,
        );
        await database.createOrUpdateTransaction(transactionNew,
            updateSharedEntry: false);
      });
}

Future<bool> markSubscriptionsAsPaid() async {
  List<Transaction> subscriptions = await database.getAllSubscriptions().$2;
  for (Transaction transaction in subscriptions) {
    if (transaction.dateCreated.isBefore(DateTime.now())) {
      Transaction transactionNew = transaction.copyWith(
        paid: true,
        dateCreated: transaction.dateCreated,
        createdAnotherFutureTransaction: Value(true),
      );
      await database.createOrUpdateTransaction(transactionNew);
      await createNewSubscriptionTransaction(null, transaction);
    }
  }
  return true;
}
