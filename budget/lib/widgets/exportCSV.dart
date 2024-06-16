import 'dart:convert';

import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/dropdownSelect.dart';
import 'package:budget/widgets/globalSnackbar.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/progressBar.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/util/saveFile.dart';
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
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:io';
import 'package:budget/struct/randomConstants.dart';
import 'package:universal_html/html.dart' show AnchorElement;
import 'package:file_picker/file_picker.dart';

Future saveCSV(
    {required BuildContext boxContext,
    required String csv,
    required String fileName}) async {
  return await saveFile(
    boxContext: boxContext,
    dataStore: null,
    dataString: csv,
    fileName: fileName,
    successMessage: "csv-saved-success".tr(),
    errorMessage: "error-exporting".tr(),
  );
}

Map<String, String> createRowOutput(
  TransactionWithCategory transactionWithCategory,
  Map<String, String Function(TransactionWithCategory)> lookups,
) {
  Map<String, String> output = {};
  for (String key in lookups.keys) {
    String entry = lookups[key]!(transactionWithCategory);
    output[key] = entry;
  }
  return output;
}

class ExportCSV extends StatelessWidget {
  const ExportCSV({super.key});

  Future exportCSV({required BuildContext boxContext}) async {
    await openLoadingPopupTryCatch(() async {
      List<Map<String, String>> output = [];
      List<TransactionWithCategory> transactions = await database
          .getAllTransactionsWithCategoryWalletBudgetObjectiveSubCategory(
              (tbl) => tbl.paid.equals(true));
      for (TransactionWithCategory transactionWithCategory in transactions) {
        Map<
            String,
            String Function(
                TransactionWithCategory transactionWithCategory)> lookups = {
          "account": (transactionWithCategory) =>
              transactionWithCategory.wallet?.name ?? "",
          "amount": (transactionWithCategory) =>
              transactionWithCategory.transaction.amount.toString(),
          "currency": (transactionWithCategory) =>
              (transactionWithCategory.wallet?.currency ?? "").allCaps,
          "title": (transactionWithCategory) =>
              transactionWithCategory.transaction.name,
          "note": (transactionWithCategory) =>
              transactionWithCategory.transaction.note,
          "date": (transactionWithCategory) =>
              transactionWithCategory.transaction.dateCreated.toString(),
          "income": (transactionWithCategory) =>
              transactionWithCategory.transaction.income.toString(),
          "type": (transactionWithCategory) =>
              transactionWithCategory.transaction.type.toString(),
          "category name": (transactionWithCategory) =>
              transactionWithCategory.category.name,
          "subcategory name": (transactionWithCategory) =>
              transactionWithCategory.subCategory?.name ?? "",
          "color": (transactionWithCategory) =>
              transactionWithCategory.category.colour ?? "",
          "icon": (transactionWithCategory) =>
              transactionWithCategory.category.iconName ?? "",
          "emoji": (transactionWithCategory) =>
              transactionWithCategory.category.emojiIconName ?? "",
          "budget": (transactionWithCategory) =>
              transactionWithCategory.budget?.name ?? "",
          "objective": (transactionWithCategory) =>
              transactionWithCategory.objective?.name ?? "",
        };
        Map<String, String> outMap =
            createRowOutput(transactionWithCategory, lookups);

        output.add(outMap);
      }

      List<List<dynamic>> csvData = [];
      csvData.add(output.first.keys.toList()); // Add first row headers
      csvData.addAll(output.map((map) => map.values.toList()));
      // print(csvData);
      String csv = ListToCsvConverter().convert(csvData);

      String fileName = "cashew-" +
          DateTime.now()
              .toString()
              .replaceAll(".", "-")
              .replaceAll("-", "-")
              .replaceAll(" ", "-")
              .replaceAll(":", "-") +
          ".csv";
      await saveCSV(boxContext: boxContext, csv: csv, fileName: fileName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (boxContext) {
      return SettingsContainer(
        onTap: () async {
          await openPopup(
            context,
            barrierDismissible: false,
            onSubmit: () {
              Navigator.pop(context);
            },
            onSubmitLabel: "ok".tr(),
            icon: appStateSettings["outlinedIcons"]
                ? Icons.warning_amber_outlined
                : Icons.warning_amber_rounded,
            title: "export-csv-warning".tr(),
            description: "export-csv-warning-description".tr(),
          );
          await exportCSV(boxContext: boxContext);
        },
        title: "export-csv".tr(),
        icon: appStateSettings["outlinedIcons"]
            ? Icons.file_present_outlined
            : Icons.file_present_rounded,
      );
    });
  }
}
