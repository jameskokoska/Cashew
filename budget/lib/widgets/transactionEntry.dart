import 'package:budget/functions.dart';
import 'package:budget/struct/transaction.dart';
import 'package:budget/struct/transactionCategory.dart';
import 'package:budget/struct/transactionTag.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import '../colors.dart';
import 'package:intl/intl.dart';

class TransactionEntry extends StatelessWidget {
  TransactionEntry(
      {Key? key, required this.openPage, required this.transaction})
      : super(key: key);

  final Widget openPage;
  final Transaction transaction;

  final double fabSize = 50;
  final TransactionCategory category = findCategory("id");

  @override
  Widget build(BuildContext context) {
    return OpenContainer<bool>(
      transitionType: ContainerTransitionType.fade,
      openBuilder: (BuildContext context, VoidCallback _) {
        return openPage;
      },
      onClosed: () {
        print("hello");
      }(),
      closedColor: Theme.of(context).canvasColor,
      tappable: false,
      closedShape: const RoundedRectangleBorder(),
      middleColor: Theme.of(context).colorScheme.white,
      transitionDuration: Duration(milliseconds: 500),
      closedElevation: 0.0,
      openColor: Theme.of(context).colorScheme.lightDarkAccent,
      closedBuilder: (BuildContext _, VoidCallback openContainer) {
        return Material(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 1),
            child: InkWell(
              customBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              onTap: () {
                openContainer();
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                child: Row(
                  children: [
                    CategoryIcon(category: category, size: 50),
                    Container(
                      width: 15,
                    ),
                    Expanded(
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            transaction.title == ""
                                ? TagIcon(
                                    tag: TransactionTag(
                                        title: "test",
                                        id: "test",
                                        categoryID: "id"),
                                    size: 16)
                                : TextFont(
                                    text: transaction.title,
                                    fontSize: 20,
                                  ),
                            transaction.title == "" && transaction.note != ""
                                ? Container(height: 4)
                                : Container(),
                            transaction.note == ""
                                ? Container()
                                : TextFont(
                                    text: transaction.note,
                                    fontSize: 16,
                                    maxLines: 2,
                                  ),
                            transaction.note == ""
                                ? Container()
                                : Container(height: 4),
                            //TODO loop through all tags relating to this entry
                            transaction.title == ""
                                ? Container()
                                : TagIcon(
                                    tag: TransactionTag(
                                        title: "test",
                                        id: "test",
                                        categoryID: "id"),
                                    size: 12)
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 8, left: 5),
                      child: TextFont(
                        text: convertToMoney(transaction.amount),
                        fontSize: 25,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class CategoryIcon extends StatelessWidget {
  CategoryIcon({Key? key, required this.category, required this.size})
      : super(key: key);

  final TransactionCategory category;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: category.color),
      child: Center(
        child: Image(
          image: AssetImage("../assets/icons/categories/" + category.icon),
          width: size * 0.5,
        ),
      ),
    );
  }
}

class TagIcon extends StatelessWidget {
  TagIcon({Key? key, required this.tag, required this.size}) : super(key: key);

  final TransactionTag tag;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(1000),
        color: Theme.of(context).colorScheme.lightDarkAccentHeavy,
      ),
      child: Padding(
        padding: EdgeInsets.only(
            top: 5.5 * this.size / 14,
            right: 10 * this.size / 14,
            left: 10 * this.size / 14,
            bottom: 4 * this.size / 14),
        child: TextFont(
          text: "My Text",
          fontSize: this.size,
        ),
      ),
    );
  }
}

class DateDivider extends StatelessWidget {
  DateDivider({
    Key? key,
    required this.date,
  }) : super(key: key);

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.accentColor,
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: TextFont(
          text: DateFormat.MMMMEEEEd('en_US').format(date).toString(),
          fontSize: 15,
        ),
      ),
    );
  }
}
