import 'package:budget/struct/settings.dart';
import 'package:flutter/material.dart';

Future<TimeOfDay?> showCustomTimePicker(
    BuildContext context, TimeOfDay initialTime) async {
  TimeOfDay? newTime = await showTimePicker(
    context: context,
    initialTime: initialTime,
    initialEntryMode: TimePickerEntryMode.dial,
    helpText: "",
    builder: (BuildContext context, Widget? child) {
      if (appStateSettings["materialYou"]) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  tertiaryContainer:
                      Theme.of(context).colorScheme.primaryContainer,
                  onTertiaryContainer:
                      Theme.of(context).colorScheme.onPrimaryContainer,
                ),
            textTheme: TextTheme(
              displayLarge: TextStyle(
                fontSize: 65,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          child: child ?? SizedBox.shrink(),
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
        child: child ?? SizedBox.shrink(),
      );
    },
  );

  return newTime;
}
