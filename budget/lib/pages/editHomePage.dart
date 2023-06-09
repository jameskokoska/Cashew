import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/main.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/defaultPreferences.dart';
import 'package:budget/struct/reorderable_list.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/editRowEntry.dart';
import 'package:budget/widgets/moreIcons.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/popupFramework.dart';
import 'package:budget/widgets/radioItems.dart';
import 'package:budget/widgets/selectItems.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart' hide SliverReorderableList;
import 'package:flutter/services.dart';

class EditHomePageItem {
  final IconData icon;
  final String name;
  bool isEnabled;
  final Function(bool value) onSwitched;
  final Function()? onTap;
  List<Widget>? extraWidgetsBelow;

  EditHomePageItem({
    required this.icon,
    required this.name,
    required this.isEnabled,
    required this.onSwitched,
    this.onTap,
    this.extraWidgetsBelow,
  });
}

class EditHomePage extends StatefulWidget {
  const EditHomePage({super.key});

  @override
  State<EditHomePage> createState() => _EditHomePageState();
}

String _defaultLabel = "Default (30 days)";

class _EditHomePageState extends State<EditHomePage> {
  bool dragDownToDismissEnabled = true;
  int currentReorder = -1;

  Map<String, EditHomePageItem> editHomePageItems = {};
  List<dynamic> keyOrder = [];

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      setState(() {
        editHomePageItems = {
          "wallets": EditHomePageItem(
            icon: Icons.account_balance_wallet_rounded,
            name: "Wallets",
            isEnabled: appStateSettings["showWalletSwitcher"],
            onSwitched: (value) {
              updateSettings("showWalletSwitcher", value,
                  pagesNeedingRefresh: [0], updateGlobalState: false);
            },
          ),
          "budgets": EditHomePageItem(
            icon: MoreIcons.chart_pie,
            name: "Budgets",
            isEnabled: appStateSettings["showPinnedBudgets"],
            onSwitched: (value) {
              updateSettings("showPinnedBudgets", value,
                  pagesNeedingRefresh: [0], updateGlobalState: false);
            },
            onTap: () async {
              String defaultLabel = "Default (30 days)";
              List<Budget> allBudgets = await database.getAllBudgets();
              List<Budget> allPinnedBudgets =
                  await database.getAllPinnedBudgets().$2;
              openBottomSheet(
                context,
                PopupFramework(
                  title: "Select Budgets",
                  child: Column(
                    children: [
                      SettingsContainerSwitch(
                        title: "Total Spent",
                        descriptionWithValue: (value) => value
                            ? "Showing total spent"
                            : "Showing remaining amount",
                        onSwitched: (value) {
                          updateSettings("showTotalSpentForBudget", value,
                              pagesNeedingRefresh: [0, 2],
                              updateGlobalState: false);
                        },
                        initialValue:
                            appStateSettings["showTotalSpentForBudget"],
                        icon: Icons.center_focus_weak_rounded,
                      ),
                      SelectItems(
                        checkboxCustomIconSelected: Icons.push_pin_rounded,
                        checkboxCustomIconUnselected: Icons.push_pin_outlined,
                        items: [
                          for (Budget budget in allBudgets)
                            budget.budgetPk.toString()
                        ],
                        displayFilter: (budgetPk) {
                          for (Budget budget in allBudgets)
                            if (budget.budgetPk.toString() ==
                                budgetPk.toString()) {
                              return budget.name;
                            }
                          return defaultLabel;
                        },
                        initialItems: [
                          for (Budget budget in allPinnedBudgets)
                            budget.budgetPk.toString()
                        ],
                        onChangedSingleItem: (value) async {
                          Budget budget = allBudgets[allBudgets.indexWhere(
                              (item) => item.budgetPk == int.parse(value))];
                          Budget budgetToUpdate =
                              await database.getBudgetInstance(budget.budgetPk);
                          await database.createOrUpdateBudget(
                            budgetToUpdate.copyWith(
                                pinned: !budgetToUpdate.pinned),
                            updateSharedEntry: false,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          "overdueUpcoming": EditHomePageItem(
            icon: Icons.upcoming_rounded,
            name: "Overdue and Upcoming",
            isEnabled: appStateSettings["showOverdueUpcoming"],
            onSwitched: (value) {
              updateSettings("showOverdueUpcoming", value,
                  pagesNeedingRefresh: [0], updateGlobalState: false);
            },
          ),
          "spendingGraph": EditHomePageItem(
            icon: Icons.insights_rounded,
            name: "Spending Graph",
            isEnabled: appStateSettings["showSpendingGraph"],
            onSwitched: (value) {
              updateSettings("showSpendingGraph", value,
                  pagesNeedingRefresh: [0], updateGlobalState: false);
            },
            extraWidgetsBelow: [],
            onTap: () async {
              String defaultLabel = "Default (30 days)";
              List<Budget> allBudgets = await database.getAllBudgets();
              openBottomSheet(
                context,
                PopupFramework(
                  title: "Select Budget",
                  child: RadioItems(
                    items: [
                      defaultLabel,
                      ...[
                        for (Budget budget in allBudgets)
                          budget.budgetPk.toString()
                      ],
                    ],
                    displayFilter: (budgetPk) {
                      for (Budget budget in allBudgets)
                        if (budget.budgetPk.toString() == budgetPk.toString()) {
                          return budget.name;
                        }
                      return defaultLabel;
                    },
                    initial:
                        appStateSettings["lineGraphReferenceBudgetPk"] == null
                            ? defaultLabel
                            : appStateSettings["lineGraphReferenceBudgetPk"]
                                .toString(),
                    onChanged: (value) {
                      if (value == defaultLabel) {
                        updateSettings(
                          "lineGraphReferenceBudgetPk",
                          null,
                          pagesNeedingRefresh: [0],
                          updateGlobalState: false,
                        );
                        Navigator.pop(context);
                        return;
                      } else {
                        updateSettings(
                          "lineGraphReferenceBudgetPk",
                          int.parse(value),
                          pagesNeedingRefresh: [0],
                          updateGlobalState: false,
                        );
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              );
            },
          ),
        };
        keyOrder = List<String>.from(appStateSettings["homePageOrder"]
            .map((element) => element.toString()));
      });
      super.initState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageFramework(
      horizontalPadding: getHorizontalPaddingConstrained(context),
      dragDownToDismiss: true,
      dragDownToDismissEnabled: dragDownToDismissEnabled,
      navbar: false,
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
            String key = keyOrder[index];
            return EditRowEntry(
              canReorder: true,
              currentReorder: currentReorder != -1 && currentReorder != index,
              padding: EdgeInsets.only(left: 18, right: 0, top: 16, bottom: 16),
              key: ValueKey(key),
              extraWidget: Row(
                children: [
                  Switch(
                    activeColor: Theme.of(context).colorScheme.primary,
                    value: editHomePageItems[key]!.isEnabled,
                    onChanged: (value) {
                      editHomePageItems[key]!.onSwitched(value);
                      setState(() {
                        editHomePageItems[key]!.isEnabled = value;
                      });
                    },
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
              content: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    editHomePageItems[key]!.icon,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(width: 13),
                  Expanded(
                    child: TextFont(
                      text: editHomePageItems[key]!.name,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      maxLines: 5,
                    ),
                  ),
                  editHomePageItems[key]?.onTap == null
                      ? SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Icon(
                            Icons.more_horiz_rounded,
                            size: 22,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                ],
              ),
              extraWidgetsBelow: editHomePageItems[key]?.extraWidgetsBelow ??
                  [SizedBox.shrink()],
              canDelete: false,
              index: index,
              onDelete: () {},
              onTap: editHomePageItems[key]?.onTap ?? () {},
              openPage: Container(),
            );
          },
          itemCount: editHomePageItems.keys.length,
          onReorder: (oldIndex, newIndex) async {
            setState(() {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final String item = keyOrder.removeAt(oldIndex);
              keyOrder.insert(newIndex, item);
            });
            updateSettings("homePageOrder", keyOrder, pagesNeedingRefresh: [0]);
            return true;
          },
        ),
      ],
    );
  }
}
