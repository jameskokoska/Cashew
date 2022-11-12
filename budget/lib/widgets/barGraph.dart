import 'package:budget/colors.dart';
import 'package:budget/functions.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/admob/v1.dart';

class BarGraph extends StatefulWidget {
  BarGraph({
    required this.color,
    required this.dateRanges,
    required this.bars,
    required this.horizontalLineAt,
    required this.maxY,
    Key? key,
  }) : super(key: key);

  final Color color;
  final List<DateTimeRange> dateRanges;
  final List<BarChartGroupData> bars;

  final double? horizontalLineAt;
  final double maxY;

  @override
  State<StatefulWidget> createState() => BarGraphState();
}

class BarGraphState extends State<BarGraph> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 10,
        right: 30,
        bottom: 10,
        top: 5,
      ),
      child: Container(
        height: 190,
        child: BarChart(
          swapAnimationDuration: Duration(milliseconds: 500),
          BarChartData(
            maxY: widget.maxY,
            minY: -1,
            alignment: BarChartAlignment.spaceBetween,
            barTouchData: BarTouchData(
              handleBuiltInTouches: false,
            ),
            gridData: FlGridData(
              show: true,
              horizontalInterval: 1,
              checkToShowHorizontalLine: (value) => true,
              getDrawingHorizontalLine: (value) {
                if (value == widget.horizontalLineAt) {
                  return FlLine(
                    dashArray: [2, 2],
                    strokeWidth: 2,
                    color: dynamicPastel(context, widget.color, amount: 0.3)
                        .withOpacity(0.7),
                  );
                }
                if (value == 0) {
                  return FlLine(
                    color: dynamicPastel(context, widget.color, amount: 0.3)
                        .withOpacity(0.2),
                    strokeWidth: 2,
                  );
                }
                if (value % ((widget.maxY / 3.8).ceil()) == 1) {
                  return FlLine(
                    color: dynamicPastel(context, widget.color, amount: 0.3)
                        .withOpacity(0.2),
                    strokeWidth: 2,
                    dashArray: [2, 8],
                  );
                }
                return FlLine(color: Colors.transparent, strokeWidth: 0);
              },
              getDrawingVerticalLine: (value) {
                return FlLine(
                  color: dynamicPastel(context, widget.color, amount: 0.3)
                      .withOpacity(0.2),
                  strokeWidth: 2,
                  dashArray: [2, 8],
                );
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: SideTitles(
                showTitles: true,
                getTextStyles: (_, __) {
                  return TextStyle(
                    color: dynamicPastel(context, widget.color,
                            amount: 0.8, inverse: true)
                        .withOpacity(0.5),
                    fontFamily: 'Avenir',
                    fontSize: 12.5,
                  );
                },
                margin: 7,
                getTitles: (value) {
                  return getWordedDateShort(
                    widget.dateRanges[value.toInt()].start,
                    showTodayTomorrow: false,
                    newLineDay: true,
                  );
                },
              ),
              rightTitles: SideTitles(showTitles: false),
              topTitles: SideTitles(showTitles: false),
              leftTitles: SideTitles(
                textAlign: TextAlign.right,
                showTitles: true,
                getTextStyles: (_, __) {
                  return TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: dynamicPastel(context, widget.color,
                            amount: 0.5, inverse: true)
                        .withOpacity(0.3),
                    fontFamily: 'Avenir',
                  );
                },
                getTitles: (value) {
                  return getWordedNumber(value);
                },
                interval: (widget.maxY / 3.8),
                margin: 6,
                reservedSize: 40,
              ),
            ),
            borderData: FlBorderData(
              show: false,
            ),
            barGroups: widget.bars,
          ),
        ),
      ),
    );
  }
}

BarChartGroupData makeGroupData(int x, double y1, double y2, color) {
  return BarChartGroupData(
    barsSpace: 0,
    x: x,
    barRods: [
      BarChartRodData(
        y: y1,
        colors: [color.withAlpha(120), color],
        width: 13,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(5),
          bottomRight: Radius.circular(5),
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      // BarChartRodData(
      //   y: y2,
      //   colors: [color.withAlpha(120), color],
      //   width: 10,
      // ),
    ],
  );
}
