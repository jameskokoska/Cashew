import 'package:budget/colors.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/outlinedButtonStacked.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry/incomeAmountArrow.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
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
  final TabController? tabController;
  final Widget? expenseCustomIcon;
  final Widget? incomeCustomIcon;
  final Widget Function(bool selectedIncome)? belowWidgetBuilder;

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
    this.tabController,
    this.expenseCustomIcon,
    this.incomeCustomIcon,
    this.belowWidgetBuilder,
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
    _incomeTabController = widget.tabController ??
        TabController(
          length: 2,
          vsync: this,
          initialIndex: selectedIncome ? 1 : 0,
        );
    if (widget.tabController != null)
      _incomeTabController.addListener(onControllerTabSwitch);
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

  void onControllerTabSwitch() {
    setState(() {
      selectedIncome = _incomeTabController.index != 0;
    });
  }

  @override
  void dispose() {
    if (widget.tabController == null) _incomeTabController.dispose();
    if (widget.tabController != null)
      _incomeTabController.removeListener(onControllerTabSwitch);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget tabSelector = Material(
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
              customIcon: widget.expenseCustomIcon,
              tabController: _incomeTabController,
            ),
          ),
          Tab(
            child: ExpenseIncomeSelectorLabel(
              selectedIncome: selectedIncome,
              showIcons: widget.showIcons,
              label: widget.incomeLabel,
              isIncome: true,
              customIcon: widget.incomeCustomIcon,
              tabController: _incomeTabController,
            ),
          ),
        ],
      ),
    );
    if (widget.belowWidgetBuilder == null)
      return tabSelector;
    else
      return Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(
                getPlatform() == PlatformOS.isIOS ? 10 : 15),
            child: tabSelector,
          ),
          widget.belowWidgetBuilder!(selectedIncome)
        ],
      );
  }
}

class ExpenseIncomeSelectorLabel extends StatelessWidget {
  const ExpenseIncomeSelectorLabel({
    required this.selectedIncome,
    required this.showIcons,
    required this.isIncome,
    this.label,
    this.customIcon,
    this.tabController,
    super.key,
  });
  final bool selectedIncome;
  final bool showIcons;
  final String? label;
  final bool isIncome;
  final Widget? customIcon;
  final TabController? tabController;

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
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
            if (customIcon != null)
              Padding(
                padding: const EdgeInsets.only(right: 5),
                child: customIcon!,
              ),
            Flexible(
              child: TextFont(
                text: label ?? (isIncome ? "income".tr() : "expense".tr()),
                maxLines: 2,
                fontSize: 14.5,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
    return tabController == null
        ? AnimatedOpacity(
            duration: Duration(milliseconds: 300),
            opacity: (isIncome && selectedIncome) ||
                    (isIncome == false && selectedIncome == false)
                ? 1
                : 0.5,
            child: content,
          )
        : AnimatedBuilder(
            animation: tabController!.animation!,
            builder: (BuildContext context, Widget? child) {
              double animationProgress = isIncome
                  ? 0.5 + tabController!.animation!.value * 0.5
                  : 0.5 + (1 - tabController!.animation!.value) * 0.5;
              return AnimatedOpacity(
                duration: Duration(milliseconds: 300),
                opacity: clampDouble(animationProgress, 0, 1),
                child: content,
              );
            },
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
