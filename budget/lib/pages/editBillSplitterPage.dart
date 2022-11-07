import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:budget/colors.dart';
import 'package:budget/database/binary_string_conversion.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/billSplitterPage.dart';
import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/pages/editCategoriesPage.dart';
import 'package:budget/pages/editWalletsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/accountAndBackup.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/editRowEntry.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/globalSnackBar.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/popupFramework.dart';
import 'package:budget/widgets/selectCategoryImage.dart';
import 'package:budget/widgets/selectColor.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:budget/main.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart' as signIn;
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;
import 'dart:math' as math;
import 'package:file_picker/file_picker.dart';
import '../functions.dart';

class EditBillSplitterPage extends StatefulWidget {
  const EditBillSplitterPage({Key? key}) : super(key: key);

  @override
  State<EditBillSplitterPage> createState() => _EditBillSplitterPageState();
}

class _EditBillSplitterPageState extends State<EditBillSplitterPage> {
  bool dragDownToDismissEnabled = true;
  int currentReorder = -1;

  @override
  Widget build(BuildContext context) {
    return PageFramework(
      dragDownToDismissEnabled: dragDownToDismissEnabled,
      floatingActionButton: AnimatedScaleDelayed(
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomPaddingSafeArea),
          child: FAB(
            tooltip: "Add Bill",
            openPage: SizedBox.shrink(),
            onTap: () {
              openBottomSheet(
                context,
                PopupFramework(
                  title: "Enter Title",
                  child: SelectText(
                    setSelectedText: (_) {},
                    labelText: "Title",
                    selectedText: "",
                    nextWithInput: (input) async {
                      int length = await database.getAmountOfBillSplitters();
                      await database.createOrUpdateBillSplitter(
                        BillSplitter(
                          billSplitterPk: DateTime.now().millisecondsSinceEpoch,
                          name: input.trim(),
                          dateCreated: DateTime.now(),
                          order: length,
                        ),
                      );
                    },
                  ),
                ),
                snap: false,
              );
            },
          ),
        ),
      ),
      dragDownToDismiss: true,
      title: "Bill Splitter",
      navbar: false,
      appBarBackgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      appBarBackgroundColorStart: Theme.of(context).canvasColor,
      slivers: [
        StreamBuilder<List<BillSplitter>>(
          stream: database.watchAllBillSplitters(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.length <= 0) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 85, right: 15, left: 15),
                      child: TextFont(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          text: "No bills."),
                    ),
                  ),
                );
              }
              return SliverReorderableList(
                onReorderStart: (index) {
                  HapticFeedback.heavyImpact();
                  setState(() {
                    dragDownToDismissEnabled = false;
                    currentReorder = index;
                  });
                },
                onReorderEnd: (_) {
                  setState(() {
                    dragDownToDismissEnabled = true;
                    currentReorder = -1;
                  });
                },
                itemBuilder: (context, index) {
                  BillSplitter billSplitter = snapshot.data![index];
                  return EditRowEntry(
                    canReorder: (snapshot.data ?? []).length != 1,
                    padding: EdgeInsets.symmetric(vertical: 7, horizontal: 7),
                    currentReorder:
                        currentReorder != -1 && currentReorder != index,
                    index: index,
                    backgroundColor:
                        Theme.of(context).colorScheme.lightDarkAccent,
                    content: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFont(
                            text: billSplitter.name +
                                " - " +
                                billSplitter.order.toString(),
                            fontWeight: FontWeight.bold,
                            fontSize: 21,
                            maxLines: 10,
                          ),
                          TextFont(
                            text: getWordedDateShortMore(
                                billSplitter.dateCreated),
                            fontSize: 15,
                            maxLines: 10,
                            textColor: Theme.of(context).colorScheme.textLight,
                          ),
                        ],
                      ),
                    ),
                    onDelete: () {
                      openPopup(
                        context,
                        title: "Delete " + billSplitter.name + "?",
                        icon: Icons.delete_rounded,
                        onCancel: () {
                          Navigator.pop(context);
                        },
                        onCancelLabel: "Cancel",
                        onSubmit: () async {
                          await database.deleteBillSplitter(
                              billSplitter.billSplitterPk,
                              billSplitter.billSplitterPk);
                          Navigator.pop(context);
                          openSnackbar(
                            SnackbarMessage(
                                title: "Deleted " + billSplitter.name,
                                icon: Icons.delete),
                          );
                        },
                        onSubmitLabel: "Delete",
                      );
                    },
                    openPage: BillSplitterPage(billSplitter: billSplitter),
                    key: ValueKey(index),
                  );
                },
                itemCount: snapshot.data!.length,
                onReorder: (_intPrevious, _intNew) async {
                  BillSplitter oldBillSplitter = snapshot.data![_intPrevious];

                  _intNew = snapshot.data!.length - _intNew;
                  _intPrevious = snapshot.data!.length - _intPrevious;

                  if (_intNew > _intPrevious) {
                    await database.moveBillSplitter(
                        oldBillSplitter.billSplitterPk,
                        _intNew - 1,
                        oldBillSplitter.order);
                  } else {
                    await database.moveBillSplitter(
                        oldBillSplitter.billSplitterPk,
                        _intNew,
                        oldBillSplitter.order);
                  }
                },
              );
            } else {
              return SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 85, right: 15, left: 15),
                    child: TextFont(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        text: "No bills."),
                  ),
                ),
              );
            }
          },
        ),
        // Wipe all remaining pixels off - sometimes graphics artifacts are left behind
        SliverToBoxAdapter(
          child: Container(height: 70, color: Theme.of(context).canvasColor),
        ),
      ],
    );
  }
}
