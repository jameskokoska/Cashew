import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/categoryIcon.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/struct/upcomingTransactionsFunctions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../colors.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/countNumber.dart';
import 'package:budget/struct/currencyFunctions.dart';

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
    // if (selected !=
    //     globalSelectedID.value[listID ?? "0"]!
    //         .contains(transaction.transactionPk))
    //   setState(() {
    //     selected = globalSelectedID.value[listID ?? "0"]!
    //         .contains(transaction.transactionPk);
    //   });

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
                        ? getColor(context, "unPaidOverdue")
                        : getColor(context, "unPaidUpcoming");
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
                        right: selected ? 12 : 10,
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
                          Container(
                            width: 12,
                          ),
                          transaction.type != null
                              ? Padding(
                                  padding: EdgeInsets.only(right: 3),
                                  child: Icon(
                                    getTransactionTypeIcon(transaction.type),
                                    color: iconColor,
                                    size: 20,
                                  ),
                                )
                              : SizedBox(),
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
                          // Expanded(
                          //   child: Container(
                          //     child: Column(
                          //       crossAxisAlignment: CrossAxisAlignment.start,
                          //       children: [
                          //         transaction.name != ""
                          //             ? TextFont(
                          //                 text: transaction.name,
                          //                 fontSize: 20,
                          //               )
                          //             : Container(
                          //                 height: transaction.note == "" ? 0 : 7),
                          //         transaction.name == "" &&
                          //                 (transaction.labelFks?.length ?? 0) > 0
                          //             ? TagIcon(
                          //                 tag: TransactionTag(
                          //                     title: "test",
                          //                     id: "test",
                          //                     categoryID: "id"),
                          //                 size: transaction.note == "" ? 20 : 16)
                          //             : Container(),
                          //         transaction.name == "" &&
                          //                 (transaction.labelFks?.length ?? 0) == 0
                          //             ? StreamBuilder<TransactionCategory>(
                          //                 stream: database
                          //                     .getCategory(transaction.categoryFk),
                          //                 builder: (context, snapshot) {
                          //                   if (snapshot.hasData) {
                          //                     return TextFont(
                          //                       text: snapshot.data!.name,
                          //                       fontSize:
                          //                           transaction.note == "" ? 20 : 20,
                          //                     );
                          //                   }
                          //                   return TextFont(
                          //                     text: "",
                          //                     fontSize:
                          //                         transaction.note == "" ? 20 : 20,
                          //                   );
                          //                 })
                          //             : Container(),
                          //         transaction.name == "" && transaction.note != ""
                          //             ? Container(height: 4)
                          //             : Container(),
                          //         transaction.note == ""
                          //             ? Container()
                          //             : TextFont(
                          //                 text: transaction.note,
                          //                 fontSize: 16,
                          //                 maxLines: 2,
                          //               ),
                          //         transaction.note == ""
                          //             ? Container()
                          //             : Container(height: 4),
                          //         //TODO loop through all tags relating to this entry
                          //         transaction.name != "" &&
                          //                 (transaction.labelFks?.length ?? 0) > 0
                          //             ? TagIcon(
                          //                 tag: TransactionTag(
                          //                     title: "test",
                          //                     id: "test",
                          //                     categoryID: "id"),
                          //                 size: 12)
                          //             : Container()
                          //       ],
                          //     ),
                          //   ),
                          // ),
                          TransactionEntryTypeButton(
                            transaction: transaction,
                          ),
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

class TransactionEntryTypeButton extends StatelessWidget {
  const TransactionEntryTypeButton({required this.transaction, super.key});
  final Transaction transaction;
  @override
  Widget build(BuildContext context) {
    return transaction.type != null
        ? Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 3.0),
                child: Tappable(
                  color: Colors.transparent,
                  borderRadius: 10,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 3),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 7),
                      decoration: BoxDecoration(
                          color: appStateSettings["materialYou"]
                              ? Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.1)
                              : getColor(context, "lightDarkAccent"),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: TextFont(
                        text: transaction.type == TransactionSpecialType.credit
                            ? transaction.paid
                                ? "collect".tr() + "?"
                                : "collected".tr()
                            : transaction.type == TransactionSpecialType.debt
                                ? transaction.paid
                                    ? "settle".tr() + "?"
                                    : "settled".tr()
                                : transaction.income
                                    ? (transaction.paid
                                        ? "deposited".tr()
                                        : transaction.skipPaid
                                            ? "skipped".tr()
                                            : "deposit".tr() + "?")
                                    : (transaction.paid
                                        ? "paid".tr()
                                        : transaction.skipPaid
                                            ? "skipped".tr()
                                            : "pay".tr() + "?"),
                        fontSize: 14,
                        textColor: getColor(context, "textLight"),
                      ),
                    ),
                  ),
                  onTap: () {
                    if (transaction.paid == false &&
                        (transaction.type == TransactionSpecialType.credit ||
                            transaction.type == TransactionSpecialType.debt)) {
                      openUnpayDebtCreditPopup(context, transaction);
                    } else if (transaction.paid == true &&
                        (transaction.type == TransactionSpecialType.credit ||
                            transaction.type == TransactionSpecialType.debt)) {
                      openPayDebtCreditPopup(context, transaction);
                    } else if (transaction.paid == true) {
                      openUnpayPopup(context, transaction);
                    } else if (transaction.skipPaid == true) {
                      openRemoveSkipPopup(context, transaction);
                    } else {
                      openPayPopup(context, transaction);
                    }
                  },
                ),
              ),
            ],
          )
        : SizedBox();
  }
}

class TransactionEntryNote extends StatelessWidget {
  const TransactionEntryNote({
    required this.transaction,
    required this.iconColor,
    super.key,
  });
  final Transaction transaction;
  final Color iconColor;
  @override
  Widget build(BuildContext context) {
    return transaction.note.toString().trim() != ""
        ? Tooltip(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            margin: EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: getColor(context, "lightDarkAccent"),
              boxShadow: boxShadowCheck(
                [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.light
                        ? getColor(context, "shadowColorLight").withOpacity(0.3)
                        : Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    offset: Offset(0, 4),
                    spreadRadius: 9,
                  ),
                ],
              ),
            ),
            textStyle: TextStyle(
                color: getColor(context, "black"), fontFamily: 'Avenir'),
            triggerMode: TooltipTriggerMode.tap,
            showDuration: getIsFullScreen(context) == false
                ? Duration(milliseconds: 10000)
                : Duration(milliseconds: 100),
            message: transaction.note,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 10),
              child: Icon(
                Icons.sticky_note_2_rounded,
                size: 22,
                color: iconColor,
              ),
            ),
          )
        : SizedBox.shrink();
  }
}

class TransactionEntryAmount extends StatelessWidget {
  const TransactionEntryAmount({
    required this.transaction,
    required this.textColor,
    required this.showOtherCurrency,
    super.key,
  });
  final Transaction transaction;
  final Color textColor;
  final bool showOtherCurrency;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            CountNumber(
              count: (transaction.amount.abs()) *
                  (amountRatioToPrimaryCurrencyGivenPk(
                          Provider.of<AllWallets>(context),
                          transaction.walletFk) ??
                      1),
              duration: Duration(milliseconds: 1000),
              dynamicDecimals: true,
              initialCount: (transaction.amount.abs()) *
                  (amountRatioToPrimaryCurrencyGivenPk(
                          Provider.of<AllWallets>(context),
                          transaction.walletFk) ??
                      1),
              textBuilder: (number) {
                return Row(
                  children: [
                    Transform.translate(
                      offset: Offset(3, 0),
                      child: AnimatedSize(
                        curve: Curves.easeInOutCubicEmphasized,
                        duration: Duration(milliseconds: 1000),
                        child: (transaction.type ==
                                        TransactionSpecialType.credit ||
                                    transaction.type ==
                                        TransactionSpecialType.debt) &&
                                transaction.paid == false
                            ? Container(width: 5)
                            : AnimatedRotation(
                                duration: Duration(milliseconds: 2000),
                                curve: ElasticOutCurve(0.5),
                                turns: transaction.income ? 0.5 : 0,
                                child: Icon(
                                  Icons.arrow_drop_down_rounded,
                                  color: textColor,
                                ),
                              ),
                      ),
                    ),
                    TextFont(
                      text: convertToMoney(
                        Provider.of<AllWallets>(context),
                        number,
                        showCurrency: false,
                        finalNumber: (transaction.amount.abs()) *
                            (amountRatioToPrimaryCurrencyGivenPk(
                                    Provider.of<AllWallets>(context),
                                    transaction.walletFk) ??
                                1),
                      ),
                      fontSize: 19 - (showOtherCurrency ? 1 : 0),
                      fontWeight: FontWeight.bold,
                      textColor: textColor,
                      walletPkForCurrency: appStateSettings["selectedWallet"],
                      onlyShowCurrencyIcon: true,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        AnimatedSize(
          duration: Duration(milliseconds: 500),
          child: showOtherCurrency
              ? Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: TextFont(
                    text: convertToMoney(
                      Provider.of<AllWallets>(context),
                      transaction.amount.abs(),
                      showCurrency: false,
                      decimals: 2,
                      // TODO this should match the decimal count of transaction.walletFk
                    ),
                    fontSize: 12,
                    textColor: textColor.withOpacity(0.6),
                    walletPkForCurrency: transaction.walletFk,
                    onlyShowCurrencyIcon: transaction.walletFk ==
                        appStateSettings["selectedWallet"],
                  ),
                )
              : SizedBox.shrink(),
        ),
      ],
    );
  }
}

//If 1, selecting, if -1 deselecting
int selectingTransactionsActive = 0;

class SwipeToSelectTransactions extends StatefulWidget {
  const SwipeToSelectTransactions({
    super.key,
    required this.listID,
    required this.child,
  });

  final String listID;
  final Widget child;

  @override
  State<SwipeToSelectTransactions> createState() =>
      _SwipeToSelectTransactionsState();
}

class _SwipeToSelectTransactionsState extends State<SwipeToSelectTransactions> {
  final key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerMove: (PointerEvent event) {
        // reference: https://stackoverflow.com/questions/70277515/how-can-i-select-widgets-by-dragging-over-them-but-also-clicking-them-individual
        final RenderBox box =
            key.currentContext!.findAncestorRenderObjectOfType<RenderBox>()!;
        final result = BoxHitTestResult();
        Offset local = box.globalToLocal(event.position);
        if (box.hitTest(result, position: local)) {
          for (final hit in result.path) {
            final target = hit.target;
            if (target is TransactionEntryHitBox) {
              if (selectingTransactionsActive == 0) {
                return;
              }
              if (target.transactionKey != null) {
                if (selectingTransactionsActive == 1) {
                  if (!globalSelectedID.value[widget.listID]!
                      .contains(target.transactionKey!)) {
                    globalSelectedID.value[widget.listID]!
                        .add(target.transactionKey!);
                    globalSelectedID.notifyListeners();
                    HapticFeedback.heavyImpact();
                  }
                } else if (selectingTransactionsActive == -1) {
                  if (globalSelectedID.value[widget.listID]!
                      .contains(target.transactionKey!)) {
                    globalSelectedID.value[widget.listID]!
                        .remove(target.transactionKey);
                    globalSelectedID.notifyListeners();
                    HapticFeedback.heavyImpact();
                  }
                }
              }
            }
          }
        }
      },
      onPointerUp: (_) {
        selectingTransactionsActive = 0;
      },
      child: SizedBox(
        key: key,
        child: widget.child,
      ),
    );
  }
}

class InfiniteRotationAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  InfiniteRotationAnimation({
    required this.child,
    this.duration = const Duration(milliseconds: 2000),
  });

  @override
  _InfiniteRotationAnimationState createState() =>
      _InfiniteRotationAnimationState();
}

class _InfiniteRotationAnimationState extends State<InfiniteRotationAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    animation = Tween<double>(
      begin: 0,
      end: -12.5664, // 2Radians (360 degrees)
    ).animate(animationController);
    animationController.forward();
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationController.repeat();
      }
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) => Transform.rotate(
        angle: animation.value,
        child: widget.child,
      ),
    );
  }
}

// class TagIcon extends StatefulWidget {
//   TagIcon(
//       {Key? key,
//       required this.tag,
//       required this.size,
//       this.onTap,
//       this.selected = false})
//       : super(key: key);

//   final TransactionTag tag;
//   final double size;
//   final VoidCallback? onTap;
//   final bool selected;

//   @override
//   _TagIconState createState() => _TagIconState();
// }

// class _TagIconState extends State<TagIcon> {
//   bool selected = false;

//   @override
//   void initState() {
//     super.initState();
//     setState(() {
//       selected = selected;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Tappable(
//       onTap: onTap == null
//           ? null
//           : () {
//               setState(() {
//                 selected = !selected;
//               });
//               onTap;
//             },
//       borderRadius: size * 0.8,
//       child: AnimatedContainer(
//         duration: Duration(milliseconds: 200),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(size * 0.8),
//           color: selected
//               ? .colors["accentColor"].withOpacity(0.8)
//               : Theme.of(context)
//                   .colorScheme
//                   .lightDarkAccentHeavy
//                   .withOpacity(0.6),
//         ),
//         child: Padding(
//           padding: EdgeInsets.only(
//             right: onTap == null
//                 ? 9 * size / 14
//                 : 8 * size / 14,
//             left: onTap == null
//                 ? 9 * size / 14
//                 : 6 * size / 14,
//           ),
//           child: Row(
//               mainAxisSize: MainAxisSize.min,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 onTap != null
//                     ? Padding(
//                         padding: EdgeInsets.only(right: 2 * size / 14),
//                         child: AnimatedContainer(
//                           duration: Duration(milliseconds: 700),
//                           width:
//                               selected ? size * 0.9 : size * 0.75,
//                           height:
//                               selected ? size * 0.9 : size * 0.75,
//                           margin: EdgeInsets.symmetric(
//                               horizontal: selected
//                                   ? size * 0.1 / 2
//                                   : size * 0.25 / 2),
//                           curve: Curves.elasticOut,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(size),
//                             color: selected
//                                 ? Theme.of(context)
//                                     .colorScheme
//                                     .accentColorHeavy
//                                     .withOpacity(0.8)
//                                 : Theme.of(context)
//                                     .colorScheme
//                                     .lightDarkAccentHeavy
//                                     .withOpacity(0.9),
//                           ),
//                         ),
//                       )
//                     : Container(),
//                 Padding(
//                   padding: EdgeInsets.only(
//                     top: 4 * size / 14,
//                     bottom: 4 * size / 14,
//                   ),
//                   child: TextFont(
//                     text: tag.title,
//                     fontSize: size,
//                   ),
//                 ),
//               ]),
//         ),
//       ),
//     );
//   }
// }

class DateDivider extends StatelessWidget {
  DateDivider({
    Key? key,
    required this.date,
    this.info,
    this.color,
    this.useHorizontalPaddingConstrained = true,
  }) : super(key: key);

  final DateTime date;
  final String? info;
  final Color? color;
  final bool useHorizontalPaddingConstrained;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: useHorizontalPaddingConstrained == false
            ? 0
            : getHorizontalPaddingConstrained(context),
      ),
      child: Container(
        color: color == null ? Theme.of(context).canvasColor : color,
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextFont(
              text: getWordedDate(date,
                  includeMonthDate: true, includeYearIfNotCurrentYear: true),
              fontSize: 14,
              textColor: getColor(context, "textLight"),
            ),
            info != null
                ? TextFont(
                    text: info!,
                    fontSize: 14,
                    textColor: getColor(context, "textLight"),
                  )
                : SizedBox()
          ],
        ),
      ),
    );
  }
}
