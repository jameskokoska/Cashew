import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/pages/addObjectivePage.dart';
import 'package:budget/pages/objectivesListPage.dart';
import 'package:budget/pages/transactionsSearchPage.dart';
import 'package:budget/pages/walletDetailsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/keepAliveClientMixin.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/transactionsAmountBox.dart';
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
    return !appStateSettings["showObjectives"] &&
            enableDoubleColumn(context) == false
        ? SizedBox.shrink()
        : KeepAliveClientMixin(
            child: StreamBuilder<List<Objective>>(
              stream: database.getAllPinnedObjectives().$1,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.length == 0) {
                    return enableDoubleColumn(context) == true
                        ? SizedBox.shrink()
                        : AddButton(
                            onTap: () {},
                            height: 160,
                            width: null,
                            padding: const EdgeInsets.only(
                                left: 13, right: 13, bottom: 13),
                            openPage: AddObjectivePage(
                              routesToPopAfterDelete:
                                  RoutesToPopAfterDelete.None,
                            ),
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
                        onTap: () {},
                        height: null,
                        width: null,
                        padding: EdgeInsets.all(0),
                        openPage: AddObjectivePage(
                          routesToPopAfterDelete: RoutesToPopAfterDelete.None,
                        ),
                      ),
                    ),
                  ];
                  return Stack(
                    children: [
                      Visibility(
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
                                        padding:
                                            const EdgeInsets.only(right: 7),
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
                                  enlargeStrategy:
                                      CenterPageEnlargeStrategy.zoom,
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
  }
}
