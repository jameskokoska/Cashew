import 'dart:developer';
import 'dart:math';

import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/main.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/pinWheelReveal.dart';
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
      {Key? key,
      required this.data,
      required this.totalSpent,
      required this.setSelectedCategory,
      required this.isPastBudget,
      required this.pieChartDisplayStateKey})
      : super(key: key);
  final List<CategoryWithTotal> data;
  final double totalSpent;
  final Function(int, TransactionCategory?) setSelectedCategory;
  final bool isPastBudget;
  final pieChartDisplayStateKey;

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
            setSelectedCategory: setSelectedCategory,
            key: pieChartDisplayStateKey,
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
          IgnorePointer(
            child: Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    shape: BoxShape.circle),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

GlobalKey<PieChartDisplayState> pieChartDisplayStatePastBudgetKey = GlobalKey();

class PieChartDisplay extends StatefulWidget {
  PieChartDisplay(
      {Key? key,
      required this.data,
      required this.totalSpent,
      required this.setSelectedCategory})
      : super(key: key);
  final List<CategoryWithTotal> data;
  final double totalSpent;
  final Function(int, TransactionCategory?) setSelectedCategory;

  @override
  State<StatefulWidget> createState() => PieChartDisplayState();
}

class PieChartDisplayState extends State<PieChartDisplay> {
  int touchedIndex = -1;
  bool scaleIn = false;
  int showLabels = 0;
  @override
  void initState() {
    super.initState();
    if (!appStateSettings["batterySaver"]) {
      Future.delayed(Duration(milliseconds: 0), () {
        setState(() {
          scaleIn = true;
        });
      });
    }
    Future.delayed(Duration(milliseconds: 500), () async {
      for (int i = 1; i <= widget.data.length; i++) {
        await Future.delayed(const Duration(milliseconds: 70));
        setState(() {
          showLabels = showLabels + 1;
        });
      }
    });
  }

  void setTouchedIndex(index) {
    setState(() {
      touchedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PinWheelReveal(
      delay: Duration(milliseconds: 0),
      duration: Duration(milliseconds: 850),
      child: PieChart(
        PieChartData(
          startDegreeOffset: -45,
          pieTouchData: PieTouchData(
              touchCallback: (FlTouchEvent event, pieTouchResponse) {
            // print(event.runtimeType);
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
                widget.setSelectedCategory(
                    widget.data[touchedIndex].category.categoryPk,
                    widget.data[touchedIndex].category);
              } else if (event.runtimeType == FlTapDownEvent) {
                touchedIndex = -1;
                widget.setSelectedCategory(-1, null);
              } else if (event.runtimeType == FlLongPressMoveUpdate) {
                touchedIndex =
                    pieTouchResponse.touchedSection!.touchedSectionIndex;
                widget.setSelectedCategory(
                    widget.data[touchedIndex].category.categoryPk,
                    widget.data[touchedIndex].category);
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
        swapAnimationDuration: Duration(milliseconds: 1300),
        swapAnimationCurve: ElasticOutCurve(0.6),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(widget.data.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 20.0 : 16.0;
      final radius = isTouched ? 106.0 : 100.0;
      final widgetScale = isTouched ? 1.3 : 1.0;
      return PieChartSectionData(
        color: dynamicPastel(
            context,
            HexColor(widget.data[i].category.colour,
                defaultColor: Theme.of(context).colorScheme.primary),
            amountLight: 0.3,
            amountDark: 0.1),
        value: (widget.data[i].total / widget.totalSpent).abs(),
        title: "",
        radius: radius,
        badgeWidget: _Badge(
          showLabels: i < showLabels,
          scale: widgetScale,
          color: dynamicPastel(
              context,
              HexColor(widget.data[i].category.colour,
                  defaultColor: Theme.of(context).colorScheme.primary),
              amountLight: 0.3,
              amountDark: 0.1),
          assetImage: AssetImage(
            "assets/categories/" + (widget.data[i].category.iconName ?? ""),
          ),
          percent: (widget.data[i].total / widget.totalSpent * 100).abs(),
          isTouched: isTouched,
        ),
        titlePositionPercentageOffset: 1.4,
        badgePositionPercentageOffset: .98,
      );
    });
  }
}

class _Badge extends StatelessWidget {
  final double scale;
  final Color color;
  final AssetImage assetImage;
  final double percent;
  final bool isTouched;
  final bool showLabels;

  const _Badge({
    Key? key,
    required this.scale,
    required this.color,
    required this.assetImage,
    required this.percent,
    required this.isTouched,
    required this.showLabels,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      curve:
          percent < 5 ? Curves.easeInOutCubicEmphasized : ElasticOutCurve(0.6),
      duration: percent < 5
          ? Duration(milliseconds: 700)
          : Duration(milliseconds: 1300),
      scale: percent < 5 && isTouched == false
          ? 0
          : (showLabels ? (percent < 5 ? 1 : scale) : 0),
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: color,
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            AnimatedOpacity(
              duration: Duration(milliseconds: 200),
              opacity: this.scale == 1 ? 0 : 1,
              child: Center(
                child: Transform.translate(
                  offset: Offset(0, 34),
                  child: IntrinsicWidth(
                    child: Container(
                      height: 20,
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: color,
                          width: 1.5,
                        ),
                        color: Theme.of(context).colorScheme.background,
                      ),
                      child: Center(
                        child: TextFont(
                          text: percent.toStringAsFixed(0) + '%',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.lightDarkAccent),
              child: Center(
                child: Image(
                  image: assetImage,
                  width: 23,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
