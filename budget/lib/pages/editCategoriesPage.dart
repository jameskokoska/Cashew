import 'dart:developer';

import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:flutter/material.dart';

class EditCategoriesPage extends StatefulWidget {
  EditCategoriesPage({
    Key? key,
    required this.title,
  }) : super(key: key);
  final String title;

  @override
  _EditCategoriesPageState createState() => _EditCategoriesPageState();
}

class _EditCategoriesPageState extends State<EditCategoriesPage> {
  @override
  Widget build(BuildContext context) {
    return PageFramework(
      title: widget.title,
      navbar: false,
      floatingActionButton: AnimatedScaleDelayed(
        child: FAB(
          tooltip: "Add Category",
          openPage: AddCategoryPage(
            title: "Add Category",
          ),
        ),
      ),
      slivers: [
        StreamBuilder<List<TransactionCategory>>(
          stream: database.watchAllCategories(),
          builder: (context, snapshot) {
            if (snapshot.hasData && (snapshot.data ?? []).length > 0) {
              return SliverReorderableList(
                itemBuilder: (context, index) {
                  return CategoryRowEntry(
                    category: snapshot.data![index],
                    index: index,
                    key: ValueKey(index),
                  );
                },
                itemCount: snapshot.data!.length,
                onReorder: (_intPrevious, _intNew) async {
                  TransactionCategory oldCategory =
                      snapshot.data![_intPrevious];

                  if (_intNew > _intPrevious) {
                    await database.moveCategory(
                        oldCategory.categoryPk, _intNew - 1, oldCategory.order);
                  } else {
                    await database.moveCategory(
                        oldCategory.categoryPk, _intNew, oldCategory.order);
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

class CategoryRowEntry extends StatelessWidget {
  const CategoryRowEntry(
      {required this.index, required this.category, Key? key})
      : super(key: key);
  final int index;
  final TransactionCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: EdgeInsets.only(left: 10, right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: HexColor(category.colour),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CategoryIcon(
                categoryPk: category.categoryPk,
                size: 40,
                category: category,
              ),
              TextFont(text: category.name + " - " + category.order.toString()),
            ],
          ),
          Row(
            children: [
              Tappable(
                color: Colors.transparent,
                borderRadius: 50,
                child: Container(
                    width: 40, height: 50, child: Icon(Icons.delete_rounded)),
                onTap: () {
                  openPopup(context,
                      description: "Delete " + category.name + "?",
                      icon: Icons.delete_rounded,
                      onCancel: () {
                        Navigator.pop(context);
                      },
                      onCancelLabel: "Cancel",
                      onSubmit: () {
                        // database.deleteCategory(category.categoryPk);
                        Navigator.pop(context);
                        openSnackbar(context, "Deleted " + category.name);
                      },
                      onSubmitLabel: "Delete");
                },
              ),
              // OpenContainerNavigation(
              //   closedColor: HexColor(category.colour),
              //   button: (openContainer) {
              //     return Tappable(
              //       color: Colors.transparent,
              //       borderRadius: 50,
              //       child: Container(
              //           width: 40, height: 50, child: Icon(Icons.edit_rounded)),
              //       onTap: () {
              //         openContainer();
              //       },
              //     );
              //   },
              //   openPage: AddBudgetPage(
              //     title: "Edit " + category.name + " Category",
              //     category: category,
              //   ),
              // ),
              Material(
                color: Colors.transparent,
                child: ReorderableDragStartListener(
                  index: index,
                  child: Tappable(
                    color: Colors.transparent,
                    borderRadius: 50,
                    child: Container(
                        width: 40,
                        height: 50,
                        child: Icon(Icons.drag_handle_rounded)),
                    onTap: () {},
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
