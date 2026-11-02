import 'dart:async';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/dedupeLedger.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/util/appLinks.dart';
import 'package:notification_listener_service/notification_event.dart';

/// Parsed data from a Google Wallet / Google Pay transaction notification.
class GooglePayTransactionResult {
  final String merchant;
  final double amount;
  final String? currency;
  final String? cardName;
  final String? cardLast4;
  final String rawTitle;
  final String rawContent;

  const GooglePayTransactionResult({
    required this.merchant,
    required this.amount,
    this.currency,
    this.cardName,
    this.cardLast4,
    required this.rawTitle,
    required this.rawContent,
  });
}

/// Parser for Android Google Wallet and Google Pay payment notifications.
class GooglePayParser {
  static const Set<String> recognizedPackages = {
    'com.google.android.apps.walletnfcrel',
    'com.google.android.apps.nbu.paisa.user',
    'com.google.android.gms',
  };

  static const Set<String> _genericTitles = {
    'google wallet',
    'google pay',
    'google',
    'wallet',
    'gpay',
  };

  static final RegExp _amountRegex = RegExp(
    r'(?:([₱$€£¥₹]|PHP|USD|EUR|GBP|P)\s*)?([0-9]{1,3}(?:,[0-9]{3})*(?:\.[0-9]{2})|[0-9]+\.[0-9]{2})(?:\s*([₱$€£¥₹]|PHP|USD|EUR|GBP|P))?',
    caseSensitive: false,
  );

  static final RegExp _withCardRegex = RegExp(
    r'\bwith\s+([^,.\n]+)',
    caseSensitive: false,
  );

  static final RegExp _cardLast4Regex = RegExp(
    r'(?:\*\*|••••|\*{2,4})\s*(\d{4})|\b(\d{4})\b',
  );

  static final RegExp _atMerchantRegex = RegExp(
    r'\b(?:at|to|in)\s+([^,.\n]+)',
    caseSensitive: false,
  );

  /// Checks if the package belongs to Google Wallet or Google Pay ecosystem.
  static bool isRecognizedPackage(String? packageName) {
    if (packageName == null) return false;
    return recognizedPackages.contains(packageName);
  }

  /// Determines if an event comes from Google Wallet/Pay and contains payment info.
  static bool isGooglePayEvent(ServiceNotificationEvent event) {
    if (!isRecognizedPackage(event.packageName)) return false;
    return canParse(event.title, event.content);
  }

  /// Checks if a notification title and content can be parsed as a payment.
  static bool canParse(String? title, String? content) {
    return parse(title, content) != null;
  }

  /// Parses a Google Wallet or Google Pay notification into a [GooglePayTransactionResult].
  static GooglePayTransactionResult? parse(String? title, String? content) {
    if (title == null || content == null) return null;
    final trimmedTitle = title.trim();
    final trimmedContent = content.trim();

    if (trimmedTitle.isEmpty || trimmedContent.isEmpty) return null;

    // 1. Extract Amount and Currency
    final amountMatch = _amountRegex.firstMatch(trimmedContent);
    if (amountMatch == null) return null;

    final rawAmountString = amountMatch.group(2);
    if (rawAmountString == null) return null;

    final cleanAmount = rawAmountString.replaceAll(',', '');
    final amountDouble = double.tryParse(cleanAmount);
    if (amountDouble == null || amountDouble <= 0) return null;

    final prefixCurr = amountMatch.group(1);
    final suffixCurr = amountMatch.group(3);
    final rawCurrency = prefixCurr ?? suffixCurr;
    final currency = _normalizeCurrency(rawCurrency);

    // 2. Extract Card / Account hints
    String? cardName;
    String? cardLast4;

    final withMatch = _withCardRegex.firstMatch(trimmedContent);
    if (withMatch != null) {
      final fullCardString = withMatch.group(1)!.trim();
      final last4Match = _cardLast4Regex.firstMatch(fullCardString);
      if (last4Match != null) {
        cardLast4 = last4Match.group(1) ?? last4Match.group(2);
      }

      // Strip masked digits from card name
      cardName = fullCardString
          .replaceAll(RegExp(r'(?:\*\*|••••|\*{2,4})\s*\d{4}.*$'), '')
          .trim();
      if (cardName.isEmpty) cardName = null;
    }

    // 3. Extract Merchant Name
    String merchant;
    final lowerTitle = trimmedTitle.toLowerCase();
    if (!_genericTitles.contains(lowerTitle)) {
      merchant = trimmedTitle;
    } else {
      final atMatch = _atMerchantRegex.firstMatch(trimmedContent);
      if (atMatch != null) {
        merchant = atMatch
            .group(1)!
            .replaceAll(RegExp(r'\s+with\s+.*$', caseSensitive: false), '')
            .trim();
      } else {
        merchant = 'Google Wallet Purchase';
      }
    }

    return GooglePayTransactionResult(
      merchant: merchant,
      amount: amountDouble,
      currency: currency,
      cardName: cardName,
      cardLast4: cardLast4,
      rawTitle: trimmedTitle,
      rawContent: trimmedContent,
    );
  }

  /// Suggests a matching [TransactionWallet] from Cashew's database.
  static Future<TransactionWallet?> resolveWallet(
    GooglePayTransactionResult result,
  ) async {
    // 1. Match card last 4 digits against wallet account numbers
    if (result.cardLast4 != null && result.cardLast4!.isNotEmpty) {
      final wallet = await database.getRelatingWallet(result.cardLast4!);
      if (wallet != null) return wallet;
    }

    // 2. Match card name against wallet names (e.g. "UnionBank")
    if (result.cardName != null && result.cardName!.isNotEmpty) {
      final wallet = await database.getRelatingWallet(result.cardName!);
      if (wallet != null) return wallet;

      final tokens = result.cardName!.split(RegExp(r'\s+'));
      for (final token in tokens) {
        if (token.length >= 4) {
          final tokenWallet = await database.getRelatingWallet(token);
          if (tokenWallet != null) return tokenWallet;
        }
      }
    }

    // 3. Fall back to user's selected/default wallet
    final selectedPk = appStateSettings['selectedWalletPk'];
    if (selectedPk != null && selectedPk != '-1') {
      return await database.getWalletInstanceOrNull(selectedPk.toString());
    }

    return null;
  }

  /// Suggests a matching [TransactionCategory] from Cashew's database.
  static Future<TransactionCategory?> resolveCategory(
    GooglePayTransactionResult result,
  ) async {
    final foundTitle = (await database.getSimilarAssociatedTitles(
      title: result.merchant,
      limit: 1,
    ))
        .firstOrNull;
    return foundTitle?.category;
  }

  /// Dispatches the parsed Google Pay transaction into Cashew's UI flow.
  static Future<bool> processGooglePayTransaction(
    GooglePayTransactionResult result, {
    bool willPushRoute = true,
    DateTime? dateTime,
    TransactionWallet? walletOverride,
    TransactionCategory? categoryOverride,
    bool isPossibleDuplicate = false,
    DedupeEntryRecord? possibleDuplicateEntry,
  }) async {
    final wallet = walletOverride ?? await resolveWallet(result);
    final category = categoryOverride ?? await resolveCategory(result);

    if (willPushRoute || isPossibleDuplicate) {
      pushRoute(
        null,
        AddTransactionPage(
          useCategorySelectedIncome: true,
          routesToPopAfterDelete: RoutesToPopAfterDelete.None,
          selectedAmount: result.amount,
          selectedTitle: result.merchant,
          selectedCategory: category,
          startInitialAddTransactionSequence: false,
          selectedWallet: wallet,
          selectedDate: dateTime ?? DateTime.now(),
          isPossibleDuplicate: isPossibleDuplicate,
          possibleDuplicateEntry: possibleDuplicateEntry,
        ),
      );
    } else {
      if (navigatorKey.currentContext != null) {
        processAddTransactionFromParams(navigatorKey.currentContext!, {
          'title': result.merchant,
          'categoryPk': category?.categoryPk,
          'walletPk': wallet?.walletPk,
          'amount': result.amount.toString(),
          'date': (dateTime ?? DateTime.now()).toString(),
          'skipDedupe': 'true',
        });
      }
    }
    return true;
  }

  static String? _normalizeCurrency(String? raw) {
    if (raw == null) return null;
    final upper = raw.trim().toUpperCase();
    if (upper == 'P' || upper == '₱' || upper == 'PHP') return 'PHP';
    if (upper == '\$' || upper == 'USD') return 'USD';
    if (upper == '€' || upper == 'EUR') return 'EUR';
    if (upper == '£' || upper == 'GBP') return 'GBP';
    if (upper == '¥' || upper == 'JPY') return 'JPY';
    if (upper == '₹' || upper == 'INR') return 'INR';
    return upper;
  }
}
