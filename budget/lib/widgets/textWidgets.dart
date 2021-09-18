import 'package:flutter/material.dart';
import '../colors.dart';

class TextFont extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? textColor;
  final TextAlign textAlign;
  final int? maxLines;

  const TextFont(
      {Key? key,
      required this.text,
      this.fontSize = 20,
      this.fontWeight = FontWeight.normal,
      this.textAlign = TextAlign.left,
      this.textColor,
      this.maxLines = null})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var finalTextColor;
    if (this.textColor == null) {
      finalTextColor = Theme.of(context).colorScheme.black;
    } else {
      finalTextColor = textColor;
    }
    return Text(
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
          decorationColor: Color(0x00FFFFFF)),
    );
  }
}
