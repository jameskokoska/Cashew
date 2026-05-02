import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/homePage/homePageLineGraph.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/lineGraph.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntries.dart';
import 'package:budget/widgets/transactionEntry/incomeAmountArrow.dart';
import 'package:budget/widgets/util/keepAliveClientMixin.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePageCalendar extends StatefulWidget {
  const HomePageCalendar({super.key});

  @override
  State<HomePageCalendar> createState() => _HomePageCalendarState();
}

class _HomePageCalendarState extends State<HomePageCalendar>
    with AutomaticKeepAliveClientMixin {
  late DateTime currentMonth;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    currentMonth = DateTime(now.year, now.month, 1);
  }

  void goToPreviousMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month - 1, 1);
    });
  }

  void goToNextMonth() {
    DateTime now = DateTime.now();
    DateTime nextMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
    if (nextMonth.isBefore(DateTime(now.year, now.month + 1, 1))) {
      setState(() {
        currentMonth = nextMonth;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    DateTime firstDayOfMonth =
        DateTime(currentMonth.year, currentMonth.month, 1);
    DateTime lastDayOfMonth =
        DateTime(currentMonth.year, currentMonth.month + 1, 0);

    return StreamBuilder<List<Transaction>>(
      stream: database.getTransactionsInTimeRangeFromCategories(
        firstDayOfMonth,
        lastDayOfMonth,
        null,
        null,
        true,
        null,
        null,
        null,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox.shrink();

        CalculatePointsParams p = CalculatePointsParams(
          transactions: snapshot.data!,
          customStartDate: firstDayOfMonth,
          customEndDate: lastDayOfMonth,
          totalSpentBefore: 0,
          isIncome: null,
          removeBalanceCorrection: true,
          allWallets: Provider.of<AllWallets>(context, listen: false),
          showCumulativeSpending: false,
          appStateSettingsPassed: appStateSettings,
          cycleThroughAllDays: true,
        );
        List<Pair> points = calculatePoints(p);
        Map<DateTime, double> dailyTotals = {};
        for (Pair pair in points) {
          if (pair.dateTime != null) {
            dailyTotals[pair.dateTime!.justDay()] = pair.y;
          }
        }

        List<Pair> pointsList =
            points.where((p) => p.dateTime != null).toList();

        // maxIncome: highest income day (largest positive)
        // minExpense: biggest expense day (most negative)
        double maxIncome = _getMaxY(pointsList, true) ?? 0;
        double minExpense = _getMinY(pointsList, false) ?? 0;

        return buildCalendar(
          context,
          dailyTotals,
          firstDayOfMonth,
          maxIncome: maxIncome,
          minExpense: minExpense,
        );
      },
    );
  }

  /// Returns the largest positive value across all pairs (highest income day).
  double? _getMaxY(List<Pair> pairs, bool isIncome) {
    double? maxY;
    for (Pair pair in pairs) {
      if (isIncome && pair.y > 0 || !isIncome && pair.y < 0) {
        if (maxY == null || pair.y > maxY) {
          maxY = pair.y;
        }
      }
    }
    return maxY;
  }

  /// Returns the smallest value across all pairs.
  /// For expenses (isIncome=false) this gives the most negative value (biggest expense day).
  double? _getMinY(List<Pair> pairs, bool isIncome) {
    double? minY;
    for (Pair pair in pairs) {
      if (isIncome && pair.y > 0 || !isIncome && pair.y < 0) {
        if (minY == null || pair.y < minY) {
          minY = pair.y;
        }
      }
    }
    return minY;
  }

  Widget buildCalendar(
    BuildContext context,
    Map<DateTime, double> dailyTotals,
    DateTime month, {
    required double maxIncome,
    required double minExpense,
  }) {
    Color backgroundColor = getColor(context, "lightDarkAccentHeavyLight");
    DateTime now = DateTime.now().justDay();

    int firstDayWeekday = DateTime(month.year, month.month, 1).weekday;
    int firstDayOffset = (appStateSettings["firstDayOfWeek"] == -1
        ? MaterialLocalizations.of(context).firstDayOfWeekIndex
        : (appStateSettings["firstDayOfWeek"] as int? ??
            MaterialLocalizations.of(context).firstDayOfWeekIndex));
    int daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    List<Widget> dayLabels = buildDayLabels(context, firstDayOffset);

    List<Widget> dayCells = [];
    int leadingEmpty = (firstDayWeekday - firstDayOffset + 7) % 7;

    for (int i = 0; i < leadingEmpty; i++) {
      dayCells.add(Container());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      DateTime date = DateTime(month.year, month.month, day);
      double netChange = dailyTotals[date] ?? 0;
      bool isFuture = date.isAfter(now);
      Color dayColor = getCalendarDayColor(
        context,
        netChange,
        isFuture: isFuture,
        maxIncome: maxIncome,
        minExpense: minExpense,
      );

      dayCells.add(
        Tappable(
          onTap: isFuture
              ? null
              : () {
                  openTransactionsOnDayBottomSheet(context, date);
                },
          color: dayColor,
          borderRadius: 8,
          child: Container(
            height: 40,
            alignment: Alignment.center,
            child: TextFont(
              text: day.toString(),
              fontSize: 14,
              textColor: isFuture
                  ? Theme.of(context).colorScheme.onSurface.withOpacity(0.3)
                  : (netChange >= 0
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    bool canGoForward = currentMonth.isBefore(DateTime(now.year, now.month, 1));

    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 13),
      child: Container(
        margin: EdgeInsetsDirectional.symmetric(horizontal: 13),
        padding: EdgeInsetsDirectional.only(
            start: 13, end: 13, bottom: 15, top: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadiusDirectional.all(Radius.circular(15)),
          color: backgroundColor,
          boxShadow: boxShadowCheck(boxShadowGeneral(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Tappable(
                  onTap: goToPreviousMonth,
                  borderRadius: 8,
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      appStateSettings["outlinedIcons"]
                          ? Icons.chevron_left_outlined
                          : Icons.chevron_left_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                TextFont(
                  text: getMonth(month, includeYear: true),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                Tappable(
                  onTap: canGoForward ? goToNextMonth : null,
                  borderRadius: 8,
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      appStateSettings["outlinedIcons"]
                          ? Icons.chevron_right_outlined
                          : Icons.chevron_right_rounded,
                      color: canGoForward
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.3),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: dayLabels,
            ),
            SizedBox(height: 6),
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              childAspectRatio: 1.0,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              children: dayCells,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> buildDayLabels(BuildContext context, int firstDayOffset) {
    const dayNames = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    List<Widget> labels = [];
    for (int i = 0; i < 7; i++) {
      int index = (firstDayOffset + i) % 7;
      labels.add(
        Expanded(
          child: Container(
            height: 28,
            alignment: Alignment.center,
            child: TextFont(
              text: dayNames[index],
              fontSize: 12,
              fontWeight: FontWeight.w600,
              textColor:
                  Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ),
      );
    }
    return labels;
  }

  /// Heatmap color logic:
  /// - Future days: faint overlay
  /// - netChange == 0: lightest green (no activity)
  /// - netChange > 0: green, opacity scales with ratio to the highest income day
  /// - netChange < 0: red, opacity scales with ratio to the biggest expense day
  Color getCalendarDayColor(
    BuildContext context,
    double netChange, {
    required bool isFuture,
    required double maxIncome,
    required double minExpense,
  }) {
    if (isFuture) {
      return Theme.of(context).colorScheme.onSurface.withOpacity(0.05);
    }
    if (netChange == 0) {
      // Light green for days with no activity
      return getColor(context, "incomeAmount").withOpacity(0.2);
    } else if (netChange > 0) {
      // Heatmap: lowest income day → 0.3, highest income day → 0.95
      double ratio = maxIncome > 0 ? (netChange / maxIncome) : 0.0;
      double opacity = (0.3 + ratio * 0.65).clamp(0.3, 0.95);
      return getColor(context, "incomeAmount").withOpacity(opacity);
    } else {
      // Heatmap: smallest expense day → 0.3, biggest expense day → 0.95
      // minExpense is the most negative value, so we normalize against its abs
      double ratio = minExpense != 0 ? (netChange.abs() / minExpense.abs()) : 0.0;
      double opacity = (0.3 + ratio * 0.65).clamp(0.3, 0.95);
      return getColor(context, "expenseAmount").withOpacity(opacity);
    }
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
            return Padding(
              padding: EdgeInsetsDirectional.only(
                  top: getPlatform() == PlatformOS.isIOS ? 4 : 1),
              child: AmountWithColorAndArrow(
                showIncomeArrow: true,
                totalSpent: snapshot.data ?? 0,
                fontSize: 19,
                iconSize: 24,
                iconWidth: 15,
                mainAxisAlignment: getPlatform() == PlatformOS.isIOS
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                countNumber: false,
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
        transactionBackgroundColor: getPopupBackgroundColor(context),
        dateDividerColor: Colors.transparent,
        includeDateDivider: false,
        allowSelect: false,
        useHorizontalPaddingConstrained: false,
        noResultsPadding:
            EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 10),
        limitPerDay: 50,
        enableFutureTransactionsCollapse: false,
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
