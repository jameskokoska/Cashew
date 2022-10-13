import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class NoResults extends StatelessWidget {
  const NoResults({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 35, right: 30, left: 30),
        child: Column(
          children: [
            TextFont(
              maxLines: 4,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              text: "No transactions for this budget.",
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 50),
            Lottie.asset('assets/animations/search-animation.json'),
          ],
        ),
      ),
    );
  }
}
