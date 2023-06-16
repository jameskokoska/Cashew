import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';
import 'package:flutter/services.dart';
import 'package:sliding_sheet/sliding_sheet.dart';
import 'package:budget/widgets/scrollbarWrap.dart';

bool getIsFullScreen(context) {
  return getWidthNavigationSidebar(context) > 0;
  double maxWidth = 700;
  return MediaQuery.of(context).size.width > maxWidth;
}

double getWidthBottomSheet(context) {
  double maxWidth = 900;
  return MediaQuery.of(context).size.width -
              getWidthNavigationSidebar(context) >
          maxWidth
      ? maxWidth - getWidthNavigationSidebar(context)
      : MediaQuery.of(context).size.width - getWidthNavigationSidebar(context);
}

double getHorizontalPaddingConstrained(context) {
  return (MediaQuery.of(context).size.width - getWidthBottomSheet(context)) / 3;
}

late SheetController bottomSheetControllerGlobal;
// Set snap to false if there is a keyboard
Future openBottomSheet(
  context,
  child, {
  bool maxHeight = true,
  bool snap = true,
  bool resizeForKeyboard = true,
  bool showScrollbar = false,
}) async {
  //minimize keyboard when open
  FocusScope.of(context).unfocus();
  bottomSheetControllerGlobal = new SheetController();
  return await showSlidingBottomSheet(context,
      resizeToAvoidBottomInset: resizeForKeyboard,
      // getOSInsideWeb() == "iOS" ? false : resizeForKeyboard,
      bottomPaddingColor: appStateSettings["materialYou"]
          ? dynamicPastel(
              context, Theme.of(context).colorScheme.secondaryContainer,
              amount: 0.3)
          : getColor(context, "lightDarkAccent"), builder: (context) {
    return SlidingSheetDialog(
      maxWidth: getWidthBottomSheet(context),
      scrollSpec: ScrollSpec(
        overscroll: false,
        overscrollColor: Colors.transparent,
        showScrollbar: showScrollbar,
        scrollbar: ((child) => ScrollbarWrap(child: child)),
      ),
      controller: bottomSheetControllerGlobal,
      elevation: 0,
      isBackdropInteractable: true,
      dismissOnBackdropTap: true,
      cornerRadiusOnFullscreen: 0,
      avoidStatusBar: true,
      extendBody: true,
      headerBuilder: (context, state) {
        return SizedBox(height: 10);
      },
      // headerBuilder: (context, _) {
      //   if (handle) {
      //     return Padding(
      //       padding: const EdgeInsets.only(bottom: 5.0),
      //       child: Container(
      //         width: 40,
      //         height: 5,
      //         decoration: BoxDecoration(
      //           borderRadius: BorderRadius.circular(100),
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
        snappings: getIsFullScreen(context)
            ? [
                0.95,
              ]
            : [0.6, 1],
        positioning: SnapPositioning.relativeToAvailableSpace,
      ),
      listener: (SheetState state) {
        if (state.maxExtent == 1 &&
            state.isExpanded &&
            state.isAtTop &&
            state.currentScrollOffset == 0 &&
            state.progress == 1) {
          HapticFeedback.heavyImpact();
        }
      },
      color: appStateSettings["materialYou"]
          ? dynamicPastel(
              context, Theme.of(context).colorScheme.secondaryContainer,
              amount: 0.3)
          : getColor(context, "lightDarkAccent"),
      cornerRadius: 20,
      duration: Duration(milliseconds: 300),
      builder: (context, state) {
        return Material(
          child: SingleChildScrollView(
            child: child,
          ),
        );
      },
    );
  });
}

// openBottomSheetWithKeyboard(context, child,
//     {bool maxHeight: true, bool handle: true}) {
//   //minimize keyboard when open
//   FocusScope.of(context).unfocus();
//   showModalBottomSheet(
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.circular(16),
//     ),
//     isScrollControlled: true,
//     isDismissible: false,
//     context: context,
//     backgroundColor: Colors.transparent,
//     builder: (contextBuilder) {
//       return Padding(
//         padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
//         child: GestureDetector(
//           onTap: () {
//             Navigator.pop(context);
//           },
//           child: Align(
//             alignment: Alignment.bottomCenter,
//             child: Container(
//               padding: EdgeInsets.only(
//                 bottom: MediaQuery.of(contextBuilder).viewInsets.bottom,
//               ),
//               decoration: BoxDecoration(
//                 color: getColor(context, "lightDarkAccent"),
//                 borderRadius: BorderRadius.only(
//                   topRight: Radius.circular(20),
//                   topLeft: Radius.circular(20),
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
