import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/upcomingOverdueTransactionsPage.dart';
import 'package:budget/struct/notificationsGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/notificationsSettings.dart';
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
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
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
        builder: (context) => AddTransactionPage(),
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
      AddTransactionPage(),
    );
  } else if (notificationPayload == "upcomingTransaction") {
    pushRoute(
      context,
      UpcomingOverdueTransactions(overdueTransactions: false),
    );
  }
  notificationPayload = "";
}

Future<void> setDailyNotificationOnLaunch(context) async {
  if (kIsWeb) return;
  bool notificationsEnabled = appStateSettings["notifications"];
  TimeOfDay timeOfDay = TimeOfDay(
      hour: appStateSettings["notificationHour"],
      minute: appStateSettings["notificationMinute"]);
  if (notificationsEnabled) {
    await scheduleDailyNotification(context, timeOfDay);
  }
}

Future<void> setUpcomingNotifications(context) async {
  if (kIsWeb) return;
  bool upcomingTransactionsNotificationsEnabled =
      appStateSettings["notificationsUpcomingTransactions"];
  if (upcomingTransactionsNotificationsEnabled) {
    await scheduleUpcomingTransactionsNotification(context);
  }
}
