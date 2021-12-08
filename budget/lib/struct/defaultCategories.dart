import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/struct/transactionCategory.dart';
import 'package:flutter/material.dart';

List<TransactionCategoryOld> defaultCategoriesOld() {
  return [
    TransactionCategoryOld(
        title: "Food", icon: "cutlery.png", id: "food", color: Colors.blueGrey),
    TransactionCategoryOld(
        title: "Groceries",
        icon: "groceries.png",
        id: "groceries",
        color: Colors.green),
    TransactionCategoryOld(
        title: "Shopping",
        icon: "shopping.png",
        id: "shopping",
        color: Colors.pink),
    TransactionCategoryOld(
        title: "Transit", icon: "tram.png", id: "id", color: Colors.yellow),
    TransactionCategoryOld(
        title: "Entertainment",
        icon: "popcorn.png",
        id: "entertainment",
        color: Colors.blue),
    TransactionCategoryOld(
        title: "Bills & Fees",
        icon: "bills.png",
        id: "bills & fees",
        color: Colors.green),
    TransactionCategoryOld(
        title: "Education",
        icon: "graduation.png",
        id: "education",
        color: Colors.blue),
    TransactionCategoryOld(
        title: "Gifts", icon: "gift.png", id: "gifts", color: Colors.red),
    TransactionCategoryOld(
        title: "Sports", icon: "sports.png", id: "sports", color: Colors.cyan),
    TransactionCategoryOld(
        title: "Beauty",
        icon: "flower.png",
        id: "beauty",
        color: Colors.purple),
    TransactionCategoryOld(
        title: "Work", icon: "briefcase.png", id: "work", color: Colors.brown),
    TransactionCategoryOld(
        title: "Travel", icon: "plane.png", id: "travel", color: Colors.orange),
  ];
}

List<TransactionCategory> defaultCategories() {
  toHexString(Colors.green);
  return [
    TransactionCategory(
      categoryPk: 1,
      name: "Food",
      colour: toHexString(Colors.blueGrey),
      iconName: "cutlery.png",
      dateCreated: DateTime.now(),
    ),
    TransactionCategory(
      categoryPk: 2,
      name: "Groceries",
      colour: toHexString(Colors.green),
      iconName: "groceries.png",
      dateCreated: DateTime.now(),
    ),
    TransactionCategory(
      categoryPk: 3,
      name: "Shopping",
      colour: toHexString(Colors.pink),
      iconName: "shopping.png",
      dateCreated: DateTime.now(),
    ),
    TransactionCategory(
      categoryPk: 4,
      name: "Transit",
      colour: toHexString(Colors.yellow),
      iconName: "tram.png",
      dateCreated: DateTime.now(),
    ),
    TransactionCategory(
      categoryPk: 5,
      name: "Entertainment",
      colour: toHexString(Colors.blue),
      iconName: "popcorn.png",
      dateCreated: DateTime.now(),
    ),
    TransactionCategory(
      categoryPk: 6,
      name: "Bills & Fees",
      colour: toHexString(Colors.green),
      iconName: "bills.png",
      dateCreated: DateTime.now(),
    ),
    TransactionCategory(
      categoryPk: 7,
      name: "Education",
      colour: toHexString(Colors.blue),
      iconName: "graduation.png",
      dateCreated: DateTime.now(),
    ),
    TransactionCategory(
      categoryPk: 8,
      name: "Gifts",
      colour: toHexString(Colors.red),
      iconName: "gift.png",
      dateCreated: DateTime.now(),
    ),
    TransactionCategory(
      categoryPk: 9,
      name: "Sports",
      colour: toHexString(Colors.cyan),
      iconName: "sports.png",
      dateCreated: DateTime.now(),
    ),
    TransactionCategory(
      categoryPk: 10,
      name: "Beauty",
      colour: toHexString(Colors.purple),
      iconName: "flower.png",
      dateCreated: DateTime.now(),
    ),
    TransactionCategory(
      categoryPk: 11,
      name: "Work",
      colour: toHexString(Colors.brown),
      iconName: "briefcase.png",
      dateCreated: DateTime.now(),
    ),
    TransactionCategory(
      categoryPk: 12,
      name: "Travel",
      colour: toHexString(Colors.orange),
      iconName: "plane.png",
      dateCreated: DateTime.now(),
    ),
  ];
}
