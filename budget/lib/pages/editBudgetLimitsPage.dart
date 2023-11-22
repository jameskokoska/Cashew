import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/currencyFunctions.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/categoryLimits.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  void initState() {
    Future.delayed(Duration(milliseconds: 0), () async {
      await database.fixWanderingCategoryLimitsInBudget(
        allWallets: Provider.of<AllWallets>(context, listen: false),
        budgetPk: widget.budget.budgetPk,
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double budgetAmount = budgetAmountToPrimaryCurrency(
        Provider.of<AllWallets>(context, listen: true), widget.budget);

    return PageFramework(
      dragDownToDismiss: true,
      title: "spending-goals".tr(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: getHorizontalPaddingConstrained(context)),
            child: SettingsContainerDropdown(
              title: "spending-limit-type".tr(),
              icon: appStateSettings["outlinedIcons"]
                  ? Icons.confirmation_num_outlined
                  : Icons.confirmation_num_rounded,
              initial: selectedIsAbsoluteSpendingLimit.toString(),
              items: ["true", "false"],
              onChanged: (value) async {
                await database
                    .toggleAbsolutePercentSpendingCategoryBudgetLimits(
                  Provider.of<AllWallets>(context, listen: false),
                  widget.budget.budgetPk,
                  budgetAmount,
                  selectedIsAbsoluteSpendingLimit,
                );
                await database.createOrUpdateBudget(widget.budget.copyWith(
                    isAbsoluteSpendingLimit: !selectedIsAbsoluteSpendingLimit));
                setState(() {
                  selectedIsAbsoluteSpendingLimit =
                      !selectedIsAbsoluteSpendingLimit;
                });
              },
              getLabel: (item) {
                if (item == "true") return "amount".tr().capitalizeFirst;
                if (item == "false") return "percent".tr().capitalizeFirst;
              },
            ),
          ),
        ),
        CategoryLimits(
          isAbsoluteSpendingLimit: selectedIsAbsoluteSpendingLimit,
          categoryFks: widget.budget.categoryFks,
          categoryFksExclude: widget.budget.categoryFksExclude,
          budgetPk: widget.budget.budgetPk,
          budgetLimit: budgetAmount,
          showAddCategoryButton: (widget.budget.categoryFks == null ||
              widget.budget.categoryFks?.isEmpty == true),
        ),
      ],
    );
  }
}
