import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addWalletPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/globalSnackBar.dart';
import 'package:budget/widgets/noResults.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/walletEntry.dart';
import 'package:budget/widgets/selectChips.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' hide SliverReorderableList;
import 'package:flutter/services.dart' hide TextInput;
import 'package:budget/widgets/editRowEntry.dart';
import 'package:budget/modified/reorderable_list.dart';
import 'package:provider/provider.dart';

class EditWalletsPage extends StatefulWidget {
  EditWalletsPage({
    Key? key,
  }) : super(key: key);

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
        title: "edit-wallets".tr(),
        floatingActionButton: AnimateFABDelayed(
          fab: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewPadding.bottom),
            child: FAB(
              tooltip: "add-wallet".tr(),
              openPage: AddWalletPage(),
            ),
          ),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TextInput(
                labelText: "search-wallets-placeholder".tr(),
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
                    Color accentColor = dynamicPastel(
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
                      accentColor: accentColor,
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
                            stream: database.watchTotalOfWallet(wallet.walletPk,
                                allWallets: Provider.of<AllWallets>(context)),
                            builder: (context, snapshot) {
                              return TextFont(
                                textAlign: TextAlign.left,
                                text: convertToMoney(
                                        Provider.of<AllWallets>(context),
                                        snapshot.data ?? 0 * -1)
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
                                      " " +
                                      (snapshot.data![0] == 1
                                          ? "transaction".tr().toLowerCase()
                                          : "transactions".tr().toLowerCase()),
                                  fontSize: 14,
                                  textColor: getColor(context, "black")
                                      .withOpacity(0.65),
                                );
                              } else {
                                return TextFont(
                                    textAlign: TextAlign.left,
                                    text: "/ transactions",
                                    fontSize: 14,
                                    textColor: getColor(context, "black")
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
                    return true;
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
    onCancelLabel: "cancel".tr(),
    onExtraLabel2: "Move Transactions To Another Wallet and Delete",
    onExtra2: () async {
      Navigator.pop(context);
      var result = await openPopupCustom(
        context,
        title: "Select Wallet",
        child: StreamBuilder<List<TransactionWallet>>(
          stream: database.watchAllWallets(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<TransactionWallet> walletsWithoutOneDeleted = snapshot.data!;
              walletsWithoutOneDeleted.removeWhere(
                  (TransactionWallet w) => w.walletPk == wallet.walletPk);
              return SelectChips(
                wrapped: true,
                items: walletsWithoutOneDeleted,
                getLabel: (TransactionWallet item) {
                  return item.name;
                },
                onLongPress: (TransactionWallet? item) {
                  pushRoute(
                    context,
                    AddWalletPage(
                      wallet: item,
                    ),
                  );
                },
                onSelected: (TransactionWallet item) {
                  Navigator.pop(context, item.walletPk);
                },
                getSelected: (TransactionWallet item) {
                  return false;
                },
                getCustomBorderColor: (TransactionWallet item) {
                  return dynamicPastel(
                    context,
                    lightenPastel(
                      HexColor(
                        item.colour,
                        defaultColor: Colors.transparent,
                      ),
                      amount: 0.3,
                    ),
                    amount: 0.4,
                  );
                },
              );
            } else {
              return SizedBox.shrink();
            }
          },
        ),
      );
      if (isNumber(result)) {
        await database.moveWalletTransactons(
            Provider.of<AllWallets>(context, listen: false),
            wallet.walletPk,
            int.parse(result.toString()));
        if (appStateSettings["selectedWallet"] == wallet.walletPk) {
          setPrimaryWallet(0);
        }
        database.deleteWallet(wallet.walletPk, wallet.order);
        Navigator.pop(context);
        openSnackbar(
          SnackbarMessage(title: "Deleted " + wallet.name, icon: Icons.delete),
        );
        if (afterDelete != null) afterDelete();
      } else {}
    },
    onSubmit: () async {
      await database.deleteWalletsTransactions(wallet.walletPk);
      // If we delete the selected wallet, set it back to the default
      if (appStateSettings["selectedWallet"] == wallet.walletPk) {
        setPrimaryWallet(0);
      }
      database.deleteWallet(wallet.walletPk, wallet.order);
      Navigator.pop(context);
      openSnackbar(
        SnackbarMessage(title: "Deleted " + wallet.name, icon: Icons.delete),
      );
      if (afterDelete != null) afterDelete();
    },
    onSubmitLabel: "delete".tr(),
  );
}
