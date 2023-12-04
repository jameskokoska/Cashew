// web.dart
import 'dart:typed_data';
import 'package:budget/database/binary_string_conversion.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:drift/web.dart';
import 'package:budget/database/tables.dart';
import 'package:universal_html/html.dart' as html;

Future<FinanceDatabase> constructDb(String dbName,
    {Uint8List? initialDataWeb}) async {
  if (initialDataWeb != null)
    return FinanceDatabase(
        WebDatabase.withStorage(InMemoryWebStorage(initialDataWeb)));

  return FinanceDatabase(
    WebDatabase.withStorage(
      await DriftWebStorage.indexedDbIfSupported(dbName),
      logStatements: false,
    ),
  );
}

Future<DBFileInfo> getCurrentDBFileInfo() async {
  Uint8List dbFileBytes;
  late Stream<List<int>> mediaStream;
  bool supportIndexedDb = await DriftWebStorage.supportsIndexedDb();

  if (supportIndexedDb) {
    DriftWebStorage storage = await DriftWebStorage.indexedDbIfSupported('db');
    await storage.open();
    dbFileBytes = (await storage.restore()) ?? Uint8List.fromList([]);
    mediaStream = Stream.value(List<int>.from(dbFileBytes));
  } else {
    final html.Storage localStorage = html.window.localStorage;
    dbFileBytes = bin2str.decode(localStorage["moor_db_str_db"] ?? "");
    mediaStream = Stream.value(dbFileBytes);
  }

  return DBFileInfo(dbFileBytes, mediaStream);
}

Future overwriteDefaultDB(Uint8List dataStore) async {
  bool supportIndexedDb = await DriftWebStorage.supportsIndexedDb();
  if (supportIndexedDb) {
    DriftWebStorage storage = await DriftWebStorage.indexedDbIfSupported('db');
    await storage.open();
    await storage.store(dataStore);
  } else {
    final html.Storage localStorage = html.window.localStorage;
    localStorage.clear();
    localStorage["moor_db_str_db"] =
        bin2str.encode(Uint8List.fromList(dataStore));
  }
  // we need to be able to sync with others after the restore
  await sharedPreferences.setString("dateOfLastSyncedWithClient", "{}");
}

// Similar to DriftWebStorage.volatile, except we can load an initial db
// https://github.com/simolus3/drift/discussions/1082
class InMemoryWebStorage implements DriftWebStorage {
  Uint8List? _storedData;

  InMemoryWebStorage([Uint8List? initialData]) : _storedData = initialData;

  @override
  Future<void> close() => Future.value();

  @override
  Future<void> open() => Future.value();

  @override
  Future<Uint8List?> restore() => Future.value(_storedData);

  @override
  Future<void> store(Uint8List data) {
    _storedData = data;
    return Future.value();
  }
}


// Notes:
// While looking for a solution to sync the web database without making a copy in local storage
// https://github.com/simolus3/drift/discussions/1082
// InMemoryWebStorage is the solution!
// And 
// https://github.com/simolus3/drift/discussions/2120
// DriftWebStorage storage = await DriftWebStorage.indexedDbIfSupported('db');
// await storage.open();
// dbFileBytes = (await storage.restore()) ?? Uint8List.fromList([]);
// mediaStream = Stream.value(List<int>.from(dbFileBytes));
// ---------------------------------------------------
// These are the brainstorming/research notes of this migration:
// ---------------------------------------------------
// We want to support indexed DB in the future -> smaller file size since syncing will have its limits
// However, we would need to implement a way to get the 'bytes' of the current SQL
// When uploading sync backups from web
// There are also issues with putting a sync db in a temp
// indexedDb from the bin2str.encode(Uint8List.fromList(dataStore))
// when loading a file from GDrive
// https://github.com/simolus3/drift/issues/207
//
// Some things to try? When loading a sync backup, use the indexedDb only for sync backups
// Therefore we do not hit the file limit?
//
// Or do we just redo the way syncing works?
// When syncing, create a separate temporary db with ONLY the changes
// Can use queries to find the changes that occurred, add to temp db and upload
// But we don't know when these changes are processed by who?
//
// return FinanceDatabase(
//   WebDatabase.withStorage(
//     await DriftWebStorage.indexedDbIfSupported(dbName),
//     logStatements: false,
//   ),
// );

// For some reason using an indexed DB doesnt seem to work for restoring data?
// If uncommenting this for tests, make sure to comment constructDb!
// databaseSync = FinanceDatabase(
//   WebDatabase.withStorage(
//     await DriftWebStorage.indexedDbIfSupported("syncdb"),
//     logStatements: false,
//     initializer: () => bin2str.decode(dataEncoded),
//   ),
// );

//print("Constructing web database");
//DriftWebStorage storage =
//    await DriftWebStorage.indexedDbIfSupported("syncdb");
//databaseSync = FinanceDatabase(
//  WebDatabase.withStorage(
//    storage,
//    logStatements: false,
//    initializer: () async {
//      await storage.store(Uint8List.fromList(dataStore));
//      return Uint8List.fromList(dataStore);
//    },
//  ),
//);

// How to get the file bytes of the current db?
// DriftWebStorage storage = await DriftWebStorage.indexedDbIfSupported("db");
// FinanceDatabase _database = FinanceDatabase(
//   WebDatabase.withStorage(
//     await DriftWebStorage.indexedDbIfSupported("db"),
//     logStatements: false,
//   ),
// );
// final html.Storage localStorage = html.window.localStorage;
// dbFileBytes = bin2str.decode(localStorage["moor_db_str_db"] ?? "");
// dbFileBytes = (await storage.restore()) ?? Uint8List.fromList([]);
// mediaStream = Stream.value(dbFileBytes);

// final html.Storage localStorage = html.window.localStorage;
// localStorage["moor_db_str_syncdb"] = dataEncoded;

// databaseSync =
//     await FinanceDatabase(WebDatabase('syncdb', logStatements: false));

// print("QUERY TEST " + (await databaseSync.getAllBudgets()).toString());
// print(Uint8List.fromList(dataStore).length);