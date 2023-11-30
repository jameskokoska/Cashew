import 'dart:async';

import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/struct/currencyFunctions.dart';
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
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/selectCategory.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/util/debouncer.dart';
import 'package:budget/widgets/viewAllTransactionsButton.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';
import 'package:async/async.dart' show StreamZip;
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:provider/provider.dart';
import 'package:budget/widgets/countNumber.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:sliver_tools/sliver_tools.dart';

class PastBudgetsPage extends StatelessWidget {
  const PastBudgetsPage({super.key, required String this.budgetPk});
  final String budgetPk;

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

class __PastBudgetsPageContentState extends State<_PastBudgetsPageContent> {
  Stream<List<double?>>? mergedStreamsBudgetTotal;
  Stream<List<double?>>? mergedStreamsCategoriesTotal;
  List<DateTimeRange> dateTimeRanges = [];
  int amountLoaded = 8;
  bool amountLoadedPressedOnce = false;
  late List<String> selectedCategoryFks =
      getSelectedCategoryFksConsideringBudget();
  GlobalKey<_PastBudgetContainerListState>
      _pastBudgetContainerListStateStateKey = GlobalKey();
  GlobalKey<PageFrameworkState> budgetHistoryKey = GlobalKey();

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

  List<String> getSelectedCategoryFksConsideringBudget() {
    List<String> selectedCategoryFks =
        (appStateSettings["watchedCategoriesOnBudget"]
                    [widget.budget.budgetPk.toString()] ??
                [])
            .map<String>((value) => value.toString())
            .toList();
    selectedCategoryFks.removeWhere((categoryFk) =>
        (widget.budget.categoryFksExclude ?? []).contains(categoryFk));
    if (widget.budget.categoryFks != null ||
        widget.budget.categoryFks?.isNotEmpty == true) {
      selectedCategoryFks.retainWhere((categoryFk) =>
          (widget.budget.categoryFks ?? []).contains(categoryFk));
    }
    return selectedCategoryFks;
  }

  void loadLines(amountLoaded) async {
    dateTimeRanges = [];
    List<Stream<double?>> watchedBudgetTotals = [];
    List<Stream<double?>> watchedCategoryTotals = [];
    for (int index = 0; index < amountLoaded; index++) {
      DateTime datePast =
          getDatePastToDetermineBudgetDate(index, widget.budget);
      DateTimeRange budgetRange = getBudgetDate(widget.budget, datePast);
      dateTimeRanges.add(budgetRange);
      watchedBudgetTotals.add(database.watchTotalSpentInTimeRangeFromCategories(
        allWallets: Provider.of<AllWallets>(context, listen: false),
        start: budgetRange.start,
        end: budgetRange.end,
        categoryFks: widget.budget.categoryFks,
        categoryFksExclude: widget.budget.categoryFksExclude,
        budgetTransactionFilters: widget.budget.budgetTransactionFilters,
        memberTransactionFilters: widget.budget.memberTransactionFilters,
        onlyShowTransactionsBelongingToBudgetPk:
            widget.budget.sharedKey != null ||
                    widget.budget.addedTransactionsOnly == true
                ? widget.budget.budgetPk
                : null,
        budget: widget.budget,
      ));
      for (String categoryFk in [...(selectedCategoryFks)]) {
        try {
          await database.getCategory(categoryFk).$2;
        } catch (e) {
          // print("Category No Longer Exists!");
          (selectedCategoryFks).remove(categoryFk);
          updateSetting(selectedCategoryFks);
          continue;
        }
        watchedCategoryTotals
            .add(database.watchTotalSpentInTimeRangeFromCategories(
          allWallets: Provider.of<AllWallets>(context, listen: false),
          start: budgetRange.start,
          end: budgetRange.end,
          categoryFks: [categoryFk],
          categoryFksExclude: null,
          budgetTransactionFilters: widget.budget.budgetTransactionFilters,
          memberTransactionFilters: widget.budget.memberTransactionFilters,
          onlyShowTransactionsBelongingToBudgetPk:
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

  void updateSetting(List<String> selectedCategoryFks) {
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

  void openWatchCategoriesBottomSheet() {
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
              setSelectedCategories: (List<String>? selectedCategoryFks) {
                setState(() {
                  this.selectedCategoryFks = selectedCategoryFks ?? [];
                  updateSetting(selectedCategoryFks ?? []);
                });
                loadLines(amountLoaded);
              },
              scaleWhenSelected: false,
              categoryFks: widget.budget.categoryFks,
              hideCategoryFks: widget.budget.categoryFksExclude,
              allowRearrange: false,
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
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    textColor:
                        Theme.of(context).colorScheme.onTertiaryContainer,
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
    double budgetAmount = budgetAmountToPrimaryCurrency(
        Provider.of<AllWallets>(context, listen: true), widget.budget);

    return PageFramework(
      backgroundColor: backgroundColor,
      appBarBackgroundColor: budgetColorScheme.secondaryContainer,
      appBarBackgroundColorStart: backgroundColor,
      key: budgetHistoryKey,
      title: "history".tr(),
      subtitle: TextFont(
        text: widget.budget.name,
        fontSize: getCenteredTitle(context: context, backButtonEnabled: true) ==
                    true &&
                getCenteredTitleSmall(
                        context: context, backButtonEnabled: true) ==
                    false
            ? 30
            : 22,
        maxLines: 5,
        fontWeight: FontWeight.bold,
      ),
      actions: [
        IconButton(
          tooltip: "watch-categories".tr(),
          onPressed: () {
            openWatchCategoriesBottomSheet();
          },
          padding: EdgeInsets.all(15 - 8),
          icon: AnimatedContainer(
            duration: Duration(milliseconds: 500),
            decoration: BoxDecoration(
              color: selectedCategoryFks.length > 0
                  ? budgetColorScheme.tertiary.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(100),
            ),
            padding: EdgeInsets.all(8),
            child: Icon(
              appStateSettings["outlinedIcons"]
                  ? Icons.category_outlined
                  : Icons.category_rounded,
              color: selectedCategoryFks.length > 0
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
                routesToPopAfterDelete: RoutesToPopAfterDelete.All,
              ),
            );
          },
          icon: Icon(
            appStateSettings["outlinedIcons"]
                ? Icons.edit_outlined
                : Icons.edit_rounded,
            color: budgetColorScheme.onSecondaryContainer,
          ),
        ),
      ],
      subtitleSize: 10,
      subtitleAlignment: Alignment.bottomLeft,
      textColor: getColor(context, "black"),
      dragDownToDismiss: true,
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
                          vertical: 7, horizontal: 0),
                      color: backgroundColor,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: StreamBuilder<Map<String, TransactionCategory>>(
                            stream: database.watchAllCategoriesMapped(),
                            builder: (context, snapshotCategoriesMapped) {
                              if (snapshotCategoriesMapped.hasData) {
                                return StreamBuilder<List<double?>>(
                                  stream: mergedStreamsBudgetTotal,
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      double maxY = 0.1;
                                      double minY = -0.00000000000001;
                                      List<FlSpot> spots = [];

                                      for (int i = snapshot.data!.length - 1;
                                          i >= 0;
                                          i--) {
                                        if ((snapshot.data![i] ?? 0) * -1 <
                                            minY) {
                                          minY = (snapshot.data![i] ?? 0) * -1;
                                        }
                                        if ((snapshot.data![i] ?? 0) * -1 >
                                            maxY) {
                                          maxY = (snapshot.data![i] ?? 0) * -1;
                                        }
                                        spots.add(FlSpot(
                                          snapshot.data!.length -
                                              1 -
                                              i.toDouble(),
                                          (snapshot.data![i] ?? 0).abs() == 0
                                              ? 0.00000000001
                                              : (snapshot.data![i] ?? 0) * -1,
                                        ));
                                      }
                                      // print(minY);
                                      // print(maxY);
                                      return StreamBuilder<List<double?>>(
                                        stream: mergedStreamsCategoriesTotal,
                                        builder: (context,
                                            snapshotMergedStreamsCategoriesTotal) {
                                          Map<String, List<FlSpot>>
                                              categorySpentPoints = {};
                                          if (snapshotMergedStreamsCategoriesTotal
                                                  .hasData &&
                                              (selectedCategoryFks).length >
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
                                                        selectedCategoryFks
                                                            .length;
                                                day++) {
                                              for (String categoryFk
                                                  in selectedCategoryFks
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
                                                          ? 0.00000000001
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
                                          Widget graph = BudgetHistoryLineGraph(
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
                                            maxY: selectedCategoryFks.length > 0
                                                ? maxY
                                                : budgetAmount +
                                                            0.0000000000001 >
                                                        maxY
                                                    ? budgetAmount +
                                                        0.0000000000001
                                                    : maxY,
                                            minY: minY,
                                            spots: [spots],
                                            horizontalLineAt: budgetAmount,
                                            budget: widget.budget,
                                            extraCategorySpots:
                                                categorySpentPoints,
                                            categoriesMapped:
                                                snapshotCategoriesMapped.data!,
                                            loadAllEvenIfZero:
                                                amountLoadedPressedOnce,
                                            setNoPastRegionsAreZero:
                                                (bool value) {
                                              amountLoadedPressedOnce = true;
                                            },
                                          );
                                          if (getCenteredTitle(
                                              context: context,
                                              backButtonEnabled: true)) {
                                            return ClipRRect(
                                              child: graph,
                                            );
                                          }
                                          return graph;
                                        },
                                      );
                                    } else {
                                      return SizedBox.shrink();
                                    }
                                  },
                                );
                              }
                              return SizedBox.shrink();
                            }),
                      ),
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
                    LoadMorePeriodsButton(
                      color: budgetColorScheme.primary,
                      onPressed: () {
                        if (amountLoadedPressedOnce == false) {
                          setState(() {
                            amountLoadedPressedOnce = true;
                          });
                        } else {
                          int amountMoreToLoad =
                              getIsFullScreen(context) == false ? 3 : 5;
                          loadLines(amountLoaded + amountMoreToLoad);
                          setState(() {
                            amountLoaded = amountLoaded + amountMoreToLoad;
                          });
                        }
                      },
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
                child: appStateSettings["sharedBudgets"]
                    ? BudgetSpenderSummary(
                        budget: widget.budget,
                        budgetRange: budgetRange,
                        budgetColorScheme: budgetColorScheme,
                        setSelectedMember: (member) {},
                        disableMemberSelection: true,
                        allTime: true,
                        isLarge: true,
                      )
                    : SizedBox.shrink(),
              ),
              selectedCategoryFks.length > 0
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: StreamBuilder<List<double?>>(
                            stream: mergedStreamsBudgetTotal,
                            builder:
                                (context, snapshotMergedStreamsBudgetTotal) {
                              int totalNonZeroPeriods = 0;
                              for (double? periodTotal
                                  in (snapshotMergedStreamsBudgetTotal.data ??
                                      [])) {
                                if (periodTotal != null && periodTotal != 0) {
                                  totalNonZeroPeriods++;
                                }
                              }

                              return StreamBuilder<
                                  Map<String, TransactionCategory>>(
                                stream: database.watchAllCategoriesMapped(),
                                builder: (context, snapshotCategoriesMapped) {
                                  if (snapshotCategoriesMapped.hasData) {
                                    return StreamBuilder<List<double?>>(
                                      stream: mergedStreamsCategoriesTotal,
                                      builder:
                                          (context, snapshotCategoriesTotal) {
                                        if (snapshotCategoriesTotal.hasData) {
                                          List<Widget> children = [];
                                          Map<String, double> categoryTotals =
                                              {};
                                          for (int period = 0;
                                              period <
                                                  amountLoaded *
                                                      selectedCategoryFks
                                                          .length;
                                              period++) {
                                            int categoryIndex = period %
                                                (selectedCategoryFks).length;
                                            TransactionCategory? category =
                                                snapshotCategoriesMapped.data![
                                                    selectedCategoryFks[
                                                        categoryIndex]];
                                            if (category != null &&
                                                period <
                                                    snapshotCategoriesTotal
                                                        .data!.length) {
                                              categoryTotals[
                                                      category.categoryPk] =
                                                  (categoryTotals[category
                                                              .categoryPk] ??
                                                          0) +
                                                      (snapshotCategoriesTotal
                                                              .data?[period] ??
                                                          0);
                                            }
                                          }
                                          for (String categoryPk
                                              in categoryTotals.keys) {
                                            TransactionCategory? category =
                                                snapshotCategoriesMapped
                                                    .data![categoryPk];
                                            if (category != null) {
                                              children.add(
                                                CategoryAverageSpent(
                                                  category: category,
                                                  amountPeriods:
                                                      totalNonZeroPeriods,
                                                  amountSpent: categoryTotals[
                                                          categoryPk] ??
                                                      0,
                                                  onTap: () {
                                                    openWatchCategoriesBottomSheet();
                                                  },
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
                              );
                            }),
                      ),
                    )
                  : SliverToBoxAdapter(child: SizedBox.shrink()),
              PastBudgetContainerList(
                key: _pastBudgetContainerListStateStateKey,
                budget: widget.budget,
                amountLoaded: amountLoaded,
                setAmountLoaded: (int amountLoaded) {
                  if (amountLoadedPressedOnce == false) {
                    setState(() {
                      amountLoadedPressedOnce = true;
                    });
                  } else {
                    setState(() {
                      this.amountLoaded = amountLoaded;
                    });
                  }
                },
                budgetColorScheme: budgetColorScheme,
                loadLines: (amountLoaded) {
                  if (amountLoadedPressedOnce == false) {
                    // This is set insetAmountLoaded
                  } else {
                    loadLines(amountLoaded);
                    Future.delayed(Duration(milliseconds: 150), () {
                      budgetHistoryKey.currentState!
                          .scrollToBottom(duration: 4000);
                    });
                  }
                },
                backgroundColor: backgroundColor,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class LoadMorePeriodsButton extends StatelessWidget {
  const LoadMorePeriodsButton(
      {required this.color, required this.onPressed, super.key});

  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 0,
      top: 0,
      child: Transform.translate(
        offset: Offset(2, -2),
        child: Tooltip(
          message: "view-more".tr(),
          child: IconButton(
            color: color,
            icon: Icon(
              appStateSettings["outlinedIcons"]
                  ? Icons.history_outlined
                  : Icons.history_rounded,
              size: 22,
              color: color.withOpacity(0.8),
            ),
            onPressed: onPressed,
          ),
        ),
      ),
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
    required this.backgroundColor,
    super.key,
  });

  final Budget budget;
  final int amountLoaded;
  final Function(int) setAmountLoaded;
  final ColorScheme budgetColorScheme;
  final Function(int amountLoaded) loadLines;
  final Color backgroundColor;

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
    return MultiSliver(
      children: [
        getIsFullScreen(context) == false
            ? SliverPadding(
                padding: EdgeInsets.only(
                  bottom: 15,
                  left: getPlatform() == PlatformOS.isIOS ? 0 : 13,
                  right: getPlatform() == PlatformOS.isIOS ? 0 : 13,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      DateTime datePast = getDatePastToDetermineBudgetDate(
                          index, widget.budget);
                      return FadeIn(
                        duration: Duration(milliseconds: 400),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            border: getPlatform() == PlatformOS.isIOS
                                ? Border(
                                    top: BorderSide(
                                      color: getColor(context, "dividerColor"),
                                      width: index == 0 ? 2 : 0,
                                    ),
                                    bottom: BorderSide(
                                      color: getColor(context, "dividerColor"),
                                      width: touchedBudgetIndex == null ? 2 : 0,
                                    ),
                                  )
                                : null,
                            boxShadow: getPlatform() == PlatformOS.isIOS ||
                                    appStateSettings["materialYou"]
                                ? []
                                : touchedBudgetIndex == null ||
                                        widget.amountLoaded -
                                                touchedBudgetIndex! -
                                                1 ==
                                            index
                                    ? boxShadowCheck(boxShadowGeneral(context))
                                    : [BoxShadow(color: Colors.transparent)],
                          ),
                          padding: getPlatform() == PlatformOS.isIOS
                              ? EdgeInsets.zero
                              : EdgeInsets.only(
                                  bottom: touchedBudgetIndex != null ||
                                          index == widget.amountLoaded - 1
                                      ? 0
                                      : 10,
                                ),
                          child: AnimatedExpanded(
                            expand: touchedBudgetIndex == null ||
                                widget.amountLoaded - touchedBudgetIndex! - 1 ==
                                    index,
                            child: PastBudgetContainer(
                              budget: widget.budget,
                              smallBudgetContainer: true,
                              showTodayForSmallBudget:
                                  (index == 0 ? true : false),
                              dateForRange: datePast,
                              isPastBudget: index == 0 ? false : true,
                              isPastBudgetButCurrentPeriod: index == 0,
                              budgetColorScheme: widget.budgetColorScheme,
                              backgroundColor: widget.backgroundColor,
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
                padding: getPlatform() == PlatformOS.isIOS
                    ? EdgeInsets.zero
                    : EdgeInsets.only(bottom: 15, left: 13, right: 13),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 600,
                    mainAxisExtent: 95,
                    crossAxisSpacing:
                        getPlatform() == PlatformOS.isIOS ? 0 : 10,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      DateTime datePast = getDatePastToDetermineBudgetDate(
                          index, widget.budget);
                      return FadeIn(
                        duration: Duration(milliseconds: 400),
                        child: AnimatedOpacity(
                          duration: Duration(milliseconds: 200),
                          opacity: touchedBudgetIndex == null ||
                                  widget.amountLoaded -
                                          touchedBudgetIndex! -
                                          1 ==
                                      index
                              ? 1
                              : 0.5,
                          child: Container(
                            decoration: BoxDecoration(
                              border: getPlatform() == PlatformOS.isIOS
                                  ? Border(
                                      top: BorderSide(
                                        color:
                                            getColor(context, "dividerColor"),
                                        width: index == 0 ? 2 : 0,
                                      ),
                                      bottom: BorderSide(
                                        color:
                                            getColor(context, "dividerColor"),
                                        width:
                                            touchedBudgetIndex == null ? 2 : 0,
                                      ),
                                    )
                                  : null,
                              boxShadow: getPlatform() == PlatformOS.isIOS ||
                                      appStateSettings["materialYou"]
                                  ? []
                                  : boxShadowCheck(boxShadowGeneral(context)),
                            ),
                            child: Padding(
                              padding: getPlatform() == PlatformOS.isIOS
                                  ? EdgeInsets.zero
                                  : EdgeInsets.only(bottom: 13.0),
                              child: PastBudgetContainer(
                                budget: widget.budget,
                                smallBudgetContainer: true,
                                showTodayForSmallBudget:
                                    (index == 0 ? true : false),
                                dateForRange: datePast,
                                isPastBudget: index == 0 ? false : true,
                                isPastBudgetButCurrentPeriod: index == 0,
                                budgetColorScheme: widget.budgetColorScheme,
                                backgroundColor: widget.backgroundColor,
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
              padding: EdgeInsets.only(
                bottom: 30,
                top: getIsFullScreen(context) == true &&
                        getPlatform() == PlatformOS.isIOS
                    ? 10
                    : 0,
              ),
              child: Opacity(
                opacity: 0.5,
                child: LowKeyButton(
                  color: widget.budgetColorScheme.secondaryContainer,
                  textColor: widget.budgetColorScheme.onSecondaryContainer,
                  onTap: () {
                    int amountMoreToLoad =
                        getIsFullScreen(context) == false ? 3 : 5;
                    widget.loadLines(widget.amountLoaded + amountMoreToLoad);
                    widget.setAmountLoaded(
                        widget.amountLoaded + amountMoreToLoad);
                  },
                  text: "view-more".tr(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
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
    required this.backgroundColor,
  }) : super(key: key);

  final Budget budget;
  final bool smallBudgetContainer;
  final bool showTodayForSmallBudget;
  final DateTime? dateForRange;
  final bool? isPastBudget;
  final bool? isPastBudgetButCurrentPeriod;
  final ColorScheme budgetColorScheme;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    double budgetAmount = budgetAmountToPrimaryCurrency(
        Provider.of<AllWallets>(context, listen: true), budget);
    DateTime dateForRangeLocal =
        dateForRange == null ? DateTime.now() : dateForRange!;
    DateTimeRange budgetRange = getBudgetDate(budget, dateForRangeLocal);
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

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Flexible(
                              child: TextFont(
                                text: getPercentBetweenDates(
                                            budgetRange, DateTime.now()) <=
                                        100
                                    ? "current-budget-period".tr()
                                    : getWordedDateShortMore(budgetRange.start),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
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
                        budgetAmount - totalSpent >= 0
                            ? Row(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                                      : budgetAmount -
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
                                            const EdgeInsets.only(bottom: 0.5),
                                        child: Container(
                                          child: TextFont(
                                            text: (appStateSettings[
                                                        "showTotalSpentForBudget"]
                                                    ? " " +
                                                        "spent-amount-of".tr() +
                                                        " "
                                                    : " " +
                                                        "remaining-amount-of"
                                                            .tr() +
                                                        " ") +
                                                convertToMoney(
                                                    Provider.of<AllWallets>(
                                                        context),
                                                    budgetAmount),
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
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    child: CountNumber(
                                      count: appStateSettings[
                                              "showTotalSpentForBudget"]
                                          ? totalSpent
                                          : -1 * (budgetAmount - totalSpent),
                                      duration: Duration(milliseconds: 700),
                                      initialCount: (0),
                                      textBuilder: (number) {
                                        return TextFont(
                                          text: convertToMoney(
                                              Provider.of<AllWallets>(context),
                                              number,
                                              finalNumber: appStateSettings[
                                                      "showTotalSpentForBudget"]
                                                  ? totalSpent
                                                  : -1 *
                                                      (budgetAmount -
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
                                              Provider.of<AllWallets>(context),
                                              budgetAmount),
                                      fontSize: 12,
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ],
                              ),
                      ],
                    ),
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
                          count: budgetAmount == 0
                              ? 0
                              : (totalSpent / budgetAmount * 100),
                          duration: Duration(milliseconds: 1000),
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
                        percent: (totalSpent / budgetAmount).abs(),
                        backgroundColor: budgetColorScheme.secondaryContainer,
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
          return Container(height: 80, width: double.infinity);
        }
      },
    );
    return Container(
      child: OpenContainerNavigation(
        borderRadius: getPlatform() == PlatformOS.isIOS ? 0 : 20,
        closedColor: getPlatform() == PlatformOS.isIOS
            ? backgroundColor
            : appStateSettings["materialYou"]
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
                  routesToPopAfterDelete: RoutesToPopAfterDelete.All,
                ),
              );
            },
            borderRadius: getPlatform() == PlatformOS.isIOS ? 0 : 20,
            child: widget,
            color: getPlatform() == PlatformOS.isIOS
                ? backgroundColor
                : appStateSettings["materialYou"]
                    ? dynamicPastel(
                        context,
                        budgetColorScheme.secondaryContainer,
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
    required this.onTap,
    super.key,
  });
  final TransactionCategory category;
  final int amountPeriods;
  final double amountSpent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onLongPress: () {
        pushRoute(
          context,
          AddCategoryPage(
            category: category,
            routesToPopAfterDelete: RoutesToPopAfterDelete.One,
          ),
        );
      },
      onTap: onTap,
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
                width: 12,
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
                        maxLines: 1,
                      ),
                      SizedBox(
                        height: 1,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: CountNumber(
                              count: amountPeriods == 0
                                  ? 0
                                  : (amountSpent / amountPeriods).abs(),
                              duration: Duration(milliseconds: 400),
                              initialCount: amountPeriods == 0
                                  ? 0
                                  : (amountSpent / amountPeriods).abs(),
                              textBuilder: (number) {
                                return TextFont(
                                  text: convertToMoney(
                                          Provider.of<AllWallets>(context),
                                          number,
                                          finalNumber: amountPeriods == 0
                                              ? 0
                                              : (amountSpent / amountPeriods)
                                                  .abs()) +
                                      " " +
                                      "average-spent".tr().toLowerCase(),
                                  fontSize: 14,
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
              SizedBox(width: 10),
              CountNumber(
                count: amountSpent.abs(),
                duration: Duration(milliseconds: 400),
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
