import 'package:flutter/material.dart';

class IncomeOutcomeArrow extends StatelessWidget {
  const IncomeOutcomeArrow({
    required this.isIncome,
    required this.color,
    this.iconSize,
    this.width,
    super.key,
  });
  final bool isIncome;
  final Color color;
  final double? iconSize;
  final double? width;
  @override
  Widget build(BuildContext context) {
    return AnimatedRotation(
      duration: Duration(milliseconds: 1700),
      curve: ElasticOutCurve(0.5),
      turns: isIncome ? 0.5 : 0,
      child: Container(
        width: width,
        child: UnconstrainedBox(
          clipBehavior: Clip.hardEdge,
          alignment: Alignment.center,
          child: Icon(
            Icons.arrow_drop_down_rounded,
            color: color,
            size: iconSize,
          ),
        ),
      ),
    );
  }
}
