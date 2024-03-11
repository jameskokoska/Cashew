import 'package:budget/colors.dart';
import 'package:budget/database/generatePreviewData.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/homePage/homePagePieChart.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/languageMap.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/accountAndBackup.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/currencyPicker.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/moreIcons.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/selectAmount.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/viewAllTransactionsButton.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../functions.dart';
import 'package:budget/database/initializeDefaultDatabase.dart';

import '../widgets/pageIndicator.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({
    Key? key,
    this.popNavigationWhenDone = false,
    this.showPreviewDemoButton = true,
  }) : super(key: key);

  final bool popNavigationWhenDone;
  final bool showPreviewDemoButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: OnBoardingPageBody(
            popNavigationWhenDone: popNavigationWhenDone,
            showPreviewDemoButton: showPreviewDemoButton));
  }
}

class OnBoardingPageBody extends StatefulWidget {
  const OnBoardingPageBody({
    Key? key,
    this.popNavigationWhenDone = false,
    this.showPreviewDemoButton = true,
  }) : super(key: key);
  final bool popNavigationWhenDone;
  final bool showPreviewDemoButton;

  @override
  State<OnBoardingPageBody> createState() => OnBoardingPageBodyState();
}

class OnBoardingPageBodyState extends State<OnBoardingPageBody> {
  final PageController controller = PageController();

  double? selectedAmount;
  int selectedPeriodLength = 1;
  DateTime selectedStartDate =
      DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime? selectedEndDate;
  String selectedRecurrence = "Monthly";
  bool selectedIncludeIncome = false;

  bool showImage = false;
  final Image imageLanding1 = Image(
    image: AssetImage("assets/landing/Graph.png"),
  );
  final Image imageLanding2 = Image(
    image: AssetImage("assets/landing/BankOrPig.png"),
  );
  final Image imageLanding3 = Image(
    image: AssetImage("assets/landing/PigBank.png"),
  );

  @override
  void didChangeDependencies() {
    precacheImage(imageLanding1.image, context);
    precacheImage(imageLanding2.image, context);
    precacheImage(imageLanding3.image, context);
    super.didChangeDependencies();
  }

  nextNavigation({bool generatePreview = false}) async {
    if (selectedAmount != null && selectedAmount != 0) {
      int order = await database.getAmountOfBudgets();
      await database.createOrUpdateBudget(
        insert: true,
        Budget(
          budgetPk: "-1",
          name: "default-budget-name".tr(),
          amount: selectedAmount ?? 0,
          startDate: selectedStartDate,
          endDate: selectedEndDate ?? DateTime.now(),
          addedTransactionsOnly: false,
          periodLength: selectedPeriodLength,
          dateCreated: DateTime.now(),
          pinned: true,
          order: order,
          walletFk: "0",
          reoccurrence: mapRecurrence(selectedRecurrence),
          isAbsoluteSpendingLimit: false,
          budgetTransactionFilters: [
            ...(selectedIncludeIncome == false
                ? [BudgetTransactionFilters.defaultBudgetTransactionFilters]
                : [
                    BudgetTransactionFilters.includeIncome,
                    BudgetTransactionFilters.addedToOtherBudget,
                    BudgetTransactionFilters.addedToObjective,
                  ])
          ],
          income: false,
          archived: false,
        ),
      );
    }
    if (generatePreview) {
      openLoadingPopup(context);
      await generatePreviewData();
      Navigator.pop(context);
    }
    if (widget.popNavigationWhenDone) {
      Navigator.pop(context);
    } else {
      updateSettings("hasOnboarded", true,
          pagesNeedingRefresh: [], updateGlobalState: true);
    }
  }

  FocusNode _focusNode = FocusNode();
  late FocusAttachment _focusAttachment;

  @override
  void initState() {
    super.initState();
    _focusAttachment = _focusNode.attach(context, onKeyEvent: (node, event) {
      if (event.logicalKey.keyLabel == "Go Back" ||
          event.logicalKey == LogicalKeyboardKey.escape) {
        nextNavigation();
      } else if (event.runtimeType == KeyDownEvent &&
          event.logicalKey == LogicalKeyboardKey.arrowRight) {
        nextOnBoardPage(4);
      } else if (event.runtimeType == KeyDownEvent &&
          event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        previousOnBoardPage();
      }
      return KeyEventResult.handled;
    });
    _focusNode.requestFocus();

    Future.delayed(Duration.zero, () async {
      // Functions to run after entire UI loaded - landing page
      // Run here too, so user has a wallet when creating first budget
      // We need to run this after the UI is loaded - after translations are loaded
      await initializeDefaultDatabase();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void nextOnBoardPage(int numPages) {
    controller.nextPage(
      duration: Duration(milliseconds: 1100),
      curve: ElasticOutCurve(1.3),
    );
    if ((controller.page?.round().toInt() ?? 0) + 1 == numPages) {
      nextNavigation();
    }
  }

  void previousOnBoardPage() {
    controller.previousPage(
      duration: Duration(milliseconds: 1100),
      curve: ElasticOutCurve(1.3),
    );
  }

  @override
  Widget build(BuildContext context) {
    _focusAttachment.reparent();
    final List<Widget> children = [
      // OnBoardPage(
      //   widgets: [
      //     Container(
      //       constraints: BoxConstraints(
      //           maxWidth: MediaQuery.sizeOf(context).height <=
      //                   MediaQuery.sizeOf(context).width
      //               ? MediaQuery.sizeOf(context).height * 0.5
      //               : 300),
      //       child: Image(
      //         image: AssetImage("assets/landing/DepressedMan.png"),
      //       ),
      //     ),
      //     SizedBox(height: 15),
      //     Padding(
      //       padding: const EdgeInsets.symmetric(horizontal: 25),
      //       child: TextFont(
      //         text: "Losing track of your spending?",
      //         fontWeight: FontWeight.bold,
      //         textAlign: TextAlign.center,
      //         fontSize: 25,
      //         maxLines: 5,
      //       ),
      //     ),
      //     SizedBox(height: 15),
      //     Padding(
      //       padding: const EdgeInsets.symmetric(horizontal: 25),
      //       child: TextFont(
      //         text: "It's important to be mindful of your purchases.",
      //         textAlign: TextAlign.center,
      //         fontSize: 16,
      //         maxLines: 5,
      //       ),
      //     ),
      //   ],
      // ),
      OnBoardPage(
        widgets: [
          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).height <=
                        MediaQuery.sizeOf(context).width
                    ? MediaQuery.sizeOf(context).height * 0.5
                    : 300),
            child: imageLanding1,
          ),
          SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: TextFont(
              text: "onboarding-title-1".tr(namedArgs: {"app": globalAppName}),
              fontWeight: FontWeight.bold,
              textAlign: TextAlign.center,
              fontSize: 25,
              maxLines: 5,
            ),
          ),
          SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: TextFont(
              text: "onboarding-info-1".tr(),
              textAlign: TextAlign.center,
              fontSize: 16,
              maxLines: 5,
            ),
          ),
          SizedBox(height: 55),
        ],
        bottomWidget: widget.showPreviewDemoButton
            ? PreviewDemoButton(
                nextNavigation: nextNavigation,
              )
            : null,
      ),
      OnBoardPage(
        widgets: [
          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).height <=
                        MediaQuery.sizeOf(context).width
                    ? MediaQuery.sizeOf(context).height * 0.5
                    : 300),
            child: imageLanding2,
          ),
          SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: TextFont(
              text: "onboarding-title-2".tr(),
              fontWeight: FontWeight.bold,
              textAlign: TextAlign.center,
              fontSize: 25,
              maxLines: 5,
            ),
          ),
          SizedBox(height: 10),
          BudgetDetails(
            determineBottomButton: () {},
            setSelectedAmount: (amount, _) {
              setState(() {
                selectedAmount = amount;
              });
            },
            initialSelectedAmount: selectedAmount,
            setSelectedPeriodLength: (length) {
              setState(() {
                selectedPeriodLength = length;
              });
            },
            initialSelectedPeriodLength: selectedPeriodLength,
            setSelectedRecurrence: (recurrence) {
              setState(() {
                selectedRecurrence = recurrence;
              });
            },
            initialSelectedRecurrence: selectedRecurrence,
            setSelectedStartDate: (date) {
              setState(() {
                selectedStartDate = date;
              });
            },
            initialSelectedStartDate: selectedStartDate,
            setSelectedEndDate: (date) {
              setState(() {
                selectedEndDate = date;
              });
            },
            initialSelectedEndDate: selectedEndDate,
          ),
          // This is pretty confusing, users can enable this later by editing the budget
          // Opacity(
          //   opacity: 0.8,
          //   child: ChoiceChip(
          //     materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          //     selectedColor: appStateSettings["materialYou"]
          //         ? null
          //         : getColor(context, "lightDarkAccentHeavy"),
          //     label: TextFont(
          //       text: "include-income-onboarding-label".tr() +
          //           (selectedIncludeIncome == false ? "?" : ""),
          //       fontSize: 15,
          //     ),
          //     selected: selectedIncludeIncome,
          //     onSelected: (bool selected) {
          //       setState(() {
          //         selectedIncludeIncome = selected;
          //       });
          //     },
          //   ),
          // ),

          StreamBuilder<AllWallets>(
            stream: database.watchAllWalletsIndexed(),
            builder: (context, snapshot) {
              TransactionWallet? primaryWallet = snapshot
                  .data?.indexedByPk[appStateSettings["selectedWalletPk"]];
              if (primaryWallet != null) {
                return Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: LowKeyButton(
                    onTap: () {
                      openBottomSheet(
                        context,
                        PopupFramework(
                          title: "select-primary-currency".tr(),
                          subtitle: "select-primary-currency-description".tr(),
                          child: Column(
                            children: [
                              CurrencyPicker(
                                padding: EdgeInsets.zero,
                                onSelected: (selectedCurrency) {
                                  Navigator.pop(context);
                                  database.createOrUpdateWallet(
                                      primaryWallet.copyWith(
                                          currency: Value(selectedCurrency)));
                                },
                                initialCurrency: primaryWallet.currency,
                                onHasFocus: () {
                                  // Disable scroll when focus - because iOS header height is different than that of Android.
                                  // Future.delayed(Duration(milliseconds: 500), () {
                                  //   addWalletPageKey.currentState?.scrollTo(250);
                                  // });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    text: "change-currency".tr(),
                  ),
                );
              }
              return SizedBox.shrink();
            },
          ),
          SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: TextFont(
              text: "onboarding-info-2-1".tr(),
              textAlign: TextAlign.center,
              fontSize: 15,
              maxLines: 5,
              textColor: getColor(context, "black").withOpacity(0.35),
            ),
          ),
        ],
      ),
      OnBoardPage(
        widgets: [
          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).height <=
                        MediaQuery.sizeOf(context).width
                    ? MediaQuery.sizeOf(context).height * 0.5
                    : 300),
            child: imageLanding3,
          ),
          SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: TextFont(
              text: "onboarding-title-3".tr(namedArgs: {"app": globalAppName}),
              fontWeight: FontWeight.bold,
              textAlign: TextAlign.center,
              fontSize: 25,
              maxLines: 5,
            ),
          ),
          SizedBox(height: 25),
          getPlatform() == PlatformOS.isIOS
              ? IntrinsicWidth(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Button(
                      label: "lets-go".tr(),
                      onTap: () {
                        nextNavigation();
                      },
                      expandedLayout: false,
                    ),
                  ),
                )
              : SizedBox.shrink(),
          getPlatform() == PlatformOS.isIOS
              ? SizedBox.shrink()
              : SettingsContainerOutlined(
                  onTap: () async {
                    loadingIndeterminateKey.currentState?.setVisibility(true);
                    openLoadingPopupTryCatch(
                      () async {
                        // Can maybe use this function, but on web first login does not sync...
                        // Let's just use the functionality below this
                        // await signInAndSync(context, next: () {});

                        await signInGoogle(
                          context: context,
                          waitForCompletion: false,
                          drivePermissions: true,
                          next: () {},
                        );
                        if (appStateSettings["username"] == "" &&
                            googleUser != null) {
                          updateSettings(
                              "username", googleUser?.displayName ?? "",
                              pagesNeedingRefresh: [0],
                              updateGlobalState: false);
                        }
                        // If user has sync backups, but no real backups it will show up here
                        // For now disable restoring of a backup popup, the sync backups will be restored automatically using the function call below
                        // var result;
                        // List<drive.File>? files = (await getDriveFiles()).$2;
                        // if ((files?.length ?? 0) > 0) {
                        //   result = await openPopup(
                        //     context,
                        //     icon: appStateSettings["outlinedIcons"] ? Icons.cloud_sync_outlined : Icons.cloud_sync_rounded,
                        //     title: "backup-found".tr(),
                        //     description: "backup-found-description".tr(),
                        //     onSubmit: () {
                        //       Navigator.pop(context, true);
                        //     },
                        //     onCancel: () {
                        //       Navigator.pop(context, false);
                        //     },
                        //     onSubmitLabel: "restore".tr(),
                        //     onCancelLabel: "cancel".tr(),
                        //   );
                        // }
                        // if (result == true) {
                        //   chooseBackup(context, hideDownloadButton: true);
                        // } else if (result == false && googleUser != null) {
                        //   openLoadingPopup(context);
                        //   // set this to true so cloud functions run
                        //   entireAppLoaded = true;
                        //   await runAllCloudFunctions(
                        //     context,
                        //     forceSignIn: true,
                        //   );
                        //   Navigator.pop(context);
                        //   nextNavigation();
                        // }
                        // else {
                        //   nextNavigation();
                        // }

                        // set this to true so cloud functions run
                        entireAppLoaded = true;
                        await runAllCloudFunctions(
                          context,
                          forceSignIn: true,
                        );

                        nextNavigation();
                        loadingIndeterminateKey.currentState
                            ?.setVisibility(false);
                      },
                      onError: (e) {
                        print("Error signing in: " + e.toString());
                        loadingIndeterminateKey.currentState
                            ?.setVisibility(false);
                      },
                    );
                  },
                  title: "sign-in-with-google".tr(),
                  icon: MoreIcons.google,
                  isExpanded: false,
                ),
          getPlatform() == PlatformOS.isIOS
              ? SizedBox.shrink()
              : SizedBox(height: 8),
          getPlatform() == PlatformOS.isIOS
              ? SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: TextFont(
                    text: "onboarding-info-3".tr(),
                    textAlign: TextAlign.center,
                    fontSize: 16,
                    maxLines: 5,
                  ),
                ),
          getPlatform() == PlatformOS.isIOS
              ? SizedBox.shrink()
              : SizedBox(height: 35),
          getPlatform() == PlatformOS.isIOS
              ? SizedBox.shrink()
              : LowKeyButton(
                  onTap: () {
                    nextNavigation();
                  },
                  text: "continue-without-sign-in".tr(),
                ),
          // IntrinsicWidth(
          //   child: Button(
          //     label: "Let's go!",
          //     onTap: () {
          //       nextNavigation();
          //     },
          //   ),
          // ),
        ],
      ),
    ];

    return Stack(
      children: [
        PageView(
          controller: controller,
          children: children,
        ),
        Positioned(
          bottom: 0,
          child: IgnorePointer(
            child: Container(
              height: 100,
              width: 1000,
              foregroundDecoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).canvasColor.withOpacity(0.0),
                    Theme.of(context).canvasColor,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.1, 1],
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.viewPaddingOf(context).bottom),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 15,
              ),
              child: IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AnimatedBuilder(
                      animation: controller,
                      builder: (BuildContext context, Widget? child) {
                        int currentIndex =
                            controller.page?.round().toInt() ?? 0;
                        return AnimatedOpacity(
                          opacity: currentIndex <= 0 ? 0 : 1,
                          duration: Duration(milliseconds: 200),
                          child: ButtonIcon(
                            onTap: () {
                              previousOnBoardPage();
                            },
                            icon: getPlatform() == PlatformOS.isIOS
                                ? appStateSettings["outlinedIcons"]
                                    ? Icons.chevron_left_outlined
                                    : Icons.chevron_left_rounded
                                : appStateSettings["outlinedIcons"]
                                    ? Icons.arrow_back_outlined
                                    : Icons.arrow_back_rounded,
                            size: 50,
                            padding: getIsFullScreen(context) == false
                                ? EdgeInsets.all(3)
                                : EdgeInsets.all(6),
                          ),
                        );
                      },
                    ),
                    PageIndicator(
                        controller: controller, itemCount: children.length),
                    AnimatedBuilder(
                      animation: controller,
                      builder: (BuildContext context, Widget? child) {
                        int currentIndex =
                            controller.page?.round().toInt() ?? 0;
                        return AnimatedOpacity(
                          opacity: getPlatform() == PlatformOS.isIOS
                              ? 1
                              : currentIndex >= children.length - 1
                                  ? 0
                                  : 1,
                          duration: Duration(milliseconds: 200),
                          child: ButtonIcon(
                            onTap: () {
                              if (currentIndex < children.length - 1 ||
                                  getPlatform() == PlatformOS.isIOS)
                                nextOnBoardPage(children.length);
                            },
                            icon: getPlatform() == PlatformOS.isIOS
                                ? appStateSettings["outlinedIcons"]
                                    ? Icons.chevron_right_outlined
                                    : Icons.chevron_right_rounded
                                : appStateSettings["outlinedIcons"]
                                    ? Icons.arrow_forward_outlined
                                    : Icons.arrow_forward_rounded,
                            size: 50,
                            padding: getIsFullScreen(context) == false
                                ? EdgeInsets.all(3)
                                : EdgeInsets.all(6),
                          ),
                        );
                      },
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

class OnBoardPage extends StatelessWidget {
  const OnBoardPage({Key? key, required this.widgets, this.bottomWidget})
      : super(key: key);
  final List<Widget> widgets;
  final Widget? bottomWidget;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Column(
                children: [
                  SizedBox(height: 20),
                  ...widgets,
                  SizedBox(height: 80),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
              bottom: 60 + MediaQuery.paddingOf(context).bottom),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: bottomWidget ?? SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
