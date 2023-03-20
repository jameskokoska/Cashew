// web.dart
import 'package:drift/web.dart';
import 'package:budget/database/tables.dart';

FinanceDatabase constructDb(String dbName) {
  return FinanceDatabase(WebDatabase(dbName, logStatements: false));
}
