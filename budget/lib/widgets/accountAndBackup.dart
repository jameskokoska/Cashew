import 'dart:convert';
import 'dart:developer';

import 'package:budget/colors.dart';
import 'package:budget/database/binary_string_conversion.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/settingsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/dropdownSelect.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/popupFramework.dart';
import 'package:budget/widgets/progressBar.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:drift/drift.dart' hide Column hide Table;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/gmail/v1.dart' as gMail;
import 'package:google_sign_in/google_sign_in.dart' as signIn;
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;
import 'dart:math' as math;
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:csv/csv.dart';

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = new http.Client();
  GoogleAuthClient(this._headers);
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}

class AccountAndBackup extends StatefulWidget {
  const AccountAndBackup({Key? key}) : super(key: key);

  @override
  State<AccountAndBackup> createState() => _AccountAndBackupState();
}

signIn.GoogleSignInAccount? user;
late signIn.GoogleSignIn googleSignIn;

Future<bool> signInGoogle(context,
    {bool? waitForCompletion,
    bool? drivePermissions,
    bool? gMailPermissions}) async {
  try {
    if (waitForCompletion == true) openLoadingPopup(context);
    if (user == null) {
      googleSignIn = signIn.GoogleSignIn.standard(scopes: [
        ...(drivePermissions == true ? [drive.DriveApi.driveAppdataScope] : []),
        ...(gMailPermissions == true ? [gMail.GmailApi.gmailReadonlyScope] : [])
      ]);
      final signIn.GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account != null) {
        user = account;
      } else {
        throw ("Login failed");
      }
    }
    if (waitForCompletion == true) Navigator.of(context).pop();
    return true;
  } catch (e) {
    if (waitForCompletion == true) Navigator.of(context).pop();
    openSnackbar(context, e.toString());
    return false;
  }
}

Future<bool> signOutGoogle() async {
  await googleSignIn.signOut();
  user = null;
  print("Signedout");
  return true;
}

class _AccountAndBackupState extends State<AccountAndBackup> {
  Future<void> _createBackup() async {
    try {
      openLoadingPopup(context);
      var dbFileBytes;
      late Stream<List<int>> mediaStream;
      if (kIsWeb) {
        final html.Storage localStorage = html.window.localStorage;
        dbFileBytes = bin2str.decode(localStorage["moor_db_str_db"] ?? "");
        mediaStream = Stream.value(dbFileBytes);
      } else {
        final dbFolder = await getApplicationDocumentsDirectory();
        final dbFile = File(p.join(dbFolder.path, 'db.sqlite'));
        // Share.shareFiles([p.join(dbFolder.path, 'db.sqlite')],
        //     text: 'Database');
        // await file.readAsBytes();
        dbFileBytes = await dbFile.readAsBytes();
        mediaStream = Stream.value(List<int>.from(dbFileBytes));
      }
      final authHeaders = await user!.authHeaders;
      final authenticateClient = GoogleAuthClient(authHeaders);
      final driveApi = drive.DriveApi(authenticateClient);

      var media = new drive.Media(mediaStream, dbFileBytes.length);

      var driveFile = new drive.File();
      final timestamp = DateFormat("yyyy-MM-dd-hhmmss").format(DateTime.now());
      driveFile.name = "db-$timestamp.sqlite";
      driveFile.modifiedTime = DateTime.now().toUtc();
      driveFile.parents = ["appDataFolder"];

      await driveApi.files.create(driveFile, uploadMedia: media);
      Navigator.of(context).pop();
      openSnackbar(context, "Backup created: " + (driveFile.name ?? ""));
    } catch (e) {
      Navigator.of(context).pop();
      openSnackbar(context, e.toString());
    }
  }

  Future<void> _deleteRecentBackups(amountToKeep) async {
    try {
      openLoadingPopup(context);

      final authHeaders = await user!.authHeaders;
      final authenticateClient = GoogleAuthClient(authHeaders);
      final driveApi = drive.DriveApi(authenticateClient);
      if (driveApi == null) {
        throw "Failed to login to Google Drive";
      }

      final fileList = await driveApi.files.list(
          spaces: 'appDataFolder', $fields: 'files(id, name, modifiedTime)');
      final files = fileList.files;
      if (files == null) {
        throw "No backups found.";
      }

      int index = 0;
      files.forEach((file) {
        if (index >= amountToKeep) {
          _deleteBackup(driveApi, file.id ?? "");
        }
        index++;
      });

      Navigator.of(context).pop();
    } catch (e) {
      Navigator.of(context).pop();
      openSnackbar(context, e.toString());
    }
  }

  Future<void> _deleteBackup(drive.DriveApi driveApi, String fileId) async {
    await driveApi.files.delete(fileId);
  }

  Future<void> _loadBackup(drive.DriveApi driveApi, String fileId) async {
    try {
      openLoadingPopup(context);

      List<int> dataStore = [];
      dynamic response = await driveApi.files
          .get(fileId, downloadOptions: drive.DownloadOptions.fullMedia);
      response.stream.listen(
        (data) {
          print("Data: ${data.length}");
          dataStore.insertAll(dataStore.length, data);
        },
        onDone: () async {
          if (kIsWeb) {
            final html.Storage localStorage = html.window.localStorage;
            localStorage["moor_db_str_db"] =
                bin2str.encode(Uint8List.fromList(dataStore));
          } else {
            final dbFolder = await getApplicationDocumentsDirectory();
            final dbFile = File(p.join(dbFolder.path, 'db.sqlite'));
            await dbFile.writeAsBytes(dataStore);
            // Share.shareFiles([p.join(dbFolder.path, 'db.sqlite')],
            //     text: 'Database');
          }

          Navigator.of(context).pop();
          openPopup(
            context,
            description: "Please Restart the Application",
            barrierDismissible: false,
            icon: Icons.restart_alt_rounded,
          );
        },
        onError: (error) {
          openSnackbar(context, error.toString());
        },
      );
    } catch (e) {
      Navigator.of(context).pop();
      openSnackbar(context, e.toString());
    }
  }

  Future<void> _chooseBackup() async {
    try {
      openLoadingPopup(context);

      final authHeaders = await user!.authHeaders;
      final authenticateClient = GoogleAuthClient(authHeaders);
      final driveApi = drive.DriveApi(authenticateClient);
      if (driveApi == null) {
        throw "Failed to login to Google Drive";
      }

      final fileList = await driveApi.files.list(
          spaces: 'appDataFolder', $fields: 'files(id, name, modifiedTime)');
      final files = fileList.files;
      if (files == null) {
        throw "No backups found.";
      }

      Navigator.of(context).pop();

      openBottomSheet(
        context,
        PopupFramework(
          title: "Choose a Backup to Restore",
          child: Column(
            children: files
                .map(
                  (file) => SettingsContainer(
                    icon: Icons.file_copy,
                    title: file.name ?? "No name",
                    onTap: () {
                      _loadBackup(driveApi, file.id ?? "");
                    },
                  ),
                )
                .toList(),
          ),
        ),
      );
    } catch (e) {
      Navigator.of(context).pop();
      openSnackbar(context, e.toString());
    }
  }

  _getHeaderIndex(List<String> headers, String header) {
    int index = 0;
    for (String headerEntry in headers) {
      if (header == headerEntry) {
        return index;
      }
      index++;
    }
    return -1;
  }

  Future<void> _chooseBackupFile() async {
    try {
      openLoadingPopup(context);

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowedExtensions: ['csv'],
        type: FileType.custom,
      );

      if (result != null) {
        File file = File(result.files.single.path ?? "");
        String fileString = await file.readAsString();
        List<List<String>> fileContents = CsvToListConverter()
            .convert(fileString, eol: '\n', shouldParseNumbers: false);
        List<String> headers = fileContents[0];
        List<String> firstEntry = fileContents[1];

        Navigator.of(context).pop();

        Transaction(
          amount: 0,
          categoryFk: 0,
          dateCreated: DateTime.now(),
          income: false,
          name: "test",
          note: "hello",
          transactionPk: 0,
          walletFk: 0,
          labelFks: [],
          paid: true,
          skipPaid: false,
        );

        Map<String, Map<String, dynamic>> assignedColumns = {
          "date": {
            "displayName": "Date",
            "headerValues": ["date"],
            "required": true,
            "setHeaderValue": "",
            "setHeaderIndex": -1,
          },
          "amount": {
            "displayName": "Amount",
            "headerValues": ["amount"],
            "required": true,
            "setHeaderValue": "",
            "setHeaderIndex": -1,
          },
          "category": {
            "displayName": "Category",
            "headerValues": ["category", "category name"],
            // "extraOptions": ["Use Smart Categories"],
            //This will be implemented later... in the future
            //Use title to determine category. If smart category entry not found, ask user to select which category when importing. Save these selections to that category.
            "required": true,
            "setHeaderValue": "",
            "setHeaderIndex": -1,
          },
          "name": {
            "displayName": "Transaction Name",
            "headerValues": ["title", "name"],
            "required": false,
            "setHeaderValue": "",
            "setHeaderIndex": -1,
          },
          "note": {
            "displayName": "Note",
            "headerValues": ["note"],
            "required": false,
            "setHeaderValue": "",
            "setHeaderIndex": -1,
          },
          "wallet": {
            "displayName": "Wallet",
            "headerValues": ["wallet"],
            "required": true,
            "setHeaderValue": "",
            "setHeaderIndex": -1,
          },
          //In the future make it so users can select a default wallet already made
        };
        for (dynamic key in assignedColumns.keys) {
          String setHeaderValue = determineInitialValue(
              assignedColumns[key]!["headerValues"],
              headers,
              assignedColumns[key]!["required"]);
          assignedColumns[key]!["setHeaderValue"] = setHeaderValue;
          assignedColumns[key]!["setHeaderIndex"] =
              _getHeaderIndex(headers, setHeaderValue);
        }

        openBottomSheet(
          context,
          PopupFramework(
            title: "Assign Columns",
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Table(
                      border: TableBorder.all(),
                      defaultColumnWidth: IntrinsicColumnWidth(),
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: <TableRow>[
                        TableRow(
                          decoration: const BoxDecoration(
                            color: Colors.grey,
                          ),
                          children: <Widget>[
                            for (dynamic header in headers)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFont(
                                  text: header.toString(),
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                          ],
                        ),
                        TableRow(
                          children: <Widget>[
                            for (dynamic entry in firstEntry)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFont(text: entry.toString()),
                              )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  children: [
                    for (dynamic key in assignedColumns.keys)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextFont(
                              text: assignedColumns[key]!["displayName"]
                                  .toString()),
                          DropdownSelect(
                            compact: true,
                            initial: assignedColumns[key]!["setHeaderValue"],
                            items: assignedColumns[key]!["required"]
                                ? [
                                    ...(assignedColumns[key]![
                                                "setHeaderValue"] ==
                                            ""
                                        ? [""]
                                        : []),
                                    ...headers
                                  ]
                                : ["None", ...headers],
                            onChanged: (String setHeaderValue) {
                              assignedColumns[key]!["setHeaderValue"] =
                                  setHeaderValue;
                              assignedColumns[key]!["setHeaderIndex"] =
                                  _getHeaderIndex(headers, setHeaderValue);
                            },
                            backgroundColor: Theme.of(context).canvasColor,
                            checkInitialValue: true,
                          ),
                        ],
                      )
                  ],
                ),
                Button(
                    label: "label",
                    onTap: () async {
                      _importEntries(assignedColumns, fileContents);
                    })
              ],
            ),
          ),
        );
      } else {
        throw "No file selected";
      }
    } catch (e) {
      Navigator.of(context).pop();
      openSnackbar(context, e.toString());
    }
  }

  Future<void> _importEntries(Map<String, Map<String, dynamic>> assignedColumns,
      List<List<String>> fileContents) async {
    try {
      //Check to see if all the required parameters have been set
      for (dynamic key in assignedColumns.keys) {
        if (assignedColumns[key]!["setHeaderValue"] == "") {
          throw "Please make sure you select a parameter for each required field.";
        }
        print(assignedColumns[key]!["setHeaderIndex"]);
      }
    } catch (e) {
      openPopup(
        context,
        description: e.toString(),
        icon: Icons.error_rounded,
        onSubmitLabel: "OK",
        onSubmit: () {
          Navigator.of(context).pop();
        },
      );
    }
    Navigator.of(context).pop();
    // Open the progress bar
    // This Widget opened will actually do the importing
    openPopupCustom(
      context,
      title: "Importing...",
      child: ImportingEntriesPopup(
        assignedColumns: assignedColumns,
        fileContents: fileContents,
        next: () {
          Navigator.of(context).pop();
        },
      ),
      barrierDismissible: false,
    );
    return;
  }

  String determineInitialValue(
      List<String> headerValues, List<String> headers, bool required) {
    for (String header in headers) {
      if (headerValues.contains(header.toLowerCase())) {
        return header;
      }
    }
    if (!required) {
      return "None";
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SettingsContainer(
          onTap: () async {
            if (user == null) {
              await signInGoogle(context,
                  waitForCompletion: true, drivePermissions: true);
            } else {
              await signOutGoogle();
            }
            setState(() {});
          },
          title: user == null ? "Sign-In" : user!.displayName ?? "",
          icon: Icons.account_circle,
        ),
        SettingsContainer(
          onTap: () async {
            await _deleteRecentBackups(10);
            await _createBackup();
          },
          title: "Export Database",
          icon: Icons.upload_rounded,
        ),
        SettingsContainer(
          onTap: () async {
            await _chooseBackup();
          },
          title: "Import Database",
          icon: Icons.download_rounded,
        ),
        SettingsContainer(
          onTap: () async {
            await _chooseBackupFile();
          },
          title: "Import From File",
          icon: Icons.download_rounded,
        ),
      ],
    );
  }
}

class ImportingEntriesPopup extends StatefulWidget {
  const ImportingEntriesPopup({
    required this.assignedColumns,
    required this.fileContents,
    required this.next,
    Key? key,
  }) : super(key: key);

  final Map<String, Map<String, dynamic>> assignedColumns;
  final List<List<String>> fileContents;
  final VoidCallback next;

  @override
  State<ImportingEntriesPopup> createState() => _ImportingEntriesPopupState();
}

class _ImportingEntriesPopupState extends State<ImportingEntriesPopup> {
  double currentPercent = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => _importEntries(widget.assignedColumns, widget.fileContents));
  }

  Future<void> _importEntry(Map<String, Map<String, dynamic>> assignedColumns,
      List<String> row, int i) async {
    int transactionPk = 0;
    transactionPk = DateTime.now().millisecondsSinceEpoch;

    String name = "";
    if (assignedColumns["name"]!["setHeaderIndex"] != -1) {
      name = row[assignedColumns["name"]!["setHeaderIndex"]].toString();
    }

    double amount = 0;
    amount = double.parse(row[assignedColumns["amount"]!["setHeaderIndex"]]);

    String note = "";
    if (assignedColumns["note"]!["setHeaderIndex"] != -1) {
      note = row[assignedColumns["note"]!["setHeaderIndex"]].toString();
    }

    int categoryFk = 0;
    try {
      categoryFk = (await database.getCategoryInstanceGivenName(
              row[assignedColumns["category"]!["setHeaderIndex"]]))
          .categoryPk;
    } catch (_) {
      print("category not found");
      int numberOfCategories =
          (await database.getTotalCountOfCategories())[0] ?? 0;
      await database.createOrUpdateCategory(
        TransactionCategory(
          categoryPk: DateTime.now().millisecondsSinceEpoch,
          name: row[assignedColumns["category"]!["setHeaderIndex"]],
          dateCreated: DateTime.now(),
          order: numberOfCategories,
          colour:
              toHexString(getSettingConstants(appStateSettings)["accentColor"]),
          income: amount > 0,
          iconName: "image.png",
          smartLabels: [],
        ),
      );
      categoryFk = (await database.getCategoryInstanceGivenName(
              row[assignedColumns["category"]!["setHeaderIndex"]]))
          .categoryPk;
    }

    int walletFk = 0;
    try {
      walletFk = (await database.getWalletInstanceGivenName(
              row[assignedColumns["wallet"]!["setHeaderIndex"]]))
          .walletPk;
    } catch (_) {
      print("wallet not found");
      throw "Wallet not found!";
    }

    DateTime dateCreated =
        DateTime.parse(row[assignedColumns["date"]!["setHeaderIndex"]]);

    bool income = amount > 0;

    await database.createOrUpdateTransaction(
      Transaction(
        transactionPk: transactionPk,
        name: name,
        amount: amount,
        note: note,
        categoryFk: categoryFk,
        walletFk: walletFk,
        dateCreated: dateCreated,
        income: income,
        paid: true,
        skipPaid: false,
      ),
    );

    return;
  }

  Future<void> _importEntries(Map<String, Map<String, dynamic>> assignedColumns,
      List<List<String>> fileContents) async {
    List<String> categoriesCreated = [];
    try {
      for (int i = 0; i < fileContents.length; i++) {
        if (i == 0) {
          continue;
        }
        setState(() {
          currentPercent = i / fileContents.length * 100;
        });
        await Future.delayed(Duration(milliseconds: 0), () async {
          List<String> row = fileContents[i];
          await _importEntry(assignedColumns, row, i);
        });
      }
      widget.next();
    } catch (e) {
      openPopup(
        context,
        description: e.toString(),
        icon: Icons.error_rounded,
        onSubmitLabel: "OK",
        onSubmit: () {
          Navigator.of(context).pop();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProgressBar(
      currentPercent: currentPercent,
      color: Colors.black,
    );
  }
}
