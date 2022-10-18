import 'package:budget/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Map<String, dynamic> defaultPreferences() {
  return {
    "databaseJustImported": false,
    "backupLimit": 10,
    "theme": "system",
    "selectedWallet": 0,
    "selectedSubscriptionType": 0,
    "accentColor": toHexString(Color(0xFF1B447A)),
    "showWalletSwitcher": true,
    "showOverdueUpcoming": true,
    "showTotalSpentForBudget": false,
    "roundedGraphLines": true,
    "showCumulativeSpending": true,
    "removeZeroTransactionEntries": false,
    "askForTransactionTitle": true,
    "batterySaver": kIsWeb,
    "username": "",
    "hasOnboarded": false,
    "autoAddAssociatedTitles": true,
    "AutoTransactions-canReadEmails": false,
    "currencyIcon": "\$",
    "EmailAutoTransactions-setWallet": 0,
    "EmailAutoTransactions-defaultCategory": 0,
    "EmailAutoTransactions-amountOfEmails": 10,
    "autoBackups": true,
    "lastBackup": DateTime.now().subtract(Duration(days: 1)).toString(),
    "lastLoginVersion": "",
    "notifications": true,
  };
}
