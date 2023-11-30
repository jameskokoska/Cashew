import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addWalletPage.dart';
import 'package:budget/pages/editHomePage.dart';
import 'package:budget/pages/homePage/homePageLineGraph.dart';
import 'package:budget/pages/transactionsSearchPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/dropdownSelect.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/iconButtonScaled.dart';
import 'package:budget/widgets/incomeExpenseTabSelector.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/outlinedButtonStacked.dart';
import 'package:budget/widgets/radioItems.dart';
import 'package:budget/widgets/selectAmount.dart';
import 'package:budget/widgets/selectedTransactionsAppBar.dart';
import 'package:budget/widgets/categoryEntry.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/pieChart.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/tappableTextEntry.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntries.dart';
import 'package:budget/widgets/transactionEntry/transactionEntry.dart';
import 'package:budget/widgets/transactionsAmountBox.dart';
import 'package:budget/widgets/util/showDatePicker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';
import 'package:budget/widgets/viewAllTransactionsButton.dart';
import 'package:provider/provider.dart';

import 'selectDateRange.dart';

enum CycleType {
  allTime,
  dateRange, // e.g. September 10 to present day
  pastDays, // e.g. last 10 days
  cycle, //e.g. every 1 month starting Sept 13
}

class PeriodCyclePicker extends StatefulWidget {
  const PeriodCyclePicker({
    required this.cycleSettingsExtension,
    this.onlyShowCycleOption = false,
    super.key,
  });
  final String cycleSettingsExtension;
  final bool onlyShowCycleOption;

  @override
  State<PeriodCyclePicker> createState() => _PeriodCyclePickerState();
}

class _PeriodCyclePickerState extends State<PeriodCyclePicker> {
  late CycleType selectedCycle = CycleType.values[appStateSettings[
          "selectedPeriodCycleType" + widget.cycleSettingsExtension] ??
      0];
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.onlyShowCycleOption == false)
          CycleTypeEntry(
            cycleSettingsExtension: widget.cycleSettingsExtension,
            title: "all-time".tr(),
            icon: appStateSettings["outlinedIcons"]
                ? Icons.apps_outlined
                : Icons.apps_rounded,
            cycle: CycleType.allTime,
            onTap: () {
              setState(() {
                selectedCycle = CycleType.allTime;
              });
            },
            selectedCycle: selectedCycle,
          ),
        CycleTypeEntry(
          cycleSettingsExtension: widget.cycleSettingsExtension,
          title: "cycle".tr(),
          icon: appStateSettings["outlinedIcons"]
              ? Icons.timelapse_outlined
              : Icons.timelapse_rounded,
          cycle: CycleType.cycle,
          onTap: () {
            setState(() {
              selectedCycle = CycleType.cycle;
            });
          },
          extraWidget: CyclePeriodSelection(
            cycleSettingsExtension: widget.cycleSettingsExtension,
          ),
          selectedCycle:
              widget.onlyShowCycleOption ? CycleType.cycle : selectedCycle,
        ),
        if (widget.onlyShowCycleOption == false)
          CycleTypeEntry(
            cycleSettingsExtension: widget.cycleSettingsExtension,
            title: "past-days".tr(),
            icon: appStateSettings["outlinedIcons"]
                ? Icons.today_outlined
                : Icons.today_rounded,
            cycle: CycleType.pastDays,
            onTap: () {
              setState(() {
                selectedCycle = CycleType.pastDays;
              });
            },
            selectedCycle: selectedCycle,
            extraWidget: PastDaysSelection(
              cycleSettingsExtension: widget.cycleSettingsExtension,
            ),
          ),
        if (widget.onlyShowCycleOption == false)
          CycleTypeEntry(
            cycleSettingsExtension: widget.cycleSettingsExtension,
            title: "date-range".tr(),
            icon: appStateSettings["outlinedIcons"]
                ? Icons.date_range_outlined
                : Icons.date_range_rounded,
            cycle: CycleType.dateRange,
            onTap: () {
              setState(() {
                selectedCycle = CycleType.dateRange;
              });
            },
            extraWidget: SelectDateRange(
              initialStartDate: DateTime.tryParse(appStateSettings[
                      "customPeriodStartDate" +
                          widget.cycleSettingsExtension] ??
                  ""),
              onSelectedStartDate: (DateTime? selectedStartDate) {
                updateSettings(
                    "customPeriodStartDate" + widget.cycleSettingsExtension,
                    (selectedStartDate ?? DateTime.now()).toString(),
                    updateGlobalState: false);
              },
              initialEndDate: DateTime.tryParse(appStateSettings[
                      "customPeriodEndDate" + widget.cycleSettingsExtension] ??
                  ""),
              onSelectedEndDate: (DateTime? selectedEndDate) {
                updateSettings(
                    "customPeriodEndDate" + widget.cycleSettingsExtension,
                    selectedEndDate.toString(),
                    updateGlobalState: false);
              },
            ),
            selectedCycle: selectedCycle,
          ),
      ],
    );
  }
}

class CycleTypeEntry extends StatelessWidget {
  const CycleTypeEntry({
    super.key,
    required this.title,
    required this.icon,
    this.extraWidget,
    required this.onTap,
    required this.cycle,
    required this.selectedCycle,
    required this.cycleSettingsExtension,
  });

  final String title;
  final IconData icon;
  final Widget? extraWidget;
  final VoidCallback onTap;
  final CycleType cycle;
  final CycleType selectedCycle;
  final String cycleSettingsExtension;

  @override
  Widget build(BuildContext context) {
    bool isSelected = cycle == selectedCycle;
    return AnimatedOpacity(
      duration: Duration(milliseconds: 500),
      opacity: isSelected ? 1 : 0.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButtonStacked(
                filled: isSelected,
                alignLeft: true,
                alignBeside: true,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                text: title,
                iconData: icon,
                onTap: () {
                  onTap();
                  updateSettings(
                      "selectedPeriodCycleType" + cycleSettingsExtension,
                      cycle.index,
                      updateGlobalState: false);
                },
                afterWidget: extraWidget == null
                    ? null
                    : IgnorePointer(
                        ignoring: !isSelected,
                        child: extraWidget,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CyclePeriodSelection extends StatefulWidget {
  const CyclePeriodSelection({
    super.key,
    required this.cycleSettingsExtension,
  });
  final String cycleSettingsExtension;
  @override
  State<CyclePeriodSelection> createState() => _CyclePeriodSelectionState();
}

class _CyclePeriodSelectionState extends State<CyclePeriodSelection> {
  late int selectedPeriodLength;
  late DateTime selectedStartDate;
  late DateTime? selectedEndDate;
  late String selectedRecurrence;
  String selectedRecurrenceDisplay = "month";
  @override
  void initState() {
    selectedPeriodLength =
        appStateSettings["cyclePeriodLength" + widget.cycleSettingsExtension] ??
            1;
    selectedStartDate = DateTime.tryParse(appStateSettings[
            "cycleStartDate" + widget.cycleSettingsExtension]) ??
        DateTime(DateTime.now().year, DateTime.now().month, 1);
    selectedRecurrence = enumRecurrence[BudgetReoccurence.values[
            appStateSettings[
                "cycleReoccurrence" + widget.cycleSettingsExtension]]] ??
        "Monthly";

    if (selectedPeriodLength == 1) {
      selectedRecurrenceDisplay = nameRecurrence[selectedRecurrence];
    } else {
      selectedRecurrenceDisplay = namesRecurrence[selectedRecurrence];
    }
    super.initState();
  }

  Future<void> selectPeriodLength(BuildContext context) async {
    openBottomSheet(
      context,
      PopupFramework(
        title: "enter-period-length".tr(),
        child: SelectAmountValue(
          amountPassed: selectedPeriodLength.toString(),
          setSelectedAmount: (amount, _) {
            setSelectedPeriodLength(amount);
          },
          next: () async {
            Navigator.pop(context);
          },
          nextLabel: "set-amount".tr(),
        ),
      ),
    );
  }

  void setSelectedPeriodLength(double period) {
    try {
      setState(() {
        selectedPeriodLength = period.toInt();
        if (selectedPeriodLength == 0) {
          selectedPeriodLength = 1;
        }
        if (selectedPeriodLength == 1) {
          selectedRecurrenceDisplay = nameRecurrence[selectedRecurrence];
        } else {
          selectedRecurrenceDisplay = namesRecurrence[selectedRecurrence];
        }
      });
    } catch (e) {
      setState(() {
        selectedPeriodLength = 1;
        if (selectedPeriodLength == 1) {
          selectedRecurrenceDisplay = nameRecurrence[selectedRecurrence];
        } else {
          selectedRecurrenceDisplay = namesRecurrence[selectedRecurrence];
        }
      });
    }
    updateSettings("cyclePeriodLength" + widget.cycleSettingsExtension,
        selectedPeriodLength,
        updateGlobalState: false);
    return;
  }

  Future<void> selectRecurrence(BuildContext context) async {
    openBottomSheet(
      context,
      PopupFramework(
        title: "select-period".tr(),
        child: RadioItems(
          items: ["Daily", "Weekly", "Monthly", "Yearly"],
          initial: selectedRecurrence,
          displayFilter: (item) {
            return item.toString().toLowerCase().tr();
          },
          onChanged: (value) {
            setState(() {
              selectedRecurrence = value;
              updateSettings(
                  "cycleReoccurrence" + widget.cycleSettingsExtension,
                  enumRecurrence[value].index,
                  updateGlobalState: false);
              if (selectedPeriodLength == 1) {
                selectedRecurrenceDisplay = nameRecurrence[value];
              } else {
                selectedRecurrenceDisplay = namesRecurrence[value];
              }
            });
            Navigator.of(context).pop();
          },
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
      updateSettings(
          "cycleStartDate" + widget.cycleSettingsExtension, date.toString(),
          updateGlobalState: false);
      setState(() {
        selectedStartDate = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            alignment: WrapAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 15,
                  right: 10,
                  left: 10,
                ),
                child: TextFont(
                  text: "every".tr(),
                  fontSize: 20,
                ),
              ),
              IntrinsicWidth(
                child: Row(
                  children: [
                    TappableTextEntry(
                      title: selectedPeriodLength.toString(),
                      placeholder: "0",
                      showPlaceHolderWhenTextEquals: "0",
                      onTap: () {
                        selectPeriodLength(context);
                      },
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      internalPadding:
                          EdgeInsets.symmetric(vertical: 4, horizontal: 9),
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 3),
                    ),
                    TappableTextEntry(
                      title: selectedRecurrenceDisplay
                          .toString()
                          .toLowerCase()
                          .tr()
                          .toLowerCase(),
                      placeholder: "",
                      onTap: () {
                        selectRecurrence(context);
                      },
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      internalPadding:
                          EdgeInsets.symmetric(vertical: 4, horizontal: 5),
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
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
                        text: "beginning".tr() + " ",
                        fontSize: 20,
                      ),
                    ),
                    IgnorePointer(
                      child: TappableTextEntry(
                        title: getWordedDateShortMore(selectedStartDate),
                        placeholder: "",
                        onTap: () {},
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        internalPadding:
                            EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                        padding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Builder(builder: (context) {
          DateTimeRange budgetRange = getBudgetDate(
            Budget(
              startDate: selectedStartDate,
              periodLength: selectedPeriodLength,
              reoccurrence: enumRecurrence[selectedRecurrence],
              budgetPk: "-1",
              name: "",
              amount: 0,
              endDate: DateTime.now(),
              addedTransactionsOnly: false,
              dateCreated: DateTime.now(),
              pinned: false,
              order: -1,
              walletFk: "",
              isAbsoluteSpendingLimit: false,
              income: false,
            ),
            DateTime.now(),
          );
          return Padding(
            padding: const EdgeInsets.only(
              bottom: 0,
              top: 15,
            ),
            child: TextFont(
              text: "(" +
                  getWordedDateShortMore(budgetRange.start) +
                  " – " +
                  getWordedDateShortMore(budgetRange.end) +
                  ")",
              fontSize: 16,
              maxLines: 3,
              textColor: getColor(context, "textLight"),
              textAlign: TextAlign.center,
            ),
          );
        }),
      ],
    );
  }
}

Budget getCustomCycleTempBudget(String cycleSettingsExtension) {
  return Budget(
    startDate: DateTime.tryParse(
            appStateSettings["cycleStartDate" + cycleSettingsExtension] ??
                "") ??
        DateTime.now(),
    periodLength:
        appStateSettings["cyclePeriodLength" + cycleSettingsExtension] ?? 1,
    reoccurrence: BudgetReoccurence.values[
        appStateSettings["cycleReoccurrence" + cycleSettingsExtension] ?? 0],
    budgetPk: "-1",
    name: "",
    amount: 0,
    endDate: DateTime.now(),
    addedTransactionsOnly: false,
    dateCreated: DateTime.now(),
    pinned: false,
    order: -1,
    walletFk: "",
    isAbsoluteSpendingLimit: false,
    income: false,
  );
}

DateTime getCycleDatePastToDetermineBudgetDate(
    String cycleSettingsExtension, int index) {
  return getDatePastToDetermineBudgetDate(
    index,
    getCustomCycleTempBudget(cycleSettingsExtension),
  );
}

DateTimeRange getCycleDateTimeRange(String cycleSettingsExtension,
    {DateTime? currentDate}) {
  return getBudgetDate(
    getCustomCycleTempBudget(cycleSettingsExtension),
    currentDate ?? DateTime.now(),
  );
}

DateTime? getStartDateOfSelectedCustomPeriod(
  String cycleSettingsExtension, {
  DateTimeRange? forcedDateTimeRange,
}) {
  if (forcedDateTimeRange != null) {
    return forcedDateTimeRange.start;
  }
  CycleType selectedPeriodType = CycleType.values[
      appStateSettings["selectedPeriodCycleType" + cycleSettingsExtension] ??
          0];
  if (selectedPeriodType == CycleType.allTime) {
    return null;
  } else if (selectedPeriodType == CycleType.cycle) {
    DateTimeRange budgetRange = getCycleDateTimeRange(cycleSettingsExtension);
    DateTime startDate = DateTime(
        budgetRange.start.year, budgetRange.start.month, budgetRange.start.day);
    return startDate;
  } else if (selectedPeriodType == CycleType.pastDays) {
    DateTime startDate = DateTime.now().subtract(Duration(
        days: (appStateSettings[
                "customPeriodPastDays" + cycleSettingsExtension] ??
            0)));
    if (startDate.year <= 1900) return DateTime(1900);
    if (startDate.isAfter(DateTime.now())) return DateTime(1900);
    return startDate;
  } else if (selectedPeriodType == CycleType.dateRange) {
    DateTime startDate = DateTime.tryParse(appStateSettings[
                "customPeriodStartDate" + cycleSettingsExtension] ??
            "") ??
        DateTime.now();
    return startDate;
  }
  return null;
}

DateTime? getEndDateOfSelectedCustomPeriod(
  String cycleSettingsExtension, {
  DateTimeRange? forcedDateTimeRange,
}) {
  if (forcedDateTimeRange != null) {
    return forcedDateTimeRange.end;
  }

  CycleType selectedPeriodType = CycleType.values[
      appStateSettings["selectedPeriodCycleType" + cycleSettingsExtension] ??
          0];

  // If it is a cycle, we want the end date to be null (display everything up to today!)
  // Therefore, do not add this code in!
  if (selectedPeriodType == CycleType.cycle) {
    DateTimeRange budgetRange = getCycleDateTimeRange(cycleSettingsExtension);
    DateTime endDate = DateTime(
        budgetRange.end.year, budgetRange.end.month, budgetRange.end.day);
    return endDate;
  }

  if (selectedPeriodType == CycleType.pastDays) {
    DateTime endDate =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return endDate;
  }

  if (selectedPeriodType == CycleType.dateRange) {
    DateTime? endDate = DateTime.tryParse(
        appStateSettings["customPeriodEndDate" + cycleSettingsExtension] ?? "");
    return endDate == null
        ? null
        : DateTime(endDate.year, endDate.month, endDate.day, 23, 59);
  }
  return null;
}

String getLabelOfSelectedCustomPeriod(String cycleSettingsExtension) {
  CycleType selectedPeriodType = CycleType.values[
      appStateSettings["selectedPeriodCycleType" + cycleSettingsExtension] ??
          0];
  if (selectedPeriodType == CycleType.allTime) {
    return "all-time".tr();
  } else if (selectedPeriodType == CycleType.cycle) {
    DateTimeRange dateRange = getCycleDateTimeRange(cycleSettingsExtension);
    return getWordedDateShort(dateRange.start) +
        " – " +
        getWordedDateShort(dateRange.end);
  } else if (selectedPeriodType == CycleType.pastDays) {
    int days =
        appStateSettings["customPeriodPastDays" + cycleSettingsExtension] ?? 1;
    return "previous".tr() +
        " " +
        days.toString() +
        " " +
        (days == 1 ? "day".tr() : "days".tr());
  } else if (selectedPeriodType == CycleType.dateRange) {
    DateTime startDate =
        getStartDateOfSelectedCustomPeriod(cycleSettingsExtension) ??
            DateTime.now();
    DateTime? endDate =
        getEndDateOfSelectedCustomPeriod(cycleSettingsExtension);
    return getWordedDateShort(startDate) +
        (endDate == null
            ? " " + "until-forever".tr().toLowerCase()
            : (" – " + getWordedDateShort(endDate)));
  }
  return "";
}

class PastDaysSelection extends StatefulWidget {
  const PastDaysSelection({super.key, required this.cycleSettingsExtension});
  final String cycleSettingsExtension;
  @override
  State<PastDaysSelection> createState() => _PastDaysSelectionState();
}

class _PastDaysSelectionState extends State<PastDaysSelection> {
  late int selectedPeriodLength;

  @override
  void initState() {
    selectedPeriodLength = appStateSettings[
            "customPeriodPastDays" + widget.cycleSettingsExtension] ??
        1;
    super.initState();
  }

  Future<void> selectPeriodLength(BuildContext context) async {
    openBottomSheet(
      context,
      PopupFramework(
        title: "enter-period-length".tr(),
        child: SelectAmountValue(
          amountPassed: selectedPeriodLength.toString(),
          setSelectedAmount: (amount, _) {
            setSelectedPeriodLength(amount);
          },
          next: () async {
            Navigator.pop(context);
          },
          nextLabel: "set-amount".tr(),
        ),
      ),
    );
  }

  void setSelectedPeriodLength(double period) {
    try {
      setState(() {
        selectedPeriodLength = period.toInt();
        if (selectedPeriodLength == 0) {
          selectedPeriodLength = 1;
        }
      });
    } catch (e) {
      setState(() {
        selectedPeriodLength = 0;
      });
    }
    updateSettings("customPeriodPastDays" + widget.cycleSettingsExtension,
        selectedPeriodLength,
        updateGlobalState: false);
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFont(
                text: "previous".tr(),
                fontSize: 20,
              ),
              Flexible(
                child: TappableTextEntry(
                  title: selectedPeriodLength.toString(),
                  placeholder: "0",
                  showPlaceHolderWhenTextEquals: "0",
                  onTap: () {
                    selectPeriodLength(context);
                  },
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  internalPadding:
                      EdgeInsets.symmetric(vertical: 4, horizontal: 9),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 3),
                ),
              ),
              TextFont(
                text: selectedPeriodLength == 1 ? "day".tr() : "days".tr(),
                fontSize: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
