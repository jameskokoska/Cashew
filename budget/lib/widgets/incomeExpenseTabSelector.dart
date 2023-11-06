import 'package:budget/colors.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/outlinedButtonStacked.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry/incomeAmountArrow.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class IncomeExpenseTabSelector extends StatefulWidget {
  final Function(bool isIncome) onTabChanged;
  final bool initialTabIsIncome;
  final Color? color;
  final Color? unselectedColor;
  final bool syncWithInitial;
  final String? incomeLabel;
  final String? expenseLabel;
  final Color? unselectedLabelColor;
  final bool showIcons;

  IncomeExpenseTabSelector({
    required this.onTabChanged,
    required this.initialTabIsIncome,
    this.color,
    this.unselectedColor,
    this.syncWithInitial = false,
    this.incomeLabel,
    this.expenseLabel,
    this.unselectedLabelColor,
    this.showIcons = true,
  });

  @override
  _IncomeExpenseTabSelectorState createState() =>
      _IncomeExpenseTabSelectorState();
}

class _IncomeExpenseTabSelectorState extends State<IncomeExpenseTabSelector>
    with SingleTickerProviderStateMixin {
  late TabController _incomeTabController;
  bool selectedIncome = false;

  @override
  void initState() {
    super.initState();
    selectedIncome = widget.initialTabIsIncome;
    _incomeTabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: selectedIncome ? 1 : 0,
    );
  }

  @override
  void didUpdateWidget(covariant IncomeExpenseTabSelector oldWidget) {
    if (widget.syncWithInitial) {
      _incomeTabController.animateTo(widget.initialTabIsIncome ? 1 : 0);
      setState(() {
        selectedIncome = widget.initialTabIsIncome;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _incomeTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: widget.unselectedColor == null
          ? appStateSettings["materialYou"]
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Theme.of(context).brightness == Brightness.dark
                  ? getColor(context, "lightDarkAccentHeavyLight")
                      .withOpacity(0.5)
                  : Colors.black.withOpacity(0.07)
          : widget.unselectedColor,
      child: TabBar(
        controller: _incomeTabController,
        dividerColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: widget.color != null
              ? widget.color
              : (appStateSettings["materialYou"]
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.25)
                  : getColor(context, "black").withOpacity(0.15)),
        ),
        labelColor: getColor(context, "black"),
        unselectedLabelColor: widget.unselectedLabelColor ??
            getColor(context, "black").withOpacity(0.3),
        onTap: (value) {
          widget.onTabChanged(value == 1);
          setState(() {
            selectedIncome = value == 1;
          });
        },
        tabs: [
          Tab(
            child: ExpenseIncomeSelectorLabel(
              selectedIncome: selectedIncome,
              showIcons: widget.showIcons,
              label: widget.expenseLabel,
              isIncome: false,
            ),
          ),
          Tab(
            child: ExpenseIncomeSelectorLabel(
              selectedIncome: selectedIncome,
              showIcons: widget.showIcons,
              label: widget.incomeLabel,
              isIncome: true,
            ),
          ),
        ],
      ),
    );
  }
}

class ExpenseIncomeSelectorLabel extends StatelessWidget {
  const ExpenseIncomeSelectorLabel({
    required this.selectedIncome,
    required this.showIcons,
    required this.isIncome,
    this.label,
    super.key,
  });
  final bool selectedIncome;
  final bool showIcons;
  final String? label;
  final bool isIncome;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showIcons)
              AnimatedOpacity(
                duration: Duration(milliseconds: 300),
                opacity: (isIncome && selectedIncome) ||
                        (isIncome == false && selectedIncome == false)
                    ? 1
                    : 0.5,
                child: IncomeOutcomeArrow(
                  width: 19,
                  isIncome: isIncome,
                  color: isIncome
                      ? getColor(context, "incomeAmount")
                      : getColor(context, "expenseAmount"),
                ),
              ),
            Flexible(
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 300),
                opacity: (isIncome && selectedIncome) ||
                        (isIncome == false && selectedIncome == false)
                    ? 1
                    : 0.5,
                child: TextFont(
                  text: label ?? (isIncome ? "income".tr() : "expense".tr()),
                  maxLines: 2,
                  fontSize: 14.5,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IncomeExpenseButtonSelector extends StatefulWidget {
  const IncomeExpenseButtonSelector(
      {required this.setSelectedIncome, super.key});
  final Function(bool?) setSelectedIncome;

  @override
  State<IncomeExpenseButtonSelector> createState() =>
      _IncomeExpenseButtonSelectorState();
}

class _IncomeExpenseButtonSelectorState
    extends State<IncomeExpenseButtonSelector> {
  bool? selectedIncome;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 18, right: 18, bottom: 13),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Tappable(
                onTap: () {
                  if (selectedIncome == false) {
                    setState(() {
                      selectedIncome = null;
                    });
                  } else {
                    setState(() {
                      selectedIncome = false;
                    });
                  }
                  widget.setSelectedIncome(selectedIncome);
                },
                color: Colors.transparent,
                child: OutlinedContainer(
                  filled: selectedIncome == false,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ExpenseIncomeSelectorLabel(
                      selectedIncome: false,
                      showIcons: true,
                      isIncome: false,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 13),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Tappable(
                onTap: () {
                  if (selectedIncome == true) {
                    setState(() {
                      selectedIncome = null;
                    });
                  } else {
                    setState(() {
                      selectedIncome = true;
                    });
                  }
                  widget.setSelectedIncome(selectedIncome);
                },
                color: Colors.transparent,
                child: OutlinedContainer(
                  filled: selectedIncome == true,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ExpenseIncomeSelectorLabel(
                      selectedIncome: true,
                      showIcons: true,
                      isIncome: true,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
