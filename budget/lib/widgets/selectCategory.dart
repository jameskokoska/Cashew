import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/categoryIcon.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart'
    hide SliverReorderableList, ReorderableDelayedDragStartListener;
import 'package:flutter/services.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

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
    this.labelIcon = true,
    this.addButton = true,
    this.scaleWhenSelected = false,
    this.categoryFks,
    this.hideCategoryFks,
  }) : super(key: key);
  final Function(TransactionCategory)? setSelectedCategory;
  final Function(List<int>)? setSelectedCategories;
  final TransactionCategory? selectedCategory;
  final List<int>? selectedCategories;
  final VoidCallback? next;
  final bool? skipIfSet;
  final String? nextLabel;
  final bool horizontalList;
  final bool popRoute;
  final bool showSelectedAllCategoriesIfNoneSelected;
  final bool labelIcon;
  final bool addButton;
  final bool scaleWhenSelected;
  final List<int>? categoryFks;
  final List<int>? hideCategoryFks;

  @override
  _SelectCategoryState createState() => _SelectCategoryState();
}

class _SelectCategoryState extends State<SelectCategory> {
  List<int> selectedCategories = [];
  bool updatedInitial = false;
  late ScrollController _scrollController;

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
      if (widget.selectedCategory != null) {
        setState(() {
          selectedCategories.add(widget.selectedCategory!.categoryPk);
        });
      }
    });
    setInitialCategories();
    _scrollController = ScrollController();
  }

  void didUpdateWidget(oldWidget) {
    if (widget.selectedCategories != oldWidget.selectedCategories) {
      setState(() {
        selectedCategories = widget.selectedCategories ?? [];
      });
    }
  }

  setInitialCategories() {
    if (widget.selectedCategories != null) {
      setState(() {
        selectedCategories = widget.selectedCategories ?? [];
      });
    } else if (widget.selectedCategory != null) {
      setState(() {
        selectedCategories.add(-1);
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
                if (widget.categoryFks != null &&
                    !widget.categoryFks!.contains(category.categoryPk)) {
                  continue;
                } else if (widget.hideCategoryFks != null &&
                    widget.hideCategoryFks!.contains(category.categoryPk)) {
                  continue;
                }

                children.add(AnimatedScale(
                  key: ValueKey(category.categoryPk.toString()),
                  duration: Duration(milliseconds: 1500),
                  curve: Curves.elasticOut,
                  scale: widget.scaleWhenSelected == true &&
                          selectedCategories.contains(category.categoryPk) ==
                              false
                      ? 0.86
                      : 1,
                  child: Padding(
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
                      size: 42,
                      sizePadding: 28,
                      label: widget.labelIcon,
                      onTap: () {
                        if (widget.setSelectedCategory != null) {
                          widget.setSelectedCategory!(category);
                          setState(() {
                            selectedCategories = [];
                            selectedCategories.add(category.categoryPk);
                          });
                          Future.delayed(Duration(milliseconds: 70), () {
                            if (widget.popRoute) Navigator.pop(context);
                            if (widget.next != null) {
                              widget.next!();
                            }
                          });
                        } else if (widget.setSelectedCategories != null) {
                          // print(selectedCategories);
                          if (selectedCategories
                              .contains(category.categoryPk)) {
                            setState(() {
                              selectedCategories.remove(category.categoryPk);
                            });
                            widget.setSelectedCategories!(selectedCategories);
                          } else {
                            setState(() {
                              selectedCategories.add(category.categoryPk);
                            });
                            widget.setSelectedCategories!(selectedCategories);
                          }
                        }
                      },
                      outline: selectedCategories.contains(category.categoryPk),
                    ),
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
                                    text: "all".tr(),
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
                  widget.addButton == false
                      ? SizedBox.shrink()
                      : Padding(
                          key: ValueKey(2),
                          padding: const EdgeInsets.only(
                            bottom: 21,
                            top: 8,
                            right: 20,
                          ),
                          child: AddButton(
                            onTap: () {},
                            padding: EdgeInsets.zero,
                            openPage: AddCategoryPage(),
                            width: 70,
                          ),
                        ),
                ],
              );
            }
            double size = getWidthBottomSheet(context) <= 400
                ? (getWidthBottomSheet(context) - 20) / 4 - 50
                : 45;
            // print(size);
            // print(snapshot.data);
            // print(size);
            List<Widget> categoryIcons = [];
            for (TransactionCategory category in snapshot.data!) {
              if (widget.categoryFks != null &&
                  !widget.categoryFks!.contains(category.categoryPk)) {
                continue;
              } else if (widget.hideCategoryFks != null &&
                  widget.hideCategoryFks!.contains(category.categoryPk)) {
                continue;
              }
              categoryIcons.add(
                AnimatedScale(
                  key: ValueKey(category.categoryPk),
                  duration: Duration(milliseconds: 1500),
                  curve: Curves.elasticOut,
                  scale: widget.scaleWhenSelected == true &&
                          selectedCategories.contains(category.categoryPk) ==
                              false
                      ? 0.86
                      : 1,
                  child: CategoryIcon(
                    canEditByLongPress: false,
                    categoryPk: category.categoryPk,
                    size: size,
                    sizePadding: 24,
                    margin: EdgeInsets.zero,
                    label: widget.labelIcon,
                    onTap: () {
                      if (widget.setSelectedCategory != null) {
                        widget.setSelectedCategory!(category);
                        setState(() {
                          selectedCategories = [];
                          selectedCategories.add(category.categoryPk);
                        });
                        Future.delayed(Duration(milliseconds: 70), () {
                          if (widget.popRoute) Navigator.pop(context);
                          if (widget.next != null) {
                            widget.next!();
                          }
                        });
                      } else if (widget.setSelectedCategories != null) {
                        if (selectedCategories.contains(category.categoryPk)) {
                          setState(() {
                            selectedCategories.remove(category.categoryPk);
                          });
                          widget.setSelectedCategories!(selectedCategories);
                        } else {
                          setState(() {
                            selectedCategories.add(category.categoryPk);
                          });
                          widget.setSelectedCategories!(selectedCategories);
                        }
                      }
                    },
                    outline: selectedCategories.contains(category.categoryPk),
                  ),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0, left: 10, right: 10),
              child: Column(
                children: [
                  ReorderableGridView.count(
                    dragWidgetBuilder: (index, child) {
                      return Opacity(opacity: 0.5, child: child);
                    },
                    placeholderBuilder: (dropIndex, dropInddex, dragWidget) {
                      return Opacity(
                        opacity: 0.2,
                        child: dragWidget,
                      );
                    },
                    childAspectRatio: 0.96,
                    padding: EdgeInsets.only(top: 5),
                    controller: _scrollController,
                    crossAxisSpacing: 0,
                    mainAxisSpacing: 5,
                    crossAxisCount: getWidthBottomSheet(context) <= 400
                        ? 4
                        : ((getWidthBottomSheet(context)) ~/ size ~/ 2.1)
                            .toInt(),
                    shrinkWrap: true,
                    children: categoryIcons,
                    footer: [
                      widget.addButton == false
                          ? SizedBox.shrink()
                          : Padding(
                              padding:
                                  const EdgeInsets.only(left: 7.5, right: 7.5),
                              child: Column(
                                children: [
                                  LayoutBuilder(
                                    builder:
                                        (context, BoxConstraints constraints) {
                                      print(constraints);
                                      return AddButton(
                                        onTap: () {},
                                        height: constraints.maxWidth,
                                        width: constraints.maxWidth,
                                        openPage: AddCategoryPage(),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                    ],
                    onReorder: (_intPrevious, _intNew) async {
                      TransactionCategory oldCategory =
                          snapshot.data![_intPrevious];

                      if (_intNew > _intPrevious) {
                        await database.moveCategory(
                            oldCategory.categoryPk, _intNew, oldCategory.order);
                      } else {
                        await database.moveCategory(
                            oldCategory.categoryPk, _intNew, oldCategory.order);
                      }
                      return true;
                    },
                    onDragStart: (_) {
                      database.fixOrderCategories();
                      HapticFeedback.heavyImpact();
                    },
                  ),
                  // Center(
                  //   child: Wrap(
                  //     alignment: WrapAlignment.center,
                  //     children: [
                  //       ...snapshot.data!
                  //           .asMap()
                  //           .map(
                  //             (index, category) => MapEntry(
                  //               index,
                  //               CategoryIcon(
                  //                 categoryPk: category.categoryPk,
                  //                 size: size,
                  //                 label: true,
                  //                 onTap: () {
                  //                   if (widget.setSelectedCategory != null) {
                  //                     widget.setSelectedCategory!(category);
                  //                     setState(() {
                  //                       selectedCategories = [];
                  //                       selectedCategories
                  //                           .add(category.categoryPk);
                  //                     });
                  //                     Future.delayed(Duration(milliseconds: 70),
                  //                         () {
                  //                       if (widget.popRoute)
                  //                         Navigator.pop(context);
                  //                       if (widget.next != null) {
                  //                         widget.next!();
                  //                       }
                  //                     });
                  //                   } else if (widget.setSelectedCategories !=
                  //                       null) {
                  //                     if (selectedCategories
                  //                         .contains(category.categoryPk)) {
                  //                       setState(() {
                  //                         selectedCategories
                  //                             .remove(category.categoryPk);
                  //                       });
                  //                       widget.setSelectedCategories!(
                  //                           selectedCategories);
                  //                     } else {
                  //                       setState(() {
                  //                         selectedCategories
                  //                             .add(category.categoryPk);
                  //                       });
                  //                       widget.setSelectedCategories!(
                  //                           selectedCategories);
                  //                     }
                  //                   }
                  //                 },
                  //                 outline: selectedCategories
                  //                     .contains(category.categoryPk),
                  //               ),
                  //             ),
                  //           )
                  //           .values
                  //           .toList(),
                  //       Padding(
                  //         key: ValueKey(2),
                  //         padding: const EdgeInsets.only(
                  //           top: 8,
                  //           right: 8,
                  //           left: 8,
                  //         ),
                  //         child: AddButton(
                  //           onTap: () {},
                  //           padding: EdgeInsets.zero,
                  //           openPage: AddCategoryPage(
                  //           ),
                  //           width: size + 20,
                  //           height: size + 20,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
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
