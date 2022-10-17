import 'dart:developer';

import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addWalletPage.dart';
import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/globalSnackBar.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:budget/widgets/editRowEntry.dart';

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
  bool dragDownToDismissEnabled = true;
  int currentReorder = -1;
  @override
  Widget build(BuildContext context) {
    return PageFramework(
      dragDownToDismiss: true,
      dragDownToDismissEnabled: dragDownToDismissEnabled,
      title: widget.title,
      navbar: false,
      floatingActionButton: AnimatedScaleDelayed(
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomPaddingSafeArea),
          child: FAB(
            tooltip: "Add Wallet",
            openPage: AddWalletPage(
              title: "Add Wallet",
            ),
          ),
        ),
      ),
      slivers: [
        StreamBuilder<List<TransactionWallet>>(
          stream: database.watchAllWallets(),
          builder: (context, snapshot) {
            if (snapshot.hasData && (snapshot.data ?? []).length <= 0) {
              return SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 85, right: 15, left: 15),
                    child: TextFont(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        text: "No wallets created."),
                  ),
                ),
              );
            }
            if (snapshot.hasData && (snapshot.data ?? []).length > 0) {
              return SliverReorderableList(
                onReorderStart: (index) {
                  HapticFeedback.heavyImpact();
                  setState(() {
                    dragDownToDismissEnabled = false;
                    currentReorder = index;
                  });
                },
                onReorderEnd: (_) {
                  setState(() {
                    dragDownToDismissEnabled = true;
                    currentReorder = -1;
                  });
                },
                itemBuilder: (context, index) {
                  TransactionWallet wallet = snapshot.data![index];
                  Color backgroundColor = dynamicPastel(
                      context,
                      HexColor(wallet.colour,
                          defaultColor: Theme.of(context).colorScheme.primary),
                      amountLight: 0.55,
                      amountDark: 0.35);
                  return EditRowEntry(
                    canReorder: (snapshot.data ?? []).length != 1,
                    currentReorder:
                        currentReorder != -1 && currentReorder != index,
                    index: index,
                    backgroundColor: backgroundColor,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFont(
                          text: wallet.name,
                          fontWeight: FontWeight.bold,
                          fontSize: 21,
                        ),
                        Container(height: 2),
                        StreamBuilder<List<double?>>(
                          stream: database.watchTotalOfWallet(wallet.walletPk),
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data != null) {
                              return TextFont(
                                textAlign: TextAlign.left,
                                text:
                                    convertToMoney(snapshot.data![0] ?? 0 * -1)
                                        .toString(),
                                fontSize: 15,
                              );
                            } else {
                              return TextFont(
                                textAlign: TextAlign.left,
                                text: "/",
                                fontSize: 15,
                              );
                            }
                          },
                        ),
                        StreamBuilder<List<int?>>(
                          stream:
                              database.watchTotalCountOfTransactionsInWallet(
                                  wallet.walletPk),
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data != null) {
                              return TextFont(
                                textAlign: TextAlign.left,
                                text: snapshot.data![0].toString() +
                                    pluralString(
                                        snapshot.data![0] == 1, " transaction"),
                                fontSize: 14,
                                textColor: Theme.of(context)
                                    .colorScheme
                                    .black
                                    .withOpacity(0.65),
                              );
                            } else {
                              return TextFont(
                                  textAlign: TextAlign.left,
                                  text: "/ transactions",
                                  fontSize: 14,
                                  textColor: Theme.of(context)
                                      .colorScheme
                                      .black
                                      .withOpacity(0.65));
                            }
                          },
                        ),
                      ],
                    ),
                    onDelete: () {
                      openPopup(
                        context,
                        title: "Delete " + wallet.name + " wallet?",
                        description:
                            "This will delete all transactions associated with this wallet.",
                        icon: Icons.delete_rounded,
                        onCancel: () {
                          Navigator.pop(context);
                        },
                        onCancelLabel: "Cancel",
                        onSubmit: () {
                          database.deleteWallet(wallet.walletPk, wallet.order);
                          database.deleteWalletsTransactions(wallet.walletPk);
                          Navigator.pop(context);
                          openSnackbar(
                            SnackbarMessage(
                                title: "Deleted " + wallet.name,
                                icon: Icons.delete),
                          );
                        },
                        onSubmitLabel: "Delete",
                      );
                    },
                    openPage: AddWalletPage(
                      title: "Edit Wallet",
                      wallet: wallet,
                    ),
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
