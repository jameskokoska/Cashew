import 'package:budget/struct/dedupeLedger.dart';
import 'package:budget/struct/notificationDispatcher.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notification_listener_service/notification_event.dart';

ServiceNotificationEvent createTestEvent({
  int id = 1,
  String packageName = 'com.example.bank',
  String title = 'Notification Title',
  String content = 'Notification Content',
  bool hasRemoved = false,
  bool canReply = false,
  bool haveExtraPicture = false,
  bool onGoing = false,
  int timestamp = 0,
}) {
  return ServiceNotificationEvent(
    id: id,
    packageName: packageName,
    title: title,
    content: content,
    hasRemoved: hasRemoved,
    canReply: canReply,
    haveExtraPicture: haveExtraPicture,
    onGoing: onGoing,
    timestamp: timestamp,
    appIcon: null,
    extrasPicture: null,
    largeIcon: null,
  );
}

void main() {
  group('NotificationDispatcher.formatNotificationMessage', () {
    test(
      'formats event details according to Cashew standard notification format',
      () {
        final event = createTestEvent(
          id: 42,
          packageName: 'com.google.android.apps.walletnfcrel',
          title: 'Google Wallet Payment',
          content: 'Paid PHP 250.00 at Merchant',
          hasRemoved: false,
        );

        final formatted =
            NotificationDispatcher.formatNotificationMessage(event);

        expect(
          formatted,
          contains('Package name: com.google.android.apps.walletnfcrel\n'),
        );
        expect(
          formatted,
          contains('Notification removed: false\n'),
        );
        expect(
          formatted,
          contains('Notification Title: Google Wallet Payment\n\n'),
        );
        expect(
          formatted,
          contains('Notification Content: Paid PHP 250.00 at Merchant'),
        );
      },
    );
  });

  group('NotificationDispatcher.handleEvent with Bank Fixtures', () {
    late NotificationDispatcher dispatcher;

    setUp(() {
      DedupeLedger.instance.clear();
      dispatcher = NotificationDispatcher.instance;
      dispatcher.recentCapturedNotifications.clear();
      dispatcher.queueHandler = null;
    });

    test(
      'processes GoTyme bank sample fixture and ignores subsequent dismissal',
      () async {
        // Redacted sample based on .scratch/bank-samples/gotyme/sample-receipt.md
        final gotymePosted = createTestEvent(
          id: 101,
          packageName: 'com.gotyme',
          title: 'GoTyme Bank Transfer',
          content:
              'Transferred ₱3,600.00 to MariBank Philippines. Ref: ITO261019143038004',
          hasRemoved: false,
        );

        final gotymeRemoved = createTestEvent(
          id: 101,
          packageName: 'com.gotyme',
          title: 'GoTyme Bank Transfer',
          content:
              'Transferred ₱3,600.00 to MariBank Philippines. Ref: ITO261019143038004',
          hasRemoved: true,
        );

        int queueCount = 0;
        String? capturedMessage;

        Future<void> queueHandler(
          String msg, {
          DateTime? dateTime,
          bool willPushRoute = true,
        }) async {
          queueCount++;
          capturedMessage = msg;
        }

        // 1. Notification arrived (posted)
        final handledPosted = await dispatcher.handleEvent(
          gotymePosted,
          customQueueHandler: queueHandler,
        );

        expect(handledPosted, isTrue);
        expect(queueCount, equals(1));
        expect(capturedMessage, contains('Package name: com.gotyme'));
        expect(capturedMessage, contains('₱3,600.00'));
        expect(dispatcher.recentCapturedNotifications.length, equals(1));

        // 2. Notification dismissed (removed)
        final handledRemoved = await dispatcher.handleEvent(
          gotymeRemoved,
          customQueueHandler: queueHandler,
        );

        expect(handledRemoved, isFalse);
        expect(queueCount, equals(1));
        expect(dispatcher.recentCapturedNotifications.length, equals(1));
      },
    );

    test(
      'processes MariBank sample fixture and suppresses duplicate on dismissal',
      () async {
        // Redacted sample based on .scratch/bank-samples/maribank/sample-receipt-app.md
        final maribankPosted = createTestEvent(
          id: 202,
          packageName: 'com.maribank',
          title: 'MariBank Transfer Sent',
          content:
              'Sent PHP 1,000.00 to Kid Omar Costelo (Maya Wallet). Ref: 454658',
          hasRemoved: false,
        );

        final maribankDismissed = createTestEvent(
          id: 202,
          packageName: 'com.maribank',
          title: 'MariBank Transfer Sent',
          content:
              'Sent PHP 1,000.00 to Kid Omar Costelo (Maya Wallet). Ref: 454658',
          hasRemoved: true,
        );

        int dispatchCount = 0;
        final handledPosted = await dispatcher.handleEvent(
          maribankPosted,
          customQueueHandler: (msg, {dateTime, willPushRoute = true}) async {
            dispatchCount++;
          },
        );

        expect(handledPosted, isTrue);
        expect(dispatchCount, equals(1));

        final handledDismissed = await dispatcher.handleEvent(
          maribankDismissed,
          customQueueHandler: (msg, {dateTime, willPushRoute = true}) async {
            dispatchCount++;
          },
        );

        expect(handledDismissed, isFalse);
        expect(dispatchCount, equals(1));
      },
    );

    test(
      'processes Maya sample fixture correctly',
      () async {
        // Redacted sample based on .scratch/bank-samples/maya/sample-receipt.md
        final mayaPosted = createTestEvent(
          id: 303,
          packageName: 'com.maya',
          title: 'Money Sent',
          content: 'You sent ₱100.00 to RICA T. Ref: 456C6B393301',
          hasRemoved: false,
        );

        String? dispatchedMsg;
        final handled = await dispatcher.handleEvent(
          mayaPosted,
          customQueueHandler: (msg, {dateTime, willPushRoute = true}) async {
            dispatchedMsg = msg;
          },
        );

        expect(handled, isTrue);
        expect(dispatchedMsg, contains('Package name: com.maya'));
        expect(dispatchedMsg, contains('₱100.00'));
        expect(dispatcher.recentCapturedNotifications.length, equals(1));
      },
    );
  });

  group('NotificationDispatcher.addCapturedNotification capping', () {
    test(
      'caps recentCapturedNotifications to 50 items',
      () {
        final dispatcher = NotificationDispatcher.instance;
        dispatcher.recentCapturedNotifications.clear();

        for (int i = 0; i < 60; i++) {
          dispatcher.addCapturedNotification('Notification #$i');
        }

        expect(dispatcher.recentCapturedNotifications.length, equals(50));
        expect(
          dispatcher.recentCapturedNotifications.first,
          equals('Notification #59'),
        );
        expect(
          dispatcher.recentCapturedNotifications.last,
          equals('Notification #10'),
        );
      },
    );
  });
}
