import 'package:budget/functions.dart';
import 'package:flutter/material.dart';

class LinearGradientFadedEdges extends StatelessWidget {
  const LinearGradientFadedEdges({
    required this.child,
    this.enableStart = true,
    this.enableEnd = true,
    this.enableTop = true,
    this.enableBottom = true,
    this.gradientSize = 12,
    this.gradientColor,
    super.key,
  });
  final Widget child;
  final bool enableStart;
  final bool enableEnd;
  final bool enableTop;
  final bool enableBottom;
  final double gradientSize;
  final Color? gradientColor;

  @override
  Widget build(BuildContext context) {
    // positioned cannot contain negative values
    // If it does, it will clip shadows for some reason...
    Color gradientColorFiltered =
        gradientColor ?? Theme.of(context).colorScheme.background;
    return Stack(
      children: [
        child,
        if (enableStart)
          PositionedDirectional(
            start: 0,
            top: 0,
            bottom: 0,
            child: Transform.translate(
              offset: Offset(-1, 0).withDirectionality(context),
              child: IgnorePointer(
                child: Container(
                  width: gradientSize,
                  foregroundDecoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        gradientColorFiltered,
                        gradientColorFiltered.withOpacity(0.0),
                      ],
                      begin: AlignmentDirectional.centerStart,
                      end: AlignmentDirectional.centerEnd,
                      stops: [0.1, 1],
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (enableEnd)
          PositionedDirectional(
            end: 0,
            top: 0,
            bottom: 0,
            child: Transform.translate(
              offset: Offset(1, 0).withDirectionality(context),
              child: IgnorePointer(
                child: Container(
                  width: gradientSize,
                  foregroundDecoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        gradientColorFiltered,
                        gradientColorFiltered.withOpacity(0.0),
                      ],
                      begin: AlignmentDirectional.centerEnd,
                      end: AlignmentDirectional.centerStart,
                      stops: [0.1, 1],
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (enableTop)
          PositionedDirectional(
            end: 0,
            start: 0,
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
                      begin: AlignmentDirectional.topCenter,
                      end: AlignmentDirectional.bottomCenter,
                      stops: [0.1, 1],
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (enableBottom)
          PositionedDirectional(
            end: 0,
            start: 0,
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
                      begin: AlignmentDirectional.bottomCenter,
                      end: AlignmentDirectional.topCenter,
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
