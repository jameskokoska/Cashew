import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/pages/addObjectivePage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';

class CategoryIcon extends StatelessWidget {
  CategoryIcon({
    Key? key,
    this.categoryPk,
    required this.size,
    this.onTap,
    this.label = false,
    this.labelSize = 10,
    this.margin,
    this.sizePadding = 20,
    this.outline = false,
    this.noBackground = false,
    this.category, //pass this in to not look it up again
    this.borderRadius = 18,
    this.canEditByLongPress = true,
    this.onLongPress,
    this.tintColor,
    this.tintEnabled = true,
    this.cacheImage = false,
    this.enableTooltip = false,
    this.correctionEmojiPaddingBottom = 0,
    this.emojiSize,
    this.emojiScale = 1,
  }) : super(key: key);

  final String? categoryPk;
  final double size;
  final VoidCallback? onTap;
  final bool label;
  final double labelSize;
  final EdgeInsets? margin;
  final double sizePadding;
  final bool outline;
  final bool noBackground;
  final TransactionCategory? category;
  final double borderRadius;
  final bool canEditByLongPress;
  final VoidCallback? onLongPress;
  final Color? tintColor;
  final bool tintEnabled;
  final bool cacheImage;
  final bool enableTooltip;
  final double? correctionEmojiPaddingBottom;
  final double? emojiSize;
  final double emojiScale;

  Widget categoryIconWidget(context, TransactionCategory? category) {
    Widget child = Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 250),
              margin: margin ??
                  EdgeInsets.only(
                      left: 8, right: 8, top: 8, bottom: label ? 2 : 8),
              height: size + sizePadding,
              width: size + sizePadding,
              decoration: outline
                  ? BoxDecoration(
                      border: Border.all(
                        color: dynamicPastel(
                            context,
                            HexColor(
                                category != null ? category.colour : "FFFFFFF",
                                defaultColor:
                                    Theme.of(context).colorScheme.primary),
                            amountLight: 0.5,
                            amountDark: 0.4,
                            inverse: true),
                        width: 3,
                      ),
                      borderRadius:
                          BorderRadius.all(Radius.circular(borderRadius)),
                    )
                  : BoxDecoration(
                      border: Border.all(
                        color: Colors.transparent,
                        width: 0,
                      ),
                      borderRadius:
                          BorderRadius.all(Radius.circular(borderRadius)),
                    ),
              child: Tappable(
                color: noBackground && category != null
                    ? Colors.transparent
                    : category != null
                        ? appStateSettings["colorTintCategoryIcon"] &&
                                tintEnabled
                            ? dynamicPastel(
                                context,
                                tintColor ??
                                    Theme.of(context).colorScheme.primary,
                                amount: 0.5,
                              )
                            : dynamicPastel(
                                context,
                                HexColor(category.colour,
                                    defaultColor:
                                        Theme.of(context).colorScheme.primary),
                                amountLight: 0.55,
                                amountDark: 0.35)
                        : getColor(context, "canvasContainer"),
                onTap: onTap,
                onLongPress: canEditByLongPress == false && onLongPress == null
                    ? null
                    : () {
                        if (onLongPress != null) onLongPress!();
                        if (canEditByLongPress)
                          pushRoute(
                            context,
                            AddCategoryPage(
                              category: category,
                              routesToPopAfterDelete:
                                  RoutesToPopAfterDelete.One,
                            ),
                          );
                      },
                borderRadius: borderRadius - 3,
                child: Center(
                  child: (category?.emojiIconName == null &&
                          category != null &&
                          category.iconName != null
                      ? !appStateSettings["colorTintCategoryIcon"] ||
                              !tintEnabled
                          ? CacheCategoryIcon(
                              iconName: category.iconName ?? "",
                              size: size,
                            )
                          : ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                tintColor ??
                                    Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.7),
                                BlendMode.srcATop,
                              ),
                              child: ColorFiltered(
                                colorFilter: greyScale,
                                child: Opacity(
                                  opacity: 1,
                                  child: CacheCategoryIcon(
                                    iconName: category.iconName ?? "",
                                    size: size,
                                  ),
                                ),
                              ),
                            )
                      : Container()),
                ),
              ),
            ),
            category?.emojiIconName != null
                ? EmojiIcon(
                    emojiIconName: category?.emojiIconName,
                    size: emojiSize ?? size,
                    emojiScale: emojiScale,
                    correctionPaddingBottom: correctionEmojiPaddingBottom,
                  )
                : SizedBox.shrink(),
          ],
        ),
        label
            ? Container(
                margin: EdgeInsets.only(top: 3),
                width: 60,
                child: Center(
                  child: TextFont(
                    textAlign: TextAlign.center,
                    text: category != null ? category.name : "",
                    fontSize: labelSize,
                    maxLines: 1,
                  ),
                ),
              )
            : Container(
                width: size + sizePadding,
              ),
      ],
    );
    if (enableTooltip == true && category?.name != null) {
      return Tooltip(
        waitDuration: Duration(milliseconds: 100),
        message: category?.name ?? "",
        child: child,
        // A hover will still trigger the tooltip,
        // but a long press won't since category icons can be long pressed to reorder/edited
        triggerMode: TooltipTriggerMode.manual,
      );
    } else {
      return child;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (category != null) {
      return categoryIconWidget(context, category);
    } else if (categoryPk != null) {
      return StreamBuilder<TransactionCategory>(
        stream: database.getCategory(categoryPk!).$1,
        builder: (context, snapshot) {
          return categoryIconWidget(context, snapshot.data);
        },
      );
    } else {
      return categoryIconWidget(context, null);
    }
  }
}

class CacheCategoryIcon extends StatefulWidget {
  const CacheCategoryIcon({
    required this.iconName,
    required this.size,
    super.key,
  });
  final String iconName;
  final double size;
  @override
  State<CacheCategoryIcon> createState() => _CacheCategoryIconState();
}

class _CacheCategoryIconState extends State<CacheCategoryIcon> {
  late Image image;

  @override
  void initState() {
    super.initState();
    image = Image.asset(
      "assets/categories/" + widget.iconName,
      width: widget.size,
    );
  }

  @override
  void didUpdateWidget(covariant CacheCategoryIcon oldWidget) {
    if (widget.iconName != oldWidget.iconName ||
        widget.size != oldWidget.size) {
      setState(() {
        image = Image.asset(
          "assets/categories/" + widget.iconName,
          width: widget.size,
        );
      });
    }
  }

  @override
  void didChangeDependencies() {
    precacheImage(image.image, context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return image;
  }
}

class EmojiIcon extends StatelessWidget {
  const EmojiIcon({
    required this.emojiIconName,
    required this.size,
    this.correctionPaddingBottom,
    this.emojiScale = 1,
    super.key,
  });
  final String? emojiIconName;
  final double size;
  final double? correctionPaddingBottom;
  final double emojiScale;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQueryData(textScaleFactor: 1),
      child: IgnorePointer(
        child: Padding(
          padding: EdgeInsets.only(
              bottom: size * 0.185 - (correctionPaddingBottom ?? 0)),
          child: Transform.scale(
            scale: emojiScale,
            child: TextFont(
              text: emojiIconName ?? "",
              textAlign: TextAlign.center,
              fontSize: size,
            ),
          ),
        ),
      ),
    );
  }
}
