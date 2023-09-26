import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';

class ListItem extends StatelessWidget {
  ListItem(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFont(
            text: "• ",
            maxLines: 1,
            fontSize: 15.5,
          ),
          Expanded(
            child: TextFont(
              text: text,
              maxLines: 50,
              fontSize: 15.5,
            ),
          ),
        ],
      ),
    );
  }
}
