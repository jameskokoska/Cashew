import 'package:budget/functions.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../colors.dart';

class TextInput extends StatelessWidget {
  final String labelText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final bool obscureText;
  final IconData? icon;
  final EdgeInsets padding;
  final bool autoFocus;
  final VoidCallback? onEditingComplete;
  final String? initialValue;
  final TextEditingController? controller;
  final bool? showCursor;
  final bool readOnly;
  final int? minLines;
  final int? maxLines;
  final bool numbersOnly;
  final String? prefix;
  final String? suffix;
  final double paddingRight;
  final FocusNode? focusNode;
  final bool? bubbly;
  final Color? backgroundColor;
  final TextInputType? keyboardType;
  final double? fontSize;
  final FontWeight fontWeight;
  final double? topContentPadding;
  final TextCapitalization? textCapitalization;
  final BorderRadius? borderRadius;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final TextAlign textAlign;
  final bool autocorrect;

  const TextInput({
    Key? key,
    required this.labelText,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.obscureText = false,
    this.icon,
    this.padding = const EdgeInsets.only(left: 18.0, right: 18),
    this.autoFocus = false,
    this.onEditingComplete,
    this.initialValue,
    this.controller,
    this.showCursor,
    this.readOnly = false,
    this.minLines = 1,
    this.maxLines = 1,
    this.numbersOnly = false,
    this.prefix,
    this.suffix,
    this.paddingRight = 12,
    this.focusNode,
    this.bubbly = true,
    this.backgroundColor,
    this.keyboardType,
    this.fontSize,
    this.fontWeight = FontWeight.normal,
    this.topContentPadding,
    this.textCapitalization,
    this.borderRadius,
    this.textInputAction,
    this.inputFormatters,
    this.textAlign = TextAlign.start,
    this.autocorrect = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Container(
        decoration: BoxDecoration(
          color: bubbly == false
              ? Colors.transparent
              : backgroundColor ??
                  (appStateSettings["materialYou"]
                      ? Theme.of(context).colorScheme.secondaryContainer
                      : getColor(context, "canvasContainer")),
          borderRadius: borderRadius ??
              BorderRadius.circular(getPlatform() == PlatformOS.isIOS ? 8 : 15),
        ),
        child: Center(
          child: TextFormField(
            inputFormatters: inputFormatters,
            textInputAction: textInputAction,
            textCapitalization:
                textCapitalization ?? TextCapitalization.sentences,
            textAlignVertical: kIsWeb ? TextAlignVertical.bottom : null,
            //incognito keyboard
            enableIMEPersonalizedLearning:
                !appStateSettings["incognitoKeyboard"],
            scrollPadding: EdgeInsets.only(bottom: 80),
            focusNode: focusNode,
            keyboardType: keyboardType != null
                ? keyboardType
                : numbersOnly
                    ? TextInputType.number
                    : TextInputType.text,
            maxLines: maxLines,
            minLines: minLines,
            onTap: onTap,
            showCursor: showCursor,
            readOnly: readOnly,
            controller: controller,
            initialValue: initialValue,
            autofocus: autoFocus,
            onEditingComplete: onEditingComplete,
            textAlign: textAlign,
            autocorrect: autocorrect,
            style: TextStyle(
              fontSize:
                  fontSize != null ? fontSize : (bubbly == false ? 18 : 15),
              height: kIsWeb
                  ? null
                  : bubbly == true
                      ? 1.7
                      : 1.3,
              fontWeight: fontWeight,
              fontFamily: appStateSettings["font"],
              fontFamilyFallback: ['Inter'],
            ),
            cursorColor: dynamicPastel(
                context, HexColor(appStateSettings["accentColor"]),
                amount: 0.1, inverse: true),
            decoration: new InputDecoration(
              hintStyle: TextStyle(color: getColor(context, "textLight")),
              alignLabelWithHint: true,
              prefix: prefix != null ? TextFont(text: prefix ?? "") : null,
              suffix: suffix != null ? TextFont(text: suffix ?? "") : null,
              contentPadding: EdgeInsets.only(
                left: bubbly == false ? (kIsWeb ? 8 + 5 : 8) : 18,
                right: (kIsWeb ? paddingRight + 5 : paddingRight),
                top: topContentPadding != null
                    ? topContentPadding ?? 0
                    : (bubbly == false ? 15 : 18),
                bottom: bubbly == false ? (kIsWeb ? 8 : 5) : (kIsWeb ? 15 : 0),
              ),
              hintText: labelText,
              filled: bubbly == false ? true : false,
              fillColor: Colors.transparent,
              isDense: true,
              suffixIconConstraints: BoxConstraints(maxHeight: 20),
              suffixIcon: bubbly == false || icon == null
                  ? null
                  : Padding(
                      padding: const EdgeInsets.only(right: 13.0, left: 5),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Icon(
                            icon,
                            size: 20,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ],
                      ),
                    ),
              icon: bubbly == false
                  ? icon != null
                      ? Icon(
                          icon,
                          size: 30,
                          color: Theme.of(context).colorScheme.secondary,
                        )
                      : null
                  : null,
              enabledBorder: bubbly == false
                  ? UnderlineInputBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(10)),
                      borderSide: BorderSide(
                        color: appStateSettings["materialYou"]
                            ? Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.2)
                            : getColor(context, "lightDarkAccentHeavy"),
                        width: 2,
                      ),
                    )
                  : null,
              hoverColor: bubbly == false
                  ? Theme.of(context)
                      .colorScheme
                      .secondaryContainer
                      .withAlpha(90)
                  : null,
              focusedBorder: bubbly == false
                  ? UnderlineInputBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(5.0)),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 2,
                      ),
                    )
                  : null,
              border: bubbly == false
                  ? null
                  : OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
            ),
            obscureText: obscureText,
            onChanged: (text) {
              if (onChanged != null) {
                onChanged!(text);
              }
            },
            onFieldSubmitted: (text) {
              if (onSubmitted != null) {
                onSubmitted!(text);
              }
            },
          ),
        ),
      ),
    );
  }
}
