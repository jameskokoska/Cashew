import 'package:budget/colors.dart';
import 'package:budget/main.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/accountAndBackup.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/moreIcons.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
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
    Widget profileWidget = Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: dynamicPastel(context, Theme.of(context).colorScheme.primary,
            amount: 0.2),
      ),
      child: Center(
        child: TextFont(
            text: user?.displayName![0] ?? "",
            fontSize: 60,
            textAlign: TextAlign.center,
            fontWeight: FontWeight.bold,
            textColor: dynamicPastel(
                context, Theme.of(context).colorScheme.primary,
                amount: 0.85, inverse: false)),
      ),
    );
    return PageFramework(
      horizontalPadding: getHorizontalPaddingConstrained(context),
      dragDownToDismiss: true,
      expandedHeight: 56,
      title: "account-and-backup".tr(),
      appBarBackgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      appBarBackgroundColorStart:
          Theme.of(context).colorScheme.secondaryContainer,
      dragDownToDissmissBackground:
          Theme.of(context).colorScheme.secondaryContainer,
      bottomPadding: false,
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: user == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SettingsContainerOutlined(
                        title: "sign-in-with-google".tr(),
                        icon: MoreIcons.google,
                        isExpanded: false,
                        onTap: () async {
                          loadingIndeterminateKey.currentState
                              ?.setVisibility(true);
                          try {
                            await signInGoogle(
                              context: context,
                              waitForCompletion: false,
                              drivePermissions: true,
                              next: () {},
                            );
                          } catch (e) {
                            print("Error signing in: " + e.toString());
                          }
                        },
                      )
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 35),
                      ClipOval(
                        child: user == null || user!.photoUrl == null
                            ? profileWidget
                            : FadeInImage.memoryNetwork(
                                fadeInDuration: Duration(milliseconds: 500),
                                fadeOutDuration: Duration(milliseconds: 500),
                                placeholder: kTransparentImage,
                                image: user!.photoUrl.toString(),
                                height: 95,
                                width: 95,
                                imageErrorBuilder: (BuildContext context,
                                    Object exception, StackTrace? stackTrace) {
                                  return profileWidget;
                                },
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
                                settingsPageStateKey.currentState
                                    ?.refreshState();
                              } else {
                                pageNavigationFrameworkKey.currentState!
                                    .changePage(0, switchNavbar: true);
                              }
                            }
                          },
                          padding: EdgeInsets.symmetric(
                              horizontal: 17, vertical: 12),
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 25),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: IgnorePointer(
                                ignoring: currentlyExporting,
                                child: AnimatedOpacity(
                                  opacity: currentlyExporting ? 0.4 : 1,
                                  duration: Duration(milliseconds: 200),
                                  child: OutlinedButtonStacked(
                                    text: "export".tr(),
                                    iconData: Icons.upload_rounded,
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
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 15),
                            Expanded(
                              child: OutlinedButtonStacked(
                                text: "import".tr(),
                                iconData: Icons.download_rounded,
                                onTap: () async {
                                  await chooseBackup(context);
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButtonStacked(
                                text: "sync".tr(),
                                iconData: Icons.cloud_sync_rounded,
                                onTap: () async {
                                  chooseBackup(context,
                                      isManaging: true, isClientSync: true);
                                },
                              ),
                            ),
                            SizedBox(width: 18),
                            Expanded(
                              child: OutlinedButtonStacked(
                                text: "backups".tr(),
                                iconData: Icons.folder_rounded,
                                onTap: () async {
                                  await chooseBackup(context, isManaging: true);
                                },
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

class OutlinedButtonStacked extends StatelessWidget {
  const OutlinedButtonStacked(
      {super.key,
      required this.text,
      required this.onTap,
      required this.iconData});
  final String text;
  final void Function()? onTap;
  final IconData iconData;
  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: onTap,
      borderRadius: 15,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: (appStateSettings["materialYou"]
                ? Theme.of(context).colorScheme.secondary.withOpacity(0.5)
                : getColor(context, "lightDarkAccentHeavy")),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            SizedBox(height: 30),
            Icon(
              iconData,
              size: 35,
              color: Theme.of(context).colorScheme.secondary,
            ),
            SizedBox(height: 10),
            TextFont(
              text: text,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
