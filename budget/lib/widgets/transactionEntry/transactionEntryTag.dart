import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/categoryEntry.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/util/infiniteRotationAnimation.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';
import 'package:provider/provider.dart';

class TransactionEntryTag extends StatelessWidget {
  const TransactionEntryTag(
      {required this.transaction,
      this.showObjectivePercentage = true,
      super.key});
  final Transaction transaction;
  final bool showObjectivePercentage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 1.0),
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
                        Budget budget = snapshot.data!;
                        return TransactionTag(
                          color: HexColor(budget.colour),
                          name: budget.name,
                        );
                      }
                      return Container();
                    },
                  ),
                ),
          transaction.objectiveFk == null
              ? SizedBox.shrink()
              : Expanded(
                  child: StreamBuilder<Objective>(
                    stream: database.getObjective(transaction.objectiveFk!),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        Objective objective = snapshot.data!;
                        return StreamBuilder<double?>(
                          stream: database.watchTotalTowardsObjective(
                            Provider.of<AllWallets>(context),
                            objective.objectivePk,
                          ),
                          builder: (context, snapshot) {
                            double totalAmount = snapshot.data ?? 0;
                            if (objective.income == false) {
                              totalAmount = totalAmount * -1;
                            }
                            double percentageTowardsGoal = objective.amount == 0
                                ? 0
                                : totalAmount / objective.amount;
                            percentageTowardsGoal = percentageTowardsGoal <= 0
                                ? 0
                                : percentageTowardsGoal;
                            // Use layout builder
                            // https://stackoverflow.com/questions/65933330/expanded-and-flexible-not-filling-entire-row
                            return LayoutBuilder(
                              builder: (context, constraints) {
                                return Row(
                                  children: [
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                          maxWidth: constraints.maxWidth * 0.8),
                                      child: TransactionTag(
                                        color: HexColor(objective.colour),
                                        name: objective.name +
                                            ": " +
                                            convertToPercent(
                                                percentageTowardsGoal * 100,
                                                numberDecimals: 0),
                                      ),
                                    ),
                                    if (showObjectivePercentage)
                                      SizedBox(width: 7),
                                    if (showObjectivePercentage)
                                      Expanded(
                                        child: ThinProgress(
                                          backgroundColor:
                                              appStateSettings["materialYou"]
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .secondaryContainer
                                                  : getColor(context,
                                                      "lightDarkAccentHeavy"),
                                          color: HexColor(objective.colour),
                                          progress: percentageTowardsGoal,
                                        ),
                                      ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      }
                      return Container();
                    },
                  ),
                ),
        ],
      ),
    );
  }
}

class TransactionTag extends StatelessWidget {
  final Color color;
  final String name;

  TransactionTag({
    required this.color,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 3),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.25),
          borderRadius: BorderRadius.circular(6),
        ),
        padding: EdgeInsets.symmetric(horizontal: 4.5, vertical: 1.05),
        child: TextFont(
          text: name,
          fontSize: 11.5,
          textColor: getColor(context, "black").withOpacity(0.7),
          maxLines: 1,
        ),
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
