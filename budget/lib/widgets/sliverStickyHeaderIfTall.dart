import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';

class SliverStickyHeaderIfTall extends StatelessWidget {
  const SliverStickyHeaderIfTall({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.sizeOf(context).height > 800
        ? SliverPinnedHeader(
            child: Container(
                color: Theme.of(context).colorScheme.background, child: child))
        : SliverToBoxAdapter(child: child);
  }
}
