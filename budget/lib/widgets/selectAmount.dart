import 'package:budget/functions.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:budget/colors.dart';

class SelectAmount extends StatefulWidget {
  SelectAmount(
      {Key? key,
      required this.setSelectedAmount,
      this.amountPassed = "",
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

  @override
  void initState() {
    super.initState();
    amount = widget.amountPassed;
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
    } else if ((!includesOperations(
                amount.substring(amount.length - 1), true) &&
            includesOperations(input, true)) ||
        !includesOperations(input, true)) {
      setState(() {
        amount += input;
      });
    } else if (includesOperations(amount.substring(amount.length - 1), false) &&
        input == ".") {
      setState(() {
        amount += "0" + input;
      });
    } else if (amount.substring(amount.length - 1) == "." &&
        includesOperations(input, false)) {
      setState(() {
        amount = amount.substring(0, amount.length - 1) + input;
      });
    } else if (includesOperations(amount.substring(amount.length - 1), false) &&
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
        print(operation);
        return true;
      }
    }
    return false;
  }

  bool decimalCheck(input) {
    var splitInputs = input.split(" ");
    for (var splitInput in splitInputs) {
      print('.'.allMatches(splitInput));
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
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
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
                      maxLines: 5,
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
                    fractionScaleHeight: 0.93,
                    fractionScaleWidth: 0.91,
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
                    fractionScaleHeight: 0.93,
                    fractionScaleWidth: 0.91,
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
        color: Theme.of(context).colorScheme.white,
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
              child: TextFont(
                fontSize: 24,
                text: label,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
