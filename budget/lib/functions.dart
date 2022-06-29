import 'dart:math';

import 'package:budget/database/tables.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/subscriptionsPage.dart';
import 'package:budget/struct/defaultCategories.dart';
import 'package:budget/struct/defaultTags.dart';
import 'package:budget/struct/transactionCategory.dart';
import 'package:budget/struct/transactionTag.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';

import './colors.dart';
import './widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

getMonth(int currentMonth) {
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

getMonthShort(int currentMonth) {
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

getWeekDay(int currentWeekDay) {
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
getWordedDateShort(
  DateTime date, {
  includeYear = false,
  showTodayTomorrow = true,
}) {
  if (showTodayTomorrow && checkYesterdayTodayTomorrow(date) != false) {
    return checkYesterdayTodayTomorrow(date);
  }
  if (includeYear) {
    return DateFormat('MMM d\nyyyy').format(date);
  } else {
    return DateFormat('MMM d').format(date);
  }
}

// e.g. Today/Yesterday/Tomorrow/Tuesday/ March 15
getWordedDateShortMore(DateTime date, {includeYear = false}) {
  if (checkYesterdayTodayTomorrow(date) != false) {
    return checkYesterdayTodayTomorrow(date);
  }
  if (includeYear) {
    return DateFormat('MMMM d, yyyy').format(date);
  } else {
    return DateFormat('MMMM d').format(date);
  }
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

setTextInput(inputController, value) {
  inputController.value = TextEditingValue(
    text: value,
    selection: TextSelection.fromPosition(
      TextPosition(offset: value.length),
    ),
  );
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
  if (budget.reoccurrence == BudgetReoccurence.custom) {
    return DateTimeRange(start: budget.startDate, end: budget.endDate);
  } else if (budget.reoccurrence == BudgetReoccurence.weekly) {
    DateTime currentDateLoop = currentDate;
    for (int daysToGoBack = 0; daysToGoBack <= 7; daysToGoBack++) {
      if (currentDateLoop.weekday == budget.startDate.weekday) {
        DateTime endDate = new DateTime(currentDateLoop.year,
            currentDateLoop.month, currentDateLoop.day + 6);
        return DateTimeRange(start: currentDateLoop, end: endDate);
      }
      currentDateLoop = currentDateLoop.subtract(Duration(days: 1));
    }
  } else if (budget.reoccurrence == BudgetReoccurence.monthly) {
    //this gives weird things when you select 31 and current month is march... because of february
    DateTime startDate =
        new DateTime(currentDate.year, currentDate.month, budget.startDate.day);
    DateTime endDate = new DateTime(
        currentDate.year, currentDate.month + 1, budget.startDate.day - 1);
    if (startDate.isBefore(currentDate)) {
      return DateTimeRange(start: startDate, end: endDate);
    }
    startDate = new DateTime(currentDate.year, currentDate.month - 1, 0);
    endDate = new DateTime(
        currentDate.year, currentDate.month, budget.startDate.day - 1);
    return DateTimeRange(start: startDate, end: endDate);
  } else if (budget.reoccurrence == BudgetReoccurence.yearly) {
    DateTime startDate =
        new DateTime(currentDate.year, budget.startDate.month, currentDate.day);
    DateTime endDate = new DateTime(
        currentDate.year, budget.startDate.month + 12, currentDate.day - 1);
    if (startDate.isBefore(currentDate)) {
      return DateTimeRange(start: startDate, end: endDate);
    }
    startDate = new DateTime(
        currentDate.year, budget.startDate.month - 12, currentDate.day);
    endDate = new DateTime(
        currentDate.year, budget.startDate.month, currentDate.day - 1);
    return DateTimeRange(start: startDate, end: endDate);
  }
  return DateTimeRange(
      start: budget.startDate,
      end: DateTime(budget.startDate.year + 1, budget.startDate.month,
          budget.startDate.day));
}

String getWordedNumber(double value) {
  if (value >= 1000) {
    return getCurrencyString() + (value / 1000).toStringAsFixed(1) + "K";
  } else if (value <= -1000) {
    return getCurrencyString() + (value / 1000).toStringAsFixed(1) + "K";
  } else {
    return getCurrencyString() + value.toInt().toString();
  }
}

double getPercentBetweenDates(DateTimeRange timeRange, DateTime currentTime) {
  int millisecondDifference = timeRange.end.millisecondsSinceEpoch -
      timeRange.start.millisecondsSinceEpoch;
  double percent = (currentTime.millisecondsSinceEpoch -
          timeRange.start.millisecondsSinceEpoch) /
      millisecondDifference;
  return percent * 100;
}

int daysBetween(DateTime from, DateTime to) {
  from = DateTime(from.year, from.month, from.day);
  to = DateTime(to.year, to.month, to.day);
  return (to.difference(from).inHours / 24).round();
}

String getWelcomeMessage() {
  int h24 = DateTime.now().hour;
  List<String> greetings = [
    "Hello,",
    "Hi there,",
    "Hi,",
    "How are you,",
    "What's up",
    "Hello there",
    "Hope all is well",
  ];
  List<String> greetingsMorning = [
    "Good morning",
    "Good day",
  ];
  List<String> greetingsAfternoon = [
    "Good afternoon",
    "Good day",
  ];
  List<String> greetingsEvening = ["Good evening"];
  List<String> greetingsLate = ["Good night", "Get some rest"];
  if (random.nextBool() == true) {
    if (h24 <= 12 && h24 >= 6)
      return greetingsMorning[random.nextInt(greetingsMorning.length)];
    else if (h24 <= 16 && h24 >= 13)
      return greetingsAfternoon[random.nextInt(greetingsAfternoon.length)];
    else if (h24 <= 22 && h24 >= 19)
      return greetingsEvening[random.nextInt(greetingsEvening.length)];
    else if (h24 >= 23 || h24 <= 5)
      return greetingsLate[random.nextInt(greetingsLate.length)];
    else
      return greetings[random.nextInt(greetings.length)];
  } else {
    return greetings[random.nextInt(greetings.length)];
  }
}

IconData getTransactionTypeIcon(TransactionSpecialType? selectedType) {
  if (selectedType == null) {
    return Icons.payments_rounded;
  } else if (selectedType == TransactionSpecialType.upcoming) {
    return Icons.savings_rounded;
  } else if (selectedType == TransactionSpecialType.subscription) {
    return Icons.event_repeat_rounded;
  } else if (selectedType == TransactionSpecialType.repetitive) {
    return Icons.repeat_rounded;
  }
  return Icons.event_repeat_rounded;
}

getTotalSubscriptions(
    SelectedSubscriptionsType type, List<Transaction>? subscriptions) {
  double total = 0;
  DateTime today = DateTime.now();
  if (subscriptions != null) {
    for (Transaction subscription in subscriptions) {
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

List<BoxShadow> boxShadow(context) {
  return [
    BoxShadow(
      color: Theme.of(context).colorScheme.shadowColorLight.withAlpha(30),
      blurRadius: 20,
      offset: Offset(0, 0),
      spreadRadius: 8,
    ),
  ];
}
