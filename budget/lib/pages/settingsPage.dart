import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:budget/colors.dart';
import 'package:budget/database/binary_string_conversion.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/pages/editCategoriesPage.dart';
import 'package:budget/pages/editWalletsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/accountAndBackup.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/popupFramework.dart';
import 'package:budget/widgets/selectCategoryImage.dart';
import 'package:budget/widgets/selectColor.dart';
import 'package:budget/widgets/settingsContainers.dart';
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
  late Color selectedColor = Colors.red;
  void refreshState() {
    print("refresh settings");
    setState(() {});
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return PageFramework(
      title: "Settings",
      backButton: false,
      navbar: true,
      appBarBackgroundColor: Theme.of(context).colorScheme.accentColor,
      appBarBackgroundColorStart: Theme.of(context).canvasColor,
      listWidgets: [
        SettingsHeader(title: "Data"),
        SettingsContainerOpenPage(
          openPage: EditCategoriesPage(title: "Edit Categories"),
          title: "Edit Categories",
          description: "Add and edit the order of categories",
          icon: Icons.category_rounded,
        ),
        SettingsContainerOpenPage(
          openPage: EditBudgetPage(title: "Edit Budgets"),
          title: "Edit Budgets",
          description: "Edit the order and budget details",
          icon: Icons.price_change_rounded,
        ),
        SettingsContainerOpenPage(
          openPage: EditWalletsPage(title: "Edit Wallets"),
          title: "Edit Wallets",
          description: "Edit the order and wallet details",
          icon: Icons.category_rounded,
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
        SettingsContainer(
          onTap: () {
            openBottomSheet(
              context,
              PopupFramework(
                title: "Select Icon",
                child: SelectCategoryImage(
                  setSelectedImage: (_) {},
                ),
              ),
            );
          },
          title: "Select Icon",
          icon: Icons.portrait,
        ),
        SettingsHeader(title: "Layout Customization"),
        SettingsContainerSwitch(
          title: "Show Wallet Switcher",
          description: "On home page",
          onSwitched: (value) {
            updateSettings("showWalletSwitcher", value,
                pagesNeedingRefresh: [0]);
          },
          initialValue: appStateSettings["showWalletSwitcher"],
        ),
        SettingsContainerSwitch(
          title: "Show Cumulative Spending",
          description: "On home page spending graph",
          onSwitched: (value) {
            updateSettings("showCumulativeSpending", value,
                pagesNeedingRefresh: [0]);
          },
          initialValue: appStateSettings["showCumulativeSpending"],
        ),
      ],
    );
  }
}
