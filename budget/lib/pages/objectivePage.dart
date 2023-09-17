import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addObjectivePage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/editBudgetLimitsPage.dart';
import 'package:budget/pages/pastBudgetsPage.dart';
import 'package:budget/pages/premiumPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/dropdownSelect.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/selectedTransactionsActionBar.dart';
import 'package:budget/widgets/budgetContainer.dart';
import 'package:budget/widgets/categoryEntry.dart';
import 'package:budget/widgets/categoryLimits.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/lineGraph.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/pieChart.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntries.dart';
import 'package:budget/widgets/transactionEntry/transactionEntry.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';
import 'package:async/async.dart' show StreamZip;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:budget/widgets/countNumber.dart';
import 'package:budget/struct/currencyFunctions.dart';

import '../widgets/util/widgetSize.dart';

class ObjectivePage extends StatelessWidget {
  const ObjectivePage({
    super.key,
    required this.objectivePk,
  });
  final String objectivePk;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Objective>(
        stream: database.getObjective(objectivePk),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _ObjectivePageContent(
              objective: snapshot.data!,
            );
          }
          return SizedBox.shrink();
        });
    ;
  }
}

class _ObjectivePageContent extends StatefulWidget {
  const _ObjectivePageContent({
    Key? key,
    required this.objective,
  }) : super(key: key);

  final Objective objective;

  @override
  State<_ObjectivePageContent> createState() => _ObjectivePageContentState();
}

class _ObjectivePageContentState extends State<_ObjectivePageContent> {
  @override
  Widget build(BuildContext context) {
    ColorScheme objectiveColorScheme = ColorScheme.fromSeed(
      seedColor: HexColor(widget.objective.colour,
          defaultColor: Theme.of(context).colorScheme.primary),
      brightness: determineBrightnessTheme(context),
    );
    Color? pageBackgroundColor = appStateSettings["materialYou"]
        ? dynamicPastel(context, objectiveColorScheme.primary, amount: 0.92)
        : null;
    String pageId = widget.objective.objectivePk;
    return Stack(
      children: [
        PageFramework(
          belowAppBarPaddingWhenCenteredTitleSmall: 0,
          subtitleAlignment: Alignment.bottomLeft,
          subtitleSize: 10,
          backgroundColor: pageBackgroundColor,
          listID: pageId,
          floatingActionButton: AnimateFABDelayed(
            fab: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewPadding.bottom),
              child: FAB(
                tooltip: "add-transaction".tr(),
                openPage: AddTransactionPage(
                  selectedObjective: widget.objective,
                  routesToPopAfterDelete: RoutesToPopAfterDelete.One,
                ),
                color: objectiveColorScheme.secondary,
                colorPlus: objectiveColorScheme.onSecondary,
              ),
            ),
          ),
          actions: [
            CustomPopupMenuButton(
              showButtons: enableDoubleColumn(context),
              keepOutFirst: true,
              forceKeepOutFirst: true,
              items: [
                DropdownItemMenu(
                  id: "edit-objective",
                  label: "edit-objective".tr(),
                  icon: appStateSettings["outlinedIcons"]
                      ? Icons.edit_outlined
                      : Icons.edit_rounded,
                  action: () {
                    pushRoute(
                      context,
                      AddObjectivePage(
                        objective: widget.objective,
                        routesToPopAfterDelete: RoutesToPopAfterDelete.All,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
          title: widget.objective.name,
          appBarBackgroundColor: objectiveColorScheme.secondaryContainer,
          appBarBackgroundColorStart: objectiveColorScheme.secondaryContainer,
          textColor: getColor(context, "black"),
          dragDownToDismiss: true,
          slivers: [
            TransactionEntries(
              null,
              null,
              categoryFks: [],
              income: null,
              listID: pageId,
              dateDividerColor: pageBackgroundColor,
              transactionBackgroundColor: pageBackgroundColor,
              categoryTintColor: objectiveColorScheme.primary,
              colorScheme: objectiveColorScheme,
            ),
            // Wipe all remaining pixels off - sometimes graphics artifacts are left behind
            SliverToBoxAdapter(
              child: Container(height: 1, color: pageBackgroundColor),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 45))
          ],
        ),
        SelectedTransactionsActionBar(
          pageID: pageId,
        ),
      ],
    );
  }
}
