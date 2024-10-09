import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/homePage/homePageLineGraph.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/notificationsSettings.dart';
import 'package:budget/widgets/periodCyclePicker.dart';
import 'package:budget/widgets/selectAmount.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// default settings, defaultSettings, initial settings
Future<Map<String, dynamic>> getDefaultPreferences() async {
  return {
    "databaseJustImported": false,
    "backupLimit": 20,
    "backupSync": true,
    "syncEveryChange": kIsWeb,
    "devicesHaveBeenSynced": 1,
    "numBackups": 1,
    "theme": "system", //system, light, dark
    "use24HourFormat": "system", //system, 12-hour, 24-hour
    "numberCountUpAnimation": true,
    "appAnimations": AppAnimations.all.index,
    "showFAQAndHelpLink": true,
    "showExtraInfoText": true,
    "selectedWalletPk": "0",
    "selectedSubscriptionType": 0,
    "accentColor": toHexString(Color(0xFF1B447A)),
    "accentSystemColor": await systemColorByDefault(),
    "widgetOpacity": 1,
    "widgetTheme": "system", //system, light, dark
    "nonCompactTransactions":
        false, //still in testing, declares a new transaction layout to show more information in lists
    "fadeTransactionNameOverflows":
        false, //still in testing, overflow transaction titles use fade instead of "..."
    "circularProgressRotation":
        false, // still in testing, offsets the circular progress to align with pie chart sections
    "forceFullDarkBackground": false,
    // FullScreen is added if the section has its own preference when full screen (double column)
    "futureTransactionDaysHomePage": 4,
    "homePageTransactionsListIncomeAndExpenseOnly": true,
    "showWalletSwitcher": true,
    "showWalletSwitcherFullScreen": true,
    "showWalletList": false,
    "showWalletListFullScreen": false,
    "showPinnedBudgets": true,
    "showPinnedBudgetsFullScreen": true,
    "showObjectives": false,
    "showObjectivesFullScreen": true,
    "showAllSpendingSummary": false,
    "showAllSpendingSummaryFullScreen": false,
    "showNetWorth": false,
    "showNetWorthFullScreen": false,
    "showOverdueUpcoming": false,
    "showOverdueUpcomingFullScreen": true,
    "showObjectiveLoans": false,
    "showObjectiveLoansFullScreen": true,
    "showCreditDebt": false,
    "showCreditDebtFullScreen": true,
    "showSpendingGraph": true,
    "showSpendingGraphFullScreen": true,
    "showPieChart": false,
    "showPieChartFullScreen": false,
    "showHeatMap": false,
    "showHeatMapFullScreen": true,
    "showTransactionsList": true,
    "showTransactionsListFullScreen": true,
    "showUsernameWelcomeBanner": true,
    "showUsernameWelcomeBannerFullScreen": true,
    "enableGreetingMessage": true,
    "homePageOrder": [
      "wallets",
      "walletsList",
      "budgets",
      "objectives",
      "allSpendingSummary",
      "netWorth",
      "overdueUpcoming",
      "creditDebts",
      "objectiveLoans",
      "spendingGraph",
      "pieChart",
      "heatMap",
      "transactionsList",
    ],
    "homePageOrderFullScreen": [
      "wallets",
      "walletsList",
      "budgets",
      "ORDER:LEFT",
      "objectives",
      "allSpendingSummary",
      "netWorth",
      "overdueUpcoming",
      "creditDebts",
      "objectiveLoans",
      "spendingGraph",
      "pieChart",
      "heatMap",
      "ORDER:RIGHT",
      "transactionsList",
    ],
    // Values for customNavBarShortcuts are the keys of navBarIconsData
    "customNavBarShortcut0": "home",
    "customNavBarShortcut1": "transactions",
    "customNavBarShortcut2": "budgets",
    "showTotalSpentForBudget": false,
    "showTotalSpentForObjective": true,
    "showCumulativeSpending": true,
    "removeZeroTransactionEntries": true,
    "ignorePastAmountSpent": false,
    "askForTransactionTitle": true,
    "askForTransactionNoteWithTitle": false,
    "automaticallyPayUpcoming": true,
    "automaticallyPayRepetitive": true,
    "automaticallyPaySubscriptions": true,
    "markAsPaidOnOriginalDay": false,
    "batterySaver": false,
    "username": "",
    "hasOnboarded": false,
    "restrictAmountOfInitiallyLoadedTransactions": false,
    "autoAddAssociatedTitles": true,
    "AutoTransactions-canReadEmails": false,
    "notificationScanningDebug": false,
    "notificationScanning": false,
    "accountColorfulAmountsWithArrows": false,
    "netTotalsColorful": false,
    "EmailAutoTransactions-amountOfEmails": 10,
    "autoBackups": true,
    "autoBackupsFrequency": 3, //in days
    "hasSignedIn": false,
    "lastBackup": DateTime.now().subtract(Duration(days: 1)).toString(),
    "lastLoginVersion": "",
    "numLogins": 0,
    "enableGoogleLoginFlyIn": false,
    "openedStoreRating": false,
    "dismissedStoreRating": false,
    "submittedFeedback": false,
    "canShowBackupReminderPopup": true,
    "canShowTransactionActionButtonTip": true,
    "autoLoginDisabledOnWebTip": true,
    "forceAutoLogin": false,
    "allSpendingPageTip": true,
    "notifications": true,
    "notificationHour": 20,
    "notificationMinute": 0,
    "notificationsUpcomingTransactions": true,
    "notificationsReminderType": ReminderNotificationType.IfAppNotOpened.index,
    "appOpenedHour": DateTime.now().hour,
    "appOpenedMinute": DateTime.now().minute,
    "materialYou": supportsSystemColor(),
    "colorTintCategoryIcon": false,
    "sendTransactionsToServerQueue": {},
    "currentUserEmail": "",
    "usersNicknames": {},
    "requireAuth": false,
    "cachedCurrencyExchange": {},
    "customCurrencies": [],
    "lineGraphReferenceBudgetPk": null,
    "lineGraphDisplayType": LineGraphDisplay.Default30Days.index,
    "lineGraphStartDate": DateTime.now().toString(),
    "pieChartTotal": "outgoing", // "outgoing", "incoming"
    "pieChartIncomeAndExpenseOnly": true,
    "pieChartAllWallets": true,
    "netWorthAllWallets": true,
    "walletsListCurrencyBreakdown": false,
    "allSpendingSummaryAllWallets": true,
    "showPastSpendingTrajectory": false,
    "lastSynced": null,
    "font": "Avenir",
    "forceSmallHeader": false,
    "animationSpeed": 1.0,
    "logging": false,
    "sharedBudgets": false,
    "emailScanning": false,
    "emailScanningPullToRefresh": false,
    "incognitoKeyboard": false,
    // the key is the budgetPk (in String!)
    // Should be of type Map<String, List<String>>
    "watchedCategoriesOnBudget": {},
    "showCompressedViewBudgetGraph": false,
    "showAllSubcategories": true,
    "expandAllCategoriesWithSpendingLimits": false,
    // Should be of type Map<String, double>
    "customCurrencyAmounts": {},
    "iOSEmulate": false,
    "iOSAnimatedGoo": false,
    "expandedNavigationSidebar": true,
    "locale": "System", // the locale code or "System"
    "firstDayOfWeek": -1, // -1: Locale/System, 0: Sunday, 1: Monday,
    "disableShadows": false,
    "showBillSplitterShortcut": false,
    "showTransactionPk": false,
    "showMethodAdded": false,
    "showBackupLimit": false,
    "outlinedIcons": false,
    "premiumPopupAddTransactionCount": -5,
    "premiumPopupAddTransactionLastShown": DateTime.now().toString(),
    "premiumPopupFreeSeen": false,
    "previewDemo": false,
    "purchaseID": null,
    "showAccountLabelTagInTransactionEntry": false,
    "showCurrencyLabel": false,
    "showTransactionsMonthlySpendingSummary": true,
    "showTransactionsBalanceTransferTab": true,
    "balanceTransferAmountColor": "green-or-red", // "green-or-red", "no-color"
    //Show all categories or only income/expense
    "showAllCategoriesWhenSelecting": true,
    // Search filters strings
    "searchTransactionsSetFiltersString": null,
    "allSpendingSetFiltersString": null,
    "transactionsListPageSetFiltersString": null,
    "increaseTextContrast": false,
    "customNumberFormat": false,
    "numberFormatDelimiter": ",",
    "numberFormatDecimal": ".",
    "numberFormatCurrencyFirst": true,
    "shortNumberFormat": null, //null, compact
    "netAllSpendingTotal": false,
    "netSpendingDayTotal": false,
    "extraZerosButton": null, //will be null, 00 or 000
    "numberPadFormat": NumberPadFormat.format123.index,
    "numberPadHapticFeedback": false,
    "savingHapticFeedback": false,
    "closeNavigationHapticFeedback": false,
    "tabNavigationHapticFeedback": false,
    "percentagePrecision": 0, //number of decimals to round percentages to
    "allSpendingLastPage": 0, //index of the last tab on the all spending page
    "loansLastPage": 0, //index of the last tab on the loans page
    // "loansUseDifferenceInsteadOfTotalGoal": false,
    // "loansHideDate": false,
    "longTermLoansDifferenceFeature": false,
    // *********************************************************** //
    // For showing information within a certain cycle for all spending wallet details page
    // cycleSettingsExtension = ""
    "selectedPeriodCycleType": CycleType.allTime.index,
    "cyclePeriodLength": 1,
    "cycleReoccurrence": BudgetReoccurence.monthly.index,
    "cycleStartDate": DateTime.now().firstDayOfMonth().toString(),
    "customPeriodStartDate": DateTime.now().firstDayOfMonth().toString(),
    "customPeriodEndDate": null,
    "customPeriodPastDays": 30,
    // For showing information within a certain cycle for pie chart
    // cycleSettingsExtension = "PieChart"
    "selectedPeriodCycleTypePieChart": CycleType.allTime.index,
    "cyclePeriodLengthPieChart": 1,
    "cycleReoccurrencePieChart": BudgetReoccurence.monthly.index,
    "cycleStartDatePieChart": DateTime.now().firstDayOfMonth().toString(),
    "customPeriodStartDatePieChart":
        DateTime.now().firstDayOfMonth().toString(),
    "customPeriodEndDatePieChart": null,
    "customPeriodPastDaysPieChart": 30,
    // For showing information within a certain cycle for net worth
    // cycleSettingsExtension = "NetWorth"
    "selectedPeriodCycleTypeNetWorth": CycleType.allTime.index,
    "cyclePeriodLengthNetWorth": 1,
    "cycleReoccurrenceNetWorth": BudgetReoccurence.monthly.index,
    "cycleStartDateNetWorth": DateTime.now().firstDayOfMonth().toString(),
    "customPeriodStartDateNetWorth":
        DateTime.now().firstDayOfMonth().toString(),
    "customPeriodEndDateNetWorth": null,
    "customPeriodPastDaysNetWorth": 30,
    // For showing information within a certain cycle for income and expenses (allSpendingSummary)
    // cycleSettingsExtension = "AllSpendingSummary"
    "selectedPeriodCycleTypeAllSpendingSummary": CycleType.allTime.index,
    "cyclePeriodLengthAllSpendingSummary": 1,
    "cycleReoccurrenceAllSpendingSummary": BudgetReoccurence.monthly.index,
    "cycleStartDateAllSpendingSummary":
        DateTime.now().firstDayOfMonth().toString(),
    "customPeriodStartDateAllSpendingSummary":
        DateTime.now().firstDayOfMonth().toString(),
    "customPeriodEndDateAllSpendingSummary": null,
    "customPeriodPastDaysAllSpendingSummary": 30,
    // For showing information within a certain cycle for overdue and upcoming (overdueUpcoming)
    // cycleSettingsExtension = "OverdueUpcoming"
    "selectedPeriodCycleTypeOverdueUpcoming": CycleType.allTime.index,
    "cyclePeriodLengthOverdueUpcoming": 1,
    "cycleReoccurrenceOverdueUpcoming": BudgetReoccurence.monthly.index,
    "cycleStartDateOverdueUpcoming":
        DateTime.now().firstDayOfMonth().toString(),
    "customPeriodStartDateOverdueUpcoming":
        DateTime.now().firstDayOfMonth().toString(),
    "customPeriodEndDateOverdueUpcoming": null,
    "customPeriodPastDaysOverdueUpcoming": 30,
    // For showing information within a certain cycle for credits and debts (loans) (creditDebts)
    // cycleSettingsExtension = "CreditDebts"
    "selectedPeriodCycleTypeCreditDebts": CycleType.allTime.index,
    "cyclePeriodLengthCreditDebts": 1,
    "cycleReoccurrenceCreditDebts": BudgetReoccurence.monthly.index,
    "cycleStartDateCreditDebts": DateTime.now().firstDayOfMonth().toString(),
    "customPeriodStartDateCreditDebts":
        DateTime.now().firstDayOfMonth().toString(),
    "customPeriodEndDateCreditDebts": null,
    "customPeriodPastDaysCreditDebts": 30,
    // // For showing information within a certain cycle for wallets homepage section
    // // cycleSettingsExtension = "Wallets"
    // "selectedPeriodCycleTypeWallets": CycleType.allTime.index,
    // "cyclePeriodLengthWallets": 1,
    // "cycleReoccurrenceWallets": BudgetReoccurence.monthly.index,
    // "cycleStartDateWallets":
    //     DateTime.now().firstDayOfMonth().toString(),
    // "customPeriodStartDateWallets":
    //     DateTime.now().firstDayOfMonth().toString(),
    // "customPeriodEndDateWallets": null,
    // "customPeriodPastDaysWallets": 30,
    // // For showing information within a certain cycle for walletsList homepage section
    // // cycleSettingsExtension = "WalletsList"
    // "selectedPeriodCycleTypeWalletsList": CycleType.allTime.index,
    // "cyclePeriodLengthWalletsList": 1,
    // "cycleReoccurrenceWalletsList": BudgetReoccurence.monthly.index,
    // "cycleStartDateWalletsList":
    //     DateTime.now().firstDayOfMonth().toString(),
    // "customPeriodStartDateWalletsList":
    //     DateTime.now().firstDayOfMonth().toString(),
    // "customPeriodEndDateWalletsList": null,
    // "customPeriodPastDaysWalletsList": 30,
    // *********************************************************** //
    //
    // Web app asks to login every time on launch setting, on by default - still testing
    // because Safari blocks popups when webpage loads? so there is no point!
    // The last synced button is there though!
    // "webForceLoginPopupOnLaunch": true,
    //

    // This key is used as a migration
    // "migratedSetLongTermLoansAmountTo0": false,
  };
}

enum AppAnimations { all, minimal, disabled }

Future attemptToMigrateSetLongTermLoansAmountTo0() async {
  try {
    if (appStateSettings["hasOnboarded"] == true &&
        appStateSettings["migratedSetLongTermLoansAmountTo0"] != true) {
      print("Migrating setting long term loans amounts to 0");
      appStateSettings["migratedSetLongTermLoansAmountTo0"] = true;
      List<Objective> objectivesInserting = [];
      List<Objective> allObjectives =
          await database.getAllObjectives(objectiveType: ObjectiveType.loan);
      for (Objective objective in allObjectives) {
        objectivesInserting.add(objective.copyWith(
            amount: 0, dateTimeModified: Value(DateTime.now())));
      }
      await database.updateBatchObjectivesOnly(objectivesInserting);
    }
  } catch (e) {
    print(
        "Error migrating setting long term loans amounts to 0 " + e.toString());
  }
}

attemptToMigrateCustomNumberFormattingSettings() {
  try {
    if (appStateSettings["numberFormatLocale"] != null) {
      if (appStateSettings["numberFormatLocale"] == "en") {
        appStateSettings["numberFormatDelimiter"] = ",";
        appStateSettings["numberFormatDecimal"] = ".";
        appStateSettings["numberFormatCurrencyFirst"] = true;
      } else if (appStateSettings["numberFormatLocale"] == "tr") {
        appStateSettings["numberFormatDelimiter"] = ".";
        appStateSettings["numberFormatDecimal"] = ",";
        appStateSettings["numberFormatCurrencyFirst"] = true;
      } else if (appStateSettings["numberFormatLocale"] == "af") {
        appStateSettings["numberFormatDelimiter"] = " ";
        appStateSettings["numberFormatDecimal"] = ",";
        appStateSettings["numberFormatCurrencyFirst"] = true;
      } else if (appStateSettings["numberFormatLocale"] == "de") {
        appStateSettings["numberFormatDelimiter"] = ".";
        appStateSettings["numberFormatDecimal"] = ",";
        appStateSettings["numberFormatCurrencyFirst"] = false;
      } else if (appStateSettings["numberFormatLocale"] == "fr") {
        appStateSettings["numberFormatDelimiter"] = " ";
        appStateSettings["numberFormatDecimal"] = ",";
        appStateSettings["numberFormatCurrencyFirst"] = false;
      }
      appStateSettings["customNumberFormat"] = true;
      appStateSettings["numberFormatLocale"] = null;
    }
  } catch (e) {
    print(
        "Error migrating setting long term loans amounts to 0 " + e.toString());
  }
}

Map<String, dynamic> attemptToMigrateCyclePreferences(
    Map<String, dynamic> currentUserSettings, String key) {
  try {
    if (
        // This is a setting we need to find a value for
        migrateCyclePreferencesKeys.keys.contains(key) &&
            // The current setting does not have a value
            currentUserSettings[key] == null &&
            // We have a current setting for the previous associated value
            currentUserSettings[migrateCyclePreferencesKeys[key]] != null) {
      print("Migrating cycle setting " +
          key.toString() +
          " to the value of " +
          currentUserSettings[migrateCyclePreferencesKeys[key]].toString() +
          " from key " +
          migrateCyclePreferencesKeys[key].toString());
      currentUserSettings[key] =
          currentUserSettings[migrateCyclePreferencesKeys[key]];
    }
  } catch (e) {
    print("Error migrating cycle preferences " + e.toString());
  }

  return currentUserSettings;
}

Map<String, String> migrateCyclePreferencesKeys = {
  "selectedPeriodCycleTypePieChart": "selectedPeriodCycleType",
  "cyclePeriodLengthPieChart": "cyclePeriodLength",
  "cycleReoccurrencePieChart": "cycleReoccurrence",
  "cycleStartDatePieChart": "customPeriodStartDate",
  "customPeriodStartDatePieChart": "customPeriodStartDate",
  "customPeriodPastDaysPieChart": "customPeriodPastDays",
  //
  "selectedPeriodCycleTypeNetWorth": "selectedPeriodCycleType",
  "cyclePeriodLengthNetWorth": "cyclePeriodLength",
  "cycleReoccurrenceNetWorth": "cycleReoccurrence",
  "cycleStartDateNetWorth": "customPeriodStartDate",
  "customPeriodStartDateNetWorth": "customPeriodStartDate",
  "customPeriodPastDaysNetWorth": "customPeriodPastDays",
  //
  "selectedPeriodCycleTypeAllSpendingSummary": "selectedPeriodCycleType",
  "cyclePeriodLengthAllSpendingSummary": "cyclePeriodLength",
  "cycleReoccurrenceAllSpendingSummary": "cycleReoccurrence",
  "cycleStartDateAllSpendingSummary": "customPeriodStartDate",
  "customPeriodStartDateAllSpendingSummary": "customPeriodStartDate",
  "customPeriodPastDaysAllSpendingSummary": "customPeriodPastDays",
};
