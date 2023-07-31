import 'dart:convert';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:flutter/scheduler.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/defaultPreferences.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/colors.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
      Map<String, dynamic> userPreferencesDefault =
          await getDefaultPreferences();
      userPreferencesDefault.forEach((key, value) {
        if (userSettings[key] == null) {
          userSettings[key] = userPreferencesDefault[key];
        }
      });
      updateSettings("databaseJustImported", false, updateGlobalState: false);
      print("Settings were restored");
    } catch (e) {
      print("Error restoring imported settings " + e.toString());
    }
  }

  appStateSettings = userSettings;

  packageInfoGlobal = await PackageInfo.fromPlatform();

  // Do some actions based on loaded settings

  appStateSettings["accentColor"] = await getAccentColorSystemString();

  if (appStateSettings["hasOnboarded"] == true) {
    updateSettings("numLogins", appStateSettings["numLogins"] + 1,
        updateGlobalState: false, pagesNeedingRefresh: []);
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

  Map<String, dynamic> defaultPreferences = await getDefaultPreferences();
  List<String> keyOrder = List<String>.from(
      appStateSettings["homePageOrder"].map((element) => element.toString()));
  List<String> defaultPrefPageOrder = List<String>.from(
      defaultPreferences["homePageOrder"].map((element) => element.toString()));
  for (String key in keyOrder) {
    if (!defaultPreferences["homePageOrder"].contains(key)) {
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
Future<bool> updateSettings(
  setting,
  value, {
  required bool updateGlobalState,
  List<int> pagesNeedingRefresh = const [],
  bool forceGlobalStateUpdate = false,
}) async {
  bool isChanged = appStateSettings[setting] != value;

  appStateSettings[setting] = value;
  await sharedPreferences.setString(
      'userSettings', json.encode(appStateSettings));

  if (updateGlobalState == true) {
    // Only refresh global state if the value is different
    if (isChanged || forceGlobalStateUpdate) {
      print("Rebuilt Main Request from: " +
          setting.toString() +
          " : " +
          value.toString());
      appStateKey.currentState?.refreshAppState();
    }
  } else {
    //Refresh any pages listed
    for (int page in pagesNeedingRefresh) {
      print("Pages Rebuilt and Refreshed: " + pagesNeedingRefresh.toString());
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
  }

  if (setting == "batterySaver" || setting == "materialYou") {
    generateColors();
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
  Map<String, dynamic> userPreferencesDefault = await getDefaultPreferences();

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
