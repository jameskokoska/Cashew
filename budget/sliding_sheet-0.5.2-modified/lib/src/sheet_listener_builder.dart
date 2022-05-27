import 'package:flutter/material.dart';

import 'sheet.dart';

/// A widget that can be used to react to changes in the [SheetState]
/// of a [SlidingSheet].
///
/// This is useful to implementing custom transitions for the [SlidingSheet].
class SheetListenerBuilder extends StatefulWidget {
  /// A callback that gets invoked whenever the [SheetState] of the [SlidingSheet]
  /// changes and [buildWhen] is `null` or returns `true`.
  final Widget Function(BuildContext context, SheetState state) builder;

  /// Can be used to conditionally invoke [builder] to improve performance.
  final bool Function(SheetState oldState, SheetState newState)? buildWhen;

  /// Creates a widget that can be used to react to changes in the [SheetState]
  /// of a [SlidingSheet].
  const SheetListenerBuilder({
    Key? key,
    required this.builder,
    this.buildWhen,
  }) : super(key: key);

  @override
  _SheetListenerBuilderState createState() => _SheetListenerBuilderState();
}

class _SheetListenerBuilderState extends State<SheetListenerBuilder> {
  SheetState _state = SheetState.inital();

  late final ValueNotifier<SheetState> _notifier = SheetState.notifier(context)
    ..addListener(_listener);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _state = _notifier.value;
  }

  void _listener() {
    final newState = _notifier.value;
    final shouldRebuild =
        widget.buildWhen == null || widget.buildWhen!(_state, newState);

    if (shouldRebuild) {
      _state = newState;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _state);

  @override
  void dispose() {
    _notifier.removeListener(_listener);
    super.dispose();
  }
}
