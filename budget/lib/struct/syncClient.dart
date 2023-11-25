import 'dart:async';
import 'dart:convert';

import 'package:budget/database/binary_string_conversion.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/main.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/accountAndBackup.dart';
import 'package:budget/widgets/globalSnackBar.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/util/debouncer.dart';
import 'package:budget/widgets/walletEntry.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:universal_html/html.dart' as html;
import 'dart:io';

bool isSyncBackupFile(String? backupFileName) {
  if (backupFileName == null) return false;
  return backupFileName.contains("sync-");
}

bool isCurrentDeviceSyncBackupFile(String? backupFileName) {
  if (backupFileName == null) return false;
  return backupFileName == getCurrentDeviceSyncBackupFileName();
}

String getCurrentDeviceSyncBackupFileName({String? clientIDForSync}) {
  if (clientIDForSync == null) clientIDForSync = clientID;
  return "sync-" + clientIDForSync + ".sqlite";
}

String getDeviceFromSyncBackupFileName(String? backupFileName) {
  if (backupFileName == null) return "";
  return (backupFileName).replaceAll("sync-", "").split("-")[0];
}

String getCurrentDeviceName() {
  return (clientID).split("-")[0];
}

Future<DateTime> getDateOfLastSyncedWithClient(String clientIDForSync) async {
  String string =
      sharedPreferences.getString("dateOfLastSyncedWithClient") ?? "{}";
  String lastTimeSynced =
      (jsonDecode(string)[clientIDForSync] ?? "").toString();
  if (lastTimeSynced == "") return DateTime(0);
  try {
    return DateTime.parse(lastTimeSynced);
  } catch (e) {
    print("Error getting time of last sync " + e.toString());
    return DateTime(0);
  }
}

Future<bool> setDateOfLastSyncedWithClient(
    String clientIDForSync, DateTime dateTimeSynced) async {
  String string =
      sharedPreferences.getString("dateOfLastSyncedWithClient") ?? "{}";
  dynamic parsed = jsonDecode(string);
  parsed[clientIDForSync] = dateTimeSynced.toString();
  await sharedPreferences.setString(
      "dateOfLastSyncedWithClient", jsonEncode(parsed));
  return true;
}

// if changeMadeSync show loading and check if syncEveryChange is turned on
Timer? syncTimeoutTimer;
Debouncer backupDebounce = Debouncer(milliseconds: 5000);
Future<bool> createSyncBackup(
    {bool changeMadeSync = false,
    bool changeMadeSyncWaitForDebounce = true}) async {
  if (appStateSettings["hasSignedIn"] == false) return false;
  if (errorSigningInDuringCloud == true) return false;
  if (appStateSettings["backupSync"] == false) return false;
  if (changeMadeSync == true && appStateSettings["syncEveryChange"] == false)
    return false;
  // create the auto syncs after 10 seconds of no changes
  if (changeMadeSync == true &&
      appStateSettings["syncEveryChange"] == true &&
      changeMadeSyncWaitForDebounce == true) {
    print("Running sync debouncer");
    backupDebounce.run(() {
      createSyncBackup(
          changeMadeSync: true, changeMadeSyncWaitForDebounce: false);
    });
  }

  print("Creating sync backup");
  if (changeMadeSync)
    loadingIndeterminateKey.currentState!.setVisibility(true, opacity: 0.4);
  if (syncTimeoutTimer?.isActive == true) {
    // openSnackbar(SnackbarMessage(title: "Please wait..."));
    if (changeMadeSync)
      loadingIndeterminateKey.currentState!.setVisibility(false);
    return false;
  } else {
    syncTimeoutTimer = Timer(Duration(milliseconds: 5000), () {
      syncTimeoutTimer!.cancel();
    });
  }

  bool hasSignedIn = false;
  if (googleUser == null) {
    hasSignedIn = await signInGoogle(
      gMailPermissions: false,
      waitForCompletion: false,
      silentSignIn: true,
    );
  } else {
    hasSignedIn = true;
  }
  if (hasSignedIn == false) {
    if (changeMadeSync)
      loadingIndeterminateKey.currentState!.setVisibility(false);
    return false;
  }

  final authHeaders = await googleUser!.authHeaders;
  final authenticateClient = GoogleAuthClient(authHeaders);
  drive.DriveApi driveApi = drive.DriveApi(authenticateClient);
  if (driveApi == null) {
    if (changeMadeSync)
      loadingIndeterminateKey.currentState!.setVisibility(false);
    throw "Failed to login to Google Drive";
  }

  drive.FileList fileList = await driveApi.files.list(
      spaces: 'appDataFolder', $fields: 'files(id, name, modifiedTime, size)');
  List<drive.File>? files = fileList.files;

  for (drive.File file in files ?? []) {
    if (isCurrentDeviceSyncBackupFile(file.name)) {
      try {
        await deleteBackup(driveApi, file.id ?? "");
      } catch (e) {
        print(e.toString());
      }
    }
  }
  await createBackup(null,
      silentBackup: true, deleteOldBackups: true, clientIDForSync: clientID);
  if (changeMadeSync)
    loadingIndeterminateKey.currentState!.setVisibility(false);
  return true;
}

class SyncLog {
  SyncLog({
    this.deleteLogType,
    this.updateLogType,
    required this.transactionDateTime,
    required this.pk,
    this.itemToUpdate,
  });

  DeleteLogType? deleteLogType;
  UpdateLogType? updateLogType;
  DateTime? transactionDateTime;
  String pk;
  dynamic itemToUpdate;

  @override
  String toString() {
    return "SyncLog(deleteLogType: $deleteLogType, updateLogType: $updateLogType, transactionDateTime: $transactionDateTime, pk: $pk, itemToUpdate: $itemToUpdate)";
  }
}

// Only allow one sync at a time
bool canSyncData = true;

// load the latest backup and import any newly modified data into the db
Future<bool> syncData(BuildContext context) async {
  if (canSyncData == false) return false;
  // Syncing data seems to fail on iOS debug mode (at least on iPad).
  // When actually creating the entries, it seems the device disconnects.
  // It works on release though.

  if (appStateSettings["backupSync"] == false) return false;
  if (appStateSettings["hasSignedIn"] == false) return false;
  if (errorSigningInDuringCloud == true) return false;
  // Prevent sign-in on web - background sign-in cannot access Google Drive etc.
  if (kIsWeb && !entireAppLoaded) return false;

  canSyncData = false;

  bool hasSignedIn = false;
  if (googleUser == null) {
    hasSignedIn = await signInGoogle(
      gMailPermissions: false,
      waitForCompletion: false,
      silentSignIn: true,
    );
  } else {
    hasSignedIn = true;
  }
  if (hasSignedIn == false) {
    canSyncData = true;
    return false;
  }

  final authHeaders = await googleUser!.authHeaders;
  final authenticateClient = GoogleAuthClient(authHeaders);
  drive.DriveApi driveApi = drive.DriveApi(authenticateClient);
  if (driveApi == null) {
    throw "Failed to login to Google Drive";
  }

  await createSyncBackup();

  drive.FileList fileList = await driveApi.files.list(
      spaces: 'appDataFolder', $fields: 'files(id, name, modifiedTime, size)');
  List<drive.File>? files = fileList.files;

  if (files == null) {
    throw "No backups found.";
  }

  List<drive.File> filesToDownloadSyncChanges = [];
  for (drive.File file in files) {
    if (isSyncBackupFile(file.name)) {
      filesToDownloadSyncChanges.add(file);
    }
  }

  print("LOADING SYNC DB");
  DateTime syncStarted = DateTime.now();
  List<SyncLog> syncLogs = [];
  List<drive.File> filesSyncing = [];

  int currentFileIndex = 0;
  loadingProgressKey.currentState!.setProgressPercentage(0);
  for (drive.File file in filesToDownloadSyncChanges) {
    loadingIndeterminateKey.currentState!.setVisibility(true);

    // we don't want to restore this clients backup
    if (isCurrentDeviceSyncBackupFile(file.name)) continue;

    // check if this is a new sync from this specific client
    DateTime lastSynced = await getDateOfLastSyncedWithClient(
        getDeviceFromSyncBackupFileName(file.name));

    print("COMPARING TIMES");
    print(file.modifiedTime?.toLocal());
    print(lastSynced);
    print(lastSynced != file.modifiedTime!.toLocal());
    if (file.modifiedTime == null ||
        lastSynced.isAfter(file.modifiedTime!.toLocal()) ||
        lastSynced == file.modifiedTime!.toLocal()) {
      print(
          "no need to restore backup from this client, no new backup file to pull data from");
      continue;
    }

    String? fileId = file.id;
    if (fileId == null) continue;
    print("SYNCING WITH " + (file.name ?? ""));
    filesSyncing.add(file);

    List<int> dataStore = [];
    dynamic response = await driveApi.files
        .get(fileId, downloadOptions: drive.DownloadOptions.fullMedia);
    await for (var data in response.stream) {
      dataStore.insertAll(dataStore.length, data);
    }

    if (kIsWeb) {
      final html.Storage localStorage = html.window.localStorage;
      localStorage["moor_db_str_syncdb"] =
          bin2str.encode(Uint8List.fromList(dataStore));
    } else {
      final dbFolder = await getApplicationDocumentsDirectory();
      final dbFile = File(p.join(dbFolder.path, 'syncdb.sqlite'));
      await dbFile.writeAsBytes(dataStore);
    }

    FinanceDatabase databaseSync = await constructDb('syncdb');

    try {
      List<TransactionWallet> newWallets =
          await databaseSync.getAllNewWallets(lastSynced);
      for (TransactionWallet newEntry in newWallets) {
        syncLogs.add(SyncLog(
          deleteLogType: null,
          updateLogType: UpdateLogType.TransactionWallet,
          pk: newEntry.walletPk,
          itemToUpdate: newEntry,
          transactionDateTime: newEntry.dateTimeModified,
        ));
      }
      print("NEW WALLETS");
      print(newWallets);

      List<TransactionCategory> newCategories =
          await databaseSync.getAllNewCategories(lastSynced);
      for (TransactionCategory newEntry in newCategories) {
        syncLogs.add(SyncLog(
          deleteLogType: null,
          updateLogType: UpdateLogType.TransactionCategory,
          pk: newEntry.categoryPk,
          itemToUpdate: newEntry,
          transactionDateTime: newEntry.dateTimeModified,
        ));
      }
      print("NEW CATEGORIES");
      print(newCategories);

      List<Budget> newBudgets = await databaseSync.getAllNewBudgets(lastSynced);
      for (Budget newEntry in newBudgets) {
        syncLogs.add(SyncLog(
          deleteLogType: null,
          updateLogType: UpdateLogType.Budget,
          pk: newEntry.budgetPk,
          itemToUpdate: newEntry,
          transactionDateTime: newEntry.dateTimeModified,
        ));
      }
      print("NEW BUDGETS");
      print(newBudgets);

      List<CategoryBudgetLimit> newCategoryBudgetLimits =
          await databaseSync.getAllNewCategoryBudgetLimits(lastSynced);
      for (CategoryBudgetLimit newEntry in newCategoryBudgetLimits) {
        syncLogs.add(SyncLog(
          deleteLogType: null,
          updateLogType: UpdateLogType.CategoryBudgetLimit,
          pk: newEntry.categoryLimitPk,
          itemToUpdate: newEntry,
          transactionDateTime: newEntry.dateTimeModified,
        ));
      }
      print("NEW CATEGORY LIMITS");
      print(newCategoryBudgetLimits);

      List<Transaction> newTransactions =
          await databaseSync.getAllNewTransactions(lastSynced);
      for (Transaction newEntry in newTransactions) {
        syncLogs.add(SyncLog(
          deleteLogType: null,
          updateLogType: UpdateLogType.Transaction,
          pk: newEntry.transactionPk,
          itemToUpdate: newEntry,
          transactionDateTime: newEntry.dateTimeModified,
        ));
      }
      print("NEW TRANSACTIONS");
      print(newTransactions);

      List<TransactionAssociatedTitle> newTitles =
          await databaseSync.getAllNewAssociatedTitles(lastSynced);
      for (TransactionAssociatedTitle newEntry in newTitles) {
        syncLogs.add(SyncLog(
          deleteLogType: null,
          updateLogType: UpdateLogType.TransactionAssociatedTitle,
          pk: newEntry.associatedTitlePk,
          itemToUpdate: newEntry,
          transactionDateTime: newEntry.dateTimeModified,
        ));
      }
      print("NEW TITLES");
      print(newTitles);

      for (ScannerTemplate newEntry
          in (await databaseSync.getAllNewScannerTemplates(lastSynced))) {
        syncLogs.add(SyncLog(
          deleteLogType: null,
          updateLogType: UpdateLogType.ScannerTemplate,
          pk: newEntry.scannerTemplatePk,
          itemToUpdate: newEntry,
          transactionDateTime: newEntry.dateTimeModified,
        ));
      }

      List<Objective> newObjectives =
          await databaseSync.getAllNewObjectives(lastSynced);
      for (Objective newEntry in newObjectives) {
        syncLogs.add(SyncLog(
          deleteLogType: null,
          updateLogType: UpdateLogType.Objective,
          pk: newEntry.objectivePk,
          itemToUpdate: newEntry,
          transactionDateTime: newEntry.dateTimeModified,
        ));
      }
      print("NEW OBJECTIVES");
      print(newObjectives);

      List<DeleteLog> deleteLogs =
          await databaseSync.getAllNewDeleteLogs(lastSynced);

      for (DeleteLog deleteLog in deleteLogs) {
        syncLogs.add(SyncLog(
          deleteLogType: deleteLog.type,
          updateLogType: null,
          pk: deleteLog.entryPk,
          transactionDateTime: deleteLog.dateTimeModified,
        ));
      }

      print("DELETE LOGS");
      print(deleteLogs);
    } catch (e) {
      print("SYNC FAILED");
      print(e.toString());
      openSnackbar(
        SnackbarMessage(
          title: "syncing-failed".tr(),
          description: "sync-fail-reason".tr(),
          icon: appStateSettings["outlinedIcons"]
              ? Icons.sync_problem_outlined
              : Icons.sync_problem_rounded,
          timeout: Duration(milliseconds: 5500),
        ),
      );
      filesSyncing.remove(file);
      await databaseSync.close();
      loadingProgressKey.currentState!.setProgressPercentage(1);
      canSyncData = true;
      // By returning we do not update the time last synced!
      return false;
    }

    currentFileIndex = currentFileIndex + 1;
    loadingProgressKey.currentState!.setProgressPercentage(
        currentFileIndex / filesToDownloadSyncChanges.length);

    await databaseSync.close();
  }

  await database.processSyncLogs(syncLogs);
  for (drive.File file in filesSyncing)
    setDateOfLastSyncedWithClient(getDeviceFromSyncBackupFileName(file.name),
        file.modifiedTime?.toLocal() ?? DateTime(0));

  try {
    print("UPDATED WALLET CURRENCY");
    await database.getWalletInstance(appStateSettings["selectedWalletPk"]);
  } catch (e) {
    print("Selected wallet not found: " + e.toString());
    await setPrimaryWallet((await database.getAllWallets())[0].walletPk);
  }

  updateSettings(
    "lastSynced",
    syncStarted.toString(),
    pagesNeedingRefresh: [],
    updateGlobalState: getIsFullScreen(context) ? true : false,
  );

  loadingProgressKey.currentState!.setProgressPercentage(0.999);

  Future.delayed(Duration(milliseconds: 300), () {
    loadingProgressKey.currentState!.setProgressPercentage(1);
  });

  canSyncData = true;

  print("DONE SYNCING");
  return true;
}
