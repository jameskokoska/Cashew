import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/pages/addWalletPage.dart';
import 'package:budget/pages/editHomePage.dart';
import 'package:budget/pages/homePage/homePageWalletSwitcher.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/keepAliveClientMixin.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/walletEntry.dart';
import 'package:flutter/material.dart';

class HomePageWalletList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (isHomeScreenSectionEnabled(context, "showWalletList") == false)
      return SizedBox.shrink();
    return KeepAliveClientMixin(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 13, left: 13, right: 13),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Container(
            decoration: BoxDecoration(
              color: getColor(context, "lightDarkAccentHeavyLight"),
              boxShadow: boxShadowCheck(boxShadowGeneral(context)),
            ),
            child: StreamBuilder<List<TransactionWallet>>(
              stream: database
                  .getAllPinnedWallets(HomePageWidgetDisplay.WalletList)
                  .$1,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      if (snapshot.hasData && snapshot.data!.length > 0)
                        SizedBox(height: 8),
                      for (TransactionWallet wallet in snapshot.data!)
                        WalletEntryRow(
                          selected: appStateSettings["selectedWalletPk"] ==
                              wallet.walletPk,
                          wallet: wallet,
                        ),
                      if (snapshot.hasData && snapshot.data!.length > 0)
                        SizedBox(height: 8),
                      if (snapshot.hasData && snapshot.data!.length <= 0)
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: AddButton(
                                onTap: () {
                                  openBottomSheet(
                                    context,
                                    EditHomePagePinnedWalletsPopup(
                                      homePageWidgetDisplay:
                                          HomePageWidgetDisplay.WalletList,
                                    ),
                                    useCustomController: true,
                                  );
                                },
                                height: 40,
                                // icon: Icons.format_list_bulleted_add,
                              ),
                            ),
                          ],
                        ),
                    ],
                  );
                }
                return Container();
              },
            ),
          ),
        ),
      ),
    );
  }
}
