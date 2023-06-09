import 'dart:convert';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/struct/keyboardIntents.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/util/initializeBiometrics.dart';
import 'package:budget/widgets/util/watchForDayChange.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/scheduler.dart';
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
import 'package:budget/widgets/util/scrollBehaviorOverride.dart';
import 'package:budget/widgets/globalSnackBar.dart';
import 'package:budget/widgets/initializeNotifications.dart';
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

Map<String, dynamic> appStateSettings = {};

Future<bool> initializeSettings() async {
  Map<String, dynamic> userSettings = await getUserSettings();
  if (userSettings["databaseJustImported"] == true) {
    try {
      print("Settings were loaded from backup, trying to restore");
      String storedSettings = (await database.getSettings()).settingsJSON;
      await sharedPreferences.setString('userSettings', storedSettings);
      print(storedSettings);
      userSettings = json.decode(storedSettings);
      //we need to load any defaults to migrate if on an older version backup restores
      //Set to defaults if a new setting is added, but no entry saved
      Map<String, dynamic> userPreferencesDefault = defaultPreferences();
      userPreferencesDefault.forEach((key, value) {
        if (userSettings[key] == null) {
          userSettings[key] = userPreferencesDefault[key];
        }
      });
      updateSettings("databaseJustImported", false);
      print("Settings were restored");
    } catch (e) {
      print("Error restoring imported settings " + e.toString());
    }
  }

  appStateSettings = userSettings;

  packageInfoGlobal = await PackageInfo.fromPlatform();

  // Do some actions based on loaded settings
  if (appStateSettings["accentSystemColor"] == true) {
    await SystemTheme.accentColor.load();
    Color accentColor = SystemTheme.accentColor.accent;
    appStateSettings["accentColor"] = toHexString(accentColor);
  }

  if (appStateSettings["cachedWalletCurrencies"] == null ||
      appStateSettings["cachedWalletCurrencies"].keys.length <= 0) {
    print("wallet cache is empty, need to add in values");
    await updateCachedWalletCurrencies();
  }

  String? retrievedClientID = await sharedPreferences.getString("clientID");
  if (retrievedClientID == null) {
    String systemID = await getDeviceInfo();
    String newClientID = systemID
            .substring(0, (systemID.length > 17 ? 17 : systemID.length))
            .replaceAll("-", "_") +
        "-" +
        DateTime.now().millisecondsSinceEpoch.toString();
    await sharedPreferences.setString('clientID', newClientID);
    clientID = newClientID;
  } else {
    clientID = retrievedClientID;
  }

  timeDilation = double.parse(appStateSettings["animationSpeed"].toString());

  generateColors();

  List<String> keyOrder = List<String>.from(
      appStateSettings["homePageOrder"].map((element) => element.toString()));
  List<String> defaultPrefPageOrder = List<String>.from(
      defaultPreferences()["homePageOrder"]
          .map((element) => element.toString()));
  for (String key in keyOrder) {
    if (!defaultPreferences()["homePageOrder"].contains(key)) {
      appStateSettings["homePageOrder"] = defaultPrefPageOrder;
      print("Fixed homepage ordering");
      break;
    }
  }
  for (String key in defaultPrefPageOrder) {
    if (!keyOrder.contains(key)) {
      appStateSettings["homePageOrder"] = defaultPrefPageOrder;
      print("Fixed homepage ordering");
      break;
    }
  }

  return true;
}

// setAppStateSettings
Future<bool> updateSettings(setting, value,
    {List<int> pagesNeedingRefresh = const [],
    bool updateGlobalState = true}) async {
  appStateSettings[setting] = value;
  await sharedPreferences.setString(
      'userSettings', json.encode(appStateSettings));
  if (updateGlobalState == true) appStateKey.currentState?.refreshAppState();
  //Refresh any pages listed
  for (int page in pagesNeedingRefresh) {
    if (page == 0) {
      homePageStateKey.currentState?.refreshState();
    } else if (page == 1) {
      transactionsListPageStateKey.currentState?.refreshState();
    } else if (page == 2) {
      budgetsListPageStateKey.currentState?.refreshState();
    } else if (page == 3) {
      settingsPageStateKey.currentState?.refreshState();
    }
  }

  return true;
}

Map<String, dynamic> getSettingConstants(Map<String, dynamic> userSettings) {
  Map<String, dynamic> themeSetting = {
    "system": ThemeMode.system,
    "light": ThemeMode.light,
    "dark": ThemeMode.dark,
  };

  Map<String, dynamic> userSettingsNew = {...userSettings};
  userSettingsNew["theme"] = themeSetting[userSettings["theme"]];
  userSettingsNew["accentColor"] = HexColor(userSettings["accentColor"]);
  return userSettingsNew;
}

Future<Map<String, dynamic>> getUserSettings() async {
  Map<String, dynamic> userPreferencesDefault = defaultPreferences();

  String? userSettings = sharedPreferences.getString('userSettings');
  try {
    if (userSettings == null) {
      throw ("no settings on file");
    }
    print("Found user settings on file");

    var userSettingsJSON = json.decode(userSettings);
    //Set to defaults if a new setting is added, but no entry saved
    userPreferencesDefault.forEach((key, value) {
      if (userSettingsJSON[key] == null) {
        userSettingsJSON[key] = userPreferencesDefault[key];
      }
    });
    return userSettingsJSON;
  } catch (e) {
    print("There was an error, settings corrupted");
    await sharedPreferences.setString(
        'userSettings', json.encode(userPreferencesDefault));
    return userPreferencesDefault;
  }
}
