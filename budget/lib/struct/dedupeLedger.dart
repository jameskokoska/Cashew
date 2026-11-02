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
  final String? matchReason;
  final DedupeEntryRecord? matchedEntry;
  final String? matchedKey;
  final DateTime? matchedTime;

  const DedupeCheckResult.unique({this.matchedEntry})
      : isDuplicate = false,
        matchReason = null,
        matchedKey = null,
        matchedTime = null;

  const DedupeCheckResult.duplicate({
    required this.matchReason,
    this.matchedEntry,
    this.matchedKey,
    this.matchedTime,
  }) : isDuplicate = true;
}

/// In-memory and persistent ledger tracking notification and payment events to
/// prevent duplicate transaction prompts within a configurable time window.
class DedupeLedger {
  static DedupeLedger instance = DedupeLedger();

  final List<DedupeEntryRecord> entries = [];
  final List<DedupeEntryRecord> suppressedEntries = [];

  static const Duration defaultWindow = Duration(minutes: 5);
  static const int maxLedgerCapacity = 200;

  /// Clears in-memory ledger entries (primarily for test isolation).
  void clear() {
    entries.clear();
    suppressedEntries.clear();
  }

  /// Normalizes monetary amounts to fixed 2-decimal strings to prevent IEEE 754 float comparison drift.
  static String? normalizeAmount(double? amount) {
    if (amount == null) return null;
    return amount.toStringAsFixed(2);
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
  Future<void> loadFromDatabase({Duration? window}) async {
    try {
      final dbEntries =
          await database.getAllDedupeEntries(limit: maxLedgerCapacity);
      final existingPks = {
        for (final e in entries) e.entryPk,
        for (final e in suppressedEntries) e.entryPk,
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
        } else {
          entries.add(rec);
        }
      }
      _pruneList(entries);
      _pruneList(suppressedEntries);
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
      status: 'created',
    );
    await _recordEntry(newEntry);

    return const DedupeCheckResult.unique();
  }
}
