// Parses transaction SMS sent by Indian banks and UPI apps.
//
// Pure Dart (no Flutter imports) so it can be unit tested on its own.
// Covers the common formats of SBI, HDFC, ICICI, Axis, Kotak, Paytm and
// generic UPI / card / NACH messages. Anything that is not a completed
// transaction (OTPs, offers, failed payments, payment requests, "will be
// debited" reminders) returns null so it never becomes a transaction.

enum BankSmsType { debit, credit }

class ParsedBankSms {
  ParsedBankSms({
    required this.type,
    required this.amount,
    this.merchant,
    this.accountLast4,
    this.balance,
    this.isAutopay = false,
    this.reference,
    this.bank,
    this.channel,
  });

  final BankSmsType type;
  final double amount;

  /// Who the money went to (debit) or came from (credit), if found.
  final String? merchant;

  /// Last 4 digits of the account or card, if found.
  final String? accountLast4;

  /// Available balance after the transaction, if the SMS reports it.
  final double? balance;

  /// True for autopay, e-mandate, NACH, ECS and standing-instruction debits.
  final bool isAutopay;

  /// UPI reference / UTR / RRN, used to avoid adding the same payment twice.
  final String? reference;

  /// Bank name, e.g. "HDFC".
  final String? bank;

  /// "UPI", "Card", "ATM", "NEFT", "IMPS", "NACH"... if detected.
  final String? channel;

  bool get isDebit => type == BankSmsType.debit;

  /// A readable transaction title.
  String get title {
    String base;
    if (merchant != null && merchant!.isNotEmpty) {
      base = merchant!;
    } else if (channel == "ATM") {
      base = "ATM withdrawal";
    } else if (isDebit) {
      base = channel != null ? "$channel payment" : "Bank debit";
    } else {
      base = channel != null ? "$channel received" : "Bank credit";
    }
    if (isAutopay && !base.toLowerCase().contains("autopay")) {
      return "Autopay: $base";
    }
    return base;
  }

  @override
  String toString() =>
      "ParsedBankSms(${type.name}, $amount, merchant: $merchant, acct: $accountLast4, "
      "bal: $balance, autopay: $isAutopay, ref: $reference, bank: $bank, channel: $channel)";
}

class BankSmsParser {
  static const String _cur = r"(?:rs\.?|inr|₹)";
  static const String _num = r"([0-9][0-9,]*(?:\.[0-9]{1,2})?)";

  static RegExp _re(String pattern) =>
      RegExp(pattern, caseSensitive: false, multiLine: true);

  // ---- Messages that are never transactions ----
  static final List<RegExp> _ignore = [
    // OTPs and verification codes
    _re(r"\botp\b|one[- ]time password|verification code|\bcode is\b"),
    // Failed / declined
    _re(r"\b(failed|declined|unsuccessful|rejected|could not be (processed|completed)|insufficient (funds|balance))\b"),
    // Future debits: autopay / mandate reminders, bill due dates
    _re(r"\b(will|shall|would) be (debited|deducted|charged|credited|processed)\b|\bto be (debited|deducted|charged)\b"),
    _re(r"\bis due\b|\bdue (on|date|by)\b|minimum (amount )?due|\bpre[- ]?debit\b|\bupcoming (payment|debit|mandate)\b|\bscheduled (for|on)\b"),
    // Payment requests (not money moved)
    _re(r"\bhas requested\b|\bcollect request\b|\brequested (money|payment|rs|inr|₹)|\brequest(ed)? (for|of) (rs|inr|₹)"),
    // Mandate set up / cancelled, without money moving
    _re(r"\bmandate (is |has been )?(created|registered|set ?up|successfully set|revoked|cancelled|paused)\b"),
    // Marketing
    _re(r"\b(pre-?approved|apply now|click here to apply|limited period|eligible for (a )?(loan|credit))\b"),
    // Credit card bill payment acknowledgements (would double count the bank debit)
    _re(r"\b(payment|pymt)\b.{0,60}\b(received|credited)\b.{0,60}\bcard\b"),
    _re(r"\bcard\b.{0,60}\b(payment|pymt)\b.{0,40}\breceived\b"),
  ];

  // ---- Direction keywords ----
  static final RegExp _debitWords = _re(
      r"\b(?:debited|spent|paid|sent|withdrawn|withdrawal|purchase|debit(?!\s*card))\b|\bdr\.?(?=\s)");
  static final RegExp _creditWords = _re(
      r"\b(?:credited|received|deposited|refunded|refund|reversed|reversal)\b|\bcr\.?(?=\s)");
  static final RegExp _refundWords =
      _re(r"\b(refund(ed)?|reversed|reversal)\b");

  // ---- Autopay ----
  static final RegExp _autopay = _re(
      r"\b(auto[- ]?pay|auto[- ]?debit|e-?mandate|mandate|nach|ecs|standing instruction|recurring payment|si debit)\b");

  // ---- Amounts ----
  static final RegExp _currencyAmount = _re("(?<![a-z])$_cur\\s*$_num");
  static final RegExp _keywordAmountNoCurrency = _re(
      r"\b(?:debited|credited)\s+(?:by|with|for)\s+" + _num + r"(?!\s*%)");

  // ---- Balance ----
  static final RegExp _balance = _re(
      r"\b(?:avl\.?|avail(?:able)?|aval|updated|clear|total|net|a/c|ac)?\s*bal(?:ance)?\.?\s*(?:is|:|-|of|as on [0-9a-z/ -]+?:)?\s*(?:" +
          _cur +
          r")?\s*:?\s*(-?" +
          _num.substring(1));

  // ---- Account / card ----
  static final List<RegExp> _accountPatterns = [
    _re(r"\b(?:a/?c|acct|account|ac)\b\.?\s*(?:no\.?|number|num)?\s*:?\s*(?:ending\s*(?:with|in)?\s*)?[x*.\-]*\s*([0-9]{3,6})\b"),
    _re(r"\bcard\b\s*(?:no\.?|number)?\s*(?:ending\s*(?:with|in)?\s*)?[x*.\-]*\s*([0-9]{4})\b"),
    _re(r"\bending\s*(?:with|in)?\s*[x*]*([0-9]{4})\b"),
  ];

  // ---- Reference numbers ----
  static final List<RegExp> _refPatterns = [
    _re(r"\bupi/p2[am]/([0-9]{8,})"),
    _re(r"\b(?:upi\s*(?:ref|txn)?\.?\s*(?:no|id)?\.?|ref(?:erence)?\.?\s*(?:no|num|number|id)?\.?|refno|utr(?:\s*no)?|rrn|txn\s*(?:id|no)|transaction\s*id)\s*[:.\-#]?\s*([a-z0-9]{6,})"),
  ];

  // ---- Merchant / counter-party ----
  static const String _stop =
      r"(?=\s+(?:on|ref|refno|upi|via|avl|avail|using|from|for|info|txn|dt|date|is|has|thru|through|with|bal|not|if|call)\b|\s*(?:[;,(\n]|\.(?:\s|$))|\s+\d|$)";
  static final List<RegExp> _debitMerchantPatterns = [
    _re(r"\bupi/p2[am]/[0-9]+/([^/\n]+)"),
    _re(r";\s*([a-z0-9 &._@'-]{2,40}?)\s+credited\b"),
    _re(r"\b(?:to|at|towards|trf to|transfer to|paid to|sent to)\s+(?:vpa\s+|a/c\s+)?([a-z0-9][a-z0-9 &._@'*-]{1,40}?)" +
        _stop),
    _re(r"\binfo:?\s*(?:upi[/-])?([a-z0-9][a-z0-9 &._@'*/-]{2,40}?)" + _stop),
  ];
  static final List<RegExp> _creditMerchantPatterns = [
    _re(r"\bupi/p2[am]/[0-9]+/([^/\n]+)"),
    _re(r"\bfrom\s+(?:vpa\s+)?([a-z0-9][a-z0-9 &._@'*-]{1,40}?)" +
        _stop),
    _re(r"\binfo:?\s*(?:upi[/-])?([a-z0-9][a-z0-9 &._@'*/-]{2,40}?)" + _stop),
  ];

  // ---- Bank names ----
  static final Map<String, RegExp> _banks = {
    "SBI": _re(r"\bsbi\b|sbiinb|sbiupi|sbicrd|state bank"),
    "HDFC": _re(r"hdfc"),
    "ICICI": _re(r"icici"),
    "Axis": _re(r"\baxis\b|axisbk"),
    "Kotak": _re(r"kotak"),
    "Paytm": _re(r"paytm"),
    "PNB": _re(r"\bpnb\b|punjab national"),
    "Bank of Baroda": _re(r"\bbob\b|bank of baroda|barodambank"),
    "Canara": _re(r"canara"),
    "Union Bank": _re(r"union bank|unionb"),
    "IDFC First": _re(r"idfc"),
    "Yes Bank": _re(r"yes ?bank|yesbnk"),
    "IndusInd": _re(r"indusind|indusb"),
    "AU Bank": _re(r"\bau bank|aubank"),
    "Federal": _re(r"federal|fedbnk"),
  };

  /// Returns null if the SMS is not a completed bank transaction.
  ///
  /// [sender] is the SMS sender (e.g. "VM-HDFCBK"). Messages from ordinary
  /// phone numbers are ignored so a friend's "sent you Rs 500" is not added.
  static ParsedBankSms? parse(String body, {String? sender}) {
    final String text = body.replaceAll(RegExp(r"[ \t]+"), " ").trim();
    if (text.isEmpty) return null;

    if (sender != null && _looksLikePersonalNumber(sender)) return null;
    for (final RegExp r in _ignore) {
      if (r.hasMatch(text)) return null;
    }

    // Direction
    final RegExpMatch? debitMatch = _debitWords.firstMatch(text);
    final RegExpMatch? creditMatch = _creditWords.firstMatch(text);
    BankSmsType type;
    if (_refundWords.hasMatch(text)) {
      type = BankSmsType.credit;
    } else if (debitMatch != null && creditMatch != null) {
      type = debitMatch.start <= creditMatch.start
          ? BankSmsType.debit
          : BankSmsType.credit;
    } else if (debitMatch != null) {
      type = BankSmsType.debit;
    } else if (creditMatch != null) {
      type = BankSmsType.credit;
    } else {
      return null;
    }

    // Must look like it came from a bank / payment service
    final bool bankLike = _re(
            r"\b(a/?c|acct|account|card|upi|bank|imps|neft|rtgs|vpa|wallet|atm|nach|ecs|mandate)\b")
        .hasMatch(text);
    if (!bankLike) return null;

    final double? amount = _findAmount(text);
    if (amount == null || amount <= 0) return null;

    final String? bank = _findBank("${sender ?? ""} $text");
    return ParsedBankSms(
      type: type,
      amount: amount,
      merchant: _findMerchant(text, type),
      accountLast4: _findAccount(text),
      balance: _findBalance(text),
      isAutopay: type == BankSmsType.debit && _autopay.hasMatch(text),
      reference: _findReference(text),
      bank: bank,
      channel: _findChannel(text),
    );
  }

  static bool _looksLikePersonalNumber(String sender) {
    final String s = sender.replaceAll(RegExp(r"[\s-]"), "");
    return RegExp(r"^\+?[0-9]{10,13}$").hasMatch(s);
  }

  static double? _toDouble(String s) =>
      double.tryParse(s.replaceAll(",", "").replaceAll(RegExp(r"\.$"), ""));

  static bool _isBalanceOrLimitContext(String text, int start) {
    final int from = start - 25 < 0 ? 0 : start - 25;
    final String before = text.substring(from, start).toLowerCase();
    return RegExp(r"(bal(ance)?|limit|lmt|due|outstanding)\s*[a-z]*\.?\s*(is|:|-|of)?\s*$")
        .hasMatch(before);
  }

  static double? _findAmount(String text) {
    for (final RegExpMatch m in _currencyAmount.allMatches(text)) {
      if (_isBalanceOrLimitContext(text, m.start)) continue;
      final double? v = _toDouble(m.group(1)!);
      if (v != null && v > 0) return v;
    }
    final RegExpMatch? m = _keywordAmountNoCurrency.firstMatch(text);
    if (m != null) return _toDouble(m.group(1)!);
    return null;
  }

  static double? _findBalance(String text) {
    final RegExpMatch? m = _balance.firstMatch(text);
    if (m == null) return null;
    return _toDouble(m.group(1)!);
  }

  static String? _findAccount(String text) {
    for (final RegExp r in _accountPatterns) {
      final RegExpMatch? m = r.firstMatch(text);
      if (m != null) {
        final String digits = m.group(1)!;
        return digits.length > 4 ? digits.substring(digits.length - 4) : digits;
      }
    }
    return null;
  }

  static String? _findReference(String text) {
    for (final RegExp r in _refPatterns) {
      for (final RegExpMatch m in r.allMatches(text)) {
        final String ref = m.group(1)!;
        // Needs at least one digit, otherwise it's probably a word
        if (RegExp(r"[0-9]").hasMatch(ref)) return ref.toUpperCase();
      }
    }
    return null;
  }

  static String? _findBank(String text) {
    for (final MapEntry<String, RegExp> e in _banks.entries) {
      if (e.value.hasMatch(text)) return e.key;
    }
    return null;
  }

  static String? _findChannel(String text) {
    if (_re(r"\b(nach|ecs)\b").hasMatch(text)) return "NACH";
    if (_re(r"\b(upi|vpa)\b").hasMatch(text)) return "UPI";
    if (_re(r"\batm\b|withdrawn|withdrawal|cash wdl").hasMatch(text))
      return "ATM";
    if (_re(r"\bcard\b").hasMatch(text)) return "Card";
    if (_re(r"\bimps\b").hasMatch(text)) return "IMPS";
    if (_re(r"\bneft\b").hasMatch(text)) return "NEFT";
    if (_re(r"\brtgs\b").hasMatch(text)) return "RTGS";
    return null;
  }

  static final RegExp _junkMerchant = _re(
      r"^(your|you|me|the|rs|inr|linked|a/?c|acct|account|ac|card|bank|mobile|block|dispute|report|customer|self|beneficiary|upi|vpa|us|sms|call|not|x+[0-9]*|[0-9 x*-]+)$");

  static String? _findMerchant(String text, BankSmsType type) {
    final List<RegExp> patterns = type == BankSmsType.debit
        ? _debitMerchantPatterns
        : _creditMerchantPatterns;
    for (final RegExp r in patterns) {
      for (final RegExpMatch m in r.allMatches(text)) {
        final String? cleaned = _cleanMerchant(m.group(1)!);
        if (cleaned != null) return cleaned;
      }
    }
    return null;
  }

  static String? _cleanMerchant(String raw) {
    String s = raw.trim();
    // VPA: keep the part before @ ("swiggy.upi@axisbank" -> "swiggy.upi")
    if (s.contains("@")) {
      s = s.split("@").first.replaceAll(RegExp(r"[._]+"), " ");
    }
    s = s
        .replaceAll(RegExp(r"^(mr|mrs|ms|m/s)\.?\s+", caseSensitive: false), "")
        .replaceAll(RegExp(r"[*_]+"), " ")
        .replaceAll(RegExp(r"\s+"), " ")
        .trim();
    s = s.replaceAll(RegExp(r"[.\-/ ]+$"), "");
    if (s.length < 2) return null;
    if (_junkMerchant.hasMatch(s)) return null;
    if (RegExp(r"^[0-9]+$").hasMatch(s)) return null;
    if (RegExp(r"^(a/?c|acct|account|card|mobile)\b", caseSensitive: false)
        .hasMatch(s)) return null;
    return _titleCase(s);
  }

  static String _titleCase(String s) {
    // Leave mixed-case names alone; fix ALL CAPS / all lower.
    if (s != s.toUpperCase() && s != s.toLowerCase()) return s;
    return s.split(" ").map((w) {
      if (w.isEmpty) return w;
      if (_keepUpper.contains(w.toUpperCase())) return w.toUpperCase();
      return w[0].toUpperCase() + w.substring(1).toLowerCase();
    }).join(" ");
  }

  static const Set<String> _keepUpper = {
    "SBI", "LIC", "BSNL", "ATM", "UPI", "IRCTC", "ACT", "HP", "BP", "KFC",
  };
}
