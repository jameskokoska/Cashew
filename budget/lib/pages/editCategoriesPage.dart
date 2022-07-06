import 'dart:developer';

import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditCategoriesPage extends StatefulWidget {
  EditCategoriesPage({
    Key? key,
    required this.title,
  }) : super(key: key);
  final String title;

  @override
  _EditCategoriesPageState createState() => _EditCategoriesPageState();
}

class _EditCategoriesPageState extends State<EditCategoriesPage> {
  bool dragDownToDismissEnabled = true;
  int currentReorder = -1;
  @override
  Widget build(BuildContext context) {
    return PageFramework(
      dragDownToDismiss: true,
      dragDownToDismissEnabled: dragDownToDismissEnabled,
      title: widget.title,
      navbar: false,
      floatingActionButton: AnimatedScaleDelayed(
        child: FAB(
          tooltip: "Add Category",
          openPage: AddCategoryPage(
            title: "Add Category",
          ),
        ),
      ),
      slivers: [
        StreamBuilder<List<TransactionCategory>>(
          stream: database.watchAllCategories(),
          builder: (context, snapshot) {
            if (snapshot.hasData && (snapshot.data ?? []).length <= 0) {
              return SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 85, right: 15, left: 15),
                    child: TextFont(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        text: "No categories created."),
                  ),
                ),
              );
            }
            if (snapshot.hasData && (snapshot.data ?? []).length > 0) {
              return SliverReorderableList(
                onReorderStart: (index) {
                  HapticFeedback.heavyImpact();
                  setState(() {
                    dragDownToDismissEnabled = false;
                    currentReorder = index;
                  });
                },
                onReorderEnd: (_) {
                  setState(() {
                    dragDownToDismissEnabled = true;
                    currentReorder = -1;
                  });
                },
                itemBuilder: (context, index) {
                  TransactionCategory category = snapshot.data![index];
                  Color backgroundColor = dynamicPastel(
                      context,
                      HexColor(category.colour,
                          Theme.of(context).colorScheme.lightDarkAccent),
                      amountLight: 0.55,
                      amountDark: 0.35);
                  return EditRowEntry(
                    currentReorder:
                        currentReorder != -1 && currentReorder != index,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    key: ValueKey(index),
                    backgroundColor: backgroundColor,
                    content: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CategoryIcon(
                          categoryPk: category.categoryPk,
                          size: 40,
                          category: category,
                        ),
                        Container(width: 5),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFont(
                              text: category.name +
                                  " - " +
                                  category.order.toString(),
                              fontWeight: FontWeight.bold,
                              fontSize: 19,
                            ),
                            StreamBuilder<List<int?>>(
                              stream: database
                                  .watchTotalCountOfTransactionsInWalletInCategory(
                                      appStateSettings["selectedWallet"],
                                      category.categoryPk),
                              builder: (context, snapshot) {
                                if (snapshot.hasData && snapshot.data != null) {
                                  return TextFont(
                                    textAlign: TextAlign.left,
                                    text: snapshot.data![0] == 1
                                        ? (snapshot.data![0].toString() +
                                            " transaction")
                                        : (snapshot.data![0].toString() +
                                            " transactions"),
                                    fontSize: 14,
                                    textColor: Theme.of(context)
                                        .colorScheme
                                        .black
                                        .withOpacity(0.65),
                                  );
                                } else {
                                  return TextFont(
                                    textAlign: TextAlign.left,
                                    text: "/ transactions",
                                    fontSize: 14,
                                    textColor: Theme.of(context)
                                        .colorScheme
                                        .black
                                        .withOpacity(0.65),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    index: index,
                    onDelete: () {
                      openPopup(
                        context,
                        title: "Delete " + category.name + " category?",
                        description:
                            "This will delete all transactions associated with this category.",
                        icon: Icons.delete_rounded,
                        onCancel: () {
                          Navigator.pop(context);
                        },
                        onCancelLabel: "Cancel",
                        onSubmit: () {
                          // database.deleteCategory(category.categoryPk);
                          // database.deleteTransactionWithCategory(category.categoryPk);
                          Navigator.pop(context);
                          openSnackbar(context, "Deleted " + category.name);
                        },
                        onSubmitLabel: "Delete",
                      );
                    },
                    openPage: AddCategoryPage(
                      title: "Edit Category",
                      category: category,
                    ),
                  );
                },
                itemCount: snapshot.data!.length,
                onReorder: (_intPrevious, _intNew) async {
                  TransactionCategory oldCategory =
                      snapshot.data![_intPrevious];

                  if (_intNew > _intPrevious) {
                    await database.moveCategory(
                        oldCategory.categoryPk, _intNew - 1, oldCategory.order);
                  } else {
                    await database.moveCategory(
                        oldCategory.categoryPk, _intNew, oldCategory.order);
                  }
                },
              );
            }
            return SliverToBoxAdapter(
              child: Container(),
            );
          },
        ),
      ],
    );
  }
}
