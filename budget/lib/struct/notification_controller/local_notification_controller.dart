import 'package:budget/struct/initializeNotifications.dart';
import 'package:budget/struct/notification_controller/notification_controller.dart';
import 'package:flutter/foundation.dart';

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
    required NotificationContent content,
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
    required NotificationContent content,
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
}
