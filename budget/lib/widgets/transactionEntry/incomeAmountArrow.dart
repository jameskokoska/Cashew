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
          alignment: Alignment.center,
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
