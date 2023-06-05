import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';
import 'package:budget/widgets/textWidgets.dart';

// Tappable(
//   color: Colors.green,
//   child: Container(width: 20, height: 20),
//   onTap: () {
//     openPopup(
//       context,
//       icon: Icons.ac_unit_outlined,
//       description: "hello",
//     );
//   },
// ),
// Tappable(
//   color: Colors.green,
//   child: Container(width: 20, height: 20),
//   onTap: () {
//     openPopup(context, title: "hello", description: "test");
//   },
// ),
// Tappable(
//   color: Colors.green,
//   child: Container(width: 20, height: 20),
//   onTap: () {
//     openPopup(
//       context,
//       title: "hello",
//       description: "test",
//       onSubmitLabel: "submit",
//       onCancelLabel: "cancel",
//     );
//   },
// ),
// Tappable(
//   color: Colors.green,
//   child: Container(width: 20, height: 20),
//   onTap: () {
//     openPopup(
//       context,
//       icon: Icons.ac_unit_outlined,
//       description: "hello",
//       onSubmitLabel: "submit",
//     );
//   },
// ),

Future<T?> openPopup<T extends Object?>(
  BuildContext context, {
  IconData? icon,
  String? title,
  String? description,
  String? onSubmitLabel,
  String? onCancelLabel,
  String? onExtraLabel,
  String? onExtraLabel2,
  VoidCallback? onSubmit,
  VoidCallback? onCancel,
  VoidCallback? onExtra,
  VoidCallback? onExtra2,
  bool barrierDismissible = true,
}) {
  //Minimize keyboard when tap non interactive widget
  FocusScopeNode currentFocus = FocusScope.of(context);
  if (!currentFocus.hasPrimaryFocus) {
    currentFocus.unfocus();
  }
  return showGeneralDialog(
    context: context,
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
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: getWidthBottomSheet(context)),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 0),
              margin: EdgeInsets.only(
                left: 20,
                right: 20,
                top: MediaQuery.of(context).padding.top + 20,
                bottom: MediaQuery.of(context).padding.bottom + 20,
              ),
              decoration: BoxDecoration(
                color: appStateSettings["materialYou"]
                    ? dynamicPastel(context,
                        Theme.of(context).colorScheme.secondaryContainer,
                        amount: 0.5)
                    : getColor(context, "lightDarkAccent"),
                borderRadius: BorderRadius.circular(22),
                boxShadow: boxShadowGeneral(context),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 17),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 10),
                      child: Icon(
                        icon,
                        size: 65,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 10),
                      child: TextFont(
                        textAlign: TextAlign.center,
                        text: title ?? "",
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        maxLines: 5,
                        textColor:
                            Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    description != "" && description != null
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 10),
                            child: TextFont(
                              textAlign: TextAlign.center,
                              text: description,
                              fontSize: 17,
                              maxLines: 100,
                            ),
                          )
                        : SizedBox.shrink(),
                    onSubmitLabel != null || onCancelLabel != null
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              runSpacing: 10,
                              children: [
                                onCancelLabel != null
                                    ? IntrinsicWidth(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Button(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondaryContainer,
                                            label: onCancelLabel,
                                            onTap: onCancel ?? () {},
                                          ),
                                        ),
                                      )
                                    : SizedBox.shrink(),
                                onExtraLabel != null
                                    ? IntrinsicWidth(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Button(
                                            expandedLayout: true,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondaryContainer,
                                            label: onExtraLabel,
                                            onTap: onExtra ?? () {},
                                          ),
                                        ),
                                      )
                                    : SizedBox.shrink(),
                                onSubmitLabel != null
                                    ? IntrinsicWidth(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Button(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .tertiaryContainer,
                                            label: onSubmitLabel,
                                            onTap: onSubmit ?? () {},
                                          ),
                                        ),
                                      )
                                    : SizedBox.shrink(),
                                onExtraLabel2 != null
                                    ? IntrinsicWidth(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Button(
                                            expandedLayout: true,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondaryContainer,
                                            label: onExtraLabel2,
                                            onTap: onExtra2 ?? () {},
                                          ),
                                        ),
                                      )
                                    : SizedBox.shrink(),
                              ],
                            ),
                          )
                        : SizedBox.shrink(),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

Future<T?> openPopupCustom<T extends Object?>(
  BuildContext context, {
  String? title,
  bool barrierDismissible = true,
  required Widget child,
}) {
  return showGeneralDialog(
    context: context,
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
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            margin: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: appStateSettings["materialYou"]
                  ? dynamicPastel(
                      context, Theme.of(context).colorScheme.secondaryContainer,
                      amount: 0.5)
                  : getColor(context, "lightDarkAccent"),
              borderRadius: BorderRadius.circular(10),
              boxShadow: boxShadowGeneral(context),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                title == null
                    ? SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: TextFont(
                          text: title,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                child,
              ],
            ),
          ),
        ),
      );
    },
  );
}

Future<T?> openLoadingPopup<T extends Object?>(context) {
  return showGeneralDialog(
    context: context,
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
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            margin: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: appStateSettings["materialYou"]
                  ? dynamicPastel(
                      context, Theme.of(context).colorScheme.secondaryContainer,
                      amount: 0.5)
                  : getColor(context, "lightDarkAccent"),
              borderRadius: BorderRadius.circular(10),
            ),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    },
  );
}

void discardChangesPopup(context,
    {previousObject, currentObject, Function? onDiscard}) async {
  print(previousObject);
  print(currentObject);

  if (previousObject == currentObject &&
      previousObject != null &&
      currentObject != null) {
    Navigator.pop(context);
    return;
  }
  if (previousObject == null) {
    Navigator.pop(context);
    return;
  }

  previousObject = previousObject?.copyWith(dateTimeModified: Value(null));

  if (previousObject != null &&
      currentObject != null &&
      previousObject.toString() == currentObject.toString()) {
    print(previousObject.toString());
    print(currentObject.toString());

    Navigator.pop(context);
  } else {
    await openPopup(
      context,
      title: "Discard Changes?",
      description: "Are you sure you want to discard your changes.",
      icon: Icons.warning_rounded,
      onSubmitLabel: "Discard",
      onSubmit: () async {
        if (onDiscard != null) await onDiscard();
        Navigator.pop(context);
        Navigator.pop(context);
      },
      onCancelLabel: "Cancel",
      onCancel: () {
        Navigator.pop(context);
      },
    );
  }
}
