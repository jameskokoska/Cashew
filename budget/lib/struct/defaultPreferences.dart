import 'package:budget/colors.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/homePage/homePageLineGraph.dart';
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
    "showAllSpendingSummary": false,
    "showOverdueUpcoming": false,
    "showCreditDebt": false,
    "showSpendingGraph": true,
    "showHeatMap": false,
    "homePageOrder": [
      "wallets",
      "budgets",
      "allSpendingSummary",
      "overdueUpcoming",
      "creditDebts",
      "spendingGraph",
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
    "notifications": true,
    "notificationHour": 20,
    "notificationMinute": 0,
    "notificationsUpcomingTransactions": true,
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
    "locale": "System",
    "incomeExpenseStartDate": null,
    "disableShadows": false,
    "showBackupLimit": false,
    "premiumPopupAddTransactionCount": -5,
    "premiumPopupAddTransactionLastShown": DateTime.now().toString(),
    "premiumPopupFreeSeen": false,
    "previewDemo": false,
    "purchaseID": null,
  };
}
