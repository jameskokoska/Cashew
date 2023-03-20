import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:budget/main.dart';
import 'package:flutter/services.dart';
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

  final PageController controller = PageController();
  FocusNode _focusNode = FocusNode();
  late FocusAttachment _focusAttachment;

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
    _focusAttachment = _focusNode.attach(context, onKeyEvent: (node, event) {
      if (event.logicalKey.keyLabel == "Go Back" ||
          event.logicalKey == LogicalKeyboardKey.escape) {
        nextNavigation();
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
          event.logicalKey == LogicalKeyboardKey.arrowRight) {
        nextOnBoardPage(4);
      } else if (event.runtimeType.toString() == "KeyDownEvent" &&
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
            // print(currentIndex);
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
                          previousOnBoardPage();
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
                          nextOnBoardPage(children.length);
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
