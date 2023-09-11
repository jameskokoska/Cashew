import 'package:budget/widgets/animatedExpanded.dart';
import 'package:flutter/material.dart'
    hide SliverReorderableList, ReorderCallback, ReorderItemProxyDecorator;
import 'package:budget/widgets/editRowEntry.dart';
import 'package:budget/modified/reorderable_list.dart';
import 'dart:async';
// Still in development and testing...
// This widget animates the size of a re-orderable sliver list when something is deleted

// Example:
// StreamBuilder<Map<String, TransactionCategory>>(
// stream: database.watchAllCategoriesMapped(),
// builder: (context, mappedCategoriesSnapshot) {
//   return StreamBuilder<List<TransactionAssociatedTitle>>(
//     stream: database.watchAllAssociatedTitles(
//         searchFor: searchValue == "" ? null : searchValue),
//     builder: (context, snapshot) {
//       // print(snapshot.data);
//       if (snapshot.hasData && (snapshot.data ?? []).length <= 0) {
//         return SliverToBoxAdapter(
//           child: NoResults(
//             message: "no-titles-found".tr(),
//           ),
//         );
//       }
//       if (snapshot.hasData && (snapshot.data ?? []).length > 0) {
//         return ImplicitlyAnimatedDeleteSliverReorderableList(
//           onReorderStart: (index) {
//             HapticFeedback.heavyImpact();
//             setState(() {
//               dragDownToDismissEnabled = false;
//               currentReorder = index;
//             });
//           },
//           onReorderEnd: (_) {
//             setState(() {
//               dragDownToDismissEnabled = true;
//               currentReorder = -1;
//             });
//           },
//           keyGetter: (item) {
//             return item.associatedTitlePk;
//           },
//           data: snapshot.data ?? [],
//           itemBuilder:
//               (context, index, item, canReorder, runWhenDeleted) {
//             TransactionAssociatedTitle associatedTitle = item;
//             return EditRowEntry(
//               canReorder: canReorder == false
//                   ? false
//                   : searchValue == "" &&
//                       (snapshot.data ?? []).length != 1,
//               onTap: () {
//                 openBottomSheet(
//                   context,
//                   fullSnap: true,
//                   AddAssociatedTitlePage(
//                     associatedTitle: associatedTitle,
//                   ),
//                 );
//                 Future.delayed(Duration(milliseconds: 100), () {
//                   // Fix over-scroll stretch when keyboard pops up quickly
//                   bottomSheetControllerGlobal.scrollTo(0,
//                       duration: Duration(milliseconds: 100));
//                 });
//               },
//               padding: EdgeInsets.symmetric(
//                   vertical: 7,
//                   horizontal:
//                       getPlatform() == PlatformOS.isIOS ? 17 : 7),
//               currentReorder:
//                   currentReorder != -1 && currentReorder != index,
//               index: index,
//               content: Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   SizedBox(width: 3),
//                   CategoryIcon(
//                     categoryPk: associatedTitle.categoryFk,
//                     size: 25,
//                     margin: EdgeInsets.zero,
//                     sizePadding: 20,
//                     borderRadius: 1000,
//                     category: mappedCategoriesSnapshot
//                         .data![associatedTitle.categoryFk],
//                   ),
//                   SizedBox(width: 15),
//                   Expanded(
//                     child: TextFont(
//                       text: associatedTitle.title
//                       // +
//                       //     " - " +
//                       //     associatedTitle.order.toString()
//                       ,
//                       fontSize: 16,
//                       maxLines: 3,
//                     ),
//                   ),
//                 ],
//               ),
//               onDelete: () async {
//                 bool result = (await deleteAssociatedTitlePopup(
//                       context,
//                       title: associatedTitle,
//                       routesToPopAfterDelete:
//                           RoutesToPopAfterDelete.None,
//                     )) ==
//                     DeletePopupAction.Delete;
//                 if (result) runWhenDeleted();
//                 return result;
//               },
//               openPage: Container(),
//               key: ValueKey(associatedTitle.associatedTitlePk),
//             );
//           },
//           onReorder: (_intPrevious, _intNew) async {
//             TransactionAssociatedTitle oldTitle =
//                 snapshot.data![_intPrevious];
//             _intNew = snapshot.data!.length - _intNew;
//             _intPrevious = snapshot.data!.length - _intPrevious;
//             if (_intNew > _intPrevious) {
//               await database.moveAssociatedTitle(
//                   oldTitle.associatedTitlePk,
//                   _intNew - 1,
//                   oldTitle.order);
//             } else {
//               await database.moveAssociatedTitle(
//                   oldTitle.associatedTitlePk,
//                   _intNew,
//                   oldTitle.order);
//             }

//             return true;
//           },
//         );
//       }
//       return SliverToBoxAdapter(
//         child: Container(),
//       );
//     },
//   );
// }),

class ImplicitlyAnimatedDeleteSliverReorderableList<T> extends StatefulWidget {
  const ImplicitlyAnimatedDeleteSliverReorderableList({
    super.key,
    required this.data,
    required this.itemBuilder,
    required this.keyGetter,
    required this.onReorder,
    this.onReorderStart,
    this.onReorderEnd,
  });

  final List<T> data;
  // call runWhenDeleted to animate the item to disappear
  final Widget Function(BuildContext context, int index, T item,
      bool canReorder, VoidCallback runWhenDeleted) itemBuilder;
  final String Function(T item) keyGetter;
  final ReorderCallback onReorder;
  final void Function(int)? onReorderStart;
  final void Function(int)? onReorderEnd;

  @override
  State<ImplicitlyAnimatedDeleteSliverReorderableList<T>> createState() =>
      _ImplicitlyAnimatedDeleteSliverReorderableListState<T>();
}

class _ImplicitlyAnimatedDeleteSliverReorderableListState<T>
    extends State<ImplicitlyAnimatedDeleteSliverReorderableList<T>> {
  late List<T> dataList = widget.data;
  int? deletedIndex;
  bool isDeleting = false;
  final Duration fullAnimationDuration = const Duration(milliseconds: 400);
  Timer? completedAnimationTimer;
  @override
  void didUpdateWidget(
      covariant ImplicitlyAnimatedDeleteSliverReorderableList<T> oldWidget) {
    if (isDeleting == false) {
      setState(() {
        dataList = widget.data;
        deletedIndex = null;
      });
    } else if (isDeleting == true) {
      // Something was deleted...
      // print("Something was deleted");
      if (widget.data.length < oldWidget.data.length) {
        isDeleting = false;
      }
      completedAnimationTimer = Timer(fullAnimationDuration, () {
        // print("Completed animation, updating data");
        setState(() {
          dataList = widget.data;
          deletedIndex = null;
        });
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  void runWhenDeleted(int index) {
    if (deletedIndex == null &&
        (completedAnimationTimer?.isActive == false ||
            completedAnimationTimer?.isActive == null)) {
      setState(() {
        isDeleting = true;
        dataList = widget.data;
        deletedIndex = index;
      });
    } else {
      completedAnimationTimer?.cancel;
      setState(() {
        isDeleting = false;
        dataList = widget.data;
        deletedIndex = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverReorderableList(
      itemCount: dataList.length,
      onReorderStart: widget.onReorderStart,
      onReorderEnd: widget.onReorderEnd,
      onReorder: widget.onReorder,
      itemBuilder: (BuildContext context, int index) {
        T item = dataList[index];
        String itemKey = widget.keyGetter(item);
        bool isAnimating = isDeleting == false && deletedIndex == null;
        return AnimatedExpanded(
          duration: fullAnimationDuration,
          key: ValueKey(itemKey),
          expand: deletedIndex != index,
          child: Container(
            key: ValueKey(1),
            child: widget.itemBuilder(
              context,
              index,
              item,
              isAnimating,
              () => runWhenDeleted(deletedIndex == null ? index : index - 5),
            ),
          ),
        );
      },
    );
  }
}
