import 'package:budget/colors.dart';
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
                      : 270),
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.primary.withOpacity(0.6),
                  BlendMode.srcATop,
                ),
                child: ColorFiltered(
                  colorFilter: greyScale,
                  child: Opacity(
                    opacity: 1,
                    child: Image(
                      image: AssetImage("assets/images/empty-filter.png"),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            TextFont(
              maxLines: 4,
              fontSize: 15,
              text: message,
              textAlign: TextAlign.center,
              textColor: Theme.of(context).colorScheme.textLight,
            ),
            SizedBox(height: 80),
            // Lottie.asset('assets/animations/search-animation.json'),
          ],
        ),
      ),
    );
  }
}
