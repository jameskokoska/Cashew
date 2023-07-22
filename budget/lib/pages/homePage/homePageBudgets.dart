import 'package:budget/database/tables.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/pages/budgetPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/keepAliveClientMixin.dart';
import 'package:budget/widgets/budgetContainer.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class HomePageBudgets extends StatefulWidget {
  const HomePageBudgets({super.key});

  @override
  State<HomePageBudgets> createState() => _HomePageBudgetsState();
}

class _HomePageBudgetsState extends State<HomePageBudgets> {
  double height = 0;

  @override
  Widget build(BuildContext context) {
    if (appStateSettings["showPinnedBudgets"] == false &&
        enableDoubleColumn(context) == false) return SizedBox.shrink();
    return KeepAliveClientMixin(
      child: StreamBuilder<List<Budget>>(
        stream: database.getAllPinnedBudgets().$1,
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
                      openPage: AddBudgetPage(),
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
                  onTap: () {},
                  height: null,
                  width: null,
                  padding: EdgeInsets.all(0),
                  openPage: AddBudgetPage(),
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
                      child: BudgetContainer(
                        budget: snapshot.data![0],
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
