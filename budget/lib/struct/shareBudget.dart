import 'dart:async';

import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/globalSnackBar.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry/swipeToSelectTransactions.dart';
import 'package:drift/drift.dart' hide Query, Column;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:budget/struct/firebaseAuthGlobal.dart';
import 'package:flutter/services.dart';
import 'package:timer_builder/timer_builder.dart';
import 'package:budget/widgets/pullDownToRefreshSync.dart';

Future<bool> shareBudget(Budget? budgetToShare, context) async {
  if (appStateSettings["sharedBudgets"] == false) return false;
  if (budgetToShare == null) {
    return false;
  }
  print(budgetToShare.budgetPk);
  // Share budget information
  FirebaseFirestore? db = await firebaseGetDBInstance();
  if (db == null) {
    return false;
  }
  print(budgetToShare.reoccurrence);
  print(enumRecurrence[budgetToShare.reoccurrence]);
  Map<String, dynamic> budgetEntry = {
    "name": budgetToShare.name,
    "amount": budgetToShare.amount,
    "colour": budgetToShare.colour,
    "startDate": budgetToShare.startDate,
    "endDate": budgetToShare.endDate,
    "periodLength": budgetToShare.periodLength,
    "reoccurrence": enumRecurrence[budgetToShare.reoccurrence],
    "members": [
      // FirebaseAuth.instance.currentUser!.email
    ],
    "dateShared": DateTime.now(),
    "owner": FirebaseAuth.instance.currentUser!.uid,
    "ownerEmail": FirebaseAuth.instance.currentUser!.email,
    "dateUpdated": DateTime.now(),
  };

  DocumentReference budgetCreatedOnCloud =
      await db.collection("budgets").add(budgetEntry);

  await database.createOrUpdateBudget(
    budgetToShare.copyWith(
      sharedKey: Value(budgetCreatedOnCloud.id),
      sharedOwnerMember: Value(SharedOwnerMember.owner),
      sharedDateUpdated: Value(DateTime.now()),
      sharedMembers: Value([FirebaseAuth.instance.currentUser!.email!]),
      categoryFks: Value(null),
      budgetTransactionFilters: Value(null),
      memberTransactionFilters: Value(null),
    ),
    updateSharedEntry: false,
  );

  openSnackbar(SnackbarMessage(title: "Shared Budget"));
  loadingProgressKey.currentState!.setProgressPercentage(0);
  return true;
}

Future<bool> removedSharedFromBudget(Budget sharedBudget,
    {bool removeFromServer = true}) async {
  if (appStateSettings["sharedBudgets"] == false) return false;
  if (removeFromServer)
    try {
      FirebaseFirestore? db = await firebaseGetDBInstance();
      if (db == null) {
        return false;
      }
      DocumentReference collectionRef =
          db.collection('budgets').doc(sharedBudget.sharedKey);
      CollectionReference transactionSubCollection = db
          .collection('budgets')
          .doc(sharedBudget.sharedKey)
          .collection("transactions");

      WriteBatch batch = db.batch();
      final QuerySnapshot transactionsOnCloud =
          await transactionSubCollection.get();
      // print(transactionsOnCloud);
      for (DocumentSnapshot transaction in transactionsOnCloud.docs) {
        print(transaction);
        DocumentReference transactionSubCollectionDoc =
            transactionSubCollection.doc(transaction.id);
        batch.delete(transactionSubCollectionDoc);
      }
      await batch.commit();
      await collectionRef.delete();
    } catch (e) {
      print(e.toString());
    }

  List<Transaction> transactionsFromBudget = await database
      .getAllTransactionsBelongingToSharedBudget(sharedBudget.budgetPk);
  List<Transaction> allTransactionsToUpdate = [];
  for (Transaction transactionFromBudget in transactionsFromBudget) {
    allTransactionsToUpdate.add(transactionFromBudget.copyWith(
      sharedKey: Value(null),
      sharedDateUpdated: Value(null),
      sharedStatus: Value(null),
    ));
  }
  await database.updateBatchTransactionsOnly(allTransactionsToUpdate);
  await database.createOrUpdateBudget(
    sharedBudget.copyWith(
      sharedDateUpdated: Value(null),
      sharedKey: Value(null),
      sharedOwnerMember: Value(null),
      sharedMembers: Value(null),
      budgetTransactionFilters: Value(null),
      memberTransactionFilters: Value(null),
    ),
    updateSharedEntry: false,
  );
  return true;
}

Future<bool> leaveSharedBudget(Budget sharedBudget) async {
  if (appStateSettings["sharedBudgets"] == false) return false;
  FirebaseFirestore? db = await firebaseGetDBInstance();
  if (db == null) {
    return false;
  }
  removeMemberFromBudget(sharedBudget.sharedKey!,
      FirebaseAuth.instance.currentUser!.email!, sharedBudget);
  removedSharedFromBudget(sharedBudget, removeFromServer: false);
  return true;
}

Future<bool> addMemberToBudget(
    String sharedKey, String member, Budget budget) async {
  FirebaseFirestore? db = await firebaseGetDBInstance();
  if (db == null) {
    return false;
  }
  DocumentReference budgetCreatedOnCloud =
      db.collection('budgets').doc(sharedKey);
  budgetCreatedOnCloud.update({
    "members": FieldValue.arrayUnion([member]),
    "dateUpdated": DateTime.now(),
  });
  Budget budgetFromDB = await database.getBudgetInstance(budget.budgetPk);
  List<String> memberList = budgetFromDB.sharedMembers ?? [];
  memberList.add(member);
  Set<String> allMembersEver =
      (budgetFromDB.sharedAllMembersEver ?? []).toSet();
  allMembersEver.add(member);
  await database.createOrUpdateBudget(
    budgetFromDB.copyWith(
      sharedMembers: Value(memberList),
      sharedAllMembersEver: Value(
        allMembersEver.toList(),
      ),
    ),
    updateSharedEntry: false,
  );
  return true;
}

Future<bool> removeMemberFromBudget(
    String sharedKey, String member, Budget budget) async {
  if (appStateSettings["sharedBudgets"] == false) return false;
  FirebaseFirestore? db = await firebaseGetDBInstance();
  if (db == null) {
    return false;
  }
  DocumentReference budgetCreatedOnCloud =
      db.collection('budgets').doc(sharedKey);
  budgetCreatedOnCloud.update({
    "members": FieldValue.arrayRemove([member]),
    "dateUpdated": DateTime.now(),
  });
  Budget budgetFromDB = await database.getBudgetInstance(budget.budgetPk);
  List<String> memberList = budgetFromDB.sharedMembers ?? [];
  memberList.remove(member);
  await database.createOrUpdateBudget(
    budgetFromDB.copyWith(
      sharedMembers: Value(memberList),
    ),
    updateSharedEntry: false,
  );
  return true;
}

// the owner is always the first entry!
Future<dynamic> getMembersFromBudget(String sharedKey, Budget budget) async {
  if (appStateSettings["sharedBudgets"] == false) return false;
  FirebaseFirestore? db = await firebaseGetDBInstance();
  if (db == null) {
    return null;
  }
  DocumentReference budgetCreatedOnCloud =
      db.collection('budgets').doc(sharedKey);
  Map<dynamic, dynamic> budgetDecoded =
      (await budgetCreatedOnCloud.get()).data() as Map;
  print([
    budgetDecoded["ownerEmail"].toString(),
    ...List<String>.from(budgetDecoded["members"])
  ]);
  List<String> memberList = [
    budgetDecoded["ownerEmail"].toString(),
    ...List<String>.from(budgetDecoded["members"])
  ];
  await database.createOrUpdateBudget(
    budget.copyWith(sharedMembers: Value(memberList)),
    updateSharedEntry: false,
  );
  return memberList;
}

Future<bool> compareSharedToCurrentBudgets(
    List<QueryDocumentSnapshot<Object?>> budgetSnapshot) async {
  if (appStateSettings["sharedBudgets"] == false) return false;
  List<Budget> budgets = await database.getAllBudgets();
  for (Budget budget in budgets) {
    if (budget.sharedKey != null) {
      bool found = false;
      for (DocumentSnapshot budgetCloud in budgetSnapshot) {
        if (budgetCloud.id == budget.sharedKey) {
          print("Found a matching budget!");
          found = true;
          break;
        }
      }
      if (found == false) {
        openSnackbar(SnackbarMessage(
            icon: appStateSettings["outlinedIcons"]
                ? Icons.remove_circle_outline_outlined
                : Icons.remove_circle_outline_rounded,
            title: budget.name,
            description: "Is no longer shared with you"));
        print("You have lost permission to this budget: " + budget.name);
        removedSharedFromBudget(budget);
      }
    }
  }
  for (DocumentSnapshot budgetCloud in budgetSnapshot) {
    bool found = false;
    for (Budget budget in budgets) {
      if (budget.sharedKey != null && budgetCloud.id == budget.sharedKey) {
        found = true;
        break;
      }
    }
    if (found == false) {
      Map<dynamic, dynamic> budgetDecoded = budgetCloud.data() as Map;
      openSnackbar(SnackbarMessage(
        title: budgetCloud["name"] + " was shared with you",
        description: "From " + getMemberNickname(budgetDecoded["ownerEmail"]),
        icon: appStateSettings["outlinedIcons"]
            ? Icons.share_outlined
            : Icons.share_rounded,
      ));
    }
  }
  return true;
}

Timer? cloudTimeoutTimer;
Future<bool> getCloudBudgets() async {
  if (appStateSettings["sharedBudgets"] == false) return false;
  if (appStateSettings["hasSignedIn"] == false) return false;
  if (errorSigningInDuringCloud == true) return false;
  if (kIsWeb && !entireAppLoaded) return false;
  FirebaseFirestore? db = await firebaseGetDBInstance();
  if (cloudTimeoutTimer?.isActive == true) {
    // openSnackbar(SnackbarMessage(title: "Please wait..."));
    return false;
  } else {
    cloudTimeoutTimer = Timer(Duration(milliseconds: 5000), () {
      cloudTimeoutTimer!.cancel();
    });
  }
  if (db == null) {
    return false;
  }

  final budgetMembersOf = db.collection('budgets').where('members',
      arrayContains: FirebaseAuth.instance.currentUser!.email);
  final QuerySnapshot snapshotBudgetMembersOf = await budgetMembersOf.get();
  // for (DocumentSnapshot budget in snapshotBudgetMembersOf.docs) {
  //   print("YOU ARE A MEMBER OF THIS BUDGET " + budget.data().toString());
  // }
  final Query budgetOwned = db
      .collection('budgets')
      .where('owner', isEqualTo: FirebaseAuth.instance.currentUser!.uid);
  final QuerySnapshot snapshotOwned = await budgetOwned.get();
  // for (DocumentSnapshot budget in snapshotOwned.docs) {
  //   print("YOU OWN THIS BUDGET " + budget.data().toString());
  // }
  await compareSharedToCurrentBudgets(
      [...snapshotBudgetMembersOf.docs, ...snapshotOwned.docs]);

  int totalTransactionsUpdated = 0;
  totalTransactionsUpdated = totalTransactionsUpdated +
      await downloadTransactionsFromBudgets(db, snapshotBudgetMembersOf.docs);
  totalTransactionsUpdated = totalTransactionsUpdated +
      await downloadTransactionsFromBudgets(db, snapshotOwned.docs);
  int amountSynced =
      snapshotBudgetMembersOf.docs.length + snapshotOwned.docs.length;
  if (amountSynced > 0 && totalTransactionsUpdated > 0)
    openSnackbar(
      SnackbarMessage(
        icon: appStateSettings["outlinedIcons"]
            ? Icons.cloud_sync_outlined
            : Icons.cloud_sync_rounded,
        title: "synced".tr() +
            " " +
            totalTransactionsUpdated.toString() +
            " " +
            pluralString(totalTransactionsUpdated == 1, "change"),
        description: "From " +
            amountSynced.toString() +
            " shared " +
            pluralString(amountSynced == 1, "budget"),
      ),
    );
  // else if (amountSynced > 0 && totalTransactionsUpdated == 0) {
  //   openSnackbar(SnackbarMessage(
  //     title: "No updates",
  //   ));
  // }
  return true;
}

Future<int> downloadTransactionsFromBudgets(
    FirebaseFirestore db, List<DocumentSnapshot> snapshots) async {
  if (appStateSettings["sharedBudgets"] == false) return 0;
  int totalUpdated = 0;
  for (DocumentSnapshot budget in snapshots) {
    Set<String> allMembersEver = {};
    Map<dynamic, dynamic> budgetDecoded = budget.data() as Map;
    await database.createOrUpdateFromSharedBudget(
      insert: true,
      Budget(
        budgetPk: "-1",
        name: budgetDecoded["name"],
        amount: budgetDecoded["amount"].toDouble(),
        colour: budgetDecoded["colour"],
        startDate: budgetDecoded["startDate"].toDate(),
        endDate: budgetDecoded["endDate"].toDate(),
        categoryFks: null,
        addedTransactionsOnly: true,
        periodLength: budgetDecoded["periodLength"],
        reoccurrence: mapRecurrence(budgetDecoded["reoccurrence"]),
        dateCreated: DateTime.now(),
        dateTimeModified: null,
        pinned: true,
        order: 0,
        walletFk: "0",
        sharedKey: budget.id,
        sharedOwnerMember: FirebaseAuth.instance.currentUser!.email ==
                budgetDecoded["ownerEmail"]
            ? SharedOwnerMember.owner
            : SharedOwnerMember.member,
        sharedMembers: [
          budgetDecoded["ownerEmail"],
          ...List<String>.from(budgetDecoded["members"]),
        ],
        budgetTransactionFilters: [],
        memberTransactionFilters: null,
        isAbsoluteSpendingLimit: false,
        income: false,
      ),
    );

    // Get transactions from the server
    Budget sharedBudget = await database.getSharedBudget(budget.id);
    Query transactionsFromServer;
    if (sharedBudget.sharedDateUpdated == null) {
      print("Download all transactions");
      transactionsFromServer =
          db.collection('budgets').doc(budget.id).collection('transactions');
    } else {
      print(sharedBudget.sharedDateUpdated);
      transactionsFromServer = db
          .collection('budgets')
          .doc(budget.id)
          .collection('transactions')
          .where(FieldPath.fromString("dateUpdated"),
              isGreaterThan: sharedBudget.sharedDateUpdated);
    }
    final QuerySnapshot snapshotTransactionsFromServer =
        await transactionsFromServer.get();
    totalUpdated = totalUpdated + snapshotTransactionsFromServer.docs.length;
    for (DocumentSnapshot transaction in snapshotTransactionsFromServer.docs) {
      Map<dynamic, dynamic> transactionDecoded = transaction.data() as Map;
      if (transaction["logType"] == "create" ||
          transaction["logType"] == "update") {
        TransactionCategory selectedCategory;
        try {
          selectedCategory = await database
              .getCategoryInstanceGivenName(transactionDecoded["categoryName"]);
        } catch (_) {
          int numberOfCategories =
              (await database.getTotalCountOfCategories())[0] ?? 0;
          await database.createOrUpdateCategory(
            insert: true,
            TransactionCategory(
              categoryPk: "-1",
              name: transactionDecoded["categoryName"],
              dateCreated: DateTime.now(),
              dateTimeModified: null,
              order: numberOfCategories,
              income: false,
              iconName: transactionDecoded["categoryIcon"],
              colour: transactionDecoded["categoryColour"],
              methodAdded: MethodAdded.shared,
            ),
          );
          selectedCategory = await database
              .getCategoryInstanceGivenName(transactionDecoded["categoryName"]);
        }

        await database.createOrUpdateFromSharedTransaction(
          insert: true,
          Transaction(
            transactionPk: "-1",
            name: transactionDecoded["name"],
            amount: transactionDecoded["amount"].toDouble(),
            note: transactionDecoded["note"],
            categoryFk: selectedCategory.categoryPk,
            walletFk: "0",
            dateCreated: transactionDecoded["dateTimeCreated"].toDate(),
            dateTimeModified: null,
            income: transactionDecoded["income"],
            paid: true,
            skipPaid: false,
            sharedKey: transaction.id,
            sharedOldKey: transaction.id,
            transactionOwnerEmail: transactionDecoded["ownerEmail"],
            transactionOriginalOwnerEmail:
                transactionDecoded["originalCreatorEmail"],
            methodAdded: MethodAdded.shared,
            sharedDateUpdated: DateTime.now(),
            sharedStatus: SharedStatus.shared,
            sharedReferenceBudgetPk: sharedBudget.budgetPk,
          ),
        );
        if (transactionDecoded["ownerEmail"] != null)
          allMembersEver.add(transactionDecoded["ownerEmail"]);
        if (transactionDecoded["name"] != null &&
            transactionDecoded["name"] != "")
          await addAssociatedTitles(
              transactionDecoded["name"], selectedCategory);
      } else if (transaction["logType"] == "delete") {
        print("DELETING");
        try {
          await database.deleteFromSharedTransaction(
              transactionDecoded["deleteSharedKey"]);
        } catch (e) {
          print("This shared transaction already deleted" + e.toString());
        }
      }

      print(transaction.id);
      print(transaction.data().toString());
    }
    Budget budgetAlreadyStored = (await database.getSharedBudget(budget.id));
    allMembersEver.addAll((budgetAlreadyStored.sharedMembers ?? []).toSet());
    allMembersEver
        .addAll((budgetAlreadyStored.sharedAllMembersEver ?? []).toSet());
    await database.createOrUpdateFromSharedBudget(sharedBudget.copyWith(
        sharedDateUpdated: Value(DateTime.now()),
        sharedAllMembersEver: Value(allMembersEver.toList())));

    print("DOWNLOADED FROM THIS BUDGET " + budget.data().toString());
  }

  return totalUpdated;
}

Future<bool> sendTransactionSet(Transaction transaction, Budget budget) async {
  if (appStateSettings["sharedBudgets"] == false) return false;
  print("SETTING UP TRANSACTION TO BE SET: " + transaction.toString());
  FirebaseFirestore? db = await firebaseGetDBInstance();
  if (db == null) {
    Map<dynamic, dynamic> currentSendTransactionsToServerQueue =
        appStateSettings["sendTransactionsToServerQueue"];
    currentSendTransactionsToServerQueue[transaction.transactionPk.toString()] =
        {
      "action": "sendTransactionSet",
      "transactionPk": transaction.transactionPk.toString(),
      "budgetPk": budget.budgetPk.toString(),
    };
    print(currentSendTransactionsToServerQueue);
    updateSettings(
      "sendTransactionsToServerQueue",
      currentSendTransactionsToServerQueue,
      pagesNeedingRefresh: [],
      updateGlobalState: false,
    );
    return false;
  }
  await setOnServer(db, transaction, budget);
  return true;
}

// update the entry on the server
Future<bool> setOnServer(
    FirebaseFirestore db, Transaction transaction, Budget budget) async {
  if (appStateSettings["sharedBudgets"] == false) return false;
  TransactionCategory transactionCategory =
      await database.getCategoryInstance(transaction.categoryFk);
  CollectionReference subCollectionRef =
      db.collection('budgets').doc(budget.sharedKey).collection("transactions");
  await subCollectionRef.doc(transaction.sharedKey).set({
    "logType": "update", // create, delete, update
    "name": transaction.name,
    "amount": transaction.amount,
    "note": transaction.note,
    "dateTimeCreated": transaction.dateCreated,
    "dateUpdated": DateTime.now(),
    "income": transaction.income,
    "ownerEmail": transaction.transactionOwnerEmail, //ownerEmail is the payer
    "categoryName": transactionCategory.name,
    "categoryIcon": transactionCategory.iconName, //emoji icons not supported
    "categoryColour": transactionCategory.colour,
  }, SetOptions(merge: true));
  transaction = transaction.copyWith(
    sharedStatus: Value(SharedStatus.shared),
    sharedDateUpdated: Value(DateTime.now()),
    sharedOldKey: Value(transaction.sharedKey),
  );
  print("Transaction updated on server: " + transaction.toString());
  await database.createOrUpdateTransaction(transaction,
      updateSharedEntry: false);
  return true;
}

Future<bool> sendTransactionAdd(Transaction transaction, Budget budget) async {
  if (appStateSettings["sharedBudgets"] == false) return false;
  FirebaseFirestore? db = await firebaseGetDBInstance();
  if (db == null) {
    Map<dynamic, dynamic> currentSendTransactionsToServerQueue =
        appStateSettings["sendTransactionsToServerQueue"];
    currentSendTransactionsToServerQueue[transaction.transactionPk.toString()] =
        {
      "action": "sendTransactionAdd",
      "transactionPk": transaction.transactionPk.toString(),
      "budgetPk": budget.budgetPk.toString(),
    };
    updateSettings(
      "sendTransactionsToServerQueue",
      currentSendTransactionsToServerQueue,
      pagesNeedingRefresh: [],
      updateGlobalState: false,
    );
    print(currentSendTransactionsToServerQueue);
    return false;
  }
  await addOnServer(db, transaction, budget);
  return true;
}

Future<bool> addOnServer(
    FirebaseFirestore db, Transaction transaction, Budget budget) async {
  if (appStateSettings["sharedBudgets"] == false) return false;
  TransactionCategory transactionCategory =
      await database.getCategoryInstance(transaction.categoryFk);
  CollectionReference subCollectionRef =
      db.collection('budgets').doc(budget.sharedKey).collection("transactions");
  DocumentReference addedDocument = await subCollectionRef.add({
    "logType": "create", // create, delete, update
    "name": transaction.name,
    "amount": transaction.amount,
    "note": transaction.note,
    "dateTimeCreated": transaction.dateCreated,
    "dateUpdated": DateTime.now(),
    "income": transaction.income,
    "ownerEmail": transaction.transactionOwnerEmail, //ownerEmail is the payer
    "originalCreatorEmail": FirebaseAuth.instance.currentUser!.email,
    "categoryName": transactionCategory.name,
    "categoryIcon": transactionCategory.iconName, //emoji icons not supported
    "categoryColour": transactionCategory.colour,
  });
  transaction = transaction.copyWith(
    sharedKey: Value(addedDocument.id),
    sharedOldKey: Value(addedDocument.id),
    transactionOwnerEmail: Value(transaction.transactionOwnerEmail),
    transactionOriginalOwnerEmail:
        Value(FirebaseAuth.instance.currentUser!.email),
    sharedStatus: Value(SharedStatus.shared),
    sharedDateUpdated: Value(DateTime.now()),
  );
  await database.createOrUpdateTransaction(transaction,
      updateSharedEntry: false);
  return true;
}

Future<bool> sendTransactionDelete(
    Transaction transaction, Budget budget) async {
  if (appStateSettings["sharedBudgets"] == false) return false;
  FirebaseFirestore? db = await firebaseGetDBInstance();
  if (db == null) {
    Map<dynamic, dynamic> currentSendTransactionsToServerQueue =
        appStateSettings["sendTransactionsToServerQueue"];
    currentSendTransactionsToServerQueue[transaction.transactionPk.toString()] =
        {
      "action": "sendTransactionDelete",
      "transactionSharedKey": transaction.sharedKey.toString(),
      "budgetPk": budget.budgetPk.toString(),
    };
    print(currentSendTransactionsToServerQueue);
    updateSettings(
      "sendTransactionsToServerQueue",
      currentSendTransactionsToServerQueue,
      pagesNeedingRefresh: [],
      updateGlobalState: false,
    );
    return false;
  }
  await deleteOnServer(db, transaction.sharedKey, budget);
  return true;
}

Future<bool> deleteOnServer(
    FirebaseFirestore db, String? transactionSharedKey, Budget budget) async {
  if (appStateSettings["sharedBudgets"] == false) return false;
  if (transactionSharedKey != null && transactionSharedKey != "null") {
    CollectionReference subCollectionRef = db
        .collection('budgets')
        .doc(budget.sharedKey)
        .collection("transactions");
    subCollectionRef.add({
      "logType": "delete", // create, delete, update
      "deleteSharedKey": transactionSharedKey,
      "dateUpdated": DateTime.now(),
    });
    subCollectionRef.doc(transactionSharedKey).delete();
  }
  return true;
}

Future<bool> syncPendingQueueOnServer() async {
  if (appStateSettings["sharedBudgets"] == false) return false;
  if (appStateSettings["hasSignedIn"] == false) return false;
  if (errorSigningInDuringCloud == true) return false;
  if (kIsWeb && !entireAppLoaded) return false;
  print("syncing pending queue");
  Map<dynamic, dynamic> currentSendTransactionsToServerQueue =
      appStateSettings["sendTransactionsToServerQueue"];
  for (String key in currentSendTransactionsToServerQueue.keys) {
    FirebaseFirestore? db = await firebaseGetDBInstance();
    if (db == null) {
      return false;
    }
    try {
      print("CURRENT:");
      print(currentSendTransactionsToServerQueue[key]);

      Budget budget;
      try {
        budget = await database.getBudgetInstance(
            currentSendTransactionsToServerQueue[key]["budgetPk"].toString());
      } catch (e) {
        print(e.toString());
        // budget was probably deleted, we don't need to sync anything...
        continue;
      }

      if (currentSendTransactionsToServerQueue[key]["action"] ==
          "sendTransactionDelete") {
        await deleteOnServer(
            db,
            currentSendTransactionsToServerQueue[key]["transactionSharedKey"],
            budget);
      }

      Transaction transaction = await database.getTransactionFromPk(
          currentSendTransactionsToServerQueue[key]["transactionPk"]
              .toString());
      print("UPLOADING THIS TRANSACTION");
      print(transaction);
      if (currentSendTransactionsToServerQueue[key]["action"] ==
          "sendTransactionSet") {
        await setOnServer(db, transaction, budget);
      } else if (currentSendTransactionsToServerQueue[key]["action"] ==
          "sendTransactionAdd") {
        await addOnServer(db, transaction, budget);
      }
    } catch (e) {
      print(e.toString());
      print("skipping syncing this transaction...");
    }
  }
  updateSettings("sendTransactionsToServerQueue", {},
      pagesNeedingRefresh: [], updateGlobalState: false);
  return true;
}

Future<bool> updateTransactionOnServerAfterChangingCategoryInformation(
    TransactionCategory category) async {
  if (appStateSettings["sharedBudgets"] == false) return false;
  loadingIndeterminateKey.currentState?.setVisibility(true);
  List<Transaction> sharedTransactionsInCategory =
      await database.getAllTransactionsSharedInCategory(category.categoryPk);

  List<Future> asyncCalls = [];
  for (Transaction transaction in sharedTransactionsInCategory) {
    // update all shared transactions one by one, need to update the server
    if (transaction.sharedReferenceBudgetPk != null) {
      Budget budget = await database
          .getBudgetInstance(transaction.sharedReferenceBudgetPk!);
      asyncCalls.add(sendTransactionSet(transaction, budget));
    }
  }
  await Future.wait(asyncCalls);
  loadingIndeterminateKey.currentState?.setVisibility(false);
  return true;
}
