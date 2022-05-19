import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/categoryEntry.dart';
import 'package:budget/widgets/dropdownSelect.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/popupFramework.dart';
import 'package:budget/widgets/radioItems.dart';
import 'package:budget/widgets/selectAmount.dart';
import 'package:budget/widgets/selectCategory.dart';
import 'package:budget/widgets/selectColor.dart';
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

  late TextEditingController _nameInputController;
  late TextEditingController _colorInputController;
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

  void setSelectedTitle(String title) {
    selectedTitle = title;
    determineBottomButton();
    return;
  }

  void setSelectedColor(Color color) {
    selectedColor = color;
    setTextInput(_colorInputController, toHexString(color));
    determineBottomButton();
    return;
  }

  Future addWallet() async {
    print("Added wallet");
    int numberOfWallets = (await database.getTotalCountOfWallets())[0] ?? 0;
    await database.createOrUpdateWallet(
      TransactionWallet(
        walletPk: widget.wallet != null
            ? widget.wallet!.walletPk
            : DateTime.now().millisecondsSinceEpoch,
        name: selectedTitle ?? "",
        colour: toHexString(selectedColor ?? Colors.green),
        dateCreated: DateTime.now(),
        order: numberOfWallets,
      ),
    );
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    _periodLengthFocusNode = FocusNode();

    if (widget.wallet != null) {
      //We are editing a wallet
      textAddWallet = "Edit Wallet";
      selectedTitle = widget.wallet!.name;
      //Fill in the information from the passed in wallet
      _nameInputController =
          new TextEditingController(text: widget.wallet!.name);
      _colorInputController =
          new TextEditingController(text: widget.wallet!.colour);
      WidgetsBinding.instance.addPostFrameCallback((_) {});
    } else {
      _nameInputController = new TextEditingController();
      _colorInputController = new TextEditingController();
    }
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
    return Scaffold(
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
              listWidgets: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Container(height: 20),
                      TextInput(
                        labelText: "Wallet Name",
                        icon: Icons.title_rounded,
                        padding: EdgeInsets.zero,
                        controller: _nameInputController,
                        onChanged: (text) {
                          setSelectedTitle(text);
                        },
                      ),
                      Container(height: 14),
                      TextInput(
                        labelText: "Select color",
                        icon: Icons.color_lens_rounded,
                        padding: EdgeInsets.zero,
                        onTap: () {
                          selectColor(context);
                        },
                        readOnly: true,
                        showCursor: false,
                        controller: _colorInputController,
                      ),
                    ],
                  ),
                )
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: canAddWallet ?? false
                  ? Button(
                      label: "Add Wallet",
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      onTap: () {
                        addWallet();
                      },
                    )
                  : Button(
                      label: "Add Wallet",
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      onTap: () {
                        addWallet();
                      },
                      color: Colors.grey,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
