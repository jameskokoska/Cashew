import 'package:implicitly_animated_reorderable_list/src/diff/myers_diff.dart';

// ignore_for_file: avoid_print

class Item {
  Item(this.id, this.value);

  int id;
  int value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Item && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

Future<void> main() async {
  final List<Item> list = List.generate(1000, (index) => Item(index, index));
  final List<Item> newList = List.from(list)..shuffle();

  final start = DateTime.now();
  await MyersDiff.diff<Item>(
    newList,
    list,
    areItemsTheSame: (a, b) => a.id == b.id,
  );

  final millis = DateTime.now().difference(start).inMilliseconds;
  print('Diffing ${newList.length} elements took $millis milliseconds.');
}
