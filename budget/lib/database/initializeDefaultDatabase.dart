import 'dart:convert';
import 'package:budget/functions.dart';
import 'package:budget/struct/keyboardIntents.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/struct/initializeBiometrics.dart';
import 'package:budget/widgets/util/watchForDayChange.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:easy_localization/easy_localization.dart';
import 'package:local_auth/local_auth.dart';
import 'package:animations/animations.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/pages/onBoardingPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/defaultCategories.dart';
import 'package:budget/struct/defaultPreferences.dart';
import 'package:budget/struct/notificationsGlobal.dart';
import 'package:budget/widgets/breathingAnimation.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/globalLoadingProgress.dart';
import 'package:budget/struct/scrollBehaviorOverride.dart';
import 'package:budget/widgets/globalSnackBar.dart';
import 'package:budget/struct/initializeNotifications.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/restartApp.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:budget/colors.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/gestures.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:system_theme/system_theme.dart';
import 'package:firebase_core/firebase_core.dart';

//Initialize default values in database
Future<bool> initializeDefaultDatabase() async {
  //Initialize default categories
  if ((await database.getAllCategories()).length <= 0) {
    for (TransactionCategory category in defaultCategories()) {
      await database.createOrUpdateCategory(category,
          customDateTimeModified: DateTime(0));
    }
  }
  if ((await database.getAllWallets()).length <= 0) {
    await database.createOrUpdateWallet(
      TransactionWallet(
        walletPk: 0,
        name: "default-wallet-name".tr(),
        dateCreated: DateTime.now(),
        order: 0,
        currency: getDevicesDefaultCurrencyCode(),
        dateTimeModified: null,
        decimals: 2,
      ),
      customDateTimeModified: DateTime(0),
    );
  }
  return true;
}
