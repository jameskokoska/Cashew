import 'package:flutter/material.dart';

class NavBar extends StatefulWidget {
  NavBar({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  //Can access title by using widget.title
  //Call this widget in main like so: NavBar(title:"test")
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
