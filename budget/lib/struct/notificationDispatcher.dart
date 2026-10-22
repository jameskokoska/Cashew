import 'dart:async';
import 'package:budget/functions.dart';
import 'package:budget/struct/dedupeLedger.dart';
import 'package:budget/struct/googlePayParser.dart';
import 'package:budget/struct/settings.dart';
import 'package:notification_listener_service/notification_event.dart';
import 'package:notification_listener_service/notification_listener_service.dart';

typedef TransactionQueueHandler = Future<dynamic> Function(
  String messageString, {
  bool willPushRoute,
  DateTime? dateTime,
});

/// Centralized dispatcher for Android NotificationListenerService events.
///
/// Ensures a single subscription owner to avoid duplicate stream events and
/// filters out notification removal events (`hasRemoved == true`) so that
/// dismissals do not generate duplicate transactions.
class NotificationDispatcher {
  NotificationDispatcher._();
  static final NotificationDispatcher instance = NotificationDispatcher._();

  StreamSubscription<ServiceNotificationEvent>? _subscription;
  final List<String> recentCapturedNotifications = [];

  TransactionQueueHandler? queueHandler;
  Future<bool> Function(GooglePayTransactionResult)? onGooglePayTransaction;

  /// Checks if notification listener access has been granted by the user.
  Future<bool> isPermissionGranted() async {
    try {
      return await NotificationListenerService.isPermissionGranted();
    } catch (e) {
      return false;
    }
  }

  /// Requests notification listener permission via system settings.
  Future<bool> requestReadNotificationPermission() async {
    try {
      bool status = await isPermissionGranted();
      if (status != true) {
        status = await NotificationListenerService.requestPermission();
      }
      return status;
    } catch (e) {
      return false;
    }
  }

  /// Initializes the single notification listener subscription if permitted and enabled.
  Future<void> initNotificationScanning() async {
    if (getPlatform(ignoreEmulation: true) != PlatformOS.isAndroid) return;
    await stopListening();
    if (appStateSettings["notificationScanning"] != true) return;

    bool status = await requestReadNotificationPermission();
    if (status == true) {
      _subscription = NotificationListenerService.notificationsStream.listen(
        (event) => handleEvent(event),
      );
    }
  }

  /// Cancels the active stream subscription.
  Future<void> stopListening() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  /// Appends a raw message string to [recentCapturedNotifications], maintaining a max size of 50.
  void addCapturedNotification(String messageString) {
    recentCapturedNotifications.insert(0, messageString);
    if (recentCapturedNotifications.length > 50) {
      recentCapturedNotifications.removeRange(
          50, recentCapturedNotifications.length);
    }
  }

  /// Formats a [ServiceNotificationEvent] into Cashew's standard notification message string.
  static String formatNotificationMessage(ServiceNotificationEvent event) {
    String output = "";
    output = output + "Package name: " + event.packageName.toString() + "\n";
    output =
        output + "Notification removed: " + event.hasRemoved.toString() + "\n";
    output = output + "\n----\n\n";
    output = output + "Notification Title: " + event.title.toString() + "\n\n";
    output = output + "Notification Content: " + event.content.toString();
    return output;
  }

  /// Processes an incoming [ServiceNotificationEvent].
  ///
  /// Returns `true` if the event was an active notification and dispatched for
  /// transaction queuing, or `false` if ignored (e.g. `hasRemoved == true`).
  Future<bool> handleEvent(
    ServiceNotificationEvent event, {
    TransactionQueueHandler? customQueueHandler,
  }) async {
    // Ignore notification removal/dismissal events to prevent duplicate transactions.
    if (event.hasRemoved == true) {
      return false;
    }

    // Parse potential payment fields for deduplication check
    final googlePayResult = GooglePayParser.parse(event.title, event.content);
    final dedupeResult = await DedupeLedger.instance.checkAndRecordNotification(
      packageName: event.packageName,
      notificationId: event.id?.toString(),
      amount: googlePayResult?.amount,
      currency: googlePayResult?.currency,
      title: googlePayResult?.merchant ?? event.title,
      rawContent: event.content,
      eventTime: event.timestamp != null && event.timestamp! > 0
          ? DateTime.fromMillisecondsSinceEpoch(event.timestamp!)
          : null,
    );

    // Suppress duplicate events within the time window
    if (dedupeResult.isDuplicate) {
      return false;
    }

    String messageString = formatNotificationMessage(event);
    addCapturedNotification(messageString);

    // If custom queue handler was supplied (e.g. in tests), prioritize it
    if (customQueueHandler != null) {
      await customQueueHandler(messageString);
      return true;
    }

    // Check if event is from Google Wallet / Google Pay
    if (GooglePayParser.isGooglePayEvent(event)) {
      // googlePayResult was parsed above for deduplication check
      if (googlePayResult != null) {
        final gPayHandler = onGooglePayTransaction ??
            GooglePayParser.processGooglePayTransaction;
        await gPayHandler(googlePayResult);
        return true;
      }
    }

    TransactionQueueHandler? handler = queueHandler;
    if (handler != null) {
      await handler(messageString);
    }

    return true;
  }
}
