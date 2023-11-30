import 'dart:developer';

import 'package:budget/functions.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/homePage/homePageLineGraph.dart';
import 'package:budget/pages/transactionFilters.dart';
import 'package:budget/pages/transactionsSearchPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/firebaseAuthGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/struct/shareBudget.dart';
import 'package:budget/struct/syncClient.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/periodCyclePicker.dart';
import 'package:budget/widgets/walletEntry.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:async/async.dart';
import 'package:drift/drift.dart';
export 'platform/shared.dart';
import 'dart:convert';
import 'package:budget/struct/currencyFunctions.dart';
import 'schema_versions.dart';
import 'package:flutter/material.dart' show DateTimeRange;

import 'package:flutter/material.dart' show RangeValues;
part 'tables.g.dart';

int schemaVersionGlobal = 45;

// To update and migrate the database, check the README

// Character Limits
const int NAME_LIMIT = 250;
const int NOTE_LIMIT = 500;
const int COLOUR_LIMIT = 50;

// Query Constants
const int DEFAULT_LIMIT = 100000;
const int DEFAULT_OFFSET = 0;

enum BudgetReoccurence { custom, daily, weekly, monthly, yearly }

enum TransactionSpecialType {
  upcoming,
  subscription,
  repetitive,
  credit, //lent, withdraw, owed
  debt, //borrowed, deposit, owe
}

enum SharedOwnerMember {
  owner,
  member,
}

enum ExpenseIncome {
  income,
  expense,
}

enum PaidStatus {
  paid,
  notPaid,
  skipped,
}

// You should explain what each one does to the user in ViewBudgetTransactionFilterInfo
// Implement the default and behavior here: onlyShowIfFollowsFilters
// Also add the default to the onboarding page budget creation: OnBoardingPageBodyState
enum BudgetTransactionFilters {
  addedToOtherBudget,
  sharedToOtherBudget,
  includeIncome, //disabled by default (as set by the function below: isFilterSelectedWithDefaults -> offByDefault)
  includeDebtAndCredit, //disabled by default (as set by the function below:isFilterSelectedWithDefaults ->  offByDefault)
  addedToObjective,
  defaultBudgetTransactionFilters, //if default is in the list, use the default behavior
  includeBalanceCorrection, //disabled by default
}

enum HomePageWidgetDisplay {
  WalletSwitcher,
  WalletList,
  NetWorth,
  AllSpending, //Deprecated
}

List<HomePageWidgetDisplay> defaultWalletHomePageWidgetDisplay = [
  HomePageWidgetDisplay.WalletSwitcher,
  HomePageWidgetDisplay.WalletList,
];

bool isFilterSelectedWithDefaults(
    List<BudgetTransactionFilters>? filters, BudgetTransactionFilters filter) {
  if (filters == null) return true;

  List<BudgetTransactionFilters> offByDefault = [
    BudgetTransactionFilters.includeIncome,
    BudgetTransactionFilters.includeDebtAndCredit,
    BudgetTransactionFilters.includeBalanceCorrection,
  ];

  if (filters
      .contains(BudgetTransactionFilters.defaultBudgetTransactionFilters)) {
    if (offByDefault.contains(filter)) {
      return false;
    }
    return true;
  } else {
    return filters.contains(filter);
  }
}

enum ThemeSetting { dark, light }

enum MethodAdded { email, shared, csv, preview }

enum SharedStatus { waiting, shared, error }

class IntListInColumnConverter extends TypeConverter<List<int>, String> {
  const IntListInColumnConverter();
  @override
  List<int> fromSql(String string_from_db) {
    return new List<int>.from(json.decode(string_from_db));
  }

  @override
  String toSql(List<int> ints) {
    return json.encode(ints);
  }
}

class BudgetTransactionFiltersListInColumnConverter
    extends TypeConverter<List<BudgetTransactionFilters>, String> {
  const BudgetTransactionFiltersListInColumnConverter();
  @override
  List<BudgetTransactionFilters> fromSql(String string_from_db) {
    List<int> ints = List<int>.from(json.decode(string_from_db));
    List<BudgetTransactionFilters> filters = ints
        .where((i) => i >= 0 && i < BudgetTransactionFilters.values.length)
        .map((i) => BudgetTransactionFilters.values[i])
        .toList();
    return filters;
  }

  @override
  String toSql(List<BudgetTransactionFilters> filters) {
    List<int> ints = filters.map((filter) => filter.index).toList();
    return json.encode(ints);
  }
}

class HomePageWidgetDisplayListInColumnConverter
    extends TypeConverter<List<HomePageWidgetDisplay>, String> {
  const HomePageWidgetDisplayListInColumnConverter();
  @override
  List<HomePageWidgetDisplay> fromSql(String string_from_db) {
    List<int> ints = List<int>.from(json.decode(string_from_db));
    List<HomePageWidgetDisplay> widgetDisplays = ints
        .where((i) => i >= 0 && i < HomePageWidgetDisplay.values.length)
        .map((i) => HomePageWidgetDisplay.values[i])
        .toList();
    return widgetDisplays;
  }

  @override
  String toSql(List<HomePageWidgetDisplay> filters) {
    List<int> ints = filters.map((filter) => filter.index).toList();
    return json.encode(ints);
  }
}

class StringListInColumnConverter extends TypeConverter<List<String>, String> {
  const StringListInColumnConverter();
  @override
  List<String> fromSql(String string_from_db) {
    List<dynamic> dynamicList = List<dynamic>.from(json.decode(string_from_db));
    List<String> stringList =
        dynamicList.map((dynamic item) => item.toString()).toList();
    return stringList;
  }

  @override
  String toSql(List<String> strings) {
    return json.encode(strings);
  }
}

class DoubleListInColumnConverter extends TypeConverter<List<double>, String> {
  const DoubleListInColumnConverter();
  @override
  List<double> fromSql(String string_from_db) {
    return new List<double>.from(json.decode(string_from_db));
  }

  @override
  String toSql(List<double> doubles) {
    return json.encode(doubles);
  }
}

enum DeleteLogType {
  TransactionWallet,
  TransactionCategory,
  Budget,
  CategoryBudgetLimit,
  Transaction,
  TransactionAssociatedTitle,
  ScannerTemplate,
  Objective,
}

enum UpdateLogType {
  TransactionWallet,
  TransactionCategory,
  Budget,
  CategoryBudgetLimit,
  Transaction,
  TransactionAssociatedTitle,
  ScannerTemplate,
  Objective,
}

@DataClassName('DeleteLog')
class DeleteLogs extends Table {
  TextColumn get deleteLogPk => text().clientDefault(() => uuid.v4())();
  TextColumn get entryPk => text()();
  IntColumn get type => intEnum<DeleteLogType>()();
  DateTimeColumn get dateTimeModified =>
      dateTime().withDefault(Constant(DateTime.now()))();

  @override
  Set<Column> get primaryKey => {deleteLogPk};
}

@DataClassName('TransactionWallet')
class Wallets extends Table {
  TextColumn get walletPk => text().clientDefault(() => uuid.v4())();
  TextColumn get name => text().withLength(max: NAME_LIMIT)();
  TextColumn get colour => text().withLength(max: COLOUR_LIMIT).nullable()();
  TextColumn get iconName => text().nullable()(); // Money symbol
  DateTimeColumn get dateCreated =>
      dateTime().clientDefault(() => new DateTime.now())();
  DateTimeColumn get dateTimeModified =>
      dateTime().withDefault(Constant(DateTime.now())).nullable()();
  IntColumn get order => integer()();
  TextColumn get currency => text().nullable()();
  IntColumn get decimals => integer().withDefault(Constant(2))();
  TextColumn get homePageWidgetDisplay => text()
      .nullable()
      .withDefault(const Constant(null))
      .map(const HomePageWidgetDisplayListInColumnConverter())();

  @override
  Set<Column> get primaryKey => {walletPk};
}

@DataClassName('Transaction')
class Transactions extends Table {
  TextColumn get transactionPk => text().clientDefault(() => uuid.v4())();
  TextColumn get name => text().withLength(max: NAME_LIMIT)();
  RealColumn get amount => real()();
  TextColumn get note => text().withLength(max: NOTE_LIMIT)();
  TextColumn get categoryFk => text().references(Categories, #categoryPk)();
  TextColumn get subCategoryFk => text()
      .references(Categories, #categoryPk)
      .withDefault(const Constant(null))
      .nullable()();
  TextColumn get walletFk =>
      text().references(Wallets, #walletPk).withDefault(const Constant("0"))();
  // TextColumn get labelFks =>
  //     text().map(const IntListInColumnConverter()).nullable()();
  DateTimeColumn get dateCreated =>
      dateTime().clientDefault(() => new DateTime.now())();
  // DateTimeColumn get dateTimeCreated =>
  //     dateTime().withDefault(Constant(DateTime.now())).nullable()();
  DateTimeColumn get dateTimeModified =>
      dateTime().withDefault(Constant(DateTime.now())).nullable()();
  // The original date the transaction was due. When a transaction is paid, the date gets set to the current time
  // This stores the original date it was supposed to be due on.
  DateTimeColumn get originalDateDue =>
      dateTime().withDefault(Constant(DateTime.now())).nullable()();
  BoolColumn get income => boolean().withDefault(const Constant(false))();
  // Subscriptions and Repetitive payments
  IntColumn get periodLength => integer().nullable()();
  IntColumn get reoccurrence => intEnum<BudgetReoccurence>().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  BoolColumn get upcomingTransactionNotification =>
      boolean().withDefault(const Constant(true)).nullable()();
  IntColumn get type => intEnum<TransactionSpecialType>().nullable()();
  // For credit and debts, paid will be true initially, then false when it is received/paid
  // this is the opposite of what is expected - but taht's because we only want it to count for the totals
  // until it is recieved/paid off resulting in a net of 0
  BoolColumn get paid => boolean().withDefault(const Constant(false))();
  // If user sets to paid and then un pays it will not create a new transaction
  BoolColumn get createdAnotherFutureTransaction =>
      boolean().withDefault(const Constant(false)).nullable()();
  BoolColumn get skipPaid => boolean().withDefault(const Constant(false))();
  // methodAdded will be shared if downloaded from shared server
  IntColumn get methodAdded => intEnum<MethodAdded>().nullable()();
  // Attributes to configure sharing of transactions:
  // Note: a transaction has not been published until methodAdded is shared and sharedKey is not null
  TextColumn get transactionOwnerEmail => text().nullable()();
  TextColumn get transactionOriginalOwnerEmail => text().nullable()();
  TextColumn get sharedKey => text().nullable()();
  TextColumn get sharedOldKey => text()
      .nullable()(); // when a transaction removed shared, this will be sharedKey
  IntColumn get sharedStatus => intEnum<SharedStatus>().nullable()();
  DateTimeColumn get sharedDateUpdated => dateTime().nullable()();
  // the budget this transaction belongs to
  TextColumn get sharedReferenceBudgetPk => text().nullable()();

  TextColumn get objectiveFk =>
      text().references(Objectives, #objectivePk).nullable()();
  TextColumn get budgetFksExclude =>
      text().map(const StringListInColumnConverter()).nullable()();

  @override
  Set<Column> get primaryKey => {transactionPk};
}

@DataClassName('TransactionCategory')
class Categories extends Table {
  TextColumn get categoryPk => text().clientDefault(() => uuid.v4())();
  TextColumn get name => text().withLength(max: NAME_LIMIT)();
  TextColumn get colour => text().withLength(max: COLOUR_LIMIT).nullable()();
  TextColumn get iconName => text().nullable()();
  TextColumn get emojiIconName => text().nullable()();
  DateTimeColumn get dateCreated =>
      dateTime().clientDefault(() => new DateTime.now())();
  DateTimeColumn get dateTimeModified =>
      dateTime().withDefault(Constant(DateTime.now())).nullable()();
  IntColumn get order => integer()();
  BoolColumn get income => boolean().withDefault(const Constant(false))();
  IntColumn get methodAdded => intEnum<MethodAdded>().nullable()();
  // If mainCategoryPk is null, it is a main category and can have sub categories
  // If mainCategoryPk is NOT null, it is a subcategory
  TextColumn get mainCategoryPk => text()
      .references(Categories, #categoryPk)
      .withDefault(const Constant(null))
      .nullable()();

  // Attributes to configure sharing of transactions:
  // sharedKey will have the key referencing the entry in the firebase database, if this is null, it is not shared
  // TextColumn get sharedKey => text().nullable()();
  // IntColumn get sharedOwnerMember => intEnum<SharedOwnerMember>().nullable()();
  // DateTimeColumn get sharedDateUpdated => dateTime().nullable()();
  // TextColumn get sharedMembers =>
  //     text().map(const StringListInColumnConverter()).nullable()();

  @override
  Set<Column> get primaryKey => {categoryPk};
}

@DataClassName('CategoryBudgetLimit')
class CategoryBudgetLimits extends Table {
  TextColumn get categoryLimitPk => text().clientDefault(() => uuid.v4())();
  TextColumn get categoryFk => text().references(Categories, #categoryPk)();
  TextColumn get budgetFk => text().references(Budgets, #budgetPk)();
  RealColumn get amount => real()();
  DateTimeColumn get dateTimeModified =>
      dateTime().withDefault(Constant(DateTime.now())).nullable()();
  TextColumn get walletFk =>
      text().references(Wallets, #walletPk).withDefault(const Constant("0"))();

  @override
  Set<Column> get primaryKey => {categoryLimitPk};
}

//If a title is in a smart label, automatically choose this category
// For e.g. for Food category
// smartLabels = ["apple", "pear"]
// Then when user sets title to pineapple, it will set the category to Food. Because "apple" is in "pineapple".
@DataClassName('TransactionAssociatedTitle')
class AssociatedTitles extends Table {
  TextColumn get associatedTitlePk => text().clientDefault(() => uuid.v4())();
  TextColumn get categoryFk => text().references(Categories, #categoryPk)();
  TextColumn get title => text().withLength(max: NAME_LIMIT)();
  DateTimeColumn get dateCreated =>
      dateTime().clientDefault(() => new DateTime.now())();
  DateTimeColumn get dateTimeModified =>
      dateTime().withDefault(Constant(DateTime.now())).nullable()();
  IntColumn get order => integer()();
  BoolColumn get isExactMatch => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {associatedTitlePk};
}

// @DataClassName('TransactionLabel')
// class Labels extends Table {
//   IntColumn get label_pk => integer().autoIncrement()();
//   TextColumn get name => text().withLength(max: NAME_LIMIT)();
//   IntColumn get categoryFk => integer().references(Categories, #categoryPk)();
//   DateTimeColumn get dateCreated =>
//       dateTime().clientDefault(() => new DateTime.now())();
//   DateTimeColumn get dateTimeModified =>
//       dateTime().withDefault(Constant(DateTime.now())).nullable()();
//   IntColumn get order => integer()();
// }

@DataClassName('Budget')
class Budgets extends Table {
  TextColumn get budgetPk => text().clientDefault(() => uuid.v4())();
  TextColumn get name => text().withLength(max: NAME_LIMIT)();
  RealColumn get amount => real()();
  TextColumn get colour => text()
      .withLength(max: COLOUR_LIMIT)
      .nullable()(); // if null we are using the themes color
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  TextColumn get walletFks =>
      text().map(const StringListInColumnConverter()).nullable()();
  TextColumn get categoryFks =>
      text().map(const StringListInColumnConverter()).nullable()();
  TextColumn get categoryFksExclude =>
      text().map(const StringListInColumnConverter()).nullable()();
  // BoolColumn get allCategoryFks => boolean()();
  BoolColumn get income => boolean().withDefault(const Constant(false))();
  BoolColumn get addedTransactionsOnly =>
      boolean().withDefault(const Constant(false))();
  IntColumn get periodLength => integer()();
  IntColumn get reoccurrence => intEnum<BudgetReoccurence>().nullable()();
  DateTimeColumn get dateCreated =>
      dateTime().clientDefault(() => new DateTime.now())();
  DateTimeColumn get dateTimeModified =>
      dateTime().withDefault(Constant(DateTime.now())).nullable()();
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();
  IntColumn get order => integer()();
  TextColumn get walletFk =>
      text().references(Wallets, #walletPk).withDefault(const Constant("0"))();
  TextColumn get budgetTransactionFilters => text()
      .nullable()
      .withDefault(const Constant(null))
      .map(const BudgetTransactionFiltersListInColumnConverter())();
  TextColumn get memberTransactionFilters => text()
      .nullable()
      .withDefault(const Constant(null))
      .map(const StringListInColumnConverter())();
  // Attributes to configure sharing of transactions:
  // sharedKey will have the key referencing the entry in the firebase database, if this is null, it is not shared
  TextColumn get sharedKey => text().nullable()();
  IntColumn get sharedOwnerMember => intEnum<SharedOwnerMember>().nullable()();
  DateTimeColumn get sharedDateUpdated => dateTime().nullable()();
  TextColumn get sharedMembers =>
      text().map(const StringListInColumnConverter()).nullable()();
  TextColumn get sharedAllMembersEver =>
      text().map(const StringListInColumnConverter()).nullable()();
  BoolColumn get isAbsoluteSpendingLimit =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {budgetPk};
}
// Server entry

@DataClassName('AppSetting')
class AppSettings extends Table {
  // We can keep it as an IntColumn, there will only ever be one entry at id 0
  IntColumn get settingsPk => integer().autoIncrement()();
  TextColumn get settingsJSON =>
      text()(); // This is the JSON stored as a string for shared prefs 'userSettings'
  DateTimeColumn get dateUpdated =>
      dateTime().clientDefault(() => new DateTime.now())();
}

@DataClassName('ScannerTemplate')
class ScannerTemplates extends Table {
  TextColumn get scannerTemplatePk => text().clientDefault(() => uuid.v4())();
  DateTimeColumn get dateCreated =>
      dateTime().clientDefault(() => new DateTime.now())();
  DateTimeColumn get dateTimeModified =>
      dateTime().withDefault(Constant(DateTime.now())).nullable()();
  TextColumn get templateName => text().withLength(max: NAME_LIMIT)();
  TextColumn get contains => text().withLength(max: NAME_LIMIT)();
  TextColumn get titleTransactionBefore => text().withLength(max: NAME_LIMIT)();
  TextColumn get titleTransactionAfter => text().withLength(max: NAME_LIMIT)();
  TextColumn get amountTransactionBefore =>
      text().withLength(max: NAME_LIMIT)();
  TextColumn get amountTransactionAfter => text().withLength(max: NAME_LIMIT)();
  TextColumn get defaultCategoryFk =>
      text().references(Categories, #categoryPk)();
  TextColumn get walletFk =>
      text().references(Wallets, #walletPk).withDefault(const Constant("0"))();
  // TODO: if it contains certain keyword ignore these emails
  BoolColumn get ignore => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {scannerTemplatePk};
}

// Objective, savings jars, payment goals, installments, targets etc.
@DataClassName('Objective')
class Objectives extends Table {
  TextColumn get objectivePk => text().clientDefault(() => uuid.v4())();
  TextColumn get name => text().withLength(max: NAME_LIMIT)();
  RealColumn get amount => real()();
  IntColumn get order => integer()();
  TextColumn get colour => text()
      .withLength(max: COLOUR_LIMIT)
      .nullable()(); // if null we are using the themes color
  DateTimeColumn get dateCreated =>
      dateTime().clientDefault(() => new DateTime.now())();
  DateTimeColumn get endDate => dateTime().nullable()();
  DateTimeColumn get dateTimeModified =>
      dateTime().withDefault(Constant(DateTime.now())).nullable()();
  TextColumn get iconName => text().nullable()();
  TextColumn get emojiIconName => text().nullable()();
  BoolColumn get income => boolean().withDefault(const Constant(false))();
  BoolColumn get pinned => boolean().withDefault(const Constant(true))();
  TextColumn get walletFk =>
      text().references(Wallets, #walletPk).withDefault(const Constant("0"))();

  @override
  Set<Column> get primaryKey => {objectivePk};
}

class TransactionWithCategory {
  final TransactionCategory category;
  final Transaction transaction;
  final TransactionWallet? wallet;
  final Budget? budget;
  final Objective? objective;
  final TransactionCategory? subCategory;
  TransactionWithCategory({
    required this.category,
    required this.transaction,
    this.wallet,
    this.budget,
    this.objective,
    this.subCategory,
  });
}

class CategoryWithDetails {
  final TransactionCategory category;
  final int? numberTransactions;
  CategoryWithDetails({
    required this.category,
    this.numberTransactions,
  });
}

class WalletWithDetails {
  final TransactionWallet wallet;
  final double? totalSpent;
  final int? numberTransactions;
  WalletWithDetails({
    required this.wallet,
    this.totalSpent,
    this.numberTransactions,
  });
}

class AllWallets {
  final List<TransactionWallet> list;
  final Map<String, TransactionWallet> indexedByPk;
  AllWallets({required this.list, required this.indexedByPk});

  bool allContainSameCurrency() {
    if (list.isEmpty) {
      return false;
    }
    final String? firstCurrency = list.first.currency;
    return list.every((wallet) => wallet.currency == firstCurrency);
  }
}

class CategoryWithTotal {
  final TransactionCategory category;
  final CategoryBudgetLimit? categoryBudgetLimit;
  final double total;
  final int transactionCount;

  CategoryWithTotal({
    required this.category,
    required this.total,
    this.transactionCount = 0,
    this.categoryBudgetLimit,
  });

  @override
  String toString() {
    return 'CategoryWithTotal {'
        'category: ${category.name}, '
        'total: $total, '
        '}';
  }

  CategoryWithTotal copyWith({
    TransactionCategory? category,
    CategoryBudgetLimit? categoryBudgetLimit,
    double? total,
    int? transactionCount,
  }) {
    return CategoryWithTotal(
      category: category ?? this.category,
      categoryBudgetLimit: categoryBudgetLimit ?? this.categoryBudgetLimit,
      total: total ?? this.total,
      transactionCount: transactionCount ?? this.transactionCount,
    );
  }
}

// bool canAddToBudget(bool? income, TransactionSpecialType? transactionType) {
//   return income != true &&
//       transactionType != TransactionSpecialType.credit &&
//       transactionType != TransactionSpecialType.debt;
// }

// when adding a new table, make sure to enable syncing and that
// all relevant delete queries create delete logs
// Modify processSyncLogs to process the update/creation and delete!
// Modify syncData to process the newly created!
@DriftDatabase(tables: [
  Wallets,
  Transactions,
  Categories,
  CategoryBudgetLimits,
  // Labels,
  AssociatedTitles,
  Budgets,
  AppSettings,
  ScannerTemplates,
  DeleteLogs,
  Objectives,
])
class FinanceDatabase extends _$FinanceDatabase {
  // FinanceDatabase() : super(_openConnection());
  FinanceDatabase(QueryExecutor e) : super(e);

  // you should bump this number whenever you change or add a table definition
  @override
  int get schemaVersion => schemaVersionGlobal;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      // import 'package:drift_dev/api/migrations.dart';
      // beforeOpen: (details) async {
      //   try {
      //     await validateDatabaseSchema();
      //   } catch (e) {
      //     print("Database mismatch " + e.toString());
      //   }
      // },
      onUpgrade: (migrator, from, to) async {
        print("Migrating from: " + from.toString() + " to " + to.toString());
        if (from <= 9) {
          await migrator.createTable($AppSettingsTable(database));
        }
        if (from <= 10) {
          await migrator.alterTable(TableMigration(budgets));
          await migrator.alterTable(TableMigration(categories));
          await migrator.alterTable(TableMigration(wallets));
        }
        if (from <= 12) {
          await migrator.addColumn(
              transactions, transactions.createdAnotherFutureTransaction);
        }
        if (from <= 13) {
          await migrator.createTable($ScannerTemplatesTable(database));
        }
        if (from <= 14) {
          await migrator.addColumn(
              transactions, transactions.transactionOwnerEmail);
          await migrator.addColumn(transactions, transactions.sharedKey);
          await migrator.addColumn(scannerTemplates, scannerTemplates.ignore);
          // await migrator.addColumn(categories, categories.sharedKey);
          // await migrator.addColumn(
          //     transactions, transactions.dateTimeCreated);
        }
        if (from <= 15) {
          // await migrator.addColumn(categories, categories.sharedOwnerMember);
          // await migrator.addColumn(categories, categories.sharedDateUpdated);
        }
        if (from <= 19) {
          await migrator.addColumn(transactions, transactions.sharedStatus);
        }
        if (from <= 20) {
          await migrator.addColumn(
              transactions, transactions.sharedDateUpdated);
          // await migrator.addColumn(budgets, budgets.sharedTransactionsShow);
        }
        if (from <= 21) {
          await migrator.addColumn(
              transactions, transactions.transactionOriginalOwnerEmail);
          // await migrator.addColumn(categories, categories.sharedMembers);
        }
        if (from <= 21) {
          await migrator.addColumn(wallets, wallets.currency);
        }
        if (from <= 23) {
          await migrator.addColumn(budgets, budgets.sharedKey);
          await migrator.addColumn(budgets, budgets.sharedOwnerMember);
          await migrator.addColumn(budgets, budgets.sharedDateUpdated);
          await migrator.addColumn(budgets, budgets.sharedMembers);
          await migrator.addColumn(
              transactions, transactions.sharedReferenceBudgetPk);
          await migrator.addColumn(transactions, transactions.sharedOldKey);
          await migrator.addColumn(categories, categories.methodAdded);
        }
        if (from <= 24) {
          try {
            await migrator.addColumn(budgets, budgets.sharedAllMembersEver);
          } catch (e) {
            print(e.toString);
          }
        }
        if (from <= 25) {
          try {
            await migrator.addColumn(budgets, budgets.addedTransactionsOnly);
          } catch (e) {
            print(e.toString);
          }
        }
        if (from <= 26) {
          try {
            await migrator.addColumn(
                transactions, transactions.upcomingTransactionNotification);
          } catch (e) {
            print(e.toString);
          }
        }
        if (from <= 27) {
          await migrator.createTable($CategoryBudgetLimitsTable(database));
        }
        if (from <= 28) {
          try {
            await migrator.addColumn(budgets, budgets.budgetTransactionFilters);
          } catch (e) {
            print(e.toString);
          }
          try {
            await migrator.addColumn(budgets, budgets.memberTransactionFilters);
          } catch (e) {
            print(e.toString);
          }
        }
        if (from <= 29) {
          try {
            await migrator.addColumn(budgets, budgets.dateTimeModified);
          } catch (e) {
            print(e.toString);
          }
          await migrator.alterTable(TableMigration(budgets));
        }
        if (from <= 30) {
          try {
            await migrator.addColumn(wallets, wallets.dateTimeModified);
          } catch (e) {
            print(e.toString);
          }
          try {
            await migrator.addColumn(
                transactions, transactions.dateTimeModified);
          } catch (e) {
            print(e.toString);
          }
          try {
            await migrator.addColumn(categories, categories.dateTimeModified);
          } catch (e) {
            print(e.toString);
          }
          try {
            await migrator.addColumn(
                categoryBudgetLimits, categoryBudgetLimits.dateTimeModified);
          } catch (e) {
            print(e.toString);
          }
          try {
            await migrator.addColumn(
                associatedTitles, associatedTitles.dateTimeModified);
          } catch (e) {
            print(e.toString);
          }
          try {
            await migrator.addColumn(budgets, budgets.dateTimeModified);
          } catch (e) {
            print(e.toString);
          }
          try {
            await migrator.addColumn(
                scannerTemplates, scannerTemplates.dateTimeModified);
          } catch (e) {
            print(e.toString);
          }
          // await migrator.addColumn(labels, labels.dateTimeModified);
        }
        if (from <= 31) {
          await migrator.alterTable(TableMigration(budgets));
        }
        if (from <= 32) {
          await migrator.createTable($DeleteLogsTable(database));
          await migrator.alterTable(TableMigration(categories));
          await migrator.alterTable(TableMigration(transactions));
          await migrator.deleteTable("Labels");
        }
        await stepByStep(
          from33To34: (m, schema) async {
            await m.addColumn(schema.wallets, schema.wallets.decimals);
          },
          from34To35: (m, schema) async {
            await m.addColumn(
                schema.budgets, schema.budgets.isAbsoluteSpendingLimit);
          },
          from35To36: (m, schema) async {
            await m.alterTable(TableMigration(schema.transactions));
          },
          from36To37: (m, schema) async {
            await m.alterTable(
              TableMigration(schema.deleteLogs, columnTransformer: {
                schema.deleteLogs.deleteLogPk:
                    schema.deleteLogs.deleteLogPk.cast<String>(),
                schema.deleteLogs.entryPk:
                    schema.deleteLogs.entryPk.cast<String>(),
              }),
            );
            await m.alterTable(
              TableMigration(schema.wallets, columnTransformer: {
                schema.wallets.walletPk: schema.wallets.walletPk.cast<String>(),
              }),
            );
            await m.alterTable(
              TableMigration(schema.transactions, columnTransformer: {
                schema.transactions.transactionPk:
                    schema.transactions.transactionPk.cast<String>(),
                schema.transactions.categoryFk:
                    schema.transactions.categoryFk.cast<String>(),
                schema.transactions.walletFk:
                    schema.transactions.walletFk.cast<String>(),
                schema.transactions.sharedReferenceBudgetPk:
                    schema.transactions.sharedReferenceBudgetPk.cast<String>(),
              }),
            );
            await m.alterTable(
              TableMigration(schema.categories, columnTransformer: {
                schema.categories.categoryPk:
                    schema.categories.categoryPk.cast<String>(),
              }),
            );
            await m.alterTable(
              TableMigration(schema.categoryBudgetLimits, columnTransformer: {
                schema.categoryBudgetLimits.categoryLimitPk:
                    schema.categoryBudgetLimits.categoryLimitPk.cast<String>(),
                schema.categoryBudgetLimits.categoryFk:
                    schema.categoryBudgetLimits.categoryFk.cast<String>(),
                schema.categoryBudgetLimits.budgetFk:
                    schema.categoryBudgetLimits.budgetFk.cast<String>(),
              }),
            );
            await m.alterTable(
              TableMigration(schema.associatedTitles, columnTransformer: {
                schema.associatedTitles.associatedTitlePk:
                    schema.associatedTitles.associatedTitlePk.cast<String>(),
                schema.associatedTitles.categoryFk:
                    schema.associatedTitles.categoryFk.cast<String>(),
              }),
            );
            await m.alterTable(
              TableMigration(schema.budgets, columnTransformer: {
                schema.budgets.budgetPk: schema.budgets.budgetPk.cast<String>(),
                schema.budgets.walletFk: schema.budgets.walletFk.cast<String>(),
              }),
            );
            await m.alterTable(
              TableMigration(schema.scannerTemplates, columnTransformer: {
                schema.scannerTemplates.scannerTemplatePk:
                    schema.scannerTemplates.scannerTemplatePk.cast<String>(),
                schema.scannerTemplates.defaultCategoryFk:
                    schema.scannerTemplates.defaultCategoryFk.cast<String>(),
                schema.scannerTemplates.walletFk:
                    schema.scannerTemplates.walletFk.cast<String>(),
              }),
            );
          },
          from37To38: (m, schema) async {
            print("37 to 38");
            try {
              await m.addColumn(
                  schema.transactions, schema.transactions.originalDateDue);
            } catch (e) {
              print("Migration Error: Error creating column originalDateDue " +
                  e.toString());
            }
          },
          from38To39: (m, schema) async {
            print("38 to 39");
            // We should try and catch for upgrades - why?
            // If a user imports a backup from a newer schema when they are on an older
            // App version, it will import correctly. However, when they do update the app
            // The migrator will run and it will error out!
            try {
              await m.addColumn(
                  schema.categories, schema.categories.emojiIconName);
            } catch (e) {
              print("Migration Error: Error creating column emojiIconName " +
                  e.toString());
            }
          },
          from39To40: (m, schema) async {
            print("39 to 40");
            try {
              await m.addColumn(
                  schema.transactions, schema.transactions.objectiveFk);
            } catch (e) {
              print("Migration Error: Error creating column objectiveFk " +
                  e.toString());
            }
            try {
              await migrator.createTable($ObjectivesTable(database));
            } catch (e) {
              print("Migration Error: Error creating table ObjectivesTable " +
                  e.toString());
            }
          },
          from40To41: (m, schema) async {
            print("40 to 41");
            try {
              await m.addColumn(
                  schema.budgets, schema.budgets.categoryFksExclude);
            } catch (e) {
              print(
                  "Migration Error: Error creating column categoryFksExclude " +
                      e.toString());
            }
            try {
              await m.alterTable(TableMigration(budgets));
            } catch (e) {
              print("Migration Error: Error deleting includeAllCategories " +
                  e.toString());
            }
            try {
              List<Budget> allBudgets = await getAllBudgets();
              List<Budget> budgetsInserting = [];
              for (Budget budget in allBudgets) {
                if (budget.budgetTransactionFilters == null &&
                    budget.addedTransactionsOnly == false) {
                  budgetsInserting.add(budget.copyWith(
                      budgetTransactionFilters: Value([
                    BudgetTransactionFilters.defaultBudgetTransactionFilters
                  ])));
                }
              }
              await updateBatchBudgetsOnly(budgetsInserting);
            } catch (e) {
              print(
                  "Migration Error: Error upgrading transaction filters default for budgets " +
                      e.toString());
            }
          },
          from41To42: (m, schema) async {
            print("41 to 42");
            try {
              await m.addColumn(
                  schema.categories, schema.categories.mainCategoryPk);
            } catch (e) {
              print("Migration Error: Error creating column mainCategoryPk " +
                  e.toString());
            }
            try {
              await m.addColumn(
                  schema.wallets, schema.wallets.homePageWidgetDisplay);
            } catch (e) {
              print(
                  "Migration Error: Error creating column homePageWidgetDisplay " +
                      e.toString());
            }
            try {
              await m.addColumn(
                  schema.transactions, schema.transactions.subCategoryFk);
            } catch (e) {
              print("Migration Error: Error creating column subCategoryFk " +
                  e.toString());
            }
            // Also see beforeOpen
            // We modify the entries of homePageWidgetDisplay of wallet entries after this migration
            // Since this code prevents the other migrations from running after, and it existed before,
            // the budgetFksExclude in 42to43 may have not run properly...
            // Therefore we also have code to check if this was properly created in beforeOpen
          },
          from42To43: (m, schema) async {
            print("42 to 43");
            try {
              await m.addColumn(
                  schema.transactions, schema.transactions.budgetFksExclude);
            } catch (e) {
              print("Migration Error: Error creating column budgetFksExclude " +
                  e.toString());
            }
          },
          from43To44: (m, schema) async {
            print("43 to 44");
            try {
              await m.addColumn(
                  schema.transactions, schema.transactions.endDate);
            } catch (e) {
              print(
                  "Migration Error: Error creating column transactions.endDate" +
                      e.toString());
            }
            try {
              await m.addColumn(schema.objectives, schema.objectives.endDate);
            } catch (e) {
              print(
                  "Migration Error: Error creating column objectives.endDate " +
                      e.toString());
            }
          },
          from44To45: (m, schema) async {
            print("44 to 45");
            try {
              await m.addColumn(schema.budgets, schema.budgets.walletFks);
            } catch (e) {
              print("Migration Error: Error creating column budgets.walletFks" +
                  e.toString());
            }
            try {
              await m.addColumn(schema.budgets, schema.budgets.income);
            } catch (e) {
              print("Migration Error: Error creating column budgets.income " +
                  e.toString());
            }
            try {
              await m.addColumn(schema.objectives, schema.objectives.walletFk);
            } catch (e) {
              print(
                  "Migration Error: Error creating column objectives.walletFk " +
                      e.toString());
            }
            try {
              await m.addColumn(schema.categoryBudgetLimits,
                  schema.categoryBudgetLimits.walletFk);
            } catch (e) {
              print(
                  "Migration Error: Error creating column categoryBudgetLimits.walletFk " +
                      e.toString());
            }
          },
        )(migrator, from, to);
      },
      beforeOpen: (details) async {
        // This code exists because migration 42to43 may have not run correctly...
        // See explanation in 41to42
        try {
          final m = createMigrator();
          await m.addColumn(transactions, transactions.budgetFksExclude);
          print("Migration successfully fixed budgetFksExclude");
        } catch (e) {
          // The column already existed
        }

        if (details.hadUpgrade && details.versionBefore != null) {
          print(
              "Migration Version Before: " + details.versionBefore.toString());
          print("Migration Version After: " + details.versionNow.toString());

          if (details.versionBefore! < 42) {
            // Migration 41to42
            print(
                "Migration updating wallet homePageWidgetDisplay entries to default values");
            try {
              List<TransactionWallet> allWallets = await getAllWallets();
              List<TransactionWallet> walletsInserting = [];
              for (TransactionWallet wallet in allWallets) {
                walletsInserting.add(wallet.copyWith(
                    homePageWidgetDisplay:
                        Value(defaultWalletHomePageWidgetDisplay)));
              }
              await updateBatchWalletsOnly(walletsInserting);
            } catch (e) {
              print(
                  "Migration Error: Error upgrading home page widget display default for wallets " +
                      e.toString());
            }
          }
          if (details.versionBefore! < 45) {
            // Migration 44to45
            print(
                "Migration updating wallet objectives.walletFk to current wallet");
            try {
              List<Objective> allObjectives = await getAllObjectives();
              List<Objective> objectivesInserting = [];
              for (Objective objective in allObjectives) {
                objectivesInserting.add(objective.copyWith(
                    walletFk: appStateSettings["selectedWalletPk"]));
              }
              await updateBatchObjectivesOnly(objectivesInserting);
            } catch (e) {
              print(
                  "Migration Error: Error upgrading objectives.walletFk to current wallet " +
                      e.toString());
            }

            print(
                "Migration updating wallet budget.walletFk to current wallet");
            try {
              List<Budget> allBudgets = await getAllBudgets();
              List<Budget> budgetsInserting = [];
              for (Budget budget in allBudgets) {
                budgetsInserting.add(budget.copyWith(
                    walletFk: appStateSettings["selectedWalletPk"]));
              }
              await updateBatchBudgetsOnly(budgetsInserting);
            } catch (e) {
              print(
                  "Migration Error: Error upgrading objectives.walletFk to current wallet " +
                      e.toString());
            }

            print(
                "Migration updating wallet categoryBudgetLimits.walletFk to current wallet");
            try {
              List<CategoryBudgetLimit> allCategoryBudgetLimits =
                  await getAllCategorySpendingLimits();
              List<CategoryBudgetLimit> categoryBudgetLimitsInserting = [];
              for (CategoryBudgetLimit categoryBudgetLimit
                  in allCategoryBudgetLimits) {
                categoryBudgetLimitsInserting.add(categoryBudgetLimit.copyWith(
                    walletFk: appStateSettings["selectedWalletPk"]));
              }
              await updateBatchCategoryLimitsOnly(
                  categoryBudgetLimitsInserting);
            } catch (e) {
              print(
                  "Migration Error: Error upgrading objectives.walletFk to current wallet " +
                      e.toString());
            }
          }
        }
      },
    );
  }

  // Migration history
  // Use the line with global schema version
  // git log -p -L 22,22:lib\database\tables.dart

  // -int schemaVersionGlobal = 31;
  // +int schemaVersionGlobal = 33;
  // commit 2c8e50bbee8d8f75e2d537ab8ee28d1a2bb288c5
  // Tue Mar 21 02:22:21 2023 -0400

  // -int schemaVersionGlobal = 33;
  // +int schemaVersionGlobal = 34;
  // commit 812c0ada7ec346970d21e711d46f4fa11967b951
  // Tue Apr 25 01:18:51 2023 -0400

  // -int schemaVersionGlobal = 34;
  // +int schemaVersionGlobal = 35;
  // commit 339d6662acc413b03f0fdfbd828c6bca95897f17
  // Sun Jun 18 17:50:44 2023 -0400

  // -int schemaVersionGlobal = 35;
  // +int schemaVersionGlobal = 36;
  // commit 867daa0847f43c504b6a9b75f5613eb4d5b0fc71
  // Mon Jun 26 02:03:47 2023 -0400

  // -int schemaVersionGlobal = 36;
  // +int schemaVersionGlobal = 37;
  // Thu Aug 10 18:40:26 2023 -0400
  // commit c5099cd91c20d05d84bb271e87ca051f55080665

  // -int schemaVersionGlobal = 37;
  // +int schemaVersionGlobal = 38;
  // Sat Aug 12 03:26:31 2023 -0400
  // commit 3b1e604950ec04eba0a545991ba743954156246e

  Future<void> deleteEverything() {
    return transaction(() async {
      for (final table in allTables) {
        await delete(table).go();
      }
    });
  }

  // Future<bool> updateDateCreatedColumn() async {
  //   List<Transaction> transactionsList = await (select(transactions)).get();

  //   await batch((batch) {
  //     for (Transaction transaction in transactionsList) {
  //       batch.update(
  //         transactions,
  //         TransactionsCompanion(
  //           dateCreated: Value(
  //             DateTime(
  //               transaction.dateCreated.year,
  //               transaction.dateCreated.month,
  //               transaction.dateCreated.day,
  //               transaction.dateTimeCreated?.hour ?? 0,
  //               transaction.dateTimeCreated?.minute ?? 0,
  //             ),
  //           ),
  //         ),
  //         where: (t) => t.transactionPk.equals(transaction.transactionPk),
  //       );
  //     }
  //   });
  //   return true;
  // }

  // get all filtered transactions from earliest to oldest date created, paginated
  // Stream<List<Transaction>> watchAllTransactionsFiltered(
  //     {int? categoryPk, String? itemPk, int? limit, int? offset}) {
  //   return (categoryPk != null
  //           ? (select(transactions)
  //             ..where((tbl) => tbl.categoryFk.equals(categoryPk)))
  //           : itemPk != null
  //               ? (select(transactions)
  //                 ..where((tbl) => tbl.labelFks.contains(itemPk)))
  //               : select(transactions)
  //         ..orderBy([(t) => OrderingTerm.desc(t.dateCreated)])
  //         ..limit(limit ?? DEFAULT_LIMIT, offset: offset ?? DEFAULT_OFFSET))
  //       .watch();
  // }

  //get transactions that occurred on a given date
  (Stream<List<Transaction>>, Future<List<Transaction>>) getTransactionWithDate(
      DateTime date) {
    final SimpleSelectStatement<$TransactionsTable, Transaction> query =
        select(transactions)..where((tbl) => tbl.dateCreated.equals(date));
    return (query.watch(), query.get());
  }

  //get transactions that occurred on a given day and category
  Stream<List<TransactionWithCategory>> getTransactionCategoryWithDay(
    DateTime? start,
    DateTime? end, {
    String search = "",
    // Search will be ignored... if these params are passed in
    List<String>? categoryFks,
    List<String>? categoryFksExclude,
    List<String> walletFks = const [],
    bool? income,
    required List<BudgetTransactionFilters>? budgetTransactionFilters,
    required List<String>? memberTransactionFilters,
    String? member,
    String? onlyShowTransactionsBelongingToBudgetPk,
    String? onlyShowTransactionsBelongingToObjectivePk,
    SearchFilters? searchFilters,
    int? limit,
    Budget? budget,
  }) {
    final $CategoriesTable subCategories = alias(categories, 'subCategories');
    JoinedSelectStatement<HasResultSet, dynamic> query;

    query = select(transactions).join([
      innerJoin(
          categories, categories.categoryPk.equalsExp(transactions.categoryFk)),
      leftOuterJoin(
        budgets,
        budgets.budgetPk.equalsExp(transactions.sharedReferenceBudgetPk),
      ),
      leftOuterJoin(
        objectives,
        objectives.objectivePk.equalsExp(transactions.objectiveFk),
      ),
      leftOuterJoin(subCategories,
          subCategories.categoryPk.equalsExp(transactions.subCategoryFk)),
    ])
      ..limit(limit ?? DEFAULT_LIMIT, offset: null)
      ..orderBy([
        // This will bring unpaid transactions to the top of the list
        // Before it brought it to the top of the day, but now
        // This returns all transactions within a time range
        // (t) => OrderingTerm(
        //       expression: (t.type
        //                   .equalsValue(TransactionSpecialType.repetitive) |
        //               t.type.equalsValue(
        //                   TransactionSpecialType.subscription) |
        //               t.type.equalsValue(TransactionSpecialType.upcoming)) &
        //           t.paid.equals(false),
        //       mode: OrderingMode.desc,
        //     ),
        OrderingTerm.desc(transactions.dateCreated)
      ])
      ..where(
        onlyShowBalanceCorrectionIfIsIncomeIsNull(transactions, income) &
            onlyShowTransactionBasedOnSearchQuery(transactions, search,
                withCategories: true,
                joinedWithSubcategoriesTable: subCategories) &
            // Pass in the subcategories table so we can search name based on subcategory
            onlyShowIfFollowsSearchFilters(
              transactions,
              searchFilters,
              joinedWithSubcategoriesTable: subCategories,
              joinedWithBudgets: true,
              joinedWithCategories: true,
              joinedWithObjectives: true,
            ) &
            onlyShowIfFollowsFilters(transactions,
                budgetTransactionFilters: budgetTransactionFilters,
                memberTransactionFilters: memberTransactionFilters) &
            onlyShowBasedOnTimeRange(transactions, start, end, budget) &
            (onlyShowBasedOnCategoryFks(
                    transactions, categoryFks, categoryFksExclude) |
                onlyShowBasedOnSubcategoryFks(transactions, categoryFks)) &
            onlyShowBasedOnWalletFks(transactions, walletFks) &
            onlyShowBasedOnIncome(transactions, income) &
            onlyShowIfMember(transactions, member) &
            onlyShowIfNotExcludedFromBudget(transactions, budget?.budgetPk) &
            onlyShowIfCertainBudget(
                transactions, onlyShowTransactionsBelongingToBudgetPk) &
            onlyShowIfCertainObjective(
                transactions, onlyShowTransactionsBelongingToObjectivePk),
      );

    return query.watch().map((rows) => rows.map((row) {
          return TransactionWithCategory(
              category: row.readTable(categories),
              transaction: row.readTable(transactions),
              budget: row.readTableOrNull(budgets),
              objective: row.readTableOrNull(objectives),
              subCategory: row.readTableOrNull(subCategories));
        }).toList());
  }

  Expression<bool> isOnDay(
      GeneratedColumn<DateTime> dateColumn, DateTime date) {
    return dateColumn.isBetweenValues(
        DateTime(date.year, date.month, date.day),
        DateTime(date.year, date.month, date.day + 1)
            .subtract(Duration(milliseconds: 1)));
  }

  Stream<RangeValues> getHighestLowestAmount(SearchFilters searchFilters) {
    final max = transactions.amount.max();
    final min = transactions.amount.min();
    final query = selectOnly(transactions)
      ..where(onlyShowIfFollowsSearchFilters(
        transactions,
        searchFilters,
        joinedWithBudgets: false,
        joinedWithCategories: false,
        joinedWithObjectives: false,
        joinedWithSubcategoriesTable: null,
      ))
      ..addColumns([max, min]);
    return query
        .map((row) => RangeValues(row.read(min) ?? 0, row.read(max) ?? 0))
        .watchSingle();
  }

  // Unused
  Stream<List<DateTime?>> getUniqueDates({
    required DateTime? start,
    required DateTime? end,
    String search = "",
    // Search will be ignored... if these params are passed in
    List<String>? categoryFks,
    List<String>? categoryFksExclude,
    List<String> walletFks = const [],
    bool? income,
    required List<BudgetTransactionFilters>? budgetTransactionFilters,
    required List<String>? memberTransactionFilters,
    String? member,
    String? onlyShowTransactionsBelongingToBudgetPk,
    String? onlyShowTransactionsBelongingToObjectivePk,
    Budget? budget,
    int? limit,
    SearchFilters? searchFilters,
  }) {
    DateTime? startDate =
        start == null ? null : DateTime(start.year, start.month, start.day);
    DateTime? endDate =
        end == null ? null : DateTime(end.year, end.month, end.day);
    final $CategoriesTable subCategories = alias(categories, 'subCategories');

    final query = selectOnly(transactions, distinct: true)
      ..join([
        leftOuterJoin(categories,
            categories.categoryPk.equalsExp(transactions.categoryFk)),
        leftOuterJoin(subCategories,
            subCategories.categoryPk.equalsExp(transactions.subCategoryFk)),
      ])
      ..orderBy([OrderingTerm.desc(transactions.dateCreated)])
      ..where(
        onlyShowTransactionBasedOnSearchQuery(transactions, search,
                withCategories: true,
                joinedWithSubcategoriesTable: subCategories) &
            onlyShowIfFollowsSearchFilters(
              transactions,
              searchFilters,
              joinedWithCategories: true,
              joinedWithSubcategoriesTable: subCategories,
              joinedWithBudgets: false,
              joinedWithObjectives: false,
            ) &
            onlyShowIfFollowsFilters(transactions,
                budgetTransactionFilters: budgetTransactionFilters,
                memberTransactionFilters: memberTransactionFilters) &
            onlyShowBasedOnTimeRange(transactions, startDate, endDate, budget) &
            (onlyShowBasedOnCategoryFks(
                    transactions, categoryFks, categoryFksExclude) |
                onlyShowBasedOnSubcategoryFks(transactions, categoryFks)) &
            onlyShowBasedOnWalletFks(transactions, walletFks) &
            onlyShowBasedOnIncome(transactions, income) &
            onlyShowIfMember(transactions, member) &
            onlyShowIfNotExcludedFromBudget(transactions, budget?.budgetPk) &
            onlyShowIfCertainBudget(
                transactions, onlyShowTransactionsBelongingToBudgetPk) &
            onlyShowIfCertainObjective(
                transactions, onlyShowTransactionsBelongingToObjectivePk),
      )
      ..addColumns([transactions.dateCreated])
      ..where(transactions.dateCreated.isNotNull())
      ..limit(limit ?? DEFAULT_LIMIT, offset: null);

    if (limit == null)
      return query.map((row) => row.read(transactions.dateCreated)).watch();
    else
      return query
          .map((row) => row.read(transactions.dateCreated))
          .watch()
          .map((list) => list.reversed.toList());
  }

  Future<List<String?>> getUniqueCurrenciesFromWallets() {
    final query = selectOnly(wallets, distinct: true)
      ..addColumns([wallets.currency])
      ..where(wallets.currency.isNotNull());

    return query.map((row) => row.read(wallets.currency)).get();
  }

  // Stream<List<TransactionWithCategory>> getTransactionCategoryWithMonth(
  //   DateTime date, {
  //   String search = "",
  //   // Search will be ignored... if these params are passed in
  //   List<String> categoryFks = const [],
  // }) {
  //   JoinedSelectStatement<HasResultSet, dynamic> query;
  //   if (categoryFks.length > 0) {
  //     query = (select(transactions)
  //           ..where((tbl) {
  //             final dateCreated = tbl.dateCreated;
  //             return isOnDay(dateCreated, date) &
  //                 tbl.categoryFk.isIn(categoryFks);
  //           }))
  //         .join([
  //       leftOuterJoin(categories,
  //           categories.categoryPk.equalsExp(transactions.categoryFk))
  //     ]);
  //   } else if (search == "") {
  //     query = (select(transactions)
  //           ..where((tbl) {
  //             final dateCreated = tbl.dateCreated;
  //             return isOnDay(dateCreated, date);
  //           }))
  //         .join([
  //       leftOuterJoin(categories,
  //           categories.categoryPk.equalsExp(transactions.categoryFk))
  //     ]);
  //   } else {
  //     query = ((select(transactions)
  //           ..where((tbl) {
  //             final dateCreated = tbl.dateCreated;
  //             return isOnDay(dateCreated, date);
  //           }))
  //         .join([
  //       innerJoin(categories,
  //           categories.categoryPk.equalsExp(transactions.categoryFk))
  //     ]))
  //       ..where(categories.name.lower().like("%" + search.toLowerCase() + "%") |
  //           transactions.name.like("%" + search + "%"));
  //   }

  //   return query.watch().map((rows) => rows.map((row) {
  //         return TransactionWithCategory(
  //             category: row.readTable(categories),
  //             transaction: row.readTable(transactions));
  //       }).toList());
  // }

  //get the days that a transaction occurs on, specify search term, categories, or time period to list these
  // Stream<List<DateTime?>> watchDatesOfTransaction(
  //     {DateTime? startDate,
  //     DateTime? endDate,
  //     String search = "",
  //     // Search will be ignored... if these params are passed in
  //     List<String> categoryFks = const []}) {
  //   if (categoryFks.length > 0) {
  //     final query = (select(transactions)
  //       ..where((tbl) {
  //         if (startDate != null && endDate != null) {
  //           return tbl.dateCreated.isBiggerOrEqualValue(startDate) &
  //               tbl.dateCreated.isSmallerOrEqualValue(endDate) &
  //               tbl.categoryFk.isIn(categoryFks);
  //         } else {
  //           return tbl.categoryFk.isIn(categoryFks);
  //         }
  //       })
  //       ..orderBy([(t) => OrderingTerm.asc(t.dateCreated)]));
  //     DateTime previousDate = DateTime.now();
  //     return query.map((tbl) {
  //       DateTime currentDate = DateTime(
  //           tbl.dateCreated.year, tbl.dateCreated.month, tbl.dateCreated.day);
  //       if (previousDate != currentDate) {
  //         previousDate = currentDate;
  //         return currentDate;
  //       } else {
  //         previousDate = currentDate;
  //         return null;
  //       }
  //     }).watch();
  //   } else if (search == "") {
  //     final query = (select(transactions)
  //       ..where((tbl) {
  //         if (startDate != null && endDate != null) {
  //           return tbl.dateCreated.isBiggerOrEqualValue(startDate) &
  //               tbl.dateCreated.isSmallerOrEqualValue(endDate);
  //         } else {
  //           return tbl.walletFk.isNotNull();
  //         }
  //       })
  //       ..orderBy([(t) => OrderingTerm.asc(t.dateCreated)]));
  //     DateTime previousDate = DateTime.now();
  //     return query.map((tbl) {
  //       DateTime currentDate = DateTime(
  //           tbl.dateCreated.year, tbl.dateCreated.month, tbl.dateCreated.day);
  //       if (previousDate != currentDate) {
  //         previousDate = currentDate;
  //         return currentDate;
  //       } else {
  //         previousDate = currentDate;
  //         return null;
  //       }
  //     }).watch();
  //   } else {
  //     final query = ((select(transactions)
  //           ..where((tbl) {
  //             if (startDate != null && endDate != null) {
  //               return tbl.dateCreated.isBiggerOrEqualValue(startDate) &
  //                   tbl.dateCreated.isSmallerOrEqualValue(endDate);
  //             } else {
  //               return tbl.walletFk.isNotNull();
  //             }
  //           })
  //           ..orderBy([(t) => OrderingTerm.asc(t.dateCreated)]))
  //         .join([
  //       innerJoin(categories,
  //           categories.categoryPk.equalsExp(transactions.categoryFk))
  //     ]))
  //       ..where(categories.name.lower().like("%" + search.toLowerCase() + "%") |
  //           transactions.name.like("%" + search + "%"));
  //     DateTime previousDate = DateTime.now();
  //     return query.watch().map((rows) => rows.map((row) {
  //           DateTime currentDate = DateTime(
  //               row.readTable(transactions).dateCreated.year,
  //               row.readTable(transactions).dateCreated.month,
  //               row.readTable(transactions).dateCreated.day);
  //           if (previousDate != currentDate) {
  //             previousDate = currentDate;
  //             return currentDate;
  //           } else {
  //             previousDate = currentDate;
  //             return null;
  //           }
  //         }).toList());
  //   }
  // }

  //watch all transactions sorted by date
  Stream<List<Transaction>> watchAllTransactions(
      {int? limit, DateTime? startDate, DateTime? endDate}) {
    return (select(transactions)
          ..where((tbl) {
            if (startDate != null && endDate != null) {
              return tbl.dateCreated.isBiggerOrEqualValue(startDate) &
                  tbl.dateCreated.isSmallerOrEqualValue(endDate);
            } else {
              return tbl.walletFk.isNotNull();
            }
          })
          ..orderBy([(b) => OrderingTerm.desc(b.dateCreated)])
          ..limit(limit ?? DEFAULT_LIMIT))
        .watch();
  }

  // This gets all overdue subscription transactions
  (Stream<List<Transaction>>, Future<List<Transaction>>) getAllSubscriptions() {
    final query = select(transactions)
      ..orderBy([(t) => OrderingTerm.asc(t.dateCreated)])
      ..where(
        (transaction) =>
            transactions.paid.equals(false) &
            transactions.type
                .equals(TransactionSpecialType.subscription.index) &
            transactions.skipPaid.equals(false),
      );
    return (query.watch(), query.get());
  }

  // This gets all overdue upcoming transactions
  (Stream<List<Transaction>>, Future<List<Transaction>>)
      getAllOverdueUpcomingTransactions() {
    final query = select(transactions)
      ..orderBy([(t) => OrderingTerm.asc(t.dateCreated)])
      ..where(
        (transaction) =>
            transactions.paid.equals(false) &
            transactions.type.equals(TransactionSpecialType.upcoming.index) &
            transactions.skipPaid.equals(false),
      );
    return (query.watch(), query.get());
  }

  // This gets all overdue repetitive transactions
  (Stream<List<Transaction>>, Future<List<Transaction>>)
      getAllOverdueRepetitiveTransactions() {
    final query = select(transactions)
      ..orderBy([(t) => OrderingTerm.asc(t.dateCreated)])
      ..where(
        (transaction) =>
            transactions.paid.equals(false) &
            transactions.type.equals(TransactionSpecialType.repetitive.index) &
            transactions.skipPaid.equals(false),
      );
    return (query.watch(), query.get());
  }

  // This only gets upcoming transactions that are past the current time
  Future<List<Transaction>> getAllUpcomingTransactions(
      {int? limit, DateTime? startDate, DateTime? endDate}) {
    final query = select(transactions)
      ..orderBy([(b) => OrderingTerm.asc(b.dateCreated)])
      ..where((transaction) =>
          transactions.skipPaid.equals(false) &
          transactions.paid.equals(false) &
          transactions.dateCreated
              .isBiggerThanValue(startDate ?? DateTime.now()) &
          transactions.dateCreated.isSmallerThanValue(
              endDate ?? DateTime.now().add(Duration(days: 1000))) &
          (transactions.type.equals(TransactionSpecialType.subscription.index) |
              transactions.type
                  .equals(TransactionSpecialType.repetitive.index) |
              transactions.type.equals(TransactionSpecialType.upcoming.index)));
    return query.get();
  }

  Stream<List<Transaction>> watchAllUpcomingTransactions(String? searchString,
      {int? limit, DateTime? startDate, DateTime? endDate, bool? isIncome}) {
    final query = select(transactions)
      ..orderBy([(b) => OrderingTerm.asc(b.dateCreated)])
      ..where((transactions) =>
          onlyShowBasedOnIncome(transactions, isIncome) &
          transactions.skipPaid.equals(false) &
          transactions.paid.equals(false) &
          transactions.dateCreated
              .isBiggerThanValue(startDate ?? DateTime.now()) &
          transactions.dateCreated.isSmallerThanValue(
              endDate ?? DateTime.now().add(Duration(days: 1000))) &
          (transactions.type.equals(TransactionSpecialType.subscription.index) |
              transactions.type
                  .equals(TransactionSpecialType.repetitive.index) |
              transactions.type.equals(TransactionSpecialType.upcoming.index)));
    return query.watch();
  }

  Stream<List<Transaction>> watchAllOverdueUpcomingTransactions(
      bool? isOverdueTransactions,
      {int? limit,
      String? searchString}) {
    final $CategoriesTable subCategories = alias(categories, 'subCategories');
    final query = select(transactions).join([
      innerJoin(
          categories, categories.categoryPk.equalsExp(transactions.categoryFk)),
      leftOuterJoin(subCategories,
          subCategories.categoryPk.equalsExp(transactions.subCategoryFk)),
    ])
      ..orderBy([OrderingTerm.asc(transactions.dateCreated)])
      ..where(onlyShowTransactionBasedOnSearchQuery(transactions, searchString,
              withCategories: true,
              joinedWithSubcategoriesTable: subCategories) &
          transactions.skipPaid.equals(false) &
          transactions.paid.equals(false) &
          (isOverdueTransactions == null
              ? Constant(true)
              : isOverdueTransactions == true
                  ? transactions.dateCreated.isSmallerThanValue(DateTime.now())
                  : transactions.dateCreated
                      .isBiggerThanValue(DateTime.now())) &
          (transactions.type.equals(TransactionSpecialType.subscription.index) |
              transactions.type
                  .equals(TransactionSpecialType.repetitive.index) |
              transactions.type.equals(TransactionSpecialType.upcoming.index)));

    return query.map((row) => row.readTable(transactions)).watch();
  }

  //get dates of all transactions in the month and year
  Stream<List<DateTime>> getTransactionDays(DateTime date) {
    final query = (select(transactions)
      ..where((tbl) {
        final dateCreated = tbl.dateCreated;
        return dateCreated.year.equals(date.year) &
            dateCreated.month.equals(date.month);
      }));

    return query
        .map((tbl) => DateTime(
            tbl.dateCreated.year, tbl.dateCreated.month, tbl.dateCreated.day))
        .watch();
  }

  // watch all labels in a category (if given)
  // Stream<List<TransactionLabel>> watchAllLabelsInCategory(int? categoryPk) {
  //   return (categoryPk != null
  //           ? (select(labels)
  //             ..where((label) => label.categoryFk.equals(categoryPk)))
  //           : select(labels))
  //       .watch();
  // }

  // // watch all labels grouped by all category
  // Stream<List<TypedResult>> watchAllLabelsGroupedByCategory() {
  //   return (select(categories).join([
  //     innerJoin(labels, labels.categoryFk.equalsExp(categories.categoryPk))
  //   ])
  //         ..groupBy([categories.categoryPk]))
  //       .watch();
  // }

  // watch all budgets that have been created
  Stream<List<Budget>> watchAllBudgets(
      {String? searchFor, int? limit, int? offset}) {
    return (select(budgets)
          ..where((b) => (searchFor == null
              ? Constant(true)
              : b.name.collate(Collate.noCase).like("%" + (searchFor) + "%")))
          ..orderBy([(b) => OrderingTerm.asc(b.order)])
          ..limit(limit ?? DEFAULT_LIMIT, offset: offset ?? DEFAULT_OFFSET))
        .watch();
  }

  Future<List<TransactionAssociatedTitle>> getSimilarAssociatedTitles(
      {required String title, int? limit, int? offset}) {
    return (select(associatedTitles)
          ..where(
              (t) => (t.title.collate(Collate.noCase).like("%" + title + "%")))
          ..orderBy([(t) => OrderingTerm.desc(t.order)])
          ..limit(limit ?? DEFAULT_LIMIT, offset: offset ?? DEFAULT_OFFSET))
        .get();
  }

  (Stream<List<TransactionWallet>>, Future<List<TransactionWallet>>)
      getAllPinnedWallets(HomePageWidgetDisplay homePageWidgetDisplay) {
    final query = (select(wallets)
      ..where((tbl) => tbl.homePageWidgetDisplay
          .contains(homePageWidgetDisplay.index.toString()))
      ..orderBy([(b) => OrderingTerm.asc(b.order)]));
    return (query.watch(), query.get());
  }

  // watch all budgets that have been created that are pinned
  (Stream<List<Budget>>, Future<List<Budget>>) getAllPinnedBudgets(
      {int? limit, int? offset}) {
    final query = (select(budgets)
      ..where((tbl) => tbl.pinned.equals(true))
      ..orderBy([(b) => OrderingTerm.asc(b.order)])
      ..limit(limit ?? DEFAULT_LIMIT, offset: offset ?? DEFAULT_OFFSET));
    return (query.watch(), query.get());
  }

  (Stream<List<Objective>>, Future<List<Objective>>) getAllPinnedObjectives(
      {int? limit, int? offset}) {
    final query = (select(objectives)
      ..where((tbl) => tbl.pinned.equals(true))
      ..orderBy([(b) => OrderingTerm.asc(b.order)])
      ..limit(limit ?? DEFAULT_LIMIT, offset: offset ?? DEFAULT_OFFSET));
    return (query.watch(), query.get());
  }

  Stream<Budget> getBudget(String budgetPk) {
    return (select(budgets)..where((b) => b.budgetPk.equals(budgetPk)))
        .watchSingle();
  }

  Stream<Objective> getObjective(String objectivePk) {
    return (select(objectives)..where((o) => o.objectivePk.equals(objectivePk)))
        .watchSingle();
  }

  Stream<TransactionWallet> getWallet(String walletPk) {
    return (select(wallets)..where((w) => w.walletPk.equals(walletPk)))
        .watchSingle();
  }

  Future<int> getAmountOfBudgets() async {
    return (await select(budgets).get()).length;
  }

  Future<List<Transaction>> getAllPreviewTransactions() {
    return (select(transactions)
          ..where((tbl) =>
              tbl.methodAdded.equalsValue(MethodAdded.preview) &
              tbl.methodAdded.isNotNull()))
        .get();
  }

  Future moveBudget(String budgetPk, int newPosition, int oldPosition) async {
    List<Budget> budgetsList = await (select(budgets)
          ..orderBy([(b) => OrderingTerm.asc(b.order)]))
        .get();

    await batch((batch) {
      if (newPosition > oldPosition) {
        for (Budget budget in budgetsList) {
          batch.update(
            budgets,
            BudgetsCompanion(
              order: Value(budget.order - 1),
              dateTimeModified: Value(DateTime.now()),
            ),
            where: (b) =>
                b.budgetPk.equals(budget.budgetPk) &
                b.order.isBiggerOrEqualValue(oldPosition) &
                b.order.isSmallerOrEqualValue(newPosition),
          );
        }
      } else {
        for (Budget budget in budgetsList) {
          batch.update(
            budgets,
            BudgetsCompanion(
              order: Value(budget.order + 1),
              dateTimeModified: Value(DateTime.now()),
            ),
            where: (b) =>
                b.budgetPk.equals(budget.budgetPk) &
                b.order.isBiggerOrEqualValue(newPosition) &
                b.order.isSmallerOrEqualValue(oldPosition),
          );
        }
      }
      batch.update(
        budgets,
        BudgetsCompanion(
          order: Value(newPosition),
          dateTimeModified: Value(DateTime.now()),
        ),
        where: (b) => b.budgetPk.equals(budgetPk),
      );
    });
  }

  Future moveObjective(
      String objectivePk, int newPosition, int oldPosition) async {
    List<Objective> objectivesList = await (select(objectives)
          ..orderBy([(b) => OrderingTerm.asc(b.order)]))
        .get();

    await batch((batch) {
      if (newPosition > oldPosition) {
        for (Objective objective in objectivesList) {
          batch.update(
            objectives,
            ObjectivesCompanion(
              order: Value(objective.order - 1),
              dateTimeModified: Value(DateTime.now()),
            ),
            where: (b) =>
                b.objectivePk.equals(objective.objectivePk) &
                b.order.isBiggerOrEqualValue(oldPosition) &
                b.order.isSmallerOrEqualValue(newPosition),
          );
        }
      } else {
        for (Objective objective in objectivesList) {
          batch.update(
            objectives,
            ObjectivesCompanion(
              order: Value(objective.order + 1),
              dateTimeModified: Value(DateTime.now()),
            ),
            where: (b) =>
                b.objectivePk.equals(objective.objectivePk) &
                b.order.isBiggerOrEqualValue(newPosition) &
                b.order.isSmallerOrEqualValue(oldPosition),
          );
        }
      }
      batch.update(
        objectives,
        ObjectivesCompanion(
          order: Value(newPosition),
          dateTimeModified: Value(DateTime.now()),
        ),
        where: (b) => b.objectivePk.equals(objectivePk),
      );
    });
  }

  Future<bool> shiftBudgets(int direction, int pastIndexIncluding) async {
    List<Budget> budgetsList = await (select(budgets)
          ..orderBy([(b) => OrderingTerm.asc(b.order)]))
        .get();
    if (direction == -1 || direction == 1) {
      for (Budget budget in budgetsList) {
        await (update(budgets)
              ..where(
                (b) =>
                    b.order.isBiggerOrEqualValue(pastIndexIncluding) &
                    b.budgetPk.equals(budget.budgetPk),
              ))
            .write(
          BudgetsCompanion(
            order: Value(budget.order + direction),
            dateTimeModified: Value(DateTime.now()),
          ),
        );
      }
    } else {
      return false;
    }
    return true;
  }

  Future<bool> shiftObjectives(int direction, int pastIndexIncluding) async {
    List<Objective> objectivesList = await (select(objectives)
          ..orderBy([(b) => OrderingTerm.asc(b.order)]))
        .get();
    if (direction == -1 || direction == 1) {
      for (Objective objective in objectivesList) {
        await (update(objectives)
              ..where(
                (b) =>
                    b.order.isBiggerOrEqualValue(pastIndexIncluding) &
                    b.objectivePk.equals(objective.objectivePk),
              ))
            .write(
          ObjectivesCompanion(
            order: Value(objective.order + direction),
            dateTimeModified: Value(DateTime.now()),
          ),
        );
      }
    } else {
      return false;
    }
    return true;
  }

  Future<Map<String, TransactionCategory>> getAllCategoriesIndexed() async {
    List<TransactionCategory> allCategories = (await ((select(categories)
          ..orderBy([(w) => OrderingTerm.asc(w.order)]))
        .get()));
    Map<String, TransactionCategory> indexedByPk = {
      for (TransactionCategory category in allCategories)
        category.categoryPk: category,
    };
    return indexedByPk;
  }

  Stream<AllWallets> watchAllWalletsIndexed() {
    return (select(wallets)..orderBy([(w) => OrderingTerm.asc(w.order)]))
        .watch()
        .map((wallets) {
      Map<String, TransactionWallet> indexedByPk = {
        for (TransactionWallet wallet in wallets) wallet.walletPk: wallet,
      };
      return AllWallets(list: wallets, indexedByPk: indexedByPk);
    });
  }

  Stream<List<TransactionWallet>> watchAllWallets(
      {String? searchFor, int? limit, int? offset}) {
    return (select(wallets)
          ..where((w) => (searchFor == null
              ? Constant(true)
              : w.name.collate(Collate.noCase).like("%" + (searchFor) + "%")))
          ..orderBy([(w) => OrderingTerm.asc(w.order)])
          ..limit(limit ?? DEFAULT_LIMIT, offset: offset ?? DEFAULT_OFFSET))
        .watch();
  }

  Stream<List<WalletWithDetails>> watchAllWalletsWithDetails(
      {String? searchFor, HomePageWidgetDisplay? homePageWidgetDisplay}) {
    JoinedSelectStatement<HasResultSet, dynamic> query;
    final totalCount = transactions.transactionPk.count();
    final totalSpent =
        transactions.amount.sum(filter: transactions.paid.equals(true));
    query = (select(wallets)
          ..where((w) => ((homePageWidgetDisplay != null
                  ? w.homePageWidgetDisplay
                      .contains(homePageWidgetDisplay.index.toString())
                  : Constant(true)) &
              (searchFor == null
                  ? Constant(true)
                  : w.name
                      .collate(Collate.noCase)
                      .like("%" + (searchFor) + "%"))))
          ..orderBy([(w) => OrderingTerm.asc(w.order)]))
        .join([
      leftOuterJoin(
          transactions, transactions.walletFk.equalsExp(wallets.walletPk)),
    ])
      ..groupBy([wallets.walletPk])
      ..addColumns([totalCount, totalSpent]);

    return query.watch().map((rows) => rows.map((row) {
          return WalletWithDetails(
            wallet: row.readTable(wallets),
            numberTransactions: row.read(totalCount),
            totalSpent: row.read(totalSpent),
          );
        }).toList());
  }

  Stream<List<ScannerTemplate>> watchAllScannerTemplates(
      {int? limit, int? offset}) {
    return (select(scannerTemplates)
          ..orderBy([(s) => OrderingTerm.asc(s.dateCreated)])
          ..limit(limit ?? DEFAULT_LIMIT, offset: offset ?? DEFAULT_OFFSET))
        .watch();
  }

  Future<List<ScannerTemplate>> getAllScannerTemplates(
      {int? limit, int? offset}) {
    return (select(scannerTemplates)
          ..orderBy([(s) => OrderingTerm.asc(s.dateCreated)])
          ..limit(limit ?? DEFAULT_LIMIT, offset: offset ?? DEFAULT_OFFSET))
        .get();
  }

  Future<List<TransactionWallet>> getAllWallets({int? limit, int? offset}) {
    return (select(wallets)
          ..orderBy([(w) => OrderingTerm.asc(w.order)])
          ..limit(limit ?? DEFAULT_LIMIT, offset: offset ?? DEFAULT_OFFSET))
        .get();
  }

  Future<List<TransactionWallet>> getAllNewWallets(DateTime lastSynced) {
    return (select(wallets)
          ..where((tbl) =>
              tbl.dateTimeModified.isBiggerOrEqualValue(lastSynced) |
              tbl.dateTimeModified.isNull()))
        .get();
  }

  Future<List<Transaction>> getAllNewTransactions(DateTime lastSynced) {
    return (select(transactions)
          ..where((tbl) =>
              tbl.dateTimeModified.isBiggerOrEqualValue(lastSynced) |
              tbl.dateTimeModified.isNull()))
        .get();
  }

  Future<List<TransactionWithCategory>>
      getAllTransactionsWithCategoryWalletBudgetObjectiveSubCategory(
          Expression<bool> Function($TransactionsTable) filter) async {
    final subCategories = alias(categories, 'subCategories');
    final query = (select(transactions)
          ..where(filter)
          ..orderBy([(t) => OrderingTerm.desc(t.dateCreated)]))
        .join([
      innerJoin(
        categories,
        categories.categoryPk.equalsExp(transactions.categoryFk),
      ),
      innerJoin(
        wallets,
        wallets.walletPk.equalsExp(transactions.walletFk),
      ),
      leftOuterJoin(
        budgets,
        budgets.budgetPk.equalsExp(transactions.sharedReferenceBudgetPk),
      ),
      leftOuterJoin(
        objectives,
        objectives.objectivePk.equalsExp(transactions.objectiveFk),
      ),
      leftOuterJoin(subCategories,
          subCategories.categoryPk.equalsExp(transactions.subCategoryFk)),
    ]);

    final rows = await query.get();

    return rows.map((row) {
      return TransactionWithCategory(
        category: row.readTable(categories),
        transaction: row.readTable(transactions),
        wallet: row.readTableOrNull(wallets),
        budget: row.readTableOrNull(budgets),
        objective: row.readTableOrNull(objectives),
        subCategory: row.readTableOrNull(subCategories),
      );
    }).toList();
  }

  Future<List<TransactionCategory>> getAllNewCategories(DateTime lastSynced) {
    return (select(categories)
          ..where((tbl) =>
              tbl.dateTimeModified.isBiggerOrEqualValue(lastSynced) |
              tbl.dateTimeModified.isNull()))
        .get();
  }

  Future<List<CategoryBudgetLimit>> getAllNewCategoryBudgetLimits(
      DateTime lastSynced) {
    return (select(categoryBudgetLimits)
          ..where((tbl) =>
              tbl.dateTimeModified.isBiggerOrEqualValue(lastSynced) |
              tbl.dateTimeModified.isNull()))
        .get();
  }

  Future<List<TransactionAssociatedTitle>> getAllNewAssociatedTitles(
      DateTime lastSynced) {
    return (select(associatedTitles)
          ..where((tbl) =>
              tbl.dateTimeModified.isBiggerOrEqualValue(lastSynced) |
              tbl.dateTimeModified.isNull()))
        .get();
  }

  Future<List<Budget>> getAllNewBudgets(DateTime lastSynced) {
    return (select(budgets)
          ..where((tbl) =>
              tbl.dateTimeModified.isBiggerOrEqualValue(lastSynced) |
              tbl.dateTimeModified.isNull()))
        .get();
  }

  Future<List<Objective>> getAllNewObjectives(DateTime lastSynced) {
    return (select(objectives)
          ..where((tbl) =>
              tbl.dateTimeModified.isBiggerOrEqualValue(lastSynced) |
              tbl.dateTimeModified.isNull()))
        .get();
  }

  Future<List<ScannerTemplate>> getAllNewScannerTemplates(DateTime lastSynced) {
    return (select(scannerTemplates)
          ..where((tbl) =>
              tbl.dateTimeModified.isBiggerOrEqualValue(lastSynced) |
              tbl.dateTimeModified.isNull()))
        .get();
  }

  Future getAmountOfWallets() async {
    return (await select(budgets).get()).length;
  }

  Future moveWallet(String walletPk, int newPosition, int oldPosition) async {
    List<TransactionWallet> walletsList = await (select(wallets)
          ..orderBy([(w) => OrderingTerm.asc(w.order)]))
        .get();
    await batch((batch) {
      if (newPosition > oldPosition) {
        for (TransactionWallet wallet in walletsList) {
          batch.update(
            wallets,
            WalletsCompanion(
              order: Value(wallet.order - 1),
              dateTimeModified: Value(DateTime.now()),
            ),
            where: (w) =>
                w.walletPk.equals(wallet.walletPk) &
                w.order.isBiggerOrEqualValue(oldPosition) &
                w.order.isSmallerOrEqualValue(newPosition),
          );
        }
      } else {
        for (TransactionWallet wallet in walletsList) {
          batch.update(
            wallets,
            WalletsCompanion(
              order: Value(wallet.order + 1),
              dateTimeModified: Value(DateTime.now()),
            ),
            where: (w) =>
                w.walletPk.equals(wallet.walletPk) &
                w.order.isBiggerOrEqualValue(newPosition) &
                w.order.isSmallerOrEqualValue(oldPosition),
          );
        }
      }
      batch.update(
        wallets,
        WalletsCompanion(
          order: Value(newPosition),
          dateTimeModified: Value(DateTime.now()),
        ),
        where: (w) => w.walletPk.equals(walletPk),
      );
    });
  }

  Future<bool> shiftWallets(int direction, int pastIndexIncluding) async {
    List<TransactionWallet> walletsList = await (select(wallets)
          ..orderBy([(b) => OrderingTerm.asc(b.order)]))
        .get();
    if (direction == -1 || direction == 1) {
      for (TransactionWallet wallet in walletsList) {
        await (update(wallets)
              ..where(
                (w) =>
                    w.order.isBiggerOrEqualValue(pastIndexIncluding) &
                    w.walletPk.equals(wallet.walletPk),
              ))
            .write(
          WalletsCompanion(
            order: Value(wallet.order + direction),
            dateTimeModified: Value(DateTime.now()),
          ),
        );
      }
    } else {
      return false;
    }
    return true;
  }

  Future<List<DeleteLog>> getAllNewDeleteLogs(DateTime lastSynced) async {
    return (select(deleteLogs)
          ..where(
              (tbl) => tbl.dateTimeModified.isBiggerOrEqualValue(lastSynced)))
        .get();
  }

  Future<List<DeleteLog>> getAllDeleteLogs() async {
    return select(deleteLogs).get();
  }

  Future<bool> createDeleteLog(DeleteLogType type, String deletedPk) async {
    await into(deleteLogs).insert(
      DeleteLogsCompanion.insert(
        type: type,
        entryPk: deletedPk,
        dateTimeModified: Value(DateTime.now()),
      ),
    );
    // print((await getAllDeleteLogs()).length);
    return true;
  }

  Future<bool> createDeleteLogs(
      DeleteLogType type, List<String> deletedPks) async {
    List<DeleteLogsCompanion> deleteLogsToInsert = [];
    for (String deletePk in deletedPks) {
      deleteLogsToInsert.add(
        DeleteLogsCompanion.insert(
          type: type,
          entryPk: deletePk,
          dateTimeModified: Value(DateTime.now()),
        ),
      );
    }
    await batch((batch) {
      batch.insertAll(deleteLogs, deleteLogsToInsert, mode: InsertMode.replace);
    });
    return true;
  }

  //Overwrite settings entry, it will always have id 0
  Future<int> createOrUpdateSettings(AppSetting setting) {
    return into(appSettings).insertOnConflictUpdate(setting);
  }

  Future<AppSetting> getSettings() {
    return (select(appSettings)..where((s) => s.settingsPk.equals(0)))
        .getSingle();
  }

  //create or update a new wallet
  Future<int> createOrUpdateWallet(TransactionWallet wallet,
      {DateTime? customDateTimeModified, bool insert = false}) {
    wallet = wallet.copyWith(
        dateTimeModified: Value(customDateTimeModified ?? DateTime.now()));
    WalletsCompanion companionToInsert = wallet.toCompanion(true);

    if (insert) {
      // Use auto incremented ID when inserting
      companionToInsert = companionToInsert.copyWith(
        walletPk: Value.absent(),
        homePageWidgetDisplay: Value(defaultWalletHomePageWidgetDisplay),
      );
    }

    return into(wallets)
        .insert((companionToInsert), mode: InsertMode.insertOrReplace);
  }

  //create or update a new objective
  Future<int> createOrUpdateObjective(Objective objective,
      {DateTime? customDateTimeModified, bool insert = false}) async {
    objective = objective.copyWith(
        dateTimeModified: Value(customDateTimeModified ?? DateTime.now()));
    ObjectivesCompanion companionToInsert = objective.toCompanion(true);

    if (insert) {
      // Use auto incremented ID when inserting
      companionToInsert =
          companionToInsert.copyWith(objectivePk: Value.absent());

      // If homepage section disabled and user added an objective, enable homepage section
      if (appStateSettings["showObjectives"] == false &&
          objective.pinned == true) {
        int amountObjectives = (await getAllObjectives()).length;
        if (amountObjectives <= 0) {
          await updateSettings("showObjectives", true,
              updateGlobalState: false, pagesNeedingRefresh: [0]);
        }
      }
    }

    return into(objectives)
        .insert((companionToInsert), mode: InsertMode.insertOrReplace);
  }

  //create or update a new wallet
  Future<int> createOrUpdateScannerTemplate(ScannerTemplate scannerTemplate,
      {bool insert = false}) {
    scannerTemplate =
        scannerTemplate.copyWith(dateTimeModified: Value(DateTime.now()));
    ScannerTemplatesCompanion companionToInsert =
        scannerTemplate.toCompanion(true);

    if (insert) {
      // Use auto incremented ID when inserting
      companionToInsert =
          companionToInsert.copyWith(scannerTemplatePk: Value.absent());
    }

    return into(scannerTemplates)
        .insert((companionToInsert), mode: InsertMode.insertOrReplace);
  }

  Future<int> createOrUpdateCategoryLimit(CategoryBudgetLimit categoryLimit,
      {bool insert = false}) {
    categoryLimit =
        categoryLimit.copyWith(dateTimeModified: Value(DateTime.now()));

    CategoryBudgetLimitsCompanion companionToInsert =
        categoryLimit.toCompanion(true);

    if (insert) {
      // Use auto incremented ID when inserting
      companionToInsert =
          companionToInsert.copyWith(categoryLimitPk: Value.absent());
    }

    return into(categoryBudgetLimits)
        .insert((companionToInsert), mode: InsertMode.insertOrReplace);
  }

  Stream<List<TransactionAssociatedTitle>> watchAllAssociatedTitles(
      {String? searchFor, int? limit, int? offset}) {
    return (select(associatedTitles)
          ..where((t) => (searchFor == null
              ? Constant(true)
              : t.title.collate(Collate.noCase).like("%" + (searchFor) + "%")))
          ..orderBy([(t) => OrderingTerm.desc(t.order)])
        // ..limit(limit ?? DEFAULT_LIMIT, offset: offset ?? DEFAULT_OFFSET)
        )
        .watch();
  }

  Future<List<TransactionAssociatedTitle>> getAllAssociatedTitles(
      {int? limit, int? offset}) {
    return (select(associatedTitles)
          ..orderBy([(t) => OrderingTerm.desc(t.order)])
        // ..limit(limit ?? DEFAULT_LIMIT, offset: offset ?? DEFAULT_OFFSET)
        )
        .get();
  }

  Future<TransactionAssociatedTitle> getRelatingAssociatedTitleWithCategory(
      String searchFor, String categoryFk,
      {int? limit, int? offset}) async {
    return (await (select(associatedTitles)
              ..where((t) =>
                  t.title.collate(Collate.noCase).like("%" + searchFor + "%") &
                  t.categoryFk.equals(categoryFk))
            // ..limit(limit ?? DEFAULT_LIMIT, offset: offset ?? DEFAULT_OFFSET)
            )
            .get())
        .first;
  }

  Future<TransactionAssociatedTitle> getRelatingAssociatedTitle(
      String searchFor,
      {int? limit,
      int? offset}) async {
    return (await (select(associatedTitles)
              ..where((t) =>
                  t.title.collate(Collate.noCase).like("%" + searchFor + "%"))
            // ..limit(limit ?? DEFAULT_LIMIT, offset: offset ?? DEFAULT_OFFSET)
            )
            .get())
        .first;
  }

  Future<TransactionCategory> getRelatingCategory(String searchFor,
      {int? limit, int? offset}) async {
    return (await (select(categories)
              ..where((c) =>
                  onlyShowMainCategoryListing(c) &
                  c.name.collate(Collate.noCase).like("%" + searchFor + "%"))
              ..limit(limit ?? DEFAULT_LIMIT, offset: offset ?? DEFAULT_OFFSET))
            .get())
        .first;
  }

  Stream<List<TransactionAssociatedTitle>> watchAllAssociatedTitlesInCategory(
      String categoryFk,
      {int? limit}) {
    return (select(associatedTitles)
          ..where((t) => t.categoryFk.equals(categoryFk))
          ..orderBy([(t) => OrderingTerm.desc(t.order)])
          ..limit(
            limit ?? DEFAULT_LIMIT,
          ))
        .watch();
  }

  Future<List<TransactionAssociatedTitle>> getAllAssociatedTitlesInCategory(
    String categoryFk,
  ) {
    return (select(associatedTitles)
          ..where((t) => t.categoryFk.equals(categoryFk))
          ..orderBy([(t) => OrderingTerm.asc(t.order)]))
        .get();
  }

  Stream<List<CategoryBudgetLimit>> watchAllCategoryLimitsInBudget(
      String budgetPk) {
    return (select(categoryBudgetLimits)
          ..where((t) => t.budgetFk.equals(budgetPk)))
        .watch();
  }

  Future<bool> toggleAbsolutePercentSpendingCategoryBudgetLimits(
    AllWallets allWallets,
    String budgetPk,
    double budgetSetAmount,
    bool absoluteToPercentage,
  ) async {
    List<CategoryBudgetLimit> limitsInserting = [];
    List<CategoryBudgetLimit> categorySpendingLimits =
        await (select(categoryBudgetLimits)
              ..where((t) => t.budgetFk.equals(budgetPk)))
            .get();
    for (CategoryBudgetLimit categorySpendingLimit in categorySpendingLimits) {
      TransactionCategory category =
          await getCategoryInstance(categorySpendingLimit.categoryFk);
      double convertedAmount;
      if (category.mainCategoryPk == null) {
        // This is a main category
        convertedAmount = categorySpendingLimit.amount;
        if (absoluteToPercentage) {
          convertedAmount = categoryBudgetLimitToPrimaryCurrency(
              allWallets, categorySpendingLimit);
          convertedAmount = convertedAmount / budgetSetAmount * 100;
        } else {
          convertedAmount = convertedAmount / 100 * budgetSetAmount;
          convertedAmount = convertedAmount *
              1 /
              amountRatioToPrimaryCurrencyGivenPk(
                  allWallets, categorySpendingLimit.walletFk);
        }
      } else {
        // This is a subcategory
        CategoryBudgetLimit? categoryLimitMain = categorySpendingLimits
            .where((e) => e.categoryFk == category.mainCategoryPk)
            .toList()
            .firstOrNull;
        double convertedAmountMain = categoryLimitMain?.amount ??
            (absoluteToPercentage ? budgetSetAmount : 100);
        convertedAmount = categorySpendingLimit.amount;
        if (absoluteToPercentage) {
          convertedAmount = categoryBudgetLimitToPrimaryCurrency(
              allWallets, categorySpendingLimit);
          convertedAmount = convertedAmount / convertedAmountMain * 100;
        } else {
          convertedAmount = (convertedAmount / 100) *
              (convertedAmountMain / 100) *
              (budgetSetAmount);
          convertedAmount = convertedAmount *
              1 /
              amountRatioToPrimaryCurrencyGivenPk(
                  allWallets, categorySpendingLimit.walletFk);
        }
      }
      limitsInserting.add(categorySpendingLimit.copyWith(
          amount: convertedAmount, dateTimeModified: Value(DateTime.now())));
      await updateBatchCategoryLimitsOnly(limitsInserting);
    }
    return true;
  }

  Expression<bool> evaluateIfNull(
      Expression<bool> expression, value, evaluationIfValueNull) {
    if (value == null) return Constant(evaluationIfValueNull);
    return expression;
  }

  (Stream<CategoryBudgetLimit?>, Future<CategoryBudgetLimit?>) getCategoryLimit(
      String? budgetPk, String? categoryPk) {
    SimpleSelectStatement<$CategoryBudgetLimitsTable, CategoryBudgetLimit>
        query = (select(categoryBudgetLimits)
          ..where((t) =>
              evaluateIfNull(
                  t.budgetFk.equals(budgetPk ?? "0"), budgetPk, true) &
              evaluateIfNull(
                  t.categoryFk.equals(categoryPk ?? "0"), categoryPk, true)));
    return (query.watchSingleOrNull(), query.getSingleOrNull());
  }

  (Stream<CategoryBudgetLimit>, Future<CategoryBudgetLimit>)
      getCategoryBudgetLimitInstance(String categoryLimitPk) {
    final SimpleSelectStatement<$CategoryBudgetLimitsTable, CategoryBudgetLimit>
        query = (select(categoryBudgetLimits)
          ..where((t) => t.categoryLimitPk.equals(categoryLimitPk)));
    return (query.watchSingle(), query.getSingle());
  }

  Stream<TransactionCategory> watchCategory(String categoryPk) {
    return (select(categories)..where((t) => t.categoryPk.equals(categoryPk)))
        .watchSingle();
  }

  (Stream<TransactionCategory>, Future<TransactionCategory>) getCategory(
      String categoryPk) {
    final SimpleSelectStatement<$CategoriesTable, TransactionCategory> query =
        (select(categories)..where((c) => c.categoryPk.equals(categoryPk)));
    return (query.watchSingle(), query.getSingle());
  }

  (Stream<TransactionAssociatedTitle>, Future<TransactionAssociatedTitle>)
      getAssociatedTitleInstance(String associatedTitlePk) {
    final SimpleSelectStatement<$AssociatedTitlesTable,
        TransactionAssociatedTitle> query = (select(associatedTitles)
      ..where((t) => t.associatedTitlePk.equals(associatedTitlePk)));
    return (query.watchSingle(), query.getSingle());
  }

  (Stream<List<CategoryBudgetLimit>>, Future<List<CategoryBudgetLimit>>)
      getCategoryLimits() {
    final SimpleSelectStatement<$CategoryBudgetLimitsTable, CategoryBudgetLimit>
        query = (select(categoryBudgetLimits));
    return (query.watch(), query.get());
  }

  //create or update a new associatedTitle
  Future<int> createOrUpdateAssociatedTitle(
    TransactionAssociatedTitle associatedTitle, {
    insert = false,
  }) {
    associatedTitle =
        associatedTitle.copyWith(dateTimeModified: Value(DateTime.now()));
    AssociatedTitlesCompanion companionToInsert =
        associatedTitle.toCompanion(true);

    if (insert) {
      // Use auto incremented ID when inserting
      companionToInsert =
          companionToInsert.copyWith(associatedTitlePk: Value.absent());
    }

    return into(associatedTitles)
        .insert((companionToInsert), mode: InsertMode.insertOrReplace);
  }

  Future moveAssociatedTitle(
      String associatedTitlePk, int newPosition, int oldPosition) async {
    List<TransactionAssociatedTitle> associatedTitlesList =
        await (select(associatedTitles)
              ..orderBy([(t) => OrderingTerm.asc(t.order)]))
            .get();
    await batch((batch) {
      if (newPosition > oldPosition) {
        for (TransactionAssociatedTitle associatedTitle
            in associatedTitlesList) {
          batch.update(
            associatedTitles,
            AssociatedTitlesCompanion(
              order: Value(associatedTitle.order - 1),
              dateTimeModified: Value(DateTime.now()),
            ),
            where: (t) =>
                t.associatedTitlePk.equals(associatedTitle.associatedTitlePk) &
                t.order.isBiggerOrEqualValue(oldPosition) &
                t.order.isSmallerOrEqualValue(newPosition),
          );
        }
      } else {
        for (TransactionAssociatedTitle associatedTitle
            in associatedTitlesList) {
          batch.update(
            associatedTitles,
            AssociatedTitlesCompanion(
              order: Value(associatedTitle.order + 1),
              dateTimeModified: Value(DateTime.now()),
            ),
            where: (t) =>
                t.associatedTitlePk.equals(associatedTitle.associatedTitlePk) &
                t.order.isBiggerOrEqualValue(newPosition) &
                t.order.isSmallerOrEqualValue(oldPosition),
          );
        }
      }
      batch.update(
        associatedTitles,
        AssociatedTitlesCompanion(
          order: Value(newPosition),
          dateTimeModified: Value(DateTime.now()),
        ),
        where: (t) => t.associatedTitlePk.equals(associatedTitlePk),
      );
    });
  }

  Future<bool> fixOrderBudgets() async {
    List<Budget> budgetsList = await (select(budgets)
          ..orderBy([(t) => OrderingTerm.asc(t.order)]))
        .get();
    for (int i = 0; i < budgetsList.length; i++) {
      budgetsList[i] = budgetsList[i].copyWith(
        order: i,
        // Don't update the dateTimeModified, opening the page will cause them all to have a new dateTimeModified... when something was actually not modified
        // dateTimeModified: Value(DateTime.now()),
      );
    }
    await batch((batch) {
      batch.insertAll(budgets, budgetsList, mode: InsertMode.replace);
    });
    return true;
  }

  Future<bool> fixOrderObjectives() async {
    List<Objective> objectivesList = await (select(objectives)
          ..orderBy([(t) => OrderingTerm.asc(t.order)]))
        .get();
    for (int i = 0; i < objectivesList.length; i++) {
      objectivesList[i] = objectivesList[i].copyWith(
        order: i,
        // Don't update the dateTimeModified, opening the page will cause them all to have a new dateTimeModified... when something was actually not modified
        // dateTimeModified: Value(DateTime.now()),
      );
    }
    await batch((batch) {
      batch.insertAll(objectives, objectivesList, mode: InsertMode.replace);
    });
    return true;
  }

  Future<bool> fixOrderCategories(
      {String? mainCategoryPkIfSubCategoryOrderFixing}) async {
    List<TransactionCategory> categoriesList = await (select(categories)
          ..where((c) => mainCategoryPkIfSubCategoryOrderFixing == null
              ? onlyShowMainCategoryListing(c)
              : c.mainCategoryPk.equals(mainCategoryPkIfSubCategoryOrderFixing))
          ..orderBy([(t) => OrderingTerm.asc(t.order)]))
        .get();
    for (int i = 0; i < categoriesList.length; i++) {
      categoriesList[i] = categoriesList[i].copyWith(
        order: i,
        // Don't update the dateTimeModified, opening the page will cause them all to have a new dateTimeModified... when something was actually not modified
        // dateTimeModified: Value(DateTime.now()),
      );
    }
    await batch((batch) {
      batch.insertAll(categories, categoriesList, mode: InsertMode.replace);
    });
    return true;
  }

  Future<bool> fixOrderWallets() async {
    List<TransactionWallet> walletsList = await (select(wallets)
          ..orderBy([(t) => OrderingTerm.asc(t.order)]))
        .get();
    for (int i = 0; i < walletsList.length; i++) {
      walletsList[i] = walletsList[i].copyWith(
        order: i,
        // Don't update the dateTimeModified, opening the page will cause them all to have a new dateTimeModified... when something was actually not modified
        // dateTimeModified: Value(DateTime.now()),
      );
    }
    await batch((batch) {
      batch.insertAll(wallets, walletsList, mode: InsertMode.replace);
    });
    return true;
  }

  Future<bool> fixOrderAssociatedTitles() async {
    List<TransactionAssociatedTitle> associatedTitlesList =
        await (select(associatedTitles)
              ..orderBy([(t) => OrderingTerm.asc(t.order)]))
            .get();
    for (int i = 0; i < associatedTitlesList.length; i++) {
      associatedTitlesList[i] = associatedTitlesList[i].copyWith(
        order: i,
        // Don't update the dateTimeModified, opening the page will cause them all to have a new dateTimeModified... when something was actually not modified
        // dateTimeModified: Value(DateTime.now()),
      );
    }
    await batch((batch) {
      batch.insertAll(associatedTitles, associatedTitlesList,
          mode: InsertMode.replace);
    });
    return true;
  }

  Future<bool> shiftAssociatedTitles(
      int direction, int pastIndexIncluding) async {
    List<TransactionAssociatedTitle> associatedTitlesList =
        await (select(associatedTitles)
              ..orderBy([(t) => OrderingTerm.asc(t.order)]))
            .get();
    if (direction == -1 || direction == 1) {
      List<TransactionAssociatedTitle> associatedTitlesNeedUpdating = [];
      for (TransactionAssociatedTitle associatedTitle in associatedTitlesList) {
        if (associatedTitle.order >= pastIndexIncluding)
          associatedTitlesNeedUpdating.add(associatedTitle.copyWith(
            order: associatedTitle.order + direction,
            dateTimeModified: Value(DateTime.now()),
          ));
      }
      await batch((batch) {
        batch.insertAll(associatedTitles, associatedTitlesNeedUpdating,
            mode: InsertMode.replace);
      });
    } else {
      return false;
    }
    return true;
  }

  Future<List<int?>> getTotalCountOfAssociatedTitles() async {
    final totalCount = associatedTitles.associatedTitlePk.count();
    final query = selectOnly(associatedTitles)..addColumns([totalCount]);
    return query.map((row) => row.read(totalCount)).get();
  }

  Future<Transaction> getTransactionFromRowId(int rowId) {
    return (select(transactions)..where((t) => t.rowId.equals(rowId)))
        .getSingle();
  }

  Future<TransactionWallet> getWalletFromRowId(int rowId) {
    return (select(wallets)..where((w) => w.rowId.equals(rowId))).getSingle();
  }

  Future<TransactionCategory> getCategoryFromRowId(int rowId) {
    return (select(categories)..where((c) => c.rowId.equals(rowId)))
        .getSingle();
  }

  // create or update a new transaction
  Future<int?>? createOrUpdateTransaction(
    Transaction transaction, {
    bool insert = false,
    bool updateSharedEntry = true,
    Transaction? originalTransaction,
  }) async {
    if (updateSharedEntry == true && appStateSettings["sharedBudgets"] == false)
      updateSharedEntry = false;
    double maxAmount = 100000000;
    if (transaction.amount >= maxAmount)
      transaction = transaction.copyWith(amount: maxAmount);
    else if (transaction.amount <= -maxAmount)
      transaction = transaction.copyWith(amount: -maxAmount);

    if (transaction.amount == double.infinity ||
        transaction.amount == double.negativeInfinity ||
        transaction.amount.isNaN) {
      return null;
    }

    if (transaction.type == TransactionSpecialType.credit) {
      transaction = transaction.copyWith(
          income: false, amount: transaction.amount.abs() * -1);
    } else if (transaction.type == TransactionSpecialType.debt) {
      transaction =
          transaction.copyWith(income: true, amount: transaction.amount.abs());
    }

    // we are saying we still need this category! - for syncing
    try {
      TransactionCategory categoryInUse =
          await getCategoryInstance(transaction.categoryFk);

      // Somehow a subcategory got selected as the main category!
      // Lets swap them - otherwise the wandering transactions algorithm will delete it!
      if (categoryInUse.mainCategoryPk != null) {
        transaction = transaction.copyWith(
          categoryFk: categoryInUse.mainCategoryPk,
          subCategoryFk: Value(transaction.categoryFk),
        );
        categoryInUse = await getCategoryInstance(transaction.categoryFk);
      }

      await createOrUpdateCategory(
        categoryInUse.copyWith(dateTimeModified: Value(DateTime.now())),
        updateSharedEntry: false,
      );
    } catch (e) {
      throw ("category-no-longer-exists");
    }

    // we are saying we still need this subcategory! - for syncing
    if (transaction.subCategoryFk != null) {
      try {
        TransactionCategory subCategoryInUse =
            await getCategoryInstance(transaction.subCategoryFk!);
        await createOrUpdateCategory(
          subCategoryInUse.copyWith(dateTimeModified: Value(DateTime.now())),
          updateSharedEntry: false,
        );
      } catch (e) {
        print("subcategory no longer exists");
        transaction = transaction.copyWith(subCategoryFk: Value(null));
      }
    }

    // Update the servers entry of the transaction
    if (transaction.paid && updateSharedEntry == true) {
      if (transaction.sharedReferenceBudgetPk != null) {
        Budget budget = await database
            .getBudgetInstance(transaction.sharedReferenceBudgetPk!);
        if (originalTransaction != null) {
          if (originalTransaction.sharedReferenceBudgetPk !=
              transaction.sharedReferenceBudgetPk) {
            await deleteTransaction(transaction.transactionPk);
            return await createOrUpdateTransaction(
              insert: true,
              transaction.copyWith(
                transactionPk: "-1",
                sharedKey: Value(null),
                // transactionOwnerEmail: Value(null),
                // transactionOriginalOwnerEmail: Value(null),
                sharedDateUpdated: Value(null),
                sharedStatus: Value(null),
                // sharedReferenceBudgetPk: Value(null),
              ),
            );
          }
        }

        if (transaction.sharedKey != null && budget.sharedKey != null) {
          sendTransactionSet(transaction, budget);
          transaction =
              transaction.copyWith(sharedStatus: Value(SharedStatus.waiting));
        } else if (transaction.sharedKey == null && budget.sharedKey != null) {
          sendTransactionAdd(transaction, budget);
          transaction =
              transaction.copyWith(sharedStatus: Value(SharedStatus.waiting));
        }
      } else {
        if (transaction.sharedStatus == null &&
            originalTransaction != null &&
            originalTransaction.sharedStatus == null) {
        } else {
          try {
            print("REMOVING SHARED");
            await deleteTransaction(transaction.transactionPk);
          } catch (e) {
            print(e.toString());
          }
          return await createOrUpdateTransaction(
              insert: true,
              transaction.copyWith(
                transactionPk: "-1",
                sharedKey: Value(null),
                transactionOwnerEmail: Value(null),
                transactionOriginalOwnerEmail: Value(null),
                sharedDateUpdated: Value(null),
                sharedStatus: Value(null),
                sharedReferenceBudgetPk: Value(null),
              ),
              updateSharedEntry: false);
        }
      }
    }

    transaction = transaction.copyWith(dateTimeModified: Value(DateTime.now()));
    TransactionsCompanion companionToInsert = transaction.toCompanion(true);

    if (insert) {
      // Use auto incremented ID when inserting
      companionToInsert =
          companionToInsert.copyWith(transactionPk: Value.absent());
    }

    if (insert == false && transaction.methodAdded == MethodAdded.preview) {
      companionToInsert = companionToInsert.copyWith(methodAdded: Value(null));
    }

    return into(transactions)
        .insert((companionToInsert), mode: InsertMode.insertOrReplace);
  }

  // ************************************************************
  // The following functions should only be used for data sync
  // Unless another use case makes sense
  // These are also not logged into the Delete log!
  // ************************************************************

  Future<bool> processSyncLogs(List<SyncLog> syncLogs) async {
    // We want InsertMode.insertOrReplace because
    // if null values are inserted we want to overwrite it with a null
    // For example when a transactions subCategoryPk is set to null
    // We need to set it to null, nt keep the default when syncing!

    syncLogs.sort(
        (a, b) => a.transactionDateTime!.compareTo(b.transactionDateTime!));

    await batch((batch) {
      for (SyncLog syncLog in syncLogs) {
        if (syncLog.deleteLogType != null) {
          print("Sync Log: Deleting " +
              syncLog.deleteLogType.toString() +
              " " +
              syncLog.pk.toString());
        } else if (syncLog.updateLogType != null) {
          String name = "";
          try {
            name = syncLog.itemToUpdate?.title;
          } catch (e) {}
          try {
            name = syncLog.itemToUpdate?.name;
          } catch (e) {}
          print(
            "Sync Log: Creating " +
                syncLog.updateLogType.toString() +
                " " +
                name,
          );
        }

        if (syncLog.deleteLogType == DeleteLogType.TransactionWallet) {
          batch.deleteWhere(
            wallets,
            (tbl) =>
                tbl.walletPk.equals(syncLog.pk) &
                tbl.dateTimeModified.isSmallerThanValue(
                  syncLog.transactionDateTime ?? DateTime.now(),
                ),
          );
        } else if (syncLog.deleteLogType == DeleteLogType.TransactionCategory) {
          batch.deleteWhere(
            categories,
            (tbl) =>
                tbl.categoryPk.equals(syncLog.pk) &
                tbl.dateTimeModified.isSmallerThanValue(
                  syncLog.transactionDateTime ?? DateTime.now(),
                ),
          );
        } else if (syncLog.deleteLogType == DeleteLogType.Budget) {
          batch.deleteWhere(
            budgets,
            (tbl) =>
                tbl.budgetPk.equals(syncLog.pk) &
                tbl.dateTimeModified.isSmallerThanValue(
                  syncLog.transactionDateTime ?? DateTime.now(),
                ),
          );
        } else if (syncLog.deleteLogType == DeleteLogType.CategoryBudgetLimit) {
          batch.deleteWhere(
            categoryBudgetLimits,
            (tbl) =>
                tbl.categoryLimitPk.equals(syncLog.pk) &
                tbl.dateTimeModified.isSmallerThanValue(
                  syncLog.transactionDateTime ?? DateTime.now(),
                ),
          );
        } else if (syncLog.deleteLogType == DeleteLogType.Transaction) {
          batch.deleteWhere(
            transactions,
            (tbl) =>
                tbl.transactionPk.equals(syncLog.pk) &
                tbl.dateTimeModified.isSmallerThanValue(
                  syncLog.transactionDateTime ?? DateTime.now(),
                ),
          );
        } else if (syncLog.deleteLogType ==
            DeleteLogType.TransactionAssociatedTitle) {
          batch.deleteWhere(
            associatedTitles,
            (tbl) =>
                tbl.associatedTitlePk.equals(syncLog.pk) &
                tbl.dateTimeModified.isSmallerThanValue(
                  syncLog.transactionDateTime ?? DateTime.now(),
                ),
          );
        } else if (syncLog.deleteLogType == DeleteLogType.ScannerTemplate) {
          batch.deleteWhere(scannerTemplates,
              (tbl) => tbl.scannerTemplatePk.equals(syncLog.pk));
        } else if (syncLog.deleteLogType == DeleteLogType.Objective) {
          batch.deleteWhere(
            objectives,
            (tbl) =>
                tbl.objectivePk.equals(syncLog.pk) &
                tbl.dateTimeModified.isSmallerThanValue(
                  syncLog.transactionDateTime ?? DateTime.now(),
                ),
          );
        } else if (syncLog.updateLogType == UpdateLogType.TransactionWallet) {
          batch.update(
            wallets,
            syncLog.itemToUpdate,
            where: (tbl) =>
                tbl.walletPk.equals(syncLog.pk) &
                tbl.dateTimeModified.isSmallerThanValue(
                  syncLog.transactionDateTime ?? DateTime.now(),
                ),
          );
          batch.insert(wallets, syncLog.itemToUpdate,
              mode: InsertMode.insertOrReplace);
        } else if (syncLog.updateLogType == UpdateLogType.TransactionCategory) {
          batch.update(
            categories,
            syncLog.itemToUpdate,
            where: (tbl) =>
                tbl.categoryPk.equals(syncLog.pk) &
                tbl.dateTimeModified.isSmallerThanValue(
                  syncLog.transactionDateTime ?? DateTime.now(),
                ),
          );
          batch.insert(categories, syncLog.itemToUpdate,
              mode: InsertMode.insertOrReplace);
        } else if (syncLog.updateLogType == UpdateLogType.Budget) {
          batch.update(
            budgets,
            syncLog.itemToUpdate,
            where: (tbl) =>
                tbl.budgetPk.equals(syncLog.pk) &
                tbl.dateTimeModified.isSmallerThanValue(
                  syncLog.transactionDateTime ?? DateTime.now(),
                ),
          );
          batch.insert(budgets, syncLog.itemToUpdate,
              mode: InsertMode.insertOrReplace);
        } else if (syncLog.updateLogType == UpdateLogType.CategoryBudgetLimit) {
          batch.update(
            categoryBudgetLimits,
            syncLog.itemToUpdate,
            where: (tbl) =>
                tbl.categoryLimitPk.equals(syncLog.pk) &
                tbl.dateTimeModified.isSmallerThanValue(
                  syncLog.transactionDateTime ?? DateTime.now(),
                ),
          );
          batch.insert(categoryBudgetLimits, syncLog.itemToUpdate,
              mode: InsertMode.insertOrReplace);
        } else if (syncLog.updateLogType == UpdateLogType.Transaction) {
          batch.update(
            transactions,
            syncLog.itemToUpdate,
            where: (tbl) =>
                tbl.transactionPk.equals(syncLog.pk) &
                tbl.dateTimeModified.isSmallerThanValue(
                  syncLog.transactionDateTime ?? DateTime.now(),
                ),
          );
          batch.insert(transactions, syncLog.itemToUpdate,
              mode: InsertMode.insertOrReplace);
        } else if (syncLog.updateLogType ==
            UpdateLogType.TransactionAssociatedTitle) {
          batch.update(
            associatedTitles,
            syncLog.itemToUpdate,
            where: (tbl) =>
                tbl.associatedTitlePk.equals(syncLog.pk) &
                tbl.dateTimeModified.isSmallerThanValue(
                  syncLog.transactionDateTime ?? DateTime.now(),
                ),
          );
          batch.insert(associatedTitles, syncLog.itemToUpdate,
              mode: InsertMode.insertOrReplace);
        } else if (syncLog.updateLogType == UpdateLogType.ScannerTemplate) {
          batch.update(
            scannerTemplates,
            syncLog.itemToUpdate,
            where: (tbl) =>
                tbl.scannerTemplatePk.equals(syncLog.pk) &
                tbl.dateTimeModified.isSmallerThanValue(
                  syncLog.transactionDateTime ?? DateTime.now(),
                ),
          );
          batch.insert(scannerTemplates, syncLog.itemToUpdate,
              mode: InsertMode.insertOrReplace);
        } else if (syncLog.updateLogType == UpdateLogType.Objective) {
          batch.update(
            objectives,
            syncLog.itemToUpdate,
            where: (tbl) =>
                tbl.objectivePk.equals(syncLog.pk) &
                tbl.dateTimeModified.isSmallerThanValue(
                  syncLog.transactionDateTime ?? DateTime.now(),
                ),
          );
          batch.insert(objectives, syncLog.itemToUpdate,
              mode: InsertMode.insertOrReplace);
        }
      }
    });
    return true;
  }

  // This doesn't handle shared transactions!
  // updateShared is always false
  // This cannot create new entries, we need a companion for that! (use the function below!)
  // This is good for a migration!
  Future<bool> updateBatchTransactionsOnly(
      List<Transaction> transactionsInserting) async {
    await batch((batch) {
      batch.insertAll(transactions, transactionsInserting,
          mode: InsertMode.insertOrReplace);
    });
    return true;
  }

  Future<bool> createBatchTransactionsOnly(
      List<TransactionsCompanion> transactionsInserting) async {
    await batch((batch) {
      batch.insertAll(transactions, transactionsInserting,
          mode: InsertMode.insert);
    });
    return true;
  }

  Future<bool> createBatchAssociatedTitlesOnly(
      List<AssociatedTitlesCompanion> titlesInserting) async {
    await batch((batch) {
      batch.insertAll(associatedTitles, titlesInserting,
          mode: InsertMode.insert);
    });
    return true;
  }

  Future<bool> updateBatchWalletsOnly(
      List<TransactionWallet> walletsInserting) async {
    await batch((batch) {
      batch.insertAll(wallets, walletsInserting,
          mode: InsertMode.insertOrReplace);
    });
    return true;
  }

  Future<bool> updateBatchCategoriesOnly(
      List<TransactionCategory> categoriesInserting) async {
    await batch((batch) {
      batch.insertAll(categories, categoriesInserting,
          mode: InsertMode.insertOrReplace);
    });
    return true;
  }

  // This doesn't handle order of budgets!
  Future<bool> updateBatchBudgetsOnly(List<Budget> budgetsInserting) async {
    await batch((batch) {
      batch.insertAll(budgets, budgetsInserting,
          mode: InsertMode.insertOrReplace);
    });
    return true;
  }

  Future<bool> updateBatchCategoryLimitsOnly(
      List<CategoryBudgetLimit> limitsInserting) async {
    await batch((batch) {
      batch.insertAll(categoryBudgetLimits, limitsInserting,
          mode: InsertMode.insertOrReplace);
    });
    return true;
  }

  Future<bool> updateBatchObjectivesOnly(
      List<Objective> objectivesInserting) async {
    await batch((batch) {
      batch.insertAll(objectives, objectivesInserting,
          mode: InsertMode.insertOrReplace);
    });
    return true;
  }

  // Future<bool> createOrUpdateBatchScannerTemplatesOnly(
  //     List<ScannerTemplate> templatesInserting) async {
  //   await batch((batch) {
  //     batch.insertAll(scannerTemplates, templatesInserting,
  //         mode: InsertMode.insertOrReplace);
  //   });
  //   return true;
  // }

  // This doesn't handle order of titles!
  Future<bool> updateBatchAssociatedTitlesOnly(
      List<TransactionAssociatedTitle> associatedTitlesInserting) async {
    await batch((batch) {
      batch.insertAll(associatedTitles, associatedTitlesInserting,
          mode: InsertMode.insertOrReplace);
    });
    return true;
  }

  // Future<int> deleteBatchWalletsGivenPks(List<int> walletPks) async {
  //   return (delete(wallets)..where((tbl) => tbl.walletPk.isIn(walletPks))).go();
  // }

  // Future<bool> deleteBatchWallets(
  //     List<TransactionWallet> walletsDeleting) async {
  //   await batch((batch) {
  //     for (TransactionWallet wallet in walletsDeleting)
  //       batch.delete(wallets, wallet);
  //   });
  //   return true;
  // }

  // Future<int> deleteBatchCategoriesGivenPks(List<int> categoryPks) async {
  //   return (delete(categories)
  //         ..where((tbl) => tbl.categoryPk.isIn(categoryPks)))
  //       .go();
  // }

  // Future<bool> deleteBatchCategories(
  //     List<TransactionCategory> categoriesDeleting) async {
  //   await batch((batch) {
  //     for (TransactionCategory category in categoriesDeleting)
  //       batch.delete(categories, category);
  //   });
  //   return true;
  // }

  // Future<int> deleteBatchBudgetsGivenPks(List<int> budgetPks) async {
  //   return (delete(budgets)..where((tbl) => tbl.budgetPk.isIn(budgetPks))).go();
  // }

  // // This doesn't handle shared budgets!
  // Future<bool> deleteBatchBudgets(List<Budget> budgetsDeleting) async {
  //   await batch((batch) {
  //     for (Budget budget in budgetsDeleting) batch.delete(budgets, budget);
  //   });
  //   return true;
  // }

  // Future<int> deleteBatchCategoryBudgetLimitsGivenPks(
  //     List<int> categoryLimitPks) async {
  //   return (delete(categoryBudgetLimits)
  //         ..where((tbl) => tbl.categoryLimitPk.isIn(categoryLimitPks)))
  //       .go();
  // }

  // Future<bool> deleteBatchCategoryBudgetLimit(
  //     List<CategoryBudgetLimit> categoryBudgetLimitDeleting) async {
  //   await batch((batch) {
  //     for (CategoryBudgetLimit categoryBudgetLimit
  //         in categoryBudgetLimitDeleting)
  //       batch.delete(categoryBudgetLimits, categoryBudgetLimit);
  //   });
  //   return true;
  // }

  // Future<int> deleteBatchAssociatedTitlesGivenTransactionPks(
  //     List<int> associatedTitlePks) async {
  //   return (delete(associatedTitles)
  //         ..where((tbl) => tbl.associatedTitlePk.isIn(associatedTitlePks)))
  //       .go();
  // }

  // // This doesn't handle order of titles!
  // Future<bool> deleteBatchAssociatedTitles(
  //     List<TransactionAssociatedTitle> associatedTitlesDeleting) async {
  //   await batch((batch) {
  //     for (TransactionAssociatedTitle associatedTitle
  //         in associatedTitlesDeleting)
  //       batch.delete(associatedTitles, associatedTitle);
  //   });
  //   return true;
  // }

  // Future<int> deleteBatchTransactionsGivenPks(List<int> transactionPks) async {
  //   return (delete(transactions)
  //         ..where((tbl) => tbl.transactionPk.isIn(transactionPks)))
  //       .go();
  // }

  // // This doesn't handle shared transactions!
  // // updateShared is always false
  // Future<bool> deleteBatchTransactions(
  //     List<Transaction> transactionsDeleting) async {
  //   await batch((batch) {
  //     for (Transaction transaction in transactionsDeleting)
  //       batch.delete(transactions, transaction);
  //   });
  //   return true;
  // }

  // Future<int> deleteBatchScannerTemplatesGivenPks(
  //     List<int> scannerTemplatePks) async {
  //   return (delete(scannerTemplates)
  //         ..where((tbl) => tbl.scannerTemplatePk.isIn(scannerTemplatePks)))
  //       .go();
  // }

  // Future<bool> deleteBatchScannerTemplates(
  //     List<ScannerTemplate> scannerTemplatesDeleting) async {
  //   await batch((batch) {
  //     for (ScannerTemplate scannerTemplate in scannerTemplatesDeleting)
  //       batch.delete(scannerTemplates, scannerTemplate);
  //   });
  //   return true;
  // }

  // ************************************************************
  // ************************************************************

  // create or update a category
  Future<int> createOrUpdateCategory(
    TransactionCategory category, {
    bool updateSharedEntry = true,
    DateTime? customDateTimeModified,
    bool insert = false,
  }) async {
    if (updateSharedEntry == true && appStateSettings["sharedBudgets"] == false)
      updateSharedEntry = false;

    category = category.copyWith(
        dateTimeModified: Value(customDateTimeModified ?? DateTime.now()));
    CategoriesCompanion companionToInsert = category.toCompanion(true);

    if (insert) {
      // Use auto incremented ID when inserting
      companionToInsert =
          companionToInsert.copyWith(categoryPk: Value.absent());
    }

    // We need to ensure the value is set back to null, so insert/replace
    int result = await into(categories)
        .insert((companionToInsert), mode: InsertMode.insertOrReplace);

    if (updateSharedEntry)
      updateTransactionOnServerAfterChangingCategoryInformation(category);
    return result;
  }

  Future<int> createOrUpdateFromSharedBudget(Budget budget,
      {insert = false}) async {
    if (budget.sharedKey != null) {
      Budget sharedBudget;

      try {
        // entry exists, update it
        List<Budget> sharedBudgets = await (select(budgets)
              ..where((t) => t.sharedKey.equals(budget.sharedKey ?? "")))
            .get();
        if (sharedBudgets.isEmpty) throw ("Need to make a new entry");
        sharedBudget = sharedBudgets.first;
        sharedBudget = budget.copyWith(
            budgetPk: sharedBudget.budgetPk,
            order: sharedBudget.order,
            pinned: sharedBudget.pinned);
        return into(budgets).insertOnConflictUpdate(
            sharedBudget.copyWith(dateTimeModified: Value(DateTime.now())));
      } catch (e) {
        int numberOfBudgets = (await database.getAmountOfBudgets());
        // new entry is needed
        sharedBudget = budget.copyWith(
            dateTimeModified: Value(DateTime.now()), order: numberOfBudgets);
        BudgetsCompanion companionToInsert = sharedBudget.toCompanion(true);
        if (insert) {
          // Use auto incremented ID when inserting
          companionToInsert =
              companionToInsert.copyWith(budgetPk: Value.absent());
        }
        return into(budgets).insert((companionToInsert));
      }
    } else {
      return 0;
    }
  }

  Future<Budget> getSharedBudget(String sharedKey) async {
    return (await (select(budgets)..where((t) => t.sharedKey.equals(sharedKey)))
            .get())
        .first;
  }

  Future<List<Transaction>> getAllTransactionsFromCategory(String categoryPk) {
    return (select(transactions)
          ..where((tbl) {
            return tbl.categoryFk.equals(categoryPk);
          })
          ..orderBy([(t) => OrderingTerm.desc(t.dateCreated)]))
        .get();
  }

  Future<List<Transaction>> getAllTransactionsFromSubCategory(
      String categoryPk) {
    return (select(transactions)
          ..where((tbl) {
            return tbl.subCategoryFk.equals(categoryPk);
          })
          ..orderBy([(t) => OrderingTerm.desc(t.dateCreated)]))
        .get();
  }

  Future<List<Transaction>> getAllTransactionsFromWallet(String walletPk) {
    return (select(transactions)
          ..where((tbl) {
            return tbl.walletFk.equals(walletPk) & tbl.paid.equals(true);
          })
          ..orderBy([(t) => OrderingTerm.desc(t.dateCreated)]))
        .get();
  }

  Future<List<Transaction>> getAllTransactionsBelongingToSharedBudget(
      String budgetPk) {
    return (select(transactions)
          ..where((tbl) {
            return tbl.sharedReferenceBudgetPk.equals(budgetPk);
            // & tbl.paid.equals(true);
          })
          ..orderBy([(t) => OrderingTerm.desc(t.dateCreated)]))
        .get();
  }

  Future<List<Transaction>> getAllTransactionsBelongingToExcludedBudget(
      String budgetPk) {
    return (select(transactions)
          ..where((tbl) {
            return tbl.budgetFksExclude.contains(budgetPk);
          }))
        .get();
  }

  Future<List<Transaction>> getAllTransactionsBelongingToObjective(
      String objectivePk) {
    return (select(transactions)
          ..where((tbl) {
            return tbl.objectiveFk.equals(objectivePk) & tbl.paid.equals(true);
          })
          ..orderBy([(t) => OrderingTerm.desc(t.dateCreated)]))
        .get();
  }

  Future<int> createOrUpdateFromSharedTransaction(Transaction transaction,
      {bool insert = false}) async {
    if (transaction.sharedKey != null) {
      Transaction sharedTransaction;
      try {
        // entry exists, update it
        List<Transaction> sharedTransactions = await (select(transactions)
              ..where((t) =>
                  t.sharedKey.equals(transaction.sharedKey ?? "") |
                  t.sharedOldKey.equals(transaction.sharedKey ?? "")))
            .get();
        if (sharedTransactions.isEmpty) throw ("Need to make a new entry");
        sharedTransaction = sharedTransactions[0];
        sharedTransaction = transaction.copyWith(
            transactionPk: sharedTransaction.transactionPk);
        return into(transactions).insertOnConflictUpdate(sharedTransaction
            .copyWith(dateTimeModified: Value(DateTime.now())));
      } catch (e) {
        print(e.toString());
        // new entry is needed
        transaction =
            transaction.copyWith(dateTimeModified: Value(DateTime.now()));
        TransactionsCompanion companionToInsert = transaction.toCompanion(true);
        if (insert) {
          // Use auto incremented ID when inserting
          companionToInsert =
              companionToInsert.copyWith(transactionPk: Value.absent());
        }
        return into(transactions).insert((companionToInsert));
      }
    } else {
      return 0;
    }
  }

  Future<int> deleteFromSharedTransaction(String sharedTransactionKey) async {
    Transaction transactionToDelete = (await (select(transactions)
              ..where((t) => t.sharedKey.equals(sharedTransactionKey)))
            .get())
        .first;
    await createDeleteLog(
        DeleteLogType.Transaction, transactionToDelete.transactionPk);
    return (delete(transactions)
          ..where(
              (t) => t.transactionPk.equals(transactionToDelete.transactionPk)))
        .go();
  }

  Future<List<Transaction>> get allTransactions => select(transactions).get();

  // create or update a label
  // Future<int> createOrUpdateLabel(TransactionLabel label) {
  //   return into(labels).insertOnConflictUpdate(
  //       label.copyWith(dateTimeModified: Value(DateTime.now())));
  // }

  // create or update a budget

  Budget limitBudgetPeriod(Budget budget) {
    int maxTimePeriodYears = 10;
    int maxTimePeriodMonths = 100;
    int maxTimePeriodWeeks = 500;
    int maxTimePeriodDays = 1000;
    if (budget.reoccurrence == BudgetReoccurence.yearly &&
        budget.periodLength >= maxTimePeriodYears)
      budget = budget.copyWith(periodLength: maxTimePeriodYears);
    else if (budget.reoccurrence == BudgetReoccurence.monthly &&
        budget.periodLength >= maxTimePeriodMonths)
      budget = budget.copyWith(periodLength: maxTimePeriodMonths);
    else if (budget.reoccurrence == BudgetReoccurence.weekly &&
        budget.periodLength >= maxTimePeriodWeeks)
      budget = budget.copyWith(periodLength: maxTimePeriodWeeks);
    else if (budget.reoccurrence == BudgetReoccurence.daily &&
        budget.periodLength >= maxTimePeriodDays)
      budget = budget.copyWith(periodLength: maxTimePeriodDays);

    if (budget.periodLength <= 0) budget = budget.copyWith(periodLength: 1);

    budget = budget.copyWith(
      startDate: DateTime(
          budget.startDate.year, budget.startDate.month, budget.startDate.day),
    );
    return budget;
  }

  Future<int> createOrUpdateBudget(Budget budget,
      {bool updateSharedEntry = true, bool insert = false}) async {
    budget = limitBudgetPeriod(budget);

    double maxAmount = 100000000;
    if (budget.amount >= maxAmount) budget = budget.copyWith(amount: maxAmount);

    if (updateSharedEntry == true && appStateSettings["sharedBudgets"] == false)
      updateSharedEntry = false;

    print(budget);

    if (budget.sharedKey != null && updateSharedEntry == true) {
      FirebaseFirestore? db = await firebaseGetDBInstance();
      if (db == null) {
        return -1;
      }
      DocumentReference collectionRef =
          db.collection('budgets').doc(budget.sharedKey);
      collectionRef.update({
        "name": budget.name,
        "amount": budget.amount,
        "colour": budget.colour,
        "startDate": budget.startDate,
        "endDate": budget.endDate,
        "periodLength": budget.periodLength,
        "reoccurrence": enumRecurrence[budget.reoccurrence],
      });
    }

    budget = budget.copyWith(dateTimeModified: Value(DateTime.now()));
    BudgetsCompanion companionToInsert = budget.toCompanion(true);

    if (insert) {
      // Use auto incremented ID when inserting
      companionToInsert = companionToInsert.copyWith(budgetPk: Value.absent());

      // If homepage section disabled and user added a budget, enable homepage section
      if (appStateSettings["showPinnedBudgets"] == false &&
          budget.pinned == true) {
        int amountBudgets = (await getAllBudgets()).length;
        if (amountBudgets <= 0) {
          await updateSettings("showPinnedBudgets", true,
              updateGlobalState: false, pagesNeedingRefresh: [0]);
        }
      }
    }

    return into(budgets)
        .insert((companionToInsert), mode: InsertMode.insertOrReplace);
  }

  // get category given key
  Future<TransactionCategory> getCategoryInstance(String categoryPk) {
    return (select(categories)..where((c) => c.categoryPk.equals(categoryPk)))
        .getSingle();
  }

  Future<TransactionCategory?> getCategoryInstanceOrNull(String categoryPk) {
    return (select(categories)..where((c) => c.categoryPk.equals(categoryPk)))
        .getSingleOrNull();
  }

  // get budget given key
  Future<Budget> getBudgetInstance(String budgetPk) {
    return (select(budgets)..where((t) => t.budgetPk.equals(budgetPk)))
        .getSingle();
  }

  Future<Objective> getObjectiveInstance(String objectivePk) {
    return (select(objectives)..where((t) => t.objectivePk.equals(objectivePk)))
        .getSingle();
  }

  // get category given name
  Future<TransactionCategory> getCategoryInstanceGivenName(String name) async {
    return (await (select(categories)
              ..where(
                  (c) => onlyShowMainCategoryListing(c) & c.name.equals(name)))
            .get())
        .first;
  }

  Future<TransactionCategory> getCategoryInstanceGivenNameTrim(
      String name) async {
    return (await (select(categories)
              ..where((c) =>
                  onlyShowMainCategoryListing(c) &
                  c.name.lower().trim().equals(name.toLowerCase().trim())))
            .get())
        .first;
  }

  Stream<List<TransactionCategory>> watchAllCategories({
    String? searchFor,
    int? limit,
    int? offset,
    List<String>? mainCategoryPks,
    bool? selectedIncome,
  }) {
    return (select(categories)
          ..where((c) => ((mainCategoryPks == null
                  ? onlyShowMainCategoryListing(c)
                  : c.mainCategoryPk.isIn(mainCategoryPks)) &
              (selectedIncome == true
                  ? c.income.equals(true)
                  : selectedIncome == false
                      ? c.income.equals(false)
                      : Constant(true)) &
              (searchFor == null
                  ? Constant(true)
                  : c.name
                      .collate(Collate.noCase)
                      .like("%" + (searchFor) + "%"))))
          ..orderBy([
            (c) => OrderingTerm.asc(c.mainCategoryPk),
            (c) => OrderingTerm.asc(c.order),
          ])
          ..limit(limit ?? DEFAULT_LIMIT, offset: offset ?? DEFAULT_OFFSET))
        .watch();
  }

  Stream<List<CategoryWithDetails>> watchAllMainCategoriesWithDetails({
    String? searchFor,
  }) {
    JoinedSelectStatement<HasResultSet, dynamic> query;
    final totalCount = transactions.transactionPk.count();
    query = (select(categories)
          ..where((c) => (onlyShowMainCategoryListing(c) &
              (searchFor == null
                  ? Constant(true)
                  : c.name
                      .collate(Collate.noCase)
                      .like("%" + (searchFor) + "%"))))
          ..orderBy([
            (c) => OrderingTerm.asc(c.order),
          ]))
        .join([
      leftOuterJoin(transactions,
          transactions.categoryFk.equalsExp(categories.categoryPk)),
    ])
      ..groupBy([categories.categoryPk])
      ..addColumns([totalCount]);

    return query.watch().map((rows) => rows.map((row) {
          return CategoryWithDetails(
            category: row.readTable(categories),
            numberTransactions: row.read(totalCount),
          );
        }).toList());
  }

  Stream<Map<String, TransactionCategory>> watchAllCategoriesIndexed() {
    return (select(categories)..orderBy([(w) => OrderingTerm.asc(w.order)]))
        .watch()
        .map((categories) {
      Map<String, TransactionCategory> indexedByPk = {
        for (TransactionCategory category in categories)
          category.categoryPk: category,
      };
      return indexedByPk;
    });
  }

  Stream<Map<String, List<TransactionCategory>>>
      watchAllSubCategoriesIndexedByMainCategoryPk() {
    return (select(categories)..orderBy([(w) => OrderingTerm.asc(w.order)]))
        .watch()
        .map((categories) {
      Map<String, List<TransactionCategory>> indexedByPk = {
        for (TransactionCategory category in categories)
          category.categoryPk: categories
              .where((c) => c.mainCategoryPk == category.categoryPk)
              .toList(),
      };
      return indexedByPk;
    });
  }

  Stream<List<TransactionCategory>> watchAllSubCategoriesOfMainCategory(
      String mainCategoryPk) {
    return (select(categories)
          ..where((c) => (c.mainCategoryPk.equals(mainCategoryPk)))
          ..orderBy([(c) => OrderingTerm.asc(c.order)]))
        .watch();
  }

  Future<List<TransactionCategory>> getAllSubCategoriesOfMainCategory(
      String mainCategoryPk) {
    return (select(categories)
          ..where((c) => (c.mainCategoryPk.equals(mainCategoryPk)))
          ..orderBy([(c) => OrderingTerm.asc(c.order)]))
        .get();
  }

  Stream<List<Objective>> watchAllObjectives(
      {String? searchFor, int? limit, int? offset}) {
    return (select(objectives)
          ..where((i) => (searchFor == null
              ? Constant(true)
              : i.name.collate(Collate.noCase).like("%" + (searchFor) + "%")))
          ..orderBy([(i) => OrderingTerm.asc(i.order)]))
        .watch();
  }

  Stream<Map<String, TransactionCategory>> watchAllCategoriesMapped(
      {int? limit, int? offset}) {
    return (select(categories)
          ..where((c) => onlyShowMainCategoryListing(c))
          ..limit(limit ?? DEFAULT_LIMIT, offset: offset ?? DEFAULT_OFFSET))
        .watch()
        .map((categoryList) => {
              for (TransactionCategory category in categoryList)
                category.categoryPk: category
            });
  }

  Future<List<TransactionCategory>> getAllCategories(
      {int? limit,
      int? offset,
      List<String>? categoryFks,
      bool? allCategories,
      bool includeSubCategories = false}) {
    return (select(categories)
          ..where((c) => ((includeSubCategories == false
                  ? onlyShowMainCategoryListing(c)
                  : Constant(true)) &
              (allCategories != false
                  ? Constant(true)
                  : c.categoryPk.isIn(categoryFks ?? []))))
          ..orderBy([(c) => OrderingTerm.asc(c.order)])
          ..limit(limit ?? DEFAULT_LIMIT, offset: offset ?? DEFAULT_OFFSET))
        .get();
  }

  Future<List<String>> getAllCategoryPks(
      {int? limit,
      int? offset,
      List<String>? categoryFks,
      bool? allCategories}) {
    return (select(categories)
          ..where((c) => onlyShowMainCategoryListing(categories))
          ..orderBy([(c) => OrderingTerm.asc(c.order)])
          ..limit(limit ?? DEFAULT_LIMIT, offset: offset ?? DEFAULT_OFFSET))
        .get()
        .then(
            (result) => result.map((category) => category.categoryPk).toList());
  }

  Future<List<Budget>> getAllBudgets({bool? sharedBudgetsOnly}) {
    return (select(budgets)
          ..where((b) => ((sharedBudgetsOnly == null
              ? Constant(true)
              : sharedBudgetsOnly == true
                  ? b.sharedKey.isNotNull()
                  : b.sharedKey.isNull())))
          ..orderBy([(c) => OrderingTerm.asc(c.order)]))
        .get();
  }

  Future<List<CategoryBudgetLimit>> getAllCategorySpendingLimits() {
    return (select(categoryBudgetLimits)).get();
  }

  Future<List<Objective>> getAllObjectives() {
    return (select(objectives)..orderBy([(c) => OrderingTerm.asc(c.order)]))
        .get();
  }

  Stream<List<Budget>> watchAllAddableBudgets() {
    return (select(budgets)
          ..where((b) => (b.sharedKey.isNotNull() |
              (b.addedTransactionsOnly.equals(true) & b.sharedKey.isNull())))
          ..orderBy([(c) => OrderingTerm.asc(c.order)]))
        .watch();
  }

  Stream<List<Budget>> watchAllNonAddableBudgets() {
    return (select(budgets)
          ..where((b) => (b.addedTransactionsOnly.equals(false)))
          ..orderBy([(c) => OrderingTerm.asc(c.order)]))
        .watch();
  }

  Future<List<String>> getAllMembersOfBudgets() async {
    List<Budget> sharedBudgets = await getAllBudgets(sharedBudgetsOnly: true);
    Set<String> members = {};
    for (Budget budget in sharedBudgets) {
      for (String member in budget.sharedAllMembersEver ?? [])
        members.add(member);
    }
    return members.toList();
  }

  Future<List<Budget>> getAllBudgetsAddedTransactionsOnly() {
    return (select(budgets)
          ..where((b) =>
              (b.addedTransactionsOnly.equals(true) & b.sharedKey.isNull()))
          ..orderBy([(c) => OrderingTerm.asc(c.order)]))
        .get();
  }

  Future<int> getAmountOfCategories() async {
    return (await (select(categories)
              ..where((c) => onlyShowMainCategoryListing(c)))
            .get())
        .length;
  }

  Future<int> getAmountOfSubCategories(String mainCategoryPk) async {
    return (await (select(categories)
              ..where((c) => c.mainCategoryPk.equals(mainCategoryPk)))
            .get())
        .length;
  }

  Future<int> getAmountOfAssociatedTitles() async {
    return (await select(associatedTitles).get()).length;
  }

  Future moveCategory(String categoryPk, int newPosition, int oldPosition,
      {String? mainCategoryPk}) async {
    List<TransactionCategory> categoriesList = await (select(categories)
          ..where((c) => mainCategoryPk == null
              ? onlyShowMainCategoryListing(c)
              : c.mainCategoryPk.equals(mainCategoryPk))
          ..orderBy([(c) => OrderingTerm.asc(c.order)]))
        .get();
    await batch((batch) {
      if (newPosition > oldPosition) {
        for (TransactionCategory category in categoriesList) {
          batch.update(
            categories,
            CategoriesCompanion(
              order: Value(category.order - 1),
              dateTimeModified: Value(DateTime.now()),
            ),
            where: (c) =>
                c.categoryPk.equals(category.categoryPk) &
                c.order.isBiggerOrEqualValue(oldPosition) &
                c.order.isSmallerOrEqualValue(newPosition),
          );
        }
      } else {
        for (TransactionCategory category in categoriesList) {
          batch.update(
            categories,
            CategoriesCompanion(
              order: Value(category.order + 1),
              dateTimeModified: Value(DateTime.now()),
            ),
            where: (c) =>
                c.categoryPk.equals(category.categoryPk) &
                c.order.isBiggerOrEqualValue(newPosition) &
                c.order.isSmallerOrEqualValue(oldPosition),
          );
        }
      }
      batch.update(
        categories,
        CategoriesCompanion(
          order: Value(newPosition),
          dateTimeModified: Value(DateTime.now()),
        ),
        where: (c) => c.categoryPk.equals(categoryPk),
      );
    });
  }

  Future<bool> shiftCategories(int direction, int pastIndexIncluding,
      {String? mainCategoryPk}) async {
    List<TransactionCategory> categoryList = await (select(categories)
          ..where((c) => mainCategoryPk == null
              ? onlyShowMainCategoryListing(c)
              : c.mainCategoryPk.equals(mainCategoryPk))
          ..orderBy([(c) => OrderingTerm.asc(c.order)]))
        .get();
    if (direction == -1 || direction == 1) {
      for (TransactionCategory category in categoryList) {
        await (update(categories)
              ..where(
                (c) =>
                    c.order.isBiggerOrEqualValue(pastIndexIncluding) &
                    c.categoryPk.equals(category.categoryPk),
              ))
            .write(
          CategoriesCompanion(
            order: Value(category.order + direction),
            dateTimeModified: Value(DateTime.now()),
          ),
        );
      }
    } else {
      return false;
    }
    return true;
  }

  // get wallet given name
  Future<TransactionWallet> getWalletInstanceGivenName(String name) async {
    return (await (select(wallets)..where((w) => w.name.equals(name))).get())
        .first;
  }

  // get wallet given name, to lower and trim
  Future<TransactionWallet> getWalletInstanceGivenNameTrim(String name) async {
    return (await (select(wallets)
              ..where((w) =>
                  w.name.lower().trim().equals(name.toLowerCase().trim())))
            .get())
        .first;
  }

  // get wallet given id
  Future<TransactionWallet> getWalletInstance(String walletPk) {
    return (select(wallets)..where((w) => w.walletPk.equals(walletPk)))
        .getSingle();
  }

  Future<ScannerTemplate> getScannerTemplateInstance(String scannerTemplatePk) {
    return (select(scannerTemplates)
          ..where((s) => s.scannerTemplatePk.equals(scannerTemplatePk)))
        .getSingle();
  }

  // delete budget given key
  Future<int> deleteBudget(context, Budget budget) async {
    if (budget.sharedKey != null) {
      loadingIndeterminateKey.currentState!.setVisibility(true);
      if (budget.sharedOwnerMember == SharedOwnerMember.owner) {
        bool result = await removedSharedFromBudget(budget);
      } else {
        bool result = await leaveSharedBudget(budget);
      }
      loadingIndeterminateKey.currentState!.setVisibility(false);
    }
    if (budget.addedTransactionsOnly) {
      // Clear the budget the transactions are added to
      List<Transaction> transactionsAddedToThisBudget =
          await getAllTransactionsBelongingToSharedBudget(budget.budgetPk);
      await moveTransactionsToBudget(transactionsAddedToThisBudget, null);
    }

    List<Transaction> transactionsExcludedFromThisBudget =
        await getAllTransactionsBelongingToExcludedBudget(budget.budgetPk);
    await clearExcludeTransactions(
        transactionsExcludedFromThisBudget, budget.budgetPk);

    if (appStateSettings["lineGraphDisplayType"] ==
            LineGraphDisplay.Budget.index &&
        appStateSettings["lineGraphReferenceBudgetPk"] == budget.budgetPk) {
      updateSettings(
        "lineGraphDisplayType",
        LineGraphDisplay.Default30Days.index,
        pagesNeedingRefresh: [0],
        updateGlobalState: false,
      );
    }

    await shiftBudgets(-1, budget.order);
    await deleteCategoryBudgetLimitsInBudget(budget.budgetPk);
    await createDeleteLog(DeleteLogType.Budget, budget.budgetPk);
    return (delete(budgets)..where((b) => b.budgetPk.equals(budget.budgetPk)))
        .go();
  }

  Future<int> deleteObjective(context, Objective objective) async {
    // Clear the objective the transactions are added to
    List<Transaction> transactionsAddedToThisObjective =
        await getAllTransactionsBelongingToObjective(objective.objectivePk);
    await moveTransactionsToObjective(transactionsAddedToThisObjective, null);

    await shiftObjectives(-1, objective.order);
    await createDeleteLog(DeleteLogType.Objective, objective.objectivePk);
    return (delete(objectives)
          ..where((b) => b.objectivePk.equals(objective.objectivePk)))
        .go();
  }

  //delete transaction given key
  Future deleteTransaction(String transactionPk,
      {bool updateSharedEntry = true}) async {
    if (updateSharedEntry == true && appStateSettings["sharedBudgets"] == false)
      updateSharedEntry = false;
    // Send the delete log to the server
    if (updateSharedEntry) {
      Transaction transactionToDelete =
          await database.getTransactionFromPk(transactionPk);
      if (transactionToDelete.sharedKey != null &&
          transactionToDelete.sharedReferenceBudgetPk != null) {
        Budget budget = await database
            .getBudgetInstance(transactionToDelete.sharedReferenceBudgetPk!);
        sendTransactionDelete(transactionToDelete, budget);
      }
    }
    await createDeleteLog(DeleteLogType.Transaction, transactionPk);
    return (delete(transactions)
          ..where((t) => t.transactionPk.equals(transactionPk)))
        .go();
  }

  Future deleteTransactions(List<String> transactionPks,
      {bool updateSharedEntry = true}) async {
    if (updateSharedEntry == true && appStateSettings["sharedBudgets"] == false)
      updateSharedEntry = false;
    // Send the delete log to the server
    for (String transactionPk in transactionPks) {
      if (updateSharedEntry) {
        Transaction transactionToDelete =
            await database.getTransactionFromPk(transactionPk);
        if (transactionToDelete.sharedKey != null &&
            transactionToDelete.sharedReferenceBudgetPk != null) {
          Budget budget = await database
              .getBudgetInstance(transactionToDelete.sharedReferenceBudgetPk!);
          sendTransactionDelete(transactionToDelete, budget);
        }
      }
    }

    await createDeleteLogs(DeleteLogType.Transaction, transactionPks);
    return (delete(transactions)
          ..where((t) => t.transactionPk.isIn(transactionPks)))
        .go();
  }

  Future forceDeleteBudgets(List<String> budgetPks) async {
    return (delete(budgets)..where((t) => t.budgetPk.isIn(budgetPks))).go();
  }

  Future forceDeleteObjectives(List<String> objectivePks) async {
    return (delete(objectives)..where((t) => t.objectivePk.isIn(objectivePks)))
        .go();
  }

  Future deleteCategoryBudgetLimit(String categoryLimitPk) async {
    await createDeleteLog(DeleteLogType.CategoryBudgetLimit, categoryLimitPk);
    return (delete(categoryBudgetLimits)
          ..where((t) => t.categoryLimitPk.equals(categoryLimitPk)))
        .go();
  }

  Future unAssignSubCategoryFromTransactions(String categoryPk) async {
    List<Transaction> transactionsWithSubCategory =
        await getAllTransactionsFromSubCategory(categoryPk);
    List<Transaction> transactionsInserting = [];
    for (Transaction transaction in transactionsWithSubCategory) {
      transactionsInserting.add(transaction.copyWith(
          subCategoryFk: Value(null), dateTimeModified: Value(DateTime.now())));
    }
    await updateBatchTransactionsOnly(transactionsInserting);
  }

  //delete category given key
  Future deleteCategory(String categoryPk, int order) async {
    await deleteCategoryTitles(categoryPk);
    await deleteCategoryTransactions(categoryPk);
    await unAssignSubCategoryFromTransactions(categoryPk);
    await deleteCategoryBudgetLimitsInCategory(categoryPk);
    // List<Transaction> sharedTransactionsInCategory =
    //     await getAllTransactionsSharedInCategory(categoryPk);
    // print(sharedTransactionsInCategory);
    // await Future.wait([
    //   for (Transaction transaction in sharedTransactionsInCategory)
    //     // delete shared transactions one by one, need to update the server
    //     deleteTransaction(transaction.transactionPk)
    // ]);
    TransactionCategory category = await getCategoryInstance(categoryPk);
    if (category.mainCategoryPk != null) {
      // a subcategory
      await shiftCategories(-1, order, mainCategoryPk: category.mainCategoryPk);
    } else {
      await shiftCategories(-1, order);
    }
    // print("DELETING");
    // print(categoryPk);
    await createDeleteLog(DeleteLogType.TransactionCategory, categoryPk);
    // Delete any category with same key, or subcategory with that key
    return (delete(categories)
          ..where((c) =>
              c.categoryPk.equals(categoryPk) |
              c.mainCategoryPk.equals(categoryPk)))
        .go();
  }

  Future<List<Transaction>> getAllTransactionsSharedInCategory(categoryFk) {
    return (select(transactions)
          ..where((tbl) {
            return tbl.sharedKey.isNotNull() &
                tbl.categoryFk.equals(categoryFk);
          }))
        .get();
  }

  //delete transactions that belong to specific category key
  Future deleteCategoryTransactions(String categoryPk) async {
    List<Transaction> transactionsToDelete = await (select(transactions)
          ..where((t) => t.categoryFk.equals(categoryPk)))
        .get();
    List<String> transactionPks = transactionsToDelete
        .map((transaction) => transaction.transactionPk)
        .toList();
    await createDeleteLogs(DeleteLogType.Transaction, transactionPks);
    return (delete(transactions)..where((t) => t.categoryFk.equals(categoryPk)))
        .go();
  }

  //delete associatedTitles that belong to specific category key
  Future deleteCategoryTitles(String categoryPk) async {
    List<TransactionAssociatedTitle> titlesToDelete =
        await (select(associatedTitles)
              ..where((t) => t.categoryFk.equals(categoryPk)))
            .get();
    List<String> titlePks =
        titlesToDelete.map((title) => title.associatedTitlePk).toList();
    await createDeleteLogs(DeleteLogType.TransactionAssociatedTitle, titlePks);
    await (delete(associatedTitles)
          ..where((t) => t.categoryFk.equals(categoryPk)))
        .go();
    await fixOrderAssociatedTitles();
    return;
  }

  Future deleteCategoryBudgetLimitsInBudget(String budgetPk) async {
    List<CategoryBudgetLimit> limitsToDelete =
        await (select(categoryBudgetLimits)
              ..where((t) => t.budgetFk.equals(budgetPk)))
            .get();
    List<String> limitPks =
        limitsToDelete.map((limit) => limit.categoryLimitPk).toList();
    await createDeleteLogs(DeleteLogType.TransactionAssociatedTitle, limitPks);
    return (delete(categoryBudgetLimits)
          ..where((t) => t.budgetFk.equals(budgetPk)))
        .go();
  }

  Future deleteCategoryBudgetLimitsInCategory(String categoryPk) async {
    List<CategoryBudgetLimit> limitsToDelete =
        await (select(categoryBudgetLimits)
              ..where((t) => t.categoryFk.equals(categoryPk)))
            .get();
    List<String> limitPks =
        limitsToDelete.map((limit) => limit.categoryLimitPk).toList();
    await createDeleteLogs(DeleteLogType.TransactionAssociatedTitle, limitPks);
    return (delete(categoryBudgetLimits)
          ..where((t) => t.categoryFk.equals(categoryPk)))
        .go();
  }

  //delete wallet given key
  Future deleteWallet(String walletPk, int order) async {
    if (walletPk == "0") {
      throw "Can't delete default wallet";
    }
    if (appStateSettings["selectedWalletPk"] == walletPk) {
      setPrimaryWallet("0");
    }
    await database.deleteWalletsTransactions(walletPk);
    await database.shiftWallets(-1, order);
    await createDeleteLog(DeleteLogType.TransactionWallet, walletPk);
    return (delete(wallets)..where((w) => w.walletPk.equals(walletPk))).go();
  }

  Future<bool> moveWalletTransactions(
    AllWallets allWallets,
    String? walletPk,
    String toWalletPk, {
    List<Transaction>? transactionsToMove,
  }) async {
    List<Transaction> transactionsForMove = transactionsToMove ??
        await (select(transactions)
              ..where((tbl) {
                return tbl.walletFk.equals(walletPk!);
              }))
            .get();
    List<Transaction> allTransactionsToUpdate = [];
    for (Transaction transaction in transactionsForMove) {
      allTransactionsToUpdate.add(transaction.copyWith(
        amount: (amountRatioFromToCurrency(
                    allWallets.indexedByPk[transaction.walletFk]?.currency ??
                        "usd",
                    allWallets.indexedByPk[toWalletPk]?.currency ?? "usd") ??
                1) *
            transaction.amount,
        dateTimeModified: Value(DateTime.now()),
        walletFk: toWalletPk,
      ));
    }
    await updateBatchTransactionsOnly(allTransactionsToUpdate);
    return true;
  }

  // Returns the number of updates transactions
  Future<int> moveTransactionsToBudget(
      List<Transaction> transactionsToMove, String? addedBudgetPk) async {
    List<Transaction> allTransactionsToUpdate = [];
    for (Transaction transaction in transactionsToMove) {
      // if (addedBudgetPk == null ||
      //     canAddToBudget(transaction.income, transaction.type)) {
      allTransactionsToUpdate.add(transaction.copyWith(
        sharedReferenceBudgetPk: Value(addedBudgetPk),
        dateTimeModified: Value(DateTime.now()),
      ));
    }
    await updateBatchTransactionsOnly(allTransactionsToUpdate);
    return allTransactionsToUpdate.length;
  }

  // Returns the number of updates transactions
  Future<int> clearExcludeTransactions(List<Transaction> transactionsToMove,
      String? excludedBudgetPkToClear) async {
    List<Transaction> allTransactionsToUpdate = [];
    for (Transaction transaction in transactionsToMove) {
      List<String> budgetFksExclude = transaction.budgetFksExclude ?? [];
      budgetFksExclude.remove(excludedBudgetPkToClear);
      allTransactionsToUpdate.add(transaction.copyWith(
        budgetFksExclude:
            Value(budgetFksExclude.isEmpty ? null : budgetFksExclude),
        dateTimeModified: Value(DateTime.now()),
      ));
    }
    await updateBatchTransactionsOnly(allTransactionsToUpdate);
    return allTransactionsToUpdate.length;
  }

  Future<int> moveTransactionsToObjective(
      List<Transaction> transactionsToMove, String? objectivePk) async {
    List<Transaction> allTransactionsToUpdate = [];
    for (Transaction transaction in transactionsToMove) {
      allTransactionsToUpdate.add(transaction.copyWith(
        objectiveFk: Value(objectivePk),
        dateTimeModified: Value(DateTime.now()),
      ));
    }
    await updateBatchTransactionsOnly(allTransactionsToUpdate);
    return allTransactionsToUpdate.length;
  }

  Future moveTransactionsToCategory(List<Transaction> transactionsToMove,
      String categoryPk, String? subCategoryPk, bool clearSubcategory) async {
    List<Transaction> allTransactionsToUpdate = [];
    if (clearSubcategory == false && subCategoryPk == null) {
      List<String> subCategories =
          (await database.getAllSubCategoriesOfMainCategory(categoryPk))
              .map((c) => c.categoryPk)
              .toList();
      for (Transaction transaction in transactionsToMove) {
        bool clearSubCategory = true;
        if (subCategories.contains(transaction.subCategoryFk)) {
          clearSubCategory = false;
        }
        allTransactionsToUpdate.add(transaction.copyWith(
          categoryFk: categoryPk,
          dateTimeModified: Value(DateTime.now()),
          subCategoryFk: Value(
              clearSubCategory == true ? null : transaction.subCategoryFk),
        ));
      }
    } else {
      for (Transaction transaction in transactionsToMove) {
        allTransactionsToUpdate.add(transaction.copyWith(
          categoryFk: categoryPk,
          dateTimeModified: Value(DateTime.now()),
          subCategoryFk: Value(subCategoryPk),
        ));
      }
    }

    return await updateBatchTransactionsOnly(allTransactionsToUpdate);
  }

  Future deleteScannerTemplate(String scannerTemplatePk) async {
    await createDeleteLog(DeleteLogType.ScannerTemplate, scannerTemplatePk);
    return (delete(scannerTemplates)
          ..where((s) => s.scannerTemplatePk.equals(scannerTemplatePk)))
        .go();
  }

  //delete transactions that belong to specific wallet key
  Future deleteWalletsTransactions(String walletPk) async {
    List<Transaction> transactionPkForDelete = await (select(transactions)
          ..where((tbl) {
            return tbl.walletFk.equals(walletPk);
          }))
        .get();
    List<String> transactionPks =
        transactionPkForDelete.map((t) => t.transactionPk).toList();
    await createDeleteLogs(DeleteLogType.Transaction, transactionPks);
    return (delete(transactions)..where((t) => t.walletFk.equals(walletPk)))
        .go();
  }

  //delete associated title given key
  Future deleteAssociatedTitle(String associatedTitlePk, int order) async {
    await database.shiftAssociatedTitles(-1, order);
    await createDeleteLog(
        DeleteLogType.TransactionAssociatedTitle, associatedTitlePk);
    return (delete(associatedTitles)
          ..where((t) => t.associatedTitlePk.equals(associatedTitlePk)))
        .go();
  }

  Future mergeAndDeleteSubCategory(TransactionCategory subCategoryFrom,
      TransactionCategory subCategoryTo) async {
    List<Transaction> transactionsToUpdate =
        await getAllTransactionsFromSubCategory(subCategoryFrom.categoryPk);

    List<Transaction> transactionsEdited = [];
    for (Transaction transaction in transactionsToUpdate) {
      transactionsEdited.add(transaction.copyWith(
          subCategoryFk: Value(subCategoryTo.categoryPk),
          dateTimeModified: Value(DateTime.now())));
    }
    await updateBatchTransactionsOnly(transactionsEdited);

    // Delete the old subcategory
    await database.deleteCategory(
      subCategoryFrom.categoryPk,
      subCategoryFrom.order,
    );
  }

  Future makeMainCategoryIntoSubcategory(
      TransactionCategory categoryFrom, TransactionCategory categoryTo) async {
    List<Transaction> transactionsToUpdate =
        await getAllTransactionsFromCategory(categoryFrom.categoryPk);
    List<Transaction> transactionsEdited = [];
    for (Transaction transaction in transactionsToUpdate) {
      transactionsEdited.add(transaction.copyWith(
          categoryFk: categoryTo.categoryPk,
          subCategoryFk: Value(categoryFrom.categoryPk),
          dateTimeModified: Value(DateTime.now())));
    }
    await updateBatchTransactionsOnly(transactionsEdited);

    await shiftCategories(-1, categoryFrom.order);

    await database.createOrUpdateCategory(
      categoryFrom.copyWith(
        mainCategoryPk: Value(categoryTo.categoryPk),
        order: await database.getAmountOfSubCategories(categoryTo.categoryPk),
      ),
    );
  }

  Future makeSubcategoryIntoMainCategory(
      TransactionCategory categoryFrom) async {
    List<Transaction> transactionsToUpdate =
        await getAllTransactionsFromSubCategory(categoryFrom.categoryPk);
    List<Transaction> transactionsEdited = [];
    for (Transaction transaction in transactionsToUpdate) {
      transactionsEdited.add(
        transaction.copyWith(
          categoryFk: categoryFrom.categoryPk,
          subCategoryFk: Value(null),
          dateTimeModified: Value(DateTime.now()),
        ),
      );
    }
    await updateBatchTransactionsOnly(transactionsEdited);

    await shiftCategories(-1, categoryFrom.order,
        mainCategoryPk: categoryFrom.mainCategoryPk);

    await database.createOrUpdateCategory(
      categoryFrom.copyWith(
        mainCategoryPk: Value(null),
        order: await database.getAmountOfCategories(),
      ),
    );
  }

  Future mergeAndDeleteCategory(
      TransactionCategory categoryFrom, TransactionCategory categoryTo) async {
    List<Transaction> transactionsToUpdate =
        await getAllTransactionsFromCategory(categoryFrom.categoryPk);
    // This is good for shared budgets, but shared is discontinued
    // for (Transaction transaction in transactionsToUpdate) {
    //   Transaction transactionEdited =
    //       transaction.copyWith(categoryFk: categoryTo.categoryPk);
    //   await database.createOrUpdateTransaction(transactionEdited);
    // }
    List<Transaction> transactionsEdited = [];
    for (Transaction transaction in transactionsToUpdate) {
      transactionsEdited.add(transaction.copyWith(
          categoryFk: categoryTo.categoryPk,
          subCategoryFk: Value(transaction.subCategoryFk),
          dateTimeModified: Value(DateTime.now())));
    }
    await updateBatchTransactionsOnly(transactionsEdited);

    List<TransactionAssociatedTitle> associatedTitlesToUpdate =
        await getAllAssociatedTitlesInCategory(categoryFrom.categoryPk);
    List<TransactionAssociatedTitle> associatedTitlesEdited = [];
    for (TransactionAssociatedTitle title in associatedTitlesToUpdate) {
      associatedTitlesEdited.add(title.copyWith(
          categoryFk: categoryTo.categoryPk,
          dateTimeModified: Value(DateTime.now())));
    }
    await updateBatchAssociatedTitlesOnly(associatedTitlesEdited);

    // Move all subcategories into the new category
    List<TransactionCategory> allSubCategories = await database
        .getAllSubCategoriesOfMainCategory(categoryFrom.categoryPk);
    List<TransactionCategory> categoriesEdited = [];
    int order =
        await database.getAmountOfSubCategories(categoryFrom.categoryPk);
    for (TransactionCategory category in allSubCategories) {
      categoriesEdited.add(
        category.copyWith(
          mainCategoryPk: Value(categoryTo.categoryPk),
          dateTimeModified: Value(DateTime.now()),
          order: order,
        ),
      );
      order = order + 1;
    }
    await updateBatchCategoriesOnly(categoriesEdited);

    // Delete the old category
    await database.deleteCategory(categoryFrom.categoryPk, categoryFrom.order);
  }

  Stream<double?> totalDoubleStream(List<Stream<double?>> mergedStreams) {
    return StreamZip(mergedStreams)
        .map((list) => list.where((x) => x != null))
        .map((list) => list.reduce((acc, val) => (acc ?? 0) + (val ?? 0)));
  }

  Stream<List<CategoryWithTotal>> totalCategoryTotalStream(
      List<Stream<List<CategoryWithTotal>>> mergedStreams) {
    return StreamZip(mergedStreams).map((lists) {
      final Map<String, CategoryWithTotal> categoryTotals = {};
      for (final list in lists) {
        for (final item in list) {
          categoryTotals[item.category.categoryPk] = CategoryWithTotal(
            category: item.category,
            total: item.total +
                (categoryTotals[item.category.categoryPk]?.total ?? 0),
            transactionCount: item.transactionCount +
                (categoryTotals[item.category.categoryPk]?.transactionCount ??
                    0),
            categoryBudgetLimit: item.categoryBudgetLimit,
          );
        }
      }
      List<CategoryWithTotal> categoryWithTotalsSorted = categoryTotals.values
          .toList()
        ..sort((a, b) => b.total.abs().compareTo(a.total.abs()));
      return categoryWithTotalsSorted;
    });
  }

  // If a category budget limit is not tied to an existing wallet,
  // make it the primary currency
  // This is because the total banner category limits would be incorrect
  // (Would not default to a factor of one since we loop through the wallets,
  // not the wallets that the limits exist in)
  Future<bool> fixWanderingCategoryLimitsInBudget({
    required AllWallets allWallets,
    required String budgetPk,
  }) async {
    List<CategoryBudgetLimit> wanderingLimits =
        await (select(categoryBudgetLimits)
              ..where((t) => t.walletFk.isNotIn(allWallets.indexedByPk.keys)))
            .get();
    for (CategoryBudgetLimit limit in wanderingLimits) {
      await createOrUpdateCategoryLimit(
          limit.copyWith(walletFk: appStateSettings["selectedWalletPk"]));
    }
    return true;
  }

  Stream<double?> watchTotalOfCategoryLimitsInBudgetWithCategories({
    required AllWallets allWallets,
    required String budgetPk,
    required List<String>? categoryPks,
    required List<String>? categoryPksExclude,
    required bool isAbsoluteSpendingLimit,
  }) {
    if (isAbsoluteSpendingLimit == false) {
      final totalAmt = categoryBudgetLimits.amount.sum();
      JoinedSelectStatement<$CategoryBudgetLimitsTable, CategoryBudgetLimit>
          query;

      query = selectOnly(categoryBudgetLimits)
        ..join([
          leftOuterJoin(categories,
              categories.categoryPk.equalsExp(categoryBudgetLimits.categoryFk))
        ])
        ..addColumns([totalAmt])
        ..where(categories.mainCategoryPk.isNull() &
            categoryBudgetLimits.budgetFk.equals(budgetPk) &
            isInCategory(
                categoryBudgetLimits, categoryPks, categoryPksExclude));

      return query.map((row) => row.read(totalAmt)).watchSingleOrNull();
    } else {
      List<Stream<double?>> mergedStreams = [];
      for (TransactionWallet wallet in allWallets.list) {
        final totalAmt = categoryBudgetLimits.amount.sum();
        JoinedSelectStatement<$CategoryBudgetLimitsTable, CategoryBudgetLimit>
            query;

        query = selectOnly(categoryBudgetLimits)
          ..join([
            leftOuterJoin(
                categories,
                categories.categoryPk
                    .equalsExp(categoryBudgetLimits.categoryFk))
          ])
          ..addColumns([totalAmt])
          ..where(categoryBudgetLimits.walletFk.equals(wallet.walletPk) &
              categories.mainCategoryPk.isNull() &
              categoryBudgetLimits.budgetFk.equals(budgetPk) &
              isInCategory(
                  categoryBudgetLimits, categoryPks, categoryPksExclude));

        mergedStreams.add(query
            .map(((row) =>
                (row.read(totalAmt) ?? 0) *
                (amountRatioToPrimaryCurrency(allWallets, wallet.currency))))
            .watchSingle());
      }

      return totalDoubleStream(mergedStreams);
    }
  }

  Stream<double?> watchTotalOfCategoryLimitsInBudgetWithSubCategories(
      {required AllWallets allWallets,
      required String mainCategoryPk,
      required String budgetPk,
      required List<String>? categoryPks,
      required List<String>? categoryPksExclude,
      required bool isAbsoluteSpendingLimit}) {
    if (isAbsoluteSpendingLimit == false) {
      final totalAmt = categoryBudgetLimits.amount.sum();
      JoinedSelectStatement<$CategoryBudgetLimitsTable, CategoryBudgetLimit>
          query;

      query = selectOnly(categoryBudgetLimits)
        ..join([
          leftOuterJoin(categories,
              categories.categoryPk.equalsExp(categoryBudgetLimits.categoryFk))
        ])
        ..addColumns([totalAmt])
        ..where(categories.mainCategoryPk.equals(mainCategoryPk) &
            categoryBudgetLimits.budgetFk.equals(budgetPk) &
            isInCategory(
                categoryBudgetLimits, categoryPks, categoryPksExclude));

      return query.map((row) => row.read(totalAmt)).watchSingleOrNull();
    } else {
      List<Stream<double?>> mergedStreams = [];
      for (TransactionWallet wallet in allWallets.list) {
        final totalAmt = categoryBudgetLimits.amount.sum();
        JoinedSelectStatement<$CategoryBudgetLimitsTable, CategoryBudgetLimit>
            query;

        query = selectOnly(categoryBudgetLimits)
          ..join([
            leftOuterJoin(
                categories,
                categories.categoryPk
                    .equalsExp(categoryBudgetLimits.categoryFk))
          ])
          ..addColumns([totalAmt])
          ..where(categoryBudgetLimits.walletFk.equals(wallet.walletPk) &
              categories.mainCategoryPk.equals(mainCategoryPk) &
              categoryBudgetLimits.budgetFk.equals(budgetPk) &
              isInCategory(
                  categoryBudgetLimits, categoryPks, categoryPksExclude));

        mergedStreams.add(query
            .map(((row) =>
                (row.read(totalAmt) ?? 0) *
                (amountRatioToPrimaryCurrency(allWallets, wallet.currency))))
            .watchSingle());
      }
      return totalDoubleStream(mergedStreams);
    }
  }

  Stream<double?> watchTotalTowardsObjective(
      AllWallets allWallets, String objectivePk) {
    List<Stream<double?>> mergedStreams = [];
    for (TransactionWallet wallet in allWallets.list) {
      final totalAmt = transactions.amount.sum();
      JoinedSelectStatement<$TransactionsTable, Transaction> query;

      query = selectOnly(transactions)
        ..addColumns([totalAmt])
        ..where(transactions.objectiveFk.equals(objectivePk) &
            transactions.walletFk.equals(wallet.walletPk) &
            transactions.paid.equals(true));

      mergedStreams.add(query
          .map(((row) =>
              (row.read(totalAmt) ?? 0) *
              (amountRatioToPrimaryCurrency(allWallets, wallet.currency))))
          .watchSingle());
    }
    return totalDoubleStream(mergedStreams);
  }

  Future<double?> getTotalTowardsObjective(
      AllWallets allWallets, String objectivePk) async {
    double totalAmount = 0;
    for (TransactionWallet wallet in allWallets.list) {
      final totalAmt = transactions.amount.sum();
      JoinedSelectStatement<$TransactionsTable, Transaction> query;

      query = selectOnly(transactions)
        ..addColumns([totalAmt])
        ..where(transactions.objectiveFk.equals(objectivePk) &
            transactions.walletFk.equals(wallet.walletPk) &
            transactions.paid.equals(true));

      totalAmount += await query
          .map(((row) =>
              (row.read(totalAmt) ?? 0) *
              (amountRatioToPrimaryCurrency(allWallets, wallet.currency))))
          .getSingle();
    }
    return totalAmount;
  }

  Stream<double?> watchTotalSpentGivenList(
      AllWallets allWallets, List<String> transactionPks) {
    List<Stream<double?>> mergedStreams = [];
    for (TransactionWallet wallet in allWallets.list) {
      final totalAmt = transactions.amount.sum();
      JoinedSelectStatement<$TransactionsTable, Transaction> query;

      query = (selectOnly(transactions)
        ..addColumns([totalAmt])
        ..where(
          transactions.transactionPk.isIn(transactionPks) &
              transactions.walletFk.equals(wallet.walletPk),
        ));
      mergedStreams.add(query
          .map(((row) =>
              (row.read(totalAmt) ?? 0) *
              (amountRatioToPrimaryCurrency(allWallets, wallet.currency))))
          .watchSingle());
    }

    return totalDoubleStream(mergedStreams);
  }

  // get total amount spent in each day
  Stream<double?> watchTotalSpentInTimeRangeFromCategories(
      {required AllWallets allWallets,
      required DateTime start,
      required DateTime end,
      required List<String>? categoryFks,
      required List<String>? categoryFksExclude,
      required List<BudgetTransactionFilters>? budgetTransactionFilters,
      required List<String>? memberTransactionFilters,
      bool allCashFlow = false,
      String? onlyShowTransactionsBelongingToBudgetPk,
      Budget? budget}) {
    DateTime startDate = DateTime(start.year, start.month, start.day);
    DateTime endDate = DateTime(end.year, end.month, end.day);
    List<Stream<double?>> mergedStreams = [];
    for (TransactionWallet wallet in allWallets.list) {
      final totalAmt = transactions.amount.sum();
      final date = transactions.dateCreated.date;

      JoinedSelectStatement<$TransactionsTable, Transaction> query =
          (selectOnly(transactions)
            ..addColumns([totalAmt])
            ..where(
              isInCategory(transactions, categoryFks, categoryFksExclude) &
                  onlyShowBasedOnTimeRange(
                      transactions, startDate, endDate, budget) &
                  transactions.paid.equals(true) &
                  // (allCashFlow
                  //     ? transactions.income.isIn([true, false])
                  //     : transactions.income.equals(false)) &
                  onlyShowBasedOnWalletFks(transactions, budget?.walletFks) &
                  onlyShowIfNotExcludedFromBudget(
                      transactions, budget?.budgetPk) &
                  onlyShowIfCertainBudget(
                      transactions, onlyShowTransactionsBelongingToBudgetPk) &
                  transactions.walletFk.equals(wallet.walletPk) &
                  onlyShowIfFollowsFilters(transactions,
                      budgetTransactionFilters: budgetTransactionFilters,
                      memberTransactionFilters: memberTransactionFilters),
            ));

      mergedStreams.add(query
          .map(((row) =>
              (row.read(totalAmt) ?? 0) *
              (amountRatioToPrimaryCurrency(allWallets, wallet.currency))))
          .watchSingle());
    }
    return totalDoubleStream(mergedStreams);
  }

  Expression<bool> onlyShowIfFollowsSearchFilters(
    $TransactionsTable tbl,
    SearchFilters? searchFilters, {
    required $CategoriesTable? joinedWithSubcategoriesTable,
    required bool joinedWithCategories,
    required bool joinedWithBudgets,
    required bool joinedWithObjectives,
  }) {
    if (searchFilters == null) return Constant(true);

    Expression<bool> isInWalletPks =
        onlyShowBasedOnWalletFks(tbl, searchFilters.walletPks);
    Expression<bool> isInCategoryPks =
        onlyShowBasedOnCategoryFks(tbl, searchFilters.categoryPks, null);
    Expression<bool> isInSubcategoryPks =
        onlyShowBasedOnSubcategoryFks(tbl, searchFilters.subcategoryPks);
    Expression<bool> isInBudgetPks =
        onlyShowBasedOnBudgetFks(tbl, searchFilters.budgetPks);
    Expression<bool> isInExcludedBudgetPks =
        onlyShowBasedOnExcludedBudgetFks(tbl, searchFilters.excludedBudgetPks);
    Expression<bool> isInObjectivePks =
        onlyShowBasedOnObjectiveFks(tbl, searchFilters.objectivePks);

    Expression<bool> isBalanceCorrectionAnd =
        searchFilters.categoryPks.contains("0")
            ? Constant(true)
            : tbl.categoryFk.equals("0").not();
    Expression<bool> isIncome = searchFilters.expenseIncome.length <= 0
        ? Constant(true)
        : searchFilters.expenseIncome.contains(ExpenseIncome.income)
            ? tbl.income.equals(true) & isBalanceCorrectionAnd
            : Constant(false);
    Expression<bool> isExpense = searchFilters.expenseIncome.length <= 0
        ? Constant(true)
        : searchFilters.expenseIncome.contains(ExpenseIncome.expense)
            ? tbl.income.equals(false) & isBalanceCorrectionAnd
            : Constant(false);

    Expression<bool> isPaid = searchFilters.paidStatus.length <= 0
        ? Constant(true)
        : searchFilters.paidStatus.contains(PaidStatus.paid)
            ? tbl.paid.equals(true) &
                tbl.type.isNotNull() &
                tbl.type.isNotInValues([
                  TransactionSpecialType.debt,
                  TransactionSpecialType.credit
                ])
            : Constant(false);
    Expression<bool> isNotPaid = searchFilters.paidStatus.length <= 0
        ? Constant(true)
        : searchFilters.paidStatus.contains(PaidStatus.notPaid)
            ? tbl.paid.equals(false) &
                tbl.type.isNotNull() &
                tbl.type.isNotInValues([
                  TransactionSpecialType.debt,
                  TransactionSpecialType.credit
                ])
            : Constant(false);
    Expression<bool> isSkippedPaid = searchFilters.paidStatus.length <= 0
        ? Constant(true)
        : searchFilters.paidStatus.contains(PaidStatus.skipped)
            ? tbl.skipPaid.equals(true) & tbl.type.isNotNull()
            : Constant(false);

    Expression<bool> isTransactionType =
        searchFilters.transactionTypes.length > 0
            ? tbl.type.isInValues(searchFilters.transactionTypes)
            : Constant(true);

    Expression<bool> includeShared =
        searchFilters.budgetTransactionFilters.length <= 0
            ? Constant(true)
            : searchFilters.budgetTransactionFilters.contains(
                        BudgetTransactionFilters.sharedToOtherBudget) ==
                    true
                ? tbl.sharedKey.isNotNull()
                : Constant(false);

    Expression<bool> includeAdded = searchFilters
                .budgetTransactionFilters.length <=
            0
        ? Constant(true)
        : searchFilters.budgetTransactionFilters
                    .contains(BudgetTransactionFilters.addedToOtherBudget) ==
                true
            ? tbl.sharedReferenceBudgetPk.isNotNull() & tbl.sharedKey.isNull()
            : Constant(false);

    Expression<bool> isMethodAdded =
        onlyShowBasedOnMethodAdded(tbl, searchFilters.methodAdded);

    Expression<bool> isInAmountRange = searchFilters.amountRange != null
        ? tbl.amount.isBetweenValues(searchFilters.amountRange?.start ?? 0,
            searchFilters.amountRange?.end ?? 0)
        : Constant(true);

    Expression<bool> isInDateTimeRange = onlyShowBasedOnTimeRange(
        tbl,
        searchFilters.dateTimeRange?.start,
        searchFilters.dateTimeRange?.end,
        null);

    String searchQuery = searchFilters.searchQuery ?? "";
    Expression<bool> isInQuery = onlyShowTransactionBasedOnSearchQuery(
      tbl,
      searchQuery,
      withCategories: joinedWithCategories,
      joinedWithSubcategoriesTable: joinedWithSubcategoriesTable,
      withBudgets: joinedWithBudgets,
      withObjectives: joinedWithObjectives,
    );

    return isInWalletPks &
        isInCategoryPks &
        isInSubcategoryPks &
        isInBudgetPks &
        isInExcludedBudgetPks &
        isInObjectivePks &
        isInQuery &
        (isIncome | isExpense) &
        (isPaid | isNotPaid | isSkippedPaid) &
        isInDateTimeRange &
        isTransactionType &
        (includeShared | includeAdded) &
        isInAmountRange &
        isMethodAdded;
  }

  Expression<bool> onlyShowBalanceCorrectionIfIsIncomeIsNull(
    $TransactionsTable tbl,
    bool? isIncome,
  ) {
    return isIncome == null
        ? Constant(true)
        : transactions.categoryFk.equals("0").not();
  }

  Expression<bool> onlyShowTransactionBasedOnSearchQuery(
    $TransactionsTable tbl,
    String? searchQuery, {
    required bool withCategories,
    required $CategoriesTable? joinedWithSubcategoriesTable,
    bool? withBudgets,
    bool? withObjectives,
  }) {
    // If withCategories if true, you will need to use a join with categories!
    return searchQuery == "" || searchQuery == null
        ? Constant(true)
        : (withCategories == true
                ? categories.name
                    .collate(Collate.noCase)
                    .like("%" + searchQuery + "%")
                : Constant(false)) |
            (joinedWithSubcategoriesTable != null
                ? joinedWithSubcategoriesTable.name
                    .collate(Collate.noCase)
                    .like("%" + searchQuery + "%")
                : Constant(false)) |
            (withBudgets == true
                ? budgets.name
                    .collate(Collate.noCase)
                    .like("%" + searchQuery + "%")
                : Constant(false)) |
            (withObjectives == true
                ? objectives.name
                    .collate(Collate.noCase)
                    .like("%" + searchQuery + "%")
                : Constant(false)) |
            tbl.name.collate(Collate.noCase).like("%" + searchQuery + "%") |
            tbl.note.collate(Collate.noCase).like("%" + searchQuery + "%");
  }

  Expression<bool> onlyShowIfFollowsFilters($TransactionsTable tbl,
      {List<BudgetTransactionFilters>? budgetTransactionFilters,
      List<String>? memberTransactionFilters}) {
    Expression<bool> memberIncluded = memberTransactionFilters == null
        ? Constant(true)
        : (tbl.sharedKey.isNotNull() &
                tbl.transactionOwnerEmail.isIn(memberTransactionFilters) |
            tbl.sharedKey.isNull());

    Expression<bool> includeShared = budgetTransactionFilters
                ?.contains(BudgetTransactionFilters.sharedToOtherBudget) ==
            false
        ? Constant(
              isFilterSelectedWithDefaults(budgetTransactionFilters,
                  BudgetTransactionFilters.sharedToOtherBudget),
            ) |
            (tbl.sharedKey.isNull())
        : Constant(true);

    Expression<bool> includeAdded = budgetTransactionFilters
                ?.contains(BudgetTransactionFilters.addedToOtherBudget) ==
            false
        ? Constant(
              isFilterSelectedWithDefaults(budgetTransactionFilters,
                  BudgetTransactionFilters.addedToOtherBudget),
            ) |
            (tbl.sharedReferenceBudgetPk.isNull() | tbl.sharedKey.isNotNull())
        : Constant(true);

    Expression<bool> includeIncome = budgetTransactionFilters
                ?.contains(BudgetTransactionFilters.includeIncome) ==
            false
        ? Constant(
              isFilterSelectedWithDefaults(budgetTransactionFilters,
                  BudgetTransactionFilters.includeIncome),
            ) |
            (tbl.income.equals(false))
        : Constant(true);

    Expression<bool> includeDebtAndCredit = budgetTransactionFilters
                ?.contains(BudgetTransactionFilters.includeDebtAndCredit) ==
            false
        ? Constant(
              isFilterSelectedWithDefaults(budgetTransactionFilters,
                  BudgetTransactionFilters.includeDebtAndCredit),
            ) |
            (tbl.type.isNotIn([
                  TransactionSpecialType.credit.index,
                  TransactionSpecialType.debt.index
                ]) |
                tbl.type.isNull())
        : Constant(true);

    Expression<bool> includeAddedToObjective = budgetTransactionFilters
                ?.contains(BudgetTransactionFilters.addedToObjective) ==
            false
        ? Constant(
              isFilterSelectedWithDefaults(budgetTransactionFilters,
                  BudgetTransactionFilters.addedToObjective),
            ) |
            (tbl.objectiveFk.isNull())
        : Constant(true);

    Expression<bool> includeBalanceCorrection = budgetTransactionFilters
                ?.contains(BudgetTransactionFilters.includeBalanceCorrection) ==
            false
        ? Constant(
              isFilterSelectedWithDefaults(budgetTransactionFilters,
                  BudgetTransactionFilters.includeBalanceCorrection),
            ) |
            (tbl.categoryFk.equals("0").not())
        : Constant(true);

    return memberIncluded &
        includeShared &
        includeAdded &
        includeIncome &
        includeDebtAndCredit &
        includeAddedToObjective &
        includeBalanceCorrection;
  }

  Stream<double?> watchTotalSpentByCurrentUserOnly(
    AllWallets allWallets,
    DateTime start,
    DateTime end,
    String budgetPk,
  ) {
    DateTime startDate = DateTime(start.year, start.month, start.day);
    DateTime endDate = DateTime(end.year, end.month, end.day);

    List<Stream<double?>> mergedStreams = [];
    for (TransactionWallet wallet in allWallets.list) {
      final totalAmt = transactions.amount.sum();
      JoinedSelectStatement<$TransactionsTable, Transaction> query =
          (selectOnly(transactions)
            ..addColumns([totalAmt])
            ..where(transactions.paid.equals(true) &
                //transactions.income.equals(false) &
                transactions.walletFk.equals(wallet.walletPk) &
                onlyShowBasedOnTimeRange(
                    transactions, startDate, endDate, null) &
                onlyShowIfFollowsFilters(transactions,
                    memberTransactionFilters: [
                      appStateSettings["currentUserEmail"] ?? ""
                    ]) &
                transactions.sharedReferenceBudgetPk.equals(budgetPk)));
      mergedStreams.add(query
          .map(((row) =>
              (row.read(totalAmt) ?? 0) *
              (amountRatioToPrimaryCurrency(allWallets, wallet.currency))))
          .watchSingleOrNull());
    }

    return totalDoubleStream(mergedStreams);
  }

  Stream<double?> watchTotalSpentByUser(
      AllWallets allWallets,
      DateTime start,
      DateTime end,
      List<String>? categoryFks,
      List<String>? categoryFksExclude,
      String userEmail,
      String onlyShowTransactionsBelongingToBudgetPk,
      {bool allTime = false}) {
    DateTime startDate = DateTime(start.year, start.month, start.day);
    DateTime endDate = DateTime(end.year, end.month, end.day);
    List<Stream<double?>> mergedStreams = [];
    for (TransactionWallet wallet in allWallets.list) {
      final totalAmt = transactions.amount.sum();
      JoinedSelectStatement<$TransactionsTable, Transaction> query;

      query = (selectOnly(transactions)
        ..addColumns([totalAmt])
        ..where((allTime
                ? transactions.dateCreated.isNotNull()
                : transactions.dateCreated
                    .isBetweenValues(startDate, endDate)) &
            transactions.paid.equals(true) &
            //transactions.income.equals(false) &
            transactions.walletFk.equals(wallet.walletPk) &
            isInCategory(transactions, categoryFks, categoryFksExclude) &
            transactions.transactionOwnerEmail.equals(userEmail) &
            transactions.sharedReferenceBudgetPk
                .equals(onlyShowTransactionsBelongingToBudgetPk)));
      mergedStreams.add(query
          .map(((row) =>
              (row.read(totalAmt) ?? 0) *
              (amountRatioToPrimaryCurrency(allWallets, wallet.currency))))
          .watchSingleOrNull());
    }
    return totalDoubleStream(mergedStreams);
  }

  Stream<List<Transaction>> watchAllTransactionsByUser(
      {int? limit,
      required DateTime start,
      required DateTime end,
      required List<String>? categoryFks,
      required List<String>? categoryFksExclude,
      required String userEmail}) {
    DateTime startDate = DateTime(start.year, start.month, start.day);
    DateTime endDate = DateTime(end.year, end.month, end.day);
    return (select(transactions)
          ..where((tbl) {
            return tbl.dateCreated.isBetweenValues(startDate, endDate) &
                tbl.paid.equals(true) &
                tbl.income.equals(false) &
                isInCategory(tbl, categoryFks, categoryFksExclude) &
                tbl.transactionOwnerEmail.equals(userEmail);
          })
          ..orderBy([(b) => OrderingTerm.desc(b.dateCreated)])
          ..limit(limit ?? DEFAULT_LIMIT))
        .watch();
  }

  Expression<bool> isInCategory(
      tbl, List<String>? categoryFks, List<String>? categoryFksExclude) {
    if ((categoryFks ?? []).length <= 0) categoryFks = null;
    if ((categoryFksExclude ?? []).length <= 0) categoryFksExclude = null;
    return categoryFks == null && categoryFksExclude == null
        ? tbl.categoryFk.isNotNull()
        : categoryFks != null && categoryFksExclude == null
            ? tbl.categoryFk.isIn(categoryFks)
            : categoryFks == null && categoryFksExclude != null
                ? tbl.categoryFk.isNotIn(categoryFksExclude)
                : tbl.categoryFk.isIn(categoryFks ?? []) &
                    tbl.categoryFk.isNotIn(categoryFksExclude ?? []);
  }

  bool isInCategoryCheck(String categoryFk, List<String>? categoryFks,
      List<String>? categoryFksExclude) {
    if ((categoryFks ?? []).length <= 0) categoryFks = null;
    if ((categoryFksExclude ?? []).length <= 0) categoryFksExclude = null;
    return categoryFks == null && categoryFksExclude == null
        ? true
        : categoryFks != null && categoryFksExclude == null
            ? categoryFks.contains(categoryFk)
            : categoryFks == null && categoryFksExclude != null
                ? categoryFksExclude.contains(categoryFk) == false
                : (categoryFks ?? []).contains(categoryFk) &&
                    (categoryFksExclude ?? []).contains(categoryFk) == false;
  }

  Expression<bool> onlyShowIfMember($TransactionsTable tbl, String? member) {
    return (member != null
        ? tbl.transactionOwnerEmail.equals(member)
        : Constant(true));
  }

  Expression<bool> onlyShowBasedOnIncome($TransactionsTable tbl, bool? income) {
    return (income != null ? tbl.income.equals(income) : Constant(true));
  }

  // Balance correction category has pk "0"
  // We also want to include these transactions if isIncome is null (total net spending)
  Expression<bool> onlyShowIfNotBalanceCorrection(
      $TransactionsTable tbl, bool? isIncome) {
    return (tbl.categoryFk.equals("0").not() |
        (isIncome == null ? Constant(true) : Constant(false)));
  }

  // If followCustomPeriodCycle is true, cycleSettingsExtension should always be passed in a value!
  Expression<bool> onlyShowIfFollowCustomPeriodCycle(
    $TransactionsTable tbl,
    bool followCustomPeriodCycle, {
    String cycleSettingsExtension = "",
    DateTimeRange? forcedDateTimeRange,
  }) {
    if (forcedDateTimeRange != null) {
      return onlyShowBasedOnTimeRange(
          tbl, forcedDateTimeRange.start, forcedDateTimeRange.end, null,
          allTime: false);
    }
    CycleType selectedPeriodType = CycleType.values[
        appStateSettings["selectedPeriodCycleType" + cycleSettingsExtension] ??
            0];
    if (followCustomPeriodCycle == false) {
      return Constant(true);
    } else if (selectedPeriodType == CycleType.allTime) {
      return Constant(true);
    } else if (selectedPeriodType == CycleType.cycle) {
      DateTimeRange budgetRange = getCycleDateTimeRange(cycleSettingsExtension);
      DateTime startDate = DateTime(budgetRange.start.year,
          budgetRange.start.month, budgetRange.start.day);
      DateTime endDate = DateTime(
          budgetRange.end.year, budgetRange.end.month, budgetRange.end.day);
      return onlyShowBasedOnTimeRange(tbl, startDate, endDate, null,
          allTime: false);
    } else if (selectedPeriodType == CycleType.pastDays) {
      DateTime startDate =
          getStartDateOfSelectedCustomPeriod(cycleSettingsExtension) ??
              DateTime.now();
      return tbl.dateCreated.isBiggerOrEqualValue(startDate);
    } else if (selectedPeriodType == CycleType.dateRange) {
      DateTime startDate =
          getStartDateOfSelectedCustomPeriod(cycleSettingsExtension) ??
              DateTime.now();
      DateTime? endDate =
          getEndDateOfSelectedCustomPeriod(cycleSettingsExtension);
      if (endDate != null) {
        return onlyShowBasedOnTimeRange(tbl, startDate, endDate, null,
            allTime: false);
      } else {
        return tbl.dateCreated.isBiggerOrEqualValue(startDate);
      }
    }
    return Constant(true);
  }

  Expression<bool> onlyShowBasedOnCategoryFks($TransactionsTable tbl,
      List<String>? categoryFks, List<String>? categoryFksExclude) {
    return isInCategory(tbl, categoryFks, categoryFksExclude);
  }

  Expression<bool> onlyShowBasedOnSubcategoryFks(
      $TransactionsTable tbl, List<String>? subCategoryFks) {
    return subCategoryFks == null
        ? tbl.subCategoryFk.isNull()
        : subCategoryFks.isEmpty
            ? Constant(true)
            : tbl.subCategoryFk.isIn(subCategoryFks);
  }

  Expression<bool> onlyShowBasedOnWalletFks(
      $TransactionsTable tbl, List<String>? walletFks) {
    return (walletFks != null && walletFks.length > 0
        ? tbl.walletFk.isIn(walletFks)
        : Constant(true));
  }

  Expression<bool> onlyShowBasedOnMethodAdded(
      $TransactionsTable tbl, List<MethodAdded>? methodAdded) {
    return (methodAdded != null && methodAdded.length > 0
        ? tbl.methodAdded.isInValues(methodAdded)
        : Constant(true));
  }

  Expression<bool> onlyShowBasedOnBudgetFks(
      $TransactionsTable tbl, List<String?>? budgetFks) {
    return budgetFks != null && budgetFks.contains(null) && budgetFks.length > 1
        ? tbl.sharedReferenceBudgetPk
                .isIn(budgetFks.map((value) => value ?? "0").toList()) |
            tbl.sharedReferenceBudgetPk.isNull()
        : (budgetFks ?? []).contains(null)
            ? tbl.sharedReferenceBudgetPk.isNull()
            : (budgetFks != null && budgetFks.length > 0
                ? tbl.sharedReferenceBudgetPk
                    .isIn(budgetFks.map((value) => value ?? "0").toList())
                : Constant(true));
  }

  Expression<bool> onlyShowBasedOnExcludedBudgetFks(
      $TransactionsTable tbl, List<String>? excludedBudgetFks) {
    Expression<bool> result = Constant(true);
    for (String excludedBudgetFk in excludedBudgetFks ?? []) {
      result = result & tbl.budgetFksExclude.contains(excludedBudgetFk);
    }
    return result;
  }

  Expression<bool> onlyShowBasedOnObjectiveFks(
      $TransactionsTable tbl, List<String?>? objectiveFks) {
    return objectiveFks != null &&
            objectiveFks.contains(null) &&
            objectiveFks.length > 1
        ? tbl.objectiveFk
                .isIn(objectiveFks.map((value) => value ?? "0").toList()) |
            tbl.objectiveFk.isNull()
        : (objectiveFks ?? []).contains(null)
            ? tbl.objectiveFk.isNull()
            : (objectiveFks != null && objectiveFks.length > 0
                ? tbl.objectiveFk
                    .isIn(objectiveFks.map((value) => value ?? "0").toList())
                : Constant(true));
  }

  // Start date is in the past
  // End date is in the future
  // Start -> End
  Expression<bool> onlyShowBasedOnTimeRange($TransactionsTable tbl,
      DateTime? startDate, DateTime? endDate, Budget? budget,
      {bool? allTime = false}) {
    return (budget != null &&
            // Only if an Added only, Custom budget -> show all transactions belonging to it, even if outside the date range
            (budget.addedTransactionsOnly == true &&
                budget.sharedKey == null &&
                budget.reoccurrence == BudgetReoccurence.custom)
        ? Constant(true)
        : (allTime == true || (startDate == null && endDate == null)
            ? Constant(true)
            : startDate == null && endDate != null
                ? isOnDay(transactions.dateCreated, endDate) |
                    transactions.dateCreated.isSmallerOrEqualValue(endDate)
                : startDate != null && endDate == null
                    ? isOnDay(transactions.dateCreated, startDate) |
                        transactions.dateCreated.isBiggerOrEqualValue(startDate)
                    : isOnDay(transactions.dateCreated, endDate!) |
                        isOnDay(transactions.dateCreated, startDate!) |
                        transactions.dateCreated
                            .isBetweenValues(startDate, endDate)));
  }

  Expression<bool> onlyShowMainCategoryListing($CategoriesTable tbl) {
    return tbl.mainCategoryPk.isNull();
  }

  Expression<bool> onlyShowIfCertainBudget(
      $TransactionsTable tbl, String? budgetPk) {
    return (budgetPk != null
        ? tbl.sharedReferenceBudgetPk.equals(budgetPk)
        : Constant(true));
  }

  Expression<bool> onlyShowIfNotExcludedFromBudget(
      $TransactionsTable tbl, String? budgetPk) {
    return (budgetPk != null
        ? tbl.budgetFksExclude.isNull() |
            (tbl.budgetFksExclude.isNotNull() &
                tbl.budgetFksExclude.contains(budgetPk).not())
        : Constant(true));
  }

  Expression<bool> onlyShowIfCertainObjective(
      $TransactionsTable tbl, String? objectivePk) {
    return (objectivePk != null
        ? tbl.objectiveFk.equals(objectivePk)
        : Constant(true));
  }

  Stream<double?> watchTotalOfBudget({
    required AllWallets allWallets,
    required DateTime start,
    required DateTime end,
    required List<String>? categoryFks,
    required List<String>? categoryFksExclude,
    required List<BudgetTransactionFilters>? budgetTransactionFilters,
    required List<String>? memberTransactionFilters,
    String? member,
    String? onlyShowTransactionsBelongingToBudgetPk,
    Budget? budget,
    bool allTime = false,
    List<String>? walletPks,
    bool? isIncome = null,
    bool followCustomPeriodCycle = false,
    String? mainCategoryPkIfSubCategories,
    String cycleSettingsExtension = "",
    SearchFilters? searchFilters,
    DateTimeRange? forcedDateTimeRange,
    bool paidOnly = true,
  }) {
    DateTime startDate = DateTime(start.year, start.month, start.day);
    DateTime endDate = DateTime(end.year, end.month, end.day);
    // we have to convert currencies to account for all wallets
    List<Stream<double?>> mergedStreams = [];
    for (TransactionWallet wallet in allWallets.list) {
      if (walletPks != null && walletPks.contains(wallet.walletPk) == false)
        continue;
      final totalAmt = transactions.amount.sum();
      final query = selectOnly(transactions)
        ..addColumns([totalAmt])
        // This query should match that of the one below!
        // watchTotalSpentInEachCategoryInTimeRangeFromCategories
        // If you make changes to this, make changes here: watchTotalSpentInEachCategoryInTimeRangeFromCategories
        ..where(onlyShowIfFollowsSearchFilters(
              transactions,
              searchFilters,
              joinedWithSubcategoriesTable: null,
              joinedWithCategories: false,
              joinedWithBudgets: false,
              joinedWithObjectives: false,
            ) &
            onlyShowBasedOnTimeRange(transactions, startDate, endDate, budget,
                allTime: allTime) &
            isInCategory(transactions, categoryFks, categoryFksExclude) &
            onlyShowBasedOnWalletFks(transactions, budget?.walletFks) &
            onlyShowIfNotBalanceCorrection(transactions, isIncome) &
            onlyShowIfFollowCustomPeriodCycle(
              transactions,
              followCustomPeriodCycle,
              cycleSettingsExtension: cycleSettingsExtension,
              forcedDateTimeRange: forcedDateTimeRange,
            ) &
            (paidOnly == true
                ? transactions.paid.equals(true)
                : Constant(true)) &
            // evaluateIfNull(tbl.income.equals(income ?? false), income, true) &
            transactions.walletFk.equals(wallet.walletPk) &
            onlyShowIfFollowsFilters(transactions,
                budgetTransactionFilters: budgetTransactionFilters,
                memberTransactionFilters: memberTransactionFilters) &
            onlyShowIfMember(transactions, member) &
            onlyShowBasedOnIncome(transactions, isIncome) &
            onlyShowIfNotExcludedFromBudget(transactions, budget?.budgetPk) &
            onlyShowIfCertainBudget(
                transactions, onlyShowTransactionsBelongingToBudgetPk) &
            (mainCategoryPkIfSubCategories == null
                ? Constant(true)
                : transactions.categoryFk
                    .equals(mainCategoryPkIfSubCategories)));
      mergedStreams.add(query
          .map((row) =>
              (row.read(totalAmt) ?? 0) *
              (amountRatioToPrimaryCurrency(allWallets, wallet.currency)))
          .watchSingle());
    }
    return totalDoubleStream(mergedStreams);
  }

  // The total amount of that category will always be that last column
  // print(snapshot.data![0].rawData.data["transactions.category_fk"]);
  // print(snapshot.data![0].rawData.data["c" + (snapshot.data![0].rawData.data.length).toString()]);
  Stream<List<CategoryWithTotal>>
      watchTotalSpentInEachCategoryInTimeRangeFromCategories({
    required AllWallets allWallets,
    required DateTime start,
    required DateTime end,
    required List<String>? categoryFks,
    required List<String>? categoryFksExclude,
    required List<BudgetTransactionFilters>? budgetTransactionFilters,
    required List<String>? memberTransactionFilters,
    String? member,
    String? onlyShowTransactionsBelongingToBudgetPk,
    Budget? budget,
    bool allTime = false,
    List<String>? walletPks,
    bool? isIncome = null,
    bool followCustomPeriodCycle = false,
    String? mainCategoryPkIfSubCategories,
    bool includeAllSubCategories = false,
    // if a transaction does not have a subcategory assigned, does it show up in the total?
    bool countUnassignedTransactions = false,
    String cycleSettingsExtension = "",
    SearchFilters? searchFilters,
    DateTimeRange? forcedDateTimeRange,
    bool paidOnly = true,
  }) {
    DateTime startDate = DateTime(start.year, start.month, start.day);
    DateTime endDate = DateTime(end.year, end.month, end.day);
    List<Stream<List<CategoryWithTotal>>> mergedStreams = [];

    for (TransactionWallet wallet in allWallets.list) {
      if (walletPks != null && walletPks.contains(wallet.walletPk) == false)
        continue;
      final totalAmt = transactions.amount.sum();
      final totalCount = transactions.transactionPk.count();

      final query = (select(transactions)
        ..where((tbl) {
          // This query should match that of the one above!
          // watchTotalOfBudget
          // If you make changes to this, make changes here: watchTotalOfBudget
          return onlyShowIfFollowsSearchFilters(
                tbl,
                searchFilters,
                joinedWithSubcategoriesTable: null,
                joinedWithCategories: false,
                joinedWithBudgets: false,
                joinedWithObjectives: false,
              ) &
              onlyShowBasedOnTimeRange(transactions, startDate, endDate, budget,
                  allTime: allTime) &
              isInCategory(tbl, categoryFks, categoryFksExclude) &
              onlyShowBasedOnWalletFks(tbl, budget?.walletFks) &
              onlyShowIfNotBalanceCorrection(transactions, isIncome) &
              onlyShowIfFollowCustomPeriodCycle(
                transactions,
                followCustomPeriodCycle,
                cycleSettingsExtension: cycleSettingsExtension,
                forcedDateTimeRange: forcedDateTimeRange,
              ) &
              (paidOnly == true ? tbl.paid.equals(true) : Constant(true)) &
              // evaluateIfNull(tbl.income.equals(income ?? false), income, true) &
              transactions.walletFk.equals(wallet.walletPk) &
              onlyShowIfFollowsFilters(tbl,
                  budgetTransactionFilters: budgetTransactionFilters,
                  memberTransactionFilters: memberTransactionFilters) &
              onlyShowIfMember(tbl, member) &
              onlyShowBasedOnIncome(tbl, isIncome) &
              onlyShowIfNotExcludedFromBudget(tbl, budget?.budgetPk) &
              onlyShowIfCertainBudget(
                  tbl, onlyShowTransactionsBelongingToBudgetPk) &
              (mainCategoryPkIfSubCategories == null
                  ? Constant(true)
                  : transactions.categoryFk
                      .equals(mainCategoryPkIfSubCategories));
        })
        ..orderBy([(c) => OrderingTerm.desc(c.dateCreated)]));
      mergedStreams.add((query.join([
        leftOuterJoin(
            categories,
            includeAllSubCategories == true
                ? ((categories.categoryPk
                            .equalsExp(transactions.subCategoryFk) &
                        transactions.subCategoryFk.isNotNull()) |
                    (countUnassignedTransactions == true
                        ? categories.categoryPk
                            .equalsExp(transactions.categoryFk)
                        : (categories.categoryPk
                                .equalsExp(transactions.categoryFk) &
                            transactions.subCategoryFk.isNull())))
                : mainCategoryPkIfSubCategories == null
                    ? categories.categoryPk.equalsExp(transactions.categoryFk)
                    : (categories.categoryPk
                            .equalsExp(transactions.subCategoryFk) |
                        categories.categoryPk
                            .equalsExp(transactions.categoryFk))),
        leftOuterJoin(
            categoryBudgetLimits,
            categoryBudgetLimits.categoryFk.equalsExp(categories.categoryPk) &
                evaluateIfNull(
                    categoryBudgetLimits.budgetFk
                        .equals(budget?.budgetPk ?? "0"),
                    budget,
                    false))
      ])
            ..addColumns([totalAmt, totalCount])
            ..groupBy([categories.categoryPk]))
          // totalCategoryTotalStream takes care of the ordering!
          .map((row) {
        final TransactionCategory category = row.readTable(categories);
        CategoryBudgetLimit? categoryBudgetLimit =
            row.readTableOrNull(categoryBudgetLimits);

        final double? total = (row.read(totalAmt) ?? 0) *
            (amountRatioToPrimaryCurrency(allWallets, wallet.currency));
        final int? transactionCount = row.read(totalCount);
        return CategoryWithTotal(
            category: category,
            categoryBudgetLimit: categoryBudgetLimit,
            total: total ?? 0,
            transactionCount: transactionCount ?? -1);
      }).watch());
    }

    return totalCategoryTotalStream(mergedStreams);

    // Stream<List<TransactionCategory>> allCategoriesWatched =
    //     watchAllCategories();

    // return StreamZip(mergedStreams).map((values) {
    //   List<CategoryWithTotal> allCategoriesWithTotals = [];
    //   for (List<CategoryWithTotal> categoriesWithTotal in values) {
    //     allCategoriesWithTotals.addAll(categoriesWithTotal);
    //   }
    //   // Add categories with total amount of 0
    //   allCategoriesWatched
    //       .expand((categories) => categories)
    //       .forEach((TransactionCategory category) {
    //     if (!allCategoriesWithTotals
    //         .any((c) => c.category.categoryPk == category.categoryPk)) {
    //       allCategoriesWithTotals.add(CategoryWithTotal(
    //           category: category, total: 0, transactionCount: 0));
    //     }
    //   });
    //   return allCategoriesWithTotals;
    // });
  }

  Stream<double?> watchTotalOfWallet(
    List<String>? walletPks, {
    bool? isIncome = null,
    DateTime? startDate,
    required AllWallets allWallets,
    bool followCustomPeriodCycle = false,
    String cycleSettingsExtension = "",
    SearchFilters? searchFilters,
    DateTimeRange? forcedDateTimeRange,
  }) {
    // we have to convert currencies to account for all wallets
    List<Stream<double?>> mergedStreams = [];
    for (TransactionWallet wallet in allWallets.list) {
      final totalAmt = transactions.amount.sum();
      final query = selectOnly(transactions)
        ..addColumns([totalAmt])
        ..where(onlyShowIfFollowsSearchFilters(transactions, searchFilters,
                joinedWithSubcategoriesTable: null,
                joinedWithCategories: false,
                joinedWithBudgets: false,
                joinedWithObjectives: false) &
            transactions.walletFk.equals(wallet.walletPk) &
            onlyShowIfNotBalanceCorrection(transactions, isIncome) &
            transactions.paid.equals(true) &
            onlyShowIfFollowCustomPeriodCycle(
              transactions,
              followCustomPeriodCycle,
              cycleSettingsExtension: cycleSettingsExtension,
              forcedDateTimeRange: forcedDateTimeRange,
            ) &
            evaluateIfNull(
                transactions.walletFk.isIn(walletPks ?? []), walletPks, true) &
            onlyShowBasedOnTimeRange(transactions, startDate, null, null) &
            evaluateIfNull(
                transactions.income.equals(isIncome ?? true), isIncome, true) &
            onlyShowBasedOnIncome(transactions, isIncome));
      mergedStreams.add(query
          .map((row) =>
              (row.read(totalAmt) ?? 0) *
              (amountRatioToPrimaryCurrency(allWallets, wallet.currency)))
          .watchSingle());
    }
    return totalDoubleStream(mergedStreams);
  }

  Stream<double?> watchTotalOfWalletNoConversion(
    String walletPk, {
    bool? isIncome = null,
    DateTime? startDate,
  }) {
    final totalAmt = transactions.amount.sum();
    final query = selectOnly(transactions)
      ..addColumns([totalAmt])
      ..where((startDate == null
              ? Constant(true)
              : transactions.dateCreated.isBiggerThanValue(startDate)) &
          (isIncome == null
              ? Constant(true)
              : isIncome == true
                  ? transactions.income.equals(true)
                  : transactions.income.equals(false)) &
          transactions.walletFk.equals(walletPk) &
          onlyShowIfNotBalanceCorrection(transactions, isIncome) &
          transactions.paid.equals(true));
    return query.map((row) => row.read(totalAmt)).watchSingleOrNull();
  }

  Stream<List<int?>> watchTotalCountOfTransactionsInWallet(
    List<String>? walletPks, {
    bool? isIncome = null,
    DateTime? startDate,
    bool followCustomPeriodCycle = false,
    String cycleSettingsExtension = "",
    SearchFilters? searchFilters,
    DateTimeRange? forcedDateTimeRange,
  }) {
    final totalCount = transactions.transactionPk.count();
    final query = selectOnly(transactions)
      ..addColumns([totalCount])
      ..where((onlyShowIfFollowsSearchFilters(transactions, searchFilters,
                  joinedWithSubcategoriesTable: null,
                  joinedWithCategories: false,
                  joinedWithBudgets: false,
                  joinedWithObjectives: false) &
              (isIncome == null
                  ? transactions.walletFk.isNotNull()
                  : isIncome == true
                      ? transactions.income.equals(true)
                      : transactions.income.equals(false))) &
          onlyShowIfNotBalanceCorrection(transactions, isIncome) &
          onlyShowIfFollowCustomPeriodCycle(
              transactions, followCustomPeriodCycle,
              cycleSettingsExtension: cycleSettingsExtension,
              forcedDateTimeRange: forcedDateTimeRange) &
          onlyShowBasedOnTimeRange(transactions, startDate, null, null) &
          evaluateIfNull(
              transactions.walletFk.isIn(walletPks ?? []), walletPks, true));
    return query.map((row) => row.read(totalCount)).watch();
  }

  Stream<double?> watchTotalOfUpcomingOverdue(
    AllWallets allWallets,
    bool? isOverdueTransactions, {
    String? searchString,
    bool followCustomPeriodCycle = false,
    String cycleSettingsExtension = "",
  }) {
    List<Stream<double?>> mergedStreams = [];
    for (TransactionWallet wallet in allWallets.list) {
      final totalAmt = transactions.amount.sum();
      final $CategoriesTable subCategories = alias(categories, 'subCategories');
      final query = selectOnly(transactions)
        ..addColumns([totalAmt])
        ..join([
          innerJoin(categories,
              categories.categoryPk.equalsExp(transactions.categoryFk)),
          leftOuterJoin(subCategories,
              subCategories.categoryPk.equalsExp(transactions.subCategoryFk)),
        ])
        ..where(onlyShowIfFollowCustomPeriodCycle(
              transactions,
              followCustomPeriodCycle,
              cycleSettingsExtension: cycleSettingsExtension,
            ) &
            onlyShowTransactionBasedOnSearchQuery(transactions, searchString,
                withCategories: true,
                joinedWithSubcategoriesTable: subCategories) &
            // transactions.income.equals(false) &
            transactions.skipPaid.equals(false) &
            transactions.paid.equals(false) &
            transactions.walletFk.equals(wallet.walletPk) &
            (isOverdueTransactions == null
                ? Constant(true)
                : isOverdueTransactions == true
                    ? transactions.dateCreated
                        .isSmallerThanValue(DateTime.now())
                    : transactions.dateCreated
                        .isBiggerThanValue(DateTime.now())) &
            (transactions.type
                    .equals(TransactionSpecialType.subscription.index) |
                transactions.type
                    .equals(TransactionSpecialType.repetitive.index) |
                transactions.type
                    .equals(TransactionSpecialType.upcoming.index)));
      mergedStreams.add(query
          .map((row) =>
              (row.read(totalAmt) ?? 0) *
              (amountRatioToPrimaryCurrency(allWallets, wallet.currency)))
          .watchSingle());
    }
    return totalDoubleStream(mergedStreams);
  }

  Stream<List<int?>> watchCountOfUpcomingOverdue(
    bool? isOverdueTransactions, {
    String? searchString,
    bool followCustomPeriodCycle = false,
    String cycleSettingsExtension = "",
  }) {
    final totalCount = transactions.transactionPk.count();
    final $CategoriesTable subCategories = alias(categories, 'subCategories');

    final query = selectOnly(transactions)
      ..addColumns([totalCount])
      ..join([
        innerJoin(categories,
            categories.categoryPk.equalsExp(transactions.categoryFk)),
        leftOuterJoin(subCategories,
            subCategories.categoryPk.equalsExp(transactions.subCategoryFk)),
      ])
      ..where(onlyShowIfFollowCustomPeriodCycle(
            transactions,
            followCustomPeriodCycle,
            cycleSettingsExtension: cycleSettingsExtension,
          ) &
          onlyShowTransactionBasedOnSearchQuery(transactions, searchString,
              withCategories: true,
              joinedWithSubcategoriesTable: subCategories) &
          transactions.skipPaid.equals(false) &
          transactions.paid.equals(false) &
          (isOverdueTransactions == null
              ? Constant(true)
              : isOverdueTransactions == true
                  ? transactions.dateCreated.isSmallerThanValue(DateTime.now())
                  : transactions.dateCreated
                      .isBiggerThanValue(DateTime.now())) &
          (transactions.type.equals(TransactionSpecialType.subscription.index) |
              transactions.type
                  .equals(TransactionSpecialType.repetitive.index) |
              transactions.type.equals(TransactionSpecialType.upcoming.index)));
    return query.map((row) => row.read(totalCount)).watch();
  }

  Stream<double?> watchTotalOfCreditDebt(
    AllWallets allWallets,
    bool? isCredit, {
    String? searchString,
    bool followCustomPeriodCycle = false,
    String cycleSettingsExtension = "",
  }) {
    List<Stream<double?>> mergedStreams = [];
    for (TransactionWallet wallet in allWallets.list) {
      final totalAmt = transactions.amount.sum();
      final $CategoriesTable subCategories = alias(categories, 'subCategories');
      final query = selectOnly(transactions)
        ..addColumns([totalAmt])
        ..join([
          innerJoin(categories,
              categories.categoryPk.equalsExp(transactions.categoryFk)),
          leftOuterJoin(subCategories,
              subCategories.categoryPk.equalsExp(transactions.subCategoryFk)),
        ])
        ..where(onlyShowIfFollowCustomPeriodCycle(
              transactions,
              followCustomPeriodCycle,
              cycleSettingsExtension: cycleSettingsExtension,
            ) &
            transactions.paid.equals(true) &
            onlyShowTransactionBasedOnSearchQuery(transactions, searchString,
                withCategories: true,
                joinedWithSubcategoriesTable: subCategories) &
            transactions.walletFk.equals(wallet.walletPk) &
            (isCredit == null
                ? transactions.type
                        .equals(TransactionSpecialType.credit.index) |
                    transactions.type.equals(TransactionSpecialType.debt.index)
                : isCredit
                    ? transactions.type
                        .equals(TransactionSpecialType.credit.index)
                    : transactions.type
                        .equals(TransactionSpecialType.debt.index)));
      mergedStreams.add(query
          .map((row) =>
              (row.read(totalAmt) ?? 0) *
              (amountRatioToPrimaryCurrency(allWallets, wallet.currency)))
          .watchSingle());
    }
    return totalDoubleStream(mergedStreams);
  }

  Stream<List<int?>> watchCountOfCreditDebt(
    bool? isCredit,
    String? searchString, {
    bool followCustomPeriodCycle = false,
    String cycleSettingsExtension = "",
  }) {
    final totalCount = transactions.transactionPk.count();
    final $CategoriesTable subCategories = alias(categories, 'subCategories');

    final query = selectOnly(transactions)
      ..addColumns([totalCount])
      ..join([
        innerJoin(categories,
            categories.categoryPk.equalsExp(transactions.categoryFk)),
        leftOuterJoin(subCategories,
            subCategories.categoryPk.equalsExp(transactions.subCategoryFk)),
      ])
      ..where(onlyShowIfFollowCustomPeriodCycle(
            transactions,
            followCustomPeriodCycle,
            cycleSettingsExtension: cycleSettingsExtension,
          ) &
          transactions.paid.equals(true) &
          onlyShowTransactionBasedOnSearchQuery(transactions, searchString,
              withCategories: true,
              joinedWithSubcategoriesTable: subCategories) &
          (isCredit == null
              ? transactions.type.equals(TransactionSpecialType.credit.index) |
                  transactions.type.equals(TransactionSpecialType.debt.index)
              : isCredit
                  ? transactions.type
                      .equals(TransactionSpecialType.credit.index)
                  : transactions.type
                      .equals(TransactionSpecialType.debt.index)));
    return query.map((row) => row.read(totalCount)).watch();
  }

  Stream<List<Transaction>> watchAllCreditDebtTransactions(
      bool? isCredit, String? searchString) {
    final $CategoriesTable subCategories = alias(categories, 'subCategories');
    final query = select(transactions).join([
      innerJoin(
          categories, categories.categoryPk.equalsExp(transactions.categoryFk)),
      leftOuterJoin(subCategories,
          subCategories.categoryPk.equalsExp(transactions.subCategoryFk)),
    ])
      ..orderBy([
        OrderingTerm.desc(transactions.paid),
        OrderingTerm.desc(transactions.dateCreated),
      ])
      ..where(onlyShowTransactionBasedOnSearchQuery(transactions, searchString,
              withCategories: true,
              joinedWithSubcategoriesTable: subCategories) &
          (isCredit == null
              ? transactions.type.equals(TransactionSpecialType.credit.index) |
                  transactions.type.equals(TransactionSpecialType.debt.index)
              : isCredit
                  ? transactions.type
                      .equals(TransactionSpecialType.credit.index)
                  : transactions.type
                      .equals(TransactionSpecialType.debt.index)));
    return query.map((row) => row.readTable(transactions)).watch();
  }

  Stream<List<int?>> watchTotalCountOfTransactionsInCategory(
      String categoryPk) {
    final totalCount = transactions.transactionPk.count();
    final query = selectOnly(transactions)
      ..addColumns([totalCount])
      ..where(transactions.categoryFk.equals(categoryPk));
    return query.map((row) => row.read(totalCount)).watch();
  }

  Stream<List<int?>> watchTotalCountOfTransactionsInSubCategory(
      String categoryPk) {
    final totalCount = transactions.transactionPk.count();
    final query = selectOnly(transactions)
      ..addColumns([totalCount])
      ..where(transactions.subCategoryFk.equals(categoryPk));
    return query.map((row) => row.read(totalCount)).watch();
  }

  Future<List<int?>> getTotalCountOfCategories() async {
    final totalCount = categories.categoryPk.count();
    final query = selectOnly(categories)..addColumns([totalCount]);
    return query.map((row) => row.read(totalCount)).get();
  }

  Future<List<int?>> getTotalCountOfWallets() async {
    final totalCount = wallets.walletPk.count();
    final query = selectOnly(wallets)..addColumns([totalCount]);
    return query.map((row) => row.read(totalCount)).get();
  }

  Future<List<int?>> getTotalCountOfObjectives() async {
    final totalCount = objectives.objectivePk.count();
    final query = selectOnly(objectives)..addColumns([totalCount]);
    return query.map((row) => row.read(totalCount)).get();
  }

  Future<int?> getTotalCountOfTransactionsInBudget(String budgetPk) async {
    final totalCount = transactions.transactionPk.count();
    final query = selectOnly(transactions)
      ..where(transactions.sharedReferenceBudgetPk.equals(budgetPk))
      ..addColumns([totalCount]);
    final result = await query.map((row) => row.read(totalCount)).getSingle();
    return result;
  }

  (Stream<int?>, Future<int?>) getTotalCountOfTransactionsInObjective(
      String objectivePk) {
    final totalCount = transactions.transactionPk.count();
    final query = selectOnly(transactions)
      ..where(transactions.objectiveFk.equals(objectivePk))
      ..addColumns([totalCount]);
    final result = query.map((row) => row.read(totalCount));
    return (result.watchSingle(), result.getSingle());
  }

  // get all transactions that occurred in a given time period that belong to categories
  Stream<List<Transaction>> getTransactionsInTimeRangeFromCategories(
    DateTime start,
    DateTime end,
    List<String>? categoryFks,
    List<String>? categoryFksExclude,
    bool isPaidOnly,
    bool? isIncome,
    List<BudgetTransactionFilters>? budgetTransactionFilters,
    List<String>? memberTransactionFilters, {
    String? member,
    String? onlyShowTransactionsBelongingToBudgetPk,
    Budget? budget,
    List<String>? walletPks,
    bool followCustomPeriodCycle = false,
    String cycleSettingsExtension = "",
    SearchFilters? searchFilters,
    DateTimeRange? forcedDateTimeRange,
  }) {
    DateTime startDate = DateTime(start.year, start.month, start.day);
    DateTime endDate = DateTime(end.year, end.month, end.day);
    return (select(transactions)
          ..where((tbl) {
            return onlyShowIfFollowsSearchFilters(transactions, searchFilters,
                    joinedWithSubcategoriesTable: null,
                    joinedWithCategories: false,
                    joinedWithBudgets: false,
                    joinedWithObjectives: false) &
                isInCategory(tbl, categoryFks, categoryFksExclude) &
                evaluateIfNull(tbl.paid.equals(true), isPaidOnly, true) &
                onlyShowIfFollowCustomPeriodCycle(
                  transactions,
                  followCustomPeriodCycle,
                  cycleSettingsExtension: cycleSettingsExtension,
                  forcedDateTimeRange: forcedDateTimeRange,
                ) &
                onlyShowIfFollowsFilters(tbl,
                    budgetTransactionFilters: budgetTransactionFilters,
                    memberTransactionFilters: memberTransactionFilters) &
                onlyShowBasedOnTimeRange(tbl, startDate, endDate, budget) &
                onlyShowIfMember(tbl, member) &
                onlyShowIfNotExcludedFromBudget(tbl, budget?.budgetPk) &
                onlyShowIfCertainBudget(
                    tbl, onlyShowTransactionsBelongingToBudgetPk) &
                onlyShowBasedOnWalletFks(tbl, walletPks) &
                onlyShowBasedOnWalletFks(tbl, budget?.walletFks) &
                onlyShowBasedOnIncome(tbl, isIncome);
          })
          ..orderBy([(t) => OrderingTerm.desc(t.dateCreated)]))
        .watch();
  }

  Stream<double?> getTotalBeforeStartDateInTimeRangeFromCategories(
    DateTime start,
    List<String> categoryFks,
    bool allCategories,
    bool isPaidOnly,
    bool? isIncome,
    List<BudgetTransactionFilters>? budgetTransactionFilters,
    List<String>? memberTransactionFilters, {
    String? member,
    String? onlyShowTransactionsBelongingToBudgetPk,
    Budget? budget,
    List<String>? walletPks,
    required AllWallets allWallets,
    bool followCustomPeriodCycle = false,
    String cycleSettingsExtension = "",
    SearchFilters? searchFilters,
    DateTimeRange? forcedDateTimeRange,
  }) {
    // the date, which acts as the end point and everything before this day is inclusive
    // for onlyShowBasedOnTimeRange, but we don't want to include this day
    DateTime startDate = DateTime(start.year, start.month, start.day - 1);
    List<Stream<double?>> mergedStreams = [];
    for (TransactionWallet wallet in allWallets.list) {
      final totalAmt = transactions.amount.sum();
      final query = selectOnly(transactions)
        ..addColumns([totalAmt])
        ..where(onlyShowIfFollowsSearchFilters(transactions, searchFilters,
                joinedWithSubcategoriesTable: null,
                joinedWithCategories: false,
                joinedWithBudgets: false,
                joinedWithObjectives: false) &
            transactions.walletFk.equals(wallet.walletPk) &
            onlyShowIfFollowCustomPeriodCycle(
              transactions,
              followCustomPeriodCycle,
              cycleSettingsExtension: cycleSettingsExtension,
              forcedDateTimeRange: forcedDateTimeRange,
            ) &
            evaluateIfNull(transactions.categoryFk.isIn(categoryFks),
                categoryFks.length <= 0 ? null : true, true) &
            evaluateIfNull(transactions.paid.equals(true), isPaidOnly, true) &
            onlyShowIfFollowsFilters(transactions,
                budgetTransactionFilters: budgetTransactionFilters,
                memberTransactionFilters: memberTransactionFilters) &
            onlyShowBasedOnTimeRange(transactions, null, startDate, budget) &
            onlyShowIfMember(transactions, member) &
            onlyShowIfNotExcludedFromBudget(transactions, budget?.budgetPk) &
            onlyShowIfCertainBudget(
                transactions, onlyShowTransactionsBelongingToBudgetPk) &
            onlyShowBasedOnWalletFks(transactions, walletPks) &
            onlyShowBasedOnIncome(transactions, isIncome));
      mergedStreams.add(query
          .map((row) =>
              (row.read(totalAmt) ?? 0) *
              (amountRatioToPrimaryCurrency(allWallets, wallet.currency)))
          .watchSingle());
    }
    return totalDoubleStream(mergedStreams);
  }

  Future<Transaction> getTransactionFromPk(String transactionPk) {
    return (select(transactions)
          ..where((t) => t.transactionPk.equals(transactionPk)))
        .getSingle();
  }

  Future<List<Transaction>> getTransactionsFromPk(List<String> transactionPks) {
    return (select(transactions)
          ..where((t) => t.transactionPk.isIn(transactionPks)))
        .get();
  }

  // when a change is made we can listen to it, debounce and sync after debounce timer
  // this is handled in navigationFramework
  Stream<dynamic> watchAllForAutoSync() {
    StreamGroup streamGroup = StreamGroup<dynamic>();
    streamGroup.add(select(transactions).watch());
    streamGroup.add(select(categories).watch());
    streamGroup.add(select(wallets).watch());
    streamGroup.add(select(budgets).watch());
    streamGroup.add(select(categoryBudgetLimits).watch());
    streamGroup.add(select(associatedTitles).watch());
    streamGroup.add(select(objectives).watch());
    streamGroup.add(select(scannerTemplates).watch());
    return streamGroup.stream;
  }

  // transactions not belonging to a category should be deleted
  Future<bool> deleteWanderingTransactions() async {
    List<TransactionCategory> allCategories = await getAllCategories();
    List<String> categoryPks =
        allCategories.map((category) => category.categoryPk).toList();
    List<Transaction> wanderingTransactions = await (select(transactions)
          ..where((t) => t.categoryFk.isNotIn(categoryPks)))
        .get();
    for (Transaction transaction in wanderingTransactions) {
      await deleteTransaction(transaction.transactionPk,
          updateSharedEntry: true);
    }
    return true;
  }

  Future deleteAllDeleteLogs() async {
    await delete(deleteLogs).go();
  }

  Stream<List<DeleteLog>> watchAllDeleteLogs() {
    return (select(deleteLogs)).watch();
  }

  Stream<List<TransactionWithCount>> getCommonTransactions() {
    // Database dates stored in seconds since epoch
    final int threeMonthsAgo =
        DateTime.now().subtract(Duration(days: 60)).millisecondsSinceEpoch ~/
            1000;

    return customSelect(
      'SELECT *, COUNT(*) as "count" FROM transactions WHERE date_created >= $threeMonthsAgo GROUP BY transactions.category_fk, transactions.name ORDER BY count DESC, MAX(date_created) DESC LIMIT 5',
      readsFrom: {transactions},
    ).watch().map((rows) {
      return rows
          .map((row) => TransactionWithCount(
                transaction: transactions.map(row.data),
                count: row.read<int>('count'),
              ))
          .toList();
    });
  }

  // Created within a second, is of the opposite polarity
  // category type of balance transaction
  // Is not the current balance transaction
  Future<Transaction?> getCloselyRelatedBalanceCorrectionTransaction(
      Transaction originalBalanceCorrection) async {
    bool isOtherIncome = !originalBalanceCorrection.income;
    DateTime otherDateTime = originalBalanceCorrection.dateCreated;
    try {
      return (await (select(transactions)
                ..where(
                  (t) =>
                      t.categoryFk.equals("0") &
                      t.transactionPk
                          .equals(originalBalanceCorrection.transactionPk)
                          .not() &
                      t.income.equals(isOtherIncome) &
                      t.dateCreated.isBetweenValues(
                        DateTime(
                          otherDateTime.year,
                          otherDateTime.month,
                          otherDateTime.day,
                          otherDateTime.hour,
                          otherDateTime.minute,
                          otherDateTime.second - 1,
                        ),
                        DateTime(
                          otherDateTime.year,
                          otherDateTime.month,
                          otherDateTime.day,
                          otherDateTime.hour,
                          otherDateTime.minute,
                          otherDateTime.second + 1,
                        ),
                      ),
                ))
              .get())
          .firstOrNull;
    } catch (e) {
      print("No relating transfer transaction found");
    }
    return null;
  }

  // This corresponds to the logic set out when adding a transaction
  // A comparison is made with what fields are replaced
  Future updateCloselyRelatedBalanceTransfer(
    AllWallets allWallets,
    Transaction originalBalanceCorrection,
    Transaction closeBalanceCorrection,
  ) async {
    closeBalanceCorrection = originalBalanceCorrection.copyWith(
      transactionPk: closeBalanceCorrection.transactionPk,
      walletFk: closeBalanceCorrection.walletFk,
      name: closeBalanceCorrection.name,
      note: closeBalanceCorrection.note,
      income: closeBalanceCorrection.income,
      amount: originalBalanceCorrection.amount.abs() *
          double.parse(
            (closeBalanceCorrection.income
                    ? getAmountRatioWalletTransferTo(
                        allWallets,
                        closeBalanceCorrection.walletFk,
                        enteredAmountWalletPk:
                            originalBalanceCorrection.walletFk,
                      )
                    : getAmountRatioWalletTransferFrom(
                        allWallets,
                        closeBalanceCorrection.walletFk,
                        enteredAmountWalletPk:
                            originalBalanceCorrection.walletFk,
                      ))
                .toString(),
          ),
    );
    return await createOrUpdateTransaction(closeBalanceCorrection,
        insert: false);
  }

  Stream<List<Budget>> watchAllExcludedTransactionsBudgetsInUse() {
    return customSelect(
      "SELECT DISTINCT budgets.* FROM transactions INNER JOIN budgets ON transactions.budget_fks_exclude LIKE '%' || budgets.budget_pk || '%'",
      readsFrom: {transactions, budgets},
    ).watch().map((rows) {
      return rows.map((row) => budgets.map(row.data)).toList();
    });
  }
}

class TransactionWithCount {
  final Transaction transaction;
  final int count;

  TransactionWithCount({required this.transaction, required this.count});
}
