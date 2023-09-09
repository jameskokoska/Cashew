import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/notificationsSettings.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/statusBox.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with WidgetsBindingObserver {
  bool notificationsEnabled = false;
  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await _checkNotificationEnabled();
    });
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  AppLifecycleState? _lastState;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (_lastState == null) {
      _lastState = state;
    }

    // app resumed
    if (state == AppLifecycleState.resumed &&
        (_lastState == AppLifecycleState.paused ||
            _lastState == AppLifecycleState.inactive)) {
      _checkNotificationEnabled();
    }

    _lastState = state;
  }

  _checkNotificationEnabled() async {
    bool status = await checkNotificationsPermissionAll();
    setState(() {
      notificationsEnabled = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageFramework(
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
    );
  }
}
