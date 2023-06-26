import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/noResults.dart';
import 'package:budget/widgets/scrollbarWrap.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/budgetPage.dart';
import 'package:budget/pages/transactionsSearchPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/shareBudget.dart';
import 'package:budget/widgets/selectedTransactionsActionBar.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:budget/main.dart';
import 'package:budget/colors.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'dart:math';
import 'package:flutter/rendering.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:implicitly_animated_reorderable_list/transitions.dart';
import 'package:sliver_tools/sliver_tools.dart';

class SliverPinnedOverlapInjector extends SingleChildRenderObjectWidget {
  const SliverPinnedOverlapInjector({
    required this.handle,
    Key? key,
  }) : super(key: key);

  final SliverOverlapAbsorberHandle handle;

  @override
  RenderSliverPinnedOverlapInjector createRenderObject(BuildContext context) {
    return RenderSliverPinnedOverlapInjector(
      handle: handle,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSliverPinnedOverlapInjector renderObject,
  ) {
    renderObject.handle = handle;
  }
}

class RenderSliverPinnedOverlapInjector extends RenderSliver {
  RenderSliverPinnedOverlapInjector({
    required SliverOverlapAbsorberHandle handle,
  }) : _handle = handle;

  double? _currentLayoutExtent;
  double? _currentMaxExtent;

  SliverOverlapAbsorberHandle get handle => _handle;
  SliverOverlapAbsorberHandle _handle;
  set handle(SliverOverlapAbsorberHandle value) {
    if (handle == value) return;
    if (attached) {
      handle.removeListener(markNeedsLayout);
    }
    _handle = value;
    if (attached) {
      handle.addListener(markNeedsLayout);
      if (handle.layoutExtent != _currentLayoutExtent ||
          handle.scrollExtent != _currentMaxExtent) markNeedsLayout();
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    handle.addListener(markNeedsLayout);
    if (handle.layoutExtent != _currentLayoutExtent ||
        handle.scrollExtent != _currentMaxExtent) markNeedsLayout();
  }

  @override
  void detach() {
    handle.removeListener(markNeedsLayout);
    super.detach();
  }

  @override
  void performLayout() {
    _currentLayoutExtent = handle.layoutExtent;

    final paintedExtent = min(
      _currentLayoutExtent!,
      constraints.remainingPaintExtent - constraints.overlap,
    );

    geometry = SliverGeometry(
      paintExtent: paintedExtent,
      maxPaintExtent: _currentLayoutExtent!,
      maxScrollObstructionExtent: _currentLayoutExtent!,
      paintOrigin: constraints.overlap,
      scrollExtent: _currentLayoutExtent!,
      layoutExtent: max(0, paintedExtent - constraints.scrollOffset),
      hasVisualOverflow: paintedExtent < _currentLayoutExtent!,
    );
  }
}
