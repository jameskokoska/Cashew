import 'package:budget/functions.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';
import 'package:flutter/services.dart';
import 'package:sliding_sheet/sliding_sheet.dart';
import 'package:budget/widgets/scrollbarWrap.dart';

bool getIsFullScreen(context) {
  return getWidthNavigationSidebar(context) > 0;
  double maxWidth = 700;
  return MediaQuery.sizeOf(context).width > maxWidth;
}

double getWidthBottomSheet(context) {
  double maxWidth = 900;
  return MediaQuery.sizeOf(context).width - getWidthNavigationSidebar(context) >
          maxWidth
      ? maxWidth - getWidthNavigationSidebar(context)
      : MediaQuery.sizeOf(context).width - getWidthNavigationSidebar(context);
}

double getHorizontalPaddingConstrained(context, {bool enabled = true}) {
  if (enabled == false) return 0;
  if (MediaQuery.sizeOf(context).width >= 550 &&
      MediaQuery.sizeOf(context).width <= 1000 &&
      getIsFullScreen(context) == false) {
    double returnedPadding = 0;
    returnedPadding = MediaQuery.sizeOf(context).width / 3 - 140;
    return returnedPadding < 0 ? 0 : returnedPadding;
  } else if (MediaQuery.sizeOf(context).width <= 1000 &&
      getIsFullScreen(context) &&
      appStateSettings["expandedNavigationSidebar"] == true) {
    double returnedPadding = 0;
    returnedPadding = MediaQuery.sizeOf(context).width / 5 - 125;
    return returnedPadding < 0 ? 0 : returnedPadding;
  }
  // When the navigation bar is closed
  else if (MediaQuery.sizeOf(context).width <= 1000 &&
      getIsFullScreen(context) &&
      appStateSettings["expandedNavigationSidebar"] == false) {
    double returnedPadding = 0;
    returnedPadding = MediaQuery.sizeOf(context).width / 3.5 - 125;
    return returnedPadding < 0 ? 0 : returnedPadding;
  } else if (getIsFullScreen(context) &&
      appStateSettings["expandedNavigationSidebar"] == false) {
    double returnedPadding = 0;
    returnedPadding = (MediaQuery.sizeOf(context).width - 500) / 3;
    return returnedPadding < 0 ? 0 : returnedPadding;
  }

  return (MediaQuery.sizeOf(context).width - getWidthBottomSheet(context)) / 3;
}

SheetController? bottomSheetControllerGlobalCustomAssigned;

late SheetController bottomSheetControllerGlobal;
// Set snap to false if there is a keyboard
Future openBottomSheet(
  context,
  child, {
  bool maxHeight = true,
  bool snap = true,
  bool resizeForKeyboard = true,
  bool showScrollbar = false,
  bool fullSnap = false,
  bool popupWithKeyboard =
      false, // If the popup is shown and an on screen keyboard focus is immediately required
  bool isDismissable = true,
  bool useCustomController = false,
  bool reAssignBottomSheetControllerGlobal = true,
  Widget Function(BuildContext context, ScrollController scrollController,
          SheetState sheetState)?
      customBuilder,
  bool useParentContextForTheme = true,
}) async {
  //minimize keyboard when open
  minimizeKeyboard(context);
  if (reAssignBottomSheetControllerGlobal)
    bottomSheetControllerGlobal = new SheetController();
  if (useCustomController == true)
    bottomSheetControllerGlobalCustomAssigned = new SheetController();

  // Fix over-scroll stretch when keyboard pops up quickly
  if (popupWithKeyboard) {
    Future.delayed(Duration(milliseconds: 100), () {
      (useCustomController
              ? bottomSheetControllerGlobalCustomAssigned
              : bottomSheetControllerGlobal)
          ?.scrollTo(0, duration: Duration(milliseconds: 100));
    });
  }

  BuildContext? themeContext =
      useParentContextForTheme && isContextValidForTheme(context)
          ? context
          : null;

  return await showSlidingBottomSheet(
    context,
    resizeToAvoidBottomInset: resizeForKeyboard,
    // getOSInsideWeb() == "iOS" ? false : resizeForKeyboard,
    builder: (context) {
      if (checkIfDefaultThemeData(themeContext)) themeContext = null;

      double deviceAspectRatio =
          MediaQuery.sizeOf(context).height / MediaQuery.sizeOf(context).width;
      Color bottomPaddingColor = appStateSettings["materialYou"]
          ? dynamicPastel(themeContext ?? context,
              Theme.of(themeContext ?? context).colorScheme.secondaryContainer,
              amountDark: 0.3, amountLight: 0.6)
          : getColor(themeContext ?? context, "lightDarkAccent");

      return SlidingSheetDialog(
        isDismissable: isDismissable,
        maxWidth: getWidthBottomSheet(context),
        scrollSpec: ScrollSpec(
          overscroll: false,
          overscrollColor: Colors.transparent,
          showScrollbar: showScrollbar,
          scrollbar: ((child) => ScrollbarWrap(child: child)),
        ),
        controller: useCustomController
            ? bottomSheetControllerGlobalCustomAssigned
            : bottomSheetControllerGlobal,
        elevation: 0,
        isBackdropInteractable: true,
        dismissOnBackdropTap: true,
        cornerRadiusOnFullscreen: 0,
        avoidStatusBar: true,
        extendBody: true,
        // Add a header builder so that we get proper extension when full screen sliding sheets
        // extend properly past that notification bar
        headerBuilder: (context, state) {
          return SizedBox(height: 0);
        },
        // headerBuilder: (context, _) {
        //   if (handle) {
        //     return Padding(
        //       padding: const EdgeInsetsDirectional.only(bottom: 5.0),
        //       child: Container(
        //         width: 40,
        //         height: 5,
        //         decoration: BoxDecoration(
        //           shape: BoxShape.circle,
        //           color: Colors.red,
        //         ),
        //       ),
        //     );
        //   } else {
        //     return SizedBox();
        //   }
        // },
        snapSpec: SnapSpec(
          snap: snap,
          // Max snapping when on-screen keyboard because the keyboard takes up screen space!
          snappings: popupWithKeyboard == false &&
                  fullSnap == false &&
                  getIsFullScreen(context) == false &&
                  deviceAspectRatio > 2
              ? [0.6, 1]
              : [0.95, 1],
          positioning: SnapPositioning.relativeToAvailableSpace,
        ),
        customBuilder: customBuilder != null
            ? (context, controller, state) {
                if (checkIfDefaultThemeData(themeContext)) themeContext = null;

                return Material(
                  child: Theme(
                    data: Theme.of(themeContext ?? context),
                    child: Container(
                      color: bottomPaddingColor,
                      child: customBuilder(context, controller, state),
                    ),
                  ),
                );
              }
            : null,
        listener: (SheetState state) {
          if (state.maxExtent == 1 &&
              state.isExpanded &&
              state.isAtTop &&
              state.currentScrollOffset == 0 &&
              state.progress == 1 &&
              ScrollConfiguration.of(context)
                      .getScrollPhysics(context)
                      .toString() !=
                  "BouncingScrollPhysics" &&
              getPlatform() != PlatformOS.isIOS) {
            HapticFeedback.heavyImpact();
          }
        },
        color: bottomPaddingColor,
        cornerRadius: getPlatform() == PlatformOS.isIOS ? 10 : 20,
        duration: Duration(milliseconds: 300),
        builder: customBuilder != null
            ? null
            : (context, state) {
                if (checkIfDefaultThemeData(themeContext)) themeContext = null;

                return Material(
                  child: Theme(
                    data: Theme.of(themeContext ?? context),
                    child: SingleChildScrollView(
                      child: child,
                    ),
                  ),
                );
              },
      );
    },
  );
}

bool isContextValidForTheme(context) {
  try {
    Theme.of(context);
    return true;
  } catch (e) {
    return false;
  }
}

bool checkIfDefaultThemeData(BuildContext? context) {
  try {
    return context != null &&
        Theme.of(context).primaryColor == ThemeData().primaryColor &&
        Theme.of(context).secondaryHeaderColor ==
            ThemeData().secondaryHeaderColor &&
        Theme.of(context).colorScheme.background ==
            ThemeData().colorScheme.background &&
        Theme.of(context).cardColor == ThemeData().cardColor;
  } catch (e) {
    return true;
  }
}

// openBottomSheetWithKeyboard(context, child,
//     {bool maxHeight: true, bool handle: true}) {
//   //minimize keyboard when open
//   FocusScope.of(context).unfocus();
//   showModalBottomSheet(
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadiusDirectional.circular(16),
//     ),
//     isScrollControlled: true,
//     isDismissible: false,
//     context: context,
//     backgroundColor: Colors.transparent,
//     builder: (contextBuilder) {
//       return Padding(
//         padding: EdgeInsetsDirectional.only(top: MediaQuery.paddingOf(context).top),
//         child: GestureDetector(
//           onTap: () {
//             Navigator.pop(context);
//           },
//           child: Align(
//             alignment: AlignmentDirectional.bottomCenter,
//             child: Container(
//               padding: EdgeInsetsDirectional.only(
//                 bottom: MediaQuery.of(contextBuilder).viewInsets.bottom,
//               ),
//               decoration: BoxDecoration(
//                 color: getColor(context, "lightDarkAccent"),
//                 borderRadius: BorderRadiusDirectional.only(
//                   topend: Radius.circular(20),
//                   topstart: Radius.circular(20),
//                 ),
//               ),
//               child: child,
//             ),
//           ),
//         ),
//       );
//     },
//   );
// }
