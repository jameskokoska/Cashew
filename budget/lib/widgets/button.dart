import 'dart:async';

import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';

class Button extends StatefulWidget {
  Button(
      {Key? key,
      required this.label,
      this.width,
      this.height,
      this.fontSize = 16,
      required this.onTap,
      this.color})
      : super(key: key);
  final String label;
  final double? width;
  final double? height;
  final double fontSize;
  final VoidCallback onTap;
  final Color? color;

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
    super.dispose();
    if (timer != null) timer!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      scale: isTapped ? 0.95 : 1,
      child: Tappable(
        color: widget.color != null
            ? widget.color!.withOpacity(0.8)
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
        borderRadius: 20,
        child: Container(
          width: widget.width,
          height: widget.height,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Center(
            child: TextFont(
              text: widget.label,
              fontSize: widget.fontSize,
              textColor: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
        ),
      ),
    );
  }
}

class ButtonIcon extends StatelessWidget {
  const ButtonIcon({Key? key, required this.onTap, required this.icon})
      : super(key: key);
  final VoidCallback onTap;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return Tappable(
      child: Container(
        height: 44,
        width: 44,
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
      ),
      color: Theme.of(context).colorScheme.secondaryContainer,
      borderRadius: 15,
      onTap: onTap,
    );
  }
}
