import 'package:budget/widgets/transactionEntry/transactionEntry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class SwipeToSelectTransactions extends StatefulWidget {
  const SwipeToSelectTransactions({
    super.key,
    required this.listID,
    required this.child,
  });

  final String listID;
  final Widget child;

  @override
  State<SwipeToSelectTransactions> createState() =>
      _SwipeToSelectTransactionsState();
}

//If 1, selecting, if -1 deselecting
int selectingTransactionsActive = 0;

class _SwipeToSelectTransactionsState extends State<SwipeToSelectTransactions> {
  final key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerMove: (PointerEvent event) {
        // reference: https://stackoverflow.com/questions/70277515/how-can-i-select-widgets-by-dragging-over-them-but-also-clicking-them-individual
        final RenderBox box =
            key.currentContext!.findAncestorRenderObjectOfType<RenderBox>()!;
        final result = BoxHitTestResult();
        Offset local = box.globalToLocal(event.position);
        if (box.hitTest(result, position: local)) {
          for (final hit in result.path) {
            final target = hit.target;
            if (target is TransactionEntryHitBox) {
              if (selectingTransactionsActive == 0) {
                return;
              }
              if (target.transactionKey != null) {
                if (selectingTransactionsActive == 1) {
                  if (!globalSelectedID.value[widget.listID]!
                      .contains(target.transactionKey!)) {
                    globalSelectedID.value[widget.listID]!
                        .add(target.transactionKey!);
                    globalSelectedID.notifyListeners();
                    HapticFeedback.selectionClick();
                  }
                } else if (selectingTransactionsActive == -1) {
                  if (globalSelectedID.value[widget.listID]!
                      .contains(target.transactionKey!)) {
                    globalSelectedID.value[widget.listID]!
                        .remove(target.transactionKey);
                    globalSelectedID.notifyListeners();
                    HapticFeedback.selectionClick();
                  }
                }
              }
            }
          }
        }
      },
      onPointerUp: (_) {
        selectingTransactionsActive = 0;
      },
      child: SizedBox(
        key: key,
        child: widget.child,
      ),
    );
  }
}
