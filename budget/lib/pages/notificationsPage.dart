import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/debugPage.dart';
import 'package:budget/pages/onBoardingPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/notificationsSettings.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/showChangelog.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    String version = packageInfoGlobal.version;
    String buildNumber = packageInfoGlobal.buildNumber;
    return PageFramework(
      dragDownToDismiss: true,
      title: "Notifications",
      navbar: false,
      appBarBackgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      appBarBackgroundColorStart: Theme.of(context).colorScheme.background,
      listWidgets: [
        DailyNotificationsSettings(),
        UpcomingTransactionsNotificationsSettings()
      ],
    );
  }
}
