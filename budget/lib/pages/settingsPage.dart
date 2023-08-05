import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/pages/aboutPage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/creditDebtTransactionsPage.dart';
import 'package:budget/pages/upcomingOverdueTransactionsPage.dart';
import 'package:budget/struct/languageMap.dart';
import 'package:budget/widgets/importCSV.dart';
import 'package:budget/pages/autoTransactionsPageEmail.dart';
import 'package:budget/pages/editAssociatedTitlesPage.dart';
import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/pages/editCategoriesPage.dart';
import 'package:budget/pages/editWalletsPage.dart';
import 'package:budget/pages/notificationsPage.dart';
import 'package:budget/pages/subscriptionsPage.dart';
import 'package:budget/widgets/accountAndBackup.dart';
import 'package:budget/widgets/moreIcons.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
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

//To get SHA1 Key run
// ./gradlew signingReport
//in budget\Android
//Generate new OAuth and put JSON in budget\android\app folder

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key, this.hasMorePages = true}) : super(key: key);
  final bool hasMorePages;

  @override
  State<SettingsPage> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage>
    with AutomaticKeepAliveClientMixin {
  GlobalKey<PageFrameworkState> pageState = GlobalKey();

  late Color? selectedColor = HexColor(appStateSettings["accentColor"]);
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
    return PageFramework(
      key: pageState,
      title: "more-actions".tr(),
      backButton: false,
      appBarBackgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      appBarBackgroundColorStart: Theme.of(context).canvasColor,
      horizontalPadding: getHorizontalPaddingConstrained(context),
      listWidgets: [
        getIsFullScreen(context)
            ? SizedBox.shrink()
            : SettingsContainerOpenPage(
                openPage: AboutPage(),
                title: "about-app".tr(namedArgs: {"app": globalAppName}),
                icon: Icons.info_outline_rounded,
              ),
        kIsWeb
            ? SettingsContainer(
                title: "share-feedback".tr(),
                icon: Icons.rate_review_rounded,
                onTap: () {
                  openBottomSheet(context, RatingPopup());
                },
              )
            : SizedBox.shrink(),
        widget.hasMorePages ? MorePages() : SizedBox.shrink(),
        SettingsHeader(title: "theme".tr()),
        SettingsContainer(
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
                              icon: Icons.brush_rounded,
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
          icon: Icons.color_lens_rounded,
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
                icon: Icons.brush_rounded,
              ),
        SettingsContainerDropdown(
          title: "theme-mode".tr(),
          icon: Icons.lightbulb_rounded,
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
        //   icon: Icons.battery_charging_full_rounded,
        // ),
        biometricsAvailable
            ? SettingsContainerSwitch(
                title: "require-biometrics".tr(),
                description: "require-biometrics-description".tr(),
                onSwitched: (value) async {
                  bool result = await checkBiometrics(
                    checkAlways: true,
                    message: "verify-identity".tr(),
                  );
                  if (result)
                    updateSettings("requireAuth", value,
                        updateGlobalState: false);
                  return result;
                },
                initialValue: appStateSettings["requireAuth"],
                icon: Icons.fingerprint_rounded,
              )
            : SizedBox.shrink(),

        SettingsContainerDropdown(
          title: "language".tr(),
          icon: Icons.language_rounded,
          initial: appStateSettings["locale"].toString(),
          items: [
            "System",
            for (String languageCode in supportedLanguagesSet) languageCode,
          ],
          getLabel: (String item) {
            if (languageNamesJSON[item] != null) {
              return languageNamesJSON[item]
                  .toString()
                  .capitalizeFirstofEach
                  .replaceAll(" ", "\n");
            }
            // if (supportedLanguagesSet.contains(item))
            //   return supportedLanguagesSet[item];
            if (item == "System") return "system".tr();
            return item;
          },
          onChanged: (value) {
            if (value == "System") {
              context.resetLocale();
            } else {
              context.setLocale(Locale(value));
            }
            updateSettings(
              "locale",
              value,
              pagesNeedingRefresh: [],
              updateGlobalState: false,
            );
          },
        ),
        TranslationsHelp(),

        SettingsHeader(title: "automation".tr()),
        // SettingsContainerOpenPage(
        //   openPage: AutoTransactionsPage(),
        //   title: "Auto Transactions",
        //   icon: Icons.auto_fix_high_rounded,
        // ),
        ImportCSV(),

        appStateSettings["emailScanning"]
            ? SettingsContainerOpenPage(
                openPage: AutoTransactionsPageEmail(),
                title: "auto-email-transactions".tr(),
                icon: Icons.mark_email_unread_rounded,
              )
            : SizedBox.shrink(),

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
      ],
    );
  }
}

class MorePages extends StatelessWidget {
  const MorePages({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              kIsWeb
                  ? SizedBox.shrink()
                  : Expanded(
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 4),
                        child: SettingsContainer(
                          onTap: () {
                            openUrl("https://github.com/jameskokoska/Cashew");
                          },
                          title: "open-source".tr(),
                          icon: Icons.code_rounded,
                          isOutlined: true,
                        ),
                      ),
                    ),
              kIsWeb
                  ? SizedBox.shrink()
                  : Expanded(
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 4),
                        child: SettingsContainer(
                          onTap: () {
                            openBottomSheet(context, RatingPopup());
                          },
                          title: "feedback".tr(),
                          icon: Icons.rate_review_rounded,
                          isOutlined: true,
                        ),
                      ),
                    ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: SettingsContainerOpenPage(
                  openPage: SubscriptionsPage(),
                  title: "subscriptions".tr(),
                  icon: Icons.event_repeat_rounded,
                  isOutlined: true,
                ),
              ),
              kIsWeb
                  ? SizedBox.shrink()
                  : Expanded(
                      child: SettingsContainerOpenPage(
                        openPage: NotificationsPage(),
                        title: "notifications".tr(),
                        icon: Icons.notifications_rounded,
                        isOutlined: true,
                      ),
                    ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: SettingsContainerOpenPage(
                  openPage: WalletDetailsPage(wallet: null),
                  title: "all-spending".tr(),
                  icon: Icons.receipt_long_rounded,
                  isOutlined: true,
                ),
              ),
              Expanded(child: GoogleAccountLoginButton()),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: SettingsContainerOpenPage(
                  isOutlinedColumn: true,
                  openPage:
                      UpcomingOverdueTransactions(overdueTransactions: true),
                  title: "overdue".tr(),
                  icon: Icons.date_range_rounded,
                  isOutlined: true,
                ),
              ),
              Expanded(
                flex: 1,
                child: SettingsContainerOpenPage(
                  isOutlinedColumn: true,
                  openPage:
                      UpcomingOverdueTransactions(overdueTransactions: false),
                  title: "upcoming".tr(),
                  icon: getTransactionTypeIcon(TransactionSpecialType.upcoming),
                  isOutlined: true,
                ),
              ),
              Expanded(
                flex: 1,
                child: SettingsContainerOpenPage(
                  isOutlinedColumn: true,
                  openPage: CreditDebtTransactions(isCredit: true),
                  title: "lent".tr(),
                  icon: getTransactionTypeIcon(TransactionSpecialType.credit),
                  isOutlined: true,
                ),
              ),
              Expanded(
                flex: 1,
                child: SettingsContainerOpenPage(
                  isOutlinedColumn: true,
                  openPage: CreditDebtTransactions(isCredit: false),
                  title: "borrowed".tr(),
                  icon: getTransactionTypeIcon(TransactionSpecialType.debt),
                  isOutlined: true,
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: SettingsContainerOpenPage(
                  isOutlinedColumn: true,
                  openPage: EditWalletsPage(),
                  title: "wallets".tr(),
                  icon: Icons.account_balance_wallet_rounded,
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
                  icon: Icons.category_rounded,
                  isOutlined: true,
                ),
              ),
              Expanded(
                flex: 1,
                child: SettingsContainerOpenPage(
                  isOutlinedColumn: true,
                  openPage: EditAssociatedTitlesPage(),
                  title: "titles".tr(),
                  icon: Icons.text_fields_rounded,
                  isOutlined: true,
                ),
              )
            ],
          ),
        ),
      ],
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
      },
    );
  }
}

Future enterNameBottomSheet(context) async {
  return await openBottomSheet(
    context,
    PopupFramework(
      title: "enter-name".tr(),
      child: Column(
        children: [
          SelectText(
            icon: Icons.person_rounded,
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

class TranslationsHelp extends StatelessWidget {
  const TranslationsHelp({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Tappable(
        onTap: () {
          openUrl('mailto:dapperappdeveloper@gmail.com');
        },
        color:
            Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.7),
        borderRadius: 10,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  Icons.connect_without_contact_rounded,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 31,
                ),
              ),
              Expanded(
                child: TextFont(
                  textColor: Theme.of(context).colorScheme.onSecondaryContainer,
                  richTextSpan: [
                    TextSpan(
                      text: 'dapperappdeveloper@gmail.com',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        decorationStyle: TextDecorationStyle.solid,
                        decorationColor:
                            getColor(context, "unPaidOverdue").withOpacity(0.8),
                        color:
                            getColor(context, "unPaidOverdue").withOpacity(0.8),
                      ),
                    ),
                  ],
                  text: "translations-help".tr() + " ",
                  maxLines: 5,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
