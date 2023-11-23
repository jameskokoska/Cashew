import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/upcomingOverdueTransactionsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/noResults.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/selectedTransactionsAppBar.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/slidingSelectorIncomeExpense.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry/transactionEntry.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budget/widgets/countNumber.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:implicitly_animated_reorderable_list/transitions.dart';
import 'package:budget/widgets/textInput.dart';

class CreditDebtTransactions extends StatefulWidget {
  const CreditDebtTransactions({required this.isCredit, super.key});
  final bool? isCredit;

  @override
  State<CreditDebtTransactions> createState() => _CreditDebtTransactionsState();
}

class _CreditDebtTransactionsState extends State<CreditDebtTransactions> {
  late bool? isCredit = widget.isCredit;
  String? searchValue;
  FocusNode _searchFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    String pageId = "CreditDebt";
    return WillPopScope(
      onWillPop: () async {
        if ((globalSelectedID.value[pageId] ?? []).length > 0) {
          globalSelectedID.value[pageId] = [];
          globalSelectedID.notifyListeners();
          return false;
        } else {
          return true;
        }
      },
      child: Stack(
        children: [
          PageFramework(
            resizeToAvoidBottomInset: true,
            floatingActionButton: AnimateFABDelayed(
              enabled: isCredit != null,
              fab: FAB(
                tooltip: isCredit == true ? "add-credit".tr() : "add-debt".tr(),
                openPage: AddTransactionPage(
                  selectedType: isCredit == true
                      ? TransactionSpecialType.credit
                      : TransactionSpecialType.debt,
                  routesToPopAfterDelete: RoutesToPopAfterDelete.None,
                ),
              ),
            ),
            listID: pageId,
            title: "loans".tr(),
            dragDownToDismiss: true,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: CenteredAmountAndNumTransactions(
                    numTransactionsStream:
                        database.watchCountOfCreditDebt(isCredit, searchValue),
                    totalAmountStream: database.watchTotalOfCreditDebt(
                      Provider.of<AllWallets>(context),
                      isCredit,
                      searchString: searchValue,
                    ),
                    showIncomeArrow: false,
                    getInitialText: (totalAmount) {
                      if (totalAmount < 0) {
                        return "you-get".tr();
                      } else if (totalAmount > 0) {
                        return "you-owe".tr();
                      } else {
                        return null;
                      }
                    },
                    textColor: isCredit == null
                        ? getColor(context, "black")
                        : isCredit == true
                            ? getColor(context, "unPaidUpcoming")
                            : getColor(context, "unPaidOverdue"),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: getHorizontalPaddingConstrained(context)),
                  child: Row(
                    children: [
                      SizedBox(width: 13),
                      Flexible(
                        child: AnimatedSize(
                          clipBehavior: Clip.none,
                          duration: Duration(milliseconds: 500),
                          child: SlidingSelectorIncomeExpense(
                            useHorizontalPaddingConstrained: false,
                            initialIndex: isCredit == null
                                ? 0
                                : isCredit == true
                                    ? 1
                                    : 2,
                            onSelected: (int index) {
                              if (index == 1)
                                isCredit = null;
                              else if (index == 2)
                                isCredit = true;
                              else if (index == 3) isCredit = false;
                              setState(() {});
                            },
                            options: ["all", "lent", "borrowed"],
                            customPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      AnimatedSizeSwitcher(
                        child: searchValue == null
                            ? Padding(
                                padding: const EdgeInsets.only(left: 7.0),
                                child: ButtonIcon(
                                  key: ValueKey(1),
                                  onTap: () {
                                    setState(() {
                                      searchValue = "";
                                    });
                                    _searchFocusNode.requestFocus();
                                  },
                                  icon: Icons.search,
                                ),
                              )
                            : Container(
                                key: ValueKey(2),
                              ),
                      ),
                      SizedBox(width: 13),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: getHorizontalPaddingConstrained(context)),
                  child: AnimatedExpanded(
                    expand: searchValue != null,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, top: 8),
                      child: TextInput(
                        labelText: "search-transactions-placeholder".tr(),
                        icon: appStateSettings["outlinedIcons"]
                            ? Icons.search_outlined
                            : Icons.search_rounded,
                        focusNode: _searchFocusNode,
                        onSubmitted: (value) {
                          setState(() {
                            searchValue = value == "" ? null : value;
                          });
                        },
                        onChanged: (value) {
                          setState(() {
                            searchValue = value == "" ? null : value;
                          });
                        },
                        autoFocus: false,
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: 10),
              ),
              StreamBuilder<List<Transaction>>(
                stream: database.watchAllCreditDebtTransactions(
                    isCredit, searchValue),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.length <= 0) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: NoResults(
                            message: "no-transactions-found".tr(),
                          ),
                        ),
                      );
                    }

                    return SliverImplicitlyAnimatedList<Transaction>(
                      items: snapshot.data!,
                      areItemsTheSame: (a, b) =>
                          a.transactionPk == b.transactionPk,
                      insertDuration: Duration(milliseconds: 500),
                      removeDuration: Duration(milliseconds: 500),
                      updateDuration: Duration(milliseconds: 500),
                      itemBuilder: (BuildContext context,
                          Animation<double> animation,
                          Transaction item,
                          int index) {
                        return SizeFadeTransition(
                          sizeFraction: 0.7,
                          curve: Curves.easeInOut,
                          animation: animation,
                          child: TransactionEntry(
                            openPage: AddTransactionPage(
                              transaction: item,
                              routesToPopAfterDelete:
                                  RoutesToPopAfterDelete.One,
                            ),
                            transaction: item,
                            listID: pageId,
                            key: ValueKey(item.transactionPk),
                            transactionAfter: nullIfIndexOutOfRange(
                                snapshot.data!, index + 1),
                            transactionBefore: nullIfIndexOutOfRange(
                                snapshot.data!, index - 1),
                          ),
                        );
                      },
                    );
                  } else {
                    return SliverToBoxAdapter();
                  }
                },
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: 75),
              ),
            ],
          ),
          SelectedTransactionsAppBar(
            pageID: pageId,
          ),
        ],
      ),
    );
  }
}
