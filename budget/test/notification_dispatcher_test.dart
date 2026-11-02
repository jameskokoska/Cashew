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

  group('NotificationDispatcher.extractAmountAndCurrencyFromText', () {
    test('extracts prefix currency and amount', () {
      final res1 = NotificationDispatcher.extractAmountAndCurrencyFromText(
        'Transferred ₱3,600.00 to MariBank Philippines. Ref: ITO261019143038004',
      );
      expect(res1, isNotNull);
      expect(res1!.amount, equals(3600.0));
      expect(res1.currency, equals('PHP'));

      final res2 = NotificationDispatcher.extractAmountAndCurrencyFromText(
        'Sent PHP 1,000.00 to Kid Omar Costelo. Ref: 454658',
      );
      expect(res2, isNotNull);
      expect(res2!.amount, equals(1000.0));
      expect(res2.currency, equals('PHP'));

      final res3 = NotificationDispatcher.extractAmountAndCurrencyFromText(
        'Paid \$25.50 at Trader Joe\'s',
      );
      expect(res3, isNotNull);
      expect(res3!.amount, equals(25.50));
      expect(res3.currency, equals('USD'));
    });

    test('extracts suffix currency and amount', () {
      final res = NotificationDispatcher.extractAmountAndCurrencyFromText(
        'Paid 250.00 PHP at Merchant',
      );
      expect(res, isNotNull);
      expect(res!.amount, equals(250.0));
      expect(res.currency, equals('PHP'));
    });

    test('extracts monetary decimal without currency symbol', () {
      final res = NotificationDispatcher.extractAmountAndCurrencyFromText(
        'Account debited: 125.75 for transaction',
      );
      expect(res, isNotNull);
      expect(res!.amount, equals(125.75));
      expect(res.currency, isNull);
    });

    test('extracts uppercase P prefix currency and amount', () {
      final res1 = NotificationDispatcher.extractAmountAndCurrencyFromText(
        'P123.00 with UnionBank Rewards Platinum **3353',
      );
      expect(res1, isNotNull);
      expect(res1!.amount, equals(123.0));
      expect(res1.currency, equals('PHP'));

      final res2 = NotificationDispatcher.extractAmountAndCurrencyFromText(
        'P 500.00 transferred successfully',
      );
      expect(res2, isNotNull);
      expect(res2!.amount, equals(500.0));
      expect(res2.currency, equals('PHP'));
    });

    test('returns null for non-financial text with reference numbers', () {
      final res = NotificationDispatcher.extractAmountAndCurrencyFromText(
        'Your security verification code is 454658. Do not share.',
      );
      expect(res, isNull);
    });

    test(
        'returns null for words ending in P followed by numbers (OTP, Trip, Shop, Step)',
        () {
      expect(
        NotificationDispatcher.extractAmountAndCurrencyFromText(
            'Your OTP 454658 is valid for 5 mins'),
        isNull,
      );
      expect(
        NotificationDispatcher.extractAmountAndCurrencyFromText(
            'Your OTP: 987654'),
        isNull,
      );
      expect(
        NotificationDispatcher.extractAmountAndCurrencyFromText(
            'Trip 10 was completed today'),
        isNull,
      );
      expect(
        NotificationDispatcher.extractAmountAndCurrencyFromText(
            'Shop 500 deals available now'),
        isNull,
      );
      expect(
        NotificationDispatcher.extractAmountAndCurrencyFromText(
            'Step 1 to activate your card'),
        isNull,
      );
      expect(
        NotificationDispatcher.extractAmountAndCurrencyFromText(
            'Stop 50 meters ahead'),
        isNull,
      );
    });

    test(
        'returns null for non-financial decimal numbers without financial context',
        () {
      expect(
        NotificationDispatcher.extractAmountAndCurrencyFromText(
            'App updated to version 2.40 successfully'),
        isNull,
      );
      expect(
        NotificationDispatcher.extractAmountAndCurrencyFromText(
            'Team meeting scheduled at 10.30 tomorrow'),
        isNull,
      );
      expect(
        NotificationDispatcher.extractAmountAndCurrencyFromText(
            'Battery charge level is 85.00% remaining'),
        isNull,
      );
    });
  });

  group('Cross-source Deduplication (Bank vs Google Pay)', () {
    late NotificationDispatcher dispatcher;

    setUp(() {
      DedupeLedger.instance.clear();
      dispatcher = NotificationDispatcher.instance;
      dispatcher.recentCapturedNotifications.clear();
      dispatcher.queueHandler = null;
      dispatcher.onGooglePayTransaction = null;
    });

    test(
        'bank notification suppresses subsequent Google Pay payment within window',
        () async {
      // 1. Bank notification arrives first (e.g. GoTyme)
      final gotymeEvent = createTestEvent(
        id: 101,
        packageName: 'com.gotyme',
        title: 'GoTyme Bank Transfer',
        content: 'Transferred ₱3,600.00 to MariBank Philippines',
        timestamp: DateTime(2026, 10, 22, 10, 0, 0).millisecondsSinceEpoch,
      );

      // 2. Google Pay notification arrives 15 seconds later for same payment
      final gpayEvent = createTestEvent(
        id: 999,
        packageName: 'com.google.android.apps.walletnfcrel',
        title: 'Google Wallet',
        content: 'Paid PHP 3,600.00 at MariBank Philippines with GoTyme',
        timestamp: DateTime(2026, 10, 22, 10, 0, 15).millisecondsSinceEpoch,
      );

      int queueCount = 0;
      int gpayCount = 0;

      dispatcher.queueHandler = (msg, {dateTime, willPushRoute = true}) async {
        queueCount++;
      };
      dispatcher.onGooglePayTransaction = (res) async {
        gpayCount++;
        return true;
      };

      // Bank event should be handled and queued
      final handledBank = await dispatcher.handleEvent(gotymeEvent);
      expect(handledBank, isTrue);
      expect(queueCount, equals(1));
      expect(DedupeLedger.instance.entries.length, equals(1));
      expect(DedupeLedger.instance.entries.first.amountNormalized,
          equals('3600.00'));
      expect(DedupeLedger.instance.entries.first.currency, equals('PHP'));

      // Google Pay event for same amount within 5 min should be suppressed
      final handledGPay = await dispatcher.handleEvent(gpayEvent);
      expect(handledGPay, isFalse);
      expect(gpayCount, equals(0));
      expect(DedupeLedger.instance.suppressedEntries.length, equals(1));
      expect(DedupeLedger.instance.suppressedEntries.first.status,
          equals('suppressed'));
    });

    test(
        'Google Pay payment suppresses subsequent Bank notification within window',
        () async {
      // 1. Google Pay arrives first
      final gpayEvent = createTestEvent(
        id: 888,
        packageName: 'com.google.android.apps.walletnfcrel',
        title: 'Google Wallet',
        content: 'Paid PHP 1,000.00 at Maya with MariBank',
        timestamp: DateTime(2026, 10, 22, 11, 0, 0).millisecondsSinceEpoch,
      );

      // 2. MariBank notification arrives 30 seconds later
      final maribankEvent = createTestEvent(
        id: 202,
        packageName: 'com.maribank',
        title: 'MariBank Transfer Sent',
        content: 'Sent PHP 1,000.00 to Kid Omar Costelo (Maya Wallet)',
        timestamp: DateTime(2026, 10, 22, 11, 0, 30).millisecondsSinceEpoch,
      );

      int queueCount = 0;
      int gpayCount = 0;

      dispatcher.queueHandler = (msg, {dateTime, willPushRoute = true}) async {
        queueCount++;
      };
      dispatcher.onGooglePayTransaction = (res) async {
        gpayCount++;
        return true;
      };

      // Google Pay handled
      final handledGPay = await dispatcher.handleEvent(gpayEvent);
      expect(handledGPay, isTrue);
      expect(gpayCount, equals(1));

      // Bank notification should be suppressed
      final handledBank = await dispatcher.handleEvent(maribankEvent);
      expect(handledBank, isFalse);
      expect(queueCount, equals(0));
      expect(DedupeLedger.instance.suppressedEntries.length, equals(1));
    });

    test('different amounts between bank and Google Pay are both processed',
        () async {
      final gotymeEvent = createTestEvent(
        id: 101,
        packageName: 'com.gotyme',
        title: 'GoTyme Bank Transfer',
        content: 'Transferred ₱500.00 to Merchant',
        timestamp: DateTime(2026, 10, 22, 12, 0, 0).millisecondsSinceEpoch,
      );

      final gpayEvent = createTestEvent(
        id: 999,
        packageName: 'com.google.android.apps.walletnfcrel',
        title: 'Google Wallet',
        content: 'Paid PHP 250.00 at 7-Eleven',
        timestamp: DateTime(2026, 10, 22, 12, 0, 15).millisecondsSinceEpoch,
      );

      int queueCount = 0;
      int gpayCount = 0;
      dispatcher.queueHandler = (msg, {dateTime, willPushRoute = true}) async {
        queueCount++;
      };
      dispatcher.onGooglePayTransaction = (res) async {
        gpayCount++;
        return true;
      };

      final handled1 = await dispatcher.handleEvent(gotymeEvent);
      final handled2 = await dispatcher.handleEvent(gpayEvent);

      expect(handled1, isTrue);
      expect(handled2, isTrue);
      expect(queueCount, equals(1));
      expect(gpayCount, equals(1));
      expect(DedupeLedger.instance.entries.length, equals(2));
      expect(DedupeLedger.instance.suppressedEntries.isEmpty, isTrue);
    });
  });

  group('NotificationDispatcher Uncertain Match Routing (Slice S4)', () {
    late NotificationDispatcher dispatcher;

    setUp(() {
      DedupeLedger.instance.clear();
      dispatcher = NotificationDispatcher.instance;
      dispatcher.recentCapturedNotifications.clear();
      dispatcher.queueHandler = null;
      dispatcher.onGooglePayTransaction = null;
    });

    test(
        'routes ambiguous match with conflicting merchants to review instead of suppressing',
        () async {
      final event1 = createTestEvent(
        id: 111,
        packageName: 'com.bank.one',
        title: 'Purchase Alert',
        content: 'Paid ₱250.00 at Starbucks',
        timestamp: DateTime(2026, 10, 22, 10, 0, 0).millisecondsSinceEpoch,
      );

      final event2 = createTestEvent(
        id: 222,
        packageName: 'com.bank.two',
        title: 'Purchase Alert',
        content: "Paid ₱250.00 at McDonald's",
        timestamp: DateTime(2026, 10, 22, 10, 0, 30).millisecondsSinceEpoch,
      );

      bool? capturedIsPossibleDuplicate;
      DedupeEntryRecord? capturedMatchedEntry;
      int dispatchCount = 0;

      dispatcher.queueHandler = (
        msg, {
        dateTime,
        willPushRoute = true,
        isPossibleDuplicate = false,
        possibleDuplicateEntry,
      }) async {
        dispatchCount++;
        capturedIsPossibleDuplicate = isPossibleDuplicate;
        capturedMatchedEntry = possibleDuplicateEntry;
      };

      final handled1 = await dispatcher.handleEvent(event1);
      expect(handled1, isTrue);
      expect(dispatchCount, equals(1));
      expect(capturedIsPossibleDuplicate, isFalse);

      final handled2 = await dispatcher.handleEvent(event2);
      expect(handled2,
          isTrue); // Not suppressed! Handled and dispatched for review!
      expect(dispatchCount, equals(2));
      expect(capturedIsPossibleDuplicate, isTrue);
      expect(capturedMatchedEntry, isNotNull);
      expect(capturedMatchedEntry!.amountNormalized, equals('250.00'));
    });
  });
}
