import 'package:budget/functions.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/globalSnackbar.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';
import 'package:budget/widgets/textWidgets.dart';

Future<T?> openPopup<T extends Object?>(
  BuildContext? contextPassed, {
  IconData? icon,
  double? iconScale,
  String? title,
  String? subtitle,
  String? description,
  Widget? descriptionWidget,
  Widget? beforeDescriptionWidget,
  String? onSubmitLabel,
  String? onCancelLabel,
  String? onExtraLabel,
  String? onExtraLabel2,
  VoidCallback? onSubmit,
  VoidCallback? onCancel,
  Function(BuildContext context)? onCancelWithBoxContext,
  VoidCallback? onExtra,
  VoidCallback? onExtra2,
  bool barrierDismissible = true,
}) {
  if ((contextPassed ?? navigatorKey.currentContext) == null)
    return Future.error("No context");
  BuildContext context = contextPassed ?? navigatorKey.currentContext!;

  minimizeKeyboard(context);
  return showGeneralDialog(
    context: context,
    useRootNavigator: false,
    barrierDismissible: barrierDismissible,
    barrierColor: Colors.black.withOpacity(0.4),
    barrierLabel: '',
    transitionBuilder: (_, anim, __, child) {
      Tween<double> tween;
      if (anim.status == AnimationStatus.reverse) {
        tween = Tween(begin: 0.9, end: 1);
      } else {
        tween = Tween(begin: 0.95, end: 1);
      }
      return ScaleTransition(
        scale: tween.animate(
            new CurvedAnimation(parent: anim, curve: Curves.easeInOutQuart)),
        child: FadeTransition(
          opacity: anim,
          child: child,
        ),
      );
    },
    transitionDuration: Duration(milliseconds: 200),
    pageBuilder: (_, __, ___) {
      double borderRadius = getPlatform() == PlatformOS.isIOS ? 10 : 25;
      Color tertiaryButtonColor = appStateSettings["materialYou"] == false &&
              Theme.of(context).brightness == Brightness.light
          ? dynamicPastel(context, Theme.of(context).colorScheme.tertiary,
              amount: 0.3)
          : appStateSettings["materialYou"]
              ? dynamicPastel(context, Theme.of(context).colorScheme.tertiary,
                  amount: 0.15)
              : dynamicPastel(
                  context, Theme.of(context).colorScheme.tertiaryContainer,
                  amount: 0.15);
      Color onTertiaryButtonColor = appStateSettings["materialYou"] ||
              Theme.of(context).brightness == Brightness.light
          ? dynamicPastel(context, Theme.of(context).colorScheme.onTertiary,
              amount: 0.25)
          : Theme.of(context).colorScheme.onTertiaryContainer;
      Color primaryButtonColor = appStateSettings["materialYou"] == false &&
              Theme.of(context).brightness == Brightness.light
          ? dynamicPastel(context, Theme.of(context).colorScheme.primary,
              amount: 0.3)
          : appStateSettings["materialYou"]
              ? dynamicPastel(context, Theme.of(context).colorScheme.primary,
                  amount: 0.15)
              : Theme.of(context).colorScheme.secondaryContainer;
      Color onPrimaryButtonColor = appStateSettings["materialYou"] ||
              Theme.of(context).brightness == Brightness.light
          ? dynamicPastel(
              context,
              Theme.of(context).colorScheme.onPrimary,
              amount: 0.25,
            )
          : Theme.of(context).colorScheme.onSecondaryContainer;
      return WillPopScope(
        //Stop back button
        onWillPop: () async => barrierDismissible,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: getWidthBottomSheet(context)),
            child: Container(
              margin: EdgeInsets.only(
                left: MediaQuery.paddingOf(context).left + 20,
                right: MediaQuery.paddingOf(context).right + 20,
                top: MediaQuery.paddingOf(context).top + 20,
                bottom: MediaQuery.paddingOf(context).bottom + 20,
              ),
              decoration: BoxDecoration(
                color: appStateSettings["materialYou"]
                    ? dynamicPastel(context,
                        Theme.of(context).colorScheme.secondaryContainer,
                        amount: 0.5)
                    : getColor(context, "lightDarkAccent"),
                borderRadius: BorderRadiusDirectional.circular(borderRadius),
                boxShadow: boxShadowGeneral(context),
              ),
              child: SingleChildScrollView(
                child: Builder(builder: (context) {
                  Widget content = Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding:
                            EdgeInsetsDirectional.symmetric(horizontal: 25),
                        child: Column(
                          children: [
                            SizedBox(height: 17),
                            if (icon != null)
                              Padding(
                                padding: const EdgeInsetsDirectional.symmetric(
                                    vertical: 8.0, horizontal: 10),
                                child: Transform.scale(
                                  scale: iconScale ?? 1,
                                  child: Icon(
                                    icon,
                                    size: 65,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            if (title != null)
                              Padding(
                                padding: const EdgeInsetsDirectional.symmetric(
                                    vertical: 8.0, horizontal: 10),
                                child: TextFont(
                                  textAlign: TextAlign.center,
                                  text: title,
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                  maxLines: 5,
                                  textColor: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                ),
                              ),
                            if (subtitle != null)
                              Padding(
                                padding: const EdgeInsetsDirectional.symmetric(
                                    vertical: 8.0, horizontal: 10),
                                child: TextFont(
                                  textAlign: TextAlign.center,
                                  text: subtitle,
                                  fontSize: 21,
                                  fontWeight: FontWeight.bold,
                                  maxLines: 5,
                                  textColor: Theme.of(context)
                                      .colorScheme
                                      .onTertiaryContainer,
                                ),
                              ),
                            if (beforeDescriptionWidget != null)
                              beforeDescriptionWidget,
                            if (description != null)
                              Padding(
                                padding: const EdgeInsetsDirectional.symmetric(
                                    vertical: 8.0, horizontal: 10),
                                child: TextFont(
                                  textAlign: TextAlign.center,
                                  text: description,
                                  fontSize: 16.5,
                                  maxLines: 100,
                                ),
                              ),
                            if (descriptionWidget != null) descriptionWidget,
                            if (onSubmitLabel != null || onCancelLabel != null)
                              Padding(
                                padding: const EdgeInsetsDirectional.symmetric(
                                    vertical: 16.0),
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  runSpacing: 10,
                                  children: [
                                    onCancelLabel != null
                                        ? IntrinsicWidth(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsetsDirectional
                                                      .symmetric(
                                                      horizontal: 8.0),
                                              child: Builder(
                                                  builder: (boxContext) {
                                                return Button(
                                                  color: tertiaryButtonColor,
                                                  textColor:
                                                      onTertiaryButtonColor,
                                                  label: onCancelLabel,
                                                  onTap: () {
                                                    if (onCancel != null) {
                                                      onCancel();
                                                    }
                                                    if (onCancelWithBoxContext !=
                                                        null) {
                                                      onCancelWithBoxContext(
                                                          boxContext);
                                                    }
                                                  },
                                                );
                                              }),
                                            ),
                                          )
                                        : SizedBox.shrink(),
                                    onExtraLabel != null
                                        ? IntrinsicWidth(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsetsDirectional
                                                      .symmetric(
                                                      horizontal: 8.0),
                                              child: Button(
                                                expandedLayout: true,
                                                color: primaryButtonColor,
                                                textColor: onPrimaryButtonColor,
                                                label: onExtraLabel,
                                                onTap: onExtra ?? () {},
                                              ),
                                            ),
                                          )
                                        : SizedBox.shrink(),
                                    onSubmitLabel != null
                                        ? IntrinsicWidth(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsetsDirectional
                                                      .symmetric(
                                                      horizontal: 8.0),
                                              child: Button(
                                                color: primaryButtonColor,
                                                textColor: onPrimaryButtonColor,
                                                label: onSubmitLabel,
                                                onTap: onSubmit ?? () {},
                                              ),
                                            ),
                                          )
                                        : SizedBox.shrink(),
                                  ],
                                ),
                              ),
                            onExtraLabel2 == null
                                ? SizedBox(height: 17)
                                : SizedBox(height: 5),
                          ],
                        ),
                      ),
                      if (onExtraLabel2 != null)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(
                            start: 10,
                            end: 10,
                            bottom: 12,
                          ),
                          child: Button(
                            borderRadius: borderRadius,
                            expandedLayout: true,
                            color: tertiaryButtonColor,
                            textColor: onTertiaryButtonColor,
                            label: onExtraLabel2,
                            onTap: onExtra2 ?? () {},
                          ),
                        ),
                      // SizedBox(height: 16),
                    ],
                  );
                  // Only use intrinsic width if the content is controlled
                  if (onExtraLabel2 != null &&
                      descriptionWidget == null &&
                      beforeDescriptionWidget == null)
                    return IntrinsicWidth(child: content);
                  return content;
                }),
              ),
            ),
          ),
        ),
      );
    },
  );
}

enum DeletePopupAction {
  Cancel,
  Delete,
  Extra,
}

enum RoutesToPopAfterDelete {
  None,
  One,
  All,
  PreventDelete,
}

Future<DeletePopupAction?> openDeletePopup(
  BuildContext context, {
  String? title,
  String? subtitle,
  String? description,
  String? extraLabel,
}) async {
  dynamic result = await openPopup(
    context,
    title: title,
    subtitle: subtitle,
    description: description,
    icon: appStateSettings["outlinedIcons"]
        ? Icons.delete_outlined
        : Icons.delete_rounded,
    onCancel: () {
      popRoute(context, DeletePopupAction.Cancel);
    },
    onCancelLabel: "cancel".tr(),
    onSubmit: () async {
      popRoute(context, DeletePopupAction.Delete);
    },
    onSubmitLabel: "delete".tr(),
    onExtraLabel2: extraLabel,
    onExtra2: () async {
      popRoute(context, DeletePopupAction.Extra);
    },
  );
  if (result is DeletePopupAction) return result;
  return null;
}

Future<T?> openPopupCustom<T extends Object?>(
  BuildContext context, {
  String? title,
  bool barrierDismissible = true,
  EdgeInsetsDirectional padding =
      const EdgeInsetsDirectional.symmetric(horizontal: 25, vertical: 20),
  BorderRadius? borderRadius,
  required Widget child,
}) {
  return showGeneralDialog(
    context: context,
    useRootNavigator: false,
    barrierDismissible: barrierDismissible,
    barrierColor: Colors.black.withOpacity(0.4),
    barrierLabel: '',
    transitionBuilder: (_, anim, __, child) {
      Tween<double> tween;
      if (anim.status == AnimationStatus.reverse) {
        tween = Tween(begin: 0.9, end: 1);
      } else {
        tween = Tween(begin: 0.95, end: 1);
      }
      return ScaleTransition(
        scale: tween.animate(
            new CurvedAnimation(parent: anim, curve: Curves.easeInOutQuart)),
        child: FadeTransition(
          opacity: anim,
          child: child,
        ),
      );
    },
    transitionDuration: Duration(milliseconds: 200),
    pageBuilder: (_, __, ___) {
      return WillPopScope(
        //Stop back button
        onWillPop: () async => barrierDismissible,
        child: Center(
          child: Container(
            margin: EdgeInsetsDirectional.only(
              start: 20,
              end: 20,
              top: MediaQuery.paddingOf(context).top,
              bottom: MediaQuery.paddingOf(context).bottom,
            ),
            decoration: BoxDecoration(
              color: appStateSettings["materialYou"]
                  ? dynamicPastel(
                      context, Theme.of(context).colorScheme.secondaryContainer,
                      amount: 0.5)
                  : getColor(context, "lightDarkAccent"),
              borderRadius: borderRadius ??
                  BorderRadiusDirectional.circular(
                      getPlatform() == PlatformOS.isIOS ? 10 : 25),
              boxShadow: boxShadowGeneral(context),
            ),
            child: SingleChildScrollView(
              padding: padding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  title == null
                      ? SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsetsDirectional.only(bottom: 15),
                          child: TextFont(
                            text: title,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            maxLines: 5,
                            textAlign: TextAlign.center,
                          ),
                        ),
                  child,
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

Future<T?> openLoadingPopup<T extends Object?>(BuildContext context) {
  return showGeneralDialog(
    context: context,
    useRootNavigator: false,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.4),
    barrierLabel: '',
    transitionBuilder: (_, anim, __, child) {
      Tween<double> tween;
      if (anim.status == AnimationStatus.reverse) {
        tween = Tween(begin: 0.9, end: 1);
      } else {
        tween = Tween(begin: 0.95, end: 1);
      }
      return ScaleTransition(
        scale: tween.animate(
            new CurvedAnimation(parent: anim, curve: Curves.easeInOutQuart)),
        child: FadeTransition(
          opacity: anim,
          child: child,
        ),
      );
    },
    transitionDuration: Duration(milliseconds: 200),
    pageBuilder: (_, __, ___) {
      return WillPopScope(
        //Stop back button
        onWillPop: () async => false,
        child: Center(
          child: Container(
            padding:
                EdgeInsetsDirectional.symmetric(horizontal: 20, vertical: 20),
            margin: EdgeInsetsDirectional.only(
              start: 20,
              end: 20,
              top: MediaQuery.paddingOf(context).top,
              bottom: MediaQuery.paddingOf(context).bottom,
            ),
            decoration: BoxDecoration(
              color: appStateSettings["materialYou"]
                  ? dynamicPastel(
                      context, Theme.of(context).colorScheme.secondaryContainer,
                      amount: 0.5)
                  : getColor(context, "lightDarkAccent"),
              borderRadius: BorderRadiusDirectional.circular(
                  getPlatform() == PlatformOS.isIOS ? 10 : 25),
            ),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    },
  );
}

Future openLoadingPopupTryCatch(
  Future Function() function, {
  BuildContext? context,
  Function(dynamic error)? onError,
  Function(dynamic result)? onSuccess,
}) async {
  openLoadingPopup(context ?? navigatorKey.currentContext!);
  try {
    dynamic result = await function();
    popRoute(context ?? navigatorKey.currentContext!, result);
    if (onSuccess != null) onSuccess(result);
    return result;
  } catch (e) {
    popRoute(context ?? navigatorKey.currentContext!, null);
    if (onError != null)
      onError(e);
    else
      openSnackbar(
        SnackbarMessage(
          title: "an-error-occured".tr(),
          icon: appStateSettings["outlinedIcons"]
              ? Icons.warning_outlined
              : Icons.warning_rounded,
          description: e.toString(),
        ),
      );
  }
  return null;
}

void discardChangesPopup(context,
    {previousObject,
    currentObject,
    Function? onDiscard,
    bool forceShow = false}) async {
  print(previousObject);
  print(currentObject);

  if (forceShow == false &&
      previousObject == currentObject &&
      previousObject != null &&
      currentObject != null) {
    popRoute(context);
    return;
  }
  if (forceShow == false && previousObject == null) {
    popRoute(context);
    return;
  }

  previousObject = previousObject?.copyWith(dateTimeModified: Value(null));

  if (forceShow == false &&
      previousObject != null &&
      currentObject != null &&
      previousObject.toString() == currentObject.toString()) {
    print(previousObject.toString());
    print(currentObject.toString());

    popRoute(context);
  } else {
    await openPopup(
      context,
      title: "discard-changes".tr(),
      description: "discard-changes-description".tr(),
      icon: appStateSettings["outlinedIcons"]
          ? Icons.warning_outlined
          : Icons.warning_rounded,
      onSubmitLabel: "discard".tr(),
      onSubmit: () async {
        if (onDiscard != null) await onDiscard();
        popRoute(context);
        popRoute(context);
      },
      onCancelLabel: "cancel".tr(),
      onCancel: () {
        popRoute(context);
      },
    );
  }
}

class CodeBlock extends StatelessWidget {
  const CodeBlock({required this.text, super.key});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Tappable(
      borderRadius: 5,
      color: Theme.of(context).colorScheme.secondaryContainer,
      onLongPress: () => copyToClipboard(text),
      child: Padding(
        padding: EdgeInsetsDirectional.all(10),
        child: TextFont(
          text: "",
          textAlign: TextAlign.center,
          fontSize: 15,
          softWrap: true,
          richTextSpan: [
            TextSpan(
              text: text,
              style: TextStyle(
                fontSize: 15,
                fontFamily: "monospace",
                fontFamilyFallback: <String>["Courier"],
                color: getColor(context, "black"),
              ),
            ),
          ],
          maxLines: 100,
        ),
      ),
    );
  }
}
