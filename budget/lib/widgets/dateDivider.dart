import 'dart:ui';
import 'package:budget/colors.dart';
import 'package:budget/functions.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/material/theme.dart';
import 'package:flutter/src/painting/alignment.dart';
import 'package:flutter/src/painting/edge_insets.dart';
import 'package:flutter/src/rendering/flex.dart';
import 'package:flutter/src/widgets/basic.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class DateDivider extends StatelessWidget {
  DateDivider({
    Key? key,
    required this.date,
    this.info,
    this.color,
    this.useHorizontalPaddingConstrained = true,
  }) : super(key: key);

  final DateTime date;
  final String? info;
  final Color? color;
  final bool useHorizontalPaddingConstrained;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: useHorizontalPaddingConstrained == false
            ? 0
            : getHorizontalPaddingConstrained(context),
      ),
      child: Container(
        color: color == null ? Theme.of(context).canvasColor : color,
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextFont(
              text: getWordedDate(date,
                  includeMonthDate: true, includeYearIfNotCurrentYear: true),
              fontSize: 14,
              textColor: getColor(context, "textLight"),
            ),
            info != null
                ? TextFont(
                    text: info!,
                    fontSize: 14,
                    textColor: getColor(context, "textLight"),
                  )
                : SizedBox()
          ],
        ),
      ),
    );
  }
}
