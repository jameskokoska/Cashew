import 'package:budget/functions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/defaultCategories.dart';

//Initialize default values in database
Future<bool> initializeDefaultDatabase() async {
  //Initialize default categories
  if ((await database.getAllCategories()).length <= 0) {
    for (TransactionCategory category in defaultCategories()) {
      await database.createOrUpdateCategory(category,
          customDateTimeModified: DateTime(0));
    }
  }
  if ((await database.getAllWallets()).length <= 0) {
    await database.createOrUpdateWallet(
      TransactionWallet(
        walletPk: 0,
        name: "default-wallet-name".tr(),
        dateCreated: DateTime.now(),
        order: 0,
        currency: getDevicesDefaultCurrencyCode(),
        dateTimeModified: null,
        decimals: 2,
      ),
      customDateTimeModified: DateTime(0),
    );
  }
  return true;
}
