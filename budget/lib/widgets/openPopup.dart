import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/widgets/button.dart';
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
  context, {
  IconData? icon,
  String? title,
  String? description,
  String? onSubmitLabel,
  String? onCancelLabel,
  String? onExtraLabel,
  VoidCallback? onSubmit,
  VoidCallback? onCancel,
  VoidCallback? onExtra,
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
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            margin: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: appStateSettings["materialYou"]
                  ? dynamicPastel(
                      context, Theme.of(context).colorScheme.secondaryContainer,
                      amount: 0.5)
                  : Theme.of(context).colorScheme.lightDarkAccent,
              borderRadius: BorderRadius.circular(22),
              boxShadow: boxShadowGeneral(context),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 7),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
                  child: Icon(
                    icon,
                    size: 65,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
                  child: TextFont(
                    textAlign: TextAlign.center,
                    text: title ?? "",
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    maxLines: 5,
                    textColor: Theme.of(context).colorScheme.onPrimaryContainer,
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                onCancelLabel != null
                                    ? Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Button(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondaryContainer,
                                            label: onCancelLabel,
                                            height: 50,
                                            onTap: onCancel ?? () {}),
                                      )
                                    : SizedBox.shrink(),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                onExtraLabel != null
                                    ? Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Button(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondaryContainer,
                                            label: onExtraLabel,
                                            height: 50,
                                            onTap: onExtra ?? () {}),
                                      )
                                    : SizedBox.shrink(),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                onSubmitLabel != null
                                    ? Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Button(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .tertiaryContainer,
                                            label: onSubmitLabel,
                                            height: 50,
                                            onTap: onSubmit ?? () {}),
                                      )
                                    : SizedBox.shrink(),
                              ],
                            ),
                          ],
                        ),
                      )
                    : SizedBox.shrink(),
                SizedBox(height: 6),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Future<T?> openPopupCustom<T extends Object?>(
  context, {
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
                  : Theme.of(context).colorScheme.lightDarkAccent,
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
                  : Theme.of(context).colorScheme.lightDarkAccent,
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
  if (previousObject == currentObject &&
      previousObject != null &&
      currentObject != null) {
    Navigator.maybePop(context);
  }
  print(previousObject);
  print(currentObject);
  previousObject = previousObject.copyWith(dateTimeModified: Value(null));
  if (previousObject != currentObject &&
      previousObject != null &&
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
