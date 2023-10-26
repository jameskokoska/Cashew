import 'package:animations/animations.dart';
import 'package:budget/colors.dart';
import 'package:budget/database/initializeDefaultDatabase.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/aboutPage.dart';
import 'package:budget/pages/accountsPage.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/pages/addObjectivePage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/addWalletPage.dart';
import 'package:budget/pages/autoTransactionsPageEmail.dart';
import 'package:budget/pages/budgetsListPage.dart';
import 'package:budget/pages/editAssociatedTitlesPage.dart';
import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/pages/editObjectivesPage.dart';
import 'package:budget/pages/editWalletsPage.dart';
import 'package:budget/pages/homePage/homePage.dart';
import 'package:budget/pages/notificationsPage.dart';
import 'package:budget/pages/objectivesListPage.dart';
import 'package:budget/pages/premiumPage.dart';
import 'package:budget/pages/settingsPage.dart';
import 'package:budget/pages/subscriptionsPage.dart';
import 'package:budget/pages/transactionsListPage.dart';
import 'package:budget/pages/walletDetailsPage.dart';
import 'package:budget/struct/currencyFunctions.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/quickActions.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/struct/shareBudget.dart';
import 'package:budget/struct/syncClient.dart';
import 'package:budget/widgets/accountAndBackup.dart';
import 'package:budget/widgets/bottomNavBar.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/importDB.dart';
import 'package:budget/widgets/moreIcons.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/notificationsSettings.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/outlinedButtonStacked.dart';
import 'package:budget/widgets/ratingPopup.dart';
import 'package:budget/widgets/showChangelog.dart';
import 'package:budget/struct/initializeNotifications.dart';
import 'package:budget/widgets/globalLoadingProgress.dart';
import 'package:budget/widgets/globalSnackBar.dart';
import 'package:budget/pages/editCategoriesPage.dart';
import 'package:budget/struct/upcomingTransactionsFunctions.dart';
import 'package:budget/widgets/transactionEntry/transactionEntry.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lazy_indexed_stack/flutter_lazy_indexed_stack.dart';
import 'package:googleapis/drive/v3.dart';
// import 'package:feature_discovery/feature_discovery.dart';

class PageNavigationFramework extends StatefulWidget {
  const PageNavigationFramework({Key? key}) : super(key: key);

  //PageNavigationFramework.changePage(context, 0);
  static void changePage(BuildContext context, page,
      {bool switchNavbar = false}) {
    context
        .findAncestorStateOfType<PageNavigationFrameworkState>()!
        .changePage(page, switchNavbar: switchNavbar);
  }

  @override
  State<PageNavigationFramework> createState() =>
      PageNavigationFrameworkState();
}

//can also do GlobalKey<dynamic> for private state classes, but bad practice and no autocomplete
GlobalKey<HomePageState> homePageStateKey = GlobalKey();
GlobalKey<TransactionsListPageState> transactionsListPageStateKey = GlobalKey();
GlobalKey<BudgetsListPageState> budgetsListPageStateKey = GlobalKey();
GlobalKey<MoreActionsPageState> settingsPageStateKey = GlobalKey();
GlobalKey<SettingsPageFrameworkState> settingsPageFrameworkStateKey =
    GlobalKey();
GlobalKey<ProductsState> purchasesStateKey = GlobalKey();
GlobalKey<AccountsPageState> accountsPageStateKey = GlobalKey();
GlobalKey<BottomNavBarState> navbarStateKey = GlobalKey();
GlobalKey<NavigationSidebarState> sidebarStateKey = GlobalKey();
GlobalKey<GlobalLoadingProgressState> loadingProgressKey = GlobalKey();
GlobalKey<GlobalLoadingIndeterminateState> loadingIndeterminateKey =
    GlobalKey();
GlobalKey<GlobalSnackbarState> snackbarKey = GlobalKey();

bool runningCloudFunctions = false;
bool errorSigningInDuringCloud = false;
Future<bool> runAllCloudFunctions(BuildContext context,
    {bool forceSignIn = false}) async {
  print("Running All Cloud Functions");
  runningCloudFunctions = true;
  errorSigningInDuringCloud = false;
  try {
    loadingIndeterminateKey.currentState!.setVisibility(true);
    await syncData(context);
    if (appStateSettings["emailScanningPullToRefresh"] ||
        entireAppLoaded == false) {
      loadingIndeterminateKey.currentState!.setVisibility(true);
      await parseEmailsInBackground(context, forceParse: true);
    }
    loadingIndeterminateKey.currentState!.setVisibility(true);
    await syncPendingQueueOnServer(); //sync before download
    loadingIndeterminateKey.currentState!.setVisibility(true);
    await getCloudBudgets();
    loadingIndeterminateKey.currentState!.setVisibility(true);
    await createBackupInBackground(context);
    loadingIndeterminateKey.currentState!.setVisibility(true);
    await getExchangeRates();
  } catch (e) {
    print("Error running sync functions on load: " + e.toString());
    loadingIndeterminateKey.currentState!.setVisibility(false);
    runningCloudFunctions = false;
    if (e is DetailedApiRequestError &&
            e.status == 401 &&
            forceSignIn == true ||
        e is PlatformException) {
      // Request had invalid authentication credentials. Try logging out and back in.
      // This stems from silent sign-in not providing the credentials for GDrive API for e.g.
      await refreshGoogleSignIn();
      runAllCloudFunctions(context);
    }
    return false;
  }
  loadingIndeterminateKey.currentState!.setVisibility(false);
  Future.delayed(Duration(milliseconds: 2000), () {
    runningCloudFunctions = false;
  });
  errorSigningInDuringCloud = false;
  return true;
}

class PageNavigationFrameworkState extends State<PageNavigationFramework> {
  late List<Widget> pages;
  late List<Widget> pagesExtended;

  int currentPage = 0;
  int previousPage = 0;

  void changePage(int page, {bool switchNavbar = true}) {
    if (switchNavbar) {
      sidebarStateKey.currentState?.setSelectedIndex(page);
      navbarStateKey.currentState?.setSelectedIndex(page >= 3 ? 3 : page);
    }
    setState(() {
      previousPage = currentPage;
      currentPage = page;
    });
  }

  @override
  void initState() {
    super.initState();

    // Functions to run after entire UI loaded
    Future.delayed(Duration.zero, () async {
      SystemChrome.setSystemUIOverlayStyle(
          getSystemUiOverlayStyle(Theme.of(context).brightness));

      bool isDatabaseCorruptedPopupShown = openDatabaseCorruptedPopup(context);
      if (isDatabaseCorruptedPopupShown) return;

      await initializeNotificationsPlatform();

      bool isChangelogShown = showChangelog(context);
      if (isChangelogShown == false) {
        bool isRatingPopupShown = openRatingPopupCheck(context);
        if (isRatingPopupShown == false) {
          openBackupReminderPopupCheck(context);
        }
      }

      await setDailyNotificationOnLaunch(context);
      await initializeDefaultDatabase();
      runNotificationPayLoads(context);
      runQuickActionsPayLoads(context);
      initializeStoreAndPurchases(
          context: context, popRouteWithPurchase: false);

      if (entireAppLoaded == false) {
        await runAllCloudFunctions(context);
      }

      // Should do this after syncing
      // The upcoming transactions may have been modified after a sync
      await setUpcomingNotifications(context);

      // Mark subscriptions as paid AFTER syncing with cloud
      // Maybe another device already marked them as paid
      await markSubscriptionsAsPaid();

      database.deleteWanderingTransactions();

      entireAppLoaded = true;

      print("Entire app loaded");

      database.watchAllForAutoSync().listen((event) {
        // Must be logged in to perform an automatic sync - googleUser != null
        // If we remove this, it will ask the user to login though - but it can be annoying
        // Users can visually see the last time of sync, especially on web where sign-in is not automatic,
        // so it shouldn't be an issue
        if (runningCloudFunctions == false && googleUser != null) {
          createSyncBackup(changeMadeSync: true);
        }
      });

      if (kIsWeb) {
        // On web, disable the browser's context menu since this example uses a custom
        // Flutter-rendered context menu.
        // Refer here: https://api.flutter.dev/flutter/material/TextField/contextMenuBuilder.html
        BrowserContextMenu.disableContextMenu();
      }
    });

    pages = [
      HomePage(key: homePageStateKey), // 0
      TransactionsListPage(key: transactionsListPageStateKey), //1
      BudgetsListPage(key: budgetsListPageStateKey), //2
      MoreActionsPage(key: settingsPageStateKey), //3
    ];
    pagesExtended = [
      MoreActionsPage(), //4
      SubscriptionsPage(), //5
      NotificationsPage(), //6
      WalletDetailsPage(wallet: null), //7
      AccountsPage(key: accountsPageStateKey), // 8
      EditWalletsPage(), //9
      EditBudgetPage(), //10
      EditCategoriesPage(), //11
      EditAssociatedTitlesPage(), //12
      AboutPage(), //13
      ObjectivesListPage(backButton: false), //14
      EditObjectivesPage(), //15
    ];

    // SchedulerBinding.instance.addPostFrameCallback((Duration duration) {
    //   FeatureDiscovery.discoverFeatures(
    //     context,
    //     const <String>{
    //       'add_transaction_button',
    //     },
    //   );
    // });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Deselect selected transactions
        int notEmpty = 0;
        for (String key in globalSelectedID.value.keys) {
          if (globalSelectedID.value[key]?.isNotEmpty == true) notEmpty++;
          globalSelectedID.value[key] = [];
        }
        globalSelectedID.notifyListeners();

        // Allow the back button to exit the app when on home
        if (notEmpty <= 0) {
          if (currentPage == 0) {
            return true;
          } else {
            changePage(0);
          }
        }

        return false;
      },
      // The global Widget stack
      child: Stack(children: [
        Scaffold(
          resizeToAvoidBottomInset: false,
          body: FadeIndexedStack(
            children: [...pages, ...pagesExtended],
            index: currentPage,
            duration: !kIsWeb
                ? Duration.zero
                : appStateSettings["batterySaver"]
                    ? Duration.zero
                    : Duration(milliseconds: 300),
          ),
          extendBody: true,
          bottomNavigationBar: BottomNavBar(
            key: navbarStateKey,
            onChanged: (index) {
              changePage(index);
            },
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: (getIsFullScreen(context) == false
                      ? 95 + MediaQuery.viewPaddingOf(context).bottom
                      : 15 + MediaQuery.viewPaddingOf(context).bottom) -
                  // iOS navbar is lower
                  (getPlatform() == PlatformOS.isIOS ? 10 : 0),
              right: 15,
            ),
            child: Stack(
              children: [
                // DescribedFeatureOverlay(
                //   featureId: 'add_transaction_button',
                //   tapTarget: IgnorePointer(
                //     child: AnimateFAB(
                //       fab: FAB(
                //         tooltip: "Add Transaction",
                //         openPage: AddTransactionPage(
                //
                //         ),
                //       ),
                //       condition: currentPage == 0 || currentPage == 1,
                //     ),
                //   ),
                //   pulseDuration: Duration(milliseconds: 3500),
                //   contentLocation: ContentLocation.above,
                //   title: TextFont(
                //     text: 'Add Transaction',
                //     fontWeight: FontWeight.bold,
                //     fontSize: 22,
                //     maxLines: 3,
                //   ),
                //   description: TextFont(
                //     text: 'Tap the plus to add a transaction',
                //     fontSize: 17,
                //     maxLines: 10,
                //   ),
                //   backgroundColor: Theme.of(context).primaryColor,
                //   textColor: Colors.white,
                //   child: AnimateFAB(
                //     fab: FAB(
                //       tooltip: "Add Transaction",
                //       openPage: AddTransactionPage(
                //
                //       ),
                //     ),
                //     condition: currentPage == 0 || currentPage == 1,
                //   ),
                // ),

                // AnimatedSwitcher(
                //   duration: Duration(milliseconds: 350),
                //   switchInCurve: Curves.easeOutCubic,
                //   switchOutCurve: Curves.ease,
                //   transitionBuilder:
                //       (Widget child, Animation<double> animation) {
                //     return FadeTransition(
                //       opacity: animation,
                //       child: ScaleTransition(
                //         scale: Tween<double>(begin: 0.4, end: 1.0)
                //             .animate(animation),
                //         child: child,
                //       ),
                //     );
                //   },
                //   child: currentPage == 0 ||
                //           currentPage == 1 ||
                //           (previousPage == 0 && currentPage != 2) ||
                //           (previousPage == 1 && currentPage != 2)
                //       ? AnimateFAB(
                //           key: ValueKey(1),
                //           fab: FAB(
                //             tooltip: "add-transaction".tr(),
                //             openPage: AddTransactionPage(
                //               routesToPopAfterDelete:
                //                   RoutesToPopAfterDelete.None,
                //             ),
                //           ),
                //           condition: currentPage == 0 || currentPage == 1,
                //         )
                //       : AnimateFAB(
                //           key: ValueKey(2),
                //           fab: FAB(
                //             tooltip: "add-budget".tr(),
                //             openPage: AddBudgetPage(
                //               routesToPopAfterDelete:
                //                   RoutesToPopAfterDelete.None,
                //             ),
                //           ),
                //           condition: currentPage == 2,
                //         ),
                // ),
                AnimateFAB(
                  key: ValueKey(1),
                  fab: FAB(
                    tooltip: "add-transaction".tr(),
                    openPage: AddTransactionPage(
                      routesToPopAfterDelete: RoutesToPopAfterDelete.None,
                    ),
                    onLongPress: () {
                      openBottomSheet(
                        context,
                        PopupFramework(
                          title: "add".tr(),
                          child: AddMoreThingsPopup(),
                        ),
                      );
                    },
                  ),
                  condition: [0, 1, 2, 14].contains(currentPage),
                )
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

class AddMoreThingsPopup extends StatelessWidget {
  const AddMoreThingsPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AddThing(
          iconData: appStateSettings["outlinedIcons"]
              ? Icons.payments_outlined
              : Icons.payments_rounded,
          title: "transaction".tr(),
          openPage: AddTransactionPage(
              routesToPopAfterDelete: RoutesToPopAfterDelete.None),
        ),
        AddThing(
          iconData: MoreIcons.chart_pie,
          title: "budget".tr(),
          openPage: AddBudgetPage(
              routesToPopAfterDelete: RoutesToPopAfterDelete.None),
          iconScale: 0.9,
        ),
        AddThing(
          iconData: appStateSettings["outlinedIcons"]
              ? Icons.savings_outlined
              : Icons.savings_rounded,
          title: "goal".tr(),
          openPage: AddObjectivePage(
              routesToPopAfterDelete: RoutesToPopAfterDelete.None),
        ),
        AddThing(
          iconData: appStateSettings["outlinedIcons"]
              ? Icons.category_outlined
              : Icons.category_rounded,
          title: "category".tr(),
          openPage: AddCategoryPage(
              routesToPopAfterDelete: RoutesToPopAfterDelete.None),
        ),
        AddThing(
          iconData: appStateSettings["outlinedIcons"]
              ? Icons.account_balance_wallet_outlined
              : Icons.account_balance_wallet_rounded,
          title: "account".tr(),
          openPage: AddWalletPage(
              routesToPopAfterDelete: RoutesToPopAfterDelete.None),
        ),
      ],
    );
  }
}

class AddThing extends StatelessWidget {
  const AddThing({
    required this.iconData,
    required this.title,
    required this.openPage,
    this.iconScale = 1,
    super.key,
  });

  final IconData iconData;
  final String title;
  final Widget openPage;
  final double iconScale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 5,
        top: 5,
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButtonStacked(
              filled: false,
              alignLeft: true,
              alignBeside: true,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              text: title.capitalizeFirst,
              iconData: iconData,
              iconScale: iconScale,
              onTap: () {
                Navigator.pop(context);
                pushRoute(context, openPage);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AnimateFAB extends StatelessWidget {
  const AnimateFAB({required this.condition, required this.fab, super.key});

  final bool condition;
  final Widget fab;

  @override
  Widget build(BuildContext context) {
    // return AnimatedOpacity(
    //   duration: Duration(milliseconds: 400),
    //   opacity: condition ? 1 : 0,
    //   child: AnimatedScale(
    //     duration: Duration(milliseconds: 1100),
    //     scale: condition ? 1 : 0,
    //     curve: Curves.easeInOutCubicEmphasized,
    //     child: fab,
    //     alignment: Alignment(0.7, 0.7),
    //   ),
    // );
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 500),
      switchInCurve: Curves.easeInOutCubicEmphasized,
      switchOutCurve: Curves.ease,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeScaleTransitionButton(
          animation: animation,
          child: child,
          alignment: Alignment(0.7, 0.7),
        );
      },
      child: condition
          ? fab
          : Container(
              key: ValueKey(1),
              width: 50,
              height: 50,
            ),
    );
  }
}

class FadeScaleTransitionButton extends StatelessWidget {
  const FadeScaleTransitionButton({
    Key? key,
    required this.animation,
    required this.alignment,
    this.child,
  }) : super(key: key);

  final Animation<double> animation;
  final Widget? child;
  final Alignment alignment;

  static final Animatable<double> _fadeInTransition = CurveTween(
    curve: const Interval(0.0, 0.7),
  );
  static final Animatable<double> _scaleInTransition = Tween<double>(
    begin: 0.30,
    end: 1.00,
  );
  static final Animatable<double> _fadeOutTransition = Tween<double>(
    begin: 1.0,
    end: 0,
  );
  static final Animatable<double> _scaleOutTransition = Tween<double>(
    begin: 1.0,
    end: 0.1,
  );

  @override
  Widget build(BuildContext context) {
    return DualTransitionBuilder(
      animation: animation,
      forwardBuilder: (
        BuildContext context,
        Animation<double> animation,
        Widget? child,
      ) {
        return FadeTransition(
          opacity: _fadeInTransition.animate(animation),
          child: ScaleTransition(
            scale: _scaleInTransition.animate(animation),
            child: child,
            alignment: alignment,
          ),
        );
      },
      reverseBuilder: (
        BuildContext context,
        Animation<double> animation,
        Widget? child,
      ) {
        return FadeTransition(
          opacity: _fadeOutTransition.animate(animation),
          child: ScaleTransition(
            scale: _scaleOutTransition.animate(animation),
            child: child,
            alignment: alignment,
          ),
        );
      },
      child: child,
    );
  }
}

class FadeIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;
  final Duration duration;
  final AlignmentGeometry alignment;
  final TextDirection? textDirection;
  final StackFit sizing;

  const FadeIndexedStack({
    super.key,
    required this.index,
    required this.children,
    this.duration = const Duration(
      milliseconds: 250,
    ),
    this.alignment = AlignmentDirectional.topStart,
    this.textDirection,
    this.sizing = StackFit.loose,
  });

  @override
  FadeIndexedStackState createState() => FadeIndexedStackState();
}

class FadeIndexedStackState extends State<FadeIndexedStack>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.duration);

  @override
  void didUpdateWidget(FadeIndexedStack oldWidget) {
    if (widget.index != oldWidget.index) {
      _controller.forward(from: 0.0);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    _controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: LazyIndexedStack(
        index: widget.index,
        alignment: widget.alignment,
        textDirection: widget.textDirection,
        sizing: widget.sizing,
        children: widget.children,
      ),
    );
  }
}
