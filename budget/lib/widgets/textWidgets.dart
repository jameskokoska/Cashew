import 'package:flutter/material.dart';
import '../colors.dart';

class TextFont extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? textColor;
  final TextAlign textAlign;
  final int? maxLines;
  final bool fixParagraphMargin;

  const TextFont({
    Key? key,
    required this.text,
    this.fontSize = 20,
    this.fontWeight = FontWeight.normal,
    this.textAlign = TextAlign.left,
    this.textColor,
    this.maxLines = null,
    this.fixParagraphMargin = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var finalTextColor;
    if (this.textColor == null) {
      finalTextColor = Theme.of(context).colorScheme.black;
    } else {
      finalTextColor = textColor;
    }
    return Transform.translate(
      offset: Offset(0, this.fontSize * 0.1),
      child: Text(
        '$text',
        maxLines: maxLines,
        textAlign: textAlign,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: this.fontWeight,
          fontSize: this.fontSize,
          fontFamily: 'Avenir',
          color: finalTextColor,
          decoration: TextDecoration.underline,
          decorationStyle: TextDecorationStyle.double,
          decorationColor: Color(0x00FFFFFF),
        ),
      ),
    );
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
