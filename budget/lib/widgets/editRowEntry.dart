import 'package:budget/colors.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:flutter/material.dart'
    hide
        SliverReorderableList,
        ReorderableDragStartListener,
        ReorderableDelayedDragStartListener;
import 'package:budget/struct/reorderable_list.dart';

class EditRowEntry extends StatelessWidget {
  const EditRowEntry(
      {required this.index,
      required this.content,
      this.backgroundColor,
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
      Key? key})
      : super(key: key);
  final int index;
  final Widget content;
  final Color? backgroundColor;
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

  @override
  Widget build(BuildContext context) {
    Widget container = Container(
      decoration: BoxDecoration(
        boxShadow: appStateSettings["materialYou"]
            ? []
            : boxShadowCheck(boxShadowGeneral(context)),
      ),
      child: OpenContainerNavigation(
        openPage: openPage,
        closedColor: appStateSettings["materialYou"]
            ? dynamicPastel(
                context,
                Theme.of(context).colorScheme.secondaryContainer,
                amount: 0.5,
              )
            : getColor(context, "lightDarkAccentHeavyLight"),
        borderRadius: 18,
        button: (openContainer) {
          return Tappable(
            borderRadius: 18,
            color: appStateSettings["materialYou"]
                ? dynamicPastel(
                    context,
                    Theme.of(context).colorScheme.secondaryContainer,
                    amount: 0.5,
                  )
                : getColor(context, "lightDarkAccentHeavyLight"),
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
                      backgroundColor != null
                          ? Container(
                              width: 5,
                              color: dynamicPastel(
                                context,
                                backgroundColor!,
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
                              borderRadius: 18,
                              child: Container(
                                  height: double.infinity,
                                  width: 40,
                                  child: Icon(extraIcon)),
                              onTap: onExtra,
                            )
                          : SizedBox.shrink(),
                      extraWidget ?? SizedBox.shrink(),
                      canDelete
                          ? Tappable(
                              color: Colors.transparent,
                              borderRadius: 18,
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
                                borderRadius: 18,
                                child: Container(
                                    margin: EdgeInsets.only(right: 10),
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
    //   closedColor: dynamicPastel(context, backgroundColor, amount: 0.6),
    //   borderRadius: 15,
    //   button: (openContainer) {
    //     return Tappable(
    //       borderRadius: 15,
    //       color: dynamicPastel(context, backgroundColor, amount: 0.6),
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
    //                 dynamicPastel(context, backgroundColor,
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
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: container,
      );
    }
    return AnimatedOpacity(
      duration: Duration(milliseconds: 200),
      opacity: currentReorder ? 0.6 : 1,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: ReorderableDelayedDragStartListener(
          index: index,
          child: container,
        ),
      ),
    );
  }
}
