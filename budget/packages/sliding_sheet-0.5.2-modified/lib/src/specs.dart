import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'sheet.dart';

// ignore_for_file: public_member_api_docs

/// How the snaps will be positioned.
enum SnapPositioning {
  /// Positions the snaps relative to the total
  /// available space (that is, the maximum height the widget can expand to).
  relativeToAvailableSpace,

  /// Positions the snaps relative to the total height
  /// of the sheet itself.
  relativeToSheetHeight,

  /// Positions the snaps at the given pixel offset. If the
  /// sheet is smaller than the offset, it will snap to the max possible offset.
  pixelOffset,
}

/// Defines how a [SlidingSheet] should snap, or if it should at all.
class SnapSpec {
  /// If true, the [SlidingSheet] will snap to the provided [snappings].
  /// If false, the [SlidingSheet] will slide from minExtent to maxExtent
  /// and then begin to scroll.
  final bool snap;

  /// The snap extents for a [SlidingSheet].
  ///
  /// The minimum and maximum values will represent the thresholds in which
  /// the [SlidingSheet] will slide. When the child of the sheet is bigger
  /// than the available space defined by the minimum and maximum extent,
  /// it will begin to scroll.
  final List<double> snappings;

  /// The initial snap extent.
  ///
  /// On a [SlidingSheet] this will correspond to the initial extent of the
  /// sheet. On a [SlidingSheetDialog] this will be the first extent that
  /// the dialog will animate to.
  ///
  /// The value must be included in the [snappings] array, otherwise the sheet will
  /// animate immidiately to the next valid snap.
  final double? initialSnap;

  /// How the snaps will be positioned:
  /// - [SnapPositioning.relativeToAvailableSpace] positions the snaps relative to the total
  /// available space (that is, the maximum height the widget can expand to). All values must be between 0 and 1.
  /// - [SnapPositioning.relativeToSheetHeight] positions the snaps relative to the total size
  /// of the sheet itself. All values must be between 0 and 1.
  /// - [SnapPositioning.pixelOffset] positions the snaps at the given pixel offset. If the
  /// sheet is smaller than the offset, it will snap to the max possible offset.
  final SnapPositioning positioning;

  /// A callback function that gets called when the [SlidingSheet] snaps to an extent.
  final void Function(SheetState, double? snap)? onSnap;

  /// Creates an object that defines how a [SlidingSheet] should snap, or if it should at all.
  const SnapSpec({
    this.snap = true,
    this.snappings = const [0.4, 1.0],
    this.initialSnap,
    this.positioning = SnapPositioning.relativeToAvailableSpace,
    this.onSnap,
  });

  /// The snap extent that makes header and footer fully visible without account for vertical padding on the [SlidingSheet].
  static const double headerFooterSnap = -1;

  /// The snap extent that makes the header fully visible without account for top padding on the [SlidingSheet].
  static const double headerSnap = -2;

  /// The snap extent that makes the footer fully visible without account for bottom padding on the [SlidingSheet].
  static const double footerSnap = -3;

  /// The snap extent that expands the whole [SlidingSheet]
  static const double expanded = double.infinity;

  /// private
  static bool isSnap(double? snap) =>
      snap == expanded ||
      snap == headerFooterSnap ||
      snap == headerSnap ||
      snap == footerSnap;

  double get minSnap => snappings.first;
  double get maxSnap => snappings.last;

  SnapSpec copyWith({
    bool? snap,
    List<double>? snappings,
    double? initialExtent,
    SnapPositioning? positioning,
    void Function(SheetState, double? snap)? onSnap,
  }) {
    return SnapSpec(
      snap: snap ?? this.snap,
      snappings: snappings ?? this.snappings,
      initialSnap: initialExtent ?? initialSnap,
      positioning: positioning ?? this.positioning,
      onSnap: onSnap ?? this.onSnap,
    );
  }

  @override
  String toString() {
    return 'SnapSpec(snap: $snap, snappings: $snappings, initialExtent: $initialSnap, positioning: $positioning, onSnap: $onSnap)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is SnapSpec &&
        o.snap == snap &&
        listEquals(o.snappings, snappings) &&
        o.initialSnap == initialSnap &&
        o.positioning == positioning &&
        o.onSnap == onSnap;
  }

  @override
  int get hashCode {
    return snap.hashCode ^
        snappings.hashCode ^
        initialSnap.hashCode ^
        positioning.hashCode ^
        onSnap.hashCode;
  }
}

/// Defines the scroll effects, physics and more.
class ScrollSpec {
  /// Whether the containing ScrollView should overscroll.
  final bool overscroll;

  /// The color of the overscroll when [overscroll] is true.
  final Color? overscrollColor;

  /// The physics of the containing ScrollView.
  final ScrollPhysics? physics;

  /// Whether to wrap the scrollable content inside a `Scrollbar` widget.
  final bool showScrollbar;

  final Widget Function(Widget child)? scrollbar;

  /// Creates an object that defines the scroll effects, physics and more.
  const ScrollSpec({
    this.overscroll = true,
    this.overscrollColor,
    this.physics,
    this.showScrollbar = false,
    this.scrollbar,
  });

  /// Creates an overscroll effect with the given [color].
  const ScrollSpec.overscroll({Color? color}) : this(overscrollColor: color);

  /// Creates an iOS bouncing scroll effect.
  const ScrollSpec.bouncingScroll()
      : this(physics: const BouncingScrollPhysics());

  @override
  String toString() {
    return 'ScrollSpec(overscroll: $overscroll, overscrollColor: $overscrollColor, physics: $physics, showScrollbar: $showScrollbar)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is ScrollSpec &&
        o.overscroll == overscroll &&
        o.overscrollColor == overscrollColor &&
        o.physics == physics &&
        o.showScrollbar == showScrollbar;
  }

  @override
  int get hashCode {
    return overscroll.hashCode ^
        overscrollColor.hashCode ^
        physics.hashCode ^
        showScrollbar.hashCode;
  }
}

/// {@macro sliding_sheet.parallaxSpec}
class ParallaxSpec {
  /// If true, the parallax effect will be applied
  /// to the body of the [SlidingSheet].
  final bool enabled;

  /// A fractional ([0..1]) value that determines the intensity of
  /// the parallax effect.
  ///
  /// For example, a value of 0.5 would mean that the body of the [SlidingSheet]
  /// would be moved with half the speed of the [SlidingSheet].
  final double amount;

  /// The parallax effect will be applied between [minExtent..endExtent] where the minExtent
  /// is defined by the lowest snap in the `snappings` array on the [SnapSpec].
  ///
  /// If endExtent is null, the [SlidingSheet] will use the penultimate extent on the `snappings` array
  /// if there are more than 2 snaps, otherwise the `maxExtent` will be used.
  ///
  /// **Note that the [SnapPositioning] you set on the [SnapSpec] will be applied
  /// to this extent aswell**
  final double? endExtent;

  /// Creates an object that defines a parallax effect.
  const ParallaxSpec({
    this.enabled = true,
    this.amount = 0.15,
    this.endExtent,
  }) : assert(amount >= 0.0 && amount <= 1.0);

  @override
  String toString() =>
      'ParallaxSpec(enabled: $enabled, amount: $amount, extent: $endExtent)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is ParallaxSpec &&
        o.enabled == enabled &&
        o.amount == amount &&
        o.endExtent == endExtent;
  }

  @override
  int get hashCode => enabled.hashCode ^ amount.hashCode ^ endExtent.hashCode;
}
