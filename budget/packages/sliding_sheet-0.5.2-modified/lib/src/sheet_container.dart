import 'package:flutter/material.dart';

import 'package:sliding_sheet/src/sheet_listener_builder.dart';

import 'sheet.dart';

// ignore_for_file: public_member_api_docs

class SheetContainer extends StatelessWidget {
  final Duration? duration;
  final double borderRadius;
  final double elevation;
  final Border? border;
  final BorderRadius? customBorders;
  final EdgeInsets? margin;
  final EdgeInsets padding;
  final Widget? child;
  final Color color;
  final Color? shadowColor;
  final List<BoxShadow>? boxShadows;
  final AlignmentGeometry? alignment;
  final BoxConstraints? constraints;
  const SheetContainer({
    Key? key,
    this.duration,
    this.borderRadius = 0.0,
    this.elevation = 0.0,
    this.border,
    this.customBorders,
    this.margin,
    this.padding = const EdgeInsets.all(0),
    this.child,
    this.color = Colors.transparent,
    this.shadowColor = Colors.black12,
    this.boxShadows,
    this.alignment,
    this.constraints,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final br = customBorders ?? BorderRadius.circular(borderRadius);

    final decoration = BoxDecoration(
      color: color,
      borderRadius: br,
      border: border,
      boxShadow: boxShadows ??
          (elevation > 0.0
              ? [
                  BoxShadow(
                    color: shadowColor ?? Colors.black12,
                    blurRadius: elevation,
                    spreadRadius: 0,
                  )
                ]
              : const []),
    );

    final child = ClipRRect(borderRadius: br, child: this.child);

    if (duration == null || duration == Duration.zero) {
      return Container(
        margin: margin,
        padding: padding,
        alignment: alignment,
        constraints: constraints,
        decoration: decoration,
        child: child,
      );
    } else {
      return AnimatedContainer(
        duration: duration!,
        padding: padding,
        alignment: alignment,
        constraints: constraints,
        decoration: decoration,
        child: child,
      );
    }
  }
}

class ElevatedContainer extends StatelessWidget {
  final Color? shadowColor;
  final double elevation;
  final bool Function(SheetState state) elevateWhen;
  final Widget child;
  const ElevatedContainer({
    Key? key,
    required this.shadowColor,
    required this.elevation,
    required this.elevateWhen,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (elevation == 0) return child;

    return SheetListenerBuilder(
      buildWhen: (oldState, newState) =>
          elevateWhen(oldState) != elevateWhen(newState),
      builder: (context, state) {
        return SheetContainer(
          shadowColor: shadowColor,
          elevation: elevateWhen(state) ? elevation : 0.0,
          duration: const Duration(milliseconds: 400),
          child: child,
        );
      },
    );
  }
}
