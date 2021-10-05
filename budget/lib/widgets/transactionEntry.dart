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
      onClosed: () {}(),
      closedColor: Theme.of(context).canvasColor,
      tappable: false,
      closedShape: const RoundedRectangleBorder(),
      middleColor: Theme.of(context).colorScheme.white,
      transitionDuration: Duration(milliseconds: 500),
      closedElevation: 0.0,
      openColor: Theme.of(context).colorScheme.lightDarkAccent,
      closedBuilder: (BuildContext _, VoidCallback openContainer) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 1),
          child: Material(
            borderRadius: BorderRadius.circular(15),
            child: InkWell(
              customBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              onTap: () {
                openContainer();
              },
              child: Container(
                margin:
                    EdgeInsets.only(left: 14, right: 25, top: 12, bottom: 12),
                child: Row(
                  children: [
                    CategoryIcon(
                      category: category,
                      size: 45,
                      margin: EdgeInsets.zero,
                    ),
                    Container(
                      width: 15,
                    ),
                    Expanded(
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            transaction.title != ""
                                ? TextFont(
                                    text: transaction.title,
                                    fontSize: 20,
                                  )
                                : Container(),
                            transaction.title == "" &&
                                    transaction.tagIDs.length > 0
                                ? TagIcon(
                                    tag: TransactionTag(
                                        title: "test",
                                        id: "test",
                                        categoryID: "id"),
                                    size: 16)
                                : Container(),
                            transaction.title == "" &&
                                    transaction.tagIDs.length == 0
                                ? TextFont(
                                    text: category.title,
                                    fontSize: 20,
                                  )
                                : Container(),
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
                            transaction.title != "" &&
                                    transaction.tagIDs.length > 0
                                ? TagIcon(
                                    tag: TransactionTag(
                                        title: "test",
                                        id: "test",
                                        categoryID: "id"),
                                    size: 12)
                                : Container()
                          ],
                        ),
                      ),
                    ),
                    TextFont(
                      text: convertToMoney(transaction.amount),
                      fontSize: 25,
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
  CategoryIcon(
      {Key? key,
      required this.category,
      required this.size,
      this.onTap,
      this.label = false,
      this.labelSize = 10,
      this.margin,
      this.sizePadding = 20,
      this.outline = false})
      : super(key: key);

  final TransactionCategory? category;
  final double size;
  final VoidCallback? onTap;
  final bool label;
  final double labelSize;
  final EdgeInsets? margin;
  final double sizePadding;
  final bool outline;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: Duration(milliseconds: 250),
          margin: margin ??
              EdgeInsets.only(left: 8, right: 8, top: 8, bottom: label ? 2 : 8),
          height: size + sizePadding,
          width: size + sizePadding,
          decoration: outline
              ? BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.accentColorHeavy,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(13)),
                )
              : BoxDecoration(
                  border: Border.all(
                    color: Colors.transparent,
                    width: 0,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(13)),
                ),
          child: Material(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: category?.color.withOpacity(0.6) ??
                Theme.of(context).colorScheme.lightDarkAccent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              child: Center(
                child: (category?.icon != null
                    ? Image(
                        image:
                            AssetImage("assets/categories/" + category!.icon),
                        width: size,
                      )
                    : Container()),
              ),
            ),
          ),
        ),
        label
            ? Container(
                margin: EdgeInsets.only(top: 3),
                width: 60,
                child: Center(
                  child: TextFont(
                    textAlign: TextAlign.center,
                    text: category?.title ?? "",
                    fontSize: labelSize,
                    maxLines: 1,
                  ),
                ),
              )
            : Container(
                width: size + sizePadding,
              ),
      ],
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
        color:
            Theme.of(context).colorScheme.lightDarkAccentHeavy.withOpacity(0.6),
      ),
      padding: EdgeInsets.only(
          top: 5.5 * this.size / 14,
          right: 10 * this.size / 14,
          left: 10 * this.size / 14,
          bottom: 4 * this.size / 14),
      child: TextFont(
        text: "My Text",
        fontSize: this.size,
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
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      alignment: Alignment.centerLeft,
      child: TextFont(
        text: DateFormat.MMMMEEEEd('en_US').format(date).toString(),
        fontSize: 15,
      ),
    );
  }
}
