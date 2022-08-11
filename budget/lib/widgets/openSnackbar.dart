import 'package:flutter/material.dart';
import 'package:budget/colors.dart';
import 'package:budget/widgets/textWidgets.dart';

openSnackbar(context, text,
    {Color? textColor, Color? backgroundColor, bool? isErrorColor}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: 14, left: 20, right: 90),
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        content: TextFont(
          text: text,
          fontSize: 14,
          maxLines: 3,
          textColor: isErrorColor == true
              ? dynamicPastel(context, Theme.of(context).colorScheme.error,
                  amountLight: 0.5)
              : (textColor == null
                  ? Theme.of(context).colorScheme.black
                  : textColor),
        ),
        backgroundColor: backgroundColor == null
            ? Theme.of(context).colorScheme.lightDarkAccentHeavy
            : backgroundColor),
  );
  return;
}
