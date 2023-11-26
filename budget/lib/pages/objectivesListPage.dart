import 'dart:collection';

import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/pages/addObjectivePage.dart';
import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/pages/editObjectivesPage.dart';
import 'package:budget/pages/objectivePage.dart';
import 'package:budget/struct/currencyFunctions.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/randomConstants.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/budgetContainer.dart';
import 'package:budget/widgets/categoryIcon.dart';
import 'package:budget/widgets/editRowEntry.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/noResults.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/util/widgetSize.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart'
    hide SliverReorderableList, ReorderableDelayedDragStartListener;
import 'package:provider/provider.dart';

class ObjectivesListPage extends StatelessWidget {
  const ObjectivesListPage({required this.backButton, Key? key})
      : super(key: key);
  final bool backButton;

  @override
  Widget build(BuildContext context) {
    return PageFramework(
      dragDownToDismiss: true,
      title: "goals".tr(),
      backButton: backButton,
      horizontalPadding: enableDoubleColumn(context) == false
          ? getHorizontalPaddingConstrained(context)
          : 0,
      actions: [
        IconButton(
          padding: EdgeInsets.all(15),
          tooltip: "edit-goals".tr(),
          onPressed: () {
            pushRoute(
              context,
              EditObjectivesPage(),
            );
          },
          icon: Icon(
            appStateSettings["outlinedIcons"]
                ? Icons.edit_outlined
                : Icons.edit_rounded,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
        if (getIsFullScreen(context))
          IconButton(
            padding: EdgeInsets.all(15),
            tooltip: "add-goal".tr(),
            onPressed: () {
              pushRoute(
                context,
                AddObjectivePage(
                    routesToPopAfterDelete: RoutesToPopAfterDelete.None),
              );
            },
            icon: Icon(
              appStateSettings["outlinedIcons"]
                  ? Icons.add_outlined
                  : Icons.add_rounded,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
      ],
      slivers: [
        StreamBuilder<List<Objective>>(
          stream: database.watchAllObjectives(),
          builder: (context, snapshot) {
            bool showDemoObjectives = false;
            List<Objective> objectivesList = [...(snapshot.data ?? [])];
            if (snapshot.hasData == false ||
                (objectivesList.length <= 0 && snapshot.hasData)) {
              showDemoObjectives = true;
              objectivesList.add(
                Objective(
                  objectivePk: "-3",
                  name: "example-goals-1".tr(),
                  amount: 1500,
                  order: 0,
                  dateCreated: DateTime.now().subtract(Duration(days: 40)),
                  income: false,
                  pinned: false,
                  iconName: "coconut-tree.png",
                  colour: toHexString(Colors.greenAccent),
                  walletFk: "0",
                ),
              );
              objectivesList.add(
                Objective(
                  objectivePk: "-2",
                  name: "example-goals-2".tr(),
                  amount: 2000,
                  order: 0,
                  dateCreated: DateTime.now().subtract(Duration(days: 10)),
                  income: false,
                  pinned: false,
                  iconName: "car(1).png",
                  colour: toHexString(Colors.orangeAccent),
                  walletFk: "0",
                ),
              );
            }
            Widget addButton = Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: getPlatform() == PlatformOS.isIOS ? 10 : 0,
                          bottom: 20,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                getPlatform() == PlatformOS.isIOS ? 13 : 0,
                          ),
                          child: AddButton(
                            onTap: () {},
                            openPage: AddObjectivePage(
                              routesToPopAfterDelete:
                                  RoutesToPopAfterDelete.PreventDelete,
                            ),
                            height: 150,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (showDemoObjectives)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: TextFont(
                      text: "example-goals".tr(),
                      textColor: getColor(context, "black").withOpacity(0.25),
                      fontSize: 16,
                      textAlign: TextAlign.center,
                    ),
                  )
              ],
            );
            return SliverPadding(
              padding: EdgeInsets.symmetric(
                vertical: getPlatform() == PlatformOS.isIOS ? 3 : 7,
                horizontal: getPlatform() == PlatformOS.isIOS ? 0 : 13,
              ),
              sliver: enableDoubleColumn(context)
                  ? SliverGrid(
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 500.0,
                        mainAxisExtent: 160,
                        mainAxisSpacing:
                            getPlatform() == PlatformOS.isIOS ? 0 : 15.0,
                        crossAxisSpacing:
                            getPlatform() == PlatformOS.isIOS ? 0 : 15.0,
                        childAspectRatio: 5,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          if ((showDemoObjectives && index == 0) ||
                              (showDemoObjectives == false &&
                                  index == objectivesList.length)) {
                            return AddButton(
                              onTap: () {},
                              openPage: AddObjectivePage(
                                routesToPopAfterDelete:
                                    RoutesToPopAfterDelete.PreventDelete,
                              ),
                            );
                          } else {
                            Objective objective = objectivesList[
                                index - (showDemoObjectives ? 1 : 0)];
                            return ObjectiveContainer(
                              index: index,
                              objective: objective,
                              forcedTotalAmount: showDemoObjectives
                                  ? (objective.income
                                          ? randomInt[index].toDouble()
                                          : randomInt[index].toDouble() * -1) *
                                      15
                                  : null,
                              forcedNumberTransactions:
                                  showDemoObjectives ? randomInt[index] : null,
                            );
                          }
                        },
                        childCount: (objectivesList.length) + 1,
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          if ((showDemoObjectives && index == 0) ||
                              (showDemoObjectives == false &&
                                  index == objectivesList.length)) {
                            return addButton;
                          } else {
                            Objective objective = objectivesList[
                                index - (showDemoObjectives ? 1 : 0)];
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: getPlatform() == PlatformOS.isIOS
                                    ? 0
                                    : 16.0,
                              ),
                              child: ObjectiveContainer(
                                index: index,
                                objective: objective,
                                forcedTotalAmount: showDemoObjectives
                                    ? (objective.income
                                            ? randomInt[index].toDouble()
                                            : randomInt[index].toDouble() *
                                                -1) *
                                        15
                                    : null,
                                forcedNumberTransactions: showDemoObjectives
                                    ? randomInt[index]
                                    : null,
                              ),
                            );
                          }
                        },
                        childCount: (objectivesList.length) + 1,
                      ),
                    ),
            );
          },
        ),
        SliverToBoxAdapter(
          child: SizedBox(height: 50),
        ),
      ],
    );
  }
}

class ObjectiveContainer extends StatelessWidget {
  const ObjectiveContainer({
    required this.objective,
    required this.index,
    this.forcedTotalAmount,
    this.forcedNumberTransactions,
    this.forceAndroidBubbleDesign = false, //forced on the homepage
    super.key,
  });
  final Objective objective;
  final int index;
  final double? forcedTotalAmount;
  final int? forcedNumberTransactions;
  final bool forceAndroidBubbleDesign;

  @override
  Widget build(BuildContext context) {
    double borderRadius =
        getPlatform() == PlatformOS.isIOS && forceAndroidBubbleDesign == false
            ? 0
            : 20;
    Color containerColor =
        getPlatform() == PlatformOS.isIOS && forceAndroidBubbleDesign == false
            ? Theme.of(context).canvasColor
            : getColor(context, "lightDarkAccentHeavyLight");
    EdgeInsets containerPadding = EdgeInsets.only(
      left:
          getPlatform() == PlatformOS.isIOS && forceAndroidBubbleDesign == false
              ? 23
              : 30,
      right:
          getPlatform() == PlatformOS.isIOS && forceAndroidBubbleDesign == false
              ? 23
              : 20,
    );
    Widget child = StreamBuilder<double?>(
      stream: database.watchTotalTowardsObjective(
        Provider.of<AllWallets>(context),
        objective.objectivePk,
      ),
      builder: (context, snapshot) {
        double objectiveAmount = objectiveAmountToPrimaryCurrency(
            Provider.of<AllWallets>(context, listen: true), objective);
        double totalAmount = forcedTotalAmount ?? snapshot.data ?? 0;
        if (objective.income == false) {
          totalAmount = totalAmount * -1;
        }
        double percentageTowardsGoal =
            objectiveAmount == 0 ? 0 : totalAmount / objectiveAmount;
        return Container(
          decoration: BoxDecoration(
            boxShadow: getPlatform() == PlatformOS.isIOS &&
                    forceAndroidBubbleDesign == false
                ? []
                : boxShadowCheck(boxShadowGeneral(context)),
          ),
          child: OpenContainerNavigation(
            openPage: ObjectivePage(objectivePk: objective.objectivePk),
            borderRadius: borderRadius,
            closedColor: containerColor,
            button: (openContainer()) {
              return Tappable(
                onLongPress: () {
                  pushRoute(
                    context,
                    AddObjectivePage(
                      routesToPopAfterDelete: RoutesToPopAfterDelete.One,
                      objective: objective,
                    ),
                  );
                },
                color: containerColor,
                onTap: () {
                  openContainer();
                },
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 18,
                    bottom: 23,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: containerPadding,
                        child: Column(children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextFont(
                                      text: objective.name,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(right: 3),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 3),
                                              child:
                                                  Builder(builder: (context) {
                                                String content =
                                                    getWordedDateShortMore(
                                                  objective.dateCreated,
                                                  includeYear: objective
                                                          .dateCreated.year !=
                                                      DateTime.now().year,
                                                );
                                                if (objective.endDate != null) {
                                                  content = getObjectiveStatus(
                                                    context,
                                                    objective,
                                                    totalAmount,
                                                    percentageTowardsGoal,
                                                  );
                                                }
                                                return TextFont(
                                                  text: content,
                                                  fontSize: 15,
                                                  textColor:
                                                      getColor(context, "black")
                                                          .withOpacity(0.65),
                                                  maxLines: 1,
                                                );
                                              }),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              CategoryIcon(
                                categoryPk: "-1",
                                category: TransactionCategory(
                                  categoryPk: "-1",
                                  name: "",
                                  dateCreated: DateTime.now(),
                                  dateTimeModified: null,
                                  order: 0,
                                  income: false,
                                  iconName: objective.iconName,
                                  colour: objective.colour,
                                  emojiIconName: objective.emojiIconName,
                                ),
                                size: 30,
                                sizePadding: 20,
                                borderRadius: 100,
                                canEditByLongPress: false,
                                margin: EdgeInsets.zero,
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Flexible(
                                child: StreamBuilder<int?>(
                                  stream: database
                                      .getTotalCountOfTransactionsInObjective(
                                          objective.objectivePk)
                                      .$1,
                                  builder: (context, snapshot) {
                                    int numberTransactions =
                                        forcedNumberTransactions ??
                                            snapshot.data ??
                                            0;
                                    return TextFont(
                                      textAlign: TextAlign.left,
                                      text: numberTransactions.toString() +
                                          " " +
                                          (numberTransactions == 1
                                              ? "transaction".tr().toLowerCase()
                                              : "transactions"
                                                  .tr()
                                                  .toLowerCase()),
                                      fontSize: 15,
                                      textColor: getColor(context, "black")
                                          .withOpacity(0.65),
                                    );
                                  },
                                ),
                              ),
                              Builder(builder: (context) {
                                String amountSpentLabel =
                                    getObjectiveAmountSpentLabel(
                                  context: context,
                                  showTotalSpent: appStateSettings[
                                      "showTotalSpentForObjective"],
                                  objectiveAmount: objectiveAmount,
                                  totalAmount: totalAmount,
                                );
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    TextFont(
                                      fontWeight: FontWeight.bold,
                                      text: amountSpentLabel,
                                      fontSize: 24,
                                      textColor: totalAmount >= objectiveAmount
                                          ? getColor(context, "incomeAmount")
                                          : getColor(context, "black"),
                                    ),
                                    if (isShowingAmountRemaining(
                                        showTotalSpent: appStateSettings[
                                            "showTotalSpentForObjective"],
                                        objectiveAmount: objectiveAmount,
                                        totalAmount: totalAmount))
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 2.5),
                                        child: TextFont(
                                          text: " " + "remaining".tr(),
                                          fontSize: 15,
                                          textColor: getColor(context, "black")
                                              .withOpacity(0.3),
                                        ),
                                      ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 2.5),
                                      child: TextFont(
                                        text: " / " +
                                            convertToMoney(
                                                Provider.of<AllWallets>(
                                                    context),
                                                objectiveAmount),
                                        fontSize: 15,
                                        textColor: getColor(context, "black")
                                            .withOpacity(0.3),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ],
                          ),
                          SizedBox(height: 8),
                        ]),
                      ),
                      Padding(
                        padding: objective.endDate == null
                            ? containerPadding
                            : const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (objective.endDate != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 7),
                                child: TextFont(
                                  textAlign: TextAlign.center,
                                  text: getWordedDateShort(
                                    objective.dateCreated,
                                    includeYear: objective.dateCreated.year !=
                                        DateTime.now().year,
                                  ),
                                  fontSize: 12,
                                  textColor: getColor(context, "black")
                                      .withOpacity(0.3),
                                ),
                              ),
                            Expanded(
                              child: BudgetProgress(
                                color: HexColor(
                                  objective.colour,
                                  defaultColor:
                                      Theme.of(context).colorScheme.primary,
                                ),
                                ghostPercent: 0,
                                percent: percentageTowardsGoal * 100,
                                todayPercent: -1,
                                showToday: false,
                                yourPercent: 0,
                                padding: EdgeInsets.zero,
                                enableShake: false,
                                backgroundColor: (getPlatform() ==
                                                PlatformOS.isIOS &&
                                            forceAndroidBubbleDesign ==
                                                false) ||
                                        appStateSettings["materialYou"] == false
                                    ? null
                                    : Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer,
                              ),
                            ),
                            if (objective.endDate != null)
                              Padding(
                                padding: const EdgeInsets.only(left: 7),
                                child: TextFont(
                                  textAlign: TextAlign.center,
                                  text: getWordedDateShort(
                                    objective.endDate!,
                                    includeYear: objective.endDate?.year !=
                                        DateTime.now().year,
                                  ),
                                  fontSize: 12,
                                  textColor: getColor(context, "black")
                                      .withOpacity(0.3),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
    if (getPlatform() == PlatformOS.isIOS &&
        forceAndroidBubbleDesign == false) {
      child = Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          index == 0 || enableDoubleColumn(context)
              ? Container(
                  height: 1.5,
                  color: getColor(context, "dividerColor"),
                )
              : SizedBox.shrink(),
          child,
          Container(
            height: 1.5,
            color: getColor(context, "dividerColor"),
          ),
        ],
      );
    }
    if (forcedNumberTransactions != null || forcedTotalAmount != null) {
      return IgnorePointer(
        child: Opacity(
          opacity: 0.25,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.grey,
                BlendMode.saturation,
              ),
              child: child,
            ),
          ),
        ),
      );
    } else {
      return child;
    }
  }
}

String getObjectiveStatus(BuildContext context, Objective objective,
    double totalAmount, double percentageTowardsGoal,
    {bool addSpendingSavingIndication = false}) {
  double objectiveAmount = objectiveAmountToPrimaryCurrency(
      Provider.of<AllWallets>(context, listen: true), objective);

  String content;
  if (objective.endDate == null) return "";
  int remainingDays = objective.endDate!
          .difference(
            DateTime(DateTime.now().year, DateTime.now().month,
                DateTime.now().day, 0, 0),
          )
          .inDays +
      1;
  double amount = ((totalAmount - objectiveAmount) / remainingDays) * -1;
  if (percentageTowardsGoal >= 1) {
    content = "goal-reached".tr();
  } else if (remainingDays <= 0) {
    content = "goal-overdue".tr();
  } else {
    content = (addSpendingSavingIndication
            ? (objective.income ? "save".tr() + " " : "spend".tr() + " ")
            : "") +
        convertToMoney(Provider.of<AllWallets>(context), amount.abs()) +
        "/" +
        "day".tr() +
        " " +
        "for".tr() +
        " " +
        remainingDays.toString() +
        " " +
        (remainingDays == 1 ? "day".tr() : "days".tr());
  }
  return content;
}

bool isShowingAmountRemaining({
  required bool showTotalSpent,
  required double objectiveAmount,
  required double totalAmount,
}) {
  return showTotalSpent == false && totalAmount < objectiveAmount;
}

String getObjectiveAmountSpentLabel({
  required BuildContext context,
  required bool showTotalSpent,
  required double objectiveAmount,
  required double totalAmount,
}) {
  bool showTotalRemaining = isShowingAmountRemaining(
      showTotalSpent: showTotalSpent,
      objectiveAmount: objectiveAmount,
      totalAmount: totalAmount);
  double amountSpent =
      showTotalRemaining ? objectiveAmount - totalAmount : totalAmount;
  String amountSpentLabel = convertToMoney(
    Provider.of<AllWallets>(context),
    amountSpent,
  );
  return amountSpentLabel;
}
