import 'dart:math';

import 'package:budget/database/tables.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class CountUp extends StatefulWidget {
  const CountUp({
    Key? key,
    required this.count,
    this.fontSize = 16,
    this.prefix = "",
    this.suffix = "",
    this.fontWeight = FontWeight.normal,
    this.textAlign = TextAlign.start,
    this.textColor,
    this.maxLines = null,
    this.duration = const Duration(milliseconds: 3000),
    this.decimals = 2,
    this.curve = Curves.easeOutExpo,
    this.walletPkForCurrency,
  }) : super(key: key);

  final double count;
  final double fontSize;
  final String prefix;
  final String suffix;
  final FontWeight fontWeight;
  final Color? textColor;
  final TextAlign textAlign;
  final int? maxLines;
  final Duration duration;
  final int decimals;
  final Curve curve;
  final int? walletPkForCurrency;

  @override
  State<CountUp> createState() => _CountUpState();
}

class _CountUpState extends State<CountUp> {
  @override
  Widget build(BuildContext context) {
    if (appStateSettings["batterySaver"]) {
      return TextFont(
        text: widget.prefix +
            (widget.count).toStringAsFixed(widget.decimals) +
            widget.suffix,
        fontSize: widget.fontSize,
        fontWeight: widget.fontWeight,
        textAlign: widget.textAlign,
        textColor: widget.textColor,
        maxLines: widget.maxLines,
      );
    }
    return TweenAnimationBuilder<int>(
      tween: IntTween(
          begin: 0, end: (widget.count * pow(10, widget.decimals)).toInt()),
      duration: widget.duration,
      curve: widget.curve,
      builder: (BuildContext context, int animatedCount, Widget? child) {
        String countString = animatedCount.toString();
        return TextFont(
          text: widget.prefix +
              (countString.length >= widget.decimals + 1
                  ? countString.substring(
                      0, countString.length - widget.decimals)
                  : "0") +
              (widget.decimals > 0 ? "." : "") +
              (countString.length >= widget.decimals
                  ? countString.substring(countString.length - widget.decimals)
                  : countString.substring(countString.length - 1)) +
              widget.suffix,
          fontSize: widget.fontSize,
          fontWeight: widget.fontWeight,
          textAlign: widget.textAlign,
          textColor: widget.textColor,
          maxLines: widget.maxLines,
        );
      },
    );
  }
}

bool isWholeNumber(num value) => value is int || value == value.roundToDouble();

class CountNumber extends StatefulWidget {
  const CountNumber({
    Key? key,
    required this.count,
    required this.textBuilder,
    this.fontSize = 16,
    this.duration = const Duration(milliseconds: 1000),
    this.curve = Curves.easeOutQuint,
    this.initialCount = 0,
    this.decimals,
    this.lazyFirstRender = true,
  }) : super(key: key);

  final double count;
  final Widget Function(double amount) textBuilder;
  final double fontSize;
  final Duration duration;
  final Curve curve;
  final double initialCount;
  final int? decimals;
  final bool lazyFirstRender;

  @override
  State<CountNumber> createState() => _CountNumberState();
}

class _CountNumberState extends State<CountNumber> {
  late double previousAmount = widget.initialCount;
  late bool lazyFirstRender = widget.lazyFirstRender;

  @override
  Widget build(BuildContext context) {
    int decimals = 0;

    if (isWholeNumber(double.parse(widget.count.toStringAsFixed(
        widget.decimals ??
            (Provider.of<AllWallets>(context)
                    .indexedByPk[appStateSettings["selectedWalletPk"]]
                    ?.decimals ??
                2))))) {
      decimals = 0;
    } else {
      int currentSelectedDecimals = Provider.of<AllWallets>(context)
              .indexedByPk[appStateSettings["selectedWalletPk"]]
              ?.decimals ??
          2;
      decimals = ((widget.decimals ?? currentSelectedDecimals) > 2
          ? widget.count.toString().split('.')[1].length <
                  (widget.decimals ?? currentSelectedDecimals)
              ? widget.count.toString().split('.')[1].length
              : (widget.decimals ?? currentSelectedDecimals)
          : (widget.decimals ?? currentSelectedDecimals));
    }

    if (appStateSettings["batterySaver"]) {
      return widget.textBuilder(widget.count);
    }

    if (lazyFirstRender && widget.initialCount == widget.count) {
      lazyFirstRender = false;
      return widget.textBuilder(
        double.parse((widget.count).toStringAsFixed(decimals)),
      );
    }

    Widget builtWidget = TweenAnimationBuilder<int>(
      tween: IntTween(
        begin: (double.parse((previousAmount).toStringAsFixed(decimals)) *
                pow(10, decimals))
            .round(),
        end: (double.parse((widget.count).toStringAsFixed(decimals)) *
                pow(10, decimals))
            .round(),
      ),
      duration: widget.duration,
      curve: widget.curve,
      builder: (BuildContext context, int animatedCount, Widget? child) {
        return widget.textBuilder(
          animatedCount / pow(10, decimals).toDouble(),
        );
      },
    );

    previousAmount = widget.count;
    return builtWidget;
  }
}
