import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
import '../colors.dart';
import '../functions.dart';

class BudgetContainer extends StatelessWidget {
  BudgetContainer({
    Key? key,
    required this.title,
    required this.color,
    required this.total,
    required this.spent,
  }) : super(key: key);

  final String title;
  final Color color;
  final double total;
  final double spent;

  @override
  Widget build(BuildContext context) {
    var widget = Column(
      children: [
        Container(
          width: double.infinity,
          child: TextFont(
            text: title,
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
              child: TextFont(
                text: convertToMoney(spent),
                fontSize: 20,
                textAlign: TextAlign.left,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 3.0),
              child: Container(
                child: TextFont(
                  text: " spent of " + convertToMoney(total),
                  fontSize: 13,
                  textAlign: TextAlign.left,
                ),
              ),
            ),
          ],
        ),
        BudgetTimeline(
            startDate: "Sept 1",
            endDate: "Oct 1",
            percent: spent / total * 100,
            color: this.color),
        Container(
          height: 14,
        ),
        Center(
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child: TextFont(
              text:
                  "You can keep spending 15\$ each day for the rest of the period.",
              fontSize: 15,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
    return Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(
          horizontal: 15.0,
          vertical: 8,
        ),
        decoration:
            BoxDecoration(borderRadius: BorderRadius.circular(15), boxShadow: [
          BoxShadow(
              color: this.color,
              offset: Offset(0, 4.0),
              blurRadius: 15.0,
              spreadRadius: -5),
        ]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedGooBackground(color: color),
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
        ));
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
        color: this.color,
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
  BudgetTimeline(
      {Key? key,
      required this.startDate,
      required this.endDate,
      required this.percent,
      required this.color})
      : super(key: key);

  final String startDate;
  final String endDate;
  final double percent;
  final Color color;
  double todayPercent = 20;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextFont(
          text: this.startDate,
          fontSize: 12,
        ),
        Expanded(
          child: BudgetProgress(
            color: this.color,
            percent: percent,
            todayPercent: todayPercent,
          ),
        ),
        TextFont(
          text: this.endDate,
          fontSize: 12,
        ),
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
      required this.todayPercent})
      : super(key: key);

  final Color color;
  final double percent;
  final double todayPercent;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomLeft,
      children: [
        Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: darken(color, 0.5)),
            margin: EdgeInsets.symmetric(horizontal: 8),
            height: 20),
        Container(
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
                        color: Colors.white.withOpacity(0.8)),
                  ),
                ],
              ),
            ),
            margin: EdgeInsets.symmetric(horizontal: 8),
            height: 20),
        TodayIndicator(
          percent: todayPercent,
        ),
        Container(
            child: Center(
                child: Padding(
              padding: const EdgeInsets.only(top: 4.3),
              child: TextFont(
                text: percent.toInt().toString() + "%",
                fontSize: 14,
                textAlign: TextAlign.center,
                fontWeight: FontWeight.bold,
              ),
            )),
            height: 22),
      ],
    );
  }
}

class TodayIndicator extends StatelessWidget {
  TodayIndicator({Key? key, required this.percent}) : super(key: key);

  final double percent;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: FractionalOffset(percent / 100, 0),
      child: Container(
        child: Container(
          width: 20,
          height: 39,
          child: OverflowBox(
            maxWidth: 500,
            child: SizedBox(
              width: 38,
              child: Column(
                children: [
                  Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: Theme.of(context).colorScheme.black),
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: 4, right: 5, left: 5, bottom: 3),
                        child: TextFont(
                          textAlign: TextAlign.center,
                          text: "Today",
                          fontSize: 9,
                          textColor: Theme.of(context).colorScheme.white,
                        ),
                      )),
                  Container(
                    width: 3,
                    height: 21,
                    decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.vertical(bottom: Radius.circular(5)),
                        color: Theme.of(context).colorScheme.black),
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
