import 'dart:math';

import 'package:budget/database/tables.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/initializeNotifications.dart';
import 'package:budget/struct/notification_controller/models.dart';
import 'package:budget/struct/notification_controller/notification_controller.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/notificationsSettings.dart';
import 'package:budget/widgets/transactionEntry/transactionLabel.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart';

const initialActionResetTimeoutInSeconds = 2;

class LocalNotificationController
    extends NotificationController<NotificationResponse, String, TZDateTime> {
  LocalNotificationController._();

  static final LocalNotificationController _instance =
      LocalNotificationController._();

  static LocalNotificationController get instance => _instance;

  static FlutterLocalNotificationsPlugin _pluginInstance =
      FlutterLocalNotificationsPlugin();

  static FlutterLocalNotificationsPlugin get plugin => _pluginInstance;

  @override
  Future<bool> initNotificationPlugin() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('notification_icon_android2');
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
            onDidReceiveLocalNotification: (_, __, ___, ____) {});

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );
    final isInitialized = await plugin.initialize(
      initializationSettings,
      onDidReceiveBackgroundNotificationResponse: onNotificationActionReceived,
      onDidReceiveNotificationResponse: onNotificationActionReceived,
    );

    return isInitialized ?? false;
  }

  NotificationResponse? _initialAction;

  @override
  NotificationResponse? get initialAction {
    final currentAction = _initialAction;
    Future.delayed(
      Duration(seconds: initialActionResetTimeoutInSeconds),
      () => _initialAction = null,
    );
    return currentAction;
  }

  @override
  Future<NotificationResponse?> init() async {
    final isInitialized = await initNotificationPlugin();
    if (!isInitialized) {
      throw Exception('Failed to initialize notification plugin');
    }

    final appLaunchDetails = await plugin.getNotificationAppLaunchDetails();

    if (appLaunchDetails?.didNotificationLaunchApp ?? false) {
      _initialAction = appLaunchDetails!.notificationResponse;
    }

    return _initialAction;
  }

  @override
  Future<bool> checkNotificationPermission() async {
    bool? hasPermission;
    try {
      hasPermission = await _requestPermission();
    } catch (e) {
      print("Error setting up notifications: $e");
    }

    return hasPermission ?? false;
  }

  Future<bool?> _requestPermission() async {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return await plugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
      case TargetPlatform.macOS:
        return await plugin
            .resolvePlatformSpecificImplementation<
                MacOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
      case TargetPlatform.android:
        return await plugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
      default:
    }
    return null;
  }

  @pragma('vm:entry-point')
  static Future<void> onNotificationActionReceived(
      NotificationResponse action) async {
    runNotificationPayLoadsNoContext(action.payload ?? '');
  }

  int _notificationCount = 1;

  @override
  Future<int?> createNotification({
    required NotificationData content,
    NotificationType type = NotificationType.alert,
    String? payload,
  }) async {
    final hasPermission = await checkNotificationPermission();
    if (!hasPermission) {
      return null;
    }

    final config = _getConfigByType(type);

    final NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        config.channelId,
        config.channelName,
        silent: config.silent,
        importance: Importance.max,
        priority: Priority.high,
        color: content.color,
      ),
    );

    try {
      final notificationId = _notificationCount++;

      await plugin.show(
        notificationId,
        content.title,
        content.body,
        notificationDetails,
        payload: payload,
      );

      return notificationId;
    } catch (e) {
      _notificationCount--;
      return null;
    }
  }

  Future<int?> scheduleNotification({
    required NotificationData content,
    NotificationType type = NotificationType.alert,
    required TZDateTime schedule,
    String? payload,
    bool recurring = false,
  }) async {
    final hasPermission = await checkNotificationPermission();
    if (!hasPermission) {
      return null;
    }

    final config = _getConfigByType(type);

    final NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        config.channelId,
        config.channelName,
        silent: config.silent,
        importance: Importance.max,
        priority: Priority.high,
        color: content.color,
      ),
    );

    if (!schedule.isAfter(DateTime.now())) {
      print("Scheduling notification with previous date");
      return null;
    }

    try {
      final notificationId = _notificationCount++;

      await plugin.zonedSchedule(
        notificationId,
        content.title,
        content.body,
        schedule,
        notificationDetails,
        payload: payload,
        matchDateTimeComponents:
            recurring ? DateTimeComponents.dateAndTime : null,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      return notificationId;
    } catch (e) {
      _notificationCount--;
      return null;
    }
  }

  AndroidNotificationDetails _getConfigByType(NotificationType type) {
    final String channelId, channelName;
    final bool isSilent;

    switch (type) {
      case NotificationType.debitTransaction:
      case NotificationType.creditTransaction:
        isSilent = true;
        channelId = 'newTransaction';
        channelName = 'New Transaction';
      default:
        isSilent = false;
        channelId = 'alert';
        channelName = 'Alert';
    }

    return AndroidNotificationDetails(channelId, channelName, silent: isSilent);
  }

  @override
  Future<void> cancelNotification(int id) async {
    await plugin.cancel(id);
  }

  @override
  Future<void> cancelAllNotifications() async {
    await plugin.cancelAll();
  }

  @override
  Future<bool> scheduleDailyNotification(
      BuildContext context, TimeOfDay timeOfDay,
      {bool scheduleNowDebug = false}) async {
    // If the app was opened on the day the notification was scheduled it will be
    // cancelled and set to the next day because of _nextInstanceOfSetTime
    // If ReminderNotificationType.Everyday is not true
    await cancelDailyNotification();

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'transactionReminders',
      'Transaction Reminders',
      importance: Importance.max,
      priority: Priority.high,
      color: Theme.of(context).colorScheme.primary,
    );

    DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(threadIdentifier: 'transactionReminders');

    // schedule 2 weeks worth of notifications
    for (int i = (ReminderNotificationType
                    .values[appStateSettings["notificationsReminderType"]] ==
                ReminderNotificationType.Everyday
            ? 0
            : 1);
        i <= 14;
        i++) {
      String chosenMessage =
          reminderStrings[Random().nextInt(reminderStrings.length)].tr();
      TZDateTime dateTime = _nextInstanceOfSetTime(timeOfDay, dayOffset: i);
      if (scheduleNowDebug)
        dateTime = TZDateTime.now(local).add(Duration(seconds: i * 5));
      NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: darwinNotificationDetails,
      );
      // TODO: Implement schedule notification for daily reminders
      await plugin.zonedSchedule(
        i,
        'notification-reminder-title'.tr(),
        chosenMessage,
        dateTime,
        notificationDetails,
        androidAllowWhileIdle: true,
        payload: 'addTransaction',
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,

        // If exact time was used, need USE_EXACT_ALARM and SCHEDULE_EXACT_ALARM permissions
        // which are only meant for calendar/reminder based applications
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
      print("Notification " +
          chosenMessage +
          " scheduled for " +
          dateTime.toString() +
          " with id " +
          i.toString());
    }

    // final List<PendingNotificationRequest> pendingNotificationRequests =
    //     await notificationPlugin.pendingNotificationRequests();

    return true;
  }

  TZDateTime _nextInstanceOfSetTime(TimeOfDay timeOfDay, {int dayOffset = 0}) {
    final TZDateTime now = TZDateTime.now(local);
    // TZDateTime scheduledDate = TZDateTime(
    //     local, now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    // if (scheduledDate.isBefore(now)) {
    //   scheduledDate = scheduledDate.add(const Duration(days: 1));
    // }

    // add one to current day (if app wasn't opened, it will notify)
    TZDateTime scheduledDate = TZDateTime(local, now.year, now.month,
        now.day + dayOffset, timeOfDay.hour, timeOfDay.minute);

    return scheduledDate;
  }

  @override
  Future<bool> cancelDailyNotification() async {
    // Need to cancel all, including the one at 0 - even if it does not exist
    for (int i = 0; i <= 14; i++) {
      await plugin.cancel(i);
    }
    print("Cancelled notifications for daily reminder");
    return true;
  }

  @override
  Future<bool> scheduleUpcomingTransactionsNotification(context) async {
    await cancelUpcomingTransactionsNotification();

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'upcomingTransactions',
      'Upcoming Transactions',
      importance: Importance.max,
      priority: Priority.high,
      color: Theme.of(context).colorScheme.primary,
    );

    DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(threadIdentifier: 'upcomingTransactions');

    // print(upcomingTransactions);
    int idStart = 100;
    for (Transaction upcomingTransaction in await _upcomingTransactions) {
      idStart++;
      // Note: if upcomingTransactionNotification is NULL the loop will continue and schedule a notification
      if (upcomingTransaction.upcomingTransactionNotification == false)
        continue;
      if (upcomingTransaction.dateCreated.year == DateTime.now().year &&
          upcomingTransaction.dateCreated.month == DateTime.now().month &&
          upcomingTransaction.dateCreated.day == DateTime.now().day &&
          (upcomingTransaction.dateCreated.hour < DateTime.now().hour ||
              (upcomingTransaction.dateCreated.hour == DateTime.now().hour &&
                  upcomingTransaction.dateCreated.minute <=
                      DateTime.now().minute))) {
        continue;
      }
      String chosenMessage = await getTransactionLabel(upcomingTransaction);
      TZDateTime dateTime = TZDateTime(
        local,
        upcomingTransaction.dateCreated.year,
        upcomingTransaction.dateCreated.month,
        upcomingTransaction.dateCreated.day,
        upcomingTransaction.dateCreated.hour,
        upcomingTransaction.dateCreated.minute,
      );
      NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: darwinNotificationDetails,
      );
      if (upcomingTransaction.dateCreated.isAfter(DateTime.now())) {
        await plugin.zonedSchedule(
          idStart,
          'notification-upcoming-transaction-title'.tr(),
          chosenMessage,
          dateTime,
          notificationDetails,
          androidAllowWhileIdle: true,
          payload: 'upcomingTransaction',
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,

          // If exact time was used, need USE_EXACT_ALARM and SCHEDULE_EXACT_ALARM permissions
          // which are only meant for calendar/reminder based applications
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      } else {
        print("Cannot set up notification before current time!");
      }

      print("Notification " +
          chosenMessage +
          " scheduled for " +
          dateTime.toString() +
          " with id " +
          upcomingTransaction.transactionPk.toString());
    }

    return true;
  }

  Future<List<Transaction>> get _upcomingTransactions async =>
      await database.getAllUpcomingTransactions(
        startDate: DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day - 1),
        endDate: DateTime(DateTime.now().year, DateTime.now().month,
            DateTime.now().day + 365),
      );

  @override
  Future<bool> cancelUpcomingTransactionsNotification() async {
    int upcomingTransactionCount = (await _upcomingTransactions).length;
    for (var i = 100; i <= upcomingTransactionCount; i++) {
      await plugin.cancel(i);
    }
    print("Cancelled notifications for upcoming");
    return true;
  }
}
