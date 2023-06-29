import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addWalletPage.dart';
import 'package:budget/pages/budgetPage.dart';
import 'package:budget/pages/homePage/homePageLineGraph.dart';
import 'package:budget/pages/transactionsListPage.dart';
import 'package:budget/pages/transactionsSearchPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/lineGraph.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/selectedTransactionsActionBar.dart';
import 'package:budget/widgets/categoryEntry.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/pieChart.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:budget/widgets/transactionsAmountBox.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';
import 'package:budget/widgets/viewAllTransactionsButton.dart';
import 'package:provider/provider.dart';
import 'package:budget/widgets/countNumber.dart';

class WatchedWalletDetailsPage extends StatelessWidget {
  const WatchedWalletDetailsPage({required this.walletPk, super.key});
  final int walletPk;
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
  int selectedCategoryPk = -1;
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
    int? walletPk = widget.wallet == null ? null : widget.wallet!.walletPk;
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
              IconButton(
                tooltip: "Edit wallet",
                onPressed: () {
                  pushRoute(
                    context,
                    AddWalletPage(
                      title: "Edit Wallet",
                      wallet: widget.wallet,
                    ),
                  );
                },
                icon: Icon(Icons.edit_rounded),
              ),
            ],
            dragDownToDismiss: true,
            title: widget.wallet == null ? "All Spending" : widget.wallet!.name,
            appBarBackgroundColor:
                Theme.of(context).colorScheme.secondaryContainer,
            appBarBackgroundColorStart: Theme.of(context).canvasColor,
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
                                label: "Income",
                                amountStream: database.watchTotalOfWallet(
                                  walletPk,
                                  isIncome: true,
                                ),
                                textColor: getColor(context, "incomeAmount"),
                                transactionsAmountStream: database
                                    .watchTotalCountOfTransactionsInWallet(
                                  walletPk,
                                  isIncome: true,
                                ),
                                openPage: TransactionsSearchPage(
                                  initialFilters: SearchFilters(
                                    expenseIncome: [ExpenseIncome.income],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 13),
                            Expanded(
                              child: TransactionsAmountBox(
                                label: "Expense",
                                amountStream: database.watchTotalOfWallet(
                                  walletPk,
                                  isIncome: false,
                                ),
                                textColor: getColor(context, "expenseAmount"),
                                transactionsAmountStream: database
                                    .watchTotalCountOfTransactionsInWallet(
                                  walletPk,
                                  isIncome: false,
                                ),
                                openPage: TransactionsSearchPage(
                                  initialFilters: SearchFilters(
                                    expenseIncome: [ExpenseIncome.expense],
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
                    WalletCategoryPieChart(
                      wallet: widget.wallet,
                      walletColorScheme: walletColorScheme,
                      onSelectedCategory: (int categoryPk) {
                        // pageState.currentState?.scrollTo(500);
                        setState(() {
                          selectedCategoryPk = categoryPk;
                        });
                      },
                    ),
                  ],
                ),
              ),
              getTransactionsSlivers(
                null,
                null,
                categoryFks: [selectedCategoryPk],
                walletFks: walletPk == null ? [] : [walletPk],
                limit: selectedCategoryPk == -1 ? 0 : 10,
                listID: listID,
                showNoResults: false,
              ),
              selectedCategoryPk == -1
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
    super.key,
  });

  final TransactionWallet? wallet;
  final ColorScheme walletColorScheme;
  final Function(int) onSelectedCategory;

  @override
  State<WalletCategoryPieChart> createState() => _WalletCategoryPieChartState();
}

class _WalletCategoryPieChartState extends State<WalletCategoryPieChart> {
  int selectedCategoryPk = -1;
  TransactionCategory? selectedCategory = null;
  GlobalKey<PieChartDisplayState> _pieChartDisplayStateKey = GlobalKey();
  bool tiledCategoryEntries = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CategoryWithTotal>>(
      stream: database.watchTotalSpentInEachCategoryInTimeRangeFromCategories(
        Provider.of<AllWallets>(context),
        DateTime.now(),
        DateTime.now(),
        [],
        true,
        null, null,
        allTime: true,
        walletPk: widget.wallet == null ? null : widget.wallet!.walletPk,
        // member: selectedMember,
        // onlyShowTransactionsBelongingToBudget:
        //     widget.budget.sharedKey != null ||
        //             widget.budget.addedTransactionsOnly == true
        //         ? widget.budget.budgetPk
        //         : null,
        // budget: widget.budget,
        income: null,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          double totalSpent = 0;
          List<Widget> categoryEntries = [];
          snapshot.data!.forEach((category) {
            totalSpent = totalSpent + category.total.abs();
          });
          snapshot.data!.asMap().forEach((index, category) {
            categoryEntries.add(
              CategoryEntry(
                extraText:
                    widget.wallet == null ? " of spending" : " of wallet",
                isTiled: tiledCategoryEntries,
                budgetColorScheme: widget.walletColorScheme,
                category: category.category,
                totalSpent: totalSpent,
                transactionCount: category.transactionCount,
                categorySpent: category.total.abs(),
                onTap: () {
                  if (selectedCategoryPk == category.category.categoryPk) {
                    setState(() {
                      selectedCategoryPk = -1;
                      selectedCategory = null;
                    });
                    _pieChartDisplayStateKey.currentState!.setTouchedIndex(-1);
                    widget.onSelectedCategory(-1);
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
                selected: selectedCategoryPk == category.category.categoryPk,
                allSelected: selectedCategoryPk == -1,
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
                totalSpent: totalSpent,
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
              //         ? Icons.grid_view_rounded
              //         : Icons.list_rounded,
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
  }
}

class WalletDetailsLineGraph extends StatefulWidget {
  const WalletDetailsLineGraph({super.key, required this.walletPks});
  final List<int>? walletPks;

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
              left: 0,
              bottom: 0,
              child: IconButton(
                icon: Icon(
                  Icons.history_rounded,
                  size: 22,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                ),
                onPressed: () {
                  setState(() {
                    numberMonthsToLoad++;
                  });
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 9, right: 9, bottom: 12, top: 18),
              child: PastSpendingGraph(
                isIncome: null,
                walletPks: widget.walletPks,
                monthsToLoad: numberMonthsToLoad,
                extraLeftPaddingIfSmall:
                    10, //we want this because the corner has the load more dates button
              ),
            ),
          ],
        ),
      ),
    );
  }
}
