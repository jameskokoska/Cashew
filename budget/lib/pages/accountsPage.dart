import 'package:budget/colors.dart';
import 'package:budget/widgets/accountAndBackup.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import '../functions.dart';
import 'package:transparent_image/transparent_image.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({
    Key? key,
    required this.exportData,
    required this.importData,
    required this.manageData,
    required this.logout,
  }) : super(key: key);
  final Function() exportData;
  final Function() importData;
  final Function() manageData;

  final Function() logout;
  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  bool currentlyExporting = false;

  @override
  Widget build(BuildContext context) {
    return PageFramework(
      horizontalPadding: getHorizontalPaddingConstrained(context),
      expandedHeight: 65,
      dragDownToDismiss: true,
      navbar: false,
      title: "Account and Backup",
      appBarBackgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      appBarBackgroundColorStart:
          Theme.of(context).colorScheme.secondaryContainer,
      dragDownToDissmissBackground:
          Theme.of(context).colorScheme.secondaryContainer,
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 35),
                ClipOval(
                  child: user == null || user!.photoUrl == null
                      ? Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: dynamicPastel(
                                context, Theme.of(context).colorScheme.primary,
                                amount: 0.2),
                          ),
                          child: Center(
                            child: TextFont(
                                text: user?.displayName![0] ?? "",
                                fontSize: 60,
                                textAlign: TextAlign.center,
                                fontWeight: FontWeight.bold,
                                textColor: dynamicPastel(context,
                                    Theme.of(context).colorScheme.primary,
                                    amount: 0.85, inverse: false)),
                          ),
                        )
                      : FadeInImage.memoryNetwork(
                          placeholder: kTransparentImage,
                          image: user!.photoUrl.toString(),
                          height: 95,
                          width: 95,
                          fadeInDuration: Duration(milliseconds: 200),
                        ),
                ),
                SizedBox(height: 10),
                TextFont(
                  text: (user?.displayName ?? "").toString(),
                  textAlign: TextAlign.center,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: 2),
                TextFont(
                  text: (user?.email ?? "").toString(),
                  textAlign: TextAlign.center,
                  fontSize: 15,
                ),
                SizedBox(height: 15),
                IntrinsicWidth(
                  child: Button(
                    label: "Logout",
                    onTap: widget.logout,
                    padding: EdgeInsets.symmetric(horizontal: 17, vertical: 12),
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 18.0),
                        child: Container(
                          decoration: BoxDecoration(
                              boxShadow:
                                  boxShadowCheck(boxShadowGeneral(context))),
                          child: IgnorePointer(
                            ignoring: currentlyExporting,
                            child: AnimatedOpacity(
                              opacity: currentlyExporting ? 0.4 : 1,
                              duration: Duration(milliseconds: 200),
                              child: Tappable(
                                onTap: () async {
                                  setState(() {
                                    currentlyExporting = true;
                                  });
                                  await widget.exportData();
                                  if (mounted)
                                    setState(() {
                                      currentlyExporting = false;
                                    });
                                },
                                borderRadius: 15,
                                color: Theme.of(context)
                                    .colorScheme
                                    .lightDarkAccentHeavyLight,
                                child: Column(
                                  children: [
                                    SizedBox(height: 30),
                                    Icon(
                                      Icons.upload_rounded,
                                      size: 35,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                    SizedBox(height: 10),
                                    TextFont(
                                      text: "Export",
                                      fontSize: 21,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    SizedBox(height: 30),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 18.0),
                        child: Container(
                          decoration: BoxDecoration(
                              boxShadow:
                                  boxShadowCheck(boxShadowGeneral(context))),
                          child: Tappable(
                            onTap: widget.importData,
                            borderRadius: 15,
                            color: Theme.of(context)
                                .colorScheme
                                .lightDarkAccentHeavyLight,
                            child: Column(
                              children: [
                                SizedBox(height: 30),
                                Icon(
                                  Icons.download_rounded,
                                  size: 35,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                                SizedBox(height: 10),
                                TextFont(
                                  text: "Import",
                                  fontSize: 21,
                                  fontWeight: FontWeight.bold,
                                ),
                                SizedBox(height: 30),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.only(left: 18.0, right: 18.0),
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                        boxShadow: boxShadowCheck(boxShadowGeneral(context))),
                    child: Tappable(
                      onTap: widget.manageData,
                      borderRadius: 15,
                      color: Theme.of(context)
                          .colorScheme
                          .lightDarkAccentHeavyLight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(width: 30),
                          Icon(
                            Icons.folder_rounded,
                            size: 35,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          SizedBox(width: 10),
                          TextFont(
                            text: "Manage",
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                          SizedBox(width: 30),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 75),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
