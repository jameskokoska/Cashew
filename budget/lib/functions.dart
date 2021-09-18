import 'package:budget/struct/transactionCategory.dart';
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
  String currencyType = "\$";
  final currency = new NumberFormat("#,##0.00", "en_US");
  String formatOutput = currency.format(amount);
  if (formatOutput.substring(formatOutput.length - 2) == "00") {
    return currencyType +
        formatOutput.replaceRange(
            formatOutput.length - 3, formatOutput.length, '');
  }
  return currencyType + currency.format(amount);
}

//TODO
TransactionCategory findCategory(String id) {
  return TransactionCategory(
      title: "Food and Drink",
      icon: "cutlery.png",
      id: "id",
      color: Colors.orange);
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

getWeekDayShort(currentWeekDay) {
  var weekDays = ['Sun', 'Mon', 'Tues', 'Wed', 'Thurs', 'Fri', 'Sat'];
  return weekDays[currentWeekDay];
}
