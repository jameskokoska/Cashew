import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addObjectivePage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/editBudgetLimitsPage.dart';
import 'package:budget/pages/objectivesListPage.dart';
import 'package:budget/pages/pastBudgetsPage.dart';
import 'package:budget/pages/premiumPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/animatedCircularProgress.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/categoryIcon.dart';
import 'package:budget/widgets/dropdownSelect.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/selectedTransactionsAppBar.dart';
import 'package:budget/widgets/budgetContainer.dart';
import 'package:budget/widgets/categoryEntry.dart';
import 'package:budget/widgets/categoryLimits.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/lineGraph.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/pieChart.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntries.dart';
import 'package:budget/widgets/transactionEntry/transactionEntry.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';
import 'package:async/async.dart' show StreamZip;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:budget/widgets/countNumber.dart';
import 'package:budget/struct/currencyFunctions.dart';
import 'package:confetti/confetti.dart';

import '../widgets/util/widgetSize.dart';

class ObjectivePage extends StatelessWidget {
  const ObjectivePage({
    super.key,
    required this.objectivePk,
  });
  final String objectivePk;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Objective>(
        stream: database.getObjective(objectivePk),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _ObjectivePageContent(
              objective: snapshot.data!,
            );
          }
          return SizedBox.shrink();
        });
    ;
  }
}

class _ObjectivePageContent extends StatefulWidget {
  const _ObjectivePageContent({
    Key? key,
    required this.objective,
  }) : super(key: key);

  final Objective objective;

  @override
  State<_ObjectivePageContent> createState() => _ObjectivePageContentState();
}

class _ObjectivePageContentState extends State<_ObjectivePageContent> {
  final ConfettiController confettiController = ConfettiController();
  bool hasPlayedConfetti = false;

  bool showTotalSpent = appStateSettings["showTotalSpentForObjective"];

  _swapTotalSpentDisplay() {
    setState(() {
      showTotalSpent = !showTotalSpent;
    });
    updateSettings(
      "showTotalSpentForObjective",
      showTotalSpent,
      updateGlobalState: true,
    );
  }

  @override
  void initState() {
    confettiController.addListener(confettiListener);
    super.initState();
  }

  @override
  void dispose() {
    confettiController.dispose();
    super.dispose();
  }

  confettiListener() {
    if (mounted &&
        confettiController.state == ConfettiControllerState.playing) {
      Future.delayed(Duration(milliseconds: 2000), () {
        if (mounted) confettiController.stop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme objectiveColorScheme = ColorScheme.fromSeed(
      seedColor: HexColor(widget.objective.colour,
          defaultColor: Theme.of(context).colorScheme.primary),
      brightness: determineBrightnessTheme(context),
    );
    Color? pageBackgroundColor = appStateSettings["materialYou"]
        ? dynamicPastel(context, objectiveColorScheme.primary, amount: 0.92)
        : null;
    String pageId = widget.objective.objectivePk;
    return WillPopScope(
      onWillPop: () async {
        if ((globalSelectedID.value[pageId] ?? []).length > 0) {
          globalSelectedID.value[pageId] = [];
          globalSelectedID.notifyListeners();
          return false;
        } else {
          return true;
        }
      },
      child: Stack(
        children: [
          PageFramework(
            belowAppBarPaddingWhenCenteredTitleSmall: 0,
            subtitleAlignment: Alignment.bottomLeft,
            backgroundColor: pageBackgroundColor,
            listID: pageId,
            floatingActionButton: AnimateFABDelayed(
              fab: FAB(
                tooltip: "add-transaction".tr(),
                openPage: AddTransactionPage(
                  selectedObjective: widget.objective,
                  routesToPopAfterDelete: RoutesToPopAfterDelete.One,
                  selectedIncome: widget.objective.income,
                ),
                color: objectiveColorScheme.secondary,
                colorPlus: objectiveColorScheme.onSecondary,
              ),
            ),
            expandedHeight: 56,
            actions: [
              CustomPopupMenuButton(
                showButtons: enableDoubleColumn(context),
                keepOutFirst: true,
                forceKeepOutFirst: true,
                items: [
                  DropdownItemMenu(
                    id: "edit-goals",
                    label: "edit-goals".tr(),
                    icon: appStateSettings["outlinedIcons"]
                        ? Icons.edit_outlined
                        : Icons.edit_rounded,
                    action: () {
                      pushRoute(
                        context,
                        AddObjectivePage(
                          objective: widget.objective,
                          routesToPopAfterDelete: RoutesToPopAfterDelete.All,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
            title: widget.objective.name,
            appBarBackgroundColor: objectiveColorScheme.secondaryContainer,
            appBarBackgroundColorStart: objectiveColorScheme.secondaryContainer,
            textColor: getColor(context, "black"),
            dragDownToDismiss: true,
            slivers: [
              SliverToBoxAdapter(
                child: StreamBuilder<double?>(
                  stream: database.watchTotalTowardsObjective(
                    Provider.of<AllWallets>(context),
                    widget.objective.objectivePk,
                  ),
                  builder: (context, snapshot) {
                    double objectiveAmount = objectiveAmountToPrimaryCurrency(
                        Provider.of<AllWallets>(context, listen: true),
                        widget.objective);
                    double totalAmount = snapshot.data ?? 0;
                    if (widget.objective.income == false) {
                      totalAmount = totalAmount * -1;
                    }
                    double percentageTowardsGoal = objectiveAmount == 0
                        ? 0
                        : totalAmount / objectiveAmount;
                    if (percentageTowardsGoal >= 1 &&
                        hasPlayedConfetti == false) {
                      confettiController.play();
                      hasPlayedConfetti = true;
                    } else {
                      hasPlayedConfetti = false;
                    }
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 40, bottom: 5),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Container(
                                      constraints:
                                          BoxConstraints(maxWidth: 250),
                                      child: AspectRatio(
                                        aspectRatio: 1,
                                        child: AnimatedCircularProgress(
                                          percent: clampDouble(
                                              percentageTowardsGoal, 0, 1),
                                          backgroundColor: objectiveColorScheme
                                              .secondaryContainer,
                                          foregroundColor: dynamicPastel(
                                            context,
                                            objectiveColorScheme.primary,
                                            amountLight: 0.4,
                                            amountDark: 0.2,
                                          ),
                                          strokeWidth: 5,
                                          valueStrokeWidth: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  CategoryIcon(
                                    categoryPk: "-1",
                                    category: TransactionCategory(
                                      categoryPk: "-1",
                                      name: "",
                                      dateCreated: DateTime.now(),
                                      dateTimeModified: null,
                                      order: 0,
                                      income: false,
                                      iconName: widget.objective.iconName,
                                      colour: widget.objective.colour,
                                      emojiIconName:
                                          widget.objective.emojiIconName,
                                    ),
                                    size: 40,
                                    sizePadding: 30,
                                    borderRadius: 100,
                                    canEditByLongPress: false,
                                    margin: EdgeInsets.zero,
                                  ),
                                  SizedBox(height: 10),
                                  CountNumber(
                                    count: percentageTowardsGoal * 100,
                                    duration: Duration(milliseconds: 1000),
                                    initialCount: (0),
                                    textBuilder: (value) {
                                      return TextFont(
                                        text: convertToPercent(
                                          value,
                                          finalNumber:
                                              percentageTowardsGoal * 100,
                                          numberDecimals: 0,
                                        ),
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      );
                                    },
                                  ),
                                  Builder(builder: (context) {
                                    String amountSpentLabel =
                                        getObjectiveAmountSpentLabel(
                                            context: context,
                                            showTotalSpent: showTotalSpent,
                                            objectiveAmount: objectiveAmount,
                                            totalAmount: totalAmount);
                                    return AnimatedSizeSwitcher(
                                      child: IntrinsicWidth(
                                        key: ValueKey(showTotalSpent),
                                        child: Tappable(
                                          borderRadius: 15,
                                          onTap: () {
                                            _swapTotalSpentDisplay();
                                          },
                                          color: Colors.transparent,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                TextFont(
                                                  text: amountSpentLabel,
                                                  fontSize: 18,
                                                  textColor: totalAmount >=
                                                          objectiveAmount
                                                      ? getColor(context,
                                                          "incomeAmount")
                                                      : getColor(
                                                          context, "black"),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 1),
                                                  child: TextFont(
                                                    text: (isShowingAmountRemaining(
                                                                showTotalSpent:
                                                                    showTotalSpent,
                                                                objectiveAmount:
                                                                    objectiveAmount,
                                                                totalAmount:
                                                                    totalAmount)
                                                            ? " " +
                                                                "remaining".tr()
                                                            : "") +
                                                        " / " +
                                                        convertToMoney(
                                                            Provider.of<
                                                                    AllWallets>(
                                                                context),
                                                            objectiveAmount),
                                                    fontSize: 13,
                                                    textColor: getColor(
                                                            context, "black")
                                                        .withOpacity(0.4),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 20.0, left: 20, right: 20),
                          child: Column(
                            children: [
                              TextFont(
                                text: getWordedDateShortMore(
                                      widget.objective.dateCreated,
                                      includeYear:
                                          widget.objective.dateCreated.year !=
                                              DateTime.now().year,
                                    ) +
                                    (widget.objective.endDate != null
                                        ? " – " +
                                            getWordedDateShortMore(
                                              widget.objective.endDate!,
                                              includeYear: widget.objective
                                                      .endDate!.year !=
                                                  DateTime.now().year,
                                            )
                                        : ""),
                                maxLines: 3,
                                textAlign: TextAlign.center,
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                              ),
                              if (widget.objective.endDate != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: TextFont(
                                    text: getObjectiveStatus(
                                      context,
                                      widget.objective,
                                      totalAmount,
                                      percentageTowardsGoal,
                                      addSpendingSavingIndication: true,
                                    ),
                                    maxLines: 3,
                                    textAlign: TextAlign.center,
                                    fontSize: 16,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.only(
                  top: 5,
                  left: 20,
                  right: 20,
                  bottom: 30,
                ),
                sliver: SliverToBoxAdapter(
                  child: StreamBuilder<int?>(
                    stream: database
                        .getTotalCountOfTransactionsInObjective(
                            widget.objective.objectivePk)
                        .$1,
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        return TextFont(
                          textAlign: TextAlign.center,
                          text: snapshot.data.toString() +
                              " " +
                              (snapshot.data == 1
                                  ? "transaction".tr().toLowerCase()
                                  : "transactions".tr().toLowerCase()),
                          fontSize: 16,
                          maxLines: 3,
                        );
                      } else {
                        return TextFont(
                          textAlign: TextAlign.center,
                          text: "/ transactions",
                          fontSize: 16,
                          maxLines: 3,
                        );
                      }
                    },
                  ),
                ),
              ),
              TransactionEntries(
                null,
                null,
                income: null,
                listID: pageId,
                dateDividerColor: pageBackgroundColor,
                transactionBackgroundColor: pageBackgroundColor,
                categoryTintColor: objectiveColorScheme.primary,
                colorScheme: objectiveColorScheme,
                onlyShowTransactionsBelongingToObjectivePk:
                    widget.objective.objectivePk,
                showObjectivePercentage: false,
                noResultsMessage: "no-transactions-found".tr(),
              ),
              // Wipe all remaining pixels off - sometimes graphics artifacts are left behind
              SliverToBoxAdapter(
                child: Container(height: 1, color: pageBackgroundColor),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 45))
            ],
          ),
          SelectedTransactionsAppBar(
            pageID: pageId,
            colorScheme: objectiveColorScheme,
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              shouldLoop: true,
              confettiController: confettiController,
              gravity: 0.2,
              blastDirectionality: BlastDirectionality.explosive,
              maximumSize: Size(15, 15),
              minimumSize: Size(10, 10),
              numberOfParticles: 15,
            ),
          )
        ],
      ),
    );
  }
}
