import 'dart:math' as math;

import 'package:flutter/material.dart';

export 'handler.dart';
export 'invisible.dart';
export 'key_extensions.dart';

void postFrame(VoidCallback callback) =>
    WidgetsBinding.instance.addPostFrameCallback((_) => callback());

extension ListExtension<E> on List<E> {
  E? getOrNull(int index) {
    try {
      return this[index];
      // ignore: avoid_catching_errors
    } on Error {
      return null;
    } on Exception {
      return null;
    }
  }

  E? get firstOrNull => isNotEmpty ? first : null;
}

extension NumExtension<T extends num> on T {
  bool isBetween(T min, T max) => this >= min && this <= max;

  T atLeast(T min) => math.max(this, min);
  T atMost(T max) => math.min(this, max);
}
