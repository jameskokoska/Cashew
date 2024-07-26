import 'dart:math';

import 'package:budget/functions.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

// Modified from:
// https://medium.com/@mhstoller.it/how-i-made-a-custom-color-picker-slider-using-flutter-and-dart-e2350ec693a1

class _SliderIndicatorPainter extends CustomPainter {
  final double position;
  final double ringSize;
  final Color ringColor;
  final Color fillColor;
  _SliderIndicatorPainter(
      this.position, this.ringSize, this.ringColor, this.fillColor);
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
        Offset(position, size.height / 2),
        ringSize,
        Paint()
          ..color = ringColor
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke);
    canvas.drawCircle(Offset(position, size.height / 2), ringSize,
        Paint()..color = fillColor);
  }

  @override
  bool shouldRepaint(_SliderIndicatorPainter old) {
    return true;
  }
}

class ColorPicker extends StatefulWidget {
  final double width;
  final Color ringColor;
  final double ringSize;
  final double? colorSliderPosition;
  final double? shadeSliderPosition;
  final Color? initialColor;
  final Function(Color, double, double) onChange;
  ColorPicker({
    required this.width,
    required this.ringColor,
    required this.ringSize,
    required this.onChange,
    this.colorSliderPosition,
    this.shadeSliderPosition,
    this.initialColor,
  });
  @override
  _ColorPickerState createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  final List<Color> _colors = [
    Color.fromARGB(255, 255, 255, 255),
    Color.fromARGB(255, 255, 0, 0),
    Color.fromARGB(255, 255, 128, 0),
    Color.fromARGB(255, 255, 255, 0),
    Color.fromARGB(255, 128, 255, 0),
    Color.fromARGB(255, 0, 255, 0),
    Color.fromARGB(255, 0, 219, 110),
    Color.fromARGB(255, 0, 255, 255),
    Color.fromARGB(255, 0, 128, 255),
    Color.fromARGB(255, 0, 0, 255),
    Color.fromARGB(255, 127, 0, 255),
    Color.fromARGB(255, 255, 0, 255),
    Color.fromARGB(255, 255, 0, 127),
    Color.fromARGB(255, 255, 0, 0),
  ];

  double _colorSliderPosition = 0;
  bool _tapDownColor = false;
  bool _tapDownShade = false;

  double _shadeSliderPosition = 0;
  late Color _currentColor;
  late Color _shadedColor;

  @override
  initState() {
    super.initState();
    // print(widget.colorSliderPosition);
    _colorSliderPosition = widget.colorSliderPosition ??
        (widget.width *
            findClosestColorPosition(
              colors: _colors,
              targetColor: widget.initialColor,
              compareBlackAndWhiteSpectrum: true,
            ));
    _currentColor = _calculateSelectedColor(_colorSliderPosition);
    _shadeSliderPosition = widget.shadeSliderPosition ??
        (widget.width *
            findClosestColorPosition(
              colors: getShadeColors(_currentColor) ?? [],
              targetColor: widget.initialColor,
              compareBlackAndWhiteSpectrum: false,
            ));
    _shadedColor = _calculateShadedColor(_shadeSliderPosition);
    Future.delayed(Duration.zero, () {
      print("Distance to predicted color: " +
          colorDistance(widget.initialColor ?? Colors.red, _shadedColor)
              .toString());

      if (widget.colorSliderPosition == null &&
          widget.shadeSliderPosition == null)
        widget.onChange(widget.initialColor ?? _shadedColor,
            _colorSliderPosition, _shadeSliderPosition);
    });
  }

  List<Color>? getShadeColors(Color? selectedColor) {
    if (selectedColor == null) return null;
    return [Colors.black, selectedColor, Colors.white];
  }

  _colorChangeHandler(double position) {
    //handle out of bounds positions
    if (position > widget.width - widget.ringSize / 2 + 2) {
      position = widget.width - widget.ringSize / 2 + 2;
    }
    if (position < 0) {
      position = 0;
    }
    // print("New pos: $position");
    setState(() {
      _colorSliderPosition = position;
      _currentColor = _calculateSelectedColor(_colorSliderPosition);
      _shadedColor = _calculateShadedColor(_shadeSliderPosition);
      _tapDownColor = true;
    });
    widget.onChange(_shadedColor, _colorSliderPosition, _shadeSliderPosition);
  }

  _shadeChangeHandler(double position) {
    //handle out of bounds gestures
    if (position > widget.width - widget.ringSize / 2 + 2) {
      position = widget.width - widget.ringSize / 2 + 2;
    }
    if (position < 0) position = 0;
    setState(() {
      _shadeSliderPosition = position;
      _shadedColor = _calculateShadedColor(_shadeSliderPosition);
      _tapDownShade = true;
      // print(
      //     "r: ${_shadedColor.red}, g: ${_shadedColor.green}, b: ${_shadedColor.blue}");
    });
    widget.onChange(_shadedColor, _colorSliderPosition, _shadeSliderPosition);
  }

  Color _calculateShadedColor(double position) {
    double ratio = position / widget.width;
    if (ratio > 0.5) {
      //Calculate new color (values converge to 255 to make the color lighter)
      int redVal = _currentColor.red != 255
          ? (_currentColor.red +
                  (255 - _currentColor.red) * (ratio - 0.5) / 0.5)
              .round()
          : 255;
      int greenVal = _currentColor.green != 255
          ? (_currentColor.green +
                  (255 - _currentColor.green) * (ratio - 0.5) / 0.5)
              .round()
          : 255;
      int blueVal = _currentColor.blue != 255
          ? (_currentColor.blue +
                  (255 - _currentColor.blue) * (ratio - 0.5) / 0.5)
              .round()
          : 255;
      return Color.fromARGB(255, redVal, greenVal, blueVal);
    } else if (ratio < 0.5) {
      //Calculate new color (values converge to 0 to make the color darker)
      int redVal = _currentColor.red != 0
          ? (_currentColor.red * ratio / 0.5).round()
          : 0;
      int greenVal = _currentColor.green != 0
          ? (_currentColor.green * ratio / 0.5).round()
          : 0;
      int blueVal = _currentColor.blue != 0
          ? (_currentColor.blue * ratio / 0.5).round()
          : 0;
      return Color.fromARGB(255, redVal, greenVal, blueVal);
    } else {
      //return the base color
      return _currentColor;
    }
  }

  Color _calculateSelectedColor(double position) {
    //determine color
    double positionInColorArray =
        (position / widget.width * (_colors.length - 1));
    // print(positionInColorArray);
    int index = positionInColorArray.truncate();
    // print(index);
    double remainder = positionInColorArray - index;
    if (remainder == 0.0) {
      _currentColor = _colors[index];
    } else {
      //calculate new color
      int redValue = _colors[index].red == _colors[index + 1].red
          ? _colors[index].red
          : (_colors[index].red +
                  (_colors[index + 1].red - _colors[index].red) * remainder)
              .round();
      int greenValue = _colors[index].green == _colors[index + 1].green
          ? _colors[index].green
          : (_colors[index].green +
                  (_colors[index + 1].green - _colors[index].green) * remainder)
              .round();
      int blueValue = _colors[index].blue == _colors[index + 1].blue
          ? _colors[index].blue
          : (_colors[index].blue +
                  (_colors[index + 1].blue - _colors[index].blue) * remainder)
              .round();
      _currentColor = Color.fromARGB(255, redValue, greenValue, blueValue);
    }
    return _currentColor;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: _shadedColor,
            shape: BoxShape.circle,
          ),
          margin: EdgeInsetsDirectional.only(bottom: 5),
        ),
        Center(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: (DragStartDetails details) {
              _colorChangeHandler(
                  details.localPosition.dx - widget.ringSize * 2);
            },
            onHorizontalDragUpdate: (DragUpdateDetails details) {
              _colorChangeHandler(
                  details.localPosition.dx - widget.ringSize * 2);
            },
            onTapDown: (TapDownDetails details) {
              _colorChangeHandler(
                  details.localPosition.dx - widget.ringSize * 2);
            },
            onTapUp: (_) {
              setState(() {
                _tapDownColor = false;
              });
            },
            onHorizontalDragEnd: (_) {
              setState(() {
                _tapDownColor = false;
              });
            },
            //This outside padding makes it much easier to grab the   slider because the gesture detector has
            // the extra padding to recognize gestures inside of
            child: Padding(
              padding: EdgeInsetsDirectional.all(15),
              child: Container(
                width: widget.width,
                height: 15,
                decoration: BoxDecoration(
                  borderRadius: BorderRadiusDirectional.circular(15),
                  gradient: LinearGradient(colors: _colors),
                ),
                child: AnimatedScale(
                  alignment:
                      Alignment(_colorSliderPosition / widget.width * 2 - 1, 0),
                  duration: Duration(milliseconds: 1000),
                  curve: ElasticOutCurve(0.5),
                  scale: _tapDownColor ? 1.5 : 1,
                  child: CustomPaint(
                    painter: _SliderIndicatorPainter(_colorSliderPosition,
                        widget.ringSize, widget.ringColor, _currentColor),
                  ),
                ),
              ),
            ),
          ),
        ),
        Center(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: (DragStartDetails details) {
              _shadeChangeHandler(
                  details.localPosition.dx - widget.ringSize * 2);
            },
            onHorizontalDragUpdate: (DragUpdateDetails details) {
              _shadeChangeHandler(
                  details.localPosition.dx - widget.ringSize * 2);
            },
            onTapDown: (TapDownDetails details) {
              _shadeChangeHandler(
                  details.localPosition.dx - widget.ringSize * 2);
            },
            onTapUp: (_) {
              setState(() {
                _tapDownShade = false;
              });
            },
            onHorizontalDragEnd: (_) {
              setState(() {
                _tapDownShade = false;
              });
            },
            //This outside padding makes it much easier to grab the slider because the gesture detector has
            // the extra padding to recognize gestures inside of
            child: Padding(
              padding: EdgeInsetsDirectional.all(15),
              child: Container(
                width: widget.width,
                height: 15,
                decoration: BoxDecoration(
                  borderRadius: BorderRadiusDirectional.circular(15),
                  gradient: LinearGradient(
                      colors: getShadeColors(_currentColor) ?? []),
                ),
                child: AnimatedScale(
                  alignment:
                      Alignment(_shadeSliderPosition / widget.width * 2 - 1, 0),
                  duration: Duration(milliseconds: 1000),
                  curve: ElasticOutCurve(0.5),
                  scale: _tapDownShade ? 1.5 : 1,
                  child: CustomPaint(
                    painter: _SliderIndicatorPainter(_shadeSliderPosition,
                        widget.ringSize, widget.ringColor, _shadedColor),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Find the initial position (percentage decimal) of the slider given a gradient list and a target color

double lerp(double a, double b, double t) {
  return a + (b - a) * t;
}

Color lerpColor(Color a, Color b, double t) {
  return Color.fromARGB(
    lerp(a.alpha.toDouble(), b.alpha.toDouble(), t).round(),
    lerp(a.red.toDouble(), b.red.toDouble(), t).round(),
    lerp(a.green.toDouble(), b.green.toDouble(), t).round(),
    lerp(a.blue.toDouble(), b.blue.toDouble(), t).round(),
  );
}

double colorDistance(Color a, Color b) {
  return sqrt(pow(a.red - b.red, 2) +
      pow(a.green - b.green, 2) +
      pow(a.blue - b.blue, 2));
}

double findClosestColorPosition(
    {required List<Color> colors,
    required Color? targetColor,
    required bool compareBlackAndWhiteSpectrum}) {
  if (colors.isEmpty || targetColor == null) return 0.5;

  int closestIndex = 0;
  double minDistance = double.infinity;
  double resolution = 0.01;

  for (int i = 0; i < colors.length - 1; i++) {
    Color start = colors[i];
    Color end = colors[i + 1];
    for (double t = 0; t <= 1; t += resolution) {
      Color interpolated = lerpColor(start, end, t);
      double distance = colorDistance(interpolated, targetColor);
      if (distance < minDistance) {
        minDistance = distance;
        closestIndex = i;
      }
    }
  }

  Color start = colors[max(closestIndex, 0)];
  Color end = colors[min(closestIndex + 1, colors.length - 1)];
  double closestT = 0.0;
  minDistance = double.infinity;

  for (double t = 0; t <= 1; t += resolution) {
    Color interpolated = lerpColor(start, end, t);
    double distance = colorDistance(interpolated, targetColor);
    if (compareBlackAndWhiteSpectrum) {
      for (double t2 = 0; t2 <= 1; t2 += resolution) {
        Color interpolated2 = lerpColor(interpolated, Colors.white, t2);
        double distance = colorDistance(interpolated2, targetColor);
        if (distance < minDistance) {
          minDistance = distance;
          closestT = t;
        }
      }
      for (double t2 = 0; t2 <= 1; t2 += resolution) {
        Color interpolated2 = lerpColor(Colors.black, interpolated, t2);
        double distance = colorDistance(interpolated2, targetColor);
        if (distance < minDistance) {
          minDistance = distance;
          closestT = t;
        }
      }
    } else {
      if (distance < minDistance) {
        minDistance = distance;
        closestT = t;
      }
    }
  }

  double position = (closestIndex + closestT) / (colors.length - 1);
  return position;
}

class RingColorPicker extends StatefulWidget {
  const RingColorPicker({
    Key? key,
    required this.pickerColor,
    required this.onColorChanged,
    this.colorPickerHeight = 250.0,
    this.hueRingStrokeWidth = 20.0,
    this.pickerAreaBorderRadius = const BorderRadius.all(Radius.zero),
    this.onSelect,
    this.previewBuilder,
  }) : super(key: key);

  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;
  final double colorPickerHeight;
  final double hueRingStrokeWidth;
  final BorderRadius pickerAreaBorderRadius;
  final VoidCallback? onSelect;
  final Widget Function(Color color)? previewBuilder;

  @override
  State<RingColorPicker> createState() => _RingColorPickerState();
}

class _RingColorPickerState extends State<RingColorPicker> {
  HSVColor currentHsvColor = const HSVColor.fromAHSV(0.0, 0.0, 0.0, 0.0);
  Widget? previewWidget = null;

  @override
  void initState() {
    currentHsvColor = HSVColor.fromColor(widget.pickerColor);
    super.initState();
  }

  @override
  void didUpdateWidget(RingColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    currentHsvColor = HSVColor.fromColor(widget.pickerColor);
  }

  void onColorChanging(HSVColor color) {
    setState(() => currentHsvColor = color);
    widget.onColorChanged(currentHsvColor.toColor().withOpacity(1));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.colorPickerHeight,
      child: Stack(alignment: AlignmentDirectional.center, children: <Widget>[
        widget.previewBuilder != null
            ? Align(
                alignment: Alignment.topRight,
                child: widget
                    .previewBuilder!(currentHsvColor.toColor().withOpacity(1)),
              )
            : Align(
                alignment: Alignment.topRight,
                child: Container(
                  height: 45,
                  width: 45,
                  decoration: BoxDecoration(
                    boxShadow: boxShadowCheck(boxShadowSharp(context)),
                    shape: BoxShape.circle,
                  ),
                  child: Tappable(
                    onTap: widget.onSelect,
                    borderRadius: 100,
                    color: currentHsvColor.toColor().withOpacity(1),
                    child: SizedBox(),
                  ),
                ),
              ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: widget.colorPickerHeight,
            height: widget.colorPickerHeight,
            child: ColorPickerHueRing(
              currentHsvColor,
              onColorChanging,
              displayThumbColor: true,
              strokeWidth: widget.hueRingStrokeWidth,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: widget.colorPickerHeight / 1.8,
            height: widget.colorPickerHeight / 1.8,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: ColorPickerArea(
                  currentHsvColor, onColorChanging, PaletteType.hsv),
            ),
          ),
        )
      ]),
    );
  }
}
