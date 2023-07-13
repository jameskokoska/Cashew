import 'package:budget/struct/settings.dart';
import 'package:flutter/material.dart';

Future<DateTime?> showCustomDatePicker(
  BuildContext context,
  DateTime initialDate, {
  DatePickerEntryMode initialEntryMode = DatePickerEntryMode.calendar,
}) async {
  return await showDatePicker(
    context: context,
    initialDate: initialDate,
    initialEntryMode: initialEntryMode,
    firstDate: DateTime(DateTime.now().year - 10),
    lastDate: DateTime(DateTime.now().year + 2),
    builder: (BuildContext context, Widget? child) {
      if (appStateSettings["materialYou"]) {
        return Theme(
          data: Theme.of(context).brightness == Brightness.light
              ? ThemeData.light(
                  useMaterial3: true,
                )
              : ThemeData.dark(
                  useMaterial3: true,
                ),
          child: child ?? SizedBox.shrink(),
        );
      }
      return Theme(
        data: Theme.of(context).brightness == Brightness.light
            ? ThemeData.light().copyWith(
                useMaterial3: true,
                typography: Typography.material2021(),
                primaryColor: Theme.of(context).colorScheme.primary,
                colorScheme: ColorScheme.light(
                    primary: Theme.of(context).colorScheme.primary),
                buttonTheme:
                    ButtonThemeData(textTheme: ButtonTextTheme.primary),
              )
            : ThemeData.dark().copyWith(
                useMaterial3: true,
                typography: Typography.material2021(),
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
}

Future<DateTimeRange?> showCustomDateRangePicker(
  BuildContext context,
  DateTimeRange? initialDateRange, {
  DatePickerEntryMode initialEntryMode = DatePickerEntryMode.calendar,
}) async {
  return await showDateRangePicker(
    context: context,
    firstDate: DateTime(DateTime.now().year - 15),
    lastDate: DateTime(DateTime.now().year + 2),
    initialDateRange: initialDateRange,
    builder: (BuildContext context, Widget? child) {
      if (appStateSettings["materialYou"]) {
        return Theme(
          data: Theme.of(context).brightness == Brightness.light
              ? ThemeData.light(
                  useMaterial3: true,
                )
              : ThemeData.dark(
                  useMaterial3: true,
                ),
          child: child ?? SizedBox.shrink(),
        );
      }
      return Theme(
        data: Theme.of(context).brightness == Brightness.light
            ? ThemeData.light().copyWith(
                useMaterial3: true,
                typography: Typography.material2021(),
                primaryColor: Theme.of(context).colorScheme.primary,
                colorScheme: ColorScheme.light(
                    primary: Theme.of(context).colorScheme.primary),
                buttonTheme:
                    ButtonThemeData(textTheme: ButtonTextTheme.primary),
              )
            : ThemeData.dark().copyWith(
                useMaterial3: true,
                typography: Typography.material2021(),
                primaryColor: Theme.of(context).colorScheme.secondary,
                colorScheme: ColorScheme.dark(
                    primary: Theme.of(context).colorScheme.secondary),
                buttonTheme:
                    ButtonThemeData(textTheme: ButtonTextTheme.primary),
              ),
        child: child ?? SizedBox.shrink(),
      );
    },
    initialEntryMode: initialEntryMode,
  );
}
