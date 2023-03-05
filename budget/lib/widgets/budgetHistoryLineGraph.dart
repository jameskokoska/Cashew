import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BudgetHistoryLineGraph extends StatefulWidget {
  const BudgetHistoryLineGraph({
    super.key,
    required this.budget,
    required this.color,
    required this.dateRanges,
    required this.spots,
    required this.initialSpots,
    required this.horizontalLineAt,
    required this.maxY,
    this.onTouchedIndex,
  });

  final Color color;
  final List<DateTimeRange> dateRanges;
  final List<FlSpot> spots;
  final List<FlSpot> initialSpots;
  final Budget budget;
  final double? horizontalLineAt;
  final double maxY;
  final Function(int?)? onTouchedIndex;

  @override
  State<BudgetHistoryLineGraph> createState() => _BudgetHistoryLineGraphState();
}

class _BudgetHistoryLineGraphState extends State<BudgetHistoryLineGraph> {
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 0), () {
      setState(() {
        loaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final lineBarsData = [
      LineChartBarData(
        isStrokeCapRound: true,
        spots: loaded ? widget.spots : widget.initialSpots,
        isCurved: true,
        preventCurveOverShooting: true,
        barWidth: 3,
        // shadow: const Shadow(
        //   blurRadius: 8,
        // ),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [
              widget.color.withOpacity(0),
              widget.color.withOpacity(0.3),
              widget.color.withOpacity(0.6),
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            return FlDotCirclePainter(
              radius: 4,
              color: lightenPastel(widget.color, amount: 0.3).withOpacity(0.8),
              strokeWidth: 0,
            );
          },
        ),
        color: lightenPastel(widget.color, amount: 0.3),
      ),
      LineChartBarData(
        isStrokeCapRound: false,
        spots: loaded ? widget.spots : widget.initialSpots,
        isCurved: true,
        preventCurveOverShooting: true,
        barWidth: 0,
        belowBarData: BarAreaData(
          show: true,
          applyCutOffY: true,
          cutOffY: widget.horizontalLineAt,
          gradient: LinearGradient(
            colors: [
              widget.color.withOpacity(0.15),
              widget.color.withOpacity(0.15),
              widget.color.withOpacity(0.15),
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        dotData: FlDotData(show: false),
        color: Colors.transparent,
      ),
    ];

    final tooltipsOnBar = lineBarsData[0];

    return Container(
      height: 190,
      padding: const EdgeInsets.only(
        left: 10,
        right: 25,
        top: 25,
      ),
      child: LineChart(
        swapAnimationCurve: Curves.easeInOutCubicEmphasized,
        swapAnimationDuration: Duration(milliseconds: 2000),
        LineChartData(
          lineBarsData: lineBarsData,
          minY: -0.00000000000001,
          maxY: widget.maxY,
          lineTouchData: LineTouchData(
            touchCallback:
                (FlTouchEvent event, LineTouchResponse? touchResponse) {
              if (!event.isInterestedForInteractions || touchResponse == null) {
                if (widget.onTouchedIndex != null) widget.onTouchedIndex!(null);
                return;
              }
              double value = touchResponse.lineBarSpots![0].x;
              if (widget.onTouchedIndex != null)
                widget.onTouchedIndex!(value.toInt());
            },
            enabled: true,
            touchSpotThreshold: 1000,
            getTouchedSpotIndicator:
                (LineChartBarData barData, List<int> spotIndexes) {
              return spotIndexes.map((index) {
                return TouchedSpotIndicatorData(
                  FlLine(
                    color: widget.color.withOpacity(0.9),
                    strokeWidth: 2,
                    dashArray: [2, 2],
                  ),
                  FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) =>
                        FlDotCirclePainter(
                      radius: 3,
                      color: widget.color.withOpacity(0.9),
                      strokeWidth: 2,
                      strokeColor: widget.color.withOpacity(0.9),
                    ),
                  ),
                );
              }).toList();
            },
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: widget.color.withOpacity(0.7),
              tooltipRoundedRadius: 8,
              fitInsideVertically: true,
              fitInsideHorizontally: true,
              tooltipPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
                return lineBarsSpot.map((lineBarSpot) {
                  // only show touch data for primary colored lines
                  if (lineBarSpot.bar.color !=
                      lightenPastel(widget.color, amount: 0.3)) {
                    return null;
                  }
                  return LineTooltipItem(
                    convertToMoney(lineBarSpot.y),
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, _) {
                    print(value.toInt());
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: TextFont(
                        textAlign: TextAlign.center,
                        fontSize: 13,
                        text: widget.budget.reoccurrence ==
                                BudgetReoccurence.monthly
                            ? DateFormat('MMM').format(widget
                                .dateRanges[
                                    widget.spots.length - 1 - value.toInt()]
                                .start)
                            : widget.budget.reoccurrence ==
                                    BudgetReoccurence.yearly
                                ? DateFormat('yyyy').format(widget
                                    .dateRanges[
                                        widget.spots.length - 1 - value.toInt()]
                                    .start)
                                : DateFormat('MMM\nd').format(widget
                                    .dateRanges[
                                        widget.spots.length - 1 - value.toInt()]
                                    .start),
                        textColor: dynamicPastel(context, widget.color,
                                amount: 0.8, inverse: true)
                            .withOpacity(0.5),
                      ),
                    );
                  }),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (
                  value,
                  titleMeta,
                ) {
                  bool show = false;
                  if (value == 0) {
                    show = true;
                  } else if (value <= widget.maxY && value > 1) {
                    show = true;
                  } else {
                    return SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: TextFont(
                      textAlign: TextAlign.right,
                      text: getWordedNumber(value),
                      textColor: dynamicPastel(context, widget.color,
                              amount: 0.5, inverse: true)
                          .withOpacity(0.3),
                      fontSize: 13,
                    ),
                  );
                },
                reservedSize: (widget.maxY >= 10000
                    ? 55
                    : widget.maxY >= 1000
                        ? 45
                        : widget.maxY >= 100
                            ? 40
                            : 40),
                interval: (widget.maxY / 3.8),
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            horizontalInterval: 1,
            checkToShowHorizontalLine: (value) {
              if (value == widget.horizontalLineAt) {
                return true;
              } else if (value == 0) {
                return true;
              } else if (value % ((widget.maxY / 3.8).ceil()) == 1) {
                return true;
              }
              return false;
            },
            getDrawingHorizontalLine: (value) {
              if (value == widget.horizontalLineAt) {
                return FlLine(
                  dashArray: [2, 2],
                  strokeWidth: 2,
                  color: dynamicPastel(context, widget.color, amount: 0.3)
                      .withOpacity(0.7),
                );
              } else if (value == 0) {
                return FlLine(
                  color: dynamicPastel(context, widget.color, amount: 0.3)
                      .withOpacity(0.2),
                  strokeWidth: 2,
                );
              } else if (value % ((widget.maxY / 3.8).ceil()) == 1) {
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
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}
