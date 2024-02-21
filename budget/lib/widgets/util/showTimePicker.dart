import 'package:budget/colors.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/settingsPage.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/timeDigits.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future<TimeOfDay?> showCustomTimePicker(
    BuildContext context, TimeOfDay initialTime,
    {String? confirmText}) async {
  minimizeKeyboard(context);
  TimeOfDay? newTime = await showTimePicker(
    context: context,
    initialTime: initialTime,
    initialEntryMode: TimePickerEntryMode.dial,
    helpText: "",
    confirmText: confirmText,
    builder: (BuildContext context, Widget? child) {
      child = Apply24HourFormatSetting(child: child ?? SizedBox.shrink());

      if (appStateSettings["materialYou"]) {
        return Theme(
          data: Theme.of(context).copyWith(
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
                primaryColor: Theme.of(context).colorScheme.primary,
                colorScheme: ColorScheme.light(
                    primary: Theme.of(context).colorScheme.primary),
                buttonTheme:
                    ButtonThemeData(textTheme: ButtonTextTheme.primary),
              )
            : ThemeData.dark().copyWith(
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
      {required this.child, super.key, this.customConfirmText});
  final Widget child;
  final String? customConfirmText;

  @override
  Widget build(BuildContext context) {
    if (isSetting24HourFormat() == null) return child;
    TimePickerLocalizationsDelegate translations =
        TimePickerLocalizationsDelegate(
      customAnteMeridiemAbbreviation:
          MaterialLocalizations.of(context).anteMeridiemAbbreviation,
      customPostMeridiemAbbreviation:
          MaterialLocalizations.of(context).postMeridiemAbbreviation,
      customCancelButtonLabel:
          MaterialLocalizations.of(context).cancelButtonLabel,
      customOkButtonLabel:
          customConfirmText ?? MaterialLocalizations.of(context).okButtonLabel,
      customTimePickerHourLabel:
          MaterialLocalizations.of(context).timePickerHourLabel,
      customTimePickerMinuteLabel:
          MaterialLocalizations.of(context).timePickerMinuteLabel,
    );
    return Localizations.override(
      context: context,
      // We have to force the locale to english. If it is "fr" it will always be 24 hours :(
      // See: https://github.com/flutter/flutter/issues/54839 which is slightly incorrect in its implementation
      // We apply the translations to the actual time picker when opened
      // Only issue: AM and PM is not correctly translated... so we fix that with a custom delegate
      locale: Locale("en", "US"),
      delegates: [translations],
      child: MediaQuery(
        child: child,
        data: MediaQuery.of(context).copyWith(
          alwaysUse24HourFormat: isSetting24HourFormat(),
        ),
      ),
    );
  }
}

class TimePickerLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  final String customAnteMeridiemAbbreviation;
  final String customPostMeridiemAbbreviation;
  final String customCancelButtonLabel;
  final String customOkButtonLabel;
  final String customTimePickerHourLabel;
  final String customTimePickerMinuteLabel;

  const TimePickerLocalizationsDelegate({
    this.customAnteMeridiemAbbreviation = "",
    this.customPostMeridiemAbbreviation = "",
    this.customCancelButtonLabel = "",
    this.customOkButtonLabel = "",
    this.customTimePickerHourLabel = "",
    this.customTimePickerMinuteLabel = "",
  });

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'en';

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      TimePickerLocalizations.load(
        locale,
        customAnteMeridiemAbbreviation,
        customPostMeridiemAbbreviation,
        customCancelButtonLabel,
        customOkButtonLabel,
        customTimePickerHourLabel,
        customTimePickerMinuteLabel,
      );

  @override
  bool shouldReload(TimePickerLocalizationsDelegate old) => false;
}

class TimePickerLocalizations extends DefaultMaterialLocalizations {
  final String customAnteMeridiemAbbreviation;
  final String customPostMeridiemAbbreviation;
  final String customCancelButtonLabel;
  final String customOkButtonLabel;
  final String customTimePickerHourLabel;
  final String customTimePickerMinuteLabel;
  const TimePickerLocalizations({
    required this.customAnteMeridiemAbbreviation,
    required this.customPostMeridiemAbbreviation,
    required this.customCancelButtonLabel,
    required this.customOkButtonLabel,
    required this.customTimePickerHourLabel,
    required this.customTimePickerMinuteLabel,
  });

  static Future<MaterialLocalizations> load(
    Locale locale,
    String customAnteMeridiemAbbreviation,
    String customPostMeridiemAbbreviation,
    String customCancelButtonLabel,
    String customOkButtonLabel,
    String customTimePickerHourLabel,
    String customTimePickerMinuteLabel,
  ) {
    return SynchronousFuture<TimePickerLocalizations>(
      TimePickerLocalizations(
        customAnteMeridiemAbbreviation: customAnteMeridiemAbbreviation,
        customPostMeridiemAbbreviation: customPostMeridiemAbbreviation,
        customCancelButtonLabel: customCancelButtonLabel,
        customOkButtonLabel: customOkButtonLabel,
        customTimePickerHourLabel: customTimePickerHourLabel,
        customTimePickerMinuteLabel: customTimePickerMinuteLabel,
      ),
    );
  }

  @override
  String get anteMeridiemAbbreviation => customAnteMeridiemAbbreviation;

  @override
  String get postMeridiemAbbreviation => customPostMeridiemAbbreviation;

  @override
  String get cancelButtonLabel => customCancelButtonLabel;

  @override
  String get okButtonLabel => customOkButtonLabel;

  @override
  String get timePickerHourLabel => customTimePickerHourLabel;

  @override
  String get timePickerMinuteLabel => customTimePickerMinuteLabel;

  static const LocalizationsDelegate<MaterialLocalizations> delegate =
      TimePickerLocalizationsDelegate();
}
