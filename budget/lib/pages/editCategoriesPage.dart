import 'dart:async';
import 'dart:math';

import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
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
import 'package:budget/widgets/selectCategory.dart';
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
          fab: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewPadding.bottom),
            child: FAB(
              tooltip: "add-category".tr(),
              openPage: AddCategoryPage(
                routesToPopAfterDelete: RoutesToPopAfterDelete.None,
              ),
            ),
          ),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TextInput(
                labelText: "search-categories-placeholder".tr(),
                icon: Icons.search_rounded,
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
          StreamBuilder<List<TransactionCategory>>(
            stream: database.watchAllCategories(
                searchFor: searchValue == "" ? null : searchValue),
            builder: (context, snapshot) {
              if (snapshot.hasData && (snapshot.data ?? []).length <= 0) {
                return SliverToBoxAdapter(
                  child: NoResults(
                    message: "No categories found.",
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
                    TransactionCategory category = snapshot.data![index];
                    return EditRowEntry(
                      canReorder: searchValue == "" &&
                          (snapshot.data ?? []).length != 1,
                      currentReorder:
                          currentReorder != -1 && currentReorder != index,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      key: ValueKey(index),
                      content: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
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
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                  textColor: getColor(context, "black")
                                      .withOpacity(0.65),
                                ),
                                StreamBuilder<List<int?>>(
                                  stream: database
                                      .watchTotalCountOfTransactionsInCategory(
                                          category.categoryPk),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData &&
                                        snapshot.data != null) {
                                      return TextFont(
                                        textAlign: TextAlign.left,
                                        text: snapshot.data![0].toString() +
                                            " " +
                                            (snapshot.data![0] == 1
                                                ? "transaction"
                                                    .tr()
                                                    .toLowerCase()
                                                : "transactions"
                                                    .tr()
                                                    .toLowerCase()),
                                        fontSize: 14,
                                        textColor: getColor(context, "black")
                                            .withOpacity(0.65),
                                      );
                                    } else {
                                      return TextFont(
                                        textAlign: TextAlign.left,
                                        text: "/ transactions",
                                        fontSize: 14,
                                        textColor: getColor(context, "black")
                                            .withOpacity(0.65),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      index: index,
                      onDelete: () {
                        deleteCategoryPopup(
                          context,
                          category: category,
                          routesToPopAfterDelete: RoutesToPopAfterDelete.None,
                        );
                      },
                      openPage: AddCategoryPage(
                        category: category,
                        routesToPopAfterDelete: RoutesToPopAfterDelete.One,
                      ),
                    );
                  },
                  itemCount: snapshot.data!.length,
                  onReorder: (_intPrevious, _intNew) async {
                    TransactionCategory oldCategory =
                        snapshot.data![_intPrevious];

                    if (_intNew > _intPrevious) {
                      await database.moveCategory(oldCategory.categoryPk,
                          _intNew - 1, oldCategory.order);
                    } else {
                      await database.moveCategory(
                          oldCategory.categoryPk, _intNew, oldCategory.order);
                    }
                    return true;
                  },
                );
              }
              return SliverToBoxAdapter(
                child: Container(),
              );
            },
          ),
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
                      widget.customIcon ?? Icons.refresh_rounded,
                      color: Theme.of(context).colorScheme.secondary,
                    )
                  : IconButton(
                      padding: widget.padding ?? EdgeInsets.all(15),
                      icon: Icon(widget.customIcon ?? Icons.refresh_rounded),
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

void deleteCategoryPopup(
  BuildContext context, {
  required TransactionCategory category,
  required RoutesToPopAfterDelete routesToPopAfterDelete,
}) async {
  DeletePopupAction? action = await openDeletePopup(
    context,
    title: "delete-category-question".tr(),
    subtitle: category.name,
    description: "delete-category-question-description".tr(),
  );
  if (action == DeletePopupAction.Delete) {
    int transactionsFromCategoryLength =
        (await database.getAllTransactionsFromCategory(category.categoryPk))
            .length;
    dynamic result = true;
    if (transactionsFromCategoryLength > 0) {
      result = await openPopup(
        context,
        title: "delete-all-transactions-question".tr(),
        description: "delete-category-merge-warning".tr(),
        icon: Icons.warning_amber_rounded,
        onCancel: () {
          Navigator.pop(context, false);
        },
        onCancelLabel: "cancel".tr(),
        onSubmit: () async {
          Navigator.pop(context, true);
        },
        onExtra2: () async {
          Navigator.pop(context, false);
          mergeCategoryPopup(
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
        popRoute: true,
        setSelectedCategory: (category) async {
          Future.delayed(Duration(milliseconds: 90), () async {
            final result = await openPopup(
              context,
              title: "merge-into".tr() + " " + category.name + "?",
              description: "merge-into-description".tr(),
              icon: Icons.warning_amber_rounded,
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
                    icon: Icons.merge_rounded,
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
