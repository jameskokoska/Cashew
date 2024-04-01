import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/notification_controller/awesome_notifications/extensions.dart';
import 'package:budget/struct/notification_controller/models.dart';
import 'package:budget/struct/notification_controller/notification_controller.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/notificationsSettings.dart';
import 'package:budget/widgets/transactionEntry/transactionLabel.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AwesomeNotificationController extends NotificationController<
    ReceivedAction, Map<String, String?>, NotificationCalendar> {
  AwesomeNotificationController._();

  static final AwesomeNotificationController _instance =
      AwesomeNotificationController._();

  static AwesomeNotificationController get instance => _instance;

  static AwesomeNotifications _plugin = AwesomeNotifications();

  static AwesomeNotifications get plugin => _plugin;

  ReceivedAction? _initialAction;
  @override
  ReceivedAction? get initialAction => _initialAction;

  String get _defaultIcon => 'resource://drawable/notification_icon_android2';

  List<NotificationChannel> _channels = [];

  List<NotificationChannel> get channels {
    if (_channels.isEmpty) {
      final Set<String> channelSet = {};
      for (var type in NotificationType.values) {
        final channel = type.channel;
        if (!channelSet.contains(channel.channelKey)) {
          channelSet.add(channel.channelKey!);
          _channels.add(channel);
        }
      }
    }

    return _channels;
  }

  @override
  Future<bool> initNotificationPlugin() async {
    bool isInitialized = false;
    try {
      isInitialized = await plugin.initialize(
        _defaultIcon,
        channels,
        debug: true,
      );
    } catch (e, s) {
      debugPrintStack(
        stackTrace: s,
        label: 'Error initializing notification plugin: $e',
      );
    }

    return isInitialized;
  }

  static ReceivePort? receivePort;

  Future<void> initializeIsolateReceivePort() async {
    receivePort = ReceivePort('notification_recieve_port')
      ..listen((silentData) => handleNotificationAction(silentData));

    // This initialization only happens on main isolate
    IsolateNameServer.registerPortWithName(
      receivePort!.sendPort,
      'notification_action_port',
    );
  }

  @override
  Future<ReceivedAction?> init() async {
    final isInitialized = await initNotificationPlugin();

    if (!isInitialized) {
      throw Exception('Failed to initialize notification plugin');
    }

    await initializeIsolateReceivePort();

    // Get initial notification action is optional
    _initialAction = await plugin
        .getInitialNotificationAction(removeFromActionEvents: false)
        .timeout(Duration(seconds: 2));

    await plugin.setListeners(onActionReceivedMethod: onActionReceivedMethod);

    return _initialAction;
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    if (receivedAction.actionType == ActionType.SilentAction ||
        receivedAction.actionType == ActionType.SilentBackgroundAction) {
      // For background actions, you must hold the execution until the end
      print(
          'Message sent via notification input: "${receivedAction.buttonKeyInput}"');
    } else {
      // this process is only necessary when you need to redirect the user
      // to a new page or use a valid context, since parallel isolates do not
      // have valid context, so you need redirect the execution to main isolate
      if (receivePort == null) {
        // check for main isolate, if null then it is a parallel isolate
        print('onActionReceivedMethod was called in parallel dart isolate.');
        SendPort? sendPort =
            IsolateNameServer.lookupPortByName('notification_action_port');

        if (sendPort != null) {
          print('Redirecting the execution to main isolate process.');
          sendPort.send(receivedAction);
          return;
        }
      }

      return handleNotificationAction(receivedAction);
    }
  }

  static Future<void> handleNotificationAction(ReceivedAction action) async {
    print("handleNotificationAction: $action");
  }

  @override
  Future<bool> checkNotificationPermission() async {
    bool isAllowed = await plugin.isNotificationAllowed();

    if (!isAllowed) {
      isAllowed = await plugin.requestPermissionToSendNotifications();
    }

    return isAllowed;
  }

  @override
  Future<void> cancelAllNotifications() async {
    await plugin.cancelAll();
  }

  @override
  Future<void> cancelNotification(int id) async {
    await plugin.cancel(id);
  }

  int _notificationCount = 1000;

  @override
  Future<int?> createNotification({
    int? id,
    required NotificationData content,
    NotificationType type = NotificationType.alert,
    Map<String, String?>? payload,
  }) async {
    final hasPermission = await checkNotificationPermission();

    if (!hasPermission) {
      return null;
    }

    final notificationId = id ?? _notificationCount;

    final isCreated = await plugin.createNotification(
      content: NotificationContent(
        id: notificationId,
        channelKey: type.channel.channelKey ?? 'alerts',
        title: content.title,
        body: content.body,
        summary: content.summary,
        largeIcon: content.largeIcon,
        color: content.color,
        backgroundColor: content.color,
        payload: payload,
      ),
      actionButtons: type.actionButtons
          .map(
            (e) => NotificationActionButton(
              key: e.key!,
              label: e.label!,
              actionType: e.actionType ?? ActionType.Default,
              color: content.color,
            ),
          )
          .toList(),
    );

    if (isCreated && notificationId == _notificationCount) {
      _notificationCount++;
    }

    return isCreated ? notificationId : null;
  }

  @override
  Future<int?> scheduleNotification({
    int? id,
    required NotificationData content,
    NotificationType type = NotificationType.alert,
    required NotificationCalendar schedule,
    Map<String, String?>? payload,
    bool recurring = false,
  }) async {
    final hasPermission = await checkNotificationPermission();

    if (!hasPermission) {
      return null;
    }
    final notificationId = id ?? _notificationCount;

    final isCreated = await plugin.createNotification(
      content: NotificationContent(
        id: notificationId,
        channelKey: type.channel.channelKey ?? 'alerts',
        title: content.title,
        body: content.body,
        largeIcon: content.largeIcon,
        color: content.color,
        payload: payload,
      ),
      actionButtons: type.actionButtons,
      schedule: schedule,
    );

    if (isCreated && notificationId == _notificationCount) {
      _notificationCount++;
    }

    return isCreated ? notificationId : null;
  }

  Future<bool> scheduleDailyNotification(
      BuildContext context, TimeOfDay timeOfDay,
      {bool scheduleNowDebug = false}) async {
    // If the app was opened on the day the notification was scheduled it will be
    // cancelled and set to the next day because of _nextInstanceOfSetTime
    // If ReminderNotificationType.Everyday is not true
    await cancelDailyNotification();

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
      final now = DateTime.now();
      var dateTime = DateTime(
        now.year,
        now.month,
        now.day + i,
        timeOfDay.hour,
        timeOfDay.minute,
      );
      if (scheduleNowDebug) dateTime = now.add(Duration(seconds: i * 5));

      await scheduleNotification(
        id: i,
        content: NotificationData(
          title: 'notification-reminder-title'.tr(),
          body: chosenMessage,
          color: Theme.of(context).colorScheme.primary,
        ),
        payload: {
          'type': 'addTransaction',
        },
        schedule: NotificationCalendar(
          day: dateTime.day,
          hour: dateTime.hour,
          minute: dateTime.minute,
          allowWhileIdle: true,
        ),
      );
      print("Notification " +
          chosenMessage +
          " scheduled for " +
          dateTime.toString() +
          " with id " +
          i.toString());
    }

    return true;
  }

  Future<bool> cancelDailyNotification() async {
    // Need to cancel all, including the one at 0 - even if it does not exist
    for (int i = 0; i <= 14; i++) {
      await plugin.cancel(i);
    }
    print("Cancelled notifications for daily reminder");
    return true;
  }

  Future<bool> scheduleUpcomingTransactionsNotification(context) async {
    await cancelUpcomingTransactionsNotification();

    int idStart = 100;
    for (Transaction upcomingTransaction in await _upcomingTransactions) {
      idStart++;
      // Note: if upcomingTransactionNotification is NULL the loop will continue and schedule a notification
      if (upcomingTransaction.upcomingTransactionNotification == false)
        continue;
      if (upcomingTransaction.dateCreated.isBefore(DateTime.now())) {
        continue;
      }
      String chosenMessage = await getTransactionLabel(upcomingTransaction);

      final dateTime = upcomingTransaction.dateCreated;
      if (dateTime.isAfter(DateTime.now())) {
        await scheduleNotification(
          id: idStart,
          content: NotificationData(
            title: 'notification-upcoming-transaction-title'.tr(),
            body: chosenMessage,
            color: Theme.of(context).colorScheme.primary,
          ),
          payload: {
            'type': 'upcomingTransaction',
          },
          schedule: NotificationCalendar(
            year: dateTime.year,
            month: dateTime.month,
            day: dateTime.day,
            hour: dateTime.hour,
            minute: dateTime.minute,
            allowWhileIdle: true,
          ),
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
        startDate: DateTime.now().subtract(Duration(days: 1)),
        endDate: DateTime.now().add(Duration(days: 365)),
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
