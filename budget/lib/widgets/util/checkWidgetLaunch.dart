import 'dart:async';

import 'package:budget/colors.dart';
import 'package:budget/database/generatePreviewData.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/homePage/homePageHeatmap.dart';
import 'package:budget/pages/homePage/homePageLineGraph.dart';
import 'package:budget/pages/homePage/homePageNetWorth.dart';
import 'package:budget/pages/homePage/homePageObjectives.dart';
import 'package:budget/pages/homePage/homePagePieChart.dart';
import 'package:budget/pages/homePage/homePageWalletList.dart';
import 'package:budget/pages/homePage/homePageWalletSwitcher.dart';
import 'package:budget/pages/homePage/homeTransactions.dart';
import 'package:budget/pages/homePage/homePageUsername.dart';
import 'package:budget/pages/homePage/homePageBudgets.dart';
import 'package:budget/pages/homePage/homePageUpcomingTransactions.dart';
import 'package:budget/pages/homePage/homePageAllSpendingSummary.dart';
import 'package:budget/pages/editHomePage.dart';
import 'package:budget/pages/settingsPage.dart';
import 'package:budget/pages/homePage/homePageCreditDebts.dart';
import 'package:budget/pages/transactionFilters.dart';
import 'package:budget/pages/walletDetailsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/initializeNotifications.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/ratingPopup.dart';
import 'package:budget/widgets/selectedTransactionsAppBar.dart';
import 'package:budget/widgets/util/debouncer.dart';
import 'package:budget/widgets/util/keepAliveClientMixin.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry/swipeToSelectTransactions.dart';
import 'package:budget/widgets/util/onAppResume.dart';
import 'package:budget/widgets/viewAllTransactionsButton.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:budget/widgets/scrollbarWrap.dart';
import 'package:budget/widgets/slidingSelectorIncomeExpense.dart';
import 'package:budget/widgets/linearGradientFadedEdges.dart';
import 'package:budget/widgets/pullDownToRefreshSync.dart';
import 'package:budget/widgets/util/rightSideClipper.dart';
import 'package:home_widget/home_widget.dart';
import 'package:provider/provider.dart';
import 'package:budget/pages/addWalletPage.dart';
import 'package:budget/widgets/util/checkWidgetLaunch.dart';

class AndroidOnly extends StatelessWidget {
  const AndroidOnly({required this.child, super.key});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    if (getPlatform(ignoreEmulation: true) != PlatformOS.isAndroid)
      return SizedBox.shrink();
    return child;
  }
}

class CheckWidgetLaunch extends StatefulWidget {
  const CheckWidgetLaunch({super.key});

  @override
  State<CheckWidgetLaunch> createState() => _CheckWidgetLaunchState();
}

bool hasDoneWidgetAction = false;

class _CheckWidgetLaunchState extends State<CheckWidgetLaunch> {
  Timer? cancelTimer;

  @override
  void initState() {
    super.initState();
    HomeWidget.setAppGroupId('WIDGET_GROUP_ID');
  }

  @override
  void dispose() {
    cancelTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkForWidgetLaunch();
    HomeWidget.widgetClicked.listen(_launchedFromWidget);
  }

  void _checkForWidgetLaunch() {
    HomeWidget.initiallyLaunchedFromHomeWidget().then(_launchedFromWidget);
  }

  // For some reason, older Android versions open an entirely new app instance... weird!
  // has this been fixed with: android:launchMode="singleInstance" ?
  void _launchedFromWidget(Uri? uri) async {
    // Only perform one widget action per launch/continue of the app
    if (hasDoneWidgetAction == true) return;
    hasDoneWidgetAction = true;

    String widgetPayload = (uri ?? "").toString();
    if (widgetPayload == "addTransactionWidget") {
      pushRoute(
        context,
        AddTransactionPage(
          routesToPopAfterDelete: RoutesToPopAfterDelete.None,
        ),
      );
    } else if (widgetPayload == "transferTransactionWidget") {
      // This fixes an issue on older versions of Android where the route would popup twice
      // We can detect when this is going to happen if the Provider is not yet loaded, so just pop
      // the route when this is called so the first time routing does not persist (i.e. we end with one route)
      if (Provider.of<AllWallets>(context, listen: false)
              .indexedByPk[appStateSettings["selectedWalletPk"]] ==
          null) Navigator.of(context).popUntil((route) => route.isFirst);

      openBottomSheet(
        context,
        fullSnap: true,
        TransferBalancePopup(
          allowEditWallet: true,
          wallet: Provider.of<AllWallets>(context, listen: false)
              .indexedByPk[appStateSettings["selectedWalletPk"]],
          showAllEditDetails: true,
        ),
      );
    } else if (widgetPayload == "netWorthLaunchWidget") {
      pushRoute(
        context,
        WalletDetailsPage(
          wallet: null,
        ),
      );
    }
    _scheduleHasDoneWidgetAction();
  }

  void _scheduleHasDoneWidgetAction() {
    cancelTimer = Timer(Duration(milliseconds: 3000), () {
      hasDoneWidgetAction = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return OnAppResume(
      onAppResume: () {
        hasDoneWidgetAction = false;
        cancelTimer?.cancel();
      },
      child: SizedBox.shrink(),
    );
  }
}

class RenderHomePageWidgets extends StatefulWidget {
  const RenderHomePageWidgets({super.key});

  @override
  State<RenderHomePageWidgets> createState() => RenderHomePageWidgetsState();
}

Future updateWidgetColorsAndText(BuildContext context) async {
  if (getPlatform(ignoreEmulation: true) != PlatformOS.isAndroid) return;
  await Future.delayed(Duration(milliseconds: 500), () async {
    double widgetBackgroundOpacity =
        (double.tryParse((appStateSettings["widgetOpacity"] ?? 1).toString()) ??
                1)
            .clamp(0, 1);
    ThemeData widgetTheme = appStateSettings["widgetTheme"] == "light"
        ? getLightTheme()
        : appStateSettings["widgetTheme"] == "dark"
            ? getDarkTheme()
            : Theme.of(context);

    await HomeWidget.saveWidgetData<String>('netWorthTitle', "net-worth".tr());
    await HomeWidget.saveWidgetData<String>(
      'widgetColorBackground',
      colorToHex(widgetTheme.colorScheme.secondaryContainer),
    );
    await HomeWidget.saveWidgetData<String>(
      'widgetAlpha',
      widgetTheme.colorScheme.secondaryContainer
          .withOpacity(widgetBackgroundOpacity)
          .alpha
          .toString(),
    );
    await HomeWidget.saveWidgetData<String>(
      'widgetColorPrimary',
      colorToHex(widgetTheme.colorScheme.primary),
    );
    await HomeWidget.saveWidgetData<String>(
      'widgetColorText',
      colorToHex(widgetTheme.colorScheme.onSecondaryContainer),
    );
    await HomeWidget.updateWidget(
      name: 'NetWorthWidgetProvider',
    );
    await HomeWidget.updateWidget(
      name: 'NetWorthPlusWidgetProvider',
    );
    await HomeWidget.updateWidget(
      name: 'PlusWidgetProvider',
    );
    await HomeWidget.updateWidget(
      name: 'TransferWidgetProvider',
    );
  });

  return;
}

class RenderHomePageWidgetsState extends State<RenderHomePageWidgets> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      updateWidgetColorsAndText(context);
    });
  }

  void refreshState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TransactionWallet>>(
      stream: database.getAllPinnedWallets(HomePageWidgetDisplay.NetWorth).$1,
      builder: (context, snapshot) {
        List<String>? walletPks =
            (snapshot.data ?? []).map((item) => item.walletPk).toList();
        if (walletPks.length <= 0 ||
            appStateSettings["netWorthAllWallets"] == true) walletPks = null;
        return Container(
          child: StreamBuilder<TotalWithCount?>(
            stream: database.watchTotalWithCountOfWallet(
              isIncome: null,
              allWallets: Provider.of<AllWallets>(context),
              followCustomPeriodCycle: true,
              cycleSettingsExtension: "NetWorth",
              searchFilters: SearchFilters(walletPks: walletPks ?? []),
            ),
            builder: (context, snapshot) {
              Future.delayed(Duration.zero, () async {
                int totalCount = snapshot.data?.count ?? 0;
                String netWorthTransactionsNumber = totalCount.toString() +
                    " " +
                    (totalCount == 1
                        ? "transaction".tr().toLowerCase()
                        : "transactions".tr().toLowerCase());
                double totalSpent = snapshot.data?.total ?? 0;
                String netWorthAmount = convertToMoney(
                  Provider.of<AllWallets>(context, listen: false),
                  totalSpent,
                );
                await HomeWidget.saveWidgetData<String>(
                  'netWorthAmount',
                  netWorthAmount,
                );
                await HomeWidget.saveWidgetData<String>(
                  'netWorthTransactionsNumber',
                  netWorthTransactionsNumber,
                );
                await HomeWidget.updateWidget(
                  name: 'NetWorthWidgetProvider',
                );
                await HomeWidget.updateWidget(
                  name: 'NetWorthPlusWidgetProvider',
                );
              });

              return const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }
}
