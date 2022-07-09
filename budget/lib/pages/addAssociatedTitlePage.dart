import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/categoryEntry.dart';
import 'package:budget/widgets/dropdownSelect.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/popupFramework.dart';
import 'package:budget/widgets/radioItems.dart';
import 'package:budget/widgets/selectAmount.dart';
import 'package:budget/widgets/selectCategory.dart';
import 'package:budget/widgets/selectColor.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:budget/struct/transactionCategory.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:budget/colors.dart';
import 'package:math_expressions/math_expressions.dart';

class AddAssociatedTitlePage extends StatefulWidget {
  AddAssociatedTitlePage({
    Key? key,
    required this.title,
    this.associatedTitle,
  }) : super(key: key);
  final String title;

  //When a Title is passed in, we are editing that Title
  final TransactionAssociatedTitle? associatedTitle;

  @override
  _AddAssociatedTitlePageState createState() => _AddAssociatedTitlePageState();
}

class _AddAssociatedTitlePageState extends State<AddAssociatedTitlePage> {
  bool? canAddTitle;

  String? selectedTitle;
  TransactionCategory? selectedCategory;

  String? textAddTitle = "Add Title";

  Future<void> selectTitle() async {
    openBottomSheet(
      context,
      PopupFramework(
        title: "Enter Title",
        child: SelectText(
          setSelectedText: setSelectedTitle,
          labelText: "Title",
          selectedText: selectedTitle,
        ),
      ),
      snap: false,
    );
  }

  void setSelectedTitle(String title) {
    selectedTitle = title;
    determineBottomButton();
    return;
  }

  void setSelectedCategory(TransactionCategory category) {
    setState(() {
      selectedCategory = category;
    });
    return;
  }

  Future addTitle() async {
    print("Added Title");
    int numberOfAssociatedTitles =
        (await database.getTotalCountOfAssociatedTitles())[0] ?? 0;
    await database.createOrUpdateAssociatedTitle(
      TransactionAssociatedTitle(
        associatedTitlePk: widget.associatedTitle != null
            ? widget.associatedTitle!.associatedTitlePk
            : DateTime.now().millisecondsSinceEpoch,
        categoryFk: selectedCategory == null ? 0 : selectedCategory!.categoryPk,
        isExactMatch: false,
        title: selectedTitle ?? "",
        dateCreated: DateTime.now(),
        order: numberOfAssociatedTitles,
      ),
    );
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    if (widget.associatedTitle != null) {
      //We are editing a Title
      textAddTitle = "Edit Title";
      //Fill in the information from the passed in Title
      setState(() {
        // selectedColor = HexColor(widget.Title!.colour);
        // selectedTitle = widget.Title!.name;
      });
    } else {}
  }

  @override
  void dispose() {
    super.dispose();
  }

  determineBottomButton() {
    if (selectedTitle != null && selectedCategory != null) {
      if (canAddTitle != true)
        this.setState(() {
          canAddTitle = true;
        });
    } else {
      if (canAddTitle != false)
        this.setState(() {
          canAddTitle = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Tappable(
                borderRadius: 15,
                onTap: () {
                  openBottomSheet(
                    context,
                    PopupFramework(
                      title: "Select Category",
                      child: SelectCategory(
                        selectedCategory: selectedCategory,
                        setSelectedCategory: setSelectedCategory,
                      ),
                    ),
                  );
                },
                color: Colors.transparent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      child: CategoryIcon(
                        key: ValueKey(selectedCategory?.categoryPk ?? ""),
                        categoryPk: selectedCategory?.categoryPk ?? 0,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TappableTextEntry(
                  title: selectedTitle,
                  placeholder: "Title",
                  onTap: () {
                    selectTitle();
                  },
                  autoSizeText: true,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: canAddTitle ?? false
              ? Button(
                  label: "Add Title",
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  onTap: () {
                    addTitle();
                  },
                )
              : Button(
                  label: "Add Title",
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  onTap: () {
                    addTitle();
                  },
                  color: Colors.grey,
                ),
        ),
      ],
    );
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () {
          //Minimize keyboard when tap non interactive widget
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Stack(
          children: [
            PageFramework(
              title: widget.title,
              navbar: false,
              onBackButton: () async {
                if (widget.associatedTitle != null)
                  discardChangesPopup(context);
                else
                  Navigator.pop(context);
              },
              onDragDownToDissmiss: () async {
                if (widget.associatedTitle != null)
                  discardChangesPopup(context);
                else
                  Navigator.pop(context);
              },
              listWidgets: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Tappable(
                        borderRadius: 15,
                        onTap: () {
                          openBottomSheet(
                            context,
                            PopupFramework(
                              title: "Select Category",
                              child: SelectCategory(
                                selectedCategory: selectedCategory,
                                setSelectedCategory: setSelectedCategory,
                              ),
                            ),
                          );
                        },
                        color: Colors.transparent,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedSwitcher(
                              duration: Duration(milliseconds: 300),
                              child: CategoryIcon(
                                key: ValueKey(
                                    selectedCategory?.categoryPk ?? ""),
                                categoryPk: selectedCategory?.categoryPk ?? 0,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TappableTextEntry(
                          title: selectedTitle,
                          placeholder: "Title",
                          onTap: () {
                            selectTitle();
                          },
                          autoSizeText: true,
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: canAddTitle ?? false
                  ? Button(
                      label: "Add Title",
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      onTap: () {
                        addTitle();
                      },
                    )
                  : Button(
                      label: "Add Title",
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      onTap: () {
                        addTitle();
                      },
                      color: Colors.grey,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
