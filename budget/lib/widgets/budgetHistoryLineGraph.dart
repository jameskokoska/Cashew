import 'dart:math';

import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/widgets/lineGraph.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class BudgetHistoryLineGraph extends StatelessWidget {
  const BudgetHistoryLineGraph({
    super.key,
    required this.budget,
    required this.color,
    this.lineColors,
    required this.dateRanges,
    required this.spots,
    required this.horizontalLineAt,
    required this.maxY,
    required this.minY,
    required this.extraCategorySpots,
    required this.categoriesMapped,
    required this.loadAllEvenIfZero,
    this.onTouchedIndex,
    required this.setNoPastRegionsAreZero,
    this.showDateOnHover = false,
  });

  final Color color;
  final List<Color>? lineColors;
  final List<DateTimeRange> dateRanges;
  final List<List<FlSpot>> spots;
  final Budget budget;
  final double? horizontalLineAt;
  final double maxY;
  final double minY;
  final Function(int?)? onTouchedIndex;
  final Map<String, List<FlSpot>> extraCategorySpots;
  final Map<String, TransactionCategory> categoriesMapped;
  final bool loadAllEvenIfZero;
  final Function(bool) setNoPastRegionsAreZero;
  final bool showDateOnHover;

  @override
  Widget build(BuildContext context) {
    // Show 3 zero entries
    int minimumNumberOfZero = 3;

    List<DateTimeRange> filteredDateRanges = dateRanges;
    List<List<FlSpot>> filteredSpotsFixedX = spots;
    Map<String, List<FlSpot>> extraCategorySpotsFilteredFixedX =
        extraCategorySpots;
    if (loadAllEvenIfZero == false) {
      filteredDateRanges = [];
      filteredSpotsFixedX = [];
      List<int> numberZeroList = [];
      for (List<FlSpot> listSpot in spots) {
        int numberZero = 0;
        for (FlSpot spot in listSpot) {
          if (double.parse(spot.y.toStringAsFixed(5)) == 0) {
            numberZero++;
          } else {
            // Don't keep counting after there is a non-zero!
            break;
          }
        }
        numberZeroList.add(numberZero);
      }

      int minNumberZero =
          numberZeroList.isNotEmpty ? numberZeroList.reduce(min) : 0;
      // Always keep at least minimumNumberOfZero periods in view even if zero
      if (dateRanges.length - minNumberZero <= minimumNumberOfZero) {
        minNumberZero = dateRanges.length - minimumNumberOfZero;
      }

      filteredDateRanges =
          dateRanges.take(dateRanges.length - minNumberZero).toList();

      // Remove the zeroes
      List<List<FlSpot>> filteredSpots = [];
      for (List<FlSpot> listSpot in spots) {
        filteredSpots.add(listSpot.sublist(minNumberZero));
      }
      // Fix the x values
      for (List<FlSpot> listSpot in filteredSpots) {
        int index = 0;
        List<FlSpot> listSpotNew = [];
        for (FlSpot spot in listSpot) {
          listSpotNew.add(FlSpot(index.toDouble(), spot.y));
          index++;
        }
        filteredSpotsFixedX.add(listSpotNew);
      }

      // Remove the zeroes
      Map<String, List<FlSpot>> extraCategorySpotsFiltered = extraCategorySpots;
      for (String key in extraCategorySpots.keys) {
        extraCategorySpotsFiltered[key] =
            extraCategorySpots[key]?.sublist(minNumberZero) ?? [];
      }
      // Fix the x values
      for (String key in extraCategorySpotsFiltered.keys) {
        List<FlSpot> listSpot = extraCategorySpotsFiltered[key] ?? [];
        int index = 0;
        List<FlSpot> listSpotNew = [];
        for (FlSpot spot in listSpot) {
          listSpotNew.add(FlSpot(index.toDouble(), spot.y));
          index++;
        }
        extraCategorySpotsFilteredFixedX[key] = listSpotNew;
      }

      // If all regions are non-zero
      // i.e. the oldest region loaded is not zero (If showing from April-November and April is non-zero)
      // Then we set this to true which indicates all periods were displayed on the graph
      if (filteredSpotsFixedX.firstOrNull?.length ==
          spots.firstOrNull?.length) {
        setNoPastRegionsAreZero(true);
      }
      if (filteredDateRanges.length <= 0 || filteredSpotsFixedX.length <= 0) {
        filteredDateRanges = dateRanges;
        filteredSpotsFixedX = spots;
      }
    }

    if (filteredSpotsFixedX.isEmpty) {
      filteredSpotsFixedX = [
        [
          for (int i = 0; i < minimumNumberOfZero; i++)
            FlSpot(
              i.toDouble(),
              0.000000000001,
            ),
        ]
      ];
    }

    List<List<FlSpot>> initialSpotsAll = [];
    for (int i = 0; i < filteredSpotsFixedX.length; i++) {
      List<FlSpot> initialSpots = [];
      for (int j = 0; j < filteredSpotsFixedX[i].length; j++) {
        initialSpots.add(FlSpot(
          j.toDouble(),
          0.000000000001,
        ));
      }
      initialSpotsAll.add(initialSpots);
    }

    return _BudgetHistoryLineGraph(
      budget: budget,
      color: color,
      lineColors: lineColors,
      dateRanges: filteredDateRanges,
      originalDateRanges: dateRanges,
      spots: filteredSpotsFixedX,
      initialSpots: initialSpotsAll,
      horizontalLineAt: horizontalLineAt,
      maxY: maxY,
      minY: minY,
      extraCategorySpots: extraCategorySpotsFilteredFixedX,
      categoriesMapped: categoriesMapped,
      onTouchedIndex: onTouchedIndex,
      showDateOnHover: showDateOnHover,
      key: key,
    );
  }
}

class _BudgetHistoryLineGraph extends StatefulWidget {
  const _BudgetHistoryLineGraph({
    super.key,
    required this.budget,
    required this.color,
    this.lineColors,
    required this.dateRanges,
    required this.originalDateRanges,
    required this.spots,
    required this.initialSpots,
    required this.horizontalLineAt,
    required this.maxY,
    required this.minY,
    required this.extraCategorySpots,
    required this.categoriesMapped,
    required this.showDateOnHover,
    this.onTouchedIndex,
  });

  final Color color;
  final List<Color>? lineColors;
  final List<DateTimeRange> dateRanges;
  final List<DateTimeRange> originalDateRanges;
  final List<List<FlSpot>> spots;
  final List<List<FlSpot>> initialSpots;
  final Budget budget;
  final double? horizontalLineAt;
  final double maxY;
  final double minY;
  final Function(int?)? onTouchedIndex;
  final Map<String, List<FlSpot>> extraCategorySpots;
  final Map<String, TransactionCategory> categoriesMapped;
  final bool showDateOnHover;

  @override
  State<_BudgetHistoryLineGraph> createState() =>
      _BudgetHistoryLineGraphState();
}

class _BudgetHistoryLineGraphState extends State<_BudgetHistoryLineGraph> {
  bool loaded = false;
  int? touchedValue = null;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      setState(() {
        loaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final lineBarsData = [
      for (int i = 0; i < widget.spots.length; i++)
        LineChartBarData(
          isStrokeCapRound: true,
          spots: loaded ? widget.spots[i] : widget.initialSpots[i],
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
                (widget.lineColors?[i] ?? widget.color).withOpacity(0),
                (widget.lineColors?[i] ?? widget.color).withOpacity(0.3),
                (widget.lineColors?[i] ?? widget.color).withOpacity(0.6),
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
                color: lightenPastel(widget.lineColors?[i] ?? widget.color,
                        amount: 0.3)
                    .withOpacity(0.8),
                strokeWidth: 0,
              );
            },
          ),
          color:
              lightenPastel(widget.lineColors?[i] ?? widget.color, amount: 0.3),
        ),
      if (widget.horizontalLineAt != null)
        for (int i = 0; i < widget.spots.length; i++)
          LineChartBarData(
            isStrokeCapRound: false,
            spots: loaded ? widget.spots[i] : widget.initialSpots[i],
            isCurved: true,
            preventCurveOverShooting: true,
            barWidth: 0,
            belowBarData: BarAreaData(
              show: true,
              applyCutOffY: true,
              cutOffY: widget.horizontalLineAt ?? 0,
              gradient: LinearGradient(
                colors: [
                  (widget.lineColors?[i] ?? widget.color).withOpacity(0.15),
                  (widget.lineColors?[i] ?? widget.color).withOpacity(0.15),
                  (widget.lineColors?[i] ?? widget.color).withOpacity(0.15),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
            dotData: FlDotData(show: false),
            color: Colors.transparent,
          ),
      for (String categoryPk in widget.extraCategorySpots.keys)
        LineChartBarData(
          isStrokeCapRound: true,
          spots: widget.extraCategorySpots[categoryPk] ?? [],
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
                        HexColor(widget.categoriesMapped[categoryPk]?.colour),
                        amount: 0.3)
                    .withOpacity(0.6),
                strokeWidth: 0,
              );
            },
          ),
          color: lightenPastel(
                  HexColor(widget.categoriesMapped[categoryPk]?.colour),
                  amount: 0.3)
              .withOpacity(0.8),
        ),
    ];

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.3 >
              (getIsFullScreen(context) == false ? 190 : 350)
          ? getIsFullScreen(context) == false
              ? 190
              : 350
          : MediaQuery.sizeOf(context).height * 0.3,
      padding: const EdgeInsets.only(
        left: 10,
        right: 25,
        top: 25,
      ),
      child: LineChart(
        curve: Curves.easeInOutCubicEmphasized,
        duration: Duration(milliseconds: 2000),
        LineChartData(
          lineBarsData: lineBarsData,
          minY: widget.minY,
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

              // Correct the x value, because not all loaded periods may be shown in the graph
              // because we remove the zero values
              double value = (widget.originalDateRanges.length -
                      (widget.spots.firstOrNull ?? []).length) +
                  touchResponse.lineBarSpots![0].x;
              if (touchedValue != value.toInt()) if (widget.onTouchedIndex !=
                  null) widget.onTouchedIndex!(value.toInt());

              if (event.runtimeType == FlLongPressStart) {
                HapticFeedback.selectionClick();
              } else if (touchedValue != value.toInt() &&
                  (event.runtimeType == FlLongPressMoveUpdate ||
                      event.runtimeType == FlPanUpdateEvent)) {
                HapticFeedback.selectionClick();
              }

              touchedValue = value.toInt();
            },
            enabled: true,
            touchSpotThreshold: 1000,
            getTouchedSpotIndicator:
                (LineChartBarData barData, List<int> spotIndexes) {
              return spotIndexes.map((index) {
                return TouchedSpotIndicatorData(
                  FlLine(
                    color: (widget.extraCategorySpots.keys.length <= 0
                            ? widget.color
                            : barData.color) ??
                        Theme.of(context).colorScheme.primary,
                    strokeWidth: 2,
                    dashArray: [2, 2],
                  ),
                  FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) =>
                        FlDotCirclePainter(
                      radius: 3,
                      color: (widget.extraCategorySpots.keys.length <= 0 &&
                                  widget.lineColors == null
                              ? widget.color.withOpacity(0.9)
                              : barData.color) ??
                          Theme.of(context).colorScheme.primary,
                      strokeWidth: 2,
                      strokeColor:
                          (widget.extraCategorySpots.keys.length <= 0 &&
                                      widget.lineColors == null
                                  ? widget.color.withOpacity(0.9)
                                  : barData.color) ??
                              Theme.of(context).colorScheme.primary,
                    ),
                  ),
                );
              }).toList();
            },
            touchTooltipData: LineTouchTooltipData(
              maxContentWidth: 170,
              tooltipBgColor: widget.extraCategorySpots.keys.length <= 0 &&
                      (widget.lineColors == null ||
                          (widget.lineColors?.length ?? 0) <= 0)
                  ? widget.color.withOpacity(0.7)
                  : dynamicPastel(
                      context,
                      getColor(context, "white"),
                      inverse: true,
                      amountLight: 0.2,
                      amountDark: 0.05,
                    ).withOpacity(0.8),
              tooltipRoundedRadius: 8,
              fitInsideVertically: true,
              fitInsideHorizontally: true,
              tooltipPadding:
                  EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 6),
              getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
                return lineBarsSpot.asMap().entries.map((entry) {
                  LineBarSpot lineBarSpot = entry.value;
                  int index = entry.key;
                  // hide touch data for the overage line
                  if (lineBarSpot.bar.color == Colors.transparent) {
                    return null;
                  }
                  DateTimeRange? dateRange;
                  try {
                    List<DateTimeRange> dateRanges = widget.dateRanges
                        .take(widget.spots.first.length)
                        .toList();
                    dateRange = dateRanges[
                        dateRanges.length - 1 - (lineBarsSpot.first.x).round()];
                  } catch (e) {
                    print(
                        "Error with date ranges passed in, length mismatched that of lines: " +
                            e.toString());
                  }

                  return LineTooltipItem(
                    "",
                    TextStyle(),
                    children: [
                      if (dateRange != null &&
                          index == 0 &&
                          widget.showDateOnHover)
                        TextSpan(
                          text: getWordedDateShort(dateRange.start) +
                              " – " +
                              getWordedDateShort(dateRange.end) +
                              "\n",
                          style: TextStyle(
                            color: getColor(context, "black")
                                .withOpacity(lineBarsSpot.length > 1 ? 0.7 : 1),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            fontFamilyFallback: ['Inter'],
                          ),
                        ),
                      TextSpan(
                        text: convertToMoney(
                            Provider.of<AllWallets>(context, listen: false),
                            lineBarSpot.y),
                        style: TextStyle(
                          color: lineBarSpot.bar.color ==
                                  lightenPastel(widget.color, amount: 0.3)
                              ? widget.extraCategorySpots.keys.length <= 0
                                  ? Colors.white.withOpacity(0.9)
                                  : getColor(context, "black").withOpacity(0.7)
                              : lineBarSpot.bar.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          fontFamilyFallback: ['Inter'],
                          height: index == 0 &&
                                  widget.showDateOnHover &&
                                  lineBarsSpot.length > 1
                              ? 1.8
                              : null,
                        ),
                      ),
                    ],
                  );
                }).toList();
              },
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                interval: null,
                showTitles: true,
                reservedSize: widget.budget.reoccurrence ==
                            BudgetReoccurence.weekly ||
                        widget.budget.reoccurrence == BudgetReoccurence.daily
                    ? 35
                    : 22,
                getTitlesWidget: (value, meta) {
                  DateTime startDate = widget.dateRanges[0].start;
                  if ((widget.spots.firstOrNull ?? []).length -
                              1 -
                              value.round() <
                          widget.dateRanges.length &&
                      (widget.spots.firstOrNull ?? []).length -
                              1 -
                              value.round() >=
                          0) {
                    startDate = widget
                        .dateRanges[(widget.spots.firstOrNull ?? []).length -
                            1 -
                            value.round()]
                        .start;
                  }
                  if (value.toStringAsFixed(2) ==
                      value.round().toStringAsFixed(2)) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: MediaQuery(
                        data: MediaQuery.of(context)
                            .copyWith(textScaleFactor: 1.0),
                        child: TextFont(
                          textAlign: TextAlign.center,
                          fontSize: 13,
                          text: widget.budget.reoccurrence ==
                                  BudgetReoccurence.weekly
                              ? DateFormat('MMM\ndd', context.locale.toString())
                                  .format(startDate)
                              : widget.budget.reoccurrence ==
                                      BudgetReoccurence.daily
                                  ? DateFormat(
                                          'MMM\ndd', context.locale.toString())
                                      .format(startDate)
                                  : widget.budget.reoccurrence ==
                                          BudgetReoccurence.monthly
                                      ? DateFormat(
                                              'MMM', context.locale.toString())
                                          .format(startDate)
                                      : widget.budget.reoccurrence ==
                                              BudgetReoccurence.yearly
                                          ? DateFormat('yyyy',
                                                  context.locale.toString())
                                              .format(startDate)
                                          : DateFormat('MMM',
                                                  context.locale.toString())
                                              .format(startDate),
                          textColor: dynamicPastel(context, widget.color,
                                  amount: 0.8, inverse: true)
                              .withOpacity(0.5),
                        ),
                      ),
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
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
                  } else if (value <= widget.maxY && value > widget.minY) {
                    show = true;
                  } else {
                    return SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: MediaQuery(
                      data:
                          MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                      child: TextFont(
                        textAlign: TextAlign.right,
                        text: getWordedNumber(
                            Provider.of<AllWallets>(context), value),
                        textColor: dynamicPastel(context, widget.color,
                                amount: 0.5, inverse: true)
                            .withOpacity(0.3),
                        fontSize: 13,
                      ),
                    ),
                  );
                },
                reservedSize: (widget.maxY >= 10000
                        ? 55
                        : widget.maxY >= 1000
                            ? 45
                            : widget.maxY >= 100
                                ? 40
                                : 40) +
                    measureCurrencyStringExtraWidth(
                        Provider.of<AllWallets>(context)),
                interval: (widget.maxY / 3.8),
              ),
            ),
          ),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: 0,
                color: dynamicPastel(context, widget.color, amount: 0.3)
                    .withOpacity(0.4),
              ),
              ...(widget.horizontalLineAt == null
                  ? []
                  : [
                      HorizontalLine(
                        y: widget.horizontalLineAt!,
                        color: dynamicPastel(context, widget.color, amount: 0.3)
                            .withOpacity(0.7),
                        dashArray: [2, 2],
                      ),
                    ])
            ],
          ),
          gridData: FlGridData(
            show: true,
            // checkToShowHorizontalLine: (value) {
            //   if (value == widget.horizontalLineAt) {
            //     return true;
            //   } else if (value == 0) {
            //     return true;
            //   } else if (value % ((widget.maxY / 3.8).ceil()) == 1) {
            //     return true;
            //   }
            //   return false;
            // },
            // getDrawingHorizontalLine: (value) {
            //   if (value == widget.horizontalLineAt) {
            //     return FlLine(
            //       dashArray: [2, 2],
            //       strokeWidth: 2,
            //       color: dynamicPastel(context, widget.color, amount: 0.3)
            //           .withOpacity(0.7),
            //     );
            //   } else if (value == 0) {
            //     return FlLine(
            //       color: dynamicPastel(context, widget.color, amount: 0.3)
            //           .withOpacity(0.2),
            //       strokeWidth: 2,
            //     );
            //   } else if (value % ((widget.maxY / 3.8).ceil()) == 1) {
            //     return FlLine(
            //       color: dynamicPastel(context, widget.color, amount: 0.3)
            //           .withOpacity(0.2),
            //       strokeWidth: 2,
            //       dashArray: [2, 8],
            //     );
            //   }
            //   return FlLine(color: Colors.transparent, strokeWidth: 0);
            // },
            // If the interval is equal to a really small number (almost 0, it freezes the app!)
            horizontalInterval:
                double.parse((widget.maxY).toStringAsFixed(5)) == 0.0
                    ? 0.001
                    : ((widget.maxY) / (getIsFullScreen(context) ? 7 : 4))
                        .abs(),
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: dynamicPastel(context, widget.color, amount: 0.3)
                    .withOpacity(0.2),
                strokeWidth: 2,
                dashArray: [2, 8],
              );
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
