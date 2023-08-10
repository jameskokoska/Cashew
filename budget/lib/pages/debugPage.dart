import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/main.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/globalSnackBar.dart';
import 'package:budget/widgets/notificationsSettings.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/database/generatePreviewData.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:universal_html/html.dart' as html;
import 'package:budget/struct/randomConstants.dart';

class DebugPage extends StatelessWidget {
  const DebugPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return PageFramework(
      dragDownToDismiss: true,
      title: "Debug Flags",
      subtitle: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
        child: TextFont(text: "Use at your own risk"),
      ),
      subtitleAlignment: Alignment.bottomLeft,
      subtitleSize: 10,
      appBarBackgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      appBarBackgroundColorStart: Theme.of(context).canvasColor,
      listWidgets: [
        // Global context below,
        Container(
          height: 5,
          color: Theme.of(navigatorKey.currentContext!).primaryColor,
        ),
        SettingsContainerSwitch(
          title: "Use Cumulative Spending",
          description: "For spending line graphs",
          onSwitched: (value) {
            updateSettings("showCumulativeSpending", value,
                pagesNeedingRefresh: [0, 3], updateGlobalState: false);
            // if (value == true) {
            //   updateSettings("removeZeroTransactionEntries", false,
            //       pagesNeedingRefresh: [0], updateGlobalState: false);
            // }
          },
          initialValue: appStateSettings["showCumulativeSpending"],
          icon: Icons.show_chart_rounded,
        ),
        SettingsContainerSwitch(
          key: ValueKey(1),
          title: "Hide Zero Transactions",
          description: "On spending line graphs",
          onSwitched: (value) {
            updateSettings("removeZeroTransactionEntries", value,
                pagesNeedingRefresh: [0], updateGlobalState: false);
          },
          initialValue: appStateSettings["removeZeroTransactionEntries"],
          icon: Icons.money_off_rounded,
        ),
        SettingsContainerSwitch(
          title: "Start spending at 0",
          description: "For spending line graphs",
          onSwitched: (value) {
            updateSettings("ignorePastAmountSpent", value,
                pagesNeedingRefresh: [0, 3], updateGlobalState: false);
            // if (value == true) {
            //   updateSettings("removeZeroTransactionEntries", false,
            //       pagesNeedingRefresh: [0], updateGlobalState: false);
            // }
          },
          initialValue: appStateSettings["ignorePastAmountSpent"],
          icon: Icons.add_chart_rounded,
        ),
        SettingsContainerSwitch(
          title: "Show past spending trajectory",
          onSwitched: (value) {
            updateSettings("showPastSpendingTrajectory", value,
                pagesNeedingRefresh: [0], updateGlobalState: false);
          },
          initialValue: appStateSettings["showPastSpendingTrajectory"],
          icon: Icons.blur_circular_rounded,
        ),
        SettingsContainerSwitch(
          title: "battery-saver".tr(),
          description: "battery-saver-description".tr(),
          onSwitched: (value) {
            updateSettings("batterySaver", value,
                updateGlobalState: true, pagesNeedingRefresh: [0, 1, 2, 3]);
          },
          initialValue: appStateSettings["batterySaver"],
          icon: Icons.battery_charging_full_rounded,
        ),
        SettingsContainerSwitch(
          title: "Mass edit selected transactions",
          onSwitched: (value) {
            updateSettings("massEditSelectedTransactions", value,
                pagesNeedingRefresh: [0], updateGlobalState: false);
          },
          initialValue: appStateSettings["massEditSelectedTransactions"],
          icon: Icons.edit,
        ),
        SettingsContainerDropdown(
          title: "Font",
          icon: Icons.font_download_rounded,
          initial: appStateSettings["font"],
          items: ["Avenir", "Inter", "DMSans", "OpenSans", "Metropolis"],
          onChanged: (value) {
            updateSettings("font", value, updateGlobalState: true);
          },
        ),
        SettingsContainerSwitch(
          onSwitched: (value) async {
            updateSettings("colorTintCategoryIcon", value,
                updateGlobalState: true);
          },
          title: "Category Icon Tint",
          description:
              "Color category icons to follow color, material you must be enabled",
          initialValue: appStateSettings["colorTintCategoryIcon"],
          icon: Icons.category_rounded,
        ),
        SettingsContainerSwitch(
          onSwitched: (value) async {
            updateSettings("emailScanning", value,
                updateGlobalState: false, pagesNeedingRefresh: [3]);
          },
          title: "Enable Email Scanning",
          description: "Not verified by Google. Still in testing.",
          initialValue: appStateSettings["emailScanning"],
          icon: Icons.mark_email_unread_rounded,
        ),
        SettingsContainerSwitch(
          onSwitched: (value) async {
            updateSettings("emailScanningPullToRefresh", value,
                pagesNeedingRefresh: [], updateGlobalState: false);
          },
          title: "Email Scanning Pull to Refresh",
          description: "May increase API usage",
          initialValue: appStateSettings["emailScanningPullToRefresh"],
          icon: Icons.mark_email_unread_rounded,
        ),
        SettingsContainerSwitch(
          onSwitched: (value) async {
            updateSettings("sharedBudgets", value,
                updateGlobalState: true, pagesNeedingRefresh: [0, 1, 2, 3]);
          },
          title: "Enable Shared Budgets",
          description:
              "In testing, share budgets and transactions with other users.",
          initialValue: appStateSettings["sharedBudgets"],
          icon: Icons.share_rounded,
        ),
        SettingsContainerSwitch(
          title: "Emulate iOS",
          description: "Enables scroll behaviour and icons from iOS",
          onSwitched: (value) {
            updateSettings("iOSEmulate", value,
                pagesNeedingRefresh: [], updateGlobalState: true);
          },
          initialValue: appStateSettings["iOSEmulate"],
          icon: Icons.apple_rounded,
        ),
        SettingsContainerSwitch(
          title: "Native iOS Navigation",
          description: "Enables native iOS like navigation",
          onSwitched: (value) {
            updateSettings("iOSNavigation", value,
                pagesNeedingRefresh: [], updateGlobalState: true);
            // if (value == true) {
            //   updateSettings("removeZeroTransactionEntries", false,
            //       pagesNeedingRefresh: [0], updateGlobalState: false);
            // }
          },
          initialValue: appStateSettings["iOSNavigation"],
          icon: Icons.apple_rounded,
        ),
        SettingsContainerSwitch(
          title: "Disable blur",
          onSwitched: (value) {
            updateSettings("disableBlur", value,
                pagesNeedingRefresh: [0], updateGlobalState: false);
          },
          initialValue: appStateSettings["disableBlur"],
          icon: Icons.blur_off_rounded,
        ),
        SettingsContainerSwitch(
          onSwitched: (value) async {
            updateSettings("legacyTransactionAmountColors", value,
                updateGlobalState: true);
            generateColors();
          },
          title: "Legacy transaction amount colors",
          description:
              "Use a less traditional transaction amount color scheme.",
          initialValue: appStateSettings["legacyTransactionAmountColors"],
          icon: Icons.color_lens,
        ),
        SettingsContainerSwitch(
          onSwitched: (value) async {
            updateSettings("incognitoKeyboard", value,
                updateGlobalState: false);
          },
          title: "Incognito Text Input",
          description:
              "Use the incognito keyboard for text input (if supported)",
          initialValue: appStateSettings["incognitoKeyboard"],
          icon: Icons.keyboard_rounded,
        ),
        SettingsContainerSwitch(
          title: "Disable shadows",
          onSwitched: (value) {
            updateSettings("disableShadows", value, updateGlobalState: true);
            // if (value == true) {
            //   updateSettings("removeZeroTransactionEntries", false,
            //       pagesNeedingRefresh: [0], updateGlobalState: false);
            // }
          },
          initialValue: appStateSettings["disableShadows"],
          icon: Icons.dark_mode,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 13, right: 13),
          child: TextFont(text: "Animation Scale"),
        ),
        SliderSelector(
          min: 0,
          max: 3,
          initialValue: appStateSettings["animationSpeed"].toDouble(),
          onChange: (value) {},
          divisions: 30,
          onFinished: (value) {
            if (value == 0) value = 0.0000001;
            timeDilation = value;
            updateSettings("animationSpeed", value, updateGlobalState: true);
          },
        ),
        Button(
            label: "Send Notification",
            onTap: () async {
              initializeNotificationsPlatform();
              scheduleDailyNotification(context, TimeOfDay.now(),
                  scheduleNowDebug: true);
            }),
        SizedBox(height: 20),
        Button(
            label: "Force auto backup next launch",
            onTap: () async {
              updateSettings(
                "lastBackup",
                DateTime.now().subtract(Duration(days: 50)).toString(),
                updateGlobalState: false,
              );
            }),
        SizedBox(height: 20),
        Button(
            label: "Create preview data",
            onTap: () async {
              generatePreviewData();
            }),
        SizedBox(height: 10),
        Button(
            label: "Create random transactions",
            onTap: () async {
              List<TransactionCategory> categories =
                  await database.getAllCategories();
              for (int i = 0; i < 10; i++) {
                await database.createOrUpdateTransaction(
                  insert: true,
                  Transaction(
                    transactionPk: "-1",
                    name: "Test" + randomDouble[i].toString(),
                    amount: randomInt[i].toDouble(),
                    note: "",
                    categoryFk: categories[i].categoryPk,
                    walletFk: "0",
                    dateCreated: DateTime.now(),
                    income: false,
                    paid: true,
                    skipPaid: false,
                    methodAdded: MethodAdded.preview,
                  ),
                );
              }
            }),
        SizedBox(height: 20),
        Button(
            label: "Snackbar Test",
            onTap: () {
              openSnackbar(
                SnackbarMessage(
                  title:
                      '${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}.${DateTime.now().millisecond}',
                  icon: Icons.time_to_leave,
                  timeout: Duration(milliseconds: 1000),
                ),
              );
              openSnackbar(
                SnackbarMessage(
                  title: "Test",
                  description:
                      '${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}.${DateTime.now().millisecond}',
                  icon: Icons.abc,
                  timeout: Duration(milliseconds: 1000),
                  onTap: () {},
                ),
              );
              openSnackbar(
                SnackbarMessage(
                  title:
                      '${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}.${DateTime.now().millisecond}',
                  timeout: Duration(milliseconds: 1000),
                ),
              );
              openSnackbar(
                SnackbarMessage(
                  title:
                      '${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}.${DateTime.now().millisecond}',
                  description: "Some description",
                  timeout: Duration(milliseconds: 7000),
                ),
              );
              openSnackbar(
                SnackbarMessage(
                  title:
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation',
                  timeout: Duration(milliseconds: 10000),
                ),
              );
            }),
        TextFont(
            maxLines: 10,
            text: kIsWeb
                ? html.window.navigator.userAgent.toString().toLowerCase()
                : ""),
        ColorBox(color: Theme.of(context).colorScheme.surface, name: "surface"),
        ColorBox(
            color: Theme.of(context).colorScheme.onSurface, name: "onSurface"),
        ColorBox(color: Theme.of(context).canvasColor, name: "background"),
        ColorBox(
            color: Theme.of(context).colorScheme.onBackground,
            name: "onBackground"),
        Container(
          margin: EdgeInsets.all(10),
          height: 1,
          color: Colors.grey,
        ),
        ColorBox(color: Theme.of(context).colorScheme.primary, name: "primary"),
        ColorBox(
            color: Theme.of(context).colorScheme.onPrimary, name: "onPrimary"),
        ColorBox(
            color: Theme.of(context).colorScheme.primaryContainer,
            name: "primaryContainer"),
        ColorBox(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            name: "onPrimaryContainer"),
        Container(
          margin: EdgeInsets.all(10),
          height: 1,
          color: Colors.grey,
        ),
        ColorBox(
            color: Theme.of(context).colorScheme.secondary, name: "secondary"),
        ColorBox(
            color: Theme.of(context).colorScheme.onSecondary,
            name: "onSecondary"),
        ColorBox(
            color: Theme.of(context).colorScheme.secondaryContainer,
            name: "secondaryContainer"),
        ColorBox(
            color: Theme.of(context).colorScheme.onSecondaryContainer,
            name: "onSecondaryContainer"),
        Container(
          margin: EdgeInsets.all(10),
          height: 1,
          color: Colors.grey,
        ),
        ColorBox(
            color: Theme.of(context).colorScheme.tertiary, name: "tertiary"),
        ColorBox(
            color: Theme.of(context).colorScheme.onTertiary,
            name: "onTertiary"),
        ColorBox(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            name: "tertiaryContainer"),
        ColorBox(
            color: Theme.of(context).colorScheme.onTertiaryContainer,
            name: "onTertiaryContainer"),
        Container(
          margin: EdgeInsets.all(10),
          height: 1,
          color: Colors.grey,
        ),
        ColorBox(color: Theme.of(context).colorScheme.error, name: "error"),
        ColorBox(color: Theme.of(context).colorScheme.onError, name: "onError"),
        ColorBox(
            color: Theme.of(context).colorScheme.errorContainer,
            name: "errorContainer"),
        ColorBox(
            color: Theme.of(context).colorScheme.onErrorContainer,
            name: "onErrorContainer"),
      ],
    );
  }
}

class SliderSelector extends StatefulWidget {
  const SliderSelector({
    super.key,
    required this.onChange,
    this.onFinished,
    required this.initialValue,
    this.divisions,
    required this.min,
    required this.max,
  });

  final Function(double) onChange;
  final Function(double)? onFinished;
  final double initialValue;
  final int? divisions;
  final double min;
  final double max;

  @override
  State<SliderSelector> createState() => _SliderSelectorState();
}

class _SliderSelectorState extends State<SliderSelector> {
  late double _currentSliderValue = widget.initialValue;
  @override
  Widget build(BuildContext context) {
    return Slider(
      min: widget.min,
      max: widget.max,
      value: _currentSliderValue,
      divisions: widget.divisions,
      label: _currentSliderValue.toStringAsFixed(1).toString(),
      onChanged: (double value) {
        widget.onChange(value);
        setState(() {
          _currentSliderValue = value;
        });
      },
      onChangeEnd: (double value) {
        if (widget.onFinished != null) {
          widget.onFinished!(value);
        }
      },
    );
  }
}

class ColorBox extends StatelessWidget {
  const ColorBox({Key? key, required this.color, required this.name})
      : super(key: key);

  final Color color;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Container(width: 20),
          Container(width: 50, height: 50, color: color),
          Container(width: 20),
          TextFont(text: name)
        ],
      ),
    );
  }
}
