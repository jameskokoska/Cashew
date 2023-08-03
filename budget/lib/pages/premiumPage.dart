import 'package:budget/colors.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/languageMap.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/moreIcons.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sa3_liquid/sa3_liquid.dart';

class PremiumPage extends StatelessWidget {
  const PremiumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageFramework(
      enableHeader: false,
      dragDownToDismiss: true,
      bottomPadding: false,
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      tileMode: TileMode.mirror,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.tertiary,
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.tertiary,
                      ],
                      stops: [
                        0,
                        0.5,
                        1,
                      ],
                    ),
                    backgroundBlendMode: BlendMode.srcOver,
                  ),
                  child: PlasmaRenderer(
                    type: PlasmaType.infinity,
                    particles: 7,
                    color: Color(0x44B6B6B6),
                    blur: 0.4,
                    size: 0.8,
                    speed: 3,
                    offset: 0,
                    blendMode: BlendMode.plus,
                    particleType: ParticleType.atlas,
                    variation1: 0,
                    variation2: 0,
                    variation3: 0,
                    rotation: 0,
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
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
                                    margin: EdgeInsets.symmetric(horizontal: 5),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 5),
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      borderRadius: BorderRadius.circular(100),
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
                                text: "Budget like a pro with" +
                                    " " +
                                    globalAppName +
                                    " " +
                                    "Pro",
                                fontSize: 16,
                                textColor: Colors.black,
                              ),
                            ],
                          ),
                          SizedBox(height: 25),
                          IntrinsicWidth(
                            child: Column(children: [
                              SubscriptionFeature(
                                iconData: Icons.thumb_up_rounded,
                                label: "Support the developer",
                              ),
                              // SubscriptionFeature(
                              //   iconData: Icons.payments_rounded,
                              //   label: "Unlimited transactions",
                              //   description:
                              //       "Create more than 5 transactions a week",
                              // ),
                              // every 5 transactions show popup, max once a day
                              SubscriptionFeature(
                                iconData: MoreIcons.chart_pie,
                                label: "Unlimited budgets",
                                description: "Create more than 1 budget",
                              ),
                              SubscriptionFeature(
                                iconData: Icons.history_rounded,
                                label: "Past budget periods",
                                description:
                                    "View budget breakdowns of past periods",
                              ),
                              SubscriptionFeature(
                                iconData: Icons.color_lens_rounded,
                                label: "Unlimited color picker",
                                description: "Pick any color you want",
                              ),
                            ]),
                          ),
                          SizedBox(height: 25),
                          Column(
                            children: [
                              SubscriptionOption(
                                label: "Yearly",
                                price: "\$20 / year",
                              ),
                              SubscriptionOption(
                                label: "Monthly",
                                price: "\$2.50 / month",
                              ),
                              SubscriptionOption(
                                label: "One Time",
                                price: "\$30.00",
                              ),
                            ],
                          ),
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
                                text: "Continue for free",
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
                        Icons.arrow_back_rounded,
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
    super.key,
  });
  final String label;
  final String price;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: getHorizontalPaddingConstrained(context)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
        child: Tappable(
          onTap: () {},
          color: darkenPastel(Theme.of(context).colorScheme.primaryContainer,
                  amount: 0.2)
              .withOpacity(0.45),
          borderRadius: 22,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 19),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextFont(
                  text: label,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  textColor: Colors.white,
                ),
                TextFont(
                  text: price,
                  fontSize: 18,
                  textColor: Colors.white,
                ),
              ],
            ),
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

bool premiumPopupEnabled = true && !kIsWeb;

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
