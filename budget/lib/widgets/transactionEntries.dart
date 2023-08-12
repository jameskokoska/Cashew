import 'package:budget/database/tables.dart';
import 'package:budget/pages/transactionsSearchPage.dart';
import 'package:budget/widgets/dateDivider.dart';
import 'package:budget/widgets/openPopup.dart';
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
    this.categoryFks = const [],
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
    super.key,
  });

  final DateTime? startDay;
  final DateTime? endDay;
  final String search;
  final List<String> categoryFks;
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

  @override
  Widget build(BuildContext context) {
    Random random = new Random();
    return StreamBuilder<List<DateTime?>>(
      stream: database.getUniqueDates(
        start: startDay,
        end: endDay,
        search: search,
        categoryFks: categoryFks,
        walletFks: walletFks,
        income: income,
        budgetTransactionFilters: budgetTransactionFilters,
        memberTransactionFilters: memberTransactionFilters,
        member: member,
        onlyShowTransactionsBelongingToBudgetPk:
            onlyShowTransactionsBelongingToBudgetPk,
        budget: budget,
        limit: limit,
        searchFilters: searchFilters,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.length <= 0 && showNoResults == true) {
            if (slivers) {
              return SliverToBoxAdapter(
                child: NoResults(
                  message: noResultsMessage ??
                      "no-transactions-within-time-range".tr() + ".",
                  tintColor: colorScheme != null
                      ? colorScheme?.primary.withOpacity(0.6)
                      : null,
                  noSearchResultsVariation: noSearchResultsVariation,
                ),
              );
            } else {
              return NoResults(
                message: noResultsMessage ??
                    "no-transactions-within-time-range".tr() + ".",
                tintColor: colorScheme != null
                    ? colorScheme?.primary.withOpacity(0.6)
                    : null,
                noSearchResultsVariation: noSearchResultsVariation,
              );
            }
          }
          List<Widget> transactionsWidgets = [];
          DateTime previousDate = DateTime(1900);
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
            transactionsWidgets.add(
              StreamBuilder<List<TransactionWithCategory>>(
                stream: database.getTransactionCategoryWithDay(
                  date,
                  search: search,
                  categoryFks: categoryFks,
                  walletFks: walletFks,
                  income: income,
                  budgetTransactionFilters: budgetTransactionFilters,
                  memberTransactionFilters: memberTransactionFilters,
                  member: member,
                  onlyShowTransactionsBelongingToBudgetPk:
                      onlyShowTransactionsBelongingToBudgetPk,
                  searchFilters: searchFilters,
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
                            DateDivider(
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
                                return DateDivider(
                                  useHorizontalPaddingConstrained:
                                      useHorizontalPaddingConstrained,
                                  color: dateDividerColor,
                                  date: date,
                                  info: transactionList.length > 1
                                      ? convertToMoney(
                                          Provider.of<AllWallets>(context),
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
                                onSelected ??
                                    onSelected!(transaction, selected);
                              },
                              listID: listID,
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
                            ),
                          );
                        },
                      );
                    }
                    if (sticky) {
                      return SliverStickyHeader(
                        header: Transform.translate(
                          offset: Offset(0, -1),
                          child: appStateSettings["batterySaver"] == true ||
                                  simpleListRender == true
                              ? transactionList.length > 0
                                  ? DateDivider(
                                      useHorizontalPaddingConstrained:
                                          useHorizontalPaddingConstrained,
                                      color: dateDividerColor,
                                      key: ValueKey(date),
                                      date: date,
                                      info: transactionList.length > 1
                                          ? convertToMoney(
                                              Provider.of<AllWallets>(context),
                                              totalSpentForDay)
                                          : "")
                                  : SizedBox.shrink()
                              : AnimatedSize(
                                  duration: Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                  child: transactionList.length > 0
                                      ? AnimatedSwitcher(
                                          duration: Duration(milliseconds: 300),
                                          child: DateDivider(
                                              useHorizontalPaddingConstrained:
                                                  useHorizontalPaddingConstrained,
                                              color: dateDividerColor,
                                              key: ValueKey(date),
                                              date: date,
                                              info: transactionList.length > 1
                                                  ? convertToMoney(
                                                      Provider.of<AllWallets>(
                                                          context),
                                                      totalSpentForDay)
                                                  : ""),
                                        )
                                      : Container(
                                          key: ValueKey(2),
                                        ),
                                ),
                        ),
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
