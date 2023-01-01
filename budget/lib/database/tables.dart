import 'dart:developer';

import 'package:budget/main.dart';
import 'package:budget/pages/editCategoriesPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/firebaseAuthGlobal.dart';
import 'package:budget/widgets/globalSnackBar.dart';
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

int schemaVersionGlobal = 22;

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

enum CategoryOwnerMember {
  owner,
  member,
}

enum SharedTransactionsShow {
  fromEveryone,
  onlyIfOwner,
}

enum ThemeSetting { dark, light }

enum MethodAdded { email, shared }

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
  IntColumn get sharedStatus => intEnum<SharedStatus>().nullable()();
  DateTimeColumn get sharedDateUpdated => dateTime().nullable()();
}

// Server entry: (sub collection in category)
// "logType": "create", // create, delete, update
// "name": "transaction",
// "amount": 15.65,
// "note": "This is a note of a transaction",
// "dateCreated": DateTime.now(),
// "dateUpdated": DateTime.now(),
// "income": false,
// "ownerEmail": FirebaseAuth.instance.currentUser!.email,
// "originalCreatorEmail":
//     FirebaseAuth.instance.currentUser!.email,

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
  // Attributes to configure sharing of transactions:
  // sharedKey will have the key referencing the entry in the firebase database, if this is null, it is not shared
  TextColumn get sharedKey => text().nullable()();
  IntColumn get sharedOwnerMember =>
      intEnum<CategoryOwnerMember>().nullable()();
  DateTimeColumn get sharedDateUpdated => dateTime().nullable()();
  TextColumn get sharedMembers =>
      text().map(const StringListInColumnConverter()).nullable()();
}

// Server entry:
// "dateShared": DateTime.now(),
// "colour": toHexString(Colors.red),
// "icon": "icon.png",
// "name": "Food",
// "members": ["test@test.com"],
// "income": false,
// "owner": FirebaseAuth.instance.currentUser!.uid,
// "ownerEmail": FirebaseAuth.instance.currentUser!.email,

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
  IntColumn get periodLength => integer()();
  IntColumn get reoccurrence => intEnum<BudgetReoccurence>().nullable()();
  DateTimeColumn get dateCreated =>
      dateTime().clientDefault(() => new DateTime.now())();
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();
  IntColumn get order => integer()();
  IntColumn get walletFk => integer().references(Wallets, #walletPk)();
  IntColumn get sharedTransactionsShow =>
      intEnum<SharedTransactionsShow>().withDefault(const Constant(0))();
}

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
              ..where((tbl) =>
                  tbl.walletFk.equals(appStateSettings["selectedWallet"]) &
                  tbl.categoryFk.equals(categoryPk)))
            : itemPk != null
                ? (select(transactions)
                  ..where((tbl) =>
                      tbl.walletFk.equals(appStateSettings["selectedWallet"]) &
                      tbl.labelFks.contains(itemPk)))
                : select(transactions)
          ..where(
              (tbl) => tbl.walletFk.equals(appStateSettings["selectedWallet"]))
          ..orderBy([(t) => OrderingTerm.desc(t.dateCreated)])
          ..limit(limit ?? DEFAULT_LIMIT, offset: offset ?? DEFAULT_OFFSET))
        .watch();
  }

  // get all filtered transactions from a given budget ordered by date and paginated
  // Stream<List<Transaction>> watchAllTransactionsFromBudgetFiltered(int budgetPk,
  //     {int? categoryPk, String? itemPk, int? limit, int? offset}) {
  //   return (categoryPk != null
  //           ? (select(transactions)
  //             ..where((tbl) => tbl.walletFk.equals(appStateSettings["selectedWallet"]) & tbl.categoryFk.equals(categoryPk)))
  //           : itemPk != null
  //               ? (select(transactions)
  //                 ..where((tbl) => tbl.walletFk.equals(appStateSettings["selectedWallet"]) & tbl.labelFks.contains(itemPk)))
  //               : select(transactions)
  //         ..where((tbl) => tbl.walletFk.equals(appStateSettings["selectedWallet"]) & tbl.budgetFk.equals(budgetPk))
  //         ..orderBy([(t) => OrderingTerm.desc(t.dateCreated)])
  //         ..limit(limit ?? DEFAULT_LIMIT, offset: offset ?? DEFAULT_OFFSET))
  //       .watch();
  // }

  //get transactions that occurred on a given date
  Stream<List<Transaction>> getTransactionWithDate(DateTime date) {
    return (select(transactions)
          ..where((tbl) =>
              tbl.walletFk.equals(appStateSettings["selectedWallet"]) &
              tbl.dateCreated.equals(date)))
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
  }) {
    JoinedSelectStatement<HasResultSet, dynamic> query;
    if (categoryFks.length > 0) {
      query = (select(transactions)
            ..where((tbl) {
              final dateCreated = tbl.dateCreated;
              if (income == null)
                return onlyShowIfOwner(tbl, sharedTransactionsShow) &
                    tbl.walletFk.equals(appStateSettings["selectedWallet"]) &
                    dateCreated.year.equals(date.year) &
                    dateCreated.month.equals(date.month) &
                    dateCreated.day.equals(date.day) &
                    tbl.categoryFk.isIn(categoryFks);
              else
                return onlyShowIfOwner(tbl, sharedTransactionsShow) &
                    tbl.walletFk.equals(appStateSettings["selectedWallet"]) &
                    dateCreated.year.equals(date.year) &
                    dateCreated.month.equals(date.month) &
                    dateCreated.day.equals(date.day) &
                    tbl.categoryFk.isIn(categoryFks) &
                    tbl.income.equals(income);
            }))
          .join([
        innerJoin(categories,
            categories.categoryPk.equalsExp(transactions.categoryFk))
      ]);
    } else if (search == "") {
      query = (select(transactions)
            ..where((tbl) {
              final dateCreated = tbl.dateCreated;
              if (income == null)
                return onlyShowIfOwner(tbl, sharedTransactionsShow) &
                    tbl.walletFk.equals(appStateSettings["selectedWallet"]) &
                    dateCreated.year.equals(date.year) &
                    dateCreated.month.equals(date.month) &
                    dateCreated.day.equals(date.day);
              else
                return onlyShowIfOwner(tbl, sharedTransactionsShow) &
                    tbl.walletFk.equals(appStateSettings["selectedWallet"]) &
                    dateCreated.year.equals(date.year) &
                    dateCreated.month.equals(date.month) &
                    dateCreated.day.equals(date.day) &
                    tbl.income.equals(income);
            }))
          .join([
        innerJoin(categories,
            categories.categoryPk.equalsExp(transactions.categoryFk))
      ]);
    } else {
      query = ((select(transactions)
            ..where((tbl) {
              final dateCreated = tbl.dateCreated;
              if (income == null)
                return onlyShowIfOwner(tbl, sharedTransactionsShow) &
                    tbl.walletFk.equals(appStateSettings["selectedWallet"]) &
                    dateCreated.year.equals(date.year) &
                    dateCreated.month.equals(date.month) &
                    dateCreated.day.equals(date.day);
              else
                return onlyShowIfOwner(tbl, sharedTransactionsShow) &
                    tbl.walletFk.equals(appStateSettings["selectedWallet"]) &
                    dateCreated.year.equals(date.year) &
                    dateCreated.month.equals(date.month) &
                    dateCreated.day.equals(date.day) &
                    tbl.income.equals(income);
            }))
          .join([
        innerJoin(categories,
            categories.categoryPk.equalsExp(transactions.categoryFk))
      ]))
        ..where(categories.name.like("%" + search + "%") |
            transactions.name.like("%" + search + "%"));
    }

    return query.watch().map((rows) => rows.map((row) {
          return TransactionWithCategory(
              category: row.readTable(categories),
              transaction: row.readTable(transactions));
        }).toList());
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
              return tbl.walletFk.equals(appStateSettings["selectedWallet"]) &
                  dateCreated.year.equals(date.year) &
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
              return tbl.walletFk.equals(appStateSettings["selectedWallet"]) &
                  dateCreated.year.equals(date.year) &
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
              return tbl.walletFk.equals(appStateSettings["selectedWallet"]) &
                  dateCreated.year.equals(date.year) &
                  dateCreated.month.equals(date.month) &
                  dateCreated.day.equals(date.day);
            }))
          .join([
        innerJoin(categories,
            categories.categoryPk.equalsExp(transactions.categoryFk))
      ]))
        ..where(categories.name.like("%" + search + "%") |
            transactions.name.like("%" + search + "%"));
    }

    return query.watch().map((rows) => rows.map((row) {
          return TransactionWithCategory(
              category: row.readTable(categories),
              transaction: row.readTable(transactions));
        }).toList());
  }

  // //get days that transactions occurred on
  // Stream<List<DateTime?>> getDatesOfTransaction({
  //   String search = "",
  //   // Search will be ignored... if these params are passed in
  //   List<int> categoryFks = const [],
  // }) {
  //   final query = selectOnly(transactions, distinct: true)
  //     ..addColumns([transactions.dateCreated]);

  //   return query.map((row) => row.read(transactions.dateCreated)).watch();
  // }

  // Stream<List<DateTime?>> getDatesOfTransaction(
  //     {int? limit,
  //     String search = "",
  //     DateTime? startDate,
  //     DateTime? endDate}) {
  //   final query = (selectOnly(transactions)
  //     ..where(transactions.walletFk.equals(appStateSettings["selectedWallet"]) &
  //         transactions.dateCreated.isBiggerOrEqualValue(startDate) &
  //         transactions.dateCreated.isSmallerOrEqualValue(endDate))
  //     ..limit(limit ?? DEFAULT_LIMIT)
  //     ..addColumns([transactions.dateCreated])
  //     ..orderBy([
  //       OrderingTerm(
  //           expression: transactions.dateCreated, mode: OrderingMode.asc)
  //     ]));
  //   return query.map((row) => row.read(transactions.dateCreated)).watch();
  // }

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
            return tbl.walletFk.equals(appStateSettings["selectedWallet"]) &
                tbl.dateCreated.isBiggerOrEqualValue(startDate) &
                tbl.dateCreated.isSmallerOrEqualValue(endDate) &
                tbl.categoryFk.isIn(categoryFks);
          } else {
            return tbl.walletFk.equals(appStateSettings["selectedWallet"]) &
                tbl.categoryFk.isIn(categoryFks);
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
            return tbl.walletFk.equals(appStateSettings["selectedWallet"]) &
                tbl.dateCreated.isBiggerOrEqualValue(startDate) &
                tbl.dateCreated.isSmallerOrEqualValue(endDate);
          } else {
            return tbl.walletFk.equals(appStateSettings["selectedWallet"]);
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
                return tbl.walletFk.equals(appStateSettings["selectedWallet"]) &
                    tbl.dateCreated.isBiggerOrEqualValue(startDate) &
                    tbl.dateCreated.isSmallerOrEqualValue(endDate);
              } else {
                return tbl.walletFk.equals(appStateSettings["selectedWallet"]);
              }
            })
            ..orderBy([(t) => OrderingTerm.asc(t.dateCreated)]))
          .join([
        innerJoin(categories,
            categories.categoryPk.equalsExp(transactions.categoryFk))
      ]))
        ..where(categories.name.like("%" + search + "%") |
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
              return tbl.walletFk.equals(appStateSettings["selectedWallet"]) &
                  tbl.dateCreated.isBiggerOrEqualValue(startDate) &
                  tbl.dateCreated.isSmallerOrEqualValue(endDate);
            } else {
              return tbl.walletFk.equals(appStateSettings["selectedWallet"]);
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
        return tbl.walletFk.equals(appStateSettings["selectedWallet"]) &
            dateCreated.year.equals(date.year) &
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
    return into(associatedTitles).insertOnConflictUpdate(associatedTitle);
  }

  //create or update a new associatedTitle
  Future<int> createOrUpdateAssociatedTitleIfNew(
      TransactionAssociatedTitle associatedTitle) async {
    List<TransactionAssociatedTitle> associatedTitlesList =
        await (select(associatedTitles)
              ..orderBy([(t) => OrderingTerm.asc(t.order)]))
            .get();
    return into(associatedTitles).insertOnConflictUpdate(associatedTitle);
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
      {bool updateSharedEntry = true}) async {
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
    if (updateSharedEntry == true) {
      TransactionCategory category =
          await database.getCategoryInstance(transaction.categoryFk);
      if (transaction.sharedKey != null && category.sharedKey != null) {
        sendTransactionSet(transaction, category);
        transaction =
            transaction.copyWith(sharedStatus: Value(SharedStatus.waiting));
      } else if (transaction.sharedKey == null && category.sharedKey != null) {
        sendTransactionAdd(transaction, category);
        transaction =
            transaction.copyWith(sharedStatus: Value(SharedStatus.waiting));
      }
    }
    print(transaction);

    // We need to ensure the value is set back to null, so insert/replace
    if (transaction.sharedKey == null ||
        transaction.type == null ||
        transaction.sharedDateUpdated == null ||
        transaction.sharedStatus == null) {}

    return into(transactions).insertOnConflictUpdate(transaction);
  }

  // create or update a category
  Future<int> createOrUpdateCategory(TransactionCategory category,
      {bool updateSharedEntry = true}) async {
    // update category details on server
    if (updateSharedEntry == true && category.sharedKey != null) {
      FirebaseFirestore? db = await firebaseGetDBInstance();
      if (db == null) {
        return -1;
      }
      DocumentReference collectionRef =
          db.collection('categories').doc(category.sharedKey);
      collectionRef.update({
        "colour": category.colour,
        "iconName": category.iconName,
        "name": category.name,
        // "members": [
        //   // FirebaseAuth.instance.currentUser!.email
        // ],
        "income": category.income,
      });
    }

    // We need to ensure the value is set back to null, so insert/replace
    if (category.colour == null ||
        category.sharedDateUpdated == null ||
        category.sharedKey == null ||
        category.sharedOwnerMember == null ||
        category.sharedMembers == null) {
      return into(categories)
          .insert(category, mode: InsertMode.insertOrReplace);
    }
    return into(categories).insertOnConflictUpdate(category);
  }

  Future<int> createOrUpdateFromSharedCategory(
      TransactionCategory category) async {
    if (category.sharedKey != null) {
      TransactionCategory sharedCategory;

      try {
        // entry exists, update it
        sharedCategory = await (select(categories)
              ..where((t) => t.sharedKey.equals(category.sharedKey ?? "")))
            .getSingle();
        sharedCategory = category.copyWith(
            categoryPk: sharedCategory.categoryPk, order: sharedCategory.order);
        return into(categories).insertOnConflictUpdate(sharedCategory);
      } catch (e) {
        // new entry is needed
        int numberOfCategories =
            (await database.getTotalCountOfCategories())[0] ?? 0;
        sharedCategory = category.copyWith(order: numberOfCategories);
        return into(categories).insertOnConflictUpdate(sharedCategory);
      }
    } else {
      return 0;
    }
  }

  Future<TransactionCategory> getSharedCategory(sharedKey) async {
    return await (select(categories)
          ..where((t) => t.sharedKey.equals(sharedKey)))
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

  Future<int> createOrUpdateFromSharedTransaction(
      Transaction transaction) async {
    if (transaction.sharedKey != null) {
      Transaction sharedTransaction;
      try {
        // entry exists, update it
        sharedTransaction = await (select(transactions)
              ..where((t) => t.sharedKey.equals(transaction.sharedKey ?? "")))
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
  Future<int> createOrUpdateBudget(Budget budget) {
    if (budget.colour == null) {
      return into(budgets).insert(budget, mode: InsertMode.replace);
    }

    return into(budgets).insertOnConflictUpdate(budget);
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
      {int? limit, int? offset}) {
    return (select(categories)
          ..orderBy([(c) => OrderingTerm.asc(c.order)])
          ..limit(limit ?? DEFAULT_LIMIT, offset: offset ?? DEFAULT_OFFSET))
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
  Future deleteBudget(int budgetPk, int order) async {
    await shiftBudgets(-1, order);
    return (delete(budgets)..where((b) => b.budgetPk.equals(budgetPk))).go();
  }

  //delete transaction given key
  Future deleteTransaction(int transactionPk,
      {bool updateSharedEntry = true}) async {
    // Send the delete log to the server
    if (updateSharedEntry) {
      Transaction transactionToDelete =
          await database.getTransactionFromPk(transactionPk);
      TransactionCategory category =
          await database.getCategoryInstance(transactionToDelete.categoryFk);
      sendTransactionDelete(transactionToDelete, category);
    }

    return (delete(transactions)
          ..where((t) => t.transactionPk.equals(transactionPk)))
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
    await shiftCategories(-1, order);
    return (delete(categories)..where((c) => c.categoryPk.equals(categoryPk)))
        .go();
  }

  //delete transactions that belong to specific category key
  Future deleteCategoryTransactions(int categoryPk) {
    return (delete(transactions)..where((t) => t.categoryFk.equals(categoryPk)))
        .go();
  }

  //delete wallet given key
  Future deleteWallet(int walletPk, int order) async {
    if (walletPk == 0) {
      throw "Can't delete default wallet";
    }
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

  // TODO: add budget pk filter
  // get total amount spent in each category
  Stream<List<TypedResult>> watchTotalSpentInEachCategory() {
    final totalAmt = transactions.amount.sum();
    return (selectOnly(transactions).join([])
          ..addColumns([transactions.categoryFk, totalAmt])
          ..groupBy([transactions.categoryFk]))
        .watch();
  }

  Stream<double?> watchTotalSpentGivenList(List<int> transactionPks) {
    final totalAmt = transactions.amount.sum();
    JoinedSelectStatement<$TransactionsTable, Transaction> query;

    query = (selectOnly(transactions)
      ..addColumns([totalAmt])
      ..where(transactions.transactionPk.isIn(transactionPks)));
    return query.map(((row) => row.read(totalAmt))).watchSingle();
  }

  // get total amount spent in each day
  Stream<double?> watchTotalSpentInTimeRangeFromCategories(
      DateTime start, DateTime end, List<int>? categoryFks, bool allCategories,
      {bool allCashFlow = false}) {
    DateTime startDate = DateTime(start.year, start.month, start.day);
    DateTime endDate = DateTime(end.year, end.month, end.day);
    final totalAmt = transactions.amount.sum();
    final date = transactions.dateCreated.date;

    JoinedSelectStatement<$TransactionsTable, Transaction> query;
    if (allCategories) {
      query = (selectOnly(transactions)
        ..addColumns([totalAmt])
        ..where(
          transactions.walletFk.equals(appStateSettings["selectedWallet"]) &
              transactions.dateCreated.isBetweenValues(startDate, endDate) &
              transactions.paid.equals(true) &
              (allCashFlow
                  ? transactions.income.isIn([true, false])
                  : transactions.income.equals(false)),
        ));
    } else {
      query = (selectOnly(transactions)
        ..addColumns([totalAmt])
        ..where(
          transactions.walletFk.equals(appStateSettings["selectedWallet"]) &
              transactions.dateCreated.isBetweenValues(startDate, endDate) &
              transactions.categoryFk.isIn(categoryFks ?? []) &
              transactions.paid.equals(true) &
              (allCashFlow
                  ? transactions.income.isIn([true, false])
                  : transactions.income.equals(false)),
        ));
    }

    return query.map(((row) => row.read(totalAmt))).watchSingle();
  }

  Expression<bool> onlyShowIfOwner(
      $TransactionsTable tbl, SharedTransactionsShow sharedTransactionsShow) {
    return (sharedTransactionsShow == SharedTransactionsShow.onlyIfOwner
        ? (tbl.sharedKey.isNotNull() &
                tbl.transactionOwnerEmail
                    .equals(appStateSettings["currentUserEmail"])) |
            tbl.sharedKey.isNull()
        : tbl.sharedKey.isNotNull() | tbl.sharedKey.isNull());
  }

  Stream<double?> watchTotalSpentByCurrentUserOnly(
    DateTime start,
    DateTime end,
    List<int> categoryFks,
    bool allCategories,
  ) {
    DateTime startDate = DateTime(start.year, start.month, start.day);
    DateTime endDate = DateTime(end.year, end.month, end.day);
    final totalAmt = transactions.amount.sum();
    JoinedSelectStatement<$TransactionsTable, Transaction> query;

    query = (selectOnly(transactions)
      ..addColumns([totalAmt])
      ..where(transactions.walletFk.equals(appStateSettings["selectedWallet"]) &
          transactions.dateCreated.isBetweenValues(startDate, endDate) &
          transactions.paid.equals(true) &
          transactions.income.equals(false) &
          isInCategory(transactions, allCategories, categoryFks) &
          onlyShowIfOwner(transactions, SharedTransactionsShow.onlyIfOwner)));
    return query.map(((row) => row.read(totalAmt))).watchSingleOrNull();
  }

  Expression<bool> isInCategory(
      $TransactionsTable tbl, bool allCategories, List<int> categoryFks) {
    return allCategories
        ? tbl.categoryFk.isNotNull()
        : tbl.categoryFk.isIn(categoryFks);
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
  ) {
    DateTime startDate = DateTime(start.year, start.month, start.day);
    DateTime endDate = DateTime(end.year, end.month, end.day);
    final totalAmt = transactions.amount.sum();
    final totalCount = transactions.transactionPk.count();

    final query = (select(transactions)
      ..where((tbl) {
        final dateCreated = tbl.dateCreated;
        return tbl.walletFk.equals(appStateSettings["selectedWallet"]) &
            dateCreated.isBetweenValues(startDate, endDate) &
            isInCategory(tbl, allCategories, categoryFks) &
            tbl.paid.equals(true) &
            tbl.income.equals(false) &
            onlyShowIfOwner(tbl, sharedTransactionsShow);
      })
      ..orderBy([(c) => OrderingTerm.desc(c.dateCreated)]));
    return (query.join([
      leftOuterJoin(
          categories, categories.categoryPk.equalsExp(transactions.categoryFk))
    ])
          ..addColumns([totalAmt, totalCount])
          ..groupBy([categories.categoryPk])
          ..orderBy([OrderingTerm.asc(totalAmt)]))
        .map((row) {
      final TransactionCategory category = row.readTable(categories);
      final double? total = row.read(totalAmt);
      final int? transactionCount = row.read(totalCount);
      return CategoryWithTotal(
          category: category,
          total: total ?? 0,
          transactionCount: transactionCount ?? -1);
    }).watch();
  }

  // get total amount spent in each day
  Stream<List<Transaction>> watchTotalSpentEachDayInPeriod(
      DateTime startDate, DateTime endDate) {
    final totalAmt = transactions.amount.sum();
    final date = transactions.dateCreated.date;
    return (select(transactions)
          ..where((tbl) =>
              tbl.walletFk.equals(appStateSettings["selectedWallet"]) &
              tbl.dateCreated.isBiggerOrEqualValue(startDate) &
              tbl.dateCreated.isSmallerOrEqualValue(endDate) &
              tbl.paid.equals(true))
          ..addColumns([totalAmt, date]).join([]).groupBy([date]))
        .watch();
  }

  Stream<List<double?>> watchTotalOfWallet(int walletPk) {
    final totalAmt = transactions.amount.sum();
    final query = selectOnly(transactions)
      ..addColumns([totalAmt])
      ..where(transactions.walletFk.equals(walletPk) &
          transactions.paid.equals(true));
    return query.map((row) => row.read(totalAmt)).watch();
  }

  Stream<List<double?>> watchTotalOfSubscriptions() {
    final totalAmt = transactions.amount.sum();
    final query = selectOnly(transactions)
      ..addColumns([totalAmt])
      ..where(transactions.skipPaid.equals(false) &
          transactions.paid.equals(false) &
          transactions.type.equals(TransactionSpecialType.subscription.index));
    return query.map((row) => row.read(totalAmt)).watch();
  }

  Stream<List<double?>> watchTotalOfUpcoming() {
    final totalAmt = transactions.amount.sum();

    final query = selectOnly(transactions)
      ..addColumns([totalAmt])
      ..where(transactions.income.equals(false) &
          transactions.skipPaid.equals(false) &
          transactions.paid.equals(false) &
          transactions.dateCreated.isBiggerThanValue(DateTime.now()) &
          (transactions.type.equals(TransactionSpecialType.subscription.index) |
              transactions.type
                  .equals(TransactionSpecialType.repetitive.index) |
              transactions.type.equals(TransactionSpecialType.upcoming.index)));
    return query.map((row) => row.read(totalAmt)).watch();
  }

  Stream<List<double?>> watchTotalOfOverdue() {
    final totalAmt = transactions.amount.sum();

    final query = selectOnly(transactions)
      ..addColumns([totalAmt])
      ..where(transactions.income.equals(false) &
          transactions.skipPaid.equals(false) &
          transactions.paid.equals(false) &
          transactions.dateCreated.isSmallerThanValue(DateTime.now()) &
          (transactions.type.equals(TransactionSpecialType.subscription.index) |
              transactions.type
                  .equals(TransactionSpecialType.repetitive.index) |
              transactions.type.equals(TransactionSpecialType.upcoming.index)));
    return query.map((row) => row.read(totalAmt)).watch();
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

  Stream<List<Transaction>> watchTotalSpentEachDay(int? budgetPk) {
    final totalAmt = transactions.amount.sum();
    final date = transactions.dateCreated.date;
    return (select(transactions)
          ..where((tbl) {
            return tbl.walletFk.equals(
                appStateSettings["selectedWallet"] & tbl.paid.equals(true));
          })
          ..addColumns([totalAmt, date]).join([]).groupBy([date])
          ..orderBy([(t) => OrderingTerm.desc(t.dateCreated)]))
        .watch();
  }

  // get all transactions that occurred in a given time period that belong to categories
  Stream<List<Transaction>> getTransactionsInTimeRangeFromCategories(
    DateTime start,
    DateTime end,
    List<int> categoryFks,
    bool allCategories,
    bool isPaidOnly,
    bool? isIncome,
    SharedTransactionsShow sharedTransactionsShow,
  ) {
    DateTime startDate = DateTime(start.year, start.month, start.day);
    DateTime endDate = DateTime(end.year, end.month, end.day);
    if (allCategories) {
      return (select(transactions)
            ..where((tbl) {
              final dateCreated = tbl.dateCreated;
              if (isPaidOnly) {
                if (isIncome == true) {
                  return onlyShowIfOwner(tbl, sharedTransactionsShow) &
                      tbl.walletFk.equals(appStateSettings["selectedWallet"]) &
                      dateCreated.isBetweenValues(startDate, endDate) &
                      tbl.paid.equals(true) &
                      tbl.income.equals(true);
                } else if (isIncome == false) {
                  return onlyShowIfOwner(tbl, sharedTransactionsShow) &
                      tbl.walletFk.equals(appStateSettings["selectedWallet"]) &
                      dateCreated.isBetweenValues(startDate, endDate) &
                      tbl.paid.equals(true) &
                      tbl.income.equals(false);
                } else {
                  return onlyShowIfOwner(tbl, sharedTransactionsShow) &
                      tbl.walletFk.equals(appStateSettings["selectedWallet"]) &
                      dateCreated.isBetweenValues(startDate, endDate) &
                      tbl.paid.equals(true);
                }
              } else {
                if (isIncome == true) {
                  return onlyShowIfOwner(tbl, sharedTransactionsShow) &
                      tbl.walletFk.equals(appStateSettings["selectedWallet"]) &
                      dateCreated.isBetweenValues(startDate, endDate) &
                      tbl.income.equals(true);
                } else if (isIncome == false) {
                  return onlyShowIfOwner(tbl, sharedTransactionsShow) &
                      tbl.walletFk.equals(appStateSettings["selectedWallet"]) &
                      dateCreated.isBetweenValues(startDate, endDate) &
                      tbl.income.equals(false);
                } else {
                  return onlyShowIfOwner(tbl, sharedTransactionsShow) &
                      tbl.walletFk.equals(appStateSettings["selectedWallet"]) &
                      dateCreated.isBetweenValues(startDate, endDate);
                }
              }
            })
            ..orderBy([(t) => OrderingTerm.desc(t.dateCreated)]))
          .watch();
    }
    return (select(transactions)
          ..where((tbl) {
            final dateCreated = tbl.dateCreated;
            return tbl.walletFk.equals(appStateSettings["selectedWallet"]) &
                dateCreated.isBetweenValues(startDate, endDate) &
                tbl.categoryFk.isIn(categoryFks);
          }))
        .watch();
  }

  Future<Transaction> getTransactionFromPk(int transactionPk) {
    return (select(transactions)
          ..where((t) => t.transactionPk.equals(transactionPk)))
        .getSingle();
  }
  // TODO: total spent in each month
  // Stream<List<Transaction>> watchTotalSpentEachMonth() {
  //   final totalAmt = transactions.amount.sum();
  //   final month = transactions.dateCreated.date;
  //   return (select(transactions)
  //         ..where((tbl) {
  //           return tbl.walletFk.equals(appStateSettings["selectedWallet"]);
  //         })
  //         ..addColumns([totalAmt, month]).join([]).groupBy([])
  //         ..orderBy([(t) => OrderingTerm.desc(t.dateCreated)]))
  //       .watch();
  // }
}
