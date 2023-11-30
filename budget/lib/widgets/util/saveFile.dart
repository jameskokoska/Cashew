import 'dart:convert';
import 'dart:io';

import 'package:budget/functions.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/globalSnackBar.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' show AnchorElement;

// On Android -> Save file to device downloads -> Save file to folder -> Share file
// On Web -> Download file via web
// On iOS -> Share file

Future<bool> saveFile({
  // Wrap the caller in a builder and pass its context
  required BuildContext boxContext,
  // One of dataStore or dataString
  required List<int>? dataStore,
  required String? dataString,
  required String fileName,
  required String successMessage,
  required String errorMessage,
  String? customDirectory,
  bool shareFile = false,
}) async {
  if (dataStore == null && dataString == null) {
    throw ("Both arguments cannot be null");
  }
  if (kIsWeb) {
    try {
      String base64String = base64Encode(
          dataStore != null ? dataStore : utf8.encode(dataString!));
      AnchorElement anchor = AnchorElement(
          href: 'data:application/octet-stream;base64,$base64String')
        ..download = fileName
        ..style.display = 'none';
      anchor.click();
      openSnackbar(SnackbarMessage(
        title: successMessage,
        description: fileName,
        icon: appStateSettings["outlinedIcons"]
            ? Icons.download_done_outlined
            : Icons.download_done_rounded,
      ));
      return true;
    } catch (e) {
      openSnackbar(SnackbarMessage(
        title: errorMessage,
        description: e.toString(),
        icon: appStateSettings["outlinedIcons"]
            ? Icons.warning_outlined
            : Icons.warning_rounded,
      ));
      print("Error saving file to device: " + e.toString());
      return false;
    }
  }

  if (shareFile || getPlatform() == PlatformOS.isIOS) {
    try {
      int lastIndex = fileName.lastIndexOf('.');
      String? fileExtension;
      if (lastIndex != -1 && lastIndex < fileName.length - 1) {
        fileExtension = fileName.substring(lastIndex + 1);
      }
      List<XFile> files = [];
      if (dataStore != null) {
        Uint8List convertedDataStore = Uint8List.fromList(dataStore);
        files = [
          XFile.fromData(
            convertedDataStore,
            name: fileName,
            mimeType: fileExtension,
          )
        ];
      } else if (dataString != null) {
        Uint8List convertedDataString =
            Uint8List.fromList(utf8.encode(dataString));
        files = [
          XFile.fromData(
            convertedDataString,
            name: fileName,
            mimeType: fileExtension,
          )
        ];
      }

      final box = boxContext.findRenderObject() as RenderBox?;
      if (box != null) {
        ShareResult result = await Share.shareXFiles(
          files,
          subject: fileName,
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
        );
        if (result.status != ShareResultStatus.success) {
          throw ("No application selected");
        }
      } else {
        throw ("Share sheet origin could not be found!");
      }

      openSnackbar(SnackbarMessage(
        title: successMessage.tr(),
        description: fileName,
        icon: appStateSettings["outlinedIcons"]
            ? Icons.download_done_outlined
            : Icons.download_done_rounded,
        timeout: Duration(milliseconds: 5000),
      ));
      return true;
    } catch (e) {
      openSnackbar(SnackbarMessage(
        title: errorMessage.tr(),
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
    String directory = customDirectory ??
        (getPlatform() == PlatformOS.isAndroid
            ? "/storage/emulated/0/Download"
            : (await getApplicationDocumentsDirectory()).path);

    String filePath = "${directory}/${fileName}";
    File savedFile = File(filePath);
    if (dataStore != null) {
      await savedFile.writeAsBytes(dataStore);
    } else if (dataString != null) {
      await savedFile.writeAsString(dataString);
    }

    openSnackbar(SnackbarMessage(
      title: successMessage.tr(),
      description: filePath,
      icon: appStateSettings["outlinedIcons"]
          ? Icons.download_done_outlined
          : Icons.download_done_rounded,
      timeout: Duration(milliseconds: 5000),
    ));
    return true;
  } catch (e) {
    if (customDirectory == null) {
      // Try again with selecting a custom directory
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) {
        openSnackbar(SnackbarMessage(
          title: errorMessage.tr(),
          description: "no-folder-selected".tr(),
          icon: appStateSettings["outlinedIcons"]
              ? Icons.warning_outlined
              : Icons.warning_rounded,
        ));
        print("Error saving file to device: " + e.toString());
        return false;
      } else {
        return await saveFile(
          boxContext: boxContext,
          dataStore: dataStore,
          dataString: dataString,
          fileName: fileName,
          successMessage: successMessage,
          errorMessage: errorMessage,
          customDirectory: selectedDirectory,
        );
      }
    } else {
      return await saveFile(
        boxContext: boxContext,
        dataStore: dataStore,
        dataString: dataString,
        fileName: fileName,
        successMessage: successMessage,
        errorMessage: errorMessage,
        shareFile: true,
      );
    }
  }
}
