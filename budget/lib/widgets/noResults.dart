import 'package:budget/colors.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';

class NoResults extends StatelessWidget {
  const NoResults({
    Key? key,
    required this.message,
    this.tintColor,
    this.padding,
    this.noSearchResultsVariation = false,
  }) : super(key: key);
  final String message;
  final Color? tintColor;
  final EdgeInsets? padding;
  final bool noSearchResultsVariation;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding ??
            EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.4 > 400 ? 100 : 35,
              right: 30,
              left: 30,
            ),
        child: Column(
          children: [
            Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.height <=
                          MediaQuery.of(context).size.width
                      ? MediaQuery.of(context).size.height * 0.4 > 400
                          ? 400
                          : MediaQuery.of(context).size.height * 0.4
                      : 270),
              child: appStateSettings["materialYou"]
                  ? ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        !appStateSettings["materialYou"]
                            ? getColor(context, "black").withOpacity(0.1)
                            : tintColor == null
                                ? Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.7)
                                : tintColor!.withOpacity(0.7),
                        BlendMode.srcATop,
                      ),
                      child: ColorFiltered(
                        colorFilter: greyScale,
                        child: Opacity(
                          opacity: 1,
                          child: Image(
                            image: noSearchResultsVariation
                                ? AssetImage(
                                    "assets/images/no-search-filter.png")
                                : AssetImage("assets/images/empty-filter.png"),
                          ),
                        ),
                      ),
                    )
                  : Image(
                      image: noSearchResultsVariation
                          ? AssetImage("assets/images/no-search.png")
                          : AssetImage("assets/images/empty.png"),
                    ),
            ),
            SizedBox(height: 30),
            TextFont(
              maxLines: 4,
              fontSize: 15,
              text: message,
              textAlign: TextAlign.center,
              textColor: getColor(context, "textLight"),
            ),
            // Lottie.asset('assets/animations/search-animation.json'),
          ],
        ),
      ),
    );
  }
}
