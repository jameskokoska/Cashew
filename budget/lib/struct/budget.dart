import 'package:flutter/material.dart';

class Budget {
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final String period; //one of [month,week,year,days]
  final int periodLength;
  final Color color;
  final double total;
  final double spent;

  Budget(
      {required this.title,
      required this.startDate,
      required this.endDate,
      required this.period,
      required this.periodLength,
      required this.color,
      required this.total,
      required this.spent});

  double getPercent() {
    return spent / total * 100;
  }
}
