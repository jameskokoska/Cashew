abstract class Diff implements Comparable<Diff> {
  final int index;
  final int size;
  const Diff(
    this.index,
    this.size,
  );

  @override
  String toString() => '${runtimeType.toString()}(index: $index, size: $size)';

  @override
  int compareTo(Diff other) => index - other.index;
}

class Insertion<E> extends Diff {
  final List<E> items;
  const Insertion(
    int index,
    int size,
    this.items,
  ) : super(index, size);
}

class Deletion extends Diff {
  const Deletion(
    int index,
    int size,
  ) : super(index, size);
}

class Modification<E> extends Diff {
  final List<E> items;
  const Modification(
    int index,
    int size,
    this.items,
  ) : super(index, size);

  @override
  String toString() {
    return '${runtimeType.toString()}(index: $index, size: $size, items: $items)';
  }
}
