import 'package:flutter/material.dart';
import 'package:sliding_sheet/sliding_sheet.dart';
import 'package:budget/colors.dart';

openBottomSheet(context, child, {bool maxHeight: true, bool handle: true}) {
  //minimize keyboard when open
  FocusScope.of(context).unfocus();
  showSlidingBottomSheet(context, builder: (context) {
    return SlidingSheetDialog(
      elevation: 8,
      isBackdropInteractable: true,
      dismissOnBackdropTap: true,
      snapSpec: const SnapSpec(
        snap: true,
        snappings: [0.6, 1.0],
        positioning: SnapPositioning.relativeToAvailableSpace,
      ),
      color: Colors.transparent,
      // headerBuilder: (context, _) {
      //   if (handle) {
      //     return Padding(
      //       padding: const EdgeInsets.only(bottom: 5.0),
      //       child: Container(
      //         width: 40,
      //         height: 5,
      //         decoration: BoxDecoration(
      //           borderRadius: BorderRadius.circular(100),
      //           color: Theme.of(context)
      //               .colorScheme
      //               .lightDarkAccent
      //               .withOpacity(0.5),
      //         ),
      //       ),
      //     );
      //   } else {
      //     return SizedBox();
      //   }
      // },
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
