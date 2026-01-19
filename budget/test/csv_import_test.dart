import 'package:csv/csv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CSV with newline in field should be parsed correctly', () {
    const csvString =
        'Date,Amount,Category,Title,Note,Account\n11/11/2021 10:10:00,10,Dining,McD,"Burger\nChicken",Bank';
    final List<List<dynamic>> result =
        const CsvToListConverter().convert(csvString);
    expect(result.length, 2);
    expect(result[1][4], "Burger\nChicken");
  });
}
