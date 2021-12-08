import 'package:budget/struct/defaultCategories.dart';
import 'package:budget/struct/defaultTags.dart';
import 'package:budget/struct/transactionCategory.dart';
import 'package:budget/struct/transactionTag.dart';
import 'package:flutter/foundation.dart';

import './colors.dart';
import './widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

showSnackbar(context, text, Color? textColor, Color? backgroundColor) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: TextFont(
        text: text,
        fontSize: 16,
        textColor:
            textColor == null ? Theme.of(context).colorScheme.white : textColor,
      ),
      backgroundColor: backgroundColor == null
          ? Theme.of(context).colorScheme.black
          : backgroundColor));
  return;
}

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

String convertToMoney(double amount) {
  final currency = new NumberFormat("#,##0.00", "en_US");
  String formatOutput = currency.format(amount);
  if (formatOutput.substring(formatOutput.length - 2) == "00") {
    return getCurrencyString() +
        formatOutput.replaceRange(
            formatOutput.length - 3, formatOutput.length, '');
  }
  return getCurrencyString() + currency.format(amount);
}

int moneyDecimals(double amount) {
  final currency = new NumberFormat("#,##0.00", "en_US");
  String formatOutput = currency.format(amount);
  if (formatOutput.substring(formatOutput.length - 2) == "00") {
    return 0;
  }
  return 2;
}

String getCurrencyString() {
  return "\$";
}

//TODO
TransactionCategoryOld findCategory(String id) {
  return TransactionCategoryOld(
    title: "Groceries",
    icon: "groceries.png",
    id: "id",
    color: Colors.orange,
  );
}

List<TransactionCategoryOld> listCategory() {
  return defaultCategoriesOld();
}

List<TransactionTag> listTag() {
  return defaultTags();
}

getMonth(currentMonth) {
  var months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  return months[currentMonth];
}

getMonthShort(currentMonth) {
  var months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
    'Jan',
  ];
  return months[currentMonth];
}

getWeekDay(currentWeekDay) {
  var weekDays = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];
  return weekDays[currentWeekDay];
}

checkYesterdayTodayTomorrow(DateTime date) {
  DateTime now = DateTime.now();
  if (date.day == now.day && date.month == now.month && date.year == now.year) {
    return "Today";
  }
  DateTime tomorrow = now.add(Duration(days: 1));
  if (date.day == tomorrow.day &&
      date.month == tomorrow.month &&
      date.year == tomorrow.year) {
    return "Tomorrow";
  }
  DateTime yesterday = now.subtract(Duration(days: 1));
  if (date.day == yesterday.day &&
      date.month == yesterday.month &&
      date.year == yesterday.year) {
    return "Yesterday";
  }

  return false;
}

getWeekDayShort(currentWeekDay) {
  var weekDays = ['Sun', 'Mon', 'Tues', 'Wed', 'Thurs', 'Fri', 'Sat'];
  return weekDays[currentWeekDay];
}

// e.g. Today/Yesterday/Tomorrow/Tuesday/ Mar 15
getWordedDateShort(DateTime date) {
  if (checkYesterdayTodayTomorrow(date) != false) {
    return checkYesterdayTodayTomorrow(date);
  }
  return DateFormat('MMM d').format(date);
}

// e.g. Today/Yesterday/Tomorrow/Tuesday/ March 15
getWordedDateShortMore(DateTime date) {
  if (checkYesterdayTodayTomorrow(date) != false) {
    return checkYesterdayTodayTomorrow(date);
  }
  return DateFormat('MMMM d').format(date);
}

//e.g. Today/Yesterday/Tomorrow/Tuesday/ Thursday, September 15
getWordedDate(DateTime date) {
  DateTime now = DateTime.now();

  if (checkYesterdayTodayTomorrow(date) != false) {
    return checkYesterdayTodayTomorrow(date);
  }

  if (now.difference(date).inDays < 4 && now.difference(date).inDays > 0) {
    String weekday = DateFormat('EEEE').format(date);
    return weekday;
  }
  return DateFormat.MMMMEEEEd('en_US').format(date).toString();
}
