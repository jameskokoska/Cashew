import 'dart:convert';

import 'package:animations/animations.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/pages/settingsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/defaultCategories.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/books/v1.dart';
import './pages/homePage.dart';
import 'package:budget/colors.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  database = await constructDb();
  runApp(InitializeDatabase());
}

final int randomInt = Random().nextInt(100);

Future<bool> updateSettings(setting, value,
    {List<int> pagesNeedingRefresh: const []}) async {
  final prefs = await SharedPreferences.getInstance();
  appStateSettings[setting] = value;
  await prefs.setString('userSettings', json.encode(appStateSettings));

  appStateKey.currentState?.refreshAppState();
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
  Map<String, dynamic> userPreferencesDefault = {
    "theme": "system",
    "selectedWallet": 0,
    "accentColor": toHexString(Color(0xFF1B447A)),
  };

  final prefs = await SharedPreferences.getInstance();
  String? userSettings = prefs.getString('userSettings');
  if (userSettings == null) {
    await prefs.setString('userSettings', json.encode(userPreferencesDefault));
    return userPreferencesDefault;
  } else {
    return json.decode(userSettings);
  }
}

Future<bool> initializeSettings() async {
  Map<String, dynamic> userSettings = await getUserSettings();
  appStateSettings = userSettings;
  return true;
}

//Initialize default values in database
Future<bool> initializeDatabase() async {
  //Initialize default categories
  for (var category in defaultCategories()) {
    await database.createOrUpdateCategory(category);
  }
  return true;
}

class InitializeDatabase extends StatelessWidget {
  const InitializeDatabase({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initializeDatabase(),
      builder: (context, snapshot) {
        debugPrint("Initialized Database");
        Widget child = Container(
          key: ValueKey(0),
          width: 50,
          height: 50,
          color: Color(0xFF912937),
        );
        if (snapshot.hasData) {
          child = InitializeApp(
            key: appStateKey,
          );
        }
        return child;
      },
    );
  }
}

GlobalKey<_InitializeAppState> appStateKey = GlobalKey();
GlobalKey<PageNavigationFrameworkState> pageNavigationFrameworkKey =
    GlobalKey();

Map<String, dynamic> appStateSettings = {};

class InitializeApp extends StatefulWidget {
  InitializeApp({Key? key}) : super(key: key);

  @override
  State<InitializeApp> createState() => _InitializeAppState();
}

class _InitializeAppState extends State<InitializeApp> {
  void refreshAppState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initializeSettings(),
      builder: (context, snapshot) {
        debugPrint("Initialized Settings");
        Widget child = Container(
          key: ValueKey(0),
          width: 50,
          height: 50,
          color: Colors.blueGrey,
        );
        if (snapshot.hasData) {
          child = App();
        }
        return AnimatedSwitcher(
          duration: Duration(milliseconds: 500),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeScaleTransition(animation: animation, child: child);
          },
          child: child,
        );
      },
    );
  }
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: ValueKey(1),
      title: 'Budget App',
      theme: ThemeData(
        fontFamily: 'Avenir',
        primaryColor: Colors.white,
        primaryColorDark: Colors.grey[200],
        primaryColorLight: Colors.grey[100],
        primaryColorBrightness: Brightness.light,
        brightness: Brightness.light,
        canvasColor: Colors.grey[100],
        accentColor: getSettingConstants(appStateSettings)["accentColor"],
        appBarTheme:
            AppBarTheme(systemOverlayStyle: SystemUiOverlayStyle.light),
      ),
      darkTheme: ThemeData(
        fontFamily: 'Avenir',
        primaryColor: Colors.black,
        primaryColorDark: Colors.grey[800],
        primaryColorBrightness: Brightness.dark,
        primaryColorLight: Colors.grey[850],
        brightness: Brightness.dark,
        indicatorColor: Colors.white,
        canvasColor: Colors.black,
        accentColor: getSettingConstants(appStateSettings)["accentColor"],
        appBarTheme: AppBarTheme(systemOverlayStyle: SystemUiOverlayStyle.dark),
      ),
      themeMode: getSettingConstants(appStateSettings)["theme"],
      home: PageNavigationFramework(key: pageNavigationFrameworkKey),
    );
  }
}
