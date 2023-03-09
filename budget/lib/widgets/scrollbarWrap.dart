import 'package:budget/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class ScrollbarWrap extends StatelessWidget {
  const ScrollbarWrap({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return child;
    }
    return RawScrollbar(
      thumbColor: dynamicPastel(
        context,
        Theme.of(context).colorScheme.onSecondaryContainer.withOpacity(0.3),
        amountDark: 0.3,
      ),
      radius: Radius.circular(20),
      thickness: 3,
      child: child,
    );
  }
}
