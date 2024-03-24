import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addObjectivePage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/editObjectivesPage.dart';
import 'package:budget/pages/objectivesListPage.dart';
import 'package:budget/pages/upcomingOverdueTransactionsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/extraInfoBoxes.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/incomeExpenseTabSelector.dart';
import 'package:budget/widgets/listItem.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/noResults.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/outlinedButtonStacked.dart';
import 'package:budget/widgets/selectedTransactionsAppBar.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/slidingSelectorIncomeExpense.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry/transactionEntry.dart';
import 'package:budget/widgets/util/sliverPinnedOverlapInjector.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budget/widgets/countNumber.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:implicitly_animated_reorderable_list/transitions.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:sliver_tools/sliver_tools.dart';

class CreditDebtTransactions extends StatefulWidget {
  const CreditDebtTransactions({required this.isCredit, super.key});
  final bool? isCredit;

  @override
  State<CreditDebtTransactions> createState() => CreditDebtTransactionsState();
}

class CreditDebtTransactionsState extends State<CreditDebtTransactions>
    with SingleTickerProviderStateMixin {
  String pageId = "CreditDebt";
  late ScrollController _scrollController = ScrollController();
  late TabController _tabController = TabController(
    length: 2,
    vsync: this,
    initialIndex: appStateSettings["loansLastPage"] == 1 ? 1 : 0,
  );

  late bool? isCredit = widget.isCredit;
  String? searchValue;
  FocusNode _searchFocusNode = FocusNode();
  int? numberLongTerm;
  GlobalKey<PageFrameworkState> pageState = GlobalKey();

  void scrollToTop() {
    pageState.currentState?.scrollToTop();
  }

  @override
  void initState() {
    _tabController.addListener(onTabController);
    super.initState();
  }

  void onTabController() {
    updateSettings(
      "loansLastPage",
      _tabController.index == 1 ? 1 : 0,
      updateGlobalState: false,
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(onTabController);
    _tabController.dispose();
    // PageFramework takes care of the dispose lifecycle
    // _scrollController.dispose();
    super.dispose();
  }

  List<Widget> oneTimeLoanList(bool hasSomeLongTermLoans) {
    return [
      StreamBuilder<List<Transaction>>(
        stream: database.watchAllCreditDebtTransactions(isCredit, searchValue),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.length <= 0) {
              return SliverToBoxAdapter(
                child: Center(
                  child: Column(
                    children: [
                      NoResults(
                        message: "no-transactions-found".tr(),
                      ),
                      if (hasSomeLongTermLoans)
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: ExtraInfoButton(
                            onTap: () {
                              _tabController.animateTo(1);
                            },
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer
                                .withOpacity(0.4),
                            icon: appStateSettings["outlinedIcons"]
                                ? Icons.av_timer_outlined
                                : Icons.av_timer_rounded,
                            text: "view-long-term-loans".tr(),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }

            return SliverImplicitlyAnimatedList<Transaction>(
              items: snapshot.data!,
              areItemsTheSame: (a, b) => a.transactionPk == b.transactionPk,
              insertDuration: Duration(milliseconds: 500),
              removeDuration: Duration(milliseconds: 500),
              updateDuration: Duration(milliseconds: 500),
              itemBuilder: (BuildContext context, Animation<double> animation,
                  Transaction item, int index) {
                return SizeFadeTransition(
                  sizeFraction: 0.7,
                  key: ValueKey(item.transactionPk),
                  curve: Curves.easeInOut,
                  animation: animation,
                  child: TransactionEntry(
                    openPage: AddTransactionPage(
                      transaction: item,
                      routesToPopAfterDelete: RoutesToPopAfterDelete.One,
                    ),
                    transaction: item,
                    listID: "CreditDebt",
                    key: ValueKey(item.transactionPk),
                    transactionAfter:
                        nullIfIndexOutOfRange(snapshot.data!, index + 1),
                    transactionBefore:
                        nullIfIndexOutOfRange(snapshot.data!, index - 1),
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
    ];
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> longTermLoansList = [
      ObjectiveList(
        showExamplesIfEmpty: false,
        objectiveType: ObjectiveType.loan,
        showAddButton: true,
        searchFor: searchValue,
        isIncome: isCredit,
      ),
    ];

    List<Widget> loanInfoAppBar = [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: CenteredAmountAndNumTransactions(
            totalWithCountStream: database.watchTotalWithCountOfCreditDebt(
              allWallets: Provider.of<AllWallets>(context),
              isCredit: isCredit,
              searchString: searchValue,
              selectedTab: _tabController.index,
            ),
            totalWithCountStream2:
                database.watchTotalWithCountOfCreditDebtLongTermLoansOffset(
              allWallets: Provider.of<AllWallets>(context),
              isCredit: isCredit,
              searchString: searchValue,
              selectedTab: _tabController.index,
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
            getTextColor: (totalAmount) {
              return isCredit == null
                  ? totalAmount == 0
                      ? getColor(context, "black")
                      : totalAmount < 0
                          ? getColor(context, "unPaidUpcoming")
                          : getColor(context, "unPaidOverdue")
                  : isCredit == true
                      ? getColor(context, "unPaidUpcoming")
                      : getColor(context, "unPaidOverdue");
            },
            textColor: Colors.black,
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
              padding: const EdgeInsets.only(top: 8),
              child: TextInput(
                labelText: "search-loans-placeholder".tr(),
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
    ];

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
            key: pageState,
            scrollController: _scrollController,
            resizeToAvoidBottomInset: true,
            floatingActionButton: AnimateFABDelayed(
              enabled: true,
              fab: AddFAB(
                tooltip: isCredit == true || isCredit == null
                    ? "add-credit".tr()
                    : "add-debt".tr(),
                onTap: () {
                  openBottomSheet(
                    context,
                    AddLoanPopup(
                      selectedTransactionType:
                          isCredit == true || isCredit == null
                              ? TransactionSpecialType.credit
                              : TransactionSpecialType.debt,
                    ),
                  );
                },
              ),
            ),
            listID: pageId,
            title: "loans".tr(),
            dragDownToDismiss: true,
            bodyBuilder: (scrollController, scrollPhysics, sliverAppBar) {
              return StreamBuilder<List<Objective?>>(
                stream: database.watchAllObjectives(
                  objectiveType: ObjectiveType.loan,
                  hideArchived: true,
                  showDifferenceLoans: null,
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasData == false) return SizedBox.shrink();
                  if ((snapshot.data?.length ?? 0) <= 0) {
                    numberLongTerm = 0;
                    _tabController.index = 0;
                    return CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        sliverAppBar,
                        ...loanInfoAppBar,
                        ...oneTimeLoanList(false)
                      ],
                    );
                  }
                  // Set the tab to long term if none were added previously, but one was added
                  if (numberLongTerm == 0) {
                    _tabController.index = 1;
                    numberLongTerm = snapshot.data?.length ?? 0;
                  }
                  return NestedScrollView(
                    controller: _scrollController,
                    headerSliverBuilder:
                        (BuildContext contextHeader, bool innerBoxIsScrolled) {
                      return <Widget>[
                        SliverOverlapAbsorber(
                          handle:
                              NestedScrollView.sliverOverlapAbsorberHandleFor(
                                  contextHeader),
                          sliver: MultiSliver(
                            children: [
                              sliverAppBar,
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: 13),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          getHorizontalPaddingConstrained(
                                                context,
                                                enabled: enableDoubleColumn(
                                                        context) ==
                                                    false,
                                              ) +
                                              13,
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal:
                                            getHorizontalPaddingConstrained(
                                                context),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: IncomeExpenseTabSelector(
                                              hasBorderRadius: true,
                                              onTabChanged: (_) {},
                                              initialTabIsIncome: false,
                                              showIcons: false,
                                              tabController: _tabController,
                                              expenseLabel: "one-time".tr(),
                                              expenseCustomIcon: Icon(
                                                appStateSettings[
                                                        "outlinedIcons"]
                                                    ? Icons
                                                        .event_available_outlined
                                                    : Icons
                                                        .event_available_rounded,
                                              ),
                                              incomeLabel: "long-term".tr(),
                                              incomeCustomIcon: Icon(
                                                appStateSettings[
                                                        "outlinedIcons"]
                                                    ? Icons.av_timer_outlined
                                                    : Icons.av_timer_rounded,
                                              ),
                                            ),
                                          ),
                                          AnimatedBuilder(
                                            animation:
                                                _tabController.animation!,
                                            builder: (BuildContext context,
                                                Widget? child) {
                                              return ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                child: SizeTransition(
                                                  sizeFactor:
                                                      _tabController.animation!,
                                                  axis: Axis.horizontal,
                                                  child: FadeTransition(
                                                    opacity: _tabController
                                                        .animation!,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 7),
                                                      child: ButtonIcon(
                                                        size: 48,
                                                        iconPadding: 25,
                                                        key: ValueKey(2),
                                                        onTap: () {
                                                          pushRoute(
                                                            context,
                                                            EditObjectivesPage(
                                                              objectiveType:
                                                                  ObjectiveType
                                                                      .loan,
                                                            ),
                                                          );
                                                        },
                                                        icon: appStateSettings[
                                                                "outlinedIcons"]
                                                            ? Icons
                                                                .edit_outlined
                                                            : Icons
                                                                .edit_rounded,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              ...loanInfoAppBar,
                            ],
                          ),
                        ),
                      ];
                    },
                    body: Builder(
                      builder: (contextPageView) {
                        return TabBarView(
                          controller: _tabController,
                          children: [
                            CustomScrollView(
                              slivers: [
                                SliverPinnedOverlapInjector(
                                  handle: NestedScrollView
                                      .sliverOverlapAbsorberHandleFor(
                                    contextPageView,
                                  ),
                                ),
                                ...oneTimeLoanList(true)
                              ],
                            ),
                            CustomScrollView(
                              slivers: [
                                SliverPinnedOverlapInjector(
                                  handle: NestedScrollView
                                      .sliverOverlapAbsorberHandleFor(
                                    contextPageView,
                                  ),
                                ),
                                ObjectiveListDifferenceLoan(
                                  searchFor: searchValue,
                                ),
                                ...longTermLoansList
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
          SelectedTransactionsAppBar(
            pageID: pageId,
            enableSettleAllButton: true,
          ),
        ],
      ),
    );
  }
}

class AddLoanPopup extends StatelessWidget {
  const AddLoanPopup({required this.selectedTransactionType, super.key});
  final TransactionSpecialType selectedTransactionType;

  @override
  Widget build(BuildContext context) {
    return PopupFramework(
      title: "add-loan".tr(),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButtonStacked(
                  alignLeft: true,
                  alignBeside: true,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  text: "long-term-loan".tr(),
                  iconData: appStateSettings["outlinedIcons"]
                      ? Icons.av_timer_outlined
                      : Icons.av_timer_rounded,
                  onTap: () {
                    Navigator.pop(context);
                    pushRoute(
                      context,
                      AddObjectivePage(
                        routesToPopAfterDelete: RoutesToPopAfterDelete.None,
                        objectiveType: ObjectiveType.loan,
                        selectedIncome: selectedTransactionType ==
                            TransactionSpecialType.credit,
                      ),
                    );
                  },
                  afterWidget: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListItem(
                        "long-term-loan-description-1".tr(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                child: OutlinedButtonStacked(
                  alignLeft: true,
                  alignBeside: true,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  text: "one-time-loan".tr(),
                  iconData: appStateSettings["outlinedIcons"]
                      ? Icons.event_available_outlined
                      : Icons.event_available_rounded,
                  onTap: () {
                    Navigator.pop(context);
                    pushRoute(
                      context,
                      AddTransactionPage(
                        routesToPopAfterDelete: RoutesToPopAfterDelete.None,
                        selectedType: selectedTransactionType,
                      ),
                    );
                  },
                  afterWidget: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListItem(
                        "one-time-loan-description-1".tr(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
