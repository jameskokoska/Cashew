import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/pages/editObjectivesPage.dart';
import 'package:budget/pages/editWalletsPage.dart';
import 'package:budget/struct/currencyFunctions.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/listenableSelector.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/dropdownSelect.dart';
import 'package:budget/widgets/globalSnackbar.dart';
import 'package:budget/widgets/moreIcons.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/outlinedButtonStacked.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry/transactionEntry.dart';
import 'package:budget/widgets/transactionEntry/transactionLabel.dart';
import 'package:budget/widgets/util/showDatePicker.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budget/widgets/countNumber.dart';
import 'package:budget/widgets/framework/popupFramework.dart';

class SelectedTransactionsAppBar extends StatelessWidget {
  const SelectedTransactionsAppBar(
      {Key? key, required this.pageID, this.enableSettleAllButton = false})
      : super(key: key);

  Future shareSelectedTransactions(
      {required BuildContext context,
      required List<String> selectedTransactionPks,
      required double totalAmount,
      bool shareInsteadOfCopy = false}) async {
    AllWallets allWallets = Provider.of<AllWallets>(context, listen: false);
    List<Transaction> transactions =
        await database.getTransactionsSortedFromPk(selectedTransactionPks);
    List<String> transactionOutput = [];
    for (Transaction transaction in transactions) {
      String name = await getTransactionLabel(transaction);
      String amount = convertToMoney(
          allWallets,
          amountRatioToPrimaryCurrency(allWallets,
                  allWallets.indexedByPk[transaction.walletFk]?.currency) *
              (transaction.amount.abs() * (transaction.income ? 1 : -1)));
      transactionOutput.add(name + "  •  " + amount);
    }
    String outString = "";
    outString += "**" +
        "total".tr() +
        "**  •  " +
        convertToMoney(allWallets, totalAmount);
    outString += "\n" + transactionOutput.join("\n");

    if (shareInsteadOfCopy == false || kIsWeb) {
      copyToClipboard(
        outString,
        customSnackbarDescription: "transaction-details".tr(),
      );
    } else {
      shareToClipboard(outString, context: context);
    }
  }

  final String pageID;
  final bool enableSettleAllButton;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: globalSelectedID
          .select((controller) => (controller.value[pageID] ?? []).length),
      builder: (context, _, __) {
        List<String> listOfIDs = globalSelectedID.value[pageID] ?? [];
        bool animateIn =
            globalSelectedID.value[pageID] != null && listOfIDs.length > 0;
        return AnimatedPositionedDirectional(
          start: 0,
          end: 0,
          duration: Duration(milliseconds: 500),
          top: animateIn ? 0 : -(MediaQuery.paddingOf(context).top + 80),
          curve: Curves.easeInOutCubic,
          child: Align(
            alignment: AlignmentDirectional.topCenter,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsetsDirectional.only(
                      top: MediaQuery.paddingOf(context).top + 2),
                  decoration: BoxDecoration(
                    // borderRadius: BorderRadiusDirectional.only(
                    //   bottomstart: Radius.circular(
                    //       getIsFullScreen(context) ? 20 : 10),
                    //   bottomend: Radius.circular(
                    //       getIsFullScreen(context) ? 20 : 10),
                    // ),
                    boxShadow: boxShadowCheck(boxShadowSharp(context)),
                    color: Theme.of(context).colorScheme.secondaryContainer,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        padding: EdgeInsetsDirectional.all(15),
                        color: Theme.of(context).colorScheme.secondary,
                        icon: Icon(
                          getPlatform() == PlatformOS.isIOS
                              ? appStateSettings["outlinedIcons"]
                                  ? Icons.chevron_left_outlined
                                  : Icons.chevron_left_rounded
                              : appStateSettings["outlinedIcons"]
                                  ? Icons.arrow_back_outlined
                                  : Icons.arrow_back_rounded,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        onPressed: () {
                          globalSelectedID.value[pageID] = [];
                          globalSelectedID.notifyListeners();
                        },
                      ),
                      Expanded(
                        child: StreamBuilder<double?>(
                          stream: database.watchTotalSpentGivenList(
                            Provider.of<AllWallets>(context),
                            listOfIDs,
                          ),
                          builder: (context, snapshot) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Builder(
                                    builder: (context) {
                                      return Transform.translate(
                                        offset: Offset(-10, 0)
                                            .withDirectionality(context),
                                        child: Tappable(
                                          color: Colors.transparent,
                                          borderRadius: 15,
                                          onTap: () =>
                                              shareSelectedTransactions(
                                            context: context,
                                            selectedTransactionPks: listOfIDs,
                                            totalAmount: snapshot.data ?? 0,
                                            shareInsteadOfCopy: true,
                                          ),
                                          onLongPress: () =>
                                              shareSelectedTransactions(
                                            context: context,
                                            selectedTransactionPks: listOfIDs,
                                            totalAmount: snapshot.data ?? 0,
                                            shareInsteadOfCopy: false,
                                          ),
                                          child: Padding(
                                            padding:
                                                const EdgeInsetsDirectional.all(
                                                    10),
                                            child: TextFont(
                                              text:
                                                  listOfIDs.length.toString() +
                                                      " " +
                                                      "selected".tr(),
                                              fontSize: 17.5,
                                              textAlign: TextAlign.start,
                                              maxLines: 1,
                                              overflow: TextOverflow.fade,
                                              softWrap: false,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                CountNumber(
                                  count: snapshot.hasData ? snapshot.data! : 0,
                                  duration: Duration(milliseconds: 250),
                                  initialCount: (0),
                                  textBuilder: (number) {
                                    return Transform.translate(
                                      offset: Offset(10, 0)
                                          .withDirectionality(context),
                                      child: Tappable(
                                        color: Colors.transparent,
                                        borderRadius: 15,
                                        onLongPress: () {
                                          copyToClipboard(
                                            convertToMoney(
                                              Provider.of<AllWallets>(context,
                                                  listen: false),
                                              number,
                                              finalNumber: snapshot.hasData
                                                  ? snapshot.data!
                                                  : 0,
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding:
                                              const EdgeInsetsDirectional.all(
                                                  10),
                                          child: TextFont(
                                            text: convertToMoney(
                                                Provider.of<AllWallets>(
                                                    context),
                                                number,
                                                finalNumber: snapshot.hasData
                                                    ? snapshot.data!
                                                    : 0),
                                            fontSize: 17.5,
                                            textAlign: TextAlign.start,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      SelectedTransactionsAppBarMenu(
                        pageID: pageID,
                        selectedTransactionPks: listOfIDs,
                        enableSettleAllButton: enableSettleAllButton,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SelectedTransactionsAppBarMenu extends StatelessWidget {
  const SelectedTransactionsAppBarMenu(
      {Key? key,
      required this.pageID,
      required this.enableSettleAllButton,
      required this.selectedTransactionPks})
      : super(key: key);

  final String pageID;
  final bool enableSettleAllButton;
  final List<String> selectedTransactionPks;

  Future duplicateTransactions(BuildContext context,
      {bool duplicateForNow = false}) async {
    bool showDetailedSnackbarMessage = selectedTransactionPks.length <= 1;
    if (selectedTransactionPks.length <= 1) {
      await duplicateTransaction(
        context,
        selectedTransactionPks[0],
        showDuplicatedMessage: showDetailedSnackbarMessage,
        useCurrentDate: duplicateForNow,
      );
    } else {
      duplicateMultipleTransactions(
        context,
        selectedTransactionPks,
        useCurrentDate: duplicateForNow,
      );
    }
    if (showDetailedSnackbarMessage == false) {
      if (duplicateForNow) {
        openSnackbar(
          SnackbarMessage(
            icon: appStateSettings["outlinedIcons"]
                ? Icons.file_copy_outlined
                : Icons.file_copy_rounded,
            title: "created-copy-for-current-time".tr(),
            description: selectedTransactionPks.length.toString() +
                " " +
                "transactions".tr().toLowerCase(),
          ),
        );
      } else {
        openSnackbar(
          SnackbarMessage(
            icon: appStateSettings["outlinedIcons"]
                ? Icons.file_copy_outlined
                : Icons.file_copy_rounded,
            title: "created-copy".tr(),
            description: selectedTransactionPks.length.toString() +
                " " +
                "transactions".tr().toLowerCase(),
          ),
        );
      }
    }
    globalSelectedID.value[pageID] = [];
    globalSelectedID.notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Objective>>(
      stream: database.watchAllObjectives(objectiveType: ObjectiveType.loan),
      builder: (context, loansSnapshot) {
        return StreamBuilder<List<Objective>>(
          stream:
              database.watchAllObjectives(objectiveType: ObjectiveType.goal),
          builder: (context, goalsSnapshot) {
            return StreamBuilder<List<Budget>>(
              stream: database.watchAllAddableBudgets(),
              builder: (context, addableBudgetsSnapshot) {
                bool enableObjectiveLoansSection =
                    (loansSnapshot.data ?? []).length > 0;
                bool enableObjectiveSelection =
                    (goalsSnapshot.data ?? []).length > 0;
                bool enableAddableBudgetSelection =
                    (addableBudgetsSnapshot.data ?? []).length > 0;
                bool enableWalletSelection =
                    Provider.of<AllWallets>(context, listen: true)
                            .indexedByPk
                            .length >
                        1;
                bool enableDuplicate = selectedTransactionPks.length <= 10;

                return CustomPopupMenuButton(
                  showButtons: enableDoubleColumn(context),
                  keepOutFirst: true,
                  // There is no header taking up space, we can always keep out the delete button
                  forceKeepOutFirst: true,
                  items: [
                    DropdownItemMenu(
                      id: "delete-transactions",
                      label: "delete-transactions".tr(),
                      icon: Icons.delete,
                      action: () async {
                        dynamic result = await deleteTransactionsPopup(
                          context,
                          transactionPks: selectedTransactionPks,
                          routesToPopAfterDelete: RoutesToPopAfterDelete.None,
                        );
                        if (result == DeletePopupAction.Delete) {
                          globalSelectedID.value[pageID] = [];
                          globalSelectedID.notifyListeners();
                        }
                      },
                    ),
                    if (enableSettleAllButton)
                      DropdownItemMenu(
                        id: "settle-all",
                        label: "settle-and-collect-all".tr(),
                        icon: appStateSettings["outlinedIcons"]
                            ? Icons.check_circle_outline
                            : Icons.check_circle_rounded,
                        action: () async {
                          for (int i = 0;
                              i < selectedTransactionPks.length;
                              i++) {
                            await settleTransactions(
                              selectedTransactionPks[i],
                            );
                          }
                          openSnackbar(
                            SnackbarMessage(
                              icon: appStateSettings["outlinedIcons"]
                                  ? Icons.check_circle_outline
                                  : Icons.check_circle_rounded,
                              title: "settled-and-collected".tr(),
                              description:
                                  selectedTransactionPks.length.toString() +
                                      " " +
                                      "transactions".tr().toLowerCase(),
                            ),
                          );
                          globalSelectedID.value[pageID] = [];
                          globalSelectedID.notifyListeners();
                        },
                      ),
                    if (globalTransactionsListedOnPageID[pageID] != null)
                      DropdownItemMenu(
                        id: "select-all",
                        label: "select-all".tr(),
                        icon: appStateSettings["outlinedIcons"]
                            ? Icons.select_all_outlined
                            : Icons.select_all_rounded,
                        action: () async {
                          if ((globalTransactionsListedOnPageID[pageID] ?? [])
                                  .length >=
                              maxSelectableTransactionsListedOnPage) {
                            openSnackbar(
                              SnackbarMessage(
                                icon: appStateSettings["outlinedIcons"]
                                    ? Icons.rule_outlined
                                    : Icons.rule_rounded,
                                title: "maximum-transactions".tr(),
                                description: "only-the-first".tr() +
                                    " " +
                                    maxSelectableTransactionsListedOnPage
                                        .toString() +
                                    " " +
                                    "selected".tr().toLowerCase(),
                              ),
                            );
                          }
                          globalSelectedID.value[pageID] =
                              globalTransactionsListedOnPageID[pageID] ?? [];
                          globalSelectedID.notifyListeners();
                        },
                      ),
                    if (enableDuplicate)
                      DropdownItemMenu(
                        id: "create-copy",
                        label: "duplicate".tr(),
                        icon: appStateSettings["outlinedIcons"]
                            ? Icons.file_copy_outlined
                            : Icons.file_copy_rounded,
                        iconScale: 0.97,
                        actionOnLongPress: () async => duplicateTransactions(
                          context,
                          duplicateForNow: true,
                        ),
                        action: () async => duplicateTransactions(
                          context,
                          duplicateForNow: false,
                        ),
                      ),
                    DropdownItemMenu(
                      id: "edit",
                      label: "edit".tr(),
                      icon: appStateSettings["outlinedIcons"]
                          ? Icons.edit_outlined
                          : Icons.edit_rounded,
                      action: () async {
                        List<EditSelectedTransactionsContainer>
                            editSelectedTransactionsContainers = [
                          EditSelectedTransactionsContainer(
                            iconData: appStateSettings["outlinedIcons"]
                                ? Icons.calendar_month_outlined
                                : Icons.calendar_month_rounded,
                            text: "change-date".tr(),
                            onTap: () async {
                              List<Transaction> transactions =
                                  await database.getTransactionsFromPk(
                                      selectedTransactionPks);
                              if (transactions.length <= 0) return;
                              DateTime? selectedDate =
                                  await selectDateAndTimeSequence(
                                      context, transactions.first.dateCreated);
                              if (selectedDate == null) return;
                              await database
                                  .updateDateTimeCreatedOfTransactions(
                                      transactions, selectedDate);
                              openSnackbar(
                                SnackbarMessage(
                                  icon: appStateSettings["outlinedIcons"]
                                      ? Icons.calendar_month_outlined
                                      : Icons.calendar_month_rounded,
                                  title: "changed-date".tr(),
                                  description: "for".tr().capitalizeFirst +
                                      " " +
                                      transactions.length.toString() +
                                      " " +
                                      (transactions.length == 1
                                          ? "transaction".tr().toLowerCase()
                                          : "transactions".tr().toLowerCase()),
                                ),
                              );
                              globalSelectedID.value[pageID] = [];
                              globalSelectedID.notifyListeners();
                            },
                          ),
                          EditSelectedTransactionsContainer(
                            iconData: appStateSettings["outlinedIcons"]
                                ? Icons.title_outlined
                                : Icons.title_rounded,
                            text: "change-title".tr(),
                            onTap: () async {
                              String setText = "";

                              dynamic result = await openBottomSheet(
                                context,
                                popupWithKeyboard: true,
                                PopupFramework(
                                  title: "set-title".tr(),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TitleInput(
                                              resizePopupWhenChanged: true,
                                              padding:
                                                  EdgeInsetsDirectional.zero,
                                              setSelectedCategory: (_) {},
                                              setSelectedSubCategory: (_) {},
                                              alsoSearchCategories: false,
                                              setSelectedTitle: (title) {
                                                setText = title;
                                              },
                                              showCategoryIconForRecommendedTitles:
                                                  false,
                                              unfocusWhenRecommendedTapped:
                                                  false,
                                              onSubmitted: (_) {
                                                popRoute(context, true);
                                              },
                                              autoFocus: true,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Button(
                                        label: "set-title".tr(),
                                        onTap: () {
                                          popRoute(context, true);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );

                              if (result != true || setText.trim() == "")
                                return;

                              List<Transaction> transactions =
                                  await database.getTransactionsFromPk(
                                      selectedTransactionPks);
                              await database.changeTransactionsTitle(
                                  transactions, setText);

                              openSnackbar(
                                SnackbarMessage(
                                  icon: appStateSettings["outlinedIcons"]
                                      ? Icons.title_outlined
                                      : Icons.title_rounded,
                                  title: "changed-title".tr(),
                                  description: "for".tr().capitalizeFirst +
                                      " " +
                                      transactions.length.toString() +
                                      " " +
                                      (transactions.length == 1
                                          ? "transaction".tr().toLowerCase()
                                          : "transactions".tr().toLowerCase()),
                                ),
                              );

                              globalSelectedID.value[pageID] = [];
                              globalSelectedID.notifyListeners();
                            },
                          ),
                          EditSelectedTransactionsContainer(
                            iconData: appStateSettings["outlinedIcons"]
                                ? Icons.category_outlined
                                : Icons.category_rounded,
                            text: "change-category".tr(),
                            onTap: () async {
                              MainAndSubcategory mainAndSubcategory =
                                  await selectCategorySequence(
                                context,
                                selectedCategory: null,
                                setSelectedCategory: (_) {},
                                selectedSubCategory: null,
                                setSelectedSubCategory: (_) {},
                                selectedIncomeInitial: null,
                              );
                              TransactionCategory? category =
                                  mainAndSubcategory.main;
                              print(mainAndSubcategory.sub);
                              if (category == null) return;
                              TransactionCategory? subCategory =
                                  mainAndSubcategory.sub;
                              List<Transaction> transactions =
                                  await database.getTransactionsFromPk(
                                      selectedTransactionPks);
                              await database.moveTransactionsToCategory(
                                transactions,
                                category.categoryPk,
                                subCategory?.categoryPk,
                                mainAndSubcategory
                                        .ignoredSubcategorySelection ==
                                    false,
                              );
                              openSnackbar(
                                SnackbarMessage(
                                  icon: appStateSettings["outlinedIcons"]
                                      ? Icons.category_outlined
                                      : Icons.category_rounded,
                                  title: "changed-category".tr(),
                                  description: "for".tr().capitalizeFirst +
                                      " " +
                                      transactions.length.toString() +
                                      " " +
                                      (transactions.length == 1
                                          ? "transaction".tr().toLowerCase()
                                          : "transactions".tr().toLowerCase()),
                                ),
                              );
                              globalSelectedID.value[pageID] = [];
                              globalSelectedID.notifyListeners();
                            },
                          ),
                          if (enableWalletSelection)
                            EditSelectedTransactionsContainer(
                              iconData: appStateSettings["outlinedIcons"]
                                  ? Icons.account_balance_wallet_outlined
                                  : Icons.account_balance_wallet_rounded,
                              text: "change-account".tr(),
                              onTap: () async {
                                TransactionWallet? wallet =
                                    await selectWalletPopup(
                                  context,
                                  allowEditWallet: true,
                                );
                                if (wallet == null) return;
                                List<Transaction> transactions =
                                    await database.getTransactionsFromPk(
                                        selectedTransactionPks);
                                await database.moveWalletTransactions(
                                  Provider.of<AllWallets>(context,
                                      listen: false),
                                  null,
                                  wallet.walletPk,
                                  transactionsToMove: transactions,
                                );
                                openSnackbar(
                                  SnackbarMessage(
                                    icon: appStateSettings["outlinedIcons"]
                                        ? Icons.account_balance_wallet_outlined
                                        : Icons.account_balance_wallet_rounded,
                                    title: "changed-account".tr(),
                                    description: "for".tr().capitalizeFirst +
                                        " " +
                                        transactions.length.toString() +
                                        " " +
                                        (transactions.length == 1
                                            ? "transaction".tr().toLowerCase()
                                            : "transactions"
                                                .tr()
                                                .toLowerCase()),
                                  ),
                                );
                                globalSelectedID.value[pageID] = [];
                                globalSelectedID.notifyListeners();
                              },
                            ),
                          if (enableAddableBudgetSelection)
                            EditSelectedTransactionsContainer(
                              iconData: appStateSettings["outlinedIcons"]
                                  ? Icons.donut_small_outlined
                                  : MoreIcons.chart_pie,
                              iconScale:
                                  appStateSettings["outlinedIcons"] ? 1 : 0.85,
                              text: "add-to-budget".tr(),
                              onTap: () async {
                                dynamic budget =
                                    await selectAddableBudgetPopup(context);
                                print(budget);
                                if (budget == null) return;

                                String? budgetPkToMoveTo;
                                if (budget == "none") {
                                  budgetPkToMoveTo = null;
                                } else {
                                  budgetPkToMoveTo = budget.budgetPk;
                                }
                                List<Transaction> transactions =
                                    await database.getTransactionsFromPk(
                                        selectedTransactionPks);
                                int numberMoved =
                                    await database.moveTransactionsToBudget(
                                        transactions, budgetPkToMoveTo);

                                // Some transactions weren't moved to a budget
                                // if (transactions.length != numberMoved) {
                                //   showIncomeCannotBeAddedToBudgetWarning();
                                // }

                                openSnackbar(
                                  SnackbarMessage(
                                    icon: appStateSettings["outlinedIcons"]
                                        ? Icons.donut_small_outlined
                                        : MoreIcons.chart_pie,
                                    title: budget == "none"
                                        ? "removed-from-budget".tr()
                                        : "added-to-budget".tr(),
                                    description: "for".tr().capitalizeFirst +
                                        " " +
                                        numberMoved.toString() +
                                        " " +
                                        (numberMoved == 1
                                            ? "transaction".tr().toLowerCase()
                                            : "transactions"
                                                .tr()
                                                .toLowerCase()),
                                  ),
                                );

                                globalSelectedID.value[pageID] = [];
                                globalSelectedID.notifyListeners();
                              },
                            ),
                          if (enableObjectiveSelection)
                            EditSelectedTransactionsContainer(
                              iconData: appStateSettings["outlinedIcons"]
                                  ? Icons.savings_outlined
                                  : Icons.savings_rounded,
                              iconScale: 0.85,
                              text: "add-to-goal".tr(),
                              onTap: () async {
                                dynamic objective =
                                    await selectObjectivePopup(context);
                                if (objective == null) return;

                                String? objectivePkToMoveTo;
                                if (objective == "none") {
                                  objectivePkToMoveTo = null;
                                } else {
                                  objectivePkToMoveTo = objective.objectivePk;
                                }
                                List<Transaction> transactions =
                                    await database.getTransactionsFromPk(
                                        selectedTransactionPks);
                                int numberMoved =
                                    await database.moveTransactionsToObjective(
                                  transactions,
                                  objectivePkToMoveTo,
                                  ObjectiveType.goal,
                                );

                                openSnackbar(
                                  SnackbarMessage(
                                    icon: appStateSettings["outlinedIcons"]
                                        ? Icons.savings_outlined
                                        : Icons.savings_rounded,
                                    title: objective == "none"
                                        ? "removed-from-goal".tr()
                                        : "added-to-goal-action".tr(),
                                    description: "for".tr().capitalizeFirst +
                                        " " +
                                        numberMoved.toString() +
                                        " " +
                                        (numberMoved == 1
                                            ? "transaction".tr().toLowerCase()
                                            : "transactions"
                                                .tr()
                                                .toLowerCase()),
                                  ),
                                );

                                globalSelectedID.value[pageID] = [];
                                globalSelectedID.notifyListeners();
                              },
                            ),
                          if (enableObjectiveLoansSection)
                            EditSelectedTransactionsContainer(
                              iconData: getTransactionTypeIcon(
                                  TransactionSpecialType.credit),
                              text: "add-to-loan".tr(),
                              onTap: () async {
                                dynamic objective = await selectObjectivePopup(
                                    context,
                                    objectiveType: ObjectiveType.loan);
                                if (objective == null) return;

                                String? objectivePkToMoveTo;
                                if (objective == "none") {
                                  objectivePkToMoveTo = null;
                                } else {
                                  objectivePkToMoveTo = objective.objectivePk;
                                }
                                List<Transaction> transactions =
                                    await database.getTransactionsFromPk(
                                        selectedTransactionPks);
                                int numberMoved =
                                    await database.moveTransactionsToObjective(
                                  transactions,
                                  objectivePkToMoveTo,
                                  ObjectiveType.loan,
                                );

                                openSnackbar(
                                  SnackbarMessage(
                                    icon: getTransactionTypeIcon(
                                        TransactionSpecialType.credit),
                                    title: objective == "none"
                                        ? "removed-from-loan".tr()
                                        : "added-to-loan-action".tr(),
                                    description: "for".tr().capitalizeFirst +
                                        " " +
                                        numberMoved.toString() +
                                        " " +
                                        (numberMoved == 1
                                            ? "transaction".tr().toLowerCase()
                                            : "transactions"
                                                .tr()
                                                .toLowerCase()),
                                  ),
                                );

                                globalSelectedID.value[pageID] = [];
                                globalSelectedID.notifyListeners();
                              },
                            ),
                        ];
                        openBottomSheet(
                          context,
                          EditSelectedTransactionsPopup(
                            editSelectedTransactionsContainers:
                                editSelectedTransactionsContainers,
                            numTransactions: selectedTransactionPks.length,
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

class EditSelectedTransactionsPopup extends StatelessWidget {
  const EditSelectedTransactionsPopup(
      {required this.editSelectedTransactionsContainers,
      required this.numTransactions,
      super.key});
  final List<EditSelectedTransactionsContainer>
      editSelectedTransactionsContainers;
  final int numTransactions;
  @override
  Widget build(BuildContext context) {
    return PopupFramework(
      title: "edit-transactions".tr(),
      subtitle: numTransactions.toString() +
          " " +
          (numTransactions == 1
              ? "transaction".tr().toLowerCase()
              : "transactions".tr().toLowerCase()) +
          " " +
          "selected".tr(),
      child: Column(
        children: editSelectedTransactionsContainers,
      ),
    );
  }
}

class EditSelectedTransactionsContainer extends StatelessWidget {
  const EditSelectedTransactionsContainer({
    required this.iconData,
    required this.text,
    this.iconScale = 1,
    required this.onTap,
    super.key,
  });

  final IconData iconData;
  final String text;
  final double iconScale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        bottom: 5,
        top: 5,
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButtonStacked(
              filled: false,
              alignStart: true,
              alignBeside: true,
              padding:
                  EdgeInsetsDirectional.symmetric(horizontal: 20, vertical: 15),
              text: text,
              iconData: iconData,
              iconScale: iconScale,
              onTap: () {
                popRoute(context);
                onTap();
              },
            ),
          ),
        ],
      ),
    );
  }
}

Future settleTransactions(String transactionPk) async {
  Transaction transaction = await database.getTransactionFromPk(transactionPk);
  if (transaction.type == TransactionSpecialType.credit ||
      transaction.type == TransactionSpecialType.debt) {
    Transaction transactionNew = transaction.copyWith(
      //we don't want it to count towards the total - net is zero now
      paid: false,
    );
    await database.createOrUpdateTransaction(transactionNew);
  }
}

Future duplicateTransaction(
  BuildContext context,
  String transactionPk, {
  bool showDuplicatedMessage = true,
  bool useCurrentDate = false,
  double? customAmount,
}) async {
  Transaction transaction = await database.getTransactionFromPk(transactionPk);
  if (useCurrentDate) {
    transaction = transaction.copyWith(dateCreated: DateTime.now());
  }
  if (customAmount != null) {
    transaction = transaction.copyWith(amount: customAmount);
  }
  // Add one second so when transactions sorted, they don't change positions when updated
  // Since the transaction list is sorted by date created
  transaction = transaction.copyWith(
    dateCreated: transaction.dateCreated.add(Duration(seconds: 1)),
    pairedTransactionFk: Value(null),
  );
  int? rowId = await database.createOrUpdateTransaction(
    transaction,
    insert: true,
  );
  Transaction? transactionJustAdded = null;
  if (rowId != null) {
    transactionJustAdded = await database.getTransactionFromRowId(rowId);
    flashTransaction(transactionJustAdded.transactionPk);
  }
  String transactionName = transaction.name;
  if (transactionName.trim() == "") {
    transactionName =
        (await database.getCategoryInstance(transaction.categoryFk)).name;
  }
  if (showDuplicatedMessage) {
    if (useCurrentDate) {
      openSnackbar(
        SnackbarMessage(
          icon: appStateSettings["outlinedIcons"]
              ? Icons.file_copy_outlined
              : Icons.file_copy_rounded,
          title: "created-copy-for-current-time".tr(),
          description: "copied".tr() + " " + transactionName,
          onTap: () {
            if (transactionJustAdded != null)
              pushRoute(
                null,
                AddTransactionPage(
                  routesToPopAfterDelete: RoutesToPopAfterDelete.One,
                  transaction: transactionJustAdded,
                ),
              );
          },
        ),
      );
    } else {
      openSnackbar(
        SnackbarMessage(
          icon: appStateSettings["outlinedIcons"]
              ? Icons.file_copy_outlined
              : Icons.file_copy_rounded,
          title: "created-copy".tr(),
          description: "copied".tr() + " " + transactionName,
          onTap: () {
            if (transactionJustAdded != null)
              pushRoute(
                null,
                AddTransactionPage(
                  routesToPopAfterDelete: RoutesToPopAfterDelete.One,
                  transaction: transactionJustAdded,
                ),
              );
          },
        ),
      );
    }
  }
}

Future duplicateMultipleTransactions(
  BuildContext context,
  List<String> transactionPks, {
  bool useCurrentDate = false,
  double? customAmount,
}) async {
  List<Transaction> transactions =
      await database.getTransactionsFromPk(transactionPks);

  if (useCurrentDate) {
    transactions = transactions
        .map((transaction) => transaction.copyWith(dateCreated: DateTime.now()))
        .toList();
  }
  if (customAmount != null) {
    transactions = transactions
        .map((transaction) => transaction.copyWith(amount: customAmount))
        .toList();
  }

  // Add one second so when transactions sorted, they don't change positions when updated
  // Since the transaction list is sorted by date created
  transactions = transactions
      .map((transaction) => transaction.copyWith(
            dateCreated: transaction.dateCreated.add(Duration(seconds: 1)),
            dateTimeModified: Value(DateTime.now()),
            transactionPk: null,
          ))
      .toList();

  // Handle duplicating of paired transfer entries
  // Find matching pairs and pre-generate a key for the pair
  Map<String, String> relatedMatchingPairs = findMatchingPairsPks(transactions);
  Map<String, String> generatedMatchingPairKeys =
      relatedMatchingPairs.map((key, value) => MapEntry(key, uuid.v4()));

  List<TransactionsCompanion> transactionsCompanion =
      transactions.map((transaction) {
    // Handle duplicating of paired transfer entries
    if (transaction.categoryFk == "0" &&
        transaction.pairedTransactionFk != null &&
        relatedMatchingPairs[transaction.pairedTransactionFk] != null) {
      // print("usingPaired: " +
      //     (generatedMatchingPairKeys[transaction.pairedTransactionFk] ?? ""));
      return transaction.toCompanion(true).copyWith(
            transactionPk: Value.absent(),
            pairedTransactionFk: Value(
                generatedMatchingPairKeys[transaction.pairedTransactionFk]),
          );
    } else if (transaction.categoryFk == "0" &&
        transaction.pairedTransactionFk == null &&
        relatedMatchingPairs[transaction.transactionPk] != null) {
      // print("usingNew: " +
      //     (generatedMatchingPairKeys[transaction.transactionPk] ?? ""));
      return transaction.toCompanion(true).copyWith(
            transactionPk: Value(
                generatedMatchingPairKeys[transaction.transactionPk] ?? ""),
            pairedTransactionFk: Value.absent(),
          );
    }

    return transaction.toCompanion(true).copyWith(
          transactionPk: Value.absent(),
        );
  }).toList();

  await database.createBatchTransactionsOnly(transactionsCompanion);
}

// Create a map of the key pairs for paired transfer transactions
Map<String, String> findMatchingPairsPks(List<Transaction> transactions) {
  Map<String, String> pairs = {};

  final Map<String, Transaction> transactionMap = {
    for (Transaction transaction in transactions)
      transaction.transactionPk: transaction
  };

  for (Transaction transaction in transactions) {
    if (transaction.categoryFk == "0" &&
        transaction.pairedTransactionFk != null &&
        transactionMap.containsKey(transaction.pairedTransactionFk!)) {
      Transaction pairedTransaction =
          transactionMap[transaction.pairedTransactionFk!]!;

      pairs[transaction.transactionPk] = pairedTransaction.transactionPk;
      pairs[pairedTransaction.transactionPk] = transaction.transactionPk;
    }
  }

  return pairs;
}
