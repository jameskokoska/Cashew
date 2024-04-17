import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/transactionsSearchPage.dart';
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

  void setLowerRangePopup() {
    openBottomSheet(
      context,
      PopupFramework(
        title: "set-lower-range".tr(),
        child: Column(
          children: [
            SelectAmount(
              amountPassed: _currentRangeValues.start.toString(),
              setSelectedAmount: (amount, _) {
                updateRange(orderAndBoundRangeValues(
                  amount,
                  _currentRangeValues.end,
                  widget.rangeLimit.start,
                  widget.rangeLimit.end,
                ));
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
                      Navigator.pop(context);
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
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void setUpperRangePopup() {
    openBottomSheet(
      context,
      PopupFramework(
        title: "set-upper-range".tr(),
        child: Column(
          children: [
            SelectAmount(
              amountPassed: _currentRangeValues.end.toString(),
              setSelectedAmount: (amount, _) {
                updateRange(orderAndBoundRangeValues(
                  _currentRangeValues.start,
                  amount,
                  widget.rangeLimit.start,
                  widget.rangeLimit.end,
                ));
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
                      Navigator.pop(context);
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
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 5),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: RangeSlider(
              values: _currentRangeValues,
              max: widget.rangeLimit.end,
              min: widget.rangeLimit.start,
              onChanged: updateRange,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(left: 20, right: 20, top: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Tappable(
                    onLongPress: resetRange,
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: 7,
                    onTap: setLowerRangePopup,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
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
                      padding: const EdgeInsets.symmetric(
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
