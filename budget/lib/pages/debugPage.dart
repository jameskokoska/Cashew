import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/aboutPage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/logging.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/dropdownSelect.dart';
import 'package:budget/widgets/globalSnackbar.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/notificationsSettings.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/database/generatePreviewData.dart';
import 'package:budget/widgets/ratingPopup.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/util/appLinks.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart' hide TextInput;
import 'package:universal_html/html.dart' as html;
import 'package:budget/struct/randomConstants.dart';
import 'package:budget/widgets/sliderSelector.dart';

class DebugPage extends StatelessWidget {
  const DebugPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return PageFramework(
      dragDownToDismiss: true,
      horizontalPaddingConstrained: true,
      title: "Debug Flags",
      actions: [
        CustomPopupMenuButton(
          showButtons: true,
          keepOutFirst: true,
          items: [
            DropdownItemMenu(
              id: "share-logs",
              label: "logs",
              icon: Icons.list,
              action: () {
                pushRoute(context, LogPage());
              },
            ),
          ],
        ),
      ],
      subtitle: TextFont(
        text: "Use at your own risk",
        textColor: getColor(context, "expenseAmount"),
        fontWeight: FontWeight.bold,
        fontSize: 20,
        maxLines: 5,
      ),
      subtitleAlignment: AlignmentDirectional.bottomStart,
      subtitleSize: 10,
      listWidgets: [
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
          initialValue: appStateSettings["showCumulativeSpending"] == true,
          icon: appStateSettings["outlinedIcons"]
              ? Icons.show_chart_outlined
              : Icons.show_chart_rounded,
        ),
        SettingsContainerSwitch(
          title: "Hide Zero Transactions",
          description: "On spending line graphs",
          onSwitched: (value) {
            updateSettings("removeZeroTransactionEntries", value,
                pagesNeedingRefresh: [0], updateGlobalState: false);
          },
          initialValue:
              appStateSettings["removeZeroTransactionEntries"] == true,
          icon: appStateSettings["outlinedIcons"]
              ? Icons.money_off_outlined
              : Icons.money_off_rounded,
        ),
        SettingsContainerSwitch(
          title: "Start Spending At 0",
          description: "For spending line graphs",
          onSwitched: (value) {
            updateSettings("ignorePastAmountSpent", value,
                pagesNeedingRefresh: [0, 3], updateGlobalState: false);
            // if (value == true) {
            //   updateSettings("removeZeroTransactionEntries", false,
            //       pagesNeedingRefresh: [0], updateGlobalState: false);
            // }
          },
          initialValue: appStateSettings["ignorePastAmountSpent"] == true,
          icon: appStateSettings["outlinedIcons"]
              ? Icons.add_chart_outlined
              : Icons.add_chart_rounded,
        ),
        SettingsContainerSwitch(
          title: "Show Past Spending Trajectory",
          onSwitched: (value) {
            updateSettings("showPastSpendingTrajectory", value,
                pagesNeedingRefresh: [0], updateGlobalState: false);
          },
          initialValue: appStateSettings["showPastSpendingTrajectory"] == true,
          icon: appStateSettings["outlinedIcons"]
              ? Icons.blur_circular_outlined
              : Icons.blur_circular_rounded,
        ),
        SettingsContainerSwitch(
          title: "Circular Progress Rotation Category Offset",
          description:
              "Try and align with what is displayed in the pie graph. Odd rotations with subcategories.",
          onSwitched: (value) {
            updateSettings("circularProgressRotation", value,
                updateGlobalState: true);
            // if (value == true) {
            //   updateSettings("removeZeroTransactionEntries", false,
            //       pagesNeedingRefresh: [0], updateGlobalState: false);
            // }
          },
          initialValue: appStateSettings["circularProgressRotation"] == true,
          icon: appStateSettings["outlinedIcons"]
              ? Icons.rotate_90_degrees_cw_outlined
              : Icons.rotate_90_degrees_cw_rounded,
        ),
        SettingsContainerSwitch(
          title: "Large Transaction Entry".tr(),
          description: "Show more information in a transaction entry".tr(),
          onSwitched: (value) {
            updateSettings("nonCompactTransactions", value,
                updateGlobalState: true, pagesNeedingRefresh: [0, 1, 2, 3]);
          },
          initialValue: appStateSettings["nonCompactTransactions"] == true,
          icon: appStateSettings["outlinedIcons"]
              ? Icons.web_asset_outlined
              : Icons.web_asset_rounded,
        ),
        SettingsContainerSwitch(
          title: "Restrict amount transactions loaded".tr(),
          description:
              "Load a small number of transactions when loading a page initially, a view all button will appear at the bottom to load all. Only applies to some pages."
                  .tr(),
          onSwitched: (value) {
            updateSettings("restrictAmountOfInitiallyLoadedTransactions", value,
                updateGlobalState: true);
          },
          initialValue:
              appStateSettings["restrictAmountOfInitiallyLoadedTransactions"] ==
                  true,
          icon: appStateSettings["outlinedIcons"]
              ? Icons.sort_outlined
              : Icons.sort_rounded,
        ),
        SettingsContainerSwitch(
          title: "Fade Transaction Title Overflow".tr(),
          description:
              "Fade overflow text instead of adding '...' for transactions"
                  .tr(),
          onSwitched: (value) {
            updateSettings("fadeTransactionNameOverflows", value,
                updateGlobalState: true);
          },
          initialValue:
              appStateSettings["fadeTransactionNameOverflows"] == true,
          icon: appStateSettings["outlinedIcons"]
              ? Icons.more_outlined
              : Icons.more_rounded,
        ),
        SettingsContainerSwitch(
          title: "Show FAQ website buttons".tr(),
          onSwitched: (value) {
            updateSettings("showFAQAndHelpLink", value,
                updateGlobalState: false, pagesNeedingRefresh: [3]);
          },
          initialValue: appStateSettings["showFAQAndHelpLink"] == true,
          icon: appStateSettings["outlinedIcons"]
              ? Icons.live_help_outlined
              : Icons.live_help_rounded,
        ),
        SettingsContainerSwitch(
          title: "Show extra info text".tr(),
          onSwitched: (value) {
            updateSettings("showExtraInfoText", value,
                updateGlobalState: false, pagesNeedingRefresh: [3]);
          },
          initialValue: appStateSettings["showExtraInfoText"] == true,
          icon: appStateSettings["outlinedIcons"]
              ? Icons.info_outline
              : Icons.info_rounded,
        ),
        SettingsContainerSwitch(
          title: "battery-saver".tr(),
          description: "battery-saver-description".tr(),
          onSwitched: (value) {
            updateSettings("batterySaver", value,
                updateGlobalState: true, pagesNeedingRefresh: [0, 1, 2, 3]);
          },
          initialValue: appStateSettings["batterySaver"] == true,
          icon: appStateSettings["outlinedIcons"]
              ? Icons.battery_charging_full_outlined
              : Icons.battery_charging_full_rounded,
        ),
        SettingsContainerSwitch(
          onSwitched: (value) {
            updateSettings("savingHapticFeedback", value,
                pagesNeedingRefresh: [], updateGlobalState: false);
          },
          initialValue: appStateSettings["savingHapticFeedback"] == true,
          title: "Saving Haptic Feedback".tr(),
          description: "When saving changes or adding, provide haptic feedback",
          icon: appStateSettings["outlinedIcons"]
              ? Icons.vibration_outlined
              : Icons.vibration_rounded,
        ),
        SettingsContainerSwitch(
          onSwitched: (value) {
            updateSettings("closeNavigationHapticFeedback", value,
                pagesNeedingRefresh: [], updateGlobalState: false);
          },
          initialValue:
              appStateSettings["closeNavigationHapticFeedback"] == true,
          title: "Close Navigation Haptic Feedback".tr(),
          description: "When closing navigation, provide haptic feedback",
          icon: appStateSettings["outlinedIcons"]
              ? Icons.vibration_outlined
              : Icons.vibration_rounded,
        ),
        SettingsContainerSwitch(
          onSwitched: (value) {
            updateSettings("tabNavigationHapticFeedback", value,
                pagesNeedingRefresh: [], updateGlobalState: false);
          },
          initialValue: appStateSettings["tabNavigationHapticFeedback"] == true,
          title: "Navigation Haptic Feedback".tr(),
          description: "When changing tabs, provide haptic feedback",
          icon: appStateSettings["outlinedIcons"]
              ? Icons.vibration_outlined
              : Icons.vibration_rounded,
        ),
        if (getPlatform(ignoreEmulation: true) == PlatformOS.isAndroid)
          SettingsContainerSwitch(
            onSwitched: (value) async {
              await updateSettings("notificationScanningDebug", value,
                  updateGlobalState: false);
            },
            title: "Notification Transactions",
            description: "Still in testing, enables the settings option",
            initialValue: appStateSettings["notificationScanningDebug"] == true,
            icon: appStateSettings["outlinedIcons"]
                ? Icons.edit_notifications_outlined
                : Icons.edit_notifications_rounded,
          ),
        SettingsContainerSwitch(
          onSwitched: (value) async {
            updateSettings("colorTintCategoryIcon", value,
                updateGlobalState: true);
          },
          title: "Category Icon Tint",
          description:
              "Color category icons to follow color, material you must be enabled",
          initialValue: appStateSettings["colorTintCategoryIcon"] == true,
          icon: appStateSettings["outlinedIcons"]
              ? Icons.category_outlined
              : Icons.category_rounded,
        ),
        SettingsContainerSwitch(
          onSwitched: (value) async {
            updateSettings("accountColorfulAmountsWithArrows", value,
                updateGlobalState: true);
          },
          title: "Colorful Arrow Account Totals",
          description:
              "Use an arrow and color to indicate the polarity of account totals on home",
          initialValue:
              appStateSettings["accountColorfulAmountsWithArrows"] == true,
          icon: appStateSettings["outlinedIcons"]
              ? Icons.swap_vert_outlined
              : Icons.swap_vert_rounded,
        ),
        SettingsContainerSwitch(
          title: "Colorful Net Totals".tr(),
          description:
              "Negative totals indicated with red, positive with green",
          onSwitched: (value) {
            updateSettings("netTotalsColorful", value, updateGlobalState: true);
          },
          initialValue: appStateSettings["netTotalsColorful"] == true,
          icon: appStateSettings["outlinedIcons"]
              ? Icons.format_color_text_outlined
              : Icons.format_color_text_rounded,
        ),
        DangerousDebugFlag(
          child: SettingsContainerSwitch(
            onSwitched: (value) async {
              updateSettings("emailScanning", value,
                  updateGlobalState: false, pagesNeedingRefresh: [3]);
            },
            title: "Enable Email Scanning",
            description: "Not verified by Google. Still in testing.",
            initialValue: appStateSettings["emailScanning"] == true,
            icon: appStateSettings["outlinedIcons"]
                ? Icons.mark_email_unread_outlined
                : Icons.mark_email_unread_rounded,
          ),
        ),
        DangerousDebugFlag(
          child: SettingsContainerSwitch(
            onSwitched: (value) async {
              updateSettings("emailScanningPullToRefresh", value,
                  pagesNeedingRefresh: [], updateGlobalState: false);
            },
            title: "Email Scanning Pull to Refresh",
            description: "May increase API usage",
            initialValue:
                appStateSettings["emailScanningPullToRefresh"] == true,
            icon: appStateSettings["outlinedIcons"]
                ? Icons.mark_email_unread_outlined
                : Icons.mark_email_unread_rounded,
          ),
        ),
        DangerousDebugFlag(
          child: SettingsContainerSwitch(
            onSwitched: (value) async {
              updateSettings("sharedBudgets", value,
                  updateGlobalState: true, pagesNeedingRefresh: [0, 1, 2, 3]);
            },
            title: "Enable Shared Budgets",
            description:
                "In testing, share budgets and transactions with other users.",
            initialValue: appStateSettings["sharedBudgets"] == true,
            icon: appStateSettings["outlinedIcons"]
                ? Icons.share_outlined
                : Icons.share_rounded,
          ),
        ),
        SettingsContainerSwitch(
          enableBorderRadius: true,
          onSwitched: (value) {
            updateSettings("enableGoogleLoginFlyIn", value,
                pagesNeedingRefresh: [], updateGlobalState: false);
          },
          initialValue: appStateSettings["enableGoogleLoginFlyIn"] == true,
          title: "Google Login Flyin".tr(),
          description:
              "Show login with Google dropdown if not logged in and full screen",
          icon: Icons.g_mobiledata,
        ),
        SettingsContainerSwitch(
          onSwitched: (value) async {
            updateSettings("forceAutoLogin", value, updateGlobalState: false);
          },
          title: "Force Auto Login",
          description: "If sync is disabled or web app, force login popup.",
          initialValue: appStateSettings["forceAutoLogin"] == true,
          icon: appStateSettings["outlinedIcons"]
              ? Icons.input_outlined
              : Icons.input_rounded,
        ),
        SettingsContainerSwitch(
          enableBorderRadius: true,
          onSwitched: (value) {
            updateSettings("syncEveryChange", value,
                pagesNeedingRefresh: [], updateGlobalState: false);
          },
          initialValue: appStateSettings["syncEveryChange"] == true,
          title: "sync-every-change".tr(),
          descriptionWithValue: (value) {
            return value
                ? "sync-every-change-description1".tr()
                : "sync-every-change-description2".tr();
          },
          icon: appStateSettings["outlinedIcons"]
              ? Icons.sync_outlined
              : Icons.sync_rounded,
        ),
        SettingsContainerSwitch(
          title: "Emulate iOS",
          description: "Enables scroll behaviour and icons from iOS",
          onSwitched: (value) {
            if (value == true) {
              // Disable iOS font for now... Avenir looks better
              // updateSettings("font", "SFProText", updateGlobalState: false);
            } else {
              updateSettings("font", "Avenir", updateGlobalState: false);
            }
            updateSettings("iOSEmulate", value,
                pagesNeedingRefresh: [], updateGlobalState: true);
          },
          initialValue: appStateSettings["iOSEmulate"] == true,
          icon: appStateSettings["outlinedIcons"]
              ? Icons.apple_outlined
              : Icons.apple_rounded,
        ),
        SettingsContainerSwitch(
          title: "Fancy budget animations on iOS",
          description: "Enables the animated goo on iOS",
          onSwitched: (value) {
            updateSettings("iOSAnimatedGoo", value,
                pagesNeedingRefresh: [], updateGlobalState: true);
          },
          initialValue: appStateSettings["iOSAnimatedGoo"] == true,
          icon: appStateSettings["outlinedIcons"]
              ? Icons.animation_outlined
              : Icons.animation_rounded,
        ),
        FutureBuilder<bool>(
          future: inAppReview.isAvailable(),
          builder: (context, snapshot) {
            return SettingsContainer(
              icon: Icons.store,
              title: "Test store review integration",
              description: "Available: " + snapshot.data.toString(),
              onTap: () async {
                if (await inAppReview.isAvailable())
                  inAppReview.requestReview();
              },
            );
          },
        ),
        SettingsContainerSwitch(
          onSwitched: (value) async {
            updateSettings("incognitoKeyboard", value,
                updateGlobalState: false);
          },
          title: "Incognito Text Input",
          description:
              "Use the incognito keyboard for text input (if supported)",
          initialValue: appStateSettings["incognitoKeyboard"] == true,
          icon: appStateSettings["outlinedIcons"]
              ? Icons.keyboard_outlined
              : Icons.keyboard_rounded,
        ),
        SettingsContainerSwitch(
          title: "Disable Shadows",
          onSwitched: (value) {
            updateSettings("disableShadows", value, updateGlobalState: true);
            // if (value == true) {
            //   updateSettings("removeZeroTransactionEntries", false,
            //       pagesNeedingRefresh: [0], updateGlobalState: false);
            // }
          },
          initialValue: appStateSettings["disableShadows"] == true,
          icon: Icons.dark_mode,
        ),
        SettingsContainerSwitch(
          title: "Replace notification setting button with Bill Splitter",
          description: "In the More page",
          onSwitched: (value) {
            updateSettings("showBillSplitterShortcut", value,
                updateGlobalState: false, pagesNeedingRefresh: [3]);
          },
          initialValue: appStateSettings["showBillSplitterShortcut"] == true,
          icon: Icons.summarize_rounded,
        ),
        SettingsContainerSwitch(
          title: "Method Added",
          description:
              "Show the method added in the transactions page and filters",
          onSwitched: (value) {
            updateSettings("showMethodAdded", value, updateGlobalState: false);
          },
          initialValue: appStateSettings["showMethodAdded"] == true,
          icon: Icons.bookmark_add,
        ),
        SettingsContainerSwitch(
          title: "Show Transaction ID",
          description: "Show the transaction ID in the transactions page",
          onSwitched: (value) {
            updateSettings("showTransactionPk", value,
                updateGlobalState: false);
          },
          initialValue: appStateSettings["showTransactionPk"] == true,
          icon: Icons.password,
        ),
        SettingsContainerSwitch(
          title: "Long Term Loan Difference Feature",
          description:
              "Instead of a common goal. When adding a new long term goal, a new option appears.",
          onSwitched: (value) {
            updateSettings("longTermLoansDifferenceFeature", value,
                updateGlobalState: true);
          },
          initialValue:
              appStateSettings["longTermLoansDifferenceFeature"] == true,
          icon: Icons.calculate,
        ),
        Padding(
          padding:
              const EdgeInsetsDirectional.only(top: 8.0, start: 13, end: 13),
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
        Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
          child: Column(
            children: [
              Button(
                label: "Redo migration (from db 37 above)",
                onTap: () async {
                  await database.customStatement('PRAGMA user_version = 37');
                  if (kIsWeb) {
                    final html.Storage localStorage = html.window.localStorage;
                    localStorage["moor_db_version_db"] = "37";
                  }
                  restartAppPopup(context);
                },
              ),
              SizedBox(height: 20),
              Button(
                label: "Fix transaction polarity",
                onTap: () async {
                  int result = await database.fixTransactionPolarity();
                  openSnackbar(
                    SnackbarMessage(
                      title: "Done",
                      description:
                          "Applied to " + result.toString() + " transactions",
                      icon: Icons.check,
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              Button(
                label: "Capitalize first letter in all transactions",
                onTap: () async {
                  int result = await database.capitalizeFirst();
                  openSnackbar(
                    SnackbarMessage(
                      title: "Done",
                      description:
                          "Applied to " + result.toString() + " transactions",
                      icon: Icons.check,
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              Button(
                label: "Vacuum/Clean DB",
                onTap: () async {
                  try {
                    await database.customStatement('VACUUM');
                    openSnackbar(
                      SnackbarMessage(
                        title: "Done",
                        icon: Icons.check,
                      ),
                    );
                  } catch (e) {
                    openSnackbar(
                      SnackbarMessage(
                        title: e.toString(),
                        icon: Icons.error,
                      ),
                    );
                  }
                },
              ),
              SizedBox(height: 20),
              Button(
                  label: "Force full sync",
                  onTap: () async {
                    sharedPreferences.setString(
                        "dateOfLastSyncedWithClient", "{}");
                    runAllCloudFunctions(context);
                  }),
              SizedBox(height: 20),
              Button(
                expandedLayout: true,
                label:
                    "Clean database delete logs (WARNING: Make sure you sync with all other devices first!)",
                onTap: () async {
                  int result = await database.deleteAllDeleteLogs();
                  openSnackbar(
                    SnackbarMessage(
                      title: "Done",
                      description: "Deleted " + result.toString() + " logs",
                      icon: Icons.check,
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              Button(
                  label: "View Delete Logs",
                  onTap: () async {
                    pushRoute(
                      context,
                      PageFramework(
                        title: "Delete logs",
                        slivers: [
                          StreamBuilder<List<DeleteLog>>(
                            stream: database.watchAllDeleteLogs(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return SliverPadding(
                                  padding: EdgeInsetsDirectional.symmetric(
                                      vertical: 7, horizontal: 13),
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (BuildContext context, int index) {
                                        DeleteLog deletelog =
                                            snapshot.data![index];
                                        return Padding(
                                          padding:
                                              const EdgeInsetsDirectional.only(
                                                  bottom: 4),
                                          child: TextFont(
                                            text: (index + 1).toString() +
                                                ") " +
                                                deletelog.type.toString() +
                                                " " +
                                                deletelog.dateTimeModified
                                                    .toString() +
                                                ": " +
                                                deletelog.deleteLogPk +
                                                " for " +
                                                deletelog.entryPk,
                                            maxLines: 10,
                                            fontSize: 12,
                                          ),
                                        );
                                      },
                                      childCount: snapshot.data?.length,
                                    ),
                                  ),
                                );
                              } else {
                                return SliverToBoxAdapter();
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  }),
              SizedBox(height: 20),
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
              DangerousDebugFlag(
                child: Button(
                  label: "Create preview data",
                  onTap: () async {
                    generatePreviewData();
                  },
                ),
              ),
              SizedBox(height: 10),
              DangerousDebugFlag(
                child: Button(
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
                  },
                ),
              ),
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
              SizedBox(height: 10),
              HorizontalBreak(),
              AppLinkTesting(),
              HorizontalBreak(),
              SizedBox(height: 10),
              TextFont(
                  maxLines: 10,
                  text: kIsWeb
                      ? html.window.navigator.userAgent.toString().toLowerCase()
                      : ""),
              SizedBox(height: 20),
              Button(
                label: "Haptic Light",
                onTap: () => HapticFeedback.lightImpact(),
              ),
              Button(
                label: "Haptic Medium",
                onTap: () => HapticFeedback.mediumImpact(),
              ),
              Button(
                label: "Haptic Heavy",
                onTap: () => HapticFeedback.heavyImpact(),
              ),
              Button(
                label: "Haptic Selection",
                onTap: () => HapticFeedback.selectionClick(),
              ),
              Button(
                label: "Haptic Vibrate",
                onTap: () => HapticFeedback.vibrate(),
              ),
            ],
          ),
        ),
        ColorBox(color: Theme.of(context).colorScheme.surface, name: "surface"),
        ColorBox(
            color: Theme.of(context).colorScheme.onSurface, name: "onSurface"),
        ColorBox(
            color: Theme.of(context).colorScheme.background,
            name: "background"),
        ColorBox(
            color: Theme.of(context).colorScheme.onBackground,
            name: "onBackground"),
        Container(
          margin: EdgeInsetsDirectional.all(10),
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
          margin: EdgeInsetsDirectional.all(10),
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
          margin: EdgeInsetsDirectional.all(10),
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
          margin: EdgeInsetsDirectional.all(10),
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

class AppLinkTesting extends StatefulWidget {
  const AppLinkTesting({super.key});

  @override
  State<AppLinkTesting> createState() => _AppLinkTestingState();
}

class _AppLinkTestingState extends State<AppLinkTesting> {
  @override
  Widget build(BuildContext context) {
    String appLinkString = "";
    return Column(
      children: [
        TextInput(
          labelText: "Test App Link",
          keyboardType: TextInputType.multiline,
          maxLines: null,
          minLines: 3,
          onChanged: (value) {
            appLinkString = value;
          },
        ),
        SizedBox(height: 10),
        Button(
            label: "Execute App Link",
            onTap: () async {
              Uri uri;
              try {
                uri = Uri.parse(appLinkString);
                List<String> resultOutput = [];
                await executeAppLink(
                  context,
                  uri,
                  onDebug: (dynamic outResult) {
                    resultOutput.add(outResult.toString());
                  },
                );
                openPopup(
                  context,
                  title: "Result",
                  descriptionWidget: CodeBlock(
                    text: resultOutput.toString(),
                  ),
                );
              } catch (e) {
                openSnackbar(SnackbarMessage(
                    title: "Error Parsing", description: e.toString()));
              }
            }),
        SizedBox(height: 10),
        AboutDeepLinking(),
      ],
    );
  }
}

class DangerousDebugFlag extends StatelessWidget {
  const DangerousDebugFlag({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (allowDangerousDebugFlags) {
      return Container(
        color: Colors.red.withOpacity(0.3),
        child: child,
      );
    } else {
      return SizedBox.shrink();
    }
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
