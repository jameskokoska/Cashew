import 'dart:async';

import 'package:budget/functions.dart';
import 'package:budget/main.dart';
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
    this.color,
    this.textColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    this.hasBottomExtraSafeArea = false,
    this.icon,
    this.iconColor,
    this.borderRadius = 20,
    this.changeScale = true,
    this.expandedLayout = false,
  }) : super(key: key);
  final String label;
  final double? width;
  // final double? height;
  final double fontSize;
  final VoidCallback onTap;
  final Color? color;
  final Color? textColor;
  final EdgeInsets padding;
  final bool hasBottomExtraSafeArea;
  final IconData? icon;
  final Color? iconColor;
  final double borderRadius;
  final bool changeScale;
  final bool expandedLayout;

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
          Theme.of(context).colorScheme.onSecondaryContainer,
      maxLines: 5,
      textAlign: TextAlign.center,
    );
    return Padding(
      padding: EdgeInsets.only(
          bottom: widget.hasBottomExtraSafeArea == true
              ? bottomPaddingSafeArea
              : 0),
      child: AnimatedScale(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        scale: widget.changeScale ? (isTapped ? 0.95 : 1) : 1,
        child: Tappable(
          color: widget.color != null
              ? widget.color!.withOpacity(0.8)
              : appStateSettings["materialYou"]
                  ? dynamicPastel(
                      context, Theme.of(context).colorScheme.primary,
                      amount: 0.3)
                  : Theme.of(context).colorScheme.secondaryContainer,
          onHighlightChanged: (value) {
            setState(() {
              isTapped = value;
            });
          },
          onTap: () {
            _shrink();
            widget.onTap();
          },
          borderRadius: widget.borderRadius,
          child: Container(
            width: widget.width,
            // height: widget.height,
            padding: widget.padding,
            child: Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  widget.icon != null
                      ? Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Icon(
                            widget.icon,
                            size: 21,
                            color: widget.iconColor == null
                                ? Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer
                                : widget.iconColor,
                          ),
                        )
                      : SizedBox.shrink(),
                  widget.expandedLayout ? Expanded(child: text) : text,
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
  }) : super(key: key);
  final VoidCallback onTap;
  final IconData icon;
  final double size;
  final Color? color;
  final Color? iconColor;
  final EdgeInsets? padding;
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
          size: size - 20,
        ),
      ),
      color: color == null
          ? Theme.of(context).colorScheme.secondaryContainer
          : color,
      borderRadius: 15,
      onTap: onTap,
    );
  }
}
