import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class NoResults extends StatelessWidget {
  const NoResults({Key? key, required this.message}) : super(key: key);
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 35, right: 30, left: 30),
        child: Column(
          children: [
            SizedBox(height: 30),
            Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.height <=
                          MediaQuery.of(context).size.width
                      ? MediaQuery.of(context).size.height * 0.4
                      : 250),
              child: Image(
                image: AssetImage("assets/images/empty.png"),
              ),
            ),
            SizedBox(height: 30),
            TextFont(
              maxLines: 4,
              fontSize: 16,
              text: message,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 80),
            // Lottie.asset('assets/animations/search-animation.json'),
          ],
        ),
      ),
    );
  }
}
