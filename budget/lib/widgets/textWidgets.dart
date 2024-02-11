import 'dart:io';

import 'package:budget/colors.dart';
import 'package:budget/struct/settings.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

// Don't use Inter or the offset
Set<String> fallbackFontLocales = {
  "zh",
  "zh_Hant",
  "ja",
};

class TextFont extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? textColor;
  final TextAlign textAlign;
  final int? maxLines;
  final bool fixParagraphMargin;
  final bool? shadow;
  final bool autoSizeText;
  final double? minFontSize;
  final double? maxFontSize;
  final TextOverflow? overflow;
  final Widget? overflowReplacement;
  final bool? softWrap;
  final List<TextSpan>? richTextSpan;
  final bool selectableText;
  final Widget Function(BuildContext, EditableTextState)? contextMenuBuilder;

  const TextFont({
    Key? key,
    required this.text,
    this.fontSize = 20,
    this.fontWeight = FontWeight.normal,
    this.textAlign = TextAlign.start,
    this.textColor,
    this.maxLines = null,
    this.fixParagraphMargin = false,
    this.shadow = false,
    this.selectableText = false,
    this.contextMenuBuilder = null,
    this.richTextSpan,
    this.autoSizeText = false,
    this.maxFontSize,
    this.minFontSize,
    this.overflow,
    this.softWrap,
    this.overflowReplacement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color finalTextColor = textColor ?? getColor(context, "black");
    if (appStateSettings["increaseTextContrast"] == true) {
      double threshold =
          Theme.of(context).brightness == Brightness.light ? 0.7 : 0.65;
      if (finalTextColor.alpha.toDouble() < (255 * threshold)) {
        finalTextColor = finalTextColor.withOpacity(1 * threshold);
      }
    }

    final TextStyle textStyle = TextStyle(
      fontWeight: this.fontWeight,
      fontSize: this.fontSize,
      fontFamily: fallbackFontLocales.contains(appStateSettings["locale"]) &&
              appStateSettings["font"] == "Avenir"
          ? "DMSans"
          : appStateSettings["font"],
      fontFamilyFallback: ['Inter'],
      color: finalTextColor,
      decoration: TextDecoration.underline,
      decorationStyle: TextDecorationStyle.double,
      decorationColor: Color(0x00FFFFFF),
      overflow: overflow,
      shadows: shadow == true
          ? [
              Shadow(
                offset: Offset(0.0, 0.5),
                blurRadius: 8.0,
                color: Color(0x65000000),
              ),
            ]
          : [],
    );
    Widget textWidget(textPassed) {
      return AnimatedDefaultTextStyle(
        duration: Duration(milliseconds: 200),
        style: textStyle,
        child: Transform.translate(
          offset: Offset(
            0,
            this.fontSize *
                (fallbackFontLocales.contains(appStateSettings["locale"]) ==
                            true ||
                        appStateSettings["font"] != "Avenir"
                    ? 0
                    : 0.1),
          ),
          child: selectableText == true
              ? SelectableText(
                  textPassed,
                  maxLines: maxLines,
                  textAlign: textAlign,
                  contextMenuBuilder: contextMenuBuilder,
                )
              : richTextSpan != null
                  ? RichText(
                      textScaleFactor: MediaQuery.of(context).textScaleFactor,
                      textAlign: textAlign,
                      maxLines: maxLines,
                      overflow: overflow ?? TextOverflow.ellipsis,
                      text: TextSpan(
                        text: textPassed,
                        children: richTextSpan,
                      ),
                    )
                  : autoSizeText
                      ? AutoSizeText(
                          textPassed,
                          maxLines: maxLines,
                          textAlign: textAlign,
                          overflow: overflowReplacement != null
                              ? null
                              : overflow ?? TextOverflow.ellipsis,
                          minFontSize: minFontSize ?? fontSize - 10,
                          maxFontSize: maxFontSize ?? fontSize + 10,
                          softWrap: softWrap,
                          overflowReplacement: overflowReplacement,
                        )
                      : Text(
                          textPassed,
                          maxLines: maxLines,
                          textAlign: textAlign,
                          overflow: overflow ?? TextOverflow.ellipsis,
                          softWrap: softWrap,
                        ),
        ),
      );
    }

    return textWidget(text);
  }
}

List<TextSpan> generateSpans({
  required BuildContext context,
  required String mainText,
  required String? boldedText,
  required double fontSize,
}) {
  List<TextSpan> spans = [];
  if (boldedText != null) {
    mainText = mainText.replaceAllMapped(
        RegExp(boldedText, caseSensitive: false), (match) => boldedText);
  }
  final List<String> textParts = mainText.split(boldedText ?? "");

  TextStyle textStyle = TextStyle(
    color: getColor(context, "black"),
    fontFamily: appStateSettings["font"],
    fontFamilyFallback: ['Inter'],
    fontSize: fontSize,
  );

  for (int i = 0; i < textParts.length; i++) {
    spans.add(
      TextSpan(
        text: textParts[i],
        style: textStyle,
      ),
    );

    if (i < textParts.length - 1) {
      spans.add(TextSpan(
        text: boldedText,
        style: textStyle.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ));
    }
  }

  return spans;
}
