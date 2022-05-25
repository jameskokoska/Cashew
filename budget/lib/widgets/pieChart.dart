import 'dart:math';

import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class CategoryTotal {
  CategoryTotal(
    this.categoryPk,
    this.total,
  );

  int categoryPk;
  double total;
}

class CategoryTotalDetailed {
  CategoryTotalDetailed(this.categoryPk, this.total, this.categoryDetails);

  int categoryPk;
  double total;
  TransactionCategory categoryDetails;
}

Future<List<CategoryTotalDetailed>> getCategoryDetails(
    List<CategoryTotal> data) async {
  List<CategoryTotalDetailed> output = [];
  for (CategoryTotal element in data) {
    output.add(
      CategoryTotalDetailed(
        element.categoryPk,
        element.total,
        await database.getCategoryInstance(element.categoryPk),
      ),
    );
  }
  return output;
}

class PieChartWrapper extends StatelessWidget {
  const PieChartWrapper(
      {Key? key, required this.data, required this.totalSpent})
      : super(key: key);
  final List<CategoryWithTotal> data;
  final double totalSpent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      child: Stack(
        children: [
          PieChartDisplay(
            data: data,
            totalSpent: totalSpent,
          ),
          IgnorePointer(
            child: Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                    shape: BoxShape.circle),
              ),
            ),
          ),
          IgnorePointer(
            child: Center(
              child: Container(
                width: 105,
                height: 105,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PieChartDisplay extends StatefulWidget {
  PieChartDisplay({Key? key, required this.data, required this.totalSpent})
      : super(key: key);
  final List<CategoryWithTotal> data;
  final double totalSpent;

  @override
  State<StatefulWidget> createState() => PieChartDisplayState();
}

class PieChartDisplayState extends State<PieChartDisplay> {
  int touchedIndex = -1;
  bool scaleIn = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 0), () {
      setState(() {
        scaleIn = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: scaleIn ? 1 : 0,
      duration: Duration(milliseconds: 2500),
      curve: ElasticOutCurve(0.8),
      child: PieChart(
        PieChartData(
          pieTouchData: PieTouchData(
              touchCallback: (FlTouchEvent event, pieTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  pieTouchResponse == null ||
                  pieTouchResponse.touchedSection == null) {
                return;
              }
              if (event.runtimeType == FlTapDownEvent &&
                  touchedIndex !=
                      pieTouchResponse.touchedSection!.touchedSectionIndex) {
                touchedIndex =
                    pieTouchResponse.touchedSection!.touchedSectionIndex;
              } else if (event.runtimeType == FlTapDownEvent) {
                touchedIndex = -1;
              }
            });
          }),
          borderData: FlBorderData(
            show: false,
          ),
          sectionsSpace: 0,
          centerSpaceRadius: 0,
          sections: showingSections(),
        ),
        swapAnimationDuration: Duration(milliseconds: 200),
        swapAnimationCurve: Curves.decelerate,
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(widget.data.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 20.0 : 16.0;
      final radius = isTouched ? 110.0 : 100.0;
      final widgetScale = isTouched ? 1.4 : 1.0;
      return PieChartSectionData(
        color: dynamicPastel(context, HexColor(widget.data[i].category.colour),
            amountLight: 0.3, amountDark: 0.1),
        value: widget.data[i].total / widget.totalSpent,
        title: "",
        radius: radius,
        badgeWidget: _Badge(
          scale: widgetScale,
          borderColor:
              HexColor(widget.data[i].category.colour).withOpacity(0.8),
          assetImage: AssetImage(
            "assets/categories/" + (widget.data[i].category.iconName ?? ""),
          ),
          percent: (widget.data[i].total / widget.totalSpent * 100)
                  .toStringAsFixed(0) +
              '%',
        ),
        titlePositionPercentageOffset: 1.4,
        badgePositionPercentageOffset: .98,
      );
    });
  }
}

class _Badge extends StatelessWidget {
  final double scale;
  final Color borderColor;
  final AssetImage assetImage;
  final String percent;

  const _Badge({
    Key? key,
    required this.scale,
    required this.borderColor,
    required this.assetImage,
    required this.percent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      curve: Curves.decelerate,
      duration: Duration(milliseconds: 200),
      scale: scale,
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor,
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Image(
                image: assetImage,
                width: 25,
              ),
            ),
            AnimatedOpacity(
              duration: Duration(milliseconds: 200),
              opacity: this.scale == 1 ? 0 : 1,
              child: Center(
                child: Transform.translate(
                  offset: Offset(0, 32),
                  child: TextFont(
                    text: percent,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    shadow: true,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
