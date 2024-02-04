import 'package:animations/animations.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/breathingAnimation.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

// Returns null if there was an error or if biometrics are unavailable
Future<bool?> checkBiometrics({
  bool checkAlways = false,
}) async {
  try {
    if (kIsWeb) return true;
    final LocalAuthentication auth = LocalAuthentication();
    final bool requireAuth = checkAlways || appStateSettings["requireAuth"];
    biometricsAvailable = kIsWeb == false && await auth.canCheckBiometrics ||
        await auth.isDeviceSupported();
    if (biometricsAvailable == false) {
      return null;
    } else if (requireAuth == true && biometricsAvailable == true) {
      await auth.stopAuthentication();
      return await auth.authenticate(
        localizedReason: "verify-identity".tr(),
        options: const AuthenticationOptions(biometricOnly: true),
      );
    } else {
      return true;
    }
  } catch (e) {
    print("Error with biometrics: " + e.toString());
    return null;
  }
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
      final bool? result = await checkBiometrics();
      setState(() {
        authenticated = result;
      });
    });
  }

  _biometricErrorPopup() {
    // Wait so that we get a context on the navigatorKey
    // Since Initialize biometrics does not have access to Material navigator in the widget tree
    // because we want to keep the app fully locked
    Future.delayed(Duration(milliseconds: 500), () {
      if (navigatorKey.currentContext == null) return;
      openPopup(
        navigatorKey.currentContext!,
        barrierDismissible: false,
        icon: appStateSettings["outlinedIcons"]
            ? Icons.warning_outlined
            : Icons.warning_rounded,
        title: getPlatform() == PlatformOS.isIOS
            ? "biometrics-disabled".tr()
            : "biometrics-error".tr(),
        description: getPlatform() == PlatformOS.isIOS
            ? "biometrics-disabled-description".tr()
            : "biometrics-error-description".tr(),
        onSubmitLabel: "ok".tr(),
        onSubmit: () {
          updateSettings("requireAuth", false, updateGlobalState: false);
          Navigator.pop(navigatorKey.currentContext!);
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
            authenticated = null;
          });
          bool? result = await checkBiometrics();
          setState(() {
            authenticated = result;
          });
          if (result == null) {
            _biometricErrorPopup();
            setState(() {
              authenticated = true;
            });
          }
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
