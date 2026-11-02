import 'dart:ffi';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/dedupeLedger.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/possibleDuplicateBanner.dart';
import 'package:budget/widgets/util/appLinks.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sqlite3/open.dart';

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

  group('PossibleDuplicateBanner Widget Tests', () {
    testWidgets('renders banner with warning icon, title, and matched details',
        (WidgetTester tester) async {
      final matchedEntry = DedupeEntryRecord(
        eventKey: 'notif:com.bank:123',
        amount: 250.0,
        amountNormalized: '250.00',
        currency: 'PHP',
        title: 'Starbucks Coffee',
      );

      bool dismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PossibleDuplicateBanner(
              matchedEntry: matchedEntry,
              onDismiss: () {
                dismissed = true;
              },
            ),
          ),
        ),
      );

      // Verify banner container exists
      expect(find.byKey(const ValueKey('possibleDuplicateBanner')),
          findsOneWidget);

      // Verify title or duplicate text exists
      expect(find.textContaining('Possible duplicate'), findsOneWidget);

      // Verify matched amount and title are visible
      expect(find.textContaining('250.00'), findsOneWidget);
      expect(find.textContaining('Starbucks Coffee'), findsOneWidget);

      // Tap dismiss icon
      final dismissButton =
          find.byKey(const ValueKey('dismissPossibleDuplicateBanner'));
      expect(dismissButton, findsOneWidget);
      await tester.tap(dismissButton);
      await tester.pump();

      expect(dismissed, isTrue);
    });

    testWidgets('renders fallback text when matchedEntry is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PossibleDuplicateBanner(
              matchedEntry: null,
            ),
          ),
        ),
      );

      expect(find.byKey(const ValueKey('possibleDuplicateBanner')),
          findsOneWidget);
      expect(find.textContaining('Possible duplicate'), findsOneWidget);
    });
  });

  group('App Links checkPaymentDedupe and review routing', () {
    late FinanceDatabase testDb;

    setUp(() async {
      testDb = FinanceDatabase(NativeDatabase.memory());
      database = testDb;
      DedupeLedger.instance.clear();
      appStateSettings["notificationScanning"] = true;
    });

    tearDown(() async {
      await testDb.close();
      appStateSettings["notificationScanning"] = false;
    });

    test('checkPaymentDedupe detects uncertain match for conflicting titles',
        () async {
      final t0 = DateTime(2026, 10, 22, 10, 0, 0);
      final t1 = t0.add(const Duration(minutes: 1));

      // First payment: Starbucks for 250 PHP
      await DedupeLedger.instance.checkAndRecordPayment(
        amount: 250.0,
        currency: 'PHP',
        title: 'Starbucks Coffee',
        source: 'app_link',
        eventTime: t0,
      );

      // Second payment check: McDonald's for 250 PHP (conflicting merchant)
      final result = await checkPaymentDedupe(
        amount: 250.0,
        params: {'title': "McDonald's", 'currency': 'PHP'},
        platform: PlatformOS.isAndroid,
        eventTime: t1,
        currency: 'PHP',
      );

      expect(result, isNotNull);
      expect(result!.isDuplicate, isFalse);
      expect(result.isUncertainMatch, isTrue);
      expect(result.matchedEntry?.title, equals('Starbucks Coffee'));
    });

    test('checkPaymentDedupe detects duplicate for exact retry', () async {
      final t0 = DateTime(2026, 10, 22, 10, 0, 0);
      final t1 = t0.add(const Duration(seconds: 5));

      await DedupeLedger.instance.checkAndRecordPayment(
        amount: 250.0,
        currency: 'PHP',
        title: 'Starbucks Coffee',
        source: 'app_link',
        eventTime: t0,
      );

      final result = await checkPaymentDedupe(
        amount: 250.0,
        params: {'title': 'Starbucks Coffee', 'currency': 'PHP'},
        platform: PlatformOS.isAndroid,
        eventTime: t1,
        currency: 'PHP',
      );

      expect(result, isNotNull);
      expect(result!.isDuplicate, isTrue);
      expect(result.isUncertainMatch, isFalse);
    });
  });
}
