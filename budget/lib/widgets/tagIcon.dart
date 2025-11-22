import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:flutter/material.dart';

class TagIcon extends StatelessWidget {
  final Tag tag;
  final double size;
  final Color? color;

  const TagIcon({
    Key? key,
    required this.tag,
    this.size = 24,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(size * 0.2),
      decoration: BoxDecoration(
        color: (color ?? HexColor(tag.color)).withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        getIconData(tag.iconName),
        size: size,
        color: color ?? HexColor(tag.color),
      ),
    );
  }

  IconData getIconData(String? iconName) {
    switch (iconName) {
      case "shopping_cart":
        return Icons.shopping_cart;
      case "flight":
        return Icons.flight;
      case "receipt":
        return Icons.receipt;
      case "movie":
        return Icons.movie;
      case "restaurant":
        return Icons.restaurant;
      case "local_hospital":
        return Icons.local_hospital;
      default:
        return Icons.label;
    }
  }
}
