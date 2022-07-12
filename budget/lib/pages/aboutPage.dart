import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return PageFramework(
      dragDownToDismiss: true,
      title: "About",
      navbar: true,
      appBarBackgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      appBarBackgroundColorStart: Theme.of(context).canvasColor,
      listWidgets: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 7),
          child: Tappable(
            onTap: () {},
            color: Theme.of(context).colorScheme.lightDarkAccent,
            borderRadius: 15,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
              child: Column(
                children: [
                  TextFont(
                    text: "Lead Developer",
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  TextFont(
                    text: "James",
                    fontSize: 33,
                    fontWeight: FontWeight.bold,
                  ),
                  TextFont(
                    text: "dapperappdeveloper@gmail.com",
                    fontSize: 17,
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 7),
          child: Tappable(
            onTap: () {},
            color: Theme.of(context).colorScheme.lightDarkAccent,
            borderRadius: 15,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
              child: Column(
                children: [
                  TextFont(
                    text: "Database Designer",
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  TextFont(
                    text: "YuYing",
                    fontSize: 33,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}

class ColorBox extends StatelessWidget {
  const ColorBox({Key? key, required this.color, required this.name})
      : super(key: key);

  final Color color;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Container(width: 20),
          Container(width: 50, height: 50, color: color),
          Container(width: 20),
          TextFont(text: name)
        ],
      ),
    );
  }
}
