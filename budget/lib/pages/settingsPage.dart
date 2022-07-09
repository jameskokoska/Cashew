import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:budget/colors.dart';
import 'package:budget/database/binary_string_conversion.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/pages/autoTransactionsPage.dart';
import 'package:budget/pages/autoTransactionsPageEmail.dart';
import 'package:budget/pages/colorsPage.dart';
import 'package:budget/pages/editAssociatedTitlesPage.dart';
import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/pages/editCategoriesPage.dart';
import 'package:budget/pages/editWalletsPage.dart';
import 'package:budget/pages/subscriptionsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/accountAndBackup.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/popupFramework.dart';
import 'package:budget/widgets/selectCategoryImage.dart';
import 'package:budget/widgets/selectColor.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:budget/main.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart' as signIn;
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;
import 'dart:math' as math;
import 'package:file_picker/file_picker.dart';
import '../functions.dart';

//To get SHA1 Key run
// ./gradlew signingReport
//in budget\Android
//Generate new OAuth and put JSON in budget\android\app folder

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage>
    with AutomaticKeepAliveClientMixin {
  GlobalKey<PageFrameworkState> pageState = GlobalKey();

  late Color selectedColor = Colors.red;
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
      title: "Settings",
      backButton: false,
      navbar: true,
      appBarBackgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      appBarBackgroundColorStart: Theme.of(context).canvasColor,
      listWidgets: [
        SettingsHeader(title: "Data"),
        // SettingsContainerOpenPage(
        //   openPage: ColorsPage(),
        //   title: "Colors",
        //   icon: Icons.color_lens,
        // ),
        SettingsContainerOpenPage(
          openPage: SubscriptionsPage(),
          title: "Subscriptions",
          icon: Icons.event_repeat_rounded,
        ),

        SettingsContainerOpenPage(
          openPage: EditWalletsPage(title: "Edit Wallets"),
          title: "Edit Wallets",
          description: "Edit the order and wallet details",
          icon: Icons.wallet_rounded,
        ),
        SettingsContainerOpenPage(
          openPage: EditBudgetPage(title: "Edit Budgets"),
          title: "Edit Budgets",
          description: "Edit the order and budget details",
          icon: Icons.price_change_rounded,
        ),
        SettingsContainerOpenPage(
          openPage: EditCategoriesPage(title: "Edit Categories"),
          title: "Edit Categories",
          description: "Add and edit the order of categories",
          icon: Icons.category_rounded,
        ),
        SettingsContainerOpenPage(
          openPage: EditAssociatedTitlesPage(title: "Edit Titles"),
          title: "Edit Associated Titles",
          description: "Add and edit associated category titles",
          icon: Icons.text_fields_rounded,
        ),
        SettingsHeader(title: "Account and Backups"),
        AccountAndBackup(),
        SettingsHeader(title: "Theme"),
        SettingsContainer(
          onTap: () {
            openBottomSheet(
              context,
              PopupFramework(
                title: "Select Color",
                child: SelectColor(
                  selectedColor: selectedColor,
                  setSelectedColor: (color) {
                    selectedColor = color;
                    updateSettings("accentColor", toHexString(color));
                  },
                ),
              ),
            );
          },
          title: "Select Accent Color",
          icon: Icons.color_lens_rounded,
        ),
        SettingsContainerDropdown(
          title: "Theme Mode",
          icon: Icons.dark_mode_rounded,
          initial: appStateSettings["theme"].toString().capitalizeFirst,
          items: ["Light", "Dark", "System"],
          onChanged: (value) {
            if (value == "Light") {
              updateSettings("theme", "light");
            } else if (value == "Dark") {
              updateSettings("theme", "dark");
            } else if (value == "System") {
              updateSettings("theme", "system");
            }
          },
        ),
        EnterName(),
        SettingsHeader(title: "Preferences"),
        SettingsContainerSwitch(
          title: "Show Wallet Switcher",
          description: "Home page",
          onSwitched: (value) {
            updateSettings("showWalletSwitcher", value,
                pagesNeedingRefresh: [0]);
          },
          initialValue: appStateSettings["showWalletSwitcher"],
          icon: Icons.wallet_rounded,
        ),
        SettingsContainerSwitch(
          title: "Show Cumulative Spending",
          description: "Home page spending graph",
          onSwitched: (value) {
            updateSettings("showCumulativeSpending", value,
                pagesNeedingRefresh: [0]);
          },
          initialValue: appStateSettings["showCumulativeSpending"],
          icon: Icons.show_chart_rounded,
        ),
        SettingsContainerSwitch(
          title: "Ask for Transaction Title",
          description: "When adding a transaction",
          onSwitched: (value) {
            updateSettings(
              "askForTransactionTitle",
              value,
            );
          },
          initialValue: appStateSettings["askForTransactionTitle"],
          icon: Icons.text_fields_rounded,
        ),
        SettingsHeader(title: "Automations"),
        // SettingsContainerOpenPage(
        //   openPage: AutoTransactionsPage(),
        //   title: "Auto Transactions",
        //   icon: Icons.auto_fix_high_rounded,
        // ),
        SettingsContainerOpenPage(
          openPage: AutoTransactionsPageEmail(),
          title: "Auto Email Transactions",
          icon: Icons.outgoing_mail,
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
    String name = "";

    return SettingsContainer(
      title: "Username",
      icon: Icons.edit,
      onTap: () {
        openBottomSheet(
          context,
          PopupFramework(
            title: "Enter Name",
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width - 36,
                  child: TextInput(
                    bubbly: true,
                    icon: Icons.title_rounded,
                    backgroundColor:
                        Theme.of(context).colorScheme.lightDarkAccentHeavy,
                    initialValue: appStateSettings["username"],
                    autoFocus: true,
                    onEditingComplete: () {
                      Navigator.pop(context);
                      updateSettings("username", name,
                          pagesNeedingRefresh: [0]);
                    },
                    onChanged: (text) {
                      name = text;
                    },
                    labelText: "Title",
                    padding: EdgeInsets.zero,
                  ),
                ),
                Container(height: 20),
                Button(
                  label: "Set Name",
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  onTap: () {
                    Navigator.pop(context);
                    updateSettings("username", name, pagesNeedingRefresh: [0]);
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
