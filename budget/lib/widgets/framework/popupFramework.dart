import 'package:budget/functions.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:flutter/material.dart';
import 'package:budget/widgets/textWidgets.dart';
import '../../../colors.dart';

class PopupFramework extends StatelessWidget {
  PopupFramework({
    Key? key,
    required this.child,
    this.title,
    this.subtitle,
    this.padding = true,
    this.underTitleSpace = true,
    this.showCloseButton = false,
    this.hasBottomSafeArea = true,
    this.icon,
  }) : super(key: key);
  final Widget child;
  final String? title;
  final String? subtitle;
  final bool padding;
  final bool underTitleSpace;
  final bool showCloseButton;
  final bool hasBottomSafeArea;
  final Widget? icon;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: appStateSettings["materialYou"]
              ? dynamicPastel(
                  context, Theme.of(context).colorScheme.secondaryContainer,
                  amountDark: 0.3, amountLight: 0.6)
              : getColor(context, "lightDarkAccent"),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 17),
              getPlatform() == PlatformOS.isIOS
                  ? Stack(
                      alignment: Alignment.topLeft,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            title == null
                                ? SizedBox.shrink()
                                : Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 18),
                                    child: TextFont(
                                      text: title ?? "",
                                      fontSize: 23,
                                      fontWeight: FontWeight.bold,
                                      maxLines: 5,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                            subtitle == null
                                ? SizedBox.shrink()
                                : Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 18),
                                    child: TextFont(
                                      text: subtitle ?? "",
                                      fontSize: 14,
                                      maxLines: 5,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                            Container(
                              height: 1.5,
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                              margin: EdgeInsets.only(top: 10, bottom: 5),
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 10,
                          ),
                          child: icon ?? SizedBox.shrink(),
                        )
                      ],
                    )
                  : Padding(
                      padding: EdgeInsets.only(left: 18, right: 18, top: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                title == null
                                    ? SizedBox.shrink()
                                    : TextFont(
                                        text: title ?? "",
                                        fontSize: title!.length > 16 ? 24 : 32,
                                        fontWeight: FontWeight.bold,
                                        maxLines: 5,
                                      ),
                                subtitle == null
                                    ? SizedBox.shrink()
                                    : Padding(
                                        padding:
                                            EdgeInsets.only(left: 2, bottom: 4),
                                        child: TextFont(
                                          text: subtitle ?? "",
                                          fontSize: 15,
                                          maxLines: 5,
                                        ),
                                      ),
                              ],
                            ),
                          ),
                          icon ?? SizedBox.shrink()
                        ],
                      ),
                    ),
              title == null || underTitleSpace == false
                  ? Container()
                  : Container(height: 13),
              Padding(
                padding: padding
                    ? EdgeInsets.only(left: 18, right: 18)
                    : EdgeInsets.zero,
                child: child,
              ),
              hasBottomSafeArea
                  ? Builder(builder: (context) {
                      double initialBottomPadding = 10;
                      double bottomSafeAreaPadding =
                          MediaQuery.of(context).padding.bottom;

                      bottomSafeAreaPadding =
                          bottomSafeAreaPadding - initialBottomPadding;

                      if (bottomSafeAreaPadding < initialBottomPadding) {
                        bottomSafeAreaPadding = initialBottomPadding;
                      }

                      // print(MediaQuery.of(context).padding.bottom);
                      // print(bottomSafeAreaPadding);
                      return SizedBox(height: bottomSafeAreaPadding);
                    })
                  : SizedBox.shrink()
            ],
          ),
        ),
        getIsFullScreen(context) || showCloseButton
            ? Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  iconSize: 25,
                  padding: EdgeInsets.all(20),
                  icon: Icon(Icons.close_rounded),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              )
            : SizedBox(),
      ],
    );
  }
}
