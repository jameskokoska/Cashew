import 'diff.dart';

class DiffDelegate<E> {
  final DiffCallback<E> _callback;
  const DiffDelegate(this._callback);

  void applyDiffs(List<Diff> diffs) {
    for (final diff in diffs) {
      if (diff is Insertion) {
        _applyInsertion(diff as Insertion<E>);
      } else if (diff is Deletion) {
        _applyDeletion(diff);
      } else if (diff is Modification) {
        _applyModification(diff as Modification<E>);
      }
    }
  }

  void _applyModification(Modification<E> diff) {
    final diffLength = diff.items.length;

    if (diff.size != diffLength) {
      if (diff.size > diffLength) {
        var sizeDifference = diff.size - diffLength;
        while (sizeDifference > 0) {
          _callback.onRemoved(diff.index + sizeDifference);
          sizeDifference--;
        }
      } else {
        var insertIndex = diff.size;
        while (insertIndex < diffLength) {
          _callback.onInserted(
            insertIndex + diff.index,
            diff.items[insertIndex],
          );
          insertIndex++;
        }
      }
    }

    final changedItems = diff.items.take(diff.size).toList();
    _callback.onChanged(diff.index, changedItems);
  }

  void _applyDeletion(Deletion diff) {
    for (var i = diff.size - 1; i >= 0; i--) {
      _callback.onRemoved(diff.index + i);
    }
  }

  void _applyInsertion(Insertion<E> diff) {
    for (var i = 0; i < diff.size; i++) {
      _callback.onInserted(diff.index + i, diff.items[i]);
    }
  }
}
