import 'package:flutter/material.dart';
import 'package:budget/colors.dart';
import 'package:budget/widgets/textWidgets.dart';

openSnackbar(context, text, {Color? textColor, Color? backgroundColor}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: TextFont(
        text: text,
        fontSize: 16,
        textColor:
            textColor == null ? Theme.of(context).colorScheme.white : textColor,
      ),
      backgroundColor: backgroundColor == null
          ? Theme.of(context).colorScheme.black
          : backgroundColor));
  return;
}
