import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/categoryIcon.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry/transactionEntryTypeButton.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:budget/colors.dart';
import 'package:budget/widgets/openBottomSheet.dart';

import '../util/infiniteRotationAnimation.dart';
import 'swipeToSelectTransactions.dart';
import 'transactionEntryAmount.dart';
import 'transactionEntryNote.dart';

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

  @override
  Widget build(BuildContext context) {
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
            bool selected = globalSelectedID.value[listID ?? "0"]!
                .contains(transaction.transactionPk);
            bool isTransactionBeforeSelected = transactionBefore != null &&
                globalSelectedID.value[listID ?? "0"]!
                    .contains(transactionBefore?.transactionPk);
            bool isTransactionAfterSelected = transactionAfter != null &&
                globalSelectedID.value[listID ?? "0"]!
                    .contains(transactionAfter?.transactionPk);
            return Padding(
              padding: const EdgeInsets.only(left: 13, right: 13),
              child: OpenContainerNavigation(
                borderRadius: 0,
                customBorderRadius: BorderRadius.vertical(
                  top: Radius.circular(
                    isTransactionBeforeSelected ? 0 : 12,
                  ),
                  bottom: Radius.circular(
                    isTransactionAfterSelected ? 0 : 12,
                  ),
                ),
                closedColor: containerColor == null
                    ? Theme.of(context).canvasColor
                    : containerColor,
                button: (openContainer) {
                  return Tappable(
                    color: Colors.transparent,
                    borderRadius: 15,
                    onLongPress: () {
                      if (!selected) {
                        globalSelectedID.value[listID ?? "0"]!
                            .add(transaction.transactionPk);
                        selectingTransactionsActive = 1;
                      } else {
                        globalSelectedID.value[listID ?? "0"]!
                            .remove(transaction.transactionPk);
                        selectingTransactionsActive = -1;
                      }
                      globalSelectedID.notifyListeners();

                      if (onSelected != null)
                        onSelected!(transaction, selected);
                    },
                    onTap: () async {
                      openContainer();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(seconds: 1),
                      curve: Curves.easeInOutCubicEmphasized,
                      padding: EdgeInsets.only(
                        left: selected ? 12 - 2 : 10 - 2,
                        right: transaction.type == null
                            ? (selected ? 12 : 10)
                            : (selected ? 12 - 5 : 10 - 5),
                        top: selected && isTransactionBeforeSelected == false
                            ? 6
                            : 4,
                        bottom: selected && isTransactionAfterSelected == false
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
                            isTransactionBeforeSelected ? 0 : 12,
                          ),
                          bottom: Radius.circular(
                            isTransactionAfterSelected ? 0 : 12,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
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
                                  duration: Duration(milliseconds: 600),
                                  child: Tooltip(
                                    key: ValueKey(transaction.paid),
                                    message: getTransactionActionNameFromType(
                                            transaction)
                                        .tr(),
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
                                              padding: const EdgeInsets.all(6),
                                              child: Icon(
                                                getTransactionTypeIcon(
                                                    transaction.type),
                                                color:
                                                    isTransactionActionDealtWith(
                                                            transaction)
                                                        ? (containerColor ==
                                                                null
                                                            ? Theme.of(context)
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
                                          text:
                                              transaction.name.capitalizeFirst,
                                          fontSize: fontSize,
                                        )
                                      : category == null
                                          ? StreamBuilder<TransactionCategory>(
                                              stream: database
                                                  .getCategory(
                                                      transaction.categoryFk)
                                                  .$1,
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  return TextFont(
                                                    text: snapshot.data!.name,
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
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 1.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                transaction.sharedReferenceBudgetPk ==
                                                        null
                                                    ? SizedBox.shrink()
                                                    : Expanded(
                                                        child: StreamBuilder<
                                                            Budget>(
                                                          stream: database
                                                              .getBudget(transaction
                                                                  .sharedReferenceBudgetPk!),
                                                          builder: (context,
                                                              snapshot) {
                                                            if (snapshot
                                                                .hasData) {
                                                              return Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            3),
                                                                child: TextFont(
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  text: "for"
                                                                          .tr()
                                                                          .capitalizeFirst +
                                                                      " " +
                                                                      snapshot
                                                                          .data!
                                                                          .name,
                                                                  fontSize:
                                                                      12.5,
                                                                  textColor: getColor(
                                                                          context,
                                                                          "black")
                                                                      .withOpacity(
                                                                          0.7),
                                                                ),
                                                              );
                                                            }
                                                            return Container();
                                                          },
                                                        ),
                                                      ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : SizedBox.shrink(),
                              transaction.sharedKey != null ||
                                      transaction.sharedStatus ==
                                          SharedStatus.waiting
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 1.0),
                                      child: Row(
                                        children: [
                                          transaction.sharedStatus ==
                                                  SharedStatus.waiting
                                              ? Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 2.0),
                                                  child:
                                                      InfiniteRotationAnimation(
                                                    duration: Duration(
                                                        milliseconds: 5000),
                                                    child: Icon(
                                                      transaction.sharedStatus ==
                                                              SharedStatus
                                                                  .waiting
                                                          ? Icons.sync_rounded
                                                          : transaction
                                                                      .transactionOwnerEmail !=
                                                                  appStateSettings[
                                                                      "currentUserEmail"]
                                                              ? Icons
                                                                  .arrow_circle_down_rounded
                                                              : Icons
                                                                  .arrow_circle_up_rounded,
                                                      size: 14,
                                                      color: getColor(
                                                              context, "black")
                                                          .withOpacity(0.7),
                                                    ),
                                                  ),
                                                )
                                              : Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 2),
                                                  child: Icon(
                                                    transaction.transactionOwnerEmail !=
                                                            appStateSettings[
                                                                "currentUserEmail"]
                                                        ? Icons
                                                            .arrow_circle_down_rounded
                                                        : Icons
                                                            .arrow_circle_up_rounded,
                                                    size: 14,
                                                    color: getColor(
                                                            context, "black")
                                                        .withOpacity(0.7),
                                                  ),
                                                ),
                                          SizedBox(width: 2),
                                          Expanded(
                                            child: Row(
                                              children: [
                                                transaction.sharedReferenceBudgetPk ==
                                                        null
                                                    ? SizedBox.shrink()
                                                    : Expanded(
                                                        child: StreamBuilder<
                                                            Budget>(
                                                          stream: database
                                                              .getBudget(transaction
                                                                  .sharedReferenceBudgetPk!),
                                                          builder: (context,
                                                              snapshot) {
                                                            if (snapshot
                                                                .hasData) {
                                                              return TextFont(
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                text: (transaction.transactionOwnerEmail.toString() ==
                                                                            appStateSettings[
                                                                                "currentUserEmail"]
                                                                        ? getMemberNickname(appStateSettings[
                                                                            "currentUserEmail"])
                                                                        : transaction.sharedStatus == SharedStatus.waiting &&
                                                                                (transaction.transactionOwnerEmail == appStateSettings["currentUserEmail"] || transaction.transactionOwnerEmail == null)
                                                                            ? getMemberNickname(appStateSettings["currentUserEmail"])
                                                                            : getMemberNickname(transaction.transactionOwnerEmail.toString())) +
                                                                    " for " +
                                                                    snapshot.data!.name,
                                                                fontSize: 12.5,
                                                                textColor: getColor(
                                                                        context,
                                                                        "black")
                                                                    .withOpacity(
                                                                        0.7),
                                                              );
                                                            }
                                                            return Container();
                                                          },
                                                        ),
                                                      ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : SizedBox.shrink()
                            ],
                          )),
                          SizedBox(
                            width: 7,
                          ),
                          // TransactionEntryTypeButton(
                          //   transaction: transaction,
                          // ),
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
