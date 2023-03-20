import 'package:budget/database/tables.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/categoryIcon.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/popupFramework.dart';
import 'package:budget/widgets/selectCategory.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:flutter/material.dart';
import 'dart:async';

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

  late FocusNode _focusNode;

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
        title: selectedTitle?.trim() ?? "",
        dateCreated: DateTime.now(),
        dateTimeModified: null,
        order: widget.associatedTitle != null
            ? widget.associatedTitle!.order
            : length,
      ),
    );
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    _focusNode = new FocusNode();
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
    // requestLateAutoFocus
    if (widget.associatedTitle == null)
      _focusNode.requestFocus();
    else
      Future.delayed(Duration(milliseconds: 250), () {
        _focusNode.requestFocus();
      });
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
                        next: () => _focusNode.requestFocus(),
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
                          next: () => _focusNode.requestFocus(),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: TextInput(
                  labelText: "Title",
                  bubbly: false,
                  initialValue: selectedTitle,
                  onChanged: (text) {
                    setSelectedTitle(text);
                  },
                  padding: EdgeInsets.only(left: 7, right: 7),
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  topContentPadding: 0,
                  focusNode: _focusNode,
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
