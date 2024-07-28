import 'package:budget/functions.dart';
import 'package:flutter/material.dart';

class FullPageDoubleColumnLayout extends StatelessWidget {
  const FullPageDoubleColumnLayout(
      {required this.heightOfBanner,
      required this.sliverAppBar,
      required this.leftWidget,
      required this.rightWidget,
      super.key});
  final double heightOfBanner;
  final Widget sliverAppBar;
  final Widget leftWidget;
  final Widget rightWidget;

  @override
  Widget build(BuildContext context) {
    double topPaddingOfBanner = MediaQuery.viewPaddingOf(context).top;
    double totalHeaderHeight = heightOfBanner + topPaddingOfBanner;
    return Stack(
      alignment: AlignmentDirectional.topCenter,
      children: [
        Container(
          height: totalHeaderHeight,
          decoration:
              BoxDecoration(boxShadow: boxShadowCheck(boxShadowSharp(context))),
          child: CustomScrollView(
            slivers: [sliverAppBar],
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.only(top: totalHeaderHeight),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 1600),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 700),
                          child: leftWidget,
                        ),
                      ),
                      Flexible(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 700),
                          child: rightWidget,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
