import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/notificationsSettings.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/statusBox.dart';
import 'package:budget/widgets/util/onAppResume.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool notificationsEnabled = false;

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await _checkNotificationEnabled();
    });
    super.initState();
  }

  _checkNotificationEnabled() async {
    bool status = await checkNotificationsPermissionAll();
    setState(() {
      notificationsEnabled = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return OnAppResume(
      onAppResume: () async {
        await _checkNotificationEnabled();
      },
      child: PageFramework(
        horizontalPadding: getHorizontalPaddingConstrained(context),
        dragDownToDismiss: true,
        title: "notifications".tr(),
        listWidgets: [
          AnimatedExpanded(
            expand: notificationsEnabled == false,
            duration: Duration(milliseconds: 100),
            child: StatusBox(
              title: "notifications-disabled".tr(),
              description: "notifications-disabled-description".tr(),
              icon: appStateSettings["outlinedIcons"]
                  ? Icons.warning_outlined
                  : Icons.warning_rounded,
              color: Theme.of(context).colorScheme.error,
              onTap: () {
                AppSettings.openNotificationSettings();
              },
            ),
          ),
          AnimatedOpacity(
            opacity: notificationsEnabled ? 1 : 0.5,
            duration: Duration(milliseconds: 300),
            child: Column(
              children: [
                DailyNotificationsSettings(),
                UpcomingTransactionsNotificationsSettings()
              ],
            ),
          )
        ],
      ),
    );
  }
}
