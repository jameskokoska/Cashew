import 'dart:ui';

abstract class NotificationController<T, S, U> {
  Future<bool> initNotificationPlugin();

  T? get initialAction;

  Future<T?> init();

  Future<bool> checkNotificationPermission();

  Future<int?> createNotification({
    required NotificationContent content,
    NotificationType type = NotificationType.alert,
    S? payload,
  });

  Future<int?> scheduleNotification({
    required NotificationContent content,
    NotificationType type = NotificationType.alert,
    required U schedule,
    S? payload,
    bool recurring = false,
  });

  Future<void> cancelNotification(int id);

  Future<void> cancelAllNotifications();
}

class NotificationContent {
  final String title;
  final String? body;
  final Color? color;
  final String? largeIcon;

  NotificationContent({
    required this.title,
    this.body,
    this.color,
    this.largeIcon,
  });
}

enum NotificationType {
  alert,
  reminder,
  creditTransaction,
  debitTransaction,
  transfer
}
