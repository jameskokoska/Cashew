import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/globalSnackBar.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:budget/colors.dart';

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
  }) : super(key: key);
  final Function(double, String) setSelectedAmount;
  final String amountPassed;
  final VoidCallback? next;
  final bool popWithAmount;
  final String? nextLabel;
  final String? currencyKey;
  final int? walletPkForCurrency;
  final bool onlyShowCurrencyIcon;
  final bool allowZero;

  @override
  _SelectAmountState createState() => _SelectAmountState();
}

class _SelectAmountState extends State<SelectAmount> {
  String amount = "";

  FocusNode _focusNode = FocusNode();
  late FocusAttachment _focusAttachment;

  @override
  void initState() {
    super.initState();
    amount = widget.amountPassed;
    if (amount.endsWith(".0")) {
      amount = widget.amountPassed.replaceAll(".0", "");
    }
    _focusAttachment = _focusNode.attach(context, onKeyEvent: (node, event) {
      if (event.logicalKey.keyLabel == "Go Back" ||
          event.logicalKey == LogicalKeyboardKey.escape) {
        Navigator.pop(context);
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.digit0) {
        addToAmount("0");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.digit1) {
        addToAmount("1");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.digit2) {
        addToAmount("2");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.digit3) {
        addToAmount("3");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.digit4) {
        addToAmount("4");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.digit5) {
        addToAmount("5");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.digit6) {
        addToAmount("6");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.digit7) {
        addToAmount("7");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.digit8) {
        addToAmount("8");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.digit9) {
        addToAmount("9");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.numpad0) {
        addToAmount("0");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.numpad1) {
        addToAmount("1");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.numpad2) {
        addToAmount("2");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.numpad3) {
        addToAmount("3");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.numpad4) {
        addToAmount("4");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.numpad5) {
        addToAmount("5");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.numpad6) {
        addToAmount("6");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.numpad7) {
        addToAmount("7");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.numpad8) {
        addToAmount("8");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.numpad9) {
        addToAmount("9");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.asterisk) {
        addToAmount("×");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.numpadMultiply) {
        addToAmount("×");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.slash) {
        addToAmount("÷");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.numpadDivide) {
        addToAmount("÷");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.add) {
        addToAmount("+");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.numpadAdd) {
        addToAmount("+");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.minus) {
        addToAmount("-");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.numpadSubtract) {
        addToAmount("-");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.period) {
        addToAmount(".");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.numpadDecimal) {
        addToAmount(".");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.backspace) {
        removeToAmount();
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.delete) {
        removeToAmount();
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.enter) {
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

  double calculateResult(input) {
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
    } catch (e) {}
    return result;
  }

  @override
  Widget build(BuildContext context) {
    _focusAttachment.reparent();
    String amountConverted = amount == ""
        ? "0"
        : includesOperations(amount, false)
            ? convertToMoney(calculateResult(amount), showCurrency: false)
            : convertToMoney(
                    double.tryParse(amount.substring(amount.length - 1) ==
                                    "." ||
                                (amount.length > 2 &&
                                    amount.substring(amount.length - 2) == ".0")
                            ? amount.substring(0, amount.length - 1)
                            : amount) ??
                        0,
                    showCurrency: false) +
                (amount.substring(amount.length - 1) == "." ? "." : "") +
                (amount.length > 2 &&
                        amount.substring(amount.length - 2) == ".0"
                    ? ".0"
                    : "");
    return Column(
      children: [
        Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.end,
                children: [
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 400),
                    child: FractionallySizedBox(
                      key: ValueKey(amount),
                      widthFactor: 0.5,
                      child: Padding(
                        padding:
                            const EdgeInsets.only(bottom: 3.0, left: 8, top: 5),
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
                      key: ValueKey(amountConverted),
                      widthFactor: 0.5,
                      child: Tappable(
                        onLongPress: () async {
                          HapticFeedback.mediumImpact();
                          await Clipboard.setData(
                              ClipboardData(text: amountConverted));
                          openSnackbar(
                            SnackbarMessage(
                              title: "Copied to clipboard",
                              icon: Icons.copy_rounded,
                              timeout: Duration(milliseconds: 2500),
                            ),
                          );
                        },
                        color: Colors.transparent,
                        borderRadius: 10,
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.only(
                            right: 8.0,
                            bottom: 5,
                            left: 5,
                            top: 5,
                          ),
                          child: TextFont(
                            autoSizeText: true,
                            maxLines: 1,
                            minFontSize: 16,
                            walletPkForCurrency: widget.walletPkForCurrency ??
                                appStateSettings["selectedWallet"],
                            onlyShowCurrencyIcon: widget.onlyShowCurrencyIcon,
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
                ],
              ),
              SizedBox(height: 5),
              Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          CalculatorButton(
                            label: "1",
                            editAmount: () {
                              addToAmount("1");
                            },
                            topLeft: true,
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
                          CalculatorButton(
                            label: "÷",
                            editAmount: () {
                              addToAmount("÷");
                            },
                            topRight: true,
                          ),
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
                            label: ".",
                            editAmount: () {
                              addToAmount(".");
                            },
                            bottomLeft: true,
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
                          CalculatorButton(
                            label: "+",
                            editAmount: () {
                              addToAmount("+");
                            },
                            bottomRight: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 15),
              AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                child: widget.allowZero || amount != ""
                    ? Button(
                        key: Key("addSuccess"),
                        label: widget.nextLabel ?? "",
                        width: MediaQuery.of(context).size.width,
                        height: 50,
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
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        onTap: () {},
                        color: Colors.grey,
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
    this.topRight = false,
    this.topLeft = false,
    this.bottomLeft = false,
    this.bottomRight = false,
    this.onLongPress = null,
  }) : super(key: key);
  final String label;
  final VoidCallback editAmount;
  final bool topRight;
  final bool topLeft;
  final bool bottomLeft;
  final bool bottomRight;
  final VoidCallback? onLongPress;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: appStateSettings["materialYou"]
            ? Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.9)
            : Theme.of(context).colorScheme.lightDarkAccentHeavy,
        borderRadius: BorderRadius.only(
          topRight: topRight ? Radius.circular(15) : Radius.circular(0),
          topLeft: topLeft ? Radius.circular(15) : Radius.circular(0),
          bottomLeft: bottomLeft ? Radius.circular(15) : Radius.circular(0),
          bottomRight: bottomRight ? Radius.circular(15) : Radius.circular(0),
        ),
        child: InkWell(
          borderRadius: BorderRadius.only(
            topRight: topRight ? Radius.circular(15) : Radius.circular(0),
            topLeft: topLeft ? Radius.circular(15) : Radius.circular(0),
            bottomLeft: bottomLeft ? Radius.circular(15) : Radius.circular(0),
            bottomRight: bottomRight ? Radius.circular(15) : Radius.circular(0),
          ),
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
                    : Icon(Icons.backspace_rounded)),
          ),
        ),
      ),
    );
  }
}

class SelectAmountValue extends StatefulWidget {
  SelectAmountValue(
      {Key? key,
      required this.setSelectedAmount,
      this.amountPassed = "", //the string of calculations
      this.next,
      this.nextLabel})
      : super(key: key);
  final Function(double, String) setSelectedAmount;
  final String amountPassed;
  final VoidCallback? next;
  final String? nextLabel;

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
      if (event.logicalKey.keyLabel == "Go Back" ||
          event.logicalKey == LogicalKeyboardKey.escape) {
        Navigator.pop(context);
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.digit0) {
        addToAmount("0");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.digit1) {
        addToAmount("1");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.digit2) {
        addToAmount("2");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.digit3) {
        addToAmount("3");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.digit4) {
        addToAmount("4");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.digit5) {
        addToAmount("5");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.digit6) {
        addToAmount("6");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.digit7) {
        addToAmount("7");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.digit8) {
        addToAmount("8");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.digit9) {
        addToAmount("9");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.numpad0) {
        addToAmount("0");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.numpad1) {
        addToAmount("1");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.numpad2) {
        addToAmount("2");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.numpad3) {
        addToAmount("3");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.numpad4) {
        addToAmount("4");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.numpad5) {
        addToAmount("5");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.numpad6) {
        addToAmount("6");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.numpad7) {
        addToAmount("7");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.numpad8) {
        addToAmount("8");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.numpad9) {
        addToAmount("9");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.period) {
        addToAmount(".");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.numpadDecimal) {
        addToAmount(".");
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.backspace) {
        removeToAmount();
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.delete) {
        removeToAmount();
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.enter) {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 200),
            child: TextFont(
              autoSizeText: true,
              maxLines: 1,
              minFontSize: 16,
              text: amount,
              // text: amount,
              textAlign: TextAlign.right,
              fontSize: 35,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(height: 10),
        Row(
          children: [
            CalculatorButton(
              label: "1",
              editAmount: () {
                addToAmount("1");
              },
              topLeft: true,
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
              },
              topRight: true,
            ),
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
              label: ".",
              editAmount: () {
                addToAmount(".");
              },
              bottomLeft: true,
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
              onLongPress: () {
                removeAll();
              },
              bottomRight: true,
            ),
          ],
        ),
        Container(height: 15),
        AnimatedSwitcher(
          duration: Duration(milliseconds: 500),
          child: amount != ""
              ? Button(
                  key: Key("addSuccess"),
                  label: widget.nextLabel ?? "",
                  width: MediaQuery.of(context).size.width,
                  height: 50,
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
                  height: 50,
                  onTap: () {},
                  color: Colors.grey,
                ),
        )
      ],
    );
  }
}
