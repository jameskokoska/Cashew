import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';

class CategoryIcon extends StatelessWidget {
  CategoryIcon({
    Key? key,
    required this.categoryPk,
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
    this.tintColor,
    this.tintEnabled = true,
  }) : super(key: key);

  final int categoryPk;
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
  final Color? tintColor;
  final bool tintEnabled;

  categoryIconWidget(context, TransactionCategory? category) {
    return Column(
      children: [
        Stack(
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
                onLongPress: canEditByLongPress
                    ? () {
                        pushRoute(
                          context,
                          AddCategoryPage(
                            title: "Edit Category",
                            category: category,
                          ),
                        );
                      }
                    : null,
                borderRadius: borderRadius - 3,
                child: Center(
                  child: (category != null && category.iconName != null
                      ? !appStateSettings["colorTintCategoryIcon"] ||
                              !tintEnabled
                          ? Image(
                              image: AssetImage("assets/categories/" +
                                  (category.iconName ?? "")),
                              width: size,
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
                                  child: Image(
                                    image: AssetImage("assets/categories/" +
                                        (category.iconName ?? "")),
                                    width: size,
                                  ),
                                ),
                              ),
                            )
                      : Container()),
                ),
              ),
            ),
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
  }

  @override
  Widget build(BuildContext context) {
    if (category != null) {
      return categoryIconWidget(context, category);
    }
    return StreamBuilder<TransactionCategory>(
      stream: database.getCategory(categoryPk).$1,
      builder: (context, snapshot) {
        return categoryIconWidget(context, snapshot.data);
      },
    );
  }
}
