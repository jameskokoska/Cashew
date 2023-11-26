import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/pages/addObjectivePage.dart';
import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/pages/editHomePage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/util/keepAliveClientMixin.dart';
import 'package:budget/widgets/budgetContainer.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/selectItems.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../widgets/util/widgetSize.dart';

class HomePageBudgets extends StatefulWidget {
  const HomePageBudgets({super.key});

  @override
  State<HomePageBudgets> createState() => _HomePageBudgetsState();
}

class _HomePageBudgetsState extends State<HomePageBudgets> {
  double height = 0;

  @override
  Widget build(BuildContext context) {
    return KeepAliveClientMixin(
      child: StreamBuilder<List<Budget>>(
        stream: database.getAllPinnedBudgets().$1,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.length == 0) {
              return AddButton(
                onTap: () {
                  openBottomSheet(
                    context,
                    EditHomePagePinnedBudgetsPopup(
                      showBudgetsTotalLabelSetting: false,
                    ),
                    useCustomController: true,
                  );
                },
                height: 160,
                width: null,
                padding: const EdgeInsets.only(left: 13, right: 13, bottom: 13),
                // icon: Icons.format_list_bulleted_add,
              );
            }
            // if (snapshot.data!.length == 1) {
            //   return Padding(
            //     padding: const EdgeInsets.only(
            //         left: 13, right: 13, bottom: 13),
            //     child: BudgetContainer(
            //       budget: snapshot.data![0],
            //     ),
            //   );
            // }
            List<Widget> budgetItems = [
              ...(snapshot.data?.map((Budget budget) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: BudgetContainer(
                        intermediatePadding: false,
                        budget: budget,
                      ),
                    );
                  }).toList() ??
                  []),
              Padding(
                padding: const EdgeInsets.only(left: 3, right: 3),
                child: AddButton(
                  onTap: () {
                    openBottomSheet(
                      context,
                      EditHomePagePinnedBudgetsPopup(
                        showBudgetsTotalLabelSetting: false,
                      ),
                      useCustomController: true,
                    );
                  },
                  height: null,
                  width: null,
                  padding: EdgeInsets.all(0),
                  // icon: Icons.format_list_bulleted_add,
                ),
              ),
            ];
            return Stack(
              children: [
                IgnorePointer(
                  child: Visibility(
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: Opacity(
                      opacity: 0,
                      child: WidgetSize(
                        onChange: (Size size) {
                          setState(() {
                            height = size.height;
                          });
                        },
                        child: BudgetContainer(
                          budget: snapshot.data![0],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 13),
                  child: getIsFullScreen(context)
                      ? SizedBox(
                          height: height,
                          child: ListView(
                            addAutomaticKeepAlives: true,
                            clipBehavior: Clip.none,
                            scrollDirection: Axis.horizontal,
                            children: [
                              for (Widget widget in budgetItems)
                                Padding(
                                  padding: const EdgeInsets.only(right: 7),
                                  child: SizedBox(
                                    width: 500,
                                    child: widget,
                                  ),
                                )
                            ],
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                          ),
                        )
                      : CarouselSlider(
                          options: CarouselOptions(
                            height: height,
                            enableInfiniteScroll: false,
                            enlargeCenterPage: true,
                            enlargeStrategy: CenterPageEnlargeStrategy.zoom,
                            viewportFraction: 0.95,
                            clipBehavior: Clip.none,
                            // onPageChanged: (index, reason) {
                            //   if (index == snapshot.data!.length) {
                            //     pushRoute(context,
                            //         AddBudgetPage());
                            //   }
                            // },
                            enlargeFactor: 0.3,
                          ),
                          items: budgetItems,
                        ),
                ),
              ],
            );
          } else {
            return SizedBox.shrink();
          }
        },
      ),
    );
  }
}

class EditHomePagePinnedBudgetsPopup extends StatelessWidget {
  const EditHomePagePinnedBudgetsPopup(
      {super.key, required this.showBudgetsTotalLabelSetting});
  final bool showBudgetsTotalLabelSetting;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Budget>>(
        stream: database.watchAllBudgets(),
        builder: (context, snapshot) {
          List<Budget> allBudgets = snapshot.data ?? [];
          return StreamBuilder<List<Budget>>(
              stream: database.getAllPinnedBudgets().$1,
              builder: (context, snapshot2) {
                List<Budget> allPinnedBudgets = snapshot2.data ?? [];
                return PopupFramework(
                  title: "select-budgets".tr(),
                  outsideExtraWidget: IconButton(
                    iconSize: 25,
                    padding: EdgeInsets.all(
                        getPlatform() == PlatformOS.isIOS ? 15 : 20),
                    icon: Icon(
                      appStateSettings["outlinedIcons"]
                          ? Icons.edit_outlined
                          : Icons.edit_rounded,
                    ),
                    onPressed: () async {
                      pushRoute(context, EditBudgetPage());
                    },
                  ),
                  child: Column(
                    children: [
                      if (showBudgetsTotalLabelSetting)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: TotalSpentToggle(),
                        ),
                      if (allBudgets.length <= 0)
                        NoResultsCreate(
                          message: "no-budgets-found".tr(),
                          buttonLabel: "create-budget".tr(),
                          route: AddBudgetPage(
                            routesToPopAfterDelete: RoutesToPopAfterDelete.None,
                          ),
                        ),
                      SelectItems(
                        syncWithInitial: true,
                        checkboxCustomIconSelected: Icons.push_pin_rounded,
                        checkboxCustomIconUnselected: Icons.push_pin_outlined,
                        items: [
                          for (Budget budget in allBudgets)
                            budget.budgetPk.toString()
                        ],
                        getColor: (budgetPk, selected) {
                          for (Budget budget in allBudgets)
                            if (budget.budgetPk.toString() ==
                                budgetPk.toString()) {
                              return HexColor(budget.colour,
                                      defaultColor:
                                          Theme.of(context).colorScheme.primary)
                                  .withOpacity(selected == true ? 0.7 : 0.5);
                            }
                          return null;
                        },
                        displayFilter: (budgetPk) {
                          for (Budget budget in allBudgets)
                            if (budget.budgetPk.toString() ==
                                budgetPk.toString()) {
                              return budget.name;
                            }
                          return "";
                        },
                        initialItems: [
                          for (Budget budget in allPinnedBudgets)
                            budget.budgetPk.toString()
                        ],
                        onChangedSingleItem: (value) async {
                          Budget budget = allBudgets[allBudgets
                              .indexWhere((item) => item.budgetPk == value)];
                          Budget budgetToUpdate =
                              await database.getBudgetInstance(budget.budgetPk);
                          await database.createOrUpdateBudget(
                            budgetToUpdate.copyWith(
                                pinned: !budgetToUpdate.pinned),
                            updateSharedEntry: false,
                          );
                        },
                        onLongPress: (String budgetPk) async {
                          Budget budget =
                              await database.getBudgetInstance(budgetPk);
                          pushRoute(
                            context,
                            AddBudgetPage(
                              routesToPopAfterDelete:
                                  RoutesToPopAfterDelete.One,
                              budget: budget,
                            ),
                          );
                        },
                      ),
                      if (allBudgets.length > 0)
                        AddButton(
                          onTap: () {},
                          height: 50,
                          width: null,
                          padding: const EdgeInsets.only(
                            left: 13,
                            right: 13,
                            bottom: 13,
                            top: 13,
                          ),
                          openPage: AddBudgetPage(
                            routesToPopAfterDelete: RoutesToPopAfterDelete.None,
                          ),
                          afterOpenPage: () {
                            Future.delayed(Duration(milliseconds: 100), () {
                              bottomSheetControllerGlobalCustomAssigned
                                  ?.snapToExtent(0);
                            });
                          },
                        ),
                    ],
                  ),
                );
              });
        });
  }
}
