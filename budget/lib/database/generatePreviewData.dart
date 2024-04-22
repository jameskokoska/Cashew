import 'dart:math';

import 'package:budget/colors.dart';
import 'package:budget/database/initializeDefaultDatabase.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/main.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/notificationsSettings.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/viewAllTransactionsButton.dart';
import 'package:budget/widgets/walletEntry.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

Future deletePreviewData({bool resetOnboard = false}) async {
  if (resetOnboard) {
    updateSettings("hasOnboarded", false, updateGlobalState: true);
  }

  loadingIndeterminateKey.currentState?.setVisibility(true);
  try {
    await cancelUpcomingTransactionsNotification();
  } catch (e) {
    print(e.toString());
  }

  try {
    List<Transaction> transactionsToDelete =
        await database.getAllPreviewTransactions();
    List<String> transactionPks = transactionsToDelete
        .map((transaction) => transaction.transactionPk)
        .toList();
    await database.deleteTransactions(transactionPks, updateSharedEntry: false);
  } catch (e) {
    print(e.toString());
  }

  try {
    await database.deleteWallet("10", 1);
  } catch (e) {
    print(e.toString());
  }
  try {
    await database.deleteWallet("11", 2);
  } catch (e) {
    print(e.toString());
  }
  try {
    await database.forceDeleteBudgets(["10", "11"]);
  } catch (e) {
    print(e.toString());
  }
  try {
    await database.forceDeleteObjectives(["10", "11"]);
  } catch (e) {
    print(e.toString());
  }

  await database.createOrUpdateWallet(
    defaultWallet(),
    customDateTimeModified: DateTime(0),
  );

  await setPrimaryWallet("0");

  await database.deleteAllDeleteLogs();

  await createDefaultCategories();

  loadingIndeterminateKey.currentState?.setVisibility(false);
  updateSettings("previewDemo", false, updateGlobalState: false);
}

Future generatePreviewData() async {
  updateSettings("previewDemo", true, updateGlobalState: false);
  loadingIndeterminateKey.currentState?.setVisibility(true);
  await createDefaultCategories();
  await database.createOrUpdateWallet(
    TransactionWallet(
      walletPk: "0",
      name: "Bank",
      colour: null,
      iconName: null,
      dateCreated: DateTime.now(),
      dateTimeModified: null,
      order: 0,
      currency: "usd",
      decimals: 2,
      homePageWidgetDisplay: defaultWalletHomePageWidgetDisplay,
    ),
  );
  await database.createOrUpdateWallet(
    TransactionWallet(
      walletPk: "10",
      name: "Euros",
      colour: "0xff66bb6a",
      iconName: null,
      dateCreated: DateTime.now(),
      dateTimeModified: null,
      order: 1,
      currency: "eur",
      decimals: 2,
      homePageWidgetDisplay: defaultWalletHomePageWidgetDisplay,
    ),
  );
  await database.createOrUpdateWallet(
    TransactionWallet(
      walletPk: "11",
      name: "Bitcoin",
      colour: "0xffef5350",
      iconName: null,
      dateCreated: DateTime.now(),
      dateTimeModified: null,
      order: 2,
      currency: "btc",
      decimals: 7,
      homePageWidgetDisplay: defaultWalletHomePageWidgetDisplay,
    ),
  );
  DateTime tripStart = DateTime.now().subtract(Duration(days: 7));
  DateTime tripEnd = DateTime.now().add(Duration(days: 14));
  await database.createOrUpdateBudget(
    updateSharedEntry: false,
    Budget(
      budgetPk: "10",
      name: "Vacation",
      amount: 2500.0,
      colour: "0xffef5350",
      startDate: tripStart.subtract(Duration(minutes: 24)),
      endDate: tripEnd,
      categoryFks: [],
      addedTransactionsOnly: true,
      periodLength: 1,
      reoccurrence: BudgetReoccurence.custom,
      dateCreated: DateTime.now(),
      dateTimeModified: null,
      pinned: true,
      order: 1,
      walletFk: "0",
      isAbsoluteSpendingLimit: true,
      income: false,
      archived: false,
    ),
  );
  await database.createOrUpdateObjective(
    Objective(
      objectivePk: "10",
      name: "Trip Savings Jar",
      amount: 500.0,
      order: 0,
      colour: "0xff66bb6a",
      dateCreated: DateTime.now().subtract(Duration(days: 5)),
      dateTimeModified: DateTime.now(),
      iconName: "coconut-tree.png",
      emojiIconName: null,
      income: true,
      pinned: true,
      walletFk: "0",
      archived: false,
      type: ObjectiveType.goal,
    ),
  );
  await database.createOrUpdateObjective(
    Objective(
      objectivePk: "11",
      name: "Car Payment Loan",
      amount: 1000.0,
      order: 1,
      colour: "0xffff7043",
      dateCreated: DateTime.now().subtract(Duration(days: 25)),
      dateTimeModified: DateTime.now(),
      iconName: "car.png",
      emojiIconName: null,
      income: false,
      pinned: true,
      walletFk: "0",
      archived: false,
      type: ObjectiveType.goal,
    ),
  );
  await database.createOrUpdateTransaction(
    updateSharedEntry: false,
    insert: true,
    Transaction(
      objectiveFk: "10",
      methodAdded: MethodAdded.preview,
      transactionPk: "-1",
      name: "Vacation savings",
      amount: 520.0,
      note: "Some extra money to put towards a trip!",
      categoryFk: "11",
      walletFk: "0",
      dateCreated: DateTime.now().subtract(Duration(days: 4)),
      dateTimeModified: null,
      income: true,
      periodLength: 1,
      reoccurrence: BudgetReoccurence.monthly,
      upcomingTransactionNotification: true,
      type: null,
      paid: true,
      createdAnotherFutureTransaction: false,
      skipPaid: true,
    ),
  );
  await database.createOrUpdateTransaction(
    updateSharedEntry: false,
    insert: true,
    Transaction(
      objectiveFk: "11",
      methodAdded: MethodAdded.preview,
      transactionPk: "-1",
      name: "Car Payment",
      amount: -500.0,
      note: "",
      categoryFk: "6",
      walletFk: "0",
      dateCreated: tripStart.subtract(Duration(days: 4)),
      dateTimeModified: null,
      income: false,
      periodLength: 1,
      reoccurrence: BudgetReoccurence.monthly,
      upcomingTransactionNotification: true,
      type: null,
      paid: true,
      createdAnotherFutureTransaction: false,
      skipPaid: true,
    ),
  );
  await database.createOrUpdateTransaction(
    updateSharedEntry: false,
    insert: true,
    Transaction(
      objectiveFk: "11",
      methodAdded: MethodAdded.preview,
      transactionPk: "-1",
      name: "Car Payment",
      amount: -200.0,
      note: "",
      categoryFk: "6",
      walletFk: "0",
      dateCreated: DateTime.now().subtract(Duration(days: 10)),
      dateTimeModified: null,
      income: false,
      periodLength: 1,
      reoccurrence: BudgetReoccurence.monthly,
      upcomingTransactionNotification: true,
      type: null,
      paid: true,
      createdAnotherFutureTransaction: false,
      skipPaid: true,
    ),
  );
  await database.createOrUpdateTransaction(
    updateSharedEntry: false,
    insert: true,
    Transaction(
      methodAdded: MethodAdded.preview,
      transactionPk: "-1",
      name: "Plane Ticket",
      amount: -1000.0,
      note: "",
      categoryFk: "10",
      walletFk: "0",
      dateCreated: tripStart.subtract(Duration(minutes: 41)),
      dateTimeModified: null,
      income: false,
      periodLength: 1,
      reoccurrence: BudgetReoccurence.monthly,
      upcomingTransactionNotification: true,
      type: null,
      paid: true,
      createdAnotherFutureTransaction: false,
      skipPaid: true,
      sharedReferenceBudgetPk: "10",
    ),
  );
  await database.createOrUpdateTransaction(
    updateSharedEntry: false,
    insert: true,
    Transaction(
        methodAdded: MethodAdded.preview,
        transactionPk: "-1",
        name: "Phone Bill",
        amount: -25.6,
        note: "Extra fees",
        categoryFk: "6",
        walletFk: "0",
        dateCreated:
            tripStart.add(Duration(days: 2)).subtract(Duration(minutes: 41)),
        dateTimeModified: null,
        income: false,
        periodLength: 1,
        reoccurrence: BudgetReoccurence.monthly,
        upcomingTransactionNotification: true,
        type: null,
        paid: true,
        createdAnotherFutureTransaction: false,
        skipPaid: true,
        sharedReferenceBudgetPk: "10"),
  );
  await database.createOrUpdateTransaction(
    updateSharedEntry: false,
    insert: true,
    Transaction(
      methodAdded: MethodAdded.preview,
      transactionPk: "-1",
      name: "Coffee",
      amount: -6,
      note: "",
      categoryFk: "1",
      walletFk: "10",
      dateCreated:
          tripStart.add(Duration(days: 2)).subtract(Duration(minutes: 39)),
      dateTimeModified: null,
      income: false,
      periodLength: 1,
      reoccurrence: BudgetReoccurence.monthly,
      upcomingTransactionNotification: true,
      type: null,
      paid: true,
      createdAnotherFutureTransaction: false,
      skipPaid: true,
      sharedReferenceBudgetPk: "10",
    ),
  );
  await database.createOrUpdateTransaction(
    updateSharedEntry: false,
    insert: true,
    Transaction(
      methodAdded: MethodAdded.preview,
      transactionPk: "-1",
      name: "Coffee",
      amount: -10.0,
      note: "",
      categoryFk: "1",
      walletFk: "10",
      dateCreated:
          tripStart.add(Duration(days: 4)).subtract(Duration(minutes: 34)),
      dateTimeModified: null,
      income: false,
      periodLength: 1,
      reoccurrence: BudgetReoccurence.monthly,
      upcomingTransactionNotification: true,
      type: null,
      paid: true,
      createdAnotherFutureTransaction: false,
      skipPaid: true,
      sharedReferenceBudgetPk: "10",
    ),
  );
  await database.createOrUpdateTransaction(
    updateSharedEntry: false,
    insert: true,
    Transaction(
      methodAdded: MethodAdded.preview,
      transactionPk: "-1",
      name: "Restaurant",
      amount: -50.0,
      note: "",
      categoryFk: "1",
      walletFk: "10",
      dateCreated:
          tripStart.add(Duration(days: 1)).subtract(Duration(minutes: 27)),
      dateTimeModified: null,
      income: false,
      periodLength: 1,
      reoccurrence: BudgetReoccurence.monthly,
      upcomingTransactionNotification: true,
      type: null,
      paid: true,
      createdAnotherFutureTransaction: false,
      skipPaid: true,
      sharedReferenceBudgetPk: "10",
    ),
  );
  await database.createOrUpdateTransaction(
    updateSharedEntry: false,
    insert: true,
    Transaction(
      methodAdded: MethodAdded.preview,
      transactionPk: "-1",
      name: "",
      amount: -22.0,
      note: "",
      categoryFk: "2",
      walletFk: "10",
      dateCreated:
          tripStart.add(Duration(days: 4)).subtract(Duration(minutes: 23)),
      dateTimeModified: null,
      income: false,
      periodLength: 1,
      reoccurrence: BudgetReoccurence.monthly,
      upcomingTransactionNotification: true,
      type: null,
      paid: true,
      createdAnotherFutureTransaction: false,
      skipPaid: true,
      sharedReferenceBudgetPk: "10",
    ),
  );
  await database.createOrUpdateTransaction(
    updateSharedEntry: false,
    insert: true,
    Transaction(
      methodAdded: MethodAdded.preview,
      transactionPk: "-1",
      name: "",
      amount: -15,
      note: "",
      categoryFk: "4",
      walletFk: "10",
      dateCreated:
          tripStart.add(Duration(days: 3)).subtract(Duration(minutes: 8)),
      dateTimeModified: null,
      income: false,
      periodLength: 1,
      reoccurrence: BudgetReoccurence.monthly,
      upcomingTransactionNotification: true,
      type: null,
      paid: true,
      createdAnotherFutureTransaction: false,
      skipPaid: true,
      sharedReferenceBudgetPk: "10",
    ),
  );
  int monthlySpendingDayStart = DateTime.now().day <= 10 ? 15 : 2;
  await database.createOrUpdateBudget(
    updateSharedEntry: false,
    Budget(
        budgetPk: "11",
        name: "Monthly Spending",
        amount: 500.0,
        colour: null,
        startDate: DateTime(DateTime.now().year, DateTime.now().month,
                monthlySpendingDayStart)
            .subtract(Duration(minutes: 19)),
        endDate: DateTime.now(),
        categoryFks: null,
        addedTransactionsOnly: false,
        periodLength: 1,
        reoccurrence: BudgetReoccurence.monthly,
        dateCreated: DateTime.now(),
        dateTimeModified: null,
        pinned: true,
        order: 0,
        walletFk: "0",
        budgetTransactionFilters: [],
        memberTransactionFilters: null,
        sharedKey: null,
        sharedOwnerMember: null,
        sharedDateUpdated: null,
        sharedMembers: null,
        sharedAllMembersEver: null,
        isAbsoluteSpendingLimit: false,
        income: false,
        archived: false),
  );
  await database.createOrUpdateTransaction(
    updateSharedEntry: false,
    insert: true,
    Transaction(
      methodAdded: MethodAdded.preview,
      transactionPk: "-1",
      name: "Payroll",
      amount: 580.89,
      note: "",
      categoryFk: "11",
      walletFk: "0",
      dateCreated: DateTime(DateTime.now().year, DateTime.now().month - 2, 1)
          .subtract(Duration(minutes: 17)),
      dateTimeModified: null,
      income: true,
      periodLength: 1,
      reoccurrence: BudgetReoccurence.monthly,
      upcomingTransactionNotification: true,
      type: null,
      paid: true,
      createdAnotherFutureTransaction: false,
      skipPaid: true,
    ),
  );
  await database.createOrUpdateTransaction(
    updateSharedEntry: false,
    insert: true,
    Transaction(
      methodAdded: MethodAdded.preview,
      transactionPk: "-1",
      name: "Payroll",
      amount: 780.55,
      note: "",
      categoryFk: "11",
      walletFk: "0",
      dateCreated: DateTime(DateTime.now().year, DateTime.now().month - 1, 1)
          .subtract(Duration(minutes: 13)),
      dateTimeModified: null,
      income: true,
      periodLength: 1,
      reoccurrence: BudgetReoccurence.monthly,
      upcomingTransactionNotification: true,
      type: null,
      paid: true,
      createdAnotherFutureTransaction: false,
      skipPaid: true,
    ),
  );
  await database.createOrUpdateTransaction(
    updateSharedEntry: false,
    insert: true,
    Transaction(
      methodAdded: MethodAdded.preview,
      transactionPk: "-1",
      name: "Payroll",
      amount: 650.45,
      note: "",
      categoryFk: "11",
      walletFk: "0",
      dateCreated: DateTime(DateTime.now().year, DateTime.now().month, 1)
          .subtract(Duration(minutes: 35)),
      dateTimeModified: null,
      income: true,
      periodLength: 1,
      reoccurrence: BudgetReoccurence.monthly,
      upcomingTransactionNotification: true,
      type: null,
      paid: true,
      createdAnotherFutureTransaction: false,
      skipPaid: true,
    ),
  );
  await database.createOrUpdateTransaction(
    updateSharedEntry: false,
    insert: true,
    Transaction(
      methodAdded: MethodAdded.preview,
      transactionPk: "-1",
      name: "Extra income",
      amount: 0.005,
      note: "",
      categoryFk: "11",
      walletFk: "11",
      dateCreated: DateTime(DateTime.now().year, DateTime.now().month,
              DateTime.now().day - 20)
          .subtract(Duration(minutes: 40)),
      dateTimeModified: null,
      income: true,
      periodLength: 1,
      reoccurrence: BudgetReoccurence.monthly,
      upcomingTransactionNotification: true,
      type: null,
      paid: true,
      createdAnotherFutureTransaction: false,
      skipPaid: true,
    ),
  );
  await database.createOrUpdateTransaction(
    updateSharedEntry: false,
    insert: true,
    Transaction(
      methodAdded: MethodAdded.preview,
      transactionPk: "-1",
      name: "Clothes",
      amount: -95.0,
      note: "Department store",
      categoryFk: "3",
      walletFk: "0",
      dateCreated: DateTime.now()
          .subtract(Duration(days: 5))
          .subtract(Duration(minutes: 30)),
      dateTimeModified: null,
      income: false,
      periodLength: 1,
      reoccurrence: BudgetReoccurence.monthly,
      upcomingTransactionNotification: true,
      type: null,
      paid: true,
      createdAnotherFutureTransaction: false,
      skipPaid: true,
    ),
  );
  await database.createOrUpdateTransaction(
    updateSharedEntry: false,
    insert: true,
    Transaction(
      methodAdded: MethodAdded.preview,
      transactionPk: "-1",
      name: "",
      amount: -32.0,
      note: "",
      categoryFk: "1",
      walletFk: "0",
      dateCreated: DateTime.now()
          .subtract(Duration(days: 9))
          .subtract(Duration(minutes: 5)),
      dateTimeModified: null,
      income: false,
      periodLength: 1,
      reoccurrence: BudgetReoccurence.monthly,
      upcomingTransactionNotification: true,
      type: null,
      paid: true,
      createdAnotherFutureTransaction: false,
      skipPaid: true,
    ),
  );
  await database.createOrUpdateTransaction(
    updateSharedEntry: false,
    insert: true,
    Transaction(
      methodAdded: MethodAdded.preview,
      transactionPk: "-1",
      name: "",
      amount: -8.53,
      note: "",
      categoryFk: "1",
      walletFk: "0",
      dateCreated: DateTime.now()
          .subtract(Duration(days: 11))
          .subtract(Duration(minutes: 10)),
      dateTimeModified: null,
      income: false,
      periodLength: 1,
      reoccurrence: BudgetReoccurence.monthly,
      upcomingTransactionNotification: true,
      type: null,
      paid: true,
      createdAnotherFutureTransaction: false,
      skipPaid: true,
    ),
  );
  await database.createOrUpdateTransaction(
    updateSharedEntry: false,
    insert: true,
    Transaction(
      methodAdded: MethodAdded.preview,
      transactionPk: "-1",
      name: "Movie streaming service",
      amount: -15.0,
      note: "",
      categoryFk: "5",
      walletFk: "0",
      dateCreated:
          DateTime.now().add(Duration(days: 2)).subtract(Duration(minutes: 20)),
      dateTimeModified: null,
      income: false,
      periodLength: 1,
      reoccurrence: BudgetReoccurence.monthly,
      upcomingTransactionNotification: true,
      type: TransactionSpecialType.subscription,
      paid: false,
      createdAnotherFutureTransaction: false,
      skipPaid: false,
    ),
  );
  await database.createOrUpdateCategoryLimit(
    insert: true,
    CategoryBudgetLimit(
      categoryLimitPk: "-1",
      categoryFk: "1",
      budgetFk: "11",
      amount: 20.0,
      dateTimeModified: DateTime.now(),
      walletFk: "0",
    ),
  );
  await database.createOrUpdateCategoryLimit(
    insert: true,
    CategoryBudgetLimit(
      categoryLimitPk: "-1",
      categoryFk: "2",
      budgetFk: "11",
      amount: 35.0,
      dateTimeModified: DateTime.now(),
      walletFk: "0",
    ),
  );
  await database.createOrUpdateCategoryLimit(
    insert: true,
    CategoryBudgetLimit(
      categoryLimitPk: "-1",
      categoryFk: "3",
      budgetFk: "11",
      amount: 25.0,
      dateTimeModified: DateTime.now(),
      walletFk: "0",
    ),
  );
  await database.createOrUpdateCategoryLimit(
    insert: true,
    CategoryBudgetLimit(
      categoryLimitPk: "-1",
      categoryFk: "10",
      budgetFk: "10",
      amount: 1100,
      dateTimeModified: DateTime.now(),
      walletFk: "0",
    ),
  );
  loadingIndeterminateKey.currentState?.setVisibility(false);
  for (int i = 0; i < 20; i++) {
    List<int> moreCommonCategories = [1, 2, 3, 4, 5];
    List<int> moreCommonCommonCategories = [1, 2, 4];
    await database.createOrUpdateTransaction(
      updateSharedEntry: false,
      insert: true,
      Transaction(
        methodAdded: MethodAdded.preview,
        transactionPk: "-1",
        name: "",
        amount: (5 + Random().nextDouble() * 10) * -1,
        note: "",
        categoryFk: (Random().nextInt(2) == 0
                ? Random().nextInt(2) == 0
                    ? moreCommonCategories[
                        Random().nextInt(moreCommonCommonCategories.length)]
                    : moreCommonCategories[
                        Random().nextInt(moreCommonCategories.length)]
                : Random().nextInt(11) + 1)
            .toString(),
        walletFk: "0",
        dateCreated: DateTime.now()
            .subtract(Duration(days: i))
            .subtract(Duration(minutes: i * 13)),
        income: false,
        paid: true,
        skipPaid: true,
      ),
    );
  }
  for (int i = 5; i < 300; i = i + Random().nextInt(4)) {
    List<int> moreCommonCategories = [1, 2, 3, 4, 5];
    List<int> moreCommonCommonCategories = [1, 2, 4];
    loadingProgressKey.currentState?.setProgressPercentage(i / 300);
    await database.createOrUpdateTransaction(
      updateSharedEntry: false,
      insert: true,
      Transaction(
        methodAdded: MethodAdded.preview,
        transactionPk: "-1",
        name: "",
        amount: (1 + Random().nextDouble() * 45) * -1,
        note: "",
        categoryFk: (Random().nextInt(2) == 0
                ? Random().nextInt(2) == 0
                    ? moreCommonCategories[
                        Random().nextInt(moreCommonCommonCategories.length)]
                    : moreCommonCategories[
                        Random().nextInt(moreCommonCategories.length)]
                : Random().nextInt(11) + 1)
            .toString(),
        walletFk: "0",
        dateCreated: DateTime.now()
            .subtract(Duration(days: i))
            .subtract(Duration(minutes: i * 2)),
        income: false,
        paid: true,
        skipPaid: true,
      ),
    );
  }
  loadingProgressKey.currentState?.setProgressPercentage(0);

  for (int i = 90; i < 320; i = i + 25 + Random().nextInt(10)) {
    loadingIndeterminateKey.currentState?.setVisibility(true);
    await database.createOrUpdateTransaction(
      updateSharedEntry: false,
      insert: true,
      Transaction(
        methodAdded: MethodAdded.preview,
        transactionPk: "-1",
        name: "",
        amount: 300 + Random().nextDouble() * 200,
        note: "",
        categoryFk: (Random().nextInt(2) == 0 ? 6 : 10).toString(),
        walletFk: "0",
        dateCreated: DateTime.now()
            .subtract(Duration(days: i))
            .subtract(Duration(minutes: i * 2)),
        income: true,
        paid: true,
        skipPaid: true,
      ),
    );
  }

  // if (allowDangerousDebugFlags) {
  //   // Large database test

  //   List<TransactionsCompanion> insert = [];

  //   for (int i = 0; i < 35000; i++) {
  //     insert.add(
  //       Transaction(
  //         methodAdded: MethodAdded.preview,
  //         transactionPk: uuid.v4(),
  //         name: "",
  //         amount: -(10 + Random().nextDouble() * 200),
  //         note: "",
  //         categoryFk: (Random().nextInt(2) == 0 ? 6 : 10).toString(),
  //         walletFk: "0",
  //         dateCreated: DateTime.now().subtract(Duration(days: i)),
  //         income: false,
  //         paid: true,
  //         skipPaid: true,
  //       ).toCompanion(true),
  //     );
  //   }
  //   for (int i = 0; i < 35000; i++) {
  //     insert.add(
  //       Transaction(
  //         methodAdded: MethodAdded.preview,
  //         transactionPk: uuid.v4(),
  //         name: "",
  //         amount: -(10 + Random().nextDouble() * 200),
  //         note: "",
  //         categoryFk: (Random().nextInt(2) == 0 ? 6 : 10).toString(),
  //         walletFk: "0",
  //         dateCreated: DateTime.now().subtract(Duration(days: i)),
  //         income: false,
  //         paid: true,
  //         skipPaid: true,
  //       ).toCompanion(true),
  //     );
  //   }
  //   await database.createBatchTransactionsOnly(insert);
  // }

  loadingIndeterminateKey.currentState?.setVisibility(false);
}

class PreviewDemoWarning extends StatelessWidget {
  const PreviewDemoWarning({super.key});

  @override
  Widget build(BuildContext context) {
    return appStateSettings["previewDemo"] == true
        ? Padding(
            padding:
                EdgeInsets.only(bottom: MediaQuery.viewPaddingOf(context).top),
            child: Tappable(
              onTap: () async {
                deletePreviewData(resetOnboard: true);
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextFont(
                  text: "preview-demo-warning".tr(),
                  textColor: Theme.of(context).colorScheme.onError,
                  fontSize: 15,
                  maxLines: 10,
                ),
              ),
              color: Theme.of(context).colorScheme.error,
            ),
          )
        : SizedBox.shrink();
  }
}

class PreviewDemoButton extends StatelessWidget {
  const PreviewDemoButton({required this.nextNavigation, super.key});
  final Function nextNavigation;

  @override
  Widget build(BuildContext context) {
    // Only allow preview demo if the language is English
    if (context.locale.toString() == "en") {
      return LowKeyButton(
        onTap: () {
          openPopup(
            context,
            title: "preview-demo".tr(),
            description: "preview-demo-description".tr(),
            onCancel: () {
              Navigator.pop(context);
            },
            onCancelLabel: "cancel".tr(),
            onSubmit: () {
              Navigator.pop(context);
              nextNavigation(generatePreview: true);
            },
            onSubmitLabel: "activate".tr(),
          );
        },
        text: "preview-demo".tr(),
        extraWidget: Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Icon(
            Icons.help,
            size: 17,
            color: getColor(context, "black").withOpacity(0.5),
          ),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }
}

Future<bool> checkLockedFeatureIfInDemoMode(BuildContext? context) async {
  if (context == null && appStateSettings["previewDemo"] == true) return false;
  if (appStateSettings["previewDemo"] == true) {
    await openPopup(
      context!,
      icon: appStateSettings["outlinedIcons"]
          ? Icons.warning_outlined
          : Icons.warning_rounded,
      title: "not-available-in-preview-demo".tr(),
      description: "not-available-in-preview-demo-description".tr(),
      onCancel: () {
        Navigator.pop(context);
      },
      onCancelLabel: "cancel".tr(),
      onSubmit: () {
        Navigator.of(context).popUntil((route) => route.isFirst);
        deletePreviewData(resetOnboard: true);
      },
      onSubmitLabel: "exit-demo".tr(),
    );
    return false;
  }
  return true;
}
