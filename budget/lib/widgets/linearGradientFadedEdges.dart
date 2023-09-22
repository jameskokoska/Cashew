import 'package:flutter/material.dart';

class LinearGradientFadedEdges extends StatelessWidget {
  const LinearGradientFadedEdges({
    required this.child,
    this.enableLeft = true,
    this.enableRight = true,
    this.enableTop = true,
    this.enableBottom = true,
    this.gradientSize = 12,
    this.gradientColor,
    super.key,
  });
  final Widget child;
  final bool enableLeft;
  final bool enableRight;
  final bool enableTop;
  final bool enableBottom;
  final double gradientSize;
  final Color? gradientColor;

  @override
  Widget build(BuildContext context) {
    // positioned cannot contain negative values
    // If it does, it will clip shadows for some reason...
    Color gradientColorFiltered =
        gradientColor ?? Theme.of(context).canvasColor;
    return Stack(
      children: [
        child,
        if (enableLeft)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Transform.translate(
              offset: Offset(-1, 0),
              child: IgnorePointer(
                child: Container(
                  width: gradientSize,
                  foregroundDecoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        gradientColorFiltered,
                        gradientColorFiltered.withOpacity(0.0),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      stops: [0.1, 1],
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (enableRight)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Transform.translate(
              offset: Offset(1, 0),
              child: IgnorePointer(
                child: Container(
                  width: gradientSize,
                  foregroundDecoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        gradientColorFiltered,
                        gradientColorFiltered.withOpacity(0.0),
                      ],
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      stops: [0.1, 1],
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (enableTop)
          Positioned(
            right: 0,
            left: 0,
            top: 0,
            child: Transform.translate(
              offset: Offset(0, -1),
              child: IgnorePointer(
                child: Container(
                  height: gradientSize,
                  foregroundDecoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        gradientColorFiltered,
                        gradientColorFiltered.withOpacity(0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.1, 1],
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (enableBottom)
          Positioned(
            right: 0,
            left: 0,
            bottom: 0,
            child: Transform.translate(
              offset: Offset(0, 1),
              child: IgnorePointer(
                child: Container(
                  height: gradientSize,
                  foregroundDecoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        gradientColorFiltered,
                        gradientColorFiltered.withOpacity(0.0),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      stops: [0.1, 1],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
