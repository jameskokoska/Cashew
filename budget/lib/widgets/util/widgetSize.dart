import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class WidgetSize extends StatefulWidget {
  final Widget child;
  final Function(Size size) onChange;

  const WidgetSize({
    Key? key,
    required this.onChange,
    required this.child,
  }) : super(key: key);

  @override
  _WidgetSizeState createState() => _WidgetSizeState();
}

class _WidgetSizeState extends State<WidgetSize> {
  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback(postFrameCallback);
    return Container(
      key: widgetKey,
      child: widget.child,
    );
  }

  var widgetKey = GlobalKey();
  var oldSize;

  void postFrameCallback(_) {
    var context = widgetKey.currentContext;
    if (context == null) return;

    Size newSize = context.size ?? Size(0, 0);
    if (oldSize == newSize) return;

    oldSize = newSize;
    widget.onChange(newSize);
  }
}

class WidgetSizeBuilder extends StatefulWidget {
  final Widget Function(Size? size) widgetBuilder;

  const WidgetSizeBuilder({
    Key? key,
    required this.widgetBuilder,
  }) : super(key: key);

  @override
  _WidgetSizeBuilderState createState() => _WidgetSizeBuilderState();
}

class _WidgetSizeBuilderState extends State<WidgetSizeBuilder> {
  Size? size;
  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback(postFrameCallback);
    return Container(
      key: widgetKey,
      child: widget.widgetBuilder(size),
    );
  }

  var widgetKey = GlobalKey();
  var oldSize;

  void postFrameCallback(_) {
    var context = widgetKey.currentContext;
    if (context == null) return;

    Size newSize = context.size ?? Size(0, 0);
    if (oldSize == newSize) return;

    oldSize = newSize;
    setState(() {
      size = newSize;
    });
  }
}
