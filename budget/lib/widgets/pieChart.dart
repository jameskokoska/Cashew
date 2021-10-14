import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class PieChartWrapper extends StatelessWidget {
  const PieChartWrapper({Key? key, required this.data}) : super(key: key);
  final List<double> data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      child: Stack(
        children: [
          PieChartDisplay(
            data: data,
          ),
          IgnorePointer(
            child: Center(
              child: Container(
                width: 90,
                height: 90,
                decoration:
                    BoxDecoration(color: Colors.black, shape: BoxShape.circle),
              ),
            ),
          ),
          IgnorePointer(
            child: Center(
              child: Container(
                width: 115,
                height: 115,
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    shape: BoxShape.circle),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PieChartDisplay extends StatefulWidget {
  PieChartDisplay({Key? key, required this.data}) : super(key: key);
  final List<double> data;

  @override
  State<StatefulWidget> createState() => PieChartDisplayState();
}

class PieChartDisplayState extends State<PieChartDisplay> {
  int touchedIndex = -1;
  Duration animationDuration = Duration(milliseconds: 1200);
  Duration animationDurationAfter = Duration(milliseconds: 800);
  Curve animationCurve = Curves.decelerate;
  Curve animationCurveAfter = Curves.elasticOut;

  List<double> data = [-1];
  @override
  void initState() {
    super.initState();
    print(widget.data);
    Future.delayed(Duration(milliseconds: 10), () {
      setState(() {
        data = widget.data;
      });
    });
    Future.delayed(animationDuration, () {
      animationDuration = animationDurationAfter;
      animationCurve = animationCurveAfter;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PieChart(
        PieChartData(
            pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
              setState(() {
                if (!event.isInterestedForInteractions ||
                    pieTouchResponse == null ||
                    pieTouchResponse.touchedSection == null) {
                  return;
                }
                if (event.runtimeType == FlTapDownEvent &&
                    touchedIndex !=
                        pieTouchResponse.touchedSection!.touchedSectionIndex) {
                  print("event");
                  touchedIndex =
                      pieTouchResponse.touchedSection!.touchedSectionIndex;
                } else if (event.runtimeType == FlTapDownEvent) {
                  touchedIndex = -1;
                }
              });
            }),
            borderData: FlBorderData(
              show: false,
            ),
            sectionsSpace: 0,
            centerSpaceRadius: 0,
            sections: showingSections()),
        swapAnimationDuration: animationDuration,
        swapAnimationCurve: animationCurve);
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(widget.data.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 20.0 : 16.0;
      final radius = isTouched ? 110.0 : 100.0;
      final widgetSize = isTouched ? 55.0 : 40.0;
      if (data[0] == -1 && i == 0) {
        return PieChartSectionData(
          color: const Color(0x00000000),
          value: 100,
          showTitle: false,
          radius: 0,
        );
      } else if (i == widget.data.length) {
        return PieChartSectionData(
          color: const Color(0x00FF0202),
          value: 0,
          showTitle: false,
          radius: 0,
        );
      } else if (data[0] == -1) {
        return PieChartSectionData(
          color: const Color(0xFFFF0202),
          value: 0,
          showTitle: false,
          radius: 0,
        );
      } else {
        return PieChartSectionData(
          color: Colors.purple[i * 100] ?? Colors.purple,
          value: data[i],
          title: data[i].toString() + '%',
          radius: radius,
          titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff)),
          badgeWidget: _Badge(
            'assets/librarian-svgrepo-com.svg',
            size: widgetSize,
            borderColor: Colors.purple[i * 100] ?? Colors.purple,
          ),
          titlePositionPercentageOffset: 1.4,
          badgePositionPercentageOffset: .98,
        );
      }
    });
  }
}

class _Badge extends StatelessWidget {
  final String svgAsset;
  final double size;
  final Color borderColor;

  const _Badge(
    this.svgAsset, {
    Key? key,
    required this.size,
    required this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      curve: Curves.elasticOut,
      duration: Duration(milliseconds: 800),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
      ),
      padding: EdgeInsets.all(size * .15),
      child: Center(
          child: Icon(
        Icons.umbrella,
        color: Colors.black,
      )),
    );
  }
}
