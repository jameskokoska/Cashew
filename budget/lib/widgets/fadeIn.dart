import 'package:flutter/material.dart';

class FadeIn extends StatefulWidget {
  FadeIn({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  _FadeInState createState() => _FadeInState();
}

class _FadeInState extends State<FadeIn> {
  double widgetOpacity = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 10), () {
      setState(() {
        widgetOpacity = 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
        opacity: widgetOpacity,
        duration: Duration(seconds: 1),
        child: widget.child);
  }
}
