import 'package:budget/functions.dart';
import 'package:budget/main.dart';
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
    this.customSubtitleWidget,
    this.hasPadding = true,
    this.underTitleSpace = true,
    this.aboveTitleSpace = true,
    this.showCloseButton = false,
    this.hasBottomSafeArea = true,
    this.icon,
    this.outsideExtraWidget,
  }) : super(key: key);
  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? customSubtitleWidget;
  final bool hasPadding;
  final bool underTitleSpace;
  final bool aboveTitleSpace;
  final bool showCloseButton;
  final bool hasBottomSafeArea;
  final Widget? icon;
  final Widget? outsideExtraWidget;
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
              if (title != null) SizedBox(height: 17),
              getPlatform() == PlatformOS.isIOS
                  ? Stack(
                      alignment: Alignment.topLeft,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (title != null)
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 18),
                                child: TextFont(
                                  text: title ?? "",
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                  maxLines: 5,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            if (subtitle != null ||
                                customSubtitleWidget != null)
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 18),
                                child: customSubtitleWidget ??
                                    TextFont(
                                      text: subtitle ?? "",
                                      fontSize: 14,
                                      maxLines: 5,
                                      textAlign: TextAlign.center,
                                    ),
                              ),
                            if (title != null || subtitle != null)
                              Container(
                                height: 1.5,
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                                margin: EdgeInsets.only(top: 10, bottom: 5),
                              )
                            else
                              SizedBox(height: 5),
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
                                if (title != null)
                                  TextFont(
                                    text: title ?? "",
                                    fontSize: title!.length > 16 ? 23 : 29,
                                    fontWeight: FontWeight.bold,
                                    maxLines: 5,
                                  ),
                                if (subtitle != null ||
                                    customSubtitleWidget != null)
                                  Padding(
                                    padding:
                                        EdgeInsets.only(left: 2, bottom: 4),
                                    child: customSubtitleWidget ??
                                        TextFont(
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
              if (title != null || underTitleSpace == true)
                SizedBox(height: 13),
              Padding(
                padding: hasPadding
                    ? EdgeInsets.only(left: 18, right: 18)
                    : EdgeInsets.zero,
                child: child,
              ),
              hasBottomSafeArea
                  ? Builder(builder: (context) {
                      // At least (initialBottomPadding) bottom padding

                      double initialBottomPadding = 10;
                      double bottomSafeAreaPadding =
                          MediaQuery.paddingOf(context).bottom;

                      bottomSafeAreaPadding =
                          bottomSafeAreaPadding - initialBottomPadding;

                      if (bottomSafeAreaPadding < initialBottomPadding) {
                        bottomSafeAreaPadding = initialBottomPadding;
                      }

                      // print(MediaQuery.paddingOf(context).bottom);
                      // print(bottomSafeAreaPadding);
                      return SizedBox(height: bottomSafeAreaPadding);
                    })
                  : SizedBox.shrink()
            ],
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (outsideExtraWidget != null)
                Transform.translate(
                  offset: Offset(
                      (getIsFullScreen(context) || showCloseButton) ? 20 : 0,
                      0),
                  child: outsideExtraWidget!,
                ),
              if (getIsFullScreen(context) || showCloseButton)
                IconButton(
                  iconSize: 25,
                  padding: EdgeInsets.all(
                      getPlatform() == PlatformOS.isIOS ? 15 : 20),
                  icon: Icon(
                    appStateSettings["outlinedIcons"]
                        ? Icons.close_outlined
                        : Icons.close_rounded,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}
