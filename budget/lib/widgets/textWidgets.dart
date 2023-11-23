import 'package:budget/colors.dart';
import 'package:budget/struct/settings.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

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
      fontFamily: appStateSettings["font"],
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
          offset: Offset(0,
              this.fontSize * (appStateSettings["font"] == "Avenir" ? 0.1 : 0)),
          child: selectableText == true
              ? SelectableText(
                  textPassed,
                  maxLines: maxLines,
                  textAlign: textAlign,
                  contextMenuBuilder: contextMenuBuilder,
                )
              : richTextSpan != null
                  ? RichText(
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

class TextHeader extends StatelessWidget {
  const TextHeader({required this.text, Key? key}) : super(key: key);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).canvasColor,
      child: Padding(
        padding:
            const EdgeInsets.only(left: 18.0, right: 18, top: 10, bottom: 5),
        child: TextFont(
          text: text,
          fontSize: 33,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
