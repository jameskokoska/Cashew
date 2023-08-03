import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/navigationSidebar.dart';
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
              child: AdaptiveTextSelectionToolbar.buttonItems(
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
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//     color: Colors.transparent,
//     elevation: 0,
//     items: [
//       PopupMenuItem(
//         value: 1,
//         enabled: false,
//         padding: EdgeInsets.zero,
//         child: Row(
//           children: [
//             Tappable(
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: TextFont(text: "Copy"),
//               ),
//               onTap: () {},
//             ),
//             Tappable(
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
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
//         alignment: Alignment.topCenter,
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
//                               alignment: Alignment.topCenter,
//                               child: FadeIn(
//                                 child: ScaleIn(
//                                   child: Column(
//                                     children: [
//                                       ClipRRect(
//                                         borderRadius: BorderRadius.circular(8),
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
//                                                       const EdgeInsets.only(
//                                                     left: 12,
//                                                     right: 6,
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
//                                                       const EdgeInsets.only(
//                                                     right: 12,
//                                                     left: 6,
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
