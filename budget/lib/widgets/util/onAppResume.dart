import 'package:flutter/material.dart';

class OnAppResume extends StatefulWidget {
  const OnAppResume({
    super.key,
    required this.child,
    required this.onAppResume,
  });

  final Widget child;
  final VoidCallback onAppResume;

  @override
  State<OnAppResume> createState() => _OnAppResumeState();
}

class _OnAppResumeState extends State<OnAppResume> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  AppLifecycleState? _lastState;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (_lastState == null) {
      _lastState = state;
    }

    // app resumed
    if (state == AppLifecycleState.resumed &&
        (_lastState == AppLifecycleState.paused ||
            _lastState == AppLifecycleState.inactive)) {
      widget.onAppResume();
    }

    _lastState = state;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
