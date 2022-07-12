import 'package:budget/functions.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:budget/colors.dart';
import 'package:intl/intl.dart';

class _LineChart extends StatefulWidget {
  _LineChart({
    required this.spots,
    required this.maxPair,
    required this.minPair,
    required this.color,
    this.isCurved = false,
    this.endDate,
    this.verticalLineAt,
    Key? key,
  }) : super(key: key);

  final List<FlSpot> spots;
  final Pair maxPair;
  final Pair minPair;
  final Color color;
  final bool isCurved;
  final DateTime? endDate;
  final double? verticalLineAt;

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

  getMaxPoint(spots) {}

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          right: 10 + extraHorizontalPadding, top: 8, bottom: 0),
      child: LineChart(
        data,
        swapAnimationDuration: const Duration(milliseconds: 2500),
        swapAnimationCurve: Curves.easeInOutCubic,
      ),
    );
  }

  LineChartData get data => LineChartData(
        lineTouchData: lineTouchData,
        gridData: gridData,
        borderData: borderData,
        lineBarsData: lineBarsData,
        minX: 0,
        minY: widget.minPair.y,
        maxY: widget.maxPair.y,
        maxX: widget.maxPair.x + 1,
        // axisTitleData: axisTitleData,
        titlesData: titlesData,
        extraLinesData: extraLinesData,
        // clipData: FlClipData.all(),
      );

  ExtraLinesData get extraLinesData => ExtraLinesData(
        horizontalLines: [
          HorizontalLine(
            y: 0,
            color: dynamicPastel(context, widget.color, amount: 0.3)
                .withOpacity(0.4),
          ),
        ],
        verticalLines: [
          VerticalLine(
            x: 0,
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
        bottomTitles: SideTitles(
          showTitles: true,
          getTextStyles: (_, __) {
            return TextStyle(
                color: dynamicPastel(context, widget.color,
                        amount: 0.8, inverse: true)
                    .withOpacity(0.5),
                fontFamily: 'Avenir');
          },
          getTitles: (value) {
            DateTime currentDate =
                widget.endDate == null ? DateTime.now() : widget.endDate!;
            return getWordedDateShort(
              DateTime(
                currentDate.year,
                currentDate.month,
                currentDate.day - widget.maxPair.x.toInt() + value.toInt(),
              ),
              showTodayTomorrow: false,
            );
          },
          interval: widget.maxPair.x / 4,
          margin: 13,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          getTextStyles: (_, __) {
            return TextStyle(
                color: dynamicPastel(context, widget.color,
                        amount: 0.5, inverse: true)
                    .withOpacity(0.3),
                fontFamily: 'Avenir');
          },
          getTitles: (value) {
            return getWordedNumber(value);
          },
          reservedSize: widget.minPair.y <= -10000
              ? 55
              : widget.minPair.y <= -1000
                  ? 45
                  : widget.minPair.y <= -100
                      ? 40
                      : (widget.maxPair.y >= 100
                              ? (widget.maxPair.y >= 1000 ? 37 : 33)
                              : 25) +
                          extraHorizontalPadding,
          interval:
              ((((widget.maxPair.y).abs() + (widget.minPair.y).abs()) / 3.6) /
                          5)
                      .ceil() *
                  5,
          margin: 10,
          checkToShowTitle:
              (minValue, maxValue, sideTitles, appliedInterval, value) {
            if (value == 0) {
              return true;
            } else if (value % appliedInterval != 0) {
              return false;
            } else if (value < widget.maxPair.y && value > 1) {
              return true;
            } else if (value > widget.minPair.y && value < 1) {
              return true;
            } else {
              return false;
            }
          },
        ),
        topTitles: SideTitles(
          showTitles: false,
        ),
        rightTitles: SideTitles(
          showTitles: false,
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
        handleBuiltInTouches: false,
      );

  List<LineChartBarData> get lineBarsData => [
        lineChartBarData,
      ];

  FlGridData get gridData => FlGridData(
        show: true,
        verticalInterval:
            ((widget.maxPair.x).abs() + (widget.minPair.x).abs()) / 4,
        horizontalInterval:
            ((widget.maxPair.y).abs() + (widget.minPair.y).abs()) / 3.5,
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

  LineChartBarData get lineChartBarData => LineChartBarData(
        colors: [lightenPastel(widget.color, amount: 0.3)],
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: false,
          getDotPainter: (spot, percent, barData, index) {
            return FlDotCirclePainter(
              radius: 2,
              color: Colors.blue,
              strokeWidth: 0,
            );
          },
        ),
        isCurved: widget.isCurved,
        curveSmoothness: 0.83,
        preventCurveOverShooting: true,
        preventCurveOvershootingThreshold: 0,
        aboveBarData: BarAreaData(
          applyCutOffY: true,
          cutOffY: 0,
          show: true,
          colors: [
            widget.color.withAlpha(0),
            widget.color.withAlpha(100),
          ],
          gradientColorStops: [0, 1],
          gradientFrom: Offset(
              0,
              ((widget.maxPair.y).abs()) /
                  ((widget.maxPair.y).abs() + (widget.minPair.y).abs())),
          gradientTo: const Offset(0, 1),
        ),
        belowBarData: BarAreaData(
          applyCutOffY: true,
          cutOffY: 0,
          show: true,
          colors: [
            widget.color.withAlpha(100),
            widget.color.withAlpha(0),
          ],
          gradientColorStops: [0, 1],
          gradientFrom: const Offset(0, 0),
          gradientTo: Offset(
              0,
              ((widget.maxPair.y).abs()) /
                  ((widget.maxPair.y).abs() + (widget.minPair.y).abs())),
        ),
        spots: loaded ? widget.spots : [],
      );
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
    Key? key,
  }) : super(key: key);

  final List<Pair> points;
  final bool isCurved;
  final Color? color;
  final DateTime? endDate;
  final double? verticalLineAt;

  List<FlSpot> convertPoints(points) {
    List<FlSpot> pointsOut = [];
    for (Pair pair in points) {
      pointsOut.add(FlSpot(pair.x, pair.y));
    }
    return pointsOut;
  }

  Pair getMaxPoint(points) {
    Pair max = Pair(1, 1);
    for (Pair pair in points) {
      if (pair.x > max.x) {
        max.x = pair.x;
      }
      if (pair.y > max.y) {
        max.y = pair.y;
      }
    }
    return max;
  }

  Pair getMinPoint(points) {
    if (points.length <= 0) {
      return Pair(1, 1);
    }
    Pair min = Pair(points[0].x, points[0].y);
    for (Pair pair in points) {
      if (pair.x < min.x) {
        min.x = pair.x;
      }
      if (pair.y < min.y) {
        min.y = pair.y;
      }
    }
    return min;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 175,
      child: _LineChart(
        spots: convertPoints(points),
        maxPair: getMaxPoint(points),
        minPair: getMinPoint(points),
        color: color == null ? Theme.of(context).colorScheme.primary : color!,
        isCurved: isCurved,
        endDate: endDate,
        verticalLineAt: verticalLineAt,
      ),
    );
  }
}
