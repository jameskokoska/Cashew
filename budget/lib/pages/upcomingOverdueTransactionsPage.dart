import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/subscriptionsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/initializeNotifications.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/struct/upcomingTransactionsFunctions.dart';
import 'package:budget/widgets/animatedExpanded.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/dropdownSelect.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/noResults.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/selectedTransactionsAppBar.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/slidingSelectorIncomeExpense.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry/transactionEntry.dart';
import 'package:budget/widgets/transactionEntry/transactionEntryAmount.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:implicitly_animated_reorderable_list/transitions.dart';
import 'package:provider/provider.dart';
import 'package:budget/widgets/countNumber.dart';
import 'package:budget/widgets/textInput.dart';

import '../widgets/transactionEntry/incomeAmountArrow.dart';

class UpcomingOverdueTransactions extends StatefulWidget {
  const UpcomingOverdueTransactions(
      {required this.overdueTransactions, super.key});
  final bool? overdueTransactions;

  @override
  State<UpcomingOverdueTransactions> createState() =>
      UpcomingOverdueTransactionsState();
}

class UpcomingOverdueTransactionsState
    extends State<UpcomingOverdueTransactions> {
  late bool? overdueTransactions = widget.overdueTransactions;
  String? searchValue;
  FocusNode _searchFocusNode = FocusNode();
  GlobalKey<PageFrameworkState> pageState = GlobalKey();

  void scrollToTop() {
    pageState.currentState?.scrollToTop();
  }

  @override
  Widget build(BuildContext context) {
    String pageId = "OverdueUpcoming";
    return WillPopScope(
      onWillPop: () async {
        if ((globalSelectedID.value[pageId] ?? []).length > 0) {
          globalSelectedID.value[pageId] = [];
          globalSelectedID.notifyListeners();
          return false;
        } else {
          return true;
        }
      },
      child: Stack(
        children: [
          PageFramework(
            key: pageState,
            resizeToAvoidBottomInset: true,
            floatingActionButton: AnimateFABDelayed(
              enabled: overdueTransactions == null,
              fab: AnimateFABDelayed(
                fab: AddFAB(
                  tooltip: "add-upcoming".tr(),
                  openPage: AddTransactionPage(
                    selectedType: TransactionSpecialType.upcoming,
                    routesToPopAfterDelete: RoutesToPopAfterDelete.None,
                  ),
                ),
              ),
            ),
            listID: pageId,
            title: "scheduled".tr(),
            dragDownToDismiss: true,
            actions: [
              CustomPopupMenuButton(
                showButtons: enableDoubleColumn(context),
                keepOutFirst: true,
                items: [
                  DropdownItemMenu(
                    id: "settings",
                    label: "settings".tr(),
                    icon: appStateSettings["outlinedIcons"]
                        ? Icons.settings_outlined
                        : Icons.settings_rounded,
                    action: () {
                      openBottomSheet(
                          context,
                          PopupFramework(
                            hasPadding: false,
                            child: UpcomingOverdueSettings(),
                          ));
                    },
                  ),
                ],
              ),
            ],
            slivers: [
              SliverToBoxAdapter(
                  child: CenteredAmountAndNumTransactions(
                totalWithCountStream:
                    database.watchTotalWithCountOfUpcomingOverdue(
                  allWallets: Provider.of<AllWallets>(context),
                  isOverdueTransactions: overdueTransactions,
                  searchString: searchValue,
                ),
                textColor: overdueTransactions == null
                    ? getColor(context, "black")
                    : overdueTransactions == true
                        ? getColor(context, "unPaidOverdue")
                        : getColor(context, "unPaidUpcoming"),
              )),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: getHorizontalPaddingConstrained(context)),
                  child: Row(
                    children: [
                      SizedBox(width: 13),
                      Flexible(
                        child: AnimatedSize(
                          clipBehavior: Clip.none,
                          duration: Duration(milliseconds: 500),
                          child: SlidingSelectorIncomeExpense(
                            useHorizontalPaddingConstrained: false,
                            initialIndex: overdueTransactions == null
                                ? 0
                                : overdueTransactions == false
                                    ? 1
                                    : 2,
                            onSelected: (int index) {
                              if (index == 1)
                                overdueTransactions = null;
                              else if (index == 2)
                                overdueTransactions = false;
                              else if (index == 3) overdueTransactions = true;
                              setState(() {});
                            },
                            options: ["all", "upcoming", "overdue"],
                            customPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      AnimatedSizeSwitcher(
                        child: searchValue == null
                            ? Padding(
                                padding: const EdgeInsets.only(left: 7.0),
                                child: ButtonIcon(
                                  key: ValueKey(1),
                                  onTap: () {
                                    setState(() {
                                      searchValue = "";
                                    });
                                    _searchFocusNode.requestFocus();
                                  },
                                  icon: appStateSettings["outlinedIcons"]
                                      ? Icons.search_outlined
                                      : Icons.search_rounded,
                                ),
                              )
                            : Container(
                                key: ValueKey(2),
                              ),
                      ),
                      SizedBox(width: 13),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: getHorizontalPaddingConstrained(context)),
                  child: AnimatedExpanded(
                    expand: searchValue != null,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 4.0, top: 8),
                      child: TextInput(
                        labelText: "search-transactions-placeholder".tr(),
                        icon: appStateSettings["outlinedIcons"]
                            ? Icons.search_outlined
                            : Icons.search_rounded,
                        focusNode: _searchFocusNode,
                        onSubmitted: (value) {
                          setState(() {
                            searchValue = value == "" ? null : value;
                          });
                        },
                        onChanged: (value) {
                          setState(() {
                            searchValue = value == "" ? null : value;
                          });
                        },
                        autoFocus: false,
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: 15),
              ),
              StreamBuilder<List<Transaction>>(
                stream: database.watchAllOverdueUpcomingTransactions(
                    overdueTransactions,
                    searchString: searchValue),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.length <= 0) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child:
                              NoResults(message: "no-transactions-found".tr()),
                        ),
                      );
                    }
                    return SliverImplicitlyAnimatedList<Transaction>(
                      items: snapshot.data!,
                      areItemsTheSame: (a, b) =>
                          a.transactionPk == b.transactionPk,
                      insertDuration: Duration(milliseconds: 500),
                      removeDuration: Duration(milliseconds: 500),
                      updateDuration: Duration(milliseconds: 500),
                      itemBuilder: (BuildContext context,
                          Animation<double> animation,
                          Transaction item,
                          int index) {
                        return SizeFadeTransition(
                          sizeFraction: 0.7,
                          curve: Curves.easeInOut,
                          animation: animation,
                          child: Column(
                            key: ValueKey(item.transactionPk),
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              UpcomingTransactionDateHeader(transaction: item),
                              TransactionEntry(
                                openPage: AddTransactionPage(
                                  transaction: item,
                                  routesToPopAfterDelete:
                                      RoutesToPopAfterDelete.One,
                                ),
                                transaction: item,
                                listID: pageId,
                              ),
                              SizedBox(height: 12),
                            ],
                          ),
                        );
                      },
                    );
                  } else {
                    return SliverToBoxAdapter();
                  }
                },
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: 75),
              ),
            ],
          ),
          SelectedTransactionsAppBar(
            pageID: pageId,
          ),
        ],
      ),
    );
  }
}

class DoubleTotalWithCountStreamBuilder extends StatelessWidget {
  const DoubleTotalWithCountStreamBuilder({
    required this.totalWithCountStream,
    this.totalWithCountStream2,
    required this.builder,
    super.key,
  });

  final Stream<TotalWithCount?> totalWithCountStream;
  final Stream<TotalWithCount?>? totalWithCountStream2;
  final Widget Function(BuildContext, AsyncSnapshot<TotalWithCount?>) builder;

  @override
  Widget build(BuildContext context) {
    if (totalWithCountStream2 != null) {
      return StreamBuilder<TotalWithCount?>(
        stream: totalWithCountStream,
        builder: (context, snapshot1) {
          return StreamBuilder<TotalWithCount?>(
            stream: totalWithCountStream2,
            builder: (context, snapshot2) {
              final total1 = snapshot1.data;
              final total2 = snapshot2.data;
              return builder(
                context,
                AsyncSnapshot<TotalWithCount>.withData(
                  ConnectionState.done,
                  TotalWithCount(
                    total: (total1?.total ?? 0) + (total2?.total ?? 0),
                    count: (total1?.count ?? 0) + (total2?.count ?? 0),
                  ),
                ),
              );
            },
          );
        },
      );
    }
    return StreamBuilder<TotalWithCount?>(
      stream: totalWithCountStream,
      builder: builder,
    );
  }
}

class CenteredAmountAndNumTransactions extends StatelessWidget {
  const CenteredAmountAndNumTransactions({
    required this.totalWithCountStream,
    this.totalWithCountStream2,
    required this.textColor,
    this.getTextColor,
    this.getInitialText,
    this.showIncomeArrow = true,
    super.key,
  });

  final Stream<TotalWithCount?> totalWithCountStream;
  final Stream<TotalWithCount?>? totalWithCountStream2;
  final Color textColor;
  final String? Function(double totalAmount)? getInitialText;
  final Color? Function(double totalAmount)? getTextColor;
  final bool showIncomeArrow;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 10),
        DoubleTotalWithCountStreamBuilder(
          totalWithCountStream: totalWithCountStream,
          totalWithCountStream2: totalWithCountStream2,
          builder: (context, snapshot) {
            double totalSpent = snapshot.data?.total ?? 0;
            int totalCount = snapshot.data?.count ?? 0;
            return Column(
              children: [
                AnimatedSizeSwitcher(
                  child: getInitialText != null &&
                          getInitialText!(totalSpent) != null
                      ? TextFont(
                          key: ValueKey(getInitialText!(totalSpent) ?? ""),
                          text: getInitialText!(totalSpent) ?? "",
                          fontSize: 16,
                          textColor: getColor(context, "textLight"),
                        )
                      : Container(
                          key: ValueKey(2),
                        ),
                ),
                Tappable(
                  color: Colors.transparent,
                  borderRadius: 15,
                  onLongPress: () {
                    copyToClipboard(
                      convertToMoney(
                        Provider.of<AllWallets>(context, listen: false),
                        totalSpent.abs(),
                        finalNumber: totalSpent,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        showIncomeArrow
                            ? AnimatedSizeSwitcher(
                                child: totalSpent == 0
                                    ? Container(
                                        key: ValueKey(1),
                                      )
                                    : IncomeOutcomeArrow(
                                        key: ValueKey(2),
                                        color: textColor,
                                        isIncome: totalSpent > 0,
                                        iconSize: 30,
                                        width: 20,
                                      ),
                              )
                            : SizedBox.shrink(),
                        CountNumber(
                          count: totalSpent.abs(),
                          duration: Duration(milliseconds: 450),
                          initialCount: (0),
                          textBuilder: (number) {
                            return TextFont(
                              text: convertToMoney(
                                  Provider.of<AllWallets>(context), number,
                                  finalNumber: totalSpent.abs()),
                              fontSize: 30,
                              textColor: getTextColor != null
                                  ? (getTextColor!(totalSpent) ?? textColor)
                                  : textColor,
                              fontWeight: FontWeight.bold,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                TextFont(
                  text: totalCount.toString() +
                      " " +
                      (totalCount == 1
                          ? "transaction".tr().toLowerCase()
                          : "transactions".tr().toLowerCase()),
                  fontSize: 16,
                  textColor: getColor(context, "textLight"),
                ),
              ],
            );
          },
        ),
        SizedBox(height: 20),
      ],
    );
  }
}

class AutoPayUpcomingSetting extends StatelessWidget {
  const AutoPayUpcomingSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsContainerSwitch(
      title: "pay-upcoming".tr(),
      description: "pay-upcoming-description".tr(),
      onSwitched: (value) async {
        // Need to change setting first, otherwise the function would not run!
        await updateSettings("automaticallyPayUpcoming", value,
            updateGlobalState: false);
        await markUpcomingAsPaid();
        await setUpcomingNotifications(context);
      },
      initialValue: appStateSettings["automaticallyPayUpcoming"],
      icon: getTransactionTypeIcon(TransactionSpecialType.upcoming),
    );
  }
}

class AutoPayRepetitiveSetting extends StatelessWidget {
  const AutoPayRepetitiveSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsContainerSwitch(
      title: "pay-repetitive".tr(),
      description: "pay-repetitive-description".tr(),
      onSwitched: (value) async {
        // Need to change setting first, otherwise the function would not run!
        await updateSettings("automaticallyPayRepetitive", value,
            updateGlobalState: false);
        // Repetitive and subscriptions are handled by the same function
        await markSubscriptionsAsPaid(context);
        await setUpcomingNotifications(context);
      },
      initialValue: appStateSettings["automaticallyPayRepetitive"],
      icon: getTransactionTypeIcon(TransactionSpecialType.repetitive),
    );
  }
}

class MarkAsPaidOnDaySetting extends StatelessWidget {
  const MarkAsPaidOnDaySetting({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsContainerDropdown(
      title: "paid-date".tr(),
      icon: appStateSettings["outlinedIcons"]
          ? Icons.event_available_outlined
          : Icons.event_available_rounded,
      initial: appStateSettings["markAsPaidOnOriginalDay"].toString(),
      items: ["false", "true"],
      onChanged: (value) async {
        updateSettings(
            "markAsPaidOnOriginalDay", value == "true" ? true : false,
            updateGlobalState: false);
      },
      getLabel: (item) {
        if (item == "false") return "current-date".tr().capitalizeFirst;
        if (item == "true") return "transaction-date".tr().capitalizeFirst;
      },
    );
  }
}

class UpcomingOverdueSettings extends StatelessWidget {
  const UpcomingOverdueSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AutoPayUpcomingSetting(),
        AutoPayRepetitiveSetting(),
        AutoPaySubscriptionsSetting(),
        AutoPaySettingDescription(),
      ],
    );
  }
}

class AutoPaySettingDescription extends StatelessWidget {
  const AutoPaySettingDescription({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 13, bottom: 3, left: 25, right: 25),
      child: TextFont(
        text: "auto-pay-description".tr(),
        fontSize: 14,
        textColor: getColor(context, "textLight"),
        textAlign: TextAlign.center,
        maxLines: 5,
      ),
    );
  }
}
