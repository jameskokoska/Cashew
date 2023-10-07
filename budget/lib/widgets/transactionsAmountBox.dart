import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:budget/widgets/countNumber.dart';
import 'package:provider/provider.dart';

// If you just added an upcoming transaction and mark it as paid, it will not show up here
// This is because the query transactionsAmountStream needs to be updated to have the new DateTime.now(),
// as it won't catch the new transaction amount!

class TransactionsAmountBox extends StatelessWidget {
  const TransactionsAmountBox({
    this.openPage,
    this.onLongPress,
    required this.label,
    required this.amountStream,
    required this.textColor,
    required this.transactionsAmountStream,
    this.absolute = true,
    this.getTextColor,
    this.currencyKey,
    super.key,
  });
  final Widget? openPage;
  final Function? onLongPress;
  final String label;
  final Stream<double?> amountStream;
  final Color textColor;
  final Stream<List<int?>> transactionsAmountStream;
  final bool absolute;
  final String? currencyKey;
  final Function(double)? getTextColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(boxShadow: boxShadowCheck(boxShadowGeneral(context))),
      child: OpenContainerNavigation(
        closedColor: getColor(context, "lightDarkAccentHeavyLight"),
        openPage: openPage ?? SizedBox.shrink(),
        borderRadius: 15,
        button: (openContainer) {
          return Tappable(
            color: getColor(context, "lightDarkAccentHeavyLight"),
            onTap: () {
              if (openPage != null) openContainer();
            },
            onLongPress: () {
              if (onLongPress != null) onLongPress!();
            },
            child: Container(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 17),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFont(
                      text: label,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(height: 6),
                    StreamBuilder<double?>(
                      stream: amountStream,
                      builder: (context, snapshot) {
                        return CountNumber(
                          count:
                              snapshot.hasData == false || snapshot.data == null
                                  ? 0
                                  : absolute == true
                                      ? (snapshot.data ?? 0).abs()
                                      : (snapshot.data ?? 0),
                          duration: Duration(milliseconds: 1000),
                          initialCount: (0),
                          textBuilder: (number) {
                            return TextFont(
                              text: convertToMoney(
                                  Provider.of<AllWallets>(context), number,
                                  currencyKey: currencyKey,
                                  addCurrencyName: currencyKey != null,
                                  finalNumber: snapshot.hasData == false ||
                                          snapshot.data == null
                                      ? 0
                                      : absolute == true
                                          ? (snapshot.data ?? 0).abs()
                                          : (snapshot.data ?? 0)),
                              textColor: getTextColor != null
                                  ? getTextColor!(snapshot.data ?? 0)
                                  : textColor,
                              fontWeight: FontWeight.bold,
                              autoSizeText: true,
                              fontSize: 21,
                              maxFontSize: 21,
                              minFontSize: 10,
                              maxLines: 1,
                            );
                          },
                        );
                      },
                    ),
                    SizedBox(height: 6),
                    StreamBuilder<List<int?>>(
                      stream: transactionsAmountStream,
                      builder: (context, snapshot) {
                        return TextFont(
                          text: snapshot.hasData == false ||
                                  snapshot.data![0] == null
                              ? "/"
                              : (snapshot.data![0].toString() +
                                  " " +
                                  (snapshot.data![0] == 1
                                      ? "transaction".tr().toLowerCase()
                                      : "transactions".tr().toLowerCase())),
                          fontSize: 13,
                          textColor: getColor(context, "textLight"),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
