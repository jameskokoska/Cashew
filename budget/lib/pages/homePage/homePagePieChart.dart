import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/editHomePage.dart';
import 'package:budget/pages/transactionsSearchPage.dart';
import 'package:budget/pages/walletDetailsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/struct/spendingSummaryHelper.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/pages/editHomePage.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/util/keepAliveClientMixin.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/pieChart.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionsAmountBox.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePagePieChart extends StatelessWidget {
  const HomePagePieChart(
      {required this.pieChartDisplayStateKey,
      required this.selectedSlidingSelector,
      super.key});
  final int selectedSlidingSelector;
  final GlobalKey<PieChartDisplayState> pieChartDisplayStateKey;
  @override
  Widget build(BuildContext context) {
    bool? isIncome = appStateSettings["pieChartTotal"] == "all"
        ? null
        : appStateSettings["pieChartTotal"] == "outgoing"
            ? false
            : true;
    return KeepAliveClientMixin(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 13, left: 13, right: 13),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: boxShadowCheck(boxShadowGeneral(context)),
          ),
          child: Tappable(
            borderRadius: 15,
            onLongPress: () async {
              await openPieChartHomePageBottomSheetSettings(context);
              homePageStateKey.currentState?.refreshState();
            },
            onTap: () {
              pieChartDisplayStateKey.currentState?.setTouchedIndex(-1);
            },
            color: getColor(context, "lightDarkAccentHeavyLight"),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 30, horizontal: 10),
              child: StreamBuilder<List<CategoryWithTotal>>(
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
                    double total = 0;
                    for (CategoryWithTotal categoryWithTotal
                        in snapshot.data ?? []) {
                      total = total + categoryWithTotal.total.abs();
                    }
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
                                  pieChartDisplayStateKey:
                                      pieChartDisplayStateKey,
                                  isPastBudget: true,
                                  data: snapshot.data!,
                                  totalSpent: total,
                                  setSelectedCategory:
                                      (categoryPk, category) {},
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
              ),
            ),
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
