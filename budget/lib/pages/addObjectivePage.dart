import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/editWalletsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/categoryIcon.dart';
import 'package:budget/widgets/globalSnackBar.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/saveBottomButton.dart';
import 'package:budget/widgets/selectAmount.dart';
import 'package:budget/widgets/selectCategoryImage.dart';
import 'package:budget/widgets/selectColor.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/currencyPicker.dart';
import 'package:budget/widgets/transactionEntry/incomeAmountArrow.dart';
import 'package:budget/widgets/transactionEntry/transactionEntryAmount.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:budget/colors.dart';
import 'package:provider/provider.dart';

import '../widgets/sliverStickyLabelDivider.dart';
import 'exchangeRatesPage.dart';

class AddObjectivePage extends StatefulWidget {
  AddObjectivePage({
    Key? key,
    this.objective,
    required this.routesToPopAfterDelete,
  }) : super(key: key);

  //When a wallet is passed in, we are editing that wallet
  final Objective? objective;
  final RoutesToPopAfterDelete routesToPopAfterDelete;

  @override
  _AddObjectivePageState createState() => _AddObjectivePageState();
}

class _AddObjectivePageState extends State<AddObjectivePage> {
  bool? canAddObjective;

  String? selectedTitle;
  Color? selectedColor;
  late String? selectedImage = widget.objective == null ? "image.png" : null;
  String? selectedEmoji;
  double selectedAmount = 0;

  FocusNode _titleFocusNode = FocusNode();

  void setSelectedTitle(String title) {
    setState(() {
      selectedTitle = title;
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

  void setSelectedColor(Color? color) {
    selectedColor = color;
    determineBottomButton();
    return;
  }

  void setSelectedAmount(double amount) {
    setState(() {
      selectedAmount = amount;
    });
    determineBottomButton();
    return;
  }

  Future<void> selectAmount(BuildContext context) async {
    openBottomSheet(
      context,
      fullSnap: true,
      PopupFramework(
        title: "enter-amount".tr(),
        underTitleSpace: false,
        child: SelectAmount(
          onlyShowCurrencyIcon: true,
          amountPassed: selectedAmount.toString(),
          setSelectedAmount: (amount, calculation) {
            setSelectedAmount(amount.abs());
            setState(() {
              selectedAmount = amount.abs();
            });
            determineBottomButton();
          },
          next: () async {
            Navigator.pop(context);
          },
          nextLabel: "set-amount".tr(),
        ),
      ),
    );
  }

  Future addObjective() async {
    print("Added objective");
    await database.createOrUpdateObjective(
        insert: widget.objective == null, await createObjective());
    Navigator.pop(context);
  }

  Future<Objective> createObjective() async {
    int numberOfObjectives =
        (await database.getTotalCountOfObjectives())[0] ?? 0;
    return Objective(
      objectivePk:
          widget.objective != null ? widget.objective!.objectivePk : "-1",
      name: selectedTitle ?? "",
      colour: toHexString(selectedColor),
      dateCreated: widget.objective != null
          ? widget.objective!.dateCreated
          : DateTime.now(),
      dateTimeModified: null,
      order: widget.objective != null
          ? widget.objective!.order
          : numberOfObjectives,
      amount: selectedAmount,
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.objective != null) {
      //We are editing an objective
      //Fill in the information from the passed in objective
      //Outside of future.delayed because of textinput when in web mode initial value
      selectedTitle = widget.objective!.name;
      selectedColor = widget.objective!.colour == null
          ? null
          : HexColor(widget.objective!.colour);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  determineBottomButton() {
    if (selectedTitle != null) {
      if (canAddObjective != true)
        this.setState(() {
          canAddObjective = true;
        });
    } else {
      if (canAddObjective != false)
        this.setState(() {
          canAddObjective = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.objective != null) {
          discardChangesPopup(
            context,
            previousObject: widget.objective,
            currentObject: await createObjective(),
          );
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
          title: widget.objective == null
              ? "add-objective".tr()
              : "edit-objective".tr(),
          onBackButton: () async {
            if (widget.objective != null) {
              discardChangesPopup(
                context,
                previousObject: widget.objective,
                currentObject: await createObjective(),
              );
            } else {
              discardChangesPopup(context, forceShow: true);
            }
          },
          onDragDownToDismiss: () async {
            if (widget.objective != null) {
              discardChangesPopup(
                context,
                previousObject: widget.objective,
                currentObject: await createObjective(),
              );
            } else {
              discardChangesPopup(context, forceShow: true);
            }
          },
          actions: [
            ...(widget.objective != null &&
                    widget.objective!.objectivePk != "0" &&
                    widget.routesToPopAfterDelete !=
                        RoutesToPopAfterDelete.PreventDelete
                ? [
                    IconButton(
                      padding: EdgeInsets.all(15),
                      tooltip: "delete-objective".tr(),
                      onPressed: () {
                        deleteObjectivePopup(
                          context,
                          objective: widget.objective!,
                          routesToPopAfterDelete: widget.routesToPopAfterDelete,
                        );
                      },
                      icon: Icon(appStateSettings["outlinedIcons"]
                          ? Icons.delete_outlined
                          : Icons.delete_rounded),
                    )
                  ]
                : [])
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
                    label: widget.objective == null
                        ? "add-objective".tr()
                        : "save-changes".tr(),
                    onTap: () async {
                      await addObjective();
                    },
                    disabled: !(canAddObjective ?? false),
                  ),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: Row(
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
                            setSelectedTitle: (String? titleRecommendation) {},
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
                          onChanged: (text) {
                            setSelectedTitle(text);
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
            ),

            SliverToBoxAdapter(
              child: Row(
                children: [
                  IntrinsicWidth(
                    child: TappableTextEntry(
                      title: convertToMoney(
                          Provider.of<AllWallets>(context), selectedAmount),
                      placeholder:
                          convertToMoney(Provider.of<AllWallets>(context), 0),
                      showPlaceHolderWhenTextEquals:
                          convertToMoney(Provider.of<AllWallets>(context), 0),
                      onTap: () {
                        selectAmount(context);
                      },
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      internalPadding:
                          EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 3),
                    ),
                  ),
                ],
              ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(height: 14),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 65,
                child: SelectColor(
                  horizontalList: true,
                  selectedColor: selectedColor,
                  setSelectedColor: setSelectedColor,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: 15),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 65)),
            // SliverToBoxAdapter(
            //   child: KeyboardHeightAreaAnimated(),
            // ),
          ],
        ),
      ),
    );
  }
}

Future<DeletePopupAction?> deleteObjectivePopup(
  BuildContext context, {
  required Objective objective,
  required RoutesToPopAfterDelete routesToPopAfterDelete,
}) async {
  return null;
}
