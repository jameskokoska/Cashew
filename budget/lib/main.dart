import 'dart:convert';
import 'package:budget/functions.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:local_auth/local_auth.dart';
import 'package:animations/animations.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/pages/onBoardingPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/defaultCategories.dart';
import 'package:budget/struct/defaultPreferences.dart';
import 'package:budget/struct/notificationsGlobal.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/globalLoadingProgress.dart';
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
    try {
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
    } catch (e) {
      print("Error initializing Firebase");
      print(e.toString());
      Firebase.app();
    }
  } else {
    await Firebase.initializeApp();
  }
  sharedPreferences = await SharedPreferences.getInstance();
  database = await constructDb('db');
  notificationPayload = await initializeNotifications();
  entireAppLoaded = false;
  await initializeDatabase();
  await initializeSettings();

  runApp(RestartApp(child: InitializeApp(key: appStateKey)));
}

late Map<String, dynamic> currenciesJSON;
bool biometricsAvailable = false;
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

Future<bool> updateCachedWalletCurrencies() async {
  List<TransactionWallet> wallets = await database.getAllWallets();
  for (TransactionWallet wallet in wallets) {
    if (wallet.currency == null)
      await database.createOrUpdateWallet(
        wallet.copyWith(currency: Value("usd")),
      );
    else
      await database.createOrUpdateWallet(
        wallet,
      );
  }
  return true;
}

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
  // print(await rootBundle.loadString('assets/static/generated/currencies.json'));
  currenciesJSON = await json.decode(
      await rootBundle.loadString('assets/static/generated/currencies.json'));

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
        currency: "usd",
        dateTimeModified: null,
      ),
      customDateTimeModified: DateTime(0),
    );
  }
  return true;
}

Future<bool> checkBiometrics() async {
  if (kIsWeb) return true;
  final LocalAuthentication auth = LocalAuthentication();
  final bool requireAuth = appStateSettings["requireAuth"];
  biometricsAvailable = kIsWeb == false && await auth.canCheckBiometrics ||
      await auth.isDeviceSupported();
  bool didAuthenticate = false;
  if (requireAuth == true && biometricsAvailable == true) {
    didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to continue.',
        options: const AuthenticationOptions(biometricOnly: true));
  } else {
    didAuthenticate = true;
  }
  return didAuthenticate;
}

class InitializeBiometrics extends StatefulWidget {
  final Widget child;
  const InitializeBiometrics({required this.child, super.key});

  @override
  State<InitializeBiometrics> createState() => _InitializeBiometricsState();
}

class _InitializeBiometricsState extends State<InitializeBiometrics> {
  bool? authenticated;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      final bool result = await checkBiometrics();
      setState(() {
        authenticated = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (appStateSettings["requireAuth"] == false) {
      return widget.child;
    }
    Widget child = Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        key: ValueKey(0),
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: GestureDetector(
              onTap: () async {
                setState(() {
                  authenticated = null;
                });
                final bool result = await checkBiometrics();
                setState(() {
                  authenticated = result;
                });
              },
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeScaleTransition(
                      animation: animation, child: child);
                },
                child: authenticated == false
                    ? Icon(
                        Icons.lock,
                        size: 50,
                        color: Theme.of(context).colorScheme.secondary,
                      )
                    : SizedBox.shrink(),
              ),
            ),
          )
        ],
      ),
    );
    if (authenticated == true) {
      child = SizedBox(key: ValueKey(1), child: widget.child);
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
    return App(key: ValueKey("Main App"));
  }
}

class EscapeIntent extends Intent {
  const EscapeIntent();
}

class Digit1Intent extends Intent {
  const Digit1Intent();
}

class Digit2Intent extends Intent {
  const Digit2Intent();
}

class Digit3Intent extends Intent {
  const Digit3Intent();
}

class Digit4Intent extends Intent {
  const Digit4Intent();
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      shortcuts: <ShortcutActivator, Intent>{
        LogicalKeySet(LogicalKeyboardKey.escape): const EscapeIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit1):
            const Digit1Intent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit2):
            const Digit2Intent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit3):
            const Digit3Intent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit4):
            const Digit4Intent(),
      },
      actions: <Type, Action<Intent>>{
        EscapeIntent: CallbackAction<EscapeIntent>(
          onInvoke: (EscapeIntent intent) => {
            if (navigatorKey.currentState!.canPop())
              navigatorKey.currentState!.pop()
            else
              pageNavigationFrameworkKey.currentState!
                  .changePage(0, switchNavbar: true)
          },
        ),
        Digit1Intent: CallbackAction<Digit1Intent>(
          onInvoke: (Digit1Intent intent) => {
            // we are on the root of navigation pages
            if (!navigatorKey.currentState!.canPop())
              pageNavigationFrameworkKey.currentState!
                  .changePage(0, switchNavbar: true)
          },
        ),
        Digit2Intent: CallbackAction<Digit2Intent>(
          onInvoke: (Digit2Intent intent) => {
            // we are on the root of navigation pages
            if (!navigatorKey.currentState!.canPop())
              pageNavigationFrameworkKey.currentState!
                  .changePage(1, switchNavbar: true)
          },
        ),
        Digit3Intent: CallbackAction<Digit3Intent>(
          onInvoke: (Digit3Intent intent) => {
            // we are on the root of navigation pages
            if (!navigatorKey.currentState!.canPop())
              pageNavigationFrameworkKey.currentState!
                  .changePage(2, switchNavbar: true)
          },
        ),
        Digit4Intent: CallbackAction<Digit4Intent>(
          onInvoke: (Digit4Intent intent) => {
            // we are on the root of navigation pages
            if (!navigatorKey.currentState!.canPop())
              pageNavigationFrameworkKey.currentState!
                  .changePage(3, switchNavbar: true)
          },
        ),
      },
      key: ValueKey(1),
      title: 'Cashew',
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
        canvasColor: appStateSettings["materialYou"]
            ? lightenPastel(
                getSettingConstants(appStateSettings)["accentColor"],
                amount: 0.91)
            : Colors.white,
        appBarTheme:
            AppBarTheme(systemOverlayStyle: SystemUiOverlayStyle.light),
        splashColor: appStateSettings["materialYou"]
            ? darkenPastel(
                    lightenPastel(
                        getSettingConstants(appStateSettings)["accentColor"],
                        amount: 0.56),
                    amount: 0.1)
                .withOpacity(0.5)
            : null,
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
        canvasColor: appStateSettings["materialYou"]
            ? darkenPastel(getSettingConstants(appStateSettings)["accentColor"],
                amount: 0.92)
            : Colors.black,
        appBarTheme: AppBarTheme(systemOverlayStyle: SystemUiOverlayStyle.dark),
        splashColor: appStateSettings["materialYou"]
            ? darkenPastel(
                    lightenPastel(
                        getSettingConstants(appStateSettings)["accentColor"],
                        amount: 0.86),
                    amount: 0.1)
                .withOpacity(0.2)
            : null,
      ),
      scrollBehavior: ScrollBehavior(),
      themeMode: getSettingConstants(appStateSettings)["theme"],
      home: SafeArea(
        top: false,
        child: AnimatedSwitcher(
            duration: Duration(milliseconds: 1200),
            switchInCurve: Curves.easeInOutCubic,
            switchOutCurve: Curves.easeInOutCubic,
            transitionBuilder: (Widget child, Animation<double> animation) {
              final inAnimation =
                  Tween<Offset>(begin: Offset(-1.0, 0.0), end: Offset(0.0, 0.0))
                      .animate(animation);
              final outAnimation =
                  Tween<Offset>(begin: Offset(1.0, 0.0), end: Offset(0.0, 0.0))
                      .animate(animation);

              if (child.key == ValueKey("Onboarding")) {
                return ClipRect(
                  child: SlideTransition(
                    position: inAnimation,
                    child: child,
                  ),
                );
              } else {
                return ClipRect(
                  child: SlideTransition(position: outAnimation, child: child),
                );
              }
            },
            child: appStateSettings["hasOnboarded"] != true
                ? OnBoardingPage(key: ValueKey("Onboarding"))
                : PageNavigationFramework(key: pageNavigationFrameworkKey)),
      ),
      builder: (context, child) {
        return InitializeBiometrics(
          child: Stack(
            children: [
              Row(
                children: [
                  SizedBox(width: getWidthNavigationSidebar(context)),
                  Expanded(
                    child: child!,
                  ),
                ],
              ),
              NavigationSidebar(
                key: sidebarStateKey,
              ),
              // The persistent global Widget stack (stays on navigation change)
              GlobalSnackbar(key: snackbarKey),
              GlobalLoadingProgress(key: loadingProgressKey),
              GlobalLoadingIndeterminate(key: loadingIndeterminateKey)
            ],
          ),
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
