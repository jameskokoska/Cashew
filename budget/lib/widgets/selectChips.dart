import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/pages/sharedBudgetSettings.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/categoryIcon.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/globalSnackBar.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/util/initializeNotifications.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/popupFramework.dart';
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
  });
  final List<dynamic> items;
  final bool Function(dynamic) getSelected;
  final Function(dynamic) onSelected;
  final String Function(dynamic) getLabel;
  final Color? Function(dynamic)? getCustomBorderColor;
  final Widget? extraWidget;
  final Function(dynamic)? onLongPress;
  final bool wrapped;

  @override
  State<SelectChips> createState() => _SelectChipsState();
}

class _SelectChipsState extends State<SelectChips> {
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
    if (widget.wrapped)
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 18),
        child: Wrap(
          runSpacing: 10,
          children: children,
        ),
      );
    return SizedBox(
      height: 40,
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 18),
        scrollDirection: Axis.horizontal,
        children: children,
      ),
    );
  }
}
