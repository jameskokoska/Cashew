import 'package:budget/database/tables.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/budgetPage.dart';
import 'package:animations/animations.dart';
import 'package:budget/pages/pastBudgetsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/categoryEntry.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sa3_liquid/sa3_liquid.dart';
import '../colors.dart';
import '../functions.dart';

class BudgetContainerUI extends StatelessWidget {
  const BudgetContainerUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class BudgetContainer extends StatelessWidget {
  BudgetContainer({
    Key? key,
    required this.budget,
    this.height = 183,
    this.smallBudgetContainer = false,
    this.showTodayForSmallBudget = true,
    this.dateForRange,
    this.isPastBudget = false,
    this.isPastBudgetButCurrentPeriod = false,
  }) : super(key: key);

  final Budget budget;
  final double height;
  final bool smallBudgetContainer;
  final bool showTodayForSmallBudget;
  final DateTime? dateForRange;
  final bool? isPastBudget;
  final bool? isPastBudgetButCurrentPeriod;

  @override
  Widget build(BuildContext context) {
    DateTime dateForRangeLocal =
        dateForRange == null ? DateTime.now() : dateForRange!;
    DateTimeRange budgetRange = getBudgetDate(budget, dateForRangeLocal);
    var widget = (StreamBuilder<List<CategoryWithTotal>>(
      stream: database.watchTotalSpentInEachCategoryInTimeRangeFromCategories(
        budgetRange.start,
        budgetRange.end,
        budget.categoryFks ?? [],
        budget.allCategoryFks,
      ),
      builder: (context, snapshot) {
        double smallContainerHeight = showTodayForSmallBudget ? 150 : 140;
        if (snapshot.hasData) {
          double totalSpent = 0;
          snapshot.data!.forEach((category) {
            totalSpent = totalSpent + category.total.abs();
            totalSpent = totalSpent.abs();
          });
          if (smallBudgetContainer) {
            return Container(
              height: smallContainerHeight,
              child: ClipRRect(
                clipBehavior: Clip.antiAlias,
                borderRadius: BorderRadius.circular(15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Stack(
                      children: [
                        Positioned.fill(
                          child: AnimatedGooBackground(
                            randomOffset: budgetRange.start.month +
                                budgetRange.start.day +
                                budgetRange.end.month +
                                budgetRange.end.day,
                            color: HexColor(budget.colour,
                                    defaultColor:
                                        Theme.of(context).colorScheme.primary)
                                .withOpacity(0.8),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 23, right: 23, bottom: 13, top: 13),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 25,
                                child: Center(
                                  child: TextFont(
                                    text: (budgetRange.end.year ==
                                            DateTime.now().year)
                                        ? (getWordedDateShortMore(
                                              budgetRange.start,
                                            ) +
                                            " - " +
                                            getWordedDateShortMore(
                                              budgetRange.end,
                                            ))
                                        : (getWordedDateShort(
                                              budgetRange.start,
                                              includeYear: true,
                                            ) +
                                            " - " +
                                            getWordedDateShort(
                                              budgetRange.end,
                                              includeYear: true,
                                            )),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    maxFontSize: 20,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    autoSizeText: true,
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              budget.amount - totalSpent >= 0
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          child: CountUp(
                                            count: appStateSettings[
                                                    "showTotalSpentForBudget"]
                                                ? totalSpent
                                                : budget.amount - totalSpent,
                                            prefix: getCurrencyString(),
                                            duration:
                                                Duration(milliseconds: 700),
                                            fontSize: 18,
                                            textAlign: TextAlign.left,
                                            fontWeight: FontWeight.bold,
                                            decimals:
                                                moneyDecimals(budget.amount),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 1.7),
                                          child: Container(
                                            child: TextFont(
                                              text: (appStateSettings[
                                                          "showTotalSpentForBudget"]
                                                      ? " spent of "
                                                      : " left of ") +
                                                  convertToMoney(budget.amount),
                                              fontSize: 14,
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          child: CountUp(
                                            count: appStateSettings[
                                                    "showTotalSpentForBudget"]
                                                ? totalSpent
                                                : -1 *
                                                    (budget.amount -
                                                        totalSpent),
                                            prefix: getCurrencyString(),
                                            duration:
                                                Duration(milliseconds: 700),
                                            fontSize: 18,
                                            textAlign: TextAlign.left,
                                            fontWeight: FontWeight.bold,
                                            decimals:
                                                moneyDecimals(budget.amount),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.only(
                                              bottom: 1.5),
                                          child: TextFont(
                                            text: (appStateSettings[
                                                        "showTotalSpentForBudget"]
                                                    ? " spent of "
                                                    : " overspent of ") +
                                                convertToMoney(budget.amount),
                                            fontSize: 13,
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                      ],
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: BudgetTimeline(
                          budget: budget,
                          percent: (totalSpent / budget.amount * 100).abs(),
                          todayPercent: showTodayForSmallBudget
                              ? getPercentBetweenDates(
                                  budgetRange, dateForRangeLocal)
                              : -1,
                          dateForRange: dateForRangeLocal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return Container(
            height: height,
            child: ClipRRect(
              clipBehavior: Clip.antiAlias,
              borderRadius: BorderRadius.circular(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Stack(
                    children: [
                      Positioned.fill(
                        child: AnimatedGooBackground(
                          randomOffset: budget.name.length,
                          color: HexColor(budget.colour,
                                  defaultColor:
                                      Theme.of(context).colorScheme.primary)
                              .withOpacity(0.8),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 23, right: 23, bottom: 13, top: 13),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              width: double.infinity,
                              child: TextFont(
                                text: budget.name,
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                                textAlign: TextAlign.left,
                              ),
                            ),
                            budget.amount - totalSpent >= 0
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        child: CountUp(
                                          count: appStateSettings[
                                                  "showTotalSpentForBudget"]
                                              ? totalSpent
                                              : budget.amount - totalSpent,
                                          prefix: getCurrencyString(),
                                          duration: Duration(milliseconds: 700),
                                          fontSize: 18,
                                          textAlign: TextAlign.left,
                                          fontWeight: FontWeight.bold,
                                          decimals:
                                              moneyDecimals(budget.amount),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 1.7),
                                        child: Container(
                                          child: TextFont(
                                            text: (appStateSettings[
                                                        "showTotalSpentForBudget"]
                                                    ? " spent of "
                                                    : " left of ") +
                                                convertToMoney(budget.amount),
                                            fontSize: 13,
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        child: CountUp(
                                          count: appStateSettings[
                                                  "showTotalSpentForBudget"]
                                              ? totalSpent
                                              : -1 *
                                                  (budget.amount - totalSpent),
                                          prefix: getCurrencyString(),
                                          duration: Duration(milliseconds: 700),
                                          fontSize: 18,
                                          textAlign: TextAlign.left,
                                          fontWeight: FontWeight.bold,
                                          decimals:
                                              moneyDecimals(budget.amount),
                                        ),
                                      ),
                                      Container(
                                        padding:
                                            const EdgeInsets.only(bottom: 1.5),
                                        child: TextFont(
                                          text: (appStateSettings[
                                                      "showTotalSpentForBudget"]
                                                  ? " spent of "
                                                  : " overspent of ") +
                                              convertToMoney(budget.amount),
                                          fontSize: 13,
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          padding: EdgeInsets.only(top: 10, right: 10),
                          child: budget.reoccurrence == BudgetReoccurence.custom
                              ? SizedBox.shrink()
                              : ButtonIcon(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PastBudgetsPage(budget: budget),
                                      ),
                                    );
                                  },
                                  icon: Icons.history_rounded,
                                  color: dynamicPastel(
                                      context,
                                      HexColor(budget.colour,
                                          defaultColor: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                      amount: 0.5),
                                  iconColor: dynamicPastel(
                                      context,
                                      HexColor(budget.colour,
                                          defaultColor: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                      amount: 0.7,
                                      inverse: true),
                                  size: 38,
                                ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: BudgetTimeline(
                      budget: budget,
                      percent: (totalSpent / budget.amount * 100).abs(),
                      todayPercent: getPercentBetweenDates(
                          budgetRange, dateForRangeLocal),
                      dateForRange: dateForRangeLocal,
                    ),
                  ),
                  daysBetween(dateForRangeLocal, budgetRange.end) == 0
                      ? Container()
                      : Padding(
                          padding:
                              EdgeInsets.only(left: 10, right: 10, bottom: 17),
                          child: DaySpending(
                            budget: budget,
                            amount: (budget.amount - totalSpent) /
                                daysBetween(dateForRangeLocal, budgetRange.end),
                          ),
                        ),
                ],
              ),
            ),
          );
        } else {
          if (smallBudgetContainer) {
            return Container(
                height: smallContainerHeight, width: double.infinity);
          }
          return Container(height: height, width: double.infinity);
        }
      },
    ));
    return Container(
      decoration: BoxDecoration(
        boxShadow: boxShadowCheck(boxShadowGeneral(context)),
      ),
      child: OpenContainerNavigation(
        borderRadius: 20,
        closedColor: Theme.of(context).colorScheme.lightDarkAccentHeavyLight,
        button: (openContainer) {
          return Tappable(
            onTap: () {
              openContainer();
            },
            onLongPress: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddBudgetPage(
                    title: "Edit Budget",
                    budget: budget,
                  ),
                ),
              );
            },
            borderRadius: 20,
            child: widget,
            color: Theme.of(context).colorScheme.lightDarkAccentHeavyLight,
          );
        },
        openPage: BudgetPage(
          budget: budget,
          dateForRange: dateForRangeLocal,
          isPastBudget: isPastBudget,
          isPastBudgetButCurrentPeriod: isPastBudgetButCurrentPeriod,
        ),
      ),
    );
  }
}

class DaySpending extends StatelessWidget {
  const DaySpending({
    Key? key,
    required Budget this.budget,
    required double this.amount,
    bool this.large = false,
  }) : super(key: key);

  final Budget budget;
  final bool large;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.fitWidth,
        child: TextFont(
          textColor: Theme.of(context).colorScheme.black.withAlpha(80),
          text: amount < 0
              ? "You should save " + convertToMoney(amount.abs()) + " each day."
              : "You can keep spending " +
                  convertToMoney(amount) +
                  " each day.",
          fontSize: large ? 17 : 15,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class AnimatedGooBackground extends StatelessWidget {
  const AnimatedGooBackground({
    Key? key,
    required this.color,
    this.randomOffset = 1,
  });

  final Color color;
  final int randomOffset;

  @override
  Widget build(BuildContext context) {
    if (appStateSettings["batterySaver"]) {
      return Container(
        decoration: BoxDecoration(
          color:
              dynamicPastel(context, color, amountLight: 0.6, amountDark: 0.5),
        ),
      );
    }
    // Transform slightly to remove graphic artifacts
    return Transform(
      transform: Matrix4.skewX(0.001),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(200),
        ),
        child: PlasmaRenderer(
          key: ValueKey(key),
          type: PlasmaType.infinity,
          particles: 10,
          color: Theme.of(context).brightness == Brightness.light
              ? this.color.withOpacity(0.1)
              : this.color.withOpacity(0.3),
          blur: 0.3,
          size: 1.3,
          speed: 3.3,
          offset: 0,
          blendMode: BlendMode.multiply,
          particleType: ParticleType.atlas,
          variation1: 0,
          variation2: 0,
          variation3: 0,
          rotation:
              (randomInt % (randomOffset > 0 ? randomOffset : 1)).toDouble(),
        ),
      ),
    );
  }
}

class BudgetTimeline extends StatelessWidget {
  BudgetTimeline({
    Key? key,
    required this.budget,
    this.large = false,
    this.percent = 0,
    this.todayPercent = 0,
    this.dateForRange,
  }) : super(key: key);

  final Budget budget;
  final double todayPercent;
  final bool large;
  final double percent;
  final DateTime? dateForRange;

  @override
  Widget build(BuildContext context) {
    DateTime dateForRangeLocal =
        dateForRange == null ? DateTime.now() : dateForRange!;
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            large
                ? Container()
                : TextFont(
                    textAlign: TextAlign.center,
                    text: getWordedDateShort(
                        getBudgetDate(budget, dateForRangeLocal).start,
                        includeYear:
                            budget.reoccurrence == BudgetReoccurence.yearly),
                    fontSize: large ? 16 : 12,
                  ),
            Expanded(
              child: BudgetProgress(
                color: HexColor(budget.colour,
                    defaultColor: Theme.of(context).colorScheme.primary),
                percent: percent,
                todayPercent: todayPercent,
                large: large,
              ),
            ),
            large
                ? Container()
                : TextFont(
                    textAlign: TextAlign.center,
                    text: getWordedDateShort(
                        getBudgetDate(budget, dateForRangeLocal).end,
                        includeYear:
                            budget.reoccurrence == BudgetReoccurence.yearly),
                    fontSize: large ? 16 : 12,
                  ),
          ],
        ),
        large
            ? Container(
                padding: EdgeInsets.only(top: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextFont(
                      textAlign: TextAlign.center,
                      text: getWordedDateShortMore(
                          getBudgetDate(budget, dateForRangeLocal).start,
                          includeYear:
                              budget.reoccurrence == BudgetReoccurence.yearly),
                      fontSize: large ? 15 : 12,
                    ),
                    TextFont(
                      textAlign: TextAlign.center,
                      text: getWordedDateShortMore(
                          getBudgetDate(budget, dateForRangeLocal).end,
                          includeYear:
                              budget.reoccurrence == BudgetReoccurence.yearly),
                      fontSize: large ? 15 : 12,
                    ),
                  ],
                ),
              )
            : Container()
      ],
    );
  }
}

class BudgetProgress extends StatelessWidget {
  BudgetProgress(
      {Key? key,
      required this.color,
      required this.percent,
      required this.todayPercent,
      this.large = false})
      : super(key: key);

  final Color color;
  final double percent;
  final double todayPercent;
  final bool large;

  Widget getPercentText(Color color) {
    return Container(
      child: Center(
        child: TextFont(
          text: percent.toStringAsFixed(0) + "%",
          textColor: color,
          fontSize: large ? 16 : 14,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomLeft,
      children: [
        ShakeAnimation(
          delay: Duration(milliseconds: 600),
          animate: percent > 100,
          child: Padding(
            key: ValueKey(1),
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: large
                          ? Theme.of(context).colorScheme.lightDarkAccent
                          : Theme.of(context).colorScheme.lightDarkAccentHeavy,
                    ),
                    height: large ? 24.2 : 19.2,
                  ),
                  ClipRRect(
                    borderRadius: percent < 50
                        ? BorderRadius.only(
                            topRight: Radius.circular(50),
                            bottomRight: Radius.circular(50),
                          )
                        : BorderRadius.circular(50),
                    child: Container(
                      height: large ? 25 : 20,
                      child: AnimatedProgress(
                        percent: percent,
                        large: large,
                        color: color,
                        getPercentText: getPercentText,
                      ),
                    ),
                  ),
                  percent <= 40
                      ? getPercentText(
                          lightenPastel(
                              dynamicPastel(context, color,
                                  inverse: true, amount: 0.7),
                              amount: 0.3),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        ),
        todayPercent <= 0
            ? Container()
            : TodayIndicator(
                percent: todayPercent,
                large: large,
              ),
      ],
    );
  }
}

class AnimatedProgress extends StatefulWidget {
  const AnimatedProgress(
      {required this.percent,
      required this.large,
      required this.color,
      required this.getPercentText,
      super.key});

  final double percent;
  final bool large;
  final Color color;
  final Function(Color color) getPercentText;

  @override
  State<AnimatedProgress> createState() => _AnimatedProgressState();
}

class _AnimatedProgressState extends State<AnimatedProgress> {
  bool animateIn = false;
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      setState(() {
        animateIn = true;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedFractionallySizedBox(
      duration: Duration(milliseconds: 1500),
      curve: Curves.easeInOutCubic,
      heightFactor: 1,
      widthFactor:
          animateIn ? (widget.percent > 100 ? 1 : widget.percent / 100) : 0,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
              color: widget.large
                  ? dynamicPastel(context, widget.color, amount: 0.1)
                  : lightenPastel(widget.color, amount: 0.6),
            ),
          ),
          widget.percent > 40
              ? widget.getPercentText(
                  darkenPastel(widget.color, amount: 0.6),
                )
              : Container(),
        ],
      ),
    );
  }
}

class TodayIndicator extends StatelessWidget {
  TodayIndicator({Key? key, required this.percent, this.large = false})
      : super(key: key);

  final double percent;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: FractionalOffset(percent / 100, 0),
      child: Container(
        child: Container(
          width: 20,
          height: large ? 45 : 39,
          child: OverflowBox(
            maxWidth: 500,
            child: SizedBox(
              width: 38,
              child: Column(
                children: [
                  SlideFadeTransition(
                    child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: Theme.of(context).colorScheme.black),
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: 3, right: 5, left: 5, bottom: 3),
                          child: TextFont(
                            textAlign: TextAlign.center,
                            text: "Today",
                            fontSize: large ? 10 : 9,
                            textColor: Theme.of(context).colorScheme.white,
                          ),
                        )),
                  ),
                  FadeIn(
                    child: Container(
                      width: 3,
                      height: large ? 27 : 22,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.vertical(bottom: Radius.circular(5)),
                        color: Theme.of(context)
                            .colorScheme
                            .black
                            .withOpacity(0.4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
