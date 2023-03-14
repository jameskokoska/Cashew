import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/struct/notificationsGlobal.dart';
import 'package:budget/widgets/globalSnackBar.dart';
import 'package:budget/widgets/notificationsSettings.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/popupFramework.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<String?> initializeNotifications() async {
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
        builder: (context) => AddTransactionPage(title: "Add Transaction"),
      ),
    );
  }
  notificationPayload = "";
}

void runNotificationPayLoads(context) {
  if (kIsWeb) return;
  if (notificationPayload == "addTransaction") {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionPage(title: "Add Transaction"),
      ),
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
    await initializeNotificationsPlatform();
    await scheduleDailyNotification(context, timeOfDay);
  }
}

Future<void> setUpcomingNotifications(context) async {
  if (kIsWeb) return;
  bool upcomingTransactionsNotificationsEnabled =
      appStateSettings["notificationsUpcomingTransactions"];
  TimeOfDay upcomingTransactionsTimeOfDay = TimeOfDay(
      hour: appStateSettings["notificationHourUpcomingTransactions"],
      minute: appStateSettings["notificationMinuteUpcomingTransactions"]);
  if (upcomingTransactionsNotificationsEnabled) {
    await initializeNotificationsPlatform();
    await scheduleUpcomingTransactionsNotification(
        context, upcomingTransactionsTimeOfDay);
  }
}

Future<void> askForNotificationPermission() async {
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestPermission();
}
