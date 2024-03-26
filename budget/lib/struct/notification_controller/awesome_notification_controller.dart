import 'dart:isolate';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:budget/struct/notification_controller/controller_utils.dart'
    as utils;
import 'package:budget/struct/notification_controller/notification_controller.dart';
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
      for (var type in utils.NotificationType.values) {
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

  int _notificationCount = 1;

  @override
  Future<int?> createNotification({
    required utils.NotificationContent content,
    utils.NotificationType type = utils.NotificationType.alert,
    Map<String, String?>? payload,
  }) async {
    final hasPermission = await checkNotificationPermission();

    if (!hasPermission) {
      return null;
    }

    final isCreated = await plugin.createNotification(
      content: NotificationContent(
        id: _notificationCount,
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

    return isCreated ? _notificationCount++ : null;
  }

  @override
  Future<int?> scheduleNotification({
    required utils.NotificationContent content,
    utils.NotificationType type = utils.NotificationType.alert,
    required NotificationCalendar schedule,
    Map<String, String?>? payload,
    bool recurring = false,
  }) async {
    final hasPermission = await checkNotificationPermission();

    if (!hasPermission) {
      return null;
    }

    final isCreated = await plugin.createNotification(
      content: NotificationContent(
        id: _notificationCount,
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

    return isCreated ? _notificationCount++ : null;
  }
}

extension NotificationTypeExt on utils.NotificationType {
  NotificationChannel get channel {
    switch (this) {
      case utils.NotificationType.creditTransaction:
      case utils.NotificationType.debitTransaction:
      case utils.NotificationType.transfer:
        return NotificationChannel(
          channelKey: 'silentNotifications',
          channelName: 'Silent Notifications',
          channelDescription: 'Silent Notification',
          onlyAlertOnce: true,
          enableVibration: false,
          importance: NotificationImportance.Low,
          defaultPrivacy: NotificationPrivacy.Private,
          groupAlertBehavior: GroupAlertBehavior.Children,
        );
      case utils.NotificationType.alert:
      case utils.NotificationType.reminder:
      default:
        return NotificationChannel(
          channelKey: 'alerts',
          channelName: 'Alerts',
          channelDescription: 'Alert Notification',
          onlyAlertOnce: true,
          importance: NotificationImportance.High,
          defaultPrivacy: NotificationPrivacy.Public,
          groupAlertBehavior: GroupAlertBehavior.Children,
        );
    }
  }

  List<NotificationActionButton> get actionButtons {
    switch (this) {
      case utils.NotificationType.creditTransaction:
      case utils.NotificationType.debitTransaction:
      case utils.NotificationType.transfer:
        return [
          NotificationActionButton(
            key: 'EDIT',
            label: 'Edit',
          ),
          NotificationActionButton(
            key: 'DONE',
            label: 'Done',
            actionType: ActionType.DismissAction,
          ),
        ];
      case utils.NotificationType.alert:
      case utils.NotificationType.reminder:
      default:
        return [];
    }
  }
}
