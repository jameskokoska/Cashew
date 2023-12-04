import 'package:budget/functions.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class HomePageUsername extends StatelessWidget {
  final AnimationController animationControllerHeader;
  final AnimationController animationControllerHeader2;
  final bool showUsername;
  final Map<String, dynamic> appStateSettings;
  final Function enterNameBottomSheet;

  HomePageUsername({
    required this.animationControllerHeader,
    required this.animationControllerHeader2,
    required this.showUsername,
    required this.appStateSettings,
    required this.enterNameBottomSheet,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        !showUsername
            ? SizedBox()
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 9),
                child: AnimatedBuilder(
                  animation: animationControllerHeader,
                  builder: (_, child) {
                    return Transform.translate(
                      offset: Offset(
                        0,
                        20 - 20 * (animationControllerHeader.value),
                      ),
                      child: child,
                    );
                  },
                  child: FadeTransition(
                    opacity: animationControllerHeader2,
                    child: PartyHat(
                      size: 23,
                      enabled: showUsername,
                      child: TextFont(
                        text: getWelcomeMessage(),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
        AnimatedBuilder(
          animation: animationControllerHeader,
          builder: (_, child) {
            return Transform.scale(
              alignment: Alignment.bottomLeft,
              scale: animationControllerHeader.value < 0.5
                  ? 0.5 * 0.4 + 0.6
                  : (animationControllerHeader.value) * 0.4 + 0.6,
              child: Tappable(
                color: Colors.transparent,
                onTap: () {
                  enterNameBottomSheet(context);
                },
                onLongPress: () {
                  enterNameBottomSheet(context);
                },
                borderRadius: 15,
                child: child ?? SizedBox.shrink(),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9),
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: PartyHat(
                size: 28,
                enabled: !showUsername,
                child: TextFont(
                  text: !showUsername
                      ? "home".tr()
                      : appStateSettings["username"] ?? "",
                  fontWeight: FontWeight.bold,
                  fontSize: 33,
                  textColor: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class HomePageWelcomeBannerSmall extends StatelessWidget {
  const HomePageWelcomeBannerSmall({required this.showUsername, super.key});
  final bool showUsername;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 17, right: 5),
      child: PartyHat(
        child: TextFont(
          text: showUsername ? getWelcomeMessage() : "home".tr(),
          fontWeight: FontWeight.bold,
          fontSize: getWidthNavigationSidebar(context) <= 0 ? 26 : 30,
          textColor: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class PartyHat extends StatelessWidget {
  const PartyHat(
      {required this.child, this.enabled = true, this.size = 25, super.key});
  final Widget child;
  final double size;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (enabled == false) return child;
    String? hatIcon;
    if (DateTime.now().month == 12 && DateTime.now().day == 31) {
      hatIcon = "party-hat.png";
    } else if (DateTime.now().month == 1 && DateTime.now().day == 1) {
      hatIcon = "party-hat.png";
    } else if (DateTime.now().month == 12 && DateTime.now().day >= 15) {
      hatIcon = "santa-hat.png";
    }
    if (hatIcon == null) return child;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          left: -7,
          top: -16.6,
          child: Transform.rotate(
            angle: -0.24,
            child: Image.asset(
              "assets/icons/fun/" + hatIcon,
              width: size,
            ),
          ),
        ),
      ],
    );
  }
}
