import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
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
    this.bubbly = false,
    this.backgroundColor,
    this.keyboardType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool _keyboardIsVisible() {
      return !(MediaQuery.of(context).viewInsets.bottom == 0.0);
    }

    return Padding(
      padding: padding,
      child: Container(
        decoration: BoxDecoration(
          color: bubbly == false
              ? Colors.transparent
              : backgroundColor ??
                  Theme.of(context).colorScheme.canvasContainer,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: TextFormField(
            //incognito keyboard
            enableIMEPersonalizedLearning: false,
            scrollPadding: EdgeInsets.only(bottom: 80),
            focusNode: focusNode,
            keyboardType: keyboardType != null
                ? keyboardType
                : numbersOnly
                    ? TextInputType.number
                    : null,
            maxLines: maxLines,
            minLines: minLines,
            onTap: onTap,
            showCursor: showCursor,
            readOnly: readOnly,
            controller: controller,
            initialValue: initialValue,
            autofocus: autoFocus,
            onEditingComplete: onEditingComplete,
            style: TextStyle(
              fontSize: bubbly == false ? 18 : 15,
              height: 1.7,
            ),
            cursorColor: Theme.of(context).colorScheme.accentColorHeavy,
            decoration: new InputDecoration(
              prefix: prefix != null ? TextFont(text: prefix ?? "") : null,
              suffix: suffix != null ? TextFont(text: suffix ?? "") : null,
              contentPadding: EdgeInsets.only(
                left: bubbly == false ? 12 : 18,
                right: paddingRight,
                top: bubbly == false ? 7 : 18,
                bottom: bubbly == false ? 7 : 0,
              ),
              hintText: labelText,
              filled: bubbly == false ? true : false,
              fillColor: Theme.of(context)
                  .colorScheme
                  .lightDarkAccent
                  .withOpacity(0.2),
              isDense: true,
              suffixIconConstraints: BoxConstraints(maxHeight: 20),
              suffixIcon: bubbly == false || icon == null
                  ? null
                  : Padding(
                      padding: const EdgeInsets.only(right: 13.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Icon(
                            icon,
                            size: 20,
                            color:
                                Theme.of(context).colorScheme.accentColorHeavy,
                          ),
                        ],
                      ),
                    ),
              icon: bubbly == false
                  ? icon != null
                      ? Icon(
                          icon,
                          size: 30,
                          color: Theme.of(context).colorScheme.accentColorHeavy,
                        )
                      : null
                  : null,
              enabledBorder: bubbly == false
                  ? UnderlineInputBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(8.0)),
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.lightDarkAccent),
                    )
                  : null,
              focusedBorder: bubbly == false
                  ? UnderlineInputBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(5.0)),
                      borderSide: BorderSide(
                          color:
                              Theme.of(context).colorScheme.accentColorHeavy),
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

class TextInputTitle extends StatelessWidget {
  final String labelText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final bool obscureText;
  final IconData? icon;
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
  final FocusNode? focusNode;
  final Color? backgroundColor;
  final TextInputType? keyboardType;
  final FontWeight fontWeight;
  final double fontSize;

  const TextInputTitle({
    Key? key,
    required this.labelText,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.obscureText = false,
    this.icon,
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
    this.focusNode,
    this.backgroundColor,
    this.keyboardType,
    this.fontWeight = FontWeight.normal,
    this.fontSize = 18,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool _keyboardIsVisible() {
      return !(MediaQuery.of(context).viewInsets.bottom == 0.0);
    }

    return Center(
      child: TextFormField(
        focusNode: focusNode,
        keyboardType: keyboardType != null
            ? keyboardType
            : numbersOnly
                ? TextInputType.number
                : null,
        maxLines: maxLines,
        minLines: minLines,
        onTap: onTap,
        showCursor: showCursor,
        readOnly: readOnly,
        controller: controller,
        initialValue: initialValue,
        autofocus: autoFocus,
        onEditingComplete: onEditingComplete,
        style: TextStyle(
          fontSize: fontSize,
          height: 1.7,
          fontWeight: fontWeight,
        ),
        cursorColor: Theme.of(context).colorScheme.accentColorHeavy,
        decoration: new InputDecoration(
          prefix: prefix != null ? TextFont(text: prefix ?? "") : null,
          suffix: suffix != null ? TextFont(text: suffix ?? "") : null,
          contentPadding:
              EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
          hintText: labelText,
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.textLight),
          filled: false,
          isDense: true,
          suffixIconConstraints: BoxConstraints(maxHeight: 20),
          suffixIcon: icon == null
              ? null
              : Padding(
                  padding: const EdgeInsets.only(right: 13.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Icon(
                        icon,
                        size: 20,
                        color: Theme.of(context).colorScheme.accentColorHeavy,
                      ),
                    ],
                  ),
                ),
          icon: icon != null
              ? Icon(
                  icon,
                  size: 30,
                  color: Theme.of(context).colorScheme.accentColorHeavy,
                )
              : null,
          enabledBorder: UnderlineInputBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
            borderSide: BorderSide(
                color: Theme.of(context).colorScheme.lightDarkAccentHeavy),
          ),
          focusedBorder: UnderlineInputBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(5.0)),
            borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary, width: 1.5),
          ),
          border: OutlineInputBorder(
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
    );
  }
}
