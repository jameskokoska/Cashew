import 'package:flutter/material.dart';

class BudgetContainer extends StatefulWidget {
  BudgetContainer({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _BudgetContainerState createState() => _BudgetContainerState();
}

class _BudgetContainerState extends State<BudgetContainer> {
  //Can access title by using widget.title
  //Call this widget in main like so: BudgetContainer(title:"test")
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
