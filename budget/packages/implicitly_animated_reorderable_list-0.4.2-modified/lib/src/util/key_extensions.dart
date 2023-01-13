import 'package:flutter/material.dart';

extension GlobalKeyExtension on GlobalKey {
  RenderBox? get renderBox => currentContext?.renderBox;

  Size? get size => renderBox?.size;

  double? get height => size?.height;

  double? get width => size?.width;

  Offset? get offset => renderBox?.offset;
}

extension BuildContextExtension on BuildContext {
  RenderBox? get renderBox => findRenderObject() as RenderBox?;

  Size? get size => renderBox?.size;

  double? get height => size?.height;

  double? get width => size?.width;

  Offset? get offset => renderBox?.offset;
}

extension RenderBoxExtension on RenderBox {
  Offset get offset => localToGlobal(Offset.zero);
}
