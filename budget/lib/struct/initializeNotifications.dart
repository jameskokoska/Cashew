import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/upcomingOverdueTransactionsPage.dart';
import 'package:budget/struct/notificationsGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/notificationsSettings.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

runNotificationPayLoadsNoContext(payloadData) {
  if (payloadData == "addTransaction") {
    navigatorKey.currentState!.push(
      MaterialPageRoute(
        builder: (context) => AddTransactionPage(
          routesToPopAfterDelete: RoutesToPopAfterDelete.None,
        ),
      ),
    );
  } else if (payloadData == "upcomingTransaction") {
    navigatorKey.currentState!.push(
      MaterialPageRoute(
        builder: (context) =>
            UpcomingOverdueTransactions(overdueTransactions: true),
      ),
    );
  }
}

void runNotificationPayLoads(context) {
  final initialActionPayload =
      notificationController.initialAction?.payload ?? '';
  if (kIsWeb) return;
  if (initialActionPayload == "addTransaction") {
    pushRoute(
      context,
      AddTransactionPage(
        routesToPopAfterDelete: RoutesToPopAfterDelete.None,
      ),
    );
  } else if (initialActionPayload == "upcomingTransaction") {
    // When the notification comes in, the transaction is past due!
    pushRoute(
      context,
      UpcomingOverdueTransactions(overdueTransactions: true),
    );
  }
}

Future<void> setDailyNotifications(context) async {
  if (kIsWeb) return;
  bool notificationsEnabled = appStateSettings["notifications"] == true;

  if (notificationsEnabled) {
    try {
      TimeOfDay timeOfDay = TimeOfDay(
          hour: appStateSettings["notificationHour"],
          minute: appStateSettings["notificationMinute"]);
      if (ReminderNotificationType
              .values[appStateSettings["notificationsReminderType"]] ==
          ReminderNotificationType.DayFromOpen) {
        timeOfDay = TimeOfDay(
            hour: appStateSettings["appOpenedHour"],
            minute: appStateSettings["appOpenedMinute"]);
      }
      await scheduleDailyNotification(context, timeOfDay);
    } catch (e) {
      print(e.toString() +
          " Error setting up notifications for upcoming transactions");
    }
  }
}

Future<void> setUpcomingNotifications(context) async {
  if (kIsWeb) return;
  bool upcomingTransactionsNotificationsEnabled =
      appStateSettings["notificationsUpcomingTransactions"] == true;
  if (upcomingTransactionsNotificationsEnabled) {
    try {
      await scheduleUpcomingTransactionsNotification(context);
    } catch (e) {
      print(e.toString() +
          " Error setting up notifications for upcoming transactions");
    }
  }
  return;
}
