import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/transactionsListPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/categoryIcon.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:budget/colors.dart';
import 'package:math_expressions/math_expressions.dart';

class AddCategoryPage extends StatefulWidget {
  AddCategoryPage({
    Key? key,
    required this.title,
    this.category,
  }) : super(key: key);
  final String title;

  //When a transaction is passed in, we are editing that transaction
  final TransactionCategory? category;

  @override
  _AddCategoryPageState createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  String? selectedTitle;
  String? selectedImage = "image.png";
  Color? selectedColor;
  bool selectedIncome = false;
  int setCategoryPk = DateTime.now().millisecondsSinceEpoch;
  bool? canAddCategory;

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

  void setSelectedColor(Color? color) {
    setState(() {
      selectedColor = color;
    });
    determineBottomButton();
    return;
  }

  void setSelectedImage(String image) {
    setState(() {
      selectedImage = image.replaceFirst("assets/categories/", "");
    });
    determineBottomButton();
    return;
  }

  void setSelectedTitle(String title) {
    setState(() {
      selectedTitle = title;
    });
    determineBottomButton();
    return;
  }

  void setSelectedIncome(bool income) {
    setState(() {
      selectedIncome = income;
    });
    determineBottomButton();
    return;
  }

  determineBottomButton() {
    if (selectedTitle != null) {
      if (canAddCategory != true)
        this.setState(() {
          canAddCategory = true;
        });
    } else {
      if (canAddCategory != false)
        this.setState(() {
          canAddCategory = false;
        });
    }
  }

  Future addCategory() async {
    print("Added category" + (await createTransactionCategory()).toString());
    await database.createOrUpdateCategory(await createTransactionCategory());
    Navigator.pop(context);
  }

  Future<TransactionCategory> createTransactionCategory() async {
    return TransactionCategory(
      categoryPk:
          widget.category != null ? widget.category!.categoryPk : setCategoryPk,
      name: selectedTitle ?? "",
      dateCreated: widget.category != null
          ? widget.category!.dateCreated
          : DateTime.now(),
      income: selectedIncome,
      order: widget.category != null
          ? widget.category!.order
          : await database.getAmountOfCategories(),
      colour: toHexString(selectedColor),
      iconName: selectedImage,
    );
  }

  @override
  void initState() {
    super.initState();
    selectedColor = widget.category != null
        ? (widget.category!.colour == null
            ? null
            : HexColor(widget.category!.colour))
        : null;
    Future.delayed(Duration.zero, () {
      if (widget.category != null) {
        //We are editing a transaction
        //Fill in the information from the passed in transaction
        setState(() {
          selectedTitle = widget.category!.name;
          selectedImage = widget.category!.iconName;
          selectedIncome = widget.category!.income;
        });
      }
    });
    //Set to false because we can't save until we made some changes
    setState(() {
      canAddCategory = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.category != null) {
          discardChangesPopup(
            context,
            previousObject: widget.category,
            currentObject: await createTransactionCategory(),
          );
        } else {
          discardChangesPopup(context);
        }
        return false;
      },
      child: Scaffold(
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
                  if (widget.category != null) {
                    discardChangesPopup(
                      context,
                      previousObject: widget.category,
                      currentObject: await createTransactionCategory(),
                    );
                  } else {
                    discardChangesPopup(context);
                  }
                },
                onDragDownToDissmiss: () async {
                  if (widget.category != null) {
                    discardChangesPopup(
                      context,
                      previousObject: widget.category,
                      currentObject: await createTransactionCategory(),
                    );
                  } else {
                    discardChangesPopup(context);
                  }
                },
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
                                    colour: toHexString(selectedColor),
                                  ),
                                  size: 60,
                                  sizePadding: 25,
                                  canEditByLongPress: false,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Tappable(
                          onTap: !kIsWeb
                              ? () {
                                  selectTitle();
                                }
                              : null,
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
                                  child: kIsWeb
                                      ? TextInput(
                                          labelText: "Name",
                                          bubbly: false,
                                          initialValue: selectedTitle,
                                          onChanged: (text) {
                                            setSelectedTitle(text);
                                          },
                                          padding: EdgeInsets.zero,
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                          topContentPadding: 40,
                                        )
                                      : TextFont(
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
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .textLight
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .black,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 65,
                    child: SelectColor(
                      horizontalList: true,
                      selectedColor: selectedColor,
                      setSelectedColor: setSelectedColor,
                    ),
                  ),
                  SizedBox(height: 13),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 400),
                      child: IncomeTypeButton(
                        key: ValueKey(selectedIncome),
                        onTap: () {
                          setSelectedIncome(!selectedIncome);
                        },
                        selectedIncome: selectedIncome,
                      ),
                    ),
                  ),
                  SizedBox(height: 13),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFont(
                      text: "Associated Titles",
                      textColor: Theme.of(context).colorScheme.textLight,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFont(
                      text:
                          "If a transaction title contains any of the phrases listed, it will be added to this category",
                      textColor: Theme.of(context).colorScheme.textLight,
                      fontSize: 13,
                      maxLines: 10,
                    ),
                  ),
                  SizedBox(height: 10),
                  AddButton(onTap: () {
                    openBottomSheet(
                      context,
                      PopupFramework(
                        title: "Set Title",
                        child: SelectText(
                          setSelectedText: (_) {},
                          labelText: "Set Title",
                          placeholder: "Title",
                          nextWithInput: (text) async {
                            int length =
                                await database.getAmountOfAssociatedTitles();

                            await database.createOrUpdateAssociatedTitle(
                              TransactionAssociatedTitle(
                                associatedTitlePk:
                                    DateTime.now().millisecondsSinceEpoch,
                                categoryFk: widget.category == null
                                    ? setCategoryPk
                                    : widget.category!.categoryPk,
                                isExactMatch: false,
                                title: text.trim(),
                                dateCreated: DateTime.now(),
                                order: length,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }),
                  StreamBuilder<List<TransactionAssociatedTitle>>(
                      stream: database.watchAllAssociatedTitlesInCategory(
                        widget.category == null
                            ? setCategoryPk
                            : widget.category!.categoryPk,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.hasData &&
                            (snapshot.data ?? []).length > 0) {
                          List<Widget> associatedTitleWidgets = [];
                          for (int i = 0; i < snapshot.data!.length; i++) {
                            TransactionAssociatedTitle associatedTitle =
                                snapshot.data![i];
                            associatedTitleWidgets.add(
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                child: AssociatedTitleContainer(
                                  title: associatedTitle.title,
                                  setTitle: (text) async {
                                    await database
                                        .createOrUpdateAssociatedTitle(
                                      TransactionAssociatedTitle(
                                        associatedTitlePk:
                                            associatedTitle.associatedTitlePk,
                                        categoryFk: widget.category == null
                                            ? setCategoryPk
                                            : widget.category!.categoryPk,
                                        isExactMatch:
                                            associatedTitle.isExactMatch,
                                        title: text.trim(),
                                        dateCreated: DateTime.now(),
                                        order: associatedTitle.order,
                                      ),
                                    );
                                  },
                                  onDelete: () async {
                                    await database.deleteAssociatedTitle(
                                        snapshot.data![i].associatedTitlePk,
                                        snapshot.data![i].order);
                                  },
                                ),
                              ),
                            );
                          }
                          return Column(
                            children: [...associatedTitleWidgets],
                          );
                        }
                        return SizedBox();
                      }),
                  SizedBox(height: 80),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: canAddCategory ?? false
                    ? Button(
                        label: widget.category == null
                            ? "Add Category"
                            : "Save Changes",
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        onTap: () {
                          addCategory();
                        },
                        hasBottomExtraSafeArea: true,
                      )
                    : Button(
                        label: widget.category == null
                            ? "Add Category"
                            : "Save Changes",
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        onTap: () {},
                        color: Colors.grey,
                        hasBottomExtraSafeArea: true,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AssociatedTitleContainer extends StatefulWidget {
  const AssociatedTitleContainer(
      {Key? key,
      required this.title,
      required this.setTitle,
      required this.onDelete})
      : super(key: key);

  final String title;
  final Function(String) setTitle;
  final VoidCallback onDelete;

  @override
  State<AssociatedTitleContainer> createState() =>
      _AssociatedTitleContainerState();
}

class _AssociatedTitleContainerState extends State<AssociatedTitleContainer> {
  String title = "";

  @override
  void initState() {
    super.initState();
    title = widget.title;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Tappable(
        onTap: () {
          openBottomSheet(
            context,
            PopupFramework(
              title: "Set Title",
              child: SelectText(
                setSelectedText: (text) {
                  title = text;
                  widget.setTitle(text);
                },
                labelText: "Set Title",
                selectedText: title,
                placeholder: "Title",
              ),
            ),
          );
        },
        borderRadius: 15,
        color: Theme.of(context).colorScheme.lightDarkAccent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                child: TextFont(
                  text: widget.title,
                  fontSize: 18,
                ),
              ),
            ),
            Tappable(
              onTap: () async {
                await openPopup(
                  context,
                  title: "Delete Title?",
                  description: "Are you sure you want to delete this title?",
                  icon: Icons.delete_rounded,
                  onSubmitLabel: "Delete",
                  onSubmit: () {
                    Navigator.pop(context);
                    widget.onDelete();
                  },
                  onCancelLabel: "Cancel",
                  onCancel: () {
                    Navigator.pop(context);
                  },
                );
              },
              borderRadius: 15,
              color: Theme.of(context).colorScheme.lightDarkAccent,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Icon(
                  Icons.close_rounded,
                  size: 25,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddButton extends StatelessWidget {
  const AddButton({Key? key, required this.onTap}) : super(key: key);

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 15,
        right: 15,
        bottom: 9,
        top: 4,
      ),
      child: Tappable(
        color: Theme.of(context).colorScheme.background,
        borderRadius: 15,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              width: 1.5,
              color: Theme.of(context).colorScheme.lightDarkAccentHeavy,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          width: 110,
          height: 52,
          child: Center(
            child: TextFont(
              text: "+",
              fontWeight: FontWeight.bold,
              textColor: Theme.of(context).colorScheme.lightDarkAccentHeavy,
            ),
          ),
        ),
        onTap: () {
          onTap();
        },
      ),
    );
  }
}

class IncomeTypeButton extends StatelessWidget {
  const IncomeTypeButton(
      {Key? key, required this.onTap, required this.selectedIncome})
      : super(key: key);
  final VoidCallback onTap;
  final bool selectedIncome;
  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: onTap,
      borderRadius: 10,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: TextFont(
                text: selectedIncome == false ? "Expense" : "Income",
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
            ),
            ButtonIcon(
              onTap: onTap,
              icon: selectedIncome
                  ? Icons.move_to_inbox_rounded
                  : Icons.exit_to_app_rounded,
              size: 41,
            ),
          ],
        ),
      ),
    );
  }
}
