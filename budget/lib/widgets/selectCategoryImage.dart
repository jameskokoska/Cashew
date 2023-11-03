import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/ratingPopup.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/struct/iconObjects.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' hide TextInput;

// Future<List<String>> getCategoryImages() async {
//   final manifestContent = await rootBundle.loadString('AssetManifest.json');

//   final Map<String, dynamic> manifestMap = json.decode(manifestContent);

//   final List<String> imagePaths = manifestMap.keys
//       .where((String key) => key.contains('categories/'))
//       .where((String key) => key.contains('.png'))
//       .toList();

//   return imagePaths;
// }

class SelectCategoryImage extends StatefulWidget {
  SelectCategoryImage({
    Key? key,
    required this.setSelectedImage,
    this.selectedImage,
    required this.setSelectedTitle,
    required this.setSelectedEmoji,
    this.next,
  }) : super(key: key);

  final Function(String?) setSelectedImage;
  final String? selectedImage;
  final Function(String?) setSelectedTitle;
  final Function(String?) setSelectedEmoji;
  final VoidCallback? next;

  @override
  _SelectCategoryImageState createState() => _SelectCategoryImageState();
}

class _SelectCategoryImageState extends State<SelectCategoryImage> {
  String? selectedImage;
  String searchTerm = "";
  bool isEmoji = false;

  @override
  void initState() {
    super.initState();
    if (widget.selectedImage != null) {
      setState(() {
        selectedImage =
            widget.selectedImage!.replaceAll("assets/categories/", "");
      });
    }
  }

  void openEmojiSelectorPopup() {
    openBottomSheet(
      context,
      fullSnap: true,
      PopupFramework(
        title: "enter-emoji".tr(),
        child: Column(
          children: [
            SelectText(
              icon: appStateSettings["outlinedIcons"]
                  ? Icons.emoji_emotions_outlined
                  : Icons.emoji_emotions_rounded,
              setSelectedText: (value) {
                widget.setSelectedImage(null);
                widget.setSelectedEmoji(value);
              },
              popContextWhenSet: true,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(
                    r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])'))
              ],
              placeholder: "enter-emoji-placeholder".tr() + " 😀...",
              autoFocus: false,
              requestLateAutoFocus: true,
            ),
          ],
        ),
      ),
    );
    // Fix over-scroll stretch when keyboard pops up quickly
    Future.delayed(Duration(milliseconds: 100), () {
      bottomSheetControllerGlobal.scrollTo(0,
          duration: Duration(milliseconds: 100));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: [
          context.locale.toString() != "en"
              ? UseEmoji(onTap: () {
                  Navigator.pop(context);
                  openEmojiSelectorPopup();
                })
              : SizedBox.shrink(),
          context.locale.toString() == "en"
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child:
                          // Focus(
                          //   onFocusChange: (value) {
                          //     if (value) {
                          //       // Fix over-scroll stretch when keyboard pops up quickly
                          //       Future.delayed(Duration(milliseconds: 100), () {
                          //         bottomSheetControllerGlobal.scrollTo(0,
                          //             duration: Duration(milliseconds: 100));
                          //       });
                          //       // Update the size of the bottom sheet
                          //       Future.delayed(Duration(milliseconds: 500), () {
                          //         bottomSheetControllerGlobal.snapToExtent(0);
                          //       });
                          //     }
                          //   },
                          // child:
                          TextInput(
                        labelText: "search-placeholder".tr(),
                        icon: appStateSettings["outlinedIcons"]
                            ? Icons.search_outlined
                            : Icons.search_rounded,
                        onSubmitted: (value) {},
                        onChanged: (value) {
                          setState(() {
                            searchTerm = value.trim();
                          });
                          bottomSheetControllerGlobal.snapToExtent(0);
                        },
                        padding: EdgeInsets.all(0),
                        autoFocus: kIsWeb,
                      ),
                      // ),
                    ),
                    SizedBox(width: 10),
                    ButtonIcon(
                      onTap: () {
                        Navigator.pop(context);
                        openEmojiSelectorPopup();
                      },
                      icon: appStateSettings["outlinedIcons"]
                          ? Icons.emoji_emotions_outlined
                          : Icons.emoji_emotions_rounded,
                    ),
                  ],
                )
              : SizedBox.shrink(),
          SizedBox(height: 5),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              children: iconObjects.map((IconForCategory image) {
                bool show = false;
                if (searchTerm != "") {
                  for (int i = 0; i < image.tags.length; i++) {
                    if (image.tags[i]
                        .toLowerCase()
                        .contains(searchTerm.toLowerCase())) {
                      show = true;
                      break;
                    }
                  }
                } else {
                  show = true;
                }
                if (show)
                  return ImageIcon(
                    sizePadding: 8,
                    margin: EdgeInsets.all(5),
                    color: Colors.transparent,
                    size: 55,
                    iconPath: "assets/categories/" + image.icon,
                    onTap: () {
                      widget.setSelectedImage(image.icon);
                      widget.setSelectedEmoji(null);
                      if (context.locale.toString() == "en")
                        widget.setSelectedTitle(image.mostLikelyCategoryName);
                      setState(() {
                        selectedImage = image.icon;
                      });
                      Future.delayed(Duration(milliseconds: 70), () {
                        Navigator.pop(context);
                        if (widget.next != null) {
                          widget.next!();
                        }
                      });
                    },
                    outline: selectedImage == image.icon,
                  );
                return SizedBox.shrink();
              }).toList(),
            ),
          ),
          context.locale.toString() == "en"
              ? Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: UseEmoji(onTap: () {
                    Navigator.pop(context);
                    openEmojiSelectorPopup();
                  }),
                )
              : SizedBox.shrink(),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: SuggestIcon(),
          ),
        ],
      ),
    );
  }
}

class UseEmoji extends StatelessWidget {
  const UseEmoji({required this.onTap, super.key});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: onTap,
      color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.7),
      borderRadius: 15,
      child: Padding(
        padding:
            const EdgeInsets.only(left: 15, right: 10, top: 12, bottom: 12),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                appStateSettings["outlinedIcons"]
                    ? Icons.emoji_emotions_outlined
                    : Icons.emoji_emotions_rounded,
                color: Theme.of(context).colorScheme.secondary,
                size: 31,
              ),
            ),
            Expanded(
              child: TextFont(
                textColor: Theme.of(context).colorScheme.onSecondaryContainer,
                text: "use-emoji-details".tr(),
                maxLines: 5,
                fontSize: 14,
              ),
            ),
            Icon(
              appStateSettings["outlinedIcons"]
                  ? Icons.chevron_right_outlined
                  : Icons.chevron_right_rounded,
              size: 25,
            ),
          ],
        ),
      ),
    );
  }
}

class SuggestIcon extends StatelessWidget {
  const SuggestIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: () {
        openBottomSheet(
          context,
          SuggestIconPopup(),
          reAssignBottomSheetControllerGlobal: false,
          useCustomController: true,
        );
        // Fix over-scroll stretch when keyboard pops up quickly
        Future.delayed(Duration(milliseconds: 100), () {
          bottomSheetControllerGlobalCustomAssigned?.scrollTo(0,
              duration: Duration(milliseconds: 100));
        });
      },
      color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.7),
      borderRadius: 15,
      child: Padding(
        padding:
            const EdgeInsets.only(left: 15, right: 10, top: 12, bottom: 12),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                appStateSettings["outlinedIcons"]
                    ? Icons.reviews_outlined
                    : Icons.reviews_rounded,
                color: Theme.of(context).colorScheme.secondary,
                size: 31,
              ),
            ),
            Expanded(
              child: TextFont(
                textColor: Theme.of(context).colorScheme.onSecondaryContainer,
                text: "icon-suggestion-details".tr(),
                maxLines: 5,
                fontSize: 14,
              ),
            ),
            Icon(
              appStateSettings["outlinedIcons"]
                  ? Icons.chevron_right_outlined
                  : Icons.chevron_right_rounded,
              size: 25,
            ),
          ],
        ),
      ),
    );
  }
}

class SuggestIconPopup extends StatefulWidget {
  const SuggestIconPopup({super.key});

  @override
  State<SuggestIconPopup> createState() => _SuggestIconPopupState();
}

class _SuggestIconPopupState extends State<SuggestIconPopup> {
  TextEditingController _feedbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopupFramework(
      title: "suggest-icon".tr(),
      child: Column(
        children: [
          TextInput(
            labelText: "suggestion".tr(),
            keyboardType: TextInputType.multiline,
            maxLines: null,
            minLines: 3,
            padding: EdgeInsets.zero,
            controller: _feedbackController,
            onChanged: (value) {
              setState(() {});
            },
          ),
          SizedBox(height: 10),
          Opacity(
            opacity: 0.4,
            child: TextFont(
              text: "icon-suggestion-privacy".tr(),
              textAlign: TextAlign.center,
              fontSize: 12,
              maxLines: 5,
            ),
          ),
          SizedBox(height: 15),
          Button(
            label: "submit".tr(),
            onTap: () async {
              shareFeedback(_feedbackController.text, "icon");
              Navigator.pop(context);
            },
            disabled: _feedbackController.text == "",
          )
        ],
      ),
    );
  }
}

class ImageIcon extends StatelessWidget {
  ImageIcon({
    Key? key,
    required this.color,
    required this.size,
    this.onTap,
    this.margin,
    this.sizePadding = 20,
    this.outline = false,
    this.iconPath,
  }) : super(key: key);

  final Color color;
  final double size;
  final VoidCallback? onTap;
  final EdgeInsets? margin;
  final double sizePadding;
  final bool outline;
  final String? iconPath;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 250),
      margin: margin ?? EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
      height: size,
      width: size,
      decoration: outline
          ? BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                width: 2,
              ),
              borderRadius: BorderRadius.all(Radius.circular(500)),
            )
          : BoxDecoration(
              border: Border.all(
                color: color,
                width: 0,
              ),
              borderRadius: BorderRadius.all(Radius.circular(500)),
            ),
      child: Tappable(
        color: color,
        onTap: onTap,
        borderRadius: 500,
        child: Padding(
          padding: EdgeInsets.all(sizePadding),
          child: Image(
            image: AssetImage(iconPath ?? ""),
            width: size,
          ),
        ),
      ),
    );
  }
}
