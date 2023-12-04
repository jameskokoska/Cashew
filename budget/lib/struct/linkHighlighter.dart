import 'package:budget/colors.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:flutter/material.dart';

String addInvisibleSpace(String original, String newString) {
  if (newString.length >= original.length) {
    return original;
  }

  // Replace characters in newString with zero-width spaces
  String modifiedString = newString;

  for (int i = newString.length; i < original.length; i++) {
    modifiedString += '\u200b'; // Zero-width space
  }
  return modifiedString;
}

class LinkHighlighter extends TextEditingController {
  final Pattern pattern;

  LinkHighlighter({String? initialText})
      : pattern = RegExp(r'https?:\/\/(?:www\.)?\S+(?=\s)') {
    this.text = initialText ?? '';
  }
  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    List<InlineSpan> children = [];
    text.splitMapJoin(
      pattern,
      onMatch: (Match match) {
        String websiteNameClean = getDomainNameFromURL(match[0] ?? "");
        children.add(
          TextSpan(
            text:
                addInvisibleSpace(match[0] ?? "", " " + websiteNameClean + " "),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              backgroundColor: dynamicPastel(
                context,
                Theme.of(context).colorScheme.primary.withOpacity(0.5),
                inverse: true,
                amountDark: 0.1,
                amountLight: 0.25,
              ),
            ),
          ),
        );
        return match[0] ?? "";
      },
      onNonMatch: (String text) {
        children.add(TextSpan(text: text, style: style));
        return text;
      },
    );
    return TextSpan(style: style, children: children);
  }
}
