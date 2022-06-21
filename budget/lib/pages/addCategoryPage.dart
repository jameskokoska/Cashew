import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/transactionsListPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/popupFramework.dart';
import 'package:budget/widgets/selectAmount.dart';
import 'package:budget/widgets/selectCategory.dart';
import 'package:budget/widgets/selectCategoryImage.dart';
import 'package:budget/widgets/selectColor.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:budget/struct/transactionCategory.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:budget/colors.dart';
import 'package:math_expressions/math_expressions.dart';

class AddCategoryPage extends StatefulWidget {
  AddCategoryPage({
    Key? key,
    required this.title,
    this.transaction,
  }) : super(key: key);
  final String title;

  //When a transaction is passed in, we are editing that transaction
  final Transaction? transaction;

  @override
  _AddCategoryPageState createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  String? selectedTitle;
  String? selectedImage = "image.png";
  Color? selectedColor;

  String? textAddTransaction = "Add Transaction";

  Future<void> selectTitle() async {
    openBottomSheet(
      context,
      PopupFramework(
        title: "Enter Name",
        child: SelectText(
          setSelectedText: setSelectedTitle,
          labelText: "Name",
          selectedText: selectedTitle,
        ),
      ),
      snap: false,
    );
  }

  void setSelectedColor(Color color) {
    setState(() {
      selectedColor = color;
    });
    return;
  }

  void setSelectedImage(String image) {
    setState(() {
      selectedImage = image.replaceFirst("assets/categories/", "");
    });
    return;
  }

  void setSelectedTitle(String title) {
    setState(() {
      selectedTitle = title;
    });
    return;
  }

  void setSelectedTitleController(String title) {
    setTextInput(_titleInputController, title);
    selectedTitle = title;
    return;
  }

  Future addCategory() async {
    print("Added category");
    await database.createOrUpdateCategory(
      TransactionCategory(
        categoryPk: widget.transaction != null
            ? widget.transaction!.transactionPk
            : DateTime.now().millisecondsSinceEpoch,
        name: selectedTitle ?? "",
        dateCreated: DateTime.now(),
        income: false,
        order: await database.getAmountOfCategories(),
        colour: toHexString(selectedColor ?? Colors.white),
        iconName: selectedImage,
      ),
    );
  }

  late TextEditingController _titleInputController;
  late TextEditingController _dateInputController;
  late TextEditingController _noteInputController;

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      //We are editing a transaction
      //Fill in the information from the passed in transaction
      _titleInputController =
          new TextEditingController(text: widget.transaction!.name);
      _noteInputController =
          new TextEditingController(text: widget.transaction!.note);
      _dateInputController = new TextEditingController(
          text: getWordedDate(widget.transaction!.dateCreated));
      selectedTitle = widget.transaction!.name;

      // var amountString = widget.transaction!.amount.toStringAsFixed(2);
      // if (amountString.substring(amountString.length - 2) == "00") {
      //   selectedAmountCalculation =
      //       amountString.substring(0, amountString.length - 3);
      // } else {
      //   selectedAmountCalculation = amountString;
      // }
      textAddTransaction = "Edit Transaction";

      WidgetsBinding.instance.addPostFrameCallback((_) {
        updateInitial();
      });
    } else {
      _titleInputController = new TextEditingController();
      _dateInputController = new TextEditingController(text: "Today");
      _noteInputController = new TextEditingController();
    }
  }

  updateInitial() async {
    if (widget.transaction != null) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
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
              listWidgets: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Tappable(
                      onTap: () {
                        openBottomSheet(
                          context,
                          PopupFramework(
                            title: "Select Icon",
                            child: SelectCategoryImage(
                              setSelectedImage: setSelectedImage,
                              selectedImage: "assets/categories/" +
                                  selectedImage.toString(),
                            ),
                          ),
                        );
                      },
                      color: Colors.transparent,
                      child: Container(
                        height: 136,
                        padding: const EdgeInsets.only(left: 17, right: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedSwitcher(
                              duration: Duration(milliseconds: 300),
                              child: CategoryIcon(
                                key: ValueKey((selectedImage ?? "") +
                                    selectedColor.toString()),
                                categoryPk: 0,
                                category: TransactionCategory(
                                  categoryPk: 0,
                                  name: "",
                                  dateCreated: DateTime.now(),
                                  order: 0,
                                  income: false,
                                  iconName: selectedImage,
                                  colour:
                                      toHexString(selectedColor ?? Colors.red),
                                ),
                                size: 60,
                                sizePadding: 25,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Tappable(
                        onTap: () {
                          selectTitle();
                        },
                        color: Colors.transparent,
                        child: Container(
                          height: 136,
                          alignment: Alignment.centerLeft,
                          child: Container(
                            height: 55,
                            width: MediaQuery.of(context).size.width - 150,
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      width: 1.5,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .lightDarkAccentHeavy)),
                            ),
                            child: IntrinsicWidth(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: TextFont(
                                  autoSizeText: true,
                                  maxLines: 1,
                                  minFontSize: 16,
                                  textAlign: TextAlign.left,
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold,
                                  text: selectedTitle == null ||
                                          selectedTitle == ""
                                      ? "Name"
                                      : selectedTitle ?? "",
                                  textColor: selectedTitle == null ||
                                          selectedTitle == ""
                                      ? Theme.of(context).colorScheme.textLight
                                      : Theme.of(context).colorScheme.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      Container(
                        height: 65,
                        child: SelectColor(
                          horizontalList: true,
                          selectedColor: selectedColor,
                          setSelectedColor: setSelectedColor,
                        ),
                      ),
                      Container(height: 20),
                      Container(height: 20),
                      Container(height: 100),
                    ],
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Button(
                label: "Add Category",
                width: MediaQuery.of(context).size.width,
                height: 50,
                onTap: () {
                  addCategory();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DateButton extends StatelessWidget {
  const DateButton({Key? key, required this.onTap, required this.selectedDate})
      : super(key: key);
  final VoidCallback onTap;
  final DateTime selectedDate;
  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: onTap,
      borderRadius: 10,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: TextFont(
                text: getWordedDate(selectedDate),
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            ButtonIcon(onTap: onTap, icon: Icons.calendar_month_rounded),
          ],
        ),
      ),
    );
  }
}
