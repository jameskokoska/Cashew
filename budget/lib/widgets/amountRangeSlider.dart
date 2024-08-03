import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/selectAmount.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

RangeValues orderAndBoundRangeValues(
    double start, double end, double min, double max) {
  double orderedStart = start < end ? start : end;
  double orderedEnd = start < end ? end : start;

  orderedStart = orderedStart.clamp(min, max);
  orderedEnd = orderedEnd.clamp(min, max);

  return RangeValues(orderedStart, orderedEnd);
}

class AmountRangeSlider extends StatefulWidget {
  const AmountRangeSlider({
    required this.rangeLimit,
    required this.onChange,
    required this.initialRange,
    super.key,
  });
  final RangeValues rangeLimit;
  final RangeValues? initialRange;
  final Function(RangeValues) onChange;
  @override
  State<AmountRangeSlider> createState() => _AmountSlideRangerState();
}

class _AmountSlideRangerState extends State<AmountRangeSlider> {
  late RangeValues _currentRangeValues;

  @override
  void initState() {
    _currentRangeValues = widget.initialRange ??
        RangeValues(widget.rangeLimit.start, widget.rangeLimit.end);
    super.initState();
  }

  updateRange(RangeValues range) {
    widget.onChange(range);
    setState(() {
      _currentRangeValues = range;
    });
  }

  void resetRange() {
    updateRange(orderAndBoundRangeValues(
      widget.rangeLimit.start,
      widget.rangeLimit.end,
      widget.rangeLimit.start,
      widget.rangeLimit.end,
    ));
  }

  void setLowerRangePopup() async {
    double lowerRange = _currentRangeValues.start;
    // Result will be false if we reset the amount
    dynamic result = await openBottomSheet(
      context,
      PopupFramework(
        title: "set-lower-range".tr(),
        child: Column(
          children: [
            SelectAmount(
              amountPassed: lowerRange.toString(),
              setSelectedAmount: (amount, _) {
                lowerRange = amount;
              },
              hideNextButton: true,
            ),
            Row(
              children: [
                Expanded(
                  child: Button(
                    expandedLayout: true,
                    label: "reset".tr(),
                    onTap: () async {
                      resetRange();
                      popRoute(context, false);
                    },
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    textColor:
                        Theme.of(context).colorScheme.onTertiaryContainer,
                  ),
                ),
                SizedBox(width: 13),
                Expanded(
                  child: Button(
                    expandedLayout: true,
                    label: "set-range".tr(),
                    onTap: () async {
                      popRoute(context);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (result != false)
      updateRange(orderAndBoundRangeValues(
        lowerRange,
        _currentRangeValues.end,
        widget.rangeLimit.start,
        widget.rangeLimit.end,
      ));
  }

  void setUpperRangePopup() async {
    double upperRange = _currentRangeValues.end;
    // Result will be false if we reset the amount
    dynamic result = await openBottomSheet(
      context,
      PopupFramework(
        title: "set-upper-range".tr(),
        child: Column(
          children: [
            SelectAmount(
              amountPassed: upperRange.toString(),
              setSelectedAmount: (amount, _) {
                upperRange = amount;
              },
              hideNextButton: true,
            ),
            Row(
              children: [
                Expanded(
                  child: Button(
                    expandedLayout: true,
                    label: "reset".tr(),
                    onTap: () async {
                      resetRange();
                      popRoute(context, false);
                    },
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    textColor:
                        Theme.of(context).colorScheme.onTertiaryContainer,
                  ),
                ),
                SizedBox(width: 13),
                Expanded(
                  child: Button(
                    expandedLayout: true,
                    label: "set-range".tr(),
                    onTap: () async {
                      popRoute(context);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (result != false)
      updateRange(orderAndBoundRangeValues(
        _currentRangeValues.start,
        upperRange,
        widget.rangeLimit.start,
        widget.rangeLimit.end,
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 8, end: 8, bottom: 5),
      child: Stack(
        children: [
          Align(
            alignment: AlignmentDirectional.topCenter,
            child: RangeSlider(
              values: _currentRangeValues,
              max: widget.rangeLimit.end,
              min: widget.rangeLimit.start,
              onChanged: updateRange,
            ),
          ),
          Align(
            alignment: AlignmentDirectional.bottomCenter,
            child: Padding(
              padding: EdgeInsetsDirectional.only(start: 20, end: 20, top: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Tappable(
                    onLongPress: resetRange,
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: 7,
                    onTap: setLowerRangePopup,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 8, vertical: 6),
                      child: TextFont(
                        text: convertToMoney(Provider.of<AllWallets>(context),
                            _currentRangeValues.start),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Tappable(
                    onLongPress: resetRange,
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: 7,
                    onTap: setUpperRangePopup,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 8, vertical: 6),
                      child: TextFont(
                        text: convertToMoney(Provider.of<AllWallets>(context),
                            _currentRangeValues.end),
                        fontSize: 14,
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
