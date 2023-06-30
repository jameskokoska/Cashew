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

  late AppLifecycleState _lastState;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // app resumed
    if (state == AppLifecycleState.resumed &&
        _lastState == AppLifecycleState.paused) {
      _checkNotificationEnabled();
    }

    _lastState = state;
  }

  _checkNotificationEnabled() async {
    bool status = await checkNotificationsPermissionAndroid();
    setState(() {
      notificationsEnabled = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageFramework(
      dragDownToDismiss: true,
      title: "notifications".tr(),
      appBarBackgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      appBarBackgroundColorStart: Theme.of(context).canvasColor,
      listWidgets: [
        AnimatedSize(
          duration: Duration(milliseconds: 100),
          child: notificationsEnabled == false
              ? StatusBox(
                  title: "notifications-disabled".tr(),
                  description: "notifications-disabled-description".tr(),
                  icon: Icons.warning_rounded,
                  color: Theme.of(context).colorScheme.error,
                  onTap: () {
                    AppSettings.openNotificationSettings();
                  },
                )
              : Container(),
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
