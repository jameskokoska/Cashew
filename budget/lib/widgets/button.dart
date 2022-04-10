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

  void _shrink() {
    setState(() {
      isTapped = true;
    });
    Future.delayed(Duration(milliseconds: 200), () {
      setState(() {
        isTapped = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      scale: isTapped ? 0.9 : 1,
      child: Tappable(
        color: Theme.of(context).colorScheme.accentColor.withOpacity(0.8),
        onHighlightChanged: (value) {
          setState(() {
            isTapped = value;
          });
        },
        onTap: () {
          _shrink();
          widget.onTap();
        },
        borderRadius: 10,
        child: Container(
          width: widget.width,
          height: widget.height,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color ??
                    Theme.of(context).colorScheme.accentColor.withOpacity(0.5),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: TextFont(
              text: widget.label,
              fontSize: widget.fontSize,
            ),
          ),
        ),
      ),
    );
  }
}
