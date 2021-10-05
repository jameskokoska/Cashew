import 'package:budget/struct/transactionTag.dart';
import 'package:budget/struct/transactionCategory.dart';
import 'package:flutter/material.dart';

List<TransactionTag> defaultTags() {
  return [
    TransactionTag(title: "Food", id: "groceriesTag", categoryID: "groceries"),
    TransactionTag(
        title: "Store", id: "groceries2Tag", categoryID: "groceries"),
    TransactionTag(title: "Soccer", id: "sportsTag", categoryID: "sports"),
  ];
}
