import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/editWalletsPage.dart';
import 'package:budget/struct/currencyFunctions.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/countNumber.dart';
import 'package:budget/widgets/dropdownSelect.dart';
import 'package:budget/widgets/globalSnackbar.dart';
import 'package:budget/widgets/iconButtonScaled.dart';
import 'package:budget/widgets/moreIcons.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/saveBottomButton.dart';
import 'package:budget/widgets/selectAmount.dart';
import 'package:budget/widgets/selectColor.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/tappableTextEntry.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/currencyPicker.dart';
import 'package:budget/widgets/transactionEntry/incomeAmountArrow.dart';
import 'package:budget/widgets/transactionEntry/transactionEntryAmount.dart';
import 'package:budget/widgets/util/showDatePicker.dart';
import 'package:budget/widgets/util/showTimePicker.dart';
import 'package:budget/widgets/util/widgetSize.dart';
import 'package:budget/widgets/walletEntry.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:budget/colors.dart';
import 'package:provider/provider.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../widgets/sliverStickyLabelDivider.dart';
import 'exchangeRatesPage.dart';

class AddWalletPage extends StatefulWidget {
  AddWalletPage({
    Key? key,
    this.wallet,
    required this.routesToPopAfterDelete,
    this.runWhenOpen,
  }) : super(key: key);

  //When a wallet is passed in, we are editing that wallet
  final TransactionWallet? wallet;
  final RoutesToPopAfterDelete routesToPopAfterDelete;
  final VoidCallback? runWhenOpen;

  @override
  _AddWalletPageState createState() => _AddWalletPageState();
}

class _AddWalletPageState extends State<AddWalletPage> {
  bool? canAddWallet;

  String? selectedTitle;
  Color? selectedColor;
  String? selectedIconName;
  Map<String, dynamic> currencies = {};
  bool customCurrencyIcon = false;
  String? searchCurrency = "";
  String selectedCurrency =
      getDevicesDefaultCurrencyCode(); //if no currency selected use empty string
  int selectedDecimals = 2;
  FocusNode _titleFocusNode = FocusNode();

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

  Future addWallet({bool popContext = true}) async {
    print("Added wallet");
    final int? rowId = await database.createOrUpdateWallet(
        insert: widget.wallet == null, await createTransactionWallet());

    // set initial amount
    if (widget.wallet == null && initialBalance != 0) {
      if (rowId != null) {
        final TransactionWallet walletJustAdded =
            await database.getWalletFromRowId(rowId);
        await correctWalletBalance(context, initialBalance, initialBalance,
            walletJustAdded, DateTime.now(), "");
      }
    }

    if (popContext) {
      Navigator.pop(context);
    } else {
      walletInitial = await createTransactionWallet();
    }
  }

  Future<TransactionWallet> createTransactionWallet() async {
    int numberOfWallets = (await database.getTotalCountOfWallets())[0] ?? 0;
    return TransactionWallet(
      walletPk: widget.wallet != null ? widget.wallet!.walletPk : "-1",
      name: selectedTitle ?? "",
      colour: toHexString(selectedColor),
      dateCreated:
          widget.wallet != null ? widget.wallet!.dateCreated : DateTime.now(),
      dateTimeModified: null,
      order: widget.wallet != null ? widget.wallet!.order : numberOfWallets,
      currency: selectedCurrency,
      decimals: selectedDecimals,
      homePageWidgetDisplay: widget.wallet != null
          ? widget.wallet!.homePageWidgetDisplay
          : defaultWalletHomePageWidgetDisplay,
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

  TransactionWallet? walletInitial;

  void showDiscardChangesPopupIfNotEditing() async {
    TransactionWallet walletCreated = await createTransactionWallet();
    walletCreated =
        walletCreated.copyWith(dateCreated: walletInitial?.dateCreated);
    if (walletCreated != walletInitial && widget.wallet == null) {
      discardChangesPopup(context, forceShow: true);
    } else {
      Navigator.pop(context);
    }
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
    }
    populateCurrencies();
    Future.delayed(Duration.zero, () async {
      if (widget.runWhenOpen != null) widget.runWhenOpen!();
      walletInitial = await createTransactionWallet();
    });
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

  void openDecimalPrecisionPopup() async {
    await openBottomSheet(
      context,
      PopupFramework(
        title: "decimal-precision".tr(),
        subtitle: "decimal-precision-description".tr(),
        child: SelectAmountValue(
          enableDecimal: false,
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
    determineBottomButton();
  }

  double initialBalance = 0;
  openEnterInitialBalanceBottomSheet() {
    openBottomSheet(
      context,
      fullSnap: true,
      PopupFramework(
        title: "enter-amount".tr(),
        hasPadding: false,
        underTitleSpace: false,
        child: SelectAmount(
          enableWalletPicker: false,
          padding: EdgeInsets.symmetric(horizontal: 18),
          onlyShowCurrencyIcon: true,
          selectedWalletPk: appStateSettings["selectedWalletPk"],
          amountPassed: initialBalance.toString(),
          setSelectedAmount: (amount, _) {
            setState(() {
              initialBalance = amount;
            });
          },
          next: () async {
            Navigator.pop(context);
          },
          currencyKey: selectedCurrency,
          nextLabel: "set-amount".tr(),
          allowZero: true,
          decimals: selectedDecimals == 2 ? null : selectedDecimals,
        ),
      ),
    );
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
                          currencies[key]?["Currency"] ??
                          "",
                    ),
                  ],
                ),
                Row(
                  children: [
                    TextFont(
                        text: (currencies[key]?["Symbol"] ?? "") +
                            " " +
                            (currencies[key]?["Code"] ?? "")),
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
            previousObject: walletInitial,
            currentObject: await createTransactionWallet(),
          );
        } else {
          showDiscardChangesPopupIfNotEditing();
        }
        return false;
      },
      child: GestureDetector(
        onTap: () {
          minimizeKeyboard(context);
        },
        child: PageFramework(
          resizeToAvoidBottomInset: true,
          dragDownToDismiss: true,
          horizontalPadding: getHorizontalPaddingConstrained(context),
          title:
              widget.wallet == null ? "add-account".tr() : "edit-account".tr(),
          onBackButton: () async {
            if (widget.wallet != null) {
              discardChangesPopup(
                context,
                previousObject: walletInitial,
                currentObject: await createTransactionWallet(),
              );
            } else {
              showDiscardChangesPopupIfNotEditing();
            }
          },
          onDragDownToDismiss: () async {
            if (widget.wallet != null) {
              discardChangesPopup(
                context,
                previousObject: walletInitial,
                currentObject: await createTransactionWallet(),
              );
            } else {
              showDiscardChangesPopupIfNotEditing();
            }
          },
          actions: [
            CustomPopupMenuButton(
              showButtons: enableDoubleColumn(context),
              keepOutFirst: true,
              items: [
                if (widget.wallet != null &&
                    widget.wallet!.walletPk != "0" &&
                    widget.routesToPopAfterDelete !=
                        RoutesToPopAfterDelete.PreventDelete)
                  DropdownItemMenu(
                    id: "delete-account",
                    label: "delete-account".tr(),
                    icon: appStateSettings["outlinedIcons"]
                        ? Icons.delete_outlined
                        : Icons.delete_rounded,
                    action: () {
                      deleteWalletPopup(
                        context,
                        wallet: widget.wallet!,
                        routesToPopAfterDelete: widget.routesToPopAfterDelete,
                      );
                    },
                  ),
                DropdownItemMenu(
                  id: "info",
                  label: "info".tr(),
                  icon: appStateSettings["outlinedIcons"]
                      ? Icons.info_outlined
                      : Icons.info_outline_rounded,
                  action: () {
                    openPopup(
                      context,
                      title: "exchange-rate-notice".tr(),
                      description: "exchange-rate-notice-description".tr(),
                      icon: appStateSettings["outlinedIcons"]
                          ? Icons.info_outlined
                          : Icons.info_outline_rounded,
                      onCancel: () {
                        Navigator.pop(context);
                      },
                      onCancelLabel: "ok".tr(),
                      onSubmit: () async {
                        checkIfExchangeRateChangeBefore();
                        Navigator.pop(context);
                        await pushRoute(context, ExchangeRates());
                        checkIfExchangeRateChangeAfter();
                      },
                      onSubmitLabel: "exchange-rates".tr(),
                    );
                  },
                ),
              ],
            ),
          ],
          staticOverlay: Align(
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
                    label: widget.wallet == null
                        ? "add-account".tr()
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
                  autoFocus: kIsWeb && getIsFullScreen(context),
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
            SliverToBoxAdapter(
              child: widget.wallet == null ||
                      widget.routesToPopAfterDelete ==
                          RoutesToPopAfterDelete.PreventDelete
                  ? SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(
                        left: 24,
                        right: 24,
                        bottom: 10,
                      ),
                      child: SettingsContainer(
                        isOutlined: true,
                        onTap: () async {
                          if (widget.wallet != null)
                            mergeWalletPopup(
                              context,
                              walletOriginal: widget.wallet!,
                              routesToPopAfterDelete:
                                  widget.routesToPopAfterDelete,
                            );
                        },
                        title: "merge-account".tr(),
                        icon: appStateSettings["outlinedIcons"]
                            ? Icons.merge_outlined
                            : Icons.merge_rounded,
                        iconScale: 1,
                        isWideOutlined: true,
                      ),
                    ),
            ),
            if (widget.wallet != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 10,
                  ),
                  child: WidgetSizeBuilder(widgetBuilder: (Size? size) {
                    return Container(
                      height: size?.height,
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: SettingsContainer(
                                isOutlinedColumn: true,
                                isOutlined: true,
                                onTap: () async {
                                  // Save any changes made to the wallet
                                  await addWallet(popContext: false);
                                  TransactionWallet wallet =
                                      await createTransactionWallet();
                                  openBottomSheet(
                                    context,
                                    fullSnap: true,
                                    CorrectBalancePopup(wallet: wallet),
                                  );
                                },
                                title: "correct-total-balance".tr(),
                                icon: appStateSettings["outlinedIcons"]
                                    ? Icons.library_add_outlined
                                    : Icons.library_add_rounded,
                                iconScale: 1,
                                isWideOutlined: true,
                                horizontalPadding: 5,
                              ),
                            ),
                          ),
                          if (Provider.of<AllWallets>(context)
                                  .indexedByPk
                                  .keys
                                  .length >
                              1)
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: SettingsContainer(
                                  isOutlinedColumn: true,
                                  isOutlined: true,
                                  onTap: () async {
                                    if (widget.wallet != null) {
                                      // Save any changes made to the wallet
                                      await addWallet(popContext: false);
                                      TransactionWallet wallet =
                                          await createTransactionWallet();
                                      openBottomSheet(
                                        context,
                                        fullSnap: true,
                                        TransferBalancePopup(
                                          wallet: wallet,
                                          allowEditWallet: false,
                                        ),
                                      );
                                    }
                                  },
                                  title: "transfer-balance".tr(),
                                  icon: appStateSettings["outlinedIcons"]
                                      ? Icons.compare_arrows_outlined
                                      : Icons.compare_arrows_rounded,
                                  iconScale: 1,
                                  isWideOutlined: true,
                                  horizontalPadding: 5,
                                ),
                              ),
                            ),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: SettingsContainer(
                                isOutlinedColumn: true,
                                isOutlined: true,
                                onTap: () async {
                                  openDecimalPrecisionPopup();
                                },
                                title: "decimal-precision".tr(),
                                icon: appStateSettings["outlinedIcons"]
                                    ? Symbols.decimal_increase_sharp
                                    : Symbols.decimal_increase_rounded,
                                iconScale: 1,
                                isWideOutlined: true,
                                horizontalPadding: 5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            if (widget.wallet == null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: 10,
                    left: 20,
                    right: 20,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: TextFont(
                          text: "starting-at".tr() + " ",
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Flexible(
                        child: TappableTextEntry(
                          title: convertToMoney(
                            Provider.of<AllWallets>(context),
                            currencyKey: selectedCurrency,
                            initialBalance,
                            decimals: selectedDecimals,
                          ),
                          placeholder: convertToMoney(
                            Provider.of<AllWallets>(context),
                            currencyKey: selectedCurrency,
                            initialBalance,
                          ),
                          showPlaceHolderWhenTextEquals: convertToMoney(
                            Provider.of<AllWallets>(context),
                            currencyKey: selectedCurrency,
                            0,
                          ),
                          onTap: () {
                            openEnterInitialBalanceBottomSheet();
                          },
                          fontSize: 32,
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
              ),
            if (widget.wallet == null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 24,
                    bottom: 10,
                  ),
                  child: SettingsContainer(
                    isOutlinedColumn: false,
                    isOutlined: true,
                    onTap: () async {
                      openDecimalPrecisionPopup();
                    },
                    title: "decimal-precision".tr(),
                    icon: appStateSettings["outlinedIcons"]
                        ? Symbols.decimal_increase_sharp
                        : Symbols.decimal_increase_rounded,
                    iconScale: 1,
                    isWideOutlined: true,
                    horizontalPadding: 15,
                  ),
                ),
              ),
            ColumnSliver(children: [
              SizedBox(height: 10),
              CurrencyPicker(
                onSelected: setSelectedCurrency,
                initialCurrency: selectedCurrency,
                onHasFocus: () {
                  // Disable scroll when focus - because iOS header height is different than that of Android.
                  // Future.delayed(Duration(milliseconds: 500), () {
                  //   addWalletPageKey.currentState?.scrollTo(250);
                  // });
                },
                padding: EdgeInsets.symmetric(horizontal: 24),
              ),
            ]),
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

class CorrectBalancePopup extends StatefulWidget {
  const CorrectBalancePopup({
    required this.wallet,
    this.showAllEditDetails = false,
    super.key,
  });
  final TransactionWallet wallet;
  final bool showAllEditDetails;

  @override
  State<CorrectBalancePopup> createState() => _CorrectBalancePopupState();
}

class _CorrectBalancePopupState extends State<CorrectBalancePopup> {
  double enteredAmount = 0;
  bool isNegative = false;
  TimeOfDay? selectedTime = null;
  DateTime? selectedDateTime = null;
  String selectedTitle = "";

  @override
  Widget build(BuildContext context) {
    Widget editTransferDetails = Column(
      children: [
        TextInput(
          icon: appStateSettings["outlinedIcons"]
              ? Icons.title_outlined
              : Icons.title_rounded,
          autoFocus: widget.showAllEditDetails == false,
          onChanged: (text) async {
            selectedTitle = text;
          },
          onEditingComplete: widget.showAllEditDetails == true
              ? null
              : () {
                  if (widget.showAllEditDetails) Navigator.maybePop(context);
                },
          initialValue: selectedTitle,
          labelText: "transfer-balance".tr(),
          padding: EdgeInsets.only(bottom: 13),
        ),
        DateButton(
          internalPadding: EdgeInsets.only(right: 5),
          initialSelectedDate: selectedDateTime ?? DateTime.now(),
          initialSelectedTime: TimeOfDay(
              hour: selectedDateTime?.hour ?? TimeOfDay.now().hour,
              minute: selectedDateTime?.minute ?? TimeOfDay.now().minute),
          setSelectedDate: (date) {
            selectedDateTime = date;
          },
          setSelectedTime: (time) {
            selectedDateTime = (selectedDateTime ?? DateTime.now())
                .copyWith(hour: time.hour, minute: time.minute);
          },
        ),
      ],
    );

    return PopupFramework(
      title: "correct-balance".tr(),
      subtitle: widget.wallet.name,
      underTitleSpace: false,
      outsideExtraWidget: widget.showAllEditDetails
          ? null
          : IconButton(
              iconSize: 25,
              padding:
                  EdgeInsets.all(getPlatform() == PlatformOS.isIOS ? 15 : 20),
              icon: Icon(
                appStateSettings["outlinedIcons"]
                    ? Icons.edit_outlined
                    : Icons.edit_rounded,
              ),
              onPressed: () async {
                await openBottomSheet(
                  context,
                  popupWithKeyboard: true,
                  PopupFramework(
                    child: editTransferDetails,
                    title: "transaction-details".tr(),
                  ),
                );
                setState(() {});
              },
            ),
      child: StreamBuilder<double?>(
        stream: database.watchTotalOfWalletNoConversion(
          widget.wallet.walletPk,
        ),
        builder: (context, snapshot) {
          double totalWalletAmount = snapshot.data ?? 0;
          return Column(
            children: [
              if (widget.showAllEditDetails)
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: editTransferDetails,
                ),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  TextFont(
                    autoSizeText: true,
                    maxLines: 1,
                    minFontSize: 16,
                    text: convertToMoney(
                      Provider.of<AllWallets>(context),
                      totalWalletAmount,
                      currencyKey: widget.wallet.currency,
                      decimals: widget.wallet.decimals,
                    ),
                    textAlign: TextAlign.center,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(
                      appStateSettings["outlinedIcons"]
                          ? Icons.arrow_forward_outlined
                          : Icons.arrow_forward_rounded,
                    ),
                  ),
                  AnimatedSizeSwitcher(
                    clipBehavior: Clip.none,
                    child: TextFont(
                      key: ValueKey(enteredAmount.toString()),
                      autoSizeText: true,
                      maxLines: 1,
                      minFontSize: 16,
                      text: convertToMoney(
                        Provider.of<AllWallets>(context),
                        enteredAmount,
                        currencyKey: widget.wallet.currency,
                        decimals: widget.wallet.decimals,
                        forceAbsoluteZero: false,
                      ),
                      textAlign: TextAlign.center,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Builder(builder: (context) {
                double difference = (enteredAmount - totalWalletAmount);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    difference != 0
                        ? IncomeOutcomeArrow(
                            isIncome: difference > 0,
                            width: 15,
                          )
                        : Container(),
                    Flexible(
                      child: CountNumber(
                        count: difference.abs(),
                        duration: Duration(milliseconds: 300),
                        initialCount: (0),
                        textBuilder: (number) {
                          return TextFont(
                            text: convertToMoney(
                              Provider.of<AllWallets>(context),
                              number,
                              currencyKey: widget.wallet.currency,
                              decimals: widget.wallet.decimals,
                              finalNumber: number,
                            ),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            textColor: difference > 0 == true
                                ? getColor(context, "incomeAmount")
                                : getColor(context, "expenseAmount"),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }),
              SizedBox(height: 8),
              SelectAmount(
                // Rerender when has data, so that the initialValue of negative-amount if correct
                // Also render if no data, because that means the wallet is empty
                // We still want users to be able to correct the amount
                key: ValueKey(snapshot.hasData == false),
                extraWidgetAboveNumbers: SettingsContainerSwitch(
                  title: "negative-amount".tr(),
                  onSwitched: (value) {
                    setState(() {
                      isNegative = value;
                      if (isNegative == true)
                        enteredAmount = enteredAmount.abs() * -1;
                      else
                        enteredAmount = enteredAmount.abs();
                    });
                  },
                  enableBorderRadius: true,
                  initialValue: totalWalletAmount < 0,
                  syncWithInitialValue: false,
                  runOnSwitchedInitially: true,
                  icon: appStateSettings["outlinedIcons"]
                      ? Icons.exposure_outlined
                      : Icons.exposure_rounded,
                ),
                showEnteredNumber: false,
                amountPassed: "0",
                setSelectedAmount: (amount, calculation) {
                  setState(() {
                    if (isNegative == true)
                      enteredAmount = amount.abs() * -1;
                    else
                      enteredAmount = amount.abs();
                  });
                },
                allowZero: true,
                next: () async {
                  await correctWalletBalance(
                    context,
                    enteredAmount - totalWalletAmount,
                    enteredAmount,
                    widget.wallet,
                    selectedDateTime,
                    selectedTitle,
                  );
                  Navigator.pop(context);
                },
                nextLabel: "update-total-balance".tr(),
              ),
            ],
          );
        },
      ),
    );
  }
}

Future<bool> correctWalletBalance(
    BuildContext context,
    double differenceAmount,
    double newAmount,
    TransactionWallet wallet,
    DateTime? dateTime,
    String title) async {
  String transferString = wallet.name +
      ": " +
      convertToMoney(
        Provider.of<AllWallets>(context, listen: false),
        newAmount,
        currencyKey: wallet.currency,
        decimals: wallet.decimals,
      );

  String note = "updated-total-balance".tr() + "\n" + transferString;

  await createCorrectionTransaction(
    differenceAmount,
    wallet,
    note: note,
    dateTime: dateTime,
    title: title,
  );

  openSnackbar(
    SnackbarMessage(
      title: "updated-total-balance".tr(),
      description: transferString,
      icon: appStateSettings["outlinedIcons"]
          ? Icons.library_add_outlined
          : Icons.library_add_rounded,
    ),
  );

  return true;
}

Future<TransactionCategory> initializeBalanceCorrectionCategory() async {
  try {
    return await database.getCategory("0").$2;
  } catch (e) {
    print(
        e.toString() + "- creating default category amount balancing category");
    int numberOfCategories =
        (await database.getTotalCountOfCategories())[0] ?? 0;

    await database.createOrUpdateCategory(
      insert: false,
      updateSharedEntry: false,
      TransactionCategory(
        categoryPk: "0",
        name: "default-category-account-amount-balancing".tr(),
        colour: toHexString(Colors.blueGrey),
        iconName: "charts.png",
        dateCreated: DateTime.now(),
        dateTimeModified: null,
        order: numberOfCategories,
        income: false,
      ),
    );
    return await database.getCategory("0").$2;
  }
}

Future<String?> createCorrectionTransaction(
  double amount,
  TransactionWallet wallet, {
  String? note,
  DateTime? dateTime,
  String? title,
  String? pairedTransactionFk,
  String? objectiveLoanPk,
}) async {
  await initializeBalanceCorrectionCategory();

  int? rowId = await database.createOrUpdateTransaction(
    insert: true,
    updateSharedEntry: false,
    Transaction(
      pairedTransactionFk: pairedTransactionFk,
      transactionPk: "-1",
      name: title ?? "",
      amount: amount,
      note: note ?? "",
      categoryFk: "0",
      walletFk: wallet.walletPk,
      dateCreated: dateTime ?? DateTime.now(),
      income: amount > 0,
      paid: true,
      skipPaid: false,
      objectiveLoanFk: objectiveLoanPk,
    ),
  );
  if (rowId != null) {
    final Transaction transactionJustAdded =
        await database.getTransactionFromRowId(rowId);
    return transactionJustAdded.transactionPk;
  }
  return null;
}

class TransferBalancePopup extends StatefulWidget {
  const TransferBalancePopup({
    required this.wallet,
    required this.allowEditWallet,
    this.showAllEditDetails = false,
    this.initialAmount,
    this.initialDate,
    this.initialTitle,
    this.initialObjectiveLoanPk,
    this.initialIsNegative,
    super.key,
  });
  final TransactionWallet? wallet;
  final bool allowEditWallet;
  final bool showAllEditDetails;
  final double? initialAmount;
  final DateTime? initialDate;
  final String? initialTitle;
  final String? initialObjectiveLoanPk;
  final bool? initialIsNegative;

  @override
  State<TransferBalancePopup> createState() => _TransferBalancePopupState();
}

class _TransferBalancePopupState extends State<TransferBalancePopup> {
  late double enteredAmount = widget.initialAmount ?? 0;
  late bool isNegative = widget.initialIsNegative ?? false;
  late TransactionWallet? walletFrom = widget.wallet;
  TransactionWallet? walletTo;
  late TimeOfDay? selectedTime = widget.initialDate != null
      ? TimeOfDay(
          hour: widget.initialDate!.hour, minute: widget.initialDate!.minute)
      : null;
  late DateTime? selectedDateTime = widget.initialDate ?? null;
  late String selectedTitle = widget.initialTitle ?? "";
  late TransactionWallet? walletForCurrency =
      Provider.of<AllWallets>(context, listen: false)
                  .indexedByPk[appStateSettings["selectedWalletPk"]]
                  ?.currency ==
              widget.wallet?.currency
          ? widget.wallet
          : Provider.of<AllWallets>(context, listen: false)
              .indexedByPk[appStateSettings["selectedWalletPk"]];

  // double transferFee = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      if (widget.wallet == null) {
        walletFrom = await database
            .getWalletInstance(appStateSettings["selectedWalletPk"]);
        setState(() {});
      }
    });
  }

  Widget walletSelector(TransactionWallet? wallet,
      Function(TransactionWallet wallet) onSelected) {
    return Opacity(
      opacity: wallet == null ? 0.5 : 1,
      child: AnimatedSizeSwitcher(
        clipBehavior: Clip.none,
        child: Tappable(
          key: ValueKey(wallet?.walletPk),
          color: getColor(context, "lightDarkAccentHeavyLight"),
          borderRadius: 12,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: HexColor(wallet?.colour,
                        defaultColor: Theme.of(context).colorScheme.primary)
                    .withOpacity(0.7),
                width: 2,
              ),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: TextFont(
                text: (wallet?.name ?? "select-account".tr()) +
                    (wallet != null
                        ? "\n" + (wallet.currency ?? "").toUpperCase()
                        : ""),
                fontSize: 17,
                textAlign: TextAlign.center,
                maxLines: 3,
              ),
            ),
          ),
          onTap: () async {
            dynamic result = await selectWalletPopup(
              context,
              selectedWallet: wallet,
              allowEditWallet: widget.allowEditWallet,
            );
            if (result is TransactionWallet) {
              onSelected(result);
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget editTransferDetails = Column(
      children: [
        TextInput(
          icon: appStateSettings["outlinedIcons"]
              ? Icons.title_outlined
              : Icons.title_rounded,
          autoFocus: widget.showAllEditDetails == false,
          onChanged: (text) async {
            selectedTitle = text;
          },
          onEditingComplete: widget.showAllEditDetails == true
              ? null
              : () {
                  if (widget.showAllEditDetails) Navigator.maybePop(context);
                },
          initialValue: selectedTitle,
          labelText: "transfer-balance".tr(),
          padding: EdgeInsets.only(bottom: 13),
        ),
        DateButton(
          internalPadding: EdgeInsets.only(right: 5),
          initialSelectedDate: selectedDateTime ?? DateTime.now(),
          initialSelectedTime: TimeOfDay(
              hour: selectedDateTime?.hour ?? TimeOfDay.now().hour,
              minute: selectedDateTime?.minute ?? TimeOfDay.now().minute),
          setSelectedDate: (date) {
            selectedDateTime = date;
          },
          setSelectedTime: (time) {
            selectedDateTime = (selectedDateTime ?? DateTime.now())
                .copyWith(hour: time.hour, minute: time.minute);
          },
        ),
      ],
    );
    return PopupFramework(
      title: "transfer-balance".tr(),
      underTitleSpace: false,
      outsideExtraWidget: widget.showAllEditDetails
          ? null
          : IconButton(
              iconSize: 25,
              padding:
                  EdgeInsets.all(getPlatform() == PlatformOS.isIOS ? 15 : 20),
              icon: Icon(
                appStateSettings["outlinedIcons"]
                    ? Icons.edit_outlined
                    : Icons.edit_rounded,
              ),
              onPressed: () async {
                await openBottomSheet(
                  context,
                  popupWithKeyboard: true,
                  PopupFramework(
                    child: editTransferDetails,
                    title: "transaction-details".tr(),
                  ),
                );
                setState(() {});
              },
            ),
      child: Column(
        children: [
          if (widget.showAllEditDetails)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: editTransferDetails,
            ),
          SizedBox(height: 13),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 10,
            children: [
              walletSelector(walletFrom, (wallet) {
                setState(() {
                  walletFrom = wallet;
                });
              }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Tappable(
                  color: dynamicPastel(
                    context,
                    Theme.of(context)
                        .colorScheme
                        .secondaryContainer
                        .withOpacity(0.5),
                    inverse: true,
                  ),
                  borderRadius: 100,
                  onTap: () {
                    setState(() {
                      isNegative = !isNegative;
                      if (isNegative == true)
                        enteredAmount = enteredAmount.abs() * -1;
                      else
                        enteredAmount = enteredAmount.abs();
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AnimatedRotation(
                      duration: Duration(milliseconds: 1200),
                      turns: isNegative ? 0.5 : 1,
                      curve: ElasticOutCurve(0.6),
                      child: Icon(
                        appStateSettings["outlinedIcons"]
                            ? Icons.arrow_forward_outlined
                            : Icons.arrow_forward_rounded,
                      ),
                    ),
                  ),
                ),
              ),
              walletSelector(walletTo, (wallet) {
                setState(() {
                  walletTo = wallet;
                });
              }),
            ],
          ),
          SizedBox(height: 3),
          Tappable(
            color: Colors.transparent,
            borderRadius: 15,
            onTap: Provider.of<AllWallets>(context).allContainSameCurrency()
                ? null
                : () async {
                    // Always ensure that the current widget.wallet appears in the list!

                    Set<String> uniqueCurrencies = {
                      widget.wallet?.currency ?? ""
                    };
                    List<TransactionWallet> duplicateCurrencyWallets = [];

                    for (TransactionWallet wallet
                        in Provider.of<AllWallets>(context, listen: false)
                            .list) {
                      if (!uniqueCurrencies.add(wallet.currency ?? "")) {
                        duplicateCurrencyWallets.add(wallet);
                      }
                    }

                    duplicateCurrencyWallets.removeWhere(
                        (w) => w.walletPk == widget.wallet?.walletPk);

                    dynamic result = await selectWalletPopup(
                      context,
                      removeWalletPks: duplicateCurrencyWallets
                          .map((wallet) => wallet.walletPk)
                          .toList(),
                      title: "select-currency".tr(),
                      selectedWallet: walletForCurrency,
                      allowEditWallet: false,
                      currencyOnly: true,
                    );
                    if (result is TransactionWallet)
                      setState(() {
                        walletForCurrency = result;
                      });
                  },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 11),
              child: AnimatedSizeSwitcher(
                clipBehavior: Clip.none,
                child: TextFont(
                  key: ValueKey(enteredAmount.toString() +
                      (walletForCurrency?.currency ?? "")),
                  autoSizeText: true,
                  maxLines: 1,
                  minFontSize: 16,
                  text: convertToMoney(
                    Provider.of<AllWallets>(context),
                    enteredAmount
                        .abs(), //We flip the arrow instead of showing negative
                    addCurrencyName: true,
                    currencyKey: walletForCurrency?.currency ?? null,
                  ),
                  textAlign: TextAlign.center,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 3),
          SelectAmount(
            // extraWidgetAboveNumbers: SettingsContainerSwitch(
            //   title: "withdraw-amount".tr(),
            //   onSwitched: (value) {
            //     setState(() {
            //       isNegative = value;
            //       if (isNegative == true)
            //         enteredAmount = enteredAmount.abs() * -1;
            //       else
            //         enteredAmount = enteredAmount.abs();
            //     });
            //   },
            //   enableBorderRadius: true,
            //   initialValue: false,
            //   syncWithInitialValue: false,
            //   runOnSwitchedInitially: true,
            // ),
            hideNextButton: true,
            showEnteredNumber: false,
            amountPassed: enteredAmount.toString(),
            setSelectedAmount: (amount, calculation) {
              setState(() {
                if (isNegative == true)
                  enteredAmount = amount.abs() * -1;
                else
                  enteredAmount = amount.abs();
              });
            },
            allowZero: true,
          ),
          Row(
            children: [
              // Padding(
              //   padding: const EdgeInsets.only(right: 5),
              //   child: Button(
              //     label: transferFee == 0
              //         ? "transfer-fee".tr()
              //         : convertToMoney(
              //             Provider.of<AllWallets>(context),
              //             transferFee.abs(),
              //             addCurrencyName: true,
              //           ),
              //     onTap: () async {
              //       await openBottomSheet(
              //         context,
              //         fullSnap: true,
              //         PopupFramework(
              //           title: "transfer-fee".tr(),
              //           subtitle: "deducted-from".tr().capitalizeFirst +
              //               " " +
              //               walletFrom.name,
              //           hasPadding: false,
              //           underTitleSpace: false,
              //           child: SelectAmount(
              //             padding: EdgeInsets.symmetric(horizontal: 18),
              //             onlyShowCurrencyIcon: true,
              //             allowZero: true,
              //             allDecimals: true,
              //             convertToMoney: true,
              //             setSelectedAmount: (amount, __) {
              //               transferFee = amount;
              //             },
              //             amountPassed: transferFee.toString(),
              //             next: () {
              //               Navigator.pop(context);
              //             },
              //             nextLabel: "set-amount".tr(),
              //             currencyKey: null,
              //             enableWalletPicker: false,
              //           ),
              //         ),
              //       );
              //       setState(() {});
              //     },
              //     color: Theme.of(context).colorScheme.tertiaryContainer,
              //     textColor: Theme.of(context).colorScheme.onTertiaryContainer,
              //   ),
              // ),
              Expanded(
                child: Button(
                  expandedLayout: true,
                  label: walletTo == null
                      ? "select-account".tr()
                      : "transfer-amount".tr(),
                  onTap: () async {
                    AllWallets allWallets =
                        Provider.of<AllWallets>(context, listen: false);

                    // Convert the entered amount to the primary currency, then create transactions
                    if (walletForCurrency != null) {
                      enteredAmount = enteredAmount *
                          amountRatioToPrimaryCurrencyGivenPk(
                              allWallets, walletForCurrency!.walletPk);
                    }

                    TransactionWallet walletFrom = this.walletFrom ??
                        Provider.of<AllWallets>(context, listen: false)
                            .indexedByPk[appStateSettings["selectedWalletPk"]]!;
                    if (walletTo == null) {
                      dynamic result = await selectWalletPopup(
                        context,
                        selectedWallet: walletTo,
                        allowEditWallet: widget.allowEditWallet,
                      );
                      if (result is TransactionWallet) {
                        setState(() {
                          walletTo = result;
                        });
                      }
                      return;
                    }

                    if (walletFrom.walletPk == walletTo?.walletPk) {
                      openSnackbar(
                        SnackbarMessage(
                          icon: appStateSettings["outlinedIcons"]
                              ? Icons.warning_outlined
                              : Icons.warning_rounded,
                          title: "same-accounts".tr(),
                          description: "select-2-different-accounts".tr(),
                        ),
                      );
                      return;
                    }

                    String transferString = walletFrom.name +
                        (isNegative ? " ← " : " → ") +
                        walletTo!.name;

                    String note =
                        "transferred-balance".tr() + "\n" + transferString;

                    // Want these times to be the same so we know the pairing of balance corrections
                    DateTime selectedDateTimeSetToNow =
                        selectedDateTime ?? DateTime.now();

                    String? transactionPk = await createCorrectionTransaction(
                      enteredAmount *
                          getAmountRatioWalletTransferTo(
                              allWallets, walletTo!.walletPk),
                      walletTo!,
                      note: note,
                      dateTime:
                          selectedDateTimeSetToNow.add(Duration(seconds: 1)),
                      title: selectedTitle == ""
                          ? (allWallets.indexedByPk[walletTo!.walletPk]!.name +
                              " " +
                              (isNegative
                                  ? "transfer-out".tr()
                                  : "transfer-in".tr()))
                          : selectedTitle,
                    );

                    await createCorrectionTransaction(
                      objectiveLoanPk: widget.initialObjectiveLoanPk,
                      pairedTransactionFk: transactionPk,
                      enteredAmount *
                          getAmountRatioWalletTransferFrom(
                              allWallets, walletFrom.walletPk),
                      walletFrom,
                      note: note,
                      dateTime: selectedDateTimeSetToNow,
                      title: selectedTitle == ""
                          ? (allWallets.indexedByPk[walletFrom.walletPk]!.name +
                              " " +
                              (isNegative == false
                                  ? "transfer-out".tr()
                                  : "transfer-in".tr()))
                          : selectedTitle,
                    );
                    // Deal with transfer fee
                    // if (transferFee != 0) {
                    //   String transferFeeNote = "transfer-fee".tr() +
                    //       "\n" +
                    //       "from".tr().capitalizeFirst +
                    //       " " +
                    //       walletFrom.name;
                    //   await createCorrectionTransaction(
                    //     (transferFee *
                    //                 getAmountRatioWalletTransferFrom(
                    //                     allWallets, walletFrom.walletPk))
                    //             .abs() *
                    //         -1,
                    //     walletFrom,
                    //     note: transferFeeNote,
                    //     // Subtract 2 seconds so it's not in close proximity to the other paired balance correction
                    //     // This is because getCloselyRelatedBalanceCorrectionTransaction relies on the time...
                    //     dateTime: selectedDateTimeSetToNow
                    //         .subtract(Duration(seconds: 2)),
                    //     title: selectedTitle == ""
                    //         ? "transfer-fee".tr()
                    //         : selectedTitle,
                    //   );
                    // }

                    openSnackbar(
                      SnackbarMessage(
                        title: "transferred-balance".tr(),
                        description: transferString,
                        icon: appStateSettings["outlinedIcons"]
                            ? Icons.compare_arrows_outlined
                            : Icons.compare_arrows_rounded,
                      ),
                    );

                    Navigator.pop(context, true);
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
