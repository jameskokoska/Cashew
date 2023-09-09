import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/util/infiniteRotationAnimation.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';

class AssociatedBudgetLabel extends StatelessWidget {
  const AssociatedBudgetLabel({required this.transaction, super.key});
  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 1.0),
      child: transaction.sharedReferenceBudgetPk == null
          ? SizedBox.shrink()
          : StreamBuilder<Budget>(
              stream: database.getBudget(transaction.sharedReferenceBudgetPk!),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  Budget budget = snapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.only(left: 3),
                    child: Container(
                      decoration: BoxDecoration(
                        color: HexColor(budget.colour).withOpacity(0.25),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.5, vertical: 2.25),
                      child: TextFont(
                        text: snapshot.data!.name,
                        fontSize: 11.5,
                        textColor: getColor(context, "black").withOpacity(0.7),
                      ),
                    ),
                  );
                }
                return Container();
              },
            ),
    );
  }
}

class SharedBudgetLabel extends StatelessWidget {
  const SharedBudgetLabel({required this.transaction, super.key});
  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 1.0),
      child: Row(
        children: [
          transaction.sharedStatus == SharedStatus.waiting
              ? Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: InfiniteRotationAnimation(
                    duration: Duration(milliseconds: 5000),
                    child: Icon(
                      transaction.sharedStatus == SharedStatus.waiting
                          ? appStateSettings["outlinedIcons"]
                              ? Icons.sync_outlined
                              : Icons.sync_rounded
                          : transaction.transactionOwnerEmail !=
                                  appStateSettings["currentUserEmail"]
                              ? appStateSettings["outlinedIcons"]
                                  ? Icons.arrow_circle_down_outlined
                                  : Icons.arrow_circle_down_rounded
                              : appStateSettings["outlinedIcons"]
                                  ? Icons.arrow_circle_up_outlined
                                  : Icons.arrow_circle_up_rounded,
                      size: 14,
                      color: getColor(context, "black").withOpacity(0.7),
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    transaction.transactionOwnerEmail !=
                            appStateSettings["currentUserEmail"]
                        ? appStateSettings["outlinedIcons"]
                            ? Icons.arrow_circle_down_outlined
                            : Icons.arrow_circle_down_rounded
                        : appStateSettings["outlinedIcons"]
                            ? Icons.arrow_circle_up_outlined
                            : Icons.arrow_circle_up_rounded,
                    size: 14,
                    color: getColor(context, "black").withOpacity(0.7),
                  ),
                ),
          SizedBox(width: 2),
          Expanded(
            child: Row(
              children: [
                transaction.sharedReferenceBudgetPk == null
                    ? SizedBox.shrink()
                    : Expanded(
                        child: StreamBuilder<Budget>(
                          stream: database
                              .getBudget(transaction.sharedReferenceBudgetPk!),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return TextFont(
                                overflow: TextOverflow.ellipsis,
                                text: (transaction.transactionOwnerEmail
                                                .toString() ==
                                            appStateSettings["currentUserEmail"]
                                        ? getMemberNickname(appStateSettings[
                                            "currentUserEmail"])
                                        : transaction.sharedStatus ==
                                                    SharedStatus.waiting &&
                                                (transaction.transactionOwnerEmail ==
                                                        appStateSettings[
                                                            "currentUserEmail"] ||
                                                    transaction
                                                            .transactionOwnerEmail ==
                                                        null)
                                            ? getMemberNickname(
                                                appStateSettings[
                                                    "currentUserEmail"])
                                            : getMemberNickname(transaction
                                                .transactionOwnerEmail
                                                .toString())) +
                                    " for " +
                                    snapshot.data!.name,
                                fontSize: 12.5,
                                textColor:
                                    getColor(context, "black").withOpacity(0.7),
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
    );
  }
}
