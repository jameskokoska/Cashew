import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:drift/drift.dart';
import 'dart:io';

part 'tables.g.dart';

// Generate databse code
// flutter packages pub run build_runner build

// Character Limits
const int NAME_LIMIT = 250;
const int NOTE_LIMIT = 500;
const int COLOUR_LIMIT = 50;
const int CURRENCY_LIMIT = 3;

// Query Constants
const int DEFAULT_LIMIT = 50;
const int DEFAULT_OFFSET = 0;

enum BudgetReoccurence { daily, weekly, monthly, yearly }
enum ThemeSetting { dark, light }

class IntListInColumnConverter extends TypeConverter<List<int>, String> {
  const IntListInColumnConverter();
  @override
  List<int>? mapToDart(String? label_fks_from_db) {
    if (label_fks_from_db == null) return null;
    return label_fks_from_db.split(',').map(int.parse).toList();
  }

  @override
  String? mapToSql(List<int>? label_fks) {
    if (label_fks == null) return null;
    throw label_fks.map((fk) => toString).join(',');
  }
}

@DataClassName('Transaction')
class Transactions extends Table {
  IntColumn get transactionPk => integer().autoIncrement()();
  TextColumn get name => text().withLength(max: NAME_LIMIT)();
  RealColumn get amount => real()();
  TextColumn get note => text().withLength(max: NOTE_LIMIT)();
  IntColumn get budgetFk => integer()();
  IntColumn get categoryFk => integer()();
  TextColumn get labelFks =>
      text().map(const IntListInColumnConverter()).nullable()();
  DateTimeColumn get dateCreated =>
      dateTime().clientDefault(() => new DateTime.now())();
}

@DataClassName('TransactionCategory')
class Categories extends Table {
  IntColumn get categoryPk => integer().autoIncrement()();
  TextColumn get name => text().withLength(max: NAME_LIMIT)();
  TextColumn get colour => text().withLength(max: COLOUR_LIMIT).nullable()();
  TextColumn get iconName => text().nullable()();
  DateTimeColumn get dateCreated =>
      dateTime().clientDefault(() => new DateTime.now())();
}

@DataClassName('TransactionLabel')
class Labels extends Table {
  IntColumn get label_pk => integer().autoIncrement()();
  TextColumn get name => text().withLength(max: NAME_LIMIT)();
  IntColumn get categoryFk => integer()();
  DateTimeColumn get dateCreated =>
      dateTime().clientDefault(() => new DateTime.now())();
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
  IntColumn get periodLength => integer()();
  IntColumn get reoccurrence => intEnum<BudgetReoccurence>().nullable()();
  // RealColumn get optimalDailySpending => real().nullable()();
  DateTimeColumn get dateCreated =>
      dateTime().clientDefault(() => new DateTime.now())();
}

@DataClassName('UserSettings')
class Settings extends Table {
  IntColumn get userPk => integer().autoIncrement()();
  TextColumn get name => text().withLength(max: NAME_LIMIT)();
  IntColumn get theme => intEnum<ThemeSetting>()();
  TextColumn get currency => text().withLength(max: CURRENCY_LIMIT)();
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}

@DriftDatabase(tables: [Transactions, Categories, Labels, Budgets, Settings])
class FinanceDatabase extends _$FinanceDatabase {
  FinanceDatabase() : super(_openConnection());

  // you should bump this number whenever you change or add a table definition
  @override
  int get schemaVersion => 3;

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

  // get all filtered transactions from a given budget ordered by date and paginated
  Stream<List<Transaction>> watchAllTransactionsFromBudgetFiltered(int budgetPk,
      {int? categoryPk, String? itemPk, int? limit, int? offset}) {
    return (categoryPk != null
            ? (select(transactions)
              ..where((tbl) => tbl.categoryFk.equals(categoryPk)))
            : itemPk != null
                ? (select(transactions)
                  ..where((tbl) => tbl.labelFks.contains(itemPk)))
                : select(transactions)
          ..where((tbl) => tbl.budgetFk.equals(budgetPk))
          ..orderBy([(t) => OrderingTerm.desc(t.dateCreated)])
          ..limit(limit ?? DEFAULT_LIMIT, offset: offset ?? DEFAULT_OFFSET))
        .watch();
  }

  //get transactions that occurred on a given date
  Stream<List<Transaction>> getTransactionWithDate(DateTime date) {
    return (select(transactions)..where((tbl) => tbl.dateCreated.equals(date)))
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

  // create or update a user's settings
  Future<int> createOrUpdateUserSettings(UserSettings setting) {
    return into(settings).insertOnConflictUpdate(setting);
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

  // TODO: add budget pk filter
  // get total amount spent in each category
  Stream<List<TypedResult>> watchTotalSpentInEachCategory() {
    final totalAmt = transactions.amount.sum();
    return (selectOnly(transactions).join([])
          ..addColumns([transactions.categoryFk, totalAmt])
          ..groupBy([transactions.categoryFk]))
        .watch();
  }

  // get total amount spent in each day
  Stream<List<Transaction>> watchTotalSpentEachDayInPeriod(
      DateTime startDate, DateTime endDate) {
    final totalAmt = transactions.amount.sum();
    final date = transactions.dateCreated.date;
    return (select(transactions)
          ..where((tbl) =>
              tbl.dateCreated.isBiggerOrEqualValue(startDate) &
              tbl.dateCreated.isSmallerOrEqualValue(endDate))
          ..addColumns([totalAmt, date]).join([]).groupBy([date]))
        .watch();
  }

  Stream<List<Transaction>> watchTotalSpentEachDay(int? budgetPk) {
    final totalAmt = transactions.amount.sum();
    final date = transactions.dateCreated.date;
    return (select(transactions)
          ..addColumns([totalAmt, date]).join([]).groupBy([date])
          ..orderBy([(t) => OrderingTerm.desc(t.dateCreated)]))
        .watch();
  }

  // TODO: total spent in each month
  // Stream<List<Transaction>> watchTotalSpentEachMonth() {
  //   final totalAmt = transactions.amount.sum();
  //   final month = transactions.dateCreated.date;
  //   return (select(transactions)
  //         ..addColumns([totalAmt, month]).join([]).groupBy([])
  //         ..orderBy([(t) => OrderingTerm.desc(t.dateCreated)]))
  //       .watch();
  // }
}
