import './transactionCategory.dart';
import 'package:flutter/material.dart';

List<TransactionCategory> defaultCategories() {
  return [
    TransactionCategory(
        title: "Food", icon: "cutlery.png", id: "id", color: Colors.blueGrey),
    TransactionCategory(
        title: "Groceries",
        icon: "groceries.png",
        id: "id",
        color: Colors.green),
    TransactionCategory(
        title: "Shopping", icon: "shopping.png", id: "id", color: Colors.pink),
    TransactionCategory(
        title: "Transit", icon: "tram.png", id: "id", color: Colors.yellow),
    TransactionCategory(
        title: "Entertainment",
        icon: "popcorn.png",
        id: "id",
        color: Colors.blue),
    TransactionCategory(
        title: "Bills & Fees",
        icon: "bills.png",
        id: "id",
        color: Colors.green),
    TransactionCategory(
        title: "Education",
        icon: "graduation.png",
        id: "id",
        color: Colors.blue),
    TransactionCategory(
        title: "Gifts", icon: "gift.png", id: "id", color: Colors.red),
    TransactionCategory(
        title: "Sports", icon: "sports.png", id: "id", color: Colors.cyan),
    TransactionCategory(
        title: "Beauty", icon: "flower.png", id: "id", color: Colors.purple),
    TransactionCategory(
        title: "Work", icon: "briefcase.png", id: "id", color: Colors.brown),
    TransactionCategory(
        title: "Travel", icon: "plane.png", id: "id", color: Colors.orange),
  ];
}
