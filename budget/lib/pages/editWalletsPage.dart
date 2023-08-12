import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addWalletPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/fab.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/globalSnackBar.dart';
import 'package:budget/widgets/noResults.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/radioItems.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/walletEntry.dart';
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
        scrollToTopButton: true,
        title: "edit-wallets".tr(),
        floatingActionButton: AnimateFABDelayed(
          fab: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewPadding.bottom),
            child: FAB(
              tooltip: "add-wallet".tr(),
              openPage: AddWalletPage(
                routesToPopAfterDelete: RoutesToPopAfterDelete.None,
              ),
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
                      extraIcon: appStateSettings["selectedWalletPk"] ==
                              wallet.walletPk
                          ? Icons.star_rounded
                          : Icons.star_outline,
                      onExtra: () async {
                        setPrimaryWallet(wallet.walletPk);
                      },
                      canDelete: (wallet.walletPk != "0"),
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
                                  snapshot.data ?? 0 * -1,
                                  currencyKey: wallet.currency,
                                  decimals: wallet.decimals,
                                  addCurrencyName: true,
                                ).toString(),
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
                        deleteWalletPopup(
                          context,
                          wallet: wallet,
                          routesToPopAfterDelete: RoutesToPopAfterDelete.None,
                        );
                      },
                      openPage: AddWalletPage(
                          wallet: wallet,
                          routesToPopAfterDelete: RoutesToPopAfterDelete.One),
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

void deleteWalletPopup(
  BuildContext context, {
  required TransactionWallet wallet,
  required RoutesToPopAfterDelete routesToPopAfterDelete,
}) async {
  DeletePopupAction? action = await openDeletePopup(
    context,
    title: "delete-wallet-question".tr(),
    subtitle: wallet.name,
    description: "delete-wallet-question-description".tr(),
  );
  if (action == DeletePopupAction.Delete) {
    int transactionsFromWalletLength =
        (await database.getAllTransactionsFromWallet(wallet.walletPk)).length;
    dynamic result = true;
    if (transactionsFromWalletLength > 0) {
      result = await openPopup(
        context,
        title: "delete-all-transactions-question".tr(),
        description: "delete-wallet-merge-warning".tr(),
        icon: Icons.warning_amber_rounded,
        onCancel: () {
          Navigator.pop(context, false);
        },
        onCancelLabel: "cancel".tr(),
        onSubmit: () async {
          Navigator.pop(context, true);
        },
        onExtra2: () {
          Navigator.pop(context, false);
          mergeWalletPopup(
            context,
            walletOriginal: wallet,
            routesToPopAfterDelete: routesToPopAfterDelete,
          );
        },
        onExtraLabel2: "move-transactions".tr(),
        onSubmitLabel: "delete".tr(),
      );
    }
    if (result == true) {
      if (routesToPopAfterDelete == RoutesToPopAfterDelete.All) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else if (routesToPopAfterDelete == RoutesToPopAfterDelete.One) {
        Navigator.of(context).pop();
      }
      openLoadingPopupTryCatch(() async {
        await database.deleteWallet(wallet.walletPk, wallet.order);
        openSnackbar(
          SnackbarMessage(
            title: "deleted-wallet".tr(),
            icon: Icons.delete,
            description: wallet.name,
          ),
        );
      });
    }
  }
}

void mergeWalletPopup(
  BuildContext context, {
  required TransactionWallet walletOriginal,
  required RoutesToPopAfterDelete routesToPopAfterDelete,
}) async {
  var result =
      await selectWalletPopup(context, removeWalletPk: walletOriginal.walletPk);
  if (result != null) {
    if (routesToPopAfterDelete == RoutesToPopAfterDelete.All) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (routesToPopAfterDelete == RoutesToPopAfterDelete.One) {
      Navigator.of(context).pop();
    }
    openLoadingPopupTryCatch(() async {
      await database.moveWalletTransactions(
        Provider.of<AllWallets>(context, listen: false),
        walletOriginal.walletPk,
        result.walletPk,
      );
      await database.deleteWallet(
          walletOriginal.walletPk, walletOriginal.order);
      openSnackbar(
        SnackbarMessage(
          title: "deleted-wallet".tr(),
          icon: Icons.delete,
          description: walletOriginal.name,
        ),
      );
    });
  }
}

Future<TransactionWallet?> selectWalletPopup(BuildContext context,
    {String? removeWalletPk}) async {
  dynamic wallet = await openBottomSheet(
    context,
    PopupFramework(
      title: "select-wallet".tr(),
      child: StreamBuilder<List<TransactionWallet>>(
        stream: database.watchAllWallets(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<TransactionWallet> walletsWithoutOneDeleted = snapshot.data!;
            if (removeWalletPk != null)
              walletsWithoutOneDeleted.removeWhere(
                  (TransactionWallet w) => w.walletPk == removeWalletPk);
            return RadioItems(
              items: walletsWithoutOneDeleted,
              colorFilter: (TransactionWallet? wallet) {
                if (wallet == null) return null;
                return dynamicPastel(
                  context,
                  lightenPastel(
                    HexColor(
                      wallet.colour,
                      defaultColor: Theme.of(context).colorScheme.primary,
                    ),
                    amount: 0.2,
                  ),
                  amount: 0.1,
                );
              },
              displayFilter: (TransactionWallet? wallet) {
                return (wallet?.name ?? "") +
                    " " +
                    "(" +
                    (wallet?.currency ?? "").allCaps +
                    ")";
              },
              initial: null,
              onChanged: (TransactionWallet? wallet) async {
                Navigator.of(context).pop(wallet);
              },
            );
          } else {
            return SizedBox.shrink();
          }
        },
      ),
    ),
  );

  if (wallet is TransactionWallet) return wallet;
  return null;
}
