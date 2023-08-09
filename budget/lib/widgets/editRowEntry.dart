import 'package:budget/colors.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:flutter/material.dart'
    hide
        SliverReorderableList,
        ReorderableDragStartListener,
        ReorderableDelayedDragStartListener;
import 'package:budget/modified/reorderable_list.dart';

class EditRowEntry extends StatelessWidget {
  const EditRowEntry(
      {required this.index,
      required this.content,
      this.accentColor,
      required this.openPage,
      required this.onDelete,
      this.onTap,
      this.padding,
      this.currentReorder = false,
      this.canReorder = true,
      this.canDelete = true,
      this.extraIcon,
      this.onExtra,
      this.extraWidget,
      this.extraWidgetsBelow,
      this.showMoreWidget,
      Key? key})
      : super(key: key);
  final int index;
  final Widget content;
  final Color? accentColor;
  final Widget openPage;
  final VoidCallback onDelete;
  final EdgeInsets? padding;
  final bool currentReorder;
  final bool canReorder;
  final bool canDelete;
  final IconData? extraIcon;
  final VoidCallback? onExtra;
  final Widget? extraWidget;
  final List<Widget>? extraWidgetsBelow;
  final Function()? onTap;
  final Widget? showMoreWidget;

  @override
  Widget build(BuildContext context) {
    Color containerColor = getPlatform() == PlatformOS.isIOS
        ? Theme.of(context).canvasColor
        : appStateSettings["materialYou"]
            ? dynamicPastel(
                context,
                Theme.of(context).colorScheme.secondaryContainer,
                amount: 0.5,
              )
            : getColor(context, "lightDarkAccentHeavyLight");
    double borderRadius = getPlatform() == PlatformOS.isIOS ? 0 : 18;
    Widget container = Container(
      decoration: BoxDecoration(
        boxShadow: getPlatform() == PlatformOS.isIOS
            ? []
            : appStateSettings["materialYou"]
                ? []
                : boxShadowCheck(boxShadowGeneral(context)),
      ),
      child: OpenContainerNavigation(
        openPage: openPage,
        closedColor: containerColor,
        borderRadius: borderRadius,
        button: (openContainer) {
          return Tappable(
            borderRadius: borderRadius,
            color: containerColor,
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
              if (onTap != null)
                onTap!();
              else
                openContainer();
            },
            child: Column(
              children: [
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      accentColor != null
                          ? Container(
                              width: getPlatform() == PlatformOS.isIOS ? 4 : 5,
                              color: dynamicPastel(
                                context,
                                accentColor!,
                                amount: 0.1,
                                inverse: true,
                              ),
                            )
                          : SizedBox.shrink(),
                      Expanded(
                        child: Container(
                          padding: padding ??
                              EdgeInsets.only(
                                left: 25 - 3,
                                right: 10,
                                top: 15,
                                bottom: 15,
                              ),
                          child: content,
                        ),
                      ),
                      extraIcon != null
                          ? Tappable(
                              color: Colors.transparent,
                              borderRadius: borderRadius,
                              child: Container(
                                height: double.infinity,
                                width: 40,
                                child: ScaledAnimatedSwitcher(
                                  keyToWatch: extraIcon.toString(),
                                  child: Icon(
                                    extraIcon,
                                  ),
                                ),
                              ),
                              onTap: onExtra,
                            )
                          : SizedBox.shrink(),
                      extraWidget ?? SizedBox.shrink(),
                      canDelete
                          ? Tappable(
                              color: Colors.transparent,
                              borderRadius: borderRadius,
                              child: Container(
                                  height: double.infinity,
                                  width: 40,
                                  child: Icon(Icons.delete_rounded)),
                              onTap: onDelete,
                            )
                          : SizedBox.shrink(),
                      canReorder
                          ? ReorderableDragStartListener(
                              index: index,
                              child: Tappable(
                                color: Colors.transparent,
                                borderRadius: borderRadius,
                                child: Container(
                                    margin: EdgeInsets.only(
                                        right: showMoreWidget == null ? 10 : 0),
                                    width: 40,
                                    height: double.infinity,
                                    child: Icon(Icons.drag_handle_rounded)),
                                onTap: () {},
                              ),
                            )
                          : Opacity(
                              opacity: 0.2,
                              child: Container(
                                margin: EdgeInsets.only(right: 10),
                                width: 40,
                                height: double.infinity,
                                child: Icon(Icons.drag_handle_rounded),
                              ),
                            ),
                      showMoreWidget ?? SizedBox.shrink(),
                    ],
                  ),
                ),
                ...(extraWidgetsBelow ?? [])
              ],
            ),
          );
        },
      ),
    );
    // alternative theme:
    // container = OpenContainerNavigation(
    //   openPage: openPage,
    //   closedColor: dynamicPastel(context, accentColor, amount: 0.6),
    //   borderRadius: 15,
    //   button: (openContainer) {
    //     return Tappable(
    //       borderRadius: 15,
    //       color: dynamicPastel(context, accentColor, amount: 0.6),
    //       onTap: () {
    //         FocusScopeNode currentFocus = FocusScope.of(context);
    //         if (!currentFocus.hasPrimaryFocus) {
    //           currentFocus.unfocus();
    //         }
    //         if (onTap != null)
    //           onTap!();
    //         else
    //           openContainer();
    //       },
    //       child: Container(
    //         decoration: BoxDecoration(
    //           border: Border.all(
    //             color: dynamicPastel(
    //                 context,
    //                 dynamicPastel(context, accentColor,
    //                     inverse: true, amount: 0.3),
    //                 amount: 0.3),
    //             width: 2,
    //           ),
    //           borderRadius: BorderRadius.circular(15),
    //         ),
    //         child: IntrinsicHeight(
    //           child: Row(
    //             crossAxisAlignment: CrossAxisAlignment.center,
    //             mainAxisSize: MainAxisSize.max,
    //             children: [
    //               Expanded(
    //                 child: Container(
    //                   padding: padding ??
    //                       EdgeInsets.only(
    //                         left: 25,
    //                         right: 10,
    //                         top: 15,
    //                         bottom: 15,
    //                       ),
    //                   child: content,
    //                 ),
    //               ),
    //               extraIcon != null
    //                   ? Tappable(
    //                       color: Colors.transparent,
    //                       borderRadius: 18,
    //                       child: Container(
    //                           height: double.infinity,
    //                           width: 40,
    //                           child: Icon(extraIcon)),
    //                       onTap: onExtra,
    //                     )
    //                   : SizedBox.shrink(),
    //               canDelete
    //                   ? Tappable(
    //                       color: Colors.transparent,
    //                       borderRadius: 18,
    //                       child: Container(
    //                           height: double.infinity,
    //                           width: 40,
    //                           child: Icon(Icons.delete_rounded)),
    //                       onTap: onDelete,
    //                     )
    //                   : SizedBox.shrink(),
    //               canReorder
    //                   ? ReorderableDragStartListener(
    //                       index: index,
    //                       child: Tappable(
    //                         color: Colors.transparent,
    //                         borderRadius: 18,
    //                         child: Container(
    //                             margin: EdgeInsets.only(right: 10),
    //                             width: 40,
    //                             height: double.infinity,
    //                             child: Icon(Icons.drag_handle_rounded)),
    //                         onTap: () {},
    //                       ),
    //                     )
    //                   : Opacity(
    //                       opacity: 0.2,
    //                       child: Container(
    //                         margin: EdgeInsets.only(right: 10),
    //                         width: 40,
    //                         height: double.infinity,
    //                         child: Icon(Icons.drag_handle_rounded),
    //                       ),
    //                     ),
    //             ],
    //           ),
    //         ),
    //       ),
    //     );
    //   },
    // );
    if (!canReorder) {
      return Column(
        children: [
          getPlatform() == PlatformOS.isIOS && index == 0
              ? Container(
                  height: 1.5,
                  color: getColor(context, "dividerColor"),
                )
              : SizedBox.shrink(),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: getPlatform() == PlatformOS.isIOS ? 0 : 10,
                vertical: getPlatform() == PlatformOS.isIOS ? 0 : 5),
            child: container,
          ),
          getPlatform() == PlatformOS.isIOS
              ? Container(
                  height: 1.5,
                  color: getColor(context, "dividerColor"),
                )
              : SizedBox.shrink(),
        ],
      );
    }
    return AnimatedOpacity(
      duration: Duration(milliseconds: 200),
      opacity: currentReorder ? 0.6 : 1,
      child: Column(
        children: [
          getPlatform() == PlatformOS.isIOS && index == 0
              ? Container(
                  height: 1.5,
                  color: getColor(context, "dividerColor"),
                )
              : SizedBox.shrink(),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: getPlatform() == PlatformOS.isIOS ? 0 : 10,
                vertical: getPlatform() == PlatformOS.isIOS ? 0 : 5),
            child: ReorderableDelayedDragStartListener(
              index: index,
              child: container,
            ),
          ),
          getPlatform() == PlatformOS.isIOS
              ? Container(
                  height: 1.5,
                  color: getColor(context, "dividerColor"),
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }
}
