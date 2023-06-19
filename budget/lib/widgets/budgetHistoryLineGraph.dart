import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
    required this.extraCategorySpots,
    required this.categoriesMapped,
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
  final Map<int, List<FlSpot>> extraCategorySpots;
  final Map<int, TransactionCategory> categoriesMapped;

  @override
  State<BudgetHistoryLineGraph> createState() => _BudgetHistoryLineGraphState();
}

class _BudgetHistoryLineGraphState extends State<BudgetHistoryLineGraph> {
  bool loaded = false;
  int? touchedValue = null;

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
      for (int categoryPk in widget.extraCategorySpots.keys)
        LineChartBarData(
          isStrokeCapRound: true,
          spots: widget.extraCategorySpots[categoryPk],
          isCurved: true,
          curveSmoothness: 0.35,
          preventCurveOverShooting: true,
          barWidth: 3,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 3,
                color: lightenPastel(
                        HexColor(widget.categoriesMapped[categoryPk]!.colour),
                        amount: 0.3)
                    .withOpacity(0.6),
                strokeWidth: 0,
              );
            },
          ),
          color: lightenPastel(
                  HexColor(widget.categoriesMapped[categoryPk]!.colour),
                  amount: 0.3)
              .withOpacity(0.8),
        ),
    ];

    return Container(
      height: MediaQuery.of(context).size.height * 0.3 >
              (getWidthNavigationSidebar(context) <= 0 ? 190 : 350)
          ? getWidthNavigationSidebar(context) <= 0
              ? 190
              : 350
          : MediaQuery.of(context).size.height * 0.3,
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
                if (touchedValue != null) if (widget.onTouchedIndex != null)
                  widget.onTouchedIndex!(null);
                touchedValue = null;
                return;
              }
              double value = touchResponse.lineBarSpots![0].x;
              if (touchedValue != value.toInt()) if (widget.onTouchedIndex !=
                  null) widget.onTouchedIndex!(value.toInt());
              touchedValue = value.toInt();
            },
            enabled: true,
            touchSpotThreshold: 1000,
            getTouchedSpotIndicator:
                (LineChartBarData barData, List<int> spotIndexes) {
              return spotIndexes.map((index) {
                return TouchedSpotIndicatorData(
                  FlLine(
                    color: widget.extraCategorySpots.keys.length <= 0
                        ? widget.color
                        : barData.color,
                    strokeWidth: 2,
                    dashArray: [2, 2],
                  ),
                  FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) =>
                        FlDotCirclePainter(
                      radius: 3,
                      color: widget.extraCategorySpots.keys.length <= 0
                          ? widget.color.withOpacity(0.9)
                          : barData.color,
                      strokeWidth: 2,
                      strokeColor: widget.extraCategorySpots.keys.length <= 0
                          ? widget.color.withOpacity(0.9)
                          : barData.color,
                    ),
                  ),
                );
              }).toList();
            },
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: widget.extraCategorySpots.keys.length <= 0
                  ? widget.color.withOpacity(0.7)
                  : dynamicPastel(
                      context,
                      getColor(context, "white"),
                      inverse: true,
                      amountLight: 0.2,
                      amountDark: 0,
                    ).withOpacity(0.8),
              tooltipRoundedRadius: 8,
              fitInsideVertically: true,
              fitInsideHorizontally: true,
              tooltipPadding:
                  EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 6),
              getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
                return lineBarsSpot.map((LineBarSpot lineBarSpot) {
                  // hide touch data for the overage line
                  if (lineBarSpot.bar.color == Colors.transparent) {
                    return null;
                  }
                  return LineTooltipItem(
                    convertToMoney(
                        Provider.of<AllWallets>(context, listen: false),
                        lineBarSpot.y),
                    TextStyle(
                      color: lineBarSpot.bar.color ==
                              lightenPastel(widget.color, amount: 0.3)
                          ? Colors.white.withOpacity(0.9)
                          : lineBarSpot.bar.color,
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
                  interval: getIsFullScreen(context) ? 1 : null,
                  showTitles: true,
                  getTitlesWidget: (value, _) {
                    DateTime startDate = widget.dateRanges[0].start;
                    if (widget.spots.length - 1 - value.toInt() <
                            widget.dateRanges.length &&
                        widget.spots.length - 1 - value.toInt() >= 0) {
                      startDate = widget
                          .dateRanges[widget.spots.length - 1 - value.toInt()]
                          .start;
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: TextFont(
                        textAlign: TextAlign.center,
                        fontSize: 13,
                        text: widget.budget.reoccurrence ==
                                BudgetReoccurence.monthly
                            ? DateFormat('MMM').format(startDate)
                            : widget.budget.reoccurrence ==
                                    BudgetReoccurence.yearly
                                ? DateFormat('yyyy').format(startDate)
                                : DateFormat('MMM\nd').format(startDate),
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
                      text: getWordedNumber(
                          Provider.of<AllWallets>(context), value),
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
