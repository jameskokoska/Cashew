import 'package:flutter/material.dart';

class KeepAliveClientMixin extends StatefulWidget {
  const KeepAliveClientMixin({super.key, required this.child});

  final Widget child;

  @override
  State<KeepAliveClientMixin> createState() => _KeepAliveClientMixinState();
}

class _KeepAliveClientMixinState extends State<KeepAliveClientMixin>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
