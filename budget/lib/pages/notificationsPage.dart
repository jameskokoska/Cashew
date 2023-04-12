import 'package:budget/widgets/notificationsSettings.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return PageFramework(
      dragDownToDismiss: true,
      title: "Notifications",
      navbar: false,
      appBarBackgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      appBarBackgroundColorStart: Theme.of(context).canvasColor,
      listWidgets: [
        DailyNotificationsSettings(),
        UpcomingTransactionsNotificationsSettings()
      ],
    );
  }
}
