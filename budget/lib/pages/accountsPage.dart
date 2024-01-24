import 'dart:io';

import 'package:budget/colors.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/accountAndBackup.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/dropdownSelect.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/iconButtonScaled.dart';
import 'package:budget/widgets/moreIcons.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

import '../widgets/extraInfoBoxes.dart';
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
      actions: [
        // Show the tip if it was dissmissed
        if (kIsWeb && appStateSettings["autoLoginDisabledOnWebTip"] == false)
          CustomPopupMenuButton(
            showButtons: true,
            keepOutFirst: true,
            items: [
              DropdownItemMenu(
                id: "auto-login-disabled-info",
                label: "info".tr(),
                icon: appStateSettings["outlinedIcons"]
                    ? Icons.info_outlined
                    : Icons.info_outline_rounded,
                action: () {
                  openPopup(
                    context,
                    icon: appStateSettings["outlinedIcons"]
                        ? Icons.lightbulb_outlined
                        : Icons.lightbulb_outline_rounded,
                    title: "auto-login-disabled-on-web".tr(),
                    description: "why-is-auto-login-disabled-on-web".tr(),
                    onExtraLabel2: "read-more-here".tr(),
                    onExtra2: () {
                      openUrl(
                          "https://pub.dev/packages/google_sign_in_web#differences-between-google-identity-services-sdk-and-google-sign-in-for-web-sdk");
                    },
                    onSubmit: () {
                      Navigator.pop(context);
                    },
                    onSubmitLabel: "ok".tr(),
                  );
                },
              ),
            ],
          ),
      ],
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
                                        ? Icons.cloud_upload_outlined
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
                              child: SyncCloudBackupButton(
                                onTap: () async {
                                  chooseBackup(context,
                                      isManaging: true, isClientSync: true);
                                },
                              ),
                            ),
                            SizedBox(width: 18),
                            Expanded(
                              child: BackupsCloudBackupButton(
                                onTap: () async {
                                  await chooseBackup(context, isManaging: true);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (kIsWeb)
                        TipBox(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 7),
                          settingsString: "autoLoginDisabledOnWebTip",
                          onTap: () {
                            openUrl(
                                "https://pub.dev/packages/google_sign_in_web#differences-between-google-identity-services-sdk-and-google-sign-in-for-web-sdk");
                          },
                          text: "",
                          richTextSpan: [
                            TextSpan(
                              text: "why-is-auto-login-disabled-on-web".tr() +
                                  " ",
                              style: TextStyle(
                                color: getColor(context, "black"),
                                fontFamily: appStateSettings["font"],
                                fontFamilyFallback: ['Inter'],
                              ),
                            ),
                            TextSpan(
                              text: "read-more-here".tr() + ".",
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                decorationStyle: TextDecorationStyle.solid,
                                decorationColor:
                                    getColor(context, "unPaidOverdue")
                                        .withOpacity(0.8),
                                color: getColor(context, "unPaidOverdue")
                                    .withOpacity(0.8),
                                fontFamily: appStateSettings["font"],
                                fontFamilyFallback: ['Inter'],
                              ),
                            ),
                          ],
                        ),
                      // if (kIsWeb)
                      //   Padding(
                      //     padding: const EdgeInsets.symmetric(
                      //         horizontal: 18, vertical: 15),
                      //     child: SettingsContainerSwitch(
                      //       icon: appStateSettings["outlinedIcons"]
                      //           ? Icons.key_outlined
                      //           : Icons.key_rounded,
                      //       isOutlined: true,
                      //       horizontalPadding: 20,
                      //       title: "automatic-google-login-popup-web".tr(),
                      //       description:
                      //           "automatic-google-login-popup-web-description"
                      //               .tr(),
                      //       initialValue: appStateSettings[
                      //               "webForceLoginPopupOnLaunch"] ==
                      //           true,
                      //       onSwitched: (value) async {
                      //         await updateSettings(
                      //             "webForceLoginPopupOnLaunch", value,
                      //             updateGlobalState: false);
                      //       },
                      //     ),
                      //   ),
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

class SyncCloudBackupButton extends StatelessWidget {
  const SyncCloudBackupButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButtonStacked(
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
      onTap: onTap,
    );
  }
}

class BackupsCloudBackupButton extends StatelessWidget {
  const BackupsCloudBackupButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButtonStacked(
      text: "backups".tr(),
      iconData: appStateSettings["outlinedIcons"]
          ? Icons.folder_outlined
          : Icons.folder_rounded,
      onTap: onTap,
    );
  }
}

class SignInWithGoogleFlyIn extends StatefulWidget {
  const SignInWithGoogleFlyIn({super.key});

  @override
  State<SignInWithGoogleFlyIn> createState() => _SignInWithGoogleFlyInState();
}

class _SignInWithGoogleFlyInState extends State<SignInWithGoogleFlyIn> {
  bool hide = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      child: SlideFadeTransition(
        animate: true,
        animationDuration: Duration(milliseconds: 1700),
        curve: ElasticOutCurve(0.8),
        delayStart: Duration(milliseconds: 1900),
        offset: -0.5,
        child: AnimatedExpanded(
          expand: !hide,
          child: Align(
            alignment: Alignment.topRight,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 400),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(13)),
                  color: getColor(context, "lightDarkAccentHeavyLight"),
                  boxShadow: boxShadowCheck(boxShadowSharp(context)),
                ),
                child: Tappable(
                  onTap: () async {
                    await signInGoogle();
                    setState(() {
                      hide = true;
                    });
                  },
                  borderRadius: 13,
                  color: dynamicPastel(
                    context,
                    Theme.of(context).colorScheme.secondaryContainer,
                    amount: 0.6,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 25,
                            right: 15,
                            top: 15,
                            bottom: 15,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    MoreIcons.google,
                                    size: 25,
                                  ),
                                  SizedBox(width: 10),
                                  TextFont(
                                    text: "sign-in-with-google".tr(),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 18.0),
                                child: IconButtonScaled(
                                  iconData: appStateSettings["outlinedIcons"]
                                      ? Icons.close_outlined
                                      : Icons.close_rounded,
                                  iconSize: 18,
                                  scale: 1.5,
                                  onTap: () async {
                                    setState(() {
                                      hide = true;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      HorizontalBreak(
                        padding: EdgeInsets.zero,
                        color: dynamicPastel(
                          context,
                          Theme.of(context).colorScheme.secondaryContainer,
                          amount: 0.1,
                          inverse: true,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 12),
                        child: Button(
                          label: "Continue with Google",
                          onTap: () async {
                            await signInGoogle();
                            setState(() {
                              hide = true;
                            });
                          },
                          color: Theme.of(context).colorScheme.primary,
                          textColor: Theme.of(context).colorScheme.onPrimary,
                          borderRadius: 5,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 22, right: 22, bottom: 22),
                        child: TextFont(
                          text: "onboarding-info-3".tr(),
                          maxLines: 10,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
