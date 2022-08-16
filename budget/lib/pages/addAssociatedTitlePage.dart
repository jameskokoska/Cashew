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
    selectedTitle = title.trim();
    determineBottomButton();
    return;
  }

  void setSelectedCategory(TransactionCategory category) {
    setState(() {
      selectedCategory = category;
    });
    determineBottomButton();
    return;
  }

  Future addTitle() async {
    print("Added Title");
    int length = await database.getAmountOfAssociatedTitles();
    await database.createOrUpdateAssociatedTitle(
      TransactionAssociatedTitle(
        associatedTitlePk: widget.associatedTitle != null
            ? widget.associatedTitle!.associatedTitlePk
            : DateTime.now().millisecondsSinceEpoch,
        categoryFk: selectedCategory == null ? 0 : selectedCategory!.categoryPk,
        isExactMatch: false,
        title: selectedTitle ?? "",
        dateCreated: DateTime.now(),
        order: length,
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
        selectedTitle = widget.associatedTitle!.title;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        updateInitial();
      });
    } else {}
  }

  updateInitial() async {
    if (widget.associatedTitle != null) {
      setSelectedCategory(await database
          .getCategoryInstance(widget.associatedTitle!.categoryFk));
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  determineBottomButton() {
    if (selectedTitle != null &&
        selectedTitle != "" &&
        selectedCategory != null) {
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
    return PopupFramework(
      title: widget.title,
      child: Column(
        children: [
          Row(
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
                child: CategoryIcon(
                  categoryPk: selectedCategory?.categoryPk ?? 0,
                  category: selectedCategory,
                  size: 40,
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
          SizedBox(
            height: 15,
          ),
          canAddTitle ?? false
              ? Button(
                  label: widget.associatedTitle == null
                      ? "Add Title"
                      : "Save Changes",
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  onTap: () {
                    addTitle();
                  },
                )
              : Button(
                  label: widget.associatedTitle == null
                      ? "Add Title"
                      : "Save Changes",
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  onTap: () {},
                  color: Colors.grey,
                ),
        ],
      ),
    );
  }
}
