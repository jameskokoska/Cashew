import 'package:flutter/material.dart';
import 'package:budget/colors.dart';
import 'package:budget/widgets/textWidgets.dart';

openSnackbar(context, text, {Color? textColor, Color? backgroundColor}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: 70, left: 10, right: 10),
        padding: EdgeInsets.symmetric(horizontal: 22, vertical: 23),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        content: TextFont(
          text: text,
          fontSize: 14,
          maxLines: 3,
          textColor: textColor == null
              ? Theme.of(context).colorScheme.black
              : textColor,
        ),
        backgroundColor: backgroundColor == null
            ? Theme.of(context).colorScheme.lightDarkAccent
            : backgroundColor),
  );
  return;
}
