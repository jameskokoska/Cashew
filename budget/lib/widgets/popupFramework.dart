import 'package:flutter/material.dart';
import 'package:budget/widgets/textWidgets.dart';
import '../colors.dart';

class PopupFramework extends StatelessWidget {
  PopupFramework({
    Key? key,
    required this.child,
    this.title,
    this.padding = true,
  }) : super(key: key);
  final Widget child;
  final String? title;
  final bool padding;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            color: Theme.of(context).colorScheme.lightDarkAccent,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 15),
              title == null
                  ? Container()
                  : Padding(
                      padding: EdgeInsets.only(left: 18, right: 18, top: 5),
                      child: TextFont(
                        text: title ?? "",
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        maxLines: 5,
                      ),
                    ),
              title == null ? Container() : Container(height: 10),
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
