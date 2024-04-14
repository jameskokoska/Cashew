import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:budget/pages/autoTransactionsPageEmail.dart';
import 'package:budget/struct/notification_controller/models.dart';
import 'package:budget/struct/notificationsGlobal.dart';
import 'package:budget/widgets/util/deepLinks.dart';
import 'package:flutter_notification_listener/flutter_notification_listener.dart';

const _portName = "notification_listener_port";

ReceivePort port = ReceivePort();
List<String> recentCapturedNotifications = [];

// TODO: make it user configurable from settings
List<String> allowedPackages = ['com.google.android.apps.messaging'];

Future<void> initNotificationListener() async {
  try {
    await NotificationsListener.initialize(callbackHandle: _callback);

    // this can fix restart<debug> can't handle error
    IsolateNameServer.removePortNameMapping(_portName);
    IsolateNameServer.registerPortWithName(port.sendPort, _portName);

    port.listen((event) => onNotification(event as NotificationEvent));
    // don't use the default receivePort
    // NotificationsListener.receivePort.listen((evt) => onData(evt));
  } catch (e) {
    print('Error initializing notification listener: $e');
  }
}

onNotification(NotificationEvent event) async {
  final trxParams = await parseTransactionFromNotification(event);
  if (trxParams.isEmpty) return handleNonTransactionNotification(event);

  trxParams['notes'] = '[${event.title}] ${trxParams['notes']}';

  await addTransactionFromParams(trxParams);
}

const possibleTransactionKeywords = ['debit', 'credit', '5890', '8389'];

handleNonTransactionNotification(NotificationEvent event) async {
  final message = getSanitizedMessage(event.text);
  if (possibleTransactionKeywords.any((keyword) => message.contains(keyword))) {
    await notificationController.createNotification(
      content: NotificationData(
          title: 'New Transaction Detected, Add Scanner?', body: message),
      payload: {
        'type': 'addScannerTemplate',
      },
    );
  }
}

Future<Map<String, String>> parseTransactionFromNotification(
    NotificationEvent event) async {
  final notificationMessage = getSanitizedMessage(event.text);
  recentCapturedNotifications.insert(0, notificationMessage);
  recentCapturedNotifications = recentCapturedNotifications.take(10).toList();

  return await parseTransactionFromMessage(notificationMessage);
}

String getSanitizedMessage(String? msg) => (msg ?? '')
    .replaceAll(RegExp(r'[,[\]*?:^$|{}]'), '')
    .replaceAll(RegExp(r'[\r\n\t]'), ' ');

// String getNotificationMessage(NotificationEvent event) => '''
// Package name: ${event.packageName}\n----\n
// Notification Title: ${event.title}\n
// Notfication Content: ${event.text}\n
// ''';

Future<bool> requestNotificationListeningPermission() async {
  final hasPermission = (await NotificationsListener.hasPermission) ?? false;
  if (!hasPermission) {
    print("no permission, so open settings");
    NotificationsListener.openPermissionSettings();
  }
  return hasPermission;
}

Future<bool> startNotificationListener() async {
  final hasPermission = await requestNotificationListeningPermission();
  if (!hasPermission) {
    return false;
  }

  var isRunning = await NotificationsListener.isRunning;
  if (!(isRunning ?? false)) {
    isRunning = await NotificationsListener.startService(foreground: false);
  }

  return isRunning ?? false;
}

Future<bool> stopNotificationListener() async {
  final isRunning = (await NotificationsListener.isRunning) ?? false;
  if (isRunning) {
    return await NotificationsListener.stopService() ?? false;
  }

  return true;
}

@pragma('vm:entry-point')
void _callback(NotificationEvent evt) {
  if (!allowedPackages.contains(evt.packageName)) {
    return;
  }
  print("send evt to ui: $evt");
  final send = IsolateNameServer.lookupPortByName(_portName);
  if (send == null) {
    print("can't find the sender");
    return;
  }
  send.send(evt);
}
