import 'dart:convert';

import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/dropdownSelect.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/progressBar.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter_charset_detector/flutter_charset_detector.dart';
import 'package:budget/widgets/framework/popupFramework.dart';

class ImportCSV extends StatefulWidget {
  const ImportCSV({Key? key}) : super(key: key);

  @override
  State<ImportCSV> createState() => _ImportCSVState();
}

class _ImportCSVState extends State<ImportCSV> {
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
        String csvString;
        if (kIsWeb) {
          List<int> fileBytes = result.files.single.bytes!;
          csvString = utf8.decode(fileBytes);
        } else {
          File file = File(result.files.single.path ?? "");
          Uint8List fileBytes = await file.readAsBytes();
          DecodingResult decoded = await CharsetDetector.autoDecode(fileBytes);
          csvString = decoded.string;
        }

        List<List<String>> fileContents = CsvToListConverter()
            .convert(csvString, eol: '\n', shouldParseNumbers: false);
        int maxColumns = fileContents.fold(0,
            (prev, element) => element.length > prev ? element.length : prev);

        // Add missing values to rows with fewer columns
        fileContents = fileContents
            .map((row) => row + List.filled(maxColumns - row.length, ""))
            .toList();

        List<String> headers = fileContents[0];
        List<String> firstEntry = fileContents[1];

        String dateFormat = "";
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
            "displayName": "Title",
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
            "canSelectCurrentWallet": true,
          },
        };
        for (dynamic key in assignedColumns.keys) {
          String setHeaderValue = determineInitialValue(
              assignedColumns[key]!["headerValues"],
              headers,
              assignedColumns[key]!["required"],
              assignedColumns[key]!["canSelectCurrentWallet"]);
          assignedColumns[key]!["setHeaderValue"] = setHeaderValue;
          assignedColumns[key]!["setHeaderIndex"] =
              _getHeaderIndex(headers, setHeaderValue);
        }

        Navigator.of(context).pop();

        openBottomSheet(
          context,
          PopupFramework(
            title: "Assign Columns",
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Table(
                        defaultColumnWidth: IntrinsicColumnWidth(),
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        children: <TableRow>[
                          TableRow(
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                            ),
                            children: <Widget>[
                              for (dynamic header in headers)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 11.0, vertical: 5),
                                  child: TextFont(
                                    text: header.toString(),
                                    fontWeight: FontWeight.bold,
                                    textColor: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                                )
                            ],
                          ),
                          TableRow(
                            decoration: BoxDecoration(
                                color: appStateSettings["materialYou"]
                                    ? Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer
                                    : getColor(
                                        context, "lightDarkAccentHeavy")),
                            children: <Widget>[
                              for (dynamic entry in firstEntry)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 11.0, vertical: 5),
                                  child: TextFont(
                                    text: entry.toString(),
                                    fontSize: 18,
                                    textColor: appStateSettings["materialYou"]
                                        ? Theme.of(context)
                                            .colorScheme
                                            .primaryContainer
                                        : getColor(context, "black"),
                                  ),
                                )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: appStateSettings["materialYou"]
                                  ? dynamicPastel(
                                      context,
                                      Theme.of(context)
                                          .colorScheme
                                          .secondaryContainer,
                                      amount: 0.2,
                                    )
                                  : getColor(
                                      context, "lightDarkAccentHeavyLight")),
                          child: Row(
                            children: [
                              Expanded(
                                child: Wrap(
                                  alignment: WrapAlignment.spaceBetween,
                                  runAlignment: WrapAlignment.spaceBetween,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        TextFont(
                                          text: "Date Format",
                                          fontSize: 15,
                                        ),
                                        TextFont(
                                          text: "Example: dd/MM/yyyy HH:mm",
                                          fontSize: 12,
                                          maxLines: 5,
                                        ),
                                        TextFont(
                                          text:
                                              "Not needed if the CSV uses proper date formatting",
                                          maxLines: 5,
                                          fontSize: 12,
                                        ),
                                        SizedBox(height: 10),
                                      ],
                                    ),
                                    Container(
                                      child: TextInput(
                                        labelText: "dd/MM/yyyy HH:mm",
                                        padding: EdgeInsets.zero,
                                        onChanged: (value) {
                                          dateFormat = value;
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      for (dynamic key in assignedColumns.keys)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: appStateSettings["materialYou"]
                                  ? dynamicPastel(
                                      context,
                                      Theme.of(context)
                                          .colorScheme
                                          .secondaryContainer,
                                      amount: 0.2,
                                    )
                                  : getColor(
                                      context, "lightDarkAccentHeavyLight"),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Wrap(
                                    alignment: WrapAlignment.spaceBetween,
                                    runAlignment: WrapAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      TextFont(
                                        text:
                                            assignedColumns[key]!["displayName"]
                                                .toString(),
                                        fontSize: 15,
                                      ),
                                      SizedBox(width: 10),
                                      DropdownSelect(
                                        compact: true,
                                        initial: assignedColumns[key]![
                                            "setHeaderValue"],
                                        items: assignedColumns[key]![
                                                    "canSelectCurrentWallet"] ==
                                                true
                                            ? ["~Current Wallet~", ...headers]
                                            : assignedColumns[key]!["required"]
                                                ? [
                                                    ...(assignedColumns[key]?[
                                                                "setHeaderValue"] ==
                                                            ""
                                                        ? [""]
                                                        : []),
                                                    ...headers
                                                  ]
                                                : ["~None~", ...headers],
                                        boldedValues: [
                                          "~Current Wallet~",
                                          "~None~"
                                        ],
                                        onChanged: (String setHeaderValue) {
                                          assignedColumns[key]![
                                                  "setHeaderValue"] =
                                              setHeaderValue;
                                          assignedColumns[key]![
                                                  "setHeaderIndex"] =
                                              _getHeaderIndex(
                                                  headers, setHeaderValue);
                                        },
                                        backgroundColor:
                                            Theme.of(context).canvasColor,
                                        checkInitialValue: true,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Button(
                  label: "import".tr(),
                  onTap: () async {
                    _importEntries(assignedColumns, dateFormat, fileContents);
                  },
                )
              ],
            ),
          ),
        );
      } else {
        throw "no-file-selected".tr();
      }
    } catch (e) {
      Navigator.of(context).pop();
      openPopup(
        context,
        title: "csv-error".tr(),
        description: e.toString(),
        icon: Icons.error_rounded,
        onSubmitLabel: "ok".tr(),
        onSubmit: () {
          Navigator.of(context).pop();
        },
        barrierDismissible: false,
      );
    }
  }

  Future<void> _importEntries(Map<String, Map<String, dynamic>> assignedColumns,
      String dateFormat, List<List<String>> fileContents) async {
    try {
      //Check to see if all the required parameters have been set
      for (dynamic key in assignedColumns.keys) {
        if (assignedColumns[key]!["setHeaderValue"] == "") {
          throw "Please make sure you select a parameter for each required field.";
        }
        print(assignedColumns[key]!["setHeaderIndex"]);
      }
    } catch (e) {
      throw (e.toString());
    }
    Navigator.of(context).pop();
    // Open the progress bar
    // This Widget opened will actually do the importing
    openPopupCustom(
      context,
      title: "Importing...",
      child: ImportingEntriesPopup(
        dateFormat: dateFormat,
        assignedColumns: assignedColumns,
        fileContents: fileContents,
        next: () {
          Navigator.of(context).pop();
          openPopup(
            context,
            icon: Icons.check_circle_outline_rounded,
            title: "done".tr() + "!",
            description: "Successfully imported " +
                fileContents.length.toString() +
                " transactions.",
            onSubmitLabel: "ok".tr(),
            onSubmit: () {
              Navigator.pop(context);
            },
            barrierDismissible: false,
          );
        },
      ),
      barrierDismissible: false,
    );
    return;
  }

  String determineInitialValue(List<String> headerValues, List<String> headers,
      bool required, bool? canSelectCurrentWallet) {
    for (String header in headers) {
      if (headerValues.contains(header.toLowerCase())) {
        return header;
      } else if (headerValues.contains(header.toLowerCase().trim())) {
        return header;
      }
    }
    if (canSelectCurrentWallet == true) {
      return "~Current Wallet~";
    }
    if (!required) {
      return "~None~";
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SettingsContainer(
          onTap: () async {
            await _chooseBackupFile();
          },
          title: "import-csv".tr(),
          description: "import-csv-description".tr(),
          icon: Icons.file_open_rounded,
        ),
      ],
    );
  }
}

class ImportingEntriesPopup extends StatefulWidget {
  const ImportingEntriesPopup({
    required this.assignedColumns,
    required this.dateFormat,
    required this.fileContents,
    required this.next,
    Key? key,
  }) : super(key: key);

  final Map<String, Map<String, dynamic>> assignedColumns;
  final String dateFormat;
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _importEntries(
        widget.assignedColumns, widget.dateFormat, widget.fileContents));
  }

  Future<void> _importEntry(Map<String, Map<String, dynamic>> assignedColumns,
      String dateFormat, List<String> row, int i) async {
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
    TransactionCategory selectedCategory;
    try {
      selectedCategory = await database.getCategoryInstanceGivenName(
          row[assignedColumns["category"]!["setHeaderIndex"]]);
    } catch (_) {
      // just make a new category, no point in checking associated titles - doesn't make much sense!

      // category not found, check titles
      // try {
      //   if (name != "") {
      //     List result = await getRelatingAssociatedTitle(name);
      //     TransactionAssociatedTitle? associatedTitle = result[0];
      //     if (associatedTitle == null) {
      //       throw ("Can't find a category that matched this title: " + name);
      //     }
      //     selectedCategory =
      //         await database.getCategoryInstance(associatedTitle.categoryFk);
      //   } else {
      //     throw ("error, just make a new category");
      //   }
      // } catch (e) {
      // print(e.toString());
      // just create a category
      int numberOfCategories =
          (await database.getTotalCountOfCategories())[0] ?? 0;
      await database.createOrUpdateCategory(
        TransactionCategory(
          categoryPk: DateTime.now().millisecondsSinceEpoch,
          name: row[assignedColumns["category"]!["setHeaderIndex"]],
          dateCreated: DateTime.now(),
          dateTimeModified: null,
          order: numberOfCategories,
          income: amount > 0,
          iconName: "image.png",
          methodAdded: MethodAdded.csv,
        ),
      );
      selectedCategory = await database.getCategoryInstanceGivenName(
          row[assignedColumns["category"]!["setHeaderIndex"]]);
      // }
    }
    categoryFk = selectedCategory.categoryPk;

    if (name != "") {
      // print("attempting to add " + name);
      await addAssociatedTitles(name, selectedCategory);
    }

    int walletFk = 0;
    if (assignedColumns["wallet"]!["setHeaderIndex"] == -1) {
      walletFk = appStateSettings["selectedWallet"];
    } else {
      try {
        walletFk = (await database.getWalletInstanceGivenName(
                row[assignedColumns["wallet"]!["setHeaderIndex"]]))
            .walletPk;
      } catch (e) {
        throw "Wallet not found! If you want to import to the current wallet, please select '~Current Wallet~'. Details: " +
            e.toString();
      }
    }

    DateTime dateCreated;
    try {
      dateCreated =
          DateTime.parse(row[assignedColumns["date"]!["setHeaderIndex"]]);
      dateCreated =
          DateTime(dateCreated.year, dateCreated.month, dateCreated.day);
    } catch (e) {
      // No custom date format entered
      if (dateFormat == "")
        throw "Failed to parse time! Details: " + e.toString();
      DateFormat format =
          DateFormat(dateFormat.toString(), context.locale.toString());
      try {
        dateCreated =
            format.parse(row[assignedColumns["date"]!["setHeaderIndex"]]);
        dateCreated =
            DateTime(dateCreated.year, dateCreated.month, dateCreated.day);
      } catch (e) {
        throw "Failed to parse time! Details: " + e.toString();
      }
    }

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
        dateTimeModified: null,
        income: income,
        paid: true,
        skipPaid: false,
        methodAdded: MethodAdded.csv,
      ),
    );

    return;
  }

  Future<void> _importEntries(Map<String, Map<String, dynamic>> assignedColumns,
      String dateFormat, List<List<String>> fileContents) async {
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
          await _importEntry(assignedColumns, dateFormat, row, i);
        });
      }
      widget.next();
    } catch (e) {
      openPopup(
        context,
        title: "csv-error".tr(),
        description: e.toString(),
        icon: Icons.error_rounded,
        onSubmitLabel: "ok".tr(),
        onSubmit: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
        barrierDismissible: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProgressBar(
      currentPercent: currentPercent,
      color: Theme.of(context).colorScheme.primary,
    );
  }
}
