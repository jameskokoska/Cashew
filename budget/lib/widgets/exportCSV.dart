import 'dart:convert';

import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
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
import 'package:file_picker/file_picker.dart';

Future saveCSV(
  String csv,
  String fileName, {
  String? customDirectory,
}) async {
  if (kIsWeb) {
    try {
      List<int> dataStore = utf8.encode(csv);
      String base64String = base64Encode(dataStore);
      AnchorElement anchor = AnchorElement(
          href: 'data:application/octet-stream;base64,$base64String')
        ..download = fileName
        ..style.display = 'none';
      anchor.click();
      openSnackbar(SnackbarMessage(
        title: "csv-saved-success".tr(),
        description: fileName,
        icon: appStateSettings["outlinedIcons"]
            ? Icons.download_done_outlined
            : Icons.download_done_rounded,
      ));
      return true;
    } catch (e) {
      openSnackbar(SnackbarMessage(
        title: "error-exporting".tr(),
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
    await savedFile.writeAsString(csv);

    openSnackbar(SnackbarMessage(
      title: "csv-saved-success".tr(),
      description: filePath,
      icon: appStateSettings["outlinedIcons"]
          ? Icons.download_done_outlined
          : Icons.download_done_rounded,
      timeout: Duration(milliseconds: 5000),
    ));
    return true;
  } catch (e) {
    if (customDirectory == null) {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) {
        openSnackbar(SnackbarMessage(
          title: "error-exporting".tr(),
          description: "no-folder-selected".tr(),
          icon: appStateSettings["outlinedIcons"]
              ? Icons.warning_outlined
              : Icons.warning_rounded,
        ));
        print("Error saving file to device: " + e.toString());
        return false;
      } else {
        return await saveCSV(csv, fileName, customDirectory: selectedDirectory);
      }
    } else {
      openSnackbar(SnackbarMessage(
        title: "error-exporting".tr(),
        description: e.toString(),
        icon: appStateSettings["outlinedIcons"]
            ? Icons.warning_outlined
            : Icons.warning_rounded,
      ));
      print("Error saving file to device: " + e.toString());
      return false;
    }
  }
}

Map<String, String> convertStringToMap(String inputString,
    {List<String> keysToIgnore = const [],
    List<String>? keysToShow,
    Map<String, String> keysToReplace = const {}}) {
  // Find the index of the first "(" character
  final startIndex = inputString.indexOf("(");

  if (startIndex != -1) {
    // Remove everything before the first "(" character, including it
    inputString = inputString.substring(startIndex + 1);

    // Remove the last character ")"
    inputString = inputString.substring(0, inputString.length - 1);

    // Split by comma and space
    List<String> parts = inputString.split(", ");

    // Create a Map to store key-value pairs
    Map<String, String> resultMap = {};

    // Iterate through the parts and split each part by ": "
    for (String part in parts) {
      // print(part);
      List<String> keyValue = part.split(": ");
      if (keyValue.length >= 2) {
        String key = keyValue[0].trim();
        if (keysToShow != null && keysToShow.contains(key) == false) continue;
        if (keysToIgnore.contains(key)) continue;
        if (keysToReplace.keys.contains(key) && keysToReplace[key] != null)
          key = keysToReplace[key] ?? "";
        String value = keyValue[1].trim();

        // Remove the key from the string
        int index = part.indexOf(": ");
        if (index != -1) {
          value = part.substring(index);
          value = value.replaceFirst(": ", "");
        }

        if (value == "null") value = "";

        resultMap[key] = value;
      }
    }

    return resultMap;
  } else {
    if (keysToShow != null) {
      Map<String, String> out = {};
      for (String keyIteration in keysToShow) {
        String key = keyIteration;
        if (keysToReplace.keys.contains(key) && keysToReplace[key] != null)
          key = keysToReplace[key] ?? "";
        out[key] = "";
      }
      return out;
    }
    return {};
  }
}

class ExportCSV extends StatelessWidget {
  const ExportCSV({super.key});

  Future exportCSV() async {
    await openLoadingPopupTryCatch(() async {
      List<Map<String, String>> output = [];
      List<TransactionWithCategory> transactions = await database
          .getAllTransactionsWithCategoryWalletBudgetObjectiveSubCategory(
              (tbl) => tbl.paid.equals(true));
      for (TransactionWithCategory transactionWithCategory in transactions) {
        String inputTransactionString =
            transactionWithCategory.transaction.toString();
        String inputCategoryString =
            transactionWithCategory.category.toString();
        String inputWalletString = transactionWithCategory.wallet.toString();
        String inputBudgetString = transactionWithCategory.budget.toString();
        String inputObjectiveString =
            transactionWithCategory.objective.toString();
        String inputSubcategoryString =
            transactionWithCategory.subCategory.toString();
        Map<String, String> merged = {
          ...convertStringToMap(
            inputTransactionString,
            keysToIgnore: [
              "transactionPk",
              "categoryFk",
              "walletFk",
              "dateTimeModified",
              "transactionOwnerEmail",
              "transactionOriginalOwnerEmail",
              "sharedKey",
              "sharedOldKey",
              "sharedStatus",
              "sharedDateUpdated",
              "sharedReferenceBudgetPk",
              "paid",
              "createdAnotherFutureTransaction",
              "skipPaid",
              "originalDateDue",
              "upcomingTransactionNotification",
              "objectiveFk",
              "subCategoryFk",
            ],
            keysToReplace: {
              "dateCreated": "date",
            },
          ),
          ...convertStringToMap(
            inputCategoryString,
            keysToIgnore: [
              "categoryPk",
              "dateTimeModified",
              "order",
              "income",
              "methodAdded",
              "mainCategoryPk"
            ],
            keysToReplace: {
              "dateCreated": "categoryDateCreated",
              "name": "categoryName",
            },
          ),
          ...convertStringToMap(
            inputSubcategoryString,
            keysToShow: [
              "name",
            ],
            keysToReplace: {
              "name": "subcategoryName",
            },
          ),
          ...convertStringToMap(
            inputWalletString,
            keysToIgnore: [
              "walletPk",
              "dateTimeModified",
              "dateCreated",
              "colour",
              "order",
              "iconName",
              "decimals",
              "homePageWidgetDisplay",
            ],
            keysToReplace: {
              "name": "accountName", //"walletName"
            },
          ),
          ...convertStringToMap(
            inputBudgetString,
            keysToShow: [
              "name",
            ],
            keysToReplace: {
              "name": "budgetName",
            },
          ),
          ...convertStringToMap(
            inputObjectiveString,
            keysToShow: [
              "name",
            ],
            keysToReplace: {
              "name": "objectiveName",
            },
          ),
        };
        output.add(merged);
      }

      List<List<dynamic>> csvData = [];
      csvData.add(output.first.keys.toList()); // Add first row headers
      csvData.addAll(output.map((map) => map.values.toList()));
      String csv = ListToCsvConverter().convert(csvData);

      String fileName = "cashew-" +
          DateTime.now()
              .toString()
              .replaceAll(".", "-")
              .replaceAll("-", "-")
              .replaceAll(" ", "-")
              .replaceAll(":", "-") +
          ".csv";
      await saveCSV(csv, fileName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SettingsContainer(
      onTap: () async {
        await openPopup(
          context,
          barrierDismissible: false,
          onSubmit: () {
            Navigator.pop(context);
          },
          onSubmitLabel: "ok".tr(),
          icon: Icons.warning_amber,
          title: "export-csv-warning".tr(),
          description: "export-csv-warning-description".tr(),
        );
        await exportCSV();
      },
      title: "export-csv".tr(),
      icon: appStateSettings["outlinedIcons"]
          ? Icons.file_present_outlined
          : Icons.file_present_rounded,
    );
  }
}
