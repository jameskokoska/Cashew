import 'package:budget/colors.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

bool is24HourFormat(BuildContext context) {
  DateFormat format = DateFormat.jm(context.locale.toString());
  String formattedTime =
      format.format(DateTime.now()).toUpperCase().replaceAll(".", "");
  return !formattedTime.contains("AM") && !formattedTime.contains("PM");
}

class TimeDigits extends StatelessWidget {
  const TimeDigits({required this.timeOfDay, super.key});
  final TimeOfDay timeOfDay;

  @override
  Widget build(BuildContext context) {
    bool use24HourFormat =
        MediaQuery.alwaysUse24HourFormatOf(context) || is24HourFormat(context);
    String hours = "";
    String minutes = "";
    if (use24HourFormat) {
      hours = timeOfDay.hour.toString();
    } else {
      hours = timeOfDay.hour == 0
          ? "12"
          : timeOfDay.hour > 12
              ? (timeOfDay.hour - 12).toString()
              : timeOfDay.hour.toString();
    }
    minutes = timeOfDay.minute.toString().length == 1
        ? "0" + timeOfDay.minute.toString()
        : timeOfDay.minute.toString();
    Color backgroundColor = appStateSettings["materialYou"]
        ? dynamicPastel(
            context, Theme.of(context).colorScheme.secondaryContainer,
            amountLight: 0, amountDark: 0.6)
        : getColor(context, "lightDarkAccent");
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(5),
          ),
          padding: EdgeInsets.symmetric(horizontal: 7, vertical: 5),
          child: TextFont(
            text: hours,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 5),
          child: TextFont(
            text: ":",
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(5),
          ),
          padding: EdgeInsets.symmetric(horizontal: 7, vertical: 5),
          child: TextFont(
            text: minutes,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          width: 5,
        ),
        use24HourFormat
            ? SizedBox.shrink()
            : Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 5),
                child: Transform.scale(
                  scale: 0.8,
                  child: TextFont(
                    text: timeOfDay.hour < 12 ? "AM" : "PM",
                    fontSize: 18,
                  ),
                ),
              )
      ],
    );
  }
}
