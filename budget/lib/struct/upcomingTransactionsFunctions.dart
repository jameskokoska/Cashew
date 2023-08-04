import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/globalSnackBar.dart';
import 'package:budget/struct/initializeNotifications.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/selectAmount.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:easy_localization/easy_localization.dart';
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
        transaction.dateCreated.hour,
        transaction.dateCreated.minute,
        transaction.dateCreated.second,
        transaction.dateCreated.millisecond,
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
            title: "created-new-transaction".tr(),
            description: getWordedDateShort(newDate),
            icon: Icons.event_repeat_rounded,
            onTap: () {
              pushRoute(
                context,
                AddTransactionPage(transaction: newTransaction),
              );
            },
          ),
        );
      }
    }
  }
}

Future openPayPopup(
  BuildContext context,
  Transaction transaction, {
  Function? runBefore,
}) async {
  return await openPopup(
    context,
    icon: Icons.check_circle_rounded,
    title: (transaction.income ? "deposit".tr() : "pay".tr()) + "?",
    description: transaction.income
        ? "deposit-description".tr()
        : "pay-description".tr(),
    onCancelLabel: "cancel".tr().tr(),
    onCancel: () {
      Navigator.pop(context, false);
    },
    onExtraLabel: "skip".tr(),
    onExtra: () async {
      if (runBefore != null) await runBefore();
      Transaction transactionNew = transaction.copyWith(
        skipPaid: true,
        dateCreated: DateTime.now(),
        createdAnotherFutureTransaction: Value(true),
      );
      Navigator.pop(context, true);
      await database.createOrUpdateTransaction(transactionNew);
      await createNewSubscriptionTransaction(
          navigatorKey.currentContext!, transaction);
      await setUpcomingNotifications(navigatorKey.currentContext!);
    },
    onSubmitLabel: transaction.income ? "deposit".tr() : "pay".tr(),
    onSubmit: () async {
      if (runBefore != null) await runBefore();
      double amount = transaction.amount;
      if (transaction.amount == 0) {
        amount = await openBottomSheet(
          context,
          PopupFramework(
            title: "enter-amount".tr(),
            underTitleSpace: false,
            child: SelectAmount(
              setSelectedAmount: (_, __) {},
              nextLabel: "set-amount".tr(),
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
      Navigator.pop(context, true);
      await database.createOrUpdateTransaction(transactionNew);
      await createNewSubscriptionTransaction(
          navigatorKey.currentContext!, transaction);
      await setUpcomingNotifications(navigatorKey.currentContext!);
    },
  );
}

Future openPayDebtCreditPopup(
  BuildContext context,
  Transaction transaction, {
  Function? runBefore,
}) async {
  return await openPopup(
    context,
    icon: Icons.check_circle_rounded,
    title: (transaction.type == TransactionSpecialType.credit
            ? "collect".tr()
            : transaction.type == TransactionSpecialType.debt
                ? "settled".tr()
                : "") +
        "?",
    description: transaction.type == TransactionSpecialType.credit
        ? "collect-description".tr()
        : transaction.type == TransactionSpecialType.debt
            ? "settle-description".tr()
            : "",
    onCancelLabel: "cancel".tr(),
    onCancel: () {
      Navigator.pop(context, false);
    },
    onSubmitLabel: transaction.type == TransactionSpecialType.credit
        ? "collect".tr()
        : transaction.type == TransactionSpecialType.debt
            ? "settle".tr()
            : "",
    onSubmit: () async {
      if (runBefore != null) await runBefore();
      Transaction transactionNew = transaction.copyWith(
        //we don't want it to count towards the total - net is zero now
        paid: false,
      );
      Navigator.pop(context, true);
      await database.createOrUpdateTransaction(transactionNew);
    },
  );
}

Future openRemoveSkipPopup(
  BuildContext context,
  Transaction transaction, {
  Function? runBefore,
}) async {
  return await openPopup(
    context,
    icon: Icons.unpublished_rounded,
    title: "remove-skip".tr() + "?",
    description: "remove-skip-description".tr(),
    onCancelLabel: "cancel".tr(),
    onCancel: () {
      Navigator.pop(context, false);
    },
    onSubmitLabel: "remove".tr(),
    onSubmit: () async {
      if (runBefore != null) await runBefore();

      Transaction transactionNew = transaction.copyWith(skipPaid: false);
      Navigator.pop(context, true);
      await database.createOrUpdateTransaction(transactionNew);
      await setUpcomingNotifications(navigatorKey.currentContext!);
    },
  );
}

Future openUnpayPopup(
  BuildContext context,
  Transaction transaction, {
  Function? runBefore,
}) async {
  return await openPopup(context,
      icon: Icons.unpublished_rounded,
      title: "remove-payment".tr() + "?",
      description: "remove-payment-description".tr(),
      onCancelLabel: "cancel".tr(),
      onCancel: () {
        Navigator.pop(context, false);
      },
      onSubmitLabel: "remove".tr(),
      onSubmit: () async {
        await database.deleteTransaction(transaction.transactionPk);
        Transaction transactionNew = transaction.copyWith(
          paid: false,
          sharedKey: Value(null),
          transactionOriginalOwnerEmail: Value(null),
          sharedDateUpdated: Value(null),
          sharedStatus: Value(null),
        );
        Navigator.pop(context, true);
        await database.createOrUpdateTransaction(transactionNew);
        await setUpcomingNotifications(navigatorKey.currentContext!);
      });
}

Future openUnpayDebtCreditPopup(
  BuildContext context,
  Transaction transaction, {
  Function? runBefore,
}) async {
  return await openPopup(
    context,
    icon: Icons.unpublished_rounded,
    title: "remove-payment".tr() + "?",
    description: "remove-payment-description".tr(),
    onCancelLabel: "cancel".tr(),
    onCancel: () {
      Navigator.pop(context, false);
    },
    onSubmitLabel: "remove".tr(),
    onSubmit: () async {
      if (runBefore != null) await runBefore();
      Transaction transactionNew = transaction.copyWith(
        //we want it to count towards the total now - net is not zero
        paid: true,
      );
      Navigator.pop(context, true);
      await database.createOrUpdateTransaction(transactionNew,
          updateSharedEntry: false);
    },
  );
}

Future<bool> markSubscriptionsAsPaid() async {
  if (appStateSettings["automaticallyPaySubscriptions"]) {
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
  }
  return true;
}
