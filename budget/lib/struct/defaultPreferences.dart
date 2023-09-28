import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/homePage/homePageLineGraph.dart';
import 'package:budget/pages/walletDetailsPage.dart';
import 'package:budget/widgets/notificationsSettings.dart';
import 'package:budget/widgets/periodCyclePicker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';

// default settings, defaultSettings, initial settings
Future<Map<String, dynamic>> getDefaultPreferences() async {
  int androidVersion = 11;
  if (getPlatform(ignoreEmulation: true) == PlatformOS.isAndroid) {
    androidVersion = 0;
    AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
    String androidVersionString = androidInfo.version.release;
    try {
      androidVersion = int.parse(androidVersionString);
    } catch (e) {}
  }
  return {
    "databaseJustImported": false,
    "backupLimit": 20,
    "backupSync": true,
    "syncEveryChange": kIsWeb,
    "devicesHaveBeenSynced": 1,
    "numBackups": 1,
    "theme": "system",
    "selectedWalletPk": "0",
    "selectedSubscriptionType": 0,
    "accentColor": toHexString(Color(0xFF1B447A)),
    "accentSystemColor": supportsSystemColor(),
    "showWalletSwitcher": true,
    "showPinnedBudgets": true,
    "showObjectives": false,
    "showAllSpendingSummary": false,
    "showNetWorth": false,
    "showOverdueUpcoming": false,
    "showCreditDebt": false,
    "showSpendingGraph": true,
    "showPieChart": false,
    "showHeatMap": false,
    "showUsernameWelcomeBanner": true,
    "homePageOrder": [
      "wallets",
      "budgets",
      "objectives",
      "allSpendingSummary",
      "netWorth",
      "overdueUpcoming",
      "creditDebts",
      "spendingGraph",
      "pieChart",
      "heatMap",
    ],
    "showTotalSpentForBudget": false,
    "showCumulativeSpending": true,
    "removeZeroTransactionEntries": true,
    "ignorePastAmountSpent": false,
    // "askForTransactionTitle": androidVersion > 10,
    "askForTransactionTitle": true,
    "askForTransactionNoteWithTitle": false,
    // "batterySaver": kIsWeb,
    "automaticallyPaySubscriptions": true,
    "batterySaver": false,
    "username": "",
    "hasOnboarded": false,
    "autoAddAssociatedTitles": true,
    "AutoTransactions-canReadEmails": false,
    "currencyIcon": "\$",
    "EmailAutoTransactions-amountOfEmails": 10,
    "autoBackups": true,
    "autoBackupsFrequency": 3, //in days
    "hasSignedIn": false,
    "lastBackup": DateTime.now().subtract(Duration(days: 1)).toString(),
    "lastLoginVersion": "",
    "numLogins": 0,
    "submittedFeedback": false,
    "canShowBackupReminderPopup": true,
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
    "lineGraphReferenceBudgetPk": null,
    "lineGraphDisplayType": LineGraphDisplay.Default30Days.index,
    "lineGraphStartDate": DateTime.now().toString(),
    "pieChartIsIncome": false,
    "netWorthSelectedWalletPks": null, // List<String>?
    "showPastSpendingTrajectory": false,
    "lastSynced": null,
    "font": "Avenir",
    "animationSpeed": 1.0,
    "sharedBudgets": false,
    "emailScanning": false,
    "emailScanningPullToRefresh": false,
    "massEditSelectedTransactions": false,
    "incognitoKeyboard": false,
    // the key is the budgetPk (in String!)
    // Should be of type Map<String,List<int>>
    "watchedCategoriesOnBudget": {},
    "iOSNavigation": false,
    "iOSEmulate": false,
    "expandedNavigationSidebar": true,
    "locale": "System",
    "disableShadows": false,
    "showBackupLimit": false,
    "outlinedIcons": false,
    "premiumPopupAddTransactionCount": -5,
    "premiumPopupAddTransactionLastShown": DateTime.now().toString(),
    "premiumPopupFreeSeen": false,
    "previewDemo": false,
    "purchaseID": null,
    // For showing information within a certain cycle
    "selectedPeriodCycleType": CycleType.allTime.index,
    "cyclePeriodLength": 1,
    "cycleReoccurrence": BudgetReoccurence.monthly.index,
    "cycleStartDate":
        DateTime(DateTime.now().year, DateTime.now().month, 1).toString(),
    "customPeriodStartDate":
        DateTime(DateTime.now().year, DateTime.now().month, 1).toString(),
    "customPeriodPastDays": 30,
  };
}
