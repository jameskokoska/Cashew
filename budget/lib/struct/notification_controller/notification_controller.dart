import 'package:budget/struct/notification_controller/models.dart';
import 'package:flutter/material.dart';

abstract class NotificationController<T, S, U> {
  Future<bool> initNotificationPlugin();

  T? get initialAction;

  Future<T?> init();

  Future<bool> checkNotificationPermission();

  Future<int?> createNotification({
    required NotificationData content,
    NotificationType type = NotificationType.alert,
    S? payload,
  });

  Future<int?> scheduleNotification({
    required NotificationData content,
    NotificationType type = NotificationType.alert,
    required U schedule,
    S? payload,
    bool recurring = false,
  });

  Future<void> cancelNotification(int id);

  Future<void> cancelAllNotifications();

  Future<bool> scheduleDailyNotification(
    BuildContext context,
    TimeOfDay timeOfDay, {
    bool scheduleNowDebug = false,
  });

  Future<bool> cancelDailyNotification();

  Future<bool> scheduleUpcomingTransactionsNotification(BuildContext context);

  Future<bool> cancelUpcomingTransactionsNotification();
}

List<String> reminderStrings = [
  for (int i = 1; i <= 26; i++) "notification-reminder-" + i.toString()
];
