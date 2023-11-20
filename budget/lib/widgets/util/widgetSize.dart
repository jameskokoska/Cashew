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
      child: LayoutBuilder(builder: (context, constraints) {
        if (constraints.hasBoundedWidth || constraints.hasBoundedHeight) {
          // We need this second call because the first call might lead to this error:
          // The size of this render object has not yet been determined because this render object has not yet been through layout, which typically means that the size getter was called too early in the pipeline (e.g., during the build phase) before the framework has determined the size and position of the render objects during layout.
          // The second call will update the widget once it has been rendered with a bounded measurement
          // And if the size is different, the UI will update accordingly
          WidgetsBinding.instance.addPostFrameCallback(postFrameCallback);
        }
        return widget.child;
      }),
    );
  }

  var widgetKey = GlobalKey();
  var oldSize;

  void postFrameCallback(_) {
    var context = widgetKey.currentContext;
    if (context == null) return;

    try {
      Size newSize = context.size ?? Size(0, 0);
      if (oldSize == newSize) return;

      oldSize = newSize;
      widget.onChange(newSize);
    } catch (e) {
      print(e.toString());
    }
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
      child: LayoutBuilder(builder: (context, constraints) {
        if (constraints.hasBoundedWidth || constraints.hasBoundedHeight) {
          WidgetsBinding.instance.addPostFrameCallback(postFrameCallback);
        }
        return widget.widgetBuilder(size);
      }),
    );
  }

  var widgetKey = GlobalKey();
  var oldSize;

  void postFrameCallback(_) {
    var context = widgetKey.currentContext;
    if (context == null) return;
    try {
      Size newSize = context.size ?? Size(0, 0);
      if (oldSize == newSize) return;

      oldSize = newSize;
      setState(() {
        size = newSize;
      });
    } catch (e) {
      print(e.toString());
    }
  }
}
