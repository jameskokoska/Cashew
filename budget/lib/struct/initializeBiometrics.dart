import 'package:animations/animations.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/breathingAnimation.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

enum AuthResult {
  waiting,
  authenticated,
  unauthenticated,
  error,
  errorBackupRestoreLaunch,
}

bool authAvailable = false;

Future<AuthResult> checkBiometrics({
  bool checkAlways = false,
}) async {
  try {
    if (kIsWeb) {
      authAvailable = false;
      await updateSettings("requireAuth", false, updateGlobalState: false);
      return AuthResult.authenticated;
    }

    final LocalAuthentication auth = LocalAuthentication();
    authAvailable =
        await auth.isDeviceSupported() || await auth.canCheckBiometrics;

    final bool requireAuth =
        checkAlways || appStateSettings["requireAuth"] == true;
    if (requireAuth == false) return AuthResult.authenticated;

    await auth.stopAuthentication();

    if (authAvailable) {
      //bool biometricsOnly = (await auth.canCheckBiometrics);
      return (await auth.authenticate(
        localizedReason: "verify-identity".tr(),
        options: AuthenticationOptions(biometricOnly: false),
      ))
          ? AuthResult.authenticated
          : AuthResult.unauthenticated;
    }

    return isDatabaseImportedOnThisSession
        ? AuthResult.errorBackupRestoreLaunch
        : AuthResult.error;
  } catch (e) {
    return isDatabaseImportedOnThisSession
        ? AuthResult.errorBackupRestoreLaunch
        : AuthResult.error;
  }
}

class InitializeBiometrics extends StatefulWidget {
  final Widget child;
  const InitializeBiometrics({required this.child, super.key});

  @override
  State<InitializeBiometrics> createState() => _InitializeBiometricsState();
}

class _InitializeBiometricsState extends State<InitializeBiometrics> {
  AuthResult authResult = AuthResult.waiting;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      _biometricCheck();
    });
  }

  _biometricCheck() async {
    AuthResult result = await checkBiometrics();
    setState(() {
      authResult = result;
    });
    if (authResult == AuthResult.errorBackupRestoreLaunch) {
      // Allow bypass on initial backup restore launch
      _biometricErrorPopup();
      setState(() {
        authResult = AuthResult.authenticated;
      });
    }
  }

  _biometricErrorPopup() {
    // Wait so that we get a context on the navigatorKey
    // Since Initialize biometrics does not have access to Material navigator in the widget tree
    // because we want to keep the app fully locked
    Future.delayed(Duration(milliseconds: 500), () {
      openPopup(
        null,
        barrierDismissible: false,
        icon: appStateSettings["outlinedIcons"]
            ? Icons.warning_outlined
            : Icons.warning_rounded,
        title: "biometrics-error".tr(),
        description: "biometrics-error-description".tr(),
        onSubmitLabel: "ok".tr(),
        onSubmit: () {
          updateSettings("requireAuth", false, updateGlobalState: false);
          popRoute(null);
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (appStateSettings["requireAuth"] == false) {
      return widget.child;
    }
    Widget child = Scaffold(
      resizeToAvoidBottomInset: false,
      body: Tappable(
        onTap: () async {
          setState(() {
            authResult = AuthResult.waiting;
          });
          _biometricCheck();
        },
        child: Column(
          key: ValueKey(0),
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BreathingWidget(
              child: Center(
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 500),
                  switchInCurve: Curves.easeInOut,
                  switchOutCurve: Curves.easeInOut,
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return FadeScaleTransition(
                        animation: animation, child: child);
                  },
                  child: authResult != AuthResult.waiting
                      ? Icon(
                          Icons.lock,
                          size: 50,
                          color: Theme.of(context).colorScheme.secondary,
                        )
                      : SizedBox.shrink(),
                ),
              ),
            ),
            AnimatedExpanded(
              expand: authResult == AuthResult.error ||
                  authResult == AuthResult.errorBackupRestoreLaunch,
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: 18, vertical: 20),
                child: TextFont(
                  text: "biometrics-error-description".tr() +
                      "\n" +
                      "please-check-your-system-settings".tr(),
                  textAlign: TextAlign.center,
                  maxLines: 5,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    if (authResult == AuthResult.authenticated) {
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
