import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/countNumber.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class IncomeOutcomeArrow extends StatelessWidget {
  const IncomeOutcomeArrow({
    required this.isIncome,
    this.color,
    this.iconSize,
    this.width,
    this.height,
    super.key,
  });
  final bool isIncome;
  final Color? color;
  final double? iconSize;
  final double? width;
  final double? height;
  @override
  Widget build(BuildContext context) {
    return AnimatedRotation(
      duration: Duration(milliseconds: 1700),
      curve: ElasticOutCurve(0.5),
      turns: isIncome ? 0.5 : 0,
      child: Container(
        width: width,
        height: height,
        child: UnconstrainedBox(
          clipBehavior: Clip.hardEdge,
          alignment: AlignmentDirectional.center,
          child: Icon(
            appStateSettings["outlinedIcons"]
                ? Icons.arrow_drop_down_outlined
                : Icons.arrow_drop_down_rounded,
            color: color == null
                ? (isIncome
                    ? getColor(context, "incomeAmount")
                    : getColor(context, "expenseAmount"))
                : color,
            size: iconSize,
          ),
        ),
      ),
    );
  }
}

class AmountWithColorAndArrow extends StatelessWidget {
  const AmountWithColorAndArrow({
    required this.showIncomeArrow,
    required this.totalSpent,
    required this.fontSize,
    required this.iconSize,
    required this.iconWidth,
    this.textColor,
    this.getTextColor,
    this.bold = true,
    this.alwaysShowArrow = false,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.isIncome,
    this.countNumber = true,
    this.countNumberDuration = const Duration(milliseconds: 450),
    this.absoluteValueWhenNoArrow = false,
    this.customTextBuilder,
    this.currencyKey,
    super.key,
  });
  final bool showIncomeArrow;
  final double totalSpent;
  final double fontSize;
  final double iconSize;
  final double iconWidth;
  final Color? textColor;
  final Color? Function(double totalAmount)? getTextColor;
  final bool bold;
  final bool alwaysShowArrow;
  final MainAxisAlignment mainAxisAlignment;
  final bool? isIncome;
  final bool countNumber;
  final Duration countNumberDuration;
  final bool absoluteValueWhenNoArrow;
  final Widget Function(double amount, Color textColor)? customTextBuilder;
  final String? currencyKey;

  @override
  Widget build(BuildContext context) {
    Color finalColor = (getTextColor != null
            ? (getTextColor!(totalSpent) ?? textColor)
            : textColor) ??
        (totalSpent == 0
            ? getColor(context, "black")
            : totalSpent > 0
                ? getColor(context, "incomeAmount")
                : getColor(context, "expenseAmount"));

    bool finalShowIncomeArrow = showIncomeArrow || alwaysShowArrow;
    double finalNumber = finalShowIncomeArrow
        ? totalSpent.abs()
        : absoluteValueWhenNoArrow
            ? totalSpent.abs()
            : totalSpent;

    Widget textBuilder(double number) {
      if (customTextBuilder != null)
        return customTextBuilder!(number, finalColor);
      return TextFont(
        text: convertToMoney(
          Provider.of<AllWallets>(context),
          number,
          currencyKey: currencyKey,
          finalNumber: finalNumber,
        ),
        fontSize: fontSize,
        textColor: finalColor,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: mainAxisAlignment,
      children: [
        if (finalShowIncomeArrow)
          AnimatedSizeSwitcher(
            child: finalNumber.abs() == 0 && alwaysShowArrow == false
                ? Container(
                    key: ValueKey(1),
                  )
                : IncomeOutcomeArrow(
                    key: ValueKey(2),
                    color: finalColor,
                    isIncome: isIncome ?? (totalSpent > 0),
                    iconSize: iconSize,
                    width: iconWidth,
                  ),
          ),
        countNumber
            ? CountNumber(
                count: finalNumber,
                duration: countNumberDuration,
                initialCount: (0),
                textBuilder: (number) {
                  return textBuilder(number);
                },
              )
            : textBuilder(finalNumber),
      ],
    );
  }
}
