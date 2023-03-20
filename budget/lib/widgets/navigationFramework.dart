import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/aboutPage.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/autoTransactionsPageEmail.dart';
import 'package:budget/pages/budgetsListPage.dart';
import 'package:budget/pages/editAssociatedTitlesPage.dart';
import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/pages/editWalletsPage.dart';
import 'package:budget/pages/homePage.dart';
import 'package:budget/pages/notificationsPage.dart';
import 'package:budget/pages/settingsPage.dart';
import 'package:budget/pages/subscriptionsPage.dart';
import 'package:budget/pages/transactionsListPage.dart';
import 'package:budget/pages/walletDetailsPage.dart';
import 'package:budget/struct/shareBudget.dart';
import 'package:budget/widgets/accountAndBackup.dart';
import 'package:budget/widgets/bottomNavBar.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/showChangelog.dart';
import 'package:budget/widgets/initializeNotifications.dart';
import 'package:budget/widgets/globalLoadingProgress.dart';
import 'package:budget/widgets/globalSnackBar.dart';
import 'package:budget/pages/editCategoriesPage.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
GlobalKey<SettingsPageState> settingsPageStateKey = GlobalKey();
GlobalKey<BottomNavBarState> navbarStateKey = GlobalKey();
GlobalKey<NavigationSidebarState> sidebarStateKey = GlobalKey();
GlobalKey<GlobalLoadingProgressState> loadingProgressKey = GlobalKey();
GlobalKey<GlobalLoadingIndeterminateState> loadingIndeterminateKey =
    GlobalKey();
GlobalKey<GlobalSnackbarState> snackbarKey = GlobalKey();

class PageNavigationFrameworkState extends State<PageNavigationFramework> {
  late List<Widget> pages;
  late List<Widget> pagesExtended;

  int currentPage = 0;
  bool refresh = false;

  final pageController = PageController();

  void changePage(int page, {bool switchNavbar = true}) {
    if (switchNavbar) {
      sidebarStateKey.currentState?.setSelectedIndex(page);
      navbarStateKey.currentState?.setSelectedIndex(page >= 3 ? 3 : page);
    }
    setState(() {
      currentPage = page;
    });
    // pageController.animateToPage(page,
    //     duration: Duration(milliseconds: 100), curve: Curves.easeInOut);
    pageController.jumpToPage(page);
    setState(() {
      refresh = false;
    });
    Future.delayed(Duration(milliseconds: 50), () {
      setState(() {
        refresh = true;
      });
    });
  }

  @override
  void initState() {
    super.initState();

    // Functions to run after entire UI loaded
    Future.delayed(Duration.zero, () async {
      await showChangelog(context);
      runNotificationPayLoads(context);
      await askForNotificationPermission();
      await setDailyNotificationOnLaunch(context);
      await setUpcomingNotifications(context);
      await parseEmailsInBackground(context);
      await getExchangeRates();
      loadingIndeterminateKey.currentState!.setVisibility(true);
      await syncData();
      if (appStateSettings["currentUserEmail"] != "") {
        await syncPendingQueueOnServer(); //sync before download
        await getCloudBudgets();
      }
      await createBackupInBackground(context);
      loadingIndeterminateKey.currentState!.setVisibility(false);
      entireAppLoaded = true;
    });

    pages = [
      HomePage(key: homePageStateKey), // 0
      TransactionsListPage(key: transactionsListPageStateKey), //1
      BudgetsListPage(key: budgetsListPageStateKey), //2
      SettingsPage(key: settingsPageStateKey), //3
    ];
    pagesExtended = [
      SettingsPage(hasMorePages: false), //4
      SubscriptionsPage(), //5
      NotificationsPage(), //6
      WalletDetailsPage(wallet: null), //7
      SizedBox(), // 8, this is accounts page, handles by GoogleAccountLoginButton
      EditWalletsPage(title: "Edit Wallets"), //9
      EditBudgetPage(title: "Edit Budgets"), //10
      EditCategoriesPage(title: "Edit Categories"), //11
      EditAssociatedTitlesPage(title: "Edit Titles"), //12
      AboutPage(), //13
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Wipe all remaining pixels off - sometimes graphics artifacts are left behind
    return AnimatedOpacity(
      duration: Duration(milliseconds: 25),
      opacity: refresh ? 1 : 0.99,
      child: WillPopScope(
        onWillPop: () async {
          //Handle global back button

          ScaffoldMessenger.of(context).hideCurrentSnackBar();

          // Deselect selected transactions
          for (String key in globalSelectedID.value.keys) {
            globalSelectedID.value[key] = [];
          }
          globalSelectedID.notifyListeners();

          return false;
        },
        // The global Widget stack
        child: Stack(children: [
          AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light.copyWith(
                statusBarIconBrightness:
                    determineBrightnessTheme(context) == Brightness.light
                        ? Brightness.dark
                        : Brightness.light,
                statusBarColor: kIsWeb ? Colors.black : Colors.transparent),
            child: Scaffold(
              body: kIsWeb
                  ? FadeIndexedStack(
                      children: [...pages, ...pagesExtended],
                      index: currentPage,
                      duration: Duration(milliseconds: 300),
                    )
                  : PageView(
                      controller: pageController,
                      onPageChanged: (int index) {},
                      children: [...pages, ...pagesExtended],
                      physics: NeverScrollableScrollPhysics(),
                    ),
              extendBody: true,
              resizeToAvoidBottomInset: false,
              bottomNavigationBar: BottomNavBar(
                key: navbarStateKey,
                onChanged: (index) {
                  changePage(index);
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: getWidthNavigationSidebar(context) <= 0
                    ? 75
                    : 15 + bottomPaddingSafeArea,
                right: 15,
              ),
              child: Stack(
                children: [
                  AnimateFAB(
                    fab: FAB(
                      tooltip: "Add Transaction",
                      openPage: AddTransactionPage(
                        title: "Add Transaction",
                      ),
                    ),
                    condition: currentPage == 0 || currentPage == 1,
                  ),
                  AnimateFAB(
                    fab: FAB(
                      tooltip: "Add Budget",
                      openPage: AddBudgetPage(title: "Add Budget"),
                    ),
                    condition: currentPage == 2,
                  ),
                ],
              ),
            ),
          ),
        ]),
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
  final Clip clipBehavior;
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
    this.clipBehavior = Clip.hardEdge,
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
      child: IndexedStack(
        index: widget.index,
        alignment: widget.alignment,
        textDirection: widget.textDirection,
        clipBehavior: widget.clipBehavior,
        sizing: widget.sizing,
        children: widget.children,
      ),
    );
  }
}
