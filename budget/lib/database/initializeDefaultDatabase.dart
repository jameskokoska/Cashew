import 'package:budget/functions.dart';
import 'package:budget/struct/settings.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/defaultCategories.dart';

//Initialize default values in database
Future<bool> initializeDefaultDatabase() async {
  //Initialize default categories, but not after a backup load
  if (isDatabaseImportedOnThisSession != true &&
      (await database.getAllCategories()).length <= 0) {
    await createDefaultCategories();
  }

  if ((await database.getAllWallets()).length <= 0) {
    await database.createOrUpdateWallet(
      defaultWallet(),
      customDateTimeModified: DateTime(0),
    );
  }

  // Initialize default tags
  if ((await database.getAllTags()).length <= 0) {
    await createDefaultTags();
  }

  return true;
}

Future<bool> createDefaultCategories() async {
  print("Creating default categories");
  for (TransactionCategory category in defaultCategories()) {
    try {
      await database.getCategory(category.categoryPk).$2;
    } catch (e) {
      print(
          e.toString() + " default category does not already exist, creating");
      await database.createOrUpdateCategory(category,
          customDateTimeModified: DateTime(0));
    }
  }
  return true;
}

Future<bool> createDefaultTags() async {
  print("Creating default tags");
  List<Tag> defaultTags = [
    Tag(tagPk: "tag_groceries", name: "Groceries", iconName: "shopping_cart", color: "0xFF4CAF50", dateCreated: DateTime.now()),
    Tag(tagPk: "tag_travel", name: "Travel", iconName: "flight", color: "0xFF2196F3", dateCreated: DateTime.now()),
    Tag(tagPk: "tag_bills", name: "Bills", iconName: "receipt", color: "0xFFF44336", dateCreated: DateTime.now()),
    Tag(tagPk: "tag_entertainment", name: "Entertainment", iconName: "movie", color: "0xFF9C27B0", dateCreated: DateTime.now()),
    Tag(tagPk: "tag_dining", name: "Dining", iconName: "restaurant", color: "0xFFFF9800", dateCreated: DateTime.now()),
    Tag(tagPk: "tag_health", name: "Health", iconName: "local_hospital", color: "0xFFE91E63", dateCreated: DateTime.now()),
  ];

  for (Tag tag in defaultTags) {
    try {
      await database.createOrUpdateTag(tag);
    } catch (e) {
      print("Error creating default tag: " + e.toString());
    }
  }
  return true;
}

TransactionWallet defaultWallet() {
  return TransactionWallet(
    walletPk: "0",
    name: "default-account-name".tr(),
    dateCreated: DateTime.now(),
    order: 0,
    currency: getDevicesDefaultCurrencyCode(),
    dateTimeModified: null,
    decimals: 2,
    homePageWidgetDisplay: defaultWalletHomePageWidgetDisplay,
  );
}
