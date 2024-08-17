import 'package:budget/colors.dart';
import 'package:budget/functions.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomContextMenu extends StatelessWidget {
  const CustomContextMenu(
      {required this.buttonItems, required this.tappableBuilder, super.key});
  final List<ContextMenuButtonItem> buttonItems;
  final Widget Function(VoidCallback onLongPress) tappableBuilder;

  @override
  Widget build(BuildContext context) {
    return ContextMenuRegion(
      tappableBuilder: tappableBuilder,
      contextMenuBuilder: (context, offset) {
        Offset newOffset = Offset(
            offset.dx - getWidthNavigationSidebar(context),
            offset.dy - (kIsWeb ? 0 : 15));
        return Stack(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapDown: (_) {
                ContextMenuController.removeAny();
              },
              onVerticalDragDown: (_) {
                ContextMenuController.removeAny();
              },
              onHorizontalDragDown: (_) {
                ContextMenuController.removeAny();
              },
            ),
            FadeIn(
              duration: Duration(milliseconds: 125),
              child: getPlatform() == PlatformOS.isAndroid
                  ? CustomTabBar.buttonItems(
                      anchors: TextSelectionToolbarAnchors(
                        primaryAnchor: newOffset,
                      ),
                      buttonItems: buttonItems,
                    )
                  : AdaptiveTextSelectionToolbar.buttonItems(
                      anchors: TextSelectionToolbarAnchors(
                        primaryAnchor: newOffset,
                      ),
                      buttonItems: buttonItems,
                    ),
            ),
          ],
        );
      },
    );
  }
}

typedef ContextMenuBuilder = Widget Function(
    BuildContext context, Offset offset);

class ContextMenuRegion extends StatefulWidget {
  const ContextMenuRegion({
    super.key,
    required this.contextMenuBuilder,
    required this.tappableBuilder,
  });

  final ContextMenuBuilder contextMenuBuilder;

  final Widget Function(VoidCallback onLongPress) tappableBuilder;

  @override
  State<ContextMenuRegion> createState() => _ContextMenuRegionState();
}

class _ContextMenuRegionState extends State<ContextMenuRegion> {
  final ContextMenuController _contextMenuController = ContextMenuController();

  void show() {
    HapticFeedback.mediumImpact();
    _contextMenuController.show(
      context: context,
      contextMenuBuilder: (context) {
        return widget.contextMenuBuilder(context, position);
      },
    );
  }

  @override
  void dispose() {
    _contextMenuController.remove();
    super.dispose();
  }

  Offset position = Offset(0, 0);

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (PointerDownEvent e) {
        setState(() {
          position = e.position;
        });
      },
      child: widget.tappableBuilder(() {
        show();
      }),
    );
  }
}

class CustomTabBar extends AdaptiveTextSelectionToolbar {
  const CustomTabBar({
    super.key,
    required this.children,
    required this.anchors,
  })  : buttonItems = null,
        super(children: children, anchors: anchors);

  const CustomTabBar.buttonItems({
    super.key,
    required this.buttonItems,
    required this.anchors,
  })  : children = null,
        super(children: const [], anchors: anchors);

  final List<ContextMenuButtonItem>? buttonItems;
  final List<Widget>? children;
  final TextSelectionToolbarAnchors anchors;

  @override
  Widget build(BuildContext context) {
    if ((children != null && children!.isEmpty) ||
        (buttonItems != null && buttonItems!.isEmpty)) {
      return const SizedBox.shrink();
    }

    final List<Widget> resultChildren = children != null
        ? children!
        : AdaptiveTextSelectionToolbar.getAdaptiveButtons(context, buttonItems!)
            .toList();

    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
        return TextSelectionToolbar(
          anchorAbove: anchors.primaryAnchor,
          anchorBelow: anchors.secondaryAnchor == null
              ? anchors.primaryAnchor
              : anchors.secondaryAnchor!,
          children: resultChildren,
          toolbarBuilder: (BuildContext context, Widget child) {
            return _TextSelectionToolbarContainer(
              child: child,
            );
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _TextSelectionToolbarContainer extends StatelessWidget {
  const _TextSelectionToolbarContainer({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Material(
      borderRadius: const BorderRadius.all(Radius.circular(9)),
      clipBehavior: Clip.antiAlias,
      color: getToolbarColor(context, theme.colorScheme),
      elevation: 1.0,
      type: MaterialType.card,
      child: child,
    );
  }
}

Color getToolbarColor(BuildContext context, ColorScheme colorScheme) {
  return dynamicPastel(context, colorScheme.secondaryContainer,
      amountDark: 0.5, amountLight: 0.8);
}

Widget contextMenuBuilder(
    BuildContext context, EditableTextState editableTextState) {
  List<ContextMenuButtonItem> buttonItems =
      editableTextState.contextMenuButtonItems;
  final List<Widget> buttons = <Widget>[];
  for (int i = 0; i < buttonItems.length; i++) {
    final ContextMenuButtonItem buttonItem = buttonItems[i];
    buttons.add(
      Tappable(
        color: getToolbarColor(context, Theme.of(context).colorScheme),
        onTap: buttonItem.onPressed,
        child: ConstrainedBox(
          constraints: new BoxConstraints(
              minHeight:
                  const Size(kMinInteractiveDimension, kMinInteractiveDimension)
                      .height,
              minWidth:
                  const Size(kMinInteractiveDimension, kMinInteractiveDimension)
                      .width),
          child: Padding(
            padding: TextSelectionToolbarTextButton.getPadding(
                i, buttonItems.length),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFont(
                  fontSize: 14,
                  text: AdaptiveTextSelectionToolbar.getButtonLabel(
                    context,
                    buttonItem,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  // Offset primaryAnchor = editableTextState.contextMenuAnchors.primaryAnchor;
  // Offset? secondaryAnchor =
  //     editableTextState.contextMenuAnchors.secondaryAnchor;
  // TextSelectionToolbarAnchors anchor = TextSelectionToolbarAnchors(
  //   primaryAnchor: Offset(
  //     primaryAnchor.dx + getWidthNavigationSidebar(context),
  //     primaryAnchor.dy,
  //   ),
  //   secondaryAnchor: secondaryAnchor == null
  //       ? null
  //       : (Offset(
  //           secondaryAnchor.dx,
  //           secondaryAnchor.dy,
  //         )),
  // );
  return getPlatform() == PlatformOS.isAndroid
      ? CustomTabBar(
          anchors: editableTextState.contextMenuAnchors,
          children: buttons,
        )
      : AdaptiveTextSelectionToolbar.editableText(
          editableTextState: editableTextState,
        );
}

// Another method using showMenu built in

// void showContextMenu(BuildContext context, Offset position) async {
//   final RenderBox overlay =
//       Overlay.of(context).context.findRenderObject() as RenderBox;

//   // Calculate the position of the tap relative to the overlay
//   final RelativeRect positionRelativeRect = RelativeRect.fromRect(
//     Rect.fromPoints(position, position),
//     Offset.zero & overlay.size,
//   );

//   await showMenu(
//     context: context,
//     position: positionRelativeRect,
//     shape: RoundedRectangleBorder(borderRadius: BorderRadiusDirectional.circular(8)),
//     color: Colors.transparent,
//     elevation: 0,
//     items: [
//       PopupMenuItem(
//         value: 1,
//         enabled: false,
//         padding: EdgeInsetsDirectional.zero,
//         child: Row(
//           children: [
//             Tappable(
//               child: Padding(
//                 padding: const EdgeInsetsDirectional.all(8.0),
//                 child: TextFont(text: "Copy"),
//               ),
//               onTap: () {},
//             ),
//             Tappable(
//               child: Padding(
//                 padding: const EdgeInsetsDirectional.all(8.0),
//                 child: TextFont(text: "Paste"),
//               ),
//               onTap: () {},
//             )
//           ],
//         ),
//       ),
//     ],
//   );
// }


// Need to Wrap entire app in ContextMenuWrap
// and import this package: defer_pointer: ^0.0.2

// class OverlayButtonWrapper extends StatefulWidget {
//   final Widget child;

//   OverlayButtonWrapper({
//     required this.child,
//   });

//   @override
//   _OverlayButtonWrapperState createState() => _OverlayButtonWrapperState();
// }

// class _OverlayButtonWrapperState extends State<OverlayButtonWrapper> {
//   final key = GlobalKey();
//   final OverlayPortalController _tooltipController = OverlayPortalController();
//   bool isShowing = false;
//   Size childSize = Size(0, 0);

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onLongPress: () {
//         _tooltipController.show();
//         setState(() {
//           isShowing = true;
//         });
//       },
//       child: Stack(
//         clipBehavior: Clip.none,
//         fit: StackFit.loose,
//         alignment: AlignmentDirectional.topCenter,
//         children: [
//           WidgetSize(
//             onChange: (size) {
//               setState(() {
//                 childSize = size;
//               });
//             },
//             child: widget.child,
//           ),
//           isShowing
//               ? WidgetPosition(
//                   onChange: (position) {},
//                   child: Positioned.fill(
//                     child: Transform.translate(
//                       offset: Offset(0, -childSize.height + 20),
//                       child: OverflowBox(
//                         minWidth: 0,
//                         maxWidth: double.infinity,
//                         child: SizedBox(
//                           key: key,
//                           child: ContextMenuBox(
//                             child: Align(
//                               alignment: AlignmentDirectional.topCenter,
//                               child: FadeIn(
//                                 child: ScaleIn(
//                                   child: Column(
//                                     children: [
//                                       ClipRRect(
//                                         borderRadius: BorderRadiusDirectional.circular(8),
//                                         child: DeferPointer(
//                                           child: Row(
//                                             mainAxisSize: MainAxisSize.min,
//                                             children: [
//                                               Tappable(
//                                                 onTap: () {
//                                                   _tooltipController.hide();
//                                                   setState(() {
//                                                     isShowing = false;
//                                                   });
//                                                 },
//                                                 color: getColor(context,
//                                                     "lightDarkAccentHeavy"),
//                                                 child: Padding(
//                                                   padding:
//                                                       const EdgeInsetsDirectional.only(
//                                                     start: 12,
//                                                     end: 6,
//                                                     top: 12.0,
//                                                     bottom: 12,
//                                                   ),
//                                                   child: TextFont(
//                                                     text: "Copy",
//                                                     fontSize: 14,
//                                                   ),
//                                                 ),
//                                               ),
//                                               Tappable(
//                                                 onTap: () {
//                                                   _tooltipController.hide();
//                                                   setState(() {
//                                                     isShowing = false;
//                                                   });
//                                                 },
//                                                 color: getColor(context,
//                                                     "lightDarkAccentHeavy"),
//                                                 child: Padding(
//                                                   padding:
//                                                       const EdgeInsetsDirectional.only(
//                                                     end: 12,
//                                                     start: 6,
//                                                     top: 12.0,
//                                                     bottom: 12,
//                                                   ),
//                                                   child: TextFont(
//                                                     text: "Paste",
//                                                     fontSize: 14,
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                       ClipPath(
//                                         clipper: TriangleClipper(),
//                                         child: Container(
//                                           color: getColor(
//                                               context, "lightDarkAccentHeavy"),
//                                           height: 7,
//                                           width: 15,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 )
//               : SizedBox.shrink(),
//         ],
//       ),
//     );
//   }
// }

// class ContextMenuHitBox extends RenderProxyBox {
//   ContextMenuHitBox();
// }

// class ContextMenuBox extends SingleChildRenderObjectWidget {
//   ContextMenuBox({required Widget child, Key? key})
//       : super(child: child, key: key);

//   @override
//   ContextMenuHitBox createRenderObject(BuildContext context) {
//     return ContextMenuHitBox();
//   }
// }

// class ContextMenuWrap extends StatelessWidget {
//   const ContextMenuWrap({required this.child, super.key});
//   final Widget child;

//   @override
//   Widget build(BuildContext context) {
//     return DeferredPointerHandler(
//       child: child,
//     );
//   }
// }

// class TriangleClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     final path = Path();
//     path.lineTo(size.width, 0.0);
//     path.lineTo(size.width / 2, size.height);
//     path.close();
//     return path;
//   }

//   @override
//   bool shouldReclip(TriangleClipper oldClipper) => false;
// }
