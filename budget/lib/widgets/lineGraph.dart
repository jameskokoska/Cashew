import 'dart:developer';
import 'package:budget/functions.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:budget/colors.dart';
import 'package:intl/intl.dart';
import 'package:mrx_charts/mrx_charts.dart';

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
        minY: (widget.maxPair.y > 0 && widget.minPair.y > 0) ||
                (widget.maxPair.y < 0 && widget.minPair.y < 0)
            ? 0
            : widget.minPair.y,
        maxY: widget.maxPair.y,
        maxX: widget.maxPair.x + 1,
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
                ])
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
            interval: widget.maxPair.x / 4,
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
            interval:
                ((((widget.maxPair.y).abs() + (widget.minPair.y).abs()) / 3.6) /
                            5)
                        .ceil() *
                    5,
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

  LineChartBarData get lineChartBarData => LineChartBarData(
        color: lightenPastel(widget.color, amount: 0.3),
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
        curveSmoothness: 0.2,
        preventCurveOverShooting: true,
        preventCurveOvershootingThreshold: 10,
        aboveBarData: BarAreaData(
          applyCutOffY: true,
          cutOffY: 0,
          show: true,
          gradient: LinearGradient(
            colors: [
              widget.color.withAlpha(100),
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
              widget.color.withAlpha(100),
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
    // if (kIsWeb) {
    //   return Container(
    //     height: 175,
    //     child: LinePage(
    //       spots: points,
    //       maxPair: getMaxPoint(points),
    //       minPair: getMinPoint(points),
    //       color: color == null ? Theme.of(context).colorScheme.primary : color!,
    //       endDate: endDate,
    //       verticalLineAt: verticalLineAt,
    //     ),
    //   );
    // }
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

class LinePage extends StatefulWidget {
  const LinePage({
    Key? key,
    required this.spots,
    required this.maxPair,
    required this.minPair,
    required this.color,
    required this.endDate,
    required this.verticalLineAt,
  }) : super(key: key);
  final List<Pair> spots;
  final Pair maxPair;
  final Pair minPair;
  final Color color;
  final DateTime? endDate;
  final double? verticalLineAt;
  @override
  State<LinePage> createState() => _LinePageState();
}

class _LinePageState extends State<LinePage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.only(
          left: 10,
          right: 10,
          bottom: 5,
        ),
        child: Chart(
          layers: layers(),
          duration: Duration(milliseconds: 1500),
          padding: EdgeInsets.only(bottom: 5),
        ),
      ),
    );
  }

  List<ChartLayer> layers() {
    final double minYToKeep = (widget.maxPair.y > 0 && widget.minPair.y > 0) ||
            (widget.maxPair.y < 0 && widget.minPair.y < 0)
        ? 0
        : widget.minPair.y;
    return [
      ...(widget.verticalLineAt != null
          ? [
              ChartLineLayer(
                items: List.generate(
                  2,
                  (index) => ChartLineDataItem(
                    x: widget.maxPair.x - widget.verticalLineAt!,
                    value: index == 0 ? minYToKeep : widget.maxPair.y,
                  ),
                ),
                settings: ChartLineSettings(
                  color: dynamicPastel(context, widget.color, amount: 0.3)
                      .withOpacity(0.6),
                  thickness: 2.0,
                ),
              ),
            ]
          : []),
      ChartLineLayer(
        items: List.generate(
          2,
          (index) => ChartLineDataItem(
            x: index * widget.maxPair.x,
            value: 0,
          ),
        ),
        settings: ChartLineSettings(
          color: dynamicPastel(context, widget.color, amount: 0.3)
              .withOpacity(0.6),
          thickness: 2.0,
        ),
      ),
      ChartGridLayer(
        settings: ChartGridSettings(
          x: ChartGridSettingsAxis(
            color: dynamicPastel(context, widget.color, amount: 0.5)
                .withOpacity(0.4),
            frequency: (widget.maxPair.x - widget.minPair.x) / 4,
            max: widget.maxPair.x,
            min: widget.minPair.x,
          ),
          y: ChartGridSettingsAxis(
            color: dynamicPastel(context, widget.color, amount: 0.5)
                .withOpacity(0.4),
            frequency: (widget.maxPair.y - minYToKeep) / 3,
            max: widget.maxPair.y,
            min: minYToKeep,
          ),
        ),
      ),
      ChartAxisLayer(
        settings: ChartAxisSettings(
          x: ChartAxisSettingsAxis(
            frequency: (widget.maxPair.x - widget.minPair.x) / 4,
            max: widget.maxPair.x,
            min: widget.minPair.x,
            textStyle: TextStyle(
              color: dynamicPastel(context, widget.color,
                      amount: 0.5, inverse: true)
                  .withOpacity(0.3),
              fontSize: 13,
              fontFamily: 'Avenir',
            ),
          ),
          y: ChartAxisSettingsAxis(
            frequency: (widget.maxPair.y - minYToKeep) / 3,
            max: widget.maxPair.y,
            min: minYToKeep,
            textStyle: TextStyle(
              color: dynamicPastel(context, widget.color,
                      amount: 0.5, inverse: true)
                  .withOpacity(0.3),
              fontSize: 13,
              fontFamily: 'Avenir',
            ),
          ),
        ),
        labelX: (value) {
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
        labelY: (value) {
          return (value == 1 ? getWordedNumber(0.0) : getWordedNumber(value));
        },
      ),
      ChartLineLayer(
        items: List.generate(
          widget.spots.length,
          (index) => ChartLineDataItem(
            x: widget.spots[index].x,
            value: widget.spots[index].y,
          ),
        ),
        settings: ChartLineSettings(
          color: dynamicPastel(context, widget.color, amount: 0.2),
          thickness: 3.0,
        ),
      ),
    ];
  }
}
