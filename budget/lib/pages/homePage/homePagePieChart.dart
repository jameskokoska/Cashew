import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/transactionsSearchPage.dart';
import 'package:budget/pages/walletDetailsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/keepAliveClientMixin.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/pieChart.dart';
import 'package:budget/widgets/transactionsAmountBox.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePagePieChart extends StatelessWidget {
  const HomePagePieChart({required this.selectedSlidingSelector, super.key});
  final int selectedSlidingSelector;
  @override
  Widget build(BuildContext context) {
    bool isIncome = appStateSettings["pieChartIsIncome"];
    return !appStateSettings["showPieChart"] &&
            enableDoubleColumn(context) == false
        ? SizedBox.shrink()
        : KeepAliveClientMixin(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 13, left: 13, right: 13),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  color: getColor(context, "lightDarkAccentHeavyLight"),
                  boxShadow: boxShadowCheck(boxShadowGeneral(context)),
                ),
                padding: EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: StreamBuilder<double?>(
                        stream: database.watchTotalOfWallet(
                          null,
                          isIncome: isIncome,
                          allWallets: Provider.of<AllWallets>(context),
                        ),
                        builder: (context, totalSnapshot) {
                          double total = (totalSnapshot.data ?? 0).abs();
                          return StreamBuilder<List<CategoryWithTotal>>(
                            stream: database
                                .watchTotalSpentInEachCategoryInTimeRangeFromCategories(
                              allWallets: Provider.of<AllWallets>(context),
                              start: DateTime.now(),
                              end: DateTime.now(),
                              categoryFks: null,
                              categoryFksExclude: null,
                              budgetTransactionFilters: null,
                              memberTransactionFilters: null,
                              allTime: true,
                              walletPk: null,
                              isIncome: isIncome,
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return PieChartWrapper(
                                  isPastBudget: true,
                                  pieChartDisplayStateKey: null,
                                  data: snapshot.data!,
                                  totalSpent: total,
                                  setSelectedCategory:
                                      (categoryPk, category) {},
                                );
                              }
                              return SizedBox.shrink();
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
