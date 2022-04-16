import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/transactionCategory.dart';
import 'package:budget/struct/transactionTag.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import '../colors.dart';
import 'package:intl/intl.dart';

class TransactionEntry extends StatelessWidget {
  TransactionEntry(
      {Key? key,
      required this.openPage,
      required this.transaction,
      this.category})
      : super(key: key);

  final Widget openPage;
  final Transaction transaction;
  final TransactionCategory? category;

  final double fabSize = 50;

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
        return Dismissible(
          confirmDismiss: (DismissDirection direction) async {
            return await openPopup(
              context,
              description: "Delete " + transaction.name,
              icon: Icons.delete,
              onCancel: () => Navigator.of(context).pop(false),
              onCancelLabel: "Cancel",
              onSubmit: () {
                Navigator.of(context).pop(true);
                Future.delayed(Duration(milliseconds: 500), () async {
                  await database.deleteTransaction(transaction.transactionPk);
                });
              },
              onSubmitLabel: "Delete",
            );
          },
          background: Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: AlignmentDirectional.centerStart,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 0.0),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
          ),
          secondaryBackground: Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: AlignmentDirectional.centerEnd,
            child: Padding(
              padding: EdgeInsets.fromLTRB(0.0, 0.0, 20.0, 0.0),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(top: 1, bottom: 3, left: 13, right: 13),
            child: Tappable(
              borderRadius: 15,
              onTap: () async {
                openContainer();
              },
              child: Container(
                margin: EdgeInsets.only(left: 8, right: 12, top: 4, bottom: 4),
                child: Row(
                  children: [
                    CategoryIcon(
                      categoryPk: transaction.categoryFk,
                      size: 33,
                      sizePadding: 15,
                      margin: EdgeInsets.zero,
                    ),
                    Container(
                      width: 15,
                    ),
                    Expanded(
                      child: transaction.name != ""
                          ? TextFont(
                              text: transaction.name,
                              fontSize: 18,
                            )
                          : category == null
                              ? StreamBuilder<TransactionCategory>(
                                  stream: database
                                      .getCategory(transaction.categoryFk),
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
                                  text: category!.name,
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
                    TextFont(
                      text: convertToMoney(transaction.amount),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
            ),
          ),
          key: ValueKey<int>(transaction.transactionPk),
          onDismissed: (DismissDirection direction) {},
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
    this.category,
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
