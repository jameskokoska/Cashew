import 'package:flutter/material.dart';
import 'dart:math';

class LongPressListener extends StatefulWidget {
  LongPressListener({
    required this.child,
    required this.onLongPress,
    Key? key,
  }) : super(key: key);

  final Widget child;
  final VoidCallback onLongPress;

  @override
  _LongPressListenerState createState() => _LongPressListenerState();
}

class _LongPressListenerState extends State<LongPressListener> {
  bool _longPressInProgress = false;
  Offset? _longPressStartPosition;
  final Duration _longPressDuration = Duration(milliseconds: 500);
  final double _maxDistanceForLongPress = 30;

  void _handlePointerDown(PointerDownEvent event) {
    _longPressInProgress = true;
    _longPressStartPosition = event.localPosition;
    Future.delayed(_longPressDuration, _handleLongPressTimer);
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (_longPressInProgress) {
      final dx = event.localPosition.dx - _longPressStartPosition!.dx;
      final dy = event.localPosition.dy - _longPressStartPosition!.dy;
      final distance = sqrt(dx * dx + dy * dy);
      if (distance > _maxDistanceForLongPress) {
        _longPressInProgress = false;
      }
    }
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (_longPressInProgress) {
      final dx = event.localPosition.dx - _longPressStartPosition!.dx;
      final dy = event.localPosition.dy - _longPressStartPosition!.dy;
      final distance = sqrt(dx * dx + dy * dy);
      if (distance <= _maxDistanceForLongPress) {
        print('Long press detected!');
      }
      _longPressInProgress = false;
    }
  }

  void _handleLongPressTimer() {
    if (_longPressInProgress) {
      _longPressInProgress = false;
      final dx = 0.0;
      final dy = 0.0;
      final distance = sqrt(dx * dx + dy * dy);
      if (distance <= _maxDistanceForLongPress) {
        widget.onLongPress();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _handlePointerDown,
      onPointerMove: _handlePointerMove,
      onPointerUp: _handlePointerUp,
      child: widget.child,
    );
  }
}
