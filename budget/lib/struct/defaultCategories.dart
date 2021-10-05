import 'package:budget/struct/transactionCategory.dart';
import 'package:flutter/material.dart';

List<TransactionCategory> defaultCategories() {
  return [
    TransactionCategory(
        title: "Food", icon: "cutlery.png", id: "food", color: Colors.blueGrey),
    TransactionCategory(
        title: "Groceries",
        icon: "groceries.png",
        id: "groceries",
        color: Colors.green),
    TransactionCategory(
        title: "Shopping",
        icon: "shopping.png",
        id: "shopping",
        color: Colors.pink),
    TransactionCategory(
        title: "Transit", icon: "tram.png", id: "id", color: Colors.yellow),
    TransactionCategory(
        title: "Entertainment",
        icon: "popcorn.png",
        id: "entertainment",
        color: Colors.blue),
    TransactionCategory(
        title: "Bills & Fees",
        icon: "bills.png",
        id: "bills & fees",
        color: Colors.green),
    TransactionCategory(
        title: "Education",
        icon: "graduation.png",
        id: "education",
        color: Colors.blue),
    TransactionCategory(
        title: "Gifts", icon: "gift.png", id: "gifts", color: Colors.red),
    TransactionCategory(
        title: "Sports", icon: "sports.png", id: "sports", color: Colors.cyan),
    TransactionCategory(
        title: "Beauty",
        icon: "flower.png",
        id: "beauty",
        color: Colors.purple),
    TransactionCategory(
        title: "Work", icon: "briefcase.png", id: "work", color: Colors.brown),
    TransactionCategory(
        title: "Travel", icon: "plane.png", id: "travel", color: Colors.orange),
  ];
}
