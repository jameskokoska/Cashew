import 'package:budget/database/tables.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/editWalletsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/saveBottomButton.dart';
import 'package:budget/widgets/selectAmount.dart';
import 'package:budget/widgets/selectColor.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/currencyPicker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:budget/colors.dart';

class AddWalletPage extends StatefulWidget {
  AddWalletPage({
    Key? key,
    this.wallet,
  }) : super(key: key);

  //When a wallet is passed in, we are editing that wallet
  final TransactionWallet? wallet;

  @override
  _AddWalletPageState createState() => _AddWalletPageState();
}

class _AddWalletPageState extends State<AddWalletPage> {
  GlobalKey<PageFrameworkState> addWalletPageKey = GlobalKey();

  bool? canAddWallet;

  String? selectedTitle;
  Color? selectedColor;
  String? selectedIconName;
  Map<String, dynamic> currencies = {};
  bool customCurrencyIcon = false;
  String? searchCurrency = "";
  String selectedCurrency = "usd"; //if no currency selected use empty string
  int selectedDecimals = 2;
  FocusNode _titleFocusNode = FocusNode();

  Future<void> selectColor(BuildContext context) async {
    openBottomSheet(
      context,
      PopupFramework(
        title: "select-color".tr(),
        child: SelectColor(
          selectedColor: selectedColor,
          setSelectedColor: setSelectedColor,
        ),
      ),
    );
  }

  void setSelectedTitle(String title) {
    setState(() {
      selectedTitle = title;
    });
    determineBottomButton();
    return;
  }

  void setSelectedColor(Color? color) {
    selectedColor = color;
    determineBottomButton();
    return;
  }

  void setSelectedCurrency(String currencyKey) {
    setState(() {
      selectedCurrency = currencyKey;
    });
    determineBottomButton();
    return;
  }

  void setSelectedIconName(String iconName) {
    setState(() {
      selectedIconName = iconName;
    });
    return;
  }

  Future addWallet() async {
    print("Added wallet");
    await database.createOrUpdateWallet(await createTransactionWallet());
    Navigator.pop(context);
  }

  Future<TransactionWallet> createTransactionWallet() async {
    int numberOfWallets = (await database.getTotalCountOfWallets())[0] ?? 0;
    return TransactionWallet(
      walletPk: widget.wallet != null
          ? widget.wallet!.walletPk
          : DateTime.now().millisecondsSinceEpoch,
      name: selectedTitle ?? "",
      colour: toHexString(selectedColor),
      dateCreated:
          widget.wallet != null ? widget.wallet!.dateCreated : DateTime.now(),
      dateTimeModified: null,
      order: widget.wallet != null ? widget.wallet!.order : numberOfWallets,
      currency: selectedCurrency,
      decimals: selectedDecimals,
    );
  }

  void populateCurrencies() {
    Future.delayed(Duration.zero, () async {
      setState(() {
        //Set to false because we can't save until we made some changes
        canAddWallet = false;
        currencies = currenciesJSON;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.wallet != null) {
      //We are editing a wallet
      //Fill in the information from the passed in wallet
      //Outside of future.delayed because of textinput when in web mode initial value
      selectedTitle = widget.wallet!.name;
      selectedColor = widget.wallet!.colour == null
          ? null
          : HexColor(widget.wallet!.colour);
      selectedCurrency = widget.wallet!.currency ?? "usd";
      selectedDecimals = widget.wallet!.decimals;
    } else {}
    populateCurrencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  determineBottomButton() {
    if (selectedTitle != null && selectedCurrency != "") {
      if (canAddWallet != true)
        this.setState(() {
          canAddWallet = true;
        });
    } else {
      if (canAddWallet != false)
        this.setState(() {
          canAddWallet = false;
        });
    }
  }

  void searchCurrencies(String searchTerm) async {
    if (searchTerm == "") {
      populateCurrencies();
    } else {
      Map<String, dynamic> outCurrencies = {};
      for (String key in currenciesJSON.keys) {
        dynamic currency = currenciesJSON[key];
        if ((currency["CountryName"] != null &&
                currency["CountryName"]
                    .toLowerCase()
                    .contains(searchTerm.toLowerCase())) ||
            (currency["Currency"] != null &&
                currency["Currency"]
                    .toLowerCase()
                    .contains(searchTerm.toLowerCase())) ||
            (currency["Code"] != null &&
                currency["Code"]
                    .toLowerCase()
                    .contains(searchTerm.toLowerCase()))) {
          outCurrencies[key] = currency;
        }
      }
      setState(() {
        currencies = outCurrencies;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> currencyList = [];
    for (int index = 0; index < currencies.keys.length; index++) {
      String key = currencies.keys.toList()[index];
      currencyList.add(Padding(
        padding: const EdgeInsets.only(left: 18.0, right: 18, bottom: 5),
        child: Tappable(
          color: selectedCurrency == key
              ? Theme.of(context).colorScheme.secondaryContainer
              : getColor(context, "lightDarkAccent"),
          borderRadius: 13,
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
            setSelectedCurrency(key);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    TextFont(
                        text: currencies[key]?["CountryName"] ??
                            currencies[key]?["Currency"]),
                  ],
                ),
                Row(
                  children: [
                    TextFont(
                        text: currencies[key]["Symbol"] +
                            " " +
                            currencies[key]["Code"]),
                  ],
                )
              ],
            ),
          ),
        ),
      ));
    }

    return WillPopScope(
      onWillPop: () async {
        if (widget.wallet != null) {
          discardChangesPopup(
            context,
            previousObject: widget.wallet,
            currentObject: await createTransactionWallet(),
          );
        } else {
          discardChangesPopup(context);
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
          key: addWalletPageKey,
          resizeToAvoidBottomInset: true,
          dragDownToDismiss: true,
          title: widget.wallet == null ? "add-wallet".tr() : "edit-wallet".tr(),
          onBackButton: () async {
            if (widget.wallet != null) {
              discardChangesPopup(
                context,
                previousObject: widget.wallet,
                currentObject: await createTransactionWallet(),
              );
            } else {
              discardChangesPopup(context);
            }
          },
          onDragDownToDissmiss: () async {
            if (widget.wallet != null) {
              discardChangesPopup(
                context,
                previousObject: widget.wallet,
                currentObject: await createTransactionWallet(),
              );
            } else {
              discardChangesPopup(context);
            }
          },
          actions: [
            IconButton(
              padding: EdgeInsets.all(15),
              tooltip: "info".tr(),
              onPressed: () {
                openPopup(
                  context,
                  title: "exchange-rate-notice".tr(),
                  description: "exchange-rate-notice-description".tr(),
                  icon: Icons.info,
                  onCancel: () {
                    Navigator.pop(context);
                  },
                  onCancelLabel: "ok".tr(),
                );
              },
              icon: Icon(Icons.info),
            ),
            widget.wallet != null && widget.wallet!.walletPk != 0
                ? IconButton(
                    padding: EdgeInsets.all(15),
                    tooltip: "Delete wallet",
                    onPressed: () {
                      deleteWalletPopup(context, widget.wallet!,
                          afterDelete: () {
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      });
                    },
                    icon: Icon(Icons.delete_rounded),
                  )
                : SizedBox.shrink()
          ],
          overlay: Align(
            alignment: Alignment.bottomCenter,
            child: selectedTitle == "" || selectedTitle == null
                ? SaveBottomButton(
                    label: "set-title".tr(),
                    onTap: () async {
                      FocusScope.of(context).unfocus();
                      Future.delayed(Duration(milliseconds: 100), () {
                        _titleFocusNode.requestFocus();
                      });
                    },
                    disabled: false,
                  )
                : SaveBottomButton(
                    label: widget.wallet == null
                        ? "add-wallet".tr()
                        : "save-changes".tr(),
                    onTap: () async {
                      await addWallet();
                    },
                    disabled: !(canAddWallet ?? false),
                  ),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextInput(
                  focusNode: _titleFocusNode,
                  labelText: "name-placeholder".tr(),
                  bubbly: false,
                  initialValue: selectedTitle,
                  onChanged: (text) {
                    setSelectedTitle(text);
                  },
                  padding: EdgeInsets.only(left: 7, right: 7),
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  topContentPadding: 20,
                ),
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
            SliverStickyLabelDivider(
              info: "select-currency".tr(),
              sliver: ColumnSliver(children: [
                SizedBox(height: 10),
                CurrencyPicker(
                  onSelected: setSelectedCurrency,
                  initialCurrency: selectedCurrency,
                  onHasFocus: () {
                    Future.delayed(Duration(milliseconds: 500), () {
                      addWalletPageKey.currentState?.scrollTo(250);
                    });
                  },
                  extraButton: Row(
                    children: [
                      SizedBox(width: 10),
                      ButtonIcon(
                          onTap: () {
                            openBottomSheet(
                              context,
                              PopupFramework(
                                title: "decimal-precision".tr(),
                                child: SelectAmountValue(
                                  amountPassed: selectedDecimals.toString(),
                                  setSelectedAmount: (amount, _) {
                                    selectedDecimals = amount.toInt();
                                    if (amount > 10) {
                                      selectedDecimals = 10;
                                    } else if (amount < 0) {
                                      selectedDecimals = 0;
                                    }
                                    setState(() {});
                                  },
                                  next: () async {
                                    determineBottomButton();
                                    Navigator.pop(context);
                                  },
                                  nextLabel: "set-amount".tr(),
                                ),
                              ),
                            );
                          },
                          icon: Icons.more_horiz_rounded),
                      SizedBox(width: 18),
                    ],
                  ),
                ),
              ]),
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
