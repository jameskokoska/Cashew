import 'dart:developer';
import 'dart:io';

import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/accountsPage.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/pages/addObjectivePage.dart';
import 'package:budget/pages/addWalletPage.dart';
import 'package:budget/pages/premiumPage.dart';
import 'package:budget/pages/sharedBudgetSettings.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/accountAndBackup.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/categoryIcon.dart';
import 'package:budget/widgets/globalSnackbar.dart';
import 'package:budget/widgets/incomeExpenseTabSelector.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/selectedTransactionsAppBar.dart';
import 'package:budget/widgets/sliverStickyLabelDivider.dart';
import 'package:budget/widgets/timeDigits.dart';
import 'package:budget/struct/initializeNotifications.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/radioItems.dart';
import 'package:budget/widgets/selectAmount.dart';
import 'package:budget/widgets/selectCategory.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/selectChips.dart';
import 'package:budget/widgets/saveBottomButton.dart';
import 'package:budget/widgets/transactionEntry/incomeAmountArrow.dart';
import 'package:budget/widgets/transactionEntry/transactionEntry.dart';
import 'package:budget/widgets/transactionEntry/transactionEntryTypeButton.dart';
import 'package:budget/widgets/transactionEntry/transactionLabel.dart';
import 'package:budget/widgets/util/contextMenu.dart';
import 'package:budget/widgets/util/showDatePicker.dart';
import 'package:budget/widgets/util/widgetSize.dart';
import 'package:budget/widgets/viewAllTransactionsButton.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:budget/colors.dart';
import 'package:flutter/services.dart' hide TextInput;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:budget/widgets/util/showTimePicker.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/struct/currencyFunctions.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:googleapis/drive/v3.dart' as drive;

Future<String?> getPhotoAndUpload({required ImageSource source}) async {
  dynamic result = await openLoadingPopupTryCatch(() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: source);
    if (photo == null) {
      if (source == ImageSource.camera) throw ("no-photo-taken".tr());
      if (source == ImageSource.gallery) throw ("no-file-selected".tr());
      throw ("error-getting-photo");
    }

    var fileBytes;
    late Stream<List<int>> mediaStream;
    fileBytes = await photo.readAsBytes();
    mediaStream = Stream.value(List<int>.from(fileBytes));

    try {
      return await uploadFileToDrive(
          fileBytes: fileBytes, fileName: photo.name, mediaStream: mediaStream);
    } catch (e) {
      print(
          "Error uploading file, trying again and requesting new permissions " +
              e.toString());
      await signOutGoogle();
      await signInGoogle(
          drivePermissions: true, drivePermissionsAttachments: true);
      return await uploadFileToDrive(
          fileBytes: fileBytes, fileName: photo.name, mediaStream: mediaStream);
    }
  }, onError: (e) {
    openSnackbar(
      SnackbarMessage(
        title: "error-attaching-file".tr(),
        description: e.toString(),
        icon: appStateSettings["outlinedIcons"]
            ? Icons.error_outlined
            : Icons.error_rounded,
      ),
    );
  });
  if (result is String) return result;
  return null;
}

Future<String?> getFileAndUpload() async {
  dynamic result = await openLoadingPopupTryCatch(() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result == null) throw ("no-file-selected".tr());

    Uint8List fileBytes;

    if (kIsWeb) {
      fileBytes = result.files.single.bytes!;
    } else {
      File file = File(result.files.single.path ?? "");
      fileBytes = await file.readAsBytes();
    }

    late Stream<List<int>> mediaStream;
    mediaStream = Stream.value(fileBytes);

    try {
      return await uploadFileToDrive(
        fileBytes: fileBytes,
        fileName: result.files.single.name,
        mediaStream: mediaStream,
      );
    } catch (e) {
      print(
          "Error uploading file, trying again and requesting new permissions " +
              e.toString());
      await signOutGoogle();
      await signInGoogle(
          drivePermissions: true, drivePermissionsAttachments: true);
      return await uploadFileToDrive(
        fileBytes: fileBytes,
        fileName: result.files.single.name,
        mediaStream: mediaStream,
      );
    }
  }, onError: (e) {
    openSnackbar(
      SnackbarMessage(
        title: "error-attaching-file".tr(),
        description: e.toString(),
        icon: appStateSettings["outlinedIcons"]
            ? Icons.error_outlined
            : Icons.error_rounded,
      ),
    );
  });
  if (result is String) return result;
  return null;
}

Future<String?> uploadFileToDrive({
  required Stream<List<int>> mediaStream,
  required Uint8List fileBytes,
  required String fileName,
}) async {
  if (googleUser == null) {
    await signInGoogle(
        drivePermissions: true, drivePermissionsAttachments: true);
  }

  final authHeaders = await googleUser!.authHeaders;
  final authenticateClient = GoogleAuthClient(authHeaders);
  final driveApi = drive.DriveApi(authenticateClient);

  String folderName = "Cashew";
  drive.FileList list = await driveApi.files.list(
      q: "mimeType='application/vnd.google-apps.folder' and name='$folderName'");
  String? folderId;
  for (var file in list.files!) {
    if (file.name == folderName) {
      folderId = file.id;
      break;
    }
  }

  if (folderId == null) {
    // If the folder doesn't exist, create it
    drive.File folder = drive.File();
    folder.name = folderName;
    folder.mimeType = "application/vnd.google-apps.folder";
    drive.File createdFolder = await driveApi.files.create(folder);
    folderId = createdFolder.id;
  }

  if (folderId == null) throw ("Folder could not be created in Google Drive");

  drive.Media media = new drive.Media(mediaStream, fileBytes.length);

  drive.File driveFile = new drive.File();
  String timestamp = DateFormat("yyyy-MM-dd-hhmmss").format(DateTime.now());
  driveFile.name = timestamp + fileName;
  driveFile.modifiedTime = DateTime.now().toUtc();
  driveFile.parents = [folderId];

  drive.File driveFileCreated =
      await driveApi.files.create(driveFile, uploadMedia: media);

  // Only if we want attachments to be publicly available
  // drive.Permission permission = drive.Permission();
  // permission.role = "reader";
  // await driveApi.permissions.create(
  //   permission,
  //   driveFileCreated.id!,
  //   sendNotificationEmail: false,
  // );

  // Retrieve the updated metadata for the file with permissions
  drive.File fileOnDrive = await driveApi.files.get(driveFileCreated.id!,
      $fields: "id, name, webViewLink, permissions") as drive.File;

  return fileOnDrive.webViewLink;
}
