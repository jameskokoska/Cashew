import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/pages/addWalletPage.dart';
import 'package:budget/pages/editHomePage.dart';
import 'package:budget/pages/homePage/homePageWalletSwitcher.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/util/keepAliveClientMixin.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/walletEntry.dart';
import 'package:flutter/material.dart';

class HomePageWalletList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return KeepAliveClientMixin(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 13, left: 13, right: 13),
        child: Container(
          decoration: BoxDecoration(
            color: getColor(context, "lightDarkAccentHeavyLight"),
            boxShadow: boxShadowCheck(boxShadowGeneral(context)),
            borderRadius: BorderRadius.circular(15),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: StreamBuilder<List<WalletWithDetails>>(
              stream: database.watchAllWalletsWithDetails(
                  homePageWidgetDisplay: HomePageWidgetDisplay.WalletList),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      if (snapshot.hasData && snapshot.data!.length > 0)
                        SizedBox(height: 8),
                      for (WalletWithDetails walletDetails in snapshot.data!)
                        WalletEntryRow(
                          selected: appStateSettings["selectedWalletPk"] ==
                              walletDetails.wallet.walletPk,
                          walletWithDetails: walletDetails,
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
