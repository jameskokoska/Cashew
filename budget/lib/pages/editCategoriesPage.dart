import 'dart:convert';
import 'dart:developer';

import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/categoryIcon.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/globalSnackBar.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:budget/widgets/editRowEntry.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:budget/struct/firebaseAuthGlobal.dart';

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
      floatingActionButton: AnimateFABDelayed(
        fab: Padding(
          padding: EdgeInsets.only(bottom: bottomPaddingSafeArea),
          child: FAB(
            tooltip: "Add Category",
            openPage: AddCategoryPage(
              title: "Add Category",
            ),
          ),
        ),
      ),
      slivers: [
        SliverToBoxAdapter(
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.only(top: 12.5, right: 5),
                child: IconButton(
                  onPressed: () async {
                    FirebaseFirestore? db = await firebaseGetDBInstance();

                    Map<String, dynamic> categoryEntry = {
                      "dateShared": DateTime.now(),
                      "colour": toHexString(Colors.red),
                      "icon": "icon.png",
                      "name": "Food",
                      "members": [
                        // FirebaseAuth.instance.currentUser!.email
                      ],
                      "income": false,
                      "owner": FirebaseAuth.instance.currentUser!.uid,
                      "ownerEmail": FirebaseAuth.instance.currentUser!.email,
                    };
                    DocumentReference category =
                        await db!.collection("categories").add(categoryEntry);

                    CollectionReference subCollectionRef =
                        category.collection("transactions");

                    subCollectionRef.add({
                      "logType": "create", // create, delete, update
                      "name": "",
                      "amount": 15.65,
                      "note": "This is a note of a transaction",
                      "dateCreated": DateTime.now(),
                      "dateUpdated": DateTime.now(),
                      "income": false,
                      "ownerEmail": FirebaseAuth.instance.currentUser!.email,
                      "originalCreatorEmail":
                          FirebaseAuth.instance.currentUser!.email,
                    });

                    category.update({
                      "members": FieldValue.arrayUnion(["hello@hello.com"])
                    });
                  },
                  icon: Icon(Icons.share_rounded),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 12.5, right: 5),
                child: IconButton(
                  onPressed: () async {
                    FirebaseFirestore? db = await firebaseGetDBInstance();

                    print(await FirebaseAuth.instance.currentUser!.uid);
                    final Query categoryMembersOf = db!
                        .collection('categories')
                        .where('members',
                            arrayContains:
                                FirebaseAuth.instance.currentUser!.email);
                    final QuerySnapshot snapshot =
                        await categoryMembersOf.get();
                    for (DocumentSnapshot category in snapshot.docs) {
                      print("YOU ARE A MEMBER OF THIS CATEGORY " +
                          category.data().toString());
                    }

                    print(FirebaseAuth.instance.currentUser!.uid);
                    final Query categoryOwned = db
                        .collection('categories')
                        .where('owner',
                            isEqualTo: FirebaseAuth.instance.currentUser!.uid);
                    final QuerySnapshot snapshotOwned =
                        await categoryOwned.get();
                    for (DocumentSnapshot category in snapshotOwned.docs) {
                      print("YOU OWN THIS CATEGORY " +
                          category.data().toString());

                      // get transactions before certain time
                      final Query transactionsBefore = db
                          .collection('categories')
                          .doc(category.id)
                          .collection('transactions')
                          .where(FieldPath.fromString("dateUpdated"),
                              isGreaterThan:
                                  DateTime.now().subtract(Duration(days: 1)));
                      final QuerySnapshot snapshot2 =
                          await transactionsBefore.get();
                      for (DocumentSnapshot transaction in snapshot2.docs) {
                        print(transaction.id);
                        print(transaction.data().toString());
                      }
                    }
                  },
                  icon: Icon(Icons.dock),
                ),
              )
            ],
          ),
        ),
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
                          defaultColor: Theme.of(context).colorScheme.primary),
                      amountLight: 0.55,
                      amountDark: 0.35);
                  return EditRowEntry(
                    canReorder: (snapshot.data ?? []).length != 1,
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
                          canEditByLongPress: false,
                        ),
                        Container(width: 5),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFont(
                              text: category.name,
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
                                    text: snapshot.data![0].toString() +
                                        pluralString(snapshot.data![0] == 1,
                                            " transaction"),
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
                          database.deleteCategory(
                              category.categoryPk, category.order);
                          database
                              .deleteCategoryTransactions(category.categoryPk);
                          Navigator.pop(context);
                          openSnackbar(
                            SnackbarMessage(
                                title: "Deleted " + category.name,
                                icon: Icons.delete),
                          );
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
