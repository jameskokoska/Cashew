import 'dart:async';
import 'dart:math';

import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/pages/addObjectivePage.dart';
import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/categoryIcon.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/globalSnackBar.dart';
import 'package:budget/widgets/noResults.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/radioItems.dart';
import 'package:budget/widgets/selectCategory.dart';
import 'package:budget/widgets/selectChips.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' hide SliverReorderableList;
import 'package:flutter/services.dart' hide TextInput;
import 'package:budget/widgets/editRowEntry.dart';
import 'package:budget/modified/reorderable_list.dart';

class EditCategoriesPage extends StatefulWidget {
  EditCategoriesPage({
    Key? key,
  }) : super(key: key);

  @override
  _EditCategoriesPageState createState() => _EditCategoriesPageState();
}

class _EditCategoriesPageState extends State<EditCategoriesPage> {
  bool dragDownToDismissEnabled = true;
  int currentReorder = -1;
  String searchValue = "";

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      database.fixOrderCategories();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (searchValue != "") {
          setState(() {
            searchValue = "";
          });
          return false;
        } else {
          return true;
        }
      },
      child: PageFramework(
        horizontalPadding: getHorizontalPaddingConstrained(context),
        dragDownToDismiss: true,
        dragDownToDismissEnabled: dragDownToDismissEnabled,
        title: "edit-categories".tr(),
        scrollToTopButton: true,
        floatingActionButton: AnimateFABDelayed(
          fab: FAB(
            tooltip: "add-category".tr(),
            openPage: AddCategoryPage(
              routesToPopAfterDelete: RoutesToPopAfterDelete.None,
            ),
          ),
        ),
        actions: [
          IconButton(
            padding: EdgeInsets.all(15),
            tooltip: "add-category".tr(),
            onPressed: () {
              pushRoute(
                context,
                AddCategoryPage(
                  routesToPopAfterDelete: RoutesToPopAfterDelete.None,
                ),
              );
            },
            icon: Icon(appStateSettings["outlinedIcons"]
                ? Icons.add_outlined
                : Icons.add_rounded),
          ),
        ],
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TextInput(
                labelText: "search-categories-placeholder".tr(),
                icon: appStateSettings["outlinedIcons"]
                    ? Icons.search_outlined
                    : Icons.search_rounded,
                onSubmitted: (value) {
                  setState(() {
                    searchValue = value;
                  });
                },
                onChanged: (value) {
                  setState(() {
                    searchValue = value;
                  });
                },
                autoFocus: false,
              ),
            ),
          ),
          StreamBuilder<Map<String, List<TransactionCategory>>>(
              stream: database.watchAllSubCategoriesIndexedByMainCategoryPk(),
              builder: (context, snapshotSubCategories) {
                Map<String, List<TransactionCategory>>
                    subCategoriesIndexedByMainPk =
                    snapshotSubCategories.data ?? {};
                return StreamBuilder<List<CategoryWithDetails>>(
                  stream: database.watchAllMainCategoriesWithDetails(
                      searchFor: searchValue == "" ? null : searchValue),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && (snapshot.data ?? []).length <= 0) {
                      return SliverToBoxAdapter(
                        child: NoResults(
                          message: "no-categories-found".tr(),
                        ),
                      );
                    }
                    if (snapshot.hasData && (snapshot.data ?? []).length > 0) {
                      return SliverReorderableList(
                        onReorderStart: (index) {
                          HapticFeedback.heavyImpact();
                          setState(() {
                            dragDownToDismissEnabled = false;
                            currentReorder = index;
                          });
                        },
                        onReorderEnd: (_) {
                          setState(() {
                            dragDownToDismissEnabled = true;
                            currentReorder = -1;
                          });
                        },
                        itemBuilder: (context, index) {
                          CategoryWithDetails categoryDetails =
                              snapshot.data![index];
                          TransactionCategory category =
                              categoryDetails.category;
                          List<TransactionCategory> subCategories =
                              subCategoriesIndexedByMainPk[
                                      category.categoryPk] ??
                                  [];
                          return EditRowEntry(
                            canReorder: searchValue == "" &&
                                (snapshot.data ?? []).length != 1,
                            currentReorder:
                                currentReorder != -1 && currentReorder != index,
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            key: ValueKey(category.categoryPk),
                            extraWidgetsBelow: [
                              if (subCategories.length > 0)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: SelectChips(
                                    scrollablePositionedList: false,
                                    items: subCategories,
                                    onLongPress: (category) {
                                      pushRoute(
                                        context,
                                        AddCategoryPage(
                                          category: category,
                                          routesToPopAfterDelete:
                                              RoutesToPopAfterDelete.One,
                                        ),
                                      );
                                    },
                                    onSelected: (TransactionCategory category) {
                                      pushRoute(
                                        context,
                                        AddCategoryPage(
                                          category: category,
                                          routesToPopAfterDelete:
                                              RoutesToPopAfterDelete.One,
                                        ),
                                      );
                                    },
                                    getSelected:
                                        (TransactionCategory category) {
                                      return false;
                                    },
                                    getCustomBorderColor:
                                        (TransactionCategory category) {
                                      return dynamicPastel(
                                        context,
                                        lightenPastel(
                                          HexColor(
                                            category.colour,
                                            defaultColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                          amount: 0.3,
                                        ),
                                        amount: 0.4,
                                      );
                                    },
                                    getLabel: (TransactionCategory category) {
                                      return category.name;
                                    },
                                    extraWidget: AddButton(
                                      onTap: () {},
                                      width: 40,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 1),
                                      openPage: AddCategoryPage(
                                        routesToPopAfterDelete:
                                            RoutesToPopAfterDelete.One,
                                        mainCategoryPkWhenSubCategory:
                                            category.categoryPk,
                                      ),
                                      borderRadius: 8,
                                    ),
                                    getAvatar: (TransactionCategory category) {
                                      return LayoutBuilder(
                                          builder: (context, constraints) {
                                        return CategoryIcon(
                                          categoryPk: "-1",
                                          category: category,
                                          emojiSize:
                                              constraints.maxWidth * 0.73,
                                          emojiScale: 1.2,
                                          size: constraints.maxWidth,
                                          sizePadding: 0,
                                          noBackground: true,
                                          canEditByLongPress: false,
                                          margin: EdgeInsets.zero,
                                        );
                                      });
                                    },
                                  ),
                                ),
                            ],
                            content: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    CategoryIcon(
                                      categoryPk: category.categoryPk,
                                      size: 31,
                                      category: category,
                                      canEditByLongPress: false,
                                      borderRadius: 1000,
                                      sizePadding: 23,
                                    ),
                                    Container(width: 5),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextFont(
                                            text: category.name
                                            // +
                                            //     " - " +
                                            //     category.order.toString()
                                            ,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 19,
                                          ),
                                          TextFont(
                                            textAlign: TextAlign.left,
                                            text: category.income
                                                ? "income".tr()
                                                : "expense".tr(),
                                            fontSize: 14,
                                            textColor:
                                                getColor(context, "black")
                                                    .withOpacity(0.65),
                                          ),
                                          TextFont(
                                            textAlign: TextAlign.left,
                                            text: categoryDetails
                                                    .numberTransactions
                                                    .toString() +
                                                " " +
                                                (categoryDetails
                                                            .numberTransactions ==
                                                        1
                                                    ? "transaction"
                                                        .tr()
                                                        .toLowerCase()
                                                    : "transactions"
                                                        .tr()
                                                        .toLowerCase()),
                                            fontSize: 14,
                                            textColor:
                                                getColor(context, "black")
                                                    .withOpacity(0.65),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            index: index,
                            onDelete: () async {
                              return (await deleteCategoryPopup(
                                    context,
                                    category: category,
                                    routesToPopAfterDelete:
                                        RoutesToPopAfterDelete.None,
                                  )) ==
                                  DeletePopupAction.Delete;
                            },
                            openPage: AddCategoryPage(
                              category: category,
                              routesToPopAfterDelete:
                                  RoutesToPopAfterDelete.One,
                            ),
                          );
                        },
                        itemCount: snapshot.data!.length,
                        onReorder: (_intPrevious, _intNew) async {
                          CategoryWithDetails oldCategoryDetails =
                              snapshot.data![_intPrevious];
                          TransactionCategory oldCategory =
                              oldCategoryDetails.category;

                          if (_intNew > _intPrevious) {
                            await database.moveCategory(oldCategory.categoryPk,
                                _intNew - 1, oldCategory.order);
                          } else {
                            await database.moveCategory(oldCategory.categoryPk,
                                _intNew, oldCategory.order);
                          }
                          return true;
                        },
                      );
                    }
                    return SliverToBoxAdapter(
                      child: Container(),
                    );
                  },
                );
              }),
          SliverToBoxAdapter(
            child: SizedBox(height: 75),
          ),
        ],
      ),
    );
  }
}

class RefreshButton extends StatefulWidget {
  final Function onTap;
  final EdgeInsets? padding;
  final VisualDensity? visualDensity;
  final IconData? customIcon;
  final bool? flipIcon;
  final bool? halfAnimation;
  final bool iconOnly;

  RefreshButton({
    required this.onTap,
    this.padding,
    this.visualDensity,
    this.customIcon,
    this.flipIcon,
    this.halfAnimation,
    this.iconOnly = false,
    Key? key,
  }) : super(key: key);

  @override
  RefreshButtonState createState() => RefreshButtonState();
}

class RefreshButtonState extends State<RefreshButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late Tween<double> _tween;
  bool _isEnabled = true;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubicEmphasized,
    );
    _tween = Tween<double>(
        begin: 0.0, end: 12.5664 / 2 / (widget.halfAnimation == true ? 2 : 1));
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void startAnimation() {
    _animationController.forward(from: 0.0);
  }

  void _onTap() async {
    if (_isEnabled) {
      startAnimation();
      setState(() {
        _isEnabled = false;
      });
      await widget.onTap();
      Timer(Duration(seconds: 5), () {
        if (mounted)
          setState(() {
            _isEnabled = true;
          });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return AnimatedOpacity(
          opacity: _isEnabled ? 1 : 0.3,
          duration: Duration(milliseconds: 500),
          child: Transform.rotate(
            angle: _tween.evaluate(_animation),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(widget.flipIcon == true ? pi : 0),
              child: widget.iconOnly == true
                  ? Icon(
                      widget.customIcon ??
                          (appStateSettings["outlinedIcons"]
                              ? Icons.refresh_outlined
                              : Icons.refresh_rounded),
                      color: Theme.of(context).colorScheme.secondary,
                    )
                  : IconButton(
                      padding: widget.padding ?? EdgeInsets.all(15),
                      icon: Icon(widget.customIcon ??
                          (appStateSettings["outlinedIcons"]
                              ? Icons.refresh_outlined
                              : Icons.refresh_rounded)),
                      color: Theme.of(context).colorScheme.secondary,
                      onPressed: () => _onTap(),
                      visualDensity: widget.visualDensity,
                    ),
            ),
          ),
        );
      },
    );
  }
}

Future<DeletePopupAction?> deleteCategoryPopup(
  BuildContext context, {
  required TransactionCategory category,
  required RoutesToPopAfterDelete routesToPopAfterDelete,
}) async {
  bool isSubCategory = false;
  if (category.mainCategoryPk != null) {
    isSubCategory = true;
  }
  DeletePopupAction? action = await openDeletePopup(
    context,
    title: isSubCategory
        ? "delete-subcategory-question".tr()
        : "delete-category-question".tr(),
    subtitle: category.name,
    description: isSubCategory
        ? "delete-subcategory-question-description".tr()
        : "delete-category-question-description".tr(),
  );
  if (action == DeletePopupAction.Delete) {
    int transactionsFromCategoryLength = isSubCategory
        ? (await database
                .getAllTransactionsFromSubCategory(category.categoryPk))
            .length
        : (await database.getAllTransactionsFromCategory(category.categoryPk))
            .length;
    dynamic result = true;
    if (transactionsFromCategoryLength > 0) {
      result = await openPopup(
        context,
        title: isSubCategory
            ? "remove-all-transactions-from-subcategory-question".tr()
            : "delete-all-transactions-question".tr(),
        description: isSubCategory
            ? "delete-subcategory-merge-warning".tr()
            : "delete-category-merge-warning".tr(),
        icon: appStateSettings["outlinedIcons"]
            ? Icons.warning_outlined
            : Icons.warning_rounded,
        onCancel: () {
          Navigator.pop(context, false);
        },
        onCancelLabel: "cancel".tr(),
        onSubmit: () async {
          Navigator.pop(context, true);
        },
        onExtra2: () async {
          Navigator.pop(context, false);
          isSubCategory
              ? mergeSubcategoryPopup(
                  context,
                  subcategoryOriginal: category,
                  routesToPopAfterDelete: routesToPopAfterDelete,
                )
              : mergeCategoryPopup(
                  context,
                  categoryOriginal: category,
                  routesToPopAfterDelete: routesToPopAfterDelete,
                );
        },
        onExtraLabel2: "move-transactions".tr(),
        onSubmitLabel: "delete".tr(),
      );
    }
    if (result == true) {
      if (routesToPopAfterDelete == RoutesToPopAfterDelete.All) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else if (routesToPopAfterDelete == RoutesToPopAfterDelete.One) {
        Navigator.of(context).pop();
      }
      openLoadingPopupTryCatch(() async {
        await database.deleteCategory(category.categoryPk, category.order);
        openSnackbar(
          SnackbarMessage(
            title: "deleted-category".tr(),
            icon: Icons.delete,
            description: category.name,
          ),
        );
      });
    }
  }
  return action;
}

void mergeCategoryPopup(
  BuildContext context, {
  required TransactionCategory categoryOriginal,
  required RoutesToPopAfterDelete routesToPopAfterDelete,
}) {
  openBottomSheet(
    context,
    PopupFramework(
      title: "select-category".tr(),
      subtitle: "category-to-transfer-all-transactions-to".tr(),
      child: SelectCategory(
        hideCategoryFks: [categoryOriginal.categoryPk],
        allowRearrange: false,
        popRoute: true,
        setSelectedCategory: (category) async {
          Future.delayed(Duration(milliseconds: 90), () async {
            final result = await openPopup(
              context,
              title: "merge-into".tr() + " " + category.name + "?",
              description: "merge-into-description-categories".tr(),
              icon: appStateSettings["outlinedIcons"]
                  ? Icons.merge_outlined
                  : Icons.merge_rounded,
              onSubmit: () async {
                Navigator.pop(context, true);
              },
              onSubmitLabel: "merge".tr(),
              onCancelLabel: "cancel".tr(),
              onCancel: () {
                Navigator.pop(context);
              },
            );
            if (result == true) {
              if (routesToPopAfterDelete == RoutesToPopAfterDelete.All) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              } else if (routesToPopAfterDelete == RoutesToPopAfterDelete.One) {
                Navigator.of(context).pop();
              }
              openLoadingPopupTryCatch(() async {
                await database.mergeAndDeleteCategory(
                    categoryOriginal, category);
                openSnackbar(
                  SnackbarMessage(
                    title: "merged-category".tr(),
                    icon: appStateSettings["outlinedIcons"]
                        ? Icons.merge_outlined
                        : Icons.merge_rounded,
                    description: categoryOriginal.name + " → " + category.name,
                  ),
                );
              });
            }
          });
        },
      ),
    ),
  );
}

void mergeSubcategoryPopup(
  BuildContext context, {
  required TransactionCategory subcategoryOriginal,
  required RoutesToPopAfterDelete routesToPopAfterDelete,
}) {
  openBottomSheet(
    context,
    PopupFramework(
      title: "select-subcategory".tr(),
      subtitle: "subcategory-to-transfer-all-transactions-to".tr(),
      child: SelectCategory(
        hideCategoryFks: [subcategoryOriginal.categoryPk],
        allowRearrange: false,
        popRoute: true,
        mainCategoryPks: [subcategoryOriginal.mainCategoryPk ?? ""],
        setSelectedCategory: (subcategory) async {
          Future.delayed(Duration(milliseconds: 90), () async {
            final result = await openPopup(
              context,
              title: "merge-into".tr() + " " + subcategory.name + "?",
              description: "merge-into-description-subcategories".tr(),
              icon: appStateSettings["outlinedIcons"]
                  ? Icons.merge_outlined
                  : Icons.merge_rounded,
              onSubmit: () async {
                Navigator.pop(context, true);
              },
              onSubmitLabel: "merge".tr(),
              onCancelLabel: "cancel".tr(),
              onCancel: () {
                Navigator.pop(context);
              },
            );
            if (result == true) {
              if (routesToPopAfterDelete == RoutesToPopAfterDelete.All) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              } else if (routesToPopAfterDelete == RoutesToPopAfterDelete.One) {
                Navigator.of(context).pop();
              }
              openLoadingPopupTryCatch(() async {
                await database.mergeAndDeleteSubCategory(
                    subcategoryOriginal, subcategory);
                openSnackbar(
                  SnackbarMessage(
                    title: "merged-subcategory".tr(),
                    icon: appStateSettings["outlinedIcons"]
                        ? Icons.merge_outlined
                        : Icons.merge_rounded,
                    description:
                        subcategoryOriginal.name + " → " + subcategory.name,
                  ),
                );
              });
            }
          });
        },
      ),
    ),
  );
}

void makeMainCategoryPopup(
  BuildContext context, {
  required TransactionCategory subcategoryOriginal,
  required RoutesToPopAfterDelete routesToPopAfterDelete,
}) async {
  final result = await openPopup(
    context,
    title: "make-main-category-question".tr(),
    description: "make-main-category-description".tr(),
    icon: appStateSettings["outlinedIcons"]
        ? Icons.move_down_outlined
        : Icons.move_down_rounded,
    onSubmit: () async {
      Navigator.pop(context, true);
    },
    onSubmitLabel: "make-main-category".tr(),
    onCancelLabel: "cancel".tr(),
    onCancel: () {
      Navigator.pop(context);
    },
  );
  if (result == true) {
    if (routesToPopAfterDelete == RoutesToPopAfterDelete.All) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (routesToPopAfterDelete == RoutesToPopAfterDelete.One) {
      Navigator.of(context).pop();
    }
    openLoadingPopupTryCatch(() async {
      await database.makeSubcategoryIntoMainCategory(subcategoryOriginal);
      openSnackbar(
        SnackbarMessage(
          title: "main-category-created".tr(),
          icon: appStateSettings["outlinedIcons"]
              ? Icons.inbox_outlined
              : Icons.inbox_rounded,
          description: subcategoryOriginal.name,
        ),
      );
    });
  }
}

void makeSubCategoryPopup(
  BuildContext context, {
  required TransactionCategory categoryOriginal,
  required RoutesToPopAfterDelete routesToPopAfterDelete,
}) {
  openBottomSheet(
    context,
    PopupFramework(
      title: "select-category".tr(),
      subtitle: "select-the-main-category-for-this-subcategory".tr(),
      child: SelectCategory(
        hideCategoryFks: [categoryOriginal.categoryPk],
        allowRearrange: false,
        popRoute: true,
        setSelectedCategory: (category) async {
          Future.delayed(Duration(milliseconds: 90), () async {
            final result = await openPopup(
              context,
              title: "make-subcategory-of".tr() + " " + category.name + "?",
              description: "make-subcategory-description-categories".tr(),
              icon: appStateSettings["outlinedIcons"]
                  ? Icons.move_up_outlined
                  : Icons.move_up_rounded,
              onSubmit: () async {
                Navigator.pop(context, true);
              },
              onSubmitLabel: "make-subcategory".tr(),
              onCancelLabel: "cancel".tr(),
              onCancel: () {
                Navigator.pop(context);
              },
            );
            if (result == true) {
              if (routesToPopAfterDelete == RoutesToPopAfterDelete.All) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              } else if (routesToPopAfterDelete == RoutesToPopAfterDelete.One) {
                Navigator.of(context).pop();
              }
              openLoadingPopupTryCatch(() async {
                await database.makeMainCategoryIntoSubcategory(
                    categoryOriginal, category);
                openSnackbar(
                  SnackbarMessage(
                    title: "subcategory-created".tr(),
                    icon: appStateSettings["outlinedIcons"]
                        ? Icons.move_to_inbox_outlined
                        : Icons.move_to_inbox_rounded,
                    description: categoryOriginal.name + " → " + category.name,
                  ),
                );
              });
            }
          });
        },
      ),
    ),
  );
}
