import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/categoryIcon.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/pinWheelReveal.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CategoryTotal {
  CategoryTotal(
    this.categoryPk,
    this.total,
  );

  String categoryPk;
  double total;
}

class CategoryTotalDetailed {
  CategoryTotalDetailed(this.categoryPk, this.total, this.categoryDetails);

  String categoryPk;
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
  const PieChartWrapper({
    Key? key,
    required this.data,
    required this.totalSpent,
    required this.setSelectedCategory,
    required this.isPastBudget,
    required this.pieChartDisplayStateKey,
    this.middleColor,
  }) : super(key: key);
  final List<CategoryWithTotal> data;
  final double totalSpent;
  final Function(String categoryPk, TransactionCategory? category)
      setSelectedCategory;
  final bool isPastBudget;
  final GlobalKey<PieChartDisplayState>? pieChartDisplayStateKey;
  final Color? middleColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: enableDoubleColumn(context) == false ? 200 : 300,
      height: enableDoubleColumn(context) == false ? 200 : 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChartDisplay(
            data: data,
            totalSpent: totalSpent,
            setSelectedCategory: setSelectedCategory,
            key: pieChartDisplayStateKey,
          ),
          data.length <= 0
              ? SizedBox.shrink()
              : IgnorePointer(
                  child: Center(
                    child: Container(
                      width: enableDoubleColumn(context) == false ? 105 : 130,
                      height: enableDoubleColumn(context) == false ? 105 : 130,
                      decoration: BoxDecoration(
                        color: middleColor?.withOpacity(0.2) ??
                            getColor(context, "white").withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
          data.length <= 0
              ? SizedBox.shrink()
              : IgnorePointer(
                  child: Center(
                    child: Container(
                      width: enableDoubleColumn(context) == false ? 80 : 110,
                      height: enableDoubleColumn(context) == false ? 80 : 110,
                      decoration: BoxDecoration(
                          color: middleColor ?? Theme.of(context).canvasColor,
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
  final Function(String categoryPk, TransactionCategory? category)
      setSelectedCategory;

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
        if (mounted)
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
    if (widget.data.length <= 0) return SizedBox.shrink();
    int numberZeroTransactions = 0;
    for (CategoryWithTotal categoryWithTotal in widget.data) {
      if (categoryWithTotal.total == 0) numberZeroTransactions++;
    }
    if (numberZeroTransactions == widget.data.length) return SizedBox.shrink();
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
                widget.setSelectedCategory("-1", null);
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
      final radius = enableDoubleColumn(context) == false
          ? isTouched
              ? 106.0
              : 100.0
          : isTouched
              ? 146.0
              : 136.0;
      final widgetScale = isTouched ? 1.3 : 1.0;
      return PieChartSectionData(
        color: dynamicPastel(
            context,
            HexColor(widget.data[i].category.colour,
                defaultColor: Theme.of(context).colorScheme.primary),
            amountLight: 0.3,
            amountDark: 0.1),
        value: widget.totalSpent == 0
            ? 0
            : (widget.data[i].total / widget.totalSpent).abs(),
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
          iconName: widget.data[i].category.iconName ?? "",
          categoryColor: HexColor(widget.data[i].category.colour),
          emojiIconName: widget.data[i].category.emojiIconName,
          percent: widget.totalSpent == 0
              ? 0
              : (widget.data[i].total / widget.totalSpent * 100).abs(),
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
  final String iconName;
  final String? emojiIconName;
  final double percent;
  final bool isTouched;
  final bool showLabels;
  final Color categoryColor;

  const _Badge({
    Key? key,
    required this.scale,
    required this.color,
    required this.iconName,
    required this.emojiIconName,
    required this.percent,
    required this.isTouched,
    required this.showLabels,
    required this.categoryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool showIcon = percent.abs() < 5;
    return AnimatedScale(
      curve: showIcon ? Curves.easeInOutCubicEmphasized : ElasticOutCurve(0.6),
      duration:
          showIcon ? Duration(milliseconds: 700) : Duration(milliseconds: 1300),
      scale: showIcon && isTouched == false
          ? 0
          : (showLabels || isTouched ? (showIcon ? 1 : scale) : 0),
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: color,
            width: 2.5,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
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
                        color: Theme.of(context).canvasColor,
                      ),
                      child: Center(
                        child: MediaQuery(
                          child: TextFont(
                            text: percent.toStringAsFixed(0) + '%',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            textAlign: TextAlign.center,
                          ),
                          data: MediaQuery.of(context)
                              .copyWith(textScaleFactor: 1.0),
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
                color: Theme.of(context).canvasColor,
              ),
              child: Center(
                // child: SimpleShadow(
                //   child: Image(
                //     image: assetImage,
                //     width: 23,
                //   ),
                //   opacity: 0.8,
                //   color: categoryColor,
                //   offset: Offset(0, 0),
                //   sigma: 1,
                // ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.light
                        ? categoryColor.withOpacity(0.5)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(8),
                  child: emojiIconName != null
                      ? Container()
                      : CacheCategoryIcon(
                          iconName: iconName,
                          size: 34,
                        ),
                ),
              ),
            ),
            emojiIconName != null
                ? EmojiIcon(
                    emojiIconName: emojiIconName,
                    size: 34 * 0.7,
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
