import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addWalletPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/globalSnackBar.dart';
import 'package:budget/widgets/noResults.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' hide TextInput;
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
  String searchValue = "";

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      database.fixOrderWallets();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (searchValue != "") {
          setState(() {
            searchValue = "";
          });
          return false;
        } else {
          return true;
        }
      },
      child: PageFramework(
        horizontalPadding: getHorizontalPaddingConstrained(context),
        dragDownToDismiss: true,
        dragDownToDismissEnabled: dragDownToDismissEnabled,
        title: widget.title,
        navbar: false,
        floatingActionButton: AnimateFABDelayed(
          fab: Padding(
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TextInput(
                labelText: "Search wallets...",
                icon: Icons.search_rounded,
                onSubmitted: (value) {
                  setState(() {
                    searchValue = value;
                  });
                },
                onChanged: (value) {
                  setState(() {
                    searchValue = value;
                  });
                },
                autoFocus: false,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SettingsContainerSwitch(
              title: "Show Wallet Switcher",
              description: "At the top of the home page",
              onSwitched: (value) {
                updateSettings("showWalletSwitcher", value,
                    pagesNeedingRefresh: [0], updateGlobalState: false);
              },
              initialValue: appStateSettings["showWalletSwitcher"],
              icon: Icons.account_balance_wallet_rounded,
            ),
          ),
          StreamBuilder<List<TransactionWallet>>(
            stream: database.watchAllWallets(
                searchFor: searchValue == "" ? null : searchValue),
            builder: (context, snapshot) {
              if (snapshot.hasData && (snapshot.data ?? []).length <= 0) {
                return SliverToBoxAdapter(
                  child: NoResults(
                    message: "No wallets found.",
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
                            defaultColor:
                                Theme.of(context).colorScheme.primary),
                        amountLight: 0.55,
                        amountDark: 0.35);
                    return EditRowEntry(
                      canDelete: (wallet.walletPk != 0),
                      canReorder: searchValue == "" &&
                          (snapshot.data ?? []).length != 1,
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
                          StreamBuilder<double?>(
                            stream:
                                database.watchTotalOfWallet(wallet.walletPk),
                            builder: (context, snapshot) {
                              return TextFont(
                                textAlign: TextAlign.left,
                                text: convertToMoney(snapshot.data ?? 0 * -1)
                                    .toString(),
                                fontSize: 15,
                              );
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
                                      pluralString(snapshot.data![0] == 1,
                                          " transaction"),
                                  fontSize: 14,
                                  textColor: getColor(context, "black")!
                                      .withOpacity(0.65),
                                );
                              } else {
                                return TextFont(
                                    textAlign: TextAlign.left,
                                    text: "/ transactions",
                                    fontSize: 14,
                                    textColor: getColor(context, "black")!
                                        .withOpacity(0.65));
                              }
                            },
                          ),
                        ],
                      ),
                      onDelete: () {
                        deleteWalletPopup(context, wallet);
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
          SliverToBoxAdapter(
            child: SizedBox(height: 85),
          ),
        ],
      ),
    );
  }
}

void deleteWalletPopup(context, TransactionWallet wallet,
    {Function? afterDelete}) {
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
    onSubmit: () async {
      database.deleteWallet(wallet.walletPk, wallet.order);
      database.deleteWalletsTransactions(wallet.walletPk);

      // If we delete the selected wallet, set it back to the default
      if (appStateSettings["selectedWallet"] == wallet.walletPk) {
        updateSettings("selectedWallet", 0,
            updateGlobalState: true, pagesNeedingRefresh: [0, 1, 2, 3]);
        TransactionWallet defaultWallet = await database.getWalletInstance(0);
        updateSettings("selectedWalletCurrency", defaultWallet.currency,
            updateGlobalState: true, pagesNeedingRefresh: [0, 1, 2, 3]);
      }
      Navigator.pop(context);
      openSnackbar(
        SnackbarMessage(title: "Deleted " + wallet.name, icon: Icons.delete),
      );
      if (afterDelete != null) afterDelete();
    },
    onSubmitLabel: "Delete",
  );
}
