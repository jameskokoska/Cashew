import 'dart:developer';

import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/pages/transactionsSearchPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/budgetContainer.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/popupFramework.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:budget/main.dart';
import 'package:budget/colors.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'dart:math';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
// List<Widget> getTransactionsSlivers({
//   search = "",
//   List<int> categoryFks = const [],
//   DateTime? startDay,
//   DateTime? endDay,
// }) {
//   List<Widget> transactionsWidgets = [];

// database.getDatesOfTransaction(search: "").listen((data) {
//   data.forEach((DateTime? date) {
//     if (date != null) {
//       transactionsWidgets.insert(
//         0,
//         StreamBuilder<List<TransactionWithCategory>>(
//           stream: database.getTransactionCategoryWithDay(date,
//               search: search, categoryFks: categoryFks),
//           builder: (context, snapshot) {
//             if (snapshot.hasData && (snapshot.data ?? []).length > 0) {
//               double totalSpentForDay = 0;
//               snapshot.data!.forEach((transaction) {
//                 totalSpentForDay += transaction.transaction.amount;
//               });
//               return SliverStickyHeader(
//                 header: DateDivider(
//                     date: date,
//                     info: snapshot.data!.length > 1
//                         ? convertToMoney(totalSpentForDay)
//                         : ""),
//                 sticky: true,
//                 sliver: SliverList(
//                   delegate: SliverChildBuilderDelegate(
//                     (BuildContext context, int index) {
//                       return TransactionEntry(
//                         category: snapshot.data![index].category,
//                         openPage: AddTransactionPage(
//                           title: "Edit Transaction",
//                           transaction: snapshot.data![index].transaction,
//                         ),
//                         transaction: snapshot.data![index].transaction,
//                       );
//                     },
//                     childCount: snapshot.data?.length,
//                   ),
//                 ),
//               );
//             }
//             return SliverToBoxAdapter(child: SizedBox());
//           },
//         ),
//       );
//     }
//   });
// });
// List<Widget> transactionsWidgets = [];
// return [
//   StreamBuilder<List<Transaction>>(
//     stream: database.watchAllTransactions(),
//     builder: (context, snapshot) {
//       if (snapshot.hasData) {
//         List<Widget> transactionsWidgets = [];
//         if (snapshot.hasData && (snapshot.data ?? []).length > 0) {
//           for (int index = 0; index < snapshot.data!.length; index++) {
//             Transaction transaction = snapshot.data![index];
//             DateTime currentDay = DateTime(transaction.dateCreated.year,
//                 transaction.dateCreated.month, transaction.dateCreated.day);
//           }
//         }
//         return SliverToBoxAdapter(child: SizedBox());
//         snapshot.data!.forEach((Transaction transaction) {
//           {
//             double totalSpentForDay = 0;
//             snapshot.data!.forEach((transaction) {
//               totalSpentForDay += transaction.transaction.amount;
//             });
//           }
//         });
//       }
//       return SliverToBoxAdapter(child: SizedBox());
//     },
//   ),
// ];
// return [
//   StreamBuilder<List<DateTime?>>(
//     stream: database.getDatesOfTransaction(search: ""),
//     builder: (context, snapshot) {
//       if (snapshot.hasData) {
//         List<Widget> transactionsWidgets = [];
//         snapshot.data!.forEach((DateTime? date) {
//           if (date != null) {
//             transactionsWidgets.add(
//               StreamBuilder<List<TransactionWithCategory>>(
//                 stream: database.getTransactionCategoryWithDay(date,
//                     search: search, categoryFks: categoryFks),
//                 builder: (context, snapshot) {
//                   if (snapshot.hasData && (snapshot.data ?? []).length > 0) {
//                     double totalSpentForDay = 0;
//                     snapshot.data!.forEach((transaction) {
//                       totalSpentForDay += transaction.transaction.amount;
//                     });
//                     return SliverStickyHeader(
//                       header: DateDivider(
//                           date: date,
//                           info: snapshot.data!.length > 1
//                               ? convertToMoney(totalSpentForDay)
//                               : ""),
//                       sticky: true,
//                       sliver: SliverList(
//                         delegate: SliverChildBuilderDelegate(
//                           (BuildContext context, int index) {
//                             return TransactionEntry(
//                               category: snapshot.data![index].category,
//                               openPage: AddTransactionPage(
//                                 title: "Edit Transaction",
//                                 transaction:
//                                     snapshot.data![index].transaction,
//                               ),
//                               transaction: snapshot.data![index].transaction,
//                             );
//                           },
//                           childCount: snapshot.data?.length,
//                         ),
//                       ),
//                     );
//                   }
//                   return SliverToBoxAdapter(child: SizedBox());
//                 },
//               ),
//             );
//           }
//         });
//       }
//       return SliverToBoxAdapter(child: SizedBox());
//     },
//   ),
// ];

//   return transactionsWidgets;
// }

List<Widget> getTransactionsSlivers(
  DateTime startDay,
  DateTime endDay, {
  search = "",
  List<int> categoryFks = const [],
  Function(Transaction, bool)? onSelected,
  String? listID,
}) {
  List<Widget> transactionsWidgets = [];
  List<DateTime> dates = [];
  for (DateTime indexDay = startDay;
      indexDay.millisecondsSinceEpoch <= endDay.millisecondsSinceEpoch;
      indexDay = indexDay.add(Duration(days: 1))) {
    dates.add(indexDay);
  }
  for (DateTime date in dates.reversed) {
    transactionsWidgets.add(
      StreamBuilder<List<TransactionWithCategory>>(
        stream: database.getTransactionCategoryWithDay(date,
            search: search, categoryFks: categoryFks),
        builder: (context, snapshot) {
          if (snapshot.data != null &&
              snapshot.hasData &&
              (snapshot.data ?? []).length > 0) {
            List<TransactionWithCategory> transactionList =
                snapshot.data!.reversed.toList();
            double totalSpentForDay = 0;
            transactionList.forEach((transaction) {
              if (transaction.transaction.paid)
                totalSpentForDay += transaction.transaction.amount;
            });
            return SliverStickyHeader(
              header: DateDivider(
                  date: date,
                  info: transactionList.length > 1
                      ? convertToMoney(totalSpentForDay)
                      : ""),
              sticky: true,
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return TransactionEntry(
                      key: ValueKey(
                          transactionList[index].transaction.transactionPk),
                      category: transactionList[index].category,
                      openPage: AddTransactionPage(
                        title: "Edit Transaction",
                        transaction: transactionList[index].transaction,
                      ),
                      transaction: transactionList[index].transaction,
                      onSelected: (Transaction transaction, bool selected) {
                        if (onSelected != null)
                          onSelected(transaction, selected);
                      },
                      listID: listID,
                    );
                  },
                  childCount: transactionList.length,
                ),
              ),
            );
          }
          return SliverToBoxAdapter(child: SizedBox());
        },
      ),
    );
  }
  return transactionsWidgets;
}

class TransactionsListPage extends StatefulWidget {
  const TransactionsListPage({Key? key}) : super(key: key);

  @override
  State<TransactionsListPage> createState() => TransactionsListPageState();
}

class TransactionsListPageState extends State<TransactionsListPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  void refreshState() {
    setState(() {
      transactionWidgets = getTransactionsSlivers(
        selectedDateStart,
        new DateTime(selectedDateStart.year, selectedDateStart.month + 1,
            selectedDateStart.day - 1),
        onSelected: onSelected,
        listID: "Transactions",
      );
    });
  }

  void scrollToTop() {
    _scrollController.animateTo(0,
        duration: const Duration(milliseconds: 1200), curve: Curves.elasticOut);
  }

  @override
  bool get wantKeepAlive => true;

  bool showAppBarPaddingOffset = false;
  bool alreadyChanged = false;

  bool scaleInSearchIcon = false;

  late List<Widget> transactionWidgets = [];
  DateTime selectedDateStart =
      DateTime(DateTime.now().year, DateTime.now().month);
  late ScrollController _scrollController;
  late AnimationController _animationControllerSearch;
  late PageController _pageController;
  late List<int> selectedTransactionIDs = [];

  GlobalKey<_MonthSelectorState> monthSelectorStateKey = GlobalKey();

  onSelected(Transaction transaction, bool selected) {
    // print(transaction.transactionPk.toString() + " selected!");
    // print(globalSelectedID["Transactions"]);
  }

  @override
  void initState() {
    super.initState();
    transactionWidgets = getTransactionsSlivers(
      selectedDateStart,
      new DateTime(selectedDateStart.year, selectedDateStart.month + 1,
          selectedDateStart.day - 1),
      onSelected: onSelected,
      listID: "Transactions",
    );
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _animationControllerSearch = AnimationController(vsync: this, value: 1);
    _pageController = PageController(initialPage: 1);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationControllerSearch.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _loadNewTransactions() {
    setState(() {
      transactionWidgets = getTransactionsSlivers(
        selectedDateStart,
        new DateTime(selectedDateStart.year, selectedDateStart.month + 1,
            selectedDateStart.day - 1),
        onSelected: onSelected,
        listID: "Transactions",
      );
    });
  }

  _scrollListener() {
    double percent = _scrollController.offset /
        (MediaQuery.of(context).padding.top + 65 + 50);
    if (percent >= 0 && percent <= 1) {
      _animationControllerSearch.value = 1 - percent;
    }
    if (percent >= 1 && scaleInSearchIcon == false) {
      setState(() {
        scaleInSearchIcon = true;
      });
    } else if (percent < 1 && scaleInSearchIcon == true) {
      setState(() {
        scaleInSearchIcon = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget searchButton = OpenContainerNavigation(
      button: (openContainer) {
        return IconButton(
          onPressed: () {
            openContainer();
          },
          icon: Icon(Icons.search_rounded),
        );
      },
      openPage: TransactionsSearchPage(),
    );

    // return Listener(
    //   onPointerMove: (ptr) => {_onPointerMove(ptr)},
    //   onPointerUp: (ptr) => {_onPointerUp(ptr)},
    //   behavior: HitTestBehavior.opaque,
    //   child: AnimatedBuilder(
    //     animation: _animationControllerDragX,
    //     builder: (_, child) {
    //       return Transform.translate(
    //         offset: Offset((-0.5 + _animationControllerDragX.value) * 100, 0),
    //         child: PageFramework(
    //           onScroll: _onScroll,
    //           title: "Transactions",
    //           backButton: false,
    //           slivers: [
    //             SliverToBoxAdapter(
    //               child: Padding(
    //                 padding:
    //                     const EdgeInsets.only(left: 18, right: 18, bottom: 7),
    //                 child: OpenContainerNavigation(
    //                   borderRadius: 10,
    //                   button: (openContainer) {
    //                     return FakeTextInput(
    //                       onTap: openContainer,
    //                       label: "Search...",
    //                       icon: Icons.search_rounded,
    //                       edgeInsetsVertical:
    //                           MediaQuery.of(context).padding.top - 21 <= 15
    //                               ? MediaQuery.of(context).padding.top - 21
    //                               : 15,
    //                       backgroundColor:
    //                           Theme.of(context).colorScheme.secondaryContainer,
    //                     );
    //                   },
    //                   openPage: TransactionsSearchPage(),
    //                 ),
    //               ),
    //             ),
    //             SliverToBoxAdapter(
    //               child: MonthSelector(
    //                 key: monthSelectorStateKey,
    //                 selectedDateStart: selectedDateStart,
    //                 setSelectedDateStart: (DateTime currentDateTime) {
    //                   setState(() {
    //                     selectedDateStart = currentDateTime;
    //                     _loadNewTransactions();
    //                   });
    //                 },
    //               ),
    //             ),
    //             SliverToBoxAdapter(
    //               child: SizedBox(height: 15),
    //             ),
    //             ...transactionWidgets,
    //           ],
    //         ),
    //       );
    //     },
    //   ),
    // );

    return GestureDetector(
      onTap: () {
        //Minimize keyboard when tap non interactive widget
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder:
            (BuildContext contextHeader, bool innerBoxIsScrolled) {
          return <Widget>[
            PageFrameworkSliverAppBar(
              title: "Transactions",
              actions: [
                Padding(
                    padding: EdgeInsets.only(top: 10, right: 7),
                    child: MediaQuery.of(context).padding.top >= 25
                        ? AnimatedScale(
                            duration: Duration(milliseconds: 1100),
                            scale: scaleInSearchIcon ? 1 : 0,
                            curve: ElasticOutCurve(0.8),
                            child: searchButton,
                          )
                        : searchButton),
              ],
            ),
          ];
        },
        body: Builder(
          builder: (BuildContext context2) {
            return Scaffold(
              extendBodyBehindAppBar: false,
              appBar: AppBar(
                backgroundColor: Theme.of(context).canvasColor,
                elevation: 0,
                title: MediaQuery.of(context).padding.top >= 25
                    ? FadeTransition(
                        opacity: _animationControllerSearch,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18),
                          child: OpenContainerNavigation(
                            borderRadius: 10,
                            button: (openContainer) {
                              return FakeTextInput(
                                onTap: openContainer,
                                label: "Search...",
                                icon: Icons.search_rounded,
                                edgeInsetsVertical:
                                    MediaQuery.of(context).padding.top - 21 <=
                                            15
                                        ? MediaQuery.of(context).padding.top -
                                            21
                                        : 15,
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                              );
                            },
                            openPage: TransactionsSearchPage(),
                          ),
                        ),
                      )
                    : SizedBox.shrink(),
                titleSpacing: 0,
                primary: false,
                toolbarHeight: 65,
                bottom: PreferredSize(
                  child: Column(
                    children: [
                      MonthSelector(
                        key: monthSelectorStateKey,
                        selectedDateStart: selectedDateStart,
                        setSelectedDateStart: (DateTime currentDateTime) {
                          setState(() {
                            selectedDateStart = currentDateTime;
                            _loadNewTransactions();
                          });
                        },
                      ),
                      SizedBox(
                        height: 10,
                      )
                    ],
                  ),
                  preferredSize: Size.fromHeight(0),
                ),
              ),
              body: PageView(
                physics: AlwaysScrollableScrollPhysics(),
                controller: _pageController,
                onPageChanged: (index) {
                  if (alreadyChanged) {
                    alreadyChanged = false;
                    _pageController.animateToPage(
                      1,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOutCubicEmphasized,
                    );
                  } else {
                    alreadyChanged = true;
                    setState(() {
                      selectedDateStart = DateTime(selectedDateStart.year,
                          selectedDateStart.month + index - 1);
                      _loadNewTransactions();
                    });
                    _pageController.animateToPage(
                      1,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOutCubicEmphasized,
                    );
                    double middle =
                        -MediaQuery.of(context).size.width / 2 + 100 / 2;
                    int difference =
                        (DateTime.now().year - selectedDateStart.year) * 12 +
                            (DateTime.now().month - selectedDateStart.month) +
                            1;
                    monthSelectorStateKey.currentState!
                        .scrollTo(middle - difference * 100 + 100);
                  }
                },
                children: <Widget>[
                  LoadingShimmer(),
                  // Container(),
                  CustomScrollView(
                    // controller: _scrollController,
                    slivers: [
                      // SliverOverlapInjector(
                      //   handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                      //       context2),
                      // ),
                      // SliverAppBar(
                      //   title: Text("hello"),
                      //   pinned: true,
                      //   expandedHeight: 100,
                      //   toolbarHeight: 100,
                      // ),

                      //Needed in older version of flutter:
                      // SliverToBoxAdapter(),
                      ...transactionWidgets,

                      // Wipe all remaining pixels off - sometimes graphics artifacts are left behind
                      SliverToBoxAdapter(
                        child: Container(
                            height: 200, color: Theme.of(context).canvasColor),
                      ),
                    ],
                  ),
                  LoadingShimmer(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class FakeTextInput extends StatelessWidget {
  const FakeTextInput({
    Key? key,
    required this.onTap,
    required this.icon,
    this.label = "",
    this.edgeInsetsVertical = 13,
    this.backgroundColor,
    this.content,
  }) : super(key: key);

  final VoidCallback onTap;
  final String label;
  final IconData icon;
  final double edgeInsetsVertical;
  final Color? backgroundColor;
  final String? content;

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: onTap,
      color: backgroundColor ?? Theme.of(context).colorScheme.canvasContainer,
      borderRadius: 15,
      child: Container(
        margin: EdgeInsets.only(
            left: 18,
            top: edgeInsetsVertical,
            bottom: edgeInsetsVertical,
            right: 13),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            content == null || content == ""
                ? TextFont(
                    text: label,
                    fontSize: 15,
                    textColor:
                        Theme.of(context).colorScheme.black.withOpacity(0.6),
                  )
                : TextFont(
                    text: content ?? "",
                    fontSize: 15,
                    textColor: Theme.of(context).colorScheme.black,
                  ),
            Icon(
              icon,
              color: Theme.of(context).colorScheme.accentColorHeavy,
              size: 20,
            )
          ],
        ),
      ),
    );
  }
}

class LoadingShimmer extends StatelessWidget {
  const LoadingShimmer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      period: Duration(milliseconds: 1100),
      baseColor: Theme.of(context).colorScheme.lightDarkAccent,
      highlightColor:
          Theme.of(context).colorScheme.lightDarkAccentHeavy.withAlpha(20),
      child: ListView.builder(
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              color: Colors.white,
            ),
            height: 60,
          ),
        ),
      ),
    );
  }
}

class _ProductTabSliver extends SliverPersistentHeaderDelegate {
  final Widget widget;

  _ProductTabSliver(this.widget);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.red,
        ),
        child: widget);
  }

  @override
  double get maxExtent => 50;

  @override
  double get minExtent => 50;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

class _ProductTabSliver2 extends SliverPersistentHeaderDelegate {
  final Widget widget;

  _ProductTabSliver2(this.widget);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.red,
        ),
        child: widget);
  }

  @override
  double get maxExtent => 100;

  @override
  double get minExtent => 100;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

class MonthSelector extends StatefulWidget {
  const MonthSelector({
    Key? key,
    required this.selectedDateStart,
    required this.setSelectedDateStart,
  }) : super(key: key);
  final DateTime selectedDateStart;
  final Function(DateTime) setSelectedDateStart;
  @override
  State<MonthSelector> createState() => _MonthSelectorState();
}

class _MonthSelectorState extends State<MonthSelector> {
  bool showScrollBottom = false;
  bool showScrollTop = false;

  GlobalKey<_MultiDirectionalInfiniteScrollState>
      MultiDirectionalInfiniteScrollKey = GlobalKey();

  scrollTo(double position) {
    MultiDirectionalInfiniteScrollKey.currentState!
        .scrollTo(Duration(milliseconds: 700), position: position);
  }

  _onScroll(double position) {
    final upperBound = 200;
    final lowerBound = -200 - MediaQuery.of(context).size.width / 2 - 100;
    if (position > upperBound) {
      if (showScrollBottom == false)
        setState(() {
          showScrollBottom = true;
        });
    } else if (position < lowerBound) {
      if (showScrollTop == false)
        setState(() {
          showScrollTop = true;
        });
    }
    if (position > lowerBound && position < upperBound) {
      if (showScrollTop == true)
        setState(() {
          showScrollTop = false;
        });
      if (showScrollBottom == true)
        setState(() {
          showScrollBottom = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MultiDirectionalInfiniteScroll(
          key: MultiDirectionalInfiniteScrollKey,
          onScroll: (position) {
            _onScroll(position);
          },
          height: 50,
          overBoundsDetection: 50,
          initialItems: 10,
          startingScrollPosition:
              -MediaQuery.of(context).size.width / 2 + 100 / 2,
          duration: Duration(milliseconds: 1500),
          itemBuilder: (index) {
            DateTime currentDateTime =
                DateTime(DateTime.now().year, DateTime.now().month + index);
            bool isSelected =
                widget.selectedDateStart.month == currentDateTime.month &&
                    widget.selectedDateStart.year == currentDateTime.year;
            bool isToday = currentDateTime.month == DateTime.now().month &&
                currentDateTime.year == DateTime.now().year;
            return Container(
              color: Theme.of(context).canvasColor,
              child: Stack(
                children: [
                  Container(
                    height: 50,
                    child: Tappable(
                      onTap: () {
                        widget.setSelectedDateStart(currentDateTime);
                      },
                      borderRadius: 10,
                      child: Container(
                        width: 100,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AnimatedSwitcher(
                              duration: Duration(milliseconds: 300),
                              child: isSelected
                                  ? TextFont(
                                      key: ValueKey(1),
                                      fontSize: 14,
                                      text: getMonth(currentDateTime.month - 1),
                                      textColor:
                                          Theme.of(context).colorScheme.black,
                                      fontWeight: isToday
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    )
                                  : TextFont(
                                      key: ValueKey(2),
                                      fontSize: 14,
                                      text: getMonth(currentDateTime.month - 1),
                                      textColor: Theme.of(context)
                                          .colorScheme
                                          .textLight,
                                      fontWeight: isToday
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                            ),
                            DateTime.now().year != currentDateTime.year
                                ? AnimatedSwitcher(
                                    duration: Duration(milliseconds: 300),
                                    child: isSelected
                                        ? TextFont(
                                            key: ValueKey(1),
                                            fontSize: 9,
                                            text:
                                                currentDateTime.year.toString(),
                                            textColor: Theme.of(context)
                                                .colorScheme
                                                .black,
                                          )
                                        : TextFont(
                                            key: ValueKey(2),
                                            fontSize: 9,
                                            text:
                                                currentDateTime.year.toString(),
                                            textColor: Theme.of(context)
                                                .colorScheme
                                                .textLight,
                                          ),
                                  )
                                : SizedBox(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  isToday && !isSelected
                      ? Align(
                          alignment: Alignment.bottomRight,
                          child: SizedBox(
                            width: 100,
                            child: Center(
                              heightFactor: 0.5,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(40),
                                    topLeft: Radius.circular(40),
                                  ),
                                  color: Theme.of(context)
                                      .colorScheme
                                      .lightDarkAccent,
                                ),
                                width: 75,
                                height: 7,
                              ),
                            ),
                          ),
                        )
                      : SizedBox(),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: 100,
                      height: 2,
                      color: Theme.of(context).colorScheme.lightDarkAccent,
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: AnimatedScale(
                      duration: Duration(milliseconds: 500),
                      scale: isSelected ? 1 : 0,
                      curve:
                          isSelected ? Curves.decelerate : Curves.easeOutQuart,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(40),
                            topLeft: Radius.circular(40),
                          ),
                          color: Theme.of(context).colorScheme.black,
                        ),
                        width: 100,
                        height: 4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: AnimatedScale(
            scale: showScrollBottom ? 1 : 0,
            duration: const Duration(milliseconds: 400),
            alignment: Alignment.centerLeft,
            curve: Curves.fastOutSlowIn,
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8, left: 2),
              child: Tappable(
                borderRadius: 10,
                color: Theme.of(context).colorScheme.primary,
                onTap: () {
                  MultiDirectionalInfiniteScrollKey.currentState!
                      .scrollTo(Duration(milliseconds: 700));
                  widget.setSelectedDateStart(
                      DateTime(DateTime.now().year, DateTime.now().month));
                },
                child: Container(
                  width: 44,
                  height: 34,
                  child: Transform.scale(
                    scale: 1.5,
                    child: Icon(
                      Icons.arrow_left_rounded,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: AnimatedScale(
            scale: showScrollTop ? 1 : 0,
            duration: const Duration(milliseconds: 400),
            alignment: Alignment.centerRight,
            curve: Curves.fastOutSlowIn,
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8, right: 2),
              child: Tappable(
                borderRadius: 10,
                color: Theme.of(context).colorScheme.primary,
                onTap: () {
                  MultiDirectionalInfiniteScrollKey.currentState!
                      .scrollTo(Duration(milliseconds: 700));
                  widget.setSelectedDateStart(
                      DateTime(DateTime.now().year, DateTime.now().month));
                },
                child: Container(
                  width: 44,
                  height: 34,
                  child: Transform.scale(
                    scale: 1.5,
                    child: Icon(Icons.arrow_right_rounded,
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class MultiDirectionalInfiniteScroll extends StatefulWidget {
  const MultiDirectionalInfiniteScroll({
    Key? key,
    required this.itemBuilder,
    this.initialItems,
    this.overBoundsDetection = 50,
    this.startingScrollPosition = 0,
    this.duration = const Duration(milliseconds: 100),
    this.height = 40,
    this.onTopLoaded,
    this.onBottomLoaded,
    this.onScroll,
  }) : super(key: key);
  final int? initialItems;
  final int overBoundsDetection;
  final Function(int index) itemBuilder;
  final double startingScrollPosition;
  final Duration duration;
  final double height;
  final Function? onTopLoaded;
  final Function? onBottomLoaded;
  final Function? onScroll;
  @override
  State<MultiDirectionalInfiniteScroll> createState() =>
      _MultiDirectionalInfiniteScrollState();
}

class _MultiDirectionalInfiniteScrollState
    extends State<MultiDirectionalInfiniteScroll> {
  late ScrollController _scrollController;
  List<int> top = [1];
  List<int> bottom = [-1, 0];

  void initState() {
    super.initState();
    if (widget.initialItems != null) {
      top = [];
      bottom = [0];
      for (int i = 1; i < widget.initialItems!; i++) {
        top.insert(0, -(widget.initialItems! - i));
        bottom.add(i);
      }
    }
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        widget.startingScrollPosition,
        duration: widget.duration,
        curve: ElasticOutCurve(0.7),
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  scrollTo(duration, {double? position}) {
    _scrollController.animateTo(
      position == null ? widget.startingScrollPosition : position,
      duration: duration,
      curve: Curves.fastOutSlowIn,
    );
  }

  _scrollListener() {
    if (_scrollController.offset >=
        _scrollController.position.maxScrollExtent -
            widget.overBoundsDetection) {
      _onEndReached();
      if (widget.onTopLoaded != null) {
        widget.onTopLoaded!();
      }
    }
    if (_scrollController.offset <=
        _scrollController.position.minScrollExtent +
            widget.overBoundsDetection) {
      _onStartReached();
      if (widget.onBottomLoaded != null) {
        widget.onBottomLoaded!();
      }
    }
    if (widget.onScroll != null) {
      widget.onScroll!(_scrollController.offset);
    }
  }

  _onEndReached() {
    setState(() {
      bottom.add(bottom.length);
    });
  }

  _onStartReached() {
    setState(() {
      top.add(-top.length - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      child: CustomScrollView(
        scrollDirection: Axis.horizontal,
        controller: _scrollController,
        center: ValueKey('second-sliver-list'),
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return widget.itemBuilder(top[index]);
              },
              childCount: top.length,
            ),
          ),
          SliverList(
            key: ValueKey('second-sliver-list'),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return widget.itemBuilder(bottom[index]);
              },
              childCount: bottom.length,
            ),
          ),
        ],
      ),
    );
  }
}

class SliverPinnedOverlapInjector extends SingleChildRenderObjectWidget {
  const SliverPinnedOverlapInjector({
    required this.handle,
    Key? key,
  }) : super(key: key);

  final SliverOverlapAbsorberHandle handle;

  @override
  RenderSliverPinnedOverlapInjector createRenderObject(BuildContext context) {
    return RenderSliverPinnedOverlapInjector(
      handle: handle,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSliverPinnedOverlapInjector renderObject,
  ) {
    renderObject.handle = handle;
  }
}

class RenderSliverPinnedOverlapInjector extends RenderSliver {
  RenderSliverPinnedOverlapInjector({
    required SliverOverlapAbsorberHandle handle,
  }) : _handle = handle;

  double? _currentLayoutExtent;
  double? _currentMaxExtent;

  SliverOverlapAbsorberHandle get handle => _handle;
  SliverOverlapAbsorberHandle _handle;
  set handle(SliverOverlapAbsorberHandle value) {
    if (handle == value) return;
    if (attached) {
      handle.removeListener(markNeedsLayout);
    }
    _handle = value;
    if (attached) {
      handle.addListener(markNeedsLayout);
      if (handle.layoutExtent != _currentLayoutExtent ||
          handle.scrollExtent != _currentMaxExtent) markNeedsLayout();
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    handle.addListener(markNeedsLayout);
    if (handle.layoutExtent != _currentLayoutExtent ||
        handle.scrollExtent != _currentMaxExtent) markNeedsLayout();
  }

  @override
  void detach() {
    handle.removeListener(markNeedsLayout);
    super.detach();
  }

  @override
  void performLayout() {
    _currentLayoutExtent = handle.layoutExtent;

    final paintedExtent = min(
      _currentLayoutExtent!,
      constraints.remainingPaintExtent - constraints.overlap,
    );

    geometry = SliverGeometry(
      paintExtent: paintedExtent,
      maxPaintExtent: _currentLayoutExtent!,
      maxScrollObstructionExtent: _currentLayoutExtent!,
      paintOrigin: constraints.overlap,
      scrollExtent: _currentLayoutExtent!,
      layoutExtent: max(0, paintedExtent - constraints.scrollOffset),
      hasVisualOverflow: paintedExtent < _currentLayoutExtent!,
    );
  }
}
