import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addWalletPage.dart';
import 'package:budget/pages/budgetPage.dart';
import 'package:budget/pages/transactionsListPage.dart';
import 'package:budget/pages/transactionsSearchPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/SelectedTransactionsActionBar.dart';
import 'package:budget/widgets/categoryEntry.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/pieChart.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';
import 'package:budget/widgets/viewAllTransactionsButton.dart';

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
            navbar: false,
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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                              child: IncomeTransactionsSummary(
                            incomeTransactions: false,
                            walletPk: walletPk,
                          )),
                          SizedBox(width: 13),
                          Expanded(
                            child: IncomeTransactionsSummary(
                              incomeTransactions: true,
                              walletPk: walletPk,
                            ),
                          ),
                        ],
                      ),
                    ),
                    WalletCategoryPieChart(
                      wallet: widget.wallet,
                      walletColorScheme: walletColorScheme,
                      onSelectedCategory: (int categoryPk) {
                        pageState.currentState?.scrollToTop(duration: 5000);
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
              SliverToBoxAdapter(
                child: SizedBox(height: 25),
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
    return WatchAllWallets(
      noDataWidget: SliverToBoxAdapter(child: SizedBox.shrink()),
      childFunction: (wallets) => StreamBuilder<List<CategoryWithTotal>>(
        stream: database.watchTotalSpentInEachCategoryInTimeRangeFromCategories(
          DateTime.now(),
          DateTime.now(),
          [],
          true,
          null, null,
          wallets,
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
                  categorySpent: category.total,
                  onTap: () {
                    if (selectedCategoryPk == category.category.categoryPk) {
                      setState(() {
                        selectedCategoryPk = -1;
                        selectedCategory = null;
                      });
                      _pieChartDisplayStateKey.currentState!
                          .setTouchedIndex(-1);
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
      ),
    );
  }
}

class IncomeTransactionsSummary extends StatelessWidget {
  const IncomeTransactionsSummary({
    Key? key,
    this.incomeTransactions = true,
    required this.walletPk,
  }) : super(key: key);

  final bool incomeTransactions;
  final int? walletPk;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(boxShadow: boxShadowCheck(boxShadowGeneral(context))),
      child: Tappable(
        borderRadius: 15,
        color: getColor(context, "lightDarkAccentHeavyLight"),
        onTap: () {},
        child: Container(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 17),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFont(
                  text: incomeTransactions ? "Income" : "Expense",
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: 6),
                StreamBuilder<double?>(
                  stream: database.watchTotalOfWallet(walletPk,
                      isIncome: incomeTransactions),
                  builder: (context, snapshot) {
                    return CountNumber(
                      count: snapshot.hasData == false || snapshot.data == null
                          ? 0
                          : (snapshot.data ?? 0).abs(),
                      duration: Duration(milliseconds: 1000),
                      dynamicDecimals: true,
                      initialCount: (0),
                      textBuilder: (number) {
                        return TextFont(
                          text: convertToMoney(
                            number,
                            finalNumber: snapshot.hasData == false ||
                                    snapshot.data == null
                                ? 0
                                : (snapshot.data ?? 0).abs(),
                          ),
                          textColor: incomeTransactions
                              ? getColor(context, "incomeAmount")
                              : getColor(context, "expenseAmount"),
                          fontWeight: FontWeight.bold,
                          autoSizeText: true,
                          fontSize: 21,
                          maxFontSize: 21,
                          minFontSize: 10,
                          maxLines: 1,
                        );
                      },
                    );
                  },
                ),
                SizedBox(height: 5),
                StreamBuilder<List<int?>>(
                  stream: database.watchTotalCountOfTransactionsInWallet(
                    walletPk,
                    isIncome: incomeTransactions,
                  ),
                  builder: (context, snapshot) {
                    return TextFont(
                      text:
                          snapshot.hasData == false || snapshot.data![0] == null
                              ? "/"
                              : snapshot.data![0].toString() +
                                  pluralString(
                                      snapshot.data![0] == 1, " transaction"),
                      fontSize: 13,
                      textColor: getColor(context, "textLight"),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
