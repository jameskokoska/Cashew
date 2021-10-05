import 'package:flutter/material.dart';
import '../colors.dart';

class TextInput extends StatelessWidget {
  final String labelText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool obscureText;
  final IconData? icon;
  final EdgeInsets padding;

  const TextInput({
    Key? key,
    required this.labelText,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.icon,
    this.padding = const EdgeInsets.only(left: 18.0, right: 18),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: TextField(
        style: TextStyle(
          fontSize: 18,
        ),
        cursorColor: Theme.of(context).colorScheme.accentColorHeavy,
        decoration: new InputDecoration(
          contentPadding:
              EdgeInsets.only(left: 10, right: 10, top: 15, bottom: 10),
          hintText: labelText,
          filled: true,
          fillColor:
              Theme.of(context).colorScheme.lightDarkAccent.withOpacity(0.2),
          isDense: true,
          icon: icon != null
              ? Icon(
                  icon,
                  size: 40,
                  color: Theme.of(context).colorScheme.accentColorHeavy,
                )
              : null,
          enabledBorder: UnderlineInputBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
            borderSide: BorderSide(
                color: Theme.of(context).colorScheme.lightDarkAccent),
          ),
          focusedBorder: UnderlineInputBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(5.0)),
            borderSide: BorderSide(
                color: Theme.of(context).colorScheme.accentColorHeavy),
          ),
        ),
        obscureText: obscureText,
        onChanged: (text) {
          if (onChanged != null) {
            onChanged!(text);
          }
        },
        onSubmitted: (text) {
          if (onSubmitted != null) {
            onSubmitted!(text);
          }
        },
      ),
    );
  }
}
