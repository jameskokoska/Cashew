import 'package:flutter/material.dart';

class Transaction {
  final String title;
  final DateTime date;
  final double amount;
  final String categoryID;
  final String note;
  final List<String> tagIDs;
  Transaction(
      {required this.title,
      required this.date,
      required this.amount,
      required this.categoryID,
      required this.note,
      required this.tagIDs});
}
