import 'dart:convert';
import 'dart:math';

import 'package:animations/animations.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/subscriptionsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/defaultCategories.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/restartApp.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:universal_html/html.dart' hide Navigator;
import 'package:http/http.dart' as http;
import './colors.dart';
import './widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Add bottom padding for web Safari browsers
double bottomPaddingSafeArea = getOSInsideWeb() == "iOS" ? 20 : 0;

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

String convertToMoney(double amount,
    {String? currencyKey, bool showCurrency = true}) {
  {
    if (amount == -0.0) {
      amount = amount.abs();
    }
    if (amount == double.infinity) {
      return "Infinity";
    }
    final currency = new NumberFormat("#,##0.00", "en_US");
    String formatOutput = currency.format(amount);
    if (formatOutput.substring(formatOutput.length - 2) == "00") {
      return (showCurrency ? getCurrencyString(currencyKey: currencyKey) : '') +
          formatOutput.replaceRange(
              formatOutput.length - 3, formatOutput.length, '');
    }
    return (showCurrency ? getCurrencyString(currencyKey: currencyKey) : '') +
        currency.format(amount);
  }
}

int moneyDecimals(double amount) {
  final currency = new NumberFormat("#,##0.00", "en_US");
  String formatOutput = currency.format(amount);
  if (formatOutput.substring(formatOutput.length - 2) == "00") {
    return 0;
  }
  return 2;
}

// assume selected wallets currency
String getCurrencyString({String? currencyKey}) {
  return currencyKey != null &&
          currenciesJSON[currencyKey] != null &&
          currenciesJSON[currencyKey]["Symbol"] != null
      ? currenciesJSON[currencyKey]["Symbol"]
      : currenciesJSON[appStateSettings["selectedWalletCurrency"]]["Symbol"];
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
  DateTime tomorrow = DateTime(now.year, now.month, now.day + 1);
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
  newLineYear = false,
  newLineDay = false,
}) {
  if (showTodayTomorrow && checkYesterdayTodayTomorrow(date) != false) {
    return checkYesterdayTodayTomorrow(date);
  }
  if (includeYear && newLineYear) {
    return DateFormat('MMM d\nyyyy').format(date);
  } else if (includeYear) {
    return DateFormat('MMM d, yyyy').format(date);
  } else if (newLineDay) {
    return DateFormat('MMM \nd').format(date);
  }
  {
    return DateFormat('MMM d').format(date);
  }
}

// e.g. Today/Yesterday/Tomorrow/Tuesday/ March 15
getWordedDateShortMore(DateTime date,
    {includeYear = false, includeTime = false, includeTimeIfToday = false}) {
  if (checkYesterdayTodayTomorrow(date) != false) {
    if (includeTimeIfToday) {
      return checkYesterdayTodayTomorrow(date) +
          DateFormat(' - h:mm aaa').format(date);
    } else {
      return checkYesterdayTodayTomorrow(date);
    }
  }
  if (includeYear) {
    return DateFormat('MMMM d, yyyy').format(date);
  } else if (includeTime) {
    return DateFormat('MMMM d, yyyy - h:mm aaa').format(date);
  }
  {
    return DateFormat('MMMM d').format(date);
  }
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
      return '1 day ago';
    }
    return '${duration.inDays} days ago';
  } else if (duration.inHours >= 1) {
    if (duration.inHours == 1) {
      return '1 hour ago';
    }
    return '${duration.inHours} hours ago';
  } else if (duration.inMinutes >= 1) {
    if (duration.inMinutes == 1) {
      return '1 minute ago';
    }
    return '${duration.inMinutes} minutes ago';
  }
  return 'Just now';
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
                DateFormat.MMMMd('en_US').format(date).toString() +
                extraYear
            : "");
  }

  if (includeMonthDate == false &&
      now.difference(date).inDays < 4 &&
      now.difference(date).inDays > 0) {
    String weekday = DateFormat('EEEE').format(date);
    return weekday + extraYear;
  }
  return DateFormat.MMMMEEEEd('en_US').format(date).toString() + extraYear;
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
  } else if (budget.reoccurrence == BudgetReoccurence.daily ||
      budget.reoccurrence == BudgetReoccurence.monthly ||
      budget.reoccurrence == BudgetReoccurence.yearly) {
    DateTime currentDateLoopStart = budget.startDate;
    late DateTime currentDateLoopEnd;
    if (budget.reoccurrence == BudgetReoccurence.daily) {
      currentDateLoopEnd =
          budget.startDate.add(Duration(days: budget.periodLength));
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
    }
    // print("START");
    // print(currentDate);
    // print(currentDateLoopStart.toString() + currentDateLoopEnd.toString());
    // print("--------");
    if (currentDate.millisecondsSinceEpoch <=
        currentDateLoopEnd.millisecondsSinceEpoch) {
      for (int i = 0; i < 10000; i++) {
        // print(currentDateLoopStart.toString() + currentDateLoopEnd.toString());
        if (currentDate.millisecondsSinceEpoch >=
                currentDateLoopStart.millisecondsSinceEpoch &&
            currentDate.millisecondsSinceEpoch <=
                currentDateLoopEnd.millisecondsSinceEpoch) {
          return DateTimeRange(
              start: currentDateLoopStart,
              end: currentDateLoopEnd.subtract(Duration(days: 1)));
        }
        if (budget.reoccurrence == BudgetReoccurence.daily) {
          currentDateLoopStart = currentDateLoopStart
              .subtract(Duration(days: budget.periodLength));
          currentDateLoopEnd =
              currentDateLoopEnd.subtract(Duration(days: budget.periodLength));
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
        }
      }
    } else if (currentDate.millisecondsSinceEpoch >=
        currentDateLoopEnd.millisecondsSinceEpoch)
      for (int i = 0; i < 10000; i++) {
        // print(currentDateLoopStart.toString() + currentDateLoopEnd.toString());
        if (currentDate.millisecondsSinceEpoch >=
                currentDateLoopStart.millisecondsSinceEpoch &&
            currentDate.millisecondsSinceEpoch <=
                currentDateLoopEnd.millisecondsSinceEpoch) {
          return DateTimeRange(
              start: currentDateLoopStart,
              end: currentDateLoopEnd.subtract(Duration(days: 1)));
        }
        if (budget.reoccurrence == BudgetReoccurence.daily) {
          currentDateLoopStart =
              currentDateLoopStart.add(Duration(days: budget.periodLength));
          currentDateLoopEnd =
              currentDateLoopEnd.add(Duration(days: budget.periodLength));
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
        }
      }
  } else if (budget.reoccurrence == BudgetReoccurence.weekly) {
    DateTime currentDateLoop = currentDate;
    for (int daysToGoBack = 0;
        daysToGoBack <= 7 * budget.periodLength;
        daysToGoBack++) {
      if (currentDateLoop.weekday == budget.startDate.weekday) {
        DateTime endDate = new DateTime(
            currentDateLoop.year,
            currentDateLoop.month,
            currentDateLoop.day + 7 * budget.periodLength - 1);
        return DateTimeRange(start: currentDateLoop, end: endDate);
      }
      currentDateLoop = currentDateLoop.subtract(Duration(days: 1));
    }
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
      subscription = subscription.copyWith(
          amount: subscription.amount *
              (amountRatioToPrimaryCurrencyGivenPk(subscription.walletFk) ??
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
  return [
    BoxShadow(
      color: Theme.of(context).colorScheme.shadowColorLight.withAlpha(30),
      blurRadius: 20,
      offset: Offset(0, 0),
      spreadRadius: 8,
    ),
  ];
}

List<BoxShadow>? boxShadowCheck(list) {
  if (appStateSettings["batterySaver"]) return null;
  return list;
}

String pluralString(bool condition, String string) {
  if (condition)
    return string;
  else
    return string + "s";
}

String? getOSInsideWeb() {
  if (kIsWeb) {
    final userAgent = window.navigator.userAgent.toString().toLowerCase();
    if (userAgent.contains("(macintosh")) return "iOS";
    if (userAgent.contains("(iphone")) return "iOS";
    if (userAgent.contains("(linux")) return "Android";
    return "web";
  } else {
    return null;
  }
}

restartApp(context) async {
  // For now, enforce this until better solution found
  if (kIsWeb || true) {
    openPopup(context,
        title: "Please Restart the Application",
        icon: Icons.restart_alt_rounded);
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

// When we use fancyRoute, the bottom sheet causes screen to go black
// we will use this sparingly - but keep in mind the normal material page route causes a lag spike for animation / screen loading
pushRoute(context, page, {bool fancyRoute = false}) {
  if (appStateSettings["batterySaver"] || !fancyRoute) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  } else {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        transitionDuration: Duration(milliseconds: 400),
        reverseTransitionDuration: Duration(milliseconds: 400),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.vertical,
            child: child,
          );
        },
        pageBuilder: (context, animation, secondaryAnimation) {
          return page;
        },
      ),
    );
  }
}

Brightness determineBrightnessTheme(context) {
  return getSettingConstants(appStateSettings)["theme"] == ThemeMode.system
      ? MediaQuery.of(context).platformBrightness
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

Future<bool> getExchangeRates() async {
  print("Getting exchange rates for current wallets");
  List<String?> uniqueCurrencies =
      await database.getUniqueCurrenciesFromWallets();
  Map<String, dynamic> cachedCurrencyExchange =
      appStateSettings["cachedCurrencyExchange"];
  for (String? currency in uniqueCurrencies) {
    double exchangeRate = cachedCurrencyExchange[currency] ?? 1;
    if (currency == null) continue;
    try {
      Uri url = Uri.parse(
          "https://cdn.jsdelivr.net/gh/fawazahmed0/currency-api@1/latest/currencies/" +
              currency +
              "/usd.json");
      dynamic response = await http.get(url);
      if (response.statusCode == 200) {
        exchangeRate = json.decode(response.body)?["usd"];
      }
    } catch (e) {
      print(e.toString());
    }
    cachedCurrencyExchange[currency] = exchangeRate;
  }
  print(cachedCurrencyExchange);
  updateSettings("cachedCurrencyExchange", cachedCurrencyExchange,
      updateGlobalState: true);
  return true;
}

double? amountRatioToPrimaryCurrencyGivenPk(int walletPk) {
  return amountRatioToPrimaryCurrency(
      appStateSettings["cachedWalletCurrencies"][walletPk.toString()]);
}

double? amountRatioToPrimaryCurrency(String? walletCurrency) {
  if (walletCurrency == null) {
    return 0;
  }
  if (appStateSettings["cachedCurrencyExchange"][walletCurrency] == null) {
    return 0;
  }
  return appStateSettings["cachedCurrencyExchange"][walletCurrency] /
      appStateSettings["cachedCurrencyExchange"][
          appStateSettings["cachedWalletCurrencies"]
              [appStateSettings["selectedWallet"].toString()]];
}
