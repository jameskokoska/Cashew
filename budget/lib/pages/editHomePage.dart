import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/main.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/reorderable_list.dart';
import 'package:budget/widgets/editRowEntry.dart';
import 'package:budget/widgets/moreIcons.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/radioItems.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart' hide SliverReorderableList;
import 'package:flutter/services.dart';

class EditHomePageItem {
  final IconData icon;
  final String name;
  final bool isEnabled;
  List<Widget>? extraWidgetsBelow;

  EditHomePageItem({
    required this.icon,
    required this.name,
    required this.isEnabled,
    this.extraWidgetsBelow,
  });
}

class EditHomePage extends StatefulWidget {
  const EditHomePage({super.key});

  @override
  State<EditHomePage> createState() => _EditHomePageState();
}

class _EditHomePageState extends State<EditHomePage> {
  bool dragDownToDismissEnabled = true;
  int currentReorder = -1;

  List<EditHomePageItem> editHomePageItems = [
    EditHomePageItem(
      icon: Icons.account_balance_wallet_rounded,
      name: "Wallets",
      isEnabled: true,
    ),
    EditHomePageItem(
      icon: MoreIcons.chart_pie,
      name: "Budgets",
      isEnabled: true,
    ),
    EditHomePageItem(
      icon: Icons.upcoming_rounded,
      name: "Overdue and Upcoming",
      isEnabled: true,
    ),
    EditHomePageItem(
      icon: Icons.insights_rounded,
      name: "Spending Graph",
      isEnabled: true,
    ),
  ];

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      int indexSpendingGraphItem =
          editHomePageItems.indexWhere((item) => item.name == "Spending Graph");
      String defaultLabel = "Default (30 days)";
      List<Budget> allBudgets = await database.getAllBudgets();
      List<Widget> spendingGraphItems = [
        RadioItems(
          items: [
            defaultLabel,
            ...[for (Budget budget in allBudgets) budget.budgetPk.toString()],
          ],
          displayFilter: (budgetPk) {
            for (Budget budget in allBudgets)
              if (budget.budgetPk.toString() == budgetPk.toString()) {
                return budget.name;
              }
            return defaultLabel;
          },
          initial: appStateSettings["lineGraphReferenceBudgetPk"] == null
              ? defaultLabel
              : appStateSettings["lineGraphReferenceBudgetPk"].toString(),
          onChanged: (value) {
            if (value == defaultLabel) {
              updateSettings(
                "lineGraphReferenceBudgetPk",
                null,
                pagesNeedingRefresh: [0],
                updateGlobalState: false,
              );
              return;
            } else {
              updateSettings(
                "lineGraphReferenceBudgetPk",
                int.parse(value),
                pagesNeedingRefresh: [0],
                updateGlobalState: false,
              );
            }
          },
        ),
      ];
      setState(() {
        editHomePageItems[indexSpendingGraphItem].extraWidgetsBelow =
            spendingGraphItems;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageFramework(
      dragDownToDismiss: dragDownToDismissEnabled,
      title: "Edit Home",
      slivers: [
        SliverReorderableList(
          onReorderStart: (index) {
            HapticFeedback.heavyImpact();
            setState(() {
              dragDownToDismissEnabled = false;
              currentReorder = index;
            });
          },
          onReorderEnd: (_) {
            setState(() {
              dragDownToDismissEnabled = true;
              currentReorder = -1;
            });
          },
          itemBuilder: (context, index) {
            return EditRowEntry(
              canReorder: true,
              currentReorder: currentReorder != -1 && currentReorder != index,
              padding: EdgeInsets.only(left: 18, right: 0, top: 16, bottom: 16),
              key: ValueKey(index),
              extraWidget: Switch(
                activeColor: Theme.of(context).colorScheme.primary,
                value: editHomePageItems[index].isEnabled,
                onChanged: (_) {
                  // toggleSwitch();
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              content: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    editHomePageItems[index].icon,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(width: 13),
                  Expanded(
                    child: TextFont(
                      text: editHomePageItems[index].name,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      maxLines: 5,
                    ),
                  ),
                ],
              ),
              extraWidgetsBelow: editHomePageItems[index].extraWidgetsBelow ??
                  [SizedBox.shrink()],
              canDelete: false,
              index: index,
              onDelete: () {},
              openPage: Container(),
            );
          },
          itemCount: editHomePageItems.length,
          onReorder: (_intPrevious, _intNew) async {
            return true;
          },
        ),
      ],
    );
  }
}
