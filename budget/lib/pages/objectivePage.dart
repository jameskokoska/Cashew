import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addObjectivePage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/editBudgetLimitsPage.dart';
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
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntries.dart';
import 'package:budget/widgets/transactionEntry/transactionEntry.dart';
import 'package:easy_localization/easy_localization.dart';
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
              fab: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.viewPaddingOf(context).bottom),
                child: FAB(
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
                    double totalAmount = snapshot.data ?? 0;
                    if (widget.objective.income == false) {
                      totalAmount = totalAmount * -1;
                    }
                    double percentageTowardsGoal = widget.objective.amount == 0
                        ? 0
                        : totalAmount / widget.objective.amount;
                    if (percentageTowardsGoal >= 1 &&
                        hasPlayedConfetti == false) {
                      confettiController.play();
                      hasPlayedConfetti = true;
                    } else {
                      hasPlayedConfetti = false;
                    }
                    return Padding(
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
                                  constraints: BoxConstraints(maxWidth: 250),
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: AnimatedCircularProgress(
                                      percent: percentageTowardsGoal < 0
                                          ? 0
                                          : percentageTowardsGoal,
                                      backgroundColor: objectiveColorScheme
                                          .secondaryContainer,
                                      foregroundColor: dynamicPastel(
                                        context,
                                        objectiveColorScheme.primary,
                                        amountLight: 0.4,
                                        amountDark: 0.2,
                                      ),
                                      overageColor: Colors.transparent,
                                      overageShadowColor: Colors.transparent,
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
                                  emojiIconName: widget.objective.emojiIconName,
                                ),
                                size: 40,
                                sizePadding: 30,
                                borderRadius: 100,
                                canEditByLongPress: false,
                                margin: EdgeInsets.zero,
                              ),
                              SizedBox(height: 20),
                              CountNumber(
                                count: percentageTowardsGoal * 100,
                                duration: Duration(milliseconds: 1000),
                                initialCount: (0),
                                textBuilder: (value) {
                                  return TextFont(
                                    text: convertToPercent(
                                      value,
                                      finalNumber: percentageTowardsGoal * 100,
                                      numberDecimals: 0,
                                    ),
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  );
                                },
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  TextFont(
                                    text: convertToMoney(
                                        Provider.of<AllWallets>(context),
                                        totalAmount),
                                    fontSize: 18,
                                    textColor:
                                        totalAmount >= widget.objective.amount
                                            ? getColor(context, "incomeAmount")
                                            : getColor(context, "black"),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 1),
                                    child: TextFont(
                                      text: " / " +
                                          convertToMoney(
                                              Provider.of<AllWallets>(context),
                                              widget.objective.amount),
                                      fontSize: 13,
                                      textColor: getColor(context, "black")
                                          .withOpacity(0.3),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(
                  top: 10,
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
                          fontSize: 18,
                        );
                      } else {
                        return TextFont(
                          textAlign: TextAlign.center,
                          text: "/ transactions",
                          fontSize: 18,
                        );
                      }
                    },
                  ),
                ),
              ),
              TransactionEntries(
                  m: TransactionEntriesMetaData(
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
              )),
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
