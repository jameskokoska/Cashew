import 'package:budget/colors.dart';
import 'package:budget/main.dart';
import 'package:budget/widgets/accountAndBackup.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import '../functions.dart';
import 'package:transparent_image/transparent_image.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({Key? key}) : super(key: key);

  @override
  State<AccountsPage> createState() => AccountsPageState();
}

class AccountsPageState extends State<AccountsPage> {
  bool currentlyExporting = false;

  void refreshState() {
    setState(() {});
  }

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
                    onTap: () async {
                      final result = await signOutGoogle();
                      if (result == true) {
                        if (getWidthNavigationSidebar(context) <= 0) {
                          Navigator.maybePop(context);
                          settingsPageStateKey.currentState?.refreshState();
                        } else {
                          pageNavigationFrameworkKey.currentState!
                              .changePage(0, switchNavbar: true);
                        }
                      }
                    },
                    padding: EdgeInsets.symmetric(horizontal: 17, vertical: 12),
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Row(
                    children: [
                      Expanded(
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
                                  await createBackup(context,
                                      deleteOldBackups: true);
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
                      SizedBox(width: 15),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              boxShadow:
                                  boxShadowCheck(boxShadowGeneral(context))),
                          child: Tappable(
                            onTap: () async {
                              await chooseBackup(context);
                            },
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
                    ],
                  ),
                ),
                SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              boxShadow:
                                  boxShadowCheck(boxShadowGeneral(context))),
                          child: Tappable(
                            onTap: () async {
                              chooseBackup(context,
                                  isManaging: true, isClientSync: true);
                            },
                            borderRadius: 15,
                            color: Theme.of(context)
                                .colorScheme
                                .lightDarkAccentHeavyLight,
                            child: Column(
                              children: [
                                SizedBox(height: 30),
                                Icon(
                                  Icons.cloud_sync_rounded,
                                  size: 35,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                                SizedBox(height: 10),
                                TextFont(
                                  text: "Sync",
                                  fontSize: 21,
                                  fontWeight: FontWeight.bold,
                                ),
                                SizedBox(height: 30),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 18),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              boxShadow:
                                  boxShadowCheck(boxShadowGeneral(context))),
                          child: Tappable(
                            onTap: () async {
                              await chooseBackup(context, isManaging: true);
                            },
                            borderRadius: 15,
                            color: Theme.of(context)
                                .colorScheme
                                .lightDarkAccentHeavyLight,
                            child: Column(
                              children: [
                                SizedBox(height: 30),
                                Icon(
                                  Icons.folder_rounded,
                                  size: 35,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                                SizedBox(height: 10),
                                TextFont(
                                  text: "Backups",
                                  fontSize: 21,
                                  fontWeight: FontWeight.bold,
                                ),
                                SizedBox(height: 30),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
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
