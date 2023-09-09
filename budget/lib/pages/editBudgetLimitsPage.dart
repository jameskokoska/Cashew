import 'package:budget/database/tables.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/categoryLimits.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class EditBudgetLimitsPage extends StatefulWidget {
  const EditBudgetLimitsPage(
      {required this.budget, this.currentIsAbsoluteSpendingLimit, Key? key})
      : super(key: key);
  final Budget budget;
  final bool? currentIsAbsoluteSpendingLimit;

  @override
  State<EditBudgetLimitsPage> createState() => _EditBudgetLimitsPageState();
}

class _EditBudgetLimitsPageState extends State<EditBudgetLimitsPage> {
  late bool selectedIsAbsoluteSpendingLimit =
      widget.currentIsAbsoluteSpendingLimit ??
          widget.budget.isAbsoluteSpendingLimit;

  @override
  Widget build(BuildContext context) {
    return PageFramework(
      dragDownToDismiss: true,
      title: "spending-goals".tr(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: getHorizontalPaddingConstrained(context)),
            child: SettingsContainerSwitch(
              onSwitched: (value) async {
                await database
                    .toggleAbsolutePercentSpendingCategoryBudgetLimits(
                  widget.budget.budgetPk,
                  widget.budget.amount,
                  selectedIsAbsoluteSpendingLimit,
                );
                await database.createOrUpdateBudget(widget.budget.copyWith(
                    isAbsoluteSpendingLimit: !selectedIsAbsoluteSpendingLimit));
                setState(() {
                  selectedIsAbsoluteSpendingLimit =
                      !selectedIsAbsoluteSpendingLimit;
                });
              },
              initialValue: selectedIsAbsoluteSpendingLimit,
              syncWithInitialValue: true,
              title: "absolute-spending-limits".tr(),
              description: "absolute-spending-limits-description".tr(),
              icon: appStateSettings["outlinedIcons"]
                  ? Icons.numbers_outlined
                  : Icons.numbers_rounded,
            ),
          ),
        ),
        CategoryLimits(
          isAbsoluteSpendingLimit: selectedIsAbsoluteSpendingLimit,
          selectedCategories: widget.budget.categoryFks ?? [],
          budgetPk: widget.budget.budgetPk,
          budgetLimit: widget.budget.amount,
          showAddCategoryButton: widget.budget.categoryFks == null ||
              widget.budget.categoryFks?.isEmpty == true,
        ),
      ],
    );
  }
}
