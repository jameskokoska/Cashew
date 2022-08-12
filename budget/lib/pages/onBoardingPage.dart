import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:budget/colors.dart';
import 'package:budget/database/binary_string_conversion.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/pages/editCategoriesPage.dart';
import 'package:budget/pages/editWalletsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/accountAndBackup.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/popupFramework.dart';
import 'package:budget/widgets/selectCategoryImage.dart';
import 'package:budget/widgets/selectColor.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:budget/main.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart' as signIn;
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;
import 'dart:math' as math;
import 'package:file_picker/file_picker.dart';
import '../functions.dart';

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

  nextNavigation() {
    if (widget.popNavigationWhenDone) {
      Navigator.pop(context);
    } else {
      updateSettings("hasOnboarded", true,
          pagesNeedingRefresh: [], updateGlobalState: true);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController();

    final List<Widget> children = [
      OnBoardPage(
        widgets: [
          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.height <=
                        MediaQuery.of(context).size.width
                    ? MediaQuery.of(context).size.height * 0.5
                    : 300),
            child: Image(
              image: AssetImage("assets/landing/DepressedMan.png"),
            ),
          ),
          SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: TextFont(
              text: "Losing track of your transactions?",
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
              text: "It's important to be mindful of your purchases.",
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
              image: AssetImage("assets/landing/BankOrPig.png"),
            ),
          ),
          SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: TextFont(
              text: "Save money by knowing where your money is going.",
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
                  "Identify and remove unnecessary spending habits from your life.",
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
              image: AssetImage("assets/landing/Graph.png"),
            ),
          ),
          SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: TextFont(
              text: "Track your spending habits with Budget App!",
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
              text: "Create budgets to understand your spending habits.",
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
              text: "Start getting on top of your transactions!",
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
                  "Track your income, expenses, recurring scubscription transactions, and more!",
              textAlign: TextAlign.center,
              fontSize: 16,
              maxLines: 5,
            ),
          ),
          SizedBox(height: 20),
          IntrinsicWidth(
            child: Button(
              label: "Let's go!",
              onTap: () {
                nextNavigation();
              },
            ),
          ),
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
            print(currentIndex);
          },
          controller: controller,
          children: children,
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
                          controller.previousPage(
                            duration: Duration(milliseconds: 1100),
                            curve: ElasticOutCurve(1.3),
                          );
                        },
                        icon: Icons.arrow_back_rounded,
                        size: 45,
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
                          controller.nextPage(
                            duration: Duration(milliseconds: 1100),
                            curve: ElasticOutCurve(1.3),
                          );
                          if (currentIndex + 1 == children.length) {
                            nextNavigation();
                          }
                        },
                        icon: Icons.arrow_forward_rounded,
                        size: 45,
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
    return Column(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        Column(
          children: widgets,
        )
      ],
    );
  }
}
