import 'package:budget/functions.dart';
import 'package:budget/struct/settings.dart';
import 'package:flutter/material.dart';

// Currently there is a bug (Flutter 3.13) where the shadow behind date pickers
// when using Material 3 is always white
// For now, we disable the material 3 theming on iOS for date pickers
// useMaterial3: getPlatform() != PlatformOS.isIOS,

Future<DateTime?> showCustomDatePicker(
  BuildContext context,
  DateTime initialDate, {
  DatePickerEntryMode initialEntryMode = DatePickerEntryMode.calendar,
}) async {
  return await showDatePicker(
    context: context,
    initialDate: initialDate,
    initialEntryMode: initialEntryMode,
    firstDate: DateTime(DateTime.now().year - 1000),
    lastDate: DateTime(DateTime.now().year + 1000),
    builder: (BuildContext context2, Widget? child) {
      return Theme(
        data: Theme.of(context).copyWith(
          useMaterial3: getPlatform() != PlatformOS.isIOS,
          datePickerTheme: DatePickerTheme.of(context).copyWith(
            headerHeadlineStyle: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
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
          useMaterial3: getPlatform() != PlatformOS.isIOS,
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
