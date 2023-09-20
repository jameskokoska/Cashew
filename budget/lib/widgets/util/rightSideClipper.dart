import 'package:flutter/material.dart';

class RightSideClipper extends CustomClipper<RRect> {
  @override
  RRect getClip(Size size) {
    final radius = Radius.circular(0);
    final rightRect = RRect.fromRectAndRadius(
      Rect.fromPoints(Offset(0, -1000), Offset(size.width, size.height + 1000)),
      radius,
    );
    return rightRect;
  }

  @override
  bool shouldReclip(CustomClipper<RRect> oldClipper) {
    return false;
  }
}
