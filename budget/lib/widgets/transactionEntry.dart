import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/transactionCategory.dart';
import 'package:budget/struct/transactionTag.dart';
import 'package:budget/widgets/tappable.dart';
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
  final TransactionCategoryOld category = findCategory("id");

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
          child: Tappable(
            borderRadius: 15,
            onTap: () {
              openContainer();
            },
            child: Container(
              margin: EdgeInsets.only(left: 14, right: 25, top: 12, bottom: 12),
              child: Row(
                children: [
                  // CategoryIcon(
                  //   category: category,
                  //   size: 45,
                  //   margin: EdgeInsets.zero,
                  // ),
                  Container(
                    width: 15,
                  ),
                  Expanded(
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          transaction.name != ""
                              ? TextFont(
                                  text: transaction.name,
                                  fontSize: 20,
                                )
                              : Container(
                                  height: transaction.note == "" ? 0 : 7),
                          transaction.name == "" &&
                                  (transaction.labelFks?.length ?? 0) > 0
                              ? TagIcon(
                                  tag: TransactionTag(
                                      title: "test",
                                      id: "test",
                                      categoryID: "id"),
                                  size: transaction.note == "" ? 20 : 16)
                              : Container(),
                          transaction.name == "" &&
                                  (transaction.labelFks?.length ?? 0) == 0
                              ? TextFont(
                                  text: category.title,
                                  fontSize: transaction.note == "" ? 23 : 20,
                                )
                              : Container(),
                          transaction.name == "" && transaction.note != ""
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
                          transaction.name != "" &&
                                  (transaction.labelFks?.length ?? 0) > 0
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
      this.outline = false,
      this.noBackground = false})
      : super(key: key);

  final TransactionCategory? category;
  final double size;
  final VoidCallback? onTap;
  final bool label;
  final double labelSize;
  final EdgeInsets? margin;
  final double sizePadding;
  final bool outline;
  final bool noBackground;

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
          child: Tappable(
            color: HexColor(category?.colour,
                    Theme.of(context).colorScheme.lightDarkAccent)
                .withOpacity(noBackground
                    ? (category?.colour == null ? 0.55 : 0)
                    : 0.55),
            onTap: onTap,
            borderRadius: 10,
            child: Center(
              child: (category?.iconName != null
                  ? Image(
                      image: AssetImage(
                          "assets/categories/" + (category?.iconName ?? "")),
                      width: size,
                    )
                  : Container()),
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
                    text: category?.name ?? "",
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

class TagIcon extends StatefulWidget {
  TagIcon(
      {Key? key,
      required this.tag,
      required this.size,
      this.onTap,
      this.selected = false})
      : super(key: key);

  final TransactionTag tag;
  final double size;
  final VoidCallback? onTap;
  final bool selected;

  @override
  _TagIconState createState() => _TagIconState();
}

class _TagIconState extends State<TagIcon> {
  bool selected = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      selected = widget.selected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: widget.onTap == null
          ? null
          : () {
              setState(() {
                selected = !selected;
              });
              widget.onTap;
            },
      borderRadius: widget.size * 0.8,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.size * 0.8),
          color: selected
              ? Theme.of(context).colorScheme.accentColor.withOpacity(0.8)
              : Theme.of(context)
                  .colorScheme
                  .lightDarkAccentHeavy
                  .withOpacity(0.6),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            right: widget.onTap == null
                ? 9 * widget.size / 14
                : 8 * widget.size / 14,
            left: widget.onTap == null
                ? 9 * widget.size / 14
                : 6 * widget.size / 14,
          ),
          child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                widget.onTap != null
                    ? Padding(
                        padding: EdgeInsets.only(right: 2 * widget.size / 14),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 700),
                          width:
                              selected ? widget.size * 0.9 : widget.size * 0.75,
                          height:
                              selected ? widget.size * 0.9 : widget.size * 0.75,
                          margin: EdgeInsets.symmetric(
                              horizontal: selected
                                  ? widget.size * 0.1 / 2
                                  : widget.size * 0.25 / 2),
                          curve: Curves.elasticOut,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(widget.size),
                            color: selected
                                ? Theme.of(context)
                                    .colorScheme
                                    .accentColorHeavy
                                    .withOpacity(0.8)
                                : Theme.of(context)
                                    .colorScheme
                                    .lightDarkAccentHeavy
                                    .withOpacity(0.9),
                          ),
                        ),
                      )
                    : Container(),
                Padding(
                  padding: EdgeInsets.only(
                    top: 5.5 * widget.size / 14,
                    bottom: 4 * widget.size / 14,
                  ),
                  child: TextFont(
                    text: widget.tag.title,
                    fontSize: widget.size,
                  ),
                ),
              ]),
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
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      alignment: Alignment.centerLeft,
      child: TextFont(
        text: getWordedDate(date),
        fontSize: 15,
      ),
    );
  }
}
