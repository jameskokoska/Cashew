import 'dart:ui';
import 'package:budget/colors.dart';
import 'package:budget/functions.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/sliverStickyLabelDivider.dart';
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
      child: StickyLabelDivider(
        info: getWordedDate(date,
            includeMonthDate: true, includeYearIfNotCurrentYear: true),
        extraInfo: info,
        color: color,
        fontSize: 14,
      ),
    );
  }
}
