import 'package:flutter/material.dart';

AppLifecycleState appLifecycleState = AppLifecycleState.resumed;

class OnAppResume extends StatefulWidget {
  const OnAppResume({
    super.key,
    required this.child,
    required this.onAppResume,
    this.onAppPaused,
    this.onAppInactive,
    this.updateGlobalAppLifecycleState = false,
  });

  final Widget child;
  final VoidCallback onAppResume;
  final VoidCallback? onAppPaused;
  final VoidCallback? onAppInactive;
  final bool updateGlobalAppLifecycleState;

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

    if (widget.onAppInactive != null && state == AppLifecycleState.inactive) {
      widget.onAppInactive!();
    }

    if (widget.onAppPaused != null && state == AppLifecycleState.paused) {
      widget.onAppPaused!();
    }

    _lastState = state;
    if (widget.updateGlobalAppLifecycleState) appLifecycleState = state;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
