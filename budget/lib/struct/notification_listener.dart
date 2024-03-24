import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:budget/pages/autoTransactionsPageEmail.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/util/deepLinks.dart';
import 'package:flutter_notification_listener/flutter_notification_listener.dart';

ReceivePort port = ReceivePort();
List<String> recentCapturedNotifications = [];

void initNotificationListener() {
  NotificationsListener.initialize(callbackHandle: _callback);

  // this can fix restart<debug> can't handle error
  IsolateNameServer.removePortNameMapping("_listener_");
  IsolateNameServer.registerPortWithName(port.sendPort, "_listener_");

  port.listen((event) => onNotification(event as NotificationEvent));
  // don't use the default receivePort
  // NotificationsListener.receivePort.listen((evt) => onData(evt));
}

onNotification(NotificationEvent event) async {
  final trxParams = await parseTransactionFromNotification(event);
  if (trxParams.isEmpty) return;
}

Future<Map<String, String>> parseTransactionFromNotification(
    NotificationEvent event) async {
  final notificationMessage = getNotificationMessage(event);
  recentCapturedNotifications.insert(0, notificationMessage);
  recentCapturedNotifications.take(10);

  return {};
}

String getNotificationMessage(NotificationEvent event) => '''
Package name: ${event.packageName}\n----\n
Notification Title: ${event.title}\n
Notfication Content: ${event.text}\n
''';

Future<bool> requestNotificationListeningPermission() async {
  final hasPermission = (await NotificationsListener.hasPermission) ?? false;
  if (!hasPermission) {
    print("no permission, so open settings");
    NotificationsListener.openPermissionSettings();
  }
  return hasPermission;
}

Future<void> startNotificationListener() async {
  if (appStateSettings["notificationScanning"] != true) return;

  final hasPermission = await requestNotificationListeningPermission();
  if (!hasPermission) {
    return;
  }

  var isRunning = (await NotificationsListener.isRunning) ?? false;
  if (!isRunning) {
    await NotificationsListener.startService(foreground: false);
  }
}

Future<void> stopNotificationListener() async {
  final isRunning = (await NotificationsListener.isRunning) ?? false;
  if (isRunning) {
    await NotificationsListener.stopService();
  }
}

@pragma(
    'vm:entry-point') // prevent dart from stripping out this function on release build in Flutter 3.x
void _callback(NotificationEvent evt) {
  print("send evt to ui: $evt");
  if ((evt.packageName ?? '') == 'com.budget.tracker_app') {
    return;
  }
  final SendPort? send = IsolateNameServer.lookupPortByName("_listener_");
  if (send == null) print("can't find the sender");
  send?.send(evt);
}
