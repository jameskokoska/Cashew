import 'dart:developer';

import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/editCategoriesPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/categoryIcon.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/globalSnackBar.dart';
import 'package:budget/widgets/initializeNotifications.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import '../colors.dart';
import 'package:intl/intl.dart';

ValueNotifier<Map<String, List<int>>> globalSelectedID =
    ValueNotifier<Map<String, List<int>>>({});

class TransactionEntry extends StatelessWidget {
  TransactionEntry({
    Key? key,
    required this.openPage,
    required this.transaction,
    this.listID, //needs to be unique based on the page to avoid conflicting globalSelectedIDs
    this.category,
    this.onSelected,
  }) : super(key: key);

  final Widget openPage;
  final Transaction transaction;
  final String? listID;
  final TransactionCategory? category;
  final Function(Transaction transaction, bool selected)? onSelected;

  final double fabSize = 50;

  createNewSubscriptionTransaction(context, Transaction transaction) async {
    if (transaction.createdAnotherFutureTransaction == false) {
      if (transaction.type == TransactionSpecialType.subscription ||
          transaction.type == TransactionSpecialType.repetitive) {
        int yearOffset = 0;
        int monthOffset = 0;
        int dayOffset = 0;
        if (transaction.reoccurrence == BudgetReoccurence.yearly) {
          yearOffset = transaction.periodLength ?? 0;
        } else if (transaction.reoccurrence == BudgetReoccurence.monthly) {
          monthOffset = transaction.periodLength ?? 0;
        } else if (transaction.reoccurrence == BudgetReoccurence.weekly) {
          dayOffset = (transaction.periodLength ?? 0) * 7;
        } else if (transaction.reoccurrence == BudgetReoccurence.daily) {
          dayOffset = transaction.periodLength ?? 0;
        }
        DateTime newDate = DateTime(
          transaction.dateCreated.year + yearOffset,
          transaction.dateCreated.month + monthOffset,
          transaction.dateCreated.day + dayOffset,
        );
        Transaction newTransaction = transaction.copyWith(
          paid: false,
          transactionPk: DateTime.now().millisecond,
          dateCreated: newDate,
          createdAnotherFutureTransaction: Value(false),
        );
        await database.createOrUpdateTransaction(newTransaction);

        openSnackbar(
          SnackbarMessage(
            title: "Created New Subscription",
            description: "On " + getWordedDateShort(newDate),
            icon: Icons.event_repeat_rounded,
            onTap: () {
              pushRoute(
                context,
                AddTransactionPage(
                    title: "Edit Transaction", transaction: newTransaction),
              );
            },
          ),
        );
      }
    }
  }

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

    Color textColor = transaction.paid
        ? transaction.income == true
            ? Theme.of(context).colorScheme.incomeGreen
            : Theme.of(context).colorScheme.black
        : transaction.skipPaid
            ? Theme.of(context).colorScheme.textLight
            : transaction.dateCreated.millisecondsSinceEpoch <=
                    DateTime.now().millisecondsSinceEpoch
                ? Theme.of(context).colorScheme.unPaidRed
                : Theme.of(context).colorScheme.unPaidYellow;
    Color iconColor = dynamicPastel(
        context, Theme.of(context).colorScheme.primary,
        amount: 0.3);

    Color textColorLight = Theme.of(context).colorScheme.textLight;

    return ValueListenableBuilder(
      valueListenable: globalSelectedID,
      builder: (context, value, _) {
        bool selected = globalSelectedID.value[listID ?? "0"]!
            .contains(transaction.transactionPk);
        return OpenContainerNavigation(
          borderRadius: 15,
          button: (openContainer) {
            return Padding(
              padding:
                  const EdgeInsets.only(left: 13, right: 13, top: 1, bottom: 2),
              child: Tappable(
                borderRadius: 15,
                onLongPress: () {
                  if (!selected) {
                    globalSelectedID.value[listID ?? "0"]!
                        .add(transaction.transactionPk);
                  } else {
                    globalSelectedID.value[listID ?? "0"]!
                        .remove(transaction.transactionPk);
                  }
                  globalSelectedID.notifyListeners();

                  if (onSelected != null) onSelected!(transaction, selected);
                },
                onTap: () async {
                  openContainer();
                },
                child: AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeInOutCubicEmphasized,
                  padding: EdgeInsets.only(
                    left: selected ? 15 - 2 : 10 - 2,
                    right: selected ? 15 : 10,
                    top: selected ? 8 : 4,
                    bottom: selected ? 8 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? appStateSettings["materialYou"]
                            ? Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.35)
                            : Theme.of(context)
                                .colorScheme
                                .lightDarkAccentHeavy
                                .withAlpha(200)
                        : Colors.transparent,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          CategoryIcon(
                            categoryPk: transaction.categoryFk,
                            size: 33,
                            sizePadding: 15,
                            margin: EdgeInsets.zero,
                            borderRadius: 13,
                          ),
                          transaction.sharedKey != null
                              ? Positioned(
                                  bottom: 0,
                                  left: 0,
                                  child: Transform.translate(
                                    offset: Offset(-3, 3),
                                    child: Icon(
                                        transaction.transactionOwnerEmail !=
                                                appStateSettings[
                                                    "currentUserEmail"]
                                            ? Icons.download_rounded
                                            : Icons.upload_rounded,
                                        size: 15),
                                  ),
                                )
                              : SizedBox.shrink()
                        ],
                      ),
                      Container(
                        width: transaction.type != null ? 12 : 15,
                      ),
                      transaction.type != null
                          ? Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: Icon(
                                getTransactionTypeIcon(transaction.type),
                                color: iconColor,
                                size: 20,
                              ),
                            )
                          : SizedBox(),
                      Expanded(
                        child: transaction.name != ""
                            ? TextFont(
                                text: transaction.name,
                                fontSize: 18,
                              )
                            : category == null
                                ? StreamBuilder<TransactionCategory>(
                                    stream: database
                                        .getCategory(transaction.categoryFk),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return TextFont(
                                          text: snapshot.data!.name,
                                          fontSize: 18,
                                        );
                                      }
                                      return Container();
                                    },
                                  )
                                : TextFont(
                                    text: category!.name,
                                    fontSize: 18,
                                  ),
                      ),
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
                      transaction.type != null
                          ? Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 3.0),
                                  child: Tappable(
                                    color: Colors.transparent,
                                    borderRadius: 10,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 3),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 6, horizontal: 7),
                                        decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .lightDarkAccent,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10))),
                                        child: TextFont(
                                          text: transaction.income
                                              ? (transaction.paid
                                                  ? "Desposited"
                                                  : transaction.skipPaid
                                                      ? "Skipped"
                                                      : "Desposit?")
                                              : (transaction.paid
                                                  ? "Paid"
                                                  : transaction.skipPaid
                                                      ? "Skipped"
                                                      : "Pay?"),
                                          fontSize: 14,
                                          textColor: textColorLight,
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      if (transaction.paid == true) {
                                        openPopup(context,
                                            icon: Icons.unpublished_rounded,
                                            title: "Remove Payment?",
                                            description:
                                                "Remove the payment on this transaction?",
                                            onCancelLabel: "Cancel",
                                            onCancel: () {
                                              Navigator.pop(context);
                                            },
                                            onSubmitLabel: "Remove",
                                            onSubmit: () async {
                                              Transaction transactionNew =
                                                  transaction.copyWith(
                                                      paid: false);
                                              await database
                                                  .createOrUpdateTransaction(
                                                      transactionNew);
                                              Navigator.pop(context);
                                              setUpcomingNotifications(context);
                                            });
                                      } else if (transaction.skipPaid == true) {
                                        openPopup(context,
                                            icon: Icons.unpublished_rounded,
                                            title: "Remove Skip?",
                                            description:
                                                "Remove the skipped payment on this transaction?",
                                            onCancelLabel: "Cancel",
                                            onCancel: () {
                                              Navigator.pop(context);
                                            },
                                            onSubmitLabel: "Remove",
                                            onSubmit: () async {
                                              Transaction transactionNew =
                                                  transaction.copyWith(
                                                      skipPaid: false);
                                              await database
                                                  .createOrUpdateTransaction(
                                                      transactionNew);
                                              Navigator.pop(context);
                                              setUpcomingNotifications(context);
                                            });
                                      } else {
                                        openPopup(
                                          context,
                                          icon: Icons.payments_rounded,
                                          title: transaction.income
                                              ? "Desposit?"
                                              : "Pay?",
                                          description: transaction.income
                                              ? "Desposit this amount?"
                                              : "Add payment on this transaction?",
                                          onCancelLabel: "Cancel",
                                          onCancel: () {
                                            Navigator.pop(context);
                                          },
                                          onExtraLabel: "Skip",
                                          onExtra: () async {
                                            Transaction transactionNew =
                                                transaction.copyWith(
                                                    skipPaid: true,
                                                    dateCreated: DateTime(
                                                        DateTime.now().year,
                                                        DateTime.now().month,
                                                        DateTime.now().day),
                                                    createdAnotherFutureTransaction:
                                                        Value(true));
                                            await database
                                                .createOrUpdateTransaction(
                                                    transactionNew);
                                            await createNewSubscriptionTransaction(
                                                context, transactionNew);
                                            Navigator.pop(context);
                                            setUpcomingNotifications(context);
                                          },
                                          onSubmitLabel: transaction.income
                                              ? "Desposit"
                                              : "Pay",
                                          onSubmit: () async {
                                            Transaction transactionNew =
                                                transaction.copyWith(
                                                    paid: !transaction.paid,
                                                    dateCreated: DateTime(
                                                        DateTime.now().year,
                                                        DateTime.now().month,
                                                        DateTime.now().day),
                                                    createdAnotherFutureTransaction:
                                                        Value(true));
                                            await database
                                                .createOrUpdateTransaction(
                                                    transactionNew);
                                            await createNewSubscriptionTransaction(
                                                context, transaction);
                                            Navigator.pop(context);
                                            setUpcomingNotifications(context);
                                          },
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ],
                            )
                          : SizedBox(),

                      CountNumber(
                        count: (transaction.amount.abs()),
                        duration: Duration(milliseconds: 2000),
                        dynamicDecimals: true,
                        initialCount: (transaction.amount.abs()),
                        textBuilder: (number) {
                          return TextFont(
                            textAlign: TextAlign.left,
                            text: convertToMoney(number),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            textColor: textColor,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          openPage: openPage,
          closedColor: Theme.of(context).colorScheme.background,
        );
      },
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
//               ? Theme.of(context).colorScheme.accentColor.withOpacity(0.8)
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
  }) : super(key: key);

  final DateTime date;
  final String? info;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextFont(
            text: getWordedDate(date,
                includeMonthDate: true, includeYearIfNotCurrentYear: true),
            fontSize: 14,
            textColor: Theme.of(context).colorScheme.textLight,
          ),
          info != null
              ? TextFont(
                  text: info!,
                  fontSize: 14,
                  textColor: Theme.of(context).colorScheme.textLight,
                )
              : SizedBox()
        ],
      ),
    );
  }
}
