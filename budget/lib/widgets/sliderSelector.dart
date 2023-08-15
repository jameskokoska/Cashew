import 'package:flutter/material.dart';

class SliderSelector extends StatefulWidget {
  const SliderSelector({
    super.key,
    required this.onChange,
    this.onFinished,
    required this.initialValue,
    this.divisions,
    required this.min,
    required this.max,
  });

  final Function(double) onChange;
  final Function(double)? onFinished;
  final double initialValue;
  final int? divisions;
  final double min;
  final double max;

  @override
  State<SliderSelector> createState() => _SliderSelectorState();
}

class _SliderSelectorState extends State<SliderSelector> {
  late double _currentSliderValue = widget.initialValue;
  @override
  Widget build(BuildContext context) {
    return Slider(
      min: widget.min,
      max: widget.max,
      value: _currentSliderValue,
      divisions: widget.divisions,
      label: _currentSliderValue.toStringAsFixed(1).toString(),
      onChanged: (double value) {
        widget.onChange(value);
        setState(() {
          _currentSliderValue = value;
        });
      },
      onChangeEnd: (double value) {
        if (widget.onFinished != null) {
          widget.onFinished!(value);
        }
      },
    );
  }
}
