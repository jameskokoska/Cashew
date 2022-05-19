import 'dart:developer';

import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addWalletPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';

class EditWalletsPage extends StatefulWidget {
  EditWalletsPage({
    Key? key,
    required this.title,
  }) : super(key: key);
  final String title;

  @override
  _EditWalletsPageState createState() => _EditWalletsPageState();
}

class _EditWalletsPageState extends State<EditWalletsPage> {
  @override
  Widget build(BuildContext context) {
    return PageFramework(
      title: widget.title,
      navbar: false,
      floatingActionButton: AnimatedScaleDelayed(
        child: FAB(
          tooltip: "Add Wallet",
          openPage: AddWalletPage(
            title: "Add Wallet",
          ),
        ),
      ),
      slivers: [
        StreamBuilder<List<TransactionWallet>>(
          stream: database.watchAllWallets(),
          builder: (context, snapshot) {
            if (snapshot.hasData && (snapshot.data ?? []).length > 0) {
              return SliverReorderableList(
                itemBuilder: (context, index) {
                  return WalletRowEntry(
                    wallet: snapshot.data![index],
                    index: index,
                    key: ValueKey(index),
                  );
                },
                itemCount: snapshot.data!.length,
                onReorder: (_intPrevious, _intNew) async {
                  TransactionWallet oldWallet = snapshot.data![_intPrevious];

                  if (_intNew > _intPrevious) {
                    await database.moveWallet(
                        oldWallet.walletPk, _intNew - 1, oldWallet.order);
                  } else {
                    await database.moveWallet(
                        oldWallet.walletPk, _intNew, oldWallet.order);
                  }
                },
              );
            }
            return SliverToBoxAdapter(
              child: Container(),
            );
          },
        ),
      ],
    );
  }
}

class WalletRowEntry extends StatelessWidget {
  const WalletRowEntry({required this.index, required this.wallet, Key? key})
      : super(key: key);
  final int index;
  final TransactionWallet wallet;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: EdgeInsets.only(left: 20, right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: HexColor(wallet.colour),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextFont(text: wallet.name + " - " + wallet.order.toString()),
          Row(
            children: [
              Tappable(
                color: Colors.transparent,
                borderRadius: 50,
                child: Container(
                    width: 40, height: 50, child: Icon(Icons.delete_rounded)),
                onTap: () {
                  openPopup(
                    context,
                    description: "Delete " +
                        wallet.name +
                        "?\nThis will delete all transactions associated with this wallet.",
                    icon: Icons.delete_rounded,
                    onCancel: () {
                      Navigator.pop(context);
                    },
                    onCancelLabel: "Cancel",
                    onSubmit: () {
                      database.deleteWallet(wallet.walletPk);
                      database.deleteWalletsTransactions(wallet.walletPk);
                      Navigator.pop(context);
                      openSnackbar(context, "Deleted " + wallet.name);
                    },
                    onSubmitLabel: "Delete",
                  );
                },
              ),
              OpenContainerNavigation(
                closedColor: HexColor(wallet.colour),
                button: (openContainer) {
                  return Tappable(
                    color: Colors.transparent,
                    borderRadius: 50,
                    child: Container(
                        width: 40, height: 50, child: Icon(Icons.edit_rounded)),
                    onTap: () {
                      openContainer();
                    },
                  );
                },
                openPage: AddWalletPage(
                  title: "Edit " + wallet.name + " Wallet",
                  wallet: wallet,
                ),
              ),
              Material(
                color: Colors.transparent,
                child: ReorderableDragStartListener(
                  index: index,
                  child: Tappable(
                    color: Colors.transparent,
                    borderRadius: 50,
                    child: Container(
                        width: 40,
                        height: 50,
                        child: Icon(Icons.drag_handle_rounded)),
                    onTap: () {},
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
