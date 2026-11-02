import 'dart:ffi';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/dedupeLedger.dart';
import 'package:budget/struct/notificationDispatcher.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/util/appLinks.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notification_listener_service/notification_event.dart';
import 'package:sqlite3/open.dart';

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
  setUpAll(() {
    open.overrideFor(OperatingSystem.linux, () {
      try {
        return DynamicLibrary.open('libsqlite3.so');
      } catch (_) {
        return DynamicLibrary.open('libsqlite3.so.0');
      }
    });
  });

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

    test(
        'second notification with same package and id within 5 min is duplicate',
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

    test(
        'notification at exact window boundary is duplicate, past window is allowed',
        () async {
      final t0 = DateTime(2026, 10, 22, 12, 0, 0);
      final tBoundary = t0.add(const Duration(minutes: 5));
      final tAfter = t0.add(const Duration(minutes: 5, seconds: 1));

      await ledger.checkAndRecordNotification(
        packageName: 'com.google.android.apps.walletnfcrel',
        notificationId: '42',
        amount: 250.0,
        currency: 'PHP',
        title: '7-Eleven',
        eventTime: t0,
      );

      final boundaryResult = await ledger.checkAndRecordNotification(
        packageName: 'com.google.android.apps.walletnfcrel',
        notificationId: '42',
        amount: 250.0,
        currency: 'PHP',
        title: '7-Eleven',
        eventTime: tBoundary,
      );
      expect(boundaryResult.isDuplicate, isTrue);

      final afterWindowResult = await ledger.checkAndRecordNotification(
        packageName: 'com.google.android.apps.walletnfcrel',
        notificationId: '42',
        amount: 250.0,
        currency: 'PHP',
        title: '7-Eleven',
        eventTime: tAfter,
      );
      expect(afterWindowResult.isDuplicate, isFalse);
    });

    test(
        'null or empty package and notificationId does not trigger exact match',
        () async {
      final t0 = DateTime(2026, 10, 22, 12, 0, 0);
      final res1 = await ledger.checkAndRecordNotification(
        packageName: null,
        notificationId: null,
        eventTime: t0,
      );
      expect(res1.isDuplicate, isFalse);

      final res2 = await ledger.checkAndRecordNotification(
        packageName: '',
        notificationId: '',
        eventTime: t0.add(const Duration(seconds: 1)),
      );
      expect(res2.isDuplicate, isFalse);
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

    test('different amounts within window are not marked duplicate', () async {
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

    test('suppressedEntries list is capped at 200 items', () async {
      final t0 = DateTime(2026, 10, 22, 12, 0, 0);
      await ledger.checkAndRecordNotification(
        packageName: 'com.example.bank',
        notificationId: '1',
        amount: 100.0,
        currency: 'PHP',
        eventTime: t0,
      );

      for (int i = 0; i < 220; i++) {
        await ledger.checkAndRecordNotification(
          packageName: 'com.example.bank',
          notificationId: '1',
          amount: 100.0,
          currency: 'PHP',
          eventTime: t0.add(Duration(seconds: i + 1)),
        );
      }

      expect(ledger.suppressedEntries.length, equals(200));
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

  group('maxLedgerCapacity named constant', () {
    test('maxLedgerCapacity is defined as 200', () {
      expect(DedupeLedger.maxLedgerCapacity, equals(200));
    });
  });

  group('DedupeLedger helper matching methods', () {
    late DedupeLedger ledger;

    setUp(() {
      ledger = DedupeLedger();
    });

    test('findExactNotificationMatch finds matching entry within window',
        () async {
      final t0 = DateTime(2026, 10, 22, 10, 0, 0);
      await ledger.checkAndRecordNotification(
        packageName: 'com.bank',
        notificationId: '99',
        eventTime: t0,
      );

      final found = ledger.findExactNotificationMatch(
        packageName: 'com.bank',
        notificationId: '99',
        now: t0.add(const Duration(minutes: 2)),
        window: const Duration(minutes: 5),
      );
      expect(found, isNotNull);
      expect(found!.eventKey, equals('notif:com.bank:99'));

      final notFound = ledger.findExactNotificationMatch(
        packageName: 'com.bank',
        notificationId: '99',
        now: t0.add(const Duration(minutes: 6)),
        window: const Duration(minutes: 5),
      );
      expect(notFound, isNull);
    });

    test('findPaymentMatch finds matching amount and currency within window',
        () async {
      final t0 = DateTime(2026, 10, 22, 10, 0, 0);
      await ledger.checkAndRecordPayment(
        amount: 150.0,
        currency: 'USD',
        eventTime: t0,
      );

      final found = ledger.findPaymentMatch(
        normAmount: '150.00',
        normCurrency: 'USD',
        now: t0.add(const Duration(minutes: 3)),
        window: const Duration(minutes: 5),
      );
      expect(found, isNotNull);

      final mismatchedCurrency = ledger.findPaymentMatch(
        normAmount: '150.00',
        normCurrency: 'EUR',
        now: t0.add(const Duration(minutes: 1)),
        window: const Duration(minutes: 5),
      );
      expect(mismatchedCurrency, isNull);
    });
  });

  group('AppLink Deduplication Platform and Settings Gating', () {
    setUp(() {
      DedupeLedger.instance.clear();
      appStateSettings["notificationScanning"] = true;
    });

    tearDown(() {
      appStateSettings["notificationScanning"] = false;
    });

    test('deduplicates on Android when notificationScanning is true', () async {
      appStateSettings["notificationScanning"] = true;

      final isDup1 = await shouldDedupePayment(
        amount: 250.0,
        params: {"title": "Coffee"},
        platform: PlatformOS.isAndroid,
      );
      expect(isDup1, isFalse);

      final isDup2 = await shouldDedupePayment(
        amount: 250.0,
        params: {"title": "Coffee"},
        platform: PlatformOS.isAndroid,
      );
      expect(isDup2, isTrue);
    });

    test('bypasses deduplication on non-Android platforms', () async {
      appStateSettings["notificationScanning"] = true;

      final isDup1 = await shouldDedupePayment(
        amount: 250.0,
        params: {"title": "Coffee"},
        platform: PlatformOS.isIOS,
      );
      expect(isDup1, isFalse);

      final isDup2 = await shouldDedupePayment(
        amount: 250.0,
        params: {"title": "Coffee"},
        platform: PlatformOS.isIOS,
      );
      // Non-Android platforms are always bypassed
      expect(isDup2, isFalse);
    });

    test('bypasses deduplication when notificationScanning is false', () async {
      appStateSettings["notificationScanning"] = false;

      final isDup1 = await shouldDedupePayment(
        amount: 300.0,
        params: {"title": "Lunch"},
        platform: PlatformOS.isAndroid,
      );
      expect(isDup1, isFalse);

      final isDup2 = await shouldDedupePayment(
        amount: 300.0,
        params: {"title": "Lunch"},
        platform: PlatformOS.isAndroid,
      );
      expect(isDup2, isFalse);
    });

    test('bypasses deduplication when skipDedupe is true', () async {
      appStateSettings["notificationScanning"] = true;

      final isDup1 = await shouldDedupePayment(
        amount: 500.0,
        params: {"title": "Dinner"},
        platform: PlatformOS.isAndroid,
      );
      expect(isDup1, isFalse);

      final isDup2 = await shouldDedupePayment(
        amount: 500.0,
        params: {"title": "Dinner", "skipDedupe": "true"},
        platform: PlatformOS.isAndroid,
      );
      expect(isDup2, isFalse);
    });
  });

  group('DedupeLedger Persistence and Database Hydration', () {
    late FinanceDatabase testDb;

    setUp(() async {
      testDb = FinanceDatabase(NativeDatabase.memory());
      database = testDb;
      DedupeLedger.instance.clear();
    });

    tearDown(() async {
      await testDb.close();
    });

    test('populates notificationTimestamp when eventTime is provided',
        () async {
      final t0 = DateTime(2026, 10, 22, 14, 0, 0);
      final result = await DedupeLedger.instance.checkAndRecordNotification(
        packageName: 'com.maribank',
        notificationId: '555',
        amount: 750.0,
        currency: 'PHP',
        title: 'MariBank Sent',
        eventTime: t0,
      );

      expect(result.isDuplicate, isFalse);
      expect(DedupeLedger.instance.entries.length, equals(1));
      expect(DedupeLedger.instance.entries.first.notificationTimestamp,
          equals(t0));

      final fromDb = await database.getAllDedupeEntries();
      expect(fromDb.length, equals(1));
      expect(fromDb.first.notificationTimestamp, equals(t0));
    });

    test(
        'loadFromDatabase hydrates entries within sliding window and filters older ones',
        () async {
      final now = DateTime.now();
      final recentTime = now.subtract(const Duration(minutes: 2));
      final staleTime = now.subtract(const Duration(minutes: 10));

      // 1. Insert directly into database: one recent, one stale
      await database.insertDedupeEntry(
        DedupeEntriesCompanion(
          entryPk: const Value('recent-entry-pk'),
          eventKey: const Value('notif:com.maribank:101'),
          packageName: const Value('com.maribank'),
          notificationId: const Value('101'),
          amount: const Value(500.0),
          amountNormalized: const Value('500.00'),
          currency: const Value('PHP'),
          title: const Value('Recent Transfer'),
          source: const Value('notification'),
          dateTimeCreated: Value(recentTime),
          status: const Value('created'),
        ),
      );

      await database.insertDedupeEntry(
        DedupeEntriesCompanion(
          entryPk: const Value('stale-entry-pk'),
          eventKey: const Value('notif:com.maribank:102'),
          packageName: const Value('com.maribank'),
          notificationId: const Value('102'),
          amount: const Value(300.0),
          amountNormalized: const Value('300.00'),
          currency: const Value('PHP'),
          title: const Value('Stale Transfer'),
          source: const Value('notification'),
          dateTimeCreated: Value(staleTime),
          status: const Value('created'),
        ),
      );

      // 2. Hydrate ledger using default window (5 minutes)
      await DedupeLedger.instance.loadFromDatabase();

      // Only the recent entry within 5 minutes should be in memory
      expect(DedupeLedger.instance.entries.length, equals(1));
      expect(DedupeLedger.instance.entries.first.entryPk,
          equals('recent-entry-pk'));
      expect(DedupeLedger.instance.entries.first.amount, equals(500.0));
    });

    test('loadFromDatabase separates created vs suppressed entries correctly',
        () async {
      final now = DateTime.now();
      final t = now.subtract(const Duration(minutes: 1));

      await database.insertDedupeEntry(
        DedupeEntriesCompanion(
          entryPk: const Value('created-pk'),
          eventKey: const Value('notif:com.maribank:201'),
          packageName: const Value('com.maribank'),
          notificationId: const Value('201'),
          amount: const Value(250.0),
          amountNormalized: const Value('250.00'),
          currency: const Value('PHP'),
          title: const Value('Created Entry'),
          source: const Value('notification'),
          dateTimeCreated: Value(t),
          status: const Value('created'),
        ),
      );

      await database.insertDedupeEntry(
        DedupeEntriesCompanion(
          entryPk: const Value('suppressed-pk'),
          eventKey: const Value('notif:com.maribank:201'),
          packageName: const Value('com.maribank'),
          notificationId: const Value('201'),
          amount: const Value(250.0),
          amountNormalized: const Value('250.00'),
          currency: const Value('PHP'),
          title: const Value('Suppressed Entry'),
          source: const Value('notification'),
          dateTimeCreated: Value(t),
          status: const Value('suppressed'),
          matchedEntryPk: const Value('created-pk'),
        ),
      );

      await DedupeLedger.instance.loadFromDatabase();

      expect(DedupeLedger.instance.entries.length, equals(1));
      expect(DedupeLedger.instance.entries.first.entryPk, equals('created-pk'));

      expect(DedupeLedger.instance.suppressedEntries.length, equals(1));
      expect(DedupeLedger.instance.suppressedEntries.first.entryPk,
          equals('suppressed-pk'));
    });

    test('loadFromDatabase is idempotent on repeated calls', () async {
      final now = DateTime.now();
      await database.insertDedupeEntry(
        DedupeEntriesCompanion(
          entryPk: const Value('idempotent-pk'),
          eventKey: const Value('notif:com.gotyme:301'),
          packageName: const Value('com.gotyme'),
          notificationId: const Value('301'),
          amount: const Value(100.0),
          amountNormalized: const Value('100.00'),
          currency: const Value('PHP'),
          title: const Value('Test GoTyme'),
          source: const Value('notification'),
          dateTimeCreated: Value(now.subtract(const Duration(minutes: 1))),
          status: const Value('created'),
        ),
      );

      await DedupeLedger.instance.loadFromDatabase();
      expect(DedupeLedger.instance.entries.length, equals(1));

      // Second invocation should not duplicate entries
      await DedupeLedger.instance.loadFromDatabase();
      expect(DedupeLedger.instance.entries.length, equals(1));
    });
  });

  group('DedupeLedger Uncertain Match Classification (Slice S4)', () {
    late DedupeLedger ledger;

    setUp(() {
      ledger = DedupeLedger();
    });

    test(
        'two notifications with matching amount within window but conflicting merchants are classified as uncertain match',
        () async {
      final t0 = DateTime(2026, 10, 22, 10, 0, 0);
      final t1 = t0.add(const Duration(seconds: 30));

      // 1. First notification: Starbucks for 150 PHP
      final res1 = await ledger.checkAndRecordNotification(
        packageName: 'com.bank.one',
        notificationId: '101',
        amount: 150.0,
        currency: 'PHP',
        title: 'Starbucks Coffee',
        rawContent: 'Paid PHP 150.00 at Starbucks Coffee',
        eventTime: t0,
      );
      expect(res1.isDuplicate, isFalse);
      expect(res1.isUncertainMatch, isFalse);

      // 2. Second notification: McDonald's for 150 PHP (conflicting merchant!)
      final res2 = await ledger.checkAndRecordNotification(
        packageName: 'com.bank.two',
        notificationId: '202',
        amount: 150.0,
        currency: 'PHP',
        title: "McDonald's",
        rawContent: "Paid PHP 150.00 at McDonald's",
        eventTime: t1,
      );

      expect(res2.isDuplicate, isFalse);
      expect(res2.isUncertainMatch, isTrue);
      expect(res2.matchedEntry, isNotNull);
      expect(res2.matchedEntry!.title, equals('Starbucks Coffee'));
      expect(ledger.uncertainEntries.length, equals(1));
      expect(ledger.uncertainEntries.first.status, equals('uncertain'));
      expect(ledger.uncertainEntries.first.matchedEntryPk,
          equals(ledger.entries.first.entryPk));
    });

    test(
        'notification with matching amount but generic/uncertain merchant is classified as uncertain match',
        () async {
      final t0 = DateTime(2026, 10, 22, 10, 0, 0);
      final t1 = t0.add(const Duration(seconds: 45));

      // 1. First notification from Google Wallet with generic title and no parsed merchant
      await ledger.checkAndRecordNotification(
        packageName: 'com.google.android.apps.walletnfcrel',
        notificationId: '301',
        amount: 300.0,
        currency: 'PHP',
        title: 'Google Wallet',
        rawContent: 'Payment of PHP 300.00 successful',
        eventTime: t0,
      );

      // 2. Bank notification for 300 PHP with specific merchant "7-Eleven"
      final res2 = await ledger.checkAndRecordNotification(
        packageName: 'com.gotyme',
        notificationId: '302',
        amount: 300.0,
        currency: 'PHP',
        title: '7-Eleven Store',
        rawContent: 'Paid ₱300.00 at 7-Eleven Store',
        eventTime: t1,
      );

      expect(res2.isDuplicate, isFalse);
      expect(res2.isUncertainMatch, isTrue);
      expect(res2.matchReason, contains('uncertain'));
    });

    test(
        'payment from App Link followed by bank notification with differing merchant is uncertain match',
        () async {
      final t0 = DateTime(2026, 10, 22, 11, 0, 0);
      final t1 = t0.add(const Duration(minutes: 1));

      // 1. App Link payment: 500 PHP at "Shell Gas"
      await ledger.checkAndRecordPayment(
        amount: 500.0,
        currency: 'PHP',
        title: 'Shell Gas',
        source: 'app_link',
        eventTime: t0,
      );

      // 2. Incoming notification: 500 PHP at "Petron"
      final res2 = await ledger.checkAndRecordNotification(
        packageName: 'com.bank.app',
        notificationId: '401',
        amount: 500.0,
        currency: 'PHP',
        title: 'Petron',
        rawContent: 'Paid PHP 500.00 at Petron',
        eventTime: t1,
      );

      expect(res2.isDuplicate, isFalse);
      expect(res2.isUncertainMatch, isTrue);
    });

    test(
        'exact notification match remains duplicate suppression even with different content',
        () async {
      final t0 = DateTime(2026, 10, 22, 12, 0, 0);
      final t1 = t0.add(const Duration(seconds: 10));

      await ledger.checkAndRecordNotification(
        packageName: 'com.bank.app',
        notificationId: '999',
        amount: 100.0,
        currency: 'PHP',
        title: 'Bank Alert',
        eventTime: t0,
      );

      final res2 = await ledger.checkAndRecordNotification(
        packageName: 'com.bank.app',
        notificationId: '999',
        amount: 100.0,
        currency: 'PHP',
        title: 'Updated Bank Alert',
        eventTime: t1,
      );

      expect(res2.isDuplicate, isTrue);
      expect(res2.isUncertainMatch, isFalse);
      expect(res2.matchReason, equals('exact_notification'));
    });
  });
}
