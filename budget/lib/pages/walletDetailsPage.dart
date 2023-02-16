import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/budgetPage.dart';
import 'package:budget/pages/debugPage.dart';
import 'package:budget/pages/onBoardingPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/categoryEntry.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/notificationsSettings.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/pieChart.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/showChangelog.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class WalletDetailsPage extends StatelessWidget {
  final TransactionWallet wallet;
  const WalletDetailsPage({required this.wallet, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ColorScheme walletColorScheme = ColorScheme.fromSeed(
      seedColor: HexColor(wallet.colour,
          defaultColor: Theme.of(context).colorScheme.primary),
      brightness: determineBrightnessTheme(context),
    );
    return PageFramework(
      dragDownToDismiss: true,
      title: wallet.name,
      navbar: false,
      appBarBackgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      appBarBackgroundColorStart: Theme.of(context).colorScheme.background,
      listWidgets: [
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(bottom: 13, left: 13, right: 13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                  child: IncomeTransactionsSummary(
                incomeTransactions: false,
                walletPk: wallet.walletPk,
              )),
              SizedBox(width: 13),
              Expanded(
                child: IncomeTransactionsSummary(
                  incomeTransactions: true,
                  walletPk: wallet.walletPk,
                ),
              ),
            ],
          ),
        ),
        WalletCategoryPieChart(
          wallet: wallet,
          walletColorScheme: walletColorScheme,
        ),
      ],
    );
  }
}

class WalletCategoryPieChart extends StatefulWidget {
  const WalletCategoryPieChart(
      {required this.wallet, required this.walletColorScheme, super.key});

  final TransactionWallet wallet;
  final ColorScheme walletColorScheme;

  @override
  State<WalletCategoryPieChart> createState() => _WalletCategoryPieChartState();
}

class _WalletCategoryPieChartState extends State<WalletCategoryPieChart> {
  int selectedCategoryPk = -1;
  TransactionCategory? selectedCategory = null;
  GlobalKey<PieChartDisplayState> _pieChartDisplayStateKey = GlobalKey();

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
          SharedTransactionsShow.fromEveryone,
          wallets,
          allTime: true,
          // member: selectedMember,
          // onlyShowTransactionsBelongingToBudget:
          //     widget.budget.sharedKey != null ||
          //             widget.budget.addedTransactionsOnly == true
          //         ? widget.budget.budgetPk
          //         : null,
          // budget: widget.budget,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            double totalSpent = 0;
            List<Widget> categoryEntries = [];
            snapshot.data!.forEach((category) {
              totalSpent = totalSpent + category.total.abs();
              totalSpent = totalSpent.abs();
            });
            snapshot.data!.asMap().forEach((index, category) {
              categoryEntries.add(
                CategoryEntry(
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
                      _pieChartDisplayStateKey.currentState!
                          .setTouchedIndex(-1);
                    } else {
                      setState(() {
                        selectedCategoryPk = category.category.categoryPk;
                        selectedCategory = category.category;
                      });
                      _pieChartDisplayStateKey.currentState!
                          .setTouchedIndex(index);
                    }
                  },
                  selected: selectedCategoryPk == category.category.categoryPk,
                  allSelected: selectedCategoryPk == -1,
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
                    });
                  },
                ),
                SizedBox(height: 35),
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
  final int walletPk;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(boxShadow: boxShadowCheck(boxShadowGeneral(context))),
      child: Tappable(
        borderRadius: 15,
        color: Theme.of(context).colorScheme.lightDarkAccentHeavyLight,
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
                          text: convertToMoney(number),
                          fontSize: 21,
                          textColor: incomeTransactions
                              ? Theme.of(context).colorScheme.incomeGreen
                              : Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.bold,
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
                      textColor: Theme.of(context).colorScheme.textLight,
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
