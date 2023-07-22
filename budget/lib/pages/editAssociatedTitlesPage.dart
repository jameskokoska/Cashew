import 'package:budget/database/tables.dart';
import 'package:budget/pages/addAssociatedTitlePage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/categoryIcon.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/globalSnackBar.dart';
import 'package:budget/widgets/noResults.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' hide SliverReorderableList;
import 'package:flutter/services.dart' hide TextInput;
import 'package:budget/widgets/editRowEntry.dart';
import 'package:budget/modified/reorderable_list.dart';

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
  String searchValue = "";

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      database.fixOrderAssociatedTitles();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (searchValue != "") {
          setState(() {
            searchValue = "";
          });
          return false;
        } else {
          return true;
        }
      },
      child: PageFramework(
        horizontalPadding: getHorizontalPaddingConstrained(context),
        dragDownToDismiss: true,
        dragDownToDismissEnabled: dragDownToDismissEnabled,
        title: widget.title,
        floatingActionButton: AnimateFABDelayed(
          fab: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewPadding.bottom),
            child: FAB(
              tooltip: "add-title".tr(),
              openPage: AddAssociatedTitlePage(),
              onTap: () {
                openBottomSheet(
                  context,
                  AddAssociatedTitlePage(),
                );
              },
            ),
          ),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TextInput(
                labelText: "search-titles-placeholder".tr(),
                icon: Icons.search_rounded,
                onSubmitted: (value) {
                  setState(() {
                    searchValue = value;
                  });
                },
                onChanged: (value) {
                  setState(() {
                    searchValue = value;
                  });
                },
                autoFocus: false,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SettingsContainerSwitch(
              title: "ask-for-transaction-title".tr(),
              description: "ask-for-transaction-title-description".tr(),
              onSwitched: (value) {
                updateSettings(
                  "askForTransactionTitle",
                  value,
                );
              },
              initialValue: appStateSettings["askForTransactionTitle"],
              icon: Icons.text_fields_rounded,
            ),
          ),
          SliverToBoxAdapter(
            child: SettingsContainerSwitch(
              title: "auto-add-titles".tr(),
              description: "auto-add-titles-description".tr(),
              onSwitched: (value) {
                updateSettings("autoAddAssociatedTitles", value,
                    pagesNeedingRefresh: [], updateGlobalState: false);
              },
              initialValue: appStateSettings["autoAddAssociatedTitles"],
              icon: Icons.add_box_rounded,
            ),
          ),
          StreamBuilder<Map<int, TransactionCategory>>(
              stream: database.watchAllCategoriesMapped(),
              builder: (context, mappedCategoriesSnapshot) {
                return StreamBuilder<List<TransactionAssociatedTitle>>(
                  stream: database.watchAllAssociatedTitles(
                      searchFor: searchValue == "" ? null : searchValue),
                  builder: (context, snapshot) {
                    // print(snapshot.data);
                    if (snapshot.hasData && (snapshot.data ?? []).length <= 0) {
                      return SliverToBoxAdapter(
                        child: NoResults(
                          message: "No associated category titles found.",
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
                            canReorder: searchValue == "" &&
                                (snapshot.data ?? []).length != 1,
                            onTap: () {
                              openBottomSheet(
                                context,
                                AddAssociatedTitlePage(
                                  associatedTitle: associatedTitle,
                                ),
                              );
                            },
                            padding: EdgeInsets.symmetric(
                                vertical: 7, horizontal: 7),
                            currentReorder:
                                currentReorder != -1 && currentReorder != index,
                            index: index,
                            content: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(width: 3),
                                CategoryIcon(
                                  categoryPk: associatedTitle.categoryFk,
                                  size: 25,
                                  margin: EdgeInsets.zero,
                                  sizePadding: 20,
                                  borderRadius: 1000,
                                  category: mappedCategoriesSnapshot
                                      .data![associatedTitle.categoryFk],
                                ),
                                SizedBox(width: 15),
                                Expanded(
                                  child: TextFont(
                                    text: associatedTitle.title
                                    // +
                                    //     " - " +
                                    //     associatedTitle.order.toString()
                                    ,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 19,
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
                                onCancelLabel: "cancel".tr(),
                                onSubmit: () async {
                                  await database.deleteAssociatedTitle(
                                      associatedTitle.associatedTitlePk,
                                      associatedTitle.order);
                                  Navigator.pop(context);
                                  openSnackbar(
                                    SnackbarMessage(
                                        title: "deleted".tr() +
                                            " " +
                                            associatedTitle.title,
                                        icon: Icons.delete),
                                  );
                                },
                                onSubmitLabel: "delete".tr(),
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
                                oldTitle.associatedTitlePk,
                                _intNew,
                                oldTitle.order);
                          }

                          return true;
                        },
                      );
                    }
                    return SliverToBoxAdapter(
                      child: Container(),
                    );
                  },
                );
              }),
          SliverToBoxAdapter(
            child: SizedBox(height: 85),
          ),
        ],
      ),
    );
  }
}
