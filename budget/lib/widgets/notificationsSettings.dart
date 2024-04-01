import 'dart:io';
import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/initializeNotifications.dart';
import 'package:budget/struct/notificationsGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/radioItems.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/transactionEntry/transactionLabel.dart';
import 'package:budget/widgets/util/showTimePicker.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:budget/widgets/timeDigits.dart';

bool notificationsGlobalEnabled = kIsWeb == false;

enum ReminderNotificationType {
  IfAppNotOpened,
  DayFromOpen,
  Everyday,
}

class DailyNotificationsSettings extends StatefulWidget {
  const DailyNotificationsSettings({super.key});

  @override
  State<DailyNotificationsSettings> createState() =>
      _DailyNotificationsSettingsState();
}

class _DailyNotificationsSettingsState
    extends State<DailyNotificationsSettings> {
  bool notificationsEnabled = appStateSettings["notifications"];
  ReminderNotificationType selectedReminderType = ReminderNotificationType
      .values[appStateSettings["notificationsReminderType"]];
  TimeOfDay timeOfDay = TimeOfDay(
      hour: appStateSettings["notificationHour"],
      minute: appStateSettings["notificationMinute"]);

  @override
  Widget build(BuildContext context) {
    Map<ReminderNotificationType, String> reminderNotificationTypeTranslations =
        {
      ReminderNotificationType.IfAppNotOpened:
          "daily-notification-type-if-not-opened".tr().capitalizeFirst,
      ReminderNotificationType.DayFromOpen:
          "daily-notification-type-one-day-from-open".tr().capitalizeFirst,
      ReminderNotificationType.Everyday:
          "daily-notification-type-everyday".tr().toLowerCase().capitalizeFirst,
    };

    return Column(
      children: [
        SettingsContainerSwitch(
          title: "notifications-reminder".tr(),
          onSwitched: (value) async {
            await updateSettings("notifications", value,
                updateGlobalState: false);
            if (value == true) {
              await initializeNotificationsPlatform();
              await setDailyNotifications(context);
            } else {
              await notificationController.cancelDailyNotification();
            }
            setState(() {
              notificationsEnabled = !notificationsEnabled;
            });
            return true;
          },
          initialValue: appStateSettings["notifications"],
          icon: notificationsEnabled
              ? appStateSettings["outlinedIcons"]
                  ? Icons.notifications_outlined
                  : Icons.notifications_rounded
              : appStateSettings["outlinedIcons"]
                  ? Icons.notifications_off_outlined
                  : Icons.notifications_off_rounded,
        ),
        AnimatedExpanded(
            expand: notificationsEnabled,
            child: Column(
              children: [
                SettingsContainer(
                  title: "notifications-reminder-type".tr(),
                  description: reminderNotificationTypeTranslations[
                      ReminderNotificationType.values[
                          appStateSettings["notificationsReminderType"]]],
                  onTap: () {
                    openBottomSheet(
                      context,
                      PopupFramework(
                        title: "notifications-reminder-type".tr(),
                        child: RadioItems(
                          items: ReminderNotificationType.values,
                          initial: ReminderNotificationType.values[
                              appStateSettings["notificationsReminderType"]],
                          displayFilter: (ReminderNotificationType value) {
                            return reminderNotificationTypeTranslations[
                                    value] ??
                                "";
                          },
                          onChanged: (ReminderNotificationType option) async {
                            await updateSettings(
                                "notificationsReminderType", option.index,
                                updateGlobalState: false);
                            setState(() {
                              selectedReminderType = option;
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    );
                  },
                  icon: appStateSettings["outlinedIcons"]
                      ? Icons.notification_important_outlined
                      : Icons.notification_important_rounded,
                ),
                AnimatedExpanded(
                  expand: selectedReminderType !=
                      ReminderNotificationType.DayFromOpen,
                  child: SettingsContainer(
                    key: ValueKey(1),
                    title: "alert-time".tr(),
                    icon: Icons.timer,
                    onTap: () async {
                      TimeOfDay? newTime =
                          await showCustomTimePicker(context, timeOfDay);
                      if (newTime != null) {
                        setState(() {
                          timeOfDay = newTime;
                        });
                        await updateSettings(
                          "notificationHour",
                          timeOfDay.hour,
                          pagesNeedingRefresh: [],
                          updateGlobalState: false,
                        );
                        await updateSettings(
                          "notificationMinute",
                          timeOfDay.minute,
                          pagesNeedingRefresh: [],
                          updateGlobalState: false,
                        );
                        await initializeNotificationsPlatform();
                        await setDailyNotifications(context);
                      }
                    },
                    afterWidget: TimeDigits(timeOfDay: timeOfDay),
                  ),
                ),
              ],
            )),
        Divider(
          indent: 20,
          endIndent: 20,
          thickness: 2,
          color: getColor(context, "dividerColor"),
        ),
      ],
    );
  }
}

class UpcomingTransactionsNotificationsSettings extends StatefulWidget {
  const UpcomingTransactionsNotificationsSettings({super.key});

  @override
  State<UpcomingTransactionsNotificationsSettings> createState() =>
      _UpcomingTransactionsNotificationsSettingsState();
}

class _UpcomingTransactionsNotificationsSettingsState
    extends State<UpcomingTransactionsNotificationsSettings> {
  bool notificationsEnabled =
      appStateSettings["notificationsUpcomingTransactions"];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SettingsContainerSwitch(
          title: "upcoming-transactions".tr(),
          onSwitched: (value) async {
            updateSettings("notificationsUpcomingTransactions", value,
                updateGlobalState: false);
            if (value == true) {
              await initializeNotificationsPlatform();
              await notificationController
                  .scheduleUpcomingTransactionsNotification(context);
            } else {
              await notificationController
                  .cancelUpcomingTransactionsNotification();
            }
            setState(() {
              notificationsEnabled = !notificationsEnabled;
            });
            return true;
          },
          initialValue: appStateSettings["notificationsUpcomingTransactions"],
          icon: appStateSettings["outlinedIcons"]
              ? Icons.calendar_month_outlined
              : Icons.calendar_month_rounded,
        ),
        IgnorePointer(
          ignoring: !notificationsEnabled,
          child: AnimatedOpacity(
            opacity: notificationsEnabled ? 1 : 0,
            duration: Duration(milliseconds: 300),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                    getPlatform() == PlatformOS.isIOS ? 10 : 15),
                color: appStateSettings["materialYou"]
                    ? dynamicPastel(context,
                        Theme.of(context).colorScheme.secondaryContainer,
                        amountLight: 0, amountDark: 0.6)
                    : getColor(context, "lightDarkAccent"),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                    getPlatform() == PlatformOS.isIOS ? 10 : 15),
                child: StreamBuilder<List<Transaction>>(
                  stream: database.watchAllOverdueUpcomingTransactions(false),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        children: [
                          for (Transaction transaction in snapshot.data!)
                            StreamBuilder<TransactionCategory>(
                              stream: database
                                  .getCategory(transaction.categoryFk)
                                  .$1,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return SettingsContainerSwitch(
                                    onLongPress: () {
                                      pushRoute(
                                        context,
                                        AddTransactionPage(
                                          transaction: transaction,
                                          routesToPopAfterDelete:
                                              RoutesToPopAfterDelete.One,
                                        ),
                                      );
                                    },
                                    onTap: () {
                                      pushRoute(
                                        context,
                                        AddTransactionPage(
                                          transaction: transaction,
                                          routesToPopAfterDelete:
                                              RoutesToPopAfterDelete.One,
                                        ),
                                      );
                                    },
                                    icon: getTransactionTypeIcon(
                                        transaction.type),
                                    title: getTransactionLabelSync(
                                        transaction, snapshot.data!),
                                    description: getWordedDateShortMore(
                                            transaction.dateCreated) +
                                        ", " +
                                        getWordedTime(
                                            null, transaction.dateCreated),
                                    onSwitched: (value) async {
                                      await database.createOrUpdateTransaction(
                                          transaction.copyWith(
                                              upcomingTransactionNotification:
                                                  Value(value)));
                                      await initializeNotificationsPlatform();
                                      await notificationController
                                          .scheduleUpcomingTransactionsNotification(
                                              context);
                                      return;
                                    },
                                    syncWithInitialValue: false,
                                    initialValue: transaction
                                            .upcomingTransactionNotification ??
                                        true,
                                  );
                                }
                                return Container();
                              },
                            )
                        ],
                      );
                    }
                    return SizedBox.shrink();
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Future<bool> initializeNotificationsPlatform() async {
  if (kIsWeb || Platform.isLinux) {
    return false;
  }
  return await notificationController.checkNotificationPermission();
}
