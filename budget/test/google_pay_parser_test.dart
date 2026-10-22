import 'package:budget/struct/dedupeLedger.dart';
import 'package:budget/struct/googlePayParser.dart';
import 'package:budget/struct/notificationDispatcher.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notification_listener_service/notification_event.dart';

ServiceNotificationEvent createTestEvent({
  int id = 1,
  String packageName = 'com.google.android.apps.walletnfcrel',
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
  group('GooglePayParser.parse real device and standard samples', () {
    test(
      'parses real 7-Eleven sample with UnionBank Rewards Platinum card',
      () {
        final result = GooglePayParser.parse(
          '7-Eleveb-ST4594',
          'P123.00 with UnionBank Rewards Platinum **3353',
        );

        expect(result, isNotNull);
        expect(result!.merchant, equals('7-Eleveb-ST4594'));
        expect(result.amount, equals(123.00));
        expect(result.currency, equals('PHP'));
        expect(result.cardName, equals('UnionBank Rewards Platinum'));
        expect(result.cardLast4, equals('3353'));
      },
    );

    test(
      'parses Philippine Peso symbol and bullet masked card',
      () {
        final result = GooglePayParser.parse(
          'Starbucks',
          '₱185.00 with Mastercard •••• 1234',
        );

        expect(result, isNotNull);
        expect(result!.merchant, equals('Starbucks'));
        expect(result.amount, equals(185.00));
        expect(result.currency, equals('PHP'));
        expect(result.cardName, equals('Mastercard'));
        expect(result.cardLast4, equals('1234'));
      },
    );

    test(
      'parses US Dollar symbol and card masked digits',
      () {
        final result = GooglePayParser.parse(
          "Trader Joe's",
          '\$42.75 with Chase Freedom •••• 9876',
        );

        expect(result, isNotNull);
        expect(result!.merchant, equals("Trader Joe's"));
        expect(result.amount, equals(42.75));
        expect(result.currency, equals('USD'));
        expect(result.cardName, equals('Chase Freedom'));
        expect(result.cardLast4, equals('9876'));
      },
    );

    test(
      'parses generic Google Wallet title with merchant in body',
      () {
        final result = GooglePayParser.parse(
          'Google Wallet',
          'Paid ₱250.00 at Mercury Drug',
        );

        expect(result, isNotNull);
        expect(result!.merchant, equals('Mercury Drug'));
        expect(result.amount, equals(250.00));
        expect(result.currency, equals('PHP'));
      },
    );

    test(
      'parses European Euro currency and travel card format',
      () {
        final result = GooglePayParser.parse(
          'Supermarket',
          '40.00 EUR with Travel Card',
        );

        expect(result, isNotNull);
        expect(result!.merchant, equals('Supermarket'));
        expect(result.amount, equals(40.00));
        expect(result.currency, equals('EUR'));
        expect(result.cardName, equals('Travel Card'));
      },
    );

    test(
      'returns null for invalid or non-financial notifications',
      () {
        expect(GooglePayParser.parse(null, null), isNull);
        expect(GooglePayParser.parse('', ''), isNull);
        expect(
          GooglePayParser.parse('Google Wallet', 'Security alert update'),
          isNull,
        );
      },
    );
  });

  group('GooglePayParser package and event classification', () {
    test(
      'identifies recognized Google Wallet and Google Pay package names',
      () {
        expect(
          GooglePayParser.isRecognizedPackage(
            'com.google.android.apps.walletnfcrel',
          ),
          isTrue,
        );
        expect(
          GooglePayParser.isRecognizedPackage(
            'com.google.android.apps.nbu.paisa.user',
          ),
          isTrue,
        );
        expect(
          GooglePayParser.isRecognizedPackage('com.google.android.gms'),
          isTrue,
        );
        expect(
          GooglePayParser.isRecognizedPackage('com.facebook.katana'),
          isFalse,
        );
        expect(
          GooglePayParser.isRecognizedPackage(null),
          isFalse,
        );
      },
    );

    test(
      'isGooglePayEvent validates package and payment content',
      () {
        final validEvent = createTestEvent(
          packageName: 'com.google.android.apps.walletnfcrel',
          title: '7-Eleveb-ST4594',
          content: 'P123.00 with UnionBank Rewards Platinum **3353',
        );

        final nonPaymentEvent = createTestEvent(
          packageName: 'com.google.android.gms',
          title: 'Backup Completed',
          content: 'All device data has been backed up.',
        );

        final unrelatedAppEvent = createTestEvent(
          packageName: 'com.other.app',
          title: '7-Eleveb-ST4594',
          content: 'P123.00 with UnionBank Rewards Platinum **3353',
        );

        expect(GooglePayParser.isGooglePayEvent(validEvent), isTrue);
        expect(GooglePayParser.isGooglePayEvent(nonPaymentEvent), isFalse);
        expect(GooglePayParser.isGooglePayEvent(unrelatedAppEvent), isFalse);
      },
    );
  });

  group('NotificationDispatcher routing for Google Pay', () {
    late NotificationDispatcher dispatcher;

    setUp(() {
      DedupeLedger.instance.clear();
      dispatcher = NotificationDispatcher.instance;
      dispatcher.recentCapturedNotifications.clear();
      dispatcher.queueHandler = null;
      dispatcher.onGooglePayTransaction = null;
    });

    test(
      'routes Google Pay notification through onGooglePayTransaction handler',
      () async {
        final event = createTestEvent(
          packageName: 'com.google.android.apps.walletnfcrel',
          title: '7-Eleveb-ST4594',
          content: 'P123.00 with UnionBank Rewards Platinum **3353',
        );

        GooglePayTransactionResult? capturedResult;
        dispatcher.onGooglePayTransaction = (result) async {
          capturedResult = result;
          return true;
        };

        bool standardQueueCalled = false;
        dispatcher.queueHandler =
            (msg, {dateTime, willPushRoute = true}) async {
          standardQueueCalled = true;
        };

        final handled = await dispatcher.handleEvent(event);

        expect(handled, isTrue);
        expect(capturedResult, isNotNull);
        expect(capturedResult!.merchant, equals('7-Eleveb-ST4594'));
        expect(capturedResult!.amount, equals(123.00));
        expect(capturedResult!.cardLast4, equals('3353'));
        expect(standardQueueCalled, isFalse);
      },
    );

    test(
      'routes non-Google-Pay notification through standard queueHandler',
      () async {
        final bankEvent = createTestEvent(
          packageName: 'com.bdo.bank',
          title: 'Debit Alert',
          content: 'PHP 500.00 spent at Store',
        );

        bool gPayCalled = false;
        dispatcher.onGooglePayTransaction = (result) async {
          gPayCalled = true;
          return true;
        };

        String? standardQueueMsg;
        dispatcher.queueHandler =
            (msg, {dateTime, willPushRoute = true}) async {
          standardQueueMsg = msg;
        };

        final handled = await dispatcher.handleEvent(bankEvent);

        expect(handled, isTrue);
        expect(gPayCalled, isFalse);
        expect(standardQueueMsg, isNotNull);
        expect(standardQueueMsg, contains('com.bdo.bank'));
      },
    );
  });
}
