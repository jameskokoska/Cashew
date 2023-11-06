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
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:universal_io/io.dart';

Future<String?> initializeNotifications() async {
  if (Platform.isIOS) {
    return "";
  }
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('notification_icon_android2');
  final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
          onDidReceiveLocalNotification: (_, __, ___, ____) {});

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveBackgroundNotificationResponse: onSelectNotification,
    onDidReceiveNotificationResponse: onSelectNotification,
  );
  final NotificationAppLaunchDetails? notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  NotificationResponse? payload =
      notificationAppLaunchDetails?.notificationResponse;
  String? response = await payload?.payload;
  return response;
}

onSelectNotification(NotificationResponse notificationResponse) async {
  String? payloadData = notificationResponse.payload;
  notificationPayload = payloadData;
  runNotificationPayLoadsNoContext(payloadData);
}

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
  notificationPayload = "";
}

void runNotificationPayLoads(context) {
  if (kIsWeb) return;
  if (notificationPayload == "addTransaction") {
    pushRoute(
      context,
      AddTransactionPage(
        routesToPopAfterDelete: RoutesToPopAfterDelete.None,
      ),
    );
  } else if (notificationPayload == "upcomingTransaction") {
    pushRoute(
      context,
      UpcomingOverdueTransactions(overdueTransactions: false),
    );
  }
  notificationPayload = "";
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
