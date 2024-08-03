import 'package:budget/functions.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/breathingAnimation.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';
import 'package:flutter/services.dart';

class DropdownSelect extends StatefulWidget {
  final String initial;
  final List<String> items;
  final Function(String) onChanged;
  final Color? backgroundColor;
  final bool compact;
  final bool
      checkInitialValue; //Check if the initial value not in list, default to using the first index
  final List<String> boldedValues;
  final List<String> faintValues;
  final Function(String)? getLabel;

  const DropdownSelect({
    Key? key,
    required this.initial,
    required this.items,
    required this.onChanged,
    this.backgroundColor,
    this.compact = false,
    this.checkInitialValue = false,
    this.boldedValues = const [],
    this.faintValues = const [],
    this.getLabel,
  }) : super(key: key);

  @override
  State<DropdownSelect> createState() => DropdownSelectState();
}

class DropdownSelectState extends State<DropdownSelect> {
  String? currentValue;

  late GlobalKey? _dropdownButtonKey = GlobalKey();

  void openDropdown() {
    GestureDetector? detector;
    void searchForGestureDetector(BuildContext? element) {
      element?.visitChildElements((element) {
        if (element.widget is GestureDetector) {
          detector = element.widget as GestureDetector?;
        } else {
          searchForGestureDetector(element);
        }
      });
    }

    searchForGestureDetector(_dropdownButtonKey?.currentContext);
    assert(detector != null);

    detector?.onTap?.call();
  }

  @override
  void initState() {
    super.initState();
    if (widget.checkInitialValue == true &&
        !widget.items.contains(widget.initial)) {
      currentValue = widget.items[0];
    } else {
      currentValue = widget.initial;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.only(
          start: widget.compact ? 13 : 15,
          end: widget.compact ? 1 : 6,
          top: widget.compact ? 2 : 10,
          bottom: widget.compact ? 2 : 10),
      decoration: BoxDecoration(
        color: widget.backgroundColor == null
            ? getColor(context, "lightDarkAccent")
            : widget.backgroundColor,
        borderRadius: BorderRadiusDirectional.circular(10),
      ),
      child: DropdownButton<String>(
        key: _dropdownButtonKey,
        underline: Container(),
        style: TextStyle(color: getColor(context, "black"), fontSize: 15),
        dropdownColor: widget.backgroundColor == null
            ? getColor(context, "lightDarkAccent")
            : widget.backgroundColor,
        isDense: true,
        value: currentValue ?? widget.initial,
        elevation: 15,
        iconSize: 32,
        borderRadius: BorderRadius.circular(10),
        icon: Icon(appStateSettings["outlinedIcons"]
            ? Icons.arrow_drop_down_outlined
            : Icons.arrow_drop_down_rounded),
        onChanged: (String? value) {
          widget.onChanged(value ?? widget.items[0]);
          setState(() {
            currentValue = value;
          });
        },
        items: widget.items
            .toSet()
            .toList()
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem(
            alignment: AlignmentDirectional.centerStart,
            child: TextFont(
              text: widget.getLabel != null ? widget.getLabel!(value) : value,
              fontSize: widget.compact ? 14 : 18,
              fontWeight: widget.boldedValues.contains(value)
                  ? FontWeight.bold
                  : FontWeight.normal,
              textColor: getColor(context, "black")
                  .withOpacity(widget.faintValues.contains(value) ? 0.3 : 1),
            ),
            value: value,
          );
        }).toList(),
      ),
    );
  }
}

class DropdownItemMenu {
  final String id;
  final String label;
  final IconData icon;
  final VoidCallback action;
  final VoidCallback? actionOnLongPress;
  final double? iconScale;
  final bool selected;

  DropdownItemMenu({
    required this.id,
    required this.label,
    required this.icon,
    required this.action,
    this.actionOnLongPress,
    this.iconScale,
    this.selected = false,
  });
}

class CustomPopupMenuButton extends StatelessWidget {
  final List<DropdownItemMenu> items;
  final bool showButtons;
  final bool keepOutFirst;
  final bool forceKeepOutFirst;
  final double buttonPadding;

  CustomPopupMenuButton({
    required this.items,
    this.showButtons = false,
    this.keepOutFirst = true,
    this.forceKeepOutFirst = false,
    this.buttonPadding = 15,
  });

  menuIconButtonBuilder(BuildContext context, DropdownItemMenu menuItem) {
    return Tooltip(
      message: menuItem.label,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          AnimatedScale(
            scale: menuItem.selected ? 1.8 : 0,
            curve: Curves.easeInOutCubicEmphasized,
            duration: Duration(milliseconds: 700),
            child: Container(
              height: 22,
              width: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dynamicPastel(
                  context,
                  Theme.of(context).colorScheme.secondaryContainer,
                  inverse: true,
                  amount: 0.2,
                ).withOpacity(0.6),
              ),
            ),
          ),
          GestureDetector(
            onLongPress: menuItem.actionOnLongPress == null
                ? null
                : () {
                    HapticFeedback.heavyImpact();
                    menuItem.actionOnLongPress!();
                  },
            child: IconButton(
                padding: EdgeInsetsDirectional.all(buttonPadding),
                onPressed: () {
                  menuItem.action();
                },
                icon: Transform.scale(
                  scale: items[0].iconScale ?? 1,
                  child: Icon(
                    menuItem.icon,
                    color: dynamicPastel(
                      context,
                      Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
                color: dynamicPastel(
                  context,
                  Theme.of(context).colorScheme.onSecondaryContainer,
                )),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool keepOutFirstConsideringHeader = (keepOutFirst &&
            getCenteredTitleSmall(context: context, backButtonEnabled: true) ==
                false) ||
        this.items.length == 1;
    List<DropdownItemMenu> itemsFiltered = [...items];
    if ((keepOutFirstConsideringHeader || forceKeepOutFirst) &&
        items.length > 0) {
      itemsFiltered.removeAt(0);
      if (items.length == 2) itemsFiltered.removeAt(0);
    }

    if (showButtons) {
      return Row(
        children: [
          ...(items).asMap().entries.map((item) {
            int idx = item.key;
            int length = items.length;
            double offsetX = (length - 1 - idx) * 7;
            return Transform.translate(
              offset: Offset(offsetX, 0).withDirectionality(context),
              child: menuIconButtonBuilder(context, item.value),
            );
          })
        ],
      );
    }

    return Row(
      children: [
        if ((keepOutFirstConsideringHeader || forceKeepOutFirst) &&
            items.length > 0)
          Transform.translate(
            offset:
                Offset(itemsFiltered.isNotEmpty || items.length == 2 ? 7 : 0, 0)
                    .withDirectionality(context),
            child: menuIconButtonBuilder(context, items[0]),
          ),
        if ((keepOutFirstConsideringHeader || forceKeepOutFirst) &&
            items.length > 0 &&
            items.length == 2)
          Transform.translate(
            offset: Offset(itemsFiltered.isNotEmpty ? 7 : 0, 0)
                .withDirectionality(context),
            child: menuIconButtonBuilder(context, items[1]),
          ),
        if (itemsFiltered.isNotEmpty)
          PopupMenuButton<String>(
            padding: EdgeInsetsDirectional.all(buttonPadding),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusDirectional.all(
                Radius.circular(getPlatform() == PlatformOS.isIOS ? 5 : 10),
              ),
            ),
            onSelected: (value) {
              for (DropdownItemMenu item in items) {
                if (item.id == value) {
                  item.action();
                  break;
                }
              }
            },
            icon: Icon(
              appStateSettings["outlinedIcons"]
                  ? Icons.more_vert_outlined
                  : Icons.more_vert_rounded,
              color: dynamicPastel(
                context,
                Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
            itemBuilder: (BuildContext context) {
              return itemsFiltered.map((menuItem) {
                return PopupMenuItem<String>(
                  padding: EdgeInsets.zero,
                  height: 0,
                  value: menuItem.id,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onLongPress: menuItem.actionOnLongPress == null
                        ? null
                        : () {
                            maybePopRoute(context);
                            HapticFeedback.heavyImpact();
                            menuItem.actionOnLongPress!();
                          },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      constraints:
                          BoxConstraints(minHeight: kMinInteractiveDimension),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Stack(
                            alignment: AlignmentDirectional.center,
                            children: [
                              BreathingWidget(
                                duration: Duration(milliseconds: 700),
                                endScale: 1.2,
                                child: Transform.scale(
                                  scale: 1.5,
                                  child: Container(
                                    height: 20,
                                    width: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: menuItem.selected
                                          ? Theme.of(context)
                                              .colorScheme
                                              .secondaryContainer
                                          : null,
                                    ),
                                  ),
                                ),
                              ),
                              Transform.scale(
                                scale: menuItem.iconScale ?? 1,
                                child: Icon(menuItem.icon),
                              ),
                            ],
                          ),
                          SizedBox(width: 9),
                          TextFont(
                            text: menuItem.label,
                            fontSize: 14.5,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList();
            },
          ),
      ],
    );
  }
}
