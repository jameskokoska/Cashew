typedef ItemDiffUtil<E> = bool Function(E oldItem, E newItem);

/// A Callback class used by DiffUtil while calculating the diff between two lists.
mixin DiffCallback<E> {
  /// The list containing the new data.
  List<E>? get newList;

  /// The list containing the old data.
  List<E>? get oldList;

  /// Returns the size of the old list.
  int get oldListSize => oldList!.length;

  /// Returns the size of the list.
  int get newListSize => newList!.length;

  /// Called by the DiffUtil to decide whether two object represent the same Item.
  /// For example, if your items have unique ids, this method should check their id equality.
  bool areItemsTheSame(E oldItem, E newItem);

  /// Called by the DiffUtil to decide whether two object represent the same Item.
  /// For example, if your items have unique ids, this method should check their id equality.
  bool areContentsTheSame(E oldItem, E newItem);

  dynamic getChangePayload(E oldItem, E newItem) => null;

  /// Called when an item was inserted into the list.
  void onInserted(int index, E item);

  /// Called when an item was removed from the list.
  void onRemoved(int index);

  /// Called when an item in the list changed but not its position in the list.
  void onChanged(int startIndex, List<E> itemsChanged);
}
