import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/pages/addObjectivePage.dart';
import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/pages/editObjectivesPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/budgetContainer.dart';
import 'package:budget/widgets/categoryIcon.dart';
import 'package:budget/widgets/editRowEntry.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/noResults.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/util/widgetSize.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart'
    hide SliverReorderableList, ReorderableDelayedDragStartListener;
import 'package:provider/provider.dart';

class ObjectivesListPage extends StatefulWidget {
  const ObjectivesListPage({Key? key}) : super(key: key);

  @override
  State<ObjectivesListPage> createState() => ObjectivesListPageState();
}

class ObjectivesListPageState extends State<ObjectivesListPage> {
  @override
  Widget build(BuildContext context) {
    return PageFramework(
      title: "objectives".tr(),
      backButton: false,
      horizontalPadding: enableDoubleColumn(context) == false
          ? getHorizontalPaddingConstrained(context)
          : 0,
      actions: [
        IconButton(
          padding: EdgeInsets.all(15),
          tooltip: "edit-objectives".tr(),
          onPressed: () {
            pushRoute(
              context,
              EditObjectivesPage(),
            );
          },
          icon: Icon(
            appStateSettings["outlinedIcons"]
                ? Icons.edit_outlined
                : Icons.edit_rounded,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
      ],
      slivers: [
        StreamBuilder<List<Objective>>(
          stream: database.watchAllObjectives(),
          builder: (context, snapshot) {
            if (snapshot.hasData && (snapshot.data ?? []).length <= 0) {
              return SliverPadding(
                padding: EdgeInsets.symmetric(vertical: 7, horizontal: 13),
                sliver: SliverToBoxAdapter(
                  child: AddButton(
                    onTap: () {},
                    openPage: AddObjectivePage(
                      routesToPopAfterDelete:
                          RoutesToPopAfterDelete.PreventDelete,
                    ),
                    height: 150,
                  ),
                ),
              );
            }
            if (snapshot.hasData) {
              return SliverPadding(
                padding: EdgeInsets.symmetric(vertical: 7, horizontal: 13),
                sliver: enableDoubleColumn(context)
                    ? SliverGrid(
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 600.0,
                          mainAxisExtent: 200,
                          mainAxisSpacing: 10.0,
                          crossAxisSpacing: 10.0,
                          childAspectRatio: 5,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            if (index == snapshot.data?.length) {
                              return AddButton(
                                onTap: () {},
                                openPage: AddObjectivePage(
                                  routesToPopAfterDelete:
                                      RoutesToPopAfterDelete.PreventDelete,
                                ),
                              );
                            } else {
                              return ObjectiveContainer(
                                objective: snapshot.data![index],
                              );
                            }
                          },
                          childCount: (snapshot.data?.length ?? 0) + 1,
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            if (index == snapshot.data?.length) {
                              return AddButton(
                                onTap: () {},
                                openPage: AddObjectivePage(
                                  routesToPopAfterDelete:
                                      RoutesToPopAfterDelete.PreventDelete,
                                ),
                                height: 150,
                              );
                            } else {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: ObjectiveContainer(
                                  objective: snapshot.data![index],
                                ),
                              );
                            }
                          },
                          childCount: (snapshot.data?.length ?? 0) +
                              1, //snapshot.data?.length
                        ),
                      ),
              );
            } else {
              return SliverToBoxAdapter();
            }
          },
        ),
        SliverToBoxAdapter(
          child: SizedBox(height: 50),
        ),
      ],
    );
  }
}

class ObjectiveContainer extends StatelessWidget {
  const ObjectiveContainer({required this.objective, super.key});
  final Objective objective;

  @override
  Widget build(BuildContext context) {
    return OpenContainerNavigation(
      openPage: Container(),
      borderRadius: 15,
      closedColor: getStandardContainerColor(context),
      button: (openContainer()) {
        return Tappable(
          color: getStandardContainerColor(context),
          onTap: () {
            openContainer();
          },
          child: Padding(
            padding:
                const EdgeInsets.only(left: 30, right: 20, top: 18, bottom: 21),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFont(
                            text: objective.name,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          TextFont(
                            text: "15 transactions",
                            fontSize: 15,
                            textColor: getColor(context, "textLight"),
                          ),
                        ],
                      ),
                    ),
                    CategoryIcon(
                      categoryPk: "-1",
                      category: TransactionCategory(
                        categoryPk: "-1",
                        name: "",
                        dateCreated: DateTime.now(),
                        dateTimeModified: null,
                        order: 0,
                        income: false,
                        iconName: objective.iconName,
                        colour: objective.colour,
                        emojiIconName: objective.emojiIconName,
                      ),
                      size: 30,
                      sizePadding: 20,
                      borderRadius: 100,
                      canEditByLongPress: false,
                      margin: EdgeInsets.zero,
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextFont(
                      fontWeight: FontWeight.bold,
                      text:
                          convertToMoney(Provider.of<AllWallets>(context), 50),
                      fontSize: 24,
                      textColor: getColor(context, "black"),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 1),
                      child: TextFont(
                        text: " / " +
                            convertToMoney(
                                Provider.of<AllWallets>(context), 100),
                        fontSize: 15,
                        textColor: getColor(context, "black").withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                BudgetProgress(
                  color: HexColor(objective.colour),
                  percent: 50,
                  todayPercent: -1,
                  showToday: false,
                  yourPercent: 0,
                  padding: EdgeInsets.zero,
                  enableShake: false,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
