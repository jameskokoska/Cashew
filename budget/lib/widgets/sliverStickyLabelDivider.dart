import 'package:budget/colors.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/src/material/theme.dart';
import 'package:flutter/src/widgets/basic.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/sliver.dart';
import 'package:flutter_sticky_header/src/widgets/sliver_sticky_header.dart';

class SliverStickyLabelDivider extends StatelessWidget {
  SliverStickyLabelDivider({
    Key? key,
    required this.info,
    this.extraInfo,
    this.extraInfoWidget,
    required this.sliver,
    this.color,
    this.visible = true,
  }) : super(key: key);

  final String info;
  final String? extraInfo;
  final Widget? extraInfoWidget;
  final Widget? sliver;
  final Color? color;
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
              child: Container(
                color: color == null ? Theme.of(context).canvasColor : color,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextFont(
                      text: info,
                      fontSize: 15,
                      textColor: getColor(context, "textLight"),
                    ),
                    extraInfo == null
                        ? SizedBox.shrink()
                        : Expanded(
                            child: TextFont(
                              text: extraInfo ?? "",
                              fontSize: 15,
                              textColor: getColor(context, "textLight"),
                              textAlign: TextAlign.end,
                            ),
                          ),
                    extraInfoWidget == null
                        ? SizedBox.shrink()
                        : extraInfoWidget!,
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
