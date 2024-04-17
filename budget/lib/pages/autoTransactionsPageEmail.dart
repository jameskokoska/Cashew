import 'dart:async';
import 'dart:convert';
import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/pages/addCategoryPage.dart';
import 'package:budget/pages/addEmailTemplate.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/editCategoriesPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/accountAndBackup.dart';
import 'package:budget/widgets/button.dart';
import 'package:budget/widgets/categoryIcon.dart';
import 'package:budget/widgets/globalSnackbar.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/openContainerNavigation.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/statusBox.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:budget/main.dart';
import 'package:provider/provider.dart';
import '../functions.dart';
import 'package:googleapis/gmail/v1.dart' as gMail;
import 'package:html/parser.dart';
import 'package:notification_listener_service/notification_event.dart';
import 'package:notification_listener_service/notification_listener_service.dart';

import 'addButton.dart';

StreamSubscription<ServiceNotificationEvent>? notificationListenerSubscription;
List<String> recentCapturedNotifications = [];

Future initNotificationScanning() async {
  if (getPlatform(ignoreEmulation: true) != PlatformOS.isAndroid) return;
  notificationListenerSubscription?.cancel();
  if (appStateSettings["notificationScanning"] != true) return;

  bool status = await requestReadNotificationPermission();

  if (status == true) {
    notificationListenerSubscription =
        NotificationListenerService.notificationsStream.listen(onNotification);
  }
}

Future<bool> requestReadNotificationPermission() async {
  bool status = await NotificationListenerService.isPermissionGranted();
  if (status != true) {
    status = await NotificationListenerService.requestPermission();
  }
  return status;
}

onNotification(ServiceNotificationEvent event) async {
  String messageString = getNotificationMessage(event);
  recentCapturedNotifications.insert(0, messageString);
  recentCapturedNotifications.take(50);
  queueTransactionFromMessage(messageString);
}

class InitializeNotificationService extends StatefulWidget {
  const InitializeNotificationService({required this.child, super.key});
  final Widget child;

  @override
  State<InitializeNotificationService> createState() =>
      _InitializeNotificationServiceState();
}

class _InitializeNotificationServiceState
    extends State<InitializeNotificationService> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      initNotificationScanning();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

Future queueTransactionFromMessage(String messageString) async {
  String? title;
  double? amountDouble;
  List<ScannerTemplate> scannerTemplates =
      await database.getAllScannerTemplates();
  ScannerTemplate? templateFound;

  for (ScannerTemplate scannerTemplate in scannerTemplates) {
    if (messageString.contains(scannerTemplate.contains)) {
      templateFound = scannerTemplate;
      title = getTransactionTitleFromEmail(
          messageString,
          scannerTemplate.titleTransactionBefore,
          scannerTemplate.titleTransactionAfter);
      amountDouble = getTransactionAmountFromEmail(
          messageString,
          scannerTemplate.amountTransactionBefore,
          scannerTemplate.amountTransactionAfter);
      break;
    }
  }

  if (templateFound == null) return false;

  //if (amountDouble == null) amountDouble = getAmountFromString(title ?? "");
  // We don't need this line, we can still queue up a transaction without these details,
  // however maybe the user doesn't want to queue it up if its missing details?
  if (amountDouble == null || title == null) return false;

  TransactionCategory? category;
  TransactionAssociatedTitleWithCategory? foundTitle =
      (await database.getSimilarAssociatedTitles(title: title, limit: 1))
          .firstOrNull;
  category = foundTitle?.category;
  if (category == null) {
    category = await database
        .getCategoryInstanceOrNull(templateFound.defaultCategoryFk ?? "");
  }

  TransactionWallet? wallet = templateFound.walletFk == "-1"
      ? null
      : await database.getWalletInstance(templateFound.walletFk);

  pushRoute(
    navigatorKey.currentContext!,
    AddTransactionPage(
      useCategorySelectedIncome: true,
      routesToPopAfterDelete: RoutesToPopAfterDelete.None,
      selectedAmount: amountDouble,
      selectedTitle: title,
      selectedCategory: category,
      startInitialAddTransactionSequence: false,
      selectedWallet: wallet,
    ),
  );
}

String getNotificationMessage(ServiceNotificationEvent event) {
  String output = "";
  output = output + "Package name: " + event.packageName.toString() + "\n";
  output =
      output + "Notification removed: " + event.hasRemoved.toString() + "\n";
  output = output + "\n----\n\n";
  output = output + "Notification Title: " + event.title.toString() + "\n\n";
  output = output + "Notification Content: " + event.content.toString();
  return output;
}

class AutoTransactionsPageNotifications extends StatefulWidget {
  const AutoTransactionsPageNotifications({Key? key}) : super(key: key);

  @override
  State<AutoTransactionsPageNotifications> createState() =>
      _AutoTransactionsPageNotificationsState();
}

class _AutoTransactionsPageNotificationsState
    extends State<AutoTransactionsPageNotifications> {
  bool canReadEmails = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageFramework(
      dragDownToDismiss: true,
      title: "Auto Transactions",
      actions: [
        RefreshButton(onTap: () async {
          loadingIndeterminateKey.currentState?.setVisibility(true);
          setState(() {});
          loadingIndeterminateKey.currentState?.setVisibility(false);
        }),
      ],
      listWidgets: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5, left: 20, right: 20),
          child: TextFont(
            text:
                "Transactions can be created automatically based on your notifications.",
            fontSize: 14,
            maxLines: 10,
          ),
        ),
        SettingsContainerSwitch(
          onSwitched: (value) async {
            await updateSettings("notificationScanning", value,
                updateGlobalState: false);
            if (value == true) {
              bool status = await requestReadNotificationPermission();
              if (status == false) {
                await updateSettings("notificationScanning", false,
                    updateGlobalState: false);
              } else {
                initNotificationScanning();
              }
            } else {
              notificationListenerSubscription?.cancel();
            }
          },
          title: "Notification Transactions",
          description:
              "When a notification is dismissed and the app is open, attempt to add a transaction given its information. Create a template so Cashew understands the format of a notification.",
          initialValue: appStateSettings["notificationScanning"],
        ),
        StreamBuilder<List<ScannerTemplate>>(
          stream: database.watchAllScannerTemplates(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.length <= 0) {
                return Padding(
                  padding: const EdgeInsets.all(5),
                  child: StatusBox(
                    title: "Notification Configuration Missing",
                    description: "Please add a configuration.",
                    icon: appStateSettings["outlinedIcons"]
                        ? Icons.warning_outlined
                        : Icons.warning_rounded,
                    color: Theme.of(context).colorScheme.error,
                  ),
                );
              }
              return Column(
                children: [
                  for (ScannerTemplate scannerTemplate in snapshot.data!)
                    ScannerTemplateEntry(
                      messagesList: recentCapturedNotifications,
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
            messagesList: recentCapturedNotifications,
          ),
          borderRadius: 15,
          button: (openContainer) {
            return Row(
              children: [
                Expanded(
                  child: AddButton(
                    margin: EdgeInsets.only(
                      left: 15,
                      right: 15,
                      bottom: 9,
                      top: 4,
                    ),
                    onTap: openContainer,
                  ),
                ),
              ],
            );
          },
        ),
        EmailsList(
          messagesList: recentCapturedNotifications,
        ),
      ],
    );
  }
}

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
      if (canReadEmails == true && googleUser == null) {
        await signInGoogle(
            context: context, waitForCompletion: true, gMailPermissions: true);
        updateSettings("AutoTransactions-canReadEmails", true,
            pagesNeedingRefresh: [3], updateGlobalState: false);
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageFramework(
      dragDownToDismiss: true,
      title: "Auto Transactions",
      actions: [
        RefreshButton(onTap: () async {
          loadingIndeterminateKey.currentState?.setVisibility(true);
          await parseEmailsInBackground(context,
              sayUpdates: true, forceParse: true);
          loadingIndeterminateKey.currentState?.setVisibility(false);
        }),
      ],
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
                  pagesNeedingRefresh: [3], updateGlobalState: false);
            } else {
              setState(() {
                canReadEmails = false;
              });
              updateSettings("AutoTransactions-canReadEmails", false,
                  updateGlobalState: false, pagesNeedingRefresh: [3]);
            }
          },
          title: "Read Emails",
          description:
              "Parse Gmail emails on app launch. Every email is only scanned once.",
          initialValue: canReadEmails,
          icon: appStateSettings["outlinedIcons"]
              ? Icons.mark_email_unread_outlined
              : Icons.mark_email_unread_rounded,
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

Future<void> parseEmailsInBackground(context,
    {bool sayUpdates = false, bool forceParse = false}) async {
  if (appStateSettings["hasSignedIn"] == false) return;
  if (errorSigningInDuringCloud == true) return;
  if (appStateSettings["emailScanning"] == false) return;
  // Prevent sign-in on web - background sign-in cannot access Google Drive etc.
  if (kIsWeb && !entireAppLoaded) return;
  // print(entireAppLoaded);
  //Only run this once, don't run again if the global state changes (e.g. when changing a setting)
  if (entireAppLoaded == false || forceParse) {
    if (appStateSettings["AutoTransactions-canReadEmails"] == true) {
      List<Transaction> transactionsToAdd = [];
      Stopwatch stopwatch = new Stopwatch()..start();
      print("Scanning emails");

      bool hasSignedIn = false;
      if (googleUser == null) {
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

      final authHeaders = await googleUser!.authHeaders;
      final authenticateClient = GoogleAuthClient(authHeaders);
      gMail.GmailApi gmailApi = gMail.GmailApi(authenticateClient);
      gMail.ListMessagesResponse results = await gmailApi.users.messages
          .list(googleUser!.id.toString(), maxResults: amountOfEmails);

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
        loadingProgressKey.currentState
            ?.setProgressPercentage(currentEmailIndex / amountOfEmails);
        // await Future.delayed(Duration(milliseconds: 1000));

        // Remove this to always parse emails
        if (emailsParsed.contains(message.id!)) {
          print("Already checked this email!");
          continue;
        }
        newEmailCount++;

        gMail.Message messageData = await gmailApi.users.messages
            .get(googleUser!.id.toString(), message.id!);
        DateTime messageDate = DateTime.fromMillisecondsSinceEpoch(
            int.parse(messageData.internalDate ?? ""));
        String messageString = getEmailMessage(messageData);
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
              messageString,
              scannerTemplate.titleTransactionBefore,
              scannerTemplate.titleTransactionAfter,
            );
            amountDouble = getTransactionAmountFromEmail(
              messageString,
              scannerTemplate.amountTransactionBefore,
              scannerTemplate.amountTransactionAfter,
            );
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

        TransactionAssociatedTitleWithCategory? foundTitle =
            (await database.getSimilarAssociatedTitles(title: title, limit: 1))
                .firstOrNull;

        TransactionCategory? selectedCategory = foundTitle?.category;
        if (selectedCategory == null) continue;

        title = filterEmailTitle(title);

        await addAssociatedTitles(title, selectedCategory);

        Transaction transactionToAdd = Transaction(
          transactionPk: "-1",
          name: title,
          amount: (amountDouble).abs() * (selectedCategory.income ? 1 : -1),
          note: "",
          categoryFk: selectedCategory.categoryPk,
          walletFk: appStateSettings["selectedWalletPk"],
          dateCreated: messageDate,
          dateTimeModified: null,
          income: selectedCategory.income,
          paid: true,
          skipPaid: false,
          methodAdded: MethodAdded.email,
        );
        transactionsToAdd.add(transactionToAdd);
        openSnackbar(
          SnackbarMessage(
            title: templateFound!.templateName + ": " + "From Email",
            description: title,
            icon: appStateSettings["outlinedIcons"]
                ? Icons.payments_outlined
                : Icons.payments_rounded,
          ),
        );
        // TODO have setting so they can choose if the emails are markes as read
        gmailApi.users.messages.modify(
          gMail.ModifyMessageRequest(removeLabelIds: ["UNREAD"]),
          googleUser!.id,
          message.id!,
        );

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
        await database.createOrUpdateTransaction(insert: true, transaction);
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
      if (newEmailCount > 0 || sayUpdates == true)
        openSnackbar(
          SnackbarMessage(
            title: "Scanned " + results.messages!.length.toString() + " emails",
            description: newEmailCount.toString() +
                pluralString(newEmailCount == 1, " new email"),
            icon: appStateSettings["outlinedIcons"]
                ? Icons.mark_email_unread_outlined
                : Icons.mark_email_unread_rounded,
            onTap: () {
              pushRoute(context, AutoTransactionsPageEmail());
            },
          ),
        );
    }
  }
}

String? getTransactionTitleFromEmail(String messageString,
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

double? getTransactionAmountFromEmail(String messageString,
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
  List<String> messagesList = [];

  @override
  void initState() {
    super.initState();
  }

  init() async {
    loading = true;
    if (googleUser != null) {
      try {
        final authHeaders = await googleUser!.authHeaders;
        final authenticateClient = GoogleAuthClient(authHeaders);
        gMail.GmailApi gmailApi = gMail.GmailApi(authenticateClient);
        gMail.ListMessagesResponse results = await gmailApi.users.messages
            .list(googleUser!.id.toString(), maxResults: amountOfEmails);
        setState(() {
          loaded = true;
          error = "";
        });
        int currentEmailIndex = 0;
        for (gMail.Message message in results.messages!) {
          gMail.Message messageData = await gmailApi.users.messages
              .get(googleUser!.id.toString(), message.id!);
          // print(DateTime.fromMillisecondsSinceEpoch(
          //     int.parse(messageData.internalDate ?? "")));
          String emailMessageString = getEmailMessage(messageData);
          messagesList.add(emailMessageString);
          currentEmailIndex++;
          loadingProgressKey.currentState
              ?.setProgressPercentage(currentEmailIndex / amountOfEmails);
          if (mounted) {
            setState(() {});
          } else {
            loadingProgressKey.currentState?.setProgressPercentage(0);
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
    if (googleUser == null) {
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
                updateGlobalState: false,
              );
            },
            icon: appStateSettings["outlinedIcons"]
                ? Icons.format_list_numbered_outlined
                : Icons.format_list_numbered_rounded,
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
                      icon: appStateSettings["outlinedIcons"]
                          ? Icons.warning_outlined
                          : Icons.warning_rounded,
                      color: Theme.of(context).colorScheme.error,
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
              messagesList: messagesList,
            ),
            borderRadius: 15,
            button: (openContainer) {
              return Row(
                children: [
                  Expanded(
                    child: AddButton(
                      margin: EdgeInsets.only(
                        left: 15,
                        right: 15,
                        bottom: 9,
                        top: 4,
                      ),
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
  final List<String> messagesList;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
      child: OpenContainerNavigation(
        openPage: AddEmailTemplate(
          messagesList: messagesList,
          scannerTemplate: scannerTemplate,
        ),
        borderRadius: 15,
        button: (openContainer) {
          return Tappable(
            borderRadius: 15,
            color: getColor(context, "lightDarkAccent"),
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
                      DeletePopupAction? action = await openDeletePopup(
                        context,
                        title: "Delete template?",
                        subtitle: scannerTemplate.templateName,
                      );
                      if (action == DeletePopupAction.Delete) {
                        await database.deleteScannerTemplate(
                            scannerTemplate.scannerTemplatePk);
                        Navigator.pop(context);
                        openSnackbar(
                          SnackbarMessage(
                            title: "Deleted " + scannerTemplate.templateName,
                            icon: Icons.delete,
                          ),
                        );
                      }
                    },
                    icon: appStateSettings["outlinedIcons"]
                        ? Icons.delete_outlined
                        : Icons.delete_rounded,
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
  final List<String> messagesList;
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
          for (String messageString in messagesList) {
            bool doesEmailContain = false;
            String? title;
            double? amountDouble;
            String? templateFound;

            for (ScannerTemplate scannerTemplate in scannerTemplates) {
              if (messageString.contains(scannerTemplate.contains)) {
                doesEmailContain = true;
                templateFound = scannerTemplate.templateName;
                title = getTransactionTitleFromEmail(
                    messageString,
                    scannerTemplate.titleTransactionBefore,
                    scannerTemplate.titleTransactionAfter);
                amountDouble = getTransactionAmountFromEmail(
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
                              getColor(context, "lightDarkAccent"),
                  onTap: () {
                    if (onTap != null) onTap!(messageString);
                    if (onTap == null)
                      queueTransactionFromMessage(messageString);
                  },
                  child: Row(
                    children: [
                      Expanded(
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
                                          padding: const EdgeInsets.only(
                                              bottom: 8.0),
                                          child: TextFont(
                                            fontSize: 15,
                                            text:
                                                "Amount: Not found / invalid number.",
                                            maxLines: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 8.0),
                                          child: TextFont(
                                            fontSize: 15,
                                            text: "Amount: " +
                                                convertToMoney(
                                                    Provider.of<AllWallets>(
                                                        context),
                                                    amountDouble),
                                            maxLines: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                  : SizedBox(),
                              TextFont(
                                fontSize: 13,
                                text: messageString,
                                maxLines: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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

String getEmailMessage(gMail.Message messageData) {
  String messageEncoded = messageData.payload?.parts?[0].body?.data ?? "";
  String messageString;
  if (messageEncoded == "") {
    gMail.MessagePart payload = messageData.payload!;
    try {
      String htmlString = utf8
          .decode(payload.body!.dataAsBytes)
          .replaceAll("[^\\x00-\\x7F]", "");
      String parsedString = parseHtmlString(htmlString);
      messageString = parsedString;
    } catch (e) {
      messageString = (messageData.snippet ?? "") +
          "\n\n" +
          "There was an error getting the rest of the email";
    }
  } else {
    messageString = parseHtmlString(utf8.decode(base64.decode(messageEncoded)));
  }
  return messageString
      .split(RegExp(r"[ \t\r\f\v]+"))
      .join(" ")
      .replaceAll(new RegExp(r'(?:[\t ]*(?:\r?\n|\r))+'), '\n\n')
      .replaceAll(RegExp(r"(?<=\n) +"), "");
}
