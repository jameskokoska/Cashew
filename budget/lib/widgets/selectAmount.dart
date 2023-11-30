import 'dart:io';
import 'dart:math';

import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/pages/addWalletPage.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/globalSnackBar.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/selectChips.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/util/contextMenu.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/number_symbols_data.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:budget/colors.dart';
import 'package:provider/provider.dart';
import 'package:budget/struct/currencyFunctions.dart';
import 'package:universal_io/io.dart';

String getDecimalSeparator() {
  return numberFormatSymbols[Platform.localeName.split("-")[0]]?.DECIMAL_SEP ??
      ".";
}

class SelectAmount extends StatefulWidget {
  SelectAmount({
    Key? key,
    required this.setSelectedAmount,
    this.amountPassed = "", //the string of calculations
    this.next,
    this.popWithAmount = false,
    this.nextLabel,
    this.currencyKey,
    this.walletPkForCurrency,
    this.onlyShowCurrencyIcon = false,
    this.allowZero = false,
    this.padding = EdgeInsets.zero,
    this.enableWalletPicker = false,
    this.setSelectedWalletPk,
    this.selectedWalletPk,
    this.extraWidgetAboveNumbers,
    this.showEnteredNumber = true,
    this.convertToMoney = true,
    this.allDecimals = false,
    this.hideWalletPickerIfOneCurrency = false,
  }) : super(key: key);
  final Function(double, String) setSelectedAmount;
  final String amountPassed;
  final VoidCallback? next;
  final bool popWithAmount;
  final String? nextLabel;
  final String? currencyKey;
  final String? walletPkForCurrency;
  final bool onlyShowCurrencyIcon;
  final bool allowZero;
  final EdgeInsets padding;
  final bool enableWalletPicker;
  final Function(String)? setSelectedWalletPk;
  final String? selectedWalletPk;
  final Widget? extraWidgetAboveNumbers;
  final bool showEnteredNumber;
  final bool convertToMoney;
  final bool allDecimals;
  final bool hideWalletPickerIfOneCurrency;

  @override
  _SelectAmountState createState() => _SelectAmountState();
}

class _SelectAmountState extends State<SelectAmount> {
  String amount = "";

  FocusNode _focusNode = FocusNode();
  late FocusAttachment _focusAttachment;
  late String? walletPkForCurrency;
  late String? selectedWalletPk = widget.selectedWalletPk;

  TransactionWallet? getSelectedWallet({required bool listen}) {
    return Provider.of<AllWallets>(context, listen: listen)
        .indexedByPk[selectedWalletPk];
  }

  int getDecimals({required bool listen}) {
    return getSelectedWallet(listen: listen)?.decimals ??
        Provider.of<AllWallets>(context, listen: false)
            .indexedByPk[appStateSettings["selectedWalletPk"]]
            ?.decimals ??
        2;
  }

  bool isControlPressed = false;

  @override
  void initState() {
    // print(widget.allWallets);
    super.initState();
    walletPkForCurrency = widget.walletPkForCurrency;
    try {
      amount = widget.allDecimals
          ? double.parse(widget.amountPassed).toString()
          : double.parse(widget.amountPassed)
              .toStringAsFixed(getDecimals(listen: false));
    } catch (e) {
      print(e.toString());
    }
    amount = removeTrailingZeroes(amount);
    if (amount == "0") {
      amount = "";
    }
    // if (amount.endsWith(".0")) {
    //   amount = widget.amountPassed.replaceAll(".0", "");
    // }
    _focusAttachment = _focusNode.attach(context, onKeyEvent: (node, event) {
      bool keyIsPressed = event.runtimeType == KeyDownEvent ||
          event.runtimeType == KeyRepeatEvent;
      if (event.logicalKey.keyLabel.toLowerCase().contains("control")) {
        if (keyIsPressed) {
          isControlPressed = true;
        } else {
          isControlPressed = false;
        }
      }
      if (keyIsPressed && event.logicalKey.keyLabel == "Go Back" ||
          event.logicalKey == LogicalKeyboardKey.escape) {
        Navigator.pop(context);
      } else if (isControlPressed &&
          keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.keyC) {
        copyToClipboard(amount);
      } else if (isControlPressed &&
          keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.keyV) {
        pasteFromClipboard();
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.digit0) {
        addToAmount("0");
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.digit1) {
        addToAmount("1");
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.digit2) {
        addToAmount("2");
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.digit3) {
        addToAmount("3");
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.digit4) {
        addToAmount("4");
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.digit5) {
        addToAmount("5");
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.digit6) {
        addToAmount("6");
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.digit7) {
        addToAmount("7");
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.digit8) {
        addToAmount("8");
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.digit9) {
        addToAmount("9");
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.numpad0) {
        addToAmount("0");
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.numpad1) {
        addToAmount("1");
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.numpad2) {
        addToAmount("2");
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.numpad3) {
        addToAmount("3");
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.numpad4) {
        addToAmount("4");
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.numpad5) {
        addToAmount("5");
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.numpad6) {
        addToAmount("6");
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.numpad7) {
        addToAmount("7");
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.numpad8) {
        addToAmount("8");
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.numpad9) {
        addToAmount("9");
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.asterisk) {
        addToAmount("×");
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.numpadMultiply) {
        addToAmount("×");
      } else if (keyIsPressed && event.logicalKey == LogicalKeyboardKey.slash) {
        addToAmount("÷");
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.numpadDivide) {
        addToAmount("÷");
      } else if (keyIsPressed && event.logicalKey == LogicalKeyboardKey.add) {
        addToAmount("+");
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.numpadAdd) {
        addToAmount("+");
      } else if (keyIsPressed && event.logicalKey == LogicalKeyboardKey.minus) {
        addToAmount("-");
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.numpadSubtract) {
        addToAmount("-");
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.period) {
        addToAmount(".");
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.numpadDecimal) {
        addToAmount(".");
      } else if (keyIsPressed && event.logicalKey == LogicalKeyboardKey.comma) {
        addToAmount(".");
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.backspace) {
        removeToAmount();
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.delete) {
        removeToAmount();
      } else if (keyIsPressed && event.logicalKey == LogicalKeyboardKey.enter) {
        if (widget.next != null) {
          widget.next!();
        }
        if (widget.popWithAmount) {
          Navigator.pop(
              context,
              (amount == ""
                  ? 0
                  : includesOperations(amount, false)
                      ? calculateResult(amount)
                      : double.tryParse(amount) ?? 0));
        }
      }
      return KeyEventResult.handled;
    });
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  addToAmount(String input) {
    // bottomSheetControllerGlobal.snapToExtent(0);
    String amountClone = amount;
    if (input == "." &&
        !decimalCheck(operationsWithSpaces(amountClone + "."))) {
    } else if (amount.length == 0 && !includesOperations(input, false)) {
      if (input == "0") {
      } else if (input == ".") {
        setState(() {
          amount += "0" + input;
        });
      } else {
        setState(() {
          amount += input;
        });
      }
    } else if (amount.length != 0 &&
            (!includesOperations(amount.substring(amount.length - 1), true) &&
                includesOperations(input, true)) ||
        !includesOperations(input, true)) {
      setState(() {
        amount += input;
      });
    } else if (amount.length != 0 &&
        includesOperations(amount.substring(amount.length - 1), false) &&
        input == ".") {
      setState(() {
        amount += "0" + input;
      });
    } else if (amount.length != 0 &&
        amount.substring(amount.length - 1) == "." &&
        includesOperations(input, false)) {
      setState(() {
        amount = amount.substring(0, amount.length - 1) + input;
      });
    } else if (amount.length != 0 &&
        includesOperations(amount.substring(amount.length - 1), false) &&
        includesOperations(input, false)) {
      //replace last input operation with a new one
      setState(() {
        amount = amount.substring(0, amount.length - 1) + input;
      });
    }
    widget.setSelectedAmount(
        (amount == ""
            ? 0
            : includesOperations(amount, false)
                ? calculateResult(amount)
                : double.tryParse(amount) ?? 0),
        amount);
  }

  void removeToAmount() {
    // bottomSheetControllerGlobal.snapToExtent(0);
    setState(() {
      if (amount.length > 0) {
        amount = amount.substring(0, amount.length - 1);
      }
    });
    widget.setSelectedAmount(
        (amount == ""
            ? 0
            : includesOperations(amount, false)
                ? calculateResult(amount)
                : double.tryParse(amount) ?? 0),
        amount);
  }

  void removeAll() {
    setState(() {
      amount = "";
    });
    widget.setSelectedAmount(
        (amount == ""
            ? 0
            : includesOperations(amount, false)
                ? calculateResult(amount)
                : double.tryParse(amount) ?? 0),
        amount);
    Future.delayed(Duration(milliseconds: 100), () {
      bottomSheetControllerGlobal.snapToExtent(0);
    });
  }

  bool includesOperations(String input, bool includeDecimal) {
    List<String> operations = [
      "÷",
      "×",
      "-",
      "+",
      (includeDecimal ? "." : "+")
    ];
    for (String operation in operations) {
      if (input.contains(operation)) {
        // print(operation);
        return true;
      }
    }
    return false;
  }

  bool decimalCheck(input) {
    var splitInputs = input.split(" ");
    for (var splitInput in splitInputs) {
      // print('.'.allMatches(splitInput));
      if ('.'.allMatches(splitInput).length > 1) {
        return false;
      }
    }
    return true;
  }

  String operationsWithSpaces(String input) {
    return input
        .replaceAll("÷", " ÷ ")
        .replaceAll("×", " × ")
        .replaceAll("-", " - ")
        .replaceAll("+", " + ");
  }

  double calculateResult(String input) {
    if (input == "") {
      return 0;
    }
    String changedInput = input;
    if (includesOperations(input.substring(input.length - 1), true)) {
      changedInput = input.substring(0, input.length - 1);
    }
    changedInput = changedInput.replaceAll("÷", "/");
    changedInput = changedInput.replaceAll("×", "*");
    double result = 0;
    try {
      ContextModel cm = ContextModel();
      Parser p = new Parser();
      Expression exp = p.parse(changedInput);
      result = exp.evaluate(EvaluationType.REAL, cm);
    } catch (e) {
      print("Error calculating result");
    }
    return result;
  }

  bool canChange() {
    if (includesOperations(amount, false)) {
      return true;
    } else if (amount.contains(".") &&
        amount.split(".")[1].length >= getDecimals(listen: false)) {
      return false;
    }
    return true;
  }

  pasteFromClipboard() async {
    String? clipboardText = await readClipboard(showSnackbar: false);
    double? amount = getAmountFromString(clipboardText ?? "");
    if (amount != null) {
      setState(() {
        this.amount = amount.toString();
      });
      widget.setSelectedAmount(amount, amount.toString());
      openSnackbar(
        SnackbarMessage(
          title: "pasted-from-clipboard".tr(),
          icon: appStateSettings["outlinedIcons"]
              ? Icons.paste_outlined
              : Icons.paste_rounded,
          timeout: Duration(milliseconds: 2500),
        ),
      );
    }
  }

  bool doesNotContainOtherNumbers(String input) {
    return !RegExp(r'[1-9]').hasMatch(input);
  }

  bool startsWithTwoZeroes(String input) {
    return RegExp(r'^00').hasMatch(input);
  }

  @override
  Widget build(BuildContext context) {
    _focusAttachment.reparent();
    String amountConverted = amount;
    if (amountConverted == "") amountConverted = "0";
    amountConverted = widget.convertToMoney == false
        ? calculateResult(amountConverted).toString()
        : convertToMoney(
            Provider.of<AllWallets>(context),
            calculateResult(amountConverted),
            currencyKey: getSelectedWallet(listen: false)?.currency,
            allDecimals: true,
            forceAllDecimals: doesNotContainOtherNumbers(amount) &&
                startsWithTwoZeroes(amount) == false &&
                (getSelectedWallet(listen: false)?.decimals ?? 0) > 2,
            decimals: getSelectedWallet(listen: false)?.decimals == 2 &&
                    includesOperations(amount, true)
                ? 2
                : min(
                    getSelectedWallet(listen: false)?.decimals ?? 1000,
                    includesOperations(amount, false)
                        ? countDecimalDigits(
                            calculateResult(amountConverted).toString())
                        : countDecimalDigits(amount),
                  ),
          );
    amountConverted = amountConverted.replaceAll(".", getDecimalSeparator());
    return Column(
      children: [
        Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.showEnteredNumber == true)
                Padding(
                  padding: widget.padding,
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.end,
                    children: [
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 400),
                        child: FractionallySizedBox(
                          key: ValueKey(amount),
                          widthFactor: 0.5,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                bottom: 3.0, left: 8, top: 5),
                            child: TextFont(
                              text: (includesOperations(amount, false)
                                  ? operationsWithSpaces(amount)
                                  : ""),
                              textAlign: TextAlign.left,
                              fontSize: 18,
                              maxLines: 5,
                            ),
                          ),
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 200),
                        child: FractionallySizedBox(
                          key: ValueKey(amount),
                          widthFactor: 0.5,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Flexible(
                                child: CustomContextMenu(
                                  buttonItems: [
                                    ContextMenuButtonItem(
                                      type: ContextMenuButtonType.copy,
                                      onPressed: () {
                                        ContextMenuController.removeAny();
                                        copyToClipboard(amountConverted);
                                      },
                                    ),
                                    ContextMenuButtonItem(
                                      type: ContextMenuButtonType.paste,
                                      onPressed: () {
                                        ContextMenuController.removeAny();
                                        pasteFromClipboard();
                                      },
                                    ),
                                  ],
                                  tappableBuilder: (onLongPress) => Tappable(
                                    color: Colors.transparent,
                                    borderRadius: 10,
                                    onTap: () {
                                      return;
                                    },
                                    onLongPress: onLongPress,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        right: 8.0,
                                        bottom: 5,
                                        left: 5,
                                        top: 5,
                                      ),
                                      child: AnimatedSizeSwitcher(
                                        child: TextFont(
                                          key: ValueKey(selectedWalletPk),
                                          autoSizeText: true,
                                          maxLines: 1,
                                          minFontSize: 16,
                                          text: amountConverted,
                                          // text: amount,
                                          textAlign: TextAlign.right,
                                          fontSize: 35,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              widget.enableWalletPicker == false ||
                                      Provider.of<AllWallets>(context)
                                              .list
                                              .length <=
                                          1 ||
                                      (widget.hideWalletPickerIfOneCurrency &&
                                          Provider.of<AllWallets>(context)
                                              .allContainSameCurrency())
                                  ? SizedBox.shrink()
                                  : MediaQuery(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 3.0),
                                        child: AnimatedExpanded(
                                          axis: Axis.horizontal,
                                          expand: (getSelectedWallet(
                                                              listen: true)
                                                          ?.walletPk ==
                                                      appStateSettings[
                                                          "selectedWalletPk"] ||
                                                  ((Provider.of<AllWallets>(
                                                              context)
                                                          .indexedByPk[
                                                              getSelectedWallet(
                                                                      listen:
                                                                          true)
                                                                  ?.walletPk]
                                                          ?.currency) ==
                                                      Provider.of<AllWallets>(
                                                              context)
                                                          .indexedByPk[
                                                              appStateSettings[
                                                                  "selectedWalletPk"]]
                                                          ?.currency)) ==
                                              false,
                                          child: Tappable(
                                            key: ValueKey(
                                                getSelectedWallet(listen: true)
                                                    ?.walletPk),
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondaryContainer,
                                            borderRadius: 13,
                                            onTap: () {
                                              TransactionWallet? walletBefore =
                                                  getSelectedWallet(
                                                      listen: false);
                                              // get the index of the primary wallet
                                              int index = 0;
                                              for (TransactionWallet wallet
                                                  in Provider.of<AllWallets>(
                                                          context,
                                                          listen: false)
                                                      .list) {
                                                if (wallet.walletPk ==
                                                    appStateSettings[
                                                        "selectedWalletPk"]) {
                                                  break;
                                                }
                                                index++;
                                              }

                                              if (widget.setSelectedWalletPk !=
                                                  null)
                                                widget.setSelectedWalletPk!(
                                                    Provider.of<AllWallets>(
                                                            context,
                                                            listen: false)
                                                        .list[index]
                                                        .walletPk);
                                              setState(() {
                                                selectedWalletPk =
                                                    Provider.of<AllWallets>(
                                                            context,
                                                            listen: false)
                                                        .list[index]
                                                        .walletPk;
                                                walletPkForCurrency =
                                                    Provider.of<AllWallets>(
                                                            context,
                                                            listen: false)
                                                        .list[index]
                                                        .walletPk;
                                                try {
                                                  amount = (double.parse(
                                                              amount) *
                                                          (walletBefore == null
                                                              ? 1
                                                              : (amountRatioToPrimaryCurrencyGivenPk(
                                                                  Provider.of<
                                                                          AllWallets>(
                                                                      context,
                                                                      listen:
                                                                          false),
                                                                  walletBefore
                                                                      .walletPk))))
                                                      .toStringAsFixed(
                                                          getDecimals(
                                                              listen: false));
                                                } catch (e) {}
                                                amount = removeTrailingZeroes(
                                                    amount);
                                                addToAmount("");
                                              });
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 7),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .currency_exchange_rounded,
                                                    size: 16,
                                                  ),
                                                  SizedBox(height: 2),
                                                  TextFont(
                                                    text: Provider.of<
                                                                    AllWallets>(
                                                                context)
                                                            .indexedByPk[
                                                                appStateSettings[
                                                                    "selectedWalletPk"]]
                                                            ?.currency
                                                            .toString()
                                                            .toUpperCase() ??
                                                        "",
                                                    fontSize: 11,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      data: MediaQuery.of(context)
                                          .copyWith(textScaleFactor: 1.0),
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              widget.enableWalletPicker == false ||
                      Provider.of<AllWallets>(context).list.length <= 1 ||
                      (widget.hideWalletPickerIfOneCurrency &&
                          Provider.of<AllWallets>(context)
                              .allContainSameCurrency())
                  ? SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: SelectChips(
                        allowMultipleSelected: false,
                        items: Provider.of<AllWallets>(context).list,
                        onLongPress: (TransactionWallet? item) {
                          pushRoute(
                            context,
                            AddWalletPage(
                              wallet: item,
                              routesToPopAfterDelete:
                                  RoutesToPopAfterDelete.PreventDelete,
                            ),
                          );
                        },
                        getSelected: (TransactionWallet wallet) {
                          return getSelectedWallet(listen: false)?.walletPk ==
                              wallet.walletPk;
                        },
                        onSelected: (TransactionWallet wallet) {
                          if (widget.setSelectedWalletPk != null)
                            widget.setSelectedWalletPk!(wallet.walletPk);
                          setState(() {
                            selectedWalletPk = wallet.walletPk;
                            walletPkForCurrency = wallet.walletPk;
                            try {
                              amount = double.parse(amount)
                                  .toStringAsFixed(getDecimals(listen: false));
                            } catch (e) {}
                            amount = removeTrailingZeroes(amount);
                            addToAmount("");
                          });
                        },
                        getLabel: (TransactionWallet wallet) {
                          return wallet.name ==
                                  wallet.currency.toString().toUpperCase()
                              ? wallet.currency.toString().toUpperCase()
                              : wallet.name +
                                  " (" +
                                  wallet.currency.toString().toUpperCase() +
                                  ")";
                        },
                        getCustomBorderColor: (TransactionWallet item) {
                          return dynamicPastel(
                            context,
                            lightenPastel(
                              HexColor(
                                item.colour,
                                defaultColor:
                                    Theme.of(context).colorScheme.primary,
                              ),
                              amount: 0.3,
                            ),
                            amount: 0.4,
                          );
                        },
                        extraWidget: AddButton(
                          onTap: () {},
                          width: 40,
                          padding:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          openPage: AddWalletPage(
                            routesToPopAfterDelete: RoutesToPopAfterDelete.None,
                          ),
                          borderRadius: 8,
                        ),
                      ),
                    ),
              SizedBox(height: 5),
              Padding(
                padding: widget.padding,
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 400),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                          getPlatform() == PlatformOS.isIOS ? 10 : 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (widget.extraWidgetAboveNumbers != null)
                            Container(
                                color: appStateSettings["materialYou"]
                                    ? Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer
                                    : Theme.of(context).brightness ==
                                            Brightness.light
                                        ? getColor(
                                            context, "lightDarkAccentHeavy")
                                        : getColor(context,
                                            "lightDarkAccentHeavyLight"),
                                child: widget.extraWidgetAboveNumbers!),
                          Row(
                            children: [
                              CalculatorButton(
                                disabled: !canChange(),
                                label: "1",
                                editAmount: () {
                                  addToAmount("1");
                                },
                              ),
                              CalculatorButton(
                                  disabled: !canChange(),
                                  label: "2",
                                  editAmount: () {
                                    addToAmount("2");
                                  }),
                              CalculatorButton(
                                  disabled: !canChange(),
                                  label: "3",
                                  editAmount: () {
                                    addToAmount("3");
                                  }),
                              CalculatorButton(
                                label: "÷",
                                editAmount: () {
                                  addToAmount("÷");
                                },
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              CalculatorButton(
                                  disabled: !canChange(),
                                  label: "4",
                                  editAmount: () {
                                    addToAmount("4");
                                  }),
                              CalculatorButton(
                                  disabled: !canChange(),
                                  label: "5",
                                  editAmount: () {
                                    addToAmount("5");
                                  }),
                              CalculatorButton(
                                  disabled: !canChange(),
                                  label: "6",
                                  editAmount: () {
                                    addToAmount("6");
                                  }),
                              CalculatorButton(
                                  label: "×",
                                  editAmount: () {
                                    addToAmount("×");
                                  }),
                            ],
                          ),
                          Row(
                            children: [
                              CalculatorButton(
                                  disabled: !canChange(),
                                  label: "7",
                                  editAmount: () {
                                    addToAmount("7");
                                  }),
                              CalculatorButton(
                                  disabled: !canChange(),
                                  label: "8",
                                  editAmount: () {
                                    addToAmount("8");
                                  }),
                              CalculatorButton(
                                  disabled: !canChange(),
                                  label: "9",
                                  editAmount: () {
                                    addToAmount("9");
                                  }),
                              CalculatorButton(
                                  label: "-",
                                  editAmount: () {
                                    addToAmount("-");
                                  }),
                            ],
                          ),
                          Row(
                            children: [
                              CalculatorButton(
                                disabled: !canChange(),
                                label: getDecimalSeparator(),
                                editAmount: () {
                                  addToAmount(".");
                                },
                              ),
                              CalculatorButton(
                                  disabled: !canChange(),
                                  label: "0",
                                  editAmount: () {
                                    addToAmount("0");
                                  }),
                              CalculatorButton(
                                label: "<",
                                editAmount: () {
                                  removeToAmount();
                                },
                                onLongPress: removeAll,
                              ),
                              CalculatorButton(
                                label: "+",
                                editAmount: () {
                                  addToAmount("+");
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Padding(
                padding: widget.padding,
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 500),
                  child: widget.allowZero || (amount != "" && amount != "0")
                      ? Button(
                          key: Key("addSuccess"),
                          label: widget.nextLabel ?? "",
                          width: MediaQuery.sizeOf(context).width,
                          onTap: () {
                            if (widget.allowZero && amount == "") {
                              widget.setSelectedAmount(0, "");
                            }
                            if (widget.next != null) {
                              widget.next!();
                            }
                            if (widget.popWithAmount) {
                              Navigator.pop(
                                  context,
                                  (amount == ""
                                      ? 0
                                      : includesOperations(amount, false)
                                          ? calculateResult(amount)
                                          : double.tryParse(amount) ?? 0));
                            }
                          },
                        )
                      : Button(
                          key: Key("addNoSuccess"),
                          label: widget.nextLabel ?? "",
                          width: MediaQuery.sizeOf(context).width,
                          onTap: () {},
                          color: Colors.grey,
                        ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class CalculatorButton extends StatelessWidget {
  CalculatorButton({
    Key? key,
    required this.label,
    required this.editAmount,
    this.onLongPress = null,
    this.disabled = false,
  }) : super(key: key);
  final String label;
  final VoidCallback editAmount;
  final VoidCallback? onLongPress;
  final bool disabled;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 200),
        opacity: disabled ? 0.5 : 1,
        child: IgnorePointer(
          ignoring: disabled,
          child: Tappable(
            color: appStateSettings["materialYou"]
                ? Theme.of(context).colorScheme.secondaryContainer
                : Theme.of(context).brightness == Brightness.light
                    ? getColor(context, "lightDarkAccentHeavy")
                    : getColor(context, "lightDarkAccentHeavyLight"),
            onLongPress: onLongPress,
            onTap: editAmount,
            child: Container(
              height: 60,
              child: Center(
                child: label != "<"
                    ? TextFont(
                        fontSize: 24,
                        text: label,
                      )
                    : Icon(appStateSettings["outlinedIcons"]
                        ? Icons.backspace_outlined
                        : Icons.backspace_rounded),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SelectAmountValue extends StatefulWidget {
  SelectAmountValue({
    Key? key,
    required this.setSelectedAmount,
    this.amountPassed = "", //the string of calculations
    this.next,
    this.nextLabel,
    this.allowZero = false,
    this.suffix = "",
    this.showEnteredNumber = true,
    this.extraWidgetAboveNumbers,
  }) : super(key: key);
  final Function(double, String) setSelectedAmount;
  final String amountPassed;
  final VoidCallback? next;
  final String? nextLabel;
  final bool allowZero;
  final String suffix;
  final bool showEnteredNumber;
  final Widget? extraWidgetAboveNumbers;

  @override
  _SelectAmountValueState createState() => _SelectAmountValueState();
}

class _SelectAmountValueState extends State<SelectAmountValue> {
  String amount = "";

  FocusNode _focusNode = FocusNode();
  late FocusAttachment _focusAttachment;

  @override
  void initState() {
    super.initState();
    amount = widget.amountPassed;
    _focusAttachment = _focusNode.attach(context, onKeyEvent: (node, event) {
      bool keyIsPressed = event.runtimeType == KeyDownEvent ||
          event.runtimeType == KeyRepeatEvent;
      if (keyIsPressed && event.logicalKey.keyLabel == "Go Back" ||
          event.logicalKey == LogicalKeyboardKey.escape) {
        Navigator.pop(context);
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.digit0) {
        addToAmount("0");
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.digit1) {
        addToAmount("1");
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.digit2) {
        addToAmount("2");
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.digit3) {
        addToAmount("3");
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.digit4) {
        addToAmount("4");
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.digit5) {
        addToAmount("5");
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.digit6) {
        addToAmount("6");
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.digit7) {
        addToAmount("7");
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.digit8) {
        addToAmount("8");
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.digit9) {
        addToAmount("9");
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.numpad0) {
        addToAmount("0");
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.numpad1) {
        addToAmount("1");
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.numpad2) {
        addToAmount("2");
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.numpad3) {
        addToAmount("3");
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.numpad4) {
        addToAmount("4");
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.numpad5) {
        addToAmount("5");
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.numpad6) {
        addToAmount("6");
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.numpad7) {
        addToAmount("7");
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.numpad8) {
        addToAmount("8");
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.numpad9) {
        addToAmount("9");
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.period) {
        addToAmount(".");
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.numpadDecimal) {
        addToAmount(".");
      } else if (keyIsPressed && event.logicalKey == LogicalKeyboardKey.comma) {
        addToAmount(".");
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.backspace) {
        removeToAmount();
      } else if (keyIsPressed &&
          event.logicalKey == LogicalKeyboardKey.delete) {
        removeToAmount();
      } else if (keyIsPressed && event.logicalKey == LogicalKeyboardKey.enter) {
        if (widget.next != null) {
          widget.next!();
        }
      }
      return KeyEventResult.handled;
    });
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  addToAmount(String input) {
    String amountClone = amount;
    if (input == "." && amount.contains(".")) {
    } else {
      if (amount == "0" || amount == "") {
        if (input == ".") {
          setState(() {
            amount = "0" + input;
          });
        } else {
          setState(() {
            amount = input;
          });
        }
      } else {
        setState(() {
          amount += input;
        });
      }
    }
    widget.setSelectedAmount(double.tryParse(amount) ?? 0, amount);
  }

  void removeToAmount() {
    setState(() {
      if (amount.length > 0) {
        amount = amount.substring(0, amount.length - 1);
      }
    });
    widget.setSelectedAmount(double.tryParse(amount) ?? 0, amount);
  }

  void removeAll() {
    setState(() {
      amount = "";
    });
    widget.setSelectedAmount(double.tryParse(amount) ?? 0, amount);
  }

  @override
  Widget build(BuildContext context) {
    _focusAttachment.reparent();
    String amountConverted = amount.replaceAll(".", getDecimalSeparator());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (widget.showEnteredNumber == true)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 200),
              child: FractionallySizedBox(
                key: ValueKey(amount),
                widthFactor: 1,
                child: TextFont(
                  autoSizeText: true,
                  maxLines: 1,
                  minFontSize: 16,
                  text: amountConverted + widget.suffix,
                  textAlign: TextAlign.right,
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        Container(height: 10),
        Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 400),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                  getPlatform() == PlatformOS.isIOS ? 10 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.extraWidgetAboveNumbers != null)
                    Container(
                        color: appStateSettings["materialYou"]
                            ? Theme.of(context).colorScheme.secondaryContainer
                            : Theme.of(context).brightness == Brightness.light
                                ? getColor(context, "lightDarkAccentHeavy")
                                : getColor(
                                    context, "lightDarkAccentHeavyLight"),
                        child: widget.extraWidgetAboveNumbers!),
                  Row(
                    children: [
                      CalculatorButton(
                        label: "1",
                        editAmount: () {
                          addToAmount("1");
                        },
                      ),
                      CalculatorButton(
                          label: "2",
                          editAmount: () {
                            addToAmount("2");
                          }),
                      CalculatorButton(
                          label: "3",
                          editAmount: () {
                            addToAmount("3");
                          }),
                    ],
                  ),
                  Row(
                    children: [
                      CalculatorButton(
                          label: "4",
                          editAmount: () {
                            addToAmount("4");
                          }),
                      CalculatorButton(
                          label: "5",
                          editAmount: () {
                            addToAmount("5");
                          }),
                      CalculatorButton(
                          label: "6",
                          editAmount: () {
                            addToAmount("6");
                          }),
                    ],
                  ),
                  Row(
                    children: [
                      CalculatorButton(
                          label: "7",
                          editAmount: () {
                            addToAmount("7");
                          }),
                      CalculatorButton(
                          label: "8",
                          editAmount: () {
                            addToAmount("8");
                          }),
                      CalculatorButton(
                          label: "9",
                          editAmount: () {
                            addToAmount("9");
                          }),
                    ],
                  ),
                  Row(
                    children: [
                      CalculatorButton(
                        label: getDecimalSeparator(),
                        editAmount: () {
                          addToAmount(".");
                        },
                      ),
                      CalculatorButton(
                          label: "0",
                          editAmount: () {
                            addToAmount("0");
                          }),
                      CalculatorButton(
                        label: "<",
                        editAmount: () {
                          removeToAmount();
                        },
                        onLongPress: removeAll,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(height: 15),
        AnimatedSwitcher(
          duration: Duration(milliseconds: 500),
          child: amount != "" || widget.allowZero
              ? Button(
                  key: Key("addSuccess"),
                  label: widget.nextLabel ?? "",
                  width: MediaQuery.sizeOf(context).width,
                  onTap: () {
                    if (widget.next != null) {
                      widget.next!();
                    }
                  },
                )
              : Button(
                  key: Key("addNoSuccess"),
                  label: widget.nextLabel ?? "",
                  width: MediaQuery.sizeOf(context).width,
                  onTap: () {},
                  color: Colors.grey,
                ),
        )
      ],
    );
  }
}

String removeTrailingZeroes(String input) {
  if (!input.contains('.')) {
    return input;
  }
  int index = input.length - 1;
  while (input[index] == '0') {
    index--;
  }
  if (input[index] == '.') {
    index--;
  }
  return input.substring(0, index + 1);
}
