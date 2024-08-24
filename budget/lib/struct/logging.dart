import 'dart:async';
import 'package:budget/functions.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/dropdownSelect.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

LogService logService = LogService();

class LogService {
  static const int maxLogSize = 12500;
  static const int minLogSize = 10000;

  final List<String> _logs = [];

  final List<String> filterKeywords = [
    "[🌎 Easy Localization] [WARNING]",
  ];

  void log(String message) {
    if (appStateSettings["logging"] == true) {
      bool shouldLog =
          !filterKeywords.any((keyword) => message.contains(keyword));
      if (shouldLog) {
        _logs.insert(0, "[${DateTime.now()}] : $message");
      }

      if (_logs.length > maxLogSize) {
        _logs.removeRange(minLogSize, _logs.length);
      }
    }

    Zone.root.run(() {
      print(message);
    });
  }

  String exportLogs() {
    return _logs.join('\n');
  }

  List<String> getLogs() => _logs;
}

captureLogs(Function body) {
  runZonedGuarded(
    () async {
      await body();
    },
    (error, stackTrace) {},
    zoneSpecification: ZoneSpecification(
      print: (Zone self, ZoneDelegate parent, Zone zone, String message) {
        logService.log(message);
      },
    ),
  );
}

class LogPage extends StatelessWidget {
  const LogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageFramework(
      title: "Logs",
      backButton: true,
      dragDownToDismiss: true,
      actions: [
        CustomPopupMenuButton(
          showButtons: true,
          keepOutFirst: true,
          items: [
            DropdownItemMenu(
              id: "share-logs",
              label: "info".tr(),
              icon: Icons.copy_all,
              action: () {
                copyToClipboard(logService.exportLogs());
              },
            ),
          ],
        ),
      ],
      slivers: [
        SliverToBoxAdapter(
          child: SettingsContainerSwitch(
            title: "Enable Logging",
            onSwitched: (value) {
              updateSettings("logging", value, updateGlobalState: false);
            },
            initialValue: appStateSettings["logging"] == true,
            icon: appStateSettings["outlinedIcons"]
                ? Icons.summarize_outlined
                : Icons.summarize_rounded,
          ),
        ),
        SliverPadding(
          padding: EdgeInsetsDirectional.symmetric(vertical: 7, horizontal: 13),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                String log = logService.getLogs()[index];
                return Padding(
                  padding: const EdgeInsetsDirectional.only(bottom: 4),
                  child: CodeBlock(
                    text: log,
                    fontSize: 13,
                    textAlign: TextAlign.left,
                    highlight: log.toLowerCase().contains("error"),
                  ),
                );
              },
              childCount: logService.getLogs().length,
            ),
          ),
        ),
      ],
    );
  }
}
