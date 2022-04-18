import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

openBottomSheet(context, child, {bool maxHeight: true}) {
  //minimize keyboard when open
  FocusScope.of(context).unfocus();

  return showMaterialModalBottomSheet(
    animationCurve: Curves.fastOutSlowIn,
    duration: Duration(milliseconds: 250),
    backgroundColor: Colors.transparent,
    expand: true,
    context: context,
    builder: (context) => GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(overscroll: false),
            child: SingleChildScrollView(
              controller: ModalScrollController.of(context),
              child: Padding(
                  padding: EdgeInsets.only(
                      top: maxHeight == false
                          ? 0
                          : MediaQuery.of(context).size.height * 0.35),
                  child: child),
            ),
          ),
        ),
      ),
    ),
  );
}
