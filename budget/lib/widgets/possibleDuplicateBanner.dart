import 'package:budget/colors.dart';
import 'package:budget/struct/dedupeLedger.dart';
import 'package:budget/struct/settings.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Reusable banner rendered on [AddTransactionPage] when an ambiguous / uncertain
/// match is detected across notification or payment sources within the deduplication window.
class PossibleDuplicateBanner extends StatelessWidget {
  final DedupeEntryRecord? matchedEntry;
  final VoidCallback? onDismiss;

  const PossibleDuplicateBanner({
    Key? key,
    this.matchedEntry,
    this.onDismiss,
  }) : super(key: key ?? const ValueKey('possibleDuplicateBanner'));

  @override
  Widget build(BuildContext context) {
    final warningColor = getColor(context, 'warningOrange');
    String titleText = 'possible-duplicate-detected'.tr();
    if (titleText == 'possible-duplicate-detected') {
      titleText = 'Possible duplicate detected';
    }
    String fallbackDesc = 'possible-duplicate-description'.tr();
    if (fallbackDesc == 'possible-duplicate-description') {
      fallbackDesc =
          'A similar transaction was recorded recently. Please review details before saving.';
    }

    final String matchedDetails;
    if (matchedEntry != null) {
      final amountPart = matchedEntry!.amountNormalized != null
          ? '${matchedEntry!.currency ?? ''} ${matchedEntry!.amountNormalized}'
              .trim()
          : '';
      final titlePart = matchedEntry!.title ?? '';
      if (amountPart.isNotEmpty && titlePart.isNotEmpty) {
        matchedDetails = '$amountPart • $titlePart';
      } else if (amountPart.isNotEmpty) {
        matchedDetails = amountPart;
      } else if (titlePart.isNotEmpty) {
        matchedDetails = titlePart;
      } else {
        matchedDetails = fallbackDesc;
      }
    } else {
      matchedDetails = fallbackDesc;
    }

    return Container(
      margin:
          const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsetsDirectional.all(12),
      decoration: BoxDecoration(
        color: warningColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: warningColor.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            appStateSettings['outlinedIcons'] == true
                ? Icons.warning_amber_outlined
                : Icons.warning_amber_rounded,
            color: warningColor,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  titleText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  matchedDetails,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ),
          if (onDismiss != null)
            IconButton(
              key: const ValueKey('dismissPossibleDuplicateBanner'),
              visualDensity: VisualDensity.compact,
              icon: Icon(
                appStateSettings['outlinedIcons'] == true
                    ? Icons.close_outlined
                    : Icons.close_rounded,
                size: 20,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              onPressed: onDismiss,
            ),
        ],
      ),
    );
  }
}
