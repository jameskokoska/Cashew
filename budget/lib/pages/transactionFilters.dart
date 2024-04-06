import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addObjectivePage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/addWalletPage.dart';
import 'package:budget/pages/transactionsSearchPage.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/iconButtonScaled.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/selectedTransactionsAppBar.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/selectCategory.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntries.dart';
import 'package:budget/widgets/transactionEntry/transactionEntry.dart';
import 'package:budget/widgets/util/debouncer.dart';
import 'package:budget/widgets/util/showDatePicker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';
import 'package:provider/provider.dart';
import 'package:budget/widgets/selectChips.dart';
import 'package:budget/widgets/framework/popupFramework.dart';

import '../widgets/amountRangeSlider.dart';

class SearchFilters {
  SearchFilters({
    this.walletPks = const [],
    this.categoryPks = const [],
    this.subcategoryPks = const [],
    this.budgetPks = const [],
    this.excludedBudgetPks = const [],
    this.objectivePks = const [],
    this.objectiveLoanPks = const [],
    this.expenseIncome = const [],
    this.positiveCashFlow, //Similar to isIncome, but includes anything that is positive amount (loans)
    this.paidStatus = const [],
    this.transactionTypes = const [],
    this.budgetTransactionFilters = const [],
    // this.reoccurence,
    this.methodAdded = const [],
    this.amountRange,
    this.dateTimeRange,
    this.searchQuery,
    this.titleContains,
    this.noteContains,
  }) {
    walletPks = this.walletPks.isEmpty ? [] : this.walletPks;
    categoryPks = this.categoryPks.isEmpty ? [] : this.categoryPks;
    subcategoryPks =
        this.subcategoryPks?.isEmpty == true ? [] : this.subcategoryPks;
    budgetPks = this.budgetPks.isEmpty ? [] : this.budgetPks;
    excludedBudgetPks =
        this.excludedBudgetPks.isEmpty ? [] : this.excludedBudgetPks;
    objectivePks = this.objectivePks.isEmpty ? [] : this.objectivePks;
    objectiveLoanPks =
        this.objectiveLoanPks.isEmpty ? [] : this.objectiveLoanPks;
    expenseIncome = this.expenseIncome.isEmpty ? [] : this.expenseIncome;
    positiveCashFlow = this.positiveCashFlow;
    paidStatus = this.paidStatus.isEmpty ? [] : this.paidStatus;
    transactionTypes =
        this.transactionTypes.isEmpty ? [] : this.transactionTypes;
    budgetTransactionFilters = this.budgetTransactionFilters.isEmpty
        ? []
        : this.budgetTransactionFilters;
    // reoccurence = [];
    methodAdded = this.methodAdded.isEmpty ? [] : this.methodAdded;
  }
  //if the value is empty, it means all/ignore
  // think of it, if the tag is added it will be considered in the search
  List<String> walletPks;
  List<String> categoryPks;
  List<String>?
      subcategoryPks; // if this is null, it means any transaction WITHOUT a subcategory (blank list means all)
  List<String?> budgetPks;
  List<String> excludedBudgetPks;
  List<String?> objectivePks;
  List<String?> objectiveLoanPks;
  List<ExpenseIncome> expenseIncome;
  bool? positiveCashFlow;
  List<PaidStatus> paidStatus;
  List<TransactionSpecialType?> transactionTypes;
  List<BudgetTransactionFilters> budgetTransactionFilters;
  // List<BudgetReoccurence> reoccurence;
  List<MethodAdded> methodAdded;
  RangeValues? amountRange;
  DateTimeRange? dateTimeRange;
  String? searchQuery;
  String? titleContains;
  String? noteContains;

  SearchFilters copyWith({
    List<String>? walletPks,
    List<String>? categoryPks,
    List<String>? subcategoryPks,
    List<String?>? budgetPks,
    List<String>? excludedBudgetPks,
    List<String?>? objectivePks,
    List<String?>? objectiveLoanPks,
    List<ExpenseIncome>? expenseIncome,
    bool? positiveCashFlow,
    List<PaidStatus>? paidStatus,
    List<TransactionSpecialType?>? transactionTypes,
    List<BudgetTransactionFilters>? budgetTransactionFilters,
    List<MethodAdded>? methodAdded,
    RangeValues? amountRange,
    DateTimeRange? dateTimeRange,
    bool forceSetDateTimeRange = false,
    String? searchQuery,
    String? titleContains,
    String? noteContains,
  }) {
    return SearchFilters(
      walletPks: walletPks ?? this.walletPks,
      categoryPks: categoryPks ?? this.categoryPks,
      subcategoryPks: subcategoryPks ?? this.subcategoryPks,
      budgetPks: budgetPks ?? this.budgetPks,
      excludedBudgetPks: excludedBudgetPks ?? this.excludedBudgetPks,
      objectivePks: objectivePks ?? this.objectivePks,
      objectiveLoanPks: objectiveLoanPks ?? this.objectiveLoanPks,
      expenseIncome: expenseIncome ?? this.expenseIncome,
      positiveCashFlow: positiveCashFlow,
      paidStatus: paidStatus ?? this.paidStatus,
      transactionTypes: transactionTypes ?? this.transactionTypes,
      budgetTransactionFilters:
          budgetTransactionFilters ?? this.budgetTransactionFilters,
      methodAdded: methodAdded ?? this.methodAdded,
      amountRange: amountRange ?? this.amountRange,
      dateTimeRange: forceSetDateTimeRange == true
          ? dateTimeRange
          : (dateTimeRange ?? this.dateTimeRange),
      searchQuery: searchQuery ?? this.searchQuery,
      titleContains: titleContains ?? this.titleContains,
      noteContains: noteContains ?? this.noteContains,
    );
  }

  clearSearchFilters() {
    walletPks = [];
    categoryPks = [];
    subcategoryPks = [];
    budgetPks = [];
    excludedBudgetPks = [];
    objectivePks = [];
    objectiveLoanPks = [];
    expenseIncome = [];
    positiveCashFlow = null;
    paidStatus = [];
    transactionTypes = [];
    budgetTransactionFilters = [];
    // reoccurence = [];
    methodAdded = [];
    amountRange = null;
    dateTimeRange = null;
    searchQuery = null;
    titleContains = null;
    noteContains = null;
  }

  bool isClear({bool? ignoreDateTimeRange, bool? ignoreSearchQuery}) {
    if (walletPks.isEmpty &&
        categoryPks.isEmpty &&
        subcategoryPks?.isEmpty == true &&
        budgetPks.isEmpty &&
        excludedBudgetPks.isEmpty &&
        objectivePks.isEmpty &&
        objectiveLoanPks.isEmpty &&
        expenseIncome.isEmpty &&
        positiveCashFlow == null &&
        paidStatus.isEmpty &&
        transactionTypes.isEmpty &&
        budgetTransactionFilters.isEmpty &&
        // reoccurence == [] &&
        methodAdded.isEmpty &&
        amountRange == null &&
        (ignoreDateTimeRange == true || dateTimeRange == null) &&
        (ignoreSearchQuery == true || searchQuery == null) &&
        titleContains == null &&
        noteContains == null)
      return true;
    else
      return false;
  }

  void loadFilterString(String? filterString,
      {bool skipDateTimeRange = false, bool skipSearchQuery = false}) {
    if (filterString == null) return;
    List<String> filterElements = filterString.split(":-:");
    clearSearchFilters();

    for (int i = 0; i < filterElements.length; i += 2) {
      if (i >= filterElements.length - 1) break;
      String? key = nullIfIndexOutOfRange(filterElements, i);
      String? value = nullIfIndexOutOfRange(filterElements, i + 1);
      if (key == null || value == null) break;
      try {
        switch (key) {
          case 'walletPks':
            walletPks.add(value);
            break;
          case 'categoryPks':
            categoryPks.add(value);
            break;
          case 'subcategoryPks':
            if (value == "null") {
              subcategoryPks = null;
            } else {
              subcategoryPks?.add(value);
            }
            break;
          case 'budgetPks':
            if (value == "null") {
              budgetPks.add(null);
            } else {
              budgetPks.add(value);
            }
            break;
          case 'excludedBudgetPks':
            excludedBudgetPks.add(value);
            break;
          case 'objectivePks':
            if (value == "null") {
              objectivePks.add(null);
            } else {
              objectivePks.add(value);
            }
            break;
          case 'objectiveLoanPks':
            if (value == "null") {
              objectiveLoanPks.add(null);
            } else {
              objectiveLoanPks.add(value);
            }
            break;
          case 'expenseIncome':
            expenseIncome.add(ExpenseIncome.values[int.parse(value)]);
            break;
          case 'positiveCashFlow':
            if (value == "null") {
              positiveCashFlow = null;
            } else {
              positiveCashFlow = bool.parse(value);
            }
            break;
          case 'paidStatus':
            paidStatus.add(PaidStatus.values[int.parse(value)]);
            break;
          case 'transactionTypes':
            if (value == "null") {
              transactionTypes.add(null);
            } else {
              transactionTypes
                  .add(TransactionSpecialType.values[int.parse(value)]);
            }
            break;
          case 'budgetTransactionFilters':
            budgetTransactionFilters
                .add(BudgetTransactionFilters.values[int.parse(value)]);
            break;
          case 'methodAdded':
            methodAdded.add(MethodAdded.values[int.parse(value)]);
            break;
          case 'amountRange':
            if (value == "null") {
              amountRange = null;
            } else {
              value = value.replaceAll("RangeValues(", "");
              value = value.replaceAll(")", "");
              List<String> rangeValues = value.split(", ");
              amountRange = RangeValues(
                double.parse(rangeValues[0]),
                double.parse(rangeValues[1]),
              );
            }
            break;
          case 'dateTimeRange':
            if (value == "null" || skipDateTimeRange) {
              dateTimeRange = null;
            } else {
              List<String> dateValues = value.split(" - ");
              dateTimeRange = DateTimeRange(
                start: DateTime.parse(dateValues[0]),
                end: DateTime.parse(dateValues[1]),
              );
            }
            break;
          case 'searchQuery':
            if (value == "null" || value.trim() == "" || skipSearchQuery) {
              searchQuery = null;
            } else {
              searchQuery = value;
            }
            break;
          case 'titleContains':
            if (value == "null" || value.trim() == "") {
              titleContains = null;
            } else {
              titleContains = value;
            }
            break;
          case 'noteContains':
            if (value == "null" || value.trim() == "") {
              noteContains = null;
            } else {
              noteContains = value;
            }
            break;
          default:
            break;
        }
      } catch (e) {
        print(
          e.toString() +
              " error loading filter string " +
              key.toString() +
              " " +
              value.toString(),
        );
      }
    }
  }

  String getFilterString() {
    String outString = "";
    for (String element in walletPks) {
      outString += "walletPks:-:" + element + ":-:";
    }
    for (String element in categoryPks) {
      outString += "categoryPks:-:" + element + ":-:";
    }
    for (String element in subcategoryPks ?? []) {
      outString += "subcategoryPks:-:" + element + ":-:";
    }
    if (subcategoryPks == null) {
      outString += "subcategoryPks:-:" + "null" + ":-:";
    }
    for (String? element in budgetPks) {
      outString += "budgetPks:-:" + element.toString() + ":-:";
    }
    for (String? element in excludedBudgetPks) {
      outString += "excludedBudgetPks:-:" + element.toString() + ":-:";
    }
    for (String? element in objectivePks) {
      outString += "objectivePks:-:" + element.toString() + ":-:";
    }
    for (String? element in objectivePks) {
      outString += "objectiveLoanPks:-:" + element.toString() + ":-:";
    }
    for (ExpenseIncome element in expenseIncome) {
      outString += "expenseIncome:-:" + (element.index).toString() + ":-:";
    }
    outString += "positiveCashFlow:-:" + positiveCashFlow.toString() + ":-:";
    for (PaidStatus element in paidStatus) {
      outString += "paidStatus:-:" + (element.index).toString() + ":-:";
    }
    for (TransactionSpecialType? element in transactionTypes) {
      outString +=
          "transactionTypes:-:" + (element?.index ?? null).toString() + ":-:";
    }
    for (BudgetTransactionFilters element in budgetTransactionFilters) {
      outString +=
          "budgetTransactionFilters:-:" + (element.index).toString() + ":-:";
    }
    for (MethodAdded element in methodAdded) {
      outString +=
          "methodAdded:-:" + (element.index).toString().toString() + ":-:";
    }
    outString += "amountRange:-:" + amountRange.toString() + ":-:";
    outString += "dateTimeRange:-:" + dateTimeRange.toString() + ":-:";
    outString += "searchQuery:-:" + searchQuery.toString() + ":-:";
    outString += "titleContains:-:" + titleContains.toString() + ":-:";
    outString += "noteContains:-:" + noteContains.toString() + ":-:";
    //print(outString);
    return outString;
  }
}

class HighlightStringInList extends TextEditingController {
  final Pattern pattern;

  HighlightStringInList({String? initialText})
      : pattern = RegExp(r'\b[^,]+(?=|$)') {
    this.text = initialText ?? '';
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    if (text.contains(", ") == false) return TextSpan(style: style, text: text);
    List<InlineSpan> children = [];
    text.splitMapJoin(
      pattern,
      onMatch: (Match match) {
        children.add(
          TextSpan(
            text: match[0] ?? "",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              backgroundColor: dynamicPastel(
                context,
                Theme.of(context).colorScheme.primary.withOpacity(0.5),
                inverse: true,
                amountDark: 0.1,
                amountLight: 0.25,
              ),
            ),
          ),
        );
        return match[0] ?? "";
      },
      onNonMatch: (String text) {
        children.add(TextSpan(text: text, style: style));
        return text;
      },
    );
    return TextSpan(style: style, children: children);
  }
}

class TransactionFiltersSelection extends StatefulWidget {
  const TransactionFiltersSelection(
      {required this.searchFilters,
      required this.setSearchFilters,
      required this.clearSearchFilters,
      super.key});

  final SearchFilters searchFilters;
  final Function(SearchFilters searchFilters) setSearchFilters;
  final Function() clearSearchFilters;

  @override
  State<TransactionFiltersSelection> createState() =>
      _TransactionFiltersSelectionState();
}

class _TransactionFiltersSelectionState
    extends State<TransactionFiltersSelection> {
  late SearchFilters selectedFilters = widget.searchFilters;
  late ScrollController titleContainsScrollController = ScrollController();
  late TextEditingController titleContainsController = HighlightStringInList(
    initialText: selectedFilters.titleContains,
  );

  void setSearchFilters() {
    widget.setSearchFilters(selectedFilters);
    setState(() {});
  }

  @override
  void dispose() {
    titleContainsController.dispose();
    titleContainsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SelectCategory(
          horizontalList: true,
          showSelectedAllCategoriesIfNoneSelected: true,
          addButton: false,
          selectedCategories: selectedFilters.categoryPks,
          setSelectedCategories: (List<String>? categories) async {
            selectedFilters.categoryPks = categories ?? [];
            if (selectedFilters.categoryPks.length <= 0)
              selectedFilters.subcategoryPks = [];

            // Remove any subcategories that are selected that no longer
            // have the primary category selected
            for (String subCategoryPk in ([
              ...selectedFilters.subcategoryPks ?? []
            ])) {
              TransactionCategory subCategory =
                  await database.getCategoryInstance(subCategoryPk);
              if ((categories ?? []).contains(subCategory.mainCategoryPk) ==
                  false) {
                (selectedFilters.subcategoryPks ?? []).remove(subCategoryPk);
              }
            }

            setSearchFilters();
          },
        ),
        SelectCategory(
          horizontalList: true,
          showSelectedAllCategoriesIfNoneSelected: true,
          addButton: false,
          selectedCategories: selectedFilters.subcategoryPks,
          setSelectedCategories: (List<String>? categories) {
            selectedFilters.subcategoryPks = categories ?? [];
            setSearchFilters();
          },
          mainCategoryPks: selectedFilters.categoryPks,
          forceSelectAllToFalse: selectedFilters.subcategoryPks == null,
          header: [
            SelectedCategoryHorizontalExtraButton(
              label: "none".tr(),
              onTap: () {
                selectedFilters.subcategoryPks = null;
                setSearchFilters();
              },
              isOutlined: selectedFilters.subcategoryPks == null,
              icon: appStateSettings["outlinedIcons"]
                  ? Icons.block_outlined
                  : Icons.block_rounded,
            ),
          ],
        ),
        StreamBuilder<RangeValues>(
          stream: database.getHighestLowestAmount(
            SearchFilters(
              dateTimeRange: selectedFilters.dateTimeRange,
            ),
          ),
          builder: ((context, snapshot) {
            if (snapshot.hasData) {
              RangeValues rangeLimit = RangeValues(
                  (snapshot.data?.start ?? -0.00000001),
                  (snapshot.data?.end ?? 0.00000001));
              if ((selectedFilters.amountRange?.start ?? 0) <
                      rangeLimit.start ||
                  (selectedFilters.amountRange?.end ?? 0) > rangeLimit.end) {
                selectedFilters.amountRange = rangeLimit;
              }
              if (selectedFilters.amountRange?.end == rangeLimit.end &&
                  selectedFilters.amountRange?.start == rangeLimit.start) {
                selectedFilters.amountRange = null;
              }
              return AmountRangeSlider(
                rangeLimit: rangeLimit,
                initialRange: selectedFilters.amountRange,
                onChange: (RangeValues rangeValue) {
                  if (rangeLimit == rangeValue)
                    selectedFilters.amountRange = null;
                  else
                    selectedFilters.amountRange = rangeValue;
                },
              );
            }
            return SizedBox.shrink();
          }),
        ),
        SizedBox(height: 10),
        SelectChips(
          items: ExpenseIncome.values,
          getLabel: (ExpenseIncome item) {
            return item == ExpenseIncome.expense
                ? "expense".tr()
                : item == ExpenseIncome.income
                    ? "income".tr()
                    : "";
          },
          getCustomBorderColor: (ExpenseIncome item) {
            Color? customBorderColor;
            if (item == ExpenseIncome.expense) {
              customBorderColor = getColor(context, "expenseAmount");
            } else if (item == ExpenseIncome.income) {
              customBorderColor = getColor(context, "incomeAmount");
            }
            if (customBorderColor == null) return null;
            return dynamicPastel(
              context,
              lightenPastel(customBorderColor, amount: 0.3),
              amount: 0.4,
            );
          },
          onSelected: (ExpenseIncome item) {
            if (selectedFilters.expenseIncome.contains(item)) {
              selectedFilters.expenseIncome.remove(item);
            } else {
              selectedFilters.expenseIncome.add(item);
            }
            setSearchFilters();
          },
          getSelected: (ExpenseIncome item) {
            return selectedFilters.expenseIncome.contains(item);
          },
        ),
        SelectChips(
          items: [null, ...TransactionSpecialType.values],
          getLabel: (TransactionSpecialType? item) {
            return transactionTypeDisplayToEnum[item]
                    ?.toString()
                    .toLowerCase()
                    .tr() ??
                "";
          },
          getCustomBorderColor: (TransactionSpecialType? item) {
            Color? customBorderColor;
            if (item == TransactionSpecialType.credit) {
              customBorderColor = getColor(context, "unPaidUpcoming");
            } else if (item == TransactionSpecialType.debt) {
              customBorderColor = getColor(context, "unPaidOverdue");
            }
            if (customBorderColor == null) return null;
            return dynamicPastel(
              context,
              lightenPastel(customBorderColor, amount: 0.3),
              amount: 0.4,
            );
          },
          onSelected: (TransactionSpecialType? item) {
            if (selectedFilters.transactionTypes.contains(item)) {
              selectedFilters.transactionTypes.remove(item);
            } else {
              selectedFilters.transactionTypes.add(item);
            }
            setSearchFilters();
          },
          getSelected: (TransactionSpecialType? item) {
            return selectedFilters.transactionTypes.contains(item);
          },
        ),
        SelectChips(
          items: PaidStatus.values,
          getLabel: (PaidStatus item) {
            return item == PaidStatus.paid
                ? "paid".tr()
                : item == PaidStatus.notPaid
                    ? "not-paid".tr()
                    : item == PaidStatus.skipped
                        ? "skipped".tr()
                        : "";
          },
          onSelected: (PaidStatus item) {
            if (selectedFilters.paidStatus.contains(item)) {
              selectedFilters.paidStatus.remove(item);
            } else {
              selectedFilters.paidStatus.add(item);
            }
            setSearchFilters();
          },
          getSelected: (PaidStatus item) {
            return selectedFilters.paidStatus.contains(item);
          },
        ),
        StreamBuilder<List<TransactionWallet>>(
          stream: database.watchAllWallets(),
          builder: (context, snapshot) {
            if (snapshot.data != null && snapshot.data!.length <= 1)
              return SizedBox.shrink();
            if (snapshot.hasData) {
              return SelectChips(
                items: snapshot.data!,
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
                getLabel: (TransactionWallet item) {
                  return item.name;
                },
                onSelected: (TransactionWallet item) {
                  if (selectedFilters.walletPks.contains(item.walletPk)) {
                    selectedFilters.walletPks.remove(item.walletPk);
                  } else {
                    selectedFilters.walletPks.add(item.walletPk);
                  }
                  setSearchFilters();
                },
                getSelected: (TransactionWallet item) {
                  return selectedFilters.walletPks.contains(item.walletPk);
                },
                getCustomBorderColor: (TransactionWallet item) {
                  return dynamicPastel(
                    context,
                    lightenPastel(
                      HexColor(
                        item.colour,
                        defaultColor: Theme.of(context).colorScheme.primary,
                      ),
                      amount: 0.3,
                    ),
                    amount: 0.4,
                  );
                },
              );
            } else {
              return SizedBox.shrink();
            }
          },
        ),
        StreamBuilder<List<Budget>>(
          stream: database.watchAllAddableBudgets(),
          builder: (context, snapshot) {
            if (snapshot.data != null && snapshot.data!.length <= 0)
              return SizedBox.shrink();
            if (snapshot.hasData) {
              return Column(
                children: [
                  // SelectChips(
                  //   items: <BudgetTransactionFilters>[
                  //     BudgetTransactionFilters.addedToOtherBudget,
                  //     ...(appStateSettings["sharedBudgets"]
                  //         ? [BudgetTransactionFilters.sharedToOtherBudget]
                  //         : []),
                  //   ],
                  //   getLabel: (BudgetTransactionFilters item) {
                  //     return item == BudgetTransactionFilters.addedToOtherBudget
                  //         ? "added-to-other-budgets".tr()
                  //         : item == BudgetTransactionFilters.sharedToOtherBudget
                  //             ? "shared-to-other-budgets".tr()
                  //             : "";
                  //   },
                  //   onSelected: (BudgetTransactionFilters item) {
                  //     if (selectedFilters.budgetTransactionFilters
                  //         .contains(item)) {
                  //       selectedFilters.budgetTransactionFilters.remove(item);
                  //     } else {
                  //       selectedFilters.budgetTransactionFilters.add(item);
                  //     }
                  //     setSearchFilters();
                  //   },
                  //   getSelected: (BudgetTransactionFilters item) {
                  //     return selectedFilters.budgetTransactionFilters
                  //         .contains(item);
                  //   },
                  // ),
                  SelectChips(
                    items: [null, ...snapshot.data!],
                    onLongPress: (Budget? item) {
                      pushRoute(
                        context,
                        AddBudgetPage(
                          budget: item,
                          routesToPopAfterDelete:
                              RoutesToPopAfterDelete.PreventDelete,
                        ),
                      );
                    },
                    getLabel: (Budget? item) {
                      if (item == null) return "no-budget".tr();
                      return item.name;
                    },
                    onSelected: (Budget? item) {
                      if (selectedFilters.budgetPks.contains(item?.budgetPk)) {
                        selectedFilters.budgetPks.remove(item?.budgetPk);
                      } else {
                        selectedFilters.budgetPks.add(item?.budgetPk);
                      }
                      setSearchFilters();
                    },
                    getSelected: (Budget? item) {
                      return selectedFilters.budgetPks.contains(item?.budgetPk);
                    },
                    getCustomBorderColor: (Budget? item) {
                      if (item == null) return null;
                      return dynamicPastel(
                        context,
                        lightenPastel(
                          HexColor(
                            item.colour,
                            defaultColor: Theme.of(context).colorScheme.primary,
                          ),
                          amount: 0.3,
                        ),
                        amount: 0.4,
                      );
                    },
                  ),
                ],
              );
            } else {
              return SizedBox.shrink();
            }
          },
        ),
        StreamBuilder<List<Budget>>(
          stream: database.watchAllExcludedTransactionsBudgetsInUse(),
          builder: (context, snapshot) {
            if (snapshot.data != null && snapshot.data!.length <= 0)
              return SizedBox.shrink();
            if (snapshot.hasData) {
              return Column(
                children: [
                  SelectChips(
                    items: snapshot.data!,
                    onLongPress: (Budget? item) {
                      pushRoute(
                        context,
                        AddBudgetPage(
                          budget: item,
                          routesToPopAfterDelete:
                              RoutesToPopAfterDelete.PreventDelete,
                        ),
                      );
                    },
                    getLabel: (Budget item) {
                      return "excluded-from".tr() + " " + item.name;
                    },
                    onSelected: (Budget item) {
                      if (selectedFilters.excludedBudgetPks
                          .contains(item.budgetPk)) {
                        selectedFilters.excludedBudgetPks.remove(item.budgetPk);
                      } else {
                        selectedFilters.excludedBudgetPks.add(item.budgetPk);
                      }
                      setSearchFilters();
                    },
                    getSelected: (Budget item) {
                      return selectedFilters.excludedBudgetPks
                          .contains(item.budgetPk);
                    },
                    getCustomBorderColor: (Budget? item) {
                      if (item == null) return null;
                      return dynamicPastel(
                        context,
                        lightenPastel(
                          HexColor(
                            item.colour,
                            defaultColor: Theme.of(context).colorScheme.primary,
                          ),
                          amount: 0.3,
                        ),
                        amount: 0.4,
                      );
                    },
                  ),
                ],
              );
            } else {
              return SizedBox.shrink();
            }
          },
        ),

        StreamBuilder<List<Objective>>(
          stream: database.watchAllObjectives(
              objectiveType: ObjectiveType.goal, archivedLast: true),
          builder: (context, snapshot) {
            if (snapshot.data != null && snapshot.data!.length <= 0)
              return SizedBox.shrink();
            if (snapshot.hasData) {
              return SelectChips(
                items: [null, ...snapshot.data!],
                onLongPress: (Objective? item) {
                  pushRoute(
                    context,
                    AddObjectivePage(
                      objective: item,
                      routesToPopAfterDelete:
                          RoutesToPopAfterDelete.PreventDelete,
                    ),
                  );
                },
                getLabel: (Objective? item) {
                  if (item == null) return "no-goal".tr();
                  return item.name;
                },
                onSelected: (Objective? item) {
                  if (selectedFilters.objectivePks
                      .contains(item?.objectivePk)) {
                    selectedFilters.objectivePks.remove(item?.objectivePk);
                  } else {
                    selectedFilters.objectivePks.add(item?.objectivePk);
                  }
                  setSearchFilters();
                },
                getSelected: (Objective? item) {
                  return selectedFilters.objectivePks
                      .contains(item?.objectivePk);
                },
                getCustomBorderColor: (Objective? item) {
                  if (item == null) return null;
                  return dynamicPastel(
                    context,
                    lightenPastel(
                      HexColor(
                        item.colour,
                        defaultColor: Theme.of(context).colorScheme.primary,
                      ),
                      amount: 0.3,
                    ),
                    amount: 0.4,
                  );
                },
              );
            } else {
              return SizedBox.shrink();
            }
          },
        ),

        StreamBuilder<List<Objective>>(
          stream: database.watchAllObjectives(
              objectiveType: ObjectiveType.loan, archivedLast: true),
          builder: (context, snapshot) {
            if (snapshot.data != null && snapshot.data!.length <= 0)
              return SizedBox.shrink();
            if (snapshot.hasData) {
              return SelectChips(
                items: [null, ...snapshot.data!],
                onLongPress: (Objective? item) {
                  pushRoute(
                    context,
                    AddObjectivePage(
                      objective: item,
                      routesToPopAfterDelete:
                          RoutesToPopAfterDelete.PreventDelete,
                    ),
                  );
                },
                getLabel: (Objective? item) {
                  if (item == null) return "no-loan".tr();
                  return item.name;
                },
                onSelected: (Objective? item) {
                  if (selectedFilters.objectiveLoanPks
                      .contains(item?.objectivePk)) {
                    selectedFilters.objectiveLoanPks.remove(item?.objectivePk);
                  } else {
                    selectedFilters.objectiveLoanPks.add(item?.objectivePk);
                  }
                  setSearchFilters();
                },
                getSelected: (Objective? item) {
                  return selectedFilters.objectiveLoanPks
                      .contains(item?.objectivePk);
                },
                getCustomBorderColor: (Objective? item) {
                  if (item == null) return null;
                  return dynamicPastel(
                    context,
                    lightenPastel(
                      HexColor(
                        item.colour,
                        defaultColor: Theme.of(context).colorScheme.primary,
                      ),
                      amount: 0.3,
                    ),
                    amount: 0.4,
                  );
                },
              );
            } else {
              return SizedBox.shrink();
            }
          },
        ),
        // SelectChips(
        //   items: MethodAdded.values,
        //   getLabel: (item) {
        //     return item == MethodAdded.csv
        //         ? "CSV"
        //         : item == MethodAdded.shared
        //             ? "Shared"
        //             : item == MethodAdded.email
        //                 ? "Email"
        //                 : "";
        //   },
        //   onSelected: (item) {
        //     if (selectedFilters.methodAdded.contains(item)) {
        //       selectedFilters.methodAdded.remove(item);
        //     } else {
        //       selectedFilters.methodAdded.add(item);
        //     }
        //     setSearchFilters();
        //   },
        //   getSelected: (item) {
        //     return selectedFilters.methodAdded.contains(item);
        //   },
        // ),

        SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              TitleInput(
                maxLines: 5,
                resizePopupWhenChanged: false,
                titleInputController: titleContainsController,
                titleInputScrollController: titleContainsScrollController,
                padding: EdgeInsets.zero,
                setSelectedCategory: (_) {},
                setSelectedSubCategory: (_) {},
                alsoSearchCategories: false,
                setSelectedTitle: (String value) {
                  if (value.trim() == "") {
                    selectedFilters.titleContains = null;
                  } else {
                    selectedFilters.titleContains = value.trim();
                  }
                },
                showCategoryIconForRecommendedTitles: false,
                unfocusWhenRecommendedTapped: false,
                onNewRecommendedTitle: () {},
                onRecommendedTitleTapped:
                    (TransactionAssociatedTitleWithCategory title) async {
                  List<String> splitTitles = titleContainsController.text
                      .trim()
                      .replaceAll(", ", ",")
                      .split(",");
                  if (splitTitles.length <= 0) return;
                  splitTitles.last = title.title.title;
                  titleContainsController.text = splitTitles.join(", ") + ", ";

                  if (titleContainsController.text == "") {
                    selectedFilters.titleContains = null;
                  } else {
                    selectedFilters.titleContains =
                        titleContainsController.text.trim();
                  }

                  // Scroll to the end of the text input
                  titleContainsController.selection =
                      TextSelection.fromPosition(
                    TextPosition(offset: titleContainsController.text.length),
                  );
                  Future.delayed(Duration(milliseconds: 50), () {
                    // delay cannot be zero
                    titleContainsScrollController.animateTo(
                      titleContainsScrollController.position.maxScrollExtent,
                      curve: Curves.easeInOutCubicEmphasized,
                      duration: Duration(milliseconds: 500),
                    );
                  });
                },
                textToSearchFilter: (String text) {
                  return (text.split(",").lastOrNull ?? "").trim();
                },
                getTextToExclude: (String text) {
                  text = text.trim().replaceAll(", ", ",");
                  return (text.split(","));
                },
                handleOnRecommendedTitleTapped: false,
                onSubmitted: (_) {},
                autoFocus: false,
                labelText: "title-contains".tr() + "...",
              ),
              SizedBox(height: 7),
              TextInput(
                maxLines: 5,
                padding: EdgeInsets.zero,
                labelText: "notes-contain".tr() + "...",
                onChanged: (value) {
                  if (value.trim() == "") {
                    selectedFilters.noteContains = null;
                  } else {
                    selectedFilters.noteContains = value.trim();
                  }
                },
                initialValue: selectedFilters.noteContains,
                icon: appStateSettings["outlinedIcons"]
                    ? Icons.sticky_note_2_outlined
                    : Icons.sticky_note_2_rounded,
              )
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Flexible(
                child: Button(
                  expandedLayout: true,
                  label: "reset".tr(),
                  onTap: () {
                    widget.clearSearchFilters();
                    Navigator.pop(context);
                  },
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  textColor: Theme.of(context).colorScheme.onTertiaryContainer,
                ),
              ),
              SizedBox(width: 13),
              Flexible(
                child: Button(
                  expandedLayout: true,
                  label: "apply".tr(),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class AppliedFilterChips extends StatelessWidget {
  const AppliedFilterChips({
    required this.searchFilters,
    required this.openFiltersSelection,
    required this.clearSearchFilters,
    this.openSelectDate,
    this.padding = const EdgeInsets.only(bottom: 8.0),
    super.key,
  });
  final SearchFilters searchFilters;
  final Function openFiltersSelection;
  final Function clearSearchFilters;
  final Function? openSelectDate;
  final EdgeInsets padding;

  Future<List<Widget>> getSearchFilterWidgets(BuildContext context) async {
    AllWallets allWallets = Provider.of<AllWallets>(context);
    List<Widget> out = [];
    // Title contains
    if (searchFilters.titleContains != null) {
      out.add(AppliedFilterChip(
        label:
            "title-contains".tr() + ": " + (searchFilters.titleContains ?? ""),
        openFiltersSelection: openFiltersSelection,
      ));
    }
    // Notes contains
    if (searchFilters.noteContains != null) {
      out.add(AppliedFilterChip(
        label: "notes-contain".tr() + ": " + (searchFilters.noteContains ?? ""),
        openFiltersSelection: openFiltersSelection,
      ));
    }
    // Categories
    for (TransactionCategory category in await database.getAllCategories(
        categoryFks: searchFilters.categoryPks, allCategories: false)) {
      out.add(AppliedFilterChip(
        label: category.name,
        customBorderColor: HexColor(
          category.colour,
          defaultColor: Theme.of(context).colorScheme.primary,
        ),
        openFiltersSelection: openFiltersSelection,
      ));
    }
    for (TransactionCategory category in await database.getAllCategories(
        categoryFks: searchFilters.subcategoryPks,
        allCategories: false,
        includeSubCategories: true)) {
      out.add(AppliedFilterChip(
        label: category.name,
        customBorderColor: HexColor(
          category.colour,
          defaultColor: Theme.of(context).colorScheme.primary,
        ),
        openFiltersSelection: openFiltersSelection,
      ));
    }
    if (searchFilters.subcategoryPks == null) {
      out.add(AppliedFilterChip(
        label: "no-subcategory".tr(),
        openFiltersSelection: openFiltersSelection,
      ));
    }
    // Amount range
    if (searchFilters.amountRange != null) {
      out.add(
        AppliedFilterChip(
          label: convertToMoney(allWallets, searchFilters.amountRange!.start) +
              " – " +
              convertToMoney(
                allWallets,
                searchFilters.amountRange!.end,
              ),
          openFiltersSelection: openFiltersSelection,
        ),
      );
    }
    // Expense Income
    if (searchFilters.expenseIncome.contains(ExpenseIncome.expense)) {
      out.add(AppliedFilterChip(
        label: "expense".tr(),
        customBorderColor: getColor(context, "expenseAmount"),
        openFiltersSelection: openFiltersSelection,
      ));
    }
    if (searchFilters.expenseIncome.contains(ExpenseIncome.income)) {
      out.add(AppliedFilterChip(
        label: "income".tr(),
        customBorderColor: getColor(context, "incomeAmount"),
        openFiltersSelection: openFiltersSelection,
      ));
    }
    // Cash Flow
    if (searchFilters.positiveCashFlow == false) {
      out.add(AppliedFilterChip(
        label: "outgoing".tr(),
        customBorderColor: getColor(context, "expenseAmount"),
        openFiltersSelection: openFiltersSelection,
      ));
    } else if (searchFilters.positiveCashFlow == true) {
      out.add(AppliedFilterChip(
        label: "incoming".tr(),
        customBorderColor: getColor(context, "incomeAmount"),
        openFiltersSelection: openFiltersSelection,
      ));
    }
    // Transaction Types
    for (TransactionSpecialType? transactionType
        in searchFilters.transactionTypes) {
      Color? customBorderColor;
      if (transactionType == TransactionSpecialType.credit) {
        customBorderColor = getColor(context, "unPaidUpcoming");
      } else if (transactionType == TransactionSpecialType.debt) {
        customBorderColor = getColor(context, "unPaidOverdue");
      }
      out.add(AppliedFilterChip(
        label: transactionTypeDisplayToEnum[transactionType]
                ?.toString()
                .toLowerCase()
                .tr() ??
            "default".tr(),
        customBorderColor: customBorderColor,
        openFiltersSelection: openFiltersSelection,
      ));
    }
    // Paid status
    if (searchFilters.paidStatus.contains(PaidStatus.paid)) {
      out.add(AppliedFilterChip(
        label: "paid".tr(),
        openFiltersSelection: openFiltersSelection,
      ));
    }
    if (searchFilters.paidStatus.contains(PaidStatus.notPaid)) {
      out.add(AppliedFilterChip(
        label: "not-paid".tr(),
        openFiltersSelection: openFiltersSelection,
      ));
    }
    if (searchFilters.paidStatus.contains(PaidStatus.skipped)) {
      out.add(AppliedFilterChip(
        label: "skipped".tr(),
        openFiltersSelection: openFiltersSelection,
      ));
    }
    // Budget Transaction Filters
    if (searchFilters.budgetTransactionFilters
        .contains(BudgetTransactionFilters.sharedToOtherBudget)) {
      out.add(AppliedFilterChip(
        label: "added-to-other-budgets".tr(),
        openFiltersSelection: openFiltersSelection,
      ));
    }
    if (searchFilters.budgetTransactionFilters
        .contains(BudgetTransactionFilters.addedToOtherBudget)) {
      out.add(AppliedFilterChip(
        label: "added-to-other-budgets".tr(),
        openFiltersSelection: openFiltersSelection,
      ));
    }
    // Wallets
    for (String walletPk in searchFilters.walletPks) {
      out.add(AppliedFilterChip(
        label: allWallets.indexedByPk[walletPk]?.name ?? "",
        customBorderColor: HexColor(
          allWallets.indexedByPk[walletPk]?.colour,
          defaultColor: Theme.of(context).colorScheme.primary,
        ),
        openFiltersSelection: openFiltersSelection,
      ));
    }
    // Budgets
    for (Budget budget in await database.getAllBudgets()) {
      if (searchFilters.budgetPks.contains(budget.budgetPk))
        out.add(AppliedFilterChip(
          label: budget.name,
          customBorderColor: HexColor(
            budget.colour,
            defaultColor: Theme.of(context).colorScheme.primary,
          ),
          openFiltersSelection: openFiltersSelection,
        ));
    }
    // Excluded Budgets
    for (Budget budget in await database.getAllBudgets()) {
      if (searchFilters.excludedBudgetPks.contains(budget.budgetPk))
        out.add(AppliedFilterChip(
          label: "excluded-from".tr() + ": " + budget.name,
          customBorderColor: HexColor(
            budget.colour,
            defaultColor: Theme.of(context).colorScheme.primary,
          ),
          openFiltersSelection: openFiltersSelection,
        ));
    }
    if (searchFilters.budgetPks.contains(null)) {
      out.add(AppliedFilterChip(
        label: "no-budget".tr(),
        openFiltersSelection: openFiltersSelection,
      ));
    }
    // Objectives
    for (Objective objective
        in await database.getAllObjectives(objectiveType: ObjectiveType.goal)) {
      if (searchFilters.objectivePks.contains(objective.objectivePk))
        out.add(AppliedFilterChip(
          label: objective.name,
          customBorderColor: HexColor(
            objective.colour,
            defaultColor: Theme.of(context).colorScheme.primary,
          ),
          openFiltersSelection: openFiltersSelection,
        ));
    }
    if (searchFilters.objectivePks.contains(null)) {
      out.add(AppliedFilterChip(
        label: "no-goal".tr(),
        openFiltersSelection: openFiltersSelection,
      ));
    }
    // Loan Objectives
    for (Objective objective
        in await database.getAllObjectives(objectiveType: ObjectiveType.loan)) {
      if (searchFilters.objectiveLoanPks.contains(objective.objectivePk))
        out.add(AppliedFilterChip(
          label: objective.name,
          customBorderColor: HexColor(
            objective.colour,
            defaultColor: Theme.of(context).colorScheme.primary,
          ),
          openFiltersSelection: openFiltersSelection,
        ));
    }
    if (searchFilters.objectiveLoanPks.contains(null)) {
      out.add(AppliedFilterChip(
        label: "no-loan".tr(),
        openFiltersSelection: openFiltersSelection,
      ));
    }
    // Date and time range
    if (out.length > 0 &&
        openSelectDate != null &&
        searchFilters.dateTimeRange != null) {
      out.add(AppliedFilterChip(
        label: getWordedDateShortMore(
              searchFilters.dateTimeRange!.start,
              includeYear:
                  searchFilters.dateTimeRange!.start != DateTime.now().year,
            ) +
            " – " +
            getWordedDateShortMore(
              searchFilters.dateTimeRange!.end,
              includeYear:
                  searchFilters.dateTimeRange!.end != DateTime.now().year,
            ),
        openFiltersSelection: () => {openSelectDate!()},
      ));
    }

    return out;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        openFiltersSelection();
      },
      child: FutureBuilder(
        future: getSearchFilterWidgets(context),
        builder: (context, AsyncSnapshot<List<Widget>> snapshot) {
          return AnimatedSize(
            curve: Curves.easeInOutCubicEmphasized,
            duration: Duration(milliseconds: 1000),
            child: snapshot.hasData &&
                    snapshot.data != null &&
                    snapshot.data!.length > 0
                ? Padding(
                    padding: padding,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      child: AnimatedSizeSwitcher(
                        clipBehavior: Clip.none,
                        child: Row(
                          key: ValueKey(snapshot.data.toString()),
                          children: [
                            SizedBox(width: 5),
                            IconButtonScaled(
                              iconData: Icons.close_rounded,
                              iconSize: 14,
                              scale: 1.5,
                              onTap: () {
                                clearSearchFilters();
                              },
                            ),
                            SizedBox(width: 2),
                            ...(snapshot.data ?? [])
                          ],
                        ),
                      ),
                    ),
                  )
                : SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
