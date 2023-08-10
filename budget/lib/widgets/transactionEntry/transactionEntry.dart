import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/categoryIcon.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry/transactionEntryTypeButton.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:budget/colors.dart';
import 'package:budget/widgets/openBottomSheet.dart';

import 'swipeToSelectTransactions.dart';
import 'transactionEntryAmount.dart';
import 'transactionEntryNote.dart';
import 'associatedBudgetLabel.dart';

ValueNotifier<Map<String, List<int>>> globalSelectedID =
    ValueNotifier<Map<String, List<int>>>({});

class TransactionEntryHitBox extends RenderProxyBox {
  int? transactionKey;
  TransactionEntryHitBox(this.transactionKey);
}

class TransactionEntryBox extends SingleChildRenderObjectWidget {
  final int transactionKey;

  TransactionEntryBox(
      {required Widget child, required this.transactionKey, Key? key})
      : super(child: child, key: key);

  @override
  TransactionEntryHitBox createRenderObject(BuildContext context) {
    return TransactionEntryHitBox(transactionKey);
  }

  @override
  void updateRenderObject(
      BuildContext context, TransactionEntryHitBox renderObject) {
    renderObject..transactionKey = transactionKey;
  }
}

class TransactionEntry extends StatelessWidget {
  TransactionEntry({
    Key? key,
    required this.openPage,
    required this.transaction,
    this.listID, //needs to be unique based on the page to avoid conflicting globalSelectedIDs
    this.category,
    this.onSelected,
    this.containerColor,
    this.useHorizontalPaddingConstrained = true,
    this.categoryTintColor,
    this.transactionBefore,
    this.transactionAfter,
  }) : super(key: key);

  final Widget openPage;
  final Transaction transaction;
  final String? listID;
  final TransactionCategory? category;
  final Function(Transaction transaction, bool selected)? onSelected;
  final Color? containerColor;
  final bool useHorizontalPaddingConstrained;
  final Color? categoryTintColor;
  final Transaction? transactionBefore;
  final Transaction? transactionAfter;

  final double fabSize = 50;

  void selectTransaction(
      Transaction transaction, bool selected, bool isSwiping) {
    if (!selected) {
      globalSelectedID.value[listID ?? "0"]!.add(transaction.transactionPk);
      if (isSwiping) selectingTransactionsActive = 1;
    } else {
      globalSelectedID.value[listID ?? "0"]!.remove(transaction.transactionPk);
      if (isSwiping) selectingTransactionsActive = -1;
    }
    globalSelectedID.notifyListeners();

    if (onSelected != null) onSelected!(transaction, selected);
  }

  @override
  Widget build(BuildContext context) {
    bool enableSelectionCheckmark = getPlatform() == PlatformOS.isIOS ||
        (kIsWeb && getIsFullScreen(context));
    if (globalSelectedID.value[listID ?? "0"] == null) {
      globalSelectedID.value[listID ?? "0"] = [];
    }

    Color textColor = (transaction.type == TransactionSpecialType.credit ||
                transaction.type == TransactionSpecialType.debt) &&
            transaction.paid
        ? transaction.type == TransactionSpecialType.credit
            ? getColor(context, "unPaidUpcoming")
            : transaction.type == TransactionSpecialType.debt
                ? getColor(context, "unPaidOverdue")
                : getColor(context, "textLight")
        : (transaction.type == TransactionSpecialType.credit ||
                    transaction.type == TransactionSpecialType.debt) &&
                transaction.paid == false
            ? getColor(context, "textLight")
            : transaction.paid
                ? transaction.income == true
                    ? getColor(context, "incomeAmount")
                    : getColor(context, "expenseAmount")
                : transaction.skipPaid
                    ? getColor(context, "textLight")
                    : transaction.dateCreated.millisecondsSinceEpoch <=
                            DateTime.now().millisecondsSinceEpoch
                        ? getColor(context, "textLight")
                        // getColor(context, "unPaidOverdue")
                        : getColor(context, "textLight");
    // getColor(context, "unPaidUpcoming");
    Color iconColor = dynamicPastel(
        context, Theme.of(context).colorScheme.primary,
        amount: 0.3);

    bool showOtherCurrency =
        transaction.walletFk != appStateSettings["selectedWallet"] &&
            ((Provider.of<AllWallets>(context)
                    .indexedByPk[transaction.walletFk]
                    ?.currency) !=
                Provider.of<AllWallets>(context)
                    .indexedByPk[appStateSettings["selectedWallet"]]
                    ?.currency);

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: useHorizontalPaddingConstrained == false
              ? 0
              : getHorizontalPaddingConstrained(context)),
      child: TransactionEntryBox(
        transactionKey: transaction.transactionPk,
        child: ValueListenableBuilder(
          valueListenable: globalSelectedID,
          builder: (context, value, _) {
            bool? areTransactionsBeingSelected =
                globalSelectedID.value[listID ?? "0"]?.isNotEmpty;
            bool selected = globalSelectedID.value[listID ?? "0"]!
                .contains(transaction.transactionPk);
            bool isTransactionBeforeSelected = transactionBefore != null &&
                globalSelectedID.value[listID ?? "0"]!
                    .contains(transactionBefore?.transactionPk);
            bool isTransactionAfterSelected = transactionAfter != null &&
                globalSelectedID.value[listID ?? "0"]!
                    .contains(transactionAfter?.transactionPk);
            double borderRadius = getPlatform() == PlatformOS.isIOS ? 7 : 12;
            return Padding(
              padding: enableSelectionCheckmark
                  ? const EdgeInsets.only(left: 5, right: 5)
                  : const EdgeInsets.only(left: 13, right: 13),
              child: OpenContainerNavigation(
                borderRadius: 0,
                customBorderRadius: BorderRadius.vertical(
                  top: Radius.circular(
                    isTransactionBeforeSelected ? 0 : borderRadius,
                  ),
                  bottom: Radius.circular(
                    isTransactionAfterSelected ? 0 : borderRadius,
                  ),
                ),
                closedColor: containerColor == null
                    ? Theme.of(context).canvasColor
                    : containerColor,
                button: (openContainer) {
                  return Tappable(
                    color: Colors.transparent,
                    borderRadius: enableSelectionCheckmark ? 0 : borderRadius,
                    onLongPress: () {
                      selectTransaction(transaction, selected, true);
                    },
                    onTap: () async {
                      openContainer();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(seconds: 1),
                      curve: Curves.easeInOutCubicEmphasized,
                      padding: EdgeInsets.only(
                        left: enableSelectionCheckmark
                            ? 0
                            : selected
                                ? 12 - 2
                                : 10 - 2,
                        right: !enableSelectionCheckmark && selected ? 12 : 10,
                        top: !enableSelectionCheckmark &&
                                selected &&
                                isTransactionBeforeSelected == false
                            ? 6
                            : 4,
                        bottom: !enableSelectionCheckmark &&
                                selected &&
                                isTransactionAfterSelected == false
                            ? 6
                            : 4,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? appStateSettings["materialYou"]
                                ? categoryTintColor == null
                                    ? Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer
                                        .withOpacity(0.8)
                                    : categoryTintColor!.withOpacity(0.2)
                                : getColor(context, "black").withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(
                            isTransactionBeforeSelected ? 0 : borderRadius,
                          ),
                          bottom: Radius.circular(
                            isTransactionAfterSelected ? 0 : borderRadius,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: enableSelectionCheckmark
                            ? const EdgeInsets.only(right: 7)
                            : EdgeInsets.zero,
                        child: Row(
                          children: [
                            enableSelectionCheckmark
                                ? TransactionSelectionCheck(
                                    areTransactionsBeingSelected:
                                        areTransactionsBeingSelected,
                                    selected: selected,
                                    transaction: transaction,
                                    listID: listID,
                                    selectTransaction: selectTransaction,
                                  )
                                : SizedBox.shrink(),
                            CategoryIcon(
                              cacheImage: true,
                              category: category,
                              categoryPk: transaction.categoryFk,
                              size: 27,
                              sizePadding: 20,
                              margin: EdgeInsets.zero,
                              borderRadius: 100,
                              onTap: () {
                                openContainer();
                              },
                              tintColor: categoryTintColor,
                            ),
                            transaction.type == null
                                ? SizedBox(
                                    width: 10,
                                  )
                                : AnimatedSwitcher(
                                    duration: Duration(milliseconds: 800),
                                    child: Tooltip(
                                      key: ValueKey(transaction.paid
                                              .toString() +
                                          transaction.type.toString() +
                                          transaction.transactionPk.toString()),
                                      message: getTransactionActionNameFromType(
                                          transaction),
                                      child: GestureDetector(
                                        onTap: () {
                                          openTransactionActionFromType(
                                              context, transaction);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 6,
                                            top: 5.5,
                                            bottom: 5.5,
                                            right: 6,
                                          ),
                                          child: Transform.scale(
                                            scale: isTransactionActionDealtWith(
                                                    transaction)
                                                ? 0.92
                                                : 1,
                                            child: Tappable(
                                              color:
                                                  !isTransactionActionDealtWith(
                                                          transaction)
                                                      ? Theme.of(context)
                                                          .colorScheme
                                                          .secondaryContainer
                                                          .withOpacity(0.6)
                                                      : iconColor
                                                          .withOpacity(0.7),
                                              onTap: () {
                                                openTransactionActionFromType(
                                                    context, transaction);
                                              },
                                              borderRadius: 100,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(6),
                                                child: Icon(
                                                  getTransactionTypeIcon(
                                                      transaction.type),
                                                  color:
                                                      isTransactionActionDealtWith(
                                                              transaction)
                                                          ? (containerColor ==
                                                                  null
                                                              ? Theme.of(
                                                                      context)
                                                                  .canvasColor
                                                              : containerColor)
                                                          : iconColor
                                                              .withOpacity(0.8),
                                                  size: 23,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Builder(builder: (contextBuilder) {
                                    double fontSize =
                                        getIsFullScreen(context) == false
                                            ? 15.5
                                            : 16.5;
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 3),
                                      child: transaction.name != ""
                                          ? TextFont(
                                              text: transaction
                                                  .name.capitalizeFirst,
                                              fontSize: fontSize,
                                            )
                                          : category == null
                                              ? StreamBuilder<
                                                  TransactionCategory>(
                                                  stream: database
                                                      .getCategory(transaction
                                                          .categoryFk)
                                                      .$1,
                                                  builder: (context, snapshot) {
                                                    if (snapshot.hasData) {
                                                      return TextFont(
                                                        text:
                                                            snapshot.data!.name,
                                                        fontSize: fontSize,
                                                      );
                                                    }
                                                    return Container();
                                                  },
                                                )
                                              : TextFont(
                                                  text: category!.name,
                                                  fontSize: fontSize,
                                                ),
                                    );
                                  }),
                                  transaction.sharedReferenceBudgetPk != null &&
                                          transaction.sharedKey == null &&
                                          transaction.sharedStatus == null
                                      ? AssociatedBudgetLabel(
                                          transaction: transaction)
                                      : SizedBox.shrink(),
                                  transaction.sharedKey != null ||
                                          transaction.sharedStatus ==
                                              SharedStatus.waiting
                                      ? SharedBudgetLabel(
                                          transaction: transaction)
                                      : SizedBox.shrink()
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 7,
                            ),
                            getIsFullScreen(context)
                                ? TransactionEntryTypeButton(
                                    transaction: transaction,
                                  )
                                : SizedBox.shrink(),
                            TransactionEntryNote(
                              transaction: transaction,
                              iconColor: iconColor,
                            ),
                            TransactionEntryAmount(
                              transaction: transaction,
                              showOtherCurrency: showOtherCurrency,
                              textColor: textColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                openPage: openPage,
              ),
            );
          },
        ),
      ),
    );
  }
}

class TransactionSelectionCheck extends StatelessWidget {
  final bool selected;
  final bool? areTransactionsBeingSelected;
  final String? listID;
  final dynamic transaction;
  final Function(Transaction transaction, bool selected, bool isSwiping)
      selectTransaction;

  const TransactionSelectionCheck({
    required this.selected,
    required this.areTransactionsBeingSelected,
    this.listID,
    required this.transaction,
    required this.selectTransaction,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: Duration(milliseconds: 550),
      curve: Curves.easeInOutCubicEmphasized,
      child: selected || areTransactionsBeingSelected == true
          ? ScaleIn(
              key: ValueKey(areTransactionsBeingSelected),
              curve: Curves.easeInOutCubicEmphasized,
              child: Padding(
                padding: EdgeInsets.only(
                  left: getIsFullScreen(context) ? 5 : 0,
                ),
                child: GestureDetector(
                  onVerticalDragStart: (_) {
                    selectTransaction(transaction, selected, true);
                  },
                  child: Tappable(
                    borderRadius: 100,
                    onTap: () {
                      selectTransaction(transaction, selected, false);
                    },
                    color: Colors.transparent,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 12,
                      ),
                      child: ScaledAnimatedSwitcher(
                        duration: Duration(milliseconds: 275),
                        keyToWatch: selected.toString(),
                        child: Transform.scale(
                          scale: selected ? 1 : 0.95,
                          child: Container(
                            decoration: BoxDecoration(
                              color: selected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selected
                                    ? Colors.transparent
                                    : Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.8),
                                width: 2,
                              ),
                            ),
                            padding: EdgeInsets.all(2),
                            child: Icon(
                              Icons.check,
                              size: 14,
                              color: selected
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          : Container(width: 7 + 8),
    );
  }
}
