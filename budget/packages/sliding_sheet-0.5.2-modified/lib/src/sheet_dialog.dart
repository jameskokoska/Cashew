part of 'sheet.dart';

/// Shows a [SlidingSheet] as a material design bottom sheet.
///
/// The `builder` parameter must not be null and is used to construct a [SlidingSheetDialog].
///
/// The `parentBuilder` parameter can be used to wrap the sheet inside a parent, for example a
/// [Theme] or [AnnotatedRegion].
///
/// The `routeSettings` argument, see [RouteSettings] for details.
///
/// The `resizeToAvoidBottomInset` parameter can be used to avoid the keyboard from obscuring
/// the content bottom sheet.
Future<T?> showSlidingBottomSheet<T>(
  BuildContext context, {
  required SlidingSheetDialog Function(BuildContext context) builder,
  Widget Function(BuildContext context, SlidingSheet sheet)? parentBuilder,
  RouteSettings? routeSettings,
  bool useRootNavigator = false,
  bool resizeToAvoidBottomInset = true,
  Color bottomPaddingColor = Colors.transparent,
}) {
  SlidingSheetDialog dialog = builder(context);
  final SheetController controller = dialog.controller ?? SheetController();

  final theme = Theme.of(context);
  final ValueNotifier<int> rebuilder = ValueNotifier(0);

  return Navigator.of(
    context,
    rootNavigator: useRootNavigator,
  ).push(
    _SlidingSheetRoute(
      duration: dialog.duration,
      settings: routeSettings,
      builder: (context, animation, route) {
        return ValueListenableBuilder(
          valueListenable: rebuilder,
          builder: (context, dynamic value, _) {
            dialog = builder(context);

            // Assign the rebuild function in order to
            // be able to change the dialogs parameters
            // inside a dialog.
            controller._rebuild = () {
              rebuilder.value++;
            };

            var snapSpec = dialog.snapSpec;
            if (snapSpec.snappings.first != 0.0) {
              snapSpec = snapSpec.copyWith(
                snappings: [0.0] + snapSpec.snappings,
              );
            }

            Widget sheet = SlidingSheet._(
              route: route,
              controller: controller,
              builder: dialog.builder,
              customBuilder: dialog.customBuilder,
              headerBuilder: dialog.headerBuilder,
              footerBuilder: dialog.footerBuilder,
              listener: dialog.listener,
              snapSpec: snapSpec,
              duration: dialog.duration,
              color: dialog.color ??
                  theme.bottomSheetTheme.backgroundColor ??
                  theme.dialogTheme.backgroundColor ??
                  theme.dialogBackgroundColor,
              backdropColor: dialog.backdropColor,
              shadowColor: dialog.shadowColor,
              elevation: dialog.elevation,
              padding: dialog.padding,
              avoidStatusBar: dialog.avoidStatusBar,
              margin: dialog.margin,
              border: dialog.border,
              cornerRadius: dialog.cornerRadius,
              cornerRadiusOnFullscreen: dialog.cornerRadiusOnFullscreen,
              closeOnBackdropTap: dialog.dismissOnBackdropTap,
              scrollSpec: dialog.scrollSpec,
              maxWidth: dialog.maxWidth,
              closeSheetOnBackButtonPressed: false,
              minHeight: dialog.minHeight,
              isDismissable: dialog.isDismissable,
              onDismissPrevented: dialog.onDismissPrevented,
              isBackdropInteractable: dialog.isBackdropInteractable,
              axisAlignment: dialog.axisAlignment,
              extendBody: dialog.extendBody,
              liftOnScrollHeaderElevation: dialog.liftOnScrollHeaderElevation,
              liftOnScrollFooterElevation: dialog.liftOnScrollFooterElevation,
              body: null,
            );

            if (parentBuilder != null) {
              sheet = parentBuilder(context, sheet as SlidingSheet);
            }

            if (resizeToAvoidBottomInset &&
                bottomPaddingColor != Colors.transparent) {
              sheet = Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: MediaQuery.viewInsetsOf(context).bottom,
                      color: bottomPaddingColor,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.viewInsetsOf(context).bottom,
                    ),
                    child: sheet,
                  ),
                ],
              );
            } else if (resizeToAvoidBottomInset) {
              sheet = Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: sheet,
              );
            }

            return sheet;
          },
        );
      },
    ),
  );
}

/// A wrapper class to show a [SlidingSheet] as a bottom sheet dialog.
class SlidingSheetDialog {
  /// {@macro sliding_sheet.builder}
  final SheetBuilder? builder;

  /// {@macro sliding_sheet.customBuilder}
  final CustomSheetBuilder? customBuilder;

  /// {@macro sliding_sheet.headerBuilder}
  final SheetBuilder? headerBuilder;

  /// {@macro sliding_sheet.footerBuilder}
  final SheetBuilder? footerBuilder;

  /// {@macro sliding_sheet.snapSpec}
  final SnapSpec snapSpec;

  /// {@macro sliding_sheet.duration}
  final Duration duration;

  /// {@macro sliding_sheet.color}
  final Color? color;

  /// {@macro sliding_sheet.backdropColor}
  final Color backdropColor;

  /// {@macro sliding_sheet.shadowColor}
  final Color? shadowColor;

  /// {@macro sliding_sheet.elevation}
  final double elevation;

  /// {@macro sliding_sheet.padding}
  final EdgeInsets? padding;

  /// {@macro sliding_sheet.avoidStatusBar}
  final bool avoidStatusBar;

  /// {@macro sliding_sheet.margin}
  final EdgeInsets? margin;

  /// {@macro sliding_sheet.border}
  final Border? border;

  /// {@macro sliding_sheet.cornerRadius}
  final double cornerRadius;

  /// {@macro sliding_sheet.cornerRadiusOnFullscreen}
  final double? cornerRadiusOnFullscreen;

  /// If true, the sheet will be dismissed the backdrop
  /// was tapped.
  final bool dismissOnBackdropTap;

  /// {@macro sliding_sheet.listener}
  final SheetListener? listener;

  /// {@macro sliding_sheet.controller}
  final SheetController? controller;

  /// {@macro sliding_sheet.scrollSpec}
  final ScrollSpec scrollSpec;

  /// {@macro sliding_sheet.maxWidth}
  final double maxWidth;

  /// {@macro sliding_sheet.minHeight}
  final double? minHeight;

  /// {@macro sliding_sheet.isDismissable}
  final bool isDismissable;

  /// {@macro sliding_sheet.onDismissPrevented}
  final OnDismissPreventedCallback? onDismissPrevented;

  /// {@macro sliding_sheet.isBackDropInteractable}
  final bool isBackdropInteractable;

  /// {@macro sliding_sheet.axisAlignment}
  final double axisAlignment;

  /// {@macro sliding_sheet.extendBody}
  final bool extendBody;

  /// {@macro sliding_sheet.liftOnScrollHeaderElevation}
  final double liftOnScrollHeaderElevation;

  /// {@macro sliding_sheet.liftOnScrollFooterElevation}
  final double liftOnScrollFooterElevation;

  /// Creates a wrapper class to show a [SlidingSheet] as a bottom sheet dialog.
  const SlidingSheetDialog({
    this.builder,
    this.customBuilder,
    this.headerBuilder,
    this.footerBuilder,
    this.snapSpec = const SnapSpec(),
    this.duration = const Duration(milliseconds: 800),
    this.color,
    this.backdropColor = Colors.black54,
    this.shadowColor,
    this.elevation = 0.0,
    this.padding,
    this.avoidStatusBar = false,
    this.margin,
    this.border,
    this.cornerRadius = 0.0,
    this.cornerRadiusOnFullscreen,
    this.dismissOnBackdropTap = true,
    this.listener,
    this.controller,
    this.scrollSpec = const ScrollSpec(overscroll: false),
    this.maxWidth = double.infinity,
    this.minHeight,
    this.isDismissable = true,
    this.onDismissPrevented,
    this.isBackdropInteractable = false,
    this.axisAlignment = 0.0,
    this.extendBody = false,
    this.liftOnScrollHeaderElevation = 0.0,
    this.liftOnScrollFooterElevation = 0.0,
  });
}

/// A transparent route for a bottom sheet dialog.
class _SlidingSheetRoute<T> extends PageRoute<T> {
  final Widget Function(BuildContext, Animation<double>, _SlidingSheetRoute<T>)
      builder;
  final Duration duration;
  _SlidingSheetRoute({
    required this.builder,
    required this.duration,
    RouteSettings? settings,
  }) : super(
          settings: settings,
          fullscreenDialog: false,
        );

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => duration;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) =>
      builder(context, animation, this);
}
