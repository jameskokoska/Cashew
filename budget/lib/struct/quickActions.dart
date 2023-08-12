import "package:budget/database/tables.dart";
import "package:budget/functions.dart";
import "package:budget/main.dart";
import "package:budget/pages/addTransactionPage.dart";
import "package:budget/pages/budgetPage.dart";
import "package:budget/struct/databaseGlobal.dart";
import "package:budget/widgets/openPopup.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:quick_actions/quick_actions.dart";

void runQuickActionsPayLoads(context) async {
  if (kIsWeb) return;
  final QuickActions quickActions = const QuickActions();
  quickActions.initialize((String quickAction) async {
    if (Navigator.of(context).canPop() == false || entireAppLoaded) {
      if (quickAction == "addTransaction") {
        pushRoute(
          context,
          AddTransactionPage(
            routesToPopAfterDelete: RoutesToPopAfterDelete.None,
          ),
        );
      } else if (quickAction.contains("openBudget")) {
        String budgetPk = quickAction.replaceAll("openBudget-", "");
        try {
          Budget budget = await database.getBudgetInstance(budgetPk);
          pushRoute(
            context,
            BudgetPage(
              budgetPk: budgetPk,
              dateForRange: DateTime.now(),
              isPastBudget: false,
              isPastBudgetButCurrentPeriod: false,
            ),
          );
        } catch (e) {
          print("Budget doesn't exist");
          print(e.toString());
        }
      }
    }
  });
  List<Budget> budgets = await database.getAllBudgets();
  quickActions.setShortcutItems(<ShortcutItem>[
    ShortcutItem(
      type: "addTransaction",
      localizedTitle: "add-transaction".tr(),
      icon: "addtransaction",
    ),
    for (Budget budget in budgets)
      ShortcutItem(
        type: "openBudget-" + budget.budgetPk.toString(),
        localizedTitle: budget.name,
        icon: "piggybank",
      ),
  ]);
}
