import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addButton.dart';
import 'package:budget/pages/autoTransactionsPageEmail.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/incomeExpenseTabSelector.dart';
import 'package:budget/widgets/navigationSidebar.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/saveBottomButton.dart';
import 'package:budget/widgets/selectCategory.dart';
import 'package:budget/widgets/selectChips.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:budget/colors.dart';
import 'package:provider/provider.dart';

enum MessagePart {
  amount('(?<amount>\\d+(,\\d{2,})*(\\.\\d{1,})?)'),
  title('(?<title>.+)'),
  ignored('(.*)', false);

  final String regex;
  final bool required;

  const MessagePart(this.regex, [this.required = true]);

  String replaceWithRegex(String input, String substring) =>
      input.replaceFirst(substring, regex);

  static String getOutput(String input) {
    var output = input;

    for (final part in values) {
      output = output.replaceAll(part.regex, '<<${part.name}>>');
    }

    return output;
  }
}

class AddEmailTemplate extends StatefulWidget {
  AddEmailTemplate({
    Key? key,
    required this.messagesList,
    this.scannerTemplate,
  }) : super(key: key);
  final List<String> messagesList;
  //When a transaction is passed in, we are editing that transaction
  final ScannerTemplate? scannerTemplate;

  @override
  _AddEmailTemplateState createState() => _AddEmailTemplateState();
}

class _AddEmailTemplateState extends State<AddEmailTemplate> {
  int characterPadding = 8;

  bool? canAddTemplate;

  TransactionCategory? selectedCategory;
  String? selectedMessageString;
  String? selectedName;
  String? selectedSubject;
  String? amountTransactionBefore;
  String? amountTransactionAfter;
  String? selectedAmount;
  String? titleTransactionBefore;
  String? titleTransactionAfter;
  String? selectedTitle;
  String selectedWalletPk = appStateSettings["selectedWalletPk"];
  bool isIncome = false;
  List<String> ignoredParts = [];

  @override
  void initState() {
    super.initState();
    if (widget.scannerTemplate != null) {
      selectedName = widget.scannerTemplate!.templateName;
      selectedSubject = widget.scannerTemplate!.regex;
      // amountTransactionBefore = widget.scannerTemplate!.amountTransactionBefore;
      // amountTransactionAfter = widget.scannerTemplate!.amountTransactionAfter;
      // titleTransactionBefore = widget.scannerTemplate!.titleTransactionBefore;
      // titleTransactionAfter = widget.scannerTemplate!.titleTransactionAfter;
      selectedWalletPk = widget.scannerTemplate!.walletFk;
      isIncome = widget.scannerTemplate!.income;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateInitial();
    });
  }

  updateInitial() async {
    if (widget.scannerTemplate != null) {
      TransactionCategory? getSelectedCategory = await database
          .getCategoryInstance(widget.scannerTemplate!.defaultCategoryFk);
      setState(() {
        selectedCategory = getSelectedCategory;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  determineBottomButton() {
    if (double.tryParse(selectedAmount ?? "") == null &&
        selectedMessageString != null) {
      setState(() {
        canAddTemplate = false;
      });
      return;
    }
    if (selectedTitle == null && selectedMessageString != null) {
      setState(() {
        canAddTemplate = false;
      });
      return;
    }

    if (selectedName == null) return;
    if (selectedCategory == null) return;
    // if (amountTransactionBefore == null) return;
    // if (amountTransactionAfter == null) return;
    // if (titleTransactionBefore == null) return;
    // if (titleTransactionAfter == null) return;

    setState(() {
      canAddTemplate = true;
    });
    return true;
  }

  void setMessageString(String messageString) {
    setState(() {
      selectedMessageString = messageString;
    });
    determineBottomButton();
    return;
  }

  void setSelectedName(String title) {
    setState(() {
      selectedName = title;
    });
    determineBottomButton();
    return;
  }

  void setSelectedCategory(TransactionCategory category) {
    setState(() {
      selectedCategory = category;
    });
    determineBottomButton();
    return;
  }

  void setSelectedWalletPk(String walletPk) {
    setState(() {
      selectedWalletPk = walletPk;
    });
    determineBottomButton();
    return;
  }

  Future<void> selectMessagePart(
    BuildContext context, {
    required String title,
    String subtitle = '',
    required Function(TextSelection selection) onSubmit,
  }) async {
    await openBottomSheet(
      context,
      MessagePartSelector(
        title: title,
        subtitle: subtitle,
        messageString: selectedMessageString ?? '',
        onSelectionChanged: () {
          determineBottomButton();
          setState(() {});
        },
        onSubmit: (selection) {
          determineBottomButton();
          setState(() {});
          Navigator.pop(context);
          onSubmit(selection);
        },
      ),
    );
  }

  Widget selectSubjectText(String messageString, VoidCallback next) {
    return PopupFramework(
      title: "Select Subject Text",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFont(
            text: "Only these emails that contain this text will be scanned.",
            fontSize: 14,
            maxLines: 10,
            textAlign: TextAlign.left,
          ),
          SizedBox(height: 5),
          TextFont(
            text:
                "Long press/double tap to select text. Press the 'Done' button at the bottom after selected",
            fontSize: 14,
            maxLines: 10,
            textAlign: TextAlign.left,
          ),
          SizedBox(height: 15),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              color: getColor(context, "lightDarkAccentHeavy"),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: SelectableText(
                messageString,
                toolbarOptions: ToolbarOptions(
                    copy: false, cut: false, paste: false, selectAll: false),
                onSelectionChanged: (selection, changeCause) {
                  selectedSubject = messageString.substring(
                      selection.baseOffset, selection.extentOffset);
                  determineBottomButton();
                  setState(() {});
                },
              ),
            ),
          ),
          SizedBox(height: 10),
          Button(
            label: "done".tr(),
            onTap: () {
              determineBottomButton();
              setState(() {});
              Navigator.pop(context);
              next();
            },
          )
        ],
      ),
    );
  }

  Widget selectAmountText(String messageString, VoidCallback next) {
    return PopupFramework(
      title: "Select Amount",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFont(
            text: "Select the amount of the transaction.",
            fontSize: 14,
            fontWeight: FontWeight.bold,
            maxLines: 10,
            textAlign: TextAlign.left,
          ),
          SizedBox(height: 5),
          TextFont(
            text:
                "Long press/double tap to select text. Press the 'Done' button at the bottom after selected",
            fontSize: 14,
            maxLines: 10,
            textAlign: TextAlign.left,
          ),
          SizedBox(height: 15),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              color: getColor(context, "lightDarkAccentHeavy"),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: SelectableText(
                messageString,
                toolbarOptions: ToolbarOptions(
                    copy: false, cut: false, paste: false, selectAll: false),
                onSelectionChanged: (selection, changeCause) {
                  if (selection.baseOffset - characterPadding < 0) {
                    amountTransactionBefore =
                        messageString.substring(0, selection.baseOffset);
                  } else {
                    amountTransactionBefore = messageString.substring(
                        selection.baseOffset - characterPadding,
                        selection.baseOffset);
                  }
                  if (selection.extentOffset + characterPadding >
                      messageString.length - 1) {
                    amountTransactionAfter = messageString.substring(
                        selection.extentOffset, messageString.length);
                  } else {
                    amountTransactionAfter = messageString.substring(
                        selection.extentOffset,
                        selection.extentOffset + characterPadding);
                  }
                  selectedAmount = messageString.substring(
                      selection.baseOffset, selection.extentOffset);
                  determineBottomButton();
                  setState(() {});
                },
              ),
            ),
          ),
          SizedBox(height: 10),
          Button(
            label: "done".tr(),
            onTap: () {
              determineBottomButton();
              Navigator.pop(context);
              setState(() {});
              next();
            },
          )
        ],
      ),
    );
  }

  Widget selectTitleText(String messageString, VoidCallback next) {
    return PopupFramework(
      title: "Select Title",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFont(
            text: "Select the title of the transaction.",
            fontSize: 14,
            fontWeight: FontWeight.bold,
            maxLines: 10,
            textAlign: TextAlign.left,
          ),
          SizedBox(height: 5),
          TextFont(
            text:
                "Long press/double tap to select text. Press the 'Done' button at the bottom after selected",
            fontSize: 14,
            maxLines: 10,
            textAlign: TextAlign.left,
          ),
          SizedBox(height: 15),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              color: getColor(context, "lightDarkAccentHeavy"),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: SelectableText(
                messageString,
                toolbarOptions: ToolbarOptions(
                    copy: false, cut: false, paste: false, selectAll: false),
                onSelectionChanged: (selection, changeCause) {
                  if (selection.baseOffset - characterPadding < 0) {
                    titleTransactionBefore =
                        messageString.substring(0, selection.baseOffset);
                  } else {
                    titleTransactionBefore = messageString.substring(
                        selection.baseOffset - characterPadding,
                        selection.baseOffset);
                  }

                  if (selection.extentOffset + characterPadding >
                      messageString.length - 1) {
                    titleTransactionAfter = messageString.substring(
                        selection.extentOffset, messageString.length);
                  } else {
                    titleTransactionAfter = messageString.substring(
                        selection.extentOffset,
                        selection.extentOffset + characterPadding);
                  }
                  selectedTitle = messageString.substring(
                      selection.baseOffset, selection.extentOffset);
                  determineBottomButton();
                  setState(() {});
                },
              ),
            ),
          ),
          SizedBox(height: 10),
          Button(
            label: "done".tr(),
            onTap: () {
              determineBottomButton();
              next();
              setState(() {});
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }

  Future addTemplate() async {
    print("Added template");
    await database.createOrUpdateScannerTemplate(
      insert: widget.scannerTemplate == null,
      createTemplate(),
    );
    Navigator.pop(context);
  }

  ScannerTemplate createTemplate() {
    return ScannerTemplate(
      scannerTemplatePk: widget.scannerTemplate != null
          ? widget.scannerTemplate!.scannerTemplatePk
          : "-1",
      dateCreated: widget.scannerTemplate != null
          ? widget.scannerTemplate!.dateCreated
          : DateTime.now(),
      dateTimeModified: null,
      amountTransactionAfter: "",
      amountTransactionBefore: "",
      contains: "",
      defaultCategoryFk: selectedCategory!.categoryPk,
      templateName: selectedName ?? "",
      titleTransactionAfter: "",
      titleTransactionBefore: "",
      walletFk: selectedWalletPk,
      ignore: false,
      regex: selectedSubject ?? "",
      income: isIncome,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.scannerTemplate != null) {
          discardChangesPopup(
            context,
            previousObject: widget.scannerTemplate,
            currentObject: createTemplate(),
          );
        } else {
          discardChangesPopup(context);
        }
        return false;
      },
      child: Scaffold(
        // resizeToAvoidBottomInset: false,
        resizeToAvoidBottomInset: true,
        body: GestureDetector(
          onTap: () {
            minimizeKeyboard(context);
          },
          child: Stack(
            children: [
              PageFramework(
                dragDownToDismiss: true,
                title: widget.scannerTemplate == null
                    ? "Add Template"
                    : "Edit Template",
                onBackButton: () async {
                  if (widget.scannerTemplate != null) {
                    discardChangesPopup(
                      context,
                      previousObject: widget.scannerTemplate,
                      currentObject: createTemplate(),
                    );
                  } else {
                    discardChangesPopup(context);
                  }
                },
                onDragDownToDismiss: () async {
                  if (widget.scannerTemplate != null) {
                    discardChangesPopup(
                      context,
                      previousObject: widget.scannerTemplate,
                      currentObject: createTemplate(),
                    );
                  } else {
                    discardChangesPopup(context);
                  }
                },
                listWidgets: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: IncomeExpenseTabSelector(
                      initialTabIsIncome: isIncome,
                      onTabChanged: (income) => setState(() {
                        isIncome = income;
                      }),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextInput(
                      autoFocus: kIsWeb && getIsFullScreen(context),
                      labelText: "name-placeholder".tr(),
                      bubbly: false,
                      initialValue: selectedName,
                      onChanged: (text) {
                        setSelectedName(text);
                      },
                      padding: EdgeInsets.only(left: 7, right: 7),
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      topContentPadding: 20,
                    ),
                  ),
                  SizedBox(height: 10),
                  SelectWallet(
                    selectedWalletPk: selectedWalletPk,
                    setSelectedWalletPk: setSelectedWalletPk,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFont(
                      text: "Default Category",
                      textColor: getColor(context, "textLight"),
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFont(
                      text:
                          "Categories are also automatically set based on the Associated Title.",
                      textColor: getColor(context, "textLight"),
                      fontSize: 11,
                      maxLines: 5,
                    ),
                  ),
                  SizedBox(height: 3),
                  SelectCategory(
                    horizontalList: true,
                    selectedCategory: selectedCategory,
                    setSelectedCategory: setSelectedCategory,
                    popRoute: false,
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Button(
                      label: "Select Message",
                      onTap: () async {
                        await openBottomSheet(
                          context,
                          PopupFramework(
                            title: "Select Message",
                            hasPadding: false,
                            child: EmailsList(
                              backgroundColor: getColor(context, "white"),
                              messagesList: widget.messagesList,
                              onTap: (messageString) {
                                setMessageString(messageString);
                                Navigator.pop(context);

                                final msg = selectedMessageString!;

                                selectMessagePart(
                                  context,
                                  title: 'Select Amount',
                                  onSubmit: (selection) {
                                    selectedAmount = msg.substring(
                                      selection.start,
                                      selection.end,
                                    );
                                    selectedSubject = msg;
                                    selectedSubject = MessagePart.amount
                                        .replaceWithRegex(selectedSubject ?? '',
                                            selectedAmount ?? '');

                                    setState(() {});

                                    selectMessagePart(
                                      context,
                                      title: 'Select Title',
                                      onSubmit: (selection) {
                                        selectedTitle = msg.substring(
                                          selection.start,
                                          selection.end,
                                        );
                                        selectedSubject = MessagePart.title
                                            .replaceWithRegex(
                                                selectedSubject ?? '',
                                                selectedTitle ?? '');

                                        selectMessagePart(
                                          context,
                                          title: 'Select Ignored Part',
                                          onSubmit: (selection) {
                                            final substring = msg.substring(
                                              selection.start,
                                              selection.end,
                                            );
                                            ignoredParts.add(substring);
                                            selectedSubject = MessagePart
                                                .ignored
                                                .replaceWithRegex(
                                              selectedSubject ?? '',
                                              substring,
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: selectedMessageString == null
                        ? Container()
                        : Column(
                            children: [
                              // TemplateInfoBox(
                              //   onTap: () {
                              //     openBottomSheet(
                              //       context,
                              //       selectSubjectText(
                              //         selectedMessageString ?? "",
                              //         () {},
                              //       ),
                              //     );
                              //   },
                              //   selectedText: selectedSubject ?? "",
                              //   label: "Subject: ",
                              //   secondaryLabel:
                              //       "All emails containing this text will be checked.",
                              // ),
                              SizedBox(height: 10),
                              TemplateInfoBox(
                                onTap: () {
                                  selectMessagePart(
                                    context,
                                    title: 'Select Amount',
                                    onSubmit: (selection) {
                                      final msg = selectedMessageString ?? '';
                                      selectedAmount = msg.substring(
                                        selection.start,
                                        selection.end,
                                      );
                                      selectedSubject = MessagePart.amount
                                          .replaceWithRegex(
                                              selectedSubject ?? '',
                                              selectedAmount ?? '');
                                    },
                                  );
                                },
                                selectedText: selectedAmount ?? "",
                                label: "Amount: ",
                                secondaryLabel:
                                    "The selected amount from this email. Surrounding text will be used to find this amount in new emails.",
                                extraCheck: (input) {
                                  return double.tryParse(
                                          input.replaceAll(',', '')) !=
                                      null;
                                },
                                extraCheckMessage:
                                    "Please select a valid number!",
                              ),
                              SizedBox(height: 10),
                              TemplateInfoBox(
                                onTap: () {
                                  selectMessagePart(
                                    context,
                                    title: 'Select Title',
                                    onSubmit: (selection) {
                                      final msg = selectedMessageString ?? '';
                                      selectedTitle = msg.substring(
                                        selection.start,
                                        selection.end,
                                      );
                                      selectedSubject = MessagePart.title
                                          .replaceWithRegex(
                                              selectedSubject ?? '',
                                              selectedTitle ?? '');
                                    },
                                  );
                                },
                                selectedText: selectedTitle ?? "",
                                label: "Title: ",
                                secondaryLabel:
                                    "The selected title from this email. Surrounding text will be used to find this title in new emails.",
                              ),
                              SizedBox(height: 10),
                              TextFont(
                                text: "Ignored Parts",
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              SizedBox(height: 10),
                              for (var i = 0; i < ignoredParts.length; i++)
                                Container(
                                  margin: EdgeInsets.only(bottom: 12),
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                    color: getColor(context, "lightDarkAccent"),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextFont(
                                          text:
                                              '#${i + 1} : ${ignoredParts[i]}',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              Row(
                                children: [
                                  Expanded(
                                    child: AddButton(
                                      onTap: () {
                                        final msg = selectedMessageString ?? '';
                                        selectMessagePart(
                                          context,
                                          title: 'Select Ignored Part',
                                          onSubmit: (selection) {
                                            final substring = msg.substring(
                                              selection.start,
                                              selection.end,
                                            );
                                            ignoredParts.add(substring);
                                            selectedSubject = MessagePart
                                                .ignored
                                                .replaceWithRegex(
                                              selectedSubject ?? '',
                                              substring,
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ),
                  widget.scannerTemplate == null &&
                          selectedMessageString == null
                      ? SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            padding: EdgeInsets.symmetric(
                                horizontal: 18, vertical: 15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: getColor(context, "lightDarkAccentHeavy"),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFont(
                                  text: "Sample",
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                                SizedBox(height: 4),
                                TextFont(
                                  text: MessagePart.getOutput(
                                      selectedSubject ?? ''),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  maxLines: 10,
                                  textColor:
                                      Theme.of(context).colorScheme.primary,
                                ),
                                SizedBox(height: 4),
                                TextFont(
                                  text: (selectedSubject ?? "")
                                      .replaceAll("\n", ""),
                                  fontSize: 16,
                                  maxLines: 10,
                                  textColor:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                  SizedBox(height: 70),
                ],
              ),
              if (widget.scannerTemplate == null)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SaveBottomButton(
                    label: widget.scannerTemplate == null
                        ? "Add Template"
                        : "save-changes".tr(),
                    onTap: () {
                      addTemplate();
                    },
                    disabled: !(canAddTemplate ?? false),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class SelectWallet extends StatelessWidget {
  const SelectWallet({
    super.key,
    required this.selectedWalletPk,
    required this.setSelectedWalletPk,
  });
  final String selectedWalletPk;
  final Function(String) setSelectedWalletPk;

  @override
  Widget build(BuildContext context) {
    final wallets = Provider.of<AllWallets>(context).list;
    if (wallets.length < 2) {
      return SizedBox.shrink();
    }
    return SelectChips(
      wrapped: enableDoubleColumn(context),
      extraWidgetBeforeSticky: true,
      allowMultipleSelected: false,
      extraWidgetBefore: Icon(
        Icons.account_balance_wallet,
        color: Theme.of(context).colorScheme.outline,
      ),
      items: wallets,
      getSelected: (TransactionWallet wallet) {
        return Provider.of<AllWallets>(context, listen: false)
                .indexedByPk[selectedWalletPk]
                ?.walletPk ==
            wallet.walletPk;
      },
      onSelected: (TransactionWallet wallet) {
        setSelectedWalletPk(wallet.walletPk);
      },
      getCustomBorderColor: (TransactionWallet item) {
        return dynamicPastel(
          context,
          lightenPastel(
            HexColor(
              item.colour,
              defaultColor: Theme.of(context).colorScheme.primary,
            ),
            amount: 0.3,
          ),
          amount: 0.4,
        );
      },
      getLabel: (TransactionWallet wallet) {
        return getWalletStringName(Provider.of<AllWallets>(context), wallet);
      },
    );
  }
}

class TemplateInfoBox extends StatelessWidget {
  const TemplateInfoBox(
      {required this.onTap,
      required this.selectedText,
      required this.label,
      required this.secondaryLabel,
      this.extraCheck,
      this.extraCheckMessage,
      super.key});

  final Function() onTap;
  final String selectedText;
  final String label;
  final String secondaryLabel;
  final Function(String)? extraCheck;
  final String? extraCheckMessage;

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: onTap,
      color: selectedText == "" ||
              (extraCheck != null && extraCheck!(selectedText) == false)
          ? Theme.of(context).colorScheme.selectableColorRed.withOpacity(0.5)
          : getColor(context, "lightDarkAccent"),
      borderRadius: 15,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 18.0,
          vertical: 14,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFont(
                  text: label,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
                Expanded(
                  child: TextFont(
                    text: selectedText,
                    fontSize: 17,
                    textColor:
                        Theme.of(context).colorScheme.onSecondaryContainer,
                    maxLines: 10,
                  ),
                )
              ],
            ),
            (extraCheck != null &&
                    extraCheck!(selectedText) == false &&
                    extraCheckMessage != null)
                ? TextFont(
                    fontSize: 14,
                    text: extraCheckMessage ?? "",
                    textColor: getColor(context, "black").withOpacity(0.9),
                    maxLines: 10,
                  )
                : SizedBox.shrink(),
            SizedBox(height: 3),
            TextFont(
              fontSize: 14,
              text: secondaryLabel,
              textColor: selectedText == "" ||
                      (extraCheck != null && extraCheck!(selectedText) == false)
                  ? getColor(context, "black").withOpacity(0.5)
                  : getColor(context, "textLight"),
              maxLines: 10,
            )
          ],
        ),
      ),
    );
  }
}

class MessagePartSelector extends StatefulWidget {
  const MessagePartSelector({
    super.key,
    required this.title,
    required this.subtitle,
    this.infoMessage =
        "Long press/double tap to select text. Press the 'Done' button at the bottom after selected",
    required this.messageString,
    required this.onSelectionChanged,
    required this.onSubmit,
  });
  final String title, subtitle, infoMessage, messageString;
  final VoidCallback onSelectionChanged;
  final Function(TextSelection selection) onSubmit;

  @override
  State<MessagePartSelector> createState() => _MessagePartSelectorState();
}

class _MessagePartSelectorState extends State<MessagePartSelector> {
  TextSelection textSelection = TextSelection.collapsed(offset: 0);
  @override
  Widget build(BuildContext context) {
    return PopupFramework(
      title: widget.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFont(
            text: widget.subtitle,
            fontSize: 14,
            maxLines: 10,
            textAlign: TextAlign.left,
          ),
          SizedBox(height: 5),
          TextFont(
            text: widget.infoMessage,
            fontSize: 14,
            maxLines: 10,
            textAlign: TextAlign.left,
          ),
          SizedBox(height: 15),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              color: getColor(context, "lightDarkAccentHeavy"),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: SelectableText(
                widget.messageString,
                toolbarOptions: ToolbarOptions(
                    copy: false, cut: false, paste: false, selectAll: false),
                onSelectionChanged: (selection, changeCause) {
                  setState(() {
                    textSelection = selection;
                  });
                  widget.onSelectionChanged();
                },
              ),
            ),
          ),
          SizedBox(height: 10),
          Button(
            label: "done".tr(),
            onTap: () => widget.onSubmit(textSelection),
          )
        ],
      ),
    );
  }
}
