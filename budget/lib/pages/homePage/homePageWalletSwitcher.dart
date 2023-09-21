import 'package:budget/database/tables.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/pages/addWalletPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/keepAliveClientMixin.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/walletEntry.dart';
import 'package:flutter/material.dart';

class HomePageWalletSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (appStateSettings["showWalletSwitcher"] == false &&
        enableDoubleColumn(context) == false) return SizedBox.shrink();

    return KeepAliveClientMixin(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 13.0),
        child: StreamBuilder<List<TransactionWallet>>(
          stream: database.watchAllWallets(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (TransactionWallet wallet in snapshot.data!)
                      WalletEntry(
                        selected: appStateSettings["selectedWalletPk"] ==
                            wallet.walletPk,
                        wallet: wallet,
                      ),
                    Stack(
                      children: [
                        snapshot.data!.length <= 0
                            ? SizedBox.shrink()
                            : SizedBox(
                                width: 130,
                                child: IgnorePointer(
                                  child: Visibility(
                                    maintainSize: true,
                                    maintainAnimation: true,
                                    maintainState: true,
                                    child: Opacity(
                                      opacity: 0,
                                      child: WalletEntry(
                                        selected: false,
                                        wallet: snapshot
                                            .data![snapshot.data!.length - 1],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 6, right: 6),
                            child: AddButton(
                              onTap: () {},
                              openPage: AddWalletPage(
                                routesToPopAfterDelete:
                                    RoutesToPopAfterDelete.None,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                clipBehavior: Clip.none,
                padding: EdgeInsets.symmetric(horizontal: 7),
              );
            }
            return Container();
          },
        ),
      ),
    );
  }
}
