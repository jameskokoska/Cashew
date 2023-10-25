import 'package:budget/database/tables.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/categoryIcon.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/selectCategory.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class AddAssociatedTitlePage extends StatefulWidget {
  AddAssociatedTitlePage({
    Key? key,
    this.associatedTitle,
  }) : super(key: key);

  //When a Title is passed in, we are editing that Title
  final TransactionAssociatedTitle? associatedTitle;

  @override
  _AddAssociatedTitlePageState createState() => _AddAssociatedTitlePageState();
}

class _AddAssociatedTitlePageState extends State<AddAssociatedTitlePage> {
  bool? canAddTitle;

  String? selectedTitle;
  TransactionCategory? selectedCategory;

  late FocusNode _focusNode;

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
      insert: widget.associatedTitle == null,
      TransactionAssociatedTitle(
        associatedTitlePk: widget.associatedTitle != null
            ? widget.associatedTitle!.associatedTitlePk
            : "-1",
        categoryFk:
            selectedCategory == null ? "0" : selectedCategory!.categoryPk,
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
      title:
          widget.associatedTitle == null ? "add-title".tr() : "edit-title".tr(),
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
                      title: "select-category".tr(),
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
                  category: selectedCategory,
                  size: getIsFullScreen(context) ? 40 : 30,
                  onTap: () {
                    openBottomSheet(
                      context,
                      PopupFramework(
                        title: "select-category".tr(),
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
                  labelText: "title-placeholder".tr(),
                  bubbly: false,
                  initialValue: selectedTitle,
                  onChanged: (text) {
                    setSelectedTitle(text);
                  },
                  padding: EdgeInsets.only(left: 7, right: 7),
                  fontSize: getIsFullScreen(context) ? 25 : 23,
                  fontWeight: FontWeight.bold,
                  topContentPadding: 0,
                  focusNode: _focusNode,
                  autoFocus: kIsWeb && getIsFullScreen(context),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 12,
          ),
          canAddTitle ?? false
              ? Button(
                  label: widget.associatedTitle == null
                      ? "add-title".tr()
                      : "save-changes".tr(),
                  width: MediaQuery.sizeOf(context).width,
                  onTap: () async {
                    await addTitle();
                  },
                )
              : Button(
                  label: widget.associatedTitle == null
                      ? "add-title".tr()
                      : "save-changes".tr(),
                  width: MediaQuery.sizeOf(context).width,
                  onTap: () {},
                  color: Colors.grey,
                ),
        ],
      ),
    );
  }
}
