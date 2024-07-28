import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/struct/syncClient.dart';
import 'package:budget/widgets/globalSnackbar.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

Future<String?> importDBFileFromDevice(BuildContext context) async {
  // For some reason, iOS does not let us select SQL files if we limit
  FilePickerResult? result = getPlatform() == PlatformOS.isIOS
      ? await FilePicker.platform.pickFiles()
      : await FilePicker.platform.pickFiles(
          allowedExtensions: ['sql', 'sqlite'],
          type: FileType.custom,
        );
  if (result == null) {
    openSnackbar(SnackbarMessage(
      title: "error-importing".tr(),
      description: "no-file-selected".tr(),
      icon: appStateSettings["outlinedIcons"]
          ? Icons.warning_outlined
          : Icons.warning_rounded,
    ));
    return null;
  }

  await cancelAndPreventSyncOperation();

  if (kIsWeb) {
    Uint8List fileBytes = result.files.single.bytes!;
    await overwriteDefaultDB(fileBytes);
  } else {
    File file = File(result.files.single.path ?? "");
    Uint8List fileBytes = await file.readAsBytes();
    await overwriteDefaultDB(fileBytes);
  }
  await resetLanguageToSystem(context);
  await updateSettings("databaseJustImported", true,
      pagesNeedingRefresh: [], updateGlobalState: false);
  return result.files.single.name;
}

Future importDB(BuildContext context, {ignoreOverwriteWarning = false}) async {
  dynamic result = ignoreOverwriteWarning == true
      ? true
      : await openPopup(
          context,
          icon: appStateSettings["outlinedIcons"]
              ? Icons.warning_outlined
              : Icons.warning_rounded,
          title: "data-overwrite-warning".tr(),
          description: "data-overwrite-warning-description".tr(),
          onCancel: () {
            Navigator.pop(context, false);
          },
          onCancelLabel: "cancel".tr(),
          onSubmit: () {
            Navigator.pop(context, true);
          },
          onSubmitLabel: "ok".tr(),
        );
  if (result == true) {
    await openPopup(
      context,
      icon: appStateSettings["outlinedIcons"]
          ? Icons.file_open_outlined
          : Icons.file_open_rounded,
      title: "select-backup-file".tr(),
      description: "select-backup-file-description".tr(),
      onSubmit: () {
        Navigator.pop(context);
      },
      onSubmitLabel: "ok".tr(),
    );
    await openLoadingPopupTryCatch(
      () async {
        return await importDBFileFromDevice(context);
      },
      onSuccess: (result) {
        if (result != null)
          restartAppPopup(
            context,
            description: kIsWeb
                ? "refresh-required-to-load-backup".tr()
                : "restart-required-to-load-backup".tr(),
            // codeBlock: result.toString(),
          );
      },
    );
  }
}

class ImportDB extends StatelessWidget {
  const ImportDB({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsContainer(
      onTap: () async {
        await importDB(context);
      },
      title: "import-data-file".tr(),
      icon: appStateSettings["outlinedIcons"]
          ? Icons.download_outlined
          : Icons.download_rounded,
    );
  }
}
