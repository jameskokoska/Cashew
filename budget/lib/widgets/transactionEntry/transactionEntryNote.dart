import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TransactionEntryNote extends StatelessWidget {
  const TransactionEntryNote({
    required this.transaction,
    required this.iconColor,
    this.padding =
        const EdgeInsetsDirectional.only(start: 5, end: 3, top: 10, bottom: 10),
    super.key,
  });
  final Transaction transaction;
  final Color iconColor;
  final EdgeInsetsDirectional padding;

  @override
  Widget build(BuildContext context) {
    return transaction.note.toString().trim() != ""
        ? Tooltip(
            padding: EdgeInsetsDirectional.only(
                start: 15, end: 15, top: 10, bottom: 8),
            margin: EdgeInsetsDirectional.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadiusDirectional.circular(10),
              color: getColor(context, "lightDarkAccent"),
              boxShadow: boxShadowCheck(
                [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.light
                        ? getColor(context, "shadowColorLight")
                            .withOpacity(0.12)
                        : getColor(context, "shadowColorLight")
                            .withOpacity(0.1),
                    blurRadius: 6,
                    offset: Offset(0, 4),
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
            textStyle: TextStyle(
              color: getColor(context, "black"),
              fontFamily: appStateSettings["font"],
              fontFamilyFallback: ['Inter'],
            ),
            triggerMode: TooltipTriggerMode.tap,
            showDuration: getIsFullScreen(context) == false || kIsWeb == false
                ? Duration(milliseconds: 10000)
                : Duration(milliseconds: 100),
            message: cleanupNoteStringWithURLs(transaction.note),
            child: Padding(
              padding: padding,
              child: Icon(
                appStateSettings["outlinedIcons"]
                    ? Icons.sticky_note_2_outlined
                    : Icons.sticky_note_2_rounded,
                size: 22,
                color: iconColor,
              ),
            ),
          )
        : SizedBox.shrink();
  }
}
