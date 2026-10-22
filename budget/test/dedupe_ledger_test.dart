import 'package:budget/struct/dedupeLedger.dart';
import 'package:budget/struct/notificationDispatcher.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notification_listener_service/notification_event.dart';

ServiceNotificationEvent createTestNotification({
  int id = 1,
  String packageName = 'com.google.android.apps.walletnfcrel',
  String title = 'Google Wallet',
  String content = 'Paid PHP 250.00 at 7-Eleven',
  bool hasRemoved = false,
  int timestamp = 0,
}) {
  return ServiceNotificationEvent(
    id: id,
    packageName: packageName,
    title: title,
    content: content,
    hasRemoved: hasRemoved,
    canReply: false,
    haveExtraPicture: false,
    onGoing: false,
    timestamp: timestamp,
    appIcon: null,
    extrasPicture: null,
    largeIcon: null,
  );
}

void main() {
  group('DedupeLedger helper methods', () {
    test('normalizeAmount formats numbers to two decimal places', () {
      expect(DedupeLedger.normalizeAmount(250.0), equals('250.00'));
      expect(DedupeLedger.normalizeAmount(1000), equals('1000.00'));
      expect(DedupeLedger.normalizeAmount(49.994), equals('49.99'));
      expect(DedupeLedger.normalizeAmount(49.996), equals('50.00'));
      expect(DedupeLedger.normalizeAmount(null), isNull);
    });

    test('generateExactNotificationKey builds expected format', () {
      final key = DedupeLedger.generateExactNotificationKey(
        'com.google.android.apps.walletnfcrel',
        '1001',
      );
      expect(key, equals('notif:com.google.android.apps.walletnfcrel:1001'));
    });

    test('generatePaymentKey builds expected format', () {
      final key = DedupeLedger.generatePaymentKey(
        amount: 250.0,
        currency: 'PHP',
      );
      expect(key, equals('pay:250.00:PHP'));
    });
  });

  group('DedupeLedger Exact Notification Matching (Tier 1)', () {
    late DedupeLedger ledger;

    setUp(() {
      ledger = DedupeLedger();
    });

    test('first notification is unique and recorded as created', () async {
      final now = DateTime(2026, 10, 22, 12, 0, 0);
      final result = await ledger.checkAndRecordNotification(
        packageName: 'com.google.android.apps.walletnfcrel',
        notificationId: '42',
        amount: 250.0,
        currency: 'PHP',
        title: '7-Eleven',
        eventTime: now,
      );

      expect(result.isDuplicate, isFalse);
      expect(ledger.entries.length, equals(1));
      expect(ledger.entries.first.status, equals('created'));
      expect(ledger.entries.first.packageName,
          equals('com.google.android.apps.walletnfcrel'));
      expect(ledger.entries.first.notificationId, equals('42'));
    });

    test('second notification with same package and id within 5 min is duplicate',
        () async {
      final t0 = DateTime(2026, 10, 22, 12, 0, 0);
      final t1 = t0.add(const Duration(minutes: 2));

      await ledger.checkAndRecordNotification(
        packageName: 'com.google.android.apps.walletnfcrel',
        notificationId: '42',
        amount: 250.0,
        currency: 'PHP',
        title: '7-Eleven',
        eventTime: t0,
      );

      final secondResult = await ledger.checkAndRecordNotification(
        packageName: 'com.google.android.apps.walletnfcrel',
        notificationId: '42',
        amount: 250.0,
        currency: 'PHP',
        title: '7-Eleven',
        eventTime: t1,
      );

      expect(secondResult.isDuplicate, isTrue);
      expect(secondResult.matchReason, equals('exact_notification'));
      expect(ledger.suppressedEntries.length, equals(1));
      expect(ledger.suppressedEntries.first.status, equals('suppressed'));
    });

    test('same notification package and id outside 5 min window is allowed',
        () async {
      final t0 = DateTime(2026, 10, 22, 12, 0, 0);
      final tAfter = t0.add(const Duration(minutes: 6));

      await ledger.checkAndRecordNotification(
        packageName: 'com.google.android.apps.walletnfcrel',
        notificationId: '42',
        amount: 250.0,
        currency: 'PHP',
        title: '7-Eleven',
        eventTime: t0,
      );

      final afterWindowResult = await ledger.checkAndRecordNotification(
        packageName: 'com.google.android.apps.walletnfcrel',
        notificationId: '42',
        amount: 250.0,
        currency: 'PHP',
        title: '7-Eleven',
        eventTime: tAfter,
      );

      expect(afterWindowResult.isDuplicate, isFalse);
      expect(ledger.entries.length, equals(2));
    });
  });

  group('DedupeLedger Cross-Package Payment Matching (Tier 2)', () {
    late DedupeLedger ledger;

    setUp(() {
      ledger = DedupeLedger();
    });

    test(
        'Google Pay event followed by Bank notification for same amount within window is duplicate',
        () async {
      final t0 = DateTime(2026, 10, 22, 14, 0, 0);
      final tBank = t0.add(const Duration(seconds: 45));

      // 1. Google Wallet notification arrives
      final gpayResult = await ledger.checkAndRecordNotification(
        packageName: 'com.google.android.apps.walletnfcrel',
        notificationId: '1001',
        amount: 500.0,
        currency: 'PHP',
        title: 'Google Wallet Purchase',
        rawContent: 'Paid PHP 500.00 at Shell Gas',
        eventTime: t0,
      );
      expect(gpayResult.isDuplicate, isFalse);

      // 2. Bank notification arrives (e.g. Maya or GoTyme) with different package and ID
      final bankResult = await ledger.checkAndRecordNotification(
        packageName: 'com.gotyme',
        notificationId: '5555',
        amount: 500.0,
        currency: 'PHP',
        title: 'GoTyme Purchase',
        rawContent: 'You paid ₱500.00 at Shell Gas',
        eventTime: tBank,
      );

      expect(bankResult.isDuplicate, isTrue);
      expect(bankResult.matchReason, equals('payment_window_match'));
      expect(ledger.suppressedEntries.length, equals(1));
    });

    test(
        'different amounts within window are not marked duplicate',
        () async {
      final t0 = DateTime(2026, 10, 22, 14, 0, 0);
      final tBank = t0.add(const Duration(seconds: 30));

      await ledger.checkAndRecordNotification(
        packageName: 'com.google.android.apps.walletnfcrel',
        notificationId: '1001',
        amount: 500.0,
        currency: 'PHP',
        title: 'Google Wallet Purchase',
        eventTime: t0,
      );

      final differentAmountResult = await ledger.checkAndRecordNotification(
        packageName: 'com.gotyme',
        notificationId: '5555',
        amount: 350.0,
        currency: 'PHP',
        title: 'GoTyme Purchase',
        eventTime: tBank,
      );

      expect(differentAmountResult.isDuplicate, isFalse);
      expect(ledger.entries.length, equals(2));
    });

    test(
        'Apple Pay Shortcut / App Link retry firing twice within 5 min is suppressed',
        () async {
      final t0 = DateTime(2026, 10, 22, 15, 0, 0);
      final tRetry = t0.add(const Duration(seconds: 1));

      final firstLink = await ledger.checkAndRecordPayment(
        amount: 150.0,
        currency: 'PHP',
        title: 'Starbucks Coffee',
        source: 'app_link',
        eventTime: t0,
      );
      expect(firstLink.isDuplicate, isFalse);

      final secondLink = await ledger.checkAndRecordPayment(
        amount: 150.0,
        currency: 'PHP',
        title: 'Starbucks Coffee',
        source: 'app_link',
        eventTime: tRetry,
      );
      expect(secondLink.isDuplicate, isTrue);
      expect(secondLink.matchReason, equals('payment_window_match'));
    });
  });

  group('NotificationDispatcher with DedupeLedger Integration', () {
    late NotificationDispatcher dispatcher;
    late DedupeLedger ledger;

    setUp(() {
      ledger = DedupeLedger();
      DedupeLedger.instance = ledger;
      dispatcher = NotificationDispatcher.instance;
      dispatcher.recentCapturedNotifications.clear();
      dispatcher.queueHandler = null;
      dispatcher.onGooglePayTransaction = null;
    });

    test(
        'NotificationDispatcher suppresses exact duplicate event from reaching queue handler',
        () async {
      final event1 = createTestNotification(
        id: 77,
        packageName: 'com.gotyme',
        title: 'GoTyme Transfer',
        content: 'Transferred ₱1,200.00 to Maya',
      );

      final event2 = createTestNotification(
        id: 77,
        packageName: 'com.gotyme',
        title: 'GoTyme Transfer',
        content: 'Transferred ₱1,200.00 to Maya',
      );

      int queueCount = 0;
      Future<void> queueHandler(
        String msg, {
        DateTime? dateTime,
        bool willPushRoute = true,
      }) async {
        queueCount++;
      }

      // First delivery
      final firstHandled = await dispatcher.handleEvent(
        event1,
        customQueueHandler: queueHandler,
      );
      expect(firstHandled, isTrue);
      expect(queueCount, equals(1));

      // Second delivery (duplicate)
      final secondHandled = await dispatcher.handleEvent(
        event2,
        customQueueHandler: queueHandler,
      );
      expect(secondHandled, isFalse);
      expect(queueCount, equals(1)); // Queue handler was not called again
      expect(ledger.suppressedEntries.length, equals(1));
    });

    test(
        'NotificationDispatcher suppresses duplicate Google Pay event within 5 min window',
        () async {
      final gpayEvent1 = createTestNotification(
        id: 88,
        packageName: 'com.google.android.apps.walletnfcrel',
        title: 'Google Wallet',
        content: 'Paid PHP 250.00 at 7-Eleven with UnionBank **1234',
      );

      final gpayEvent2 = createTestNotification(
        id: 88,
        packageName: 'com.google.android.apps.walletnfcrel',
        title: 'Google Wallet',
        content: 'Paid PHP 250.00 at 7-Eleven with UnionBank **1234',
      );

      int gpayDispatchCount = 0;
      dispatcher.onGooglePayTransaction = (result) async {
        gpayDispatchCount++;
        return true;
      };

      final handled1 = await dispatcher.handleEvent(gpayEvent1);
      expect(handled1, isTrue);
      expect(gpayDispatchCount, equals(1));

      final handled2 = await dispatcher.handleEvent(gpayEvent2);
      expect(handled2, isFalse);
      expect(gpayDispatchCount, equals(1)); // Did not fire a second transaction
      expect(ledger.suppressedEntries.length, equals(1));
    });
  });
}
