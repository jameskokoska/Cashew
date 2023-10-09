import 'dart:io';

import 'package:budget/colors.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/accountAndBackup.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/moreIcons.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

import '../widgets/outlinedButtonStacked.dart';

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
            text: googleUser?.displayName![0] ?? "",
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
      title: getPlatform() == PlatformOS.isIOS
          ? "backup".tr()
          : "data-backup".tr(),
      appBarBackgroundColor: getPlatform() == PlatformOS.isIOS
          ? null
          : Theme.of(context).colorScheme.secondaryContainer,
      appBarBackgroundColorStart: getPlatform() == PlatformOS.isIOS
          ? null
          : Theme.of(context).colorScheme.secondaryContainer,
      bottomPadding: false,
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: googleUser == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SettingsContainerOutlined(
                        title: getPlatform() == PlatformOS.isIOS
                            ? "google-drive-backup".tr()
                            : "sign-in-with-google".tr(),
                        icon: getPlatform() == PlatformOS.isIOS
                            ? MoreIcons.google_drive
                            : MoreIcons.google,
                        isExpanded: false,
                        onTap: () async {
                          loadingIndeterminateKey.currentState
                              ?.setVisibility(true);
                          try {
                            await signInAndSync(context, next: () {});
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
                      getPlatform() == PlatformOS.isIOS
                          ? Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                MoreIcons.google_drive,
                                size: 50,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            )
                          : ClipOval(
                              child: googleUser == null ||
                                      googleUser!.photoUrl == null
                                  ? profileWidget
                                  : FadeInImage.memoryNetwork(
                                      fadeInDuration:
                                          Duration(milliseconds: 100),
                                      fadeOutDuration:
                                          Duration(milliseconds: 100),
                                      placeholder: kTransparentImage,
                                      image: googleUser!.photoUrl.toString(),
                                      height: 95,
                                      width: 95,
                                      imageErrorBuilder: (BuildContext context,
                                          Object exception,
                                          StackTrace? stackTrace) {
                                        return profileWidget;
                                      },
                                    ),
                            ),
                      SizedBox(height: 10),
                      TextFont(
                        text: getPlatform() == PlatformOS.isIOS
                            ? "google-drive-backup".tr()
                            : (googleUser?.displayName ?? "").toString(),
                        textAlign: TextAlign.center,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                      SizedBox(height: 2),
                      TextFont(
                        text: (appStateSettings["currentUserEmail"] ?? "")
                            .toString(),
                        textAlign: TextAlign.center,
                        fontSize: 15,
                      ),
                      SizedBox(height: 15),
                      IntrinsicWidth(
                        child: Button(
                          label: "logout".tr(),
                          onTap: () async {
                            final result = await signOutGoogle();
                            if (result == true) {
                              if (getIsFullScreen(context) == false) {
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
                                    text: "backup".tr(),
                                    iconData: appStateSettings["outlinedIcons"]
                                        ? Icons.cloud_upload_rounded
                                        : Icons.cloud_upload_rounded,
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
                                text: "restore".tr(),
                                iconData: appStateSettings["outlinedIcons"]
                                    ? Icons.cloud_download_outlined
                                    : Icons.cloud_download_rounded,
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
                                text: getPlatform() == PlatformOS.isIOS
                                    ? "devices".tr().capitalizeFirst
                                    : "sync".tr(),
                                iconData: getPlatform() == PlatformOS.isIOS
                                    ? appStateSettings["outlinedIcons"]
                                        ? Icons.devices_outlined
                                        : Icons.devices_rounded
                                    : appStateSettings["outlinedIcons"]
                                        ? Icons.cloud_sync_outlined
                                        : Icons.cloud_sync_rounded,
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
                                iconData: appStateSettings["outlinedIcons"]
                                    ? Icons.folder_outlined
                                    : Icons.folder_rounded,
                                onTap: () async {
                                  await chooseBackup(context, isManaging: true);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      getPlatform() == PlatformOS.isIOS
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 7),
                              child: Tappable(
                                borderRadius: 15,
                                onTap: () {
                                  openUrl(
                                      "https://cashewapp.web.app/policy.html");
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 10),
                                  child: TextFont(
                                    text:
                                        "google-drive-backup-description".tr(),
                                    textAlign: TextAlign.center,
                                    fontSize: 14,
                                    maxLines: 10,
                                    textColor: getColor(context, "textLight"),
                                  ),
                                ),
                              ),
                            )
                          : SizedBox(height: 75),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
