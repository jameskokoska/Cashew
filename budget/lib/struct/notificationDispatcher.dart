import 'dart:async';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/databaseGlobal.dart';
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

/// Extracted payment parameters for deduplication ledger recording.
class ExtractedNotificationDetails {
  final double? amount;
  final String? currency;
  final String? title;

  const ExtractedNotificationDetails({
    this.amount,
    this.currency,
    this.title,
  });
}

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

  static final RegExp _currencyPrefixRegex = RegExp(
    r'(?:(?<![a-zA-Z])([₱$€£¥₹]|P)\s*|\b(PHP|USD|EUR|GBP|JPY|CAD|AUD|SGD|INR|php|usd|eur|gbp|jpy|cad|aud|sgd|inr)\s*)'
    r'([0-9]{1,3}(?:,[0-9]{3})*(?:\.[0-9]{2})?|[0-9]+(?:\.[0-9]{2})?)',
  );

  static final RegExp _currencySuffixRegex = RegExp(
    r'([0-9]{1,3}(?:,[0-9]{3})*(?:\.[0-9]{2})?|[0-9]+(?:\.[0-9]{2})?)'
    r'\s*([₱$€£¥₹]|\b(?:PHP|USD|EUR|GBP|JPY|CAD|AUD|SGD|INR|php|usd|eur|gbp|jpy|cad|aud|sgd|inr)\b)',
  );

  static final RegExp _financialContextRegex = RegExp(
    r'\b(?:debited|debit|credited|credit|paid|pay|payment|sent|transferred|transfer|spent|received|charge|charged|total|amount|balance|fee|purchase|withdrawn|withdraw)\b',
    caseSensitive: false,
  );

  static final RegExp _monetaryDecimalRegex = RegExp(
    r'\b([0-9]{1,3}(?:,[0-9]{3})*\.[0-9]{2}|[0-9]+\.[0-9]{2})\b(?!\s*%)',
  );

  /// Normalizes currency symbols and codes to standard 3-letter ISO uppercase codes.
  static String? normalizeCurrency(String? raw) {
    if (raw == null) return null;
    final upper = raw.trim().toUpperCase();
    if (upper == 'P' || upper == '₱' || upper == 'PHP') return 'PHP';
    if (upper == '\$' || upper == 'USD') return 'USD';
    if (upper == '€' || upper == 'EUR') return 'EUR';
    if (upper == '£' || upper == 'GBP') return 'GBP';
    if (upper == '¥' || upper == 'JPY') return 'JPY';
    if (upper == '₹' || upper == 'INR') return 'INR';
    if (upper == 'CAD') return 'CAD';
    if (upper == 'AUD') return 'AUD';
    if (upper == 'SGD') return 'SGD';
    return upper;
  }

  /// Extracts numeric amount substring between delimiters.
  static double? extractAmountFromDelimiters(
    String messageString,
    String before,
    String after,
  ) {
    try {
      int startIndex = messageString.indexOf(before) + before.length;
      int endIndex = messageString.indexOf(after, startIndex);
      String amountString = messageString.substring(startIndex, endIndex);
      return double.tryParse(amountString.replaceAll(RegExp(r'[^0-9.]'), ''));
    } catch (_) {
      return null;
    }
  }

  /// Extracts title substring between delimiters.
  static String? extractTitleFromDelimiters(
    String messageString,
    String before,
    String after,
  ) {
    try {
      int startIndex = messageString.indexOf(before) + before.length;
      int endIndex = messageString.indexOf(after, startIndex);
      String title = messageString.substring(startIndex, endIndex);
      title = title.replaceAll("\n", " ");
      title = title.replaceAll("\r", " ");
      title = title.replaceAll(RegExp(r'\s+'), ' ');
      title = title.trim();
      if (title.isNotEmpty) {
        title = title.toLowerCase();
        title = title.capitalizeFirst;
      }
      return title;
    } catch (_) {
      return null;
    }
  }

  /// Extracts amount and optional currency from free-form notification text.
  static ExtractedNotificationDetails? extractAmountAndCurrencyFromText(
    String text,
  ) {
    if (text.trim().isEmpty) return null;

    // 1. Check for prefix currency e.g. ₱3,600.00 or PHP 1,000.00 or P123.00
    final prefixMatch = _currencyPrefixRegex.firstMatch(text);
    if (prefixMatch != null) {
      final rawCurrency = prefixMatch.group(1) ?? prefixMatch.group(2);
      final rawAmount = prefixMatch.group(3);
      if (rawAmount != null) {
        final cleanAmount = rawAmount.replaceAll(',', '');
        final parsed = double.tryParse(cleanAmount);
        if (parsed != null && parsed > 0) {
          return ExtractedNotificationDetails(
            amount: parsed,
            currency: normalizeCurrency(rawCurrency),
          );
        }
      }
    }

    // 2. Check for suffix currency e.g. 250.00 PHP or 500 PHP
    final suffixMatch = _currencySuffixRegex.firstMatch(text);
    if (suffixMatch != null) {
      final rawAmount = suffixMatch.group(1);
      final rawCurrency = suffixMatch.group(2);
      if (rawAmount != null) {
        final cleanAmount = rawAmount.replaceAll(',', '');
        final parsed = double.tryParse(cleanAmount);
        if (parsed != null && parsed > 0) {
          return ExtractedNotificationDetails(
            amount: parsed,
            currency: normalizeCurrency(rawCurrency),
          );
        }
      }
    }

    // 3. Fallback to standard 2-decimal monetary pattern only if financial context is present
    if (_financialContextRegex.hasMatch(text)) {
      final decimalMatch = _monetaryDecimalRegex.firstMatch(text);
      if (decimalMatch != null) {
        final rawAmount = decimalMatch.group(1);
        if (rawAmount != null) {
          final cleanAmount = rawAmount.replaceAll(',', '');
          final parsed = double.tryParse(cleanAmount);
          if (parsed != null && parsed > 0) {
            return ExtractedNotificationDetails(
              amount: parsed,
              currency: null,
            );
          }
        }
      }
    }

    return null;
  }

  /// Extracts payment details (amount, currency, merchant/title) from an event
  /// using Google Pay parser, user ScannerTemplates, or regex text fallback.
  Future<ExtractedNotificationDetails> extractPaymentDetails(
    ServiceNotificationEvent event, {
    GooglePayTransactionResult? googlePayResult,
  }) async {
    // 1. Google Pay parser result takes precedence if present
    if (googlePayResult != null && googlePayResult.amount > 0) {
      return ExtractedNotificationDetails(
        amount: googlePayResult.amount,
        currency: googlePayResult.currency,
        title: googlePayResult.merchant,
      );
    }

    double? amount;
    String? currency;
    String? title = event.title;

    final messageString = formatNotificationMessage(event);

    // 2. Check user-configured ScannerTemplates from database
    try {
      final templates = await database.getAllScannerTemplates();
      for (final template in templates) {
        if (messageString.contains(template.contains)) {
          final extractedAmount = extractAmountFromDelimiters(
            messageString,
            template.amountTransactionBefore,
            template.amountTransactionAfter,
          );
          if (extractedAmount != null && extractedAmount > 0) {
            amount = extractedAmount;
            final extractedTitle = extractTitleFromDelimiters(
              messageString,
              template.titleTransactionBefore,
              template.titleTransactionAfter,
            );
            if (extractedTitle != null && extractedTitle.isNotEmpty) {
              title = extractedTitle;
            }
            if (template.walletFk != "-1" && template.walletFk != "0") {
              final wallet =
                  await database.getWalletInstanceOrNull(template.walletFk);
              if (wallet?.currency != null && wallet!.currency!.isNotEmpty) {
                currency = normalizeCurrency(wallet.currency);
              }
            }
            break;
          }
        }
      }
    } catch (_) {
      // Ignored if database is not initialized (e.g. unit tests)
    }

    // 3. Regex fallback on notification text (content and title)
    if (amount == null || amount <= 0) {
      final text = '${event.content ?? ''} ${event.title ?? ''}';
      final parsed = extractAmountAndCurrencyFromText(text);
      if (parsed != null) {
        amount = parsed.amount;
        currency ??= parsed.currency;
      }
    } else if (currency == null) {
      final text = '${event.content ?? ''} ${event.title ?? ''}';
      final parsed = extractAmountAndCurrencyFromText(text);
      if (parsed?.currency != null) {
        currency = parsed!.currency;
      }
    }

    // 4. Default wallet currency fallback if currency remains unknown
    if (amount != null && amount > 0 && currency == null) {
      try {
        final selectedWalletPk = appStateSettings["selectedWalletPk"];
        if (selectedWalletPk != null) {
          final defaultWallet =
              await database.getWalletInstanceOrNull(selectedWalletPk);
          if (defaultWallet?.currency != null &&
              defaultWallet!.currency!.isNotEmpty) {
            currency = normalizeCurrency(defaultWallet.currency);
          }
        }
      } catch (_) {}
    }

    return ExtractedNotificationDetails(
      amount: amount,
      currency: currency,
      title: title,
    );
  }

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

    await DedupeLedger.instance.loadFromDatabase();

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
    final details = await extractPaymentDetails(
      event,
      googlePayResult: googlePayResult,
    );
    final dedupeResult = await DedupeLedger.instance.checkAndRecordNotification(
      packageName: event.packageName,
      notificationId: event.id?.toString(),
      amount: details.amount,
      currency: details.currency,
      title: details.title ?? event.title,
      rawContent: event.content,
      eventTime: event.timestamp != null && event.timestamp > 0
          ? DateTime.fromMillisecondsSinceEpoch(event.timestamp)
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
      try {
        await (customQueueHandler as dynamic)(
          messageString,
          isPossibleDuplicate: dedupeResult.isUncertainMatch,
          possibleDuplicateEntry: dedupeResult.matchedEntry,
        );
      } catch (e) {
        if (e is NoSuchMethodError) {
          await customQueueHandler(messageString);
        } else {
          rethrow;
        }
      }
      return true;
    }

    // Check if event is from Google Wallet / Google Pay
    if (GooglePayParser.isGooglePayEvent(event)) {
      // googlePayResult was parsed above for deduplication check
      if (googlePayResult != null) {
        if (onGooglePayTransaction != null) {
          try {
            await (onGooglePayTransaction as dynamic)(
              googlePayResult,
              isPossibleDuplicate: dedupeResult.isUncertainMatch,
              possibleDuplicateEntry: dedupeResult.matchedEntry,
            );
          } catch (e) {
            if (e is NoSuchMethodError) {
              await onGooglePayTransaction!(googlePayResult);
            } else {
              rethrow;
            }
          }
          return true;
        }
        await GooglePayParser.processGooglePayTransaction(
          googlePayResult,
          isPossibleDuplicate: dedupeResult.isUncertainMatch,
          possibleDuplicateEntry: dedupeResult.matchedEntry,
        );
        return true;
      }
    }

    TransactionQueueHandler? handler = queueHandler;
    if (handler != null) {
      try {
        await (handler as dynamic)(
          messageString,
          isPossibleDuplicate: dedupeResult.isUncertainMatch,
          possibleDuplicateEntry: dedupeResult.matchedEntry,
        );
      } catch (e) {
        if (e is NoSuchMethodError) {
          await handler(messageString);
        } else {
          rethrow;
        }
      }
    }

    return true;
  }
}
