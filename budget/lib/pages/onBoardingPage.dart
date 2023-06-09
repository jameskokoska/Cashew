import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/accountAndBackup.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/moreIcons.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/popupFramework.dart';
import 'package:budget/widgets/radioItems.dart';
import 'package:budget/widgets/selectAmount.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/viewAllTransactionsButton.dart';
import 'package:flutter/material.dart';
import 'package:budget/main.dart';
import 'package:flutter/services.dart';
import '../functions.dart';
import 'package:googleapis/drive/v3.dart' as drive;

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({Key? key, this.popNavigationWhenDone = false})
      : super(key: key);

  final bool popNavigationWhenDone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: OnBoardingPageBody(popNavigationWhenDone: popNavigationWhenDone));
  }
}

class OnBoardingPageBody extends StatefulWidget {
  const OnBoardingPageBody({Key? key, this.popNavigationWhenDone = false})
      : super(key: key);
  final bool popNavigationWhenDone;

  @override
  State<OnBoardingPageBody> createState() => OnBoardingPageBodyState();
}

class OnBoardingPageBodyState extends State<OnBoardingPageBody> {
  int currentIndex = 0;

  final PageController controller = PageController();
  FocusNode _focusNode = FocusNode();
  late FocusAttachment _focusAttachment;

  double? selectedAmount;
  int selectedPeriodLength = 1;
  DateTime selectedStartDate =
      DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime? selectedEndDate;
  String selectedRecurrence = "Monthly";

  nextNavigation() async {
    if (selectedAmount != null && selectedAmount != 0) {
      int order = await database.getAmountOfBudgets();
      await database.createOrUpdateBudget(
        Budget(
          budgetPk: DateTime.now().millisecondsSinceEpoch,
          name: "Budget",
          amount: selectedAmount ?? 0,
          startDate: selectedStartDate,
          endDate: selectedEndDate ?? DateTime.now(),
          allCategoryFks: true,
          addedTransactionsOnly: false,
          periodLength: selectedPeriodLength,
          dateCreated: DateTime.now(),
          pinned: true,
          order: order,
          walletFk: 0,
          reoccurrence: mapRecurrence(selectedRecurrence),
        ),
      );
    }
    if (widget.popNavigationWhenDone) {
      Navigator.pop(context);
    } else {
      updateSettings("hasOnboarded", true,
          pagesNeedingRefresh: [], updateGlobalState: true);
    }
  }

  @override
  void initState() {
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
    super.initState();
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
    if (currentIndex + 1 == numPages) {
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
      //           maxWidth: MediaQuery.of(context).size.height <=
      //                   MediaQuery.of(context).size.width
      //               ? MediaQuery.of(context).size.height * 0.5
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
                maxWidth: MediaQuery.of(context).size.height <=
                        MediaQuery.of(context).size.width
                    ? MediaQuery.of(context).size.height * 0.5
                    : 300),
            child: Image(
              image: AssetImage("assets/landing/Graph.png"),
            ),
          ),
          SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: TextFont(
              text: "Track your spending habits with Cashew!",
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
              text:
                  "Enter your daily transactions to gain powerful insights into your spending habits.",
              textAlign: TextAlign.center,
              fontSize: 16,
              maxLines: 5,
            ),
          ),
          SizedBox(height: 55),
        ],
      ),
      OnBoardPage(
        widgets: [
          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.height <=
                        MediaQuery.of(context).size.width
                    ? MediaQuery.of(context).size.height * 0.5
                    : 300),
            child: Image(
              image: AssetImage("assets/landing/BankOrPig.png"),
            ),
          ),
          SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: TextFont(
              text: "Set up a budget",
              fontWeight: FontWeight.bold,
              textAlign: TextAlign.center,
              fontSize: 25,
              maxLines: 5,
            ),
          ),
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
          SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: TextFont(
              text:
                  "Choose an amount right for you.\nYou can always change it and add more budgets.",
              textAlign: TextAlign.center,
              fontSize: 16,
              maxLines: 5,
            ),
          ),
        ],
      ),
      OnBoardPage(
        widgets: [
          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.height <=
                        MediaQuery.of(context).size.width
                    ? MediaQuery.of(context).size.height * 0.5
                    : 300),
            child: Image(
              image: AssetImage("assets/landing/PigBank.png"),
            ),
          ),
          SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: TextFont(
              text: "Welcome to Cashew!",
              fontWeight: FontWeight.bold,
              textAlign: TextAlign.center,
              fontSize: 25,
              maxLines: 5,
            ),
          ),
          SizedBox(height: 25),
          SettingsContainerOutlined(
            onTap: () async {
              loadingIndeterminateKey.currentState?.setVisibility(true);
              try {
                await signInGoogle(
                  context: context,
                  waitForCompletion: false,
                  drivePermissions: true,
                  next: () {},
                );
                if (appStateSettings["username"] == "" && user != null) {
                  updateSettings("username", user?.displayName ?? "",
                      pagesNeedingRefresh: [0]);
                }
              } catch (e) {
                print("Error signing in: " + e.toString());
              }
              List<drive.File>? files = (await getDriveFiles()).$2;
              var result;
              if ((files?.length ?? 0) > 0) {
                result = await openPopup(
                  context,
                  icon: Icons.cloud_sync_rounded,
                  title: "Backup Found",
                  description: "Would you like to restore a backup?",
                  onSubmit: () {
                    Navigator.pop(context, true);
                  },
                  onCancel: () {
                    Navigator.pop(context, false);
                  },
                  onSubmitLabel: "Restore",
                  onCancelLabel: "Cancel",
                );
              }
              if (result == true) {
                chooseBackup(context);
              } else {
                nextNavigation();
              }
              loadingIndeterminateKey.currentState?.setVisibility(false);
            },
            title: "Sign In with Google",
            icon: MoreIcons.google,
            isExpanded: false,
          ),
          SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: TextFont(
              text:
                  "Keep your data backed up and synced across different platforms.",
              textAlign: TextAlign.center,
              fontSize: 16,
              maxLines: 5,
            ),
          ),
          SizedBox(height: 35),
          LowKeyButton(
            onTap: () {
              nextNavigation();
            },
            text: "Continue Without Sign In",
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
          onPageChanged: (value) {
            setState(() {
              currentIndex = value;
            });
            // print(currentIndex);
          },
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
            padding: EdgeInsets.only(bottom: bottomPaddingSafeArea),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 15,
              ),
              child: IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AnimatedOpacity(
                      opacity: currentIndex <= 0 ? 0 : 1,
                      duration: Duration(milliseconds: 200),
                      child: ButtonIcon(
                        onTap: () {
                          previousOnBoardPage();
                        },
                        icon: Icons.arrow_back_rounded,
                        size: getWidthNavigationSidebar(context) <= 0 ? 50 : 65,
                      ),
                    ),
                    Row(
                      children: [
                        ...List<int>.generate(children.length, (i) => i + 1)
                            .map(
                              (
                                index,
                              ) =>
                                  Builder(
                                builder: (BuildContext context) =>
                                    AnimatedScale(
                                  duration: Duration(milliseconds: 900),
                                  scale: index - 1 == currentIndex ? 1.3 : 1,
                                  curve: ElasticOutCurve(0.2),
                                  child: AnimatedSwitcher(
                                    duration: Duration(milliseconds: 400),
                                    child: Container(
                                      key: ValueKey(index - 1 == currentIndex),
                                      width: 6,
                                      height: 6,
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 3),
                                      decoration: BoxDecoration(
                                        color: index - 1 == currentIndex
                                            ? Theme.of(context)
                                                .colorScheme
                                                .secondary
                                                .withOpacity(0.7)
                                            : Theme.of(context)
                                                .colorScheme
                                                .secondary
                                                .withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ],
                    ),
                    AnimatedOpacity(
                      opacity: currentIndex >= children.length - 1 ? 0 : 1,
                      duration: Duration(milliseconds: 200),
                      child: ButtonIcon(
                        onTap: () {
                          if (currentIndex < children.length - 1)
                            nextOnBoardPage(children.length);
                        },
                        icon: Icons.arrow_forward_rounded,
                        size: getWidthNavigationSidebar(context) <= 0 ? 50 : 65,
                      ),
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
  const OnBoardPage({Key? key, required this.widgets}) : super(key: key);
  final List<Widget> widgets;
  @override
  Widget build(BuildContext context) {
    return Center(
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
    );
  }
}
