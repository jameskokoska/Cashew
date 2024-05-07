import 'dart:convert';
import 'dart:developer';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/editHomePage.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry/transactionEntry.dart';
import 'package:budget/widgets/util/checkWidgetLaunch.dart';
import 'package:drift/isolate.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/defaultPreferences.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:budget/struct/languageMap.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/radioItems.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:budget/widgets/framework/popupFramework.dart';

Map<String, dynamic> appStateSettings = {};
bool isDatabaseCorrupted = false;
bool isDatabaseImportedOnThisSession = false;

Future<bool> initializeSettings() async {
  packageInfoGlobal = await PackageInfo.fromPlatform();

  Map<String, dynamic> userSettings = await getUserSettings();
  if (userSettings["databaseJustImported"] == true) {
    isDatabaseImportedOnThisSession = true;
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
        userSettings = attemptToMigrateCyclePreferences(userSettings, key);
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
      if (e is DriftRemoteException) {
        if (e.remoteCause
            .toString()
            .toLowerCase()
            .contains("file is not a database")) {
          isDatabaseCorrupted = true;
        }
      } else if (e
          .toString()
          .toLowerCase()
          .contains("file is not a database")) {
        isDatabaseCorrupted = true;
      }
    }
  }

  appStateSettings = userSettings;

  // Do some actions based on loaded settings
  if (appStateSettings["accentSystemColor"] == true) {
    appStateSettings["accentColor"] = await getAccentColorSystemString();
  }

  await attemptToMigrateSetLongTermLoansAmountTo0();
  attemptToMigrateCustomNumberFormattingSettings();

  // Disable sync every change is not on web
  // It will still sync when user pulls down to refresh
  // if (!kIsWeb) {
  //   appStateSettings["syncEveryChange"] = false;
  // }
  // Instead we now check for web with the setting appStateSettings["syncEveryChange"]

  // Load iOS font when iOS
  // Disable iOS font for now... Avenir looks better
  // if (getPlatform() == PlatformOS.isIOS) {
  //   // appStateSettings["font"] = "SFProText";
  //   appStateSettings["font"] = "Avenir";
  // }

  if (appStateSettings["hasOnboarded"] == true) {
    appStateSettings["numLogins"] = appStateSettings["numLogins"] + 1;
  }

  appStateSettings["appOpenedHour"] = DateTime.now().hour;
  appStateSettings["appOpenedMinute"] = DateTime.now().minute;

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

  Map<String, dynamic> defaultPreferences = await getDefaultPreferences();

  fixHomePageOrder(defaultPreferences, "homePageOrder");
  fixHomePageOrder(defaultPreferences, "homePageOrderFullScreen");

  // save settings
  await sharedPreferences.setString(
      'userSettings', json.encode(appStateSettings));

  try {
    globalCollapsedFutureID.value = (jsonDecode(
                sharedPreferences.getString("globalCollapsedFutureID") ?? "{}")
            as Map<String, dynamic>)
        .map((key, value) {
      return MapEntry(key, value is bool ? value : false);
    });
  } catch (e) {
    print("There was an error restoring globalCollapsedFutureID preference: " +
        e.toString());
  }

  return true;
}

// setAppStateSettings
Future<bool> updateSettings(
  String setting,
  value, {
  required bool updateGlobalState,
  List<int> pagesNeedingRefresh = const [],
  bool forceGlobalStateUpdate = false,
  bool setStateAllPageFrameworks = false,
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
    if (setStateAllPageFrameworks) {
      refreshPageFrameworks();
      // Since the transactions list page does not use PageFramework!
      transactionsListPageStateKey.currentState?.refreshState();
    }
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

  return true;
}

Map<String, dynamic> getSettingConstants(Map<String, dynamic> userSettings) {
  Map<String, dynamic> themeSetting = {
    "system": ThemeMode.system,
    "light": ThemeMode.light,
    "dark": ThemeMode.dark,
    "black": ThemeMode.dark,
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

    Map<String, dynamic> userSettingsJSON = json.decode(userSettings);

    //Set to defaults if a new setting is added, but no entry saved
    userPreferencesDefault.forEach((key, value) {
      userSettingsJSON =
          attemptToMigrateCyclePreferences(userSettingsJSON, key);
      if (userSettingsJSON[key] == null) {
        userSettingsJSON[key] = userPreferencesDefault[key];
      }
    });
    return userSettingsJSON;
  } catch (e) {
    print("There was an error, settings corrupted: " + e.toString());
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
  print(appStateSettings["locale"]);
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
              for (String localeKey in supportedLocales.keys) localeKey,
            ],
            initial: appStateSettings["locale"].toString(),
            displayFilter: languageDisplayFilter,
            onChanged: (value) async {
              if (value == "System") {
                context.resetLocale();
              } else {
                if (supportedLocales[value] != null)
                  context.setLocale(supportedLocales[value]!);
              }
              updateSettings(
                "locale",
                value,
                pagesNeedingRefresh: [3],
                updateGlobalState: false,
              );
              await Future.delayed(Duration(milliseconds: 50));
              initializeLocalizedMonthNames();
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
  const TranslationsHelp({
    super.key,
    this.showIcon = true,
    this.backgroundColor,
  });

  final bool showIcon;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: () {
        openUrl('mailto:dapperappdeveloper@gmail.com');
      },
      onLongPress: () {
        copyToClipboard("dapperappdeveloper@gmail.com");
      },
      color: backgroundColor ??
          Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.7),
      borderRadius: getPlatform() == PlatformOS.isIOS ? 10 : 15,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        child: Row(
          children: [
            if (showIcon)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  appStateSettings["outlinedIcons"]
                      ? Icons.connect_without_contact_outlined
                      : Icons.connect_without_contact_rounded,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 31,
                ),
              ),
            Expanded(
              child: TextFont(
                text: "",
                textColor: getColor(context, "black"),
                textAlign:
                    showIcon == true ? TextAlign.start : TextAlign.center,
                richTextSpan: [
                  TextSpan(
                    text: "translations-help".tr() + " ",
                    style: TextStyle(
                      color: getColor(context, "black"),
                      fontFamily: appStateSettings["font"],
                      fontFamilyFallback: ['Inter'],
                    ),
                  ),
                  TextSpan(
                    text: 'dapperappdeveloper@gmail.com',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      decorationStyle: TextDecorationStyle.solid,
                      decorationColor:
                          getColor(context, "unPaidOverdue").withOpacity(0.8),
                      color:
                          getColor(context, "unPaidOverdue").withOpacity(0.8),
                      fontFamily: appStateSettings["font"],
                      fontFamilyFallback: ['Inter'],
                    ),
                  ),
                ],
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
