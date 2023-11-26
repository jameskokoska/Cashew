import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/pages/addObjectivePage.dart';
import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/pages/editHomePage.dart';
import 'package:budget/pages/editObjectivesPage.dart';
import 'package:budget/pages/objectivesListPage.dart';
import 'package:budget/pages/transactionsSearchPage.dart';
import 'package:budget/pages/walletDetailsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/util/keepAliveClientMixin.dart';
import 'package:budget/widgets/linearGradientFadedEdges.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/selectItems.dart';
import 'package:budget/widgets/transactionsAmountBox.dart';
import 'package:budget/widgets/util/rightSideClipper.dart';
import 'package:budget/widgets/util/widgetSize.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePageObjectives extends StatefulWidget {
  const HomePageObjectives({super.key});

  @override
  State<HomePageObjectives> createState() => _HomePageObjectivesState();
}

class _HomePageObjectivesState extends State<HomePageObjectives> {
  double height = 0;
  @override
  Widget build(BuildContext context) {
    Widget child = KeepAliveClientMixin(
      child: StreamBuilder<List<Objective>>(
        stream: database.getAllPinnedObjectives().$1,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.length == 0) {
              return AddButton(
                onTap: () {
                  openBottomSheet(
                    context,
                    EditHomePagePinnedGoalsPopup(
                        showGoalsTotalLabelSetting: false),
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
            List<Widget> objectiveItems = [
              ...(snapshot.data?.map((Objective objective) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: ObjectiveContainer(
                        objective: objective,
                        index: 0,
                        forceAndroidBubbleDesign: true,
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
                      EditHomePagePinnedGoalsPopup(
                          showGoalsTotalLabelSetting: false),
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
                        child: ObjectiveContainer(
                          objective: snapshot.data![0],
                          index: 0,
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
                              for (Widget widget in objectiveItems)
                                Padding(
                                  padding: const EdgeInsets.only(right: 7),
                                  child: SizedBox(
                                    width: 400,
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
                            enlargeFactor: 0.3,
                          ),
                          items: objectiveItems,
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

    if (enableDoubleColumn(context)) {
      return LinearGradientFadedEdges(
        enableLeft: false,
        enableBottom: false,
        enableTop: false,
        child: ClipRRect(
          clipper: RightSideClipper(),
          child: child,
        ),
      );
    } else {
      return child;
    }
  }
}

class EditHomePagePinnedGoalsPopup extends StatelessWidget {
  const EditHomePagePinnedGoalsPopup(
      {super.key, required this.showGoalsTotalLabelSetting});
  final bool showGoalsTotalLabelSetting;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Objective>>(
        stream: database.watchAllObjectives(),
        builder: (context, snapshot) {
          List<Objective> allObjectives = snapshot.data ?? [];
          return StreamBuilder<List<Objective>>(
              stream: database.getAllPinnedObjectives().$1,
              builder: (context, snapshot2) {
                List<Objective> allPinnedObjectives = snapshot2.data ?? [];
                return PopupFramework(
                  title: "select-goals".tr(),
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
                      pushRoute(context, EditObjectivesPage());
                    },
                  ),
                  child: Column(
                    children: [
                      if (showGoalsTotalLabelSetting)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: TotalSpentToggle(isForGoalTotal: true),
                        ),
                      if (allObjectives.length <= 0)
                        NoResultsCreate(
                          message: "no-goals-found".tr(),
                          buttonLabel: "create-goal".tr(),
                          route: AddObjectivePage(
                            routesToPopAfterDelete: RoutesToPopAfterDelete.None,
                          ),
                        ),
                      SelectItems(
                        syncWithInitial: true,
                        checkboxCustomIconSelected: Icons.push_pin_rounded,
                        checkboxCustomIconUnselected: Icons.push_pin_outlined,
                        items: [
                          for (Objective objective in allObjectives)
                            objective.objectivePk.toString()
                        ],
                        getColor: (objectivePk, selected) {
                          for (Objective objective in allObjectives)
                            if (objective.objectivePk.toString() ==
                                objectivePk.toString()) {
                              return HexColor(objective.colour,
                                      defaultColor:
                                          Theme.of(context).colorScheme.primary)
                                  .withOpacity(selected == true ? 0.7 : 0.5);
                            }
                          return null;
                        },
                        displayFilter: (objectivePk) {
                          for (Objective objective in allObjectives)
                            if (objective.objectivePk.toString() ==
                                objectivePk.toString()) {
                              return objective.name;
                            }
                          return "";
                        },
                        initialItems: [
                          for (Objective objective in allPinnedObjectives)
                            objective.objectivePk.toString()
                        ],
                        onChangedSingleItem: (value) async {
                          Objective objective = allObjectives[allObjectives
                              .indexWhere((item) => item.objectivePk == value)];
                          Objective objectiveToUpdate = await database
                              .getObjectiveInstance(objective.objectivePk);
                          await database.createOrUpdateObjective(
                            objectiveToUpdate.copyWith(
                                pinned: !objectiveToUpdate.pinned),
                          );
                        },
                        onLongPress: (String objectivePk) async {
                          Objective objective =
                              await database.getObjectiveInstance(objectivePk);
                          pushRoute(
                            context,
                            AddObjectivePage(
                              routesToPopAfterDelete:
                                  RoutesToPopAfterDelete.One,
                              objective: objective,
                            ),
                          );
                        },
                      ),
                      if (allObjectives.length > 0)
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
                          openPage: AddObjectivePage(
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
