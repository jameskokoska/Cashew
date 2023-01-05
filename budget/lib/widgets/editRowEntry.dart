import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:flutter/material.dart';

class EditRowEntry extends StatelessWidget {
  const EditRowEntry(
      {required this.index,
      required this.content,
      required this.backgroundColor,
      required this.openPage,
      required this.onDelete,
      this.onTap,
      this.padding,
      this.currentReorder = false,
      this.canReorder = true,
      this.canDelete = true,
      this.extraIcon,
      this.onExtra,
      Key? key})
      : super(key: key);
  final int index;
  final Widget content;
  final Color backgroundColor;
  final Widget openPage;
  final VoidCallback onDelete;
  final EdgeInsets? padding;
  final bool currentReorder;
  final bool canReorder;
  final bool canDelete;
  final IconData? extraIcon;
  final VoidCallback? onExtra;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    Widget container = OpenContainerNavigation(
      openPage: openPage,
      closedColor: backgroundColor,
      borderRadius: 18,
      button: (openContainer) {
        return Tappable(
          borderRadius: 18,
          color: backgroundColor,
          onTap: () {
            if (onTap != null)
              onTap!();
            else
              openContainer();
          },
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Container(
                    padding: padding ??
                        EdgeInsets.only(
                          left: 25,
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
        );
      },
    );
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
