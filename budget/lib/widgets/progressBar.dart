import 'package:budget/colors.dart';
import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final double currentPercent;
  final Color color;
  final double height;

  const ProgressBar({
    required this.currentPercent,
    required this.color,
    this.height = 10,
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, boxConstraints) {
        double x = boxConstraints.maxWidth;
        double progressWidth = (currentPercent / 100) * x;
        return Stack(
          children: [
            Container(
              width: x,
              height: height,
              decoration: BoxDecoration(
                color: getColor(context, "lightDarkAccentHeavy"),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 100),
              width: progressWidth,
              height: height,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ],
        );
      },
    );
  }
}
