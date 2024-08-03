import 'package:budget/colors.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/struct/dateTimePickerLocalizationsDelegate.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/timeDigits.dart';
import 'package:flutter/material.dart';

Future<TimeOfDay?> showCustomTimePicker(
    BuildContext context, TimeOfDay initialTime,
    {String? confirmText}) async {
  minimizeKeyboard(context);
  TimeOfDay? newTime = await showTimePicker(
    context: context,
    useRootNavigator: false,
    initialTime: initialTime,
    initialEntryMode: TimePickerEntryMode.dial,
    helpText: "",
    confirmText: confirmText,
    builder: (BuildContext context, Widget? child) {
      child = Apply24HourFormatSetting(
          materialLocalizations: MaterialLocalizations.of(context),
          child: child ?? SizedBox.shrink());

      if (appStateSettings["materialYou"]) {
        return Theme(
          data: Theme.of(context).copyWith(
            // ignore: deprecated_member_use
            useMaterial3: appStateSettings["materialYou"],
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  tertiaryContainer:
                      Theme.of(context).colorScheme.primaryContainer,
                  onTertiaryContainer:
                      Theme.of(context).colorScheme.onPrimaryContainer,
                ),
            shadowColor: getPlatform() == PlatformOS.isIOS &&
                    appStateSettings["materialYou"]
                ? Theme.of(context).colorScheme.secondaryContainer
                : null,
            textTheme: TextTheme(
              displayLarge: TextStyle(
                fontSize: 65,
                fontWeight: FontWeight.w300,
              ),
              bodySmall: TextStyle(
                color: getColor(context, "textLight"),
              ),
            ),
          ),
          child: child,
        );
      }
      return Theme(
        data: Theme.of(context).brightness == Brightness.light
            ? ThemeData.light().copyWith(
                // ignore: deprecated_member_use
                useMaterial3: appStateSettings["materialYou"],
                primaryColor: Theme.of(context).colorScheme.primary,
                colorScheme: ColorScheme.light(
                    primary: Theme.of(context).colorScheme.primary),
                buttonTheme:
                    ButtonThemeData(textTheme: ButtonTextTheme.primary),
              )
            : ThemeData.dark().copyWith(
                // ignore: deprecated_member_use
                useMaterial3: appStateSettings["materialYou"],
                primaryColor: Theme.of(context).colorScheme.secondary,
                colorScheme: ColorScheme.dark(
                    primary: Theme.of(context).colorScheme.secondary),
                buttonTheme:
                    ButtonThemeData(textTheme: ButtonTextTheme.primary),
              ),
        child: child,
      );
    },
  );

  return newTime;
}

class Apply24HourFormatSetting extends StatelessWidget {
  const Apply24HourFormatSetting(
      {required this.child, super.key, required this.materialLocalizations});
  final Widget child;
  final MaterialLocalizations materialLocalizations;

  @override
  Widget build(BuildContext context) {
    if (isSetting24HourFormat() == null) return child;
    DateTimePickerLocalizationsDelegate delegate =
        DateTimePickerLocalizationsDelegate(
      materialLocalizations: materialLocalizations,
    );
    return Localizations.override(
      context: context,
      // We have to force the locale to english. If it is "fr" it will always be 24 hours :(
      // See: https://github.com/flutter/flutter/issues/54839 which is slightly incorrect in its implementation
      // We apply the translations to the actual time picker when opened
      // Only issue: AM and PM is not correctly translated... so we fix that with a custom delegate
      locale: Locale("en", "US"),
      delegates: [delegate],
      child: MediaQuery(
        child: child,
        data: MediaQuery.of(context).copyWith(
          alwaysUse24HourFormat: isSetting24HourFormat(),
        ),
      ),
    );
  }
}
