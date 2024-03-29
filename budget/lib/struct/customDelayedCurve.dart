import 'package:flutter/material.dart';

class CustomDelayedCurve extends Curve {
  final double delayPercentage;
  final Curve innerCurve;

  CustomDelayedCurve(
      {this.delayPercentage = 0.25, this.innerCurve = Curves.easeInOut});

  @override
  double transformInternal(double t) {
    if (t < delayPercentage) {
      return 0.0;
    } else {
      return innerCurve
          .transform((t - delayPercentage) / (1 - delayPercentage));
    }
  }
}
