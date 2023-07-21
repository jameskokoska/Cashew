import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/pages/upcomingOverdueTransactionsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/keepAliveClientMixin.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/transactionsAmountBox.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePageUpcomingTransactions extends StatelessWidget {
  const HomePageUpcomingTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    return !appStateSettings["showOverdueUpcoming"] &&
            enableDoubleColumn(context) == false
        ? SizedBox.shrink()
        : KeepAliveClientMixin(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 13, left: 13, right: 13),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: TransactionsAmountBox(
                      openPage: UpcomingOverdueTransactions(
                          overdueTransactions: false),
                      label: "upcoming".tr(),
                      amountStream: database.watchTotalOfUpcomingOverdue(
                        Provider.of<AllWallets>(context),
                        false,
                      ),
                      textColor: getColor(context, "unPaidUpcoming"),
                      transactionsAmountStream: database.watchCountOfUpcoming(),
                    ),
                  ),
                  SizedBox(width: 13),
                  Expanded(
                    child: TransactionsAmountBox(
                      openPage: UpcomingOverdueTransactions(
                          overdueTransactions: true),
                      label: "overdue".tr(),
                      amountStream: database.watchTotalOfUpcomingOverdue(
                        Provider.of<AllWallets>(context),
                        true,
                      ),
                      textColor: getColor(context, "unPaidOverdue"),
                      transactionsAmountStream: database.watchCountOfOverdue(),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
