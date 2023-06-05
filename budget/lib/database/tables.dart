import 'dart:developer';

import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/firebaseAuthGlobal.dart';
import 'package:budget/struct/shareBudget.dart';
import 'package:budget/widgets/accountAndBackup.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:async/async.dart';
import 'package:drift/drift.dart';
export 'platform/shared.dart';
import 'dart:convert';
part 'tables.g.dart';

int schemaVersionGlobal = 34;

// Generate database code
// dart run build_runner build

// Character Limits
const int NAME_LIMIT = 250;
const int NOTE_LIMIT = 500;
const int COLOUR_LIMIT = 50;

// Query Constants
const int DEFAULT_LIMIT = 5000;
const int DEFAULT_OFFSET = 0;

enum BudgetReoccurence { custom, daily, weekly, monthly, yearly }

enum TransactionSpecialType {
  upcoming,
  subscription,
  repetitive,
}

enum SharedOwnerMember {
  owner,
  member,
}

enum BudgetTransactionFilters {
  addedToOtherBudget,
  sharedToOtherBudget,
}

const allBudgetTransactionFilters = [
  BudgetTransactionFilters.addedToOtherBudget,
  BudgetTransactionFilters.sharedToOtherBudget
];

enum ThemeSetting { dark, light }

enum MethodAdded { email, shared, csv }

enum SharedStatus { waiting, shared, error }

enum SearchFilters {
  income,
  expense,
  paid,
  unpaid,
}

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
    List<BudgetTransactionFilters> filters =
        ints.map((i) => BudgetTransactionFilters.values[i]).toList();
    return filters;
  }

  @override
  String toSql(List<BudgetTransactionFilters> filters) {
    List<int> ints = filters.map((filter) => filter.index).toList();
    return json.encode(ints);
  }
}

class StringListInColumnConverter extends TypeConverter<List<String>, String> {
  const StringListInColumnConverter();
  @override
  List<String> fromSql(String string_from_db) {
    return new List<String>.from(json.decode(string_from_db));
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
}

enum UpdateLogType {
  TransactionWallet,
  TransactionCategory,
  Budget,
  CategoryBudgetLimit,
  Transaction,
  TransactionAssociatedTitle,
  ScannerTemplate,
}

@DataClassName('DeleteLog')
class DeleteLogs extends Table {
  IntColumn get deleteLogPk => integer().autoIncrement()();
  IntColumn get type => intEnum<DeleteLogType>()();
  IntColumn get entryPk => integer()();
  DateTimeColumn get dateTimeModified =>
      dateTime().withDefault(Constant(DateTime.now()))();
}

@DataClassName('TransactionWallet')
class Wallets extends Table {
  IntColumn get walletPk => integer().autoIncrement()();
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
}

@DataClassName('Transaction')
class Transactions extends Table {
  IntColumn get transactionPk => integer().autoIncrement()();
  TextColumn get name => text().withLength(max: NAME_LIMIT)();
  RealColumn get amount => real()();
  TextColumn get note => text().withLength(max: NOTE_LIMIT)();
  IntColumn get categoryFk => integer().references(Categories, #categoryPk)();
  IntColumn get walletFk => integer().references(Wallets, #walletPk)();
  // TextColumn get labelFks =>
  //     text().map(const IntListInColumnConverter()).nullable()();
  DateTimeColumn get dateCreated =>
      dateTime().clientDefault(() => new DateTime.now())();
  DateTimeColumn get dateTimeCreated =>
      dateTime().withDefault(Constant(DateTime.now())).nullable()();
  DateTimeColumn get dateTimeModified =>
      dateTime().withDefault(Constant(DateTime.now())).nullable()();
  BoolColumn get income => boolean().withDefault(const Constant(false))();
  // Subscriptions and Repetitive payments
  IntColumn get periodLength => integer().nullable()();
  IntColumn get reoccurrence => intEnum<BudgetReoccurence>().nullable()();
  BoolColumn get upcomingTransactionNotification =>
      boolean().withDefault(const Constant(true)).nullable()();
  IntColumn get type => intEnum<TransactionSpecialType>().nullable()();
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
  IntColumn get sharedReferenceBudgetPk => integer().nullable()();
}

@DataClassName('TransactionCategory')
class Categories extends Table {
  IntColumn get categoryPk => integer().autoIncrement()();
  TextColumn get name => text().withLength(max: NAME_LIMIT)();
  TextColumn get colour => text().withLength(max: COLOUR_LIMIT).nullable()();
  TextColumn get iconName => text().nullable()();
  DateTimeColumn get dateCreated =>
      dateTime().clientDefault(() => new DateTime.now())();
  DateTimeColumn get dateTimeModified =>
      dateTime().withDefault(Constant(DateTime.now())).nullable()();
  IntColumn get order => integer()();
  BoolColumn get income => boolean().withDefault(const Constant(false))();
  IntColumn get methodAdded => intEnum<MethodAdded>().nullable()();
  // Attributes to configure sharing of transactions:
  // sharedKey will have the key referencing the entry in the firebase database, if this is null, it is not shared
  // TextColumn get sharedKey => text().nullable()();
  // IntColumn get sharedOwnerMember => intEnum<SharedOwnerMember>().nullable()();
  // DateTimeColumn get sharedDateUpdated => dateTime().nullable()();
  // TextColumn get sharedMembers =>
  //     text().map(const StringListInColumnConverter()).nullable()();
}

@DataClassName('CategoryBudgetLimit')
class CategoryBudgetLimits extends Table {
  IntColumn get categoryLimitPk => integer().autoIncrement()();
  IntColumn get categoryFk => integer().references(Categories, #categoryPk)();
  IntColumn get budgetFk => integer().references(Budgets, #budgetPk)();
  RealColumn get amount => real()();
  DateTimeColumn get dateTimeModified =>
      dateTime().withDefault(Constant(DateTime.now())).nullable()();
}

//If a title is in a smart label, automatically choose this category
// For e.g. for Food category
// smartLabels = ["apple", "pear"]
// Then when user sets title to pineapple, it will set the category to Food. Because "apple" is in "pineapple".
@DataClassName('TransactionAssociatedTitle')
class AssociatedTitles extends Table {
  IntColumn get associatedTitlePk => integer().autoIncrement()();
  TextColumn get title => text().withLength(max: NAME_LIMIT)();
  IntColumn get categoryFk => integer().references(Categories, #categoryPk)();
  DateTimeColumn get dateCreated =>
      dateTime().clientDefault(() => new DateTime.now())();
  DateTimeColumn get dateTimeModified =>
      dateTime().withDefault(Constant(DateTime.now())).nullable()();
  IntColumn get order => integer()();
  BoolColumn get isExactMatch => boolean().withDefault(const Constant(false))();
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
  IntColumn get budgetPk => integer().autoIncrement()();
  TextColumn get name => text().withLength(max: NAME_LIMIT)();
  RealColumn get amount => real()();
  TextColumn get colour => text()
      .withLength(max: COLOUR_LIMIT)
      .nullable()(); // if null we are using the themes color
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  TextColumn get categoryFks =>
      text().map(const IntListInColumnConverter()).nullable()();
  BoolColumn get allCategoryFks => boolean()();
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
  IntColumn get walletFk => integer().references(Wallets, #walletPk)();
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
}
// Server entry

@DataClassName('AppSetting')
class AppSettings extends Table {
  IntColumn get settingsPk => integer().autoIncrement()();
  TextColumn get settingsJSON =>
      text()(); // This is the JSON stored as a string for shared prefs 'userSettings'
  DateTimeColumn get dateUpdated =>
      dateTime().clientDefault(() => new DateTime.now())();
}

@DataClassName('ScannerTemplate')
class ScannerTemplates extends Table {
  IntColumn get scannerTemplatePk => integer().autoIncrement()();
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
  IntColumn get defaultCategoryFk =>
      integer().references(Categories, #categoryPk)();
  IntColumn get walletFk => integer().references(Wallets, #walletPk)();
  // TODO: if it contains certain keyword ignore these emails
  BoolColumn get ignore => boolean().withDefault(const Constant(false))();
}

class TransactionWithCategory {
  final TransactionCategory category;
  final Transaction transaction;
  TransactionWithCategory({required this.category, required this.transaction});
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
}

// when adding a new table, make sure to enable syncing and that
// all relevant delete queries create delete logs
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
])
class FinanceDatabase extends _$FinanceDatabase {
  // FinanceDatabase() : super(_openConnection());
  FinanceDatabase(QueryExecutor e) : super(e);

  // you should bump this number whenever you change or add a table definition
  @override
  int get schemaVersion => schemaVersionGlobal;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (migrator, from, to) async {
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
            await migrator.addColumn(
                transactions, transactions.dateTimeCreated);
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
              await migrator.addColumn(
                  budgets, budgets.budgetTransactionFilters);
            } catch (e) {
              print(e.toString);
            }
            try {
              await migrator.addColumn(
                  budgets, budgets.memberTransactionFilters);
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
          if (from <= 33) {
            await migrator.addColumn(wallets, wallets.decimals);
          }
        },
      );

  Future<void> deleteEverything() {
    return transaction(() async {
      for (final table in allTables) {
        await delete(table).go();
      }
    });
  }

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
    DateTime date, {
    String search = "",
    // Search will be ignored... if these params are passed in
    List<int> categoryFks = const [],
    List<int> walletFks = const [],
    bool? income,
    required List<BudgetTransactionFilters>? budgetTransactionFilters,
    required List<String>? memberTransactionFilters,
    String? member,
    int? onlyShowTransactionsBelongingToBudget,
  }) {
    JoinedSelectStatement<HasResultSet, dynamic> query;
    if (categoryFks.length > 0) {
      query = (select(transactions)
            ..where((tbl) {
              final dateCreated = tbl.dateCreated;
              return onlyShowIfFollowsFilters(tbl,
                      budgetTransactionFilters: budgetTransactionFilters,
                      memberTransactionFilters: memberTransactionFilters) &
                  isOnDay(dateCreated, date) &
                  onlyShowBasedOnCategoryFks(tbl, categoryFks) &
                  onlyShowBasedOnWalletFks(tbl, walletFks) &
                  onlyShowBasedOnIncome(tbl, income) &
                  onlyShowIfMember(tbl, member) &
                  onlyShowIfCertainBudget(
                      tbl, onlyShowTransactionsBelongingToBudget);
            })
          // ..orderBy([(t) => OrderingTerm.asc(t.dateTimeCreated)])
          )
          .join([
        innerJoin(categories,
            categories.categoryPk.equalsExp(transactions.categoryFk))
      ]);
    } else if (search == "") {
      query = (select(transactions)
            ..where((tbl) {
              final dateCreated = tbl.dateCreated;
              return onlyShowIfFollowsFilters(tbl,
                      budgetTransactionFilters: budgetTransactionFilters,
                      memberTransactionFilters: memberTransactionFilters) &
                  isOnDay(dateCreated, date) &
                  onlyShowBasedOnIncome(tbl, income) &
                  onlyShowIfMember(tbl, member) &
                  onlyShowIfCertainBudget(
                      tbl, onlyShowTransactionsBelongingToBudget);
            })
          // ..orderBy([(t) => OrderingTerm.asc(t.dateTimeCreated)])
          )
          .join([
        innerJoin(categories,
            categories.categoryPk.equalsExp(transactions.categoryFk))
      ]);
    } else {
      query = ((select(transactions)
            ..where((tbl) {
              final dateCreated = tbl.dateCreated;
              return onlyShowIfFollowsFilters(tbl,
                      budgetTransactionFilters: budgetTransactionFilters,
                      memberTransactionFilters: memberTransactionFilters) &
                  isOnDay(dateCreated, date) &
                  onlyShowBasedOnIncome(tbl, income) &
                  onlyShowIfMember(tbl, member) &
                  onlyShowIfCertainBudget(
                      tbl, onlyShowTransactionsBelongingToBudget);
            })
          // ..orderBy([(t) => OrderingTerm.asc(t.dateTimeCreated)])
          )
          .join([
        innerJoin(categories,
            categories.categoryPk.equalsExp(transactions.categoryFk))
      ]))
        ..where(categories.name.lower().like("%" + search.toLowerCase() + "%") |
            transactions.name.lower().like("%" + search.toLowerCase() + "%") |
            transactions.note.lower().like("%" + search.toLowerCase() + "%"));
    }

    return query.watch().map((rows) => rows.map((row) {
          return TransactionWithCategory(
              category: row.readTable(categories),
              transaction: row.readTable(transactions));
        }).toList());
  }

  Expression<bool> isOnDay(
      GeneratedColumn<DateTime> dateColumn, DateTime date) {
    return dateColumn.isBetweenValues(
        DateTime(date.year, date.month, date.day),
        DateTime(date.year, date.month, date.day + 1)
            .subtract(Duration(microseconds: 1)));
  }

  Stream<List<DateTime?>> getUniqueDates({
    required DateTime? start,
    required DateTime? end,
    String search = "",
    // Search will be ignored... if these params are passed in
    List<int> categoryFks = const [],
    List<int> walletFks = const [],
    bool? income,
    required List<BudgetTransactionFilters>? budgetTransactionFilters,
    required List<String>? memberTransactionFilters,
    String? member,
    int? onlyShowTransactionsBelongingToBudget,
    Budget? budget,
    int? limit,
  }) {
    DateTime? startDate =
        start == null ? null : DateTime(start.year, start.month, start.day);
    DateTime? endDate =
        end == null ? null : DateTime(end.year, end.month, end.day);

    final query = selectOnly(transactions, distinct: true)
      ..join([
        leftOuterJoin(categories,
            categories.categoryPk.equalsExp(transactions.categoryFk))
      ])
      ..orderBy(limit == null
          ? [OrderingTerm.asc(transactions.dateCreated)]
          : [OrderingTerm.desc(transactions.dateCreated)])
      ..where((categories.name.lower().like("%" + search.toLowerCase() + "%") |
              transactions.name.like("%" + search + "%")) &
          onlyShowIfFollowsFilters(transactions,
              budgetTransactionFilters: budgetTransactionFilters,
              memberTransactionFilters: memberTransactionFilters) &
          onlyShowBasedOnTimeRange(transactions, startDate, endDate, budget) &
          onlyShowBasedOnCategoryFks(transactions, categoryFks) &
          onlyShowBasedOnWalletFks(transactions, walletFks) &
          onlyShowBasedOnIncome(transactions, income) &
          onlyShowIfMember(transactions, member) &
          onlyShowIfCertainBudget(
              transactions, onlyShowTransactionsBelongingToBudget))
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

  Stream<List<TransactionWithCategory>> getTransactionCategoryWithMonth(
    DateTime date, {
    String search = "",
    // Search will be ignored... if these params are passed in
    List<int> categoryFks = const [],
  }) {
    JoinedSelectStatement<HasResultSet, dynamic> query;
    if (categoryFks.length > 0) {
      query = (select(transactions)
            ..where((tbl) {
              final dateCreated = tbl.dateCreated;
              return isOnDay(dateCreated, date) &
                  tbl.categoryFk.isIn(categoryFks);
            }))
          .join([
        leftOuterJoin(categories,
            categories.categoryPk.equalsExp(transactions.categoryFk))
      ]);
    } else if (search == "") {
      query = (select(transactions)
            ..where((tbl) {
              final dateCreated = tbl.dateCreated;
              return isOnDay(dateCreated, date);
            }))
          .join([
        leftOuterJoin(categories,
            categories.categoryPk.equalsExp(transactions.categoryFk))
      ]);
    } else {
      query = ((select(transactions)
            ..where((tbl) {
              final dateCreated = tbl.dateCreated;
              return isOnDay(dateCreated, date);
            }))
          .join([
        innerJoin(categories,
            categories.categoryPk.equalsExp(transactions.categoryFk))
      ]))
        ..where(categories.name.lower().like("%" + search.toLowerCase() + "%") |
            transactions.name.like("%" + search + "%"));
    }

    return query.watch().map((rows) => rows.map((row) {
          return TransactionWithCategory(
              category: row.readTable(categories),
              transaction: row.readTable(transactions));
        }).toList());
  }

  //get the days that a transaction occurs on, specify search term, categories, or time period to list these
  Stream<List<DateTime?>> watchDatesOfTransaction(
      {DateTime? startDate,
      DateTime? endDate,
      String search = "",
      // Search will be ignored... if these params are passed in
      List<int> categoryFks = const []}) {
    if (categoryFks.length > 0) {
      final query = (select(transactions)
        ..where((tbl) {
          if (startDate != null && endDate != null) {
            return tbl.dateCreated.isBiggerOrEqualValue(startDate) &
                tbl.dateCreated.isSmallerOrEqualValue(endDate) &
                tbl.categoryFk.isIn(categoryFks);
          } else {
            return tbl.categoryFk.isIn(categoryFks);
          }
        })
        ..orderBy([(t) => OrderingTerm.asc(t.dateCreated)]));
      DateTime previousDate = DateTime.now();
      return query.map((tbl) {
        DateTime currentDate = DateTime(
            tbl.dateCreated.year, tbl.dateCreated.month, tbl.dateCreated.day);
        if (previousDate != currentDate) {
          previousDate = currentDate;
          return currentDate;
        } else {
          previousDate = currentDate;
          return null;
        }
      }).watch();
    } else if (search == "") {
      final query = (select(transactions)
        ..where((tbl) {
          if (startDate != null && endDate != null) {
            return tbl.dateCreated.isBiggerOrEqualValue(startDate) &
                tbl.dateCreated.isSmallerOrEqualValue(endDate);
          } else {
            return tbl.walletFk.isNotNull();
          }
        })
        ..orderBy([(t) => OrderingTerm.asc(t.dateCreated)]));
      DateTime previousDate = DateTime.now();
      return query.map((tbl) {
        DateTime currentDate = DateTime(
            tbl.dateCreated.year, tbl.dateCreated.month, tbl.dateCreated.day);
        if (previousDate != currentDate) {
          previousDate = currentDate;
          return currentDate;
        } else {
          previousDate = currentDate;
          return null;
        }
      }).watch();
    } else {
      final query = ((select(transactions)
            ..where((tbl) {
              if (startDate != null && endDate != null) {
                return tbl.dateCreated.isBiggerOrEqualValue(startDate) &
                    tbl.dateCreated.isSmallerOrEqualValue(endDate);
              } else {
                return tbl.walletFk.isNotNull();
              }
            })
            ..orderBy([(t) => OrderingTerm.asc(t.dateCreated)]))
          .join([
        innerJoin(categories,
            categories.categoryPk.equalsExp(transactions.categoryFk))
      ]))
        ..where(categories.name.lower().like("%" + search.toLowerCase() + "%") |
            transactions.name.like("%" + search + "%"));
      DateTime previousDate = DateTime.now();
      return query.watch().map((rows) => rows.map((row) {
            DateTime currentDate = DateTime(
                row.readTable(transactions).dateCreated.year,
                row.readTable(transactions).dateCreated.month,
                row.readTable(transactions).dateCreated.day);
            if (previousDate != currentDate) {
              previousDate = currentDate;
              return currentDate;
            } else {
              previousDate = currentDate;
              return null;
            }
          }).toList());
    }
  }

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

  Stream<List<Transaction>> watchAllSubscriptions(
      {int? limit, DateTime? startDate, DateTime? endDate}) {
    final query = select(transactions)
      ..where(
        (transaction) =>
            transactions.paid.equals(false) &
            transactions.type
                .equals(TransactionSpecialType.subscription.index) &
            transactions.skipPaid.equals(false),
      );
    return query.watch();
  }

  Stream<List<Transaction>> watchAllUpcomingTransactions(
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
    return query.watch();
  }

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

  Stream<List<Transaction>> watchAllOverdueTransactions(
      {int? limit, DateTime? startDate, DateTime? endDate}) {
    final query = select(transactions)
      ..orderBy([(b) => OrderingTerm.asc(b.dateCreated)])
      ..where((transaction) =>
          transactions.skipPaid.equals(false) &
          transactions.paid.equals(false) &
          transactions.dateCreated.isSmallerThanValue(DateTime.now()) &
          (transactions.type.equals(TransactionSpecialType.subscription.index) |
              transactions.type
                  .equals(TransactionSpecialType.repetitive.index) |
              transactions.type.equals(TransactionSpecialType.upcoming.index)));
    return query.watch();
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
              : b.name
                  .lower()
                  .like("%" + (searchFor).toLowerCase().trim() + "%")))
          ..orderBy([(b) => OrderingTerm.asc(b.order)])
          ..limit(limit ?? DEFAULT_LIMIT, offset: offset ?? DEFAULT_OFFSET))
        .watch();
  }

  Future<List<TransactionAssociatedTitle>> getSimilarAssociatedTitles(
      {required String title, int? limit, int? offset}) {
    return (select(associatedTitles)
          ..where((t) =>
              (t.title.lower().like("%" + (title).toLowerCase().trim() + "%")))
          ..orderBy([(t) => OrderingTerm.desc(t.order)])
          ..limit(limit ?? DEFAULT_LIMIT, offset: offset ?? DEFAULT_OFFSET))
        .get();
  }

  // watch all budgets that have been created that are pinned
  Stream<List<Budget>> watchAllPinnedBudgets({int? limit, int? offset}) {
    return (select(budgets)
          ..where((tbl) => tbl.pinned.equals(true))
          ..orderBy([(b) => OrderingTerm.asc(b.order)])
          ..limit(limit ?? DEFAULT_LIMIT, offset: offset ?? DEFAULT_OFFSET))
        .watch();
  }

  Stream<Budget> getBudget(int budgetPk) {
    return (select(budgets)..where((b) => b.budgetPk.equals(budgetPk)))
        .watchSingle();
  }

  Stream<TransactionWallet> getWallet(int walletPk) {
    return (select(wallets)..where((w) => w.walletPk.equals(walletPk)))
        .watchSingle();
  }

  Future<int> getAmountOfBudgets() async {
    return (await select(budgets).get()).length;
  }

  Future moveBudget(int budgetPk, int newPosition, int oldPosition) async {
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

  Stream<List<TransactionWallet>> watchAllWallets(
      {String? searchFor, int? limit, int? offset}) {
    return (select(wallets)
          ..where((w) => (searchFor == null
              ? Constant(true)
              : w.name
                  .lower()
                  .like("%" + (searchFor).toLowerCase().trim() + "%")))
          ..orderBy([(w) => OrderingTerm.asc(w.order)])
          ..limit(limit ?? DEFAULT_LIMIT, offset: offset ?? DEFAULT_OFFSET))
        .watch();
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

  Future moveWallet(int walletPk, int newPosition, int oldPosition) async {
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

  Future<bool> createDeleteLog(DeleteLogType type, int deletedPk) async {
    await into(deleteLogs).insert(
      DeleteLogsCompanion.insert(
        type: type,
        entryPk: deletedPk,
        dateTimeModified: Value(DateTime.now()),
      ),
    );
    print((await getAllDeleteLogs()).length);
    return true;
  }

  Future<bool> createDeleteLogs(
      DeleteLogType type, List<int> deletedPks) async {
    List<DeleteLogsCompanion> deleteLogsToInsert = [];
    for (int deletePk in deletedPks) {
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
      {DateTime? customDateTimeModified}) {
    //when the first wallet is created this will most likely be null, as we initialize the database before settings
    final Map<dynamic, dynamic> cachedWalletCurrencies =
        appStateSettings["cachedWalletCurrencies"] ?? {};
    cachedWalletCurrencies[wallet.walletPk.toString()] = wallet.currency ?? "";
    print(cachedWalletCurrencies);
    updateSettings("cachedWalletCurrencies", cachedWalletCurrencies,
        pagesNeedingRefresh: [], updateGlobalState: false);
    return into(wallets).insert(
        wallet.copyWith(
            dateTimeModified: Value(customDateTimeModified ?? DateTime.now())),
        mode: InsertMode.insertOrReplace);
  }

  //create or update a new wallet
  Future<int> createOrUpdateScannerTemplate(ScannerTemplate scannerTemplate) {
    return into(scannerTemplates).insertOnConflictUpdate(
        scannerTemplate.copyWith(dateTimeModified: Value(DateTime.now())));
  }

  Future<int> createOrUpdateCategoryLimit(CategoryBudgetLimit categoryLimit) {
    return into(categoryBudgetLimits).insertOnConflictUpdate(
        categoryLimit.copyWith(dateTimeModified: Value(DateTime.now())));
  }

  Stream<List<TransactionAssociatedTitle>> watchAllAssociatedTitles(
      {String? searchFor, int? limit, int? offset}) {
    return (select(associatedTitles)
          ..where((t) => (searchFor == null
              ? Constant(true)
              : t.title
                  .lower()
                  .like("%" + (searchFor).toLowerCase().trim() + "%")))
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
      String searchFor, int categoryFk,
      {int? limit, int? offset}) async {
    return (await (select(associatedTitles)
              ..where((t) =>
                  t.title.lower().like(searchFor.toLowerCase().trim()) &
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
              ..where(
                  (t) => t.title.lower().like(searchFor.toLowerCase().trim()))
            // ..limit(limit ?? DEFAULT_LIMIT, offset: offset ?? DEFAULT_OFFSET)
            )
            .get())
        .first;
  }

  Future<TransactionCategory> getRelatingCategory(String searchFor,
      {int? limit, int? offset}) async {
    return (await (select(categories)
              ..where(
                  (c) => c.name.lower().like(searchFor.toLowerCase().trim()))
              ..limit(limit ?? DEFAULT_LIMIT, offset: offset ?? DEFAULT_OFFSET))
            .get())
        .first;
  }

  Stream<List<TransactionAssociatedTitle>> watchAllAssociatedTitlesInCategory(
      int categoryFk,
      {int? limit,
      int? offset}) {
    return (select(associatedTitles)
          ..where((t) => t.categoryFk.equals(categoryFk))
          ..orderBy([(t) => OrderingTerm.asc(t.order)])
        // ..limit(limit ?? DEFAULT_LIMIT, offset: offset ?? DEFAULT_OFFSET)
        )
        .watch();
  }

  Stream<List<CategoryBudgetLimit>> watchAllCategoryLimitsInBudget(int budgetPk,
      {int? limit, int? offset}) {
    return (select(categoryBudgetLimits)
          ..where((t) => t.budgetFk.equals(budgetPk)))
        .watch();
  }

  Expression<bool> evaluateIfNull(
      Expression<bool> expression, value, evaluationIfValueNull) {
    if (value == null) return Constant(evaluationIfValueNull);
    return expression;
  }

  (Stream<CategoryBudgetLimit>, Future<CategoryBudgetLimit>) getCategoryLimit(
      int? budgetPk, int? categoryPk) {
    SimpleSelectStatement<$CategoryBudgetLimitsTable, CategoryBudgetLimit>
        query = (select(categoryBudgetLimits)
          ..where((t) =>
              evaluateIfNull(t.budgetFk.equals(budgetPk ?? 0), budgetPk, true) &
              evaluateIfNull(
                  t.categoryFk.equals(categoryPk ?? 0), categoryPk, true)));
    return (query.watchSingle(), query.getSingle());
  }

  (Stream<CategoryBudgetLimit>, Future<CategoryBudgetLimit>)
      getCategoryBudgetLimitInstance(int categoryLimitPk) {
    final SimpleSelectStatement<$CategoryBudgetLimitsTable, CategoryBudgetLimit>
        query = (select(categoryBudgetLimits)
          ..where((t) => t.categoryLimitPk.equals(categoryLimitPk)));
    return (query.watchSingle(), query.getSingle());
  }

  Stream<TransactionCategory> watchCategory(int categoryPk) {
    return (select(categories)..where((t) => t.categoryPk.equals(categoryPk)))
        .watchSingle();
  }

  (Stream<TransactionCategory>, Future<TransactionCategory>) getCategory(
      int categoryPk) {
    final SimpleSelectStatement<$CategoriesTable, TransactionCategory> query =
        (select(categories)..where((t) => t.categoryPk.equals(categoryPk)));
    return (query.watchSingle(), query.getSingle());
  }

  (Stream<TransactionAssociatedTitle>, Future<TransactionAssociatedTitle>)
      getAssociatedTitleInstance(int associatedTitlePk) {
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
      TransactionAssociatedTitle associatedTitle) {
    return into(associatedTitles).insert(
        associatedTitle.copyWith(dateTimeModified: Value(DateTime.now())),
        mode: InsertMode.insertOrReplace);
  }

  Future moveAssociatedTitle(
      int associatedTitlePk, int newPosition, int oldPosition) async {
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
      budgetsList[i] = budgetsList[i].copyWith(order: i);
    }
    await batch((batch) {
      batch.insertAll(budgets, budgetsList, mode: InsertMode.replace);
    });
    return true;
  }

  Future<bool> fixOrderCategories() async {
    List<TransactionCategory> categoriesList = await (select(categories)
          ..orderBy([(t) => OrderingTerm.asc(t.order)]))
        .get();
    for (int i = 0; i < categoriesList.length; i++) {
      categoriesList[i] = categoriesList[i].copyWith(order: i);
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
      walletsList[i] = walletsList[i].copyWith(order: i);
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
      associatedTitlesList[i] = associatedTitlesList[i].copyWith(order: i);
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
      List<AssociatedTitlesCompanion> associatedTitlesNeedUpdating = [];
      for (TransactionAssociatedTitle associatedTitle in associatedTitlesList) {
        if (associatedTitle.order >= pastIndexIncluding)
          associatedTitlesNeedUpdating.add(AssociatedTitlesCompanion(
            associatedTitlePk: Value(associatedTitle.associatedTitlePk),
            dateCreated: Value(associatedTitle.dateCreated),
            isExactMatch: Value(associatedTitle.isExactMatch),
            title: Value(associatedTitle.title),
            categoryFk: Value(associatedTitle.categoryFk),
            order: Value(associatedTitle.order + direction),
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

  // create or update a new transaction
  Future<int>? createOrUpdateTransaction(Transaction transaction,
      {bool updateSharedEntry = true, Transaction? originalTransaction}) async {
    double maxAmount = 10000000;
    if (transaction.amount >= maxAmount)
      transaction = transaction.copyWith(amount: maxAmount);
    else if (transaction.amount <= -maxAmount)
      transaction = transaction.copyWith(amount: -maxAmount);

    if (transaction.amount == double.infinity ||
        transaction.amount == double.negativeInfinity ||
        transaction.amount.isNaN) {
      return 0;
    }

    // we are saying we still need this category!
    TransactionCategory categoryInUse =
        await getCategoryInstance(transaction.categoryFk);
    await createOrUpdateCategory(
      categoryInUse.copyWith(dateTimeModified: Value(DateTime.now())),
      updateSharedEntry: false,
    );

    // Update the servers entry of the transaction
    if (transaction.paid && updateSharedEntry == true) {
      if (transaction.sharedReferenceBudgetPk != null) {
        Budget budget = await database
            .getBudgetInstance(transaction.sharedReferenceBudgetPk!);
        if (originalTransaction != null) {
          if (originalTransaction.sharedReferenceBudgetPk !=
              transaction.sharedReferenceBudgetPk) {
            await deleteTransaction(transaction.transactionPk);
            await createOrUpdateTransaction(
              transaction.copyWith(
                transactionPk: DateTime.now().millisecondsSinceEpoch,
                sharedKey: Value(null),
                // transactionOwnerEmail: Value(null),
                // transactionOriginalOwnerEmail: Value(null),
                sharedDateUpdated: Value(null),
                sharedStatus: Value(null),
                // sharedReferenceBudgetPk: Value(null),
              ),
            );
            return 1;
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
          await createOrUpdateTransaction(
              transaction.copyWith(
                transactionPk: DateTime.now().millisecondsSinceEpoch,
                sharedKey: Value(null),
                transactionOwnerEmail: Value(null),
                transactionOriginalOwnerEmail: Value(null),
                sharedDateUpdated: Value(null),
                sharedStatus: Value(null),
                sharedReferenceBudgetPk: Value(null),
              ),
              updateSharedEntry: false);
          return 1;
        }
      }
    }
    return into(transactions).insert(
        transaction.copyWith(dateTimeModified: Value(DateTime.now())),
        mode: InsertMode.insertOrReplace);
  }

  // ************************************************************
  // The following functions should only be used for data sync
  // Unless another use case makes sense
  // These are also not logged into the Delete log!
  // ************************************************************

  Future<bool> processSyncLogs(List<SyncLog> syncLogs) async {
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
              mode: InsertMode.insertOrIgnore);
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
              mode: InsertMode.insertOrIgnore);
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
              mode: InsertMode.insertOrIgnore);
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
              mode: InsertMode.insertOrIgnore);
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
              mode: InsertMode.insertOrIgnore);
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
              mode: InsertMode.insertOrIgnore);
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
              mode: InsertMode.insertOrIgnore);
        }
      }
    });
    return true;
  }

  // This doesn't handle shared transactions!
  // updateShared is always false
  Future<bool> createOrUpdateBatchTransactionsOnly(
      List<Transaction> transactionsInserting) async {
    await batch((batch) {
      batch.insertAll(transactions, transactionsInserting,
          mode: InsertMode.insertOrReplace);
    });
    return true;
  }

  // Future<bool> createOrUpdateBatchWalletsOnly(
  //     List<TransactionWallet> walletsInserting) async {
  //   await batch((batch) {
  //     batch.insertAll(wallets, walletsInserting,
  //         mode: InsertMode.insertOrReplace);
  //   });
  //   return true;
  // }

  // Future<bool> createOrUpdateBatchCategoriesOnly(
  //     List<TransactionCategory> categoriesInserting) async {
  //   await batch((batch) {
  //     batch.insertAll(categories, categoriesInserting,
  //         mode: InsertMode.insertOrReplace);
  //   });
  //   return true;
  // }

  // Future<bool> createOrUpdateBatchBudgetsOnly(
  //     List<Budget> budgetsInserting) async {
  //   await batch((batch) {
  //     batch.insertAll(budgets, budgetsInserting,
  //         mode: InsertMode.insertOrReplace);
  //   });
  //   return true;
  // }

  // Future<bool> createOrUpdateBatchCategoryLimitsOnly(
  //     List<CategoryBudgetLimit> limitsInserting) async {
  //   await batch((batch) {
  //     batch.insertAll(categoryBudgetLimits, limitsInserting,
  //         mode: InsertMode.insertOrReplace);
  //   });
  //   return true;
  // }

  // Future<bool> createOrUpdateBatchScannerTemplatesOnly(
  //     List<ScannerTemplate> templatesInserting) async {
  //   await batch((batch) {
  //     batch.insertAll(scannerTemplates, templatesInserting,
  //         mode: InsertMode.insertOrReplace);
  //   });
  //   return true;
  // }

  // // This doesn't handle order of titles!
  // Future<bool> createOrUpdateBatchAssociatedTitlesOnly(
  //     List<TransactionAssociatedTitle> associatedTitlesInserting) async {
  //   await batch((batch) {
  //     batch.insertAll(associatedTitles, associatedTitlesInserting,
  //         mode: InsertMode.insertOrReplace);
  //   });
  //   return true;
  // }

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
  Future<int> createOrUpdateCategory(TransactionCategory category,
      {bool updateSharedEntry = true, DateTime? customDateTimeModified}) async {
    // We need to ensure the value is set back to null, so insert/replace
    int result = await into(categories).insert(
        category.copyWith(
            dateTimeModified: Value(customDateTimeModified ?? DateTime.now())),
        mode: InsertMode.insertOrReplace);
    if (updateSharedEntry)
      updateTransactionOnServerAfterChangingCategoryInformation(category);
    return result;
  }

  Future<int> createOrUpdateFromSharedBudget(Budget budget) async {
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
        // new entry is needed
        int numberOfBudgets = (await database.getAmountOfBudgets());
        sharedBudget = budget.copyWith(order: numberOfBudgets);
        return into(budgets).insertOnConflictUpdate(
            sharedBudget.copyWith(dateTimeModified: Value(DateTime.now())));
      }
    } else {
      return 0;
    }
  }

  Future<Budget> getSharedBudget(sharedKey) async {
    return (await (select(budgets)..where((t) => t.sharedKey.equals(sharedKey)))
            .get())
        .first;
  }

  Future<List<Transaction>> getAllTransactionsFromCategory(categoryPk) {
    return (select(transactions)
          ..where((tbl) {
            return tbl.categoryFk.equals(categoryPk) & tbl.paid.equals(true);
          })
          ..orderBy([(t) => OrderingTerm.desc(t.dateCreated)]))
        .get();
  }

  Future<List<Transaction>> getAllTransactionsBelongingToSharedBudget(
      budgetPk) {
    return (select(transactions)
          ..where((tbl) {
            return tbl.sharedReferenceBudgetPk.equals(budgetPk) &
                tbl.paid.equals(true);
          })
          ..orderBy([(t) => OrderingTerm.desc(t.dateCreated)]))
        .get();
  }

  Future<int> createOrUpdateFromSharedTransaction(
      Transaction transaction) async {
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
        return into(transactions).insertOnConflictUpdate(
            transaction.copyWith(dateTimeModified: Value(DateTime.now())));
      }
    } else {
      return 0;
    }
  }

  Future<int> deleteFromSharedTransaction(sharedTransactionKey) async {
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
  Future<int> createOrUpdateBudget(Budget budget,
      {bool updateSharedEntry = true}) async {
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

    return into(budgets).insert(
        budget.copyWith(dateTimeModified: Value(DateTime.now())),
        mode: InsertMode.replace);
  }

  // get category given key
  Future<TransactionCategory> getCategoryInstance(int categoryPk) {
    return (select(categories)..where((t) => t.categoryPk.equals(categoryPk)))
        .getSingle();
  }

  // get budget given key
  Future<Budget> getBudgetInstance(int budgetPk) {
    return (select(budgets)..where((t) => t.budgetPk.equals(budgetPk)))
        .getSingle();
  }

  // get category given name
  Future<TransactionCategory> getCategoryInstanceGivenName(String name) async {
    return (await (select(categories)..where((t) => t.name.equals(name))).get())
        .first;
  }

  Stream<List<TransactionCategory>> watchAllCategories(
      {String? searchFor, int? limit, int? offset}) {
    return (select(categories)
          ..where((c) => (searchFor == null
              ? Constant(true)
              : c.name
                  .lower()
                  .like("%" + (searchFor).toLowerCase().trim() + "%")))
          ..orderBy([(c) => OrderingTerm.asc(c.order)])
          ..limit(limit ?? DEFAULT_LIMIT, offset: offset ?? DEFAULT_OFFSET))
        .watch();
  }

  Stream<Map<int, TransactionCategory>> watchAllCategoriesMapped(
      {int? limit, int? offset}) {
    return (select(categories)
          ..limit(limit ?? DEFAULT_LIMIT, offset: offset ?? DEFAULT_OFFSET))
        .watch()
        .map((categoryList) =>
            {for (var category in categoryList) category.categoryPk: category});
  }

  Future<List<TransactionCategory>> getAllCategories(
      {int? limit, int? offset, List<int>? categoryFks, bool? allCategories}) {
    return (select(categories)
          ..where((c) => (allCategories != false
              ? Constant(true)
              : c.categoryPk.isIn(categoryFks ?? [])))
          ..orderBy([(c) => OrderingTerm.asc(c.order)])
          ..limit(limit ?? DEFAULT_LIMIT, offset: offset ?? DEFAULT_OFFSET))
        .get();
  }

  Future<List<int>> getAllCategoryPks(
      {int? limit, int? offset, List<int>? categoryFks, bool? allCategories}) {
    return (select(categories)
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

  Stream<List<Budget>> watchAllAddableBudgets() {
    return (select(budgets)
          ..where((b) => (b.sharedKey.isNotNull() |
              (b.addedTransactionsOnly.equals(true) & b.sharedKey.isNull())))
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

  Future getAmountOfCategories() async {
    return (await select(categories).get()).length;
  }

  Future getAmountOfAssociatedTitles() async {
    return (await select(associatedTitles).get()).length;
  }

  Future moveCategory(int categoryPk, int newPosition, int oldPosition) async {
    List<TransactionCategory> categoriesList = await (select(categories)
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

  Future<bool> shiftCategories(int direction, int pastIndexIncluding) async {
    List<TransactionCategory> categoryList = await (select(categories)
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

  // get wallet given id
  Future<TransactionWallet> getWalletInstance(int walletPk) {
    return (select(wallets)..where((w) => w.walletPk.equals(walletPk)))
        .getSingle();
  }

  Future<ScannerTemplate> getScannerTemplateInstance(int scannerTemplatePk) {
    return (select(scannerTemplates)
          ..where((s) => s.scannerTemplatePk.equals(scannerTemplatePk)))
        .getSingle();
  }

  // delete budget given key
  Future<int> deleteBudget(context, Budget budget) async {
    if (budget.sharedKey != null) {
      dynamic response = await deleteSharedBudgetPopup(context, budget);
      // we do != true because if user taps barrier dismiss it can still move on to delete...
      if (response != true) {
        return -1;
      }
      loadingIndeterminateKey.currentState!.setVisibility(true);
      if (budget.sharedOwnerMember == SharedOwnerMember.owner) {
        bool result = await removedSharedFromBudget(budget);
      } else {
        bool result = await leaveSharedBudget(budget);
      }
      loadingIndeterminateKey.currentState!.setVisibility(false);
    } else if (budget.addedTransactionsOnly) {
      if ((await getTotalCountOfTransactionsInBudget(budget.budgetPk) ?? 0) >
          0) {
        dynamic response =
            await deleteAddedTransactionsOnlyBudgetPopup(context, budget);
        // we do != true because if user taps barrier dismiss it can still move on to delete...
        if (response != true) {
          return -1;
        }
      }
    }

    await shiftBudgets(-1, budget.order);
    await deleteCategoryBudgetLimitsInBudget(budget.budgetPk);
    await createDeleteLog(DeleteLogType.Budget, budget.budgetPk);
    return (delete(budgets)..where((b) => b.budgetPk.equals(budget.budgetPk)))
        .go();
  }

  //delete transaction given key
  Future deleteTransaction(int transactionPk,
      {bool updateSharedEntry = true}) async {
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

  Future deleteTransactions(List<int> transactionPks,
      {bool updateSharedEntry = true}) async {
    // Send the delete log to the server
    for (int transactionPk in transactionPks) {
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

  Future deleteCategoryBudgetLimitsInBudget(int budgetPk) async {
    await createDeleteLog(DeleteLogType.Budget, budgetPk);
    return (delete(categoryBudgetLimits)
          ..where((t) => t.budgetFk.equals(budgetPk)))
        .go();
  }

  Future deleteCategoryBudgetLimitsInCategory(int categoryPk) async {
    await createDeleteLog(DeleteLogType.TransactionCategory, categoryPk);
    return (delete(categoryBudgetLimits)
          ..where((t) => t.categoryFk.equals(categoryPk)))
        .go();
  }

  Future deleteCategoryBudgetLimit(int categoryLimitPk) async {
    await createDeleteLog(DeleteLogType.CategoryBudgetLimit, categoryLimitPk);
    return (delete(categoryBudgetLimits)
          ..where((t) => t.categoryLimitPk.equals(categoryLimitPk)))
        .go();
  }

  //delete category given key
  Future deleteCategory(int categoryPk, int order) async {
    List<TransactionAssociatedTitle> allAssociatedTitles =
        await getAllAssociatedTitles();
    for (TransactionAssociatedTitle associatedTitle in allAssociatedTitles) {
      if (associatedTitle.categoryFk == categoryPk)
        await deleteAssociatedTitle(
            associatedTitle.associatedTitlePk, associatedTitle.order);
    }
    List<Transaction> sharedTransactionsInCategory =
        await getAllTransactionsSharedInCategory(categoryPk);
    print(sharedTransactionsInCategory);
    await Future.wait([
      for (Transaction transaction in sharedTransactionsInCategory)
        // delete shared transactions one by one, need to update the server
        deleteTransaction(transaction.transactionPk)
    ]);
    await shiftCategories(-1, order);
    print("DELETING");
    print(categoryPk);
    print(await deleteCategoryBudgetLimitsInCategory(categoryPk));
    await createDeleteLog(DeleteLogType.TransactionCategory, categoryPk);
    return (delete(categories)..where((c) => c.categoryPk.equals(categoryPk)))
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
  Future deleteCategoryTransactions(int categoryPk) async {
    List<Transaction> transactionsToDelete = await (select(transactions)
          ..where((t) => t.categoryFk.equals(categoryPk)))
        .get();
    List<int> transactionPks = transactionsToDelete
        .map((transaction) => transaction.transactionPk)
        .toList();
    await createDeleteLogs(DeleteLogType.Transaction, transactionPks);
    return (delete(transactions)..where((t) => t.categoryFk.equals(categoryPk)))
        .go();
  }

  //delete wallet given key
  Future deleteWallet(int walletPk, int order) async {
    if (walletPk == 0) {
      throw "Can't delete default wallet";
    }
    final Map<dynamic, dynamic> cachedWalletCurrencies =
        appStateSettings["cachedWalletCurrencies"] ?? {};
    cachedWalletCurrencies.remove(walletPk.toString());
    print(cachedWalletCurrencies);
    updateSettings("cachedWalletCurrencies", cachedWalletCurrencies,
        pagesNeedingRefresh: [], updateGlobalState: false);
    await database.shiftWallets(-1, order);
    await createDeleteLog(DeleteLogType.TransactionWallet, walletPk);
    return (delete(wallets)..where((w) => w.walletPk.equals(walletPk))).go();
  }

  Future<bool> moveWalletTransactons(int walletPk, int toWalletPk) async {
    List<Transaction> transactionsForMove = await (select(transactions)
          ..where((tbl) {
            return tbl.walletFk.equals(walletPk);
          }))
        .get();
    List<Transaction> allTransactionsToUpdate = [];
    for (Transaction transaction in transactionsForMove) {
      allTransactionsToUpdate.add(transaction.copyWith(
        amount: (amountRatioFromToCurrency(
                    appStateSettings["cachedWalletCurrencies"]
                        [walletPk.toString()],
                    appStateSettings["cachedWalletCurrencies"]
                        [toWalletPk.toString()]) ??
                1) *
            transaction.amount,
        dateTimeModified: Value(DateTime.now()),
        walletFk: toWalletPk,
      ));
    }
    await createOrUpdateBatchTransactionsOnly(allTransactionsToUpdate);
    return true;
  }

  Future deleteScannerTemplate(int scannerTemplatePk) async {
    await createDeleteLog(DeleteLogType.ScannerTemplate, scannerTemplatePk);
    return (delete(scannerTemplates)
          ..where((s) => s.scannerTemplatePk.equals(scannerTemplatePk)))
        .go();
  }

  //delete transactions that belong to specific wallet key
  Future deleteWalletsTransactions(int walletPk) async {
    List<Transaction> transactionPkForDelete = await (select(transactions)
          ..where((tbl) {
            return tbl.walletFk.equals(walletPk);
          }))
        .get();
    List<int> transactionIds =
        transactionPkForDelete.map((t) => t.transactionPk).toList();
    await createDeleteLogs(DeleteLogType.Transaction, transactionIds);
    return (delete(transactions)..where((t) => t.walletFk.equals(walletPk)))
        .go();
  }

  //delete associated title given key
  Future deleteAssociatedTitle(int associatedTitlePk, int order) async {
    await database.shiftAssociatedTitles(-1, order);
    await createDeleteLog(
        DeleteLogType.TransactionAssociatedTitle, associatedTitlePk);
    return (delete(associatedTitles)
          ..where((t) => t.associatedTitlePk.equals(associatedTitlePk)))
        .go();
  }

  Stream<double?> totalDoubleStream(List<Stream<double?>> mergedStreams) {
    return StreamZip(mergedStreams)
        .map((list) => list.where((x) => x != null))
        .map((list) => list.reduce((acc, val) => (acc ?? 0) + (val ?? 0)));
  }

  Stream<List<CategoryWithTotal>> totalCategoryTotalStream(
      List<Stream<List<CategoryWithTotal>>> mergedStreams) {
    return StreamZip(mergedStreams).map((lists) {
      final Map<int, CategoryWithTotal> categoryTotals = {};
      for (final list in lists) {
        for (final item in list) {
          categoryTotals[item.category.categoryPk] = CategoryWithTotal(
            category: item.category,
            total: item.total +
                (categoryTotals[item.category.categoryPk]?.total ?? 0),
            transactionCount: item.transactionCount,
            categoryBudgetLimit: item.categoryBudgetLimit,
          );
        }
      }
      List<CategoryWithTotal> categoryWithTotalsSorted = categoryTotals.values
          .toList()
        ..sort((a, b) => a.total.compareTo(b.total));
      return categoryWithTotalsSorted;
    });
  }

  Stream<double?> watchTotalOfCategoryLimitsInBudgetWithCategories(
      int budgetPk, List<int> categoryPks) {
    final totalAmt = categoryBudgetLimits.amount.sum();
    JoinedSelectStatement<$CategoryBudgetLimitsTable, CategoryBudgetLimit>
        query;

    query = selectOnly(categoryBudgetLimits)
      ..addColumns([totalAmt])
      ..where(categoryBudgetLimits.budgetFk.equals(budgetPk) &
          categoryBudgetLimits.categoryFk.isIn(categoryPks));

    return query.map((row) => row.read(totalAmt)).watchSingleOrNull();
  }

  Stream<double?> watchTotalSpentGivenList(
      List<int> transactionPks, List<TransactionWallet> wallets) {
    List<Stream<double?>> mergedStreams = [];
    for (TransactionWallet wallet in wallets) {
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
              (amountRatioToPrimaryCurrency(wallet.currency) ?? 0)))
          .watchSingle());
    }

    return totalDoubleStream(mergedStreams);
  }

  // get total amount spent in each day
  Stream<double?> watchTotalSpentInTimeRangeFromCategories(
      DateTime start,
      DateTime end,
      List<int>? categoryFks,
      bool allCategories,
      List<TransactionWallet> wallets,
      List<BudgetTransactionFilters>? budgetTransactionFilters,
      List<String>? memberTransactionFilters,
      {bool allCashFlow = false,
      int? onlyShowTransactionsBelongingToBudget,
      Budget? budget}) {
    DateTime startDate = DateTime(start.year, start.month, start.day);
    DateTime endDate = DateTime(end.year, end.month, end.day);
    List<Stream<double?>> mergedStreams = [];
    for (TransactionWallet wallet in wallets) {
      final totalAmt = transactions.amount.sum();
      final date = transactions.dateCreated.date;

      JoinedSelectStatement<$TransactionsTable, Transaction> query;
      if (allCategories) {
        query = (selectOnly(transactions)
          ..addColumns([totalAmt])
          ..where(
            onlyShowBasedOnTimeRange(transactions, startDate, endDate, budget) &
                transactions.paid.equals(true) &
                (allCashFlow
                    ? transactions.income.isIn([true, false])
                    : transactions.income.equals(false)) &
                onlyShowIfCertainBudget(
                    transactions, onlyShowTransactionsBelongingToBudget) &
                transactions.walletFk.equals(wallet.walletPk) &
                onlyShowIfFollowsFilters(transactions,
                    budgetTransactionFilters: budgetTransactionFilters,
                    memberTransactionFilters: memberTransactionFilters),
          ));
      } else {
        query = (selectOnly(transactions)
          ..addColumns([totalAmt])
          ..where(
            onlyShowBasedOnTimeRange(transactions, startDate, endDate, budget) &
                transactions.categoryFk.isIn(categoryFks ?? []) &
                transactions.paid.equals(true) &
                (allCashFlow
                    ? transactions.income.isIn([true, false])
                    : transactions.income.equals(false)) &
                onlyShowIfCertainBudget(
                    transactions, onlyShowTransactionsBelongingToBudget) &
                transactions.walletFk.equals(wallet.walletPk) &
                onlyShowIfFollowsFilters(transactions,
                    budgetTransactionFilters: budgetTransactionFilters,
                    memberTransactionFilters: memberTransactionFilters),
          ));
      }

      mergedStreams.add(query
          .map(((row) =>
              (row.read(totalAmt) ?? 0) *
              (amountRatioToPrimaryCurrency(wallet.currency) ?? 0)))
          .watchSingle());
    }
    return totalDoubleStream(mergedStreams);
  }

  Expression<bool> onlyShowIfFollowsFilters($TransactionsTable tbl,
      {List<BudgetTransactionFilters>? budgetTransactionFilters,
      List<String>? memberTransactionFilters}) {
    Expression<bool> memberIncluded = memberTransactionFilters == null
        ? Constant(true)
        : (tbl.sharedKey.isNotNull() &
                tbl.transactionOwnerEmail.isIn(memberTransactionFilters) |
            tbl.sharedKey.isNull());
    Expression<bool> includeShared = budgetTransactionFilters == null
        ? Constant(true)
        : budgetTransactionFilters
                    .contains(BudgetTransactionFilters.sharedToOtherBudget) ==
                false
            ? tbl.sharedKey.isNull()
            : Constant(true);
    Expression<bool> includeAdded = budgetTransactionFilters == null
        ? Constant(true)
        : budgetTransactionFilters
                    .contains(BudgetTransactionFilters.addedToOtherBudget) ==
                false
            ? tbl.sharedReferenceBudgetPk.isNull() | tbl.sharedKey.isNotNull()
            : Constant(true);
    return memberIncluded & includeShared & includeAdded;
    // ? (tbl.sharedReferenceBudgetPk.isNull())
    //             : (sharedTransactionsShow ==
    //                     SharedTransactionsShow.onlyIfNotShared)
    //                 ? (tbl.sharedKey.isNull())
    //                 : (sharedTransactionsShow ==
    //                         SharedTransactionsShow.onlyIfOwnerIfShared)
    //                     ? (tbl.sharedReferenceBudgetPk.isNotNull() &
    //                         tbl.sharedKey.isNotNull() &
    //                         tbl.transactionOwnerEmail.equals(
    //                             appStateSettings["currentUserEmail"]))
    //                     : tbl.sharedKey.isNotNull() |
    //                         tbl.sharedKey.isNull());
  }

  Stream<double?> watchTotalSpentByCurrentUserOnly(
    DateTime start,
    DateTime end,
    int budgetPk,
    List<TransactionWallet> wallets,
  ) {
    DateTime startDate = DateTime(start.year, start.month, start.day);
    DateTime endDate = DateTime(end.year, end.month, end.day);

    List<Stream<double?>> mergedStreams = [];
    for (TransactionWallet wallet in wallets) {
      final totalAmt = transactions.amount.sum();
      JoinedSelectStatement<$TransactionsTable, Transaction> query =
          (selectOnly(transactions)
            ..addColumns([totalAmt])
            ..where(transactions.paid.equals(true) &
                transactions.income.equals(false) &
                transactions.walletFk.equals(wallet.walletPk) &
                onlyShowBasedOnTimeRange(
                    transactions, startDate, endDate, null) &
                onlyShowIfFollowsFilters(transactions,
                    memberTransactionFilters: [
                      appStateSettings["currentUserEmail"]
                    ]) &
                transactions.sharedReferenceBudgetPk.equals(budgetPk)));
      mergedStreams.add(query
          .map(((row) =>
              (row.read(totalAmt) ?? 0) *
              (amountRatioToPrimaryCurrency(wallet.currency) ?? 0)))
          .watchSingleOrNull());
    }

    return totalDoubleStream(mergedStreams);
  }

  Stream<double?> watchTotalSpentByUser(
      DateTime start,
      DateTime end,
      List<int> categoryFks,
      bool allCategories,
      String userEmail,
      int onlyShowTransactionsBelongingToBudget,
      List<TransactionWallet> wallets,
      {bool allTime = false}) {
    DateTime startDate = DateTime(start.year, start.month, start.day);
    DateTime endDate = DateTime(end.year, end.month, end.day);
    List<Stream<double?>> mergedStreams = [];
    for (TransactionWallet wallet in wallets) {
      final totalAmt = transactions.amount.sum();
      JoinedSelectStatement<$TransactionsTable, Transaction> query;

      query = (selectOnly(transactions)
        ..addColumns([totalAmt])
        ..where((allTime
                ? transactions.dateCreated.isNotNull()
                : transactions.dateCreated
                    .isBetweenValues(startDate, endDate)) &
            transactions.paid.equals(true) &
            transactions.income.equals(false) &
            transactions.walletFk.equals(wallet.walletPk) &
            isInCategory(transactions, allCategories, categoryFks) &
            transactions.transactionOwnerEmail.equals(userEmail) &
            transactions.sharedReferenceBudgetPk
                .equals(onlyShowTransactionsBelongingToBudget)));
      mergedStreams.add(query
          .map(((row) =>
              (row.read(totalAmt) ?? 0) *
              (amountRatioToPrimaryCurrency(wallet.currency) ?? 0)))
          .watchSingleOrNull());
    }
    return totalDoubleStream(mergedStreams);
  }

  Stream<List<Transaction>> watchAllTransactionsByUser(
      {int? limit,
      required DateTime start,
      required DateTime end,
      required List<int> categoryFks,
      required bool allCategories,
      required String userEmail}) {
    DateTime startDate = DateTime(start.year, start.month, start.day);
    DateTime endDate = DateTime(end.year, end.month, end.day);
    return (select(transactions)
          ..where((tbl) {
            return tbl.dateCreated.isBetweenValues(startDate, endDate) &
                tbl.paid.equals(true) &
                tbl.income.equals(false) &
                isInCategory(tbl, allCategories, categoryFks) &
                tbl.transactionOwnerEmail.equals(userEmail);
          })
          ..orderBy([(b) => OrderingTerm.desc(b.dateCreated)])
          ..limit(limit ?? DEFAULT_LIMIT))
        .watch();
  }

  Expression<bool> isInCategory(
      $TransactionsTable tbl, bool allCategories, List<int> categoryFks) {
    return allCategories
        ? tbl.categoryFk.isNotNull()
        : tbl.categoryFk.isIn(categoryFks);
  }

  Expression<bool> onlyShowIfMember($TransactionsTable tbl, String? member) {
    return (member != null
        ? tbl.transactionOwnerEmail.equals(member)
        : Constant(true));
  }

  Expression<bool> onlyShowBasedOnIncome($TransactionsTable tbl, bool? income) {
    return (income != null ? tbl.income.equals(income) : Constant(true));
  }

  Expression<bool> onlyShowBasedOnCategoryFks(
      $TransactionsTable tbl, List<int> categoryFks) {
    return (categoryFks.length >= 1
        ? tbl.categoryFk.isIn(categoryFks)
        : Constant(true));
  }

  Expression<bool> onlyShowBasedOnWalletFks(
      $TransactionsTable tbl, List<int> walletFks) {
    return (walletFks.length >= 1
        ? tbl.walletFk.isIn(walletFks)
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
                ? transactions.dateCreated.isSmallerOrEqualValue(endDate)
                : startDate != null && endDate == null
                    ? transactions.dateCreated.isBiggerOrEqualValue(startDate)
                    : transactions.dateCreated
                        .isBetweenValues(startDate!, endDate!)));
  }

  Expression<bool> onlyShowIfCertainBudget(
      $TransactionsTable tbl, int? budgetPk) {
    return (budgetPk != null
        ? tbl.sharedReferenceBudgetPk.equals(budgetPk)
        : Constant(true));
  }

  // The total amount of that category will always be that last column
  // print(snapshot.data![0].rawData.data["transactions.category_fk"]);
  // print(snapshot.data![0].rawData.data["c" + (snapshot.data![0].rawData.data.length).toString()]);
  Stream<List<CategoryWithTotal>>
      watchTotalSpentInEachCategoryInTimeRangeFromCategories(
    DateTime start,
    DateTime end,
    List<int> categoryFks,
    bool allCategories,
    List<BudgetTransactionFilters>? budgetTransactionFilters,
    List<String>? memberTransactionFilters,
    List<TransactionWallet> wallets, {
    String? member,
    int? onlyShowTransactionsBelongingToBudget,
    Budget? budget,
    bool allTime = false,
    int? walletPk,
  }) {
    DateTime startDate = DateTime(start.year, start.month, start.day);
    DateTime endDate = DateTime(end.year, end.month, end.day);
    List<Stream<List<CategoryWithTotal>>> mergedStreams = [];

    for (TransactionWallet wallet in wallets) {
      if (walletPk != null && wallet.walletPk != walletPk) continue;
      final totalAmt = transactions.amount.sum();
      final totalCount = transactions.transactionPk.count();

      final query = (select(transactions)
        ..where((tbl) {
          return onlyShowBasedOnTimeRange(
                  transactions, startDate, endDate, budget, allTime: allTime) &
              isInCategory(tbl, allCategories, categoryFks) &
              tbl.paid.equals(true) &
              tbl.income.equals(false) &
              transactions.walletFk.equals(wallet.walletPk) &
              onlyShowIfFollowsFilters(tbl,
                  budgetTransactionFilters: budgetTransactionFilters,
                  memberTransactionFilters: memberTransactionFilters) &
              onlyShowIfMember(tbl, member) &
              onlyShowIfCertainBudget(
                  tbl, onlyShowTransactionsBelongingToBudget);
        })
        ..orderBy([(c) => OrderingTerm.desc(c.dateCreated)]));
      mergedStreams.add((query.join([
        leftOuterJoin(categories,
            categories.categoryPk.equalsExp(transactions.categoryFk)),
        leftOuterJoin(
            categoryBudgetLimits,
            categoryBudgetLimits.categoryFk.equalsExp(categories.categoryPk) &
                evaluateIfNull(
                    categoryBudgetLimits.budgetFk.equals(budget?.budgetPk ?? 0),
                    budget,
                    false))
      ])
            ..addColumns([totalAmt, totalCount])
            ..groupBy([categories.categoryPk])
            ..orderBy([OrderingTerm.asc(totalAmt)]))
          .map((row) {
        final TransactionCategory category = row.readTable(categories);
        CategoryBudgetLimit? categoryBudgetLimit =
            row.readTableOrNull(categoryBudgetLimits);

        final double? total = (row.read(totalAmt) ?? 0) *
            (amountRatioToPrimaryCurrency(wallet.currency) ?? 0);
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

  Stream<double?> watchTotalOfWallet(int? walletPk, {bool? isIncome = null}) {
    final totalAmt = transactions.amount.sum();
    final query = selectOnly(transactions)
      ..addColumns([totalAmt])
      ..where((isIncome == null
              ? transactions.walletFk.isNotNull()
              : isIncome == true
                  ? transactions.income.equals(true)
                  : transactions.income.equals(false)) &
          (walletPk == null
              ? transactions.walletFk.isNotNull()
              : transactions.walletFk.equals(walletPk)) &
          transactions.paid.equals(true));
    return query.map((row) => row.read(totalAmt)).watchSingleOrNull();
  }

  Stream<List<int?>> watchTotalCountOfTransactionsInWallet(int? walletPk,
      {bool? isIncome = null}) {
    final totalCount = transactions.transactionPk.count();
    final query = selectOnly(transactions)
      ..addColumns([totalCount])
      ..where((isIncome == null
              ? transactions.walletFk.isNotNull()
              : isIncome == true
                  ? transactions.income.equals(true)
                  : transactions.income.equals(false)) &
          (walletPk == null
              ? transactions.walletFk.isNotNull()
              : transactions.walletFk.equals(walletPk)));
    return query.map((row) => row.read(totalCount)).watch();
  }

  Stream<double?> watchTotalOfUpcomingOverdue(
      bool isOverdue, List<TransactionWallet> wallets) {
    List<Stream<double?>> mergedStreams = [];
    for (TransactionWallet wallet in wallets) {
      final totalAmt = transactions.amount.sum();
      final query = selectOnly(transactions)
        ..addColumns([totalAmt])
        ..where(transactions.income.equals(false) &
            transactions.skipPaid.equals(false) &
            transactions.paid.equals(false) &
            transactions.walletFk.equals(wallet.walletPk) &
            (isOverdue
                ? transactions.dateCreated.isSmallerThanValue(DateTime.now())
                : transactions.dateCreated.isBiggerThanValue(DateTime.now())) &
            (transactions.type
                    .equals(TransactionSpecialType.subscription.index) |
                transactions.type
                    .equals(TransactionSpecialType.repetitive.index) |
                transactions.type
                    .equals(TransactionSpecialType.upcoming.index)));
      mergedStreams.add(query
          .map((row) =>
              (row.read(totalAmt) ?? 0) *
              (amountRatioToPrimaryCurrency(wallet.currency) ?? 0))
          .watchSingle());
    }
    return totalDoubleStream(mergedStreams);
  }

  Stream<List<int?>> watchCountOfUpcoming() {
    final totalCount = transactions.transactionPk.count();

    final query = selectOnly(transactions)
      ..addColumns([totalCount])
      ..where(transactions.skipPaid.equals(false) &
          transactions.paid.equals(false) &
          transactions.dateCreated.isBiggerThanValue(DateTime.now()) &
          (transactions.type.equals(TransactionSpecialType.subscription.index) |
              transactions.type
                  .equals(TransactionSpecialType.repetitive.index) |
              transactions.type.equals(TransactionSpecialType.upcoming.index)));
    return query.map((row) => row.read(totalCount)).watch();
  }

  Stream<List<int?>> watchCountOfOverdue() {
    final totalCount = transactions.transactionPk.count();

    final query = selectOnly(transactions)
      ..addColumns([totalCount])
      ..where(transactions.skipPaid.equals(false) &
          transactions.paid.equals(false) &
          transactions.dateCreated.isSmallerThanValue(DateTime.now()) &
          (transactions.type.equals(TransactionSpecialType.subscription.index) |
              transactions.type
                  .equals(TransactionSpecialType.repetitive.index) |
              transactions.type.equals(TransactionSpecialType.upcoming.index)));
    return query.map((row) => row.read(totalCount)).watch();
  }

  Stream<List<int?>> watchTotalCountOfTransactionsInWalletInCategory(
      int walletPk, int categoryPk) {
    final totalCount = transactions.transactionPk.count();
    final query = selectOnly(transactions)
      ..addColumns([totalCount])
      ..where(transactions.walletFk.equals(walletPk) &
          transactions.categoryFk.equals(categoryPk));
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

  Future<int?> getTotalCountOfTransactionsInBudget(int budgetPk) async {
    final totalCount = transactions.transactionPk.count();
    final query = selectOnly(transactions)
      ..where(transactions.sharedReferenceBudgetPk.equals(budgetPk))
      ..addColumns([totalCount]);
    final result = await query.map((row) => row.read(totalCount)).getSingle();
    return result;
  }

  // get all transactions that occurred in a given time period that belong to categories
  Stream<List<Transaction>> getTransactionsInTimeRangeFromCategories(
    DateTime start,
    DateTime end,
    List<int> categoryFks,
    bool allCategories,
    bool isPaidOnly,
    bool? isIncome,
    List<BudgetTransactionFilters>? budgetTransactionFilters,
    List<String>? memberTransactionFilters, {
    String? member,
    int? onlyShowTransactionsBelongingToBudget,
    Budget? budget,
  }) {
    DateTime startDate = DateTime(start.year, start.month, start.day);
    DateTime endDate = DateTime(end.year, end.month, end.day);
    if (allCategories) {
      return (select(transactions)
            ..where((tbl) {
              final dateCreated = tbl.dateCreated;
              if (isPaidOnly) {
                if (isIncome == true) {
                  return onlyShowIfFollowsFilters(tbl,
                          budgetTransactionFilters: budgetTransactionFilters,
                          memberTransactionFilters: memberTransactionFilters) &
                      onlyShowBasedOnTimeRange(
                          transactions, startDate, endDate, budget) &
                      tbl.paid.equals(true) &
                      tbl.income.equals(true) &
                      onlyShowIfMember(tbl, member) &
                      onlyShowIfCertainBudget(
                          tbl, onlyShowTransactionsBelongingToBudget);
                } else if (isIncome == false) {
                  return onlyShowIfFollowsFilters(tbl,
                          budgetTransactionFilters: budgetTransactionFilters,
                          memberTransactionFilters: memberTransactionFilters) &
                      onlyShowBasedOnTimeRange(
                          transactions, startDate, endDate, budget) &
                      tbl.paid.equals(true) &
                      tbl.income.equals(false) &
                      onlyShowIfMember(tbl, member) &
                      onlyShowIfCertainBudget(
                          tbl, onlyShowTransactionsBelongingToBudget);
                } else {
                  return onlyShowIfFollowsFilters(tbl,
                          budgetTransactionFilters: budgetTransactionFilters,
                          memberTransactionFilters: memberTransactionFilters) &
                      onlyShowBasedOnTimeRange(
                          transactions, startDate, endDate, budget) &
                      tbl.paid.equals(true) &
                      onlyShowIfMember(tbl, member) &
                      onlyShowIfCertainBudget(
                          tbl, onlyShowTransactionsBelongingToBudget);
                }
              } else {
                if (isIncome == true) {
                  return onlyShowIfFollowsFilters(tbl,
                          budgetTransactionFilters: budgetTransactionFilters,
                          memberTransactionFilters: memberTransactionFilters) &
                      onlyShowBasedOnTimeRange(
                          transactions, startDate, endDate, budget) &
                      tbl.income.equals(true) &
                      onlyShowIfMember(tbl, member) &
                      onlyShowIfCertainBudget(
                          tbl, onlyShowTransactionsBelongingToBudget);
                } else if (isIncome == false) {
                  return onlyShowIfFollowsFilters(tbl,
                          budgetTransactionFilters: budgetTransactionFilters,
                          memberTransactionFilters: memberTransactionFilters) &
                      onlyShowBasedOnTimeRange(
                          transactions, startDate, endDate, budget) &
                      tbl.income.equals(false) &
                      onlyShowIfMember(tbl, member) &
                      onlyShowIfCertainBudget(
                          tbl, onlyShowTransactionsBelongingToBudget);
                } else {
                  return onlyShowIfFollowsFilters(tbl,
                          budgetTransactionFilters: budgetTransactionFilters,
                          memberTransactionFilters: memberTransactionFilters) &
                      onlyShowBasedOnTimeRange(
                          transactions, startDate, endDate, budget) &
                      onlyShowIfMember(tbl, member) &
                      onlyShowIfCertainBudget(
                          tbl, onlyShowTransactionsBelongingToBudget);
                }
              }
            })
            ..orderBy([(t) => OrderingTerm.desc(t.dateCreated)]))
          .watch();
    }
    return (select(transactions)
          ..where((tbl) {
            return onlyShowBasedOnTimeRange(
                    transactions, startDate, endDate, budget) &
                tbl.categoryFk.isIn(categoryFks) &
                onlyShowIfMember(tbl, member) &
                onlyShowIfCertainBudget(
                    tbl, onlyShowTransactionsBelongingToBudget);
          }))
        .watch();
  }

  Future<Transaction> getTransactionFromPk(int transactionPk) {
    return (select(transactions)
          ..where((t) => t.transactionPk.equals(transactionPk)))
        .getSingle();
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
    streamGroup.add(select(scannerTemplates).watch());
    return streamGroup.stream;
  }

  // transactions not belonging to a category should be deleted
  Future<bool> deleteWanderingTransactions() async {
    List<TransactionCategory> allCategories = await getAllCategories();
    List<int> categoryPks =
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
}
