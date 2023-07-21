import 'package:budget/colors.dart';
import 'package:budget/functions.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SlidingSelectorIncomeExpense extends StatelessWidget {
  const SlidingSelectorIncomeExpense({
    Key? key,
    required this.onSelected,
    this.alternateTheme = false,
    this.useHorizontalPaddingConstrained = true,
  }) : super(key: key);

  final Function(int) onSelected;
  final bool alternateTheme;
  final bool useHorizontalPaddingConstrained;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(boxShadow: boxShadowCheck(boxShadowGeneral(context))),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: useHorizontalPaddingConstrained == false
                ? 0
                : getHorizontalPaddingConstrained(context)),
        child: Padding(
          padding: alternateTheme
              ? const EdgeInsets.symmetric(horizontal: 20)
              : const EdgeInsets.symmetric(horizontal: 13),
          child: DefaultTabController(
            length: 3,
            child: SizedBox(
              height: alternateTheme ? 40 : 45,
              child: Material(
                borderRadius: BorderRadius.circular(15),
                color: getColor(context, "lightDarkAccentHeavyLight"),
                child: Theme(
                  data: ThemeData().copyWith(
                    splashColor: Theme.of(context).splashColor,
                  ),
                  child: TabBar(
                    splashFactory: Theme.of(context).splashFactory,
                    splashBorderRadius: BorderRadius.circular(15),
                    onTap: (value) {
                      onSelected(value + 1);
                    },
                    dividerColor: Colors.transparent,
                    indicatorColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      color: appStateSettings["materialYou"]
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.3)
                          : getColor(context, "black").withOpacity(0.15),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    labelColor: getColor(context, "black"),
                    unselectedLabelColor: getColor(context, "textLight"),
                    tabs: [
                      Tab(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Text(
                            "all".tr(),
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Avenir',
                            ),
                          ),
                        ),
                      ),
                      Tab(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Text(
                            "expense".tr(),
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Avenir',
                            ),
                          ),
                        ),
                      ),
                      Tab(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Text(
                            "income".tr(),
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Avenir',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
