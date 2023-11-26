import 'package:budget/colors.dart';
import 'package:budget/database/generatePreviewData.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/homePage/homePage.dart';
import 'package:budget/pages/homePage/homePageLineGraph.dart';
import 'package:budget/pages/homePage/homePageWalletSwitcher.dart';
import 'package:budget/pages/homePage/homeTransactions.dart';
import 'package:budget/pages/homePage/homeUpcomingTransactions.dart';
import 'package:budget/pages/homePage/homePageUsername.dart';
import 'package:budget/pages/homePage/homePageBudgets.dart';
import 'package:budget/pages/homePage/homePageUpcomingTransactions.dart';
import 'package:budget/pages/homePage/homePageAllSpendingSummary.dart';
import 'package:budget/pages/editHomePage.dart';
import 'package:budget/pages/settingsPage.dart';
import 'package:budget/pages/homePage/homePageCreditDebts.dart';
import 'package:budget/struct/currencyFunctions.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/struct/shareBudget.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/lineGraph.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/selectedTransactionsAppBar.dart';
import 'package:budget/widgets/util/keepAliveClientMixin.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntries.dart';
import 'package:budget/widgets/transactionEntry/swipeToSelectTransactions.dart';
import 'package:budget/widgets/transactionEntry/transactionEntryAmount.dart';
import 'package:budget/widgets/viewAllTransactionsButton.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:budget/widgets/scrollbarWrap.dart';
import 'package:budget/widgets/slidingSelectorIncomeExpense.dart';
import 'package:provider/provider.dart';

import '../../widgets/linearGradientFadedEdges.dart';
import '../../widgets/transactionEntry/incomeAmountArrow.dart';

class HomePageHeatMap extends StatefulWidget {
  const HomePageHeatMap({super.key});

  @override
  State<HomePageHeatMap> createState() => _HomePageHeatMapState();
}

class _HomePageHeatMapState extends State<HomePageHeatMap> {
  int monthsToLoad = 5;
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      if (getIsFullScreen(context)) {
        setState(() {
          monthsToLoad = 10;
        });
      }
    });
    super.initState();
  }

  void loadMoreMonths(int amountToLoad) {
    setState(() {
      monthsToLoad = monthsToLoad + amountToLoad;
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeepAliveClientMixin(
      child: StreamBuilder<double?>(
        stream: database.getTotalBeforeStartDateInTimeRangeFromCategories(
          DateTime(
            DateTime.now().year,
            DateTime.now().month - monthsToLoad,
            DateTime.now().day,
          ),
          [],
          true,
          true,
          null,
          null,
          null,
          allWallets: Provider.of<AllWallets>(context),
        ),
        builder: (context, snapshotTotalSpentBefore) {
          if (snapshotTotalSpentBefore.hasData) {
            double totalSpentBefore = appStateSettings["ignorePastAmountSpent"]
                ? 0
                : snapshotTotalSpentBefore.data!;
            return StreamBuilder<List<Transaction>>(
              stream: database.getTransactionsInTimeRangeFromCategories(
                DateTime(
                  DateTime.now().year,
                  DateTime.now().month - monthsToLoad,
                  DateTime.now().day,
                ),
                DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                ),
                null,
                null,
                true,
                null,
                null,
                null,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  bool cumulative = false;
                  double cumulativeTotal = totalSpentBefore;
                  List<Pair> points = [];
                  for (DateTime indexDay = DateTime(
                    DateTime.now().year,
                    DateTime.now().month - monthsToLoad,
                    DateTime.now().day,
                  );
                      indexDay.compareTo(DateTime.now()) <= 0;
                      indexDay = DateTime(
                          indexDay.year, indexDay.month, indexDay.day + 1)) {
                    //can be optimized...
                    double totalForDay = 0;
                    for (Transaction transaction in snapshot.data!) {
                      if (indexDay.year == transaction.dateCreated.year &&
                          indexDay.month == transaction.dateCreated.month &&
                          indexDay.day == transaction.dateCreated.day) {
                        if (transaction.income) {
                          totalForDay += transaction.amount.abs() *
                              (amountRatioToPrimaryCurrencyGivenPk(
                                  Provider.of<AllWallets>(context),
                                  transaction.walletFk));
                        } else {
                          totalForDay -= transaction.amount.abs() *
                              (amountRatioToPrimaryCurrencyGivenPk(
                                  Provider.of<AllWallets>(context),
                                  transaction.walletFk));
                        }
                      }
                    }
                    cumulativeTotal += totalForDay;
                    points.add(
                      Pair(
                        points.length.toDouble(),
                        cumulative ? cumulativeTotal : totalForDay,
                        dateTime: indexDay,
                      ),
                    );
                  }
                  // for (Pair point in points) {
                  //   print((point.x.toString() + "," + point.y.toString()));
                  // }
                  return HeatMap(
                      points: points, loadMoreMonths: loadMoreMonths);
                }
                return SizedBox.shrink();
              },
            );
          }
          return SizedBox.shrink();
        },
      ),
    );
  }
}

class HeatMap extends StatelessWidget {
  const HeatMap({
    required this.points,
    this.dayWidth = 18,
    this.dayPadding = 1.5,
    this.bottomTitleSpacing = 24,
    this.loadMoreMonths,
    super.key,
  });
  final List<Pair> points;
  final double dayWidth;
  final double dayPadding;
  final double bottomTitleSpacing;
  final Function(int monthsToLoad)? loadMoreMonths;

  double? getMaxY(List<Pair?> pairs, bool isIncome) {
    double? maxY;
    for (Pair? pair in pairs) {
      if (pair != null &&
          (isIncome && pair.y > 0 || isIncome == false && pair.y < 0)) {
        if (maxY == null || pair.y > maxY) {
          maxY = pair.y;
        }
      }
    }
    return maxY;
  }

  double? getMinY(List<Pair?> pairs, bool isIncome) {
    double? minY;
    for (Pair? pair in pairs) {
      if (pair != null &&
          (isIncome && pair.y > 0 || isIncome == false && pair.y < 0)) {
        if (minY == null || pair.y < minY) {
          minY = pair.y;
        }
      }
    }
    return minY;
  }

  @override
  Widget build(BuildContext context) {
    final int totalDaysBeforeFixed = points.length;
    final int totalWeeksBeforeFixed = (totalDaysBeforeFixed / 7).ceil();
    final int lastDateWeekday =
        points[totalDaysBeforeFixed - 1].dateTime?.weekday ?? 0;
    final int lastDayGridLocation =
        7 - (totalWeeksBeforeFixed * 7 - totalDaysBeforeFixed);
    // Subtract one here so the first day of the week is sunday
    int extraDaysOffsetAtStart = (lastDayGridLocation - lastDateWeekday) - 1;
    if (extraDaysOffsetAtStart > 0) {
      extraDaysOffsetAtStart = 7 - extraDaysOffsetAtStart.abs();
    } else {
      extraDaysOffsetAtStart = extraDaysOffsetAtStart.abs();
    }
    final List<Pair?> pointsOffsetFixed = [
      for (int i = 0; i < extraDaysOffsetAtStart; i++) null,
      ...points
    ];
    final double maxIncome = getMaxY(pointsOffsetFixed, true) ?? 0;
    final double minIncome = getMinY(pointsOffsetFixed, true) ?? 0;
    final double maxExpense = getMaxY(pointsOffsetFixed, false) ?? 0;
    final double minExpense = getMinY(pointsOffsetFixed, false) ?? 0;
    final int totalDays = pointsOffsetFixed.length;
    final int totalWeeks = (totalDays / 7).ceil();
    final Color backgroundColor =
        getColor(context, "lightDarkAccentHeavyLight");

    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Container(
        padding: EdgeInsets.only(left: 0, right: 0, bottom: 12, top: 15),
        margin: EdgeInsets.symmetric(horizontal: 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          color: backgroundColor,
          boxShadow: boxShadowCheck(boxShadowGeneral(context)),
        ),
        child: LinearGradientFadedEdges(
          enableBottom: false,
          enableTop: false,
          gradientColor: backgroundColor,
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollNotification) {
              if (loadMoreMonths != null &&
                  scrollNotification.metrics.pixels >=
                      scrollNotification.metrics.maxScrollExtent) {
                loadMoreMonths!(1);
              }
              return false;
            },
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              padding: EdgeInsets.symmetric(horizontal: 13),
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: bottomTitleSpacing),
                    child: Row(
                      children: [
                        for (int i = 0; i < totalWeeks; i++)
                          Column(
                            children: [
                              for (int j = 0; j < 7; j++)
                                Padding(
                                  padding: EdgeInsets.all(dayPadding),
                                  child: Builder(
                                    builder: (context) {
                                      int index = i * 7 + j;
                                      double? amount = nullIfIndexOutOfRange(
                                                  pointsOffsetFixed, index) ==
                                              null
                                          ? null
                                          : nullIfIndexOutOfRange(
                                                  pointsOffsetFixed, index)
                                              .y;
                                      DateTime? day = nullIfIndexOutOfRange(
                                                  pointsOffsetFixed, index) ==
                                              null
                                          ? null
                                          : nullIfIndexOutOfRange(
                                                  pointsOffsetFixed, index)
                                              .dateTime;
                                      Color color = amount == null
                                          ? Colors.transparent
                                          : amount == 0
                                              ? appStateSettings["materialYou"]
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .onSecondary
                                                      .withOpacity(0.6)
                                                  : getColor(context,
                                                          "lightDarkAccent")
                                                      .withOpacity(0.6)
                                              : amount < 0
                                                  ? getColor(context,
                                                          "expenseAmount")
                                                      .withOpacity(
                                                      0.5 +
                                                          (((1 - 0.5) / 4) *
                                                              (getRangeIndex(
                                                                      maxExpense,
                                                                      minExpense,
                                                                      amount) +
                                                                  1)),
                                                    )
                                                  : getColor(context,
                                                          "incomeAmount")
                                                      .withOpacity(
                                                      0.5 +
                                                          (((1 - 0.5) / 4) *
                                                              (getRangeIndex(
                                                                      minIncome,
                                                                      maxIncome,
                                                                      amount) +
                                                                  1)),
                                                    );
                                      return Tooltip(
                                        waitDuration:
                                            Duration(milliseconds: 200),
                                        message: day == null
                                            ? ""
                                            : getWordedDate(
                                                day,
                                                includeMonthDate: true,
                                                includeYearIfNotCurrentYear:
                                                    true,
                                              ),
                                        child: Tappable(
                                          onTap: () {
                                            if (amount != null)
                                              openTransactionsOnDayBottomSheet(
                                                  context, day);
                                          },
                                          child: Container(
                                            height: dayWidth,
                                            width: dayWidth,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: amount == null
                                                    ? Theme.of(context)
                                                                .brightness ==
                                                            Brightness.light
                                                        ? color
                                                            .withOpacity(0.05)
                                                        : color.withOpacity(0.2)
                                                    : color.withOpacity(0.3),
                                                width: 1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                          ),
                                          borderRadius: 5,
                                          color: color,
                                        ),
                                      );
                                    },
                                  ),
                                )
                            ],
                          )
                      ],
                    ),
                  ),
                  loadMoreMonths == null
                      ? SizedBox.shrink()
                      : Positioned(
                          left: 0,
                          child: Tooltip(
                            message: "view-more".tr(),
                            child: ButtonIcon(
                              padding: EdgeInsets.zero,
                              size: dayWidth * 2 + dayPadding * 4,
                              icon: appStateSettings["outlinedIcons"]
                                  ? Icons.history_outlined
                                  : Icons.history_rounded,
                              onTap: () {
                                loadMoreMonths!(1);
                              },
                            ),
                          ),
                        ),
                  for (int i = 0; i < totalWeeks; i++)
                    i % 4 == 0
                        ? Positioned(
                            bottom: 0,
                            child: HeatMapMonthLabel(
                              label: getWordedDateShort(
                                nullIfIndexOutOfRange(
                                            pointsOffsetFixed, i * 7 + 6)
                                        ?.dateTime ??
                                    DateTime.now(),
                                showTodayTomorrow: false,
                              ),
                              weekNumber: i,
                              weekWidth: dayPadding * 2 + dayWidth,
                            ),
                          )
                        : SizedBox.shrink()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<dynamic> openTransactionsOnDayBottomSheet(
    BuildContext context, DateTime? day) {
  return openBottomSheet(
    context,
    PopupFramework(
      hasPadding: false,
      customSubtitleWidget: StreamBuilder<double?>(
        stream: database.watchTotalSpentInTimeRangeFromCategories(
          allWallets: Provider.of<AllWallets>(context, listen: false),
          start: day ?? DateTime.now(),
          end: day ?? DateTime.now(),
          categoryFks: null,
          categoryFksExclude: null,
          budgetTransactionFilters: null,
          memberTransactionFilters: null,
          allCashFlow: true,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            Color textColor = snapshot.data == 0
                ? getColor(context, "black")
                : snapshot.data! > 0
                    ? getColor(context, "incomeAmount")
                    : getColor(context, "expenseAmount");
            return Padding(
              padding: EdgeInsets.only(
                  top: getPlatform() == PlatformOS.isIOS ? 4 : 1),
              child: Row(
                mainAxisAlignment: getPlatform() == PlatformOS.isIOS
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  AnimatedSizeSwitcher(
                    child: snapshot.data == 0
                        ? Container(
                            key: ValueKey(1),
                          )
                        : IncomeOutcomeArrow(
                            key: ValueKey(2),
                            color: textColor,
                            isIncome: snapshot.data! > 0,
                            width: 15,
                          ),
                  ),
                  TextFont(
                    text: convertToMoney(
                      Provider.of<AllWallets>(context),
                      snapshot.data!.abs(),
                      finalNumber: snapshot.data!.abs(),
                    ),
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    textAlign: getPlatform() == PlatformOS.isIOS
                        ? TextAlign.center
                        : TextAlign.left,
                    textColor: textColor,
                  ),
                ],
              ),
            );
          } else {
            return SizedBox.shrink();
          }
        },
      ),
      child: TransactionEntries(
        renderType: TransactionEntriesRenderType.nonSlivers,
        day,
        day,
        transactionBackgroundColor: appStateSettings["materialYou"]
            ? dynamicPastel(
                context, Theme.of(context).colorScheme.secondaryContainer,
                amountDark: 0.3, amountLight: 0.6)
            : getColor(context, "lightDarkAccent"),
        dateDividerColor: Colors.transparent,
        includeDateDivider: false,
        allowSelect: false,
        useHorizontalPaddingConstrained: false,
        noResultsPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        limitPerDay: 50,
      ),
      title: day == null
          ? ""
          : getWordedDate(
              day,
              includeMonthDate: true,
              includeYearIfNotCurrentYear: true,
            ),
    ),
  );
}

class HeatMapMonthLabel extends StatelessWidget {
  const HeatMapMonthLabel(
      {required this.weekNumber,
      required this.label,
      required this.weekWidth,
      super.key});
  final int weekNumber;
  final String label;
  final double weekWidth;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: weekWidth * weekNumber),
      child: Container(
        child: TextFont(
          textAlign: TextAlign.center,
          fontSize: 13,
          text: label,
          textColor: dynamicPastel(
                  context, Theme.of(context).colorScheme.primary,
                  amount: 0.8, inverse: true)
              .withOpacity(0.5),
        ),
      ),
    );
  }
}

int getRangeIndex(double minValue, double maxValue, double number) {
  number = number.abs();
  minValue = minValue.abs();
  maxValue = maxValue.abs();
  double rangeWidth = (maxValue - minValue) / 4;
  if (number >= minValue && number <= maxValue) {
    for (int i = 0; i < 4; i++) {
      double rangeStart = minValue + (i * rangeWidth);
      double rangeEnd = minValue + ((i + 1) * rangeWidth);

      if (number >= rangeStart && number <= rangeEnd) {
        return i;
      }
    }
  }
  return 4 - 1;
}
