import 'package:budget/colors.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/settings.dart';
import 'package:flutter/material.dart';

Future<DateTime?> showCustomDatePicker(
  BuildContext context,
  DateTime initialDate, {
  DatePickerEntryMode initialEntryMode = DatePickerEntryMode.calendar,
  String? helpText,
  String? cancelText,
  String? confirmText,
}) async {
  return await showDatePicker(
    context: context,
    initialDate: initialDate,
    initialEntryMode: initialEntryMode,
    firstDate: DateTime(DateTime.now().year - 1000),
    lastDate: DateTime(DateTime.now().year + 1000),
    helpText: helpText,
    cancelText: cancelText,
    confirmText: confirmText,
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: Theme.of(context).copyWith(
          useMaterial3: appStateSettings["materialYou"],
          datePickerTheme: DatePickerTheme.of(context).copyWith(
            headerHeadlineStyle: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          shadowColor: getPlatform() == PlatformOS.isIOS &&
                  appStateSettings["materialYou"]
              ? Theme.of(context).colorScheme.secondaryContainer
              : null,
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
    firstDate: DateTime(DateTime.now().year - 1000),
    lastDate: DateTime(DateTime.now().year + 1000),
    initialDateRange: initialDateRange,
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: Theme.of(context).copyWith(
          useMaterial3: appStateSettings["materialYou"],
          datePickerTheme: DatePickerTheme.of(context).copyWith(
            headerHeadlineStyle: const TextStyle(
              fontSize: 18,
            ),
          ),
        ),
        child: child ?? SizedBox.shrink(),
      );
    },
    initialEntryMode: initialEntryMode,
  );
}
