import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart' hide AppSettings;
import 'package:budget/pages/aboutPage.dart';
import 'package:budget/pages/addObjectivePage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/billSplitter.dart';
import 'package:budget/pages/creditDebtTransactionsPage.dart';
import 'package:budget/pages/editHomePage.dart';
import 'package:budget/pages/editObjectivesPage.dart';
import 'package:budget/pages/objectivesListPage.dart';
import 'package:budget/pages/premiumPage.dart';
import 'package:budget/pages/upcomingOverdueTransactionsPage.dart';
import 'package:budget/struct/languageMap.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/dropdownSelect.dart';
import 'package:budget/widgets/importCSV.dart';
import 'package:budget/widgets/exportCSV.dart';
import 'package:budget/pages/autoTransactionsPageEmail.dart';
import 'package:budget/pages/editAssociatedTitlesPage.dart';
import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/pages/editCategoriesPage.dart';
import 'package:budget/pages/editWalletsPage.dart';
import 'package:budget/pages/notificationsPage.dart';
import 'package:budget/pages/subscriptionsPage.dart';
import 'package:budget/widgets/accountAndBackup.dart';
import 'package:budget/widgets/moreIcons.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/notificationsSettings.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/ratingPopup.dart';
import 'package:budget/widgets/selectColor.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/pages/walletDetailsPage.dart';
import 'package:budget/struct/initializeBiometrics.dart';
import 'package:budget/struct/initializeNotifications.dart';
import 'package:budget/struct/upcomingTransactionsFunctions.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:budget/main.dart';
import '../functions.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:app_settings/app_settings.dart';

//To get SHA1 Key run
// ./gradlew signingReport
//in budget\Android
//Generate new OAuth and put JSON in budget\android\app folder

class MoreActionsPage extends StatefulWidget {
  const MoreActionsPage({
    Key? key,
  }) : super(key: key);

  @override
  State<MoreActionsPage> createState() => MoreActionsPageState();
}

class MoreActionsPageState extends State<MoreActionsPage>
    with AutomaticKeepAliveClientMixin {
  GlobalKey<PageFrameworkState> pageState = GlobalKey();

  void refreshState() {
    print("refresh settings");
    setState(() {});
  }

  void scrollToTop() {
    pageState.currentState!.scrollToTop();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, _) {
      return PageFramework(
        key: pageState,
        title: "more-actions".tr(),
        backButton: false,
        horizontalPadding: getHorizontalPaddingConstrained(context),
        actions: [
          CustomPopupMenuButton(
            showButtons: true,
            items: [
              DropdownItemMenu(
                id: "about-app",
                label: "about-app".tr(namedArgs: {"app": globalAppName}).tr(),
                icon: appStateSettings["outlinedIcons"]
                    ? Icons.info_outlined
                    : Icons.info_outline_rounded,
                action: () {
                  pushRoute(context, AboutPage());
                },
              ),
            ],
          ),
        ],
        listWidgets: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: PremiumBanner(),
          ),
          MorePages()
        ],
      );
    });
  }
}

class MorePages extends StatelessWidget {
  const MorePages({super.key});

  @override
  Widget build(BuildContext context) {
    bool hasSideNavigation = getIsFullScreen(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          hasSideNavigation
              ? SizedBox.shrink()
              : Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: SettingsContainerOpenPage(
                        openPage: SettingsPageFramework(
                          key: settingsPageFrameworkStateKey,
                        ),
                        title: "settings-and-customization".tr(),
                        icon: appStateSettings["outlinedIcons"]
                            ? Icons.settings_outlined
                            : Icons.settings_rounded,
                        isOutlined: true,
                        // description: "Theme, Language, CSV Import",
                        // isWideOutlined: true,
                      ),
                    ),
                  ],
                ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 4),
                  child: SettingsContainer(
                    onTap: () {
                      openUrl("https://github.com/jameskokoska/Cashew");
                    },
                    title: "open-source".tr(),
                    icon: MoreIcons.github,
                    isOutlined: true,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 4),
                  child: SettingsContainer(
                    onTap: () {
                      openBottomSheet(context, RatingPopup(), fullSnap: true);
                    },
                    title: "feedback".tr(),
                    icon: appStateSettings["outlinedIcons"]
                        ? Icons.rate_review_outlined
                        : Icons.rate_review_rounded,
                    isOutlined: true,
                  ),
                ),
              ),
            ],
          ),
          hasSideNavigation
              ? SizedBox.shrink()
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    notificationsGlobalEnabled
                        ? Expanded(
                            child: SettingsContainerOpenPage(
                              openPage: NotificationsPage(),
                              title: "notifications".tr(),
                              icon: appStateSettings["outlinedIcons"]
                                  ? Icons.notifications_outlined
                                  : Icons.notifications_rounded,
                              isOutlined: true,
                            ),
                          )
                        : SizedBox.shrink(),
                    Expanded(child: GoogleAccountLoginButton()),
                  ],
                ),
          hasSideNavigation
              ? SizedBox.shrink()
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: SettingsContainerOpenPage(
                        openPage: SubscriptionsPage(),
                        title: "subscriptions".tr(),
                        icon: appStateSettings["outlinedIcons"]
                            ? Icons.event_repeat_outlined
                            : Icons.event_repeat_rounded,
                        isOutlined: true,
                      ),
                    ),
                    Expanded(
                      child: SettingsContainerOpenPage(
                        openPage: WalletDetailsPage(wallet: null),
                        title: "all-spending".tr(),
                        icon: appStateSettings["outlinedIcons"]
                            ? Icons.receipt_long_outlined
                            : Icons.receipt_long_rounded,
                        isOutlined: true,
                      ),
                    ),
                  ],
                ),
          hasSideNavigation
              ? SizedBox.shrink()
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: SettingsContainerOpenPage(
                        openPage: UpcomingOverdueTransactions(
                            overdueTransactions: null),
                        title: "scheduled".tr(),
                        icon: getTransactionTypeIcon(
                            TransactionSpecialType.upcoming),
                        isOutlined: true,
                      ),
                    ),
                    Expanded(
                      child: SettingsContainerOpenPage(
                        openPage: CreditDebtTransactions(isCredit: null),
                        title: "loans".tr(),
                        icon: getTransactionTypeIcon(
                            TransactionSpecialType.credit),
                        isOutlined: true,
                      ),
                    ),
                  ],
                ),
          hasSideNavigation
              ? SizedBox.shrink()
              : SettingsContainerOpenPage(
                  openPage: ObjectivesListPage(
                    backButton: true,
                  ),
                  title: "spending-and-savings-goals".tr(),
                  icon: appStateSettings["outlinedIcons"]
                      ? Icons.savings_outlined
                      : Icons.savings_rounded,
                  isOutlined: true,
                ),
          hasSideNavigation
              ? SizedBox.shrink()
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: SettingsContainerOpenPage(
                        isOutlinedColumn: true,
                        openPage: EditWalletsPage(),
                        title: "accounts".tr(),
                        icon: appStateSettings["outlinedIcons"]
                            ? Icons.account_balance_wallet_outlined
                            : Icons.account_balance_wallet_rounded,
                        isOutlined: true,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: SettingsContainerOpenPage(
                        isOutlinedColumn: true,
                        openPage: EditBudgetPage(),
                        title: "budgets".tr(),
                        icon: MoreIcons.chart_pie,
                        iconScale: 0.83,
                        isOutlined: true,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: SettingsContainerOpenPage(
                        isOutlinedColumn: true,
                        openPage: EditCategoriesPage(),
                        title: "categories".tr(),
                        icon: appStateSettings["outlinedIcons"]
                            ? Icons.category_outlined
                            : Icons.category_rounded,
                        isOutlined: true,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: SettingsContainerOpenPage(
                        isOutlinedColumn: true,
                        openPage: EditAssociatedTitlesPage(),
                        title: "titles".tr(),
                        icon: appStateSettings["outlinedIcons"]
                            ? Icons.text_fields_outlined
                            : Icons.text_fields_rounded,
                        isOutlined: true,
                      ),
                    )
                  ],
                ),
          hasSideNavigation ? SettingsPageContent() : SizedBox.shrink(),
        ],
      ),
    );
  }
}

class EnterName extends StatelessWidget {
  const EnterName({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SettingsContainer(
      title: "username".tr(),
      icon: Icons.edit,
      onTap: () {
        enterNameBottomSheet(context);
        // Fix over-scroll stretch when keyboard pops up quickly
        Future.delayed(Duration(milliseconds: 100), () {
          bottomSheetControllerGlobal.scrollTo(0,
              duration: Duration(milliseconds: 100));
        });
      },
    );
  }
}

Future enterNameBottomSheet(context) async {
  return await openBottomSheet(
    context,
    fullSnap: true,
    PopupFramework(
      title: "enter-name".tr(),
      child: Column(
        children: [
          SelectText(
            icon: appStateSettings["outlinedIcons"]
                ? Icons.person_outlined
                : Icons.person_rounded,
            setSelectedText: (_) {},
            nextWithInput: (text) {
              updateSettings("username", text.trim(),
                  pagesNeedingRefresh: [0], updateGlobalState: false);
            },
            selectedText: appStateSettings["username"],
            placeholder: "nickname".tr(),
            autoFocus: false,
            requestLateAutoFocus: true,
          ),
        ],
      ),
    ),
  );
}

class SettingsPageFramework extends StatefulWidget {
  const SettingsPageFramework({super.key});

  @override
  State<SettingsPageFramework> createState() => SettingsPageFrameworkState();
}

class SettingsPageFrameworkState extends State<SettingsPageFramework> {
  void refreshState() {
    print("refresh settings framework");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PageFramework(
      title: "settings".tr(),
      dragDownToDismiss: true,
      listWidgets: [SettingsPageContent()],
    );
  }
}

class SettingsPageContent extends StatelessWidget {
  const SettingsPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsHeader(title: "theme".tr()),
        Builder(
          builder: (context) {
            late Color? selectedColor =
                HexColor(appStateSettings["accentColor"]);

            return SettingsContainer(
              onTap: () {
                openBottomSheet(
                  context,
                  PopupFramework(
                    title: "select-color".tr(),
                    child: Column(
                      children: [
                        getPlatform() == PlatformOS.isIOS
                            ? Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: SettingsContainerSwitch(
                                  title: "colorful-interface".tr(),
                                  onSwitched: (value) {
                                    updateSettings("materialYou", value,
                                        updateGlobalState: true);
                                  },
                                  initialValue: appStateSettings["materialYou"],
                                  icon: appStateSettings["outlinedIcons"]
                                      ? Icons.brush_outlined
                                      : Icons.brush_rounded,
                                  enableBorderRadius: true,
                                ),
                              )
                            : SizedBox.shrink(),
                        SelectColor(
                          includeThemeColor: false,
                          selectedColor: selectedColor,
                          setSelectedColor: (color) {
                            selectedColor = color;
                            updateSettings("accentColor", toHexString(color),
                                updateGlobalState: true);
                            updateSettings("accentSystemColor", false,
                                updateGlobalState: true);
                            generateColors();
                          },
                          useSystemColorPrompt: true,
                        ),
                      ],
                    ),
                  ),
                );
              },
              title: "accent-color".tr(),
              description: "accent-color-description".tr(),
              icon: appStateSettings["outlinedIcons"]
                  ? Icons.color_lens_outlined
                  : Icons.color_lens_rounded,
            );
          },
        ),
        getPlatform() == PlatformOS.isIOS
            ? SizedBox.shrink()
            : SettingsContainerSwitch(
                title: "material-you".tr(),
                description: "material-you-description".tr(),
                onSwitched: (value) {
                  updateSettings("materialYou", value, updateGlobalState: true);
                },
                initialValue: appStateSettings["materialYou"],
                icon: appStateSettings["outlinedIcons"]
                    ? Icons.brush_outlined
                    : Icons.brush_rounded,
              ),
        SettingsContainerDropdown(
          title: "theme-mode".tr(),
          icon: appStateSettings["outlinedIcons"]
              ? Icons.lightbulb_outlined
              : Icons.lightbulb_rounded,
          initial: appStateSettings["theme"].toString().capitalizeFirst,
          items: ["Light", "Dark", "System"],
          onChanged: (value) {
            if (value == "Light") {
              updateSettings("theme", "light", updateGlobalState: true);
            } else if (value == "Dark") {
              updateSettings("theme", "dark", updateGlobalState: true);
            } else if (value == "System") {
              updateSettings("theme", "system", updateGlobalState: true);
            }
          },
          getLabel: (item) {
            return item.toLowerCase().tr();
          },
        ),
        // EnterName(),
        SettingsHeader(title: "preferences".tr()),
        // SettingsContainerSwitch(
        //   title: "battery-saver".tr(),
        //   description: "battery-saver-description".tr(),
        //   onSwitched: (value) {
        //     updateSettings("batterySaver", value,
        //         updateGlobalState: true, pagesNeedingRefresh: [0, 1, 2, 3]);
        //   },
        //   initialValue: appStateSettings["batterySaver"],
        //   icon: appStateSettings["outlinedIcons"] ? Icons.battery_charging_full_outlined : Icons.battery_charging_full_rounded,
        // ),
        notificationsGlobalEnabled && getIsFullScreen(context) == false
            ? SettingsContainerOpenPage(
                openPage: NotificationsPage(),
                title: "notifications".tr(),
                icon: appStateSettings["outlinedIcons"]
                    ? Icons.notifications_outlined
                    : Icons.notifications_rounded,
              )
            : SizedBox.shrink(),

        notificationsGlobalEnabled && getIsFullScreen(context) == false
            ? SettingsContainerOpenPage(
                openPage: EditHomePage(),
                title: "edit-home-page".tr(),
                icon: appStateSettings["outlinedIcons"]
                    ? Icons.home_outlined
                    : Icons.home_rounded,
              )
            : SizedBox.shrink(),

        BudgetTotalSpentToggle(),

        BiometricsSettingToggle(),

        Builder(builder: (context) {
          return SettingsContainer(
            title: "language".tr(),
            icon: appStateSettings["outlinedIcons"]
                ? Icons.language_outlined
                : Icons.language_rounded,
            afterWidget: Tappable(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: 10,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: TextFont(
                  text: languageDisplayFilter(
                      appStateSettings["locale"].toString()),
                  fontSize: 14,
                ),
              ),
            ),
            onTap: () {
              openLanguagePicker(context);
            },
          );
        }),

        SettingsHeader(title: "automation".tr()),
        // SettingsContainerOpenPage(
        //   openPage: AutoTransactionsPage(),
        //   title: "Auto Transactions",
        //   icon: appStateSettings["outlinedIcons"] ? Icons.auto_fix_high_outlined : Icons.auto_fix_high_rounded,
        // ),
        SettingsContainerSwitch(
          title: "pay-subscriptions".tr(),
          description: "pay-subscriptions-description".tr(),
          onSwitched: (value) async {
            if (true) {
              await markSubscriptionsAsPaid();
              await setUpcomingNotifications(context);
            }
            updateSettings("automaticallyPaySubscriptions", value,
                updateGlobalState: false);
          },
          initialValue: appStateSettings["automaticallyPaySubscriptions"],
          icon: getTransactionTypeIcon(TransactionSpecialType.subscription),
        ),

        AskForTitlesToggle(),

        AutoTitlesToggle(),

        appStateSettings["emailScanning"]
            ? SettingsContainerOpenPage(
                openPage: AutoTransactionsPageEmail(),
                title: "auto-email-transactions".tr(),
                icon: appStateSettings["outlinedIcons"]
                    ? Icons.mark_email_unread_outlined
                    : Icons.mark_email_unread_rounded,
              )
            : SizedBox.shrink(),

        SettingsHeader(title: "tools".tr()),

        SettingsContainerOpenPage(
          openPage: BillSplitter(),
          title: "bill-splitter".tr(),
          icon: appStateSettings["outlinedIcons"]
              ? Icons.summarize_outlined
              : Icons.summarize_rounded,
        ),

        SettingsHeader(title: "import-and-export".tr()),

        ImportCSV(),

        ExportCSV(),
      ],
    );
  }
}

class BiometricsSettingToggle extends StatefulWidget {
  const BiometricsSettingToggle({super.key});

  @override
  State<BiometricsSettingToggle> createState() =>
      _BiometricsSettingToggleState();
}

class _BiometricsSettingToggleState extends State<BiometricsSettingToggle> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        biometricsAvailable
            ? SettingsContainerSwitch(
                title: "require-biometrics".tr(),
                description: "require-biometrics-description".tr(),
                onSwitched: (value) async {
                  try {
                    bool result = await checkBiometrics(
                      checkAlways: true,
                      message: "verify-identity".tr(),
                    );
                    if (result)
                      updateSettings("requireAuth", value,
                          updateGlobalState: false);
                    return result;
                  } catch (e) {
                    openPopup(
                      context,
                      icon: appStateSettings["outlinedIcons"]
                          ? Icons.warning_outlined
                          : Icons.warning_rounded,
                      title: getPlatform() == PlatformOS.isIOS
                          ? "biometrics-disabled".tr()
                          : "biometrics-error".tr(),
                      description: getPlatform() == PlatformOS.isIOS
                          ? "biometrics-disabled-description".tr()
                          : "biometrics-error-description".tr(),
                      onCancelLabel:
                          getPlatform() == PlatformOS.isIOS ? "ok".tr() : null,
                      onCancel: () {
                        Navigator.pop(context);
                      },
                      onSubmitLabel: getPlatform() == PlatformOS.isIOS
                          ? "open-settings".tr()
                          : "ok".tr(),
                      onSubmit: () {
                        Navigator.pop(context);
                        // On iOS the notification app settings page also has
                        // the permission for biometrics
                        if (getPlatform() == PlatformOS.isIOS) {
                          AppSettings.openNotificationSettings();
                        }
                      },
                    );
                  }
                },
                initialValue: appStateSettings["requireAuth"],
                icon: appStateSettings["outlinedIcons"]
                    ? Icons.lock_outlined
                    : Icons.lock_rounded,
              )
            : SizedBox.shrink(),
      ],
    );
  }
}
