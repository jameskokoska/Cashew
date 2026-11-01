// "Accounts" section on the home page: each account shown as a virtual card
// with a decorative background, bank name, card holder, last digits, card
// network and balance. Swipe between cards, tap to open, long-press to edit.

import 'dart:math' as math;
import 'dart:ui' show FontFeature;

import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addButton.dart';
import 'package:budget/pages/homePage/homePageWalletSwitcher.dart';
import 'package:budget/pages/walletDetailsPage.dart';
import 'package:budget/struct/bankSmsParser.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/struct/smsTransactions.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/util/keepAliveClientMixin.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ---------------------------------------------------------------------------
// Card styles
// ---------------------------------------------------------------------------

class AccountCardStyle {
  const AccountCardStyle(this.id, this.label, this.colors);
  final String id;
  final String label;
  final List<Color> colors;
}

const List<AccountCardStyle> accountCardStyles = [
  AccountCardStyle("auto", "Account colour", []),
  AccountCardStyle("midnight", "Midnight",
      [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)]),
  AccountCardStyle("aurora", "Aurora",
      [Color(0xFF1D2B64), Color(0xFF4A3B8F), Color(0xFF0E7C7B)]),
  AccountCardStyle("sunset", "Sunset",
      [Color(0xFF6A1B4D), Color(0xFFB23A48), Color(0xFFE07A3F)]),
  AccountCardStyle("ocean", "Ocean",
      [Color(0xFF0B3D91), Color(0xFF1565C0), Color(0xFF00897B)]),
  AccountCardStyle("emerald", "Emerald",
      [Color(0xFF0B3B2E), Color(0xFF14532D), Color(0xFF1F7A4D)]),
  AccountCardStyle("rosegold", "Rose gold",
      [Color(0xFF5B3A44), Color(0xFF9E5F6B), Color(0xFFC79081)]),
  AccountCardStyle("carbon", "Carbon",
      [Color(0xFF111111), Color(0xFF2B2B2B), Color(0xFF444444)]),
  AccountCardStyle("royal", "Royal",
      [Color(0xFF2E1065), Color(0xFF5B21B6), Color(0xFF7C3AED)]),
  AccountCardStyle("gold", "Gold",
      [Color(0xFF5C4011), Color(0xFF8D6A1F), Color(0xFFB8913A)]),
];

const List<String> cardNetworks = [
  "None",
  "Visa",
  "Mastercard",
  "RuPay",
  "Amex",
  "Diners",
];

const List<String> cardTypes = [
  "Savings account",
  "Current account",
  "Debit card",
  "Credit card",
  "Wallet",
];

List<Color> _gradientFor(String styleId, TransactionWallet wallet,
    BuildContext context) {
  for (final AccountCardStyle s in accountCardStyles) {
    if (s.id == styleId && s.colors.isNotEmpty) return s.colors;
  }
  // "auto": a deep gradient from the account's own colour
  final Color base = HexColor(wallet.colour,
      defaultColor: Theme.of(context).colorScheme.primary);
  final HSLColor hsl = HSLColor.fromColor(base);
  Color shade(double lightness, double hueShift) => hsl
      .withLightness(lightness.clamp(0.0, 1.0))
      .withSaturation((hsl.saturation * 0.85).clamp(0.25, 0.9))
      .withHue((hsl.hue + hueShift) % 360)
      .toColor();
  return [shade(0.16, -12), shade(0.28, 0), shade(0.40, 18)];
}

// ---------------------------------------------------------------------------
// Stored details per account
// ---------------------------------------------------------------------------

class AccountCardDetails {
  AccountCardDetails({
    this.holder,
    this.digits,
    this.network,
    this.type,
    this.style,
    this.bankName,
  });

  final String? holder;
  final String? digits;
  final String? network;
  final String? type;
  final String? style;
  final String? bankName;

  static AccountCardDetails forWallet(String walletPk) {
    final dynamic all = appStateSettings["accountCardDetails"];
    final dynamic d = all is Map ? all[walletPk] : null;
    if (d is! Map) return AccountCardDetails();
    String? str(String k) {
      final dynamic v = d[k];
      return v == null || v.toString().trim() == "" ? null : v.toString();
    }

    return AccountCardDetails(
      holder: str("holder"),
      digits: str("digits"),
      network: str("network"),
      type: str("type"),
      style: str("style"),
      bankName: str("bankName"),
    );
  }

  Map<String, dynamic> toMap() => {
        "holder": holder,
        "digits": digits,
        "network": network,
        "type": type,
        "style": style,
        "bankName": bankName,
      };

  static Future<void> save(String walletPk, AccountCardDetails details) async {
    final dynamic raw = appStateSettings["accountCardDetails"];
    final Map<String, dynamic> all = raw is Map
        ? raw.map((k, v) => MapEntry(k.toString(), v))
        : <String, dynamic>{};
    all[walletPk] = details.toMap();
    await updateSettings("accountCardDetails", all, updateGlobalState: false);
  }
}

/// What the SMS feature knows about this account: (bank short name, digits, isCard)
(String?, String?, bool) _smsInfoForWallet(String walletPk) {
  final Map<String, dynamic> links = smsAccountWallets();
  final Map<String, dynamic> balances = smsAccountBalances();
  for (final MapEntry<String, dynamic> e in links.entries) {
    if (e.value?.toString() != walletPk) continue;
    final (String bank, String digits) = splitAccountKey(e.key);
    final dynamic info = balances[e.key];
    final bool isCard = info is Map && info["card"] == true;
    String? bankName = bank == "?" ? null : bank;
    if (bankName == null && info is Map) bankName = info["bank"]?.toString();
    return (bankName, digits, isCard);
  }
  return (null, null, false);
}

String? _bankFullName(String? shortName) {
  if (shortName == null) return null;
  for (final BankInfo b in BankSmsParser.banks) {
    if (b.shortName == shortName) return b.fullName;
  }
  return shortName;
}

String _defaultHolderName() {
  final String saved = (appStateSettings["cardHolderName"] ?? "").toString();
  if (saved.trim() != "") return saved;
  return (appStateSettings["username"] ?? "").toString();
}

// ---------------------------------------------------------------------------
// Home page section
// ---------------------------------------------------------------------------

class HomePageAccountCards extends StatefulWidget {
  const HomePageAccountCards({super.key});

  @override
  State<HomePageAccountCards> createState() => _HomePageAccountCardsState();
}

class _HomePageAccountCardsState extends State<HomePageAccountCards> {
  final PageController controller = PageController(viewportFraction: 0.88);
  int page = 0;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _openPinnedPicker() async {
    await openBottomSheet(
      context,
      EditHomePagePinnedWalletsPopup(
        homePageWidgetDisplay: HomePageWidgetDisplay.WalletList,
        showCyclePicker: true,
      ),
      useCustomController: true,
    );
    homePageStateKey.currentState?.refreshState();
  }

  @override
  Widget build(BuildContext context) {
    return KeepAliveClientMixin(
      child: Padding(
        padding: const EdgeInsetsDirectional.only(bottom: 13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(
                  start: 20, end: 8, bottom: 6),
              child: Row(
                children: [
                  Expanded(
                    child: TextFont(
                      text: "Accounts",
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    tooltip: "Choose accounts",
                    icon: Icon(Icons.tune_rounded,
                        color: getColor(context, "textLight")),
                    onPressed: _openPinnedPicker,
                  ),
                ],
              ),
            ),
            StreamBuilder<List<WalletWithDetails>>(
              stream: database.watchAllWalletsWithDetails(
                  homePageWidgetDisplay: HomePageWidgetDisplay.WalletList),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return SizedBox.shrink();
                final List<WalletWithDetails> wallets = snapshot.data!;
                if (wallets.isEmpty) {
                  return Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 13),
                    child: AddButton(
                      onTap: _openPinnedPicker,
                      height: null,
                      labelUnder: "account".tr(),
                      icon: Icons.format_list_bulleted_add,
                      padding:
                          EdgeInsetsDirectional.symmetric(vertical: 10),
                    ),
                  );
                }
                if (page >= wallets.length) page = wallets.length - 1;
                return LayoutBuilder(builder: (context, constraints) {
                  final double cardWidth = constraints.maxWidth * 0.88;
                  final double cardHeight =
                      math.min(cardWidth / 1.586, 260).toDouble();
                  return Column(
                    children: [
                      SizedBox(
                        height: cardHeight + 12,
                        child: PageView.builder(
                          controller: controller,
                          itemCount: wallets.length,
                          onPageChanged: (i) => setState(() => page = i),
                          itemBuilder: (context, i) {
                            return AnimatedBuilder(
                              animation: controller,
                              builder: (context, child) {
                                double delta = 0;
                                if (controller.hasClients &&
                                    controller.position.haveDimensions) {
                                  delta = ((controller.page ?? 0) - i).abs();
                                } else {
                                  delta = (page - i).abs().toDouble();
                                }
                                final double scale =
                                    1 - (delta.clamp(0.0, 1.0) * 0.06);
                                return Transform.scale(
                                    scale: scale, child: child);
                              },
                              child: Padding(
                                padding: const EdgeInsetsDirectional
                                    .symmetric(horizontal: 6, vertical: 6),
                                child: VirtualAccountCard(
                                  walletWithDetails: wallets[i],
                                  selected:
                                      Provider.of<SelectedWalletPk>(context)
                                              .selectedWalletPk ==
                                          wallets[i].wallet.walletPk,
                                  onChanged: () => setState(() {}),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      if (wallets.length > 1)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(top: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (int i = 0; i < wallets.length; i++)
                                AnimatedContainer(
                                  duration: Duration(milliseconds: 250),
                                  margin: const EdgeInsetsDirectional
                                      .symmetric(horizontal: 3),
                                  width: i == page ? 18 : 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: i == page
                                        ? Theme.of(context)
                                            .colorScheme
                                            .primary
                                        : getColor(context, "textLight")
                                            .withOpacity(0.35),
                                    borderRadius:
                                        BorderRadius.circular(10),
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// The card
// ---------------------------------------------------------------------------

class VirtualAccountCard extends StatelessWidget {
  const VirtualAccountCard({
    required this.walletWithDetails,
    required this.selected,
    this.onChanged,
    super.key,
  });

  final WalletWithDetails walletWithDetails;
  final bool selected;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    final TransactionWallet wallet = walletWithDetails.wallet;
    final AccountCardDetails d = AccountCardDetails.forWallet(wallet.walletPk);
    final (String? smsBank, String? smsDigits, bool smsIsCard) =
        _smsInfoForWallet(wallet.walletPk);

    final String bankName =
        d.bankName ?? _bankFullName(smsBank) ?? wallet.name;
    final String? digits = d.digits ?? smsDigits;
    final String holder = (d.holder ?? _defaultHolderName()).toUpperCase();
    final String network = d.network ?? "None";
    final String type =
        d.type ?? (smsIsCard ? "Credit card" : (digits != null ? "Savings account" : "Wallet"));
    final List<Color> colors = _gradientFor(d.style ?? "auto", wallet, context);
    final double total = walletWithDetails.totalSpent ?? 0;
    final String amount = convertToMoney(
      Provider.of<AllWallets>(context),
      total,
      currencyKey: wallet.currency,
      decimals: wallet.decimals,
    );
    // Show the account's own name too when the card shows the bank's name
    final String? subtitle = bankName.trim().toLowerCase() !=
            wallet.name.trim().toLowerCase()
        ? wallet.name
        : null;

    const Color onCard = Colors.white;
    final TextStyle label = TextStyle(
      color: onCard.withOpacity(0.65),
      fontSize: 9.5,
      letterSpacing: 1.4,
      fontWeight: FontWeight.w600,
    );

    return GestureDetector(
      onTap: () => pushRoute(
          context, WatchedWalletDetailsPage(walletPk: wallet.walletPk)),
      onLongPress: () async {
        await openBottomSheet(
          context,
          EditAccountCardPopup(wallet: wallet),
        );
        onChanged?.call();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: selected
              ? Border.all(color: Colors.white.withOpacity(0.55), width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: colors.first.withOpacity(0.45),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _CardPatternPainter(
                      seed: wallet.walletPk.hashCode),
                ),
              ),
              // Glossy sheen
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment(0.2, 0.4),
                      colors: [
                        Colors.white.withOpacity(0.16),
                        Colors.white.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bank name + network
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bankName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: onCard,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              Text(
                                (subtitle != null ? "$subtitle · " : "") +
                                    type.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: label,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                        _NetworkLabel(network: network),
                      ],
                    ),
                    Spacer(),
                    // Chip + contactless
                    Row(
                      children: [
                        _CardChip(),
                        SizedBox(width: 10),
                        Icon(Icons.contactless_outlined,
                            color: onCard.withOpacity(0.8), size: 22),
                        Spacer(),
                        if (selected)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text("PRIMARY",
                                style: label.copyWith(
                                    color: onCard, fontSize: 9)),
                          ),
                      ],
                    ),
                    SizedBox(height: 10),
                    // Number
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        "••••  ••••  ••••  ${digits == null ? "••••" : digits.padLeft(4, "•")}",
                        style: TextStyle(
                          color: onCard,
                          fontSize: 19,
                          letterSpacing: 2.2,
                          fontWeight: FontWeight.w600,
                          fontFeatures: [FontFeature.tabularFigures()],
                          shadows: [
                            Shadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 3,
                                offset: Offset(0, 1)),
                          ],
                        ),
                      ),
                    ),
                    Spacer(),
                    // Holder + balance
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("CARD HOLDER", style: label),
                              SizedBox(height: 2),
                              Text(
                                holder.isEmpty ? "TAP & HOLD TO ADD" : holder,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: onCard.withOpacity(
                                      holder.isEmpty ? 0.6 : 1),
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                                type == "Credit card"
                                    ? "OUTSTANDING"
                                    : "BALANCE",
                                style: label),
                            SizedBox(height: 2),
                            Text(
                              amount,
                              style: TextStyle(
                                color: onCard,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card network shown as plain styled text (no brand logos).
class _NetworkLabel extends StatelessWidget {
  const _NetworkLabel({required this.network});
  final String network;

  @override
  Widget build(BuildContext context) {
    if (network == "None") return SizedBox.shrink();
    final bool italic = network == "Visa" || network == "RuPay";
    return Text(
      network == "Visa" || network == "Amex" ? network.toUpperCase() : network,
      style: TextStyle(
        color: Colors.white,
        fontSize: network == "Mastercard" ? 14 : 19,
        fontWeight: FontWeight.w900,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        letterSpacing: network == "Visa" ? 1.5 : 0.3,
      ),
    );
  }
}

/// A generic gold EMV-style chip.
class _CardChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF6E7A8), Color(0xFFD4AF37), Color(0xFFF1D88A)],
        ),
      ),
      child: CustomPaint(painter: _ChipLinesPainter()),
    );
  }
}

class _ChipLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = Color(0xFF9C7A1E).withOpacity(0.55)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final double w = size.width, h = size.height;
    canvas.drawLine(Offset(0, h / 3), Offset(w * 0.35, h / 3), p);
    canvas.drawLine(Offset(0, h * 2 / 3), Offset(w * 0.35, h * 2 / 3), p);
    canvas.drawLine(Offset(w * 0.65, h / 3), Offset(w, h / 3), p);
    canvas.drawLine(Offset(w * 0.65, h * 2 / 3), Offset(w, h * 2 / 3), p);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.35, h * 0.2, w * 0.3, h * 0.6),
            Radius.circular(3)),
        p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Soft circles and flowing lines; varies a little per account.
class _CardPatternPainter extends CustomPainter {
  _CardPatternPainter({required this.seed});
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final math.Random r = math.Random(seed);
    final double w = size.width, h = size.height;

    final Paint circle = Paint()..color = Colors.white.withOpacity(0.07);
    canvas.drawCircle(
        Offset(w * (0.78 + r.nextDouble() * 0.15), h * 0.05), h * 0.78, circle);
    canvas.drawCircle(Offset(w * (0.95 + r.nextDouble() * 0.1), h * 1.05),
        h * 0.55, circle..color = Colors.white.withOpacity(0.06));
    canvas.drawCircle(Offset(w * 0.05, h * 1.1), h * 0.35,
        circle..color = Colors.black.withOpacity(0.08));

    final double shift = r.nextDouble() * 0.15;
    for (int i = 0; i < 7; i++) {
      final Paint line = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..color = Colors.white.withOpacity(0.05 + i * 0.008);
      final double y0 = h * (0.62 + i * 0.05 + shift);
      final Path path = Path()
        ..moveTo(-10, y0)
        ..cubicTo(w * 0.28, h * (0.32 + i * 0.045), w * 0.62,
            h * (1.02 - i * 0.035), w + 10, h * (0.48 + i * 0.06 - shift));
      canvas.drawPath(path, line);
    }
  }

  @override
  bool shouldRepaint(covariant _CardPatternPainter oldDelegate) =>
      oldDelegate.seed != seed;
}

// ---------------------------------------------------------------------------
// Edit card details
// ---------------------------------------------------------------------------

class EditAccountCardPopup extends StatefulWidget {
  const EditAccountCardPopup({required this.wallet, super.key});
  final TransactionWallet wallet;

  @override
  State<EditAccountCardPopup> createState() => _EditAccountCardPopupState();
}

class _EditAccountCardPopupState extends State<EditAccountCardPopup> {
  late TextEditingController bankController;
  late TextEditingController holderController;
  late TextEditingController digitsController;
  late String network;
  late String type;
  late String style;
  bool holderForAll = false;

  @override
  void initState() {
    super.initState();
    final AccountCardDetails d =
        AccountCardDetails.forWallet(widget.wallet.walletPk);
    final (String? smsBank, String? smsDigits, bool smsIsCard) =
        _smsInfoForWallet(widget.wallet.walletPk);
    bankController = TextEditingController(
        text: d.bankName ?? _bankFullName(smsBank) ?? widget.wallet.name);
    holderController =
        TextEditingController(text: d.holder ?? _defaultHolderName());
    digitsController = TextEditingController(text: d.digits ?? smsDigits ?? "");
    network = d.network ?? "None";
    type = d.type ??
        (smsIsCard
            ? "Credit card"
            : (smsDigits != null ? "Savings account" : "Wallet"));
    style = d.style ?? "auto";
    holderForAll = (appStateSettings["cardHolderName"] ?? "").toString() == "";
  }

  @override
  void dispose() {
    bankController.dispose();
    holderController.dispose();
    digitsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final String holder = holderController.text.trim();
    final String digits =
        digitsController.text.replaceAll(RegExp(r"[^0-9]"), "");
    await AccountCardDetails.save(
      widget.wallet.walletPk,
      AccountCardDetails(
        bankName: bankController.text.trim(),
        holder: holder,
        digits: digits.length > 4 ? digits.substring(digits.length - 4) : digits,
        network: network,
        type: type,
        style: style,
      ),
    );
    if (holderForAll && holder != "") {
      await updateSettings("cardHolderName", holder, updateGlobalState: false);
    }
    if (mounted) Navigator.of(context).pop();
  }

  Widget _field(String label, TextEditingController c,
      {TextInputType? keyboard, int? maxLength, String? hint}) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 12),
      child: TextField(
        controller: c,
        keyboardType: keyboard,
        maxLength: maxLength,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          counterText: "",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _chips(String title, List<String> options, String value,
      ValueChanged<String> onSelected) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFont(text: title, fontSize: 14, fontWeight: FontWeight.bold),
          SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              for (final String o in options)
                ChoiceChip(
                  label: Text(o),
                  selected: o == value,
                  onSelected: (_) => setState(() => onSelected(o)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopupFramework(
      title: "Card details",
      subtitle: widget.wallet.name,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _field("Bank name", bankController),
          _field("Card holder name", holderController),
          Row(
            children: [
              Checkbox(
                value: holderForAll,
                onChanged: (v) => setState(() => holderForAll = v ?? false),
              ),
              Expanded(
                child: TextFont(
                  text: "Use this name on all cards",
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          _field("Last 4 digits", digitsController,
              keyboard: TextInputType.number, maxLength: 4, hint: "0232"),
          _chips("Network", cardNetworks, network, (v) => network = v),
          _chips("Type", cardTypes, type, (v) => type = v),
          TextFont(text: "Card design", fontSize: 14, fontWeight: FontWeight.bold),
          SizedBox(height: 8),
          SizedBox(
            height: 64,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final AccountCardStyle s in accountCardStyles)
                  GestureDetector(
                    onTap: () => setState(() => style = s.id),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(end: 10),
                      child: Column(
                        children: [
                          Container(
                            width: 56,
                            height: 36,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              gradient: LinearGradient(
                                colors: _gradientFor(
                                    s.id, widget.wallet, context),
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(
                                color: style == s.id
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(s.label, style: TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _save,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text("Save"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
