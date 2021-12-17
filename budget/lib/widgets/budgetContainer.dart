import 'package:budget/pages/budgetPage.dart';
import 'package:animations/animations.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
import '../colors.dart';
import '../functions.dart';
import '../struct/budget.dart';

class BudgetContainer extends StatelessWidget {
  BudgetContainer({Key? key, required this.budget}) : super(key: key);

  final BudgetOld budget;

  @override
  Widget build(BuildContext context) {
    var widget = Column(
      children: [
        Container(
          width: double.infinity,
          child: TextFont(
            text: budget.title,
            fontWeight: FontWeight.bold,
            fontSize: 25,
            textAlign: TextAlign.left,
          ),
        ),
        Container(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              child: CountUp(
                count: budget.spent,
                prefix: getCurrencyString(),
                duration: Duration(milliseconds: 1500),
                fontSize: 18,
                textAlign: TextAlign.left,
                fontWeight: FontWeight.bold,
                decimals: moneyDecimals(budget.spent),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(bottom: 3.0),
              child: TextFont(
                text: " left of " + convertToMoney(budget.total),
                fontSize: 13,
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
        BudgetTimeline(budget: budget),
        Container(
          height: 14,
        ),
        DaySpending(budget: budget),
      ],
    );
    return OpenContainer<bool>(
      transitionType: ContainerTransitionType.fadeThrough,
      openBuilder: (BuildContext context, VoidCallback _) {
        return BudgetPage(budget: budget);
      },
      onClosed: () {}(),
      closedColor: Theme.of(context).canvasColor,
      tappable: false,
      closedShape: const RoundedRectangleBorder(),
      middleColor: Theme.of(context).colorScheme.white,
      transitionDuration: Duration(milliseconds: 500),
      closedElevation: 0.0,
      openColor: Theme.of(context).canvasColor,
      closedBuilder: (BuildContext _, VoidCallback openContainer) {
        return GestureDetector(
          onTap: () {
            openContainer();
          },
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(
              horizontal: 15.0,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: budget.color.withOpacity(0.8),
                  offset: Offset(0, 4.0),
                  blurRadius: 15.0,
                  spreadRadius: -5,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AnimatedGooBackground(
                        color: budget.color.withOpacity(0.8)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 25.0,
                      vertical: 20,
                    ),
                    child: widget,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class DaySpending extends StatelessWidget {
  const DaySpending(
      {Key? key, required BudgetOld this.budget, bool this.large = false})
      : super(key: key);

  final BudgetOld budget;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.fitWidth,
        child: TextFont(
          text: "You can keep spending 15\$ each day.",
          fontSize: large ? 17 : 15,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class AnimatedGooBackground extends StatelessWidget {
  const AnimatedGooBackground({
    Key? key,
    required this.color,
  });

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.white,
        backgroundBlendMode: BlendMode.srcOver,
      ),
      child: PlasmaRenderer(
        type: PlasmaType.infinity,
        particles: 10,
        color: this.color.withOpacity(0.5),
        blur: 0.5,
        size: 1.3,
        speed: 2.9,
        offset: 0,
        blendMode: BlendMode.srcOver,
        particleType: ParticleType.atlas,
        variation1: 0,
        variation2: 0,
        variation3: 0,
        rotation: 0,
      ),
    );
  }
}

class BudgetTimeline extends StatelessWidget {
  BudgetTimeline({Key? key, required this.budget, this.large = false})
      : super(key: key);

  final BudgetOld budget;
  final double todayPercent = 45;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            large
                ? Container()
                : TextFont(
                    text: getWordedDateShort(budget.startDate),
                    fontSize: large ? 16 : 12,
                  ),
            Expanded(
              child: BudgetProgress(
                color: budget.color,
                percent: budget.getPercent(),
                todayPercent: todayPercent,
                large: large,
              ),
            ),
            large
                ? Container()
                : TextFont(
                    text: getWordedDateShort(budget.startDate),
                    fontSize: large ? 16 : 12,
                  ),
          ],
        ),
        large
            ? Container(
                padding: EdgeInsets.only(top: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextFont(
                      text: getWordedDateShortMore(budget.startDate),
                      fontSize: large ? 15 : 12,
                    ),
                    TextFont(
                      text: getWordedDateShortMore(budget.startDate),
                      fontSize: large ? 15 : 12,
                    ),
                  ],
                ),
              )
            : Container()
      ],
    );
  }
}

//put the today marker in
//use proper date time objects
class BudgetProgress extends StatelessWidget {
  BudgetProgress(
      {Key? key,
      required this.color,
      required this.percent,
      required this.todayPercent,
      this.large = false})
      : super(key: key);

  final Color color;
  final double percent;
  final double todayPercent;
  final bool large;

  @override
  Widget build(BuildContext context) {
    var percentText = Container(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 4.3),
          child: CountUp(
            count: percent,
            textColor: Colors.black,
            decimals: 0,
            suffix: "%",
            fontSize: large ? 16 : 14,
            textAlign: TextAlign.center,
            fontWeight: FontWeight.bold,
            curve: Curves.decelerate,
            duration: Duration(milliseconds: 1500),
          ),
        ),
      ),
    );
    return Stack(
      alignment: Alignment.bottomLeft,
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: darken(color, 0.5)),
          margin: EdgeInsets.symmetric(horizontal: 8),
          height: large ? 25 : 20,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SlideFadeTransition(
              animationDuration: Duration(milliseconds: 1400),
              reverse: true,
              direction: Direction.horizontal,
              child: Container(
                  child: FractionallySizedBox(
                    heightFactor: 1,
                    widthFactor: percent / 100,
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: Colors
                                  .red), //can change this color to tint the progress bar
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        percent > 40 ? percentText : Container(),
                      ],
                    ),
                  ),
                  height: large ? 25 : 20),
            ),
          ),
        ),
        TodayIndicator(
          percent: todayPercent,
          large: large,
        ),
        percent <= 40 ? percentText : Container(),
      ],
    );
  }
}

class TodayIndicator extends StatelessWidget {
  TodayIndicator({Key? key, required this.percent, this.large = false})
      : super(key: key);

  final double percent;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: FractionalOffset(percent / 100, 0),
      child: Container(
        child: Container(
          width: 20,
          height: large ? 45 : 39,
          child: OverflowBox(
            maxWidth: 500,
            child: SizedBox(
              width: 38,
              child: Column(
                children: [
                  SlideFadeTransition(
                    child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: Theme.of(context).colorScheme.black),
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: 4, right: 5, left: 5, bottom: 3),
                          child: TextFont(
                            textAlign: TextAlign.center,
                            text: "Today",
                            fontSize: large ? 10 : 9,
                            textColor: Theme.of(context).colorScheme.white,
                          ),
                        )),
                  ),
                  FadeIn(
                    child: Container(
                      width: 3,
                      height: large ? 26 : 21,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.vertical(bottom: Radius.circular(5)),
                        color: Theme.of(context)
                            .colorScheme
                            .black
                            .withOpacity(0.4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
