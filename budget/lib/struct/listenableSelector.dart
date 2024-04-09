// From: https://gist.github.com/PlugFox/9c1f3b0ee5038fa0832d3d495d9aa792

import 'package:flutter/foundation.dart'
    show Listenable, ValueListenable, VoidCallback, ChangeNotifier;

/// Selector from [Listenable]
typedef ListenableSelector<Controller extends Listenable, Value> = Value
    Function(
  Controller controller,
);

/// Filter for [Listenable]
typedef ListenableFilter<Value> = bool Function(Value prev, Value next);

/// Selects a specific value from the [Listenable]
/// for subsequent use in the ValueListenableBuilder
///
/// Listenable -- selector & filter --> ValueListenable<Value>
///
/// For example:
/// ```dart
/// ValueListenableBuilder<Locale>(
///   valueListenable: appModel.select<Locale>(
///     (cn) => cn.locale,
///     (prev, next) => prev.languageCode != next.languageCode
///   ),
///   builder: (context, locale, child) => Text(locale.languageCode),
/// )
/// ```
extension ListenableSelectorExtension<Controller extends Listenable>
    on Controller {
  /// Transform [Listenable] in to [ValueListenable]
  ValueListenable<Value> select<Value>(
    ListenableSelector<Controller, Value> selector, [
    ListenableFilter<Value>? test,
  ]) =>
      _ValueListenableView<Controller, Value>(this, selector, test);
}

class _ValueListenableView<Controller extends Listenable, Value>
    with ChangeNotifier
    implements ValueListenable<Value> {
  _ValueListenableView(
    Controller controller,
    ListenableSelector<Controller, Value> selector,
    ListenableFilter<Value>? test,
  )   : _controller = controller,
        _selector = selector,
        _test = test;

  final Controller _controller;
  final ListenableSelector<Controller, Value> _selector;
  final ListenableFilter<Value>? _test;

  @override
  Value get value => hasListeners ? _$value : _selector(_controller);

  late Value _$value;

  void _update() {
    final newValue = _selector(_controller);
    if (_$value is String && newValue is String && _$value == newValue) return;
    if (identical(_$value, newValue)) return;
    if (!(_test?.call(_$value, newValue) ?? true)) return;
    _$value = newValue;
    notifyListeners();
  }

  @override
  void addListener(VoidCallback listener) {
    if (!hasListeners) {
      _$value = _selector(_controller);
      _controller.addListener(_update);
    }
    super.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (!hasListeners) _controller.removeListener(_update);
  }

  @override
  void dispose() {
    _controller.removeListener(_update);
    super.dispose();
  }
}
