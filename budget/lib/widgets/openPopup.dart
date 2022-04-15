import 'package:animations/animations.dart';
import 'package:budget/widgets/button.dart';
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
  VoidCallback? onSubmit,
  VoidCallback? onCancel,
  bool barrierDismissible = true,
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
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            margin: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.lightDarkAccent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                icon != null
                    ? Transform.translate(
                        offset: Offset(0, -50),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.accentColor,
                            borderRadius: BorderRadius.circular(1000),
                          ),
                          padding: EdgeInsets.all(15),
                          child: Icon(
                            icon,
                            size: 50,
                          ),
                        ),
                      )
                    : SizedBox.shrink(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            icon == null
                                ? TextFont(
                                    text: title ?? "",
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  )
                                : Container(
                                    height: 30,
                                    width: 1,
                                  ),
                            description != null
                                ? TextFont(
                                    text: description,
                                    fontSize: 19,
                                    maxLines: 100,
                                  )
                                : SizedBox.shrink(),
                            onSubmitLabel != null || onCancelLabel != null
                                ? Container(
                                    height: 12,
                                    width: 1,
                                  )
                                : SizedBox.shrink(),
                            onSubmitLabel != null || onCancelLabel != null
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      onSubmitLabel != null
                                          ? Button(
                                              label: onSubmitLabel,
                                              width: 100,
                                              height: 50,
                                              onTap: onSubmit ?? () {})
                                          : SizedBox.shrink(),
                                      onSubmitLabel != null &&
                                              onCancelLabel != null
                                          ? Container(
                                              width: 15,
                                            )
                                          : SizedBox.shrink(),
                                      onCancelLabel != null
                                          ? Button(
                                              label: onCancelLabel,
                                              width: 100,
                                              height: 50,
                                              onTap: onCancel ?? () {})
                                          : SizedBox.shrink(),
                                    ],
                                  )
                                : SizedBox.shrink(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
