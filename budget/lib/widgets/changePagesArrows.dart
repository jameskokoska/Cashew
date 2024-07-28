import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:flutter/material.dart';

class ChangePagesArrows extends StatelessWidget {
  const ChangePagesArrows(
      {required this.onArrowLeft,
      required this.onArrowRight,
      required this.child,
      super.key});
  final VoidCallback onArrowLeft;
  final VoidCallback onArrowRight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        getIsFullScreen(context) == false
            ? SizedBox.shrink()
            : Padding(
                padding: const EdgeInsetsDirectional.all(8.0),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: IconButton(
                      padding: EdgeInsetsDirectional.all(15),
                      icon: Icon(
                        appStateSettings["outlinedIcons"]
                            ? Icons.arrow_left_outlined
                            : Icons.arrow_left_rounded,
                        size: 30,
                      ),
                      onPressed: onArrowLeft),
                ),
              ),
        getIsFullScreen(context) == false
            ? SizedBox.shrink()
            : Padding(
                padding: const EdgeInsetsDirectional.all(8.0),
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: IconButton(
                      padding: EdgeInsetsDirectional.all(15),
                      icon: Icon(
                        appStateSettings["outlinedIcons"]
                            ? Icons.arrow_right_outlined
                            : Icons.arrow_right_rounded,
                        size: 30,
                      ),
                      onPressed: onArrowRight),
                ),
              ),
      ],
    );
  }
}
