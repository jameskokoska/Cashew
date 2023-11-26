import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/pages/editHomePage.dart';
import 'package:budget/pages/upcomingOverdueTransactionsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/periodCyclePicker.dart';
import 'package:budget/widgets/util/keepAliveClientMixin.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/transactionsAmountBox.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timer_builder/timer_builder.dart';

class HomePageUpcomingTransactions extends StatelessWidget {
  const HomePageUpcomingTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    return KeepAliveClientMixin(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 13, left: 13, right: 13),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Since the query uses DateTime.now()
            // We need to refresh every so often to get new data...
            // Is there a better way to do this? listen to database updates?
            TimerBuilder.periodic(Duration(seconds: 5), builder: (context) {
              return Expanded(
                child: TransactionsAmountBox(
                  openPage:
                      UpcomingOverdueTransactions(overdueTransactions: false),
                  label: "upcoming".tr(),
                  amountStream: database.watchTotalOfUpcomingOverdue(
                    Provider.of<AllWallets>(context),
                    false,
                    followCustomPeriodCycle: true,
                    cycleSettingsExtension: "OverdueUpcoming",
                  ),
                  textColor: getColor(context, "unPaidUpcoming"),
                  transactionsAmountStream:
                      database.watchCountOfUpcomingOverdue(
                    false,
                    followCustomPeriodCycle: true,
                    cycleSettingsExtension: "OverdueUpcoming",
                  ),
                  onLongPress: () async {
                    await openBottomSheet(
                      context,
                      PopupFramework(
                        title: "select-period".tr(),
                        child: PeriodCyclePicker(
                          cycleSettingsExtension: "OverdueUpcoming",
                        ),
                      ),
                    );
                    homePageStateKey.currentState?.refreshState();
                  },
                ),
              );
            }),
            SizedBox(width: 13),
            TimerBuilder.periodic(Duration(seconds: 5), builder: (context) {
              return Expanded(
                child: TransactionsAmountBox(
                  openPage:
                      UpcomingOverdueTransactions(overdueTransactions: true),
                  label: "overdue".tr(),
                  amountStream: database.watchTotalOfUpcomingOverdue(
                    Provider.of<AllWallets>(context),
                    true,
                    followCustomPeriodCycle: true,
                    cycleSettingsExtension: "OverdueUpcoming",
                  ),
                  textColor: getColor(context, "unPaidOverdue"),
                  transactionsAmountStream:
                      database.watchCountOfUpcomingOverdue(
                    true,
                    followCustomPeriodCycle: true,
                    cycleSettingsExtension: "OverdueUpcoming",
                  ),
                  onLongPress: () async {
                    await openBottomSheet(
                      context,
                      PopupFramework(
                        title: "select-period".tr(),
                        child: PeriodCyclePicker(
                          cycleSettingsExtension: "OverdueUpcoming",
                        ),
                      ),
                    );
                    homePageStateKey.currentState?.refreshState();
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
