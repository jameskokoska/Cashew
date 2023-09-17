import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/editAssociatedTitlesPage.dart';
import 'package:budget/pages/editCategoriesPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/categoryIcon.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/incomeExpenseTabSelector.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/saveBottomButton.dart';
import 'package:budget/widgets/selectCategoryImage.dart';
import 'package:budget/widgets/selectColor.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:budget/colors.dart';

class AddCategoryPage extends StatefulWidget {
  AddCategoryPage({
    Key? key,
    this.category,
    required this.routesToPopAfterDelete,
  }) : super(key: key);

  //When a category is passed in, we are editing that transaction
  final TransactionCategory? category;
  final RoutesToPopAfterDelete routesToPopAfterDelete;

  @override
  _AddCategoryPageState createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage>
    with SingleTickerProviderStateMixin {
  String? selectedTitle;
  late String? selectedImage = widget.category == null ? "image.png" : null;
  String? selectedEmoji;
  Color? selectedColor;
  bool selectedIncome = false;
  bool? canAddCategory;
  TransactionCategory? widgetCategory;
  List<String>? selectedMembers;
  TextEditingController _titleController = TextEditingController();
  bool userAttemptedToChangeTitle = false;
  FocusNode _titleFocusNode = FocusNode();
  late TabController _incomeTabController =
      TabController(length: 2, vsync: this);

  void setSelectedColor(Color? color) {
    setState(() {
      selectedColor = color;
    });
    determineBottomButton();
    return;
  }

  void setSelectedImage(String? image) {
    setState(() {
      selectedImage = (image ?? "").replaceFirst("assets/categories/", "");
    });
    determineBottomButton();
    return;
  }

  void setSelectedEmoji(String? emoji) {
    setState(() {
      selectedEmoji = emoji;
    });
    determineBottomButton();
    return;
  }

  void setSelectedTitle(String title,
      {bool userAttemptedToChangeTitlePassed = false,
      bool modifyControllerValue = false}) {
    setState(() {
      selectedTitle = title;
      userAttemptedToChangeTitle =
          title == "" ? false : userAttemptedToChangeTitlePassed;
    });
    if (modifyControllerValue) _titleController.text = title;
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

  void setSelectedMembers(List<String>? members) {
    if (selectedMembers != null) {
      determineBottomButton();
    }
    setState(() {
      selectedMembers = members;
    });
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
    TransactionCategory createdCategory = await createTransactionCategory();
    await database.createOrUpdateCategory(
      insert: widget.category == null,
      createdCategory,
    );
    Navigator.pop(context);
  }

  Future<TransactionCategory> createTransactionCategory() async {
    TransactionCategory? currentInstance;
    if (widget.category != null) {
      currentInstance =
          await database.getCategoryInstance(widget.category!.categoryPk);
    }
    return TransactionCategory(
      categoryPk: widget.category != null ? widget.category!.categoryPk : "-1",
      name: (selectedTitle ?? "").trim(),
      dateCreated: widget.category != null
          ? widget.category!.dateCreated
          : DateTime.now(),
      dateTimeModified: null,
      income: selectedIncome,
      order: widget.category != null
          ? widget.category!.order
          : await database.getAmountOfCategories(),
      colour: toHexString(selectedColor),
      iconName: selectedImage,
      emojiIconName: selectedEmoji,
      methodAdded:
          widget.category != null ? widget.category!.methodAdded : null,
    );
  }

  @override
  void initState() {
    super.initState();
    widgetCategory = widget.category;
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
          selectedTitle = widget.category?.name;
          selectedImage = widget.category?.iconName;
          selectedEmoji = widget.category?.emojiIconName;
          selectedIncome = widget.category!.income;
          userAttemptedToChangeTitle = true;
        });
        _titleController.text = selectedTitle ?? "";
        if (widget.category?.income == true) {
          _incomeTabController.animateTo(1);
        } else {
          _incomeTabController.animateTo(0);
        }
      }
    });
    //Set to false because we can't save until we made some changes
    setState(() {
      canAddCategory = false;
    });
  }

  @override
  void dispose() {
    _titleFocusNode.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.category != null) {
          discardChangesPopup(context,
              previousObject: widget.category!,
              currentObject: await createTransactionCategory());
        } else {
          discardChangesPopup(context, forceShow: true);
        }
        return false;
      },
      child: GestureDetector(
        onTap: () {
          //Minimize keyboard when tap non interactive widget
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: PageFramework(
          resizeToAvoidBottomInset: true,
          dragDownToDismiss: true,
          title: widget.category == null
              ? "add-category".tr()
              : "edit-category".tr(),
          onBackButton: () async {
            if (widget.category != null) {
              discardChangesPopup(context,
                  previousObject: widget.category!,
                  currentObject: await createTransactionCategory());
            } else {
              discardChangesPopup(context, forceShow: true);
            }
          },
          onDragDownToDismiss: () async {
            if (widget.category != null) {
              discardChangesPopup(context,
                  previousObject: widget.category!,
                  currentObject: await createTransactionCategory());
            } else {
              discardChangesPopup(context, forceShow: true);
            }
          },
          actions: [
            widget.category != null &&
                    widget.routesToPopAfterDelete !=
                        RoutesToPopAfterDelete.PreventDelete
                ? IconButton(
                    padding: EdgeInsets.all(15),
                    tooltip: "delete-category".tr(),
                    onPressed: () {
                      deleteCategoryPopup(
                        context,
                        category: widgetCategory!,
                        routesToPopAfterDelete: widget.routesToPopAfterDelete,
                      );
                    },
                    icon: Icon(appStateSettings["outlinedIcons"]
                        ? Icons.delete_outlined
                        : Icons.delete_rounded),
                  )
                : SizedBox.shrink()
          ],
          overlay: Align(
            alignment: Alignment.bottomCenter,
            child: selectedTitle == "" || selectedTitle == null
                ? SaveBottomButton(
                    label: "set-name".tr(),
                    onTap: () async {
                      FocusScope.of(context).unfocus();
                      Future.delayed(Duration(milliseconds: 100), () {
                        _titleFocusNode.requestFocus();
                      });
                    },
                    disabled: false,
                  )
                : SaveBottomButton(
                    label: widget.category == null
                        ? "add-category".tr()
                        : "save-changes".tr(),
                    onTap: () async {
                      await addCategory();
                    },
                    disabled: !(canAddCategory ?? false),
                  ),
          ),
          listWidgets: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13),
              child: ClipRRect(
                borderRadius: getPlatform() == PlatformOS.isIOS
                    ? BorderRadius.circular(10)
                    : BorderRadius.circular(15),
                child: IncomeExpenseTabSelector(
                  onTabChanged: setSelectedIncome,
                  initialTabIsIncome: selectedIncome,
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  unselectedColor: Theme.of(context)
                      .colorScheme
                      .secondaryContainer
                      .withOpacity(0.2),
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Tappable(
                  onTap: () {
                    openBottomSheet(
                      context,
                      PopupFramework(
                        title: "select-icon".tr(),
                        child: SelectCategoryImage(
                          setSelectedImage: setSelectedImage,
                          setSelectedEmoji: setSelectedEmoji,
                          selectedImage:
                              "assets/categories/" + selectedImage.toString(),
                          setSelectedTitle: (String? titleRecommendation) {
                            if (titleRecommendation != null &&
                                (userAttemptedToChangeTitle == false ||
                                    selectedTitle == "" ||
                                    selectedTitle == null))
                              setSelectedTitle(
                                  titleRecommendation.capitalizeFirstofEach,
                                  modifyControllerValue: true);
                          },
                        ),
                      ),
                      showScrollbar: true,
                    );
                  },
                  color: Colors.transparent,
                  child: Container(
                    height: 126,
                    padding: const EdgeInsets.only(left: 13, right: 18),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 300),
                          child: CategoryIcon(
                            key: ValueKey((selectedImage ?? "") +
                                selectedColor.toString()),
                            categoryPk: "-1",
                            category: TransactionCategory(
                              categoryPk: "-1",
                              name: "",
                              dateCreated: DateTime.now(),
                              dateTimeModified: null,
                              order: 0,
                              income: false,
                              iconName: selectedImage,
                              colour: toHexString(selectedColor),
                              emojiIconName: selectedEmoji,
                            ),
                            size: 50,
                            sizePadding: 30,
                            canEditByLongPress: false,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: IntrinsicWidth(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20, bottom: 40),
                      child: TextInput(
                        autoFocus: kIsWeb && getIsFullScreen(context),
                        focusNode: _titleFocusNode,
                        labelText: "name-placeholder".tr(),
                        bubbly: false,
                        controller: _titleController,
                        onChanged: (text) {
                          setSelectedTitle(text,
                              userAttemptedToChangeTitlePassed: true);
                        },
                        padding: EdgeInsets.zero,
                        fontSize: getIsFullScreen(context) ? 34 : 27,
                        fontWeight: FontWeight.bold,
                        topContentPadding: 40,
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
            SizedBox(height: 20),
            widgetCategory == null ||
                    widget.routesToPopAfterDelete ==
                        RoutesToPopAfterDelete.PreventDelete
                ? SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Button(
                      icon: appStateSettings["outlinedIcons"]
                          ? Icons.merge_outlined
                          : Icons.merge_rounded,
                      label: "merge-category".tr(),
                      onTap: () async {
                        if (widget.category != null)
                          mergeCategoryPopup(
                            context,
                            categoryOriginal: widget.category!,
                            routesToPopAfterDelete:
                                widget.routesToPopAfterDelete,
                          );
                      },
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      textColor:
                          Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
            widgetCategory == null ? SizedBox.shrink() : SizedBox(height: 20),
            widget.category == null
                ? SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFont(
                      text: "associated-titles".tr(),
                      textColor: getColor(context, "textLight"),
                      fontSize: 16,
                    ),
                  ),
            widget.category == null ? SizedBox.shrink() : SizedBox(height: 5),
            widget.category == null
                ? SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFont(
                      text: "associated-titles-description".tr(),
                      textColor: getColor(context, "textLight"),
                      fontSize: 13,
                      maxLines: 10,
                    ),
                  ),
            widget.category == null ? SizedBox.shrink() : SizedBox(height: 10),
            widget.category == null
                ? SizedBox.shrink()
                : AddButton(
                    padding: EdgeInsets.only(
                      left: 15,
                      right: 15,
                      bottom: 9,
                      top: 4,
                    ),
                    onTap: () {
                      openBottomSheet(
                        context,
                        fullSnap: true,
                        PopupFramework(
                          title: "set-title".tr(),
                          child: SelectText(
                            setSelectedText: (_) {},
                            labelText: "set-title".tr(),
                            placeholder: "title-placeholder".tr(),
                            nextWithInput: (text) async {
                              int length =
                                  await database.getAmountOfAssociatedTitles();

                              await database.createOrUpdateAssociatedTitle(
                                insert: true,
                                TransactionAssociatedTitle(
                                  associatedTitlePk: "-1",
                                  categoryFk: widget.category == null
                                      ? "-1"
                                      : widget.category!.categoryPk,
                                  isExactMatch: false,
                                  title: text.trim(),
                                  dateCreated: DateTime.now(),
                                  dateTimeModified: null,
                                  order: length,
                                ),
                              );
                            },
                          ),
                        ),
                      );
                      // Fix over-scroll stretch when keyboard pops up quickly
                      Future.delayed(Duration(milliseconds: 100), () {
                        bottomSheetControllerGlobal.scrollTo(0,
                            duration: Duration(milliseconds: 100));
                      });
                    }),
            widget.category == null
                ? SizedBox.shrink()
                : StreamBuilder<List<TransactionAssociatedTitle>>(
                    stream: database.watchAllAssociatedTitlesInCategory(
                      widget.category == null
                          ? "-1"
                          : widget.category!.categoryPk,
                    ),
                    builder: (context, snapshot) {
                      // print(snapshot.data);
                      if (snapshot.hasData &&
                          (snapshot.data ?? []).length > 0) {
                        return Column(
                          children: [
                            for (int i = 0; i < snapshot.data!.length; i++)
                              Builder(builder: (context) {
                                TransactionAssociatedTitle associatedTitle =
                                    snapshot.data![i];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: AssociatedTitleContainer(
                                    title: associatedTitle,
                                    setTitle: (text) async {
                                      await database
                                          .createOrUpdateAssociatedTitle(
                                        TransactionAssociatedTitle(
                                          associatedTitlePk:
                                              associatedTitle.associatedTitlePk,
                                          categoryFk: widget.category == null
                                              ? "-1"
                                              : widget.category!.categoryPk,
                                          isExactMatch:
                                              associatedTitle.isExactMatch,
                                          title: text.trim(),
                                          dateCreated: DateTime.now(),
                                          dateTimeModified: null,
                                          order: associatedTitle.order,
                                        ),
                                      );
                                    },
                                  ),
                                );
                              }),
                          ],
                        );
                      }
                      return SizedBox();
                    }),
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class AssociatedTitleContainer extends StatelessWidget {
  const AssociatedTitleContainer({
    Key? key,
    required this.title,
    required this.setTitle,
  }) : super(key: key);

  final TransactionAssociatedTitle title;
  final Function(String) setTitle;

  @override
  Widget build(BuildContext context) {
    String titleName = title.title;
    Color backgroundColor = appStateSettings["materialYou"]
        ? dynamicPastel(
            context, Theme.of(context).colorScheme.secondaryContainer,
            amountLight: 0, amountDark: 0.6)
        : getColor(context, "lightDarkAccent");

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Tappable(
        onTap: () {
          openBottomSheet(
            context,
            fullSnap: true,
            PopupFramework(
              title: "set-title".tr(),
              child: SelectText(
                setSelectedText: (text) {
                  titleName = text;
                  setTitle(text);
                },
                labelText: "set-title".tr(),
                selectedText: titleName,
                placeholder: "title-placeholder".tr(),
              ),
            ),
          );
          // Fix over-scroll stretch when keyboard pops up quickly
          Future.delayed(Duration(milliseconds: 100), () {
            bottomSheetControllerGlobal.scrollTo(0,
                duration: Duration(milliseconds: 100));
          });
        },
        borderRadius: 15,
        color: backgroundColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                child: TextFont(
                  text: title.title,
                  fontSize: 16.5,
                ),
              ),
            ),
            Tappable(
              onTap: () async {
                deleteAssociatedTitlePopup(
                  context,
                  title: title,
                  routesToPopAfterDelete: RoutesToPopAfterDelete.None,
                );
              },
              borderRadius: 15,
              color: backgroundColor,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Icon(
                  appStateSettings["outlinedIcons"]
                      ? Icons.close_outlined
                      : Icons.close_rounded,
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
  const AddButton({
    Key? key,
    required this.onTap,
    this.padding = EdgeInsets.zero,
    this.width = 110,
    this.height = 52,
    this.openPage,
    this.borderRadius = 15,
  }) : super(key: key);

  final VoidCallback onTap;
  final EdgeInsets padding;
  final double? width;
  final double? height;
  final double borderRadius;
  final Widget? openPage;

  @override
  Widget build(BuildContext context) {
    Color color = appStateSettings["materialYou"]
        ? Theme.of(context).colorScheme.secondary.withOpacity(0.3)
        : getColor(context, "lightDarkAccentHeavy");
    Widget getButton(onTap) {
      return Tappable(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              width: 1.5,
              color: color,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          width: width,
          height: height,
          child: Center(
            child: Icon(
              appStateSettings["outlinedIcons"]
                  ? Icons.add_outlined
                  : Icons.add_rounded,
              size: 22,
              color: color,
            ),
          ),
        ),
        onTap: () {
          onTap();
        },
      );
    }

    if (openPage != null) {
      return Padding(
        padding: padding,
        child: OpenContainerNavigation(
          openPage: openPage!,
          button: (openPage) {
            return getButton(openPage);
          },
          borderRadius: borderRadius,
        ),
      );
    }
    Widget button = getButton(onTap);
    return Padding(
      padding: padding,
      child: button,
    );
  }
}

// class IncomeTypeButton extends StatelessWidget {
//   const IncomeTypeButton(
//       {Key? key, required this.onTap, required this.selectedIncome})
//       : super(key: key);
//   final VoidCallback onTap;
//   final bool selectedIncome;
//   @override
//   Widget build(BuildContext context) {
//     return Tappable(
//       onTap: onTap,
//       borderRadius: 10,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
//         child: Row(
//           children: [
//             ButtonIcon(
//               onTap: onTap,
//               icon: selectedIncome
//                   ? appStateSettings["outlinedIcons"] ? Icons.exit_to_app_outlined : Icons.exit_to_app_rounded
//                   : appStateSettings["outlinedIcons"] ? Icons.logout_outlined : Icons.logout_rounded,
//               size: 41,
//             ),
//             SizedBox(width: 15),
//             Expanded(
//               child: TextFont(
//                 text: selectedIncome == false ? "expense".tr() : "income".tr(),
//                 fontWeight: FontWeight.bold,
//                 fontSize: 26,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
