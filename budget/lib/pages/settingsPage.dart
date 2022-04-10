import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/popupFramework.dart';
import 'package:budget/widgets/selectColor.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:budget/main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late Color selectedColor = Colors.red;

  @override
  Widget build(BuildContext context) {
    return PageFramework(
      title: "Settings",
      backButton: false,
      listWidgets: [
        SettingsContainerSwitch(
          title: "Dark Mode",
          description: "Set the overall theme of the app. yesss",
          initialValue: true,
          icon: Icons.dark_mode_rounded,
          onSwitched: (value) {
            if (value) {
              appStateKey.currentState?.changeTheme(ThemeMode.light);
            } else {
              appStateKey.currentState?.changeTheme(ThemeMode.dark);
            }
          },
        ),
        SettingsContainerSwitch(
          title: "Test",
          initialValue: true,
          icon: Icons.lock_rounded,
          onSwitched: (value) {},
        ),
        SettingsContainerOpenPage(
          openPage: EditBudgetPage(title: "Edit Budgets"),
          title: "Edit Budgets",
          description: "Edit the order and budget details",
          icon: Icons.bungalow_outlined,
        ),
        SettingsContainerButton(
          onTap: () {
            openBottomSheet(
              context,
              PopupFramework(
                title: "Select Color",
                child: SelectColor(
                  selectedColor: selectedColor,
                  setSelectedColor: (color) {
                    selectedColor = color;
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
          initial: "Light",
          items: ["Light", "Dark", "System"],
          onChanged: (value) {
            if (value == "Light") {
              appStateKey.currentState?.changeTheme(ThemeMode.light);
            } else if (value == "Dark") {
              appStateKey.currentState?.changeTheme(ThemeMode.dark);
            } else if (value == "System") {
              appStateKey.currentState?.changeTheme(ThemeMode.system);
            }
          },
        ),
      ],
    );
  }
}
