class Throttler {
  DateTime? _lastCallTime;
  bool _throttling = false;
  final Duration _duration;

  Throttler({required Duration duration}) : _duration = duration;

  bool canProceed() {
    final now = DateTime.now();

    if (_throttling) {
      if (_lastCallTime != null && now.difference(_lastCallTime!) < _duration) {
        return false;
      } else {
        _throttling = false;
      }
    }

    _throttling = true;
    _lastCallTime = now;
    Future.delayed(_duration, () {
      _throttling = false;
    });
    return true;
  }
}
