import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';

class Button extends StatefulWidget {
  Button(
      {Key? key,
      required this.label,
      required this.width,
      required this.height,
      this.fontSize = 16,
      this.fractionScaleHeight = 0.93,
      this.fractionScaleWidth = 0.93,
      required this.onTap})
      : super(key: key);
  final String label;
  final double width;
  final double height;
  final double fontSize;
  final double fractionScaleHeight;
  final double fractionScaleWidth;
  final VoidCallback onTap;

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
    return Container(
      height: widget.height,
      width: widget.width,
      child: Scaffold(
        body: Center(
          child: Material(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: Theme.of(context).colorScheme.accentColor.withOpacity(0.8),
            child: InkWell(
              onHighlightChanged: (value) {
                setState(() {
                  isTapped = value;
                });
              },
              onTap: () {
                _shrink();
                widget.onTap();
              },
              borderRadius: BorderRadius.all(Radius.circular(10)),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                height: isTapped
                    ? widget.height * widget.fractionScaleHeight
                    : widget.height,
                width: isTapped
                    ? widget.width * widget.fractionScaleWidth
                    : widget.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .accentColor
                          .withOpacity(0.5),
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
          ),
        ),
      ),
    );
  }
}
