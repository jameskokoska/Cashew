import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/pages/aboutPage.dart';
import 'package:budget/struct/currencyFunctions.dart';
import 'package:budget/widgets/noResults.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/showChangelog.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:budget/main.dart';
import 'package:provider/provider.dart';
import '../functions.dart';
import 'package:budget/struct/settings.dart';

class DetailedChangelogPage extends StatefulWidget {
  const DetailedChangelogPage({super.key});

  @override
  State<DetailedChangelogPage> createState() => _DetailedChangelogPageState();
}

class _DetailedChangelogPageState extends State<DetailedChangelogPage> {
  String searchCurrenciesText = "";

  @override
  Widget build(BuildContext context) {
    List<Widget>? changelogWidgets = getChangelogPointsWidgets(
          context,
          forceShow: true,
          majorChangesOnly: false,
        ) ??
        [];

    return PageFramework(
      dragDownToDismiss: true,
      title: "changelog".tr(),
      horizontalPadding: 20,
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return changelogWidgets[index];
            },
            childCount: changelogWidgets.length,
          ),
        ),
      ],
    );
  }
}
