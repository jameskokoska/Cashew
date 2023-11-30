import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/initializeNotifications.dart';
import 'package:budget/struct/upcomingTransactionsFunctions.dart';
import 'package:budget/widgets/dropdownSelect.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/selectedTransactionsAppBar.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/noResults.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry/transactionEntry.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../functions.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/countNumber.dart';

class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({Key? key}) : super(key: key);

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

enum SelectedSubscriptionsType {
  monthly,
  yearly,
  total,
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  SelectedSubscriptionsType selectedType = SelectedSubscriptionsType
      .values[appStateSettings["selectedSubscriptionType"]];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if ((globalSelectedID.value["Subscriptions"] ?? []).length > 0) {
          globalSelectedID.value["Subscriptions"] = [];
          globalSelectedID.notifyListeners();
          return false;
        } else {
          return true;
        }
      },
      child: Stack(
        children: [
          PageFramework(
            listID: "Subscriptions",
            floatingActionButton: AnimateFABDelayed(
              fab: FAB(
                tooltip: "add-subscription".tr(),
                openPage: AddTransactionPage(
                  selectedType: TransactionSpecialType.subscription,
                  routesToPopAfterDelete: RoutesToPopAfterDelete.None,
                ),
              ),
            ),
            dragDownToDismiss: true,
            title: "subscriptions".tr(),
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
                          child: SubscriptionSettings(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.only(top: 30, left: 20.0, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      StreamBuilder<List<Transaction>>(
                        stream: database.getAllSubscriptions().$1,
                        builder: (context, snapshot) {
                          double total = getTotalSubscriptions(
                              Provider.of<AllWallets>(context),
                              selectedType,
                              snapshot.data);
                          return CountNumber(
                            count: total.abs(),
                            duration: Duration(milliseconds: 700),
                            initialCount: (0),
                            textBuilder: (number) {
                              return TextFont(
                                textAlign: TextAlign.center,
                                text: convertToMoney(
                                  Provider.of<AllWallets>(context),
                                  number,
                                  finalNumber: total.abs(),
                                ),
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              );
                            },
                          );
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: TextFont(
                          text: selectedType == SelectedSubscriptionsType.yearly
                              ? "yearly-subscriptions".tr()
                              : selectedType ==
                                      SelectedSubscriptionsType.monthly
                                  ? "monthly-subscriptions".tr()
                                  : "total-subscriptions".tr(),
                          fontSize: 16,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 18.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedSwitcher(
                              duration: Duration(milliseconds: 250),
                              child: Button(
                                key: ValueKey(selectedType !=
                                    SelectedSubscriptionsType.monthly),
                                color: selectedType !=
                                        SelectedSubscriptionsType.monthly
                                    ? dynamicPastel(
                                        context,
                                        Theme.of(context)
                                            .colorScheme
                                            .secondaryContainer,
                                        amount: appStateSettings["materialYou"]
                                            ? 0.2
                                            : 0.7)
                                    : null,
                                textColor: selectedType !=
                                        SelectedSubscriptionsType.monthly
                                    ? getColor(context, "black")
                                        .withOpacity(0.5)
                                    : getColor(context, "black"),
                                label: "monthly".tr(),
                                onTap: () => setState(() {
                                  selectedType =
                                      SelectedSubscriptionsType.monthly;
                                  updateSettings("selectedSubscriptionType", 0,
                                      pagesNeedingRefresh: [],
                                      updateGlobalState: false);
                                }),
                                fontSize: 12,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 13),
                              ),
                            ),
                            SizedBox(width: 7),
                            AnimatedSwitcher(
                              duration: Duration(milliseconds: 250),
                              child: Button(
                                key: ValueKey(selectedType !=
                                    SelectedSubscriptionsType.yearly),
                                color: selectedType !=
                                        SelectedSubscriptionsType.yearly
                                    ? dynamicPastel(
                                        context,
                                        Theme.of(context)
                                            .colorScheme
                                            .secondaryContainer,
                                        amount: appStateSettings["materialYou"]
                                            ? 0.2
                                            : 0.7)
                                    : null,
                                textColor: selectedType !=
                                        SelectedSubscriptionsType.yearly
                                    ? getColor(context, "black")
                                        .withOpacity(0.5)
                                    : getColor(context, "black"),
                                label: "yearly".tr(),
                                onTap: () => setState(() {
                                  selectedType =
                                      SelectedSubscriptionsType.yearly;
                                  updateSettings("selectedSubscriptionType", 1,
                                      pagesNeedingRefresh: [],
                                      updateGlobalState: false);
                                }),
                                fontSize: 12,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 13),
                              ),
                            ),
                            SizedBox(width: 7),
                            AnimatedSwitcher(
                              duration: Duration(milliseconds: 250),
                              child: Button(
                                key: ValueKey(selectedType !=
                                    SelectedSubscriptionsType.total),
                                color: selectedType !=
                                        SelectedSubscriptionsType.total
                                    ? dynamicPastel(
                                        context,
                                        Theme.of(context)
                                            .colorScheme
                                            .secondaryContainer,
                                        amount: appStateSettings["materialYou"]
                                            ? 0.2
                                            : 0.7)
                                    : null,
                                textColor: selectedType !=
                                        SelectedSubscriptionsType.total
                                    ? getColor(context, "black")
                                        .withOpacity(0.5)
                                    : getColor(context, "black"),
                                label: "total".tr(),
                                onTap: () => setState(() {
                                  selectedType =
                                      SelectedSubscriptionsType.total;
                                  updateSettings("selectedSubscriptionType", 2,
                                      pagesNeedingRefresh: [],
                                      updateGlobalState: false);
                                }),
                                fontSize: 12,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: 45),
              ),
              StreamBuilder<List<Transaction>>(
                stream: database.getAllSubscriptions().$1,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.length <= 0) {
                      return SliverToBoxAdapter(
                          child: NoResults(
                              padding: const EdgeInsets.only(
                                top: 15,
                                right: 30,
                                left: 30,
                              ),
                              message: "No subscription transactions."));
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          Transaction transaction = snapshot.data![index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              UpcomingTransactionDateHeader(
                                transaction: transaction,
                              ),
                              TransactionEntry(
                                openPage: AddTransactionPage(
                                  transaction: transaction,
                                  routesToPopAfterDelete:
                                      RoutesToPopAfterDelete.One,
                                ),
                                transaction: transaction,
                                listID: "Subscriptions",
                              ),
                              SizedBox(height: 12),
                            ],
                          );
                        },
                        childCount: snapshot.data?.length,
                      ),
                    );
                  } else {
                    return SliverToBoxAdapter();
                  }
                },
              ),
              SliverToBoxAdapter(child: SizedBox(height: 55)),
            ],
          ),
          SelectedTransactionsAppBar(
            pageID: "Subscriptions",
          ),
        ],
      ),
    );
  }
}

class UpcomingTransactionDateHeader extends StatelessWidget {
  const UpcomingTransactionDateHeader(
      {Key? key,
      required this.transaction,
      this.small = false,
      this.useHorizontalPaddingConstrained = true})
      : super(key: key);

  final Transaction transaction;
  final bool small;
  final bool useHorizontalPaddingConstrained;

  @override
  Widget build(BuildContext context) {
    int daysDifference =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
            .difference(transaction.dateCreated)
            .inDays;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: useHorizontalPaddingConstrained
            ? getHorizontalPaddingConstrained(context)
            : 0,
      ),
      child: Padding(
        padding: EdgeInsets.only(
            left: (small ? 16 : 19), bottom: 3, right: (small ? 16 : 19)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                children: [
                  TextFont(
                    text: getWordedDateShortMore(transaction.dateCreated),
                    fontWeight: small ? FontWeight.normal : FontWeight.bold,
                    fontSize: small ? 14 : 18,
                    textColor: small ? getColor(context, "textLight") : null,
                  ),
                  Flexible(
                    child: daysDifference != 0
                        ? TextFont(
                            fontSize: small ? 14 : 16,
                            textColor: getColor(context, "textLight"),
                            text: " • " +
                                daysDifference.abs().toString() +
                                " " +
                                (daysDifference.abs() == 1
                                    ? "day".tr()
                                    : "days".tr()) +
                                (daysDifference > 0
                                    ? " " + "overdue".tr().toLowerCase()
                                    : ""),
                            fontWeight:
                                small ? FontWeight.normal : FontWeight.bold,
                          )
                        : SizedBox(),
                  ),
                ],
              ),
            ),
            transaction.type == TransactionSpecialType.repetitive ||
                    transaction.type == TransactionSpecialType.subscription
                ? Row(
                    children: [
                      Icon(
                        appStateSettings["outlinedIcons"]
                            ? Icons.loop_outlined
                            : Icons.loop_rounded,
                        color: dynamicPastel(
                            context, Theme.of(context).colorScheme.primary,
                            amount: 0.4),
                        size: small ? 12 : 16,
                      ),
                      SizedBox(width: 3),
                      TextFont(
                        text: transaction.periodLength.toString() +
                            " " +
                            (transaction.periodLength == 1
                                ? nameRecurrence[transaction.reoccurrence]
                                    .toString()
                                    .toLowerCase()
                                    .tr()
                                    .toLowerCase()
                                : namesRecurrence[transaction.reoccurrence]
                                    .toString()
                                    .toLowerCase()
                                    .tr()
                                    .toLowerCase()),
                        fontWeight: FontWeight.bold,
                        fontSize: small ? 14 : 18,
                        textColor: dynamicPastel(
                            context, Theme.of(context).colorScheme.primary,
                            amount: 0.4),
                      ),
                    ],
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}

class SubscriptionSettings extends StatelessWidget {
  const SubscriptionSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AutoPaySubscriptionsSetting(),
      ],
    );
  }
}

class AutoPaySubscriptionsSetting extends StatelessWidget {
  const AutoPaySubscriptionsSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsContainerSwitch(
      title: "pay-subscriptions".tr(),
      description: "pay-subscriptions-description".tr(),
      onSwitched: (value) async {
        // Need to change setting first, otherwise the function would not run!
        await updateSettings("automaticallyPaySubscriptions", value,
            updateGlobalState: false);
        await markSubscriptionsAsPaid(context);
        await setUpcomingNotifications(context);
      },
      initialValue: appStateSettings["automaticallyPaySubscriptions"],
      icon: getTransactionTypeIcon(TransactionSpecialType.subscription),
    );
  }
}
