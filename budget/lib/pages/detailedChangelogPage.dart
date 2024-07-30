import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/showChangelog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

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
      horizontalPaddingConstrained: true,
      getExtraHorizontalPadding: (_) => 20,
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
