import 'package:budget/colors.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/src/widgets/sliver_sticky_header.dart';

class SliverStickyLabelDivider extends StatelessWidget {
  SliverStickyLabelDivider({
    Key? key,
    required this.info,
    this.extraInfo,
    this.extraInfoWidget,
    this.color,
    required this.sliver,
    this.visible = true,
  }) : super(key: key);

  final String info;
  final String? extraInfo;
  final Widget? extraInfoWidget;
  final Color? color;
  final Widget? sliver;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return SliverIgnorePointer(
      ignoring: !visible,
      sliver: SliverStickyHeader(
        sliver: sliver,
        header: Transform.translate(
          offset: Offset(0, -1),
          child: AnimatedExpanded(
            expand: visible && sliver != null,
            child: StickyLabelDivider(
              info: info,
              extraInfo: extraInfo,
              extraInfoWidget: extraInfoWidget,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

class StickyLabelDivider extends StatelessWidget {
  const StickyLabelDivider({
    super.key,
    required this.info,
    this.extraInfo,
    this.extraInfoWidget,
    this.color,
    this.fontSize = 15,
    this.maxLines,
  });

  final String info;
  final String? extraInfo;
  final Widget? extraInfoWidget;
  final Color? color;
  final double fontSize;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color == null ? Theme.of(context).colorScheme.background : color,
      padding: EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 5),
      alignment: AlignmentDirectional.centerStart,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: TextFont(
              text: info,
              fontSize: fontSize,
              textColor: getColor(context, "textLight"),
              maxLines: maxLines,
            ),
          ),
          if (extraInfo != null)
            TextFont(
              text: extraInfo ?? "",
              fontSize: fontSize,
              textColor: getColor(context, "textLight"),
              textAlign: TextAlign.end,
            ),
          if (extraInfoWidget != null) extraInfoWidget!,
        ],
      ),
    );
  }
}
