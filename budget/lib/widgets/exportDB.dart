import 'package:budget/database/tables.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/exportCSV.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/util/saveFile.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'dart:async';

Future saveDBFileToDevice({
  required BuildContext boxContext,
  required String fileName,
  String? customDirectory,
}) async {
  try {
    await backupSettings();
  } catch (e) {
    print("Error creating settings entry in the db: " + e.toString());
  }

  DBFileInfo currentDBFileInfo = await getCurrentDBFileInfo();

  List<int> dataStore = [];
  await for (var data in currentDBFileInfo.mediaStream) {
    dataStore.insertAll(dataStore.length, data);
  }

  return await saveFile(
    boxContext: boxContext,
    dataStore: dataStore,
    dataString: null,
    fileName: fileName,
    successMessage: "backup-saved-success".tr(),
    errorMessage: "error-saving".tr(),
  );
}

Future exportDB({required BuildContext boxContext}) async {
  await openLoadingPopupTryCatch(() async {
    String fileName =
        "cashew-" + cleanFileNameString(DateTime.now().toString()) + ".sql";
    await saveDBFileToDevice(boxContext: boxContext, fileName: fileName);
  });
}

class ExportDB extends StatelessWidget {
  const ExportDB({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (boxContext) {
      return SettingsContainer(
        onTap: () async {
          await exportDB(boxContext: boxContext);
        },
        title: "export-data-file".tr(),
        icon: appStateSettings["outlinedIcons"]
            ? Icons.upload_outlined
            : Icons.upload_rounded,
      );
    });
  }
}
