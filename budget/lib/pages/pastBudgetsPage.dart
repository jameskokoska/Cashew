import 'dart:async';

import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/budgetHistoryLineGraph.dart';
import 'package:budget/pages/budgetPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/animatedCircularProgress.dart';
import 'package:budget/widgets/budgetContainer.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/categoryIcon.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/selectCategory.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/util/debouncer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';
import 'package:async/async.dart' show StreamZip;
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:budget/widgets/countNumber.dart';

class PastBudgetsPage extends StatelessWidget {
  const PastBudgetsPage({super.key, required int this.budgetPk});
  final int budgetPk;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Budget>(
        stream: database.getBudget(budgetPk),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _PastBudgetsPageContent(
              budget: snapshot.data!,
            );
          }
          return SizedBox.shrink();
        });
  }
}

class _PastBudgetsPageContent extends StatefulWidget {
  const _PastBudgetsPageContent({Key? key, required Budget this.budget})
      : super(key: key);
  final Budget budget;

  @override
  State<_PastBudgetsPageContent> createState() =>
      __PastBudgetsPageContentState();
}

GlobalKey<PageFrameworkState> budgetHistoryKey = GlobalKey();

class __PastBudgetsPageContentState extends State<_PastBudgetsPageContent> {
  Stream<List<double?>>? mergedStreamsBudgetTotal;
  Stream<List<double?>>? mergedStreamsCategoriesTotal;
  List<DateTimeRange> dateTimeRanges = [];
  int amountLoaded = 8;
  late List<int>? selectedCategoryFks =
      (appStateSettings["watchedCategoriesOnBudget"]
                  [widget.budget.budgetPk.toString()] ??
              [])
          .cast<int>();
  GlobalKey<_PastBudgetContainerListState>
      _pastBudgetContainerListStateStateKey = GlobalKey();

  initState() {
    Future.delayed(Duration.zero, () async {
      loadLines(amountLoaded);
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _PastBudgetsPageContent oldWidget) {
    if (oldWidget.budget != widget.budget) loadLines(amountLoaded);
    super.didUpdateWidget(oldWidget);
  }

  void loadLines(amountLoaded) async {
    dateTimeRanges = [];
    List<Stream<double?>> watchedBudgetTotals = [];
    List<Stream<double?>> watchedCategoryTotals = [];
    for (int index = 0; index < amountLoaded; index++) {
      DateTime datePast = DateTime(
        DateTime.now().year -
            (widget.budget.reoccurrence == BudgetReoccurence.yearly
                ? index * widget.budget.periodLength
                : 0),
        DateTime.now().month -
            (widget.budget.reoccurrence == BudgetReoccurence.monthly
                ? index * widget.budget.periodLength
                : 0),
        DateTime.now().day -
            (widget.budget.reoccurrence == BudgetReoccurence.daily
                ? index * widget.budget.periodLength
                : 0) -
            (widget.budget.reoccurrence == BudgetReoccurence.weekly
                ? index * 7 * widget.budget.periodLength
                : 0),
        0,
        0,
        1,
      );
      DateTimeRange budgetRange = getBudgetDate(widget.budget, datePast);
      dateTimeRanges.add(budgetRange);
      watchedBudgetTotals.add(database.watchTotalSpentInTimeRangeFromCategories(
        Provider.of<AllWallets>(context, listen: false),
        budgetRange.start,
        budgetRange.end,
        widget.budget.categoryFks,
        widget.budget.allCategoryFks,
        widget.budget.budgetTransactionFilters,
        widget.budget.memberTransactionFilters,
        onlyShowTransactionsBelongingToBudget:
            widget.budget.sharedKey != null ||
                    widget.budget.addedTransactionsOnly == true
                ? widget.budget.budgetPk
                : null,
        budget: widget.budget,
      ));
      for (int categoryFk in selectedCategoryFks ?? []) {
        watchedCategoryTotals
            .add(database.watchTotalSpentInTimeRangeFromCategories(
          Provider.of<AllWallets>(context, listen: false),
          budgetRange.start,
          budgetRange.end,
          [categoryFk],
          false,
          widget.budget.budgetTransactionFilters,
          widget.budget.memberTransactionFilters,
          onlyShowTransactionsBelongingToBudget:
              widget.budget.sharedKey != null ||
                      widget.budget.addedTransactionsOnly == true
                  ? widget.budget.budgetPk
                  : null,
          budget: widget.budget,
        ));
      }
    }

    setState(() {
      mergedStreamsBudgetTotal = StreamZip(watchedBudgetTotals);
      mergedStreamsCategoriesTotal = StreamZip(watchedCategoryTotals);
    });
    // mergedStreams.listen(
    //   (event) {
    //     print("EVENT");
    //     print(event.length);
    //   },
    // );
  }

  void updateSetting(List<int> selectedCategoryFks) {
    if (appStateSettings["watchedCategoriesOnBudget"]
            [widget.budget.budgetPk.toString()] ==
        null) {
      appStateSettings["watchedCategoriesOnBudget"]
          [widget.budget.budgetPk.toString()] = {};
    }
    Map<dynamic, dynamic> newSetting =
        appStateSettings["watchedCategoriesOnBudget"];
    Map<String, dynamic> convertedMap = {};
    newSetting.forEach((key, value) {
      convertedMap[key.toString()] = value;
    });
    convertedMap[widget.budget.budgetPk.toString()] = selectedCategoryFks;
    updateSettings("watchedCategoriesOnBudget", convertedMap,
        pagesNeedingRefresh: [], updateGlobalState: false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DateTimeRange budgetRange = getBudgetDate(widget.budget, DateTime.now());
    ColorScheme budgetColorScheme = ColorScheme.fromSeed(
      seedColor: HexColor(widget.budget.colour,
          defaultColor: Theme.of(context).colorScheme.primary),
      brightness: determineBrightnessTheme(context),
    );
    Color backgroundColor = appStateSettings["materialYou"]
        ? dynamicPastel(context, budgetColorScheme.primary, amount: 0.92)
        : Theme.of(context).canvasColor;

    return PageFramework(
      backgroundColor: backgroundColor,
      key: budgetHistoryKey,
      title: "budget-history".tr(),
      subtitle: Padding(
        padding: EdgeInsets.only(
            left: enableDoubleColumn(context) ? 0 : 20, bottom: 6),
        child: TextFont(
          text: widget.budget.name,
          fontSize: enableDoubleColumn(context) ? 30 : 20,
          maxLines: 5,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          tooltip: "watch-categories".tr(),
          onPressed: () {
            openBottomSheet(
              context,
              PopupFramework(
                title: "select-categories-to-watch".tr(),
                child: Column(
                  children: [
                    SelectCategory(
                      labelIcon: true,
                      addButton: false,
                      selectedCategories: selectedCategoryFks,
                      setSelectedCategories: (List<int> selectedCategoryFks) {
                        setState(() {
                          this.selectedCategoryFks = selectedCategoryFks;
                          updateSetting(selectedCategoryFks);
                        });
                        loadLines(amountLoaded);
                      },
                      scaleWhenSelected: false,
                      categoryFks: widget.budget.allCategoryFks
                          ? null
                          : widget.budget.categoryFks,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Button(
                            expandedLayout: true,
                            label: "clear".tr(),
                            onTap: () {
                              setState(() {
                                selectedCategoryFks = [];
                                updateSetting([]);
                              });
                              Navigator.pop(context);
                            },
                            color:
                                Theme.of(context).colorScheme.tertiaryContainer,
                            textColor: Theme.of(context)
                                .colorScheme
                                .onTertiaryContainer,
                          ),
                        ),
                        SizedBox(width: 13),
                        Expanded(
                          child: Button(
                            expandedLayout: true,
                            label: "done".tr(),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
          padding: EdgeInsets.all(15 - 8),
          icon: AnimatedContainer(
            duration: Duration(milliseconds: 500),
            decoration: BoxDecoration(
              color: (selectedCategoryFks?.length ?? 0) > 0
                  ? budgetColorScheme.tertiary.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(50),
            ),
            padding: EdgeInsets.all(8),
            child: Icon(
              Icons.category_outlined,
              color: (selectedCategoryFks?.length ?? 0) > 0
                  ? budgetColorScheme.tertiary
                  : budgetColorScheme.onSecondaryContainer,
            ),
          ),
        ),
        IconButton(
          padding: EdgeInsets.all(15),
          tooltip: "edit-budget".tr(),
          onPressed: () {
            pushRoute(
              context,
              AddBudgetPage(
                budget: widget.budget,
              ),
            );
          },
          icon: Icon(
            Icons.edit_rounded,
            color: budgetColorScheme.onSecondaryContainer,
          ),
        ),
      ],
      subtitleSize: 10,
      subtitleAnimationSpeed: 9.8,
      subtitleAlignment: Alignment.bottomLeft,
      appBarBackgroundColor: budgetColorScheme.secondaryContainer,
      textColor: getColor(context, "black"),
      dragDownToDismiss: true,
      dragDownToDissmissBackground: Theme.of(context).canvasColor,
      slivers: [
        SliverStickyHeader(
          header: Transform.translate(
            offset: Offset(0, -1),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 7, horizontal: 5),
                      color: backgroundColor,
                      child: StreamBuilder<Map<int, TransactionCategory>>(
                          stream: database.watchAllCategoriesMapped(),
                          builder: (context, snapshotCategoriesMapped) {
                            if (snapshotCategoriesMapped.hasData) {
                              return StreamBuilder<List<double?>>(
                                stream: mergedStreamsBudgetTotal,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    double maxY = 0.1;
                                    List<FlSpot> spots = [];
                                    List<FlSpot> initialSpots = [];

                                    for (int i = snapshot.data!.length - 1;
                                        i >= 0;
                                        i--) {
                                      if ((snapshot.data![i] ?? 0).abs() > maxY)
                                        maxY = (snapshot.data![i] ?? 0).abs();
                                      spots.add(FlSpot(
                                        snapshot.data!.length -
                                            1 -
                                            i.toDouble(),
                                        (snapshot.data![i] ?? 0).abs() == 0
                                            ? 0.001
                                            : (snapshot.data![i] ?? 0).abs(),
                                      ));
                                      initialSpots.add(
                                        FlSpot(
                                          snapshot.data!.length -
                                              1 -
                                              i.toDouble(),
                                          0.000000000001,
                                        ),
                                      );
                                    }
                                    return StreamBuilder<List<double?>>(
                                        stream: mergedStreamsCategoriesTotal,
                                        builder: (context,
                                            snapshotMergedStreamsCategoriesTotal) {
                                          Map<int, List<FlSpot>>
                                              categorySpentPoints = {};
                                          if (snapshotMergedStreamsCategoriesTotal
                                                  .hasData &&
                                              (selectedCategoryFks ?? [])
                                                      .length >
                                                  0) {
                                            maxY = 0.1;
                                            // separate each into a map of their own
                                            int i =
                                                snapshotMergedStreamsCategoriesTotal
                                                        .data!.length -
                                                    1;
                                            for (int day = 0;
                                                day <
                                                    snapshotMergedStreamsCategoriesTotal
                                                            .data!.length /
                                                        (selectedCategoryFks ??
                                                                [])
                                                            .length;
                                                day++) {
                                              for (int categoryFk
                                                  in (selectedCategoryFks ?? [])
                                                      .reversed) {
                                                if (categorySpentPoints[
                                                        categoryFk] ==
                                                    null) {
                                                  categorySpentPoints[
                                                      categoryFk] = [];
                                                }
                                                if (i <
                                                        snapshotMergedStreamsCategoriesTotal
                                                            .data!.length &&
                                                    i >= 0) {
                                                  categorySpentPoints[
                                                          categoryFk]!
                                                      .add(
                                                    FlSpot(
                                                      (snapshotMergedStreamsCategoriesTotal
                                                                  .data!
                                                                  .length -
                                                              day.toDouble() -
                                                              snapshotMergedStreamsCategoriesTotal
                                                                  .data!.length)
                                                          .abs(),
                                                      (snapshotMergedStreamsCategoriesTotal
                                                                              .data?[
                                                                          i] ??
                                                                      0)
                                                                  .abs() ==
                                                              0
                                                          ? 0.001
                                                          : (snapshotMergedStreamsCategoriesTotal
                                                                          .data![
                                                                      i] ??
                                                                  0)
                                                              .abs(),
                                                    ),
                                                  );
                                                  if ((snapshotMergedStreamsCategoriesTotal
                                                                  .data?[i] ??
                                                              0)
                                                          .abs() >
                                                      maxY) {
                                                    maxY =
                                                        (snapshotMergedStreamsCategoriesTotal
                                                                    .data?[i] ??
                                                                0)
                                                            .abs();
                                                  }
                                                }
                                                i--;
                                              }
                                            }
                                          }
                                          // print(categorySpentPoints);

                                          return BudgetHistoryLineGraph(
                                            onTouchedIndex: (index) {
                                              // debounce to avoid duplicate key on AnimatedSwitcher
                                              _pastBudgetContainerListStateStateKey
                                                  .currentState
                                                  ?.setTouchedBudgetIndex(
                                                      index);
                                            },
                                            color: dynamicPastel(
                                              context,
                                              budgetColorScheme.primary,
                                              amountLight: 0.4,
                                              amountDark: 0.2,
                                            ),
                                            dateRanges: dateTimeRanges,
                                            maxY: (selectedCategoryFks ?? [])
                                                        .length >
                                                    0
                                                ? maxY
                                                : widget.budget.amount +
                                                            0.0000000000001 >
                                                        maxY
                                                    ? widget.budget.amount +
                                                        0.0000000000001
                                                    : maxY,
                                            spots: spots,
                                            initialSpots: initialSpots,
                                            horizontalLineAt:
                                                widget.budget.amount,
                                            budget: widget.budget,
                                            extraCategorySpots:
                                                categorySpentPoints,
                                            categoriesMapped:
                                                snapshotCategoriesMapped.data!,
                                          );
                                        });
                                  } else {
                                    return SizedBox.shrink();
                                  }
                                },
                              );
                            }
                            return SizedBox.shrink();
                          }),
                    ),
                    Transform.translate(
                      offset: Offset(0, -1),
                      child: Container(
                        height: 12,
                        foregroundDecoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              backgroundColor,
                              backgroundColor.withOpacity(0.0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [0.1, 1],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Transform.translate(
                        offset: Offset(2, -2),
                        child: IconButton(
                          color: budgetColorScheme.primary,
                          icon: Icon(
                            Icons.history_rounded,
                            size: 22,
                            color: budgetColorScheme.primary.withOpacity(0.8),
                          ),
                          onPressed: () {
                            int amountMoreToLoad =
                                getWidthNavigationSidebar(context) <= 0 ? 3 : 5;
                            loadLines(amountLoaded + amountMoreToLoad);
                            setState(() {
                              amountLoaded = amountLoaded + amountMoreToLoad;
                            });
                            // Future.delayed(Duration(milliseconds: 150), () {
                            //   budgetHistoryKey.currentState!
                            //       .scrollToBottom(duration: 4000);
                            // });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Transform.translate(
                  offset: Offset(0, -1),
                  child: Container(
                    height: 12,
                    foregroundDecoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          backgroundColor,
                          backgroundColor.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.1, 1],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          sliver: MultiSliver(
            children: [
              SliverToBoxAdapter(
                child: BudgetSpenderSummary(
                  budget: widget.budget,
                  budgetRange: budgetRange,
                  budgetColorScheme: budgetColorScheme,
                  setSelectedMember: (member) {},
                  disableMemberSelection: true,
                  allTime: true,
                  isLarge: true,
                ),
              ),
              (selectedCategoryFks ?? []).length > 0
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: StreamBuilder<Map<int, TransactionCategory>>(
                          stream: database.watchAllCategoriesMapped(),
                          builder: (context, snapshotCategoriesMapped) {
                            if (snapshotCategoriesMapped.hasData) {
                              return StreamBuilder<List<double?>>(
                                stream: mergedStreamsCategoriesTotal,
                                builder: (context, snapshotCategoriesTotal) {
                                  if (snapshotCategoriesTotal.hasData) {
                                    List<Widget> children = [];
                                    Map<int, double> categoryTotals = {};
                                    for (int period = 0;
                                        period <
                                            amountLoaded *
                                                (selectedCategoryFks ?? [])
                                                    .length;
                                        period++) {
                                      int categoryIndex = period %
                                          (selectedCategoryFks ?? []).length;
                                      TransactionCategory? category =
                                          snapshotCategoriesMapped.data![
                                              selectedCategoryFks![
                                                  categoryIndex]];
                                      if (category != null &&
                                          period <
                                              snapshotCategoriesTotal
                                                  .data!.length) {
                                        categoryTotals[category.categoryPk] =
                                            (categoryTotals[
                                                        category.categoryPk] ??
                                                    0) +
                                                (snapshotCategoriesTotal
                                                        .data?[period] ??
                                                    0);
                                      }
                                    }
                                    for (int categoryPk
                                        in categoryTotals.keys) {
                                      TransactionCategory? category =
                                          snapshotCategoriesMapped
                                              .data![categoryPk];
                                      if (category != null) {
                                        children.add(
                                          CategoryAverageSpent(
                                            category: category,
                                            amountPeriods: amountLoaded,
                                            amountSpent:
                                                categoryTotals[categoryPk] ?? 0,
                                          ),
                                        );
                                      }
                                    }

                                    return Column(
                                      children: children,
                                    );
                                  } else {
                                    return SizedBox.shrink();
                                  }
                                },
                              );
                            } else {
                              return SizedBox.shrink();
                            }
                          },
                        ),
                      ),
                    )
                  : SliverToBoxAdapter(child: SizedBox.shrink()),
              PastBudgetContainerList(
                key: _pastBudgetContainerListStateStateKey,
                budget: widget.budget,
                amountLoaded: amountLoaded,
                setAmountLoaded: (int amountLoaded) {
                  setState(() {
                    this.amountLoaded = amountLoaded;
                  });
                },
                budgetColorScheme: budgetColorScheme,
                loadLines: loadLines,
              ),
              SliverToBoxAdapter(child: SizedBox(height: 10)),
            ],
          ),
        ),
      ],
    );
  }
}

class PastBudgetContainerList extends StatefulWidget {
  const PastBudgetContainerList({
    required this.budget,
    required this.amountLoaded,
    required this.setAmountLoaded,
    required this.budgetColorScheme,
    required this.loadLines,
    super.key,
  });

  final Budget budget;
  final int amountLoaded;
  final Function(int) setAmountLoaded;
  final ColorScheme budgetColorScheme;
  final Function loadLines;

  @override
  State<PastBudgetContainerList> createState() =>
      _PastBudgetContainerListState();
}

class _PastBudgetContainerListState extends State<PastBudgetContainerList> {
  int? touchedBudgetIndex = null;

  final _debouncer = Debouncer(milliseconds: 50);

  setTouchedBudgetIndex(int? touchedBudgetIndexPassed) {
    _debouncer.run(() {
      setState(() {
        touchedBudgetIndex = touchedBudgetIndexPassed;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiSliver(children: [
      getWidthNavigationSidebar(context) <= 0
          ? SliverPadding(
              padding: EdgeInsets.only(bottom: 15, left: 13, right: 13),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    DateTime datePast = DateTime(
                      DateTime.now().year -
                          (widget.budget.reoccurrence ==
                                  BudgetReoccurence.yearly
                              ? index * widget.budget.periodLength
                              : 0),
                      DateTime.now().month -
                          (widget.budget.reoccurrence ==
                                  BudgetReoccurence.monthly
                              ? index * widget.budget.periodLength
                              : 0),
                      DateTime.now().day -
                          (widget.budget.reoccurrence == BudgetReoccurence.daily
                              ? index * widget.budget.periodLength
                              : 0) -
                          (widget.budget.reoccurrence ==
                                  BudgetReoccurence.weekly
                              ? index * 7 * widget.budget.periodLength
                              : 0),
                      0,
                      0,
                      1,
                    );
                    return FadeIn(
                      duration: Duration(milliseconds: 400),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          boxShadow: appStateSettings["materialYou"]
                              ? []
                              : touchedBudgetIndex == null ||
                                      widget.amountLoaded -
                                              touchedBudgetIndex! -
                                              1 ==
                                          index
                                  ? boxShadowCheck(boxShadowGeneral(context))
                                  : [BoxShadow(color: Colors.transparent)],
                        ),
                        child: AnimatedSize(
                          duration: Duration(milliseconds: 1000),
                          curve: Curves.easeInOutCubicEmphasized,
                          child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 200),
                            child: touchedBudgetIndex == null ||
                                    widget.amountLoaded -
                                            touchedBudgetIndex! -
                                            1 ==
                                        index
                                ? Padding(
                                    padding: EdgeInsets.only(
                                        bottom: index == widget.amountLoaded - 1
                                            ? 0
                                            : 13.0),
                                    child: PastBudgetContainer(
                                      budget: widget.budget,
                                      smallBudgetContainer: true,
                                      showTodayForSmallBudget:
                                          (index == 0 ? true : false),
                                      dateForRange: datePast,
                                      isPastBudget: index == 0 ? false : true,
                                      isPastBudgetButCurrentPeriod: index == 0,
                                      budgetColorScheme:
                                          widget.budgetColorScheme,
                                    ),
                                  )
                                : Container(
                                    key: ValueKey(
                                        datePast.millisecondsSinceEpoch),
                                  ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: widget.amountLoaded, //snapshot.data?.length
                ),
              ),
            )
          : SliverPadding(
              padding: EdgeInsets.only(bottom: 15, left: 13, right: 13),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 600,
                  mainAxisExtent: 95,
                  crossAxisSpacing: 10,
                ),
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    DateTime datePast = DateTime(
                      DateTime.now().year -
                          (widget.budget.reoccurrence ==
                                  BudgetReoccurence.yearly
                              ? index * widget.budget.periodLength
                              : 0),
                      DateTime.now().month -
                          (widget.budget.reoccurrence ==
                                  BudgetReoccurence.monthly
                              ? index * widget.budget.periodLength
                              : 0),
                      DateTime.now().day -
                          (widget.budget.reoccurrence == BudgetReoccurence.daily
                              ? index * widget.budget.periodLength
                              : 0) -
                          (widget.budget.reoccurrence ==
                                  BudgetReoccurence.weekly
                              ? index * 7 * widget.budget.periodLength
                              : 0),
                      0,
                      0,
                      1,
                    );
                    return FadeIn(
                      duration: Duration(milliseconds: 400),
                      child: AnimatedOpacity(
                        duration: Duration(milliseconds: 200),
                        opacity: touchedBudgetIndex == null ||
                                widget.amountLoaded - touchedBudgetIndex! - 1 ==
                                    index
                            ? 1
                            : 0.5,
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: appStateSettings["materialYou"]
                                ? []
                                : boxShadowCheck(boxShadowGeneral(context)),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 13.0),
                            child: PastBudgetContainer(
                              budget: widget.budget,
                              smallBudgetContainer: true,
                              showTodayForSmallBudget:
                                  (index == 0 ? true : false),
                              dateForRange: datePast,
                              isPastBudget: index == 0 ? false : true,
                              isPastBudgetButCurrentPeriod: index == 0,
                              budgetColorScheme: widget.budgetColorScheme,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: widget.amountLoaded,
                ),
              ),
            ),
      SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Opacity(
              opacity: 0.5,
              child: Tappable(
                color: widget.budgetColorScheme.secondaryContainer,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  child: TextFont(
                    text: "view-more".tr(),
                    textAlign: TextAlign.center,
                    fontSize: 16,
                    textColor: widget.budgetColorScheme.onSecondaryContainer,
                  ),
                ),
                onTap: () {
                  int amountMoreToLoad =
                      getWidthNavigationSidebar(context) <= 0 ? 3 : 5;
                  widget.loadLines(widget.amountLoaded + amountMoreToLoad);
                  widget
                      .setAmountLoaded(widget.amountLoaded + amountMoreToLoad);
                  Future.delayed(Duration(milliseconds: 150), () {
                    budgetHistoryKey.currentState!
                        .scrollToBottom(duration: 4000);
                  });
                },
                borderRadius: 10,
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}

class PastBudgetContainer extends StatelessWidget {
  PastBudgetContainer({
    Key? key,
    required this.budget,
    this.smallBudgetContainer = false,
    this.showTodayForSmallBudget = true,
    this.dateForRange,
    this.isPastBudget = false,
    this.isPastBudgetButCurrentPeriod = false,
    required this.budgetColorScheme,
  }) : super(key: key);

  final Budget budget;
  final bool smallBudgetContainer;
  final bool showTodayForSmallBudget;
  final DateTime? dateForRange;
  final bool? isPastBudget;
  final bool? isPastBudgetButCurrentPeriod;
  final ColorScheme budgetColorScheme;

  @override
  Widget build(BuildContext context) {
    DateTime dateForRangeLocal =
        dateForRange == null ? DateTime.now() : dateForRange!;
    DateTimeRange budgetRange = getBudgetDate(budget, dateForRangeLocal);
    var widget = StreamBuilder<double?>(
      stream: database.watchTotalSpentByCurrentUserOnly(
        Provider.of<AllWallets>(context),
        budgetRange.start,
        budgetRange.end,
        budget.budgetPk,
      ),
      builder: (context, snapshotTotalSpentByCurrentUserOnly) {
        double smallContainerHeight = 80;
        return StreamBuilder<List<CategoryWithTotal>>(
          stream:
              database.watchTotalSpentInEachCategoryInTimeRangeFromCategories(
            Provider.of<AllWallets>(context),
            budgetRange.start,
            budgetRange.end,
            budget.categoryFks ?? [],
            budget.allCategoryFks,
            budget.budgetTransactionFilters,
            budget.memberTransactionFilters,
            onlyShowTransactionsBelongingToBudget:
                budget.sharedKey != null || budget.addedTransactionsOnly == true
                    ? budget.budgetPk
                    : null,
            budget: budget,
          ),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              double totalSpent = 0;
              snapshot.data!.forEach((category) {
                totalSpent = totalSpent + category.total.abs();
                totalSpent = totalSpent.abs();
              });
              return Container(
                height: smallContainerHeight,
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              TextFont(
                                text: (isPastBudgetButCurrentPeriod == true)
                                    ? "current-budget-period".tr()
                                    : getWordedDateShortMore(budgetRange.start),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 2,
                                  left: 5,
                                ),
                                child: TextFont(
                                  text: budgetRange.start.year !=
                                          DateTime.now().year
                                      ? budgetRange.start.year.toString()
                                      : "",
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2),
                          budget.amount - totalSpent >= 0
                              ? Row(
                                  children: [
                                    Row(
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
                                                : budget.amount - totalSpent,
                                            duration:
                                                Duration(milliseconds: 700),
                                            dynamicDecimals: true,
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
                                                        : budget.amount -
                                                            totalSpent),
                                                fontSize: 16,
                                                textAlign: TextAlign.left,
                                                fontWeight: FontWeight.bold,
                                              );
                                            },
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 0),
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
                                                      budget.amount),
                                              fontSize: 12,
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      child: CountNumber(
                                        count: appStateSettings[
                                                "showTotalSpentForBudget"]
                                            ? totalSpent
                                            : -1 * (budget.amount - totalSpent),
                                        duration: Duration(milliseconds: 700),
                                        dynamicDecimals: true,
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
                                                        (budget.amount -
                                                            totalSpent)),
                                            fontSize: 16,
                                            textAlign: TextAlign.left,
                                            fontWeight: FontWeight.bold,
                                          );
                                        },
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.only(bottom: 0),
                                      child: TextFont(
                                        text: (appStateSettings[
                                                    "showTotalSpentForBudget"]
                                                ? " " +
                                                    "spent-amount-of".tr() +
                                                    " "
                                                : " " +
                                                    "overspent-amount-of".tr() +
                                                    " ") +
                                            convertToMoney(
                                                Provider.of<AllWallets>(
                                                    context),
                                                budget.amount),
                                        fontSize: 12,
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                    SizedBox(width: 20),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(5 / 2),
                          child: Container(
                            width: 50,
                            child: CountNumber(
                              count: budget.amount == 0
                                  ? 0
                                  : (totalSpent / budget.amount * 100),
                              duration: Duration(milliseconds: 1000),
                              dynamicDecimals: false,
                              initialCount: (0),
                              textBuilder: (value) {
                                return TextFont(
                                  autoSizeText: true,
                                  text: value.toStringAsFixed(0) + "%",
                                  fontSize: 16,
                                  textAlign: TextAlign.center,
                                  fontWeight: FontWeight.bold,
                                  overflow: TextOverflow.fade,
                                  softWrap: false,
                                  maxLines: 1,
                                );
                              },
                            ),
                          ),
                        ),
                        Container(
                          height: 60,
                          width: 60,
                          child: AnimatedCircularProgress(
                            percent: (totalSpent / budget.amount).abs(),
                            backgroundColor:
                                budgetColorScheme.secondaryContainer,
                            foregroundColor: dynamicPastel(
                                context, budgetColorScheme.primary,
                                amountLight: 0.4, amountDark: 0.2),
                            overageColor: budgetColorScheme.tertiary,
                            overageShadowColor: getColor(context, "white"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            } else {
              return Container(
                  height: smallContainerHeight, width: double.infinity);
            }
          },
        );
      },
    );
    return Container(
      child: OpenContainerNavigation(
        borderRadius: 20,
        closedColor: appStateSettings["materialYou"]
            ? dynamicPastel(
                context,
                budgetColorScheme.secondaryContainer,
                amount: 0.5,
              )
            : getColor(context, "lightDarkAccentHeavyLight"),
        button: (openContainer) {
          return Tappable(
            onTap: () {
              openContainer();
            },
            onLongPress: () {
              pushRoute(
                context,
                AddBudgetPage(
                  budget: budget,
                ),
              );
            },
            borderRadius: 20,
            child: widget,
            color: appStateSettings["materialYou"]
                ? dynamicPastel(
                    context,
                    Theme.of(context).colorScheme.secondaryContainer,
                    amount: 0.3,
                  )
                : getColor(context, "lightDarkAccentHeavyLight"),
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

class CategoryAverageSpent extends StatelessWidget {
  const CategoryAverageSpent({
    required this.category,
    required this.amountPeriods,
    required this.amountSpent,
    super.key,
  });
  final TransactionCategory category;
  final int amountPeriods;
  final double amountSpent;

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onLongPress: () {
        pushRoute(
          context,
          AddCategoryPage(
            category: category,
          ),
        );
      },
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: getHorizontalPaddingConstrained(context),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              CategoryIcon(
                category: category,
                size: 30,
                margin: EdgeInsets.zero,
                borderRadius: 1000,
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextFont(
                        text: category.name,
                        fontSize: 17,
                        maxLines: 2,
                      ),
                      SizedBox(
                        height: 1,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: CountNumber(
                              count: (amountSpent / amountPeriods).abs(),
                              duration: Duration(milliseconds: 4000),
                              dynamicDecimals: true,
                              initialCount: (amountSpent / amountPeriods).abs(),
                              textBuilder: (number) {
                                return TextFont(
                                  text: convertToMoney(
                                          Provider.of<AllWallets>(context),
                                          number,
                                          finalNumber:
                                              (amountSpent / amountPeriods)
                                                  .abs()) +
                                      " " +
                                      "average-spent".tr(),
                                  fontSize: 13,
                                  textColor: getColor(context, "textLight"),
                                );
                              },
                            ),
                          ),
                          // TextFont(
                          //   text: transactionCount.toString() +
                          //       " " +
                          //       (transactionCount == 1
                          //           ? "transaction".tr().toLowerCase()
                          //           : "transactions".tr().toLowerCase()),
                          //   fontSize: 13,
                          //   textColor: selected
                          //       ? getColor(context, "black").withOpacity(0.4)
                          //       : getColor(context, "textLight"),
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              CountNumber(
                count: amountSpent.abs(),
                duration: Duration(milliseconds: 400),
                dynamicDecimals: true,
                initialCount: amountSpent.abs(),
                textBuilder: (number) {
                  return TextFont(
                    fontWeight: FontWeight.bold,
                    text: convertToMoney(
                        Provider.of<AllWallets>(context), number,
                        finalNumber: amountSpent.abs()),
                    fontSize: 20,
                    textColor: getColor(context, "black"),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
