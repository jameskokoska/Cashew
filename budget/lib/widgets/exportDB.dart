import 'dart:convert';

import 'package:budget/colors.dart';
import 'package:budget/database/binary_string_conversion.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/accountAndBackup.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/dropdownSelect.dart';
import 'package:budget/widgets/globalSnackBar.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/progressBar.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:drift/drift.dart' hide Column, Table;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter_charset_detector/flutter_charset_detector.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:io';
import 'package:budget/struct/randomConstants.dart';
import 'package:universal_html/html.dart' show AnchorElement;
import 'package:path/path.dart' as p;

Future saveDBFileToDevice(String fileName) async {
  DBFileInfo currentDBFileInfo = await getCurrentDBFileInfo();

  List<int> dataStore = [];
  await for (var data in currentDBFileInfo.mediaStream) {
    dataStore.insertAll(dataStore.length, data);
  }

  if (kIsWeb) {
    try {
      String base64String = base64Encode(dataStore);
      AnchorElement anchor = AnchorElement(
          href: 'data:application/octet-stream;base64,$base64String')
        ..download = fileName
        ..style.display = 'none';
      anchor.click();
      openSnackbar(SnackbarMessage(
        title: "backup-saved-success".tr(),
        description: fileName,
        icon: appStateSettings["outlinedIcons"]
            ? Icons.download_done_outlined
            : Icons.download_done_rounded,
      ));
      return true;
    } catch (e) {
      openSnackbar(SnackbarMessage(
        title: "error-saving".tr(),
        description: e.toString(),
        icon: appStateSettings["outlinedIcons"]
            ? Icons.warning_outlined
            : Icons.warning_rounded,
      ));
      print("Error saving file to device: " + e.toString());
      return false;
    }
  }

  try {
    String directory = getPlatform() == PlatformOS.isAndroid
        ? "/storage/emulated/0/Download"
        : (await getApplicationDocumentsDirectory()).path;

    String filePath = "${directory}/${fileName}";
    File savedFile = File(filePath);
    await savedFile.writeAsBytes(dataStore);
    openSnackbar(SnackbarMessage(
      title: "backup-saved-success".tr(),
      description: fileName,
      icon: appStateSettings["outlinedIcons"]
          ? Icons.download_done_outlined
          : Icons.download_done_rounded,
    ));
    return true;
  } catch (e) {
    openSnackbar(SnackbarMessage(
      title: "error-saving".tr(),
      description: e.toString(),
      icon: appStateSettings["outlinedIcons"]
          ? Icons.warning_outlined
          : Icons.warning_rounded,
    ));
    print("Error saving file to device: " + e.toString());
    return false;
  }
}

class ExportDB extends StatelessWidget {
  const ExportDB({super.key});

  Future exportDB() async {
    await openLoadingPopupTryCatch(() async {
      String fileName = "cashew-" +
          DateTime.now()
              .toString()
              .replaceAll(".", "-")
              .replaceAll("-", "-")
              .replaceAll(" ", "-")
              .replaceAll(":", "-") +
          ".sqlite";
      await saveDBFileToDevice(fileName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SettingsContainer(
      onTap: () async {
        await exportDB();
      },
      title: "export-data-file".tr(),
      icon: appStateSettings["outlinedIcons"]
          ? Icons.upload_outlined
          : Icons.upload_rounded,
    );
  }
}
