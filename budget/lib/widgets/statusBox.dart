import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';

class StatusBox extends StatelessWidget {
  const StatusBox({
    Key? key,
    required this.title,
    required this.description,
    required this.color,
    this.icon,
    this.smallIcon,
    this.padding,
    this.onTap,
    this.forceDark,
  }) : super(key: key);

  final String title;
  final String description;
  final IconData? icon;
  final IconData? smallIcon;
  final Color color;
  final EdgeInsetsDirectional? padding;
  final Function()? onTap;
  final bool? forceDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadiusDirectional.all(Radius.circular(15)),
        border: Border.all(color: color, width: 2),
      ),
      margin: padding ?? EdgeInsetsDirectional.all(10),
      child: Tappable(
        borderRadius: 12,
        onTap: onTap,
        color: color.withOpacity(0.4),
        child: Padding(
          padding:
              EdgeInsetsDirectional.symmetric(horizontal: 17, vertical: 10),
          child: Row(
            children: [
              if (icon != null)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 14),
                  child: Icon(icon, size: 35),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (smallIcon != null)
                          Padding(
                            padding: const EdgeInsetsDirectional.only(end: 4),
                            child: Icon(smallIcon, size: 25),
                          ),
                        Expanded(
                          child: TextFont(
                            text: title,
                            maxLines: 10,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            textColor: forceDark == true ? Colors.black : null,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    TextFont(
                      text: description,
                      maxLines: 10,
                      fontSize: 14,
                      textColor: forceDark == true ? Colors.black : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
