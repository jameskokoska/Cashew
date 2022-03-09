import 'package:budget/database/tables.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:flutter/material.dart';

class SelectCategory extends StatefulWidget {
  SelectCategory({
    Key? key,
    required this.setSelectedCategory,
    this.selectedCategory,
    this.next,
    this.skipIfSet,
  }) : super(key: key);
  final Function(TransactionCategory) setSelectedCategory;
  final TransactionCategory? selectedCategory;
  final VoidCallback? next;
  final bool? skipIfSet;

  @override
  _SelectCategoryState createState() => _SelectCategoryState();
}

class _SelectCategoryState extends State<SelectCategory> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 0), () {
      if (widget.selectedCategory != null && widget.skipIfSet == true) {
        Navigator.pop(context);
        if (widget.next != null) {
          widget.next!();
        }
      }
    });
  }

  //find the selected category using selectedCategory
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TransactionCategory>>(
        stream: database.watchAllCategories(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: snapshot.data!
                      .asMap()
                      .map(
                        (index, category) => MapEntry(
                          index,
                          CategoryIcon(
                            categoryPk: category.categoryPk,
                            size: 50,
                            label: true,
                            onTap: () {
                              widget.setSelectedCategory(category);
                              setState(() {
                                selectedIndex = index;
                              });
                              Future.delayed(Duration(milliseconds: 70), () {
                                Navigator.pop(context);
                                if (widget.next != null) {
                                  widget.next!();
                                }
                              });
                            },
                            outline: widget.selectedCategory == null
                                ? selectedIndex == index
                                : category.categoryPk ==
                                    widget.selectedCategory!.categoryPk,
                          ),
                        ),
                      )
                      .values
                      .toList(),
                ),
              ),
            );
          } else {
            return Container();
          }
        });
  }
}
