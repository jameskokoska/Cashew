import 'package:budget/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// default settings, defaultSettings
Map<String, dynamic> defaultPreferences() {
  return {
    "databaseJustImported": false,
    "backupLimit": 10,
    "theme": "system",
    "selectedWallet": 0,
    "selectedWalletCurrency": "usd",
    "selectedSubscriptionType": 0,
    "accentColor": toHexString(Color(0xFF1B447A)),
    "accentSystemColor": true,
    "showWalletSwitcher": true,
    "showOverdueUpcoming": true,
    "showTotalSpentForBudget": false,
    "roundedGraphLines": true,
    "showCumulativeSpending": true,
    "removeZeroTransactionEntries": true,
    "askForTransactionTitle": true,
    // "batterySaver": kIsWeb,
    "batterySaver": false,
    "username": "",
    "hasOnboarded": false,
    "autoAddAssociatedTitles": true,
    "AutoTransactions-canReadEmails": false,
    "currencyIcon": "\$",
    "EmailAutoTransactions-amountOfEmails": 10,
    "autoBackups": false,
    "autoBackupsFrequency": 3, //in days
    "hasSignedInOnce": false,
    "lastBackup": DateTime.now().subtract(Duration(days: 1)).toString(),
    "lastLoginVersion": "",
    "notifications": true,
    "notificationHour": 20,
    "notificationMinute": 0,
    "notificationsUpcomingTransactions": true,
    "notificationHourUpcomingTransactions": 11,
    "notificationMinuteUpcomingTransactions": 0,
    "materialYou": false,
    "sendTransactionsToServerQueue": {},
    "currentUserEmail": "",
    "usersNicknames": {},
    "requireAuth": false,
    // cachedWalletCurrencies:
    // Note: walletPk is a string
    // {"walletPk": "currency", "231435":"usd",...}
    "cachedWalletCurrencies": {},
    "cachedCurrencyExchange": {},
    "lineGraphReferenceBudgetPk": null,
    "showPastSpendingTrajectory": false,
  };
}
