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
      alignment: Alignment.bottomLeft,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: progressPercentage <= 0 || progressPercentage >= 1 ? 0 : 3,
        width: MediaQuery.of(context).size.width * progressPercentage,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(5),
            topRight: Radius.circular(5),
          ),
        ),
      ),
    );
  }
}
