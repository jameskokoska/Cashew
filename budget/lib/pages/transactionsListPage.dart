import 'dart:developer';

import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/budgetContainer.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/openBottomSheet.dart';
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

List<Widget> getTransactionsSlivers(DateTime startDay, DateTime endDay,
    {search = "", List<int> categoryFks = const []}) {
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
          if (snapshot.hasData && (snapshot.data ?? []).length > 0) {
            double totalSpentForDay = 0;
            snapshot.data!.forEach((transaction) {
              totalSpentForDay += transaction.transaction.amount;
            });
            return SliverStickyHeader(
              header: DateDivider(
                  date: date,
                  info: snapshot.data!.length > 1
                      ? convertToMoney(totalSpentForDay)
                      : ""),
              sticky: true,
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return TransactionEntry(
                      category: snapshot.data![index].category,
                      openPage: AddTransactionPage(
                        title: "Edit Transaction",
                        transaction: snapshot.data![index].transaction,
                      ),
                      transaction: snapshot.data![index].transaction,
                    );
                  },
                  childCount: snapshot.data?.length,
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
    with AutomaticKeepAliveClientMixin {
  void refreshState() {
    setState(() {});
    searchTransaction("");
  }

  @override
  bool get wantKeepAlive => true;

  late Color selectedColor = Colors.red;
  late List<Widget> transactionWidgets = [];
  DateTime selectedDateStart =
      DateTime(DateTime.now().year, DateTime.now().month);
  @override
  void initState() {
    super.initState();
    transactionWidgets = getTransactionsSlivers(
      selectedDateStart,
      new DateTime(selectedDateStart.year, selectedDateStart.month + 1,
          selectedDateStart.day - 1),
    );
  }

  void _loadNewTransactions() {
    setState(() {
      transactionWidgets = getTransactionsSlivers(
        selectedDateStart,
        new DateTime(selectedDateStart.year, selectedDateStart.month + 1,
            selectedDateStart.day - 1),
      );
    });
  }

  searchTransaction(String? search) {
    setState(() {
      transactionWidgets = getTransactionsSlivers(
          DateTime(2022, 01, 1),
          new DateTime(DateTime.now().year, DateTime.now().month + 1,
              DateTime.now().day),
          search: search);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        //Minimize keyboard when tap non interactive widget
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: PageFramework(
        title: "Transactions",
        backButton: false,
        appBarBackgroundColor: Theme.of(context).colorScheme.accentColor,
        appBarBackgroundColorStart: Theme.of(context).canvasColor,
        slivers: [
          SliverToBoxAdapter(
              child: MonthSelector(
            selectedDateStart: selectedDateStart,
            setSelectedDateStart: (DateTime currentDateTime) {
              setState(() {
                selectedDateStart = currentDateTime;
                _loadNewTransactions();
              });
            },
          )),
          SliverToBoxAdapter(child: SizedBox(height: 5)),
          ...transactionWidgets,
        ],
        subtitle: TextInput(
          labelText: "Search",
          bubbly: true,
          icon: Icons.search_rounded,
          onSubmitted: (value) {
            searchTransaction(value);
          },
          onChanged: (value) => searchTransaction(value),
        ),
        subtitleSize: 20,
        subtitleAnimationSpeed: 4.5,
        // onBottomReached: _onBottomReached,
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final upperBound = 200;
    final lowerBound = -200 - MediaQuery.of(context).size.width / 2 - 100;
    return Stack(
      children: [
        MultiDirectionalInfiniteScroll(
          key: MultiDirectionalInfiniteScrollKey,
          onScroll: (position) {
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
                            currentDateTime.month == 1 &&
                                    DateTime.now().month != 1
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
                      curve: isSelected
                          ? ElasticOutCurve(0.8)
                          : Curves.easeOutQuart,
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
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Tappable(
                borderRadius: 10,
                color: Theme.of(context).colorScheme.accentColor,
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
                    child: Icon(Icons.arrow_left_rounded),
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
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Tappable(
                borderRadius: 10,
                color: Theme.of(context).colorScheme.accentColor,
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
                    child: Icon(Icons.arrow_right_rounded),
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

// class TrianglePainter extends CustomPainter {
//   final Color strokeColor;
//   final PaintingStyle paintingStyle;
//   final double strokeWidth;

//   TrianglePainter(
//       {this.strokeColor = Colors.black,
//       this.strokeWidth = 3,
//       this.paintingStyle = PaintingStyle.stroke});

//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint paint = Paint()
//       ..color = strokeColor
//       ..strokeWidth = strokeWidth
//       ..style = paintingStyle;

//     canvas.drawPath(getTrianglePath(size.width, size.height), paint);
//   }

//   Path getTrianglePath(double x, double y) {
//     return Path()
//       ..moveTo(0, y)
//       ..lineTo(x / 2, 0)
//       ..lineTo(x, y);
//   }

//   @override
//   bool shouldRepaint(TrianglePainter oldDelegate) {
//     return oldDelegate.strokeColor != strokeColor ||
//         oldDelegate.paintingStyle != paintingStyle ||
//         oldDelegate.strokeWidth != strokeWidth;
//   }
// }

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
    WidgetsBinding.instance?.addPostFrameCallback((_) {
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
      print(_scrollController.position.minScrollExtent);
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

// SliverPersistentHeader(
//   delegate: SectionHeaderDelegate(TextFont(text: "text")),
//   pinned: true,
// ),

// class SectionHeaderDelegate extends SliverPersistentHeaderDelegate {
//   final Widget widget;
//   final double height;

//   SectionHeaderDelegate(this.widget, [this.height = 50]);

//   @override
//   Widget build(context, double shrinkOffset, bool overlapsContent) {
//     return widget;
//   }

//   @override
//   double get maxExtent => height;

//   @override
//   double get minExtent => height;

//   @override
//   bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => false;
// }
