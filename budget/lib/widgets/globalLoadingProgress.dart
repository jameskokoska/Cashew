import 'package:budget/colors.dart';
import 'package:budget/pages/pastBudgetsPage.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/util/debouncer.dart';
import 'package:flutter/material.dart';

class GlobalLoadingProgress extends StatefulWidget {
  const GlobalLoadingProgress({
    Key? key,
  }) : super(key: key);

  @override
  State<GlobalLoadingProgress> createState() => GlobalLoadingProgressState();
}

class GlobalLoadingProgressState extends State<GlobalLoadingProgress> {
  double progressPercentage = 0;
  void setProgressPercentage(double percent) {
    setState(() {
      progressPercentage = percent;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: getIsFullScreen(context) == false
          ? Alignment.bottomLeft
          : Alignment.topCenter,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: progressPercentage <= 0 || progressPercentage >= 1 ? 0 : 3,
        width: MediaQuery.of(context).size.width * progressPercentage,
        decoration: BoxDecoration(
          color: dynamicPastel(context, Theme.of(context).colorScheme.primary,
              amount: 0.5),
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(5),
            topRight: Radius.circular(5),
          ),
        ),
      ),
    );
  }
}

class GlobalLoadingIndeterminate extends StatefulWidget {
  const GlobalLoadingIndeterminate({
    Key? key,
  }) : super(key: key);

  @override
  State<GlobalLoadingIndeterminate> createState() =>
      GlobalLoadingIndeterminateState();
}

class GlobalLoadingIndeterminateState
    extends State<GlobalLoadingIndeterminate> {
  bool visible = false;
  double opacity = 0;
  // Set the timeout for loading indicator
  final _debouncer = Debouncer(milliseconds: 5000);

  void setVisibility(bool visible, {double? opacity}) {
    setState(() {
      this.visible = visible;
      this.opacity = visible == false ? 1 : opacity ?? 1;
    });
    _debouncer.run(() {
      setState(() {
        this.visible = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: SizedBox(
        width: getIsFullScreen(context) == false
            ? null
            : getWidthNavigationSidebar(context),
        child: Align(
          alignment: getIsFullScreen(context) == false
              ? Alignment.bottomLeft
              : Alignment.topCenter,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: !visible ? 0 : 3,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(5),
                topRight: Radius.circular(5),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(5),
                topRight: Radius.circular(5),
              ),
              child: LinearProgressIndicator(
                color: dynamicPastel(
                    context, Theme.of(context).colorScheme.primary,
                    amount: 0.5),
                backgroundColor: getColor(context, "white"),
                minHeight: 3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
