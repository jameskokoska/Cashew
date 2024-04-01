import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:budget/struct/notification_controller/models.dart';

extension NotificationTypeExt on NotificationType {
  NotificationChannel get channel {
    switch (this) {
      case NotificationType.creditTransaction:
      case NotificationType.debitTransaction:
      case NotificationType.transfer:
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
      case NotificationType.alert:
      case NotificationType.reminder:
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
      case NotificationType.creditTransaction:
      case NotificationType.debitTransaction:
      case NotificationType.transfer:
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
      case NotificationType.alert:
      case NotificationType.reminder:
      default:
        return [];
    }
  }
}
