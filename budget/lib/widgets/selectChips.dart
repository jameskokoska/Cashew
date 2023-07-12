import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/pages/budgetPage.dart';
import 'package:budget/pages/sharedBudgetSettings.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/categoryIcon.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/globalSnackBar.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/struct/initializeNotifications.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/radioItems.dart';
import 'package:budget/widgets/selectAmount.dart';
import 'package:budget/widgets/selectCategory.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/saveBottomButton.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:budget/colors.dart';
import 'package:provider/provider.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class SelectChips extends StatefulWidget {
  const SelectChips({
    super.key,
    required this.items,
    required this.getSelected,
    required this.onSelected,
    required this.getLabel,
    this.getCustomBorderColor,
    this.extraWidget,
    this.onLongPress,
    this.wrapped = false,
    this.darkerBackground = false,
  });
  final List<dynamic> items;
  final bool Function(dynamic) getSelected;
  final Function(dynamic) onSelected;
  final String Function(dynamic) getLabel;
  final Color? Function(dynamic)? getCustomBorderColor;
  final Widget? extraWidget;
  final Function(dynamic)? onLongPress;
  final bool wrapped;
  final bool darkerBackground;

  @override
  State<SelectChips> createState() => _SelectChipsState();
}

class _SelectChipsState extends State<SelectChips> {
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
        for (dynamic item in widget.items) {
          if (widget.getSelected(item)) {
            scrollToIndex = currentIndex;
            break;
          }
          currentIndex++;
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
      ...List<Widget>.generate(
        widget.items.length,
        (int index) {
          dynamic item = widget.items[index];
          bool selected = widget.getSelected(item);
          String label = widget.getLabel(item);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Tappable(
              onLongPress: () {
                if (widget.onLongPress != null) widget.onLongPress!(item);
              },
              color: Colors.transparent,
              child: ChoiceChip(
                backgroundColor: widget.darkerBackground
                    ? Theme.of(context)
                        .colorScheme
                        .secondaryContainer
                        .withOpacity(0.3)
                    : null,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                selectedColor: appStateSettings["materialYou"]
                    ? null
                    : getColor(context, "lightDarkAccentHeavy"),
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
          );
        },
      ).toList(),
      widget.extraWidget ?? SizedBox.shrink()
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Stack(
        children: [
          children.length > 0
              ? Visibility(
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
                      child: children[0],
                    ),
                  ),
                )
              : SizedBox.shrink(),
          Align(
            alignment: Alignment.centerLeft,
            child: widget.wrapped
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18),
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
                    child: ScrollablePositionedList.builder(
                      itemCount: children.length,
                      itemBuilder: (context, index) => children[index],
                      itemScrollController: itemScrollController,
                      scrollOffsetController: scrollOffsetController,
                      padding: EdgeInsets.symmetric(horizontal: 18),
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
