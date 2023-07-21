import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';
import 'package:budget/struct/randomConstants.dart';

class GhostTransactionsList extends StatelessWidget {
  const GhostTransactionsList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: ListView.builder(
        itemBuilder: (_, i) =>
            GhostTransactions(i: i, useHorizontalPaddingConstrained: true),
      ),
    );
  }
}

class GhostTransactions extends StatelessWidget {
  const GhostTransactions(
      {required this.i,
      required this.useHorizontalPaddingConstrained,
      super.key});

  final int i;
  final bool useHorizontalPaddingConstrained;

  @override
  Widget build(BuildContext context) {
    Color color = appStateSettings["materialYou"]
        ? Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.4)
        : getColor(context, "lightDarkAccentHeavy").withOpacity(0.3);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: useHorizontalPaddingConstrained == false
                ? 0
                : getHorizontalPaddingConstrained(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: color,
                  ),
                  height: 20,
                  width: 55 + randomDouble[i % 10] * 40,
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: color,
                  ),
                  height: 20,
                  width: 55 + randomDouble[i % 10] * 40,
                ),
              ],
            ),
            SizedBox(height: 4),
            ...[
              for (int index = 0; index < 1 + randomInt[i % 10] % 3; index++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: color,
                    ),
                    height: 51,
                  ),
                )
            ],
          ],
        ),
      ),
    );
  }
}
