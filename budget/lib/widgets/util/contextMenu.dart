import 'package:budget/widgets/navigationSidebar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomContextMenu extends StatelessWidget {
  const CustomContextMenu({required this.child, required this.buttonItems, super.key});
  final Widget child;
  final List<ContextMenuButtonItem> buttonItems;

  @override
  Widget build(BuildContext context) {
    return ContextMenuRegion(
      child: child,
      contextMenuBuilder: (context, offset) {
        Offset newOffset =
            Offset(offset.dx - getWidthNavigationSidebar(context), offset.dy);
        return AdaptiveTextSelectionToolbar.buttonItems(
          anchors: TextSelectionToolbarAnchors(
            primaryAnchor: newOffset,
          ),
          buttonItems: buttonItems,
        );
      },
    );
  }
}

typedef ContextMenuBuilder = Widget Function(
    BuildContext context, Offset offset);

/// Shows and hides the context menu based on user gestures.
///
/// By default, shows the menu on right clicks and long presses.
class ContextMenuRegion extends StatefulWidget {
  /// Creates an instance of [ContextMenuRegion].
  const ContextMenuRegion({
    super.key,
    required this.child,
    required this.contextMenuBuilder,
  });

  /// Builds the context menu.
  final ContextMenuBuilder contextMenuBuilder;

  /// The child widget that will be listened to for gestures.
  final Widget child;

  @override
  State<ContextMenuRegion> createState() => _ContextMenuRegionState();
}

class _ContextMenuRegionState extends State<ContextMenuRegion> {
  Offset? _longPressOffset;

  final ContextMenuController _contextMenuController = ContextMenuController();

  static bool get _longPressEnabled {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return true;
      case TargetPlatform.macOS:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return false;
    }
  }

  void _onSecondaryTapUp(TapUpDetails details) {
    _show(details.globalPosition);
  }

  void _onTap() {
    if (!_contextMenuController.isShown) {
      return;
    }
    _hide();
  }

  void _onLongPressStart(LongPressStartDetails details) {
    _longPressOffset = details.globalPosition;
  }

  void _onLongPress() {
    assert(_longPressOffset != null);
    _show(_longPressOffset!);
    _longPressOffset = null;
  }

  void _show(Offset position) {
    _contextMenuController.show(
      context: context,
      contextMenuBuilder: (context) {
        return widget.contextMenuBuilder(context, position);
      },
    );
  }

  void _hide() {
    _contextMenuController.remove();
  }

  @override
  void dispose() {
    _hide();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onSecondaryTapUp: _onSecondaryTapUp,
      onLongPressStart: _onLongPressStart,
      onLongPress: _longPressEnabled ? _onLongPress : null,
      child: Listener(
        onPointerDown: _longPressEnabled
            ? (PointerDownEvent e) {
                _hide();
              }
            : (PointerDownEvent e) {
                _show(e.position);
              },
        child: widget.child,
      ),
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
