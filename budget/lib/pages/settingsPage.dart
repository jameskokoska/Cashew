import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:budget/main.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

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
          openPage: Container(
            color: Colors.white,
          ),
          title: "Edit Budgets",
          description: "Edit the order and budget details",
          icon: Icons.bungalow_outlined,
        ),
        SettingsContainerDropdown(
          title: "Theme Mode",
          icon: Icons.dark_mode_rounded,
          initial: "Light",
          items: ["Light", "Dark", "System"],
          onChanged: (_) {},
        ),
      ],
    );
  }
}
