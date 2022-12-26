import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/categoryIcon.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:flutter/material.dart';

class SelectCategory extends StatefulWidget {
  SelectCategory({
    Key? key,
    this.setSelectedCategory,
    this.setSelectedCategories,
    this.selectedCategory,
    this.selectedCategories,
    this.next,
    this.skipIfSet,
    this.nextLabel,
    this.horizontalList = false,
    this.popRoute = true,
    this.showSelectedAllCategoriesIfNoneSelected = false,
  }) : super(key: key);
  final Function(TransactionCategory)? setSelectedCategory;
  final Function(List<TransactionCategory>)? setSelectedCategories;
  final TransactionCategory? selectedCategory;
  final List<TransactionCategory>? selectedCategories;
  final VoidCallback? next;
  final bool? skipIfSet;
  final String? nextLabel;
  final bool horizontalList;
  final bool popRoute;
  final bool showSelectedAllCategoriesIfNoneSelected;

  @override
  _SelectCategoryState createState() => _SelectCategoryState();
}

class _SelectCategoryState extends State<SelectCategory> {
  List<TransactionCategory> selectedCategories = [];
  bool updatedInitial = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 0), () {
      if (widget.selectedCategory != null && widget.skipIfSet == true) {
        if (widget.popRoute) Navigator.pop(context);
        if (widget.next != null) {
          widget.next!();
        }
      }
    });
    setInitialCategories();
  }

  setInitialCategories() {
    if (widget.selectedCategories != null) {
      setState(() {
        selectedCategories = widget.selectedCategories ?? [];
      });
    } else if (widget.selectedCategory != null) {
      setState(() {
        selectedCategories.add(
          widget.selectedCategory ??
              TransactionCategory(
                categoryPk: 1,
                name: "",
                dateCreated: DateTime.now(),
                income: false,
                order: 0,
              ),
        );
      });
    }
  }

  //find the selected category using selectedCategory
  @override
  Widget build(BuildContext context) {
    if (updatedInitial == false &&
        (widget.selectedCategory != null ||
            widget.selectedCategories != null)) {
      setInitialCategories();
      setState(() {
        updatedInitial = true;
      });
    }

    return StreamBuilder<List<TransactionCategory>>(
        stream: database.watchAllCategories(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (widget.horizontalList) {
              List<Widget> children = [];
              int index = 0;
              for (TransactionCategory category in snapshot.data!) {
                children.add(Padding(
                  padding: EdgeInsets.only(
                      left: index == 0
                          ? 12 -
                              (widget.showSelectedAllCategoriesIfNoneSelected
                                  ? 4
                                  : 0)
                          : 0,
                      right: index == snapshot.data!.length - 1 ? 12 - 4 : 0),
                  child: CategoryIcon(
                    categoryPk: category.categoryPk,
                    size: 50,
                    label: true,
                    onTap: () {
                      if (widget.setSelectedCategory != null) {
                        widget.setSelectedCategory!(category);
                        setState(() {
                          selectedCategories = [];
                          selectedCategories.add(category);
                        });
                        Future.delayed(Duration(milliseconds: 70), () {
                          if (widget.popRoute) Navigator.pop(context);
                          if (widget.next != null) {
                            widget.next!();
                          }
                        });
                      } else if (widget.setSelectedCategories != null) {
                        if (selectedCategories.contains(category)) {
                          setState(() {
                            selectedCategories.remove(category);
                          });
                          widget.setSelectedCategories!(selectedCategories);
                        } else {
                          setState(() {
                            selectedCategories.add(category);
                          });
                          widget.setSelectedCategories!(selectedCategories);
                        }
                      }
                    },
                    sharedIconOffset: 13,
                    outline: selectedCategories.contains(category),
                  ),
                ));
                index++;
              }
              return ListView(
                addAutomaticKeepAlives: true,
                clipBehavior: Clip.none,
                scrollDirection: Axis.horizontal,
                children: [
                  widget.showSelectedAllCategoriesIfNoneSelected
                      ? Padding(
                          key: ValueKey(1),
                          padding: const EdgeInsets.only(
                            top: 8,
                            left: 20,
                          ),
                          child: Column(
                            children: [
                              Tappable(
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                                onTap: () {
                                  if (widget.setSelectedCategories != null) {
                                    widget.setSelectedCategories!([]);
                                  }
                                  setState(() {
                                    selectedCategories = [];
                                  });
                                },
                                borderRadius: 18,
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 250),
                                  decoration: selectedCategories.isEmpty
                                      ? BoxDecoration(
                                          border: Border.all(
                                            color: dynamicPastel(
                                                context,
                                                Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                amountLight: 0.5,
                                                amountDark: 0.4,
                                                inverse: true),
                                            width: 3,
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(18)),
                                        )
                                      : BoxDecoration(
                                          border: Border.all(
                                            color: Colors.transparent,
                                            width: 0,
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15)),
                                        ),
                                  width: 70,
                                  height: 70,
                                  child: Center(
                                    child: Icon(
                                      Icons.category_rounded,
                                      size: 35,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 4),
                                width: 60,
                                child: Center(
                                  child: TextFont(
                                    textAlign: TextAlign.center,
                                    text: "All",
                                    fontSize: 10,
                                    maxLines: 1,
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      : SizedBox.shrink(),
                  ...children,
                  Padding(
                    key: ValueKey(2),
                    padding: const EdgeInsets.only(
                      bottom: 21,
                      top: 8,
                      right: 20,
                    ),
                    child: AddButton(
                      onTap: () {},
                      padding: EdgeInsets.zero,
                      openPage: AddCategoryPage(
                        title: "Add Category",
                      ),
                      width: 70,
                    ),
                  ),
                ],
              );
            }
            double size = MediaQuery.of(context).size.width <= 400
                ? (MediaQuery.of(context).size.width - 200) / 4
                : 45;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                children: [
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        ...snapshot.data!
                            .asMap()
                            .map(
                              (index, category) => MapEntry(
                                index,
                                CategoryIcon(
                                  categoryPk: category.categoryPk,
                                  size: size,
                                  label: true,
                                  onTap: () {
                                    if (widget.setSelectedCategory != null) {
                                      widget.setSelectedCategory!(category);
                                      setState(() {
                                        selectedCategories = [];
                                        selectedCategories.add(category);
                                      });
                                      Future.delayed(Duration(milliseconds: 70),
                                          () {
                                        if (widget.popRoute)
                                          Navigator.pop(context);
                                        if (widget.next != null) {
                                          widget.next!();
                                        }
                                      });
                                    } else if (widget.setSelectedCategories !=
                                        null) {
                                      if (selectedCategories
                                          .contains(category)) {
                                        setState(() {
                                          selectedCategories.remove(category);
                                        });
                                        widget.setSelectedCategories!(
                                            selectedCategories);
                                      } else {
                                        setState(() {
                                          selectedCategories.add(category);
                                        });
                                        widget.setSelectedCategories!(
                                            selectedCategories);
                                      }
                                    }
                                  },
                                  outline:
                                      selectedCategories.contains(category),
                                ),
                              ),
                            )
                            .values
                            .toList(),
                        Padding(
                          key: ValueKey(2),
                          padding: const EdgeInsets.only(
                            top: 8,
                            right: 8,
                            left: 8,
                          ),
                          child: AddButton(
                            onTap: () {},
                            padding: EdgeInsets.zero,
                            openPage: AddCategoryPage(
                              title: "Add Category",
                            ),
                            width: size + 20,
                            height: size + 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  widget.nextLabel != null
                      ? Column(
                          children: [
                            Container(height: 15),
                            AnimatedSwitcher(
                              duration: Duration(milliseconds: 500),
                              child: selectedCategories.length > 0
                                  ? Button(
                                      key: Key("addSuccess"),
                                      label: widget.nextLabel ?? "",
                                      width: MediaQuery.of(context).size.width,
                                      height: 50,
                                      onTap: () {
                                        if (widget.next != null) {
                                          widget.next!();
                                        }
                                      },
                                    )
                                  : Button(
                                      key: Key("addNoSuccess"),
                                      label: widget.nextLabel ?? "",
                                      width: MediaQuery.of(context).size.width,
                                      height: 50,
                                      onTap: () {},
                                      color: Colors.grey,
                                    ),
                            )
                          ],
                        )
                      : Container()
                ],
              ),
            );
          } else {
            return Container();
          }
        });
  }
}
