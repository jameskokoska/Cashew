import 'package:budget/main.dart';
import 'package:flutter/material.dart';
import 'package:budget/widgets/textWidgets.dart';
import '../colors.dart';

class PopupFramework extends StatelessWidget {
  PopupFramework({
    Key? key,
    required this.child,
    this.title,
    this.subtitle,
    this.padding = true,
  }) : super(key: key);
  final Widget child;
  final String? title;
  final String? subtitle;
  final bool padding;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            color: appStateSettings["materialYou"]
                ? Theme.of(context)
                    .colorScheme
                    .secondaryContainer
                    .withOpacity(0.7)
                : Theme.of(context).colorScheme.lightDarkAccent,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 17),
              title == null
                  ? SizedBox.shrink()
                  : Padding(
                      padding: EdgeInsets.only(left: 18, right: 18, top: 5),
                      child: TextFont(
                        text: title ?? "",
                        fontSize: title!.length > 16 ? 24 : 32,
                        fontWeight: FontWeight.bold,
                        maxLines: 5,
                      ),
                    ),
              subtitle == null
                  ? SizedBox.shrink()
                  : Padding(
                      padding: EdgeInsets.only(left: 18, right: 18, bottom: 4),
                      child: TextFont(
                        text: subtitle ?? "",
                        fontSize: 17,
                        maxLines: 5,
                      ),
                    ),
              title == null ? Container() : Container(height: 13),
              Padding(
                padding: padding
                    ? EdgeInsets.only(left: 18, right: 18, bottom: 10)
                    : EdgeInsets.zero,
                child: child,
              ),
              Container(height: 10),
            ],
          ),
        ),
      ],
    );
  }
}
