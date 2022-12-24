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
import 'package:budget/widgets/globalLoadingProgress.dart';
import 'package:budget/widgets/globalSnackBar.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:drift/drift.dart' hide Query, Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:budget/widgets/editRowEntry.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:budget/struct/firebaseAuthGlobal.dart';

Future<bool> shareCategory(
    TransactionCategory? categoryToShare, context) async {
  if (categoryToShare == null) {
    return false;
  }
  print("ONE TO SHARE");
  print(categoryToShare.categoryPk);
  // Share category information
  FirebaseFirestore? db = await firebaseGetDBInstance();
  if (db == null) {
    return false;
  }
  Map<String, dynamic> categoryEntry = {
    "dateShared": DateTime.now(),
    "colour": categoryToShare.colour,
    "iconName": categoryToShare.iconName,
    "name": categoryToShare.name,
    "members": [
      // FirebaseAuth.instance.currentUser!.email
    ],
    "income": categoryToShare.income,
    "owner": FirebaseAuth.instance.currentUser!.uid,
    "ownerEmail": FirebaseAuth.instance.currentUser!.email,
  };
  DocumentReference categoryCreatedOnCloud =
      await db.collection("categories").add(categoryEntry);

  // Share all transactions from this category
  List<Transaction> transactionsFromCategory =
      await database.getAllTransactionsFromCategory(categoryToShare.categoryPk);
  CollectionReference transactionSubCollection =
      categoryCreatedOnCloud.collection("transactions");
  WriteBatch batch = db.batch();
  loadingProgressKey.currentState!.setProgressPercentage(0);
  int totalLength = transactionsFromCategory.length;
  int currentIndex = 0;
  for (Transaction transactionFromCategory in transactionsFromCategory) {
    DocumentReference transactionSubCollectionDoc =
        transactionSubCollection.doc();
    batch.set(transactionSubCollectionDoc, {
      "logType": "create", // create, delete, update
      // delete entries will have "deleteSharedKey" of the latest sharedKey transaction
      "name": transactionFromCategory.name,
      "amount": transactionFromCategory.amount,
      "note": transactionFromCategory.note,
      "dateCreated": transactionFromCategory.dateCreated,
      "dateUpdated": DateTime.now(),
      "income": transactionFromCategory.income,
      "ownerEmail": FirebaseAuth.instance.currentUser!.email,
      "originalCreatorEmail": FirebaseAuth.instance.currentUser!.email,
    });
    await database.createOrUpdateTransaction(
      transactionFromCategory.copyWith(
        sharedKey: Value(transactionSubCollectionDoc.id),
        transactionOwnerEmail: Value(FirebaseAuth.instance.currentUser!.email),
      ),
      updateSharedEntry: false,
    );
    loadingProgressKey.currentState!
        .setProgressPercentage(currentIndex / totalLength);
    await Future.delayed(Duration(milliseconds: 1));
    currentIndex++;
  }
  batch.commit();

  await database.createOrUpdateCategory(
    categoryToShare.copyWith(
      sharedKey: Value(categoryCreatedOnCloud.id),
      sharedOwnerMember: Value(CategoryOwnerMember.owner),
    ),
    updateSharedEntry: false,
  );

  openSnackbar(SnackbarMessage(title: "Shared Category"));
  loadingProgressKey.currentState!.setProgressPercentage(0);
  return true;
}

Future<bool> removedSharedFromCategory(
    TransactionCategory? sharedCategory) async {
  if (sharedCategory == null) {
    return false;
  }
  try {
    FirebaseFirestore? db = await firebaseGetDBInstance();
    if (db == null) {
      return false;
    }
    DocumentReference collectionRef =
        db!.collection('categories').doc(sharedCategory!.sharedKey);
    CollectionReference transactionSubCollection = db
        .collection('categories')
        .doc(sharedCategory.sharedKey)
        .collection("transactions");

    WriteBatch batch = db.batch();
    final QuerySnapshot transactionsOnCloud =
        await transactionSubCollection.get();
    print(transactionsOnCloud);
    for (DocumentSnapshot transaction in transactionsOnCloud.docs) {
      print(transaction);
      DocumentReference transactionSubCollectionDoc =
          transactionSubCollection.doc(transaction.id);
      batch.delete(transactionSubCollectionDoc);
    }
    batch.commit();
    await collectionRef.delete();
  } catch (e) {
    print(e.toString());
  }

  List<Transaction> transactionsFromCategory =
      await database.getAllTransactionsFromCategory(sharedCategory.categoryPk);
  for (Transaction transactionFromCategory in transactionsFromCategory) {
    await database.createOrUpdateTransaction(
      transactionFromCategory.copyWith(
        sharedKey: Value(null),
        transactionOwnerEmail: Value(null),
      ),
      updateSharedEntry: false,
    );
  }
  await database.createOrUpdateCategory(
    sharedCategory.copyWith(
      sharedDateUpdated: Value(null),
      sharedKey: Value(null),
      sharedOwnerMember: Value(null),
    ),
    updateSharedEntry: false,
  );
  return true;
}

Future<bool> getCloudCategories() async {
  FirebaseFirestore? db = await firebaseGetDBInstance();
  if (db == null) {
    return false;
  }

  // aggregate categories users are members of and owners of together
  final categoryMembersOf = db!.collection('categories').where('members',
      arrayContains: FirebaseAuth.instance.currentUser!.email);
  final QuerySnapshot snapshotCategoryMembersOf = await categoryMembersOf.get();
  List<DocumentSnapshot> snapshotsMembers = [];
  for (DocumentSnapshot category in snapshotCategoryMembersOf.docs) {
    snapshotsMembers.add(category);
    print("YOU ARE A MEMBER OF THIS CATEGORY " + category.data().toString());
  }
  downloadTransactionsFromCategories(db, snapshotsMembers);

  final Query categoryOwned = db
      .collection('categories')
      .where('owner', isEqualTo: FirebaseAuth.instance.currentUser!.uid);
  final QuerySnapshot snapshotOwned = await categoryOwned.get();
  List<DocumentSnapshot> snapshotsOwners = [];
  for (DocumentSnapshot category in snapshotOwned.docs) {
    snapshotsOwners.add(category);
    print("YOU OWN THIS CATEGORY " + category.data().toString());
  }
  downloadTransactionsFromCategories(db, snapshotsOwners);

  return true;
}

Future<bool> downloadTransactionsFromCategories(
    FirebaseFirestore db, List<DocumentSnapshot> snapshots) async {
  for (DocumentSnapshot category in snapshots) {
    Map<dynamic, dynamic> categoryDecoded = category.data() as Map;
    await database.createOrUpdateFromSharedCategory(
      TransactionCategory(
        categoryPk: DateTime.now().millisecondsSinceEpoch,
        name: categoryDecoded["name"],
        dateCreated: DateTime.now(),
        order: 0,
        income: categoryDecoded["income"],
        sharedKey: category.id,
        iconName: categoryDecoded["iconName"],
        colour: categoryDecoded["colour"],
        sharedOwnerMember: FirebaseAuth.instance.currentUser!.email ==
                categoryDecoded["ownerEmail"]
            ? CategoryOwnerMember.owner
            : CategoryOwnerMember.member,
      ),
    );

    // Get transactions from the server
    TransactionCategory sharedCategory =
        await database.getSharedCategory(category.id);
    Query transactionsFromServer;
    if (sharedCategory.sharedDateUpdated == null) {
      transactionsFromServer = db
          .collection('categories')
          .doc(category.id)
          .collection('transactions');
    } else {
      transactionsFromServer = db
          .collection('categories')
          .doc(category.id)
          .collection('transactions')
          .where(FieldPath.fromString("dateUpdated"),
              isGreaterThan: sharedCategory.sharedDateUpdated);
    }
    final QuerySnapshot snapshotTransactionsFromServer =
        await transactionsFromServer.get();
    for (DocumentSnapshot transaction in snapshotTransactionsFromServer.docs) {
      Map<dynamic, dynamic> transactionDecoded = transaction.data() as Map;
      if (transaction["logType"] == "create" ||
          transaction["logType"] == "update") {
        await database.createOrUpdateFromSharedTransaction(
          Transaction(
            transactionPk: DateTime.now().millisecondsSinceEpoch,
            name: transactionDecoded["name"],
            amount: transactionDecoded["amount"].toDouble(),
            note: transactionDecoded["note"],
            categoryFk: sharedCategory.categoryPk,
            // TODO should be sharedCategory.walletFk
            walletFk: 0,
            dateCreated: transactionDecoded["dateCreated"].toDate(),
            income: transactionDecoded["income"],
            paid: true,
            skipPaid: false,
            sharedKey: transaction.id,
            transactionOwnerEmail: transactionDecoded["ownerEmail"],
            methodAdded: MethodAdded.shared,
          ),
        );
      } else if (transaction["logType"] == "delete") {
        await database
            .deleteFromSharedTransaction(transactionDecoded["deleteSharedKey"]);
      }

      print(transaction.id);
      print(transaction.data().toString());
    }
    await database.createOrUpdateFromSharedCategory(
        sharedCategory.copyWith(sharedDateUpdated: Value(DateTime.now())));

    print("DOWNLOADED FROM THIS CATEGORY " + category.data().toString());
  }

  return true;
}

Future<bool> addMemberToCategory(String sharedKey, String member) async {
  FirebaseFirestore? db = await firebaseGetDBInstance();
  if (db == null) {
    return false;
  }
  DocumentReference categoryCreatedOnCloud =
      db.collection('categories').doc(sharedKey);
  categoryCreatedOnCloud.update({
    "members": FieldValue.arrayUnion([member])
  });
  return true;
}

Future<bool> removeMemberFromCategory(String sharedKey, String member) async {
  FirebaseFirestore? db = await firebaseGetDBInstance();
  if (db == null) {
    return false;
  }
  DocumentReference categoryCreatedOnCloud =
      db.collection('categories').doc(sharedKey);
  categoryCreatedOnCloud.update({
    "members": FieldValue.arrayRemove([member])
  });
  return true;
}

Future<dynamic> getMembersFromCategory(String sharedKey) async {
  FirebaseFirestore? db = await firebaseGetDBInstance();
  if (db == null) {
    return null;
  }
  DocumentReference categoryCreatedOnCloud =
      db.collection('categories').doc(sharedKey);
  Map<dynamic, dynamic> categoryDecoded =
      (await categoryCreatedOnCloud.get()).data() as Map;
  print(categoryDecoded["members"]);
  return categoryDecoded["members"];
}

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
                    getCloudCategories();
                  },
                  icon: Icon(Icons.refresh_rounded),
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
                        Stack(
                          children: [
                            CategoryIcon(
                              categoryPk: category.categoryPk,
                              size: 40,
                              category: category,
                              canEditByLongPress: false,
                            ),
                            category.sharedKey != null
                                ? Positioned(
                                    top: 4,
                                    left: 0,
                                    child: Icon(
                                      Icons.people_alt_rounded,
                                      size: 18,
                                    ),
                                  )
                                : SizedBox.shrink()
                          ],
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
