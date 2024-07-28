import 'package:budget/functions.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/sliverStickyLabelDivider.dart';
import 'package:flutter/src/widgets/basic.dart';
import 'package:flutter/src/widgets/framework.dart';

class DateDivider extends StatelessWidget {
  DateDivider({
    Key? key,
    required this.date,
    this.info,
    this.color,
    this.useHorizontalPaddingConstrained = true,
    this.afterDate = "",
    this.maxLines,
  }) : super(key: key);

  final DateTime date;
  final String? info;
  final Color? color;
  final bool useHorizontalPaddingConstrained;
  final String afterDate;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: useHorizontalPaddingConstrained == false
            ? 0
            : getHorizontalPaddingConstrained(context),
      ),
      child: StickyLabelDivider(
        info: getWordedDate(date,
                includeMonthDate: true, includeYearIfNotCurrentYear: true) +
            afterDate,
        extraInfo: info,
        color: color,
        fontSize: 14,
        maxLines: maxLines,
      ),
    );
  }
}
