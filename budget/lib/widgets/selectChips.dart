import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:budget/colors.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'util/widgetSize.dart';

class SelectChips<T> extends StatefulWidget {
  const SelectChips({
    super.key,
    required this.items,
    required this.getSelected,
    required this.onSelected,
    required this.getLabel,
    this.getCustomBorderColor,
    this.extraWidget,
    this.extraWidgetAtBeginning = false,
    this.onLongPress,
    this.wrapped = false,
    this.extraHorizontalPadding,
    this.getAvatar,
    this.selectedColor,
    this.scrollablePositionedList = true,
    this.padding,
    // If allowMultipleSelected, we use check marks
    this.allowMultipleSelected = true,
  });
  final List<T> items;
  final bool Function(T) getSelected;
  final Function(T) onSelected;
  final String Function(T) getLabel;
  final Color? Function(T)? getCustomBorderColor;
  final Widget? extraWidget;
  final bool extraWidgetAtBeginning;
  final Function(T)? onLongPress;
  final bool wrapped;
  final double? extraHorizontalPadding;
  final Widget Function(T)? getAvatar;
  final Color? selectedColor;
  final scrollablePositionedList;
  final EdgeInsets? padding;
  final bool allowMultipleSelected;

  @override
  State<SelectChips<T>> createState() => _SelectChipsState<T>();
}

class _SelectChipsState<T> extends State<SelectChips<T>> {
  double heightOfScroll = 0;
  final ItemScrollController itemScrollController = ItemScrollController();
  final ScrollOffsetController scrollOffsetController =
      ScrollOffsetController();
  bool isDoneAnimation = false;

  @override
  void initState() {
    if (widget.wrapped == false) {
      Future.delayed(Duration(milliseconds: 0), () {
        int? scrollToIndex = null;
        int currentIndex = 0;
        for (T item in widget.items) {
          if (widget.getSelected(item)) {
            scrollToIndex = currentIndex;
            break;
          }
          currentIndex++;
        }
        // Extra widget at beginning
        if (widget.extraWidget != null &&
            widget.extraWidgetAtBeginning == true &&
            scrollToIndex != null &&
            scrollToIndex > 0) {
          scrollToIndex = scrollToIndex + 1;
        }
        if (scrollToIndex != null && scrollToIndex != 0) {
          itemScrollController.scrollTo(
            index: scrollToIndex,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOutCubicEmphasized,
            alignment: 0.06,
          );
        }
      });
      Future.delayed(Duration(milliseconds: 1000), () {
        if (mounted)
          setState(() {
            isDoneAnimation = true;
          });
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      if (widget.extraWidget != null && widget.extraWidgetAtBeginning == true)
        widget.extraWidget ?? SizedBox.shrink(),
      ...List<Widget>.generate(
        widget.items.length,
        (int index) {
          T item = widget.items[index];
          bool selected = widget.getSelected(item);
          String label = widget.getLabel(item);
          Widget? avatar =
              widget.getAvatar == null ? null : widget.getAvatar!(item);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Material(
              color: Colors.transparent,
              child: Tappable(
                onLongPress: () {
                  if (widget.onLongPress != null) widget.onLongPress!(item);
                },
                color: Colors.transparent,
                child: Theme(
                  data: Theme.of(context)
                      .copyWith(canvasColor: Colors.transparent),
                  child: ChoiceChip(
                    avatar: avatar == null
                        ? null
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              avatar,
                            ],
                          ),
                    labelPadding: avatar == null
                        ? null
                        : EdgeInsets.only(
                            left: 5, right: 10, top: 1, bottom: 1),
                    padding: avatar == null
                        ? null
                        : EdgeInsets.only(left: 10, top: 7, bottom: 7),
                    showCheckmark:
                        widget.allowMultipleSelected == true && avatar == null,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    selectedColor: widget.selectedColor ??
                        (appStateSettings["materialYou"]
                            ? null
                            : getColor(context, "lightDarkAccentHeavy")),
                    side: widget.getCustomBorderColor == null ||
                            widget.getCustomBorderColor!(item) == null
                        ? null
                        : BorderSide(
                            color: widget.getCustomBorderColor!(item)!,
                          ),
                    label: TextFont(
                      text: label,
                      fontSize: 15,
                    ),
                    selected: selected,
                    onSelected: (bool selected) {
                      widget.onSelected(item);
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ).toList(),
      if (widget.extraWidget != null && widget.extraWidgetAtBeginning == false)
        widget.extraWidget ?? SizedBox.shrink()
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Stack(
        children: [
          children.length > 0
              ? IgnorePointer(
                  child: Visibility(
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: Opacity(
                      opacity: 0,
                      child: WidgetSize(
                        onChange: (Size size) {
                          setState(() {
                            heightOfScroll = size.height;
                          });
                        },
                        child: widget.extraWidgetAtBeginning == false
                            ? children[0]
                            : children[1],
                      ),
                    ),
                  ),
                )
              : SizedBox.shrink(),
          Align(
            alignment: Alignment.centerLeft,
            child: widget.wrapped
                ? Padding(
                    padding: widget.padding ??
                        EdgeInsets.symmetric(
                            horizontal:
                                (widget.extraHorizontalPadding ?? 0) + 18),
                    child: Wrap(
                      runSpacing: 10,
                      children: [
                        for (Widget child in children)
                          SizedBox(height: heightOfScroll, child: child)
                      ],
                    ),
                  )
                : SizedBox(
                    height: heightOfScroll,
                    child: widget.scrollablePositionedList == false
                        ? SingleChildScrollView(
                            child: Row(
                              children: children,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                            ),
                            padding: widget.padding ??
                                EdgeInsets.symmetric(
                                    horizontal:
                                        (widget.extraHorizontalPadding ?? 0) +
                                            18),
                            scrollDirection: Axis.horizontal,
                          )
                        : ScrollablePositionedList.builder(
                            itemCount: children.length,
                            itemBuilder: (context, index) => children[index],
                            itemScrollController: itemScrollController,
                            scrollOffsetController: scrollOffsetController,
                            padding: widget.padding ??
                                EdgeInsets.symmetric(
                                    horizontal:
                                        (widget.extraHorizontalPadding ?? 0) +
                                            18),
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            // physics:
                            //     isDoneAnimation ? ScrollPhysics() : BouncingScrollPhysics(),
                          ),
                  ),
          )
        ],
      ),
    );
  }
}
