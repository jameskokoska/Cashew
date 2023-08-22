import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/pages/creditDebtTransactionsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/keepAliveClientMixin.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/transactionsAmountBox.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePageCreditDebts extends StatelessWidget {
  const HomePageCreditDebts({super.key});

  @override
  Widget build(BuildContext context) {
    return !appStateSettings["showCreditDebt"] &&
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
                      label: "lent".tr(),
                      amountStream: database.watchTotalOfCreditDebt(
                        Provider.of<AllWallets>(context),
                        true,
                      ),
                      textColor: getColor(context, "unPaidUpcoming"),
                      transactionsAmountStream:
                          database.watchCountOfCreditDebt(true, null),
                      openPage: CreditDebtTransactions(isCredit: true),
                    ),
                  ),
                  SizedBox(width: 13),
                  Expanded(
                    child: TransactionsAmountBox(
                      label: "borrowed".tr(),
                      amountStream: database.watchTotalOfCreditDebt(
                        Provider.of<AllWallets>(context),
                        false,
                      ),
                      textColor: getColor(context, "unPaidOverdue"),
                      transactionsAmountStream:
                          database.watchCountOfCreditDebt(false, null),
                      openPage: CreditDebtTransactions(isCredit: false),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
