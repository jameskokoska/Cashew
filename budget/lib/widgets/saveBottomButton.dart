import 'package:budget/functions.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:flutter/material.dart';

class SaveBottomButton extends StatelessWidget {
  const SaveBottomButton({
    super.key,
    required this.label,
    required this.onTap,
    this.disabled = false,
    this.color,
    this.labelColor,
  });

  final String label;
  final Function() onTap;
  final bool disabled;
  final Color? color;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    // print(getKeyboardHeight(context));
    return AddGradientOnTop(
      child: Button(
        label: label,
        disabled: disabled,
        onTap: onTap,
        hasBottomExtraSafeArea: true,
        expandToFillBottomExtraSafeArea: false,
        color: color,
        textColor: labelColor,
      ),
    );
  }
}

class AddGradientOnTop extends StatelessWidget {
  const AddGradientOnTop({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // print(getKeyboardHeight(context));
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Transform.translate(
            offset: Offset(0, 1),
            child: Container(
              height: 12,
              foregroundDecoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.background.withOpacity(0),
                    Theme.of(context).colorScheme.background,
                  ],
                  begin: AlignmentDirectional.topCenter,
                  end: AlignmentDirectional.bottomCenter,
                  stops: [0.1, 1],
                ),
              ),
            ),
          ),
          Container(
            color: Theme.of(context).colorScheme.background,
            child: child,
          ),
        ],
      ),
    );
  }
}

class MinimizeKeyboardFABOverlay extends StatefulWidget {
  const MinimizeKeyboardFABOverlay({required this.isEnabled, super.key});
  final bool isEnabled;
  @override
  State<MinimizeKeyboardFABOverlay> createState() =>
      _MinimizeKeyboardFABOverlayState();
}

class _MinimizeKeyboardFABOverlayState extends State<MinimizeKeyboardFABOverlay>
    with WidgetsBindingObserver {
  bool isKeyboardOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    bool status = getIsKeyboardOpen(context);
    if (status != isKeyboardOpen)
      setState(() {
        isKeyboardOpen = status;
      });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      end: 10,
      bottom: 10,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        curve: Curves.easeInOutCubic,
        transform: Matrix4.translationValues(
          0,
          isKeyboardOpen ? 0 : 100,
          0,
        ),
        child: AnimateFABDelayed(
          enabled: isKeyboardOpen && widget.isEnabled,
          fab: FAB(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            borderRadius: 15,
            fabSize: 50,
            iconData: appStateSettings["outlinedIcons"]
                ? Icons.check_outlined
                : Icons.check_rounded,
          ),
        ),
      ),
    );
  }
}

class KeyboardHeightAreaAnimated extends StatefulWidget {
  const KeyboardHeightAreaAnimated({
    super.key,
  });

  @override
  State<KeyboardHeightAreaAnimated> createState() =>
      _KeyboardHeightAreaAnimatedState();
}

class _KeyboardHeightAreaAnimatedState extends State<KeyboardHeightAreaAnimated>
    with WidgetsBindingObserver {
  bool isKeyboardOpen = false;
  double totalHeight = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    bool status = getIsKeyboardOpen(context);
    double height = getKeyboardHeight(context);

    setState(() {
      if (status != isKeyboardOpen) isKeyboardOpen = status;
      if (height != totalHeight) totalHeight = height;
    });
  }

  @override
  Widget build(BuildContext context) {
    // print(isKeyboardOpen);
    return AnimatedContainer(
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      color: Theme.of(context).colorScheme.background,
      height: isKeyboardOpen ? getKeyboardHeight(context) : 0,
      child: Container(color: Colors.red),
    );
  }
}
