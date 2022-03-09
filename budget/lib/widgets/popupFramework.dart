import 'package:flutter/material.dart';
import 'package:budget/widgets/textWidgets.dart';
import '../colors.dart';

class PopupFramework extends StatelessWidget {
  PopupFramework({Key? key, required this.child, this.title}) : super(key: key);
  final Widget child;
  final String? title;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color:
                Theme.of(context).colorScheme.lightDarkAccent.withOpacity(0.5),
          ),
        ),
        Container(height: 5),
        GestureDetector(
          onTap: () {},
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              color: Theme.of(context).colorScheme.lightDarkAccent,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 15),
                  title == null
                      ? Container()
                      : TextFont(
                          text: title ?? "",
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                  title == null ? Container() : Container(height: 10),
                  child,
                  Container(height: 10),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
