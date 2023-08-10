import 'package:budget/colors.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/languageMap.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/breathingAnimation.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/moreIcons.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sa3_liquid/sa3_liquid.dart';
import 'package:budget/widgets/openContainerNavigation.dart';

class PremiumPage extends StatelessWidget {
  const PremiumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PremiumBackground(),
        PageFramework(
          enableHeader: false,
          dragDownToDismiss: false,
          bottomPadding: false,
          backgroundColor: Colors.transparent,
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).viewPadding.top +
                                    MediaQuery.of(context).size.height * 0.1,
                              ),
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextFont(
                                        text: globalAppName,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 35,
                                        textColor: Colors.black,
                                      ),
                                      SizedBox(width: 4),
                                      Container(
                                        margin:
                                            EdgeInsets.symmetric(horizontal: 5),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          boxShadow: boxShadowGeneral(context),
                                        ),
                                        child: TextFont(
                                          text: "Pro",
                                          textColor: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 21,
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  TextFont(
                                    text: "budget-like-a-pro".tr() +
                                        " " +
                                        globalAppName +
                                        " " +
                                        "Pro",
                                    fontSize: 16,
                                    textColor: Colors.black,
                                  ),
                                ],
                              ),
                              SizedBox(
                                  height: 15 +
                                      MediaQuery.of(context).size.height *
                                          0.024),
                              IntrinsicWidth(
                                child: Column(children: [
                                  SubscriptionFeature(
                                    iconData: Icons.thumb_up_rounded,
                                    label: "support-the-developer".tr(),
                                    description:
                                        "support-the-developer-description"
                                            .tr(),
                                  ),
                                  SubscriptionFeature(
                                    iconData: MoreIcons.chart_pie,
                                    label: "unlimited-budgets".tr(),
                                    description:
                                        "unlimited-budgets-description".tr(),
                                  ),
                                  SubscriptionFeature(
                                    iconData: Icons.history_rounded,
                                    label: "past-budget-periods".tr(),
                                    description:
                                        "past-budget-periods-description".tr(),
                                  ),
                                  SubscriptionFeature(
                                    iconData: Icons.color_lens_rounded,
                                    label: "unlimited-color-picker".tr(),
                                    description:
                                        "unlimited-color-picker-description"
                                            .tr(),
                                  ),
                                ]),
                              ),
                              SizedBox(
                                  height: 15 +
                                      MediaQuery.of(context).size.height *
                                          0.024),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: getHorizontalPaddingConstrained(
                                            context) +
                                        20),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Column(
                                    children: [
                                      SubscriptionOption(
                                        label: "Yearly",
                                        price: "\$19.99 / year",
                                        extraPadding:
                                            EdgeInsets.only(top: 13 / 2),
                                      ),
                                      SubscriptionOption(
                                        label: "Monthly",
                                        price: "\$1.99 / month",
                                      ),
                                      SubscriptionOption(
                                        label: "One Time",
                                        price: "\$29.99",
                                        extraPadding:
                                            EdgeInsets.only(bottom: 13 / 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 7),
                              TextFont(
                                text: "Just one coffee a month! ☕",
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                textColor: Colors.black,
                              ),
                              SizedBox(height: 15),
                            ],
                          ),
                          Opacity(
                            opacity: 0.5,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Tappable(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                color: darkenPastel(
                                        Theme.of(context).colorScheme.primary,
                                        amount: 0.3)
                                    .withOpacity(0.5),
                                borderRadius: 15,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  child: TextFont(
                                    text: "continue-for-free".tr(),
                                    fontSize: 13,
                                    textColor: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: MediaQuery.of(context).viewPadding.left,
                          top: MediaQuery.of(context).viewPadding.top,
                        ),
                        child: IconButton(
                          padding: EdgeInsets.all(15),
                          icon: Icon(
                            getPlatform() == PlatformOS.isIOS
                                ? Icons.chevron_left_rounded
                                : Icons.arrow_back_rounded,
                            color: Colors.black.withOpacity(0.16),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SubscriptionFeature extends StatelessWidget {
  const SubscriptionFeature({
    required this.iconData,
    required this.label,
    this.description,
    super.key,
  });
  final IconData iconData;
  final String label;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: Theme.of(context).colorScheme.primary,
              boxShadow: boxShadowGeneral(context),
            ),
            padding: EdgeInsets.all(10),
            child: Icon(
              iconData,
              size: 23,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFont(
                  text: label,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  textColor: Colors.black,
                ),
                description != null
                    ? TextFont(
                        text: description!,
                        fontSize: 13,
                        textColor: Colors.black,
                        maxLines: 5,
                      )
                    : SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SubscriptionOption extends StatelessWidget {
  const SubscriptionOption({
    required this.label,
    required this.price,
    this.extraPadding,
    super.key,
  });
  final String label;
  final String price;
  final EdgeInsets? extraPadding;

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: () {},
      color: dynamicPastel(
        context,
        Theme.of(context).colorScheme.primaryContainer,
        amountDark: 0.2,
        amountLight: 0.6,
      ).withOpacity(0.45),
      borderRadius: 0,
      child: Padding(
        padding: extraPadding ?? EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextFont(
                text: label,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                textColor: getColor(context, "black"),
              ),
              TextFont(
                text: price,
                fontSize: 18,
                textColor: getColor(context, "black"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LockedFeature extends StatelessWidget {
  const LockedFeature(
      {required this.child, this.actionAfter, this.showLock = false, Key? key})
      : super(key: key);
  final Widget child;
  final Function? actionAfter;
  final bool showLock;

  @override
  Widget build(BuildContext context) {
    Widget child = IgnorePointer(child: this.child);
    if (showLock)
      child = Stack(
        alignment: Alignment.center,
        children: [
          IgnorePointer(child: this.child),
          Icon(Icons.lock_rounded),
        ],
      );
    return Tappable(
      onTap: () async {
        await premiumPopupPushRoute(context);
        if (actionAfter != null) actionAfter!();
      },
      borderRadius: 20,
      color: Colors.transparent,
      child: child,
    );
  }
}

Future premiumPopupPushRoute(BuildContext context) async {
  if (premiumPopupEnabled) {
    return pushRoute(context, PremiumPage());
  }
}

void premiumPopupBudgets(BuildContext context) async {
  if (premiumPopupEnabled && (await database.getAllBudgets()).length > 0) {
    pushRoute(context, PremiumPage());
  }
}

void premiumPopupPastBudgets(BuildContext context) async {
  if (premiumPopupEnabled) {
    pushRoute(context, PremiumPage());
  }
}

Future premiumPopupAddTransaction(BuildContext context) async {
  print("Checking premium before adding transaction - " +
      appStateSettings["premiumPopupAddTransactionCount"].toString());
  if (premiumPopupEnabled &&
      DateTime.parse(appStateSettings["premiumPopupAddTransactionLastShown"])
          .add(Duration(days: 1))
          .isBefore(DateTime.now()) &&
      appStateSettings["premiumPopupAddTransactionCount"] > 5 == 0) {
    updateSettings("premiumPopupAddTransactionCount", 0,
        updateGlobalState: false);
    updateSettings(
        "premiumPopupAddTransactionLastShown", DateTime.now.toString(),
        updateGlobalState: false);
    await pushRoute(context, PremiumPage());
  }
}

class PremiumBackground extends StatelessWidget {
  const PremiumBackground({this.disableAnimation = false, super.key});
  final bool disableAnimation;

  @override
  Widget build(BuildContext context) {
    Widget background = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          tileMode: TileMode.mirror,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            dynamicPastel(
                context,
                Theme.of(context).brightness == Brightness.light
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.tertiary,
                amountDark: 0,
                amountLight: 0.4),
            dynamicPastel(
                context,
                Theme.of(context).brightness == Brightness.light
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.primary,
                amountDark: 0,
                amountLight: 0.4),
            dynamicPastel(
                context,
                Theme.of(context).brightness == Brightness.light
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.tertiary,
                amountDark: 0,
                amountLight: 0.4),
          ],
          stops: disableAnimation
              ? [0, 0.4, 2.5]
              : [
                  0,
                  0.3,
                  1.3,
                ],
        ),
        backgroundBlendMode: BlendMode.srcOver,
      ),
      child: disableAnimation
          ? Container()
          : PlasmaRenderer(
              type: PlasmaType.infinity,
              particles: 7,
              color: Theme.of(context).brightness == Brightness.light
                  ? Color(0x28B4B4B4)
                  : Color(0x44B6B6B6),
              blur: 0.4,
              size: 0.8,
              speed: Theme.of(context).brightness == Brightness.light ? 4 : 3,
              offset: 0,
              blendMode: BlendMode.plus,
              particleType: ParticleType.atlas,
              variation1: 0,
              variation2: 0,
              variation3: 0,
              rotation: 0,
            ),
    );
    if (disableAnimation) {
      return BreathingWidget(
        curve: Curves.easeIn,
        duration: Duration(milliseconds: 1000),
        endScale: 1.7,
        child: background,
      );
    } else {
      return background;
    }
  }
}

class PremiumBanner extends StatelessWidget {
  const PremiumBanner({super.key});

  @override
  Widget build(BuildContext context) {
    double borderRadius = 15;
    return Container(
      decoration: BoxDecoration(
          boxShadow: boxShadowSharp(context),
          borderRadius: BorderRadius.circular(borderRadius)),
      margin: const EdgeInsets.symmetric(horizontal: 9, vertical: 0),
      child: OpenContainerNavigation(
        borderRadius: borderRadius,
        openPage: PremiumPage(),
        closedColor: Theme.of(context).brightness == Brightness.light
            ? Theme.of(context).colorScheme.secondaryContainer
            : Theme.of(context).colorScheme.secondary,
        button: (openContainer) {
          return Tappable(
            color: Colors.transparent,
            borderRadius: borderRadius,
            onTap: () {
              if (kIsWeb)
                openUrl("https://ko-fi.com/dapperappdeveloper");
              else
                openContainer();
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: IntrinsicHeight(
                child: Stack(
                  children: [
                    Opacity(
                      opacity: Theme.of(context).brightness == Brightness.light
                          ? 0.7
                          : 0.9,
                      child: PremiumBackground(
                        disableAnimation:
                            getPlatform() == PlatformOS.isIOS || kIsWeb,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 25, right: 17, top: 17, bottom: 17),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    TextFont(
                                      text: globalAppName,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 23,
                                      textColor: Colors.black,
                                    ),
                                    SizedBox(width: 2),
                                    Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 5),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        boxShadow: boxShadowGeneral(context),
                                      ),
                                      child: TextFont(
                                        text: "Pro",
                                        textColor: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    Flexible(
                                      child: TextFont(
                                        text: "budget-like-a-pro".tr() +
                                            " " +
                                            globalAppName +
                                            " " +
                                            "Pro",
                                        fontSize: 15,
                                        maxLines: 3,
                                        textColor: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.black,
                            size: 20,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
