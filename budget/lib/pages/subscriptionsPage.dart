import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:budget/colors.dart';
import 'package:budget/database/binary_string_conversion.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/pages/editCategoriesPage.dart';
import 'package:budget/pages/editWalletsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/accountAndBackup.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/popupFramework.dart';
import 'package:budget/widgets/selectCategoryImage.dart';
import 'package:budget/widgets/selectColor.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:budget/main.dart';
import 'package:intl/intl.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart' as signIn;
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;
import 'dart:math' as math;
import 'package:file_picker/file_picker.dart';
import '../functions.dart';

class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({Key? key}) : super(key: key);

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

enum SelectedSubscriptionsType {
  monthly,
  yearly,
  total,
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  SelectedSubscriptionsType selectedType = SelectedSubscriptionsType
      .values[appStateSettings["selectedSubscriptionType"]];

  @override
  Widget build(BuildContext context) {
    return PageFramework(
      floatingActionButton: AnimatedScaleDelayed(
        child: FAB(
          tooltip: "Add Subscription",
          openPage: AddTransactionPage(
            title: "Add Transaction",
            subscription: true,
          ),
        ),
      ),
      dragDownToDismiss: true,
      title: "Subscriptions",
      navbar: true,
      appBarBackgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      appBarBackgroundColorStart: Theme.of(context).canvasColor,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 30, left: 20.0, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                StreamBuilder<List<Transaction>>(
                  stream: database.watchAllSubscriptions(),
                  builder: (context, snapshot) {
                    double total =
                        getTotalSubscriptions(selectedType, snapshot.data);
                    return CountNumber(
                      count: total.abs(),
                      duration: Duration(milliseconds: 700),
                      dynamicDecimals: true,
                      initialCount: (0),
                      textBuilder: (number) {
                        return TextFont(
                          textAlign: TextAlign.center,
                          text: convertToMoney(number),
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        );
                      },
                    );
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: TextFont(
                    text: selectedType == SelectedSubscriptionsType.yearly
                        ? "Yearly subscriptions"
                        : selectedType == SelectedSubscriptionsType.monthly
                            ? "Monthly subscriptions"
                            : "Total subscriptions",
                    fontSize: 16,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 18.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Button(
                        color: selectedType != SelectedSubscriptionsType.monthly
                            ? dynamicPastel(
                                context,
                                Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                                amount: 0.7)
                            : null,
                        label: "Monthly",
                        onTap: () => setState(() {
                          selectedType = SelectedSubscriptionsType.monthly;
                          updateSettings("selectedSubscriptionType", 0);
                        }),
                        fontSize: 12,
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                      ),
                      SizedBox(width: 7),
                      Button(
                        color: selectedType != SelectedSubscriptionsType.yearly
                            ? dynamicPastel(
                                context,
                                Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                                amount: 0.7)
                            : null,
                        label: "Yearly",
                        onTap: () => setState(() {
                          selectedType = SelectedSubscriptionsType.yearly;
                          updateSettings("selectedSubscriptionType", 1);
                        }),
                        fontSize: 12,
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                      ),
                      SizedBox(width: 7),
                      Button(
                        color: selectedType != SelectedSubscriptionsType.total
                            ? dynamicPastel(
                                context,
                                Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                                amount: 0.7)
                            : null,
                        label: "Total",
                        onTap: () => setState(() {
                          selectedType = SelectedSubscriptionsType.total;
                          updateSettings("selectedSubscriptionType", 2);
                        }),
                        fontSize: 12,
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(height: 45),
        ),
        StreamBuilder<List<Transaction>>(
          stream: database.watchAllSubscriptions(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.length <= 0) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 85, right: 15, left: 15),
                      child: TextFont(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          text: "No subscription transactions."),
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    Transaction transaction = snapshot.data![index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        UpcomingTransactionDateHeader(
                          transaction: transaction,
                        ),
                        TransactionEntry(
                          openPage: AddTransactionPage(
                            title: "Edit Transaction",
                            transaction: transaction,
                          ),
                          transaction: transaction,
                        ),
                        SizedBox(height: 12),
                      ],
                    );
                  },
                  childCount: snapshot.data?.length,
                ),
              );
            } else {
              return SliverToBoxAdapter();
            }
          },
        )
      ],
    );
  }
}

class UpcomingTransactionDateHeader extends StatelessWidget {
  const UpcomingTransactionDateHeader({Key? key, required this.transaction})
      : super(key: key);

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    int daysDifference =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
            .difference(transaction.dateCreated)
            .inDays;
    return Padding(
      padding: const EdgeInsets.only(left: 19, bottom: 3, right: 19),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              TextFont(
                text: getWordedDateShortMore(transaction.dateCreated),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              daysDifference != 0
                  ? TextFont(
                      fontSize: 16,
                      textColor: Theme.of(context).colorScheme.textLight,
                      text: " • " +
                          daysDifference.abs().toString() +
                          " " +
                          (daysDifference.abs() == 1 ? "day" : "days") +
                          (daysDifference > 0 ? " overdue" : ""),
                      fontWeight: FontWeight.bold,
                    )
                  : SizedBox(),
            ],
          ),
          transaction.type == TransactionSpecialType.repetitive ||
                  transaction.type == TransactionSpecialType.subscription
              ? Row(
                  children: [
                    Icon(
                      Icons.loop_rounded,
                      color: dynamicPastel(
                          context, Theme.of(context).colorScheme.primary,
                          amount: 0.4),
                      size: 16,
                    ),
                    SizedBox(width: 3),
                    TextFont(
                      text: transaction.periodLength.toString() +
                          " " +
                          (transaction.periodLength == 1
                              ? nameRecurrence[transaction.reoccurrence]
                              : namesRecurrence[transaction.reoccurrence]),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      textColor: dynamicPastel(
                          context, Theme.of(context).colorScheme.primary,
                          amount: 0.4),
                    ),
                  ],
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
