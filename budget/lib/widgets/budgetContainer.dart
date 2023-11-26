import 'package:budget/database/tables.dart';
import 'package:budget/pages/sharedBudgetSettings.dart';
import 'package:budget/pages/transactionFilters.dart';
import 'package:budget/struct/currencyFunctions.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/animatedCircularProgress.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/budgetPage.dart';
import 'package:budget/pages/pastBudgetsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/countNumber.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/util/widgetSize.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sa3_liquid/sa3_liquid.dart';
import '../colors.dart';
import '../functions.dart';
import 'package:async/async.dart' show StreamZip;
import 'package:budget/struct/randomConstants.dart';

class BudgetContainer extends StatelessWidget {
  BudgetContainer({
    Key? key,
    required this.budget,
    this.height = 183,
    this.dateForRange,
    this.isPastBudget = false,
    this.isPastBudgetButCurrentPeriod = false,
    this.longPressToEdit = true,
    this.intermediatePadding = true,
    this.squishInactiveBudgetContainerHeight = false,
  }) : super(key: key);

  final Budget budget;
  final double height;
  final DateTime? dateForRange;
  final bool? isPastBudget;
  final bool? isPastBudgetButCurrentPeriod;
  final bool longPressToEdit;
  final bool intermediatePadding;
  final bool squishInactiveBudgetContainerHeight;

  @override
  Widget build(BuildContext context) {
    double budgetAmount = budgetAmountToPrimaryCurrency(
        Provider.of<AllWallets>(context, listen: true), budget);
    DateTime dateForRangeLocal =
        dateForRange == null ? DateTime.now() : dateForRange!;
    DateTimeRange budgetRange = getBudgetDate(budget, dateForRangeLocal);
    bool isOutOfRange = budgetRange.end.difference(DateTime.now()).inDays < 0 ||
        budgetRange.start.difference(DateTime.now()).inDays > 0;
    var widget = StreamBuilder<List<CategoryWithTotal>>(
      stream: database.watchTotalSpentInEachCategoryInTimeRangeFromCategories(
        allWallets: Provider.of<AllWallets>(context),
        start: budgetRange.start,
        end: budgetRange.end,
        categoryFks: budget.categoryFks,
        categoryFksExclude: budget.categoryFksExclude,
        budgetTransactionFilters: budget.budgetTransactionFilters,
        memberTransactionFilters: budget.memberTransactionFilters,
        onlyShowTransactionsBelongingToBudgetPk:
            budget.sharedKey != null || budget.addedTransactionsOnly == true
                ? budget.budgetPk
                : null,
        budget: budget,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          double totalSpent = 0;
          snapshot.data!.forEach((category) {
            totalSpent = totalSpent + category.total;
          });
          totalSpent = totalSpent * -1;
          return Container(
            // height: height,
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
                                fontSize: 24,
                                textAlign: TextAlign.left,
                              ),
                            ),
                            budgetAmount - totalSpent >= 0
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        child: CountNumber(
                                          count: appStateSettings[
                                                  "showTotalSpentForBudget"]
                                              ? totalSpent
                                              : budgetAmount - totalSpent,
                                          duration: Duration(milliseconds: 700),
                                          initialCount: (0),
                                          textBuilder: (number) {
                                            return TextFont(
                                              text: convertToMoney(
                                                Provider.of<AllWallets>(
                                                    context),
                                                number,
                                                finalNumber: appStateSettings[
                                                        "showTotalSpentForBudget"]
                                                    ? totalSpent
                                                    : budgetAmount - totalSpent,
                                              ),
                                              fontSize: 18,
                                              textAlign: TextAlign.left,
                                              fontWeight: FontWeight.bold,
                                            );
                                          },
                                        ),
                                      ),
                                      Flexible(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 1.4),
                                          child: Container(
                                            child: TextFont(
                                              text: (appStateSettings[
                                                          "showTotalSpentForBudget"]
                                                      ? " " +
                                                          "spent-amount-of"
                                                              .tr() +
                                                          " "
                                                      : " " +
                                                          "remaining-amount-of"
                                                              .tr() +
                                                          " ") +
                                                  convertToMoney(
                                                      Provider.of<AllWallets>(
                                                          context),
                                                      budgetAmount),
                                              fontSize: 13,
                                              textAlign: TextAlign.left,
                                            ),
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
                                        child: CountNumber(
                                          count: appStateSettings[
                                                  "showTotalSpentForBudget"]
                                              ? totalSpent
                                              : -1 *
                                                  (budgetAmount - totalSpent),
                                          duration: Duration(milliseconds: 700),
                                          initialCount: (0),
                                          textBuilder: (number) {
                                            return TextFont(
                                              text: convertToMoney(
                                                  Provider.of<AllWallets>(
                                                      context),
                                                  number,
                                                  finalNumber: appStateSettings[
                                                          "showTotalSpentForBudget"]
                                                      ? totalSpent
                                                      : -1 *
                                                          (budgetAmount -
                                                              totalSpent)),
                                              fontSize: 18,
                                              textAlign: TextAlign.left,
                                              fontWeight: FontWeight.bold,
                                            );
                                          },
                                        ),
                                      ),
                                      Flexible(
                                        child: Container(
                                          padding: const EdgeInsets.only(
                                              bottom: 1.4),
                                          child: TextFont(
                                            text: (appStateSettings[
                                                        "showTotalSpentForBudget"]
                                                    ? " " +
                                                        "spent-amount-of".tr() +
                                                        " "
                                                    : " " +
                                                        "overspent-amount-of"
                                                            .tr() +
                                                        " ") +
                                                convertToMoney(
                                                    Provider.of<AllWallets>(
                                                        context),
                                                    budgetAmount),
                                            fontSize: 13,
                                            textAlign: TextAlign.left,
                                          ),
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
                                    pushRoute(
                                      context,
                                      PastBudgetsPage(
                                          budgetPk: budget.budgetPk),
                                    );
                                  },
                                  icon: appStateSettings["outlinedIcons"]
                                      ? Icons.history_outlined
                                      : Icons.history_rounded,
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
                                  iconPadding: 18,
                                ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: intermediatePadding
                        ? EdgeInsets.only(
                            left: 15,
                            right: 15,
                            top: squishInactiveBudgetContainerHeight == true &&
                                    isOutOfRange
                                ? 8.5
                                : 16.5,
                            bottom:
                                squishInactiveBudgetContainerHeight == true &&
                                        isOutOfRange
                                    ? 0
                                    : 8.5,
                          )
                        : EdgeInsets.symmetric(horizontal: 15),
                    child: StreamBuilder<double?>(
                        stream: database.watchTotalOfBudget(
                          allWallets: Provider.of<AllWallets>(context),
                          start: budgetRange.start,
                          end: budgetRange.end,
                          categoryFks: budget.categoryFks,
                          categoryFksExclude: budget.categoryFksExclude,
                          budgetTransactionFilters:
                              budget.budgetTransactionFilters,
                          memberTransactionFilters:
                              budget.memberTransactionFilters,
                          onlyShowTransactionsBelongingToBudgetPk:
                              budget.sharedKey != null ||
                                      budget.addedTransactionsOnly == true
                                  ? budget.budgetPk
                                  : null,
                          budget: budget,
                          searchFilters:
                              SearchFilters(paidStatus: [PaidStatus.notPaid]),
                          paidOnly: false,
                        ),
                        builder: (context, snapshot) {
                          return BudgetTimeline(
                            budget: budget,
                            percent: budgetAmount == 0
                                ? 0
                                : (totalSpent / budgetAmount * 100),
                            yourPercent: 0,
                            todayPercent: getPercentBetweenDates(
                                budgetRange, dateForRangeLocal),
                            dateForRange: dateForRangeLocal,
                            ghostPercent: budgetAmount == 0
                                ? 0
                                : (((snapshot.data ?? 0) * -1) / budgetAmount) *
                                    100,
                          );
                        }),
                  ),
                  DaySpending(
                    budget: budget,
                    totalAmount: totalSpent,
                    budgetRange: budgetRange,
                    padding: EdgeInsets.only(
                      left: 10,
                      right: 10,
                      bottom: squishInactiveBudgetContainerHeight == true &&
                              isOutOfRange
                          ? 4
                          : 17,
                      top: 8,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Container(height: height, width: double.infinity);
        }
      },
    );
    ColorScheme budgetColorScheme = ColorScheme.fromSeed(
      seedColor: HexColor(budget.colour,
          defaultColor: Theme.of(context).colorScheme.primary),
      brightness: determineBrightnessTheme(context),
    );
    Color backgroundColor = appStateSettings["materialYou"]
        ? budget.colour == null
            ? appStateSettings["accentSystemColor"] == true &&
                    appStateSettings["materialYou"] &&
                    appStateSettings["batterySaver"] == false
                ? dynamicPastel(
                    context,
                    Theme.of(context).colorScheme.primary,
                    amountDark: 0.85,
                    amountLight: 0.96,
                  )
                : dynamicPastel(
                    context, HexColor(appStateSettings["accentColor"]),
                    amountDark: 0.8,
                    amountLight: appStateSettings["batterySaver"] ? 0.8 : 0.92)
            : dynamicPastel(
                context,
                budgetColorScheme.secondaryContainer,
                amountDark: 0.6,
                amountLight: 0.75,
              )
        : getColor(
            context,
            "lightDarkAccentHeavyLight",
          );
    return Container(
      decoration: BoxDecoration(
        boxShadow: boxShadowCheck(boxShadowGeneral(context)),
      ),
      child: OpenContainerNavigation(
        borderRadius: 20,
        closedColor: backgroundColor,
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
                        budget: budget,
                        routesToPopAfterDelete: RoutesToPopAfterDelete.One,
                      ),
                    );
                  }
                : null,
            borderRadius: 20,
            child: widget,
            color: backgroundColor,
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
    required double this.totalAmount,
    bool this.large = false,
    required this.budgetRange,
    required this.padding,
  }) : super(key: key);

  final Budget budget;
  final bool large;
  final double totalAmount;
  final DateTimeRange budgetRange;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    double budgetAmount = budgetAmountToPrimaryCurrency(
        Provider.of<AllWallets>(context, listen: true), budget);
    bool isOutOfRange = budgetRange.end.difference(DateTime.now()).inDays < 0 ||
        budgetRange.start.difference(DateTime.now()).inDays > 0;
    Widget textWidget = Padding(
      padding: EdgeInsets.symmetric(horizontal: 6),
      child: large && isOutOfRange
          ? SizedBox(height: 1)
          : Builder(builder: (context) {
              // Add one because if there are zero days left, we want to make it the last day
              int remainingDays = budgetRange.end
                      .difference(
                        DateTime(DateTime.now().year, DateTime.now().month,
                            DateTime.now().day, 0, 0),
                      )
                      .inDays +
                  1;
              double amount =
                  ((totalAmount - budgetAmount) / remainingDays) * -1;
              return TextFont(
                textColor: getColor(context, "black").withAlpha(80),
                text: isOutOfRange
                    ? ""
                    : (amount < 0
                            ? "saving-tracking".tr()
                            : "spending-tracking".tr()) +
                        " " +
                        convertToMoney(
                            Provider.of<AllWallets>(context), amount.abs()) +
                        "/" +
                        "day".tr() +
                        " " +
                        "for".tr() +
                        " " +
                        remainingDays.toString() +
                        " " +
                        (remainingDays == 1
                            ? "more-day".tr()
                            : "more-days".tr()),
                fontSize: large ? 14 : 13,
                textAlign: TextAlign.center,
                maxLines: 4,
              );
            }),
    );
    return Padding(
      padding: large && isOutOfRange ? EdgeInsets.zero : padding,
      child: Center(
        child: large
            ? textWidget
            : FittedBox(
                fit: BoxFit.fitWidth,
                child: textWidget,
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
    if (appStateSettings["batterySaver"] ||
        kIsWeb ||
        getPlatform() == PlatformOS.isIOS) {
      return Container(
        decoration: BoxDecoration(
          color:
              dynamicPastel(context, color, amountLight: 0.6, amountDark: 0.3),
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
    this.ghostPercent = 0,
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
  final double ghostPercent;
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
                ghostPercent: ghostPercent,
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
    this.backgroundColor,
    required this.percent,
    required this.todayPercent,
    required this.yourPercent,
    required this.ghostPercent,
    this.large = false,
    this.showToday = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 8.0),
    this.enableShake = true,
  }) : super(key: key);

  final Color color;
  final backgroundColor;
  final double percent;
  final double yourPercent;
  final double todayPercent;
  final double ghostPercent;
  final bool large;
  final bool showToday;
  final EdgeInsets padding;
  final bool enableShake;

  Widget getPercentText(Color color) {
    return Container(
      child: Center(
        child: TextFont(
          text: (percent.toStringAsFixed(0) == "-0"
                  ? "0"
                  : percent.toStringAsFixed(0)) +
              "%",
          textColor: color,
          fontSize: large ? 16 : 14,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.bold,
          overflow: TextOverflow.fade,
          softWrap: false,
          maxLines: 1,
          autoSizeText: true,
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
          animate: enableShake == true && percent > 100,
          child: Padding(
            key: ValueKey(1),
            padding: padding,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Container(
                height: large ? 24.2 : 19.2,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  clipBehavior: Clip.antiAlias,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: backgroundColor ??
                            (appStateSettings["materialYou"]
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
                                    ? getColor(context, "lightDarkAccent")
                                    : getColor(
                                        context, "lightDarkAccentHeavy")),
                      ),
                    ),
                    if (ghostPercent > 0)
                      Opacity(
                        opacity:
                            Theme.of(context).brightness == Brightness.light
                                ? appStateSettings["materialYou"]
                                    ? large
                                        ? 0.4
                                        : 0.3
                                    : 0.2
                                : appStateSettings["materialYou"]
                                    ? large
                                        ? 0.1
                                        : 0.13
                                    : 0.15,
                        child: ClipRRect(
                          borderRadius: percent < 50
                              ? BorderRadius.only(
                                  topRight: Radius.circular(50),
                                  bottomRight: Radius.circular(50),
                                )
                              : BorderRadius.circular(50),
                          child: Container(
                            child: AnimatedProgress(
                              percent: percent + ghostPercent,
                              large: large,
                              color: color,
                              getPercentText: null,
                              otherPercent: 100,
                            ),
                          ),
                        ),
                      ),
                    ClipRRect(
                      borderRadius: percent < 50
                          ? BorderRadius.only(
                              topRight: Radius.circular(50),
                              bottomRight: Radius.circular(50),
                            )
                          : BorderRadius.circular(50),
                      child: Container(
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
        ),
        showToday == true
            ? todayPercent < 0 || todayPercent > 100
                ? Container(height: 39)
                : TodayIndicator(
                    percent: todayPercent,
                    large: large,
                  )
            : SizedBox.shrink(),
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
  final Function(Color color)? getPercentText;
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
    double percent = widget.percent == double.infinity ||
            widget.percent == double.negativeInfinity ||
            widget.otherPercent == double.infinity ||
            widget.otherPercent == double.negativeInfinity ||
            widget.percent <= 0
        ? 0
        : widget.percent;
    return Stack(
      children: [
        AnimatedFractionallySizedBox(
          duration: Duration(milliseconds: 1500),
          curve: Curves.easeInOutCubic,
          heightFactor: 1,
          widthFactor: animateIn ? (percent > 100 ? 1 : percent / 100) : 0,
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
              if (widget.getPercentText != null)
                AnimatedOpacity(
                  opacity: percent > 40
                      ? fadeIn
                          ? 1
                          : 0
                      : 0,
                  duration: Duration(milliseconds: 500),
                  child: widget.getPercentText!(
                    darkenPastel(widget.color, amount: 0.6),
                  ),
                ),
            ],
          ),
        ),

        // This adds a rounded corner when the percent is small
        percent / 100 < 0.05
            ? AnimatedContainer(
                curve: Curves.easeInOutCubic,
                duration: Duration(milliseconds: 1500),
                width: animateIn
                    ? percent / 100 <= 0
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

class TodayIndicator extends StatefulWidget {
  TodayIndicator({Key? key, required this.percent, this.large = false})
      : super(key: key);

  final double percent;
  final bool large;

  @override
  State<TodayIndicator> createState() => _TodayIndicatorState();
}

class _TodayIndicatorState extends State<TodayIndicator> {
  late double percent = widget.percent;
  double horizontalMargin = 10;
  // double percent = 0;
  // @override
  // void initState() {
  //   Future.delayed(Duration.zero, () async {
  //     for (int i = 1; i <= 300; i++) {
  //       if (percent == 100) {
  //         continue;
  //       }
  //       await Future.delayed(const Duration(milliseconds: 50));
  //       percent += 0.5;
  //       setState(() {});
  //     }
  //   });
  //   super.initState();
  // }

  Size? todayIndicatorSize;
  Size? progressSize;

  @override
  void didUpdateWidget(covariant TodayIndicator oldWidget) {
    if (oldWidget.percent != widget.percent)
      setState(() {
        percent = widget.percent;
      });
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    double percentThreshold = 0;
    double indicatorOffsetPercent = 0;
    if (progressSize != null && todayIndicatorSize != null) {
      double progressWidth = progressSize!.width - horizontalMargin;
      double todayIndicatorWidth =
          todayIndicatorSize!.width - horizontalMargin * 2;
      percentThreshold = (todayIndicatorWidth / 2) / (progressWidth) * 100;
      indicatorOffsetPercent =
          (percent - percentThreshold) / (100 - percentThreshold * 2);
    }
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        WidgetSize(
          onChange: (Size size) {
            progressSize = size;
          },
          child: Align(
            alignment: percent < percentThreshold
                ? FractionalOffset(0, 0)
                : indicatorOffsetPercent > 1
                    ? FractionalOffset(1, 0)
                    : FractionalOffset(indicatorOffsetPercent, 0),
            child: Column(
              children: [
                WidgetSize(
                  onChange: (Size size) {
                    todayIndicatorSize = size;
                    setState(() {});
                  },
                  child: AnimatedOpacity(
                    duration: Duration(milliseconds: 200),
                    opacity: todayIndicatorSize != null ? 1 : 0,
                    child: SlideFadeTransition(
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Color(0xFF1F1F1F)
                                    : getColor(context, "black")),
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: 3, right: 5, left: 5, bottom: 3),
                          child: MediaQuery(
                            child: TextFont(
                              textAlign: TextAlign.center,
                              text: "today".tr(),
                              fontSize: widget.large ? 10 : 9,
                              textColor: getColor(context, "white"),
                            ),
                            data: MediaQuery.of(context)
                                .copyWith(textScaleFactor: 1.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Opacity(
                  opacity: 0,
                  child: Container(
                    width: 3,
                    margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
                    height: widget.large ? 27 : 22,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(5)),
                      color: getColor(context, "black").withOpacity(0.4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: FractionalOffset(percent / 100, 0),
          child: FadeIn(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
              width: 3,
              height: widget.large ? 27 : 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(5)),
                color: getColor(context, "black").withOpacity(0.4),
              ),
            ),
          ),
        ),
      ],
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
    this.allTime = false,
    this.disableMemberSelection = false,
    this.isLarge = false,
    super.key,
  });

  final Budget budget;
  final DateTimeRange budgetRange;
  final ColorScheme budgetColorScheme;
  final Function(String?) setSelectedMember;
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
        Provider.of<AllWallets>(context, listen: false),
        widget.budgetRange.start,
        widget.budgetRange.end,
        widget.budget.categoryFks,
        widget.budget.categoryFksExclude,
        member,
        widget.budget.budgetPk,
        allTime: widget.allTime,
      ));
    }
    mergedStreams = StreamZip(watchedSpenderTotals);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // if (widget.budget.sharedTransactionsShow ==
    //     SharedTransactionsShow.onlyIfOwner) return SizedBox.shrink();
    if (widget.budget.memberTransactionFilters ==
        [appStateSettings["currentUserEmail"]]) return SizedBox.shrink();
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
                                  ? getColor(context, "white")
                                  : getColor(context, "lightDarkAccentHeavy"),
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
                                      ? getColor(context, "black")
                                          .withOpacity(0.4)
                                      : getColor(context, "textLight"),
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
                              text: convertToMoney(
                                  Provider.of<AllWallets>(context),
                                  spender.amount),
                              fontSize: widget.isLarge ? 21 : 20,
                            ),
                            SizedBox(
                              height: 1,
                            ),
                            StreamBuilder<List<Transaction>>(
                                stream: database.watchAllTransactionsByUser(
                                    start: widget.budgetRange.start,
                                    end: widget.budgetRange.end,
                                    categoryFks: widget.budget.categoryFks,
                                    categoryFksExclude:
                                        widget.budget.categoryFksExclude,
                                    userEmail: spender.member),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return TextFont(
                                      text: snapshot.data!.length.toString() +
                                          " " +
                                          (snapshot.data!.length == 1
                                              ? "transaction".tr().toLowerCase()
                                              : "transactions"
                                                  .tr()
                                                  .toLowerCase()),
                                      fontSize: 14,
                                      textColor:
                                          selectedMember == spender.member
                                              ? getColor(context, "black")
                                                  .withOpacity(0.4)
                                              : getColor(context, "textLight"),
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
            color,
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
