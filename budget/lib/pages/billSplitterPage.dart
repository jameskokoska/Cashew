import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:budget/colors.dart';
import 'package:budget/database/binary_string_conversion.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/pages/addBillSplitterTransactionPage.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addTransactionPage.dart';
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
import 'package:budget/widgets/tappable.dart';
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

class BillSplitterPage extends StatefulWidget {
  const BillSplitterPage({required this.billSplitter, Key? key})
      : super(key: key);

  final BillSplitter billSplitter;

  @override
  State<BillSplitterPage> createState() => _BillSplitterPageState();
}

class _BillSplitterPageState extends State<BillSplitterPage> {
  @override
  Widget build(BuildContext context) {
    return PageFramework(
      floatingActionButton: AnimatedScaleDelayed(
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomPaddingSafeArea),
          child: FAB(
            tooltip: "Add Entry",
            openPage: AddBillSplitterTransaction(
              title: "Add Entry",
            ),
          ),
        ),
      ),
      dragDownToDismiss: true,
      title: widget.billSplitter.name,
      navbar: false,
      appBarBackgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      appBarBackgroundColorStart: Theme.of(context).canvasColor,
      slivers: [
        StreamBuilder<List<BillSplitterTransaction>>(
          stream: database.watchAllBillSplitterTransactions(
              widget.billSplitter.billSplitterPk),
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
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    BillSplitterTransaction billSplitterTransaction =
                        snapshot.data![index];
                    return Tappable(
                      color: Theme.of(context).colorScheme.lightDarkAccent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [],
                      ),
                    );
                  },
                  childCount: snapshot.data?.length,
                ),
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
