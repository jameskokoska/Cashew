import 'package:budget/colors.dart';
import 'package:budget/struct/settings.dart';
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
              : getColor(context, "lightDarkAccentHeavyLight")
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
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.showIcons)
                      AnimatedOpacity(
                        duration: Duration(milliseconds: 300),
                        opacity: selectedIncome ? 0.5 : 1,
                        child: IncomeOutcomeArrow(
                          width: 19,
                          isIncome: false,
                          color: getColor(context, "expenseAmount"),
                        ),
                      ),
                    Text(
                      widget.expenseLabel ?? "expense".tr(),
                      style: TextStyle(
                        fontSize: 14.5,
                        fontFamily: 'Avenir',
                        fontFamilyFallback: ['Inter'],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Tab(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.showIcons)
                      AnimatedOpacity(
                        duration: Duration(milliseconds: 300),
                        opacity: !selectedIncome ? 0.5 : 1,
                        child: IncomeOutcomeArrow(
                          width: 19,
                          isIncome: true,
                          color: getColor(context, "incomeAmount"),
                        ),
                      ),
                    Text(
                      widget.incomeLabel ?? "income".tr(),
                      style: TextStyle(
                        fontSize: 14.5,
                        fontFamily: 'Avenir',
                        fontFamilyFallback: ['Inter'],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
