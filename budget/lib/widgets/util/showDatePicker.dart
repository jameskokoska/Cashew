import 'package:budget/colors.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/globalSnackbar.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/util/showTimePicker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

Future<DateTime?> showCustomDatePicker(
  BuildContext context,
  DateTime initialDate, {
  DatePickerEntryMode initialEntryMode = DatePickerEntryMode.calendar,
  String? helpText,
  String? cancelText,
  String? confirmText,
}) async {
  minimizeKeyboard(context);
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
  minimizeKeyboard(context);
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

Future<DateTime?> selectDateAndTimeSequence(
    BuildContext context, DateTime initialDate) async {
  DateTime? selectedDateTime = await showCustomDatePicker(
    context,
    initialDate,
    confirmText: appStateSettings["materialYou"]
        ? "next-date-time".tr()
        : "next-date-time".tr().allCaps,
  );
  if (selectedDateTime == null) {
    openSnackbar(
      SnackbarMessage(
        icon: appStateSettings["outlinedIcons"]
            ? Icons.event_busy_outlined
            : Icons.event_busy_rounded,
        title: "date-not-selected".tr(),
      ),
    );
    return null;
  }
  TimeOfDay? selectedTime = await showCustomTimePicker(
    context,
    TimeOfDay(
      hour: initialDate.hour,
      minute: initialDate.minute,
    ),
    confirmText: appStateSettings["materialYou"]
        ? "set-date-time".tr()
        : "set-date-time".tr().allCaps,
  );
  if (selectedTime == null) {
    openSnackbar(
      SnackbarMessage(
        icon: appStateSettings["outlinedIcons"]
            ? Icons.timer_off_outlined
            : Icons.timer_off_rounded,
        title: "time-not-selected".tr(),
      ),
    );
    return null;
  }
  selectedDateTime = selectedDateTime.copyWith(
    hour: selectedTime.hour,
    minute: selectedTime.minute,
  );
  return selectedDateTime;
}
