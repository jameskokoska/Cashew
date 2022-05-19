import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/transactionCategory.dart';
import 'package:budget/struct/transactionTag.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import '../colors.dart';
import 'package:intl/intl.dart';

class TransactionEntry extends StatefulWidget {
  TransactionEntry({
    Key? key,
    required this.openPage,
    required this.transaction,
    this.listID, //needs to be unique based on the page to avoid conflicting globalSelectedIDs
    this.category,
    this.onSelected,
  }) : super(key: key);

  final Widget openPage;
  final Transaction transaction;
  final String? listID;
  final TransactionCategory? category;
  final Function(Transaction transaction, bool selected)? onSelected;

  @override
  State<TransactionEntry> createState() => _TransactionEntryState();
}

ValueNotifier<Map<String, List<int>>> globalSelectedID =
    ValueNotifier<Map<String, List<int>>>({});

class _TransactionEntryState extends State<TransactionEntry> {
  final double fabSize = 50;

  bool selected = false;

  @override
  Widget build(BuildContext context) {
    if (globalSelectedID.value[widget.listID ?? "0"] == null) {
      globalSelectedID.value[widget.listID ?? "0"] = [];
    }
    if (selected !=
        globalSelectedID.value[widget.listID ?? "0"]!
            .contains(widget.transaction.transactionPk))
      setState(() {
        selected = globalSelectedID.value[widget.listID ?? "0"]!
            .contains(widget.transaction.transactionPk);
      });

    return OpenContainer<bool>(
      transitionType: ContainerTransitionType.fade,
      openBuilder: (BuildContext context, VoidCallback _) {
        return widget.openPage;
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
          padding:
              const EdgeInsets.only(left: 13, right: 13, top: 1, bottom: 2),
          child: Tappable(
            borderRadius: 15,
            onLongPress: () {
              if (!selected) {
                globalSelectedID.value[widget.listID ?? "0"]!
                    .add(widget.transaction.transactionPk);
              } else {
                globalSelectedID.value[widget.listID ?? "0"]!
                    .remove(widget.transaction.transactionPk);
              }
              globalSelectedID.notifyListeners();
              setState(() {
                selected = !selected;
              });
              if (widget.onSelected != null)
                widget.onSelected!(widget.transaction, selected);
            },
            onTap: () async {
              openContainer();
            },
            child: AnimatedContainer(
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOutCubicEmphasized,
              padding: EdgeInsets.only(
                left: selected ? 15 - 2 : 10 - 2,
                right: selected ? 15 : 10,
                top: selected ? 8 : 4,
                bottom: selected ? 8 : 4,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? Theme.of(context)
                        .colorScheme
                        .lightDarkAccentHeavy
                        .withAlpha(200)
                    : Colors.transparent,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: Row(
                children: [
                  CategoryIcon(
                    categoryPk: widget.transaction.categoryFk,
                    size: 33,
                    sizePadding: 15,
                    margin: EdgeInsets.zero,
                  ),
                  Container(
                    width: 15,
                  ),
                  Expanded(
                    child: widget.transaction.name != ""
                        ? TextFont(
                            text: widget.transaction.name,
                            fontSize: 18,
                          )
                        : widget.category == null
                            ? StreamBuilder<TransactionCategory>(
                                stream: database
                                    .getCategory(widget.transaction.categoryFk),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return TextFont(
                                      text: snapshot.data!.name,
                                      fontSize: 18,
                                    );
                                  }
                                  return Container();
                                },
                              )
                            : TextFont(
                                text: widget.category!.name,
                                fontSize: 18,
                              ),
                  ),
                  // Expanded(
                  //   child: Container(
                  //     child: Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         transaction.name != ""
                  //             ? TextFont(
                  //                 text: transaction.name,
                  //                 fontSize: 20,
                  //               )
                  //             : Container(
                  //                 height: transaction.note == "" ? 0 : 7),
                  //         transaction.name == "" &&
                  //                 (transaction.labelFks?.length ?? 0) > 0
                  //             ? TagIcon(
                  //                 tag: TransactionTag(
                  //                     title: "test",
                  //                     id: "test",
                  //                     categoryID: "id"),
                  //                 size: transaction.note == "" ? 20 : 16)
                  //             : Container(),
                  //         transaction.name == "" &&
                  //                 (transaction.labelFks?.length ?? 0) == 0
                  //             ? StreamBuilder<TransactionCategory>(
                  //                 stream: database
                  //                     .getCategory(transaction.categoryFk),
                  //                 builder: (context, snapshot) {
                  //                   if (snapshot.hasData) {
                  //                     return TextFont(
                  //                       text: snapshot.data!.name,
                  //                       fontSize:
                  //                           transaction.note == "" ? 20 : 20,
                  //                     );
                  //                   }
                  //                   return TextFont(
                  //                     text: "",
                  //                     fontSize:
                  //                         transaction.note == "" ? 20 : 20,
                  //                   );
                  //                 })
                  //             : Container(),
                  //         transaction.name == "" && transaction.note != ""
                  //             ? Container(height: 4)
                  //             : Container(),
                  //         transaction.note == ""
                  //             ? Container()
                  //             : TextFont(
                  //                 text: transaction.note,
                  //                 fontSize: 16,
                  //                 maxLines: 2,
                  //               ),
                  //         transaction.note == ""
                  //             ? Container()
                  //             : Container(height: 4),
                  //         //TODO loop through all tags relating to this entry
                  //         transaction.name != "" &&
                  //                 (transaction.labelFks?.length ?? 0) > 0
                  //             ? TagIcon(
                  //                 tag: TransactionTag(
                  //                     title: "test",
                  //                     id: "test",
                  //                     categoryID: "id"),
                  //                 size: 12)
                  //             : Container()
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  CountNumber(
                    count: (widget.transaction.amount),
                    duration: Duration(milliseconds: 2000),
                    dynamicDecimals: true,
                    initialCount: (widget.transaction.amount),
                    textBuilder: (number) {
                      return TextFont(
                        textAlign: TextAlign.left,
                        text: convertToMoney(number),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      );
                    },
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
  CategoryIcon({
    Key? key,
    required this.categoryPk,
    required this.size,
    this.onTap,
    this.label = false,
    this.labelSize = 10,
    this.margin,
    this.sizePadding = 20,
    this.outline = false,
    this.noBackground = false,
    this.category, //pass this in to not look it up again
  }) : super(key: key);

  final int categoryPk;
  final double size;
  final VoidCallback? onTap;
  final bool label;
  final double labelSize;
  final EdgeInsets? margin;
  final double sizePadding;
  final bool outline;
  final bool noBackground;
  final TransactionCategory? category;

  categoryIconWidget(context, TransactionCategory? category) {
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
            color: category != null
                ? HexColor(category.colour,
                        Theme.of(context).colorScheme.lightDarkAccent)
                    .withOpacity(
                        noBackground ? (category == null ? 0.55 : 0) : 0.55)
                : Theme.of(context).colorScheme.lightDarkAccent,
            onTap: onTap,
            borderRadius: 10,
            child: Center(
              child: (category != null
                  ? Image(
                      image: AssetImage(
                          "assets/categories/" + (category.iconName ?? "")),
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
                    text: category != null ? category.name : "",
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

  @override
  Widget build(BuildContext context) {
    if (category != null) {
      return categoryIconWidget(context, category);
    }
    return StreamBuilder<TransactionCategory>(
      stream: database.getCategory(categoryPk),
      builder: (context, snapshot) {
        return categoryIconWidget(context, snapshot.data);
      },
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
                    top: 4 * widget.size / 14,
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
    this.info,
  }) : super(key: key);

  final DateTime date;
  final String? info;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).canvasColor,
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextFont(
            text: getWordedDate(date),
            fontSize: 14,
            textColor: Theme.of(context).colorScheme.textLight,
          ),
          info != null
              ? TextFont(
                  text: info!,
                  fontSize: 14,
                  textColor: Theme.of(context).colorScheme.textLight,
                )
              : SizedBox()
        ],
      ),
    );
  }
}
