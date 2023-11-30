import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/editHomePage.dart';
import 'package:budget/pages/transactionsSearchPage.dart';
import 'package:budget/pages/walletDetailsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/util/keepAliveClientMixin.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/pieChart.dart';
import 'package:budget/widgets/textWidgets.dart';
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
    return KeepAliveClientMixin(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 13, left: 13, right: 13),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            color: getColor(context, "lightDarkAccentHeavyLight"),
            boxShadow: boxShadowCheck(boxShadowGeneral(context)),
          ),
          padding: EdgeInsets.symmetric(vertical: 30, horizontal: 10),
          child: StreamBuilder<double?>(
            stream: database.watchTotalOfWallet(
              null,
              isIncome: isIncome,
              allWallets: Provider.of<AllWallets>(context),
              followCustomPeriodCycle: true,
              cycleSettingsExtension: "PieChart",
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
                  walletPks: null,
                  isIncome: isIncome,
                  followCustomPeriodCycle: true,
                  cycleSettingsExtension: "PieChart",
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return LayoutBuilder(
                      builder: (_, boxConstraints) {
                        // print(boxConstraints);
                        bool showTopCategoriesLegend =
                            boxConstraints.maxWidth > 320;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showTopCategoriesLegend)
                              Flexible(
                                flex: 1,
                                child: Padding(
                                  padding: EdgeInsets.only(left: 12),
                                  child: TopCategoriesSpentLegend(
                                    categoriesWithTotal: snapshot.data!
                                        .take(
                                          boxConstraints.maxWidth < 420 ? 3 : 5,
                                        )
                                        .toList(),
                                  ),
                                ),
                              ),
                            Flexible(
                              flex: 2,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    right: showTopCategoriesLegend ? 20 : 0),
                                child: PieChartWrapper(
                                  isPastBudget: true,
                                  pieChartDisplayStateKey: null,
                                  data: snapshot.data!,
                                  totalSpent: total,
                                  setSelectedCategory:
                                      (categoryPk, category) {},
                                  percentLabelOnTop: true,
                                  middleColor: getColor(
                                      context, "lightDarkAccentHeavyLight"),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }
                  return SizedBox.shrink();
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class TopCategoriesSpentLegend extends StatelessWidget {
  const TopCategoriesSpentLegend(
      {required this.categoriesWithTotal, super.key});
  final List<CategoryWithTotal> categoriesWithTotal;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (CategoryWithTotal categoryWithTotal in categoriesWithTotal)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: HexColor(categoryWithTotal.category.colour),
                  ),
                ),
                SizedBox(width: 5),
                Flexible(
                  child: TextFont(
                    text: categoryWithTotal.category.name,
                    fontSize: 15,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
