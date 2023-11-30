import 'dart:async';

import 'package:budget/functions.dart';
import 'package:budget/struct/firebaseAuthGlobal.dart';
import 'package:budget/struct/languageMap.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/globalSnackBar.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/showChangelog.dart';
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

bool openRatingPopupCheck(BuildContext context) {
  if ((appStateSettings["numLogins"] + 1) % 10 == 0 &&
      appStateSettings["submittedFeedback"] != true) {
    openBottomSheet(context, RatingPopup(), fullSnap: true);
    return true;
  }
  return false;
}

class RatingPopup extends StatefulWidget {
  const RatingPopup({super.key});

  @override
  State<RatingPopup> createState() => _RatingPopupState();
}

class _RatingPopupState extends State<RatingPopup> {
  int? selectedStars = null;
  bool writingFeedback = false;
  TextEditingController _feedbackController = TextEditingController();
  TextEditingController _feedbackControllerEmail = TextEditingController();

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
                          appStateSettings["outlinedIcons"]
                              ? Icons.star_outlined
                              : Icons.star_rounded,
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
            labelText: "feedback-suggestions-questions".tr(),
            keyboardType: TextInputType.multiline,
            maxLines: null,
            minLines: 3,
            padding: EdgeInsets.zero,
            controller: _feedbackController,
            onChanged: (value) {
              if (writingFeedback == false) {
                setState(() {
                  writingFeedback = true;
                });
                bottomSheetControllerGlobal.snapToExtent(0);
              }
            },
          ),
          SizedBox(height: 10),
          AnimatedExpanded(
            expand: writingFeedback,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextInput(
                labelText: "email-optional".tr(),
                padding: EdgeInsets.zero,
                controller: _feedbackControllerEmail,
                textCapitalization: TextCapitalization.none,
                autocorrect: false,
              ),
            ),
          ),
          Opacity(
            opacity: 0.4,
            child: AnimatedSizeSwitcher(
              child: TextFont(
                key: ValueKey(writingFeedback.toString()),
                text: writingFeedback
                    ? "rate-app-privacy-email".tr()
                    : "rate-app-privacy".tr(),
                textAlign: TextAlign.center,
                fontSize: 12,
                maxLines: 5,
              ),
            ),
          ),
          SizedBox(height: 15),
          Button(
            label: "submit".tr(),
            onTap: () async {
              // Remind user to provide email
              if (_feedbackController.text != "" &&
                  _feedbackControllerEmail.text == "") {
                dynamic result = await openPopup(
                  context,
                  icon: appStateSettings["outlinedIcons"]
                      ? Icons.email_outlined
                      : Icons.email_rounded,
                  title: "provide-email-question".tr(),
                  description: "provide-email-question-description".tr(),
                  onCancelLabel: "submit-anyway".tr(),
                  onCancel: () {
                    Navigator.maybePop(context, true);
                  },
                  onSubmitLabel: "go-back".tr(),
                  onSubmit: () {
                    Navigator.maybePop(context, false);
                  },
                );
                if (result == false) return;
              }

              Navigator.maybePop(context);

              shareFeedback(
                _feedbackController.text,
                "rating",
                feedbackEmail: _feedbackControllerEmail.text,
                selectedStars: selectedStars,
              );
            },
            disabled: selectedStars == null,
          )
        ],
      ),
    );
  }
}

Future<bool> shareFeedback(String feedbackText, String feedbackType,
    {String? feedbackEmail, int? selectedStars}) async {
  loadingIndeterminateKey.currentState!.setVisibility(true);
  bool error = false;

  try {
    if ((selectedStars ?? 0) >= 4) {
      if (await inAppReview.isAvailable()) inAppReview.requestReview();
    }
  } catch (e) {
    print(e.toString());
    error = true;
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
      "feedbackType": feedbackType,
      "email": feedbackEmail,
      "platform": getPlatform().toString(),
      "appVersion": getVersionString(),
    };

    DocumentReference feedbackCreatedOnCloud =
        await db.collection("feedback").add(feedbackEntry);

    openSnackbar(SnackbarMessage(
        title: "feedback-shared".tr(),
        description: "thank-you".tr(),
        icon: appStateSettings["outlinedIcons"]
            ? Icons.rate_review_outlined
            : Icons.rate_review_rounded,
        timeout: Duration(milliseconds: 2500)));
  } catch (e) {
    print(e.toString());
    error = true;
  }
  if (error == true) {
    print("Error leaving review on store");
    openSnackbar(SnackbarMessage(
        title: "Error Sharing Feedback",
        description: "Please try again later",
        icon: appStateSettings["outlinedIcons"]
            ? Icons.warning_outlined
            : Icons.warning_rounded,
        timeout: Duration(milliseconds: 2500)));
  }
  loadingIndeterminateKey.currentState!.setVisibility(false);

  if (selectedStars != -1) {
    updateSettings("submittedFeedback", true,
        pagesNeedingRefresh: [], updateGlobalState: false);
  }

  return true;
}
