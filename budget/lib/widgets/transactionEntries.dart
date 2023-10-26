import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/pages/pastBudgetsPage.dart';
import 'package:budget/pages/transactionsSearchPage.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/dateDivider.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
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

class TransactionEntriesMetaData {
  DateTime? startDay;
  DateTime? endDay;
  String search;
  List<String>? categoryFks;
  List<String>? categoryFksExclude;
  List<String> walletFks;
  Function(Transaction, bool)? onSelected;
  String? listID;
  bool? income;
  bool renderAsSlivers;
  List<BudgetTransactionFilters>? budgetTransactionFilters;
  List<String>? memberTransactionFilters;
  String? member;
  String? onlyShowTransactionsBelongingToBudgetPk;
  String? onlyShowTransactionsBelongingToObjectivePk;
  bool simpleListRender;
  Budget? budget;
  Color? dateDividerColor;
  Color? transactionBackgroundColor;
  Color? categoryTintColor;
  bool useHorizontalPaddingConstrained;
  int? limit;
  bool showNoResults;
  ColorScheme? colorScheme;
  bool noSearchResultsVariation;
  String? noResultsMessage;
  SearchFilters? searchFilters;
  int? pastDaysLimitToShow;
  bool includeDateDivider;
  bool allowSelect;
  bool showObjectivePercentage;
  EdgeInsets? noResultsPadding;
  Widget? noResultsExtraWidget;
  int? limitPerDay;

  TransactionEntriesMetaData(
    this.startDay,
    this.endDay, {
    this.search = "",
    this.categoryFks,
    this.categoryFksExclude,
    this.walletFks = const [],
    this.onSelected,
    this.listID,
    this.income,
    this.renderAsSlivers = true,
    this.budgetTransactionFilters,
    this.memberTransactionFilters,
    this.member,
    this.onlyShowTransactionsBelongingToBudgetPk,
    this.onlyShowTransactionsBelongingToObjectivePk,
    this.simpleListRender = false,
    this.budget,
    this.dateDividerColor,
    this.transactionBackgroundColor,
    this.categoryTintColor,
    this.useHorizontalPaddingConstrained = true,
    this.limit,
    this.showNoResults = true,
    this.colorScheme,
    this.noSearchResultsVariation = false,
    this.noResultsMessage,
    this.searchFilters,
    this.pastDaysLimitToShow,
    this.includeDateDivider = true,
    this.allowSelect = true,
    this.showObjectivePercentage = true,
    this.noResultsPadding,
    this.noResultsExtraWidget,
    this.limitPerDay,
  }) {}
}

List<Widget> getTransactionWidgets({
  required BuildContext context,
  required AsyncSnapshot<List<TransactionWithCategory>> snapshot,
  required TransactionEntriesMetaData m,
}) {
  if (snapshot.data != null && snapshot.hasData) {
    if (snapshot.data!.length > 0) {
      List<Widget> widgetsOut = [];
      int currentTotalIndex = 0;

      List<TransactionWithCategory> transactionListForDay = [];
      double totalSpentForDay = 0;
      DateTime? currentDate;
      int totalUniqueDays = 0;

      for (TransactionWithCategory transactionWithCategory
          in snapshot.data ?? []) {
        if (m.pastDaysLimitToShow != null &&
            totalUniqueDays > m.pastDaysLimitToShow!) break;

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
          if (transactionWithCategory.transaction.paid)
            totalSpentForDay += transactionWithCategory.transaction.amount *
                (amountRatioToPrimaryCurrencyGivenPk(
                        Provider.of<AllWallets>(context),
                        transactionWithCategory.transaction.walletFk) ??
                    0);
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
            Widget dateDividerWidget = m.includeDateDivider == false
                ? SizedBox.shrink()
                : DateDivider(
                    useHorizontalPaddingConstrained:
                        m.useHorizontalPaddingConstrained,
                    color: m.dateDividerColor,
                    date: currentTransactionDate,
                    info: transactionListForDay.length > 1
                        ? convertToMoney(
                            Provider.of<AllWallets>(context), totalSpentForDay)
                        : "");
            if (m.renderAsSlivers) {
              List<TransactionWithCategory> transactionListForDayCopy = [
                ...transactionListForDay
              ];
              Widget sliverList = m.simpleListRender
                  ? SliverList(
                      delegate: SliverChildBuilderDelegate(
                        childCount: transactionListForDayCopy.length,
                        (BuildContext context, int index) {
                          TransactionWithCategory item =
                              transactionListForDayCopy[index];
                          return createTransactionEntry(
                            transactionListForDay: transactionListForDayCopy,
                            item: item,
                            index: index,
                            m: m,
                          );
                        },
                      ),
                    )
                  : SliverImplicitlyAnimatedList<TransactionWithCategory>(
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
                            transactionListForDay: transactionListForDayCopy,
                            item: item,
                            index: index,
                            m: m,
                          ),
                        );
                      },
                    );
              widgetsOut.add(
                SliverStickyHeader(
                  header: Transform.translate(
                      offset: Offset(0, -1),
                      child: transactionListForDay.length > 0
                          ? m.includeDateDivider == false
                              ? SizedBox.shrink()
                              : dateDividerWidget
                          : SizedBox.shrink()),
                  sticky: true,
                  sliver: sliverList,
                ),
              );
            } else {
              // Render as non slivers
              widgetsOut.add(dateDividerWidget);
              for (int i = 0; i < transactionListForDay.length; i++) {
                TransactionWithCategory item = transactionListForDay[i];
                widgetsOut.add(
                  createTransactionEntry(
                    transactionListForDay: transactionListForDay,
                    item: item,
                    index: i,
                    m: m,
                  ),
                );
              }
            }

            currentDate = null;
            transactionListForDay = [];
            totalSpentForDay = 0;
          }
        }
        currentTotalIndex++;
      }
      return widgetsOut;
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
    if (m.renderAsSlivers) {
      return [SliverToBoxAdapter(child: ghostTransactions)];
    } else {
      return [ghostTransactions];
    }
  }

  Widget noResults = Column(
    children: [
      NoResults(
        message: m.noResultsMessage ??
            "no-transactions-within-time-range".tr() +
                "." +
                (m.budget != null
                    ? ("\n" +
                        "(" +
                        getWordedDateShortMore(m.startDay ?? DateTime.now()) +
                        " - " +
                        getWordedDateShortMore(m.endDay ?? DateTime.now()) +
                        ")")
                    : ""),
        tintColor: m.colorScheme != null
            ? m.colorScheme?.primary.withOpacity(0.6)
            : null,
        noSearchResultsVariation: m.noSearchResultsVariation,
        padding: m.noResultsPadding,
      ),
      if (m.noResultsExtraWidget != null) m.noResultsExtraWidget!,
    ],
  );
  if (m.renderAsSlivers) {
    return [SliverToBoxAdapter(child: noResults)];
  } else {
    return [noResults];
  }
}

Widget createTransactionEntry({
  required List<TransactionWithCategory> transactionListForDay,
  required TransactionWithCategory item,
  required int index,
  required TransactionEntriesMetaData m,
}) {
  return TransactionEntry(
    transactionBefore:
        nullIfIndexOutOfRange(transactionListForDay, index - 1)?.transaction,
    transactionAfter:
        nullIfIndexOutOfRange(transactionListForDay, index + 1)?.transaction,
    categoryTintColor: m.categoryTintColor,
    useHorizontalPaddingConstrained: m.useHorizontalPaddingConstrained,
    containerColor: m.transactionBackgroundColor,
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
      m.onSelected?.call(transaction, selected);
    },
    listID: m.listID,
    allowSelect: m.allowSelect,
    showObjectivePercentage: m.showObjectivePercentage,
  );
}

class TransactionEntries extends StatelessWidget {
  const TransactionEntries({
    required this.m,
    super.key,
  });
  final TransactionEntriesMetaData m;

  @override
  Widget build(BuildContext context) {
    return TransactionEntriesWatcher(
      m: m,
      transactionEntriesBuilder:
          (AsyncSnapshot<List<TransactionWithCategory>> snapshot) {
        List<Widget> widgetsOut = getTransactionWidgets(
          context: context,
          snapshot: snapshot,
          m: m,
        );
        if (m.renderAsSlivers) {
          return MultiSliver(children: widgetsOut);
        } else {
          return ListView(
            scrollDirection: Axis.vertical,
            children: widgetsOut,
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            padding: EdgeInsets.zero,
          );
        }
      },
    );
  }
}

class TransactionEntriesWatcher extends StatelessWidget {
  const TransactionEntriesWatcher({
    required this.m,
    required this.transactionEntriesBuilder,
    super.key,
  });
  final TransactionEntriesMetaData m;
  final Widget Function(AsyncSnapshot<List<TransactionWithCategory>> snapshot)
      transactionEntriesBuilder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TransactionWithCategory>>(
      stream: database.getTransactionCategoryWithDay(
        m.startDay,
        m.endDay,
        search: m.search,
        categoryFks: m.categoryFks,
        categoryFksExclude: m.categoryFksExclude,
        walletFks: m.walletFks,
        income: m.income,
        budgetTransactionFilters: m.budgetTransactionFilters,
        memberTransactionFilters: m.memberTransactionFilters,
        member: m.member,
        onlyShowTransactionsBelongingToBudgetPk:
            m.onlyShowTransactionsBelongingToBudgetPk,
        onlyShowTransactionsBelongingToObjectivePk:
            m.onlyShowTransactionsBelongingToObjectivePk,
        searchFilters: m.searchFilters,
        limit: m.limit,
        budget: m.budget,
      ),
      builder: (context, snapshot) {
        return transactionEntriesBuilder(snapshot);
      },
    );
  }
}
