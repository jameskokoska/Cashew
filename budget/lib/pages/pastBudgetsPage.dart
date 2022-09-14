import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/transactionsListPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/budgetContainer.dart';
import 'package:budget/widgets/categoryEntry.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/lineGraph.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/pieChart.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';
import 'package:flutter/scheduler.dart';
import 'dart:developer';

class PastBudgetsPage extends StatefulWidget {
  const PastBudgetsPage({Key? key, required Budget this.budget})
      : super(key: key);

  final Budget budget;

  @override
  State<PastBudgetsPage> createState() => _PastBudgetsPageState();
}

GlobalKey<PageFrameworkState> budgetHistoryKey = GlobalKey();

class _PastBudgetsPageState extends State<PastBudgetsPage> {
  int amountLoaded = 3;

  @override
  Widget build(BuildContext context) {
    DateTimeRange budgetRange = getBudgetDate(widget.budget, DateTime.now());
    ColorScheme budgetColorScheme = ColorScheme.fromSeed(
      seedColor: HexColor(widget.budget.colour),
      brightness: getSettingConstants(appStateSettings)["theme"] ==
              ThemeMode.system
          ? MediaQuery.of(context).platformBrightness
          : getSettingConstants(appStateSettings)["theme"] == ThemeMode.light
              ? Brightness.light
              : getSettingConstants(appStateSettings)["theme"] == ThemeMode.dark
                  ? Brightness.dark
                  : Brightness.light,
    );

    return PageFramework(
      key: budgetHistoryKey,
      title: "Budget History",
      subtitle: Padding(
        padding: const EdgeInsets.only(left: 20, bottom: 6),
        child: TextFont(
          text: widget.budget.name,
          fontSize: 20,
          maxLines: 5,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitleSize: 10,
      subtitleAnimationSpeed: 9.8,
      subtitleAlignment: Alignment.bottomLeft,
      appBarBackgroundColor: budgetColorScheme.secondaryContainer,
      textColor: Theme.of(context).colorScheme.black,
      navbar: false,
      dragDownToDismiss: true,
      dragDownToDissmissBackground: Theme.of(context).canvasColor,
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 13),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Padding(
                  padding: EdgeInsets.only(
                      bottom: index == amountLoaded - 1 ? 0 : 16.0),
                  child: BudgetContainer(
                    budget: widget.budget,
                    smallBudgetContainer: true,
                    showTodayForSmallBudget: (index == 0 ? true : false),
                    dateForRange: DateTime(
                      DateTime.now().year,
                      DateTime.now().month - index,
                      DateTime.now().day,
                    ),
                  ),
                );
              },
              childCount: amountLoaded, //snapshot.data?.length
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Center(
            child: Tappable(
              color: Theme.of(context).colorScheme.lightDarkAccent,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: TextFont(
                  text: "View More",
                  textAlign: TextAlign.center,
                  fontSize: 16,
                  textColor: Theme.of(context).colorScheme.textLight,
                ),
              ),
              onTap: () {
                setState(() {
                  amountLoaded += 3;
                });
                Future.delayed(Duration(milliseconds: 150), () {
                  budgetHistoryKey.currentState!.scrollToBottom(duration: 4000);
                });
              },
              borderRadius: 10,
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 10)),
      ],
    );
  }
}
