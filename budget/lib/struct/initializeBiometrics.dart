import 'package:animations/animations.dart';
import 'package:budget/main.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/breathingAnimation.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

Future<bool> checkBiometrics(
    {bool checkAlways = false,
    String message = 'Please authenticate to continue.'}) async {
  if (kIsWeb) return true;
  final LocalAuthentication auth = LocalAuthentication();
  final bool requireAuth = checkAlways || appStateSettings["requireAuth"];
  biometricsAvailable = kIsWeb == false && await auth.canCheckBiometrics ||
      await auth.isDeviceSupported();
  bool didAuthenticate = false;
  if (requireAuth == true && biometricsAvailable == true) {
    didAuthenticate = await auth.authenticate(
        localizedReason: message,
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
      body: Tappable(
        onTap: () async {
          setState(() {
            authenticated = null;
          });
          final bool result = await checkBiometrics();
          setState(() {
            authenticated = result;
          });
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
