import 'package:budget/functions.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:flutter/material.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/colors.dart';

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
    this.bottomSafeAreaExtraPadding = true,
    this.showCloseButton = false,
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
  final bool bottomSafeAreaExtraPadding;
  final bool showCloseButton;
  final Widget? icon;
  final Widget? outsideExtraWidget;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: getPopupBackgroundColor(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) SizedBox(height: 14),
              getPlatform() == PlatformOS.isIOS
                  ? Stack(
                      alignment: AlignmentDirectional.topStart,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (title != null)
                              Padding(
                                padding: EdgeInsetsDirectional.symmetric(
                                    horizontal: 18),
                                child: TextFont(
                                  text: (title ?? "").capitalizeFirstofEach,
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                  maxLines: 5,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            if (subtitle != null ||
                                customSubtitleWidget != null)
                              Padding(
                                padding: EdgeInsetsDirectional.symmetric(
                                    horizontal: 18),
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
                                color: appStateSettings["materialYou"] == true
                                    ? Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer
                                    : getColor(context, "canvasContainer"),
                                margin: EdgeInsetsDirectional.only(
                                    top: 10, bottom: 5),
                              )
                            else
                              SizedBox(height: 5),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.only(
                            start: 10,
                          ),
                          child: icon ?? SizedBox.shrink(),
                        )
                      ],
                    )
                  : Padding(
                      padding: EdgeInsetsDirectional.only(
                          start: 18, end: 18, top: 5),
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
                                    text: (title ?? "").capitalizeFirstofEach,
                                    fontSize: title!.length > 16 ? 23 : 29,
                                    fontWeight: FontWeight.bold,
                                    maxLines: 5,
                                  ),
                                if (subtitle != null ||
                                    customSubtitleWidget != null)
                                  Padding(
                                    padding: EdgeInsetsDirectional.only(
                                        start: 2, bottom: 4),
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
                    ? EdgeInsetsDirectional.symmetric(horizontal: 18)
                    : EdgeInsetsDirectional.zero,
                child: child,
              ),
              if (bottomSafeAreaExtraPadding == true)
                // Bottom safe area extra padding
                Builder(
                  builder: (context) {
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
                    return SizedBox(
                      height: bottomSafeAreaPadding,
                    );
                  },
                ),
              SizedBox(height: 8),
            ],
          ),
        ),
        Align(
          alignment: AlignmentDirectional.topEnd,
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
                  padding: EdgeInsetsDirectional.all(
                      getPlatform() == PlatformOS.isIOS ? 15 : 20),
                  icon: Icon(
                    appStateSettings["outlinedIcons"]
                        ? Icons.close_outlined
                        : Icons.close_rounded,
                  ),
                  onPressed: () {
                    popRoute(context);
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class OutsideExtraWidgetIconButton extends StatelessWidget {
  const OutsideExtraWidgetIconButton({
    required this.iconData,
    this.customIconWidget,
    required this.onPressed,
    super.key,
  });
  final IconData? iconData;
  final Widget? customIconWidget;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: 25,
      padding: EdgeInsetsDirectional.all(
          getPlatform() == PlatformOS.isIOS ? 15 : 20),
      icon: customIconWidget ?? Icon(iconData),
      onPressed: onPressed,
    );
  }
}
