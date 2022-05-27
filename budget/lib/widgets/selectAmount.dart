import 'package:budget/functions.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:budget/colors.dart';

class SelectAmount extends StatefulWidget {
  SelectAmount(
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
  _SelectAmountState createState() => _SelectAmountState();
}

class _SelectAmountState extends State<SelectAmount> {
  String amount = "";

  FocusNode _focusNode = FocusNode();
  late FocusAttachment _focusAttachment;

  bool fired = false;
  @override
  void initState() {
    super.initState();
    amount = widget.amountPassed;
    _focusAttachment = _focusNode.attach(context, onKeyEvent: (node, event) {
      if (fired) {
        fired = false;
      } else if (event.logicalKey.keyLabel == "Go Back") {
        fired = true;
        Navigator.pop(context);
      } else if (event.logicalKey == LogicalKeyboardKey.digit0) {
        fired = true;
        addToAmount("0");
      } else if (event.logicalKey == LogicalKeyboardKey.digit1) {
        fired = true;
        addToAmount("1");
      } else if (event.logicalKey == LogicalKeyboardKey.digit2) {
        fired = true;
        addToAmount("2");
      } else if (event.logicalKey == LogicalKeyboardKey.digit3) {
        fired = true;
        addToAmount("3");
      } else if (event.logicalKey == LogicalKeyboardKey.digit4) {
        fired = true;
        addToAmount("4");
      } else if (event.logicalKey == LogicalKeyboardKey.digit5) {
        fired = true;
        addToAmount("5");
      } else if (event.logicalKey == LogicalKeyboardKey.digit6) {
        fired = true;
        addToAmount("6");
      } else if (event.logicalKey == LogicalKeyboardKey.digit7) {
        fired = true;
        addToAmount("7");
      } else if (event.logicalKey == LogicalKeyboardKey.digit8) {
        fired = true;
        addToAmount("8");
      } else if (event.logicalKey == LogicalKeyboardKey.digit9) {
        fired = true;
        addToAmount("9");
      } else if (event.logicalKey == LogicalKeyboardKey.numpad0) {
        fired = true;
        addToAmount("0");
      } else if (event.logicalKey == LogicalKeyboardKey.numpad1) {
        fired = true;
        addToAmount("1");
      } else if (event.logicalKey == LogicalKeyboardKey.numpad2) {
        fired = true;
        addToAmount("2");
      } else if (event.logicalKey == LogicalKeyboardKey.numpad3) {
        fired = true;
        addToAmount("3");
      } else if (event.logicalKey == LogicalKeyboardKey.numpad4) {
        fired = true;
        addToAmount("4");
      } else if (event.logicalKey == LogicalKeyboardKey.numpad5) {
        fired = true;
        addToAmount("5");
      } else if (event.logicalKey == LogicalKeyboardKey.numpad6) {
        fired = true;
        addToAmount("6");
      } else if (event.logicalKey == LogicalKeyboardKey.numpad7) {
        fired = true;
        addToAmount("7");
      } else if (event.logicalKey == LogicalKeyboardKey.numpad8) {
        fired = true;
        addToAmount("8");
      } else if (event.logicalKey == LogicalKeyboardKey.numpad9) {
        fired = true;
        addToAmount("9");
      } else if (event.logicalKey == LogicalKeyboardKey.asterisk) {
        fired = true;
        addToAmount("×");
      } else if (event.logicalKey == LogicalKeyboardKey.numpadMultiply) {
        fired = true;
        addToAmount("×");
      } else if (event.logicalKey == LogicalKeyboardKey.slash) {
        fired = true;
        addToAmount("÷");
      } else if (event.logicalKey == LogicalKeyboardKey.numpadDivide) {
        fired = true;
        addToAmount("÷");
      } else if (event.logicalKey == LogicalKeyboardKey.add) {
        fired = true;
        addToAmount("+");
      } else if (event.logicalKey == LogicalKeyboardKey.numpadAdd) {
        fired = true;
        addToAmount("+");
      } else if (event.logicalKey == LogicalKeyboardKey.minus) {
        fired = true;
        addToAmount("-");
      } else if (event.logicalKey == LogicalKeyboardKey.numpadSubtract) {
        fired = true;
        addToAmount("-");
      } else if (event.logicalKey == LogicalKeyboardKey.period) {
        fired = true;
        addToAmount(".");
      } else if (event.logicalKey == LogicalKeyboardKey.numpadDecimal) {
        fired = true;
        addToAmount(".");
      } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
        fired = true;
        removeToAmount();
      } else if (event.logicalKey == LogicalKeyboardKey.delete) {
        fired = true;
        removeToAmount();
      } else if (event.logicalKey == LogicalKeyboardKey.enter) {
        fired = true;
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
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                      padding: const EdgeInsets.only(bottom: 3.0),
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
                    key: ValueKey(
                      amount == ""
                          ? getCurrencyString() + "0"
                          : includesOperations(amount, false)
                              ? convertToMoney(calculateResult(amount))
                              : convertToMoney(double.tryParse(amount.substring(
                                                      amount.length - 1) ==
                                                  "." ||
                                              (amount.length > 2 &&
                                                  amount.substring(
                                                          amount.length - 2) ==
                                                      ".0")
                                          ? amount.substring(
                                              0, amount.length - 1)
                                          : amount) ??
                                      0) +
                                  (amount.substring(amount.length - 1) == "."
                                      ? "."
                                      : "") +
                                  (amount.length > 2 &&
                                          amount.substring(amount.length - 2) ==
                                              ".0"
                                      ? ".0"
                                      : ""),
                    ),
                    widthFactor: 0.5,
                    child: TextFont(
                      autoSizeText: true,
                      maxLines: 1,
                      minFontSize: 16,
                      text: amount == ""
                          ? getCurrencyString() + "0"
                          : includesOperations(amount, false)
                              ? convertToMoney(calculateResult(amount))
                              : convertToMoney(double.tryParse(amount.substring(
                                                      amount.length - 1) ==
                                                  "." ||
                                              (amount.length > 2 &&
                                                  amount.substring(
                                                          amount.length - 2) ==
                                                      ".0")
                                          ? amount.substring(
                                              0, amount.length - 1)
                                          : amount) ??
                                      0) +
                                  (amount.substring(amount.length - 1) == "."
                                      ? "."
                                      : "") +
                                  (amount.length > 2 &&
                                          amount.substring(amount.length - 2) ==
                                              ".0"
                                      ? ".0"
                                      : ""),
                      // text: amount,
                      textAlign: TextAlign.right,
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
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
                  }),
              CalculatorButton(
                label: "+",
                editAmount: () {
                  addToAmount("+");
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
      ),
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
  }) : super(key: key);
  final String label;
  final VoidCallback editAmount;
  final bool topRight;
  final bool topLeft;
  final bool bottomLeft;
  final bool bottomRight;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Theme.of(context).colorScheme.lightDarkAccentHeavy,
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

  bool fired = false;
  @override
  void initState() {
    super.initState();
    amount = widget.amountPassed;
    _focusAttachment = _focusNode.attach(context, onKeyEvent: (node, event) {
      if (fired) {
        fired = false;
      } else if (event.logicalKey.keyLabel == "Go Back") {
        fired = true;
        Navigator.pop(context);
      } else if (event.logicalKey == LogicalKeyboardKey.digit0) {
        fired = true;
        addToAmount("0");
      } else if (event.logicalKey == LogicalKeyboardKey.digit1) {
        fired = true;
        addToAmount("1");
      } else if (event.logicalKey == LogicalKeyboardKey.digit2) {
        fired = true;
        addToAmount("2");
      } else if (event.logicalKey == LogicalKeyboardKey.digit3) {
        fired = true;
        addToAmount("3");
      } else if (event.logicalKey == LogicalKeyboardKey.digit4) {
        fired = true;
        addToAmount("4");
      } else if (event.logicalKey == LogicalKeyboardKey.digit5) {
        fired = true;
        addToAmount("5");
      } else if (event.logicalKey == LogicalKeyboardKey.digit6) {
        fired = true;
        addToAmount("6");
      } else if (event.logicalKey == LogicalKeyboardKey.digit7) {
        fired = true;
        addToAmount("7");
      } else if (event.logicalKey == LogicalKeyboardKey.digit8) {
        fired = true;
        addToAmount("8");
      } else if (event.logicalKey == LogicalKeyboardKey.digit9) {
        fired = true;
        addToAmount("9");
      } else if (event.logicalKey == LogicalKeyboardKey.numpad0) {
        fired = true;
        addToAmount("0");
      } else if (event.logicalKey == LogicalKeyboardKey.numpad1) {
        fired = true;
        addToAmount("1");
      } else if (event.logicalKey == LogicalKeyboardKey.numpad2) {
        fired = true;
        addToAmount("2");
      } else if (event.logicalKey == LogicalKeyboardKey.numpad3) {
        fired = true;
        addToAmount("3");
      } else if (event.logicalKey == LogicalKeyboardKey.numpad4) {
        fired = true;
        addToAmount("4");
      } else if (event.logicalKey == LogicalKeyboardKey.numpad5) {
        fired = true;
        addToAmount("5");
      } else if (event.logicalKey == LogicalKeyboardKey.numpad6) {
        fired = true;
        addToAmount("6");
      } else if (event.logicalKey == LogicalKeyboardKey.numpad7) {
        fired = true;
        addToAmount("7");
      } else if (event.logicalKey == LogicalKeyboardKey.numpad8) {
        fired = true;
        addToAmount("8");
      } else if (event.logicalKey == LogicalKeyboardKey.numpad9) {
        fired = true;
        addToAmount("9");
      } else if (event.logicalKey == LogicalKeyboardKey.period) {
        fired = true;
        addToAmount(".");
      } else if (event.logicalKey == LogicalKeyboardKey.numpadDecimal) {
        fired = true;
        addToAmount(".");
      } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
        fired = true;
        removeToAmount();
      } else if (event.logicalKey == LogicalKeyboardKey.delete) {
        fired = true;
        removeToAmount();
      } else if (event.logicalKey == LogicalKeyboardKey.enter) {
        fired = true;
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
