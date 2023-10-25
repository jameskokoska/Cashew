import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/functions.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';
import 'package:budget/widgets/util/multiDirectionalInfiniteScroll.dart';

class MonthSelector extends StatefulWidget {
  const MonthSelector({
    Key? key,
    required this.setSelectedDateStart,
  }) : super(key: key);
  final Function(DateTime, int) setSelectedDateStart;
  @override
  State<MonthSelector> createState() => MonthSelectorState();
}

class MonthSelectorState extends State<MonthSelector> {
  DateTime selectedDateStart = DateTime.now();
  int pageOffset = 0;
  bool showScrollBottom = false;
  bool showScrollTop = false;

  GlobalKey<MultiDirectionalInfiniteScrollState>
      MultiDirectionalInfiniteScrollKey = GlobalKey();

  scrollTo(double position) {
    MultiDirectionalInfiniteScrollKey.currentState!
        .scrollTo(Duration(milliseconds: 700), position: position);
  }

  setSelectedDateStart(DateTime dateTime, int offset) {
    setState(() {
      selectedDateStart = dateTime;
      pageOffset = offset;
    });
  }

  _onScroll(double position) {
    final upperBound = 200;
    final lowerBound = -200 -
        (MediaQuery.sizeOf(context).width -
                getWidthNavigationSidebar(context)) /
            2 -
        100;
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
    return NotificationListener(
      onNotification: (SizeChangedLayoutNotification notification) {
        double middle = -(MediaQuery.sizeOf(context).width -
                    getWidthNavigationSidebar(context)) /
                2 +
            100 / 2;
        scrollTo(middle + (pageOffset - 1) * 100 + 100);
        return true;
      },
      child: SizeChangedLayoutNotifier(
        child: Stack(
          children: [
            MultiDirectionalInfiniteScroll(
              key: MultiDirectionalInfiniteScrollKey,
              onScroll: (position) {
                _onScroll(position);
              },
              height: 50,
              overBoundsDetection: 50,
              initialItems: 10,
              startingScrollPosition: -(MediaQuery.sizeOf(context).width -
                          getWidthNavigationSidebar(context)) /
                      2 +
                  100 / 2,
              duration: Duration(milliseconds: 1500),
              itemBuilder: (index) {
                DateTime currentDateTime =
                    DateTime(DateTime.now().year, DateTime.now().month + index);
                bool isSelected =
                    selectedDateStart.month == currentDateTime.month &&
                        selectedDateStart.year == currentDateTime.year;
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
                            widget.setSelectedDateStart(currentDateTime, index);
                          },
                          borderRadius: 10,
                          child: Container(
                            width: 100,
                            padding: EdgeInsets.symmetric(horizontal: 5),
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
                                          text: getMonth(currentDateTime),
                                          textColor: getColor(context, "black"),
                                          fontWeight: isToday
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          overflow: TextOverflow.clip,
                                          maxLines: 1,
                                          textAlign: TextAlign.center,
                                        )
                                      : TextFont(
                                          key: ValueKey(2),
                                          fontSize: 14,
                                          text: getMonth(currentDateTime),
                                          textColor:
                                              getColor(context, "textLight"),
                                          fontWeight: isToday
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          overflow: TextOverflow.clip,
                                          maxLines: 1,
                                          textAlign: TextAlign.center,
                                        ),
                                ),
                                DateTime.now().year != currentDateTime.year
                                    ? AnimatedSwitcher(
                                        duration: Duration(milliseconds: 300),
                                        child: isSelected
                                            ? TextFont(
                                                key: ValueKey(1),
                                                fontSize: 9,
                                                text: currentDateTime.year
                                                    .toString(),
                                                textColor:
                                                    getColor(context, "black"),
                                              )
                                            : TextFont(
                                                key: ValueKey(2),
                                                fontSize: 9,
                                                text: currentDateTime.year
                                                    .toString(),
                                                textColor: getColor(
                                                    context, "textLight"),
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
                                      color: appStateSettings["materialYou"]
                                          ? dynamicPastel(
                                              context,
                                              Theme.of(context)
                                                  .colorScheme
                                                  .secondaryContainer,
                                              amountDark: 0.5,
                                              amountLight: 0,
                                            )
                                          : getColor(
                                              context, "lightDarkAccent"),
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
                          color: appStateSettings["materialYou"]
                              ? dynamicPastel(
                                  context,
                                  Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer,
                                  amountDark: 0.5,
                                  amountLight: 0,
                                )
                              : getColor(context, "lightDarkAccent"),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: AnimatedScale(
                          duration: Duration(milliseconds: 500),
                          scale: isSelected ? 1 : 0,
                          curve: isSelected
                              ? Curves.decelerate
                              : Curves.easeOutQuart,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(40),
                                topLeft: Radius.circular(40),
                              ),
                              color: getColor(context, "black"),
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
                          DateTime(DateTime.now().year, DateTime.now().month),
                          0);
                    },
                    child: Container(
                      width: 44,
                      height: 34,
                      child: Transform.scale(
                        scale: 1.5,
                        child: Icon(
                          appStateSettings["outlinedIcons"]
                              ? Icons.arrow_left_outlined
                              : Icons.arrow_left_rounded,
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
                          DateTime(DateTime.now().year, DateTime.now().month),
                          0);
                    },
                    child: Container(
                      width: 44,
                      height: 34,
                      child: Transform.scale(
                        scale: 1.5,
                        child: Icon(
                            appStateSettings["outlinedIcons"]
                                ? Icons.arrow_right_outlined
                                : Icons.arrow_right_rounded,
                            color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
