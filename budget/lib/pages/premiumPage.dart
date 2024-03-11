import 'dart:async';

import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/languageMap.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/breathingAnimation.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/moreIcons.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/statusBox.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry/transactionEntry.dart';
import 'package:budget/widgets/viewAllTransactionsButton.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sa3_liquid/sa3_liquid.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

bool premiumPopupEnabled = kIsWeb == false;
bool tryStoreEnabled = kIsWeb == false && kDebugMode == false;
StreamSubscription<List<PurchaseDetails>>? purchaseListener;
Map<String, ProductDetails> storeProducts = {};
Map<String, String> productIDs = {
  'yearly': getPlatform(ignoreEmulation: true) == PlatformOS.isIOS
      ? 'cashew.pro.yearly' //iOS
      : 'cashew.pro.yearly', //Android
  'monthly': getPlatform(ignoreEmulation: true) == PlatformOS.isIOS
      ? 'cashew.pro.monthly' //iOS
      : 'cashew.pro.monthly', //Android
  'lifetime': getPlatform(ignoreEmulation: true) == PlatformOS.isIOS
      ? 'cashew.pro.life' //iOS
      : 'cashew.pro.lifetime', //Android
};

// A user has paid is appStateSettings["purchaseID"] is not null

class PremiumPage extends StatelessWidget {
  const PremiumPage({
    this.canDismiss = false,
    required this.popRouteWithPurchase,
    super.key,
  });
  final bool canDismiss;
  final bool popRouteWithPurchase;

  @override
  Widget build(BuildContext context) {
    Widget premiumPageWidget = Stack(
      children: [
        PremiumBackground(),
        PageFramework(
          enableHeader: false,
          dragDownToDismiss: canDismiss,
          bottomPadding: false,
          backgroundColor: Colors.transparent,
          transparentAppBar: true,
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              SizedBox(
                                height: MediaQuery.viewPaddingOf(context).top +
                                    MediaQuery.sizeOf(context).height * 0.1,
                              ),
                              Column(
                                children: [
                                  CashewProBanner(large: true),
                                  SizedBox(height: 4),
                                  TextFont(
                                    text: "budget-like-a-pro".tr() +
                                        " " +
                                        globalAppName +
                                        " " +
                                        "Pro",
                                    fontSize: 16,
                                    textColor: Colors.black,
                                    maxLines: 3,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                              SizedBox(
                                  height: 15 +
                                      MediaQuery.sizeOf(context).height *
                                          0.028),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: IntrinsicWidth(
                                  child: Column(
                                    children: [
                                      SubscriptionFeature(
                                        iconData:
                                            appStateSettings["outlinedIcons"]
                                                ? Icons.thumb_up_outlined
                                                : Icons.thumb_up_rounded,
                                        label: "support-the-developer".tr(),
                                        description:
                                            "support-the-developer-description"
                                                .tr(),
                                      ),
                                      SubscriptionFeature(
                                        iconData:
                                            appStateSettings["outlinedIcons"]
                                                ? Icons.donut_small_outlined
                                                : MoreIcons.chart_pie,
                                        label:
                                            "unlimited-budgets-and-goals".tr(),
                                        description:
                                            "unlimited-budgets-and-goals-description"
                                                .tr(),
                                      ),
                                      SubscriptionFeature(
                                        iconData:
                                            appStateSettings["outlinedIcons"]
                                                ? Icons.history_outlined
                                                : Icons.history_rounded,
                                        label: "past-budget-periods".tr(),
                                        description:
                                            "past-budget-periods-description"
                                                .tr(),
                                      ),
                                      SubscriptionFeature(
                                        iconData:
                                            appStateSettings["outlinedIcons"]
                                                ? Icons.color_lens_outlined
                                                : Icons.color_lens_rounded,
                                        label: "unlimited-color-picker".tr(),
                                        description:
                                            "unlimited-color-picker-description"
                                                .tr(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                  height: 13 +
                                      MediaQuery.sizeOf(context).height *
                                          0.028),
                              Products(
                                key: purchasesStateKey,
                                popRouteWithPurchase: popRouteWithPurchase,
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                          if (canDismiss == false)
                            Opacity(
                              opacity: 0.7,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Tappable(
                                  onTap: () async {
                                    var result = await openPopupCustom(
                                      context,
                                      barrierDismissible: false,
                                      child: FreePremiumMessage(),
                                    );
                                    // Highlight support options
                                    if (result is bool && result == false) {
                                      purchasesStateKey.currentState
                                          ?.highlightProducts();
                                    }
                                  },
                                  color: darkenPastel(
                                          Theme.of(context).colorScheme.primary,
                                          amount: 0.3)
                                      .withOpacity(0.5),
                                  borderRadius: 15,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 13, vertical: 9),
                                    child: TextFont(
                                      text: "continue-for-free".tr(),
                                      fontSize: 13.5,
                                      textColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: MediaQuery.viewPaddingOf(context).left,
                        top: MediaQuery.viewPaddingOf(context).top,
                        right: MediaQuery.viewPaddingOf(context).right,
                      ),
                      child: IconButton(
                        padding: EdgeInsets.all(15),
                        icon: Icon(
                          getPlatform() == PlatformOS.isIOS
                              ? appStateSettings["outlinedIcons"]
                                  ? Icons.chevron_left_outlined
                                  : Icons.chevron_left_rounded
                              : appStateSettings["outlinedIcons"]
                                  ? Icons.arrow_back_outlined
                                  : Icons.arrow_back_rounded,
                          color:
                              Colors.black.withOpacity(canDismiss ? 0.9 : 0.16),
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
          ],
        ),
      ],
    );
    bool enableSubscriptionAboutBanner =
        (getPlatform(ignoreEmulation: true) == PlatformOS.isAndroid &&
            appStateSettings["purchaseID"] != productIDs["lifetime"]);
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              Container(color: Colors.black),
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  enableSubscriptionAboutBanner ? 23 : 0,
                ),
                child: premiumPageWidget,
              ),
            ],
          ),
        ),
        if (enableSubscriptionAboutBanner)
          Container(
            color: Colors.black,
            child: Row(
              children: [
                Expanded(
                  child: Tappable(
                    borderRadius: 10,
                    onTap: () {
                      openManagePurchase();
                    },
                    color: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      child: TextFont(
                        text: "",
                        maxLines: 25,
                        textAlign: TextAlign.center,
                        richTextSpan: [
                          TextSpan(
                            text: "in-app-subscription-terms-1".tr() + " ",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.3),
                              fontFamily: appStateSettings["font"],
                              fontFamilyFallback: ['Inter'],
                            ),
                          ),
                          TextSpan(
                            text: "in-app-subscription-terms-2".tr(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.3),
                              fontFamily: appStateSettings["font"],
                              fontFamilyFallback: ['Inter'],
                              decoration: TextDecoration.underline,
                              decorationStyle: TextDecorationStyle.solid,
                              decorationColor: Colors.white.withOpacity(0.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class FreePremiumMessage extends StatefulWidget {
  const FreePremiumMessage({super.key});

  @override
  State<FreePremiumMessage> createState() => _FreePremiumMessageState();
}

class _FreePremiumMessageState extends State<FreePremiumMessage> {
  int remainingTime = appStateSettings["premiumPopupFreeSeen"] != true ? 26 : 0;
  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      for (int i = remainingTime; i > 0; i--) {
        if (mounted)
          setState(() {
            remainingTime--;
          });
        await Future.delayed(const Duration(milliseconds: 1000));
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool timerUp = remainingTime <= 0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        TextFont(
          maxLines: 5,
          fontWeight: FontWeight.bold,
          fontSize: 22,
          text: "from-the-developer".tr(),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10),
        TextFont(
            maxLines: 80,
            fontSize: 15.5,
            textAlign: TextAlign.left,
            text: "developer-message-1".tr() +
                (appStateSettings["premiumPopupFreeSeen"]
                    ? "."
                    : " " + "developer-message-1-1".tr())),
        SizedBox(height: 10),
        TextFont(
            maxLines: 80,
            fontSize: 15.5,
            textAlign: TextAlign.left,
            text: "developer-message-2".tr()),
        SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: Button(
                fontSize: 14,
                expandedLayout: true,
                label: "support".tr(),
                onTap: () {
                  if (timerUp) {
                    updateSettings("premiumPopupFreeSeen", true,
                        updateGlobalState: false);
                  }
                  Navigator.pop(context, false); //Pop current popup route
                },
              ),
            ),
            SizedBox(width: 7),
            Expanded(
              child: AnimatedOpacity(
                opacity: timerUp ? 1 : 0.5,
                duration: Duration(milliseconds: 500),
                child: Button(
                  fontSize: 14,
                  expandedLayout: true,
                  label: "unlock-for-free".tr() +
                      (timerUp == false
                          ? (" " + "(" + remainingTime.toString() + ")")
                          : ""),
                  onTap: () {
                    if (timerUp) {
                      Navigator.pop(context, true); //Pop current popup route
                      Navigator.pop(context, true); //Pop premium page route
                      updateSettings("premiumPopupFreeSeen", true,
                          updateGlobalState: false);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        AnimatedExpanded(
          expand: !(timerUp),
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Button(
              fontSize: 14,
              expandedLayout: true,
              label: "no-free-stuff".tr(),
              onTap: () {
                Navigator.pop(context); //Pop current route
                Navigator.pop(context, false); //Pop premium page route
              },
              color: Theme.of(context).colorScheme.tertiaryContainer,
              textColor: Theme.of(context).colorScheme.onTertiaryContainer,
            ),
          ),
        ),
      ],
    );
  }
}

class CashewProBanner extends StatelessWidget {
  const CashewProBanner({this.large = false, this.fontColor, super.key});
  final bool large;
  final Color? fontColor;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction: Axis.horizontal,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        TextFont(
          text: globalAppName,
          fontWeight: FontWeight.bold,
          fontSize: large ? 35 : 23,
          textColor: fontColor ?? Colors.black,
        ),
        SizedBox(width: 2),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 5),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(100),
            boxShadow: boxShadowGeneral(context),
          ),
          child: TextFont(
            text: "Pro",
            textColor: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: large ? 21 : 15,
          ),
        ),
      ],
    );
  }
}

openManagePurchase() {
  if (appStateSettings["purchaseID"] == productIDs["lifetime"]) {
    return;
  } else if (getPlatform(ignoreEmulation: true) == PlatformOS.isIOS) {
    openUrl("https://apps.apple.com/account/subscriptions");
  } else if (appStateSettings["purchaseID"] == productIDs["monthly"]) {
    openUrl(
        "https://play.google.com/store/account/subscriptions?sku=cashew.pro.monthly&package=com.budget.tracker_app");
  } else if (appStateSettings["purchaseID"] == productIDs["yearly"]) {
    openUrl(
        "https://play.google.com/store/account/subscriptions?sku=cashew.pro.yearly&package=com.budget.tracker_app");
  } else {
    if (getPlatform(ignoreEmulation: true) == PlatformOS.isAndroid)
      openUrl("https://play.google.com/store/account/subscriptions");
  }
}

class ManageSubscription extends StatelessWidget {
  const ManageSubscription({super.key});

  @override
  Widget build(BuildContext context) {
    String? currentPlanName;
    if (appStateSettings["purchaseID"] == productIDs["lifetime"]) {
      currentPlanName = "lifetime".tr();
    } else if (appStateSettings["purchaseID"] == productIDs["monthly"]) {
      currentPlanName = "monthly".tr().capitalizeFirst;
    } else if (appStateSettings["purchaseID"] == productIDs["yearly"]) {
      currentPlanName = "yearly".tr().capitalizeFirst;
    }
    return Tappable(
      onTap: () {
        openManagePurchase();
      },
      color: dynamicPastel(
        context,
        Theme.of(context).colorScheme.primaryContainer,
        amountDark: 0.2,
        amountLight: 0.6,
      ).withOpacity(0.45),
      borderRadius: 15,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 35, vertical: 15),
        child: Column(
          children: [
            appStateSettings["purchaseID"] == productIDs["lifetime"]
                ? TextFont(
                    text: "already-purchased".tr(),
                    fontSize: 16,
                  )
                : TextFont(
                    text: "current-plan".tr(),
                    fontSize: 16,
                  ),
            SizedBox(height: 10),
            CashewProBanner(fontColor: getColor(context, "black")),
            TextFont(
              text: currentPlanName ?? "",
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: 10),
            appStateSettings["purchaseID"] == productIDs["lifetime"]
                ? SizedBox.shrink()
                : Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Tappable(
                      borderRadius: 15,
                      color: dynamicPastel(
                        context,
                        Theme.of(context).colorScheme.primaryContainer,
                        amountDark: 0.2,
                        amountLight: 0.6,
                      ).withOpacity(0.45),
                      onTap: () async {
                        openManagePurchase();
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 6, horizontal: 13),
                        child: TextFont(
                          text: "manage".tr(),
                          fontSize: 12,
                          textColor:
                              getColor(context, "black").withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

void listenToPurchaseUpdated({
  required List<PurchaseDetails> purchaseDetailsList,
  required BuildContext context,
  required bool popRouteWithPurchase,
}) {
  // ignore: avoid_function_literals_in_foreach_calls
  purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
    if (productIDs.values.toSet().contains(purchaseDetails.productID)) {
      if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        updateSettings("purchaseID", purchaseDetails.productID,
            updateGlobalState: false, pagesNeedingRefresh: [3]);
        print("Purchased " + purchaseDetails.productID);
        if (popRouteWithPurchase == true &&
            navigatorKey.currentContext != null) {
          Navigator.pop(navigatorKey.currentContext!, true);
        }
      }

      if (purchaseDetails.status == PurchaseStatus.pending) {
        print("Loading purchase");
      } else {
        if (purchaseDetails.status == PurchaseStatus.error ||
            purchaseDetails.status == PurchaseStatus.canceled) {
          if (navigatorKey.currentContext != null) {
            SnackBar snackBar = SnackBar(
              content: Text('error-processing-order'.tr()),
            );
            ScaffoldMessenger.of(navigatorKey.currentContext!)
                .showSnackBar(snackBar);
          }
        } else if (purchaseDetails.status == PurchaseStatus.purchased) {
          if (navigatorKey.currentContext != null) {
            SnackBar snackBar = SnackBar(
              content: Text('order-confirmation'.tr()),
            );
            ScaffoldMessenger.of(navigatorKey.currentContext!)
                .showSnackBar(snackBar);
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchaseDetails);
        }
      }
    }
  });
}

Future<Map<String, ProductDetails>> initializeStoreAndPurchases(
    {required BuildContext context, required bool popRouteWithPurchase}) async {
  if (tryStoreEnabled == true) {
    print("Loading Store");
    final bool available = await InAppPurchase.instance.isAvailable();
    if (available) {
      //Reset any purchases if we can connect to the store, they will be restored if a purchase was made
      updateSettings("purchaseID", null, updateGlobalState: false);

      Stream<List<PurchaseDetails>> purchaseUpdated =
          InAppPurchase.instance.purchaseStream;
      purchaseListener?.cancel();
      purchaseListener = purchaseUpdated.listen(
        (purchaseDetailsList) {
          listenToPurchaseUpdated(
            purchaseDetailsList: purchaseDetailsList,
            context: context,
            popRouteWithPurchase: popRouteWithPurchase,
          );
        },
        onDone: () {
          purchaseListener?.cancel();
          purchaseListener = null;
        },
        onError: (error) {
          print(error);
          purchaseListener = null;
        },
      );
      final ProductDetailsResponse response = await InAppPurchase.instance
          .queryProductDetails(productIDs.values.toSet());
      if (response.notFoundIDs.isNotEmpty) {
        print("Some products not found...");
      } else {
        storeProducts = {
          for (var product in response.productDetails) product.id: product
        };
        print("Products Loaded");
        print(storeProducts);
      }
      print("Restoring any purchases");
      await InAppPurchase.instance.restorePurchases();
      return storeProducts;
    }
  }

  // Can't connect to store, don't show popup
  premiumPopupEnabled = false;
  return {};
}

Future restorePurchases(BuildContext context) async {
  if (storeProducts.isEmpty) {
    SnackBar snackBar = SnackBar(
      content: Text('error-processing-order'.tr()),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  } else {
    await InAppPurchase.instance.restorePurchases();
    SnackBar snackBar = SnackBar(
      content: Text('any-previous-purchases-restored'.tr()),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

bool hidePremiumPopup() {
  return premiumPopupEnabled == false ||
      appStateSettings["purchaseID"] != null ||
      appStateSettings["previewDemo"] == true;
}

Future<bool> premiumPopupPushRoute(BuildContext context) async {
  if (hidePremiumPopup()) return true;
  dynamic result = await pushRoute(
    context,
    PremiumPage(
      popRouteWithPurchase: true,
    ),
  );
  if (result == true) {
    return true;
  } else {
    return false;
  }
}

Future<bool> premiumPopupBudgets(BuildContext context) async {
  if (hidePremiumPopup()) return true;
  if ((await database.getAllBudgets()).length > 0) {
    if (await premiumPopupPushRoute(context) == true) {
      return true;
    } else {
      Navigator.pop(context);
      return false;
    }
  } else {
    return true;
  }
}

Future<bool> premiumPopupObjectives(BuildContext context,
    {required ObjectiveType objectiveType}) async {
  if (hidePremiumPopup()) return true;
  if ((await database.getAllObjectives(objectiveType: objectiveType)).length >
      0) {
    if (await premiumPopupPushRoute(context) == true) {
      return true;
    } else {
      Navigator.pop(context);
      return false;
    }
  } else {
    return true;
  }
}

Future<bool> premiumPopupPastBudgets(BuildContext context) async {
  if (hidePremiumPopup()) return true;
  if (await premiumPopupPushRoute(context) == true) {
    return true;
  } else {
    Navigator.pop(context);
    return false;
  }
}

Future premiumPopupAddTransaction(BuildContext context) async {
  if (hidePremiumPopup()) return true;

  print("Checking premium before adding transaction - " +
      appStateSettings["premiumPopupAddTransactionCount"].toString());

  try {
    DateTime.parse(appStateSettings["premiumPopupAddTransactionLastShown"]);
  } catch (e) {
    print("Error parsing date for premium popup, resetting...");
    updateSettings(
        "premiumPopupAddTransactionLastShown", DateTime.now().toString(),
        updateGlobalState: false);
  }

  if (DateTime.parse(appStateSettings["premiumPopupAddTransactionLastShown"])
          .add(Duration(days: 1))
          .isBefore(DateTime.now()) &&
      appStateSettings["premiumPopupAddTransactionCount"] > 5) {
    updateSettings("premiumPopupAddTransactionCount", 0,
        updateGlobalState: false);
    updateSettings(
        "premiumPopupAddTransactionLastShown", DateTime.now().toString(),
        updateGlobalState: false);
    await pushRoute(
      context,
      PremiumPage(
        popRouteWithPurchase: true,
        canDismiss: true,
      ),
    );
  }

  // Always return true, this is not an enforced feature
  return true;
}

class Products extends StatefulWidget {
  const Products({this.popRouteWithPurchase = false, super.key});
  final bool popRouteWithPurchase;

  @override
  State<Products> createState() => ProductsState();
}

class ProductsState extends State<Products> {
  bool hasProducts = storeProducts.isNotEmpty;
  bool loading = true;
  bool animateHighlightProducts = false;

  void refreshState() {
    print("refresh products");
    setState(() {});
  }

  void highlightProducts() {
    print("highlight products");
    setState(() {
      animateHighlightProducts = true;
    });
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      Map<String, ProductDetails> products = await initializeStoreAndPurchases(
        context: context,
        popRouteWithPurchase: widget.popRouteWithPurchase,
      );
      setState(() {
        hasProducts = products.isNotEmpty;
        loading = false;
      });
    });
    Future.delayed(Duration(milliseconds: 3500), () async {
      if (loading)
        setState(() {
          loading = false;
        });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 700),
      child: appStateSettings["purchaseID"] != null
          ? ManageSubscription()
          : kIsWeb || hasProducts == false
              ? loading == true
                  ? SizedBox.shrink()
                  : StatusBox(
                      title: "error-getting-products".tr(),
                      description: "error-getting-products-description".tr() +
                          (kDebugMode && tryStoreEnabled == false
                              ? " Store disabled in debug mode! Enable `tryStoreEnabled`"
                              : ""),
                      icon: appStateSettings["outlinedIcons"]
                          ? Icons.warning_outlined
                          : Icons.warning_rounded,
                      color: Theme.of(context).colorScheme.error,
                      onTap: () {
                        initializeStoreAndPurchases(
                          context: context,
                          popRouteWithPurchase: widget.popRouteWithPurchase,
                        );
                      },
                      forceDark: true,
                    )
              : Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal:
                          getHorizontalPaddingConstrained(context) + 28),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 300),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: FlashingContainer(
                            isAnimating: animateHighlightProducts,
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            loopCount: 2,
                            flashDuration: Duration(milliseconds: 650),
                            child: Container(
                              color: dynamicPastel(
                                context,
                                Theme.of(context).colorScheme.primaryContainer,
                                amountDark: 0.2,
                                amountLight: 0.6,
                              ).withOpacity(0.45),
                              child: Column(
                                children: [
                                  Builder(
                                    builder: (context) {
                                      if (storeProducts[productIDs["yearly"]] ==
                                              null ||
                                          storeProducts[
                                                  productIDs["monthly"]] ==
                                              null) {
                                        return SizedBox.shrink();
                                      }
                                      final double monthlyPrice =
                                          storeProducts[productIDs["monthly"]]!
                                              .rawPrice;
                                      final double monthlyPriceForYear =
                                          (monthlyPrice * 12);
                                      return storeProducts[
                                                  productIDs["yearly"]] ==
                                              null
                                          ? SizedBox.shrink()
                                          : SubscriptionOption(
                                              label:
                                                  "yearly".tr().capitalizeFirst,
                                              price: storeProducts[
                                                      productIDs["yearly"]]!
                                                  .price,
                                              extraPadding:
                                                  EdgeInsets.only(top: 13 / 2),
                                              onTap: () {
                                                InAppPurchase.instance
                                                    .buyNonConsumable(
                                                  purchaseParam: PurchaseParam(
                                                    productDetails:
                                                        storeProducts[
                                                            productIDs[
                                                                "yearly"]]!,
                                                  ),
                                                );
                                              },
                                              originalPrice: storeProducts[
                                                          productIDs["yearly"]]!
                                                      .currencySymbol +
                                                  monthlyPriceForYear
                                                      .toStringAsFixed(2),
                                            );
                                    },
                                  ),
                                  storeProducts[productIDs["monthly"]] == null
                                      ? SizedBox.shrink()
                                      : SubscriptionOption(
                                          label: "monthly".tr().capitalizeFirst,
                                          price: storeProducts[
                                                  productIDs["monthly"]]!
                                              .price,
                                          onTap: () {
                                            InAppPurchase.instance
                                                .buyNonConsumable(
                                              purchaseParam: PurchaseParam(
                                                productDetails: storeProducts[
                                                    productIDs["monthly"]]!,
                                              ),
                                            );
                                          },
                                        ),
                                  storeProducts[productIDs["lifetime"]] == null
                                      ? SizedBox.shrink()
                                      : SubscriptionOption(
                                          label:
                                              "lifetime".tr().capitalizeFirst,
                                          price: storeProducts[
                                                  productIDs["lifetime"]]!
                                              .price,
                                          extraPadding:
                                              EdgeInsets.only(bottom: 13 / 2),
                                          onTap: () {
                                            InAppPurchase.instance
                                                .buyNonConsumable(
                                              purchaseParam: PurchaseParam(
                                                productDetails: storeProducts[
                                                    productIDs["lifetime"]]!,
                                              ),
                                            );
                                          },
                                        ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          child: Tappable(
                            borderRadius: 15,
                            color: dynamicPastel(
                              context,
                              Theme.of(context).colorScheme.primaryContainer,
                              amountDark: 0.2,
                              amountLight: 0.6,
                            ).withOpacity(0.45),
                            onTap: () async {
                              restorePurchases(context);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 13),
                              child: TextFont(
                                text: "restore-purchases".tr(),
                                fontSize: 12,
                                textColor:
                                    getColor(context, "black").withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  textColor: Colors.black,
                  maxLines: 3,
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
    this.originalPrice,
    required this.onTap,
    this.extraPadding,
    super.key,
  });
  final String label;
  final String price;
  final String? originalPrice;
  final VoidCallback onTap;
  final EdgeInsets? extraPadding;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Tappable(
            onTap: onTap,
            color: Colors.transparent,
            borderRadius: 0,
            child: Padding(
              padding: extraPadding ?? EdgeInsets.zero,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 26, vertical: 13),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  direction: Axis.horizontal,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    TextFont(
                      text: label,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      textColor: getColor(context, "black"),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TextFont(
                          text: "",
                          richTextSpan: [
                            TextSpan(
                              text: originalPrice,
                              style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                decorationStyle: TextDecorationStyle.solid,
                                decorationColor: getColor(context, "black")
                                    .withOpacity(0.65),
                                color:
                                    getColor(context, "black").withOpacity(0.7),
                                fontSize: 14,
                                fontFamily: appStateSettings["font"],
                                fontFamilyFallback: ['Inter'],
                              ),
                            ),
                            TextSpan(
                              text: originalPrice == null ? null : "  ",
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: appStateSettings["font"],
                                fontFamilyFallback: ['Inter'],
                              ),
                            ),
                            TextSpan(
                              text: price,
                              style: TextStyle(
                                color: getColor(context, "black"),
                                fontSize: 17,
                                fontFamily: appStateSettings["font"],
                                fontFamilyFallback: ['Inter'],
                              ),
                            ),
                          ],
                          fontSize: 17,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
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
          Icon(appStateSettings["outlinedIcons"]
              ? Icons.lock_outlined
              : Icons.lock_rounded),
        ],
      );
    return Tappable(
      onTap: () async {
        bool result = await premiumPopupPushRoute(context);
        if (actionAfter != null && result == true) actionAfter!();
      },
      borderRadius: 20,
      color: Colors.transparent,
      child: child,
    );
  }
}

class FadeOutAndLockFeature extends StatefulWidget {
  const FadeOutAndLockFeature(
      {required this.child,
      this.actionAfter,
      this.hasInitiallyDismissed = false,
      super.key});
  final Widget child;
  final VoidCallback? actionAfter;
  final bool hasInitiallyDismissed;

  @override
  State<FadeOutAndLockFeature> createState() => _FadeOutAndLockFeatureState();
}

class _FadeOutAndLockFeatureState extends State<FadeOutAndLockFeature> {
  bool fadeIn = false;
  bool dismissedPremium = false;

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      if (hidePremiumPopup() == false)
        setState(() {
          fadeIn = true;
        });
    });
    super.initState();
  }

  void openPremiumPopup() async {
    bool result = await premiumPopupPushRoute(context);
    if (result == true) {
      if (widget.actionAfter != null) widget.actionAfter!();
      setState(() {
        dismissedPremium = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (hidePremiumPopup() ||
        dismissedPremium ||
        widget.hasInitiallyDismissed) {
      return widget.child;
    }
    return Tappable(
      color: Colors.transparent,
      borderRadius: 15,
      onTap: openPremiumPopup,
      child: Stack(
        alignment: Alignment.center,
        children: [
          IgnorePointer(
            child: AnimatedOpacity(
              opacity: fadeIn ? 0.23 : 1,
              duration: Duration(milliseconds: 5000),
              child: AnimatedOpacity(
                opacity: fadeIn ? 0.25 : 1,
                duration: Duration(milliseconds: 500),
                child: widget.child,
              ),
            ),
          ),
          AnimatedOpacity(
            opacity: fadeIn ? 1 : 0,
            duration: Duration(milliseconds: 500),
            child: Column(
              children: [
                TextFont(
                  text: "unlock-with".tr(),
                  fontSize: 15,
                ),
                SizedBox(height: 5),
                CashewProBanner(fontColor: getColor(context, "black")),
                SizedBox(height: 15),
                LowKeyButton(
                  onTap: openPremiumPopup,
                  text: "learn-more".tr().capitalizeFirstofEach,
                  color: dynamicPastel(
                    context,
                    Theme.of(context).colorScheme.secondaryContainer,
                    amount: 0.4,
                  ).withOpacity(0.8),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PremiumBackground extends StatelessWidget {
  const PremiumBackground(
      {this.disableAnimation = false, this.purchased = false, super.key});
  final bool disableAnimation;
  final bool purchased;

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
    bool purchased = appStateSettings["purchaseID"] != null;

    return Container(
      decoration: BoxDecoration(
          boxShadow: boxShadowSharp(context),
          borderRadius: BorderRadius.circular(borderRadius)),
      margin: const EdgeInsets.symmetric(horizontal: 9, vertical: 0),
      child: OpenContainerNavigation(
        borderRadius: borderRadius,
        openPage: PremiumPage(canDismiss: true, popRouteWithPurchase: false),
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
                        purchased: purchased,
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CashewProBanner(),
                                    purchased
                                        ? Container(
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 5),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondaryContainer,
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              boxShadow:
                                                  boxShadowGeneral(context),
                                            ),
                                            child: TextFont(
                                              text: appStateSettings[
                                                          "purchaseID"] ==
                                                      productIDs["lifetime"]
                                                  ? "lifetime".tr()
                                                  : "active".tr(),
                                              textColor: Theme.of(context)
                                                  .colorScheme
                                                  .onSecondaryContainer
                                                  .withOpacity(0.8),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          )
                                        : SizedBox.shrink(),
                                  ],
                                ),
                                purchased
                                    ? SizedBox.shrink()
                                    : Row(
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
                          appStateSettings["purchaseID"] != null
                              ? SizedBox.shrink()
                              : Icon(
                                  appStateSettings["outlinedIcons"]
                                      ? Icons.arrow_forward_ios_outlined
                                      : Icons.arrow_forward_ios_rounded,
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
