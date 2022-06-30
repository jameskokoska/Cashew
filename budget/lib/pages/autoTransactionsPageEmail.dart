import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:budget/colors.dart';
import 'package:budget/database/binary_string_conversion.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/pages/editCategoriesPage.dart';
import 'package:budget/pages/editWalletsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/accountAndBackup.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/dropdownSelect.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/popupFramework.dart';
import 'package:budget/widgets/selectCategoryImage.dart';
import 'package:budget/widgets/selectColor.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/statusBox.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:budget/main.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart' as signIn;
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;
import 'dart:math' as math;
import 'package:file_picker/file_picker.dart';
import '../functions.dart';
import 'package:googleapis/gmail/v1.dart' as gMail;
import 'dart:convert';
import 'package:html/parser.dart';

class AutoTransactionsPageEmail extends StatefulWidget {
  const AutoTransactionsPageEmail({Key? key}) : super(key: key);

  @override
  State<AutoTransactionsPageEmail> createState() =>
      _AutoTransactionsPageEmailState();
}

class _AutoTransactionsPageEmailState extends State<AutoTransactionsPageEmail> {
  bool canReadEmails =
      appStateSettings["AutoTransactions-canReadEmails"] ?? false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      if (canReadEmails == true && user == null) {
        await signInGoogle(context,
            waitForCompletion: true, gMailPermissions: true);
        updateSettings("AutoTransactions-canReadEmails", true,
            pagesNeedingRefresh: [3]);
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageFramework(
      dragDownToDismiss: true,
      title: "Auto Transactions",
      navbar: true,
      appBarBackgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      appBarBackgroundColorStart: Theme.of(context).canvasColor,
      listWidgets: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5, left: 20, right: 20),
          child: TextFont(
            text:
                "Transactions can be created automatically based on your emails. This can be useful when you get emails from your bank, and you want to automatically add these transactions.",
            fontSize: 14,
            maxLines: 10,
          ),
        ),
        SettingsContainerSwitch(
          onSwitched: (value) async {
            if (value == true) {
              bool result = await signInGoogle(context,
                  waitForCompletion: true, gMailPermissions: true);
              if (result == false) {
                return false;
              }
              setState(() {
                canReadEmails = true;
              });
              updateSettings("AutoTransactions-canReadEmails", true,
                  pagesNeedingRefresh: [3]);
            } else {
              setState(() {
                canReadEmails = false;
              });
              updateSettings("AutoTransactions-canReadEmails", false);
            }
          },
          title: "Read Emails",
          description:
              "Parse Gmail emails on app launch. Every email is only scanned once.",
          initialValue: canReadEmails,
          icon: Icons.mark_unread_chat_alt_rounded,
        ),
        IgnorePointer(
          ignoring: !canReadEmails,
          child: AnimatedOpacity(
            duration: Duration(milliseconds: 300),
            opacity: canReadEmails ? 1 : 0.4,
            child: GmailApiScreen(),
          ),
        )
      ],
    );
  }
}

void parseEmailsInBackground(context) async {
  print(entireAppLoaded);
  //Only run this once, don't run again if the global state changes (e.g. when changing a setting)
  if (entireAppLoaded == false) {
    if (appStateSettings["AutoTransactions-canReadEmails"] == true) {
      print("Scanning emails");

      bool hasSignedIn = false;
      if (user == null) {
        hasSignedIn = await signInGoogle(context,
            gMailPermissions: true, waitForCompletion: false);
      }
      if (hasSignedIn == false) {
        return;
      }

      List<dynamic> emailsParsed =
          appStateSettings["EmailAutoTransactions-emailsParsed"] ?? [];
      int amountOfEmails =
          appStateSettings["EmailAutoTransactions-amountOfEmails"] ?? 10;
      int newEmailCount = 0;

      final authHeaders = await user!.authHeaders;
      final authenticateClient = GoogleAuthClient(authHeaders);
      gMail.GmailApi gmailApi = gMail.GmailApi(authenticateClient);
      gMail.ListMessagesResponse results = await gmailApi.users.messages
          .list(user!.id.toString(), maxResults: amountOfEmails);

      for (gMail.Message message in results.messages!) {
        if (emailsParsed.contains(message.id)) {
          print("Already checked this email!");
          continue;
        }
        newEmailCount++;

        gMail.Message messageData =
            await gmailApi.users.messages.get(user!.id.toString(), message.id!);
        DateTime messageDate = DateTime.fromMillisecondsSinceEpoch(
            int.parse(messageData.internalDate ?? ""));
        String messageEncoded = messageData.payload?.parts?[0].body?.data ?? "";
        String messageString;
        if (messageEncoded == "") {
          messageString = (messageData.snippet ?? "") +
              "\n\n" +
              "There was an error getting the rest of this email.";
        } else {
          messageString =
              parseHtmlString(utf8.decode(base64.decode(messageEncoded)));
        }
        print("Adding transaction based on email");

        String emailContains =
            appStateSettings["EmailAutoTransactions-emailContains"] ?? "";
        String amountTransactionBefore =
            appStateSettings["EmailAutoTransactions-amountTransactionBefore"] ??
                "";
        String amountTransactionAfter =
            appStateSettings["EmailAutoTransactions-amountTransactionAfter"] ??
                "";
        String titleTransactionBefore =
            appStateSettings["EmailAutoTransactions-titleTransactionBefore"] ??
                "";
        String titleTransactionAfter =
            appStateSettings["EmailAutoTransactions-titleTransactionAfter"] ??
                "";
        String? title;
        double? amountDouble;

        if (emailContains == "" ||
            (amountTransactionBefore == "" && amountTransactionAfter == "") ||
            (titleTransactionBefore == "" && titleTransactionAfter == "")) {
          openSnackbar(context,
              "You have not setup the email scanning configuration in settings.");
          break;
        }
        if (messageString.contains(emailContains) == false) {
          emailsParsed.add(message.id!);
          continue;
        }
        title = getTransactionTitleFromEmail(context, messageString,
            titleTransactionBefore, titleTransactionAfter);
        amountDouble = getTransactionAmountFromEmail(context, messageString,
            amountTransactionBefore, amountTransactionAfter);

        if (title == null) {
          openSnackbar(context,
              "Couldn't find title in email. Check the email settings page for more information.");
          emailsParsed.add(message.id!);
          continue;
        } else if (amountDouble == null) {
          openSnackbar(context,
              "Couldn't find amount in email. Check the email settings page for more information.");
          emailsParsed.add(message.id!);
          continue;
        }

        await database.createOrUpdateTransaction(
          Transaction(
            transactionPk: messageDate.millisecondsSinceEpoch,
            name: title,
            amount: amountDouble,
            note: "note",
            categoryFk: 1,
            walletFk: appStateSettings["selectedWallet"],
            dateCreated: DateTime(
                DateTime.now().year, DateTime.now().month, DateTime.now().day),
            income: false,
            paid: true,
            skipPaid: false,
            methodAdded: MethodAdded.email,
          ),
        );
        openSnackbar(context, "Added a transaction from email: " + title);
        emailsParsed.add(message.id!);
      }
      updateSettings("EmailAutoTransactions-emailsParsed", emailsParsed,
          updateGlobalState: false);
      openSnackbar(
        context,
        "Finished scanning " +
            results.messages!.length.toString() +
            " emails" +
            "\n" +
            "New emails: " +
            newEmailCount.toString(),
      );
    }
  }
}

String? getTransactionTitleFromEmail(context, String messageString,
    String titleTransactionBefore, String titleTransactionAfter) {
  String? title;
  try {
    int startIndex = messageString.indexOf(titleTransactionBefore) +
        titleTransactionBefore.length;
    int endIndex = messageString.indexOf(titleTransactionAfter, startIndex);
    title = messageString.substring(startIndex, endIndex);
    title = title.replaceAll("\n", "");
    title = title.toLowerCase();
    title = title.capitalizeFirst;
  } catch (e) {}
  return title;
}

double? getTransactionAmountFromEmail(context, String messageString,
    String amountTransactionBefore, String amountTransactionAfter) {
  double? amountDouble;
  try {
    int startIndex = messageString.indexOf(amountTransactionBefore) +
        amountTransactionBefore.length;
    int endIndex = messageString.indexOf(amountTransactionAfter, startIndex);
    String amountString = messageString.substring(startIndex, endIndex);
    amountDouble = double.parse(amountString.replaceAll(RegExp('[^0-9.]'), ''));
  } catch (e) {}
  return amountDouble;
}

class GmailApiScreen extends StatefulWidget {
  @override
  _GmailApiScreenState createState() => _GmailApiScreenState();
}

class _GmailApiScreenState extends State<GmailApiScreen> {
  bool loaded = false;
  bool loading = false;
  String emailContains =
      appStateSettings["EmailAutoTransactions-emailContains"] ?? "";
  String amountTransactionBefore =
      appStateSettings["EmailAutoTransactions-amountTransactionBefore"] ?? "";
  String amountTransactionAfter =
      appStateSettings["EmailAutoTransactions-amountTransactionAfter"] ?? "";
  String titleTransactionBefore =
      appStateSettings["EmailAutoTransactions-titleTransactionBefore"] ?? "";
  String titleTransactionAfter =
      appStateSettings["EmailAutoTransactions-titleTransactionAfter"] ?? "";
  int amountOfEmails =
      appStateSettings["EmailAutoTransactions-amountOfEmails"] ?? 10;

  late gMail.GmailApi gmailApi;
  List<gMail.Message> messagesList = [];

  @override
  void initState() {
    super.initState();
  }

  init() async {
    loading = true;
    if (user != null) {
      final authHeaders = await user!.authHeaders;
      final authenticateClient = GoogleAuthClient(authHeaders);
      gMail.GmailApi gmailApi = gMail.GmailApi(authenticateClient);
      gMail.ListMessagesResponse results = await gmailApi.users.messages
          .list(user!.id.toString(), maxResults: amountOfEmails);
      setState(() {
        loaded = true;
      });
      for (gMail.Message message in results.messages!) {
        gMail.Message messageData =
            await gmailApi.users.messages.get(user!.id.toString(), message.id!);
        // print(DateTime.fromMillisecondsSinceEpoch(
        //     int.parse(messageData.internalDate ?? "")));
        messagesList.add(messageData);
        if (mounted) setState(() {});
      }
    }
    loading = false;
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return SizedBox();
    } else if (loaded == false && loading == false) {
      init();
    }
    if (loaded) {
      // If the Future is complete, display the preview.
      List<Widget> messageTxt = [];
      for (var m in messagesList) {
        String messageShort = m.snippet ?? "";
        String messageEncoded = m.payload?.parts?[0].body?.data ?? "";
        String messageString;
        if (messageEncoded == "") {
          messageString = (m.snippet ?? "") +
              "\n\n" +
              "There was an error getting the rest of this email.";
        } else {
          messageString =
              parseHtmlString(utf8.decode(base64.decode(messageEncoded)));
        }
        bool doesEmailContain = false;
        String? title;
        double? amountDouble;
        if (messageString.contains(emailContains)) {
          doesEmailContain = true;
          title = getTransactionTitleFromEmail(context, messageString,
              titleTransactionBefore, titleTransactionAfter);
          amountDouble = getTransactionAmountFromEmail(context, messageString,
              amountTransactionBefore, amountTransactionAfter);
        }

        messageTxt.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Tappable(
              borderRadius: 15,
              color: doesEmailContain && (title == null || amountDouble == null)
                  ? Theme.of(context)
                      .colorScheme
                      .selectableColorRed
                      .withOpacity(0.5)
                  : doesEmailContain
                      ? Theme.of(context)
                          .colorScheme
                          .selectableColorGreen
                          .withOpacity(0.5)
                      : Theme.of(context).colorScheme.lightDarkAccent,
              onTap: () {
                openBottomSheet(
                  context,
                  selectSubjectText(
                    messageString,
                    () {
                      openBottomSheet(
                        context,
                        selectAmountText(
                          messageString,
                          () {
                            openBottomSheet(
                                context, selectTitleText(messageString, () {}));
                          },
                        ),
                      );
                    },
                  ),
                );
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    doesEmailContain && (title == null || amountDouble == null)
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: TextFont(
                              text: "Email parsing failed.",
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          )
                        : SizedBox(),
                    doesEmailContain
                        ? title == null
                            ? TextFont(
                                fontSize: 15,
                                text: "Title: Not found.",
                                maxLines: 10,
                                fontWeight: FontWeight.bold,
                              )
                            : TextFont(
                                fontSize: 15,
                                text: "Title: " + title,
                                maxLines: 10,
                                fontWeight: FontWeight.bold,
                              )
                        : SizedBox(),
                    doesEmailContain
                        ? amountDouble == null
                            ? Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: TextFont(
                                  fontSize: 15,
                                  text: "Amount: Not found / invalid number.",
                                  maxLines: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: TextFont(
                                  fontSize: 15,
                                  text:
                                      "Amount: " + convertToMoney(amountDouble),
                                  maxLines: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                        : SizedBox(),
                    TextFont(
                      fontSize: 13,
                      text: messageShort,
                      maxLines: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          emailContains == "" ||
                  (amountTransactionBefore == "" &&
                      amountTransactionAfter == "") ||
                  (titleTransactionBefore == "" && titleTransactionAfter == "")
              ? StatusBox(
                  title: "Email Configuration Missing",
                  description:
                      "Please go through the configuration process below.",
                  icon: Icons.warning_rounded,
                  color: Theme.of(context).errorColor,
                )
              : Container(),
          SettingsContainerDropdown(
            title: "Amount to Parse",
            description:
                "The number of recent emails to check to add transactions.",
            initial: (amountOfEmails).toString(),
            items: ["5", "10", "15", "20", "25"],
            onChanged: (value) {
              updateSettings(
                "EmailAutoTransactions-amountOfEmails",
                int.parse(value),
              );
            },
            icon: Icons.format_list_numbered_rounded,
          ),
          Opacity(
            opacity: 0.4,
            child: StreamBuilder<List<TransactionWallet>>(
                stream: database.watchAllWallets(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<String> walletNames = [];
                    for (TransactionWallet wallet in snapshot.data!) {
                      walletNames.add(wallet.name);
                    }
                    return SettingsContainerDropdown(
                      title: "Wallet",
                      description:
                          "Select the wallet transactions will be added to.",
                      initial: walletNames[0],
                      items: walletNames,
                      onChanged: (value) {
                        updateSettings(
                          "EmailAutoTransactions-setWallet",
                          int.parse(value),
                        );
                      },
                      icon: Icons.wallet_rounded,
                    );
                  } else {
                    return Container();
                  }
                }),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 4, left: 15),
            child: TextFont(
              text: "Sample Email",
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Theme.of(context).colorScheme.lightDarkAccentHeavy,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(),
                SizedBox(height: 5),
                TextFont(
                  text: emailContains,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  maxLines: 10,
                  textColor: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(height: 2),
                TextFont(
                  text: amountTransactionBefore +
                      "..." +
                      " [Amount] " +
                      "..." +
                      amountTransactionAfter,
                  fontSize: 16,
                  maxLines: 10,
                  textColor: Theme.of(context).colorScheme.secondary,
                ),
                SizedBox(height: 2),
                TextFont(
                  text: titleTransactionBefore +
                      "..." +
                      " [Title] " +
                      "..." +
                      titleTransactionAfter,
                  fontSize: 16,
                  maxLines: 10,
                  textColor: Theme.of(context).colorScheme.tertiary,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 13, bottom: 4, left: 15),
            child: TextFont(
              text: "Configure",
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 0, bottom: 4, left: 16),
            child: TextFont(
              text: "Select an email from your bank to start the confugration.",
              fontSize: 13,
              maxLines: 10,
            ),
          ),
          ...messageTxt
        ],
      );
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }

  int characterPadding = 8;

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
              color: Theme.of(context).colorScheme.lightDarkAccentHeavy,
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: SelectableText(
                messageString,
                toolbarOptions: ToolbarOptions(
                    copy: false, cut: false, paste: false, selectAll: false),
                onSelectionChanged: (selection, changeCause) {
                  emailContains = messageString.substring(
                      selection.baseOffset, selection.extentOffset);
                },
              ),
            ),
          ),
          SizedBox(height: 10),
          Button(
            label: "Done",
            onTap: () {
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
              color: Theme.of(context).colorScheme.lightDarkAccentHeavy,
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
                },
              ),
            ),
          ),
          SizedBox(height: 10),
          Button(
            label: "Done",
            onTap: () {
              Navigator.pop(context);
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
              color: Theme.of(context).colorScheme.lightDarkAccentHeavy,
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
                },
              ),
            ),
          ),
          SizedBox(height: 10),
          Button(
            label: "Done",
            onTap: () {
              next();
              setState(() {});
              updateSettings(
                  "EmailAutoTransactions-emailContains", emailContains);
              updateSettings("EmailAutoTransactions-amountTransactionBefore",
                  amountTransactionBefore);
              updateSettings("EmailAutoTransactions-amountTransactionAfter",
                  amountTransactionAfter);
              updateSettings("EmailAutoTransactions-titleTransactionBefore",
                  titleTransactionBefore);
              updateSettings("EmailAutoTransactions-titleTransactionAfter",
                  titleTransactionAfter);
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }
}

String parseHtmlString(String htmlString) {
  final document = parse(htmlString);
  final String parsedString = parse(document.body!.text).documentElement!.text;

  return parsedString;
}
