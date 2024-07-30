import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/globalSnackbar.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/outlinedButtonStacked.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/statusBox.dart';
import 'package:budget/widgets/util/saveFile.dart';
import 'package:budget/widgets/util/showDatePicker.dart';
import 'package:drift/drift.dart' hide Column, Table;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:budget/widgets/framework/popupFramework.dart';

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

String cleanFileNameString(String inputString) {
  final invalidChars = [
    ' ',
    '\\',
    '/',
    '?',
    '%',
    '*',
    ':',
    '|',
    '"',
    '<',
    '>',
    '.'
  ];

  for (var char in invalidChars) {
    inputString = inputString.replaceAll(char, '-');
  }

  // Trim any leading or trailing hyphens
  inputString = inputString.trim().replaceAll(RegExp('^-+|-+\$'), '');

  return inputString;
}

class ExportCSV extends StatelessWidget {
  const ExportCSV({super.key});

  Future exportCSV({
    required BuildContext boxContext,
    required DateTimeRange? dateTimeRange,
  }) async {
    await openLoadingPopupTryCatch(() async {
      List<Map<String, String>> output = [];
      List<TransactionWithCategory> transactions = await database
          .getAllTransactionsWithCategoryWalletBudgetObjectiveSubCategory(
        (tbl) =>
            tbl.paid.equals(true) &
            database.onlyShowBasedOnTimeRange(
              tbl,
              dateTimeRange?.start,
              dateTimeRange?.end,
              null,
            ),
      );
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

      String fileName;
      if (dateTimeRange != null) {
        fileName = "cashew-" +
            (DateTime.now().millisecondsSinceEpoch).toString() +
            "-" +
            dateTimeRange.start.year.toString() +
            "-" +
            dateTimeRange.start.month.toString() +
            "-" +
            dateTimeRange.start.day.toString() +
            "-to-" +
            dateTimeRange.end.year.toString() +
            "-" +
            dateTimeRange.end.month.toString() +
            "-" +
            dateTimeRange.end.day.toString() +
            ".csv";
      } else {
        fileName =
            "cashew-" + cleanFileNameString(DateTime.now().toString()) + ".csv";
      }

      await saveCSV(boxContext: boxContext, csv: csv, fileName: fileName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (boxContext) {
      return SettingsContainer(
        onTap: () async {
          await openBottomSheet(
            context,
            PopupFramework(
              title: "export-csv".tr(),
              child: Column(
                children: [
                  StatusBox(
                    title: "export-csv-warning".tr(),
                    description: "export-csv-warning-description".tr(),
                    color: Colors.orange,
                    padding: EdgeInsetsDirectional.zero,
                    smallIcon: appStateSettings["outlinedIcons"]
                        ? Icons.warning_outlined
                        : Icons.warning_rounded,
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButtonStacked(
                          text: "all-time".tr().capitalizeFirstofEach,
                          iconData: appStateSettings["outlinedIcons"]
                              ? Icons.calendar_month_outlined
                              : Icons.calendar_month_rounded,
                          onTap: () async {
                            Navigator.pop(context);
                            await exportCSV(
                                boxContext: boxContext, dateTimeRange: null);
                          },
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: OutlinedButtonStacked(
                          text: "date-range".tr().capitalizeFirstofEach,
                          iconData: appStateSettings["outlinedIcons"]
                              ? Icons.date_range_outlined
                              : Icons.date_range_rounded,
                          onTap: () async {
                            Navigator.pop(context);
                            DateTimeRangeOrAllTime? dateRange =
                                await showCustomDateRangePicker(
                              context,
                              null,
                              vibrantButtonColors: true,
                              initialEntryMode:
                                  DatePickerEntryMode.calendarOnly,
                            );
                            if (dateRange.dateTimeRange == null) {
                              openSnackbar(
                                SnackbarMessage(
                                  icon: appStateSettings["outlinedIcons"]
                                      ? Icons.event_busy_outlined
                                      : Icons.event_busy_rounded,
                                  title: "date-not-selected".tr(),
                                ),
                              );
                            } else {
                              await exportCSV(
                                boxContext: boxContext,
                                dateTimeRange: dateRange.dateTimeRange,
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
        title: "export-csv".tr(),
        icon: appStateSettings["outlinedIcons"]
            ? Icons.file_present_outlined
            : Icons.file_present_rounded,
      );
    });
  }
}
