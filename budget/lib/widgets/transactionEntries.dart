import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/pages/transactionFilters.dart';
import 'package:budget/pages/walletDetailsPage.dart';
import 'package:budget/struct/listenableSelector.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/countNumber.dart';
import 'package:budget/widgets/dateDivider.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry/incomeAmountArrow.dart';
import 'package:budget/widgets/transactionEntry/transactionEntry.dart';
import 'package:budget/widgets/viewAllTransactionsButton.dart';
import 'package:flutter/material.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/noResults.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/ghostTransactions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:implicitly_animated_reorderable_list/transitions.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:budget/struct/currencyFunctions.dart';
import 'package:budget/struct/randomConstants.dart';
import 'package:sticky_and_expandable_list/sticky_and_expandable_list.dart';
import 'package:budget/widgets/openBottomSheet.dart';

enum TransactionEntriesRenderType {
  slivers,
  sliversNotSticky,
  implicitlyAnimatedSlivers,
  nonSlivers,
  implicitlyAnimatedNonSlivers,
}

class TransactionEntries extends StatefulWidget {
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
    this.budgetTransactionFilters,
    this.memberTransactionFilters,
    this.member,
    this.onlyShowTransactionsBelongingToBudgetPk,
    this.budget,
    this.dateDividerColor,
    this.transactionBackgroundColor,
    this.categoryTintColor,
    this.useHorizontalPaddingConstrained = true,
    this.showNoResults = true,
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
    this.allowOpenIntoObjectiveLoanPage = true,
    this.showNumberOfDaysUntilForFutureDates = false,
    this.showExcludedBudgetTag,
    this.enableFutureTransactionsCollapse = true,
    this.initialLoadLimit,
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
  final List<BudgetTransactionFilters>? budgetTransactionFilters;
  final List<String>? memberTransactionFilters;
  final String? member;
  final String? onlyShowTransactionsBelongingToBudgetPk;
  final Budget? budget;
  final Color? dateDividerColor;
  final Color? transactionBackgroundColor;
  final Color? categoryTintColor;
  final bool useHorizontalPaddingConstrained;
  final int limit;
  final bool showNoResults;
  final bool noSearchResultsVariation;
  final String? noResultsMessage;
  final SearchFilters? searchFilters;
  final int? pastDaysLimitToShow;
  final bool includeDateDivider;
  final bool allowSelect;
  final bool showObjectivePercentage;
  final EdgeInsetsDirectional? noResultsPadding;
  final Widget? noResultsExtraWidget;
  final Widget? totalCashFlowExtraWidget;
  final int limitPerDay;
  final bool showTotalCashFlow;
  final bool enableSpendingSummary;
  final bool showSpendingSummary;
  final VoidCallback? onLongPressSpendingSummary;
  final bool allowOpenIntoObjectiveLoanPage;
  final bool showNumberOfDaysUntilForFutureDates;
  final bool Function(Transaction transaction)? showExcludedBudgetTag;
  final bool enableFutureTransactionsCollapse;
  // Note this limit restricts the net total calculation for the list!
  final int? initialLoadLimit;

  @override
  State<TransactionEntries> createState() => _TransactionEntriesState();
}

class _TransactionEntriesState extends State<TransactionEntries> {
  late bool loadAll =
      appStateSettings["restrictAmountOfInitiallyLoadedTransactions"] == true
          ? widget.initialLoadLimit == null
              ? true
              : false
          : true;

  Widget createTransactionEntry(
    List<TransactionWithCategory> transactionListForDay,
    TransactionWithCategory item,
    int index,
    bool enableFutureTransactionsDivider,
  ) {
    return TransactionEntry(
      transactionBefore:
          nullIfIndexOutOfRange(transactionListForDay, index - 1)?.transaction,
      transactionAfter:
          nullIfIndexOutOfRange(transactionListForDay, index + 1)?.transaction,
      categoryTintColor: widget.categoryTintColor,
      useHorizontalPaddingConstrained: widget.useHorizontalPaddingConstrained,
      containerColor: widget.transactionBackgroundColor,
      key: ValueKey(item.transaction.transactionPk),
      category: item.category,
      subCategory: item.subCategory,
      budget: item.budget,
      objective: item.objective,
      objectiveLoan: item.objectiveLoan,
      openPage: AddTransactionPage(
        transaction: item.transaction,
        routesToPopAfterDelete: RoutesToPopAfterDelete.One,
      ),
      transaction: item.transaction,
      onSelected: (Transaction transaction, bool selected) {
        widget.onSelected?.call(transaction, selected);
      },
      listID: widget.listID,
      allowSelect: widget.allowSelect,
      showObjectivePercentage: widget.showObjectivePercentage,
      allowOpenIntoObjectiveLoanPage: widget.allowOpenIntoObjectiveLoanPage,
      showExcludedBudgetTag: widget.showExcludedBudgetTag,
      enableFutureTransactionsDivider: enableFutureTransactionsDivider,
    );
  }

  Widget transactionEntryListBuilder(double? initialNetValue) {
    return StreamBuilder<List<TransactionWithCategory>>(
      stream: database.getTransactionCategoryWithDay(
        widget.startDay,
        widget.endDay,
        search: widget.search,
        categoryFks: widget.categoryFks,
        categoryFksExclude: widget.categoryFksExclude,
        walletFks: widget.walletFks,
        budgetTransactionFilters: widget.budgetTransactionFilters,
        memberTransactionFilters: widget.memberTransactionFilters,
        member: widget.member,
        onlyShowTransactionsBelongingToBudgetPk:
            widget.onlyShowTransactionsBelongingToBudgetPk,
        searchFilters: widget.searchFilters,
        limit: widget.limit,
        budget: widget.budget,
      ),
      builder: (context, snapshot) {
        if (snapshot.data != null && snapshot.hasData) {
          List<TransactionWithCategory> data = snapshot.data ?? [];
          int totalNumberTransactionsAll = data.length;
          if (loadAll == false)
            data = data.take(widget.initialLoadLimit ?? 30).toList();
          globalTransactionsListedOnPageID[widget.listID ?? ""] = data
              .map((t) => t.transaction.transactionPk)
              .take(maxSelectableTransactionsListedOnPage)
              .toList();
          List<Section> sectionsOut = [];
          List<Widget> widgetsOut = [];
          Widget totalCashFlowWidget = SizedBox.shrink();
          Widget viewAllTransactionsWidget = SizedBox.shrink();
          double netSpent = initialNetValue ?? 0;
          double totalSpent = 0;
          double totalIncome = 0;
          double totalExpense = 0;
          int totalNumberTransactions = data.length;
          Set<String> futureTransactionPks = (data
              .where((transactionWithCategory) => transactionWithCategory
                  .transaction.dateCreated
                  .justDay()
                  .isAfter(DateTime.now().justDay()))
              .map((transactionWithCategory) =>
                  transactionWithCategory.transaction.transactionPk)
              .toSet());

          bool enableFutureTransactionsDivider =
              widget.enableFutureTransactionsCollapse &&
                  futureTransactionPks.length >= 3;
          bool notYetAddedPastTransactionsDivider = true;

          if (totalNumberTransactions <= 0 &&
              (widget.showNoResults || widget.noResultsExtraWidget != null)) {
            Widget noResults = Column(
              children: [
                if (widget.showNoResults)
                  NoResults(
                    message: widget.noResultsMessage ??
                        "no-transactions-within-time-range".tr() +
                            "." +
                            (widget.budget != null
                                ? ("\n" +
                                    "(" +
                                    getWordedDateShortMore(
                                        widget.startDay ?? DateTime.now()) +
                                    " – " +
                                    getWordedDateShortMore(
                                        widget.endDay ?? DateTime.now()) +
                                    ")")
                                : ""),
                    tintColor:
                        Theme.of(context).colorScheme.primary.withOpacity(0.6),
                    noSearchResultsVariation: widget.noSearchResultsVariation,
                    padding: widget.noResultsPadding,
                  ),
                if (widget.noResultsExtraWidget != null)
                  widget.noResultsExtraWidget!,
              ],
            );
            if (widget.renderType == TransactionEntriesRenderType.slivers ||
                widget.renderType ==
                    TransactionEntriesRenderType.implicitlyAnimatedSlivers ||
                widget.renderType ==
                    TransactionEntriesRenderType.sliversNotSticky) {
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
            } else if (widget.renderType ==
                    TransactionEntriesRenderType.nonSlivers ||
                widget.renderType ==
                    TransactionEntriesRenderType.implicitlyAnimatedNonSlivers) {
              return noResults;
            }
          }
          int currentTotalIndex = 0;

          List<TransactionWithCategory> transactionListForDay = [];
          double totalSpentForDay = 0;
          double totalSpentForDayWithBalanceCorrection = 0;
          DateTime? currentDate;
          int totalPastUniqueDays = 0;

          for (TransactionWithCategory transactionWithCategory in data ?? []) {
            if (widget.pastDaysLimitToShow != null &&
                totalPastUniqueDays > widget.pastDaysLimitToShow!) break;

            DateTime currentTransactionDate =
                transactionWithCategory.transaction.dateCreated.justDay();
            if (currentDate == null) {
              currentDate = currentTransactionDate;
              if (currentDate.millisecondsSinceEpoch <
                  DateTime.now().millisecondsSinceEpoch) totalPastUniqueDays++;
            }
            if (currentDate == currentTransactionDate) {
              transactionListForDay.add(transactionWithCategory);
              if (transactionWithCategory.transaction.paid) {
                // Include balance correction when calculating the net
                totalSpentForDayWithBalanceCorrection +=
                    transactionWithCategory.transaction.amount *
                        (amountRatioToPrimaryCurrencyGivenPk(
                            Provider.of<AllWallets>(context),
                            transactionWithCategory.transaction.walletFk));
              }
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

            DateTime? nextTransactionDate = totalNumberTransactions ==
                    currentTotalIndex + 1
                ? null
                : data[currentTotalIndex + 1].transaction.dateCreated.justDay();

            if (nextTransactionDate == null ||
                nextTransactionDate != currentTransactionDate) {
              if (transactionListForDay.length > 0) {
                int daysDifference = DateTime.now()
                    .justDay()
                    .difference(currentTransactionDate)
                    .inDays;

                Widget? pastTransactionsDivider =
                    enableFutureTransactionsDivider &&
                            notYetAddedPastTransactionsDivider &&
                            currentTransactionDate
                                    .justDay()
                                    .isAfter(DateTime.now().justDay()) ==
                                false
                        ? PastTransactionsDivider(
                            listID: widget.listID,
                            useHorizontalPaddingConstrained:
                                widget.useHorizontalPaddingConstrained,
                          )
                        : null;

                if (pastTransactionsDivider != null)
                  notYetAddedPastTransactionsDivider = false;

                Widget dateDividerWidget = widget.includeDateDivider == false
                    ? SizedBox.shrink()
                    : CollapseFutureTransactions(
                        alwaysExpanded:
                            enableFutureTransactionsDivider == false,
                        dateToCompare: currentTransactionDate,
                        listID: widget.listID,
                        child: DateDivider(
                            useHorizontalPaddingConstrained:
                                widget.useHorizontalPaddingConstrained,
                            color: widget.dateDividerColor,
                            date: currentTransactionDate,
                            afterDate: daysDifference >= 0 ||
                                    widget.showNumberOfDaysUntilForFutureDates ==
                                        false
                                ? ""
                                : " • " +
                                    (daysDifference * -1).toString() +
                                    " " +
                                    (daysDifference * -1 == 1
                                        ? "day".tr()
                                        : "days".tr()),
                            info:
                                appStateSettings["netSpendingDayTotal"] == true
                                    ? convertToMoney(
                                        Provider.of<AllWallets>(context),
                                        netSpent,
                                      )
                                    : transactionListForDay.length > 1
                                        ? convertToMoney(
                                            Provider.of<AllWallets>(context),
                                            totalSpentForDay)
                                        : ""),
                      );

                if (widget.renderType == TransactionEntriesRenderType.slivers) {
                  if (pastTransactionsDivider != null) {
                    sectionsOut.add(
                      Section()
                        ..expanded = true
                        ..header = SizedBox()
                        ..items = [pastTransactionsDivider],
                    );
                  }
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
                          createTransactionEntry(
                              transactionListForDay,
                              transactionListForDay[index],
                              index,
                              enableFutureTransactionsDivider),
                      ],
                  );
                } else if (widget.renderType ==
                    TransactionEntriesRenderType.sliversNotSticky) {
                  if (pastTransactionsDivider != null) {
                    widgetsOut.add(pastTransactionsDivider);
                  }
                  widgetsOut.add(dateDividerWidget);
                  for (int index = 0;
                      index < transactionListForDay.length;
                      index++) {
                    widgetsOut.add(
                      createTransactionEntry(
                        transactionListForDay,
                        transactionListForDay[index],
                        index,
                        enableFutureTransactionsDivider,
                      ),
                    );
                  }
                } else if (widget.renderType ==
                    TransactionEntriesRenderType.implicitlyAnimatedSlivers) {
                  List<TransactionWithCategory> transactionListForDayCopy = [
                    ...transactionListForDay
                  ];
                  if (pastTransactionsDivider != null)
                    widgetsOut.add(
                        SliverToBoxAdapter(child: pastTransactionsDivider));
                  widgetsOut.add(
                    SliverStickyHeader(
                      header: Transform.translate(
                          offset: Offset(0, -1),
                          child: transactionListForDay.length > 0
                              ? widget.includeDateDivider == false
                                  ? SizedBox.shrink()
                                  : dateDividerWidget
                              : SizedBox.shrink()),
                      sticky: true,
                      sliver:
                          SliverImplicitlyAnimatedList<TransactionWithCategory>(
                        spawnIsolate: false,
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
                                transactionListForDayCopy,
                                item,
                                index,
                                enableFutureTransactionsDivider),
                          );
                        },
                      ),
                    ),
                  );
                } else if (widget.renderType ==
                        TransactionEntriesRenderType.nonSlivers ||
                    widget.renderType ==
                        TransactionEntriesRenderType
                            .implicitlyAnimatedNonSlivers) {
                  if (pastTransactionsDivider != null)
                    widgetsOut.add(pastTransactionsDivider);
                  widgetsOut.add(dateDividerWidget);
                  for (int i = 0; i < transactionListForDay.length; i++) {
                    TransactionWithCategory item = transactionListForDay[i];
                    widgetsOut.add(createTransactionEntry(transactionListForDay,
                        item, i, enableFutureTransactionsDivider));
                  }
                }

                currentDate = null;
                transactionListForDay = [];
                totalSpent += totalSpentForDayWithBalanceCorrection;
                netSpent = netSpent - totalSpentForDayWithBalanceCorrection;
                totalSpentForDay = 0;
                totalSpentForDayWithBalanceCorrection = 0;
              }
            }
            currentTotalIndex++;
          }

          if (widget.showTotalCashFlow) {
            totalCashFlowWidget = Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: 10,
                        end: 10,
                        top: 13,
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
                    if (widget.totalCashFlowExtraWidget != null)
                      widget.totalCashFlowExtraWidget!,
                  ],
                ),
              ],
            );
            if (widget.renderType != TransactionEntriesRenderType.slivers) {
              widgetsOut.add(totalCashFlowWidget);
            }
          }

          if (totalNumberTransactionsAll > totalNumberTransactions)
            viewAllTransactionsWidget = Padding(
              padding: EdgeInsetsDirectional.only(top: 7),
              child: Center(
                child: ViewAllTransactionsButton(
                  onPress: () {
                    setState(() {
                      loadAll = true;
                    });
                  },
                ),
              ),
            );
          if (widget.renderType != TransactionEntriesRenderType.slivers) {
            widgetsOut.add(viewAllTransactionsWidget);
          }

          Widget futureTransactionsDivider = enableFutureTransactionsDivider
              ? Padding(
                  padding: widget.enableSpendingSummary
                      ? const EdgeInsetsDirectional.only(top: 5)
                      : EdgeInsetsDirectional.zero,
                  child: FutureTransactionsDivider(
                    listID: widget.listID,
                    futureTransactionPks: futureTransactionPks,
                    useHorizontalPaddingConstrained:
                        widget.useHorizontalPaddingConstrained,
                  ),
                )
              : SizedBox.shrink();

          widgetsOut.insert(0, futureTransactionsDivider);

          if (widget.enableSpendingSummary)
            widgetsOut.insert(
              0,
              TransactionsEntriesSpendingSummary(
                show: widget.showSpendingSummary,
                netSpending: totalIncome + totalExpense,
                income: totalIncome,
                expense: totalExpense,
                onLongPress: widget.onLongPressSpendingSummary,
                dateTimeRange: widget.startDay != null && widget.endDay != null
                    ? DateTimeRange(
                        start: widget.startDay!, end: widget.endDay!)
                    : null,
              ),
            );

          if (widget.renderType == TransactionEntriesRenderType.slivers) {
            return MultiSliver(
              children: [
                SliverToBoxAdapter(child: futureTransactionsDivider),
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
                SliverToBoxAdapter(
                  child: viewAllTransactionsWidget,
                ),
              ],
            );
          } else if (widget.renderType ==
              TransactionEntriesRenderType.sliversNotSticky) {
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return widgetsOut[index];
                },
                childCount: widgetsOut.length,
                addAutomaticKeepAlives: false,
              ),
            );
          } else if (widget.renderType ==
              TransactionEntriesRenderType.implicitlyAnimatedSlivers) {
            return MultiSliver(children: widgetsOut);
          } else if (widget.renderType ==
              TransactionEntriesRenderType.implicitlyAnimatedNonSlivers) {
            return ImplicitlyAnimatedList<Widget>(
              spawnIsolate: false,
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
          } else if (widget.renderType ==
              TransactionEntriesRenderType.nonSlivers) {
            return ListView(
              scrollDirection: Axis.vertical,
              children: widgetsOut,
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              padding: EdgeInsetsDirectional.zero,
            );
          }
        } else {
          Widget ghostTransactions = Column(
            children: [
              for (int i = 0; i < 5 + random.nextInt(5); i++)
                GhostTransactions(
                  i: random.nextInt(100),
                  useHorizontalPaddingConstrained:
                      widget.useHorizontalPaddingConstrained,
                ),
            ],
          );
          if (widget.renderType == TransactionEntriesRenderType.slivers ||
              widget.renderType ==
                  TransactionEntriesRenderType.implicitlyAnimatedSlivers ||
              widget.renderType ==
                  TransactionEntriesRenderType.sliversNotSticky) {
            return SliverToBoxAdapter(child: ghostTransactions);
          } else if (widget.renderType ==
                  TransactionEntriesRenderType.nonSlivers ||
              widget.renderType ==
                  TransactionEntriesRenderType.implicitlyAnimatedNonSlivers) {
            return ghostTransactions;
          }
        }
        return SizedBox.shrink();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (appStateSettings["netSpendingDayTotal"] == false)
      return transactionEntryListBuilder(null);
    return StreamBuilder<double?>(
      // Use a reference point and subtract the totals of the transactions from this reference point to
      // get the net at that point in time
      //
      // Ideally we refactor all the queries so they only rely on the search filters!

      stream: database.watchTotalNetBeforeStartDateTransactionCategoryWithDay(
        end: widget.endDay == null &&
                widget.searchFilters?.dateTimeRange?.end == null
            ? null
            : (widget.endDay ??
                    widget.searchFilters?.dateTimeRange?.end ??
                    DateTime.now())
                //Add one because want the total from the start of the next day because we get everything BEFORE this date,
                // Only add one if not a budget! because a different query is used if it is a budget
                .justDay(dayOffset: widget.budget == null ? 1 : 0),
        start: widget.startDay,
        allWallets: Provider.of<AllWallets>(context),
        search: widget.search,
        categoryFks: widget.categoryFks,
        categoryFksExclude: widget.categoryFksExclude,
        walletFks: widget.walletFks,
        budgetTransactionFilters: widget.budgetTransactionFilters,
        memberTransactionFilters: widget.memberTransactionFilters,
        member: widget.member,
        onlyShowTransactionsBelongingToBudgetPk:
            widget.onlyShowTransactionsBelongingToBudgetPk,
        searchFilters: widget.searchFilters,
        limit: widget.limit,
        budget: widget.budget,
      ),
      builder: (context, snapshotNetTotal) {
        if (snapshotNetTotal.hasData == false) if (widget.renderType ==
                TransactionEntriesRenderType.slivers ||
            widget.renderType ==
                TransactionEntriesRenderType.implicitlyAnimatedSlivers ||
            widget.renderType == TransactionEntriesRenderType.sliversNotSticky)
          return SliverToBoxAdapter(
            child: SizedBox.shrink(),
          );
        else
          return SizedBox.shrink();
        return transactionEntryListBuilder(snapshotNetTotal.data);
      },
    );
  }
}

class PastTransactionsDivider extends StatelessWidget {
  const PastTransactionsDivider(
      {required this.listID,
      required this.useHorizontalPaddingConstrained,
      super.key});
  final String? listID;
  final bool useHorizontalPaddingConstrained;

  @override
  Widget build(BuildContext context) {
    Color color = appStateSettings["materialYou"]
        ? dynamicPastel(
            context, Theme.of(context).colorScheme.secondaryContainer,
            amountDark: 0.5, amountLight: 0)
        : getColor(context, "canvasContainer");
    return ValueListenableBuilder(
        valueListenable: globalCollapsedFutureID
            .select((controller) => controller.value[listID ?? "0"]),
        builder: (context, _, __) {
          return AnimatedPadding(
            duration: const Duration(milliseconds: 425),
            curve: Curves.fastOutSlowIn,
            padding: EdgeInsetsDirectional.only(
              top: globalCollapsedFutureID.value[listID ?? "0"] == true ? 0 : 8,
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.only(bottom: 3),
              child: Tappable(
                color: color,
                child: Padding(
                  padding: EdgeInsetsDirectional.symmetric(
                    horizontal: useHorizontalPaddingConstrained == false
                        ? 0
                        : getHorizontalPaddingConstrained(context),
                  ),
                  child: Padding(
                    padding: EdgeInsetsDirectional.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFont(
                            text: "past-transactions".tr(),
                            maxLines: 1,
                            textAlign: TextAlign.start,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }
}

class FutureTransactionsDivider extends StatelessWidget {
  const FutureTransactionsDivider(
      {required this.listID,
      required this.futureTransactionPks,
      required this.useHorizontalPaddingConstrained,
      super.key});
  final String? listID;
  final Set<String> futureTransactionPks;
  final bool useHorizontalPaddingConstrained;

  @override
  Widget build(BuildContext context) {
    Color color = appStateSettings["materialYou"]
        ? dynamicPastel(
            context, Theme.of(context).colorScheme.secondaryContainer,
            amountDark: 0.5, amountLight: 0)
        : getColor(context, "canvasContainer");
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 3),
      child: Tappable(
        onTap: () {
          toggleFutureTransactionsSection(listID);
        },
        color: color,
        child: Padding(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: useHorizontalPaddingConstrained == false
                ? 0
                : getHorizontalPaddingConstrained(context),
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.only(start: 16),
            child: ValueListenableBuilder(
                valueListenable: globalCollapsedFutureID
                    .select((controller) => controller.value[listID ?? "0"]),
                builder: (context, _, __) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFont(
                                text: "future-transactions".tr(),
                                maxLines: 1,
                                textAlign: TextAlign.start,
                                fontSize: 15,
                              ),
                            ),
                            ValueListenableBuilder(
                                valueListenable: globalSelectedID.select(
                                    (controller) =>
                                        (controller.value[listID] ?? [])
                                            .length),
                                builder: (context, _, __) {
                                  int count = (globalSelectedID.value[listID] ??
                                          [])
                                      .where((item) =>
                                          futureTransactionPks.contains(item))
                                      .length;

                                  return AnimatedOpacity(
                                    key: ValueKey("HiddenText"),
                                    duration: const Duration(milliseconds: 425),
                                    opacity: globalCollapsedFutureID
                                                .value[listID ?? "0"] ==
                                            true
                                        ? 1
                                        : 0,
                                    child: AnimatedSizeSwitcher(
                                      child: count > 0
                                          ? TextFont(
                                              key: ValueKey("SelectedText"),
                                              text: addAmountToString(
                                                "",
                                                count,
                                                extraText: "selected".tr(),
                                                addCommaWithExtraText: false,
                                              ),
                                              maxLines: 1,
                                              textAlign: TextAlign.start,
                                              fontSize: 14,
                                              textColor:
                                                  getColor(context, "black"),
                                            )
                                          : TextFont(
                                              text: addAmountToString(
                                                "",
                                                futureTransactionPks.length,
                                                extraText: "hidden".tr(),
                                                addCommaWithExtraText: false,
                                              ),
                                              maxLines: 1,
                                              textAlign: TextAlign.start,
                                              fontSize: 14,
                                              textColor: getColor(
                                                  context, "textLight"),
                                            ),
                                    ),
                                  );
                                }),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                            top: 2, bottom: 2, start: 8, end: 2),
                        child: Tappable(
                          onTap: () {
                            toggleFutureTransactionsSection(listID);
                          },
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? 0.1
                                  : 0.2),
                          borderRadius: 5,
                          child: Padding(
                            padding: const EdgeInsetsDirectional.symmetric(
                                horizontal: 10),
                            child: AnimatedRotation(
                              turns: globalCollapsedFutureID
                                          .value[listID ?? "0"] ==
                                      true
                                  ? 0
                                  : 0.5,
                              duration: const Duration(milliseconds: 425),
                              curve: Curves.fastOutSlowIn,
                              child: Icon(
                                appStateSettings["outlinedIcons"]
                                    ? Icons.arrow_drop_down_outlined
                                    : Icons.arrow_drop_down_rounded,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
          ),
        ),
      ),
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
    required this.dateTimeRange,
    this.onLongPress,
    super.key,
  });

  final bool show;
  final double netSpending;
  final double income;
  final double expense;
  final DateTimeRange? dateTimeRange;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    double borderRadius = getPlatform() == PlatformOS.isIOS ? 5 : 10;
    return AnimatedExpanded(
      axis: Axis.vertical,
      expand: show,
      child: Padding(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: getHorizontalPaddingConstrained(context) + 13,
          vertical: 5,
        ),
        child: OpenContainerNavigation(
          borderRadius: borderRadius,
          openPage: WalletDetailsPage(
            wallet: null,
            initialSearchFilters: SearchFilters(
              dateTimeRange: dateTimeRange,
            ),
          ),
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
                padding: const EdgeInsetsDirectional.symmetric(
                    vertical: 5, horizontal: 5),
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
