import 'dart:developer';

import 'package:budget/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:drift/drift.dart';
import 'dart:io';
export 'platform/shared.dart';
import 'dart:convert';
part 'tables.g.dart';

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
enum ThemeSetting { dark, light }

class IntListInColumnConverter extends TypeConverter<List<int>, String> {
  const IntListInColumnConverter();
  @override
  List<int>? mapToDart(String? string_from_db) {
    if (string_from_db == null) return null;
    // return label_fks_from_db.split(',').map(int.parse).toList();
    return new List<int>.from(json.decode(string_from_db));
  }

  @override
  String? mapToSql(List<int>? ints) {
    if (ints == null) return null;
    // throw label_fks.map((fk) => toString).join(',');
    return json.encode(ints);
  }
}

class StringListInColumnConverter extends TypeConverter<List<String>, String> {
  const StringListInColumnConverter();
  @override
  List<String>? mapToDart(String? string_from_db) {
    if (string_from_db == null) return null;
    // return label_fks_from_db.split(',').map(int.parse).toList();
    return new List<String>.from(json.decode(string_from_db));
  }

  @override
  String? mapToSql(List<String>? strings) {
    if (strings == null) return null;
    // throw label_fks.map((fk) => toString).join(',');
    return json.encode(strings);
  }
}

@DataClassName('TransactionWallet')
class Wallets extends Table {
  IntColumn get walletPk => integer().autoIncrement()();
  TextColumn get name => text().withLength(max: NAME_LIMIT)();
  TextColumn get colour => text().withLength(max: COLOUR_LIMIT).nullable()();
  TextColumn get iconName => text().nullable()();
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
  IntColumn get categoryFk => integer()();
  IntColumn get walletFk => integer()();
  TextColumn get labelFks =>
      text().map(const IntListInColumnConverter()).nullable()();
  DateTimeColumn get dateCreated =>
      dateTime().clientDefault(() => new DateTime.now())();
  BoolColumn get income => boolean().withDefault(const Constant(false))();
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
  //If a title is in a smart label, automatically choose this category
  // For e.g. for Food category
  // smartLabels = ["apple", "pear"]
  // Then when user sets title to pineapple, it will set the category to Food. Because "apple" is in "pineapple".
  TextColumn get smartLabels =>
      text().map(const StringListInColumnConverter()).nullable()();
}

@DataClassName('TransactionLabel')
class Labels extends Table {
  IntColumn get label_pk => integer().autoIncrement()();
  TextColumn get name => text().withLength(max: NAME_LIMIT)();
  IntColumn get categoryFk => integer()();
  DateTimeColumn get dateCreated =>
      dateTime().clientDefault(() => new DateTime.now())();
  IntColumn get order => integer()();
}

@DataClassName('Budget')
class Budgets extends Table {
  IntColumn get budgetPk => integer().autoIncrement()();
  TextColumn get name => text().withLength(max: NAME_LIMIT)();
  RealColumn get amount => real()();
  TextColumn get colour => text().withLength(max: COLOUR_LIMIT)();
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
  IntColumn get walletFk => integer()();
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

@DriftDatabase(tables: [Wallets, Transactions, Categories, Labels, Budgets])
class FinanceDatabase extends _$FinanceDatabase {
  // FinanceDatabase() : super(_openConnection());
  FinanceDatabase(QueryExecutor e) : super(e);

  // you should bump this number whenever you change or add a table definition
  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration =>
      MigrationStrategy(onUpgrade: (migrator, from, to) async {});

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
  }) {
    print(appStateSettings["selectedWallet"]);
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

  //watch all transactions sorted by date
  Stream<List<Transaction>> watchAllTransactions({int? limit}) {
    return (select(transactions)
          ..where((tbl) {
            return tbl.walletFk.equals(appStateSettings["selectedWallet"]);
          })
          ..orderBy([(b) => OrderingTerm.desc(b.dateCreated)])
          ..limit(limit ?? DEFAULT_LIMIT))
        .watch();
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

  // watch all categories
  Stream<List<TransactionCategory>> watchAllCategories() {
    return (select(categories)).watch();
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
          ..orderBy([(b) => OrderingTerm.desc(b.dateCreated)])
          ..limit(limit ?? DEFAULT_LIMIT, offset: offset ?? DEFAULT_OFFSET))
        .watch();
  }

  // watch all budgets that have been created that are pinned
  Stream<List<Budget>> watchAllPinnedBudgets({int? limit, int? offset}) {
    return (select(budgets)
          ..where((tbl) => tbl.pinned)
          ..orderBy([(b) => OrderingTerm.desc(b.dateCreated)])
          ..limit(limit ?? DEFAULT_LIMIT, offset: offset ?? DEFAULT_OFFSET))
        .watch();
  }

  Stream<List<TransactionWallet>> watchAllWallets({int? limit, int? offset}) {
    return (select(wallets)
          ..orderBy([(w) => OrderingTerm.desc(w.dateCreated)])
          ..limit(limit ?? DEFAULT_LIMIT, offset: offset ?? DEFAULT_OFFSET))
        .watch();
  }

  Future<List<TransactionWallet>> getAllWallets({int? limit, int? offset}) {
    return (select(wallets)
          ..orderBy([(w) => OrderingTerm.desc(w.dateCreated)])
          ..limit(limit ?? DEFAULT_LIMIT, offset: offset ?? DEFAULT_OFFSET))
        .get();
  }

  //create or update a new wallet
  Future<int> createOrUpdateWallet(TransactionWallet wallet) {
    return into(wallets).insertOnConflictUpdate(wallet);
  }

  // create or update a new transaction
  Future<int> createOrUpdateTransaction(Transaction transaction) {
    return into(transactions).insertOnConflictUpdate(transaction);
  }

  // create or update a category
  Future<int> createOrUpdateCategory(TransactionCategory category) {
    return into(categories).insertOnConflictUpdate(category);
  }

  // create or update a label
  Future<int> createOrUpdateLabel(TransactionLabel label) {
    return into(labels).insertOnConflictUpdate(label);
  }

  // create or update a budget
  Future<int> createOrUpdateBudget(Budget budget) {
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

  // delete budget given key
  Future deleteBudget(int budgetPk) {
    return (delete(budgets)..where((t) => t.budgetPk.equals(budgetPk))).go();
  }

  //delete transaction given key
  Future deleteTransaction(int transactionPk) {
    return (delete(transactions)
          ..where((t) => t.transactionPk.equals(transactionPk)))
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

  // The total amount of that category will always be that last column
  // print(snapshot.data![0].rawData.data["transactions.category_fk"]);
  // print(snapshot.data![0].rawData.data["c" + (snapshot.data![0].rawData.data.length).toString()]);
  Stream<List<CategoryWithTotal>>
      watchTotalSpentInEachCategoryInTimeRangeFromCategories(DateTime start,
          DateTime end, List<int> categoryFks, bool allCategories) {
    DateTime startDate = DateTime(start.year, start.month, start.day);
    DateTime endDate = DateTime(end.year, end.month, end.day);
    final totalAmt = transactions.amount.sum();
    final totalCount = transactions.transactionPk.count();

    if (allCategories) {
      final query = (select(transactions)
        ..where((tbl) {
          final dateCreated = tbl.dateCreated;
          return tbl.walletFk.equals(appStateSettings["selectedWallet"]) &
              dateCreated.isBetweenValues(startDate, endDate);
        })
        ..orderBy([(t) => OrderingTerm.desc(t.dateCreated)]));
      return (query.join([
        leftOuterJoin(categories,
            categories.categoryPk.equalsExp(transactions.categoryFk))
      ])
            ..addColumns([totalAmt, totalCount])
            ..groupBy([categories.categoryPk]))
          .map((row) {
        final category = row.readTable(categories);
        final total = row.read(totalAmt);
        final transactionCount = row.read(totalCount);
        return CategoryWithTotal(
            category: category,
            total: total ?? 0,
            transactionCount: transactionCount);
      }).watch();
    } else {
      final query = (select(transactions)
        ..where((tbl) {
          final dateCreated = tbl.dateCreated;
          return tbl.walletFk.equals(appStateSettings["selectedWallet"]) &
              dateCreated.isBetweenValues(startDate, endDate) &
              tbl.categoryFk.isIn(categoryFks);
        }));
      return (query.join([
        leftOuterJoin(categories,
            categories.categoryPk.equalsExp(transactions.categoryFk))
      ])
            ..addColumns([totalAmt, totalCount])
            ..groupBy([categories.categoryPk]))
          .map((row) {
        final category = row.readTable(categories);
        final total = row.read(totalAmt);
        final transactionCount = row.read(totalCount);

        return CategoryWithTotal(
            category: category,
            total: total ?? 0,
            transactionCount: transactionCount);
      }).watch();
    }
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
              tbl.dateCreated.isSmallerOrEqualValue(endDate))
          ..addColumns([totalAmt, date]).join([]).groupBy([date]))
        .watch();
  }

  Stream<List<Transaction>> watchTotalSpentEachDay(int? budgetPk) {
    final totalAmt = transactions.amount.sum();
    final date = transactions.dateCreated.date;
    return (select(transactions)
          ..where((tbl) {
            return tbl.walletFk.equals(appStateSettings["selectedWallet"]);
          })
          ..addColumns([totalAmt, date]).join([]).groupBy([date])
          ..orderBy([(t) => OrderingTerm.desc(t.dateCreated)]))
        .watch();
  }

  // get all transactions that occurred in a given time period that belong to categories
  Stream<List<Transaction>> getTransactionsInTimeRangeFromCategories(
      DateTime start, DateTime end, List<int> categoryFks, bool allCategories) {
    DateTime startDate = DateTime(start.year, start.month, start.day);
    DateTime endDate = DateTime(end.year, end.month, end.day);
    if (allCategories) {
      return (select(transactions)
            ..where((tbl) {
              final dateCreated = tbl.dateCreated;
              return tbl.walletFk.equals(appStateSettings["selectedWallet"]) &
                  dateCreated.isBetweenValues(startDate, endDate);
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
