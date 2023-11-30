import 'package:animations/animations.dart';
import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/pages/pastBudgetsPage.dart';
import 'package:budget/pages/transactionFilters.dart';
import 'package:budget/pages/transactionsListPage.dart';
import 'package:budget/pages/transactionsSearchPage.dart';
import 'package:budget/pages/walletDetailsPage.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/countNumber.dart';
import 'package:budget/widgets/dateDivider.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry/incomeAmountArrow.dart';
import 'package:budget/widgets/transactionEntry/transactionEntry.dart';
import 'package:flutter/material.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/noResults.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/ghostTransactions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:googleapis/analyticsreporting/v4.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:implicitly_animated_reorderable_list/transitions.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'dart:math';
import 'package:budget/struct/currencyFunctions.dart';
import 'package:budget/struct/randomConstants.dart';
import 'package:sticky_and_expandable_list/sticky_and_expandable_list.dart';
import 'package:budget/widgets/openBottomSheet.dart';

enum TransactionEntriesRenderType {
  slivers,
  implicitlyAnimatedSlivers,
  nonSlivers,
  implicitlyAnimatedNonSlivers,
}

class TransactionEntries extends StatelessWidget {
  const TransactionEntries(
    this.startDay,
    this.endDay, {
    this.renderType = TransactionEntriesRenderType.implicitlyAnimatedSlivers,
    this.search = "",
    this.categoryFks,
    this.categoryFksExclude,
    this.walletFks = const [],
    this.onSelected,
    this.listID,
    this.income,
    this.budgetTransactionFilters,
    this.memberTransactionFilters,
    this.member,
    this.onlyShowTransactionsBelongingToBudgetPk,
    this.onlyShowTransactionsBelongingToObjectivePk,
    this.budget,
    this.dateDividerColor,
    this.transactionBackgroundColor,
    this.categoryTintColor,
    this.useHorizontalPaddingConstrained = true,
    this.showNoResults = true,
    this.colorScheme,
    this.noSearchResultsVariation = false,
    this.noResultsMessage,
    this.searchFilters,
    this.limit = 2500,
    this.limitPerDay = 250,
    this.pastDaysLimitToShow,
    this.includeDateDivider = true,
    this.allowSelect = true,
    this.showObjectivePercentage = true,
    this.noResultsPadding,
    this.noResultsExtraWidget,
    this.totalCashFlowExtraWidget,
    this.showTotalCashFlow = false,
    this.enableSpendingSummary = false,
    this.showSpendingSummary = false,
    this.onLongPressSpendingSummary,
    super.key,
  });
  final TransactionEntriesRenderType renderType;
  final DateTime? startDay;
  final DateTime? endDay;
  final String search;
  final List<String>? categoryFks;
  final List<String>? categoryFksExclude;
  final List<String> walletFks;
  final Function(Transaction, bool)? onSelected;
  final String? listID;
  final bool? income;
  final List<BudgetTransactionFilters>? budgetTransactionFilters;
  final List<String>? memberTransactionFilters;
  final String? member;
  final String? onlyShowTransactionsBelongingToBudgetPk;
  final String? onlyShowTransactionsBelongingToObjectivePk;
  final Budget? budget;
  final Color? dateDividerColor;
  final Color? transactionBackgroundColor;
  final Color? categoryTintColor;
  final bool useHorizontalPaddingConstrained;
  final int? limit;
  final bool showNoResults;
  final ColorScheme? colorScheme;
  final bool noSearchResultsVariation;
  final String? noResultsMessage;
  final SearchFilters? searchFilters;
  final int? pastDaysLimitToShow;
  final bool includeDateDivider;
  final bool allowSelect;
  final bool showObjectivePercentage;
  final EdgeInsets? noResultsPadding;
  final Widget? noResultsExtraWidget;
  final Widget? totalCashFlowExtraWidget;
  final int? limitPerDay;
  final bool showTotalCashFlow;
  final bool enableSpendingSummary;
  final bool showSpendingSummary;
  final VoidCallback? onLongPressSpendingSummary;

  Widget createTransactionEntry(
      List<TransactionWithCategory> transactionListForDay,
      TransactionWithCategory item,
      int index) {
    return TransactionEntry(
      transactionBefore:
          nullIfIndexOutOfRange(transactionListForDay, index - 1)?.transaction,
      transactionAfter:
          nullIfIndexOutOfRange(transactionListForDay, index + 1)?.transaction,
      categoryTintColor: categoryTintColor,
      useHorizontalPaddingConstrained: useHorizontalPaddingConstrained,
      containerColor: transactionBackgroundColor,
      key: ValueKey(item.transaction.transactionPk),
      category: item.category,
      subCategory: item.subCategory,
      budget: item.budget,
      objective: item.objective,
      openPage: AddTransactionPage(
        transaction: item.transaction,
        routesToPopAfterDelete: RoutesToPopAfterDelete.One,
      ),
      transaction: item.transaction,
      onSelected: (Transaction transaction, bool selected) {
        onSelected?.call(transaction, selected);
      },
      listID: listID,
      allowSelect: allowSelect,
      showObjectivePercentage: showObjectivePercentage,
    );
  }

  @override
  Widget build(BuildContext context) {
    // print(startDay);
    // print(endDay);
    return StreamBuilder<List<TransactionWithCategory>>(
      stream: database.getTransactionCategoryWithDay(
        startDay,
        endDay,
        search: search,
        categoryFks: categoryFks,
        categoryFksExclude: categoryFksExclude,
        walletFks: walletFks,
        income: income,
        budgetTransactionFilters: budgetTransactionFilters,
        memberTransactionFilters: memberTransactionFilters,
        member: member,
        onlyShowTransactionsBelongingToBudgetPk:
            onlyShowTransactionsBelongingToBudgetPk,
        onlyShowTransactionsBelongingToObjectivePk:
            onlyShowTransactionsBelongingToObjectivePk,
        searchFilters: searchFilters,
        limit: limit,
        budget: budget,
      ),
      builder: (context, snapshot) {
        if (snapshot.data != null && snapshot.hasData) {
          List<Section> sectionsOut = [];
          List<Widget> widgetsOut = [];
          Widget totalCashFlowWidget = SizedBox.shrink();
          double totalSpent = 0;
          double totalIncome = 0;
          double totalExpense = 0;
          int totalNumberTransactions = (snapshot.data ?? []).length;

          if ((snapshot.data ?? []).length <= 0 &&
              (showNoResults || noResultsExtraWidget != null)) {
            Widget noResults = Column(
              children: [
                if (showNoResults)
                  NoResults(
                    message: noResultsMessage ??
                        "no-transactions-within-time-range".tr() +
                            "." +
                            (budget != null
                                ? ("\n" +
                                    "(" +
                                    getWordedDateShortMore(
                                        startDay ?? DateTime.now()) +
                                    " – " +
                                    getWordedDateShortMore(
                                        endDay ?? DateTime.now()) +
                                    ")")
                                : ""),
                    tintColor: colorScheme != null
                        ? colorScheme?.primary.withOpacity(0.6)
                        : null,
                    noSearchResultsVariation: noSearchResultsVariation,
                    padding: noResultsPadding,
                  ),
                if (noResultsExtraWidget != null) noResultsExtraWidget!,
              ],
            );
            if (renderType == TransactionEntriesRenderType.slivers ||
                renderType ==
                    TransactionEntriesRenderType.implicitlyAnimatedSlivers) {
              return SliverToBoxAdapter(child: noResults);
              // return SliverFillRemaining(
              //   hasScrollBody: false,
              //   child: Column(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       noResults,
              //     ],
              //   ),
              // );
            } else if (renderType == TransactionEntriesRenderType.nonSlivers ||
                renderType ==
                    TransactionEntriesRenderType.implicitlyAnimatedNonSlivers) {
              return noResults;
            }
          }
          int currentTotalIndex = 0;

          List<TransactionWithCategory> transactionListForDay = [];
          double totalSpentForDay = 0;
          DateTime? currentDate;
          int totalUniqueDays = 0;

          for (TransactionWithCategory transactionWithCategory
              in snapshot.data ?? []) {
            if (pastDaysLimitToShow != null &&
                totalUniqueDays > pastDaysLimitToShow!) break;

            DateTime currentTransactionDate = DateTime(
                transactionWithCategory.transaction.dateCreated.year,
                transactionWithCategory.transaction.dateCreated.month,
                transactionWithCategory.transaction.dateCreated.day);
            if (currentDate == null) {
              currentDate = currentTransactionDate;
              totalUniqueDays++;
            }
            if (currentDate == currentTransactionDate) {
              transactionListForDay.add(transactionWithCategory);
              if (transactionWithCategory.transaction.paid &&
                  transactionWithCategory.transaction.categoryFk != "0") {
                double amountForDay =
                    transactionWithCategory.transaction.amount *
                        (amountRatioToPrimaryCurrencyGivenPk(
                            Provider.of<AllWallets>(context),
                            transactionWithCategory.transaction.walletFk));
                totalSpentForDay += amountForDay;
                if (amountForDay < 0) {
                  totalExpense += amountForDay;
                }
                if (amountForDay > 0) {
                  totalIncome += amountForDay;
                }
              }
            }

            DateTime? nextTransactionDate =
                (snapshot.data ?? []).length == currentTotalIndex + 1
                    ? null
                    : DateTime(
                        (snapshot.data ?? [])[currentTotalIndex + 1]
                            .transaction
                            .dateCreated
                            .year,
                        (snapshot.data ?? [])[currentTotalIndex + 1]
                            .transaction
                            .dateCreated
                            .month,
                        (snapshot.data ?? [])[currentTotalIndex + 1]
                            .transaction
                            .dateCreated
                            .day,
                      );

            if (nextTransactionDate == null ||
                nextTransactionDate != currentTransactionDate) {
              if (transactionListForDay.length > 0) {
                Widget dateDividerWidget = includeDateDivider == false
                    ? SizedBox.shrink()
                    : DateDivider(
                        useHorizontalPaddingConstrained:
                            useHorizontalPaddingConstrained,
                        color: dateDividerColor,
                        date: currentTransactionDate,
                        info: transactionListForDay.length > 1
                            ? convertToMoney(Provider.of<AllWallets>(context),
                                totalSpentForDay)
                            : "");

                if (renderType == TransactionEntriesRenderType.slivers) {
                  sectionsOut.add(
                    Section()
                      ..expanded = true
                      ..header = Transform.translate(
                        offset: Offset(0, -1),
                        child: dateDividerWidget,
                      )
                      ..items = [
                        for (int index = 0;
                            index < transactionListForDay.length;
                            index++)
                          createTransactionEntry(transactionListForDay,
                              transactionListForDay[index], index),
                      ],
                  );
                } else if (renderType ==
                    TransactionEntriesRenderType.implicitlyAnimatedSlivers) {
                  List<TransactionWithCategory> transactionListForDayCopy = [
                    ...transactionListForDay
                  ];
                  widgetsOut.add(
                    SliverStickyHeader(
                      header: Transform.translate(
                          offset: Offset(0, -1),
                          child: transactionListForDay.length > 0
                              ? includeDateDivider == false
                                  ? SizedBox.shrink()
                                  : dateDividerWidget
                              : SizedBox.shrink()),
                      sticky: true,
                      sliver:
                          SliverImplicitlyAnimatedList<TransactionWithCategory>(
                        items: transactionListForDay,
                        areItemsTheSame: (a, b) =>
                            a.transaction.transactionPk ==
                            b.transaction.transactionPk,
                        insertDuration: Duration(milliseconds: 500),
                        removeDuration: Duration(milliseconds: 500),
                        updateDuration: Duration(milliseconds: 500),
                        itemBuilder: (BuildContext context,
                            Animation<double> animation,
                            TransactionWithCategory item,
                            int index) {
                          return SizeFadeTransition(
                            sizeFraction: 0.7,
                            curve: Curves.easeInOut,
                            animation: animation,
                            child: createTransactionEntry(
                                transactionListForDayCopy, item, index),
                          );
                        },
                      ),
                    ),
                  );
                } else if (renderType ==
                        TransactionEntriesRenderType.nonSlivers ||
                    renderType ==
                        TransactionEntriesRenderType
                            .implicitlyAnimatedNonSlivers) {
                  widgetsOut.add(dateDividerWidget);
                  for (int i = 0; i < transactionListForDay.length; i++) {
                    TransactionWithCategory item = transactionListForDay[i];
                    widgetsOut.add(
                        createTransactionEntry(transactionListForDay, item, i));
                  }
                }

                currentDate = null;
                transactionListForDay = [];
                totalSpent += totalSpentForDay;
                totalSpentForDay = 0;
              }
            }
            currentTotalIndex++;
          }

          if (showTotalCashFlow) {
            totalCashFlowWidget = Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 10,
                        right: 10,
                        top: 10,
                        bottom: 8,
                      ),
                      child: TextFont(
                        text: "total-cash-flow".tr() +
                            ": " +
                            convertToMoney(
                                Provider.of<AllWallets>(context), totalSpent) +
                            "\n" +
                            totalNumberTransactions.toString() +
                            " " +
                            (totalNumberTransactions == 1
                                ? "transaction".tr().toLowerCase()
                                : "transactions".tr().toLowerCase()),
                        fontSize: 13,
                        textAlign: TextAlign.center,
                        textColor: getColor(context, "textLight"),
                      ),
                    ),
                    if (totalCashFlowExtraWidget != null)
                      totalCashFlowExtraWidget!,
                  ],
                ),
              ],
            );
            if (renderType != TransactionEntriesRenderType.slivers)
              widgetsOut.add(totalCashFlowWidget);
          }

          if (enableSpendingSummary)
            widgetsOut.insert(
              0,
              TransactionsEntriesSpendingSummary(
                show: showSpendingSummary,
                netSpending: totalIncome + totalExpense,
                income: totalIncome,
                expense: totalExpense,
                onLongPress: onLongPressSpendingSummary,
              ),
            );

          if (renderType == TransactionEntriesRenderType.slivers) {
            return MultiSliver(
              children: [
                SliverExpandableList(
                  builder: SliverExpandableChildDelegate<Widget, Section>(
                    sectionList: sectionsOut,
                    headerBuilder:
                        (BuildContext context, int sectionIndex, int index) {
                      return sectionsOut[sectionIndex].header;
                    },
                    itemBuilder: (context, sectionIndex, itemIndex, index) {
                      Widget item = sectionsOut[sectionIndex].items[itemIndex];
                      return item;
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: totalCashFlowWidget,
                ),
              ],
            );
          } else if (renderType ==
              TransactionEntriesRenderType.implicitlyAnimatedSlivers) {
            return MultiSliver(children: widgetsOut);
          } else if (renderType == TransactionEntriesRenderType.nonSlivers) {
            return ImplicitlyAnimatedList<Widget>(
              items: widgetsOut,
              areItemsTheSame: (a, b) => a.key.toString() == b.key.toString(),
              insertDuration: Duration(milliseconds: 500),
              removeDuration: Duration(milliseconds: 500),
              updateDuration: Duration(milliseconds: 500),
              itemBuilder: (BuildContext context, Animation<double> animation,
                  Widget item, int index) {
                return SizeFadeTransition(
                  sizeFraction: 0.7,
                  curve: Curves.easeInOut,
                  animation: animation,
                  child: item,
                );
              },
              physics: ClampingScrollPhysics(),
              shrinkWrap: true,
            );
          } else if (renderType ==
              TransactionEntriesRenderType.implicitlyAnimatedNonSlivers) {
            return ListView(
              scrollDirection: Axis.vertical,
              children: widgetsOut,
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              padding: EdgeInsets.zero,
            );
          }
        } else {
          Widget ghostTransactions = Column(
            children: [
              for (int i = 0; i < 5 + random.nextInt(5); i++)
                GhostTransactions(
                  i: random.nextInt(100),
                  useHorizontalPaddingConstrained: true,
                ),
            ],
          );
          if (renderType == TransactionEntriesRenderType.slivers ||
              renderType ==
                  TransactionEntriesRenderType.implicitlyAnimatedSlivers) {
            return SliverToBoxAdapter(child: ghostTransactions);
          } else if (renderType == TransactionEntriesRenderType.nonSlivers ||
              renderType ==
                  TransactionEntriesRenderType.implicitlyAnimatedNonSlivers) {
            return ghostTransactions;
          }
        }
        return SizedBox.shrink();
      },
    );
  }
}

class Section implements ExpandableListSection<Widget> {
  late bool expanded;
  late List<Widget> items;
  late Widget header;

  @override
  List<Widget> getItems() {
    return items;
  }

  @override
  bool isSectionExpanded() {
    return expanded;
  }

  @override
  void setSectionExpanded(bool expanded) {
    this.expanded = expanded;
  }
}

class TransactionsEntriesSpendingSummary extends StatelessWidget {
  const TransactionsEntriesSpendingSummary({
    required this.show,
    required this.netSpending,
    required this.income,
    required this.expense,
    this.onLongPress,
    super.key,
  });

  final bool show;
  final double netSpending;
  final double income;
  final double expense;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    double borderRadius = getPlatform() == PlatformOS.isIOS ? 5 : 10;
    return AnimatedExpanded(
      axis: Axis.vertical,
      expand: show,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: getHorizontalPaddingConstrained(context) + 13,
          vertical: 5,
        ),
        child: OpenContainerNavigation(
          borderRadius: borderRadius,
          openPage: WalletDetailsPage(wallet: null),
          button: (openContainer) {
            return Tappable(
              borderRadius: borderRadius,
              color: appStateSettings["materialYou"]
                  ? dynamicPastel(
                      context, Theme.of(context).colorScheme.secondaryContainer,
                      amountDark: 0.5, amountLight: 0)
                  : getColor(context, "canvasContainer"),
              onTap: () {
                // setState(() {
                //   isExpanded = !isExpanded;
                // });
                openContainer();
              },
              onLongPress: onLongPress,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IncomeOutcomeArrow(
                            color: getColor(context, "expenseAmount"),
                            isIncome: false,
                            iconSize: 20,
                            width: 17,
                          ),
                          Flexible(
                            child: CountNumber(
                              count: expense.abs(),
                              duration: Duration(milliseconds: 450),
                              initialCount: (0),
                              textBuilder: (number) {
                                return TextFont(
                                  text: convertToMoney(
                                      Provider.of<AllWallets>(context), number,
                                      finalNumber: expense.abs()),
                                  fontSize: 15,
                                  textColor: getColor(context, "expenseAmount"),
                                  autoSizeText: true,
                                  minFontSize: 9,
                                  maxLines: 1,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IncomeOutcomeArrow(
                            color: getColor(context, "incomeAmount"),
                            isIncome: true,
                            iconSize: 20,
                            width: 17,
                          ),
                          Flexible(
                            child: CountNumber(
                              count: income.abs(),
                              duration: Duration(milliseconds: 450),
                              initialCount: (0),
                              textBuilder: (number) {
                                return TextFont(
                                  text: convertToMoney(
                                      Provider.of<AllWallets>(context), number,
                                      finalNumber: income.abs()),
                                  fontSize: 15,
                                  textColor: getColor(context, "incomeAmount"),
                                  autoSizeText: true,
                                  minFontSize: 9,
                                  maxLines: 1,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: CountNumber(
                              count: netSpending,
                              duration: Duration(milliseconds: 450),
                              initialCount: (0),
                              textBuilder: (number) {
                                return TextFont(
                                  text: "=" +
                                      " " +
                                      convertToMoney(
                                          Provider.of<AllWallets>(context),
                                          number,
                                          finalNumber: netSpending.abs()),
                                  fontSize: 15,
                                  textColor: getColor(context, "black"),
                                  autoSizeText: true,
                                  minFontSize: 9,
                                  maxLines: 1,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
