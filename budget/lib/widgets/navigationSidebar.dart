import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/editCategoriesPage.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/accountAndBackup.dart';
import 'package:budget/widgets/moreIcons.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/util/showDatePicker.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:budget/colors.dart';
import 'package:timer_builder/timer_builder.dart';

// returns 0 if no navigation sidebar should be shown
double getWidthNavigationSidebar(context) {
  double screenPercent = 0.3;
  double maxWidthNavigation = 270;
  double minScreenWidth = 700;
  if (MediaQuery.of(context).size.width < minScreenWidth) return 0;
  return (MediaQuery.of(context).size.width * screenPercent > maxWidthNavigation
          ? maxWidthNavigation
          : MediaQuery.of(context).size.width * screenPercent) +
      MediaQuery.of(context).viewPadding.left;
}

bool enableDoubleColumn(context) {
  double minScreenWidth = 1000;
  return MediaQuery.of(context).size.width > minScreenWidth ? true : false;
}

class NavigationSidebar extends StatefulWidget {
  const NavigationSidebar({super.key});

  @override
  State<NavigationSidebar> createState() => NavigationSidebarState();
}

class NavigationSidebarState extends State<NavigationSidebar> {
  int selectedIndex = 0;

  void setSelectedIndex(index) {
    setState(() {
      selectedIndex = index;
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    double widthNavigationSidebar = getWidthNavigationSidebar(context);
    if (widthNavigationSidebar <= 0) {
      return SizedBox.shrink();
    }
    // print(selectedIndex);
    return Container(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: getColor(context, "lightDarkAccent"),
            width: 3,
          ),
        ),
        color: Theme.of(context).canvasColor,
      ),
      width: getWidthNavigationSidebar(context),
      child: Padding(
        padding: EdgeInsets.only(left: MediaQuery.of(context).viewPadding.left),
        child: IgnorePointer(
          ignoring: appStateSettings["hasOnboarded"] == false,
          child: AnimatedOpacity(
            duration: Duration(milliseconds: 500),
            opacity: appStateSettings["hasOnboarded"] == false ? 0.3 : 1,
            child: SingleChildScrollView(
              child: IntrinsicHeight(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 40),
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14),
                                  child: Tappable(
                                    borderRadius: 20,
                                    onTap: () async {
                                      await showCustomDatePicker(
                                          navigatorKey.currentContext!,
                                          DateTime.now());
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 30, bottom: 30),
                                      child: TimerBuilder.periodic(
                                        Duration(seconds: 5),
                                        builder: (context) {
                                          DateTime now = DateTime.now();
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              TextFont(
                                                textColor:
                                                    getColor(context, "black"),
                                                fontSize: 48,
                                                fontWeight: FontWeight.bold,
                                                text: DateFormat.jm(context
                                                        .locale
                                                        .toString())
                                                    .format(now)
                                                    .replaceAll("AM", "")
                                                    .replaceAll("PM", "")
                                                    .replaceAll(" ", ""),
                                              ),
                                              TextFont(
                                                textColor:
                                                    getColor(context, "black")
                                                        .withOpacity(0.5),
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                text: DateFormat(
                                                        'EEEE',
                                                        context.locale
                                                            .toString())
                                                    .format(now),
                                              ),
                                              SizedBox(height: 5),
                                              TextFont(
                                                textColor:
                                                    getColor(context, "black")
                                                        .withOpacity(0.5),
                                                fontSize: 18,
                                                text: DateFormat(
                                                        'MMMM d, y',
                                                        context.locale
                                                            .toString())
                                                    .format(now),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 30),
                          NavigationSidebarButton(
                            icon: Icons.home_rounded,
                            label: "home".tr(),
                            isSelected: selectedIndex == 0,
                            onTap: () {
                              pageNavigationFrameworkKey.currentState!
                                  .changePage(0, switchNavbar: true);
                            },
                          ),
                          NavigationSidebarButton(
                            icon: Icons.payments_rounded,
                            label: "transactions".tr(),
                            isSelected: selectedIndex == 1,
                            onTap: () {
                              pageNavigationFrameworkKey.currentState!
                                  .changePage(1, switchNavbar: true);
                            },
                          ),
                          NavigationSidebarButton(
                            icon: MoreIcons.chart_pie,
                            iconSize: 15,
                            label: "budgets".tr(),
                            isSelected: selectedIndex == 2,
                            onTap: () {
                              pageNavigationFrameworkKey.currentState!
                                  .changePage(2, switchNavbar: true);
                            },
                          ),
                          NavigationSidebarButton(
                            icon: Icons.event_repeat_rounded,
                            label: "subscriptions".tr(),
                            isSelected: selectedIndex == 5,
                            onTap: () {
                              pageNavigationFrameworkKey.currentState!
                                  .changePage(5, switchNavbar: true);
                            },
                          ),
                          kIsWeb
                              ? SizedBox.shrink()
                              : NavigationSidebarButton(
                                  icon: Icons.notifications_rounded,
                                  label: "notifications".tr(),
                                  isSelected: selectedIndex == 6,
                                  onTap: () {
                                    pageNavigationFrameworkKey.currentState!
                                        .changePage(6, switchNavbar: true);
                                  },
                                ),
                          NavigationSidebarButton(
                            icon: Icons.line_weight_rounded,
                            label: "all-spending".tr(),
                            isSelected: selectedIndex == 7,
                            onTap: () {
                              pageNavigationFrameworkKey.currentState!
                                  .changePage(7, switchNavbar: true);
                            },
                          ),
                          EditDataButtons(selectedIndex: selectedIndex),
                        ],
                      ),
                      Spacer(),
                      SizedBox(height: 40),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GoogleAccountLoginButton(
                            navigationSidebarButton: true,
                            onTap: () {
                              pageNavigationFrameworkKey.currentState!
                                  .changePage(8, switchNavbar: true);
                              appStateKey.currentState?.refreshAppState();
                            },
                            isButtonSelected: selectedIndex == 8,
                          ),
                          NavigationSidebarButton(
                            icon: Icons.settings_rounded,
                            label: "settings".tr(),
                            isSelected: selectedIndex == 4,
                            onTap: () {
                              pageNavigationFrameworkKey.currentState!
                                  .changePage(4, switchNavbar: true);
                            },
                          ),
                          NavigationSidebarButton(
                            icon: Icons.info_outline_rounded,
                            label: "about".tr(),
                            isSelected: selectedIndex == 13,
                            onTap: () {
                              pageNavigationFrameworkKey.currentState!
                                  .changePage(13, switchNavbar: true);
                            },
                          ),
                          AnimatedSize(
                            duration: Duration(milliseconds: 1500),
                            curve: Curves.easeInOutCubic,
                            child: AnimatedSwitcher(
                              duration: Duration(milliseconds: 300),
                              child: googleUser == null ||
                                      appStateSettings["backupSync"] == false
                                  ? Container(
                                      key: ValueKey(1),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      child: AnimatedSwitcher(
                                        duration: Duration(milliseconds: 500),
                                        child: Tappable(
                                          key: ValueKey(
                                              appStateSettings["lastSynced"]),
                                          onTap: () {
                                            runAllCloudFunctions(
                                              context,
                                              forceSignIn: true,
                                            );
                                          },
                                          borderRadius: 15,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        googleUser?.email !=
                                                                null
                                                            ? TextFont(
                                                                textColor: getColor(
                                                                    context,
                                                                    "textLight"),
                                                                fontSize: 13,
                                                                text: (googleUser
                                                                            ?.email ??
                                                                        "")
                                                                    .split(
                                                                        "@")[0],
                                                              )
                                                            : SizedBox.shrink(),
                                                        TimerBuilder.periodic(
                                                          Duration(seconds: 5),
                                                          builder: (context) {
                                                            DateTime?
                                                                timeLastSynced =
                                                                null;
                                                            try {
                                                              timeLastSynced =
                                                                  DateTime
                                                                      .parse(
                                                                appStateSettings[
                                                                    "lastSynced"],
                                                              );
                                                            } catch (e) {
                                                              print("Error parsing time last synced: " +
                                                                  e.toString());
                                                            }
                                                            return TextFont(
                                                              textColor: getColor(
                                                                  context,
                                                                  "textLight"),
                                                              fontSize: 13,
                                                              text: "Synced " +
                                                                  (timeLastSynced ==
                                                                          null
                                                                      ? "?"
                                                                      : getTimeAgo(
                                                                          timeLastSynced)),
                                                            );
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 2),
                                                Opacity(
                                                  opacity: 0.7,
                                                  child: RefreshButton(
                                                    padding: EdgeInsets.all(8),
                                                    onTap: () {
                                                      runAllCloudFunctions(
                                                          context);
                                                    },
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
                          SizedBox(height: 10),
                        ],
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

class NavigationSidebarButton extends StatelessWidget {
  const NavigationSidebarButton({
    super.key,
    required this.icon,
    this.iconSize = 30,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.trailing = const SizedBox.shrink(),
    this.popRoutes = true,
  });

  final IconData icon;
  final double iconSize;
  final String label;
  final bool isSelected;
  final Widget trailing;
  final Function() onTap;
  final bool popRoutes;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: Tappable(
          key: ValueKey(isSelected),
          borderRadius: 50,
          color: isSelected
              ? Theme.of(context).colorScheme.secondaryContainer
              : null,
          onTap: () {
            if (popRoutes) {
              // pop all routes without animation
              navigatorKey.currentState!.pushAndRemoveUntil(
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        SizedBox(),
                    transitionDuration: Duration(seconds: 0),
                  ),
                  (route) => route.isFirst);
              navigatorKey.currentState!.pop();
            }
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onSecondaryContainer
                      : Theme.of(context).colorScheme.secondary,
                ),
                SizedBox(width: 15),
                Expanded(
                  child: TextFont(
                    text: label.capitalizeFirst,
                    fontSize: 16,
                  ),
                ),
                trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EditDataButtons extends StatefulWidget {
  const EditDataButtons({super.key, required this.selectedIndex});
  final int selectedIndex;

  @override
  State<EditDataButtons> createState() => _EdiDatatButtonsState();
}

class _EdiDatatButtonsState extends State<EditDataButtons> {
  bool showEditDataButtons = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NavigationSidebarButton(
          icon: Icons.edit_document,
          label: "edit-data".tr(),
          isSelected: false,
          onTap: () {
            setState(() {
              showEditDataButtons = !showEditDataButtons;
            });
          },
          popRoutes: false,
          trailing: AnimatedRotation(
            duration: Duration(milliseconds: 600),
            curve: Curves.easeInOutCubicEmphasized,
            turns: showEditDataButtons ? 0 : -0.5,
            child: Icon(
              Icons.arrow_drop_up_rounded,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: AnimatedSize(
            duration: Duration(milliseconds: 400),
            curve: Curves.easeInOutCubicEmphasized,
            alignment: Alignment.topCenter,
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: !showEditDataButtons
                  ? Container(key: ValueKey(1))
                  : Column(
                      children: [
                        NavigationSidebarButton(
                          icon: Icons.account_balance_wallet_rounded,
                          label: "wallet-details".tr(),
                          isSelected: widget.selectedIndex == 9,
                          onTap: () {
                            pageNavigationFrameworkKey.currentState!
                                .changePage(9, switchNavbar: true);
                          },
                        ),
                        NavigationSidebarButton(
                          icon: MoreIcons.chart_pie,
                          label: "budgets-details".tr(),
                          isSelected: widget.selectedIndex == 10,
                          onTap: () {
                            pageNavigationFrameworkKey.currentState!
                                .changePage(10, switchNavbar: true);
                          },
                        ),
                        NavigationSidebarButton(
                          icon: Icons.category_rounded,
                          label: "categories-details".tr(),
                          isSelected: widget.selectedIndex == 11,
                          onTap: () {
                            pageNavigationFrameworkKey.currentState!
                                .changePage(11, switchNavbar: true);
                          },
                        ),
                        NavigationSidebarButton(
                          icon: Icons.text_fields_rounded,
                          label: "titles-details".tr(),
                          isSelected: widget.selectedIndex == 12,
                          onTap: () {
                            pageNavigationFrameworkKey.currentState!
                                .changePage(12, switchNavbar: true);
                          },
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
