import 'package:budget/struct/notification_controller/controller_utils.dart';

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
