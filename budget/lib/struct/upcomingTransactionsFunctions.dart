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
import 'package:budget/widgets/transactionEntry/transactionEntryTypeButton.dart';
import 'package:budget/widgets/transactionEntry/transactionLabel.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:provider/provider.dart';

createNewSubscriptionTransaction(
    BuildContext context, Transaction transaction) async {
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

      // After end date
      if (transaction.endDate != null &&
          transaction.endDate!.isBefore(newDate)) {
        String transactionName = await getTransactionLabel(transaction);
        openSnackbar(
          SnackbarMessage(
            title: "end-date-reached".tr(),
            description: "for".tr().capitalizeFirst + " " + transactionName,
            icon: appStateSettings["outlinedIcons"]
                ? Icons.event_available_outlined
                : Icons.event_available_rounded,
          ),
        );
        return;
      }

      //Goal reached
      if (transaction.objectiveFk != null && transaction.endDate == null) {
        Objective objective =
            await database.getObjectiveInstance(transaction.objectiveFk!);
        double? totalSpentOfObjective = await database.getTotalTowardsObjective(
            Provider.of<AllWallets>(context, listen: false),
            transaction.objectiveFk!);
        bool willBeOverObjective = (totalSpentOfObjective ?? 0) >=
            (objective.amount * (objective.income ? 1 : -1));
        if (willBeOverObjective) {
          openSnackbar(
            SnackbarMessage(
              title: "goal-reached".tr(),
              description: "for".tr().capitalizeFirst + " " + objective.name,
              icon: appStateSettings["outlinedIcons"]
                  ? Icons.event_available_outlined
                  : Icons.event_available_rounded,
            ),
          );
          return;
        }
      }

      Transaction newTransaction = transaction.copyWith(
        paid: false,
        transactionPk: "-1",
        dateCreated: newDate,
        createdAnotherFutureTransaction: Value(false),
      );
      await database.createOrUpdateTransaction(insert: true, newTransaction);

      openSnackbar(
        SnackbarMessage(
          title: "created-new-transaction".tr(),
          description: getWordedDateShort(newDate),
          icon: appStateSettings["outlinedIcons"]
              ? Icons.event_repeat_outlined
              : Icons.event_repeat_rounded,
          onTap: () {
            pushRoute(
              context,
              AddTransactionPage(
                transaction: newTransaction,
                routesToPopAfterDelete: RoutesToPopAfterDelete.One,
              ),
            );
          },
        ),
      );
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
    icon: appStateSettings["outlinedIcons"]
        ? Icons.check_circle_outlined
        : Icons.check_circle_rounded,
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
      // if (transaction.amount == 0) {
      //   amount = await openBottomSheet(
      //     context,
      //     fullSnap: true,
      //     PopupFramework(
      //       title: "enter-amount".tr(),
      //       underTitleSpace: false,
      //       child: SelectAmount(
      //         setSelectedAmount: (_, __) {},
      //         nextLabel: "set-amount".tr(),
      //         popWithAmount: true,
      //       ),
      //     ),
      //   );
      //   amount = amount.abs() * (transaction.income ? 1 : -1);
      // }
      Transaction transactionNew = transaction.copyWith(
        amount: amount,
        paid: true,
        dateCreated:
            appStateSettings["markAsPaidOnOriginalDay"] ? null : DateTime.now(),
        createdAnotherFutureTransaction: Value(true),
        originalDateDue: Value(transaction.dateCreated),
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
    icon: appStateSettings["outlinedIcons"]
        ? Icons.check_circle_outlined
        : Icons.check_circle_rounded,
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
    icon: appStateSettings["outlinedIcons"]
        ? Icons.unpublished_outlined
        : Icons.unpublished_rounded,
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
      icon: appStateSettings["outlinedIcons"]
          ? Icons.unpublished_outlined
          : Icons.unpublished_rounded,
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
    icon: appStateSettings["outlinedIcons"]
        ? Icons.unpublished_outlined
        : Icons.unpublished_rounded,
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

Future<bool> markSubscriptionsAsPaid(BuildContext context,
    {int? iteration}) async {
  if (appStateSettings["automaticallyPaySubscriptions"] ||
      appStateSettings["automaticallyPayRepetitive"]) {
    // Loop through, because a new one that was created automatically may be past due
    if (iteration != null && iteration > 50) {
      return true;
    }
    List<Transaction> subscriptions = [
      if (appStateSettings["automaticallyPaySubscriptions"])
        ...(await database.getAllSubscriptions().$2),
      if (appStateSettings["automaticallyPayRepetitive"])
        ...(await database.getAllOverdueRepetitiveTransactions().$2)
    ];
    bool hasUpdatedASubscription = false;
    for (Transaction transaction in subscriptions) {
      if (transaction.dateCreated.isBefore(DateTime.now())) {
        hasUpdatedASubscription = true;
        Transaction transactionNew = transaction.copyWith(
          paid: true,
          dateCreated: transaction.dateCreated,
          createdAnotherFutureTransaction: Value(true),
        );
        await database.createOrUpdateTransaction(transactionNew);
        await createNewSubscriptionTransaction(context, transaction);
      }
    }
    if (hasUpdatedASubscription) {
      await markSubscriptionsAsPaid(context, iteration: (iteration ?? 0) + 1);
    }
    print("Automatically paid subscriptions with iteration: " +
        iteration.toString());
  }
  return true;
}

Future<bool> markUpcomingAsPaid() async {
  if (appStateSettings["automaticallyPayUpcoming"]) {
    List<Transaction> upcoming =
        await database.getAllOverdueUpcomingTransactions().$2;
    for (Transaction transaction in upcoming) {
      if (transaction.dateCreated.isBefore(DateTime.now())) {
        Transaction transactionNew = transaction.copyWith(
          paid: true,
          dateCreated: transaction.dateCreated,
        );
        await database.createOrUpdateTransaction(transactionNew);
      }
    }
    print("Automatically paid upcoming transactions");
  }
  return true;
}
