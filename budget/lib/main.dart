import 'dart:convert';
import 'package:budget/functions.dart';
import 'package:budget/struct/keyboardIntents.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/util/initializeBiometrics.dart';
import 'package:budget/widgets/util/watchForDayChange.dart';
import 'package:budget/widgets/watchAllWallets.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:local_auth/local_auth.dart';
import 'package:animations/animations.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/pages/onBoardingPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/database/initializeDatabase.dart';
import 'package:budget/struct/defaultCategories.dart';
import 'package:budget/struct/defaultPreferences.dart';
import 'package:budget/struct/notificationsGlobal.dart';
import 'package:budget/widgets/breathingAnimation.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/globalLoadingProgress.dart';
import 'package:budget/widgets/util/scrollBehaviorOverride.dart';
import 'package:budget/widgets/globalSnackBar.dart';
import 'package:budget/widgets/util/initializeNotifications.dart';
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
import 'package:flutter/scheduler.dart' show SchedulerBinding, timeDilation;
import 'package:device_preview/device_preview.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Transaction transaction = widget.transaction.copyWith(skipPaid: false);

/*
adb tcpip 5555
adb connect 192.168.0.22

flutter channel master
flutter upgrade

flutter build appbundle --release

firebase deploy

"dart.lineLength": 150,
*/

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  sharedPreferences = await SharedPreferences.getInstance();
  database = await constructDb('db');
  notificationPayload = await initializeNotifications();
  entireAppLoaded = false;
  currenciesJSON = await json.decode(
      await rootBundle.loadString('assets/static/generated/currencies.json'));
  await initializeDatabase();
  await initializeSettings();
  tz.initializeTimeZones();
  final String? locationName = await FlutterNativeTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(locationName ?? "America/New_York"));
  runApp(
    DevicePreview(
      enabled: false,
      builder: (context) =>
          RestartApp(child: InitializeApp(key: appStateKey)), // Wrap your app
    ),
  );
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

GlobalKey<_InitializeAppState> appStateKey = GlobalKey();
GlobalKey<PageNavigationFrameworkState> pageNavigationFrameworkKey =
    GlobalKey();

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

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return
        // FeatureDiscovery(
        //   child:

        MaterialApp(
      locale: DevicePreview.locale(context),
      shortcuts: shortcuts,
      actions: keyboardIntents,
      themeAnimationDuration: Duration(milliseconds: 700),
      key: ValueKey(1),
      title: 'Cashew',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        pageTransitionsTheme: PageTransitionsTheme(builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        }),
        fontFamily: appStateSettings["font"],
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
                        amount: 0.8),
                    amount: 0.2)
                .withOpacity(0.5)
            : null,
        extensions: <ThemeExtension<dynamic>>[appColorsLight],
      ),
      darkTheme: ThemeData(
        pageTransitionsTheme: PageTransitionsTheme(builders: {
          // the page route animation is set in pushRoute() - functions.dart
          TargetPlatform.android: appStateSettings["iOSNavigation"]
              ? CupertinoPageTransitionsBuilder()
              : ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        }),
        fontFamily: appStateSettings["font"],
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
        splashColor: getPlatform() == PlatformOS.isIOS
            ? Colors.transparent
            : appStateSettings["materialYou"]
                ? darkenPastel(
                        lightenPastel(
                            getSettingConstants(
                                appStateSettings)["accentColor"],
                            amount: 0.86),
                        amount: 0.1)
                    .withOpacity(0.2)
                : null,
        extensions: <ThemeExtension<dynamic>>[appColorsDark],
      ),
      scrollBehavior: ScrollBehaviorOverride(),
      themeMode: getSettingConstants(appStateSettings)["theme"],
      home: AnimatedSwitcher(
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
      builder: (context, child) {
        Widget mainWidget = InitializeBiometrics(
          child: WatchForDayChange(
            child: WatchAllWallets(
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
            ),
          ),
        );
        if (kIsWeb) {
          return FadeIn(
              duration: Duration(milliseconds: 1000), child: mainWidget);
        } else {
          return mainWidget;
        }
      },
      // ),
    );
  }
}
