import 'package:budget/colors.dart';
import 'package:budget/functions.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/material.dart';

class SaveBottomButton extends StatelessWidget {
  final String label;
  final Function() onTap;
  final bool disabled;
  const SaveBottomButton({
    super.key,
    required this.label,
    required this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Transform.translate(
          offset: Offset(0, 1),
          child: Container(
            height: 12,
            foregroundDecoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Theme.of(context).canvasColor,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.1, 1],
              ),
            ),
          ),
        ),
        Tappable(
          onTap: disabled ? () {} : onTap,
          child: Container(
            margin: EdgeInsets.only(bottom: bottomPaddingSafeArea),
            color: Theme.of(context).canvasColor,
            height: 60,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 5,
              ),
              child: Button(
                label: label,
                onTap: disabled ? () {} : onTap,
                color: disabled ? Colors.grey : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
