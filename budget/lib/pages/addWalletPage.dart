import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addBudgetPage.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/categoryEntry.dart';
import 'package:budget/widgets/dropdownSelect.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/popupFramework.dart';
import 'package:budget/widgets/radioItems.dart';
import 'package:budget/widgets/selectAmount.dart';
import 'package:budget/widgets/selectCategory.dart';
import 'package:budget/widgets/selectColor.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/transactionEntry.dart';
import 'package:budget/struct/transactionCategory.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:budget/colors.dart';
import 'package:math_expressions/math_expressions.dart';

class AddWalletPage extends StatefulWidget {
  AddWalletPage({
    Key? key,
    required this.title,
    this.wallet,
  }) : super(key: key);
  final String title;

  //When a wallet is passed in, we are editing that wallet
  final TransactionWallet? wallet;

  @override
  _AddWalletPageState createState() => _AddWalletPageState();
}

class _AddWalletPageState extends State<AddWalletPage> {
  bool? canAddWallet;

  String? selectedTitle;
  Color? selectedColor;

  late FocusNode _periodLengthFocusNode;

  String? textAddWallet = "Add Wallet";

  Future<void> selectColor(BuildContext context) async {
    openBottomSheet(
      context,
      PopupFramework(
        title: "Select Color",
        child: SelectColor(
          selectedColor: selectedColor,
          setSelectedColor: setSelectedColor,
        ),
      ),
    );
  }

  Future<void> selectTitle() async {
    openBottomSheet(
      context,
      PopupFramework(
        title: "Enter Name",
        child: SelectText(
          setSelectedText: setSelectedTitle,
          labelText: "Name",
          selectedText: selectedTitle,
        ),
      ),
      snap: false,
    );
  }

  void setSelectedTitle(String title) {
    selectedTitle = title;
    determineBottomButton();
    return;
  }

  void setSelectedColor(Color color) {
    selectedColor = color;
    determineBottomButton();
    return;
  }

  Future addWallet() async {
    print("Added wallet");
    await database.createOrUpdateWallet(await createTransactionWallet());
    Navigator.pop(context);
  }

  Future<TransactionWallet> createTransactionWallet() async {
    int numberOfWallets = (await database.getTotalCountOfWallets())[0] ?? 0;
    return TransactionWallet(
      walletPk: widget.wallet != null
          ? widget.wallet!.walletPk
          : DateTime.now().millisecondsSinceEpoch,
      name: selectedTitle ?? "",
      colour: toHexString(selectedColor ?? Colors.green),
      dateCreated:
          widget.wallet != null ? widget.wallet!.dateCreated : DateTime.now(),
      order: widget.wallet != null ? widget.wallet!.order : numberOfWallets,
    );
  }

  @override
  void initState() {
    super.initState();
    _periodLengthFocusNode = FocusNode();

    if (widget.wallet != null) {
      //We are editing a wallet
      textAddWallet = "Edit Wallet";
      //Fill in the information from the passed in wallet
      setState(() {
        selectedColor = HexColor(widget.wallet!.colour);
        selectedTitle = widget.wallet!.name;
        //Set to false because we can't save until we made some changes
        canAddWallet = false;
      });
    } else {}
  }

  @override
  void dispose() {
    _periodLengthFocusNode.dispose();
    super.dispose();
  }

  determineBottomButton() {
    if (selectedTitle != null && selectedColor != null) {
      if (canAddWallet != true)
        this.setState(() {
          canAddWallet = true;
        });
    } else {
      if (canAddWallet != false)
        this.setState(() {
          canAddWallet = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.wallet != null) {
          discardChangesPopup(
            context,
            previousObject: widget.wallet,
            currentObject: await createTransactionWallet(),
          );
        } else {
          discardChangesPopup(context);
        }
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: GestureDetector(
          onTap: () {
            //Minimize keyboard when tap non interactive widget
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Stack(
            children: [
              PageFramework(
                title: widget.title,
                navbar: false,
                onBackButton: () async {
                  if (widget.wallet != null) {
                    discardChangesPopup(
                      context,
                      previousObject: widget.wallet,
                      currentObject: await createTransactionWallet(),
                    );
                  } else {
                    discardChangesPopup(context);
                  }
                },
                onDragDownToDissmiss: () async {
                  if (widget.wallet != null) {
                    discardChangesPopup(
                      context,
                      previousObject: widget.wallet,
                      currentObject: await createTransactionWallet(),
                    );
                  } else {
                    discardChangesPopup(context);
                  }
                },
                listWidgets: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TappableTextEntry(
                      title: selectedTitle,
                      placeholder: "Name",
                      onTap: () {
                        selectTitle();
                      },
                      autoSizeText: true,
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    ),
                  ),
                  SizedBox(height: 14),
                  Column(
                    children: [
                      Container(
                        height: 65,
                        child: SelectColor(
                          horizontalList: true,
                          selectedColor: selectedColor,
                          setSelectedColor: setSelectedColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: canAddWallet ?? false
                    ? Button(
                        label: widget.wallet == null
                            ? "Add Wallet"
                            : "Save Changes",
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        onTap: () {
                          addWallet();
                        },
                      )
                    : Button(
                        label: widget.wallet == null
                            ? "Add Wallet"
                            : "Save Changes",
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        onTap: () {},
                        color: Colors.grey,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
