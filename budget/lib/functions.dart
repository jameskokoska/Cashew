import 'dart:math';
import 'dart:ui' as ui;

import 'package:budget/database/tables.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/subscriptionsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/globalSnackbar.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/restartApp.dart';
import 'package:budget/widgets/selectAmount.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/timeDigits.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import './colors.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:universal_io/io.dart';
import 'package:universal_html/html.dart' as html;
import 'package:budget/struct/settings.dart';
import 'package:budget/struct/currencyFunctions.dart';
import 'package:budget/struct/randomConstants.dart';

extension CapExtension on String {
  String get capitalizeFirst =>
      this.length > 0 ? '${this[0].toUpperCase()}${this.substring(1)}' : '';
  String get allCaps => this.toUpperCase();
  String get capitalizeFirstofEach => this
      .replaceAll(RegExp(' +'), ' ')
      .split(" ")
      .map((str) => str.capitalizeFirst)
      .join(" ");
}

extension DateUtils on DateTime {
  DateTime copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
  }) {
    return DateTime(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
      millisecond ?? this.millisecond,
      microsecond ?? this.microsecond,
    );
  }
}

String convertToPercent(double amount,
    {double? finalNumber,
    int? numberDecimals,
    bool useLessThanZero = false,
    bool shouldRemoveTrailingZeroes = false}) {
  amount = absoluteZero(amount);
  finalNumber = absoluteZeroNull(finalNumber);

  if (amount == 0 || finalNumber == 0) return "0%";

  int numberDecimalsGet = numberDecimals != null
      ? numberDecimals
      : (int.tryParse(appStateSettings["percentagePrecision"].toString()) ?? 0);

  String roundedAmount = amount.toStringAsFixed(numberDecimalsGet);

  if (shouldRemoveTrailingZeroes) {
    if (finalNumber != null) {
      int finalTrailingZeroes = countNonTrailingZeroes(
          finalNumber.toStringAsFixed(numberDecimalsGet));
      roundedAmount = finalNumber
          .toStringAsFixed(max(finalTrailingZeroes, numberDecimalsGet));
    } else {
      roundedAmount = removeTrailingZeroes(roundedAmount);
    }
  }

  if (useLessThanZero &&
      roundedAmount == "0" &&
      (finalNumber == null && amount.abs() != 0 ||
          finalNumber != null && finalNumber.abs() != 0)) {
    if (numberDecimalsGet == 0) {
      if (finalNumber == null && amount < 0 ||
          finalNumber != null && finalNumber < 0) {
        roundedAmount = "< -1";
      } else {
        roundedAmount = "< 1";
      }
    } else if (numberDecimalsGet == 1) {
      if (finalNumber == null && amount < 0.1 ||
          finalNumber != null && finalNumber < 0.1) {
        roundedAmount = "< -0.1";
      } else {
        roundedAmount = "< 0.1";
      }
    } else if (numberDecimalsGet == 2) {
      if (finalNumber == null && amount < 0.01 ||
          finalNumber != null && finalNumber < 0.01) {
        roundedAmount = "< -0.01";
      } else {
        roundedAmount = "< 0.01";
      }
    }
  }

  return absoluteZeroString(roundedAmount) + "%";
}

String removeLastCharacter(String text) {
  if (text.isEmpty) {
    return text;
  }
  return text.substring(0, text.length - 1);
}

int countDecimalDigits(String value) {
  int decimalIndex = value.indexOf('.');
  if (decimalIndex == -1) {
    return 0;
  }

  int count = 0;
  for (int i = decimalIndex + 1; i < value.length; i++) {
    count++;
  }
  print(count);
  return count;
}

bool hasDecimalPoints(double? value) {
  if (value == null) return false;
  String stringValue = value.toString();
  int dotIndex = stringValue.indexOf('.');

  if (dotIndex != -1) {
    for (int i = dotIndex + 1; i < stringValue.length; i++) {
      if (stringValue[i] != '0') {
        return true;
      }
    }
  }

  return false;
}

String convertToMoney(AllWallets allWallets, double amount,
    {String? currencyKey,
    double? finalNumber,
    int? decimals,
    bool? allDecimals,
    bool? addCurrencyName,
    bool forceHideCurrencyName = false,
    bool forceAllDecimals = false,
    bool forceNonCustomNumberFormat = false,
    bool forceCustomNumberFormat = false,
    String? customSymbol,
    String Function(String)? editFormattedOutput,
    bool forceCompactNumberFormatter = false,
    bool forceDefaultNumberFormatter = false,
    bool forceAbsoluteZero = true,
    NumberFormat Function(int? decimalDigits, String? locale, String? symbol)?
        getCustomNumberFormat}) {
  int numberDecimals = decimals ??
      allWallets.indexedByPk[appStateSettings["selectedWalletPk"]]?.decimals ??
      2;
  numberDecimals = numberDecimals > 2 &&
          (finalNumber ?? amount).toString().split('.').length > 1
      ? (finalNumber ?? amount).toString().split('.')[1].length < numberDecimals
          ? (finalNumber ?? amount).toString().split('.')[1].length
          : numberDecimals
      : numberDecimals;

  if (amount == double.infinity || amount == double.negativeInfinity) {
    return "Infinity";
  }
  amount = double.parse(amount.toStringAsFixed(numberDecimals));
  if (forceAbsoluteZero) amount = absoluteZero(amount);
  if (finalNumber != null) {
    finalNumber = double.parse(finalNumber.toStringAsFixed(numberDecimals));
    if (forceAbsoluteZero) finalNumber = absoluteZero(finalNumber);
  }

  int? decimalDigits = forceAllDecimals
      ? decimals
      : allDecimals == true ||
              hasDecimalPoints(finalNumber) ||
              hasDecimalPoints(amount)
          ? numberDecimals
          : 0;
  String? locale = appStateSettings["customNumberFormat"] == true
      ? "en-US"
      : Platform.localeName;
  String? symbol =
      customSymbol ?? getCurrencyString(allWallets, currencyKey: currencyKey);

  bool useCustomNumberFormat = forceCustomNumberFormat ||
      (forceNonCustomNumberFormat == false &&
          appStateSettings["customNumberFormat"] == true);

  final NumberFormat formatter;
  if (getCustomNumberFormat != null) {
    formatter = getCustomNumberFormat(
        decimalDigits, locale, useCustomNumberFormat ? "" : symbol);
  } else if (forceDefaultNumberFormatter == false &&
      (forceCompactNumberFormatter ||
          appStateSettings["shortNumberFormat"] == "compact")) {
    formatter = NumberFormat.compactCurrency(
      locale: locale,
      decimalDigits: decimalDigits,
      symbol: useCustomNumberFormat ? "" : symbol,
    );
    formatter.significantDigitsInUse = false;
  } else {
    formatter = NumberFormat.currency(
      decimalDigits: decimalDigits,
      locale: locale,
      symbol: useCustomNumberFormat ? "" : symbol,
    );
  }

  // View the entire dictionary of locale formats, through NumberFormat.currency definition
  // numberFormatSymbols[locale] as NumberSymbols

  // If there is no currency symbol, use the currency code
  if (forceHideCurrencyName == false &&
      getCurrencyString(allWallets, currencyKey: currencyKey) == "") {
    addCurrencyName = true;
  }
  String formatOutput = formatter.format(amount).trim();
  String? currencyName;
  if (addCurrencyName == true && currencyKey != null) {
    currencyName = " " + currencyKey.toUpperCase();
  } else if (addCurrencyName == true) {
    currencyName = " " +
        (allWallets.indexedByPk[appStateSettings["selectedWalletPk"]]
                    ?.currency ??
                "")
            .toUpperCase();
  }

  if (useCustomNumberFormat) {
    formatOutput = formatOutputWithNewDelimiterAndDecimal(
      amount: finalNumber ?? amount,
      currencyName: currencyName,
      input: formatOutput,
      delimiter: appStateSettings["numberFormatDelimiter"],
      decimal: appStateSettings["numberFormatDecimal"],
      symbol: symbol,
    );
  } else if (useCustomNumberFormat == false && currencyName != null) {
    formatOutput = formatOutput + currencyName;
  }

  if (editFormattedOutput != null) {
    return editFormattedOutput(formatOutput);
  }

  return formatOutput;
  // if (finalNumber != null &&
  //     !finalNumber
  //         .abs()
  //         .toStringAsFixed(numberDecimals)
  //         .split(".")[1]
  //         .startsWith("0" * numberDecimals)) {
  //   return currency.format(amount);
  // }
  // if ((finalNumber != null &&
  //         finalNumber
  //             .abs()
  //             .toStringAsFixed(numberDecimals)
  //             .split(".")[1]
  //             .startsWith("0" * numberDecimals)) ||
  //     formatOutput.substring(formatOutput.length - numberDecimals) ==
  //         "0" * numberDecimals) {
  //   // Do not show the zeroes
  //   return formatOutput.replaceRange(
  //       formatOutput.length - numberDecimals - 1, formatOutput.length, '');
  // }
  // return currency.format(amount);
}

String formatOutputWithNewDelimiterAndDecimal({
  required double amount,
  required String input,
  required String delimiter,
  required String decimal,
  required String symbol,
  required String? currencyName,
}) {
  // Use a placeholder
  input = input.replaceAll(".", "\uFFFD");
  input = input.replaceAll(",", delimiter);
  input = input.replaceAll("\uFFFD", decimal);
  String negativeSign = "";
  if (amount < 0) {
    input = input.replaceRange(0, 1, "");
    negativeSign = "-";
  }
  if (appStateSettings["numberFormatCurrencyFirst"] == false) {
    return negativeSign +
        input +
        (symbol.length > 0 ? "  " : "") +
        symbol +
        (currencyName ?? "");
  } else {
    return negativeSign + symbol + input + (currencyName ?? "");
  }
}

List<String> localizedMonthNames = [];
initializeLocalizedMonthNames() {
  localizedMonthNames = [];
  for (int i = 1; i <= 12; i++) {
    final DateTime date = DateTime(2022, i);
    final String? locale = navigatorKey.currentContext?.locale.toString();
    final String monthName = DateFormat.MMMM(locale).format(date).toLowerCase();
    localizedMonthNames.add(monthName);
  }
  print("Initializing local months: " + localizedMonthNames.toString());
}

String getMonth(DateTime dateTime, {bool includeYear = false}) {
  if (includeYear) {
    return DateFormat.yMMMM(navigatorKey.currentContext?.locale.toString())
        .format(dateTime);
  }
  return DateFormat.MMMM(navigatorKey.currentContext?.locale.toString())
      .format(dateTime);
}

String getWordedTime(
  String? locale,
  DateTime dateTime,
) {
  if (isSetting24HourFormat() == null) {
    return DateFormat.jm(
            locale ?? navigatorKey.currentContext?.locale.toString())
        .format(dateTime);
  } else {
    if (isSetting24HourFormat() == true) {
      return DateFormat("H:mm").format(dateTime);
    } else {
      return DateFormat("h:mm aa").format(dateTime);
    }
  }
}

String getMeridiemString(DateTime dateTime) {
  // or can use
  // MaterialLocalizations.of(context).anteMeridiemAbbreviation
  // and
  // MaterialLocalizations.of(context).postMeridiemAbbreviation

  return DateFormat("aa").format(dateTime).replaceAll(".", "").allCaps;
}

checkYesterdayTodayTomorrow(DateTime date) {
  DateTime now = DateTime.now();
  if (date.day == now.day && date.month == now.month && date.year == now.year) {
    return "today".tr();
  }
  DateTime tomorrow = DateTime(now.year, now.month, now.day + 1);
  if (date.day == tomorrow.day &&
      date.month == tomorrow.month &&
      date.year == tomorrow.year) {
    return "tomorrow".tr();
  }
  DateTime yesterday = now.subtract(Duration(days: 1));
  if (date.day == yesterday.day &&
      date.month == yesterday.month &&
      date.year == yesterday.year) {
    return "yesterday".tr();
  }

  return false;
}

// e.g. Today/Yesterday/Tomorrow/Tuesday/ Mar 15
String getWordedDateShort(
  DateTime date, {
  includeYear = false,
  showTodayTomorrow = true,
  lowerCaseTodayTomorrow = false,
}) {
  if (showTodayTomorrow && checkYesterdayTodayTomorrow(date) != false) {
    String todayTomorrowOut = checkYesterdayTodayTomorrow(date);
    return lowerCaseTodayTomorrow
        ? todayTomorrowOut.toLowerCase()
        : todayTomorrowOut;
  }

  final locale = navigatorKey.currentContext?.locale.toString();

  if (includeYear) {
    return DateFormat.yMMMd(locale).format(date);
  } else {
    return DateFormat.MMMd(locale).format(date);
  }
}

// e.g. Today/Yesterday/Tomorrow/Tuesday/ March 15
String getWordedDateShortMore(
  DateTime date, {
  includeYear = false,
  includeTime = false,
  includeTimeIfToday = false,
  showTodayTomorrow = true,
}) {
  final String? locale = navigatorKey.currentContext?.locale.toString();

  if (showTodayTomorrow && checkYesterdayTodayTomorrow(date) != false) {
    if (includeTimeIfToday) {
      return checkYesterdayTodayTomorrow(date) +
          " - " +
          getWordedTime(locale, date);
    } else {
      return checkYesterdayTodayTomorrow(date);
    }
  }
  if (includeYear) {
    return DateFormat.MMMMd(locale).format(date) +
        ", " +
        DateFormat.y(locale).format(date);
  } else if (includeTime) {
    return DateFormat.MMMMd(locale).format(date) +
        ", " +
        DateFormat.y(locale).format(date) +
        " - " +
        getWordedTime(locale, date);
  }
  return DateFormat.MMMMd(locale).format(date);
}

String getTimeAgo(DateTime time) {
  final duration = DateTime.now().difference(time);
  if (duration.inDays >= 7) {
    return getWordedDateShortMore(
      time,
      includeTime: false,
      includeTimeIfToday: true,
    );
  } else if (duration.inDays >= 1) {
    if (duration.inDays == 1) {
      return '1-day-ago'.tr();
    }
    return '${duration.inDays} ${"days-ago".tr()}';
  } else if (duration.inHours >= 1) {
    if (duration.inHours == 1) {
      return '1-hour-ago'.tr();
    }
    return '${duration.inHours} ${"hours-ago".tr()}';
  } else if (duration.inMinutes >= 1) {
    if (duration.inMinutes == 1) {
      return '1-minute-ago'.tr();
    }
    return '${duration.inMinutes} ${"minutes-ago".tr()}';
  }
  return 'just-now'.tr();
}

//e.g. Today/Yesterday/Tomorrow/Tuesday/ Thursday, September 15
getWordedDate(DateTime date,
    {bool includeMonthDate = false, bool includeYearIfNotCurrentYear = true}) {
  DateTime now = DateTime.now();

  String extraYear = "";
  if (includeYearIfNotCurrentYear && now.year != date.year) {
    extraYear = ", " + date.year.toString();
  }

  if (checkYesterdayTodayTomorrow(date) != false) {
    return checkYesterdayTodayTomorrow(date) +
        (includeMonthDate
            ? ", " +
                DateFormat.MMMMd(navigatorKey.currentContext?.locale.toString())
                    .format(date)
                    .toString() +
                extraYear
            : "");
  }

  if (includeMonthDate == false &&
      now.difference(date).inDays < 4 &&
      now.difference(date).inDays > 0) {
    String weekday =
        DateFormat('EEEE', navigatorKey.currentContext?.locale.toString())
            .format(date);
    return weekday + extraYear;
  }
  return DateFormat.MMMMEEEEd(navigatorKey.currentContext?.locale.toString())
          .format(date)
          .toString() +
      extraYear;
}

setTextInput(TextEditingController inputController, String value) {
  inputController.value = TextEditingValue(
    text: value,
    selection: TextSelection.fromPosition(
      TextPosition(offset: value.length),
    ),
  );
}

DateTime getDatePastToDetermineBudgetDate(int index, Budget budget,
    {bool isChecking = true}) {
  BudgetReoccurence? reoccurrence = budget.reoccurrence;
  int periodLength = budget.periodLength;
  if (reoccurrence == null) return DateTime.now();

  int year = DateTime.now().year -
      (reoccurrence == BudgetReoccurence.yearly ? index * periodLength : 0);
  int month = DateTime.now().month -
      (reoccurrence == BudgetReoccurence.monthly ? index * periodLength : 0);
  // This fixes a bug where if the currentDate is the 31 of a month, February for example won't be considered since it doesn't have 30 days
  // Every monthly budget will have a day that falls on the first!
  int day = reoccurrence == BudgetReoccurence.monthly
      ? 1
      : DateTime.now().day -
          (reoccurrence == BudgetReoccurence.daily ? index * periodLength : 0) -
          (reoccurrence == BudgetReoccurence.weekly
              ? index * 7 * periodLength
              : 0);

  // This ensures that there will always be a current period, since we start
  // on the first of the month, the current period may not be shown and we have to remove
  // one from the index, for E.g. if the budget resets between the first of the month and the 7th and it is the 7th
  // It will NOT show the current period, this is here to fix that.
  // Only needed for months
  if (isChecking && reoccurrence == BudgetReoccurence.monthly) {
    DateTimeRange budgetRange = getBudgetDate(
        budget, getDatePastToDetermineBudgetDate(0, budget, isChecking: false));
    if (budgetRange.end.isBefore(DateTime.now().subtract(Duration(days: 1))))
      return getDatePastToDetermineBudgetDate(index - 1, budget,
          isChecking: false);
  }

  return DateTime(year, month, day, 0, 0, 1);
}

BudgetReoccurence mapRecurrence(String? recurrenceString) {
  if (recurrenceString == null) {
    return BudgetReoccurence.monthly;
  } else if (recurrenceString == "Custom") {
    return BudgetReoccurence.custom;
  } else if (recurrenceString == "Daily") {
    return BudgetReoccurence.daily;
  } else if (recurrenceString == "Weekly") {
    return BudgetReoccurence.weekly;
  } else if (recurrenceString == "Monthly") {
    return BudgetReoccurence.monthly;
  } else if (recurrenceString == "Yearly") {
    return BudgetReoccurence.yearly;
  }
  return BudgetReoccurence.monthly;
}

//get the current period of a repetitive budget
DateTimeRange getBudgetDate(Budget budget, DateTime currentDate) {
  budget = database.limitBudgetPeriod(budget);
  if (budget.reoccurrence == BudgetReoccurence.custom) {
    return DateTimeRange(start: budget.startDate, end: budget.endDate);
  } else if (budget.reoccurrence == BudgetReoccurence.daily ||
      budget.reoccurrence == BudgetReoccurence.monthly ||
      budget.reoccurrence == BudgetReoccurence.yearly ||
      budget.reoccurrence == BudgetReoccurence.weekly) {
    DateTime currentDateLoopStart = budget.startDate;
    late DateTime currentDateLoopEnd;
    if (budget.reoccurrence == BudgetReoccurence.daily) {
      currentDateLoopEnd = DateTime(
          currentDateLoopStart.year,
          currentDateLoopStart.month,
          currentDateLoopStart.day + budget.periodLength);
    } else if (budget.reoccurrence == BudgetReoccurence.monthly) {
      currentDateLoopEnd = DateTime(
          currentDateLoopStart.year,
          currentDateLoopStart.month + budget.periodLength,
          currentDateLoopStart.day);
    } else if (budget.reoccurrence == BudgetReoccurence.yearly) {
      currentDateLoopEnd = DateTime(
          currentDateLoopStart.year + budget.periodLength,
          currentDateLoopStart.month,
          currentDateLoopStart.day);
    } else if (budget.reoccurrence == BudgetReoccurence.weekly) {
      currentDateLoopEnd = DateTime(
          currentDateLoopStart.year,
          currentDateLoopStart.month,
          currentDateLoopStart.day + budget.periodLength * 7);
    }
    // print("START");
    // print(currentDate);
    // print(currentDateLoopStart.toString() + currentDateLoopEnd.toString());
    // print("--------");
    if (currentDate.millisecondsSinceEpoch <=
        currentDateLoopEnd.millisecondsSinceEpoch) {
      for (int i = 0; i < 10000; i++) {
        // print("Current loop: " +
        //     i.toString() +
        //     " " +
        //     currentDateLoopStart.toString() +
        //     currentDateLoopEnd.toString());
        // dont set this one >= only >, the other if statement will catch it
        if (currentDate.millisecondsSinceEpoch >
                currentDateLoopStart.millisecondsSinceEpoch &&
            currentDate.millisecondsSinceEpoch <=
                currentDateLoopEnd.millisecondsSinceEpoch) {
          return DateTimeRange(
            start: currentDateLoopStart,
            end: DateTime(currentDateLoopEnd.year, currentDateLoopEnd.month,
                currentDateLoopEnd.day - 1),
          );
        }
        if (budget.reoccurrence == BudgetReoccurence.daily) {
          currentDateLoopStart = DateTime(
              currentDateLoopStart.year,
              currentDateLoopStart.month,
              currentDateLoopStart.day - budget.periodLength);
          currentDateLoopEnd = DateTime(
              currentDateLoopEnd.year,
              currentDateLoopEnd.month,
              currentDateLoopEnd.day - budget.periodLength);
        } else if (budget.reoccurrence == BudgetReoccurence.monthly) {
          currentDateLoopStart = DateTime(
              currentDateLoopStart.year,
              currentDateLoopStart.month - budget.periodLength,
              currentDateLoopStart.day);
          currentDateLoopEnd = DateTime(
              currentDateLoopEnd.year,
              currentDateLoopEnd.month - budget.periodLength,
              currentDateLoopEnd.day);
        } else if (budget.reoccurrence == BudgetReoccurence.yearly) {
          currentDateLoopStart = DateTime(
              currentDateLoopStart.year - budget.periodLength,
              currentDateLoopStart.month,
              currentDateLoopStart.day);
          currentDateLoopEnd = DateTime(
              currentDateLoopEnd.year - budget.periodLength,
              currentDateLoopEnd.month,
              currentDateLoopEnd.day);
        } else if (budget.reoccurrence == BudgetReoccurence.weekly) {
          currentDateLoopStart = DateTime(
              currentDateLoopStart.year,
              currentDateLoopStart.month,
              currentDateLoopStart.day - budget.periodLength * 7);
          currentDateLoopEnd = DateTime(
              currentDateLoopEnd.year,
              currentDateLoopEnd.month,
              currentDateLoopEnd.day - budget.periodLength * 7);
        }
      }
    } else if (currentDate.millisecondsSinceEpoch >=
        currentDateLoopEnd.millisecondsSinceEpoch) {
      for (int i = 0; i < 10000; i++) {
        // print(currentDateLoopStart.toString() +
        //     " " +
        //     currentDateLoopEnd.toString());
        if (currentDate.millisecondsSinceEpoch >=
                currentDateLoopStart.millisecondsSinceEpoch &&
            currentDate.millisecondsSinceEpoch <=
                currentDateLoopEnd.millisecondsSinceEpoch) {
          return DateTimeRange(
            start: currentDateLoopStart,
            end: DateTime(currentDateLoopEnd.year, currentDateLoopEnd.month,
                currentDateLoopEnd.day - 1),
          );
        }
        if (budget.reoccurrence == BudgetReoccurence.daily) {
          currentDateLoopStart = DateTime(
              currentDateLoopStart.year,
              currentDateLoopStart.month,
              currentDateLoopStart.day + budget.periodLength);
          currentDateLoopEnd = DateTime(
              currentDateLoopEnd.year,
              currentDateLoopEnd.month,
              currentDateLoopEnd.day + budget.periodLength);
        } else if (budget.reoccurrence == BudgetReoccurence.monthly) {
          currentDateLoopStart = DateTime(
              currentDateLoopStart.year,
              currentDateLoopStart.month + budget.periodLength,
              currentDateLoopStart.day);
          currentDateLoopEnd = DateTime(
              currentDateLoopEnd.year,
              currentDateLoopEnd.month + budget.periodLength,
              currentDateLoopEnd.day);
        } else if (budget.reoccurrence == BudgetReoccurence.yearly) {
          currentDateLoopStart = DateTime(
              currentDateLoopStart.year + budget.periodLength,
              currentDateLoopStart.month,
              currentDateLoopStart.day);
          currentDateLoopEnd = DateTime(
              currentDateLoopEnd.year + budget.periodLength,
              currentDateLoopEnd.month,
              currentDateLoopEnd.day);
        } else if (budget.reoccurrence == BudgetReoccurence.weekly) {
          currentDateLoopStart = DateTime(
              currentDateLoopStart.year,
              currentDateLoopStart.month,
              currentDateLoopStart.day + budget.periodLength * 7);
          currentDateLoopEnd = DateTime(
              currentDateLoopEnd.year,
              currentDateLoopEnd.month,
              currentDateLoopEnd.day + budget.periodLength * 7);
        }
      }
    }
  }
  return DateTimeRange(
      start: budget.startDate,
      end: DateTime(budget.startDate.year + 1, budget.startDate.month,
          budget.startDate.day));
}

String getWordedNumber(
    BuildContext context, AllWallets allWallets, double value) {
  if (removeTrailingZeroes(value.toStringAsFixed(10)) == "0") {
    return getCurrencyString(allWallets) + "0";
  }
  return convertToMoney(
    allWallets,
    value,
    forceHideCurrencyName: true,
    addCurrencyName: false,
    getCustomNumberFormat: (decimalDigits, locale, currencySymbol) {
      final NumberFormat formatter = NumberFormat.compactCurrency(
        locale: locale,
        decimalDigits: decimalDigits,
        symbol: currencySymbol,
      );
      formatter.significantDigitsInUse = false;
      formatter.maximumFractionDigits = value.abs() < 1000
          ? value.abs() < 10
              ? (decimalDigits ?? 2)
              : 0
          : 1;
      formatter.minimumFractionDigits =
          value.abs() < 10 ? (decimalDigits ?? 2) : 0;
      return formatter;
    },
  );
}

double getPercentBetweenDates(DateTimeRange timeRange, DateTime currentTime) {
  int millisecondDifference = timeRange.end.millisecondsSinceEpoch -
      timeRange.start.millisecondsSinceEpoch +
      Duration(days: 1).inMilliseconds;
  double percent = (currentTime.millisecondsSinceEpoch -
          timeRange.start.millisecondsSinceEpoch) /
      millisecondDifference;
  return percent * 100;
}

int daysBetween(DateTime from, DateTime to) {
  from = DateTime(from.year, from.month, from.day);
  to = DateTime(to.year, to.month, to.day + 1);
  return (to.difference(from).inHours / 24).round();
}

String getWelcomeMessage() {
  int h24 = DateTime.now().hour;
  List<String> greetings = [
    "greetings-general-1".tr(),
    "greetings-general-2".tr(),
    "greetings-general-3".tr(),
    "greetings-general-4".tr(),
    "greetings-general-5".tr(),
    "greetings-general-6".tr(),
    "greetings-general-7".tr(),
  ];
  List<String> greetingsMorning = [
    "greetings-morning-1".tr(),
    "greetings-morning-2".tr(),
  ];
  List<String> greetingsAfternoon = [
    "greetings-afternoon-1".tr(),
    "greetings-afternoon-2".tr(),
  ];
  List<String> greetingsEvening = ["greetings-evening-1".tr()];
  List<String> greetingsLate = [
    "greetings-late-1".tr(),
    "greetings-late-2".tr()
  ];
  if (randomInt[0] % 2 == 0) {
    if (h24 <= 12 && h24 >= 6)
      return greetingsMorning[randomInt[0] % (greetingsMorning.length)];
    else if (h24 <= 16 && h24 >= 13)
      return greetingsAfternoon[randomInt[0] % (greetingsAfternoon.length)];
    else if (h24 <= 22 && h24 >= 19)
      return greetingsEvening[randomInt[0] % (greetingsEvening.length)];
    else if (h24 >= 23 || h24 <= 5)
      return greetingsLate[randomInt[0] % (greetingsLate.length)];
    else
      return greetings[randomInt[0] % (greetings.length)];
  } else {
    return greetings[randomInt[0] % (greetings.length)];
  }
}

IconData getTransactionTypeIcon(TransactionSpecialType? selectedType) {
  if (selectedType == null) {
    return appStateSettings["outlinedIcons"]
        ? Icons.payments_outlined
        : Icons.payments_rounded;
  } else if (selectedType == TransactionSpecialType.upcoming) {
    return appStateSettings["outlinedIcons"]
        ? Icons.event_outlined
        : Icons.event_rounded;
  } else if (selectedType == TransactionSpecialType.subscription) {
    return appStateSettings["outlinedIcons"]
        ? Icons.event_repeat_outlined
        : Icons.event_repeat_rounded;
  } else if (selectedType == TransactionSpecialType.repetitive) {
    return appStateSettings["outlinedIcons"]
        ? Icons.repeat_outlined
        : Icons.repeat_rounded;
  } else if (selectedType == TransactionSpecialType.debt) {
    return appStateSettings["outlinedIcons"]
        ? Icons.archive_outlined
        : Icons.archive_rounded;
  } else if (selectedType == TransactionSpecialType.credit) {
    return appStateSettings["outlinedIcons"]
        ? Icons.unarchive_outlined
        : Icons.unarchive_rounded;
  }
  return appStateSettings["outlinedIcons"]
      ? Icons.event_repeat_outlined
      : Icons.event_repeat_rounded;
}

getTotalSubscriptions(AllWallets allWallets, SelectedSubscriptionsType type,
    List<Transaction>? subscriptions) {
  double total = 0;
  DateTime today = DateTime.now();
  if (subscriptions != null) {
    for (Transaction subscription in subscriptions) {
      subscription = subscription.copyWith(
          amount: subscription.amount *
              (amountRatioToPrimaryCurrencyGivenPk(
                      allWallets, subscription.walletFk) ??
                  0));
      if (subscription.periodLength == 0) {
        continue;
      }
      if (type == SelectedSubscriptionsType.monthly) {
        int numDays = DateTime(today.year, today.month + 1, 0).day;
        double numWeeks = numDays / 7;
        if (subscription.reoccurrence == BudgetReoccurence.daily) {
          total +=
              subscription.amount * numDays / (subscription.periodLength ?? 1);
        } else if (subscription.reoccurrence == BudgetReoccurence.weekly) {
          total +=
              subscription.amount * numWeeks / (subscription.periodLength ?? 1);
        } else if (subscription.reoccurrence == BudgetReoccurence.monthly) {
          total += subscription.amount / (subscription.periodLength ?? 1);
        } else if (subscription.reoccurrence == BudgetReoccurence.yearly) {
          total += subscription.amount / 12 / (subscription.periodLength ?? 1);
        }
      }
      if (type == SelectedSubscriptionsType.yearly) {
        DateTime firstDay = DateTime(today.year, 1, 1);
        DateTime lastDay = DateTime(today.year + 1, 1, 1);
        int numDays = lastDay.difference(firstDay).inDays;
        double numWeeks = numDays / 7;
        if (subscription.reoccurrence == BudgetReoccurence.daily) {
          total +=
              subscription.amount * numDays / (subscription.periodLength ?? 1);
        } else if (subscription.reoccurrence == BudgetReoccurence.weekly) {
          total +=
              subscription.amount * numWeeks / (subscription.periodLength ?? 1);
        } else if (subscription.reoccurrence == BudgetReoccurence.monthly) {
          total += subscription.amount * 12 / (subscription.periodLength ?? 1);
        } else if (subscription.reoccurrence == BudgetReoccurence.yearly) {
          total += subscription.amount / (subscription.periodLength ?? 1);
        }
      }
      if (type == SelectedSubscriptionsType.total) {
        if (subscription.reoccurrence == BudgetReoccurence.daily) {
          total += subscription.amount;
        } else if (subscription.reoccurrence == BudgetReoccurence.weekly) {
          total += subscription.amount;
        } else if (subscription.reoccurrence == BudgetReoccurence.monthly) {
          total += subscription.amount;
        } else if (subscription.reoccurrence == BudgetReoccurence.yearly) {
          total += subscription.amount;
        }
      }
    }
  }
  return total;
}

List<BoxShadow> boxShadowGeneral(context) {
  if (appStateSettings["disableShadows"] == true) return [];
  return [
    BoxShadow(
      color: getColor(context, "shadowColorLight").withAlpha(30),
      blurRadius: 20,
      offset: Offset(0, 0),
      spreadRadius: 8,
    ),
  ];
}

List<BoxShadow> boxShadowSharp(context) {
  if (appStateSettings["disableShadows"] == true) return [];
  return [
    BoxShadow(
      color: getColor(context, "shadowColorLight").withAlpha(30),
      blurRadius: 2,
      offset: Offset(0, 0),
      spreadRadius: 2,
    ),
  ];
}

List<BoxShadow> boxShadowCategoryPercent(context) {
  if (appStateSettings["disableShadows"] == true) return [];
  return [
    BoxShadow(
      color: getColor(context, "shadowColor").withOpacity(0.4),
      blurRadius: 3,
      offset: Offset(0, 0),
      spreadRadius: 2,
    ),
  ];
}

List<BoxShadow>? boxShadowCheck(list) {
  if (appStateSettings["disableShadows"] == true) return null;
  if (appStateSettings["batterySaver"]) return null;
  return list;
}

String pluralString(bool condition, String string) {
  if (condition)
    return string;
  else
    return string + "s";
}

// String? getOSInsideWeb() {
//   if (kIsWeb) {
//     final userAgent = window.navigator.userAgent.toString().toLowerCase();
//     if (userAgent.contains("(macintosh")) return "iOS";
//     if (userAgent.contains("(iphone")) return "iOS";
//     if (userAgent.contains("(linux")) return "Android";
//     return "web";
//   } else {
//     return null;
//   }
// }

bool lockAppWaitForRestart = false;
void restartAppPopup(context,
    {String? subtitle, String? description, String? codeBlock}) async {
  // For now, enforce this until better solution found
  if (kIsWeb || true) {
    // Lock the side navigation
    lockAppWaitForRestart = true;
    appStateKey.currentState?.refreshAppState();

    openPopup(
      context,
      title: kIsWeb
          ? "please-refresh-the-application".tr()
          : "please-restart-the-application".tr(),
      description: description,
      subtitle: subtitle,
      descriptionWidget: codeBlock == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 12),
              child: CodeBlock(text: codeBlock),
            ),
      icon: appStateSettings["outlinedIcons"]
          ? Icons.restart_alt_outlined
          : Icons.restart_alt_rounded,
      barrierDismissible: false,
      // Show code widget with the name of the file monospace font
    );
  } else {
    // Pop all routes, select home tab
    RestartApp.restartApp(context);
    Navigator.of(context).popUntil((route) => route.isFirst);
    Future.delayed(Duration(milliseconds: 100), () {
      PageNavigationFramework.changePage(context, 0, switchNavbar: true);
    });
  }
}

String filterEmailTitle(string) {
  // Remove store number (everything past the last '#' symbol)
  int position = string.lastIndexOf('#');
  String title = (position != -1) ? string.substring(0, position) : string;
  title = title.trim();
  return title;
}

class CustomMaterialPageRoute extends MaterialPageRoute {
  @protected
  bool get hasScopedWillPopCallback {
    return false;
  }

  CustomMaterialPageRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) : super(
          builder: builder,
          settings: settings,
          maintainState: maintainState,
          fullscreenDialog: fullscreenDialog,
        );
}

Future<dynamic> pushRoute(BuildContext context, Widget page,
    {String? routeName}) async {
  minimizeKeyboard(context);
  // if (appStateSettings["iOSNavigation"]) {
  //   return await Navigator.push(
  //     context,
  //     CustomMaterialPageRoute(builder: (context) => page),
  //   );
  // }

  return await Navigator.push(
    context,
    PageRouteBuilder(
      opaque: false,
      transitionDuration: Duration(milliseconds: 300),
      reverseTransitionDuration: Duration(milliseconds: 125),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(begin: Offset(0, 0.05), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOut));
        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return page;
      },
    ),
  );
}

Brightness determineBrightnessTheme(context) {
  return getSettingConstants(appStateSettings)["theme"] == ThemeMode.system
      ? MediaQuery.platformBrightnessOf(context)
      : getSettingConstants(appStateSettings)["theme"] == ThemeMode.light
          ? Brightness.light
          : getSettingConstants(appStateSettings)["theme"] == ThemeMode.dark
              ? Brightness.dark
              : Brightness.light;
}

String getMemberNickname(member) {
  if (member == appStateSettings["currentUserEmail"]) {
    if (appStateSettings["usersNicknames"][member] != null &&
        appStateSettings["usersNicknames"][member].toString().trim() != "") {
      return appStateSettings["usersNicknames"][member];
    } else {
      return "Me";
    }
  } else if (appStateSettings["usersNicknames"][member] != null &&
      appStateSettings["usersNicknames"][member].toString().trim() != "") {
    return appStateSettings["usersNicknames"][member];
  } else {
    return member;
  }
}

bool isNumber(dynamic value) {
  if (value == null) {
    return false;
  }
  return num.tryParse(value.toString()) != null;
}

bool getIsKeyboardOpen(context) {
  return EdgeInsets.zero !=
      EdgeInsets.fromViewPadding(
          View.of(context).viewInsets, View.of(context).devicePixelRatio);
}

double getKeyboardHeight(context) {
  return EdgeInsets.fromViewPadding(
          View.of(context).viewInsets, View.of(context).devicePixelRatio)
      .bottom;
}

double getKeyboardHeightForceBuild(context) {
  return MediaQuery.of(context).viewInsets.bottom;
}

Future<String> getDeviceInfo() async {
  if (kIsWeb) {
    String webBrowserInfo = html.window.navigator.userAgent.toString();
    return webBrowserInfo
        .toLowerCase()
        .replaceAll("mozilla/5.0", "")
        .replaceAll("mozilla", "")
        .replaceAll("(", "")
        .replaceAll(")", "")
        .replaceAll(";", "")
        .trim()
        .capitalizeFirst;
  }
  try {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo info = await deviceInfo.androidInfo;
      return info.model;
    } else if (Platform.isIOS) {
      IosDeviceInfo info = await deviceInfo.iosInfo;
      return info.utsname.machine ?? info.model ?? "iOS";
    } else if (Platform.isLinux) {
      LinuxDeviceInfo info = await deviceInfo.linuxInfo;
      return info.machineId ?? "Linux";
    } else if (Platform.isMacOS) {
      MacOsDeviceInfo info = await deviceInfo.macOsInfo;
      return info.computerName;
    } else if (Platform.isWindows) {
      WindowsDeviceInfo info = await deviceInfo.windowsInfo;
      return info.computerName;
    }
    return "";
  } catch (e) {
    return "Unknown";
  }
}

List<String> extractLinks(String text) {
  RegExp regExp = RegExp(r'https?:\/\/(?:www\.)?\S+(?=\s)');
  Iterable<RegExpMatch> matches = regExp.allMatches(text);
  List<String> links = [];
  for (RegExpMatch match in matches) {
    links.add(match.group(0)!);
  }
  return links;
}

String getDomainNameFromURL(String text) {
  RegExp regExp = RegExp(
      r'^(?:https?:\/\/)?(?:[^@\/\n]+@)?(?:www\.)?([^:\/?\n]+)',
      multiLine: true,
      caseSensitive: false);
  Match? match = regExp.firstMatch(text);
  return match?.group(1) ?? '';
}

String cleanupNoteStringWithURLs(String text) {
  RegExp regExp = RegExp(
      r'^(?:https?:\/\/)?(?:[^@\/\n]+@)?(?:www\.)?([^:\/?\n]+)',
      multiLine: true,
      caseSensitive: false);

  Iterable<Match> matches = regExp.allMatches(text);

  String modifiedText = text;

  for (Match match in matches) {
    if (match.group(0) != null)
      modifiedText = modifiedText.replaceFirst(
          match.group(0)!, getDomainNameFromURL(match.group(0)!));
  }

  return modifiedText;
}

void openUrl(String link) async {
  if (await canLaunchUrl(Uri.parse(link)))
    await launchUrl(
      Uri.parse(link),
      mode: LaunchMode.externalApplication,
    );
}

List<String> popularCurrencies = [
  'usd', // United States Dollar
  'eur', // Euro
  'jpy', // Japanese Yen
  'gbp', // British Pound Sterling
  'aud', // Australian Dollar
  'cad', // Canadian Dollar
  'chf', // Swiss Franc
  'cny', // Chinese Yuan
  'sek', // Swedish Krona
  'nzd', // New Zealand Dollar
  'mxn', // Mexican Peso
  'inr', // Indian Rupee
  'nok', // Norwegian Krone
  'krw', // South Korean Won
  'btc', // Bitcoin
];

String getDevicesDefaultCurrencyCode() {
  try {
    String? currentCountryCode =
        WidgetsBinding.instance.platformDispatcher.locale.countryCode;
    // print(currentCountryCode);
    for (String currencyKey in currenciesJSON.keys) {
      if (currenciesJSON[currencyKey] != null &&
          currenciesJSON[currencyKey]["CountryCode"] != null &&
          currenciesJSON[currencyKey]["CountryCode"] == currentCountryCode) {
        return currencyKey;
      }
    }
  } catch (e) {
    print("Error getting default currency " + e.toString());
  }
  return popularCurrencies[0];
}

void copyToClipboard(String text, {bool showSnackbar = true}) async {
  HapticFeedback.mediumImpact();
  await Clipboard.setData(ClipboardData(text: text));
  if (showSnackbar)
    openSnackbar(
      SnackbarMessage(
        title: "copied-to-clipboard".tr(),
        description: text,
        icon: appStateSettings["outlinedIcons"]
            ? Icons.copy_outlined
            : Icons.copy_rounded,
        timeout: Duration(milliseconds: 2500),
      ),
    );
}

Future<String?> readClipboard({bool showSnackbar = true}) async {
  HapticFeedback.mediumImpact();
  final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
  String? clipboardText = clipboardData?.text;
  if (showSnackbar)
    openSnackbar(
      SnackbarMessage(
        title: "pasted-from-clipboard".tr(),
        icon: appStateSettings["outlinedIcons"]
            ? Icons.paste_outlined
            : Icons.paste_rounded,
        timeout: Duration(milliseconds: 2500),
      ),
    );
  return clipboardText;
}

double? getAmountFromString(String inputString) {
  bool isNegative = false;
  if (inputString.contains("-") ||
      inputString.contains("—") ||
      inputString.contains("−") ||
      inputString.contains("–") ||
      inputString.contains("‐") ||
      inputString.contains("−") ||
      inputString.contains("⁃") ||
      inputString.contains("‑") ||
      inputString.contains("‒") ||
      inputString.contains("–") ||
      inputString.contains("—") ||
      inputString.contains("―")) {
    isNegative = true;
  }
  if (getDecimalSeparator() == ",") {
    inputString = inputString.replaceAll(",", ".");
  } else {
    inputString = inputString.replaceAll(",", "");
  }
  RegExp regex = RegExp(r'[0-9]+(?:\.[0-9]+)?');
  String? match = regex.stringMatch(inputString);

  if (match != null) {
    double amount = double.tryParse(match) ?? 0.0;
    amount = amount.abs();
    if (isNegative) {
      amount = amount * -1;
    }
    return amount;
  }
  return null;
}

enum PlatformOS {
  isIOS,
  isAndroid,
  web,
}

PlatformOS? getPlatform({bool ignoreEmulation = false}) {
  if (appStateSettings["iOSEmulate"] == true && ignoreEmulation == false) {
    return PlatformOS.isIOS;
  } else if (kIsWeb) {
    return PlatformOS.web;
  } else if (Platform.isIOS) {
    return PlatformOS.isIOS;
  } else if (Platform.isAndroid) {
    return PlatformOS.isAndroid;
  }
  return null;
}

dynamic nullIfIndexOutOfRange(List list, index) {
  if (list.length - 1 < index || index < 0) {
    return null;
  } else {
    return list[index];
  }
}

double getDeviceAspectRatio(BuildContext context) {
  Size size = MediaQuery.sizeOf(context);
  final double aspectRatio = size.height / size.width;
  return aspectRatio;
}

Future<int?> getAndroidVersion() async {
  int? androidVersion;
  if (getPlatform(ignoreEmulation: true) == PlatformOS.isAndroid) {
    try {
      AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
      String androidVersionString = androidInfo.version.release;
      androidVersion = int.tryParse(androidVersionString);
    } catch (e) {
      print("Error parsing Android version" + e.toString());
    }
  }
  return androidVersion;
}

Future<bool> setHighRefreshRate() async {
  try {
    if (getPlatform() == PlatformOS.isAndroid)
      await FlutterDisplayMode.setHighRefreshRate();
    return true;
  } catch (e) {
    print("Error setting high refresh rate: " + e.toString());
  }
  return false;
}

double absoluteZero(double number) {
  if (number == -0) return number.abs();
  return number;
}

double? absoluteZeroNull(double? number) {
  if (number == null) return null;
  if (number == -0) return number.abs();
  return number;
}

String absoluteZeroString(String number) {
  if (number == "-0") return "0";
  return number;
}

// Will only include the currency if the user has wallets of different currencies
// e.g. Wallet (USD)
String getWalletStringName(AllWallets allWallets, TransactionWallet wallet) {
  if (wallet.name == wallet.currency.toString().toUpperCase()) {
    return wallet.currency.toString().toUpperCase();
  } else if (allWallets.allContainSameCurrency() == true) {
    return wallet.name;
  } else {
    return wallet.name + " (" + wallet.currency.toString().toUpperCase() + ")";
  }
}

String addAmountToString(String string, int amount,
    {String? extraText, bool addCommaWithExtraText = true}) {
  return string +
      " " +
      "( ×" +
      amount.toString() +
      (extraText == null
          ? ""
          : (addCommaWithExtraText ? ", " : " ") + (extraText)) +
      " )";
}

int directionalityReverse(BuildContext context) {
  return (Directionality.of(context) == ui.TextDirection.rtl ? -1 : 1);
}
