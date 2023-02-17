import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'dart:math';

import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/notificationsGlobal.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class TimeDigits extends StatelessWidget {
  const TimeDigits({required this.timeOfDay, super.key});
  final TimeOfDay timeOfDay;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.lightDarkAccent,
            borderRadius: BorderRadius.circular(5),
          ),
          padding: EdgeInsets.symmetric(horizontal: 7, vertical: 5),
          child: TextFont(
            text: timeOfDay.hour == 0
                ? "12"
                : timeOfDay.hour > 12
                    ? (timeOfDay.hour - 12).toString()
                    : timeOfDay.hour.toString(),
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
            color: Theme.of(context).colorScheme.lightDarkAccent,
            borderRadius: BorderRadius.circular(5),
          ),
          padding: EdgeInsets.symmetric(horizontal: 7, vertical: 5),
          child: TextFont(
            text: timeOfDay.minute.toString().length == 1
                ? "0" + timeOfDay.minute.toString()
                : timeOfDay.minute.toString(),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          width: 5,
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.lightDarkAccent,
            borderRadius: BorderRadius.circular(5),
          ),
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 5),
          child: TextFont(
            text: timeOfDay.hour < 12 ? "AM" : "PM",
            fontSize: 18,
          ),
        )
      ],
    );
  }
}
