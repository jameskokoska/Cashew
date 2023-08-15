import 'dart:async';

import 'package:budget/colors.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/languageMap.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/breathingAnimation.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/moreIcons.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/statusBox.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sa3_liquid/sa3_liquid.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

bool premiumPopupEnabled = kIsWeb == false;
// A user has paid is appStateSettings["purchaseID"] is not null

class PremiumPage extends StatefulWidget {
  const PremiumPage({this.canDismiss = false, super.key});
  final bool canDismiss;

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PremiumBackground(),
        PageFramework(
          enableHeader: false,
          dragDownToDismiss: widget.canDismiss,
          dragDownToDissmissBackground: Colors.transparent,
          bottomPadding: false,
          backgroundColor: Colors.transparent,
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
                                height: MediaQuery.of(context).viewPadding.top +
                                    MediaQuery.of(context).size.height * 0.1,
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
                                  height: 13 +
                                      MediaQuery.of(context).size.height *
                                          0.022),
                              Products(key: purchasesStateKey),
                              SizedBox(height: 15),
                            ],
                          ),
                          widget.canDismiss
                              ? SizedBox.shrink()
                              : Opacity(
                                  opacity: 0.5,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Tappable(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      color: darkenPastel(
                                              Theme.of(context)
                                                  .colorScheme
                                                  .primary,
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
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: MediaQuery.of(context).viewPadding.left,
                        top: MediaQuery.of(context).viewPadding.top,
                        right: MediaQuery.of(context).viewPadding.right,
                      ),
                      child: IconButton(
                        padding: EdgeInsets.all(15),
                        icon: Icon(
                          getPlatform() == PlatformOS.isIOS
                              ? Icons.chevron_left_rounded
                              : Icons.arrow_back_rounded,
                          color: Colors.black
                              .withOpacity(widget.canDismiss ? 0.9 : 0.16),
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
  }
}

class CashewProBanner extends StatelessWidget {
  const CashewProBanner({this.large = false, this.fontColor, super.key});
  final bool large;
  final Color? fontColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
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

class ManageSubscription extends StatelessWidget {
  const ManageSubscription({super.key});

  openManagePurchase() {
    if (appStateSettings["purchaseID"] == "cashew.pro.lifetime") {
      return;
    } else if (appStateSettings["purchaseID"] == "cashew.pro.monthly") {
      openUrl(
          "https://play.google.com/store/account/subscriptions?sku=cashew.pro.monthly&package=com.budget.tracker_app");
    } else if (appStateSettings["purchaseID"] == "cashew.pro.yearly") {
      openUrl(
          "https://play.google.com/store/account/subscriptions?sku=cashew.pro.yearly&package=com.budget.tracker_app");
    }
  }

  @override
  Widget build(BuildContext context) {
    String? currentPlanName;
    if (appStateSettings["purchaseID"] == "cashew.pro.lifetime") {
      currentPlanName = "lifetime".tr();
    } else if (appStateSettings["purchaseID"] == "cashew.pro.monthly") {
      currentPlanName = "monthly".tr().capitalizeFirst;
    } else if (appStateSettings["purchaseID"] == "cashew.pro.yearly") {
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
            appStateSettings["purchaseID"] == "cashew.pro.lifetime"
                ? TextFont(
                    text: "already-purchased".tr(),
                    fontSize: 16,
                  )
                : TextFont(
                    text: "current-plan".tr(),
                    fontSize: 16,
                  ),
            SizedBox(height: 10),
            CashewProBanner(fontColor: Colors.white),
            TextFont(
              text: currentPlanName ?? "",
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: 10),
            appStateSettings["purchaseID"] == "cashew.pro.lifetime"
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

bool tryStoreEnabled = kIsWeb == false;
StreamSubscription<List<PurchaseDetails>>? purchaseListener;
Map<String, ProductDetails> storeProducts = {};
const Set<String> productIDs = <String>{
  'cashew.pro.yearly',
  'cashew.pro.monthly',
  'cashew.pro.lifetime',
};

void listenToPurchaseUpdated(
    List<PurchaseDetails> purchaseDetailsList, BuildContext context) {
  // ignore: avoid_function_literals_in_foreach_calls
  purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
    if (productIDs.contains(purchaseDetails.productID)) {
      if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        updateSettings("purchaseID", purchaseDetails.productID,
            updateGlobalState: false, pagesNeedingRefresh: [3]);
        print("Purchased " + purchaseDetails.productID);
      }

      if (purchaseDetails.status == PurchaseStatus.pending) {
        print("Loading purchase");
      } else {
        if (purchaseDetails.status == PurchaseStatus.error ||
            purchaseDetails.status == PurchaseStatus.canceled) {
          SnackBar snackBar = SnackBar(
            content: Text('error-processing-order'.tr()),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else if (purchaseDetails.status == PurchaseStatus.purchased) {
          SnackBar snackBar = SnackBar(
            content: Text('order-confirmation'.tr()),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchaseDetails);
        }
      }
    }
  });
}

Future<Map<String, ProductDetails>> initializeStoreAndPurchases(
    BuildContext context) async {
  if (tryStoreEnabled == true) {
    print("Loading Store");
    final bool available = await InAppPurchase.instance.isAvailable();
    if (available) {
      //Reset any purchases if we can connect to the store, they will be restored if a purchase was made
      updateSettings("purchaseID", null, updateGlobalState: false);

      Stream<List<PurchaseDetails>> purchaseUpdated =
          InAppPurchase.instance.purchaseStream;
      if (purchaseListener == null) {
        purchaseListener = purchaseUpdated.listen(
          (purchaseDetailsList) {
            listenToPurchaseUpdated(purchaseDetailsList, context);
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
      }

      final ProductDetailsResponse response =
          await InAppPurchase.instance.queryProductDetails(productIDs);
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
      content: Text('purchases-restored'.tr()),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

bool hidePremiumPopup() {
  return premiumPopupEnabled == false ||
      appStateSettings["purchaseID"] != null ||
      appStateSettings["previewDemo"] == true;
}

Future premiumPopupPushRoute(BuildContext context) async {
  if (hidePremiumPopup()) return;
  return pushRoute(context, PremiumPage());
}

void premiumPopupBudgets(BuildContext context) async {
  if (hidePremiumPopup()) return;
  if ((await database.getAllBudgets()).length > 0) {
    pushRoute(context, PremiumPage());
  }
}

void premiumPopupPastBudgets(BuildContext context) async {
  if (hidePremiumPopup()) return;
  pushRoute(context, PremiumPage());
}

Future premiumPopupAddTransaction(BuildContext context) async {
  if (hidePremiumPopup()) return;
  print("Checking premium before adding transaction - " +
      appStateSettings["premiumPopupAddTransactionCount"].toString());
  if (DateTime.parse(appStateSettings["premiumPopupAddTransactionLastShown"])
          .add(Duration(days: 1))
          .isBefore(DateTime.now()) &&
      appStateSettings["premiumPopupAddTransactionCount"] > 5 == 0) {
    updateSettings("premiumPopupAddTransactionCount", 0,
        updateGlobalState: false);
    updateSettings(
        "premiumPopupAddTransactionLastShown", DateTime.now.toString(),
        updateGlobalState: false);
    await pushRoute(context, PremiumPage(canDismiss: true));
  }
}

class Products extends StatefulWidget {
  const Products({super.key});

  @override
  State<Products> createState() => ProductsState();
}

class ProductsState extends State<Products> {
  bool hasProducts = storeProducts.isNotEmpty;
  bool loading = true;

  void refreshState() {
    print("refresh products");
    setState(() {});
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      Map<String, ProductDetails> products =
          await initializeStoreAndPurchases(context);
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
                      description: "error-getting-products-description".tr(),
                      icon: Icons.warning_rounded,
                      color: Theme.of(context).colorScheme.error,
                      onTap: () {},
                    )
              : Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal:
                          getHorizontalPaddingConstrained(context) + 20),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Column(
                          children: [
                            storeProducts["cashew.pro.yearly"] == null
                                ? SizedBox.shrink()
                                : SubscriptionOption(
                                    label: "yearly".tr().capitalizeFirst,
                                    price: storeProducts["cashew.pro.yearly"]!
                                            .price +
                                        " / " +
                                        "year".tr().toLowerCase(),
                                    extraPadding: EdgeInsets.only(top: 13 / 2),
                                    onTap: () {
                                      InAppPurchase.instance.buyNonConsumable(
                                        purchaseParam: PurchaseParam(
                                          productDetails: storeProducts[
                                              "cashew.pro.yearly"]!,
                                        ),
                                      );
                                    },
                                  ),
                            storeProducts["cashew.pro.monthly"] == null
                                ? SizedBox.shrink()
                                : SubscriptionOption(
                                    label: "monthly".tr().capitalizeFirst,
                                    price: storeProducts["cashew.pro.monthly"]!
                                            .price +
                                        " / " +
                                        "month".tr().toLowerCase(),
                                    onTap: () {
                                      InAppPurchase.instance.buyNonConsumable(
                                        purchaseParam: PurchaseParam(
                                          productDetails: storeProducts[
                                              "cashew.pro.monthly"]!,
                                        ),
                                      );
                                    },
                                  ),
                            storeProducts["cashew.pro.lifetime"] == null
                                ? SizedBox.shrink()
                                : SubscriptionOption(
                                    label: "lifetime".tr().capitalizeFirst,
                                    price: storeProducts["cashew.pro.lifetime"]!
                                        .price,
                                    extraPadding:
                                        EdgeInsets.only(bottom: 13 / 2),
                                    onTap: () {
                                      InAppPurchase.instance.buyNonConsumable(
                                        purchaseParam: PurchaseParam(
                                          productDetails: storeProducts[
                                              "cashew.pro.lifetime"]!,
                                        ),
                                      );
                                    },
                                  ),
                          ],
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
                      SizedBox(height: 7),
                      TextFont(
                        text: "one-coffee-a-month".tr() + " " + "☕",
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        textColor: Colors.black,
                      ),
                    ],
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
    required this.onTap,
    this.extraPadding,
    super.key,
  });
  final String label;
  final String price;
  final VoidCallback onTap;
  final EdgeInsets? extraPadding;

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: onTap,
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
        openPage: PremiumPage(canDismiss: true),
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
                                                      "cashew.pro.lifetime"
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
