import 'package:budget/database/tables.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/sharedBudgetSettings.dart';
import 'package:budget/widgets/animatedCircularProgress.dart';
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
import 'package:async/async.dart' show StreamZip;

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
    this.longPressToEdit = true,
  }) : super(key: key);

  final Budget budget;
  final double height;
  final bool smallBudgetContainer;
  final bool showTodayForSmallBudget;
  final DateTime? dateForRange;
  final bool? isPastBudget;
  final bool? isPastBudgetButCurrentPeriod;
  final bool longPressToEdit;

  @override
  Widget build(BuildContext context) {
    DateTime dateForRangeLocal =
        dateForRange == null ? DateTime.now() : dateForRange!;
    DateTimeRange budgetRange = getBudgetDate(budget, dateForRangeLocal);
    var widget = WatchAllWallets(
      childFunction: (wallets) => StreamBuilder<double?>(
        stream: database.watchTotalSpentByCurrentUserOnly(
          budgetRange.start,
          budgetRange.end,
          budget.budgetPk,
          wallets,
        ),
        builder: (context, snapshotTotalSpentByCurrentUserOnly) {
          double smallContainerHeight = showTodayForSmallBudget ? 150 : 140;
          return WatchAllWallets(
            childFunction: (wallets) => StreamBuilder<List<CategoryWithTotal>>(
              stream: database
                  .watchTotalSpentInEachCategoryInTimeRangeFromCategories(
                      budgetRange.start,
                      budgetRange.end,
                      budget.categoryFks ?? [],
                      budget.allCategoryFks,
                      budget.budgetTransactionFilters,
                      budget.memberTransactionFilters,
                      wallets,
                      onlyShowTransactionsBelongingToBudget:
                          budget.sharedKey != null ||
                                  budget.addedTransactionsOnly == true
                              ? budget.budgetPk
                              : null,
                      budget: budget),
              builder: (context, snapshot) {
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
                                            defaultColor: Theme.of(context)
                                                .colorScheme
                                                .primary)
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
                                                  child: CountNumber(
                                                    count: appStateSettings[
                                                            "showTotalSpentForBudget"]
                                                        ? totalSpent
                                                        : budget.amount -
                                                            totalSpent,
                                                    duration: Duration(
                                                        milliseconds: 700),
                                                    dynamicDecimals: true,
                                                    initialCount: (0),
                                                    textBuilder: (number) {
                                                      return TextFont(
                                                        text: convertToMoney(
                                                            number,
                                                            finalNumber: appStateSettings[
                                                                    "showTotalSpentForBudget"]
                                                                ? totalSpent
                                                                : budget.amount -
                                                                    totalSpent),
                                                        fontSize: 18,
                                                        textAlign:
                                                            TextAlign.left,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      );
                                                    },
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 1.7),
                                                  child: Container(
                                                    child: TextFont(
                                                      text: convertToMoney(
                                                          budget.amount),
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
                                                  child: CountNumber(
                                                    count: appStateSettings[
                                                            "showTotalSpentForBudget"]
                                                        ? totalSpent
                                                        : -1 *
                                                            (budget.amount -
                                                                totalSpent),
                                                    duration: Duration(
                                                        milliseconds: 700),
                                                    dynamicDecimals: true,
                                                    initialCount: (0),
                                                    textBuilder: (number) {
                                                      return TextFont(
                                                        text: convertToMoney(
                                                            number,
                                                            finalNumber: appStateSettings[
                                                                    "showTotalSpentForBudget"]
                                                                ? totalSpent
                                                                : -1 *
                                                                    (budget.amount -
                                                                        totalSpent)),
                                                        fontSize: 18,
                                                        textAlign:
                                                            TextAlign.left,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      );
                                                    },
                                                  ),
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 1.5),
                                                  child: TextFont(
                                                    text: (appStateSettings[
                                                                "showTotalSpentForBudget"]
                                                            ? " spent of "
                                                            : " overspent of ") +
                                                        convertToMoney(
                                                            budget.amount),
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
                                  percent:
                                      (totalSpent / budget.amount * 100).abs(),
                                  yourPercent: totalSpent == 0
                                      ? 0
                                      : (snapshotTotalSpentByCurrentUserOnly
                                                  .data! /
                                              budget.amount *
                                              100)
                                          .abs(),
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
                                          defaultColor: Theme.of(context)
                                              .colorScheme
                                              .primary)
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
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Container(
                                                child: CountNumber(
                                                  count: appStateSettings[
                                                          "showTotalSpentForBudget"]
                                                      ? totalSpent
                                                      : budget.amount -
                                                          totalSpent,
                                                  duration: Duration(
                                                      milliseconds: 700),
                                                  dynamicDecimals: true,
                                                  initialCount: (0),
                                                  textBuilder: (number) {
                                                    return TextFont(
                                                      text: convertToMoney(
                                                        number,
                                                        finalNumber:
                                                            appStateSettings[
                                                                    "showTotalSpentForBudget"]
                                                                ? totalSpent
                                                                : budget.amount -
                                                                    totalSpent,
                                                      ),
                                                      fontSize: 18,
                                                      textAlign: TextAlign.left,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    );
                                                  },
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
                                                        convertToMoney(
                                                            budget.amount),
                                                    fontSize: 13,
                                                    textAlign: TextAlign.left,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Container(
                                                child: CountNumber(
                                                  count: appStateSettings[
                                                          "showTotalSpentForBudget"]
                                                      ? totalSpent
                                                      : -1 *
                                                          (budget.amount -
                                                              totalSpent),
                                                  duration: Duration(
                                                      milliseconds: 700),
                                                  dynamicDecimals: true,
                                                  initialCount: (0),
                                                  textBuilder: (number) {
                                                    return TextFont(
                                                      text: convertToMoney(
                                                          number,
                                                          finalNumber: appStateSettings[
                                                                  "showTotalSpentForBudget"]
                                                              ? totalSpent
                                                              : -1 *
                                                                  (budget.amount -
                                                                      totalSpent)),
                                                      fontSize: 18,
                                                      textAlign: TextAlign.left,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    );
                                                  },
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
                                                      convertToMoney(
                                                          budget.amount),
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
                                  child: budget.reoccurrence ==
                                          BudgetReoccurence.custom
                                      ? SizedBox.shrink()
                                      : ButtonIcon(
                                          onTap: () {
                                            pushRoute(
                                                context,
                                                PastBudgetsPage(
                                                    budgetPk: budget.budgetPk),
                                                fancyRoute: true);
                                          },
                                          icon: Icons.history_rounded,
                                          color: dynamicPastel(
                                              context,
                                              HexColor(budget.colour,
                                                  defaultColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .primary),
                                              amount: 0.5),
                                          iconColor: dynamicPastel(
                                              context,
                                              HexColor(budget.colour,
                                                  defaultColor:
                                                      Theme.of(context)
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
                              yourPercent:
                                  snapshotTotalSpentByCurrentUserOnly.data ==
                                          null
                                      ? 0
                                      : totalSpent == 0
                                          ? 0
                                          : (snapshotTotalSpentByCurrentUserOnly
                                                      .data! /
                                                  totalSpent *
                                                  100)
                                              .abs(),
                              todayPercent: getPercentBetweenDates(
                                  budgetRange, dateForRangeLocal),
                              dateForRange: dateForRangeLocal,
                            ),
                          ),
                          daysBetween(dateForRangeLocal, budgetRange.end) == 0
                              ? Container()
                              : Padding(
                                  padding: EdgeInsets.only(
                                      left: 10, right: 10, bottom: 17),
                                  child: DaySpending(
                                    budget: budget,
                                    amount: (budget.amount - totalSpent) /
                                        daysBetween(
                                            dateForRangeLocal, budgetRange.end),
                                    budgetRange: budgetRange,
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
            ),
          );
        },
      ),
    );
    ColorScheme budgetColorScheme = ColorScheme.fromSeed(
      seedColor: HexColor(budget.colour,
          defaultColor: Theme.of(context).colorScheme.primary),
      brightness: determineBrightnessTheme(context),
    );
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
            onLongPress: longPressToEdit
                ? () {
                    pushRoute(
                      context,
                      AddBudgetPage(
                        title: "Edit Budget",
                        budget: budget,
                      ),
                    );
                  }
                : null,
            borderRadius: 20,
            child: widget,
            color: Theme.of(context).colorScheme.lightDarkAccentHeavyLight,
          );
        },
        openPage: BudgetPage(
          budgetPk: budget.budgetPk,
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
    required this.budgetRange,
  }) : super(key: key);

  final Budget budget;
  final bool large;
  final double amount;
  final DateTimeRange budgetRange;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.fitWidth,
        child: TextFont(
          textColor: Theme.of(context).colorScheme.black.withAlpha(80),
          text: amount < 0
              ? "You should save " +
                  convertToMoney(amount.abs()) +
                  " for " +
                  budgetRange.end.difference(DateTime.now()).inDays.toString() +
                  " more days."
              : "You can keep spending " +
                  convertToMoney(amount) +
                  " for " +
                  budgetRange.end.difference(DateTime.now()).inDays.toString() +
                  " days.",
          fontSize: large ? 15 : 13,
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
    if (appStateSettings["batterySaver"] || kIsWeb) {
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
              (randomInt[0] % (randomOffset > 0 ? randomOffset : 1)).toDouble(),
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
    this.yourPercent = 0,
    this.budgetColorScheme,
  }) : super(key: key);

  final Budget budget;
  final double todayPercent;
  final bool large;
  final double percent;
  final double yourPercent;
  final DateTime? dateForRange;
  final ColorScheme? budgetColorScheme;

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
                color: budgetColorScheme != null
                    ? budgetColorScheme!.primary
                    : HexColor(budget.colour,
                        defaultColor: Theme.of(context).colorScheme.primary),
                percent: percent,
                yourPercent: yourPercent,
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
  BudgetProgress({
    Key? key,
    required this.color,
    required this.percent,
    required this.todayPercent,
    required this.yourPercent,
    this.large = false,
  }) : super(key: key);

  final Color color;
  final double percent;
  final double yourPercent;
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
          overflow: TextOverflow.fade,
          softWrap: false,
          maxLines: 1,
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
                      color: appStateSettings["materialYou"]
                          ? large
                              ? dynamicPastel(context, color,
                                  amountLight: 0.9, amountDark: 0.8)
                              : dynamicPastel(
                                  context,
                                  dynamicPastel(context, color,
                                      amount: 0.7, inverse: true),
                                  amountLight: 0.87,
                                  amountDark: 0.75)
                          : large
                              ? Theme.of(context).colorScheme.lightDarkAccent
                              : Theme.of(context)
                                  .colorScheme
                                  .lightDarkAccentHeavy,
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
                        otherPercent: yourPercent,
                      ),
                    ),
                  ),
                  AnimatedOpacity(
                    duration: Duration(milliseconds: 500),
                    opacity: percent <= 40 ? 1 : 0,
                    child: getPercentText(
                      lightenPastel(
                          dynamicPastel(context, color,
                              inverse: true, amount: 0.7),
                          amount: 0.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        todayPercent <= 0
            ? Container(height: 35)
            : TodayIndicator(
                percent: todayPercent,
                large: large,
              ),
      ],
    );
  }
}

class AnimatedProgress extends StatefulWidget {
  const AnimatedProgress({
    required this.percent,
    required this.large,
    required this.color,
    required this.getPercentText,
    this.otherPercent = 0,
    super.key,
  });

  final double percent;
  final bool large;
  final Color color;
  final Function(Color color) getPercentText;
  final double otherPercent;

  @override
  State<AnimatedProgress> createState() => _AnimatedProgressState();
}

class _AnimatedProgressState extends State<AnimatedProgress> {
  bool animateIn = false;
  bool fadeIn = false;
  Future? _future;
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      setState(() {
        animateIn = true;
      });
    });
    _future = Future.delayed(Duration(milliseconds: 500), () {
      if (mounted)
        setState(() {
          fadeIn = true;
        });
    });
    super.initState();
  }

  @override
  void dispose() {
    _future = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.percent == double.infinity ||
                widget.percent == double.nan ||
                widget.percent == double.negativeInfinity ||
                widget.otherPercent == double.infinity ||
                widget.otherPercent == double.nan ||
                widget.otherPercent == double.negativeInfinity
            ? SizedBox.shrink()
            : AnimatedFractionallySizedBox(
                duration: Duration(milliseconds: 1500),
                curve: Curves.easeInOutCubic,
                heightFactor: 1,
                widthFactor: animateIn
                    ? (widget.percent > 100 ? 1 : widget.percent / 100)
                    : 0,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(0),
                        color: lightenPastel(widget.color, amount: 0.6),
                      ),
                    ),
                    // there are no other shared category entries from other users - it is all by the current user
                    AnimatedOpacity(
                      opacity: widget.otherPercent >= 99.99999 ? 0 : 1,
                      duration: Duration(milliseconds: 500),
                      child: AnimatedFractionallySizedBox(
                        duration: Duration(milliseconds: 1500),
                        curve: Curves.easeInOutCubic,
                        heightFactor: 1,
                        widthFactor: animateIn
                            ? (widget.otherPercent > 100
                                ? 1
                                : widget.otherPercent / 100)
                            : 0,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: dynamicPastel(context, widget.color,
                                    amountDark: 0.1, amountLight: 0.3)
                                .withOpacity(0.8),
                          ),
                        ),
                      ),
                    ),

                    AnimatedOpacity(
                      opacity: widget.percent > 40
                          ? fadeIn
                              ? 1
                              : 0
                          : 0,
                      duration: Duration(milliseconds: 500),
                      child: widget.getPercentText(
                        darkenPastel(widget.color, amount: 0.6),
                      ),
                    ),
                  ],
                ),
              ),

        // This adds a rounded corner when the percent is small
        widget.percent / 100 < 0.05
            ? AnimatedContainer(
                curve: Curves.easeInOutCubic,
                duration: Duration(milliseconds: 1500),
                width: animateIn
                    ? widget.percent / 100 <= 0
                        ? 0
                        : widget.large
                            ? 15
                            : 10
                    : 0,
                color: lightenPastel(widget.color, amount: 0.6),
              )
            : SizedBox.shrink()
      ],
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

class BudgetSpender {
  BudgetSpender(this.member, this.amount);

  String member;
  double amount;
}

class BudgetSpenderSummary extends StatefulWidget {
  const BudgetSpenderSummary({
    required this.budget,
    required this.budgetRange,
    required this.budgetColorScheme,
    required this.setSelectedMember,
    required this.wallets,
    this.allTime = false,
    this.disableMemberSelection = false,
    this.isLarge = false,
    super.key,
  });

  final Budget budget;
  final DateTimeRange budgetRange;
  final ColorScheme budgetColorScheme;
  final Function(String?) setSelectedMember;
  final List<TransactionWallet> wallets;
  final bool allTime;
  final bool disableMemberSelection;
  final bool isLarge;

  @override
  State<BudgetSpenderSummary> createState() => _BudgetSpenderSummaryState();
}

class _BudgetSpenderSummaryState extends State<BudgetSpenderSummary> {
  Stream<List<double?>>? mergedStreams;
  Set<String> members = {};
  String? selectedMember = null;
  void didUpdateWidget(oldWidget) {
    if (oldWidget.wallets != widget.wallets) {
      _initialize();
    }
  }

  initState() {
    Future.delayed(Duration.zero, () async {
      _initialize();
    });
    super.initState();
  }

  void _initialize() {
    List<Stream<double?>> watchedSpenderTotals = [];
    members = (widget.budget.sharedAllMembersEver ?? []).toSet();
    // print(widget.budget.sharedAllMembersEver);
    for (String member in members) {
      watchedSpenderTotals.add(database.watchTotalSpentByUser(
        widget.budgetRange.start,
        widget.budgetRange.end,
        widget.budget.categoryFks ?? [],
        widget.budget.allCategoryFks,
        member,
        widget.budget.budgetPk,
        widget.wallets,
        allTime: widget.allTime,
      ));
    }
    mergedStreams = StreamZip(watchedSpenderTotals);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.budget.sharedTransactionsShow ==
        SharedTransactionsShow.onlyIfOwner) return SizedBox.shrink();
    if (mergedStreams == null) return SizedBox.shrink();
    return StreamBuilder<List<double?>>(
      stream: mergedStreams,
      builder: (context, snapshot) {
        List<Widget> memberWidgets = [];
        if (snapshot.hasData && snapshot.data != null) {
          List<BudgetSpender> budgetSpenderList = [];
          double totalSpent = 0;
          for (int i = 0; i < (snapshot.data ?? []).length; i++) {
            double spent;
            if (snapshot.data![i] == null) {
              spent = 0;
            } else {
              spent = snapshot.data![i]!.abs().toDouble();
            }
            if (spent == 0) {
              continue;
            }
            budgetSpenderList.add(BudgetSpender(members.elementAt(i), spent));
            totalSpent += spent;
          }
          budgetSpenderList.sort((a, b) => b.amount.compareTo(a.amount));

          for (BudgetSpender spender in budgetSpenderList) {
            memberWidgets.add(
              WillPopScope(
                onWillPop: () async {
                  if (widget.disableMemberSelection == false) {
                    if (selectedMember == spender.member ||
                        spender.amount == 0) {
                      widget.setSelectedMember(null);
                      setState(() {
                        selectedMember = null;
                      });
                      return false;
                    }
                  }
                  return true;
                },
                child: Tappable(
                  onTap: () {
                    if (widget.disableMemberSelection == false) {
                      if (selectedMember == spender.member ||
                          spender.amount == 0) {
                        widget.setSelectedMember(null);
                        setState(() {
                          selectedMember = null;
                        });
                      } else {
                        widget.setSelectedMember(spender.member);
                        setState(() {
                          selectedMember = spender.member;
                        });
                      }
                    }
                  },
                  onLongPress: () {
                    memberPopup(context, spender.member);
                  },
                  color: Colors.transparent,
                  child: AnimatedContainer(
                    curve: Curves.easeInOut,
                    duration: Duration(milliseconds: 500),
                    color: selectedMember == spender.member
                        ? dynamicPastel(
                                context, widget.budgetColorScheme.primary,
                                amount: 0.3)
                            .withAlpha(80)
                        : Colors.transparent,
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 25,
                      top: widget.isLarge ? 8 : 8,
                      bottom: widget.isLarge ? 8 : 8,
                    ),
                    child: Row(
                      children: [
                        // CategoryIcon(
                        //   category: category,
                        //   size: 30,
                        //   margin: EdgeInsets.zero,
                        // ),
                        MemberSpendingPercent(
                          displayLetter: getMemberNickname(spender.member)
                              .capitalizeFirst
                              .substring(0, 1),
                          percent: totalSpent == 0
                              ? 0
                              : spender.amount / totalSpent * 100,
                          progressBackgroundColor:
                              selectedMember == spender.member
                                  ? Theme.of(context).colorScheme.white
                                  : Theme.of(context)
                                      .colorScheme
                                      .lightDarkAccentHeavy,
                          color: widget.budgetColorScheme.primary,
                          size: widget.isLarge ? 28 : 28,
                          insetPadding: widget.isLarge ? 23 : 18,
                          isLarge: widget.isLarge,
                        ),
                        Container(
                          width: 15,
                        ),
                        Expanded(
                          child: Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextFont(
                                  text: getMemberNickname(spender.member),
                                  fontSize: widget.isLarge ? 19 : 18,
                                ),
                                SizedBox(
                                  height: widget.isLarge ? 3 : 1,
                                ),
                                TextFont(
                                  maxLines: 1,
                                  text: (totalSpent == 0
                                          ? "0"
                                          : (spender.amount / totalSpent * 100)
                                              .toStringAsFixed(0)) +
                                      "% of budget",
                                  fontSize: 14,
                                  textColor: selectedMember == spender.member
                                      ? Theme.of(context)
                                          .colorScheme
                                          .black
                                          .withOpacity(0.4)
                                      : Theme.of(context).colorScheme.textLight,
                                )
                              ],
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextFont(
                              fontWeight: FontWeight.bold,
                              text: convertToMoney(spender.amount),
                              fontSize: widget.isLarge ? 21 : 20,
                            ),
                            SizedBox(
                              height: 1,
                            ),
                            StreamBuilder<List<Transaction>>(
                                stream: database.watchAllTransactionsByUser(
                                    start: widget.budgetRange.start,
                                    end: widget.budgetRange.end,
                                    categoryFks:
                                        widget.budget.categoryFks ?? [],
                                    allCategories: widget.budget.allCategoryFks,
                                    userEmail: spender.member),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return TextFont(
                                      text: snapshot.data!.length.toString() +
                                          pluralString(
                                              snapshot.data!.length == 1,
                                              " transaction"),
                                      fontSize: 14,
                                      textColor:
                                          selectedMember == spender.member
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .black
                                                  .withOpacity(0.4)
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .textLight,
                                    );
                                  }
                                  return SizedBox.shrink();
                                }),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        }

        return Column(children: [
          // HorizontalBarChart(data: chartData),
          ...memberWidgets
        ]);
      },
    );
  }
}

class MemberSpendingPercent extends StatelessWidget {
  MemberSpendingPercent({
    Key? key,
    required this.displayLetter,
    this.size = 30,
    required this.percent,
    this.insetPadding = 23,
    required this.progressBackgroundColor,
    required this.color,
    this.isLarge = false,
  }) : super(key: key);

  final String displayLetter;
  final double size;
  final double percent;
  final double insetPadding;
  final Color progressBackgroundColor;
  final Color color;
  final bool isLarge;

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      Padding(
        padding: EdgeInsets.all(insetPadding / 2),
        child: TextFont(
          text: displayLetter,
          fontWeight: FontWeight.bold,
          fontSize: isLarge ? 23 : 21,
          textColor: dynamicPastel(
            context,
            Theme.of(context).colorScheme.primary,
            amount: 0.4,
            amountLight: 0.7,
            inverse: true,
          ),
        ),
      ),
      AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: Container(
          key: ValueKey(progressBackgroundColor.toString()),
          height: size + insetPadding,
          width: size + insetPadding,
          child: AnimatedCircularProgress(
            percent: percent / 100,
            backgroundColor: progressBackgroundColor,
            foregroundColor: color,
          ),
        ),
      ),
    ]);
  }
}

class HorizontalBarChartPair {
  HorizontalBarChartPair(this.units, this.color);

  double units;
  Color color;
}

class HorizontalBarChart extends StatelessWidget {
  const HorizontalBarChart({required this.data, Key? key}) : super(key: key);
  final List<HorizontalBarChartPair> data;
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(90),
      child: SizedBox(
        height: 20,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            for (int i = 0; i < data.length; i++)
              Expanded(
                flex: (data[i].units * 100).toInt(),
                child: Padding(
                  padding: EdgeInsets.only(right: i == data.length - 1 ? 0 : 5),
                  child: Container(
                    color: data[i].color,
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
