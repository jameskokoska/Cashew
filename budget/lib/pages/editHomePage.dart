import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/pages/addObjectivePage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/pages/homePage/homePageBudgets.dart';
import 'package:budget/pages/homePage/homePageLineGraph.dart';
import 'package:budget/pages/homePage/homePageNetWorth.dart';
import 'package:budget/pages/homePage/homePageObjectives.dart';
import 'package:budget/pages/homePage/homePageWalletSwitcher.dart';
import 'package:budget/pages/walletDetailsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/modified/reorderable_list.dart';
import 'package:budget/struct/navBarIconsData.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/editRowEntry.dart';
import 'package:budget/widgets/moreIcons.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/periodCyclePicker.dart';
import 'package:budget/widgets/radioItems.dart';
import 'package:budget/widgets/selectAmount.dart';
import 'package:budget/widgets/selectItems.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/util/showDatePicker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart' hide SliverReorderableList;
import 'package:flutter/material.dart' hide SliverReorderableList;
import 'package:flutter/services.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/functions.dart';
import 'package:provider/provider.dart';

import '../widgets/tappableTextEntry.dart';

// We need to refresh the home page when this route is popped

class EditHomePageItem {
  final IconData icon;
  final String name;
  bool isEnabled;
  final Function(bool value) onSwitched;
  final Function()? onTap;
  List<Widget>? extraWidgetsBelow;
  final bool enabled;

  EditHomePageItem({
    required this.icon,
    required this.name,
    required this.isEnabled,
    required this.onSwitched,
    this.onTap,
    this.extraWidgetsBelow,
    this.enabled = true,
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

  Map<String, EditHomePageItem> editHomePageItems = {};
  List<dynamic> keyOrder = [];

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      setState(() {
        editHomePageItems = {
          "wallets": EditHomePageItem(
            icon: appStateSettings["outlinedIcons"]
                ? Icons.account_balance_wallet_outlined
                : Icons.account_balance_wallet_rounded,
            name: "accounts".tr(),
            isEnabled:
                isHomeScreenSectionEnabled(context, "showWalletSwitcher"),
            onSwitched: (value) {
              switchHomeScreenSection(context, "showWalletSwitcher", value);
            },
            onTap: () {
              openBottomSheet(
                context,
                EditHomePagePinnedWalletsPopup(
                  homePageWidgetDisplay: HomePageWidgetDisplay.WalletSwitcher,
                ),
                useCustomController: true,
              );
            },
          ),
          "walletsList": EditHomePageItem(
            icon: appStateSettings["outlinedIcons"]
                ? Icons.format_list_bulleted_outlined
                : Icons.format_list_bulleted_rounded,
            name: "accounts-list".tr(),
            isEnabled: isHomeScreenSectionEnabled(context, "showWalletList"),
            onSwitched: (value) {
              switchHomeScreenSection(context, "showWalletList", value);
            },
            onTap: () {
              openBottomSheet(
                context,
                EditHomePagePinnedWalletsPopup(
                  homePageWidgetDisplay: HomePageWidgetDisplay.WalletList,
                ),
                useCustomController: true,
              );
            },
          ),
          "budgets": EditHomePageItem(
            icon: appStateSettings["outlinedIcons"]
                ? Icons.donut_small_outlined
                : MoreIcons.chart_pie,
            name: "budgets".tr(),
            isEnabled: isHomeScreenSectionEnabled(context, "showPinnedBudgets"),
            onSwitched: (value) {
              switchHomeScreenSection(context, "showPinnedBudgets", value);
            },
            onTap: () {
              openBottomSheet(
                context,
                EditHomePagePinnedBudgetsPopup(
                  showBudgetsTotalLabelSetting: true,
                ),
                useCustomController: true,
              );
            },
          ),
          "objectives": EditHomePageItem(
            icon: appStateSettings["outlinedIcons"]
                ? Icons.savings_outlined
                : Icons.savings_rounded,
            name: "goals".tr(),
            isEnabled: isHomeScreenSectionEnabled(context, "showObjectives"),
            onSwitched: (value) {
              switchHomeScreenSection(context, "showObjectives", value);
            },
            onTap: () async {
              openBottomSheet(
                context,
                EditHomePagePinnedGoalsPopup(showGoalsTotalLabelSetting: true),
                useCustomController: true,
              );
            },
          ),
          "overdueUpcoming": EditHomePageItem(
            icon: getTransactionTypeIcon(TransactionSpecialType.subscription),
            name: "overdue-and-upcoming".tr(),
            isEnabled:
                isHomeScreenSectionEnabled(context, "showOverdueUpcoming"),
            onSwitched: (value) {
              switchHomeScreenSection(context, "showOverdueUpcoming", value);
            },
            onTap: () async {
              openBottomSheet(
                context,
                PopupFramework(
                  title: "select-period".tr(),
                  child: PeriodCyclePicker(
                      cycleSettingsExtension: "OverdueUpcoming"),
                ),
              );
            },
          ),
          "creditDebts": EditHomePageItem(
            icon: getTransactionTypeIcon(TransactionSpecialType.credit),
            // name: "lent-and-borrowed".tr(),
            name: "loans".tr(),
            isEnabled: isHomeScreenSectionEnabled(context, "showCreditDebt"),
            onSwitched: (value) {
              switchHomeScreenSection(context, "showCreditDebt", value);
            },
            onTap: () async {
              openBottomSheet(
                context,
                PopupFramework(
                  title: "select-period".tr(),
                  child:
                      PeriodCyclePicker(cycleSettingsExtension: "CreditDebts"),
                ),
              );
            },
          ),
          "allSpendingSummary": EditHomePageItem(
            icon: appStateSettings["outlinedIcons"]
                ? Icons.swap_vert_outlined
                : Icons.swap_vert_rounded,
            name: "income-and-expenses".tr(),
            isEnabled:
                isHomeScreenSectionEnabled(context, "showAllSpendingSummary"),
            onSwitched: (value) {
              switchHomeScreenSection(context, "showAllSpendingSummary", value);
            },
            onTap: () async {
              openBottomSheet(
                context,
                PopupFramework(
                  title: "select-period".tr(),
                  child: PeriodCyclePicker(
                      cycleSettingsExtension: "AllSpendingSummary"),
                ),
              );
            },
          ),
          "netWorth": EditHomePageItem(
            icon: appStateSettings["outlinedIcons"]
                ? Icons.area_chart_outlined
                : Icons.area_chart_rounded,
            name: "net-worth".tr(),
            isEnabled: isHomeScreenSectionEnabled(context, "showNetWorth"),
            onSwitched: (value) {
              switchHomeScreenSection(context, "showNetWorth", value);
            },
            extraWidgetsBelow: [],
            onTap: () async {
              await openBottomSheet(
                context,
                PopupFramework(
                  title: "net-worth-settings".tr(),
                  child: WalletPickerPeriodCycle(
                    allWalletsSettingKey: "netWorthAllWallets",
                    cycleSettingsExtension: "NetWorth",
                    homePageWidgetDisplay: HomePageWidgetDisplay.NetWorth,
                  ),
                ),
              );
            },
          ),
          "spendingGraph": EditHomePageItem(
            icon: appStateSettings["outlinedIcons"]
                ? Icons.insights_outlined
                : Icons.insights_rounded,
            name: "spending-graph".tr(),
            isEnabled: isHomeScreenSectionEnabled(context, "showSpendingGraph"),
            onSwitched: (value) {
              switchHomeScreenSection(context, "showSpendingGraph", value);
            },
            extraWidgetsBelow: [],
            onTap: () async {
              String defaultLabel = "default-line-graph".tr();
              String customLabel = "custom-line-graph".tr();
              List<Budget> allBudgets = await database.getAllBudgets();
              openBottomSheet(
                context,
                PopupFramework(
                  title: "select-graph".tr(),
                  child: RadioItems(
                    items: [
                      defaultLabel,
                      customLabel,
                      ...[
                        for (Budget budget in allBudgets)
                          budget.budgetPk.toString()
                      ],
                    ],
                    colorFilter: (budgetPk) {
                      for (Budget budget in allBudgets)
                        if (budget.budgetPk.toString() == budgetPk.toString()) {
                          return dynamicPastel(
                            context,
                            lightenPastel(
                              HexColor(
                                budget.colour,
                                defaultColor:
                                    Theme.of(context).colorScheme.primary,
                              ),
                              amount: 0.2,
                            ),
                            amount: 0.1,
                          );
                        }
                      return null;
                    },
                    displayFilter: (budgetPk) {
                      for (Budget budget in allBudgets)
                        if (budget.budgetPk.toString() == budgetPk.toString()) {
                          return budget.name;
                        }
                      if (budgetPk == customLabel)
                        return ('${customLabel} (${getWordedDateShortMore(DateTime.parse(appStateSettings["lineGraphStartDate"]), includeYear: true)})');
                      return budgetPk;
                    },
                    initial: appStateSettings["lineGraphDisplayType"] ==
                            LineGraphDisplay.Default30Days.index
                        ? defaultLabel
                        : appStateSettings["lineGraphDisplayType"] ==
                                LineGraphDisplay.CustomStartDate.index
                            ? customLabel
                            : appStateSettings["lineGraphReferenceBudgetPk"]
                                .toString(),
                    onChanged: (value) async {
                      if (value == defaultLabel) {
                        updateSettings(
                          "lineGraphDisplayType",
                          LineGraphDisplay.Default30Days.index,
                          pagesNeedingRefresh: [],
                          updateGlobalState: false,
                        );
                      } else if (value == customLabel) {
                        DateTime? picked = await showCustomDatePicker(
                          context,
                          DateTime.parse(
                              appStateSettings["lineGraphStartDate"]),
                        );
                        if (picked == null || picked.isAfter(DateTime.now())) {
                          if (DateTime.parse(
                                  appStateSettings["lineGraphStartDate"])
                              .isAfter(DateTime.now())) {
                            picked = DateTime.now();
                          } else {
                            picked = DateTime.parse(
                                appStateSettings["lineGraphStartDate"]);
                          }
                        }
                        updateSettings(
                          "lineGraphStartDate",
                          (picked ?? appStateSettings["lineGraphDisplayType"])
                              .toString(),
                          pagesNeedingRefresh: [],
                          updateGlobalState: false,
                        );
                        updateSettings(
                          "lineGraphDisplayType",
                          LineGraphDisplay.CustomStartDate.index,
                          pagesNeedingRefresh: [],
                          updateGlobalState: false,
                        );
                      } else {
                        updateSettings(
                          "lineGraphReferenceBudgetPk",
                          value,
                          pagesNeedingRefresh: [],
                          updateGlobalState: false,
                        );
                        updateSettings(
                          "lineGraphDisplayType",
                          LineGraphDisplay.Budget.index,
                          pagesNeedingRefresh: [],
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
          "pieChart": EditHomePageItem(
              icon: appStateSettings["outlinedIcons"]
                  ? Icons.pie_chart_outline
                  : Icons.pie_chart_rounded,
              name: "pie-chart".tr(),
              isEnabled: isHomeScreenSectionEnabled(context, "showPieChart"),
              onSwitched: (value) {
                switchHomeScreenSection(context, "showPieChart", value);
              },
              extraWidgetsBelow: [],
              onTap: () {
                openBottomSheet(
                  context,
                  PopupFramework(
                    title: "select-type".tr(),
                    child: Column(
                      children: [
                        RadioItems(
                          items: <String>[
                            "expense",
                            "income",
                          ],
                          displayFilter: (type) {
                            return type.toString().tr();
                          },
                          initial: appStateSettings["pieChartIsIncome"] == true
                              ? "income"
                              : "expense",
                          onChanged: (type) async {
                            if (type == "expense") {
                              updateSettings("pieChartIsIncome", false,
                                  updateGlobalState: false);
                            } else {
                              updateSettings("pieChartIsIncome", true,
                                  updateGlobalState: false);
                            }
                            Navigator.of(context).pop();
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: HorizontalBreakAbove(
                            enabled: true,
                            child: PeriodCyclePicker(
                              cycleSettingsExtension: "PieChart",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          "heatMap": EditHomePageItem(
            icon: appStateSettings["outlinedIcons"]
                ? Icons.grid_on_outlined
                : Icons.grid_on_rounded,
            name: "heat-map".tr(),
            isEnabled: isHomeScreenSectionEnabled(context, "showHeatMap"),
            onSwitched: (value) {
              switchHomeScreenSection(context, "showHeatMap", value);
            },
            extraWidgetsBelow: [],
          ),
          "transactionsList": EditHomePageItem(
            icon: navBarIconsData["transactions"]!.iconData,
            name: "transactions-list".tr(),
            isEnabled:
                isHomeScreenSectionEnabled(context, "showTransactionsList"),
            onSwitched: (value) {
              switchHomeScreenSection(context, "showTransactionsList", value);
            },
            extraWidgetsBelow: [],
            enabled: enableDoubleColumn(context) == false,
          ),
        };
        keyOrder = List<String>.from(appStateSettings["homePageOrder"]
            .map((element) => element.toString()));
      });
    });
    super.initState();
  }

  toggleSwitch(String key) {
    editHomePageItems[key]
        ?.onSwitched(!(editHomePageItems[key]?.isEnabled ?? false));
    setState(() {
      editHomePageItems[key]?.isEnabled =
          !(editHomePageItems[key]?.isEnabled ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // We need to refresh the home page when this route is popped
        homePageStateKey.currentState?.refreshState();
        return true;
      },
      child: PageFramework(
        horizontalPadding: getHorizontalPaddingConstrained(context),
        dragDownToDismiss: true,
        dragDownToDismissEnabled: dragDownToDismissEnabled,
        title: "edit-home".tr(),
        slivers: [
          SliverToBoxAdapter(
            child: HomePageEditRowEntryUsername(
              iconData: appStateSettings["outlinedIcons"]
                  ? Icons.edit_outlined
                  : Icons.edit_rounded,
              initialValue: isHomeScreenSectionEnabled(
                  context, "showUsernameWelcomeBanner"),
              name: appStateSettings["username"] == null ||
                      appStateSettings["username"] == ""
                  ? "homepage-banner".tr()
                  : "username-banner".tr(),
              onChanged: (value) {
                switchHomeScreenSection(
                    context, "showUsernameWelcomeBanner", value);
              },
            ),
          ),
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
              if (keyOrder.length <= index)
                return Container(
                  key: ValueKey(index),
                );
              String key = keyOrder[index];
              if (editHomePageItems[key] == null ||
                  editHomePageItems[key]?.enabled != true)
                return Container(
                  key: ValueKey(index),
                );

              return EditRowEntry(
                canReorder: true,
                currentReorder: currentReorder != -1 && currentReorder != index,
                padding:
                    EdgeInsets.only(left: 18, right: 0, top: 16, bottom: 16),
                key: ValueKey(key),
                extraWidget: Row(
                  children: [
                    getPlatform() == PlatformOS.isIOS
                        ? CupertinoSwitch(
                            activeColor: Theme.of(context).colorScheme.primary,
                            value: editHomePageItems[key]?.isEnabled ?? false,
                            onChanged: (value) {
                              toggleSwitch(key);
                            },
                          )
                        : Switch(
                            activeColor: Theme.of(context).colorScheme.primary,
                            value: editHomePageItems[key]?.isEnabled ?? false,
                            onChanged: (value) {
                              toggleSwitch(key);
                            },
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
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
                  ],
                ),
                hasMoreOptionsIcon: editHomePageItems[key]?.onTap != null,
                extraWidgetsBelow: editHomePageItems[key]?.extraWidgetsBelow,
                canDelete: false,
                index: index,
                onTap: editHomePageItems[key]?.onTap ??
                    () {
                      toggleSwitch(key);
                    },
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
              updateSettings("homePageOrder", keyOrder,
                  pagesNeedingRefresh: [], updateGlobalState: false);
              return true;
            },
          ),
        ],
      ),
    );
  }
}

class HomePageEditRowEntryUsername extends StatefulWidget {
  const HomePageEditRowEntryUsername(
      {required this.initialValue,
      required this.onChanged,
      required this.iconData,
      required this.name,
      super.key});

  final bool initialValue;
  final Function(bool value) onChanged;
  final IconData iconData;
  final String name;

  @override
  State<HomePageEditRowEntryUsername> createState() =>
      _HomePageEditRowEntryUsernameState();
}

class _HomePageEditRowEntryUsernameState
    extends State<HomePageEditRowEntryUsername> {
  late bool value = widget.initialValue;
  @override
  Widget build(BuildContext context) {
    return EditRowEntry(
      canReorder: false,
      padding: EdgeInsets.only(left: 18, right: 0, top: 16, bottom: 16),
      extraWidget: Row(
        children: [
          getPlatform() == PlatformOS.isIOS
              ? CupertinoSwitch(
                  activeColor: Theme.of(context).colorScheme.primary,
                  value: value,
                  onChanged: (value) {
                    widget.onChanged(value);
                    setState(() {
                      this.value = value;
                    });
                  },
                )
              : Switch(
                  activeColor: Theme.of(context).colorScheme.primary,
                  value: value,
                  onChanged: (value) {
                    widget.onChanged(value);
                    setState(() {
                      this.value = value;
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
            widget.iconData,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(width: 13),
          Expanded(
            child: TextFont(
              text: widget.name,
              fontWeight: FontWeight.bold,
              fontSize: 17,
              maxLines: 5,
            ),
          ),
        ],
      ),
      canDelete: false,
      index: 0,
      onTap: () {
        widget.onChanged(!value);
        setState(() {
          this.value = !value;
        });
      },
      openPage: Container(),
    );
  }
}

void switchHomeScreenSection(
    BuildContext context, String sectionSetting, bool value) {
  if (enableDoubleColumn(context)) {
    updateSettings(sectionSetting + "FullScreen", value,
        pagesNeedingRefresh: [], updateGlobalState: false);
  } else {
    updateSettings(sectionSetting, value,
        pagesNeedingRefresh: [], updateGlobalState: false);
  }
}

bool isHomeScreenSectionEnabled(BuildContext context, String sectionSetting) {
  if (enableDoubleColumn(context)) {
    if (appStateSettings[sectionSetting + "FullScreen"] != null)
      return appStateSettings[sectionSetting + "FullScreen"];
    return false;
  } else {
    if (appStateSettings[sectionSetting] != null)
      return appStateSettings[sectionSetting];
    return false;
  }
}
