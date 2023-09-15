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
import 'package:budget/widgets/util/showDatePicker.dart';
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

class _AddObjectivePageState extends State<AddObjectivePage>
    with SingleTickerProviderStateMixin {
  bool? canAddObjective;

  String? selectedTitle;
  Color? selectedColor;
  late String? selectedImage = widget.objective == null ? "image.png" : null;
  String? selectedEmoji;
  double selectedAmount = 0;
  DateTime selectedStartDate = DateTime.now();
  bool selectedIncome = true;

  FocusNode _titleFocusNode = FocusNode();
  late TabController _incomeTabController =
      TabController(length: 2, vsync: this);

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
    setState(() {
      selectedColor = color;
    });
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

  void setSelectedIncome(bool income) {
    setState(() {
      selectedIncome = income;
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

  Future<void> selectStartDate(BuildContext context) async {
    final DateTime? picked =
        await showCustomDatePicker(context, selectedStartDate);
    setSelectedStartDate(picked);
  }

  setSelectedStartDate(DateTime? date) {
    if (date != null && date != selectedStartDate) {
      setState(() {
        selectedStartDate = date;
      });
    }
    determineBottomButton();
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
      dateCreated: selectedStartDate,
      dateTimeModified: null,
      order: widget.objective != null
          ? widget.objective!.order
          : numberOfObjectives,
      emojiIconName: selectedEmoji,
      iconName: selectedImage,
      amount: selectedAmount,
      income: selectedIncome,
      pinned: true,
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
      selectedImage = widget.objective!.iconName;
      selectedEmoji = widget.objective!.emojiIconName;
      selectedStartDate = widget.objective!.dateCreated;
      selectedAmount = widget.objective!.amount;

      selectedIncome = widget.objective!.income;
      if (widget.objective?.income == true) {
        _incomeTabController.animateTo(1);
      } else {
        _incomeTabController.animateTo(0);
      }
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 13),
                child: ClipRRect(
                  borderRadius: getPlatform() == PlatformOS.isIOS
                      ? BorderRadius.circular(10)
                      : BorderRadius.circular(15),
                  child: Material(
                    color: Theme.of(context)
                        .colorScheme
                        .secondaryContainer
                        .withOpacity(0.2),
                    child: Theme(
                      data: ThemeData().copyWith(
                        splashColor: Theme.of(context).splashColor,
                      ),
                      child: TabBar(
                        splashFactory: Theme.of(context).splashFactory,
                        controller: _incomeTabController,
                        onTap: (value) {
                          if (value == 1)
                            setSelectedIncome(true);
                          else
                            setSelectedIncome(false);
                        },
                        dividerColor: Colors.transparent,
                        indicatorColor: Colors.transparent,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          color:
                              Theme.of(context).colorScheme.secondaryContainer,
                        ),
                        labelColor: getColor(context, "black"),
                        unselectedLabelColor:
                            getColor(context, "black").withOpacity(0.3),
                        tabs: [
                          Tab(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(
                                  "savings-goal".tr(),
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontFamily: 'Avenir',
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          Tab(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(
                                  "expense-goal".tr(),
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontFamily: 'Avenir',
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
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
                          initialValue: selectedTitle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
              child: SizedBox(
                height: 10,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: TextFont(
                        text: "goal".tr() + " ",
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Flexible(
                      child: IntrinsicWidth(
                        child: TappableTextEntry(
                          title: convertToMoney(
                              Provider.of<AllWallets>(context), selectedAmount),
                          placeholder: convertToMoney(
                              Provider.of<AllWallets>(context), 0),
                          showPlaceHolderWhenTextEquals: convertToMoney(
                              Provider.of<AllWallets>(context), 0),
                          onTap: () {
                            selectAmount(context);
                          },
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          internalPadding:
                              EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                          padding:
                              EdgeInsets.symmetric(vertical: 10, horizontal: 3),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Tappable(
                onTap: () {
                  selectStartDate(context);
                },
                color: Colors.transparent,
                borderRadius: 15,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                  child: Center(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.end,
                      runAlignment: WrapAlignment.center,
                      alignment: WrapAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5.8),
                          child: TextFont(
                            text: "starting".tr() + " ",
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IgnorePointer(
                          child: TappableTextEntry(
                            title: getWordedDateShortMore(selectedStartDate),
                            placeholder: "",
                            onTap: () {
                              selectAmount(context);
                            },
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            internalPadding: EdgeInsets.symmetric(
                                vertical: 2, horizontal: 4),
                            padding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
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
