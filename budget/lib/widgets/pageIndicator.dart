import 'package:flutter/material.dart';

class PageIndicator extends StatelessWidget {
  final PageController controller;
  final int itemCount;

  PageIndicator({
    required this.controller,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        int currentPage =
            controller.page?.round().toInt() ?? controller.initialPage;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            itemCount,
            (index) {
              return Builder(
                builder: (BuildContext context) {
                  double scaleFactor = (index == currentPage) ? 1.3 : 1.0;
                  Color color = (index == currentPage)
                      ? Theme.of(context).colorScheme.secondary.withOpacity(0.7)
                      : Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.2);
                  return AnimatedScale(
                    duration: Duration(milliseconds: 900),
                    scale: scaleFactor,
                    curve: ElasticOutCurve(0.2),
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 400),
                      child: Container(
                        key: ValueKey(index == currentPage),
                        width: 6,
                        height: 6,
                        margin: EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
