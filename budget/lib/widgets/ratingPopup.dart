import 'dart:async';

import 'package:budget/struct/firebaseAuthGlobal.dart';
import 'package:budget/struct/languageMap.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/globalSnackBar.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:budget/widgets/framework/popupFramework.dart';

final InAppReview inAppReview = InAppReview.instance;

class RatingPopup extends StatefulWidget {
  const RatingPopup({super.key});

  @override
  State<RatingPopup> createState() => _RatingPopupState();
}

class _RatingPopupState extends State<RatingPopup> {
  int? selectedStars = null;
  TextEditingController _feedbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopupFramework(
      title: "rate-app".tr(namedArgs: {"app": globalAppName}),
      subtitle: "rate-app-subtitle".tr(namedArgs: {"app": globalAppName}),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < 5; i++)
                Tappable(
                  color: Colors.transparent,
                  borderRadius: 100,
                  onTap: () {
                    setState(() {
                      selectedStars = i;
                      print(selectedStars);
                    });
                  },
                  child: ScaleIn(
                    delay: Duration(milliseconds: 300 + 100 * i),
                    child: ScalingWidget(
                      keyToWatch: (i <= (selectedStars ?? 0)).toString(),
                      child: AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        child: Icon(
                          Icons.star_rounded,
                          key: ValueKey(i <= (selectedStars ?? -1)),
                          size: getWidthBottomSheet(context) - 100 < 60 * 5
                              ? (getWidthBottomSheet(context) - 100) / 5
                              : 60,
                          color: selectedStars != null &&
                                  i <= (selectedStars ?? 0)
                              ? appStateSettings["materialYou"]
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.7)
                                  : getColor(context, "starYellow")
                              : appStateSettings["materialYou"]
                                  ? Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withOpacity(0.2)
                                  : getColor(context, "lightDarkAccentHeavy"),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 15),
          TextInput(
            labelText: "feedback".tr(),
            keyboardType: TextInputType.multiline,
            maxLines: null,
            minLines: 3,
            padding: EdgeInsets.zero,
            controller: _feedbackController,
          ),
          SizedBox(height: 10),
          Opacity(
            opacity: 0.4,
            child: TextFont(
              text: "rate-app-privacy".tr(),
              textAlign: TextAlign.center,
              fontSize: 12,
              maxLines: 5,
            ),
          ),
          SizedBox(height: 15),
          Button(
            label: "submit".tr(),
            onTap: () async {
              shareFeedback(selectedStars, _feedbackController.text);
              updateSettings("submittedFeedback", true,
                  pagesNeedingRefresh: [], updateGlobalState: false);
              Navigator.pop(context);
            },
            disabled: selectedStars == null,
          )
        ],
      ),
    );
  }
}

Future<bool> shareFeedback(selectedStars, feedbackText) async {
  loadingIndeterminateKey.currentState!.setVisibility(true);
  try {
    if ((selectedStars ?? 0) >= 4 && await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    }
  } catch (e) {
    loadingIndeterminateKey.currentState!.setVisibility(false);
    print("Error leaving review on store");
    openSnackbar(SnackbarMessage(
        title: "Error Sharing Feedback",
        description: "Please try again later",
        icon: Icons.warning_amber_rounded,
        timeout: Duration(milliseconds: 2500)));
    return false;
  }
  try {
    FirebaseFirestore? db = await firebaseGetDBInstanceAnonymous();
    if (db == null) {
      throw ("Can't connect to db");
    }
    Map<String, dynamic> feedbackEntry = {
      "stars": (selectedStars ?? -1) + 1,
      "feedback": feedbackText,
      "dateTime": DateTime.now(),
    };

    DocumentReference feedbackCreatedOnCloud =
        await db.collection("feedback").add(feedbackEntry);

    openSnackbar(SnackbarMessage(
        title: "Feedback Shared",
        description: "Thank you!",
        icon: Icons.rate_review_rounded,
        timeout: Duration(milliseconds: 2500)));
  } catch (e) {
    loadingIndeterminateKey.currentState!.setVisibility(false);
    print("There was an error sharing feedback");
    openSnackbar(SnackbarMessage(
        title: "Error Sharing Feedback",
        description: "Please try again later",
        icon: Icons.warning_amber_rounded,
        timeout: Duration(milliseconds: 2500)));
    return false;
  }
  loadingIndeterminateKey.currentState!.setVisibility(false);
  return true;
}
