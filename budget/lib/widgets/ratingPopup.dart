import 'dart:async';

import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/popupFramework.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';

class RatingPopup extends StatefulWidget {
  const RatingPopup({super.key});

  @override
  State<RatingPopup> createState() => _RatingPopupState();
}

class _RatingPopupState extends State<RatingPopup> {
  int? selectedStars = null;
  @override
  Widget build(BuildContext context) {
    return PopupFramework(
      title: "Rate Cashew",
      subtitle: "Share your feedback to help improve Cashew",
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < 5; i++)
                Tappable(
                  color: Colors.transparent,
                  borderRadius: 100,
                  onTap: () {
                    setState(() {
                      selectedStars = i;
                    });
                    bottomSheetControllerGlobal.snapToExtent(0);
                    Future.delayed(Duration(milliseconds: 300), () {
                      bottomSheetControllerGlobal.snapToExtent(0);
                    });
                  },
                  child: ScalingWidget(
                    keyToWatch: (i <= (selectedStars ?? 0)).toString(),
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      child: Icon(
                        Icons.star_rounded,
                        key: ValueKey(i <= (selectedStars ?? 0)),
                        size: (getWidthBottomSheet(context) - 125) / 5,
                        color:
                            selectedStars != null && i <= (selectedStars ?? 0)
                                ? Colors.yellow
                                : Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer
                                    .withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 15),
          AnimatedSize(
            duration: Duration(milliseconds: 600),
            curve: Curves.easeInOutCubicEmphasized,
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 200),
              child: selectedStars == null || selectedStars! > 3
                  ? Container(
                      key: ValueKey(0),
                    )
                  : TextInput(
                      labelText: "Feedback",
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      minLines: 3,
                      padding: EdgeInsets.zero,
                    ),
            ),
          ),
          SizedBox(height: 15),
          Button(
            label: "Submit",
            onTap: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }
}

class ScalingWidget extends StatefulWidget {
  final String keyToWatch;
  final Widget child;

  ScalingWidget({required this.keyToWatch, required this.child});

  @override
  _ScalingWidgetState createState() => _ScalingWidgetState();
}

class _ScalingWidgetState extends State<ScalingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isAnimating = false;
  String _currentKey = '';

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant ScalingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.keyToWatch != _currentKey && !_isAnimating) {
      _currentKey = widget.keyToWatch;
      _isAnimating = true;
      _controller.forward().then((value) {
        _controller.reverse().then((value) {
          _isAnimating = false;
        });
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (BuildContext context, Widget? child) {
        return Transform.scale(
          scale: _isAnimating ? _scaleAnimation.value : 1.0,
          child: widget.child,
        );
      },
    );
  }
}
