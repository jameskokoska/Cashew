import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/addWalletPage.dart';
import 'package:budget/pages/editHomePage.dart';
import 'package:budget/pages/homePage/homePageLineGraph.dart';
import 'package:budget/pages/transactionsSearchPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/struct/spendingSummaryHelper.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/dropdownSelect.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/incomeExpenseTabSelector.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/outlinedButtonStacked.dart';
import 'package:budget/widgets/periodCyclePicker.dart';
import 'package:budget/widgets/radioItems.dart';
import 'package:budget/widgets/selectAmount.dart';
import 'package:budget/widgets/selectedTransactionsAppBar.dart';
import 'package:budget/widgets/categoryEntry.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/pieChart.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/tappableTextEntry.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntries.dart';
import 'package:budget/widgets/transactionEntry/transactionEntry.dart';
import 'package:budget/widgets/transactionsAmountBox.dart';
import 'package:budget/widgets/util/showDatePicker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';
import 'package:budget/widgets/viewAllTransactionsButton.dart';
import 'package:provider/provider.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/fadeIn.dart';

class WatchedWalletDetailsPage extends StatelessWidget {
  const WatchedWalletDetailsPage({required this.walletPk, super.key});
  final String walletPk;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TransactionWallet>(
      stream: database.getWallet(walletPk),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return WalletDetailsPage(wallet: snapshot.data);
        }
        return SizedBox.shrink();
      },
    );
  }
}

class WalletDetailsPage extends StatefulWidget {
  final TransactionWallet? wallet;
  const WalletDetailsPage({required this.wallet, Key? key}) : super(key: key);

  @override
  State<WalletDetailsPage> createState() => _WalletDetailsPageState();
}

class _WalletDetailsPageState extends State<WalletDetailsPage> {
  TransactionCategory? selectedCategory;
  bool isIncome = false;
  late String listID = widget.wallet == null
      ? "All Spending Summary"
      : widget.wallet!.walletPk.toString() + " Wallet Summary";
  GlobalKey<PageFrameworkState> pageState = GlobalKey();

  @override
  Widget build(BuildContext context) {
    ColorScheme walletColorScheme = widget.wallet == null
        ? Theme.of(context).colorScheme
        : ColorScheme.fromSeed(
            seedColor: HexColor(widget.wallet!.colour,
                defaultColor: Theme.of(context).colorScheme.primary),
            brightness: determineBrightnessTheme(context),
          );
    String? walletPk = widget.wallet == null ? null : widget.wallet!.walletPk;
    return WillPopScope(
      onWillPop: () async {
        if ((globalSelectedID.value[listID] ?? []).length > 0) {
          globalSelectedID.value[listID] = [];
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
            listID: listID,
            floatingActionButton: AnimateFABDelayed(
              fab: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.viewPaddingOf(context).bottom),
                child: FAB(
                  tooltip: "add-transaction".tr(),
                  openPage: AddTransactionPage(
                    routesToPopAfterDelete: RoutesToPopAfterDelete.One,
                  ),
                ),
              ),
            ),
            actions: [
              if (widget.wallet != null)
                CustomPopupMenuButton(
                  showButtons: enableDoubleColumn(context),
                  keepOutFirst: true,
                  items: [
                    DropdownItemMenu(
                      id: "edit-account",
                      label: "edit-account".tr(),
                      icon: appStateSettings["outlinedIcons"]
                          ? Icons.edit_outlined
                          : Icons.edit_rounded,
                      action: () {
                        pushRoute(
                          context,
                          AddWalletPage(
                            wallet: widget.wallet,
                            routesToPopAfterDelete: RoutesToPopAfterDelete.All,
                          ),
                        );
                      },
                    ),
                    DropdownItemMenu(
                      id: "correct-total-balance",
                      label: "correct-total-balance".tr(),
                      icon: appStateSettings["outlinedIcons"]
                          ? Icons.library_add_outlined
                          : Icons.library_add_rounded,
                      action: () {
                        openBottomSheet(
                          context,
                          fullSnap: true,
                          CorrectBalancePopup(wallet: widget.wallet!),
                        );
                      },
                    ),
                    DropdownItemMenu(
                      id: "transfer-balance",
                      label: "transfer-balance".tr(),
                      icon: appStateSettings["outlinedIcons"]
                          ? Icons.compare_arrows_outlined
                          : Icons.compare_arrows_rounded,
                      action: () {
                        openBottomSheet(
                          context,
                          fullSnap: true,
                          TransferBalancePopup(wallet: widget.wallet!),
                        );
                      },
                    ),
                    DropdownItemMenu(
                      id: "decimal-precision",
                      label: "decimal-precision".tr(),
                      icon: appStateSettings["outlinedIcons"]
                          ? Icons.more_horiz_outlined
                          : Icons.more_horiz_rounded,
                      action: () {
                        openBottomSheet(
                          context,
                          PopupFramework(
                            title: "decimal-precision".tr(),
                            child: SelectAmountValue(
                              amountPassed: widget.wallet!.decimals.toString(),
                              setSelectedAmount: (amount, _) async {
                                int selectedDecimals = amount.toInt();
                                if (amount > 10) {
                                  selectedDecimals = 10;
                                } else if (amount < 0) {
                                  selectedDecimals = 0;
                                }
                                TransactionWallet wallet = await database
                                    .getWalletInstance(widget.wallet!.walletPk);
                                await database.createOrUpdateWallet(wallet
                                    .copyWith(decimals: selectedDecimals));
                              },
                              next: () async {
                                Navigator.pop(context);
                              },
                              nextLabel: "set-amount".tr(),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              if (widget.wallet == null)
                CustomPopupMenuButton(
                  showButtons: enableDoubleColumn(context),
                  keepOutFirst: true,
                  items: [
                    DropdownItemMenu(
                      id: "select-period",
                      label: "select-period-tooltip".tr(),
                      icon: appStateSettings["outlinedIcons"]
                          ? Icons.timelapse_outlined
                          : Icons.timelapse_rounded,
                      action: () async {
                        await openBottomSheet(
                          context,
                          PopupFramework(
                            title: "select-period".tr(),
                            child:
                                PeriodCyclePicker(cycleSettingsExtension: ""),
                          ),
                        );
                        setState(() {});
                        homePageStateKey.currentState?.refreshState();
                      },
                    ),
                  ],
                ),
            ],
            dragDownToDismiss: true,
            title: widget.wallet == null
                ? "all-spending".tr()
                : widget.wallet!.name,
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: 13, left: 13, right: 13),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                getHorizontalPaddingConstrained(context)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: TransactionsAmountBox(
                                label: "net-total".tr(),
                                absolute: false,
                                currencyKey: Provider.of<AllWallets>(context)
                                    .indexedByPk[
                                        appStateSettings["selectedWalletPk"]]
                                    ?.currency,
                                amountStream: database.watchTotalOfWallet(
                                  walletPk != null ? [walletPk] : null,
                                  isIncome: null,
                                  allWallets: Provider.of<AllWallets>(context),
                                  followCustomPeriodCycle:
                                      widget.wallet == null,
                                  cycleSettingsExtension: "",
                                ),
                                textColor: getColor(context, "black"),
                                transactionsAmountStream: database
                                    .watchTotalCountOfTransactionsInWallet(
                                  walletPk != null ? [walletPk] : null,
                                  isIncome: null,
                                  followCustomPeriodCycle:
                                      widget.wallet == null,
                                  cycleSettingsExtension: "",
                                ),
                                openPage: TransactionsSearchPage(
                                  initialFilters: SearchFilters(
                                    walletPks: widget.wallet == null
                                        ? []
                                        : [widget.wallet?.walletPk ?? ""],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: 13, left: 13, right: 13),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                getHorizontalPaddingConstrained(context)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: TransactionsAmountBox(
                                label: "expense".tr(),
                                amountStream: database.watchTotalOfWallet(
                                  walletPk != null ? [walletPk] : null,
                                  isIncome: false,
                                  allWallets: Provider.of<AllWallets>(context),
                                  followCustomPeriodCycle:
                                      widget.wallet == null,
                                  cycleSettingsExtension: "",
                                ),
                                textColor: getColor(context, "expenseAmount"),
                                transactionsAmountStream: database
                                    .watchTotalCountOfTransactionsInWallet(
                                  walletPk != null ? [walletPk] : null,
                                  isIncome: false,
                                  followCustomPeriodCycle:
                                      widget.wallet == null,
                                  cycleSettingsExtension: "",
                                ),
                                openPage: TransactionsSearchPage(
                                  initialFilters: SearchFilters(
                                    expenseIncome: [ExpenseIncome.expense],
                                    walletPks: widget.wallet == null
                                        ? []
                                        : [widget.wallet?.walletPk ?? ""],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 13),
                            Expanded(
                              child: TransactionsAmountBox(
                                label: "income".tr(),
                                amountStream: database.watchTotalOfWallet(
                                  walletPk == null ? null : [walletPk],
                                  isIncome: true,
                                  allWallets: Provider.of<AllWallets>(context),
                                  followCustomPeriodCycle:
                                      widget.wallet == null,
                                  cycleSettingsExtension: "",
                                ),
                                textColor: getColor(context, "incomeAmount"),
                                transactionsAmountStream: database
                                    .watchTotalCountOfTransactionsInWallet(
                                  walletPk == null ? null : [walletPk],
                                  isIncome: true,
                                  followCustomPeriodCycle:
                                      widget.wallet == null,
                                  cycleSettingsExtension: "",
                                ),
                                openPage: TransactionsSearchPage(
                                  initialFilters: SearchFilters(
                                    expenseIncome: [ExpenseIncome.income],
                                    walletPks: widget.wallet == null
                                        ? []
                                        : [widget.wallet?.walletPk ?? ""],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    WalletDetailsLineGraph(
                      walletPks: widget.wallet == null
                          ? []
                          : [widget.wallet!.walletPk],
                      followCustomPeriodCycle: widget.wallet == null,
                      cycleSettingsExtension: "",
                    ),
                    WalletCategoryPieChart(
                      cycleSettingsExtension: "",
                      wallet: widget.wallet,
                      walletColorScheme: walletColorScheme,
                      onSelectedCategory: (TransactionCategory? category) {
                        // pageState.currentState?.scrollTo(500);
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                      onSelectedIncome: (bool isIncome) {
                        setState(() {
                          this.isIncome = isIncome;
                        });
                      },
                    ),
                  ],
                ),
              ),
              if (selectedCategory != null)
                TransactionEntries(
                  null,
                  null,
                  categoryFks: selectedCategory != null
                      ? [selectedCategory!.categoryPk]
                      : [],
                  walletFks: walletPk == null ? [] : [walletPk],
                  limit: selectedCategory == null ? 0 : 10,
                  listID: listID,
                  showNoResults: false,
                  income: isIncome,
                ),
              selectedCategory == null
                  ? SliverToBoxAdapter(
                      child: SizedBox.shrink(),
                    )
                  : SliverToBoxAdapter(
                      child: Center(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        child: ViewAllTransactionsButton(
                          onPress: () {
                            pushRoute(context, TransactionsSearchPage());
                          },
                        ),
                      )),
                    ),
              SliverToBoxAdapter(child: SizedBox(height: 75)),
            ],
          ),
          SelectedTransactionsAppBar(
            pageID: listID,
          ),
        ],
      ),
    );
  }
}

class WalletCategoryPieChart extends StatefulWidget {
  const WalletCategoryPieChart({
    required this.wallet,
    required this.walletColorScheme,
    required this.onSelectedCategory,
    required this.onSelectedIncome,
    required this.cycleSettingsExtension,
    super.key,
  });

  final TransactionWallet? wallet;
  final ColorScheme walletColorScheme;
  final Function(TransactionCategory?) onSelectedCategory;
  final Function(bool) onSelectedIncome;
  final String cycleSettingsExtension;

  @override
  State<WalletCategoryPieChart> createState() => _WalletCategoryPieChartState();
}

class _WalletCategoryPieChartState extends State<WalletCategoryPieChart> {
  TransactionCategory? selectedCategory = null;
  bool isIncome = false;
  GlobalKey<PieChartDisplayState> _pieChartDisplayStateKey = GlobalKey();
  bool showAllSubcategories = appStateSettings["showAllSubcategories"];

  void toggleAllSubcategories() {
    setState(() {
      showAllSubcategories = !showAllSubcategories;
    });
    Future.delayed(Duration(milliseconds: 10), () {
      _pieChartDisplayStateKey.currentState!
          .setTouchedCategoryPk(selectedCategory?.categoryPk);
    });

    updateSettings("showAllSubcategories", showAllSubcategories,
        updateGlobalState: false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: getHorizontalPaddingConstrained(context)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: boxShadowCheck(boxShadowGeneral(context)),
              ),
              child: ClipRRect(
                borderRadius: getPlatform() == PlatformOS.isIOS
                    ? BorderRadius.circular(10)
                    : BorderRadius.circular(15),
                child: IncomeExpenseTabSelector(
                  onTabChanged: (income) {
                    setState(() {
                      isIncome = income;
                      selectedCategory = null;
                    });
                    _pieChartDisplayStateKey.currentState!.setTouchedIndex(-1);
                    widget.onSelectedIncome(income);
                    widget.onSelectedCategory(selectedCategory);
                  },
                  initialTabIsIncome: false,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        StreamBuilder<List<CategoryWithTotal>>(
          stream:
              database.watchTotalSpentInEachCategoryInTimeRangeFromCategories(
            allWallets: Provider.of<AllWallets>(context),
            start: DateTime.now(),
            end: DateTime.now(),
            categoryFks: null,
            categoryFksExclude: null,
            budgetTransactionFilters: null,
            memberTransactionFilters: null,
            allTime: true,
            walletPk: widget.wallet == null ? null : widget.wallet!.walletPk,
            isIncome: isIncome,
            followCustomPeriodCycle: widget.wallet == null,
            cycleSettingsExtension: widget.cycleSettingsExtension,
            countUnassignedTransactions: true,
            includeAllSubCategories: true,
          ),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              TotalSpentCategoriesSummary s = watchTotalSpentInTimeRangeHelper(
                  dataInput: snapshot.data ?? [],
                  showAllSubcategories: showAllSubcategories);
              List<Widget> categoryEntries = [];
              snapshot.data!.asMap().forEach((index, category) {
                categoryEntries.add(
                  CategoryEntry(
                    selectedSubCategoryPk: selectedCategory?.categoryPk,
                    expandSubcategories: showAllSubcategories ||
                        category.category.categoryPk ==
                            selectedCategory?.categoryPk ||
                        category.category.categoryPk ==
                            selectedCategory?.mainCategoryPk,
                    subcategoriesWithTotalMap:
                        s.subCategorySpendingIndexedByMainCategoryPk,
                    extraText: isIncome ? "of-income".tr() : "of-expense".tr(),
                    budgetColorScheme: widget.walletColorScheme,
                    category: category.category,
                    totalSpentAbsolute: s.totalSpentAbsolute,
                    totalSpent: s.totalSpent,
                    transactionCount: category.transactionCount,
                    categorySpent: category.total,
                    onTap: (TransactionCategory tappedCategory, _) {
                      if (selectedCategory?.categoryPk ==
                          tappedCategory.categoryPk) {
                        setState(() {
                          selectedCategory = null;
                        });
                        _pieChartDisplayStateKey.currentState!
                            .setTouchedIndex(-1);
                      } else {
                        if (showAllSubcategories ||
                            tappedCategory.mainCategoryPk == null) {
                          setState(() {
                            selectedCategory = tappedCategory;
                          });
                          _pieChartDisplayStateKey.currentState!
                              .setTouchedCategoryPk(tappedCategory.categoryPk);
                        } else {
                          // We are tapping a subcategoryEntry and it is not in the pie chart
                          // because showAllSubcategories is false and mainCategoryPk is not null
                          setState(() {
                            selectedCategory = tappedCategory;
                          });
                          _pieChartDisplayStateKey.currentState!
                              .setTouchedCategoryPk(
                                  tappedCategory.mainCategoryPk);
                        }
                      }
                      widget.onSelectedCategory(selectedCategory);
                    },
                    selected: category.category.categoryPk ==
                            selectedCategory?.mainCategoryPk ||
                        selectedCategory?.categoryPk ==
                            category.category.categoryPk,
                    allSelected: selectedCategory == null,
                    showIncomeExpenseIcons: true,
                  ),
                );
              });
              return Column(
                children: [
                  SizedBox(height: 30),
                  PieChartWrapper(
                    isPastBudget: true,
                    pieChartDisplayStateKey: _pieChartDisplayStateKey,
                    data: s.dataFilterUnassignedTransactions,
                    totalSpentAbsolute: s.totalSpentAbsolute,
                    setSelectedCategory: (categoryPk, category) async {
                      setState(() {
                        selectedCategory = category;
                      });
                      widget.onSelectedCategory(selectedCategory);
                    },
                  ),
                  PieChartOptions(
                    hasSubCategories: s.hasSubCategories,
                    selectedCategory: selectedCategory,
                    onClearSelection: () {
                      setState(() {
                        selectedCategory = null;
                      });
                      _pieChartDisplayStateKey.currentState!
                          .setTouchedIndex(-1);
                      widget.onSelectedCategory(selectedCategory);
                    },
                    onEditSpendingGoals: null,
                    toggleAllSubCategories: toggleAllSubcategories,
                    colorScheme: Theme.of(context).colorScheme,
                    showAllSubcategories: showAllSubcategories,
                  ),
                  ...categoryEntries,
                  SizedBox(height: 10),
                ],
              );
            }
            return SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

class WalletDetailsLineGraph extends StatefulWidget {
  const WalletDetailsLineGraph({
    super.key,
    required this.walletPks,
    required this.followCustomPeriodCycle,
    required this.cycleSettingsExtension,
  });
  final List<String>? walletPks;
  final bool followCustomPeriodCycle;
  final String cycleSettingsExtension;

  @override
  State<WalletDetailsLineGraph> createState() => _WalletDetailsLineGraphState();
}

class _WalletDetailsLineGraphState extends State<WalletDetailsLineGraph> {
  int numberMonthsToLoad = 1;

  @override
  Widget build(BuildContext context) {
    DateTime? customPeriodStartDate = getStartDateOfSelectedCustomPeriod("");
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          color: getColor(context, "lightDarkAccentHeavyLight"),
          boxShadow: boxShadowCheck(boxShadowGeneral(context)),
        ),
        child: Stack(
          children: [
            if (widget.followCustomPeriodCycle == false ||
                customPeriodStartDate == null)
              Positioned(
                right: 0,
                top: 0,
                child: Transform.translate(
                  offset: Offset(5, -5),
                  child: IconButton(
                    icon: Icon(
                      appStateSettings["outlinedIcons"]
                          ? Icons.history_outlined
                          : Icons.history_rounded,
                      size: 22,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.8),
                    ),
                    onPressed: () {
                      setState(() {
                        numberMonthsToLoad++;
                      });
                    },
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.only(left: 7, right: 7, bottom: 12, top: 18),
              child: PastSpendingGraph(
                isIncome: null,
                walletPks: widget.walletPks,
                monthsToLoad: numberMonthsToLoad,
                followCustomPeriodCycle: widget.followCustomPeriodCycle,
                cycleSettingsExtension: widget.cycleSettingsExtension,
                customStartDate: widget.followCustomPeriodCycle == true
                    ? customPeriodStartDate
                    : null,
                // extraLeftPaddingIfSmall:
                //     10, //we want this because the corner has the load more dates button
              ),
            ),
          ],
        ),
      ),
    );
  }
}
