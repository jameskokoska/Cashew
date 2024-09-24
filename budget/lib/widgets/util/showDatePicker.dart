import 'dart:math';
import 'dart:ui';
import 'package:budget/colors.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/pages/walletDetailsPage.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/globalSnackbar.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/tappableTextEntry.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/util/showTimePicker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:budget/struct/dateTimePickerLocalizationsDelegate.dart';
import 'package:flutter/widgets.dart';

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
    useRootNavigator: false,
    initialDate: initialDate,
    initialEntryMode: initialEntryMode,
    firstDate: DateTime(DateTime.now().year - 1000),
    lastDate: DateTime(DateTime.now().year + 1000),
    helpText: helpText,
    cancelText: cancelText,
    confirmText: confirmText,
    builder: (BuildContext context, Widget? child) {
      return ApplyStartOfTheWeekSetting(
        child: Theme(
          data: Theme.of(context).copyWith(
            // ignore: deprecated_member_use
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
        ),
      );
    },
  );
}

class DateTimeRangeOrAllTime {
  final bool allTime;
  final DateTimeRange? dateTimeRange;

  DateTimeRangeOrAllTime({
    required this.allTime,
    this.dateTimeRange,
  });

  factory DateTimeRangeOrAllTime.allTime() =>
      DateTimeRangeOrAllTime(allTime: true);

  factory DateTimeRangeOrAllTime.fromRange(DateTime start, DateTime end) =>
      DateTimeRangeOrAllTime(
        allTime: false,
        dateTimeRange: DateTimeRange(start: start, end: end),
      );

  @override
  String toString() {
    if (allTime) {
      return 'All Time';
    } else {
      return 'Start: ${dateTimeRange!.start}, End: ${dateTimeRange!.end}';
    }
  }
}

// Will pop the route with DateTimeRangeOrAllTime?
class DateRangePickerPopup extends StatefulWidget {
  const DateRangePickerPopup(
      {required this.initialDateRange, this.allTimeButton = true, super.key});
  final DateTimeRangeOrAllTime? initialDateRange;
  final bool allTimeButton;

  @override
  State<DateRangePickerPopup> createState() => _DateRangePickerPopupState();
}

class _DateRangePickerPopupState extends State<DateRangePickerPopup> {
  Future<DateTimeRange?> selectDateTimeRange(
      DateTimeRange? initialDateRange) async {
    return await showDateRangePicker(
      context: context,
      useRootNavigator: false,
      firstDate: DateTime(DateTime.now().year - 1000),
      lastDate: DateTime(DateTime.now().year + 1000),
      initialDateRange: initialDateRange,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (BuildContext context2, Widget? child) {
        return ApplyStartOfTheWeekSetting(
          child: Theme(
            child: child ?? Container(),
            data: Theme.of(context2).copyWith(
              // ignore: deprecated_member_use
              useMaterial3: appStateSettings["materialYou"],
              datePickerTheme: DatePickerTheme.of(context2).copyWith(
                headerHeadlineStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  disabledBackgroundColor: Theme.of(context)
                      .colorScheme
                      .secondaryContainer
                      .withOpacity(0.5),
                  animationDuration: Duration(milliseconds: 250),
                  textStyle:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  late DateTime? startDate = widget.initialDateRange?.dateTimeRange?.start;
  late DateTime? endDate = widget.initialDateRange?.dateTimeRange?.end;
  bool get allTime => startDate == null || endDate == null;

  DateTimeRangeOrAllTime? getDateTimeRangeOrAllTime(
      {bool forceAllTime = false}) {
    if (allTime || forceAllTime) return DateTimeRangeOrAllTime(allTime: true);
    DateTimeRange? safeRange =
        createSafeDateTimeRange(start: startDate, end: endDate);
    if (safeRange != null)
      return DateTimeRangeOrAllTime(allTime: false, dateTimeRange: safeRange);
    return null;
  }

  String? formatDateLabel(DateTime? dateTime) {
    if (dateTime == null) return null;
    return getWordedDateShortMore(
      dateTime,
      showTodayTomorrow: false,
      includeYear: (startDate?.year != endDate?.year ||
              DateTime.now().year != startDate?.year ||
              DateTime.now().year != endDate?.year) &&
          startDate?.year != null &&
          endDate?.year != null,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool materialYou = appStateSettings["materialYou"] == true;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        PositionedDirectional(
          top: 0,
          end: 0,
          child: OutsideExtraWidgetIconButton(
            iconData: appStateSettings["outlinedIcons"]
                ? Icons.edit_calendar_outlined
                : Icons.edit_calendar_rounded,
            onPressed: () async {
              DateTimeRange? result = await selectDateTimeRange(
                  createSafeDateTimeRange(start: startDate, end: endDate));
              if (result == null) {
                openSnackbar(
                  SnackbarMessage(
                    icon: appStateSettings["outlinedIcons"]
                        ? Icons.event_busy_outlined
                        : Icons.event_busy_rounded,
                    title: "date-not-selected".tr(),
                  ),
                );
              } else {
                startDate = result.start;
                endDate = result.end;
                Navigator.pop(context, getDateTimeRangeOrAllTime());
              }
            },
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.only(top: 20, bottom: 15),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Opacity(
                      opacity: 0.8,
                      child: TextFont(
                        textAlign: TextAlign.left,
                        text: materialYou
                            ? MaterialLocalizations.of(context)
                                .dateRangePickerHelpText
                            : MaterialLocalizations.of(context)
                                .dateRangePickerHelpText
                                .toUpperCase(),
                        fontSize: materialYou ? 14 : 12,
                        letterSpacing: materialYou ? null : 1.5,
                      ),
                    ),
                    SizedBox(height: 35),
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        runAlignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        runSpacing: 2,
                        children: [
                          TappableTextEntry(
                            title: formatDateLabel(startDate),
                            placeholder: MaterialLocalizations.of(context)
                                .dateRangeStartLabel,
                            onTap: () async {
                              DateTime? result = await showCustomDatePicker(
                                  context, startDate ?? DateTime.now());
                              DateTimeRange? safeRange =
                                  createSafeDateTimeRange(
                                      start: result, end: endDate);
                              setState(() {
                                startDate =
                                    safeRange?.start ?? result ?? startDate;
                                endDate = safeRange?.end ?? endDate;
                              });
                            },
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            padding: EdgeInsetsDirectional.symmetric(
                                vertical: 0, horizontal: 4),
                          ),
                          Icon(
                            size: 30,
                            appStateSettings["outlinedIcons"]
                                ? Icons.arrow_right_outlined
                                : Icons.arrow_right_rounded,
                          ),
                          TappableTextEntry(
                            title: formatDateLabel(endDate),
                            placeholder: MaterialLocalizations.of(context)
                                .dateRangeEndLabel,
                            onTap: () async {
                              DateTime? result = await showCustomDatePicker(
                                  context, endDate ?? DateTime.now());
                              DateTimeRange? safeRange =
                                  createSafeDateTimeRange(
                                      start: startDate, end: result);
                              setState(() {
                                startDate = safeRange?.start ?? startDate;
                                endDate = safeRange?.end ?? result ?? endDate;
                              });
                            },
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            padding: EdgeInsetsDirectional.symmetric(
                                vertical: 0, horizontal: 4),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              HorizontalBreak(
                  padding: EdgeInsetsDirectional.only(top: 25, bottom: 20)),
              Padding(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 25),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (widget.allTimeButton == true)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(bottom: 5),
                        child: Opacity(
                          key: ValueKey(allTime),
                          opacity: allTime ? 1 : 0.6,
                          child: FAB(
                            borderRadius: materialYou ? 15 : 7,
                            fabSize: 44,
                            iconData: appStateSettings["outlinedIcons"]
                                ? Icons.calendar_month_outlined
                                : Icons.calendar_month_rounded,
                            label: "all-time".tr(),
                            labelSize: 16,
                            onTap: () {
                              Navigator.pop(
                                  context,
                                  getDateTimeRangeOrAllTime(
                                      forceAllTime: true));
                            },
                            isOutlined: allTime == false,
                          ),
                        ),
                      ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Tappable(
                            onTap: () => Navigator.pop(context),
                            color: Colors.transparent,
                            borderRadius: materialYou ? 15 : 7,
                            child: Padding(
                              padding: const EdgeInsetsDirectional.symmetric(
                                  horizontal: 15, vertical: 10),
                              child: TextFont(
                                fontSize: materialYou ? 15 : 13,
                                textColor:
                                    Theme.of(context).colorScheme.primary,
                                text: materialYou
                                    ? MaterialLocalizations.of(context)
                                        .cancelButtonLabel
                                    : MaterialLocalizations.of(context)
                                        .cancelButtonLabel
                                        .toUpperCase(),
                              ),
                            ),
                          ),
                          Tappable(
                            onTap: () => Navigator.pop(
                                context, getDateTimeRangeOrAllTime()),
                            color: Colors.transparent,
                            borderRadius: materialYou ? 15 : 7,
                            child: Padding(
                              padding: const EdgeInsetsDirectional.symmetric(
                                  horizontal: 15, vertical: 10),
                              child: TextFont(
                                fontSize: materialYou ? 15 : 13,
                                textColor: allTime
                                    ? getColor(context, "textLight")
                                    : Theme.of(context).colorScheme.primary,
                                text: materialYou
                                    ? MaterialLocalizations.of(context)
                                        .okButtonLabel
                                    : MaterialLocalizations.of(context)
                                        .okButtonLabel
                                        .toUpperCase(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Future<DateTimeRangeOrAllTime> showCustomDateRangePicker(
  BuildContext context,
  DateTimeRangeOrAllTime? initialDateRange, {
  DatePickerEntryMode initialEntryMode = DatePickerEntryMode.calendar,
  bool allTimeButton = false,
}) async {
  minimizeKeyboard(context);
  dynamic result = await openPopupCustom(
    context,
    borderRadius: appStateSettings["materialYou"] == true
        ? BorderRadius.circular(20)
        : BorderRadius.circular(5),
    padding: EdgeInsetsDirectional.zero,
    child: DateRangePickerPopup(
      initialDateRange: initialDateRange,
      allTimeButton: allTimeButton,
    ),
  );
  if (result is DateTimeRangeOrAllTime) return result;
  return initialDateRange ?? DateTimeRangeOrAllTime(allTime: true);
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

class ApplyStartOfTheWeekSetting extends StatelessWidget {
  const ApplyStartOfTheWeekSetting({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (appStateSettings["firstDayOfWeek"] == -1) return child;
    DateTimePickerLocalizationsDelegate translations =
        DateTimePickerLocalizationsDelegate(
      materialLocalizations: MaterialLocalizations.of(context),
      customFirstDayOfWeekIndex:
          int.tryParse(appStateSettings["firstDayOfWeek"].toString()),
    );

    return Localizations.override(
      context: context,
      locale: Locale("en", "US"),
      delegates: [translations],
      child: child,
    );
  }
}
