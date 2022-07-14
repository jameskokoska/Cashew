import 'dart:convert';

import 'package:animations/animations.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/autoTransactionsPage.dart';
import 'package:budget/pages/autoTransactionsPageEmail.dart';
import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/pages/onBoardingPage.dart';
import 'package:budget/pages/settingsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/defaultCategories.dart';
import 'package:budget/widgets/accountAndBackup.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './pages/homePage.dart';
import 'package:budget/colors.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/gestures.dart';

// Transaction transaction = widget.transaction.copyWith(skipPaid: false);

/*
adb tcpip 5555
adb connect 192.168.0.22

flutter channel master
flutter upgrade
*/

void main() async {
  database = await constructDb();
  entireAppLoaded = false;
  runApp(InitializeDatabase());
  // initNotificationListener();
}

Random random = new Random();
int randomInt = random.nextInt(100);
late bool entireAppLoaded;
String versionGlobal = "1.0";

Future<bool> updateSettings(setting, value,
    {List<int> pagesNeedingRefresh: const [],
    bool updateGlobalState = true}) async {
  final prefs = await SharedPreferences.getInstance();
  appStateSettings[setting] = value;
  await prefs.setString('userSettings', json.encode(appStateSettings));

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
  Map<String, dynamic> userPreferencesDefault = {
    "theme": "system",
    "selectedWallet": 0,
    "selectedSubscriptionType": 0,
    "accentColor": toHexString(Color(0xFF1B447A)),
    "showWalletSwitcher": true,
    "showCumulativeSpending": true,
    "askForTransactionTitle": true,
    "username": "",
    "AutoTransactions-canReadNotifs": false,
  };

  final prefs = await SharedPreferences.getInstance();
  String? userSettings = prefs.getString('userSettings');
  if (userSettings == null) {
    await prefs.setString('userSettings', json.encode(userPreferencesDefault));
    return userPreferencesDefault;
  } else {
    var userSettingsJSON = json.decode(userSettings);
    //Set to defaults if a new setting is added, but no entry saved
    userPreferencesDefault.forEach((key, value) {
      if (userSettingsJSON[key] == null) {
        userSettingsJSON[key] = userPreferencesDefault[key];
      }
    });
    return userSettingsJSON;
  }
}

Future<bool> initializeSettings() async {
  Map<String, dynamic> userSettings = await getUserSettings();
  appStateSettings = userSettings;

  //Sign in user before app launches to prepare for reading emails
  if (entireAppLoaded == false) {
    if (appStateSettings["AutoTransactions-canReadEmails"] == true) {
      if (user == null) {
        print("Signing in user for reading emails");
        await signInGoogle("", gMailPermissions: true, waitForCompletion: false)
            .timeout(Duration(milliseconds: 5000), onTimeout: () {
          return false;
        });
      }
    }
  }
  return true;
}

//Initialize default values in database
Future<bool> initializeDatabase() async {
  //Initialize default categories
  for (TransactionCategory category in defaultCategories()) {
    await database.createOrUpdateCategory(category);
  }
  await database.createOrUpdateWallet(
    TransactionWallet(
      walletPk: 0,
      name: "Wallet",
      dateCreated: DateTime.now(),
      order: 0,
      colour: toHexString(Colors.green),
    ),
  );
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: getSettingConstants(appStateSettings)["accentColor"],
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        applyElevationOverlayColor: false,
        typography: Typography.material2014(),
        canvasColor: Colors.white,
        fontFamily: 'Avenir',
        appBarTheme:
            AppBarTheme(systemOverlayStyle: SystemUiOverlayStyle.light),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: getSettingConstants(appStateSettings)["accentColor"],
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        typography: Typography.material2014(),
        canvasColor: Colors.black,
        fontFamily: 'Avenir',
        appBarTheme: AppBarTheme(systemOverlayStyle: SystemUiOverlayStyle.dark),
      ),
      scrollBehavior: ScrollBehavior(),
      themeMode: getSettingConstants(appStateSettings)["theme"],
      home: true
          ? OnBoardingPage()
          : PageNavigationFramework(key: pageNavigationFrameworkKey),
    );
  }
}

class ScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
