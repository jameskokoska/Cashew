import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:budget/database/binary_string_conversion.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/popupFramework.dart';
import 'package:budget/widgets/selectColor.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:drift/drift.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:budget/main.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart' as signIn;
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import 'dart:math' as math;

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = new http.Client();
  GoogleAuthClient(this._headers);
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late Color selectedColor = Colors.red;
  signIn.GoogleSignInAccount? user;
  late signIn.GoogleSignIn googleSignIn;

  Future<void> _showList() async {
    final authHeaders = await user!.authHeaders;
    final authenticateClient = GoogleAuthClient(authHeaders);
    final driveApi = drive.DriveApi(authenticateClient);

    if (driveApi == null) {
      return;
    }

    final fileList = await driveApi.files.list(
        spaces: 'appDataFolder', $fields: 'files(id, name, modifiedTime)');
    final files = fileList.files;
    if (files == null) {
      openSnackbar(context, "NO FILEs");
    }
    //get the latest file with index 0... in the future make user be able to select which file
    inspect(await driveApi.files.get(files![0].id ?? "").asStream());
    List<int> dataStore = [];
    dynamic response = await driveApi.files.get(files[0].id ?? "",
        downloadOptions: drive.DownloadOptions.fullMedia);
    response.stream.listen((data) {
      print("Data: ${data.length}");
      dataStore.insertAll(dataStore.length, data);
    }, onDone: () async {
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

      print("File created");
      openSnackbar(context, "RESTART");
      openPopup(
        context,
        description: "Please Restart the Application",
        barrierDismissible: false,
        icon: Icons.restart_alt_rounded,
      );
    }, onError: (error) {
      print(error.toString());
    });
    final alert = AlertDialog(
      title: Text("Item List"),
      content: SingleChildScrollView(
        child: ListBody(
          children: files.map((e) => Text(e.name ?? "no-name")).toList(),
        ),
      ),
    );

    return showDialog(
      context: context,
      builder: (BuildContext context) => alert,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageFramework(
      title: "Settings",
      backButton: false,
      listWidgets: [
        SettingsContainerButton(
          onTap: () async {
            try {
              if (user == null) {
                googleSignIn = signIn.GoogleSignIn.standard(scopes: [
                  drive.DriveApi.driveAppdataScope,
                ]);
                final signIn.GoogleSignInAccount? account =
                    await googleSignIn.signIn();
                if (account != null) {
                  setState(() {
                    user = account;
                  });
                  // final client = GoogleAuthClient(headers);

                  // driveApi = drive.DriveApi(client);
                } else {
                  throw ("Login failed");
                }
              } else {
                await googleSignIn.signOut();
                setState(() {
                  user = null;
                });
                print("Signedout");
              }
            } catch (e) {
              print(e.toString());
              openSnackbar(context, e.toString());
            }
          },
          title: user == null ? "Sign-In" : user!.displayName ?? "",
          icon: Icons.account_circle,
        ),
        SettingsContainerButton(
          onTap: () async {
            var dbFileBytes;
            late Stream<List<int>> mediaStream;
            if (kIsWeb) {
              final html.Storage localStorage = html.window.localStorage;
              dbFileBytes =
                  bin2str.decode(localStorage["moor_db_str_db"] ?? "");
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
            final timestamp =
                DateFormat("yyyy-MM-dd-hhmmss").format(DateTime.now());
            driveFile.name = "db-$timestamp.sqlite";
            driveFile.modifiedTime = DateTime.now().toUtc();
            driveFile.parents = ["appDataFolder"];

            final response =
                await driveApi.files.create(driveFile, uploadMedia: media);
          },
          title: "Export Database",
          icon: Icons.upload_rounded,
        ),
        SettingsContainerButton(
          onTap: () async {
            _showList();
            // final dbFolder = await getApplicationDocumentsDirectory();
            // final org = File(p.join(dbFolder.path, 'db.sqlite'));
            // File(dbLocation).writeAsBytes(updatedContent)
          },
          title: "Import Database",
          icon: Icons.download_rounded,
        ),
        SettingsContainerSwitch(
          title: "Dark Mode",
          description: "Set the overall theme of the app. yesss",
          initialValue: true,
          icon: Icons.dark_mode_rounded,
          onSwitched: (value) {
            if (value) {
              appStateKey.currentState?.changeTheme(ThemeMode.light);
            } else {
              appStateKey.currentState?.changeTheme(ThemeMode.dark);
            }
          },
        ),
        SettingsContainerSwitch(
          title: "Test",
          initialValue: true,
          icon: Icons.lock_rounded,
          onSwitched: (value) {},
        ),
        SettingsContainerOpenPage(
          openPage: EditBudgetPage(title: "Edit Budgets"),
          title: "Edit Budgets",
          description: "Edit the order and budget details",
          icon: Icons.bungalow_outlined,
        ),
        SettingsContainerButton(
          onTap: () {
            openBottomSheet(
              context,
              PopupFramework(
                title: "Select Color",
                child: SelectColor(
                  selectedColor: selectedColor,
                  setSelectedColor: (color) {
                    selectedColor = color;
                  },
                ),
              ),
            );
          },
          title: "Select Accent Color",
          icon: Icons.color_lens_rounded,
        ),
        SettingsContainerDropdown(
          title: "Theme Mode",
          icon: Icons.dark_mode_rounded,
          initial: "Light",
          items: ["Light", "Dark", "System"],
          onChanged: (value) {
            if (value == "Light") {
              appStateKey.currentState?.changeTheme(ThemeMode.light);
            } else if (value == "Dark") {
              appStateKey.currentState?.changeTheme(ThemeMode.dark);
            } else if (value == "System") {
              appStateKey.currentState?.changeTheme(ThemeMode.system);
            }
          },
        ),
      ],
    );
  }
}
