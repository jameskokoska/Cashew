import 'package:budget/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ScrollbarWrap extends StatelessWidget {
  const ScrollbarWrap({
    required this.child,
    this.enabled = true,
    this.scrollController,
    super.key,
  });
  final Widget child;
  final bool enabled;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    // disable in debug mode because of scroll controller warnings
    if (kIsWeb || kDebugMode || enabled == false) {
      return child;
    }
    return MediaQuery.removePadding(
      context: context,
      removeLeft: true,
      removeRight: true,
      child: RawScrollbar(
        controller: scrollController,
        thumbColor: dynamicPastel(
          context,
          Theme.of(context).colorScheme.onSecondaryContainer.withOpacity(0.3),
          amountDark: 0.3,
        ),
        radius: Radius.circular(20),
        thickness: 3,
        child: child,
      ),
    );
  }
}
