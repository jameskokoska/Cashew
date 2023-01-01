import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:budget/colors.dart';
import 'package:budget/database/binary_string_conversion.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/pages/addEmailTemplate.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/editBudgetPage.dart';
import 'package:budget/pages/editCategoriesPage.dart';
import 'package:budget/pages/editWalletsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/accountAndBackup.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/categoryIcon.dart';
import 'package:budget/widgets/dropdownSelect.dart';
import 'package:budget/widgets/editRowEntry.dart';
import 'package:budget/widgets/globalSnackBar.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
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
import 'package:pausable_timer/pausable_timer.dart';
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
        await signInGoogle(
            context: context, waitForCompletion: true, gMailPermissions: true);
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
      appBarBackgroundColorStart: Theme.of(context).colorScheme.background,
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
              bool result = await signInGoogle(
                  context: context,
                  waitForCompletion: true,
                  gMailPermissions: true);
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
          icon: Icons.mark_email_unread_rounded,
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

Future<void> parseEmailsInBackground(context) async {
  print(entireAppLoaded);
  //Only run this once, don't run again if the global state changes (e.g. when changing a setting)
  if (entireAppLoaded == false) {
    if (appStateSettings["AutoTransactions-canReadEmails"] == true) {
      List<Transaction> transactionsToAdd = [];
      Stopwatch stopwatch = new Stopwatch()..start();
      print("Scanning emails");

      bool hasSignedIn = false;
      if (user == null) {
        hasSignedIn = await signInGoogle(
            context: context,
            gMailPermissions: true,
            waitForCompletion: false,
            silentSignIn: true);
      } else {
        hasSignedIn = true;
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

      int currentEmailIndex = 0;

      List<ScannerTemplate> scannerTemplates =
          await database.getAllScannerTemplates();
      if (scannerTemplates.length <= 0) {
        openSnackbar(
          SnackbarMessage(
            title:
                "You have not setup the email scanning configuration in settings.",
            onTap: () {
              pushRoute(
                context,
                AutoTransactionsPageEmail(),
              );
            },
          ),
        );
      }
      for (gMail.Message message in results.messages!) {
        currentEmailIndex++;
        loadingProgressKey.currentState!
            .setProgressPercentage(currentEmailIndex / amountOfEmails);
        // await Future.delayed(Duration(milliseconds: 1000));

        // Remove this to always parse emails
        if (emailsParsed.contains(message.id!)) {
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

        String? title;
        double? amountDouble;

        bool doesEmailContain = false;
        ScannerTemplate? templateFound;
        for (ScannerTemplate scannerTemplate in scannerTemplates) {
          if (messageString.contains(scannerTemplate.contains)) {
            doesEmailContain = true;
            templateFound = scannerTemplate;
            title = getTransactionTitleFromEmail(
                context,
                messageString,
                scannerTemplate.titleTransactionBefore,
                scannerTemplate.titleTransactionAfter);
            amountDouble = getTransactionAmountFromEmail(
                context,
                messageString,
                scannerTemplate.amountTransactionBefore,
                scannerTemplate.amountTransactionAfter);
            break;
          }
        }

        if (doesEmailContain == false) {
          emailsParsed.insert(0, message.id!);
          continue;
        }

        if (title == null) {
          openSnackbar(
            SnackbarMessage(
              title:
                  "Couldn't find title in email. Check the email settings page for more information.",
              onTap: () {
                pushRoute(
                  context,
                  AutoTransactionsPageEmail(),
                );
              },
            ),
          );
          emailsParsed.insert(0, message.id!);
          continue;
        } else if (amountDouble == null) {
          openSnackbar(
            SnackbarMessage(
              title:
                  "Couldn't find amount in email. Check the email settings page for more information.",
              onTap: () {
                pushRoute(
                  context,
                  AutoTransactionsPageEmail(),
                );
              },
            ),
          );

          emailsParsed.insert(0, message.id!);
          continue;
        }

        List result = await getRelatingAssociatedTitle(title);
        TransactionAssociatedTitle? foundTitle = result[0];
        int categoryId;

        if (foundTitle != null) {
          print("FOUND TITLE");
          categoryId =
              (await database.getCategoryInstance(foundTitle.categoryFk))
                  .categoryPk;
        } else {
          print("NO FOUND TITLE");
          categoryId = templateFound!.defaultCategoryFk;
        }
        print("NEXT");

        TransactionCategory selectedCategory;
        try {
          // Check if the set category exists
          selectedCategory = await database.getCategoryInstance(categoryId);
        } catch (e) {
          openSnackbar(
            SnackbarMessage(
              title:
                  "The transaction category cannot be found for this email! " +
                      e.toString(),
              onTap: () {
                pushRoute(context, AutoTransactionsPageEmail());
              },
            ),
          );
          continue;
        }

        title = filterEmailTitle(title);

        await addAssociatedTitles(title, selectedCategory);

        Transaction transactionToAdd = Transaction(
          transactionPk: messageDate.millisecondsSinceEpoch,
          name: title,
          amount: (amountDouble).abs() * -1,
          note: "",
          categoryFk: categoryId,
          walletFk: appStateSettings["selectedWallet"],
          dateCreated:
              DateTime(messageDate.year, messageDate.month, messageDate.day),
          income: false,
          paid: true,
          skipPaid: false,
          methodAdded: MethodAdded.email,
          dateTimeCreated: DateTime.now(),
        );
        transactionsToAdd.add(transactionToAdd);
        openSnackbar(
          SnackbarMessage(
            title: templateFound!.templateName + ": " + "From Email",
            description: title,
            icon: Icons.payments_rounded,
            onTap: () {
              pushRoute(
                context,
                AddTransactionPage(
                  title: "Edit Transaction",
                  transaction: transactionToAdd,
                ),
              );
            },
          ),
        );
        // TODO have setting so they can choose if the emails are markes as read
        gmailApi.users.messages.modify(
            gMail.ModifyMessageRequest(removeLabelIds: ["UNREAD"]),
            user!.id,
            message.id!);

        emailsParsed.insert(0, message.id!);
      }
      // wait for intro animation to finish
      if (Duration(milliseconds: 2500) > stopwatch.elapsed) {
        print("waited extra" +
            (Duration(milliseconds: 2500) - stopwatch.elapsed).toString());
        await Future.delayed(
            Duration(milliseconds: 2500) - stopwatch.elapsed, () {});
      }
      for (Transaction transaction in transactionsToAdd) {
        await database.createOrUpdateTransaction(transaction);
      }
      List<dynamic> emails = [
        ...emailsParsed
            .take(appStateSettings["EmailAutoTransactions-amountOfEmails"] + 10)
      ];
      updateSettings(
        "EmailAutoTransactions-emailsParsed",
        emails, // Keep 10 extra in case maybe the user deleted some emails recently
        updateGlobalState: false,
      );
      openSnackbar(
        SnackbarMessage(
          title: "Scanned " + results.messages!.length.toString() + " emails",
          description: newEmailCount.toString() +
              pluralString(newEmailCount == 1, " new email"),
          icon: Icons.mark_email_unread_rounded,
          onTap: () {
            pushRoute(context, AutoTransactionsPageEmail());
          },
        ),
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
  String error = "";
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
      try {
        final authHeaders = await user!.authHeaders;
        final authenticateClient = GoogleAuthClient(authHeaders);
        gMail.GmailApi gmailApi = gMail.GmailApi(authenticateClient);
        gMail.ListMessagesResponse results = await gmailApi.users.messages
            .list(user!.id.toString(), maxResults: amountOfEmails);
        setState(() {
          loaded = true;
          error = "";
        });
        int currentEmailIndex = 0;
        for (gMail.Message message in results.messages!) {
          gMail.Message messageData = await gmailApi.users.messages
              .get(user!.id.toString(), message.id!);
          // print(DateTime.fromMillisecondsSinceEpoch(
          //     int.parse(messageData.internalDate ?? "")));
          messagesList.add(messageData);
          currentEmailIndex++;
          loadingProgressKey.currentState!
              .setProgressPercentage(currentEmailIndex / amountOfEmails);
          if (mounted) {
            setState(() {});
          } else {
            loadingProgressKey.currentState!.setProgressPercentage(0);
            break;
          }
        }
      } catch (e) {
        setState(() {
          loaded = true;
          error = e.toString();
        });
      }
    }
    loading = false;
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return SizedBox();
    } else if (error != "" || (loaded == false && loading == false)) {
      init();
    }
    if (error != "") {
      return Padding(
        padding: const EdgeInsets.only(
          top: 28.0,
          left: 20,
          right: 20,
        ),
        child: Center(
          child: TextFont(
            text: error,
            fontSize: 15,
            textAlign: TextAlign.center,
            maxLines: 10,
          ),
        ),
      );
    }
    if (loaded) {
      // If the Future is complete, display the preview.

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Padding(
            padding: const EdgeInsets.only(top: 13, bottom: 4, left: 15),
            child: TextFont(
              text: "Configure",
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          StreamBuilder<List<ScannerTemplate>>(
            stream: database.watchAllScannerTemplates(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.length <= 0) {
                  return Padding(
                    padding: const EdgeInsets.all(5),
                    child: StatusBox(
                      title: "Email Configuration Missing",
                      description: "Please add a configuration.",
                      icon: Icons.warning_rounded,
                      color: Theme.of(context).errorColor,
                    ),
                  );
                }
                return Column(
                  children: [
                    for (ScannerTemplate scannerTemplate in snapshot.data!)
                      ScannerTemplateEntry(
                        messagesList: messagesList,
                        scannerTemplate: scannerTemplate,
                      )
                  ],
                );
              } else {
                return Container();
              }
            },
          ),
          OpenContainerNavigation(
            openPage: AddEmailTemplate(
              title: "Add Template",
              messagesList: messagesList,
            ),
            borderRadius: 15,
            button: (openContainer) {
              return Row(
                children: [
                  Expanded(
                    child: AddButton(
                      onTap: openContainer,
                    ),
                  ),
                ],
              );
            },
          ),
          EmailsList(messagesList: messagesList)
        ],
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(top: 28.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }
  }
}

class ScannerTemplateEntry extends StatelessWidget {
  const ScannerTemplateEntry({
    required this.scannerTemplate,
    required this.messagesList,
    super.key,
  });
  final ScannerTemplate scannerTemplate;
  final List<gMail.Message> messagesList;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
      child: OpenContainerNavigation(
        openPage: AddEmailTemplate(
          title: "Add Template",
          messagesList: messagesList,
          scannerTemplate: scannerTemplate,
        ),
        borderRadius: 15,
        button: (openContainer) {
          return Tappable(
            borderRadius: 15,
            color: Theme.of(context).colorScheme.lightDarkAccent,
            onTap: openContainer,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 7,
                right: 15,
                top: 5,
                bottom: 5,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CategoryIcon(
                          categoryPk: scannerTemplate.defaultCategoryFk,
                          size: 25),
                      SizedBox(width: 7),
                      TextFont(
                        text: scannerTemplate.templateName,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                  ButtonIcon(
                    onTap: () async {
                      openPopup(
                        context,
                        title: "Delete " + scannerTemplate.templateName + "?",
                        icon: Icons.delete_rounded,
                        onCancel: () {
                          Navigator.pop(context);
                        },
                        onCancelLabel: "Cancel",
                        onSubmit: () async {
                          await database.deleteScannerTemplate(
                              scannerTemplate.scannerTemplatePk);
                          Navigator.pop(context);
                          openSnackbar(
                            SnackbarMessage(
                              title: "Deleted " + scannerTemplate.templateName,
                              icon: Icons.delete,
                            ),
                          );
                        },
                        onSubmitLabel: "Delete",
                      );
                    },
                    icon: Icons.delete_rounded,
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

String parseHtmlString(String htmlString) {
  final document = parse(htmlString);
  final String parsedString = parse(document.body!.text).documentElement!.text;

  return parsedString;
}

class EmailsList extends StatelessWidget {
  const EmailsList({
    required this.messagesList,
    this.onTap,
    this.backgroundColor,
    super.key,
  });
  final List<gMail.Message> messagesList;
  final Function(String)? onTap;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ScannerTemplate>>(
      stream: database.watchAllScannerTemplates(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<ScannerTemplate> scannerTemplates = snapshot.data!;
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
            String? templateFound;

            for (ScannerTemplate scannerTemplate in scannerTemplates) {
              if (messageString.contains(scannerTemplate.contains)) {
                doesEmailContain = true;
                templateFound = scannerTemplate.templateName;
                title = getTransactionTitleFromEmail(
                    context,
                    messageString,
                    scannerTemplate.titleTransactionBefore,
                    scannerTemplate.titleTransactionAfter);
                amountDouble = getTransactionAmountFromEmail(
                    context,
                    messageString,
                    scannerTemplate.amountTransactionBefore,
                    scannerTemplate.amountTransactionAfter);
                break;
              }
            }

            messageTxt.add(
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Tappable(
                  borderRadius: 15,
                  color: doesEmailContain &&
                          (title == null || amountDouble == null)
                      ? Theme.of(context)
                          .colorScheme
                          .selectableColorRed
                          .withOpacity(0.5)
                      : doesEmailContain
                          ? Theme.of(context)
                              .colorScheme
                              .selectableColorGreen
                              .withOpacity(0.5)
                          : backgroundColor ??
                              Theme.of(context).colorScheme.lightDarkAccent,
                  onTap: () {
                    if (onTap != null) onTap!(messageString);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        doesEmailContain &&
                                (title == null || amountDouble == null)
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
                            ? templateFound == null
                                ? TextFont(
                                    fontSize: 19,
                                    text: "Template Not found.",
                                    maxLines: 10,
                                    fontWeight: FontWeight.bold,
                                  )
                                : TextFont(
                                    fontSize: 19,
                                    text: templateFound,
                                    maxLines: 10,
                                    fontWeight: FontWeight.bold,
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
                                      text:
                                          "Amount: Not found / invalid number.",
                                      maxLines: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: TextFont(
                                      fontSize: 15,
                                      text: "Amount: " +
                                          convertToMoney(amountDouble),
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
            children: messageTxt,
          );
        } else {
          return Container(width: 100, height: 100, color: Colors.white);
        }
      },
    );
  }
}
