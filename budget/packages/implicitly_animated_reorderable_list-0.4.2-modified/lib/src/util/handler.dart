import 'package:flutter/rendering.dart';

/// A class that can schedule a function to run at a later time using Future.delayed.
/// Additionally it supports canceling the future by not invoking the callback function
/// if it was canceled before.
class Handler {
  VoidCallback? _callback;
  bool _canceled = false;
  bool _finished = false;
  bool _invoked = false;

  void post(Duration delay, VoidCallback callback) {
    if (!_invoked) {
      _callback = callback;
      _invoked = true;

      Future.delayed(delay, () {
        if (!isFinished) {
          callback();
        }

        _finished = true;
      });
    }
  }

  void runNow() {
    if (!isFinished) {
      _callback?.call();
      _finished = true;
    }
  }

  bool get isFinished => _finished || _canceled;
  bool get isCanceled => _canceled;

  void cancel() => _canceled = true;
}

Handler post(int delay, VoidCallback callback) {
  return Handler()..post(Duration(milliseconds: delay), callback);
}

Handler postDuration(Duration delay, VoidCallback callback) {
  return Handler()..post(delay, callback);
}
