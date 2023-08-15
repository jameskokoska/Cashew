import 'dart:convert';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/defaultPreferences.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/colors.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:budget/struct/languageMap.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/radioItems.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:budget/widgets/framework/popupFramework.dart';

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
      // Always reset the language/locale when restoring a backup
      userSettings["locale"] = "System";
      userSettings["databaseJustImported"] = false;
      print("Settings were restored");
    } catch (e) {
      print("Error restoring imported settings " + e.toString());
    }
  }

  appStateSettings = userSettings;

  packageInfoGlobal = await PackageInfo.fromPlatform();

  // Do some actions based on loaded settings

  appStateSettings["accentColor"] = await getAccentColorSystemString();

  // Disable sync every change is not on web
  // It will still sync when user pulls down to refresh
  if (!kIsWeb) {
    appStateSettings["syncEveryChange"] = false;
  }

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
        settingsPageFrameworkStateKey.currentState?.refreshState();
        purchasesStateKey.currentState?.refreshState();
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

// Returns the name of the language given a key, if key is System will return system translated label
String languageDisplayFilter(String languageKey) {
  if (languageNamesJSON[languageKey] != null) {
    return languageNamesJSON[languageKey].toString().capitalizeFirstofEach;
  }
  // if (supportedLanguagesSet.contains(item))
  //   return supportedLanguagesSet[item];
  if (languageKey == "System") return "system".tr();
  return languageKey;
}

void openLanguagePicker(BuildContext context) {
  openBottomSheet(
    context,
    PopupFramework(
      title: "language".tr(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: TranslationsHelp(),
          ),
          RadioItems(
            items: [
              "System",
              for (String languageCode in supportedLanguagesSet) languageCode,
            ],
            initial: appStateSettings["locale"].toString(),
            displayFilter: languageDisplayFilter,
            onChanged: (value) async {
              if (value == "System") {
                context.resetLocale();
              } else {
                context.setLocale(Locale(value));
              }
              updateSettings(
                "locale",
                value,
                pagesNeedingRefresh: [3],
                updateGlobalState: false,
              );
              await Future.delayed(Duration(milliseconds: 50));
              Navigator.pop(context);
            },
          ),
        ],
      ),
    ),
  );
}

void resetLanguageToSystem(BuildContext context) {
  if (appStateSettings["locale"].toString() == "System") return;
  context.resetLocale();
  updateSettings(
    "locale",
    "System",
    pagesNeedingRefresh: [],
    updateGlobalState: false,
  );
}

class TranslationsHelp extends StatelessWidget {
  const TranslationsHelp({super.key});

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: () {
        openUrl('mailto:dapperappdeveloper@gmail.com');
      },
      color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.7),
      borderRadius: getPlatform() == PlatformOS.isIOS ? 10 : 15,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                Icons.connect_without_contact_rounded,
                color: Theme.of(context).colorScheme.secondary,
                size: 31,
              ),
            ),
            Expanded(
              child: TextFont(
                textColor: Theme.of(context).colorScheme.onSecondaryContainer,
                richTextSpan: [
                  TextSpan(
                    text: 'dapperappdeveloper@gmail.com',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      decorationStyle: TextDecorationStyle.solid,
                      decorationColor:
                          getColor(context, "unPaidOverdue").withOpacity(0.8),
                      color:
                          getColor(context, "unPaidOverdue").withOpacity(0.8),
                    ),
                  ),
                ],
                text: "translations-help".tr() + " ",
                maxLines: 5,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
