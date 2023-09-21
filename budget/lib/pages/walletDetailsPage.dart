import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addWalletPage.dart';
import 'package:budget/pages/homePage/homePageLineGraph.dart';
import 'package:budget/pages/transactionsSearchPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/dropdownSelect.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/incomeExpenseTabSelector.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/selectedTransactionsActionBar.dart';
import 'package:budget/widgets/categoryEntry.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/pieChart.dart';
import 'package:budget/widgets/transactionEntries.dart';
import 'package:budget/widgets/transactionEntry/transactionEntry.dart';
import 'package:budget/widgets/transactionsAmountBox.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';
import 'package:budget/widgets/viewAllTransactionsButton.dart';
import 'package:provider/provider.dart';

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
  String selectedCategoryPk = "-1";
  late String listID = widget.wallet == null
      ? "All Spending Summary"
      : widget.wallet!.walletPk.toString() + " Wallet Summary";
  GlobalKey<PageFrameworkState> pageState = GlobalKey();
  bool isIncome = false;

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
                          PopupFramework(
                            title: "enter-amount".tr(),
                            underTitleSpace: false,
                            child: CorrectBalancePopup(wallet: widget.wallet!),
                          ),
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
                          PopupFramework(
                            title: "enter-amount".tr(),
                            underTitleSpace: false,
                            child: TransferBalancePopup(wallet: widget.wallet!),
                          ),
                        );
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
                                ),
                                textColor: getColor(context, "black"),
                                transactionsAmountStream: database
                                    .watchTotalCountOfTransactionsInWallet(
                                  walletPk != null ? [walletPk] : null,
                                  isIncome: null,
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
                                ),
                                textColor: getColor(context, "expenseAmount"),
                                transactionsAmountStream: database
                                    .watchTotalCountOfTransactionsInWallet(
                                  walletPk != null ? [walletPk] : null,
                                  isIncome: false,
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
                                ),
                                textColor: getColor(context, "incomeAmount"),
                                transactionsAmountStream: database
                                    .watchTotalCountOfTransactionsInWallet(
                                  walletPk == null ? null : [walletPk],
                                  isIncome: true,
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
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: getHorizontalPaddingConstrained(context)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 13),
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow:
                                boxShadowCheck(boxShadowGeneral(context)),
                          ),
                          child: ClipRRect(
                            borderRadius: getPlatform() == PlatformOS.isIOS
                                ? BorderRadius.circular(10)
                                : BorderRadius.circular(15),
                            child: IncomeExpenseTabSelector(
                              onTabChanged: (income) {
                                setState(() {
                                  isIncome = income;
                                });
                              },
                              initialTabIsIncome: false,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    WalletCategoryPieChart(
                      wallet: widget.wallet,
                      walletColorScheme: walletColorScheme,
                      onSelectedCategory: (String categoryPk) {
                        // pageState.currentState?.scrollTo(500);
                        setState(() {
                          selectedCategoryPk = categoryPk;
                        });
                      },
                      isIncome: isIncome,
                    ),
                  ],
                ),
              ),
              TransactionEntries(
                null,
                null,
                categoryFks: [selectedCategoryPk],
                walletFks: walletPk == null ? [] : [walletPk],
                limit: selectedCategoryPk == "-1" ? 0 : 10,
                listID: listID,
                showNoResults: false,
                income: isIncome,
              ),
              selectedCategoryPk == "-1"
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
            ],
          ),
          SelectedTransactionsActionBar(
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
    required this.isIncome,
    super.key,
  });

  final TransactionWallet? wallet;
  final ColorScheme walletColorScheme;
  final Function(String) onSelectedCategory;
  final bool isIncome;

  @override
  State<WalletCategoryPieChart> createState() => _WalletCategoryPieChartState();
}

class _WalletCategoryPieChartState extends State<WalletCategoryPieChart> {
  String selectedCategoryPk = "-1";
  TransactionCategory? selectedCategory = null;
  GlobalKey<PieChartDisplayState> _pieChartDisplayStateKey = GlobalKey();
  bool tiledCategoryEntries = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<double?>(
      stream: database.watchTotalOfWallet(
        widget.wallet?.walletPk == null
            ? null
            : [widget.wallet?.walletPk ?? ""],
        isIncome: widget.isIncome,
        allWallets: Provider.of<AllWallets>(context),
      ),
      builder: (context, totalSnapshot) {
        double total = (totalSnapshot.data ?? 0).abs();
        return StreamBuilder<List<CategoryWithTotal>>(
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
            isIncome: widget.isIncome,
          ),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Widget> categoryEntries = [];
              snapshot.data!.asMap().forEach((index, category) {
                categoryEntries.add(
                  CategoryEntry(
                    extraText:
                        widget.isIncome ? "of-income".tr() : "of-expense".tr(),
                    isTiled: tiledCategoryEntries,
                    budgetColorScheme: widget.walletColorScheme,
                    category: category.category,
                    totalSpent: total,
                    transactionCount: category.transactionCount,
                    categorySpent: category.total,
                    onTap: () {
                      if (selectedCategoryPk == category.category.categoryPk) {
                        setState(() {
                          selectedCategoryPk = "-1";
                          selectedCategory = null;
                        });
                        _pieChartDisplayStateKey.currentState!
                            .setTouchedIndex(-1);
                        widget.onSelectedCategory("-1");
                      } else {
                        setState(() {
                          selectedCategoryPk = category.category.categoryPk;
                          selectedCategory = category.category;
                        });
                        _pieChartDisplayStateKey.currentState!
                            .setTouchedIndex(index);
                        widget.onSelectedCategory(category.category.categoryPk);
                      }
                    },
                    selected:
                        selectedCategoryPk == category.category.categoryPk,
                    allSelected: selectedCategoryPk == "-1",
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
                    data: snapshot.data!,
                    totalSpent: total,
                    setSelectedCategory: (categoryPk, category) {
                      setState(() {
                        selectedCategoryPk = categoryPk;
                        selectedCategory = category;
                        widget.onSelectedCategory(categoryPk);
                      });
                    },
                  ),
                  SizedBox(height: 35),
                  // IconButton(
                  //   onPressed: () {
                  //     setState(() {
                  //       tiledCategoryEntries = !tiledCategoryEntries;
                  //     });
                  //   },
                  //   icon: Icon(
                  //     tiledCategoryEntries
                  //         ? appStateSettings["outlinedIcons"] ? Icons.grid_view_outlined : Icons.grid_view_rounded
                  //         : appStateSettings["outlinedIcons"] ? Icons.list_outlined : Icons.list_rounded,
                  //   ),
                  // ),
                  // tiledCategoryEntries
                  //     ? Padding(
                  //         padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  //         child: Wrap(
                  //           children: [...categoryEntries],
                  //         ),
                  //       )
                  //     : SizedBox.shrink(),
                  // Wrap(
                  //   children: [...categoryEntries],
                  // ),
                  ...categoryEntries,
                  SizedBox(height: 15),
                ],
              );
            }
            return SizedBox.shrink();
          },
        );
      },
    );
  }
}

class WalletDetailsLineGraph extends StatefulWidget {
  const WalletDetailsLineGraph({super.key, required this.walletPks});
  final List<String>? walletPks;

  @override
  State<WalletDetailsLineGraph> createState() => _WalletDetailsLineGraphState();
}

class _WalletDetailsLineGraphState extends State<WalletDetailsLineGraph> {
  int numberMonthsToLoad = 1;

  @override
  Widget build(BuildContext context) {
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
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.8),
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
