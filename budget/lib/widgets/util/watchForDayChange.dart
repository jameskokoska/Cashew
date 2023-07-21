import 'package:budget/main.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:flutter/material.dart';

class WatchForDayChange extends StatefulWidget {
  final Widget child;
  const WatchForDayChange({required this.child, super.key});

  @override
  _WatchForDayChangeState createState() => _WatchForDayChangeState();
}

class _WatchForDayChangeState extends State<WatchForDayChange> {
  late DateTime _currentDate;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(Duration(seconds: 1), () {
      if (DateTime.now().day != _currentDate.day) {
        setState(() {
          _currentDate = DateTime.now();
        });
        appStateKey.currentState?.refreshAppState();
        homePageStateKey.currentState?.refreshState();
        transactionsListPageStateKey.currentState?.refreshState();
        budgetsListPageStateKey.currentState?.refreshState();
        settingsPageStateKey.currentState?.refreshState();
      }
      _startTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
