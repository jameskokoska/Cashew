import 'dart:async';
import 'package:budget/database/tables.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';

const Uuid _uuid = Uuid();

/// Model representing an individual deduplication ledger entry.
class DedupeEntryRecord {
  final String entryPk;
  final String eventKey;
  final String? packageName;
  final String? notificationId;
  final double? amount;
  final String? amountNormalized;
  final String? currency;
  final String? title;
  final String? rawContent;
  final String source;
  final DateTime dateTimeCreated;
  final DateTime? notificationTimestamp;
  String status;
  String? createdTransactionPk;
  String? matchedEntryPk;

  DedupeEntryRecord({
    String? entryPk,
    required this.eventKey,
    this.packageName,
    this.notificationId,
    this.amount,
    this.amountNormalized,
    this.currency,
    this.title,
    this.rawContent,
    this.source = 'notification',
    DateTime? dateTimeCreated,
    this.notificationTimestamp,
    this.status = 'created',
    this.createdTransactionPk,
    this.matchedEntryPk,
  })  : entryPk = entryPk ?? _uuid.v4(),
        dateTimeCreated = dateTimeCreated ?? DateTime.now();
}

/// Result returned by [DedupeLedger] when checking incoming events.
class DedupeCheckResult {
  final bool isDuplicate;
  final bool isUncertainMatch;
  final String? matchReason;
  final DedupeEntryRecord? matchedEntry;
  final String? matchedKey;
  final DateTime? matchedTime;

  const DedupeCheckResult.unique({this.matchedEntry})
      : isDuplicate = false,
        isUncertainMatch = false,
        matchReason = null,
        matchedKey = null,
        matchedTime = null;

  const DedupeCheckResult.duplicate({
    required this.matchReason,
    this.matchedEntry,
    this.matchedKey,
    this.matchedTime,
  })  : isDuplicate = true,
        isUncertainMatch = false;

  const DedupeCheckResult.uncertain({
    required this.matchReason,
    this.matchedEntry,
    this.matchedKey,
    this.matchedTime,
  })  : isDuplicate = false,
        isUncertainMatch = true;
}

/// In-memory and persistent ledger tracking notification and payment events to
/// prevent duplicate transaction prompts within a configurable time window.
class DedupeLedger {
  static DedupeLedger instance = DedupeLedger();

  final List<DedupeEntryRecord> entries = [];
  final List<DedupeEntryRecord> suppressedEntries = [];
  final List<DedupeEntryRecord> uncertainEntries = [];

  static const Duration defaultWindow = Duration(minutes: 5);
  static const int maxLedgerCapacity = 200;

  static const Set<String> genericMerchantTitles = {
    'google wallet',
    'google pay',
    'google',
    'wallet',
    'gpay',
    'payment',
    'purchase',
    'bank transfer',
    'money sent',
    'transfer sent',
    'card purchase',
    'transaction',
    'notification title',
  };

  /// Checks if a title is composed of generic banking / notification action terms.
  static bool isGenericTitle(String? title) {
    if (title == null || title.trim().isEmpty) return true;
    final lower = title.trim().toLowerCase();
    if (genericMerchantTitles.contains(lower)) return true;
    const genericActionWords = {
      'purchase',
      'payment',
      'transfer',
      'alert',
      'sent',
      'received',
      'debit',
      'credit',
      'notification',
      'transaction',
      'notice',
      'update',
    };
    final words =
        lower.split(RegExp(r'[\s\-_:,.]+')).where((w) => w.isNotEmpty).toList();
    if (words.isNotEmpty && words.any((w) => genericActionWords.contains(w))) {
      return true;
    }
    return false;
  }

  /// Clears in-memory ledger entries (primarily for test isolation).
  void clear() {
    entries.clear();
    suppressedEntries.clear();
    uncertainEntries.clear();
  }

  /// Normalizes monetary amounts to fixed 2-decimal strings to prevent IEEE 754 float comparison drift.
  static String? normalizeAmount(double? amount) {
    if (amount == null) return null;
    return amount.toStringAsFixed(2);
  }

  /// Extracts potential merchant name from notification text after common prepositions.
  static String? extractMerchantFromText(String? text) {
    if (text == null || text.trim().isEmpty) return null;
    final atMatch = RegExp(r'\b(?:at|to|in)\s+([^,.\n]+)', caseSensitive: false)
        .firstMatch(text);
    if (atMatch != null) {
      String m = atMatch.group(1)!.trim();
      m = m
          .replaceAll(RegExp(r'\s+with\s+.*$', caseSensitive: false), '')
          .trim();
      m = m.replaceAll(RegExp(r'[\.!\?]+$'), '').trim();
      if (m.isNotEmpty && !isGenericTitle(m)) {
        return m.toLowerCase();
      }
    }
    return null;
  }

  /// Evaluates whether two events share corroborating merchant details.
  /// Returns `true` if merchants match or content confirms the same merchant.
  /// Returns `false` if merchants conflict, or if merchant information is ambiguous/uncertain.
  static bool hasCorroboratingMerchant({
    String? title1,
    String? content1,
    String? title2,
    String? content2,
    String? source1,
    String? source2,
    String? package1,
    String? package2,
  }) {
    final t1 = title1?.trim().toLowerCase();
    final t2 = title2?.trim().toLowerCase();
    final c1 = content1?.trim().toLowerCase() ?? '';
    final c2 = content2?.trim().toLowerCase() ?? '';

    // If both are from identical source and package, and titles match:
    if (source1 != null &&
        source1 == source2 &&
        package1 == package2 &&
        t1 != null &&
        t1.isNotEmpty &&
        t1 == t2) {
      return true;
    }

    final isGen1 = isGenericTitle(t1);
    final isGen2 = isGenericTitle(t2);

    final m1 = isGen1 ? extractMerchantFromText(content1) : t1;
    final m2 = isGen2 ? extractMerchantFromText(content2) : t2;

    if (m1 != null && m2 != null) {
      if (m1 == m2 || m1.contains(m2) || m2.contains(m1)) {
        return true;
      }
      if (c1.contains(m2) || c2.contains(m1)) {
        return true;
      }
      // Both have distinct non-matching merchants -> conflicting details!
      return false;
    }

    if (m1 != null && (c2.contains(m1) || (t2 != null && t2.contains(m1)))) {
      return true;
    }

    if (m2 != null && (c1.contains(m2) || (t1 != null && t1.contains(m2)))) {
      return true;
    }

    // Common known merchant keywords check across contents
    if (c1.isNotEmpty && c2.isNotEmpty) {
      final commonKeywords = [
        'shell gas',
        'maribank',
        'gotyme',
        'maya',
        '7-eleven',
        'starbucks',
        'mcdonald',
        'jollibee',
        'grab',
      ];
      for (final kw in commonKeywords) {
        if (c1.contains(kw) && c2.contains(kw)) {
          return true;
        }
      }
    }

    return false;
  }

  /// Builds a deterministic key for exact notification identity.
  static String generateExactNotificationKey(
    String? packageName,
    String? notificationId,
  ) {
    return 'notif:${packageName ?? ''}:${notificationId ?? ''}';
  }

  /// Builds a normalized payment key based on amount and currency.
  static String generatePaymentKey({
    required double amount,
    String? currency,
  }) {
    final normAmount = normalizeAmount(amount) ?? '0.00';
    final normCurrency = currency?.trim().toUpperCase() ?? '';
    return 'pay:$normAmount:$normCurrency';
  }

  void _pruneList(List<DedupeEntryRecord> list) {
    if (list.length > maxLedgerCapacity) {
      list.removeRange(0, list.length - maxLedgerCapacity);
    }
  }

  /// Safely attempts to persist an entry to Drift if the database is initialized.
  Future<void> _tryPersist(DedupeEntryRecord record) async {
    try {
      await database.insertDedupeEntry(
        DedupeEntriesCompanion(
          entryPk: Value(record.entryPk),
          eventKey: Value(record.eventKey),
          packageName: Value(record.packageName),
          notificationId: Value(record.notificationId),
          amount: Value(record.amount),
          amountNormalized: Value(record.amountNormalized),
          currency: Value(record.currency),
          title: Value(record.title),
          rawContent: Value(record.rawContent),
          source: Value(record.source),
          dateTimeCreated: Value(record.dateTimeCreated),
          notificationTimestamp: Value(record.notificationTimestamp),
          status: Value(record.status),
          createdTransactionPk: Value(record.createdTransactionPk),
          matchedEntryPk: Value(record.matchedEntryPk),
        ),
      );
    } catch (_) {
      // Ignored if running in an environment without initialized Drift database (e.g. tests)
    }
  }

  Future<void> _recordSuppressedEntry(DedupeEntryRecord suppressed) async {
    suppressedEntries.add(suppressed);
    _pruneList(suppressedEntries);
    await _tryPersist(suppressed);
  }

  Future<void> _recordUncertainEntry(DedupeEntryRecord uncertain) async {
    uncertainEntries.add(uncertain);
    _pruneList(uncertainEntries);
    entries.add(uncertain);
    _pruneList(entries);
    await _tryPersist(uncertain);
  }

  Future<void> _recordEntry(DedupeEntryRecord entry) async {
    entries.add(entry);
    _pruneList(entries);
    await _tryPersist(entry);
  }

  /// Searches active ledger entries for an exact notification match within [window].
  DedupeEntryRecord? findExactNotificationMatch({
    required String? packageName,
    required String? notificationId,
    required DateTime now,
    required Duration window,
  }) {
    if (packageName == null ||
        packageName.isEmpty ||
        notificationId == null ||
        notificationId.isEmpty) {
      return null;
    }
    for (final existing in entries.reversed) {
      if (existing.packageName == packageName &&
          existing.notificationId == notificationId) {
        final diff = now.difference(existing.dateTimeCreated).abs();
        if (diff <= window) {
          return existing;
        }
      }
    }
    return null;
  }

  /// Searches active ledger entries for a payment match by amount and currency within [window].
  DedupeEntryRecord? findPaymentMatch({
    required String? normAmount,
    required String? normCurrency,
    required DateTime now,
    required Duration window,
  }) {
    if (normAmount == null) return null;
    for (final existing in entries.reversed) {
      if (existing.amountNormalized == normAmount) {
        if (normCurrency != null &&
            existing.currency != null &&
            normCurrency != existing.currency) {
          continue;
        }
        final diff = now.difference(existing.dateTimeCreated).abs();
        if (diff <= window) {
          return existing;
        }
      }
    }
    return null;
  }

  /// Loads recent deduplication entries from Drift if available.
  Future<void> loadFromDatabase({Duration? window = defaultWindow}) async {
    try {
      final dbEntries =
          await database.getAllDedupeEntries(limit: maxLedgerCapacity);
      final existingPks = {
        for (final e in entries) e.entryPk,
        for (final e in suppressedEntries) e.entryPk,
        for (final e in uncertainEntries) e.entryPk,
      };
      final cutoff = window != null ? DateTime.now().subtract(window) : null;
      for (final e in dbEntries.reversed) {
        if (existingPks.contains(e.entryPk)) continue;
        if (cutoff != null && e.dateTimeCreated.isBefore(cutoff)) continue;
        final rec = DedupeEntryRecord(
          entryPk: e.entryPk,
          eventKey: e.eventKey,
          packageName: e.packageName,
          notificationId: e.notificationId,
          amount: e.amount,
          amountNormalized: e.amountNormalized,
          currency: e.currency,
          title: e.title,
          rawContent: e.rawContent,
          source: e.source,
          dateTimeCreated: e.dateTimeCreated,
          notificationTimestamp: e.notificationTimestamp,
          status: e.status,
          createdTransactionPk: e.createdTransactionPk,
          matchedEntryPk: e.matchedEntryPk,
        );
        if (e.status == 'suppressed') {
          suppressedEntries.add(rec);
        } else if (e.status == 'uncertain') {
          uncertainEntries.add(rec);
          entries.add(rec);
        } else {
          entries.add(rec);
        }
      }
      _pruneList(entries);
      _pruneList(suppressedEntries);
      _pruneList(uncertainEntries);
    } catch (_) {
      // Ignored if database is unavailable
    }
  }

  /// Checks if a notification event is a duplicate within [window] and records it.
  Future<DedupeCheckResult> checkAndRecordNotification({
    required String? packageName,
    required String? notificationId,
    double? amount,
    String? currency,
    String? title,
    String? rawContent,
    DateTime? eventTime,
    Duration window = defaultWindow,
  }) async {
    final now = eventTime ?? DateTime.now();
    final normAmount = normalizeAmount(amount);
    final normCurrency = currency?.trim().toUpperCase();

    // 1. Tier 1: Exact Notification Check (same packageName and notificationId)
    final exactMatch = findExactNotificationMatch(
      packageName: packageName,
      notificationId: notificationId,
      now: now,
      window: window,
    );
    if (exactMatch != null) {
      final suppressed = DedupeEntryRecord(
        eventKey: generateExactNotificationKey(packageName, notificationId),
        packageName: packageName,
        notificationId: notificationId,
        amount: amount,
        amountNormalized: normAmount,
        currency: normCurrency,
        title: title,
        rawContent: rawContent,
        source: 'notification',
        dateTimeCreated: now,
        notificationTimestamp: eventTime,
        status: 'suppressed',
        matchedEntryPk: exactMatch.entryPk,
      );
      await _recordSuppressedEntry(suppressed);
      return DedupeCheckResult.duplicate(
        matchReason: 'exact_notification',
        matchedEntry: exactMatch,
        matchedKey: exactMatch.eventKey,
        matchedTime: exactMatch.dateTimeCreated,
      );
    }

    // 2. Tier 2: Payment Window Match (same amount within time window across packages)
    if (amount != null && amount > 0 && normAmount != null) {
      final paymentMatch = findPaymentMatch(
        normAmount: normAmount,
        normCurrency: normCurrency,
        now: now,
        window: window,
      );
      if (paymentMatch != null) {
        final isCorroborated = hasCorroboratingMerchant(
          title1: paymentMatch.title,
          content1: paymentMatch.rawContent,
          title2: title,
          content2: rawContent,
          source1: paymentMatch.source,
          source2: 'notification',
          package1: paymentMatch.packageName,
          package2: packageName,
        );

        if (isCorroborated) {
          final suppressed = DedupeEntryRecord(
            eventKey: generateExactNotificationKey(packageName, notificationId),
            packageName: packageName,
            notificationId: notificationId,
            amount: amount,
            amountNormalized: normAmount,
            currency: normCurrency,
            title: title,
            rawContent: rawContent,
            source: 'notification',
            dateTimeCreated: now,
            notificationTimestamp: eventTime,
            status: 'suppressed',
            matchedEntryPk: paymentMatch.entryPk,
          );
          await _recordSuppressedEntry(suppressed);
          return DedupeCheckResult.duplicate(
            matchReason: 'payment_window_match',
            matchedEntry: paymentMatch,
            matchedKey: paymentMatch.eventKey,
            matchedTime: paymentMatch.dateTimeCreated,
          );
        } else {
          final uncertain = DedupeEntryRecord(
            eventKey: generateExactNotificationKey(packageName, notificationId),
            packageName: packageName,
            notificationId: notificationId,
            amount: amount,
            amountNormalized: normAmount,
            currency: normCurrency,
            title: title,
            rawContent: rawContent,
            source: 'notification',
            dateTimeCreated: now,
            notificationTimestamp: eventTime,
            status: 'uncertain',
            matchedEntryPk: paymentMatch.entryPk,
          );
          await _recordUncertainEntry(uncertain);
          return DedupeCheckResult.uncertain(
            matchReason: 'uncertain_merchant',
            matchedEntry: paymentMatch,
            matchedKey: paymentMatch.eventKey,
            matchedTime: paymentMatch.dateTimeCreated,
          );
        }
      }
    }

    // 3. Unique event: record as created
    final newEntry = DedupeEntryRecord(
      eventKey: generateExactNotificationKey(packageName, notificationId),
      packageName: packageName,
      notificationId: notificationId,
      amount: amount,
      amountNormalized: normAmount,
      currency: normCurrency,
      title: title,
      rawContent: rawContent,
      source: 'notification',
      dateTimeCreated: now,
      notificationTimestamp: eventTime,
      status: 'created',
    );
    await _recordEntry(newEntry);

    return const DedupeCheckResult.unique();
  }

  /// Checks if a payment event (e.g. from App Link or Shortcut) is duplicate within [window].
  Future<DedupeCheckResult> checkAndRecordPayment({
    required double amount,
    String? currency,
    String? title,
    String source = 'app_link',
    String? packageName,
    String? notificationId,
    DateTime? eventTime,
    Duration window = defaultWindow,
  }) async {
    final now = eventTime ?? DateTime.now();
    final normAmount = normalizeAmount(amount);
    final normCurrency = currency?.trim().toUpperCase();

    if (normAmount != null) {
      final paymentMatch = findPaymentMatch(
        normAmount: normAmount,
        normCurrency: normCurrency,
        now: now,
        window: window,
      );
      if (paymentMatch != null) {
        final isCorroborated = hasCorroboratingMerchant(
          title1: paymentMatch.title,
          content1: paymentMatch.rawContent,
          title2: title,
          content2: null,
          source1: paymentMatch.source,
          source2: source,
          package1: paymentMatch.packageName,
          package2: packageName,
        );

        if (isCorroborated) {
          final suppressed = DedupeEntryRecord(
            eventKey: generatePaymentKey(
              amount: amount,
              currency: normCurrency,
            ),
            packageName: packageName,
            notificationId: notificationId,
            amount: amount,
            amountNormalized: normAmount,
            currency: normCurrency,
            title: title,
            source: source,
            dateTimeCreated: now,
            notificationTimestamp: eventTime,
            status: 'suppressed',
            matchedEntryPk: paymentMatch.entryPk,
          );
          await _recordSuppressedEntry(suppressed);
          return DedupeCheckResult.duplicate(
            matchReason: 'payment_window_match',
            matchedEntry: paymentMatch,
            matchedKey: paymentMatch.eventKey,
            matchedTime: paymentMatch.dateTimeCreated,
          );
        } else {
          final uncertain = DedupeEntryRecord(
            eventKey: generatePaymentKey(
              amount: amount,
              currency: normCurrency,
            ),
            packageName: packageName,
            notificationId: notificationId,
            amount: amount,
            amountNormalized: normAmount,
            currency: normCurrency,
            title: title,
            source: source,
            dateTimeCreated: now,
            notificationTimestamp: eventTime,
            status: 'uncertain',
            matchedEntryPk: paymentMatch.entryPk,
          );
          await _recordUncertainEntry(uncertain);
          return DedupeCheckResult.uncertain(
            matchReason: 'uncertain_merchant',
            matchedEntry: paymentMatch,
            matchedKey: paymentMatch.eventKey,
            matchedTime: paymentMatch.dateTimeCreated,
          );
        }
      }
    }

    final newEntry = DedupeEntryRecord(
      eventKey: generatePaymentKey(
        amount: amount,
        currency: normCurrency,
      ),
      packageName: packageName,
      notificationId: notificationId,
      amount: amount,
      amountNormalized: normAmount,
      currency: normCurrency,
      title: title,
      source: source,
      dateTimeCreated: now,
      notificationTimestamp: eventTime,
      status: 'created',
    );
    await _recordEntry(newEntry);

    return const DedupeCheckResult.unique();
  }
}
