import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';

class _LineChart extends StatefulWidget {
  _LineChart({
    required this.spots,
    required this.maxPair,
    required this.minPair,
    required this.color,
    this.isCurved = false,
    this.endDate,
    this.verticalLineAt,
    this.horizontalLineAt,
    required this.enableTouch,
    this.colors = const [],
    Key? key,
  }) : super(key: key);

  final List<List<FlSpot>> spots;
  final Pair maxPair;
  final Pair minPair;
  final Color color;
  final List<Color> colors;
  final bool isCurved;
  final DateTime? endDate;
  final double? verticalLineAt;
  final double? horizontalLineAt;
  final bool enableTouch;

  @override
  State<_LineChart> createState() => _LineChartState();
}

class _LineChartState extends State<_LineChart> with WidgetsBindingObserver {
  bool loaded = false;
  double extraHorizontalPadding = 10;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.delayed(Duration(milliseconds: 0), () {
      setState(() {
        loaded = true;
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    // print(widget.spots);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          right: 10 + extraHorizontalPadding, top: 8, bottom: 0),
      child: GestureDetector(
        child: LineChart(
          data,
          swapAnimationDuration: const Duration(milliseconds: 2000),
          swapAnimationCurve: Curves.easeInOutCubicEmphasized,
        ),
      ),
    );
  }

  LineChartData get data => LineChartData(
        lineTouchData: lineTouchData,
        gridData: gridData,
        borderData: borderData,
        lineBarsData: lineBarsData,
        minX: 0,
        minY: loaded
            ? (widget.maxPair.y > 0 && widget.minPair.y > 0) ||
                    (widget.maxPair.y < 0 && widget.minPair.y < 0)
                ? 0
                : widget.minPair.y
            : widget.minPair.y - widget.minPair.y * 0.7,
        maxY: loaded
            ? widget.maxPair.y
            : widget.maxPair.y + widget.maxPair.y * 0.7,
        maxX: loaded
            ? widget.maxPair.x + 1
            : widget.maxPair.x - widget.maxPair.x * 0.7,
        // axisTitleData: axisTitleData,
        titlesData: titlesData,
        extraLinesData: extraLinesData,
        // clipData: FlClipData.all(),
      );

  ExtraLinesData get extraLinesData => ExtraLinesData(
        horizontalLines: [
          ...(((widget.minPair.y > 0 && widget.maxPair.y > 0) ||
                  (widget.minPair.y < 0 && widget.maxPair.y < 0))
              ? []
              : [
                  HorizontalLine(
                    strokeWidth: 2,
                    y: 0,
                    color: dynamicPastel(context, widget.color, amount: 0.3)
                        .withOpacity(0.4),
                  ),
                ]),
          HorizontalLine(
            y: 0.0001,
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
        verticalLines: [
          VerticalLine(
            x: 0.0001,
            dashArray: [2, 5],
            strokeWidth: 2,
            color: dynamicPastel(context, widget.color, amount: 0.3)
                .withOpacity(0.2),
          ),
          ...(widget.verticalLineAt != null
              ? [
                  VerticalLine(
                    x: widget.maxPair.x - widget.verticalLineAt!,
                    dashArray: [2, 2],
                    strokeWidth: 2,
                    color: dynamicPastel(context, widget.color, amount: 0.3)
                        .withOpacity(0.7),
                  )
                ]
              : [])
        ],
      );

  FlTitlesData get titlesData => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          axisNameSize: 25,
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, titleMeta) {
              if (value == widget.maxPair.x + 1) {
                return SizedBox.shrink();
              }
              DateTime currentDate =
                  widget.endDate == null ? DateTime.now() : widget.endDate!;
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextFont(
                  textAlign: TextAlign.center,
                  fontSize: 13,
                  text: getWordedDateShort(
                    DateTime(
                      currentDate.year,
                      currentDate.month,
                      currentDate.day -
                          widget.maxPair.x.toInt() +
                          value.toInt(),
                    ),
                    showTodayTomorrow: false,
                  ),
                  textColor: dynamicPastel(context, widget.color,
                          amount: 0.8, inverse: true)
                      .withOpacity(0.5),
                ),
              );
            },
            reservedSize: 28,
            interval: widget.maxPair.x / (getIsFullScreen(context) ? 6 : 4),
          ),
        ),
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
              } else if (value < widget.maxPair.y && value > 1) {
                show = true;
              } else if (value > widget.minPair.y && value < 1) {
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
            reservedSize: (widget.minPair.y <= -10000
                    ? 55
                    : widget.minPair.y <= -1000
                        ? 45
                        : widget.minPair.y <= -100
                            ? 40
                            : (widget.maxPair.y >= 100
                                    ? (widget.maxPair.y >= 1000 ? 37 : 33)
                                    : 25) +
                                extraHorizontalPadding) +
                10,
            // This interval needs more work
            // interval: ((((widget.maxPair.y).abs() + (widget.minPair.y).abs()) /
            //                 (getIsFullScreen(context) ? 7 : 3.6)) /
            //             5)
            //         .ceil() *
            //     5,
          ),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  // FlAxisTitleData get axisTitleData => FlAxisTitleData(
  //       bottomTitle: AxisTitle(
  //         showTitle: false,
  //         titleText: "Monthly Spending",
  //         margin: 10,
  //         textStyle: TextStyle(
  //           fontSize: 15,
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //     );

  LineTouchData get lineTouchData => LineTouchData(
        enabled: true,
        touchSpotThreshold: 1000,
        getTouchedSpotIndicator:
            (LineChartBarData barData, List<int> spotIndexes) {
          // only show touch data for primary colored lines
          bool transparent = false;
          if (barData.color != lightenPastel(widget.color, amount: 0.3)) {
            transparent = true;
          }
          return spotIndexes.map((index) {
            return TouchedSpotIndicatorData(
              FlLine(
                color: transparent
                    ? Colors.transparent
                    : widget.color.withOpacity(0.9),
                strokeWidth: 2,
                dashArray: [2, 2],
              ),
              FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                  radius: 3,
                  color: transparent
                      ? Colors.transparent
                      : widget.color.withOpacity(0.9),
                  strokeWidth: 2,
                  strokeColor: transparent
                      ? Colors.transparent
                      : widget.color.withOpacity(0.9),
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
            return lineBarsSpot.map((LineBarSpot lineBarSpot) {
              // only show touch data for primary colored lines
              if (lineBarSpot.bar.color !=
                  lightenPastel(widget.color, amount: 0.3)) {
                return null;
              }
              DateTime currentDate =
                  widget.endDate == null ? DateTime.now() : widget.endDate!;
              return LineTooltipItem(
                getWordedDateShort(
                      DateTime(
                        currentDate.year,
                        currentDate.month,
                        currentDate.day -
                            widget.maxPair.x.toInt() +
                            lineBarSpot.x.toInt(),
                      ),
                    ) +
                    "\n" +
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
      );

  List<LineChartBarData> get lineBarsData => [
        for (int spotsListIndex = 0;
            spotsListIndex < widget.spots.length;
            spotsListIndex++)
          lineChartBarData(widget.spots[spotsListIndex], spotsListIndex),
      ];

  FlGridData get gridData => FlGridData(
        show: true,
        verticalInterval:
            ((widget.maxPair.x).abs() + (widget.minPair.x).abs()) /
                (getIsFullScreen(context) ? 6 : 4),
        // This interval needs more work, maybe follow the one from budgetHistoryLineGraph.dart
        // horizontalInterval:
        //     ((widget.maxPair.y).abs() + (widget.minPair.y).abs()) /
        //         (getIsFullScreen(context) ? 6 : 3.5),
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: dynamicPastel(context, widget.color, amount: 0.3)
                .withOpacity(0.2),
            strokeWidth: 2,
            dashArray: [2, 8],
          );
        },
        getDrawingVerticalLine: (value) {
          // print((widget.maxPair.y) /
          //     ((widget.maxPair.y).abs() + (widget.minPair.y).abs()));
          // print(((widget.minPair.y)) /
          //     ((widget.maxPair.y).abs() + (widget.minPair.y).abs()));
          return FlLine(
            color: dynamicPastel(context, widget.color, amount: 0.3)
                .withOpacity(0.2),
            // color: Colors.transparent,
            strokeWidth: 2,
            dashArray: [2, 8],
          );
        },
      );

  FlBorderData get borderData => FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: Colors.transparent),
          // left: BorderSide(color: widget.color.withAlpha(200), width: 3),
          right: BorderSide(color: Colors.transparent),
          top: BorderSide(color: Colors.transparent),
        ),
      );

  LineChartBarData lineChartBarData(List<FlSpot> spots, int index) {
    return LineChartBarData(
      color: widget.colors.length > 0
          ? lightenPastel(widget.colors[index], amount: 0.3)
          : lightenPastel(widget.color, amount: 0.3),
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false),
      isCurved: widget.isCurved,
      curveSmoothness:
          appStateSettings["removeZeroTransactionEntries"] ? 0.1 : 0.3,
      preventCurveOverShooting: true,
      preventCurveOvershootingThreshold: 8,
      aboveBarData: BarAreaData(
        applyCutOffY: true,
        cutOffY: 0,
        show: index != 0 ? false : true,
        gradient: LinearGradient(
          colors: [
            index == 0
                ? widget.color.withAlpha(100)
                : widget.color.withAlpha(0),
            widget.color.withAlpha(0),
          ],
          begin: Alignment.bottomCenter,
          end: Alignment(
              0,
              (widget.minPair.y) /
                  ((widget.maxPair.y).abs() + (widget.minPair.y).abs())),
        ),
        // gradientFrom: Offset(
        //     0,
        //     ((widget.maxPair.y).abs()) /
        //         ((widget.maxPair.y).abs() + (widget.minPair.y).abs())),
      ),
      belowBarData: BarAreaData(
        applyCutOffY: true,
        cutOffY: 0,
        show: true,
        gradient: LinearGradient(
          colors: [
            index == 0
                ? widget.color.withAlpha(100)
                : widget.color.withAlpha(0),
            widget.color.withAlpha(0),
          ],
          begin: Alignment.topCenter,
          end: Alignment(
              0,
              (widget.maxPair.y) /
                  ((widget.maxPair.y).abs() + (widget.minPair.y).abs())),
        ),
        // gradientTo: Offset(
        //     0,
        //     ((widget.maxPair.y).abs()) /
        //         ((widget.maxPair.y).abs() + (widget.minPair.y).abs())),
      ),
      spots: spots,
    );
  }
}

class Pair {
  Pair(this.x, this.y);

  double x;
  double y;
}

class LineChartWrapper extends StatelessWidget {
  const LineChartWrapper({
    required this.points,
    this.isCurved = false,
    this.color,
    this.endDate,
    this.verticalLineAt,
    this.horizontalLineAt,
    this.enableTouch = true,
    this.colors = const [],
    Key? key,
  }) : super(key: key);

  final List<List<Pair>> points;
  final bool isCurved;
  final Color? color;
  final DateTime? endDate;
  final double? verticalLineAt;
  final double? horizontalLineAt;
  final bool enableTouch;
  final List<Color> colors;

  List<List<Pair>> filterPointsList(List<List<Pair>> pointsList) {
    List<List<Pair>> pointsOut = [];
    for (List<Pair> points in pointsList) {
      pointsOut.add(filterPoints(points));
    }
    return pointsOut;
  }

  List<Pair> filterPoints(List<Pair> points) {
    List<Pair> pointsOut = [];
    if (appStateSettings["removeZeroTransactionEntries"] &&
        !appStateSettings["showCumulativeSpending"]) {
      for (Pair point in points) {
        if (point.y != 0) {
          pointsOut.add(Pair(point.x, point.y));
        }
      }
      if (pointsOut.length <= 0) {
        return [Pair(0, 0)];
      }
      pointsOut.last.x != points.last.x
          ? pointsOut.add(Pair(points.last.x, 0))
          : 0;
      return pointsOut;
    }
    if (appStateSettings["removeZeroTransactionEntries"] &&
        appStateSettings["showCumulativeSpending"]) {
      pointsOut.add(Pair(points.first.x, points.first.y));
      double previousTotal = 0;
      for (Pair point in points) {
        if (previousTotal != point.y) {
          pointsOut.add(Pair(point.x, point.y));
        }
        previousTotal = point.y;
      }
      if (pointsOut.length <= 0) {
        return [Pair(0, 0)];
      }
      pointsOut.last.x != points.last.x
          ? pointsOut.add(Pair(points.last.x, points.last.y))
          : 0;
      return pointsOut;
    }
    return points;
  }

  List<List<FlSpot>> convertPoints(List<List<Pair>> pointsList) {
    List<List<FlSpot>> pointsOut = [];
    for (List<Pair> points in pointsList) {
      List<FlSpot> pointsOutCurrent = [];
      for (Pair pair in points) {
        pointsOutCurrent.add(FlSpot(pair.x, pair.y));
      }
      pointsOut.add(pointsOutCurrent);
    }
    return pointsOut;
  }

  Pair getMaxPoint(List<List<Pair>> pointsList) {
    Pair max = Pair(1, 1);
    for (List<Pair> points in pointsList) {
      for (Pair pair in points) {
        if (pair.x > max.x) {
          max.x = pair.x;
        }
        if (pair.y > max.y) {
          max.y = pair.y;
        }
      }
    }
    return max;
  }

  Pair getMinPoint(List<List<Pair>> pointsList) {
    Pair min = Pair(0, 0);
    for (List<Pair> points in pointsList) {
      if (points.length <= 0 && min.x == 0 && min.y == 0) {
        min = Pair(1, 1);
      }
      for (Pair pair in points) {
        if (pair.x < min.x) {
          min.x = pair.x;
        }
        if (pair.y < min.y) {
          min.y = pair.y;
        }
      }
    }
    return min;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Container(
        height: kIsWeb && MediaQuery.of(context).size.width > 700 ? 300 : 175,
        child: _LineChart(
          spots: convertPoints(filterPointsList(points)),
          maxPair: getMaxPoint(points),
          minPair: getMinPoint(points),
          color: color == null ? Theme.of(context).colorScheme.primary : color!,
          isCurved: isCurved,
          endDate: endDate,
          verticalLineAt: verticalLineAt,
          horizontalLineAt: horizontalLineAt,
          enableTouch: enableTouch,
          colors: colors,
        ),
      ),
    );
  }
}
