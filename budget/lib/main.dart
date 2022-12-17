import 'dart:convert';
import 'dart:developer';

import 'package:animations/animations.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/autoTransactionsPageEmail.dart';
import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/pages/onBoardingPage.dart';
import 'package:budget/pages/settingsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/defaultCategories.dart';
import 'package:budget/struct/defaultPreferences.dart';
import 'package:budget/struct/notificationsGlobal.dart';
import 'package:budget/widgets/accountAndBackup.dart';
import 'package:budget/widgets/SelectedTransactionsActionBar.dart';
import 'package:budget/widgets/globalLoadingProgress.dart';
import 'package:budget/widgets/globalSnackBar.dart';
import 'package:budget/widgets/initializeNotifications.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/restartApp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './pages/homePage.dart';
import 'package:budget/colors.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/gestures.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:system_theme/system_theme.dart';
import 'package:firebase_core/firebase_core.dart';

// Transaction transaction = widget.transaction.copyWith(skipPaid: false);

/*
adb tcpip 5555
adb connect 192.168.0.22

flutter channel master
flutter upgrade

flutter build appbundle --release

firebase deploy
*/

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyBGiaRl72d4k3Ki0dh8ra-gU4v2z04CgIw",
        authDomain: "budget-app-flutter.firebaseapp.com",
        projectId: "budget-app-flutter",
        storageBucket: "budget-app-flutter.appspot.com",
        messagingSenderId: "267621253497",
        appId: "1:267621253497:web:12558fe9abebf7fa842fa8",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  database = await constructDb();
  notificationPayload = await initializeNotifications();
  entireAppLoaded = false;

  runApp(RestartApp(child: InitializeDatabase()));
}

Random random = new Random();
List<int> randomInt = [
  random.nextInt(100),
  random.nextInt(100),
  random.nextInt(100),
  random.nextInt(100),
  random.nextInt(100),
  random.nextInt(100),
  random.nextInt(100),
  random.nextInt(100),
  random.nextInt(100),
  random.nextInt(100)
];
List<double> randomDouble = [
  random.nextDouble(),
  random.nextDouble(),
  random.nextDouble(),
  random.nextDouble(),
  random.nextDouble(),
  random.nextDouble(),
  random.nextDouble(),
  random.nextDouble(),
  random.nextDouble(),
  random.nextDouble()
];
late bool entireAppLoaded;
late PackageInfo packageInfoGlobal;

// setAppStateSettings
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
  Map<String, dynamic> userPreferencesDefault = defaultPreferences();

  final prefs = await SharedPreferences.getInstance();
  String? userSettings = prefs.getString('userSettings');

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
    await prefs.setString('userSettings', json.encode(userPreferencesDefault));
    return userPreferencesDefault;
  }
}

Future<bool> initializeSettings() async {
  Map<String, dynamic> userSettings = await getUserSettings();
  if (userSettings["databaseJustImported"] == true) {
    try {
      print("Settings were loaded from backup, trying to restore");
      String storedSettings = (await database.getSettings()).settingsJSON;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userSettings', storedSettings);
      print(storedSettings);
      userSettings = json.decode(storedSettings);
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

  return true;
}

//Initialize default values in database
Future<bool> initializeDatabase() async {
  //Initialize default categories
  if ((await database.getAllCategories()).length <= 0) {
    for (TransactionCategory category in defaultCategories()) {
      await database.createOrUpdateCategory(category);
    }
  }
  if ((await database.getAllWallets()).length <= 0) {
    await database.createOrUpdateWallet(
      TransactionWallet(
        walletPk: 0,
        name: "Wallet",
        dateCreated: DateTime.now(),
        order: 0,
        colour: toHexString(Colors.green),
      ),
    );
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
        Widget child = SizedBox.shrink();

        if (snapshot.hasData || entireAppLoaded == true) {
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
        debugPrint("Initializing Settings");
        Widget child = SizedBox(
          height: 50,
          width: 50,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.secondary),
          ),
        );
        if (snapshot.hasData || entireAppLoaded == true) {
          debugPrint("Initialized Settings");
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

class EscapeIntent extends Intent {
  const EscapeIntent();
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      shortcuts: <ShortcutActivator, Intent>{
        LogicalKeySet(LogicalKeyboardKey.escape): const EscapeIntent(),
      },
      actions: <Type, Action<Intent>>{
        EscapeIntent: CallbackAction<EscapeIntent>(
          onInvoke: (EscapeIntent intent) => {
            if (navigatorKey.currentState!.canPop())
              navigatorKey.currentState!.pop()
          },
        ),
      },
      key: ValueKey(1),
      title: 'Budget App',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: getSettingConstants(appStateSettings)["accentColor"],
          brightness: Brightness.light,
          background: appStateSettings["materialYou"]
              ? lightenPastel(
                  getSettingConstants(appStateSettings)["accentColor"],
                  amount: 0.91)
              : Colors.white,
        ),
        useMaterial3: true,
        applyElevationOverlayColor: false,
        typography: Typography.material2014(),
        canvasColor: Colors.white,
        appBarTheme:
            AppBarTheme(systemOverlayStyle: SystemUiOverlayStyle.light),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: getSettingConstants(appStateSettings)["accentColor"],
          brightness: Brightness.dark,
          background: appStateSettings["materialYou"]
              ? darkenPastel(
                  getSettingConstants(appStateSettings)["accentColor"],
                  amount: 0.92)
              : Colors.black,
        ),
        useMaterial3: true,
        typography: Typography.material2014(),
        canvasColor: Colors.black,
        appBarTheme: AppBarTheme(systemOverlayStyle: SystemUiOverlayStyle.dark),
      ),
      scrollBehavior: ScrollBehavior(),
      themeMode: getSettingConstants(appStateSettings)["theme"],
      home: SafeArea(
        top: false,
        child: appStateSettings["hasOnboarded"] != true
            ? OnBoardingPage()
            : PageNavigationFramework(key: pageNavigationFrameworkKey),
      ),
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            // The persistent global Widget stack (stays on navigation change)
            GlobalSnackbar(key: snackbarKey),
            GlobalLoadingProgress(key: loadingProgressKey),
          ],
        );
      },
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
