import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/transactionsSearchPage.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: RangeSlider(
              values: _currentRangeValues,
              max: widget.rangeLimit.end,
              min: widget.rangeLimit.start,
              onChanged: (RangeValues values) {
                widget.onChange(values);
                setState(() {
                  _currentRangeValues = values;
                });
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(left: 20, right: 20, top: 35),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextFont(
                    text: convertToMoney(Provider.of<AllWallets>(context),
                        _currentRangeValues.start),
                    fontSize: 14,
                  ),
                  TextFont(
                    text: convertToMoney(Provider.of<AllWallets>(context),
                        _currentRangeValues.end),
                    fontSize: 14,
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
