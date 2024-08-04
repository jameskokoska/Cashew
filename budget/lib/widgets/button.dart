import 'dart:async';
import 'package:budget/functions.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/struct/defaultPreferences.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';

class Button extends StatefulWidget {
  Button({
    Key? key,
    required this.label,
    this.width,
    // this.height,
    this.fontSize = 15,
    required this.onTap,
    this.onLongPress,
    this.color,
    this.textColor,
    this.padding =
        const EdgeInsetsDirectional.symmetric(horizontal: 20, vertical: 15),
    this.hasBottomExtraSafeArea = false,
    this.expandToFillBottomExtraSafeArea = false,
    this.icon,
    this.iconColor,
    this.borderRadius,
    this.changeScale = true,
    this.expandedLayout = false,
    this.flexibleLayout = false,
    this.disabled = false,
    this.onDisabled,
  }) : super(key: key);
  final String label;
  final double? width;
  // final double? height;
  final double fontSize;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Color? color;
  final Color? textColor;
  final EdgeInsetsDirectional padding;
  final bool hasBottomExtraSafeArea;
  final bool expandToFillBottomExtraSafeArea;
  final IconData? icon;
  final Color? iconColor;
  final double? borderRadius;
  final bool changeScale;
  final bool expandedLayout;
  final bool flexibleLayout;
  final bool disabled;
  final VoidCallback? onDisabled;

  @override
  _ButtonState createState() => _ButtonState();
}

class _ButtonState extends State<Button> with TickerProviderStateMixin {
  bool isTapped = false;
  Timer? timer;
  void _shrink() {
    setState(() {
      isTapped = true;
    });
    timer = Timer(Duration(milliseconds: 200), () {
      setState(() {
        isTapped = false;
      });
    });
  }

  @override
  void dispose() {
    if (timer != null) timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget text = TextFont(
      text: widget.label,
      fontSize: widget.fontSize,
      textColor: widget.textColor ??
          (appStateSettings["materialYou"]
              ? dynamicPastel(context, Theme.of(context).colorScheme.onPrimary,
                  amount: 0.2)
              : Theme.of(context).colorScheme.onSecondaryContainer),
      maxLines: 5,
      textAlign: widget.icon != null ? TextAlign.start : TextAlign.center,
    );
    return Padding(
      padding: EdgeInsetsDirectional.only(
          bottom: widget.hasBottomExtraSafeArea == true &&
                  widget.expandToFillBottomExtraSafeArea == false
              ? MediaQuery.viewPaddingOf(context).bottom
              : 0),
      child: AnimatedScale(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        scale: widget.changeScale ? (isTapped ? 0.95 : 1) : 1,
        alignment: widget.expandToFillBottomExtraSafeArea
            ? Alignment.bottomCenter
            : Alignment.center,
        child: Tappable(
          color: widget.disabled
              ? appStateSettings["materialYou"]
                  ? Colors.grey
                  : getColor(context, "lightDarkAccentHeavy")
              : widget.color != null
                  ? widget.color
                  : appStateSettings["materialYou"]
                      ? dynamicPastel(
                          context, Theme.of(context).colorScheme.primary,
                          amount: 0.15)
                      : Theme.of(context).colorScheme.secondaryContainer,
          onHighlightChanged: (value) {
            if (appStateSettings["appAnimations"] == AppAnimations.all.index)
              setState(() {
                isTapped = value;
              });
          },
          onTap: () {
            if (appStateSettings["appAnimations"] == AppAnimations.all.index)
              _shrink();
            if (widget.disabled == false) widget.onTap();
            if (widget.disabled == true && widget.onDisabled != null)
              widget.onDisabled!();
          },
          onLongPress: widget.onLongPress,
          borderRadius:
              getPlatform() == PlatformOS.isIOS && widget.borderRadius == null
                  ? 10
                  : widget.borderRadius ?? 20,
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              bottom: widget.expandToFillBottomExtraSafeArea
                  ? MediaQuery.viewPaddingOf(context).bottom
                  : 0,
            ),
            child: Container(
              width: widget.width,
              // height: widget.height,
              padding: widget.padding,
              child: Center(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 8),
                        child: Icon(
                          widget.icon,
                          size: 21,
                          color: widget.iconColor == null
                              ? Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer
                              : widget.iconColor,
                        ),
                      ),
                    widget.flexibleLayout
                        ? Flexible(child: text)
                        : widget.expandedLayout
                            ? Expanded(child: text)
                            : text,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TappableOpacityButtonBreak extends StatelessWidget {
  const TappableOpacityButtonBreak({this.color, super.key});
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return HorizontalBreak(
      padding: EdgeInsetsDirectional.zero,
      color: color ??
          (appStateSettings["materialYou"]
              ? Theme.of(context).colorScheme.secondary.withOpacity(0.5)
              : getColor(context, "lightDarkAccentHeavy")),
    );
  }
}

class TappableOpacityButton extends StatelessWidget {
  const TappableOpacityButton({
    required this.label,
    this.width,
    this.fontSize = 15,
    required this.onTap,
    this.color,
    this.textColor,
    required this.expandedLayout,
    super.key,
  });

  final String label;
  final double? width;
  final double fontSize;
  final VoidCallback onTap;
  final Color? color;
  final Color? textColor;
  final bool expandedLayout;

  @override
  Widget build(BuildContext context) {
    Widget child = Tappable(
      color: color,
      onTap: onTap,
      child: Padding(
        padding:
            const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 17),
        child: TextFont(
          text: label,
          fontSize: fontSize,
          textColor: textColor ??
              (appStateSettings["materialYou"]
                  ? dynamicPastel(
                      context, Theme.of(context).colorScheme.onPrimary,
                      amount: 0.3)
                  : Theme.of(context).colorScheme.onSecondaryContainer),
          maxLines: 5,
          textAlign: TextAlign.center,
        ),
      ),
    );
    if (expandedLayout)
      return Row(
        children: [
          Expanded(
            child: child,
          ),
        ],
      );
    return child;
  }
}

class ButtonIcon extends StatelessWidget {
  const ButtonIcon({
    Key? key,
    required this.onTap,
    required this.icon,
    this.size = 44,
    this.color,
    this.iconColor,
    this.padding,
    this.iconPadding = 20,
  }) : super(key: key);
  final VoidCallback onTap;
  final IconData icon;
  final double size;
  final Color? color;
  final Color? iconColor;
  final EdgeInsetsDirectional? padding;
  final double iconPadding;
  @override
  Widget build(BuildContext context) {
    return Tappable(
      child: Container(
        height: size,
        width: size,
        margin: padding,
        child: Icon(
          icon,
          color: iconColor == null
              ? Theme.of(context).colorScheme.onSecondaryContainer
              : iconColor,
          size: size - iconPadding,
        ),
      ),
      color: color == null
          ? Theme.of(context).colorScheme.secondaryContainer
          : color,
      borderRadius: getPlatform() == PlatformOS.isIOS ? 10 : 15,
      onTap: onTap,
    );
  }
}

// If using, subtract 8 from the padding of the parent IconButton
class SelectedIconForIconButton extends StatelessWidget {
  const SelectedIconForIconButton(
      {required this.isSelected, required this.iconData, super.key});
  final bool isSelected;
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.tertiary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadiusDirectional.circular(100),
      ),
      padding: EdgeInsetsDirectional.all(8),
      child: Icon(
        iconData,
        color: isSelected ? Theme.of(context).colorScheme.tertiary : null,
      ),
    );
  }
}
