import 'dart:developer';
import 'package:async/async.dart' show StreamZip;
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/pages/editCategoriesPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/firebaseAuthGlobal.dart';
import 'package:budget/struct/shareBudget.dart';
import 'package:budget/widgets/globalSnackBar.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:drift/drift.dart';
import 'dart:io';
export 'platform/shared.dart';
import 'dart:convert';
part 'tables.g.dart';

int schemaVersionGlobal = 26;

// Generate database code
// flutter packages pub run build_runner build

// Character Limits
const int NAME_LIMIT = 250;
const int NOTE_LIMIT = 500;
const int COLOUR_LIMIT = 50;
const int CURRENCY_LIMIT = 3;

// Query Constants
const int DEFAULT_LIMIT = 50;
const int DEFAULT_OFFSET = 0;

enum BudgetReoccurence { custom, daily, weekly, monthly, yearly }

enum TransactionSpecialType {
  upcoming,
  subscription,
  repetitive,
  transactionTab
}

enum SharedOwnerMember {
  owner,
  member,
}

enum SharedTransactionsShow {
  fromEveryone,
  onlyIfOwner,
  onlyIfOwnerIfShared,
  onlyIfShared,
  onlyIfNotShared,
  excludeOther,
  excludeOtherIfShared,
  excludeOtherIfNotShared,
}

enum ThemeSetting { dark, light }

enum MethodAdded { email, shared, csv }

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

@DataClassName('TransactionWallet')
class Wallets extends Table {
  IntColumn get walletPk => integer().autoIncrement()();
  TextColumn get name => text().withLength(max: NAME_LIMIT)();
  TextColumn get colour => text().withLength(max: COLOUR_LIMIT).nullable()();
  TextColumn get iconName => text().nullable()(); // Money symbol
  DateTimeColumn get dateCreated =>
      dateTime().clientDefault(() => new DateTime.now())();
  IntColumn get order => integer()();
  TextColumn get currency => text().nullable()();
}

@DataClassName('Transaction')
class Transactions extends Table {
  IntColumn get transactionPk => integer().autoIncrement()();
  TextColumn get name => text().withLength(max: NAME_LIMIT)();
  RealColumn get amount => real()();
  TextColumn get note => text().withLength(max: NOTE_LIMIT)();
  IntColumn get categoryFk => integer().references(Categories, #categoryPk)();
  IntColumn get walletFk => integer().references(Wallets, #walletPk)();
  TextColumn get labelFks =>
      text().map(const IntListInColumnConverter()).nullable()();
  DateTimeColumn get dateCreated =>
      dateTime().clientDefault(() => new DateTime.now())();
  DateTimeColumn get dateTimeCreated =>
      dateTime().clientDefault(() => new DateTime.now()).nullable()();
  BoolColumn get income => boolean().withDefault(const Constant(false))();
  // Subscriptions and Repetitive payments
  IntColumn get periodLength => integer().nullable()();
  IntColumn get reoccurrence => intEnum<BudgetReoccurence>().nullable()();
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
  IntColumn get order => integer()();
  BoolColumn get income => boolean().withDefault(const Constant(false))();
  IntColumn get methodAdded => intEnum<MethodAdded>().nullable()();
  // Attributes to configure sharing of transactions:
  // sharedKey will have the key referencing the entry in the firebase database, if this is null, it is not shared
  TextColumn get sharedKey => text().nullable()();
  IntColumn get sharedOwnerMember => intEnum<SharedOwnerMember>().nullable()();
  DateTimeColumn get sharedDateUpdated => dateTime().nullable()();
  TextColumn get sharedMembers =>
      text().map(const StringListInColumnConverter()).nullable()();
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
  IntColumn get order => integer()();
  BoolColumn get isExactMatch => boolean().withDefault(const Constant(false))();
}

@DataClassName('TransactionLabel')
class Labels extends Table {
  IntColumn get label_pk => integer().autoIncrement()();
  TextColumn get name => text().withLength(max: NAME_LIMIT)();
  IntColumn get categoryFk => integer().references(Categories, #categoryPk)();
  DateTimeColumn get dateCreated =>
      dateTime().clientDefault(() => new DateTime.now())();
  IntColumn get order => integer()();
}

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
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();
  IntColumn get order => integer()();
  IntColumn get walletFk => integer().references(Wallets, #walletPk)();
  IntColumn get sharedTransactionsShow =>
      intEnum<SharedTransactionsShow>().withDefault(const Constant(0))();
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
  final double total;
  final int transactionCount;
  CategoryWithTotal({
    required this.category,
    required this.total,
    this.transactionCount = 0,
  });
}

@DriftDatabase(tables: [
  Wallets,
  Transactions,
  Categories,
  Labels,
  AssociatedTitles,
  Budgets,
  AppSettings,
  ScannerTemplates,
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
            await migrator.addColumn(categories, categories.sharedKey);
            await migrator.addColumn(
                transactions, transactions.dateTimeCreated);
          }
          if (from <= 15) {
            await migrator.addColumn(categories, categories.sharedOwnerMember);
            await migrator.addColumn(categories, categories.sharedDateUpdated);
          }
          if (from <= 19) {
            await migrator.addColumn(transactions, transactions.sharedStatus);
          }
          if (from <= 20) {
            await migrator.addColumn(
                transactions, transactions.sharedDateUpdated);
            await migrator.addColumn(budgets, budgets.sharedTransactionsShow);
          }
          if (from <= 21) {
            await migrator.addColumn(
                transactions, transactions.transactionOriginalOwnerEmail);
            await migrator.addColumn(categories, categories.sharedMembers);
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
            await migrator.addColumn(budgets, budgets.sharedAllMembersEver);
          }
          if (from <= 25) {
            await migrator.addColumn(budgets, budgets.addedTransactionsOnly);
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
  Stream<List<Transaction>> watchAllTransactionsFiltered(
      {int? categoryPk, String? itemPk, int? limit, int? offset}) {
    return (categoryPk != null
            ? (select(transactions)
              ..where((tbl) => tbl.categoryFk.equals(categoryPk)))
            : itemPk != null
                ? (select(transactions)
                  ..where((tbl) => tbl.labelFks.contains(itemPk)))
                : select(transactions)
          ..orderBy([(t) => OrderingTerm.desc(t.dateCreated)])
          ..limit(limit ?? DEFAULT_LIMIT, offset: offset ?? DEFAULT_OFFSET))
        .watch();
  }

  //get transactions that occurred on a given date
  Stream<List<Transaction>> getTransactionWithDate(DateTime date) {
    return (select(transactions)..where((tbl) => tbl.dateCreated.equals(date)))
        .watch();
  }

  //get transactions that occurred on a given day and category
  Stream<List<TransactionWithCategory>> getTransactionCategoryWithDay(
    DateTime date, {
    String search = "",
    // Search will be ignored... if these params are passed in
    List<int> categoryFks = const [],
    bool? income,
    required SharedTransactionsShow sharedTransactionsShow,
    String? member,
    int? onlyShowTransactionsBelongingToBudget,
  }) {
    JoinedSelectStatement<HasResultSet, dynamic> query;
    if (categoryFks.length > 0) {
      query = (select(transactions)
            ..where((tbl) {
              final dateCreated = tbl.dateCreated;
              return onlyShowIfOwner(tbl, sharedTransactionsShow) &
                  dateCreated.year.equals(date.year) &
                  dateCreated.month.equals(date.month) &
                  dateCreated.day.equals(date.day) &
                  onlyShowBasedOnCategoryFks(tbl, categoryFks) &
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
              return onlyShowIfOwner(tbl, sharedTransactionsShow) &
                  dateCreated.year.equals(date.year) &
                  dateCreated.month.equals(date.month) &
                  dateCreated.day.equals(date.day) &
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
              return onlyShowIfOwner(tbl, sharedTransactionsShow) &
                  dateCreated.year.equals(date.year) &
                  dateCreated.month.equals(date.month) &
                  dateCreated.day.equals(date.day) &
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

  Stream<List<DateTime?>> getUniqueDates({
    required DateTime start,
    required DateTime end,
    String search = "",
    // Search will be ignored... if these params are passed in
    List<int> categoryFks = const [],
    bool? income,
    required SharedTransactionsShow sharedTransactionsShow,
    String? member,
    int? onlyShowTransactionsBelongingToBudget,
    Budget? budget,
  }) {
    DateTime startDate = DateTime(start.year, start.month, start.day);
    DateTime endDate = DateTime(end.year, end.month, end.day);

    final query = selectOnly(transactions, distinct: true)
      ..orderBy([OrderingTerm.asc(transactions.dateCreated)])
      ..where(onlyShowIfOwner(transactions, sharedTransactionsShow) &
          onlyShowBasedOnTimeRange(transactions, startDate, endDate, budget) &
          onlyShowBasedOnCategoryFks(transactions, categoryFks) &
          onlyShowBasedOnIncome(transactions, income) &
          onlyShowIfMember(transactions, member) &
          onlyShowIfCertainBudget(
              transactions, onlyShowTransactionsBelongingToBudget))
      ..addColumns([transactions.dateCreated])
      ..where(transactions.dateCreated.isNotNull());

    return query.map((row) => row.read(transactions.dateCreated)).watch();
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
              return dateCreated.year.equals(date.year) &
                  dateCreated.month.equals(date.month) &
                  dateCreated.day.equals(date.day) &
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
              return dateCreated.year.equals(date.year) &
                  dateCreated.month.equals(date.month) &
                  dateCreated.day.equals(date.day);
            }))
          .join([
        leftOuterJoin(categories,
            categories.categoryPk.equalsExp(transactions.categoryFk))
      ]);
    } else {
      query = ((select(transactions)
            ..where((tbl) {
              final dateCreated = tbl.dateCreated;
              return dateCreated.year.equals(date.year) &
                  dateCreated.month.equals(date.month) &
                  dateCreated.day.equals(date.day);
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
      ..where((transaction) =>
          transactions.paid.equals(false) &
          transactions.type.equals(TransactionSpecialType.subscription.index));
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
  Stream<List<TransactionLabel>> watchAllLabelsInCategory(int? categoryPk) {
    return (categoryPk != null
            ? (select(labels)
              ..where((label) => label.categoryFk.equals(categoryPk)))
            : select(labels))
        .watch();
  }

  // watch all labels grouped by all category
  Stream<List<TypedResult>> watchAllLabelsGroupedByCategory() {
    return (select(categories).join([
      innerJoin(labels, labels.categoryFk.equalsExp(categories.categoryPk))
    ])
          ..groupBy([categories.categoryPk]))
        .watch();
  }

  // watch all budgets that have been created
  Stream<List<Budget>> watchAllBudgets({int? limit, int? offset}) {
    return (select(budgets)
          ..orderBy([(b) => OrderingTerm.asc(b.order)])
          ..limit(limit ?? DEFAULT_LIMIT, offset: offset ?? DEFAULT_OFFSET))
        .watch();
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

  Future<int> getAmountOfBudgets() async {
    return (await select(budgets).get()).length;
  }

  Future moveBudget(int budgetPk, int newPosition, int oldPosition) async {
    List<Budget> budgetsList = await (select(budgets)
          ..orderBy([(b) => OrderingTerm.asc(b.order)]))
        .get();
    if (newPosition > oldPosition) {
      for (Budget budget in budgetsList) {
        await (update(budgets)
              ..where(
                (b) =>
                    b.budgetPk.equals(budget.budgetPk) &
                    b.order.isBiggerOrEqualValue(oldPosition) &
                    b.order.isSmallerOrEqualValue(newPosition),
              ))
            .write(
          BudgetsCompanion(order: Value(budget.order - 1)),
        );
      }
    } else {
      for (Budget budget in budgetsList) {
        await (update(budgets)
              ..where(
                (b) =>
                    b.budgetPk.equals(budget.budgetPk) &
                    b.order.isBiggerOrEqualValue(newPosition) &
                    b.order.isSmallerOrEqualValue(oldPosition),
              ))
            .write(
          BudgetsCompanion(order: Value(budget.order + 1)),
        );
      }
    }
    await (update(budgets)
          ..where(
            (b) => b.budgetPk.equals(budgetPk),
          ))
        .write(
      BudgetsCompanion(order: Value(newPosition)),
    );
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
          BudgetsCompanion(order: Value(budget.order + direction)),
        );
      }
    } else {
      return false;
    }
    return true;
  }

  Stream<List<TransactionWallet>> watchAllWallets({int? limit, int? offset}) {
    return (select(wallets)
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
          ..orderBy([(w) => OrderingTerm.asc(w.dateCreated)])
          ..limit(limit ?? DEFAULT_LIMIT, offset: offset ?? DEFAULT_OFFSET))
        .get();
  }

  Future getAmountOfWallets() async {
    return (await select(budgets).get()).length;
  }

  Future moveWallet(int walletPk, int newPosition, int oldPosition) async {
    List<TransactionWallet> walletsList = await (select(wallets)
          ..orderBy([(w) => OrderingTerm.asc(w.order)]))
        .get();
    if (newPosition > oldPosition) {
      for (TransactionWallet wallet in walletsList) {
        await (update(wallets)
              ..where(
                (w) =>
                    w.walletPk.equals(wallet.walletPk) &
                    w.order.isBiggerOrEqualValue(oldPosition) &
                    w.order.isSmallerOrEqualValue(newPosition),
              ))
            .write(
          WalletsCompanion(order: Value(wallet.order - 1)),
        );
      }
    } else {
      for (TransactionWallet wallet in walletsList) {
        await (update(wallets)
              ..where(
                (w) =>
                    w.walletPk.equals(wallet.walletPk) &
                    w.order.isBiggerOrEqualValue(newPosition) &
                    w.order.isSmallerOrEqualValue(oldPosition),
              ))
            .write(
          WalletsCompanion(order: Value(wallet.order + 1)),
        );
      }
    }
    await (update(wallets)
          ..where(
            (w) => w.walletPk.equals(walletPk),
          ))
        .write(
      WalletsCompanion(order: Value(newPosition)),
    );
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
          WalletsCompanion(order: Value(wallet.order + direction)),
        );
      }
    } else {
      return false;
    }
    return true;
  }

  //Overwrite settings entry, it will always have id 0
  Future<int> createOrUpdateSettings(AppSetting setting) {
    return into(appSettings).insertOnConflictUpdate(setting);
  }

  //Overwrite settings entry, it will always have id 0
  Future<AppSetting> getSettings() {
    return (select(appSettings)..where((s) => s.settingsPk.equals(0)))
        .getSingle();
  }

  //create or update a new wallet
  Future<int> createOrUpdateWallet(TransactionWallet wallet) {
    //when the first wallet is created this will most likely be null, as we initialize the database before settings
    final Map<dynamic, dynamic> cachedWalletCurrencies =
        appStateSettings["cachedWalletCurrencies"] ?? {};
    cachedWalletCurrencies[wallet.walletPk.toString()] = wallet.currency ?? "";
    print(cachedWalletCurrencies);
    updateSettings("cachedWalletCurrencies", cachedWalletCurrencies,
        pagesNeedingRefresh: [], updateGlobalState: false);
    if (wallet.colour == null) {
      return into(wallets).insert(wallet, mode: InsertMode.insertOrReplace);
    }

    return into(wallets).insertOnConflictUpdate(wallet);
  }

  //create or update a new wallet
  Future<int> createOrUpdateScannerTemplate(ScannerTemplate scannerTemplate) {
    return into(scannerTemplates).insertOnConflictUpdate(scannerTemplate);
  }

  Stream<List<TransactionAssociatedTitle>> watchAllAssociatedTitles(
      {int? limit, int? offset}) {
    return (select(associatedTitles)
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
      {int? limit, int? offset}) {
    return (select(associatedTitles)
          ..where((t) =>
              t.title.lower().like(searchFor.toLowerCase().trim()) &
              t.categoryFk.equals(categoryFk))
        // ..limit(limit ?? DEFAULT_LIMIT, offset: offset ?? DEFAULT_OFFSET)
        )
        .getSingle();
  }

  Future<TransactionAssociatedTitle> getRelatingAssociatedTitle(
      String searchFor,
      {int? limit,
      int? offset}) {
    return (select(associatedTitles)
          ..where((t) => t.title.lower().like(searchFor.toLowerCase().trim()))
        // ..limit(limit ?? DEFAULT_LIMIT, offset: offset ?? DEFAULT_OFFSET)
        )
        .getSingle();
  }

  Future<TransactionCategory> getRelatingCategory(String searchFor,
      {int? limit, int? offset}) {
    return (select(categories)
          ..where((c) => c.name.lower().like(searchFor.toLowerCase().trim()))
          ..limit(limit ?? DEFAULT_LIMIT, offset: offset ?? DEFAULT_OFFSET))
        .getSingle();
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

  //create or update a new associatedTitle
  Future<int> createOrUpdateAssociatedTitle(
      TransactionAssociatedTitle associatedTitle) {
    return into(associatedTitles)
        .insert(associatedTitle, mode: InsertMode.insertOrReplace);
  }

  Future moveAssociatedTitle(
      int associatedTitlePk, int newPosition, int oldPosition) async {
    List<TransactionAssociatedTitle> associatedTitlesList =
        await (select(associatedTitles)
              ..orderBy([(t) => OrderingTerm.asc(t.order)]))
            .get();
    if (newPosition > oldPosition) {
      for (TransactionAssociatedTitle associatedTitle in associatedTitlesList) {
        await (update(associatedTitles)
              ..where(
                (t) =>
                    t.associatedTitlePk
                        .equals(associatedTitle.associatedTitlePk) &
                    t.order.isBiggerOrEqualValue(oldPosition) &
                    t.order.isSmallerOrEqualValue(newPosition),
              ))
            .write(
          AssociatedTitlesCompanion(order: Value(associatedTitle.order - 1)),
        );
      }
    } else {
      for (TransactionAssociatedTitle associatedTitle in associatedTitlesList) {
        await (update(associatedTitles)
              ..where(
                (t) =>
                    t.associatedTitlePk
                        .equals(associatedTitle.associatedTitlePk) &
                    t.order.isBiggerOrEqualValue(newPosition) &
                    t.order.isSmallerOrEqualValue(oldPosition),
              ))
            .write(
          AssociatedTitlesCompanion(order: Value(associatedTitle.order + 1)),
        );
      }
    }
    await (update(associatedTitles)
          ..where(
            (t) => t.associatedTitlePk.equals(associatedTitlePk),
          ))
        .write(
      AssociatedTitlesCompanion(order: Value(newPosition)),
    );
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
        transaction.amount == double.nan ||
        transaction.amount.isNaN) {
      return 0;
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
    return into(transactions)
        .insert(transaction, mode: InsertMode.insertOrReplace);
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

  // create or update a category
  Future<int> createOrUpdateCategory(TransactionCategory category,
      {bool updateSharedEntry = true}) async {
    // We need to ensure the value is set back to null, so insert/replace
    int result = await into(categories)
        .insert(category, mode: InsertMode.insertOrReplace);
    updateTransactionOnServerAfterChangingCategoryInformation(category);
    return result;
  }

  Future<int> createOrUpdateFromSharedBudget(Budget budget) async {
    if (budget.sharedKey != null) {
      Budget sharedBudget;

      try {
        // entry exists, update it
        sharedBudget = await (select(budgets)
              ..where((t) => t.sharedKey.equals(budget.sharedKey ?? "")))
            .getSingle();
        sharedBudget = budget.copyWith(
            budgetPk: sharedBudget.budgetPk,
            order: sharedBudget.order,
            pinned: sharedBudget.pinned);
        return into(budgets).insertOnConflictUpdate(sharedBudget);
      } catch (e) {
        // new entry is needed
        int numberOfBudgets = (await database.getAmountOfBudgets());
        sharedBudget = budget.copyWith(order: numberOfBudgets);
        return into(budgets).insertOnConflictUpdate(sharedBudget);
      }
    } else {
      return 0;
    }
  }

  Future<Budget> getSharedBudget(sharedKey) async {
    return await (select(budgets)..where((t) => t.sharedKey.equals(sharedKey)))
        .getSingle();
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
        sharedTransaction = await (select(transactions)
              ..where((t) =>
                  t.sharedKey.equals(transaction.sharedKey ?? "") |
                  t.sharedOldKey.equals(transaction.sharedKey ?? "")))
            .getSingle();
        sharedTransaction = transaction.copyWith(
            transactionPk: sharedTransaction.transactionPk);
        return into(transactions).insertOnConflictUpdate(sharedTransaction);
      } catch (e) {
        // new entry is needed
        return into(transactions).insertOnConflictUpdate(transaction);
      }
    } else {
      return 0;
    }
  }

  Future<int> deleteFromSharedTransaction(sharedTransactionKey) async {
    return (delete(transactions)
          ..where((t) => t.sharedKey.equals(sharedTransactionKey)))
        .go();
  }

  Future<List<Transaction>> get allTransactions => select(transactions).get();

  // create or update a label
  Future<int> createOrUpdateLabel(TransactionLabel label) {
    return into(labels).insertOnConflictUpdate(label);
  }

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

    return into(budgets).insert(budget, mode: InsertMode.replace);
  }

  // watch category given key
  Stream<TransactionCategory> getCategory(int categoryPk) {
    return (select(categories)..where((t) => t.categoryPk.equals(categoryPk)))
        .watchSingle();
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
  Future<TransactionCategory> getCategoryInstanceGivenName(String name) {
    return (select(categories)..where((t) => t.name.equals(name))).getSingle();
  }

  Stream<List<TransactionCategory>> watchAllCategories(
      {int? limit, int? offset}) {
    return (select(categories)
          ..orderBy([(c) => OrderingTerm.asc(c.order)])
          ..limit(limit ?? DEFAULT_LIMIT, offset: offset ?? DEFAULT_OFFSET))
        .watch();
  }

  Future<List<TransactionCategory>> getAllCategories(
      {int? limit, int? offset, List<int>? categoryFks, bool? allCategories}) {
    return (select(categories)
          ..where((c) => (allCategories != false
              ? c.categoryPk.isNotNull()
              : c.categoryPk.isIn(categoryFks ?? [])))
          ..orderBy([(c) => OrderingTerm.asc(c.order)])
          ..limit(limit ?? DEFAULT_LIMIT, offset: offset ?? DEFAULT_OFFSET))
        .get();
  }

  Future<List<Budget>> getAllBudgets({bool? sharedBudgetsOnly}) {
    return (select(budgets)
          ..where((b) => ((sharedBudgetsOnly == null
              ? b.sharedKey.isNotNull() | b.sharedKey.isNull()
              : sharedBudgetsOnly == true
                  ? b.sharedKey.isNotNull()
                  : b.sharedKey.isNull())))
          ..orderBy([(c) => OrderingTerm.asc(c.order)]))
        .get();
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
    if (newPosition > oldPosition) {
      for (TransactionCategory category in categoriesList) {
        await (update(categories)
              ..where(
                (c) =>
                    c.categoryPk.equals(category.categoryPk) &
                    c.order.isBiggerOrEqualValue(oldPosition) &
                    c.order.isSmallerOrEqualValue(newPosition),
              ))
            .write(
          CategoriesCompanion(order: Value(category.order - 1)),
        );
      }
    } else {
      for (TransactionCategory category in categoriesList) {
        await (update(categories)
              ..where(
                (c) =>
                    c.categoryPk.equals(category.categoryPk) &
                    c.order.isBiggerOrEqualValue(newPosition) &
                    c.order.isSmallerOrEqualValue(oldPosition),
              ))
            .write(
          CategoriesCompanion(order: Value(category.order + 1)),
        );
      }
    }
    await (update(categories)
          ..where(
            (c) => c.categoryPk.equals(categoryPk),
          ))
        .write(
      CategoriesCompanion(order: Value(newPosition)),
    );
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
          CategoriesCompanion(order: Value(category.order + direction)),
        );
      }
    } else {
      return false;
    }
    return true;
  }

  // get wallet given name
  Future<TransactionWallet> getWalletInstanceGivenName(String name) {
    return (select(wallets)..where((w) => w.name.equals(name))).getSingle();
  }

  // get wallet given id
  Future<TransactionWallet> getWalletInstance(int walletPk) {
    return (select(wallets)..where((w) => w.walletPk.equals(walletPk)))
        .getSingle();
  }

  // delete budget given key
  Future deleteBudget(context, Budget budget) async {
    if (budget.sharedKey != null) {
      dynamic response = await deleteSharedBudgetPopup(context, budget);
      if (response == false) {
        return -1;
      }
      loadingIndeterminateKey.currentState!.setVisibility(true);
      if (budget.sharedOwnerMember == SharedOwnerMember.owner) {
        bool result = await removedSharedFromBudget(budget);
      } else {
        bool result = await leaveSharedBudget(budget);
      }
      loadingIndeterminateKey.currentState!.setVisibility(false);
    }

    await shiftBudgets(-1, budget.order);
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

    return (delete(transactions)
          ..where((t) => t.transactionPk.isIn(transactionPks)))
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
    return (delete(wallets)..where((w) => w.walletPk.equals(walletPk))).go();
  }

  Future deleteScannerTemplate(int scannerTemplatePk) async {
    return (delete(scannerTemplates)
          ..where((s) => s.scannerTemplatePk.equals(scannerTemplatePk)))
        .go();
  }

  //delete transactions that belong to specific wallet key
  Future deleteWalletsTransactions(int walletPk) {
    return (delete(transactions)..where((t) => t.walletFk.equals(walletPk)))
        .go();
  }

  //delete associated title given key
  Future deleteAssociatedTitle(int associatedTitlePk, int order) async {
    await database.shiftAssociatedTitles(-1, order);
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
      final Map<TransactionCategory, double> categoryTotals = {};
      for (final list in lists) {
        for (final item in list) {
          categoryTotals[item.category] =
              (categoryTotals[item.category] ?? 0) + item.total;
        }
      }
      return lists
          .expand((list) => list)
          .map((item) => CategoryWithTotal(
                category: item.category,
                total: categoryTotals[item.category] ?? 0,
                transactionCount: item.transactionCount,
              ))
          .toList();
    });
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
      SharedTransactionsShow sharedTransactionsShow,
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
                onlyShowIfOwner(transactions, sharedTransactionsShow),
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
                onlyShowIfOwner(transactions, sharedTransactionsShow),
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

  Expression<bool> onlyShowIfOwner(
      $TransactionsTable tbl, SharedTransactionsShow sharedTransactionsShow) {
    return (sharedTransactionsShow == SharedTransactionsShow.onlyIfOwner
        ? (tbl.sharedKey.isNotNull() &
                tbl.transactionOwnerEmail
                    .equals(appStateSettings["currentUserEmail"])) |
            tbl.sharedKey.isNull()
        : (sharedTransactionsShow == SharedTransactionsShow.excludeOther)
            ? (tbl.sharedReferenceBudgetPk.isNull())
            : (sharedTransactionsShow ==
                    SharedTransactionsShow.excludeOtherIfShared)
                ? (tbl.sharedReferenceBudgetPk.isNull() |
                    tbl.sharedKey.isNull())
                : (sharedTransactionsShow ==
                        SharedTransactionsShow.excludeOtherIfNotShared)
                    ? (tbl.sharedReferenceBudgetPk.isNull() |
                        tbl.sharedKey.isNotNull())
                    : (sharedTransactionsShow ==
                            SharedTransactionsShow.onlyIfShared)
                        ? (tbl.sharedKey.isNotNull())
                        : (sharedTransactionsShow ==
                                SharedTransactionsShow.onlyIfNotShared)
                            ? (tbl.sharedKey.isNull())
                            : (sharedTransactionsShow ==
                                    SharedTransactionsShow.onlyIfOwnerIfShared)
                                ? (tbl.sharedReferenceBudgetPk.isNotNull() &
                                    tbl.sharedKey.isNotNull() &
                                    tbl.transactionOwnerEmail.equals(
                                        appStateSettings["currentUserEmail"]))
                                : tbl.sharedKey.isNotNull() |
                                    tbl.sharedKey.isNull());
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
                onlyShowIfOwner(
                    transactions, SharedTransactionsShow.onlyIfOwner) &
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
        : tbl.transactionOwnerEmail.isNull() |
            tbl.transactionOwnerEmail.isNotNull());
  }

  Expression<bool> onlyShowBasedOnIncome($TransactionsTable tbl, bool? income) {
    return (income != null
        ? tbl.income.equals(income)
        : tbl.income.isNull() | tbl.income.isNotNull());
  }

  Expression<bool> onlyShowBasedOnCategoryFks(
      $TransactionsTable tbl, List<int> categoryFks) {
    return (categoryFks.length >= 1
        ? tbl.categoryFk.isIn(categoryFks)
        : tbl.categoryFk.isNotNull());
  }

  Expression<bool> onlyShowBasedOnTimeRange($TransactionsTable tbl,
      DateTime startDate, DateTime endDate, Budget? budget) {
    return (budget != null &&
            // Only if an Added only, Custom budget -> show all transactions belonging to it, even if outside the date range
            (budget.addedTransactionsOnly == true &&
                budget.sharedKey == null &&
                budget.reoccurrence == BudgetReoccurence.custom)
        ? transactions.dateCreated.isNotNull()
        : transactions.dateCreated.isBetweenValues(startDate, endDate));
  }

  Expression<bool> onlyShowIfCertainBudget(
      $TransactionsTable tbl, int? budgetPk) {
    return (budgetPk != null
        ? tbl.sharedReferenceBudgetPk.equals(budgetPk)
        : tbl.sharedReferenceBudgetPk.isNull() |
            tbl.sharedReferenceBudgetPk.isNotNull());
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
    SharedTransactionsShow sharedTransactionsShow,
    List<TransactionWallet> wallets, {
    String? member,
    int? onlyShowTransactionsBelongingToBudget,
    Budget? budget,
  }) {
    DateTime startDate = DateTime(start.year, start.month, start.day);
    DateTime endDate = DateTime(end.year, end.month, end.day);
    List<Stream<List<CategoryWithTotal>>> mergedStreams = [];

    for (TransactionWallet wallet in wallets) {
      final totalAmt = transactions.amount.sum();
      final totalCount = transactions.transactionPk.count();

      final query = (select(transactions)
        ..where((tbl) {
          return onlyShowBasedOnTimeRange(
                  transactions, startDate, endDate, budget) &
              isInCategory(tbl, allCategories, categoryFks) &
              tbl.paid.equals(true) &
              tbl.income.equals(false) &
              transactions.walletFk.equals(wallet.walletPk) &
              onlyShowIfOwner(tbl, sharedTransactionsShow) &
              onlyShowIfMember(tbl, member) &
              onlyShowIfCertainBudget(
                  tbl, onlyShowTransactionsBelongingToBudget);
        })
        ..orderBy([(c) => OrderingTerm.desc(c.dateCreated)]));
      mergedStreams.add((query.join([
        leftOuterJoin(categories,
            categories.categoryPk.equalsExp(transactions.categoryFk))
      ])
            ..addColumns([totalAmt, totalCount])
            ..groupBy([categories.categoryPk])
            ..orderBy([OrderingTerm.asc(totalAmt)]))
          .map((row) {
        final TransactionCategory category = row.readTable(categories);
        final double? total = (row.read(totalAmt) ?? 0) *
            (amountRatioToPrimaryCurrency(wallet.currency) ?? 0);
        final int? transactionCount = row.read(totalCount);
        return CategoryWithTotal(
            category: category,
            total: total ?? 0,
            transactionCount: transactionCount ?? -1);
      }).watch());
    }

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

    return totalCategoryTotalStream(mergedStreams);
  }

  Stream<double?> watchTotalOfWallet(int walletPk) {
    final totalAmt = transactions.amount.sum();
    final query = selectOnly(transactions)
      ..addColumns([totalAmt])
      ..where(transactions.walletFk.equals(walletPk) &
          transactions.paid.equals(true));
    return query.map((row) => row.read(totalAmt)).watchSingleOrNull();
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

  Stream<List<int?>> watchTotalCountOfTransactionsInWallet(int walletPk) {
    final totalCount = transactions.transactionPk.count();
    final query = selectOnly(transactions)
      ..addColumns([totalCount])
      ..where(transactions.walletFk.equals(walletPk));
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

  Future<List<int?>> getTotalCountOfTransactionsInBudget(int budgetPk) async {
    final totalCount = transactions.transactionPk.count();
    final query = selectOnly(transactions)
      ..where(transactions.sharedReferenceBudgetPk.equals(budgetPk))
      ..addColumns([totalCount]);
    return query.map((row) => row.read(totalCount)).get();
  }

  // get all transactions that occurred in a given time period that belong to categories
  Stream<List<Transaction>> getTransactionsInTimeRangeFromCategories(
    DateTime start,
    DateTime end,
    List<int> categoryFks,
    bool allCategories,
    bool isPaidOnly,
    bool? isIncome,
    SharedTransactionsShow sharedTransactionsShow, {
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
                  return onlyShowIfOwner(tbl, sharedTransactionsShow) &
                      onlyShowBasedOnTimeRange(
                          transactions, startDate, endDate, budget) &
                      tbl.paid.equals(true) &
                      tbl.income.equals(true) &
                      onlyShowIfMember(tbl, member) &
                      onlyShowIfCertainBudget(
                          tbl, onlyShowTransactionsBelongingToBudget);
                } else if (isIncome == false) {
                  return onlyShowIfOwner(tbl, sharedTransactionsShow) &
                      onlyShowBasedOnTimeRange(
                          transactions, startDate, endDate, budget) &
                      tbl.paid.equals(true) &
                      tbl.income.equals(false) &
                      onlyShowIfMember(tbl, member) &
                      onlyShowIfCertainBudget(
                          tbl, onlyShowTransactionsBelongingToBudget);
                } else {
                  return onlyShowIfOwner(tbl, sharedTransactionsShow) &
                      onlyShowBasedOnTimeRange(
                          transactions, startDate, endDate, budget) &
                      tbl.paid.equals(true) &
                      onlyShowIfMember(tbl, member) &
                      onlyShowIfCertainBudget(
                          tbl, onlyShowTransactionsBelongingToBudget);
                }
              } else {
                if (isIncome == true) {
                  return onlyShowIfOwner(tbl, sharedTransactionsShow) &
                      onlyShowBasedOnTimeRange(
                          transactions, startDate, endDate, budget) &
                      tbl.income.equals(true) &
                      onlyShowIfMember(tbl, member) &
                      onlyShowIfCertainBudget(
                          tbl, onlyShowTransactionsBelongingToBudget);
                } else if (isIncome == false) {
                  return onlyShowIfOwner(tbl, sharedTransactionsShow) &
                      onlyShowBasedOnTimeRange(
                          transactions, startDate, endDate, budget) &
                      tbl.income.equals(false) &
                      onlyShowIfMember(tbl, member) &
                      onlyShowIfCertainBudget(
                          tbl, onlyShowTransactionsBelongingToBudget);
                } else {
                  return onlyShowIfOwner(tbl, sharedTransactionsShow) &
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
}
