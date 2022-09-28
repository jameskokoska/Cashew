import 'dart:developer';

import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addAssociatedTitlePage.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addWalletPage.dart';
import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/globalSnackBar.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditAssociatedTitlesPage extends StatefulWidget {
  EditAssociatedTitlesPage({
    Key? key,
    required this.title,
  }) : super(key: key);
  final String title;

  @override
  _EditAssociatedTitlesPageState createState() =>
      _EditAssociatedTitlesPageState();
}

class _EditAssociatedTitlesPageState extends State<EditAssociatedTitlesPage> {
  bool dragDownToDismissEnabled = true;
  int currentReorder = -1;
  @override
  Widget build(BuildContext context) {
    return PageFramework(
      dragDownToDismiss: true,
      dragDownToDismissEnabled: dragDownToDismissEnabled,
      title: widget.title,
      navbar: false,
      floatingActionButton: AnimatedScaleDelayed(
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomPaddingSafeArea),
          child: FAB(
            tooltip: "Add Title",
            openPage: AddAssociatedTitlePage(
              title: "Add Title",
            ),
            onTap: () {
              openBottomSheet(
                context,
                AddAssociatedTitlePage(
                  title: "Add Title",
                ),
                resizeForKeyboard: false,
              );
            },
          ),
        ),
      ),
      slivers: [
        SliverToBoxAdapter(
          child: SettingsContainerSwitch(
            title: "Automatically Add Titles",
            description: "When a transaction is created",
            onSwitched: (value) {
              updateSettings("autoAddAssociatedTitles", value,
                  pagesNeedingRefresh: [], updateGlobalState: false);
            },
            initialValue: appStateSettings["autoAddAssociatedTitles"],
            icon: Icons.add_box_rounded,
          ),
        ),
        StreamBuilder<List<TransactionAssociatedTitle>>(
          stream: database.watchAllAssociatedTitles(),
          builder: (context, snapshot) {
            print(snapshot.data);
            if (snapshot.hasData && (snapshot.data ?? []).length <= 0) {
              return SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 85, right: 15, left: 15),
                    child: TextFont(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        text: "No associated category titles."),
                  ),
                ),
              );
            }
            if (snapshot.hasData && (snapshot.data ?? []).length > 0) {
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
                  TransactionAssociatedTitle associatedTitle =
                      snapshot.data![index];
                  return EditRowEntry(
                    onTap: () {
                      openBottomSheet(
                        context,
                        AddAssociatedTitlePage(
                          title: "Add Title",
                          associatedTitle: associatedTitle,
                        ),
                        resizeForKeyboard: false,
                      );
                    },
                    padding: EdgeInsets.symmetric(vertical: 7, horizontal: 7),
                    currentReorder:
                        currentReorder != -1 && currentReorder != index,
                    index: index,
                    backgroundColor:
                        Theme.of(context).colorScheme.lightDarkAccent,
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CategoryIcon(
                          categoryPk: associatedTitle.categoryFk,
                          size: 25,
                          margin: EdgeInsets.zero,
                          sizePadding: 20,
                          borderRadius: 15,
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: TextFont(
                            text: associatedTitle.title +
                                " - " +
                                associatedTitle.order.toString(),
                            fontWeight: FontWeight.bold,
                            fontSize: 21,
                            maxLines: 10,
                          ),
                        ),
                      ],
                    ),
                    onDelete: () {
                      openPopup(
                        context,
                        title: "Delete " + associatedTitle.title + "?",
                        icon: Icons.delete_rounded,
                        onCancel: () {
                          Navigator.pop(context);
                        },
                        onCancelLabel: "Cancel",
                        onSubmit: () async {
                          await database.deleteAssociatedTitle(
                              associatedTitle.associatedTitlePk,
                              associatedTitle.order);
                          Navigator.pop(context);
                          openSnackbar(
                            SnackbarMessage(
                                title: "Deleted " + associatedTitle.title,
                                icon: Icons.delete),
                          );
                        },
                        onSubmitLabel: "Delete",
                      );
                    },
                    openPage: Container(),
                    key: ValueKey(index),
                  );
                },
                itemCount: snapshot.data!.length,
                onReorder: (_intPrevious, _intNew) async {
                  TransactionAssociatedTitle oldTitle =
                      snapshot.data![_intPrevious];

                  _intNew = snapshot.data!.length - _intNew;
                  _intPrevious = snapshot.data!.length - _intPrevious;

                  if (_intNew > _intPrevious) {
                    await database.moveAssociatedTitle(
                        oldTitle.associatedTitlePk,
                        _intNew - 1,
                        oldTitle.order);
                  } else {
                    await database.moveAssociatedTitle(
                        oldTitle.associatedTitlePk, _intNew, oldTitle.order);
                  }
                },
              );
            }
            return SliverToBoxAdapter(
              child: Container(),
            );
          },
        ),
      ],
    );
  }
}
