part of 'sheet.dart';

class _SheetExtent {
  final bool isDialog;
  final _SlidingSheetScrollController? controller;
  List<double> snappings;
  double targetHeight = 0;
  double childHeight = 0;
  double headerHeight = 0;
  double footerHeight = 0;
  double availableHeight = 0;
  _SheetExtent(
    this.controller, {
    required this.isDialog,
    required this.snappings,
    required void Function(double) listener,
  }) {
    maxExtent = snappings.last.clamp(0.0, 1.0);
    minExtent = snappings.first.clamp(0.0, 1.0);
    _currentExtent = ValueNotifier(minExtent)
      ..addListener(
        () => listener(currentExtent),
      );
  }

  late ValueNotifier<double?> _currentExtent;
  double get currentExtent => _currentExtent.value!;
  set currentExtent(double value) =>
      _currentExtent.value = math.min(value, maxExtent);

  double get sheetHeight => childHeight + headerHeight + footerHeight;

  late double maxExtent;
  late double minExtent;
  double get additionalMinExtent => isAtMin ? 0.0 : 0.1;
  double get additionalMaxExtent => isAtMax ? 0.0 : 0.1;

  bool get isAtMax => currentExtent >= maxExtent;
  bool get isAtMin => currentExtent <= minExtent && minExtent != maxExtent;

  void addPixelDelta(double pixelDelta) {
    if (targetHeight == 0 || availableHeight == 0) return;

    currentExtent = currentExtent + (pixelDelta / availableHeight);
    // The bottom sheet should be allowed to be dragged below its min extent.
    currentExtent = currentExtent.clamp(isDialog ? 0.0 : minExtent, maxExtent);
  }

  double get scrollOffset {
    try {
      return math.max(controller!.offset, 0);
    } catch (e) {
      return 0;
    }
  }

  double get maxScrollExtent {
    if (controller!.hasClients) {
      return controller!.position.maxScrollExtent;
    } else {
      return 0.0;
    }
  }

  bool get isAtTop => scrollOffset <= 0;
  bool get isAtBottom => scrollOffset >= maxScrollExtent;
}

class _SlidingSheetScrollController extends ScrollController {
  final _SlidingSheetState sheet;
  _SlidingSheetScrollController(this.sheet);

  SlidingSheet get widget => sheet.widget;

  _SheetExtent get extent => sheet.extent!;
  void Function(double) get onPop => sheet._pop;
  Duration get duration => sheet.widget.duration;
  SnapSpec get snapSpec => sheet.snapSpec;

  double get currentExtent => extent.currentExtent;
  double get maxExtent => extent.maxExtent;
  double get minExtent => extent.minExtent;

  bool inDrag = false;
  bool get animating => controller?.isAnimating == true;
  bool get inInteraction => inDrag || animating;

  _SlidingSheetScrollPosition? _currentPosition;

  AnimationController? controller;

  TickerFuture snapToExtent(
    double snap,
    TickerProvider vsync, {
    double velocity = 0.0,
    Duration? duration,
    bool clamp = true,
  }) {
    _dispose();

    if (clamp) snap = snap.clamp(extent.minExtent, extent.maxExtent);

    // Adjust the animation duration for a snap to give it a more
    // realistic feel.
    final num distanceFactor =
        ((currentExtent - snap).abs() / (maxExtent - minExtent))
            .clamp(0.33, 1.0);
    final speedFactor = 1.0 - ((velocity.abs() / 2500) * 0.33).clamp(0.0, 0.66);
    duration ??= this.duration * (distanceFactor * speedFactor);

    controller = AnimationController(duration: duration, vsync: vsync);
    final animation = CurvedAnimation(
      parent: controller!,
      curve: velocity.abs() > 300 ? Curves.easeOutCubic : Curves.ease,
    );

    final start = extent.currentExtent;

    controller!.addListener(() {
      // Clamp the end snap on every tick because the size of the sheet
      // could have changed in the meantime (for instance, the user makes
      // some fancy animation while sliding).
      if (clamp) snap = snap.clamp(extent.minExtent, extent.maxExtent);
      extent.currentExtent = lerpDouble(start, snap, animation.value)!;
    });

    return controller!.forward()
      ..whenComplete(() {
        controller!.dispose();

        // Needed because otherwise the scrollController
        // thinks were still dragging.
        jumpTo(offset);

        // Invoke the snap callback.
        snapSpec.onSnap?.call(
          sheet.state,
          sheet._reverseSnap(snap),
        );
      });
  }

  void delegateDrag(double delta) {
    inDrag = true;
    stopAnyRunningSnapAnimation();

    final adjustedDelta = _currentPosition?.adjustDelta(-delta) ?? -delta;
    extent.addPixelDelta(adjustedDelta);
  }

  void delegateFling([double velocity = 0.0]) {
    if (velocity != 0.0) {
      _currentPosition?.goBallistic(velocity);
    } else {
      inDrag = true;
      _currentPosition?.goSnapped(0.0);
    }
  }

  void stopAnyRunningSnapAnimation() {
    if (animating) {
      controller!.stop();
    }
  }

  @override
  _SlidingSheetScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) {
    return _currentPosition = _SlidingSheetScrollPosition(
      this,
      physics: physics,
      context: context,
      oldPosition: oldPosition,
    );
  }

  void _dispose() {
    if (animating) {
      controller?.stop();
      controller?.dispose();
    }
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }
}

class _SlidingSheetScrollPosition extends ScrollPositionWithSingleContext {
  final _SlidingSheetScrollController scrollController;
  _SlidingSheetScrollPosition(
    this.scrollController, {
    required ScrollPhysics physics,
    required ScrollContext context,
    ScrollPosition? oldPosition,
    String? debugLabel,
  }) : super(
          physics: physics,
          context: context,
          oldPosition: oldPosition,
          debugLabel: debugLabel,
        );

  VoidCallback? _dragCancelCallback;
  bool isMovingUp = true;
  bool isMovingDown = false;

  bool get inDrag => scrollController.inDrag;
  set inDrag(bool value) => scrollController.inDrag = value;

  _SheetExtent get extent => scrollController.extent;
  _SlidingSheetState get sheet => scrollController.sheet;
  void Function(double) get onPop => scrollController.onPop;
  SnapSpec get snapBehavior => sheet.snapSpec;
  ScrollSpec get scrollSpec => sheet.scrollSpec;
  List<double> get snappings => extent.snappings;
  bool get fromBottomSheet => extent.isDialog;
  bool get snap => snapBehavior.snap;
  bool get isDismissable => sheet.widget.isDismissable && fromBottomSheet;

  double get availableHeight => extent.targetHeight;
  double get currentExtent => extent.currentExtent;
  double get maxExtent => extent.maxExtent;
  double get minExtent => extent.minExtent;
  double get offset => scrollController.offset;

  bool get shouldScroll => pixels > 0.0 && extent.isAtMax;
  bool get isCoveringFullExtent => scrollController.sheet.isScrollable;
  bool get shouldMakeSheetNonDismissable =>
      sheet.didCompleteInitialRoute &&
      !isDismissable &&
      currentExtent < minExtent;
  bool get isBottomSheetBelowMinExtent =>
      fromBottomSheet && currentExtent < minExtent;

  @override
  bool applyContentDimensions(double minScrollExtent, double maxScrollExtent) {
    // We need to provide some extra extent if we haven't yet reached the max or
    // min extents. Otherwise, a list with fewer children than the extent of
    // the available space will get stuck.
    return super.applyContentDimensions(
      minScrollExtent - extent.additionalMinExtent,
      maxScrollExtent + extent.additionalMaxExtent,
    );
  }

  @override
  void applyUserOffset(double delta) {
    scrollController.stopAnyRunningSnapAnimation();

    isMovingUp = delta < 0;
    isMovingDown = delta > 0;
    inDrag = true;

    final isNotAtMinOrMaxExtent = !(extent.isAtMin || extent.isAtMax);
    final scrollsUpWhenAtMinExtent =
        extent.isAtMin && (delta < 0 || fromBottomSheet);
    final scrollsDownWhenAtMaxExtent = extent.isAtMax && delta > 0;
    final shouldAddPixelDeltaToExtent = isNotAtMinOrMaxExtent ||
        scrollsUpWhenAtMinExtent ||
        scrollsDownWhenAtMaxExtent;
    if (!shouldScroll && shouldAddPixelDeltaToExtent) {
      final adjustedDelta = adjustDelta(-delta);
      extent.addPixelDelta(adjustedDelta);
    } else if (!extent.isAtMin) {
      super.applyUserOffset(delta);
    }
  }

  // Adjust the delta of the applyUserOffset for possible
  // states such as when the sheet is not dismissable.
  double adjustDelta(double delta) {
    double result = delta;

    if (shouldMakeSheetNonDismissable) {
      final minExtentLimit = minExtent / 2;
      final reachedFraction = (minExtent - currentExtent) / minExtentLimit;
      result *= 1 - reachedFraction;
    }

    return result;
  }

  @override
  void didEndScroll() {
    super.didEndScroll();

    final canSnapToNextExtent =
        snap && !extent.isAtMax && !extent.isAtMin && !shouldScroll;
    if (inDrag &&
        !shouldMakeSheetNonDismissable &&
        (canSnapToNextExtent || isBottomSheetBelowMinExtent)) {
      goSnapped(0.0);
    }
  }

  @override
  void goBallistic(double velocity) {
    if (velocity != 0) inDrag = false;

    isMovingUp = velocity > 0;
    isMovingDown = velocity < 0;

    // There is an issue with the bouncing scroll physics that when the sheet doesn't cover the full extent
    // the bounce back of the simulation would be so fast to close the sheet again, although it was swiped
    // upwards. Here we soften the bounce back to prevent that from happening.
    if (isMovingDown &&
        !inDrag &&
        (scrollSpec.physics is BouncingScrollPhysics) &&
        !isCoveringFullExtent) {
      velocity /= 8;
    }

    if (shouldMakeSheetNonDismissable) {
      disposeDragCancelCallback();
      return;
    }

    if (velocity == 0.0 ||
        (isMovingDown && shouldScroll) ||
        (isMovingUp && extent.isAtMax)) {
      super.goBallistic(velocity);
      return;
    }

    disposeDragCancelCallback();

    snap ? goSnapped(velocity) : goUnsnapped(velocity);
  }

  void goSnapped(double velocity, {double? snap}) {
    velocity = velocity.abs();
    const flingThreshold = 1700;

    void snapTo(double snap) =>
        scrollController.snapToExtent(snap, context.vsync, velocity: velocity);

    if (velocity > flingThreshold) {
      if (!isMovingUp) {
        if (isDismissable) {
          // Pop from the navigator on down fling.
          onPop(velocity);
        } else {
          snapTo(minExtent);
        }
      } else if (currentExtent > 0.0) {
        snapTo(maxExtent);
      }
    } else {
      const snapToNextThreshold = 300;

      // Find the next snap based on the velocity.
      double distance = double.maxFinite;
      double? targetSnap = snap;

      final slow = velocity < snapToNextThreshold;
      final target = !slow
          ? ((isMovingUp ? 1 : -1) *
                  (((velocity * .45) * (1 - currentExtent)) / flingThreshold)) +
              currentExtent
          : currentExtent;

      void findSnap({bool greaterThanCurrent = true}) {
        for (var i = 0; i < snappings.length; i++) {
          final stop = snappings[i];
          final valid = slow ||
              !greaterThanCurrent ||
              ((isMovingUp && stop >= target) ||
                  (!isMovingUp && stop <= target));

          if (valid) {
            final dis = (stop - target).abs();
            if (dis < distance) {
              distance = dis;
              targetSnap = stop;
            }
          }
        }
      }

      // First try to find a snap higher than the current extent.
      // If there is none (snap == null), find the next snap.
      if (targetSnap == null) findSnap();
      if (targetSnap == null) findSnap(greaterThanCurrent: false);

      if (!isDismissable) {
        targetSnap = math.max(minExtent, targetSnap!);
      }

      if (targetSnap == 0.0) {
        onPop(velocity);
      } else if (targetSnap != extent.currentExtent && currentExtent > 0) {
        snapTo(targetSnap!.clamp(minExtent, maxExtent));
      }
    }
  }

  Future<void> goUnsnapped(double velocity) async {
    await runScrollSimulation(velocity);

    if (isBottomSheetBelowMinExtent && currentExtent > 0.0) {
      goSnapped(0.0);
    }
  }

  Future<void> runScrollSimulation(double velocity,
      {double friction = 0.015}) async {
    // The iOS bouncing simulation just isn't right here - once we delegate
    // the ballistic back to the ScrollView, it will use the right simulation.
    final simulation = ClampingScrollSimulation(
      position: currentExtent,
      velocity: velocity,
      tolerance: physics.tolerance,
      friction: friction,
    );

    final ballisticController = AnimationController.unbounded(
      debugLabel: '$runtimeType',
      vsync: context.vsync,
    );

    double lastDelta = 0;
    void _tick() {
      final double delta = ballisticController.value - lastDelta;
      lastDelta = ballisticController.value;
      extent.addPixelDelta(delta);

      final shouldStopScrollOnBottomSheets = fromBottomSheet &&
          (currentExtent <= 0.0 || shouldMakeSheetNonDismissable);
      final shouldStopOnUpFling = velocity > 0 && extent.isAtMax;
      final shouldStopOnDownFling =
          velocity < 0 && (shouldStopScrollOnBottomSheets || extent.isAtMin);

      if (shouldStopOnUpFling || shouldStopOnDownFling) {
        // Make sure we pass along enough velocity to keep scrolling - otherwise
        // we just "bounce" off the top making it look like the list doesn't
        // have more to scroll.
        velocity = ballisticController.velocity +
            (physics.tolerance.velocity * ballisticController.velocity.sign);
        super.goBallistic(shouldMakeSheetNonDismissable ? 0.0 : velocity);
        ballisticController.stop();

        // Pop the route when reaching 0.0 extent.
        if (fromBottomSheet &&
            currentExtent <= 0.0 &&
            !shouldMakeSheetNonDismissable) {
          onPop(0.0);
        }
      }
    }

    ballisticController.addListener(_tick);
    await ballisticController.animateWith(simulation);
    ballisticController.dispose();

    // Needed because otherwise the scrollController
    // thinks were still dragging. (User has to tap twice on a button for example)
    if (!inDrag) {
      jumpTo(offset);
    }
  }

  @override
  Drag drag(DragStartDetails details, VoidCallback dragCancelCallback) {
    // Save this so we can call it later if we have to [goBallistic] on our own.
    _dragCancelCallback = dragCancelCallback;
    return super.drag(details, dragCancelCallback);
  }

  void disposeDragCancelCallback() {
    // Scrollable expects that we will dispose of its current _dragCancelCallback
    _dragCancelCallback?.call();
    _dragCancelCallback = null;
  }
}
