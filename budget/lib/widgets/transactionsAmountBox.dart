import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/upcomingOverdueTransactionsPage.dart';
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
    required this.totalWithCountStream,
    this.totalWithCountStream2,
    required this.textColor,
    this.absolute = true,
    this.invertSign = false,
    this.getTextColor,
    this.currencyKey,
    super.key,
  });
  final Widget? openPage;
  final Function? onLongPress;
  final String label;
  final Stream<TotalWithCount?> totalWithCountStream;
  final Stream<TotalWithCount?>? totalWithCountStream2;
  final Color textColor;
  final bool absolute;
  final bool invertSign;
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
                    DoubleTotalWithCountStreamBuilder(
                      totalWithCountStream: totalWithCountStream,
                      totalWithCountStream2: totalWithCountStream2,
                      builder: (context, snapshot) {
                        double totalSpent = snapshot.data?.total ?? 0;
                        int totalCount = snapshot.data?.count ?? 0;
                        double finalAmount = snapshot.hasData == false ||
                                snapshot.data == null
                            ? 0
                            : absolute == true
                                ? (totalSpent).abs()
                                : totalSpent * (invertSign == true ? -1 : 1);
                        return Column(
                          children: [
                            CountNumber(
                              count: finalAmount,
                              duration: Duration(milliseconds: 1000),
                              initialCount: (0),
                              textBuilder: (number) {
                                return TextFont(
                                  text: convertToMoney(
                                      Provider.of<AllWallets>(context), number,
                                      currencyKey: currencyKey,
                                      addCurrencyName: currencyKey != null,
                                      finalNumber: finalAmount),
                                  textColor: getTextColor != null
                                      ? getTextColor!(totalSpent)
                                      : textColor,
                                  fontWeight: FontWeight.bold,
                                  autoSizeText: true,
                                  fontSize: 21,
                                  maxFontSize: 21,
                                  minFontSize: 10,
                                  maxLines: 1,
                                );
                              },
                            ),
                            SizedBox(height: 6),
                            TextFont(
                              text: totalCount.toString() +
                                  " " +
                                  (totalCount == 1
                                      ? "transaction".tr().toLowerCase()
                                      : "transactions".tr().toLowerCase()),
                              fontSize: 13,
                              textColor: getColor(context, "textLight"),
                            ),
                          ],
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
