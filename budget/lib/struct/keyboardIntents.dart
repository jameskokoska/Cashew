import 'package:budget/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Map<Type, Action<Intent>> keyboardIntents = {
  EscapeIntent: CallbackAction<EscapeIntent>(
    onInvoke: (EscapeIntent intent) => {
      if (navigatorKey.currentState!.canPop())
        navigatorKey.currentState!.pop()
      else
        pageNavigationFrameworkKey.currentState!
            .changePage(0, switchNavbar: true)
    },
  ),
  Digit1Intent: CallbackAction<Digit1Intent>(
    onInvoke: (Digit1Intent intent) => {
      // we are on the root of navigation pages
      if (!navigatorKey.currentState!.canPop())
        pageNavigationFrameworkKey.currentState!
            .changePage(0, switchNavbar: true)
    },
  ),
  Digit2Intent: CallbackAction<Digit2Intent>(
    onInvoke: (Digit2Intent intent) => {
      // we are on the root of navigation pages
      if (!navigatorKey.currentState!.canPop())
        pageNavigationFrameworkKey.currentState!
            .changePage(1, switchNavbar: true)
    },
  ),
  Digit3Intent: CallbackAction<Digit3Intent>(
    onInvoke: (Digit3Intent intent) => {
      // we are on the root of navigation pages
      if (!navigatorKey.currentState!.canPop())
        pageNavigationFrameworkKey.currentState!
            .changePage(2, switchNavbar: true)
    },
  ),
  Digit4Intent: CallbackAction<Digit4Intent>(
    onInvoke: (Digit4Intent intent) => {
      // we are on the root of navigation pages
      if (!navigatorKey.currentState!.canPop())
        pageNavigationFrameworkKey.currentState!
            .changePage(3, switchNavbar: true)
    },
  ),
};

Map<ShortcutActivator, Intent> shortcuts = {
  LogicalKeySet(LogicalKeyboardKey.escape): const EscapeIntent(),
  LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit1):
      const Digit1Intent(),
  LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit2):
      const Digit2Intent(),
  LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit3):
      const Digit3Intent(),
  LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit4):
      const Digit4Intent(),
};

class EscapeIntent extends Intent {
  const EscapeIntent();
}

class Digit1Intent extends Intent {
  const Digit1Intent();
}

class Digit2Intent extends Intent {
  const Digit2Intent();
}

class Digit3Intent extends Intent {
  const Digit3Intent();
}

class Digit4Intent extends Intent {
  const Digit4Intent();
}
