import 'dart:io';

import 'package:budget/colors.dart';
import 'package:budget/main.dart';
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

class NotificationsSettings extends StatefulWidget {
  const NotificationsSettings({super.key});

  @override
  State<NotificationsSettings> createState() => _NotificationsSettingsState();
}

class _NotificationsSettingsState extends State<NotificationsSettings> {
  bool notificationsEnabled = appStateSettings["notifications"];
  TimeOfDay timeOfDay = TimeOfDay(
      hour: appStateSettings["notificationHour"],
      minute: appStateSettings["notificationMinute"]);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SettingsContainerSwitch(
          title: "Daily Notifications",
          description: "If the app wasn't opened",
          onSwitched: (value) async {
            updateSettings("notifications", value, updateGlobalState: false);
            if (value == true) {
              await initializeNotificationsPlatform();
              await scheduleDailyNotification(context, timeOfDay);
            } else {
              await cancelDailyNotification();
            }
            setState(() {
              notificationsEnabled = !notificationsEnabled;
            });
            return true;
          },
          initialValue: appStateSettings["notifications"],
          icon: Icons.notifications_rounded,
        ),
        AnimatedSize(
          duration: Duration(milliseconds: 800),
          curve: Curves.easeInOutCubicEmphasized,
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: notificationsEnabled
                ? SettingsContainer(
                    key: ValueKey(1),
                    title: "Notification Time",
                    icon: Icons.timer,
                    onTap: () async {
                      TimeOfDay? newTime = await showTimePicker(
                        context: context,
                        initialTime: timeOfDay,
                        initialEntryMode: TimePickerEntryMode.input,
                        helpText: "",
                      );
                      if (newTime != null) {
                        await initializeNotificationsPlatform();
                        await scheduleDailyNotification(context, newTime);
                        setState(() {
                          timeOfDay = newTime;
                        });
                      }
                    },
                    afterWidget: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.lightDarkAccent,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          padding:
                              EdgeInsets.symmetric(horizontal: 7, vertical: 5),
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
                          padding:
                              EdgeInsets.symmetric(horizontal: 4, vertical: 5),
                          child: TextFont(
                            text: ":",
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.lightDarkAccent,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          padding:
                              EdgeInsets.symmetric(horizontal: 7, vertical: 5),
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
                            color:
                                Theme.of(context).colorScheme.lightDarkAccent,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          padding:
                              EdgeInsets.symmetric(horizontal: 4, vertical: 5),
                          child: TextFont(
                            text: timeOfDay.hour < 12 ? "AM" : "PM",
                            fontSize: 18,
                          ),
                        )
                      ],
                    ),
                  )
                : Container(),
          ),
        ),
      ],
    );
  }
}

Future<bool> scheduleDailyNotification(context, TimeOfDay timeOfDay) async {
  // If the app was opened on the day the notification was scheduled it will be
  // cancelled and set to the next day because of _nextInstanceOfSetTime
  await cancelDailyNotification();

  AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
    'transactionReminders',
    'Transaction Reminders',
    importance: Importance.max,
    priority: Priority.high,
    color: Theme.of(context).colorScheme.primary,
  );
  NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);
  await flutterLocalNotificationsPlugin.zonedSchedule(
    1,
    'Add Transactions',
    'Don\'t forget to add transactions from today!',
    _nextInstanceOfSetTime(timeOfDay),
    notificationDetails,
    androidAllowWhileIdle: true,
    payload: 'addTransaction',
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );

  // final List<PendingNotificationRequest> pendingNotificationRequests =
  //     await flutterLocalNotificationsPlugin.pendingNotificationRequests();

  print("Notification scheduled for " +
      _nextInstanceOfSetTime(timeOfDay).toString());

  return true;
}

Future<bool> cancelDailyNotification() async {
  await flutterLocalNotificationsPlugin.cancel(1);
  print("Cancelled notification");
  return true;
}

tz.TZDateTime _nextInstanceOfSetTime(TimeOfDay timeOfDay) {
  final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  // tz.TZDateTime scheduledDate = tz.TZDateTime(
  //     tz.local, now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
  // if (scheduledDate.isBefore(now)) {
  //   scheduledDate = scheduledDate.add(const Duration(days: 1));
  // }
  tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month,
      now.day + 1, timeOfDay.hour, timeOfDay.minute);

  return scheduledDate;
}

Future<bool> initializeNotificationsPlatform() async {
  if (kIsWeb || Platform.isLinux) {
    return false;
  }
  try {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();
    tz.initializeTimeZones();
    DateTime dateTime = DateTime.now();
    tz.setLocalLocation(tz.getLocation(dateTime.timeZoneName));
  } catch (e) {
    print("Error setting up notifications: " + e.toString());
    return false;
  }
  print("Notifications initialized");
  return true;
}
