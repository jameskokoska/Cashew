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
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:implicitly_animated_reorderable_list/transitions.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'dart:math';
import 'package:budget/struct/currencyFunctions.dart';

class TransactionEntries extends StatelessWidget {
  const TransactionEntries(
    this.startDay,
    this.endDay, {
    this.search = "",
    this.categoryFks,
    this.categoryFksExclude,
    this.walletFks = const [],
    this.onSelected,
    this.listID,
    this.income,
    this.sticky = true,
    this.slivers = true,
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
    super.key,
  });

  final DateTime? startDay;
  final DateTime? endDay;
  final String search;
  final List<String>? categoryFks;
  final List<String>? categoryFksExclude;
  final List<String> walletFks;
  final Function(Transaction, bool)? onSelected;
  final String? listID;
  final bool? income;
  final bool sticky;
  final bool slivers;
  final List<BudgetTransactionFilters>? budgetTransactionFilters;
  final List<String>? memberTransactionFilters;
  final String? member;
  final String? onlyShowTransactionsBelongingToBudgetPk;
  final String? onlyShowTransactionsBelongingToObjectivePk;
  final bool simpleListRender;
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
  final int? limitPerDay;

  @override
  Widget build(BuildContext context) {
    Random random = new Random();
    return StreamBuilder<List<DateTime?>>(
      stream: database.getUniqueDates(
        start: startDay,
        end: endDay,
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
        budget: budget,
        limit: limit,
        searchFilters: searchFilters,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.length <= 0 && showNoResults == true) {
            Widget noResults = Column(
              children: [
                NoResults(
                  message: noResultsMessage ??
                      "no-transactions-within-time-range".tr() +
                          "." +
                          (budget != null
                              ? ("\n" +
                                  "(" +
                                  getWordedDateShortMore(
                                      startDay ?? DateTime.now()) +
                                  " - " +
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
            if (slivers) {
              return SliverToBoxAdapter(child: noResults);
            } else {
              return noResults;
            }
          }
          List<Widget> transactionsWidgets = [];
          DateTime previousDate = DateTime(1900);
          int count = 0;
          for (DateTime? dateNullable in snapshot.data!.reversed) {
            DateTime date = dateNullable ?? DateTime.now();
            if (previousDate.day == date.day &&
                previousDate.month == date.month &&
                previousDate.year == date.year) {
              continue;
            }
            // return SliverToBoxAdapter(
            //   child: GhostTransactions(i: random.nextInt(100)),
            // );
            previousDate = date;

            if (pastDaysLimitToShow != null && pastDaysLimitToShow! <= count) {
              continue;
            }

            count++;

            transactionsWidgets.add(
              StreamBuilder<List<TransactionWithCategory>>(
                stream: database.getTransactionCategoryWithDay(
                  date,
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
                  limit: limitPerDay,
                ),
                builder: (context, snapshot) {
                  if (snapshot.data != null && snapshot.hasData) {
                    if (slivers == false && snapshot.data!.length <= 0) {
                      return SizedBox.shrink();
                    }
                    List<TransactionWithCategory> transactionList =
                        snapshot.data!.reversed.toList();
                    double totalSpentForDay = 0;
                    transactionList.forEach((transaction) {
                      if (transaction.transaction.paid)
                        totalSpentForDay += transaction.transaction.amount *
                            (amountRatioToPrimaryCurrencyGivenPk(
                                    Provider.of<AllWallets>(context),
                                    transaction.transaction.walletFk) ??
                                0);
                    });
                    if (slivers == false) {
                      List<Widget> children = [];
                      for (int index = 0;
                          index < transactionList.length + 1;
                          index++) {
                        int realIndex = index - 1;
                        if (realIndex == -1) {
                          children.add(
                            includeDateDivider == false
                                ? SizedBox.shrink()
                                : DateDivider(
                                    useHorizontalPaddingConstrained:
                                        useHorizontalPaddingConstrained,
                                    color: dateDividerColor,
                                    date: date,
                                    info: transactionList.length > 1
                                        ? convertToMoney(
                                            Provider.of<AllWallets>(context),
                                            totalSpentForDay)
                                        : "",
                                  ),
                          );
                        } else {
                          children.add(
                            AnimatedSwitcher(
                              duration: Duration(milliseconds: 300),
                              child: TransactionEntry(
                                transactionBefore: nullIfIndexOutOfRange(
                                        transactionList, realIndex - 1)
                                    ?.transaction,
                                transactionAfter: nullIfIndexOutOfRange(
                                        transactionList, realIndex + 1)
                                    ?.transaction,
                                categoryTintColor: categoryTintColor,
                                useHorizontalPaddingConstrained:
                                    useHorizontalPaddingConstrained,
                                containerColor: transactionBackgroundColor,
                                key: ValueKey(transactionList[realIndex]
                                    .transaction
                                    .transactionPk),
                                category: transactionList[realIndex].category,
                                subCategory:
                                    transactionList[realIndex].subCategory,
                                budget: transactionList[realIndex].budget,
                                objective: transactionList[realIndex].objective,
                                openPage: AddTransactionPage(
                                  transaction:
                                      transactionList[realIndex].transaction,
                                  routesToPopAfterDelete:
                                      RoutesToPopAfterDelete.One,
                                ),
                                transaction:
                                    transactionList[realIndex].transaction,
                                onSelected:
                                    (Transaction transaction, bool selected) {
                                  if (onSelected != null)
                                    onSelected!(transaction, selected);
                                },
                                listID: listID,
                                allowSelect: allowSelect,
                                showObjectivePercentage:
                                    showObjectivePercentage,
                              ),
                            ),
                          );
                        }
                      }
                      return Column(
                        children: children,
                      );
                    }
                    Widget sliverList;
                    if (appStateSettings["batterySaver"] == true ||
                        simpleListRender == true) {
                      sliverList = SliverList(
                        delegate: SliverChildBuilderDelegate(
                          childCount: transactionList.length + 1,
                          (BuildContext context, int index) {
                            int realIndex = index - 1;
                            if (realIndex == -1) {
                              if (sticky)
                                return SizedBox.shrink();
                              else
                                return includeDateDivider == false
                                    ? SizedBox.shrink()
                                    : DateDivider(
                                        useHorizontalPaddingConstrained:
                                            useHorizontalPaddingConstrained,
                                        color: dateDividerColor,
                                        date: date,
                                        info: transactionList.length > 1
                                            ? convertToMoney(
                                                Provider.of<AllWallets>(
                                                    context),
                                                totalSpentForDay)
                                            : "",
                                      );
                            }
                            return TransactionEntry(
                              transactionBefore: nullIfIndexOutOfRange(
                                      transactionList, realIndex - 1)
                                  ?.transaction,
                              transactionAfter: nullIfIndexOutOfRange(
                                      transactionList, realIndex + 1)
                                  ?.transaction,
                              categoryTintColor: categoryTintColor,
                              useHorizontalPaddingConstrained:
                                  useHorizontalPaddingConstrained,
                              containerColor: transactionBackgroundColor,
                              key: ValueKey(transactionList[realIndex]
                                  .transaction
                                  .transactionPk),
                              category: transactionList[realIndex].category,
                              subCategory:
                                  transactionList[realIndex].subCategory,
                              budget: transactionList[realIndex].budget,
                              objective: transactionList[realIndex].objective,
                              openPage: AddTransactionPage(
                                transaction:
                                    transactionList[realIndex].transaction,
                                routesToPopAfterDelete:
                                    RoutesToPopAfterDelete.One,
                              ),
                              transaction:
                                  transactionList[realIndex].transaction,
                              onSelected:
                                  (Transaction transaction, bool selected) {
                                if (onSelected != null)
                                  onSelected!(transaction, selected);
                              },
                              listID: listID,
                              allowSelect: allowSelect,
                              showObjectivePercentage: showObjectivePercentage,
                            );
                          },
                        ),
                      );
                    } else {
                      sliverList =
                          SliverImplicitlyAnimatedList<TransactionWithCategory>(
                        items: transactionList,
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
                            child: TransactionEntry(
                              transactionBefore: nullIfIndexOutOfRange(
                                      transactionList, index - 1)
                                  ?.transaction,
                              transactionAfter: nullIfIndexOutOfRange(
                                      transactionList, index + 1)
                                  ?.transaction,
                              categoryTintColor: categoryTintColor,
                              useHorizontalPaddingConstrained:
                                  useHorizontalPaddingConstrained,
                              containerColor: transactionBackgroundColor,
                              key: ValueKey(item.transaction.transactionPk),
                              category: item.category,
                              subCategory: item.subCategory,
                              budget: item.budget,
                              objective: item.objective,
                              openPage: AddTransactionPage(
                                transaction: item.transaction,
                                routesToPopAfterDelete:
                                    RoutesToPopAfterDelete.One,
                              ),
                              transaction: item.transaction,
                              onSelected:
                                  (Transaction transaction, bool selected) {
                                onSelected?.call(transaction, selected);
                              },
                              listID: listID,
                              allowSelect: allowSelect,
                              showObjectivePercentage: showObjectivePercentage,
                            ),
                          );
                        },
                      );
                    }
                    if (sticky) {
                      return SliverStickyHeader(
                        header: Transform.translate(
                            offset: Offset(0, -1),
                            child: transactionList.length > 0
                                ? includeDateDivider == false
                                    ? SizedBox.shrink()
                                    : DateDivider(
                                        useHorizontalPaddingConstrained:
                                            useHorizontalPaddingConstrained,
                                        color: dateDividerColor,
                                        date: date,
                                        info: transactionList.length > 1
                                            ? convertToMoney(
                                                Provider.of<AllWallets>(
                                                    context),
                                                totalSpentForDay)
                                            : "")
                                : SizedBox.shrink()),
                        sticky: true,
                        sliver: sliverList,
                      );
                    } else {
                      return sliverList;
                    }
                  }
                  if (slivers == false) {
                    return GhostTransactions(
                      i: random.nextInt(100),
                      useHorizontalPaddingConstrained: true,
                    );
                  }
                  return SliverToBoxAdapter(
                    child: GhostTransactions(
                      i: random.nextInt(100),
                      useHorizontalPaddingConstrained: true,
                    ),
                  );
                },
              ),
            );
          }
          if (slivers) {
            return MultiSliver(
              children: transactionsWidgets,
            );
          } else {
            return Column(
              children: transactionsWidgets,
            );
          }
        }
        if (slivers) {
          return SliverToBoxAdapter(child: SizedBox.shrink());
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }
}
