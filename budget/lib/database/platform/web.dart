// web.dart
import 'package:drift/web.dart';
import 'package:budget/database/tables.dart';

FinanceDatabase constructDb() {
  return FinanceDatabase(WebDatabase('db', logStatements: false));
}
