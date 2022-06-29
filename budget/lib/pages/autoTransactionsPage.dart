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
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/pageFramework.dart';
import 'package:budget/widgets/popupFramework.dart';
import 'package:budget/widgets/selectCategoryImage.dart';
import 'package:budget/widgets/selectColor.dart';
import 'package:budget/widgets/settingsContainers.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:budget/main.dart';
import 'package:installed_apps/app_info.dart';
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
import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import 'package:installed_apps/installed_apps.dart';

void onData(NotificationEvent event) async {
  //Handler for UI
  print("NOTIFICATION");
  print(event.toString());
  print("TRANSACTION ADDING");
  print(await database.createOrUpdateTransaction(
    Transaction(
      transactionPk: DateTime.now().millisecondsSinceEpoch,
      name: "Test Auto",
      amount: 50,
      note: "note",
      categoryFk: 1,
      walletFk: appStateSettings["selectedWallet"],
      dateCreated: DateTime.now(),
      income: false,
      paid: true,
      skipPaid: false,
      labelFks: null,
      // reoccurrence: BudgetReoccurence.daily,
      // periodLength: 0,
      // type: TransactionSpecialType.upcoming,
    ),
  ));
  // print(await database.allTransactions);
  print("------------");
}

void _callback(NotificationEvent evt) {
  print("send evt to ui: $evt");
  final SendPort? send = IsolateNameServer.lookupPortByName("_listener_");
  if (send == null) print("can't find the sender");
  send?.send(evt);
}

ReceivePort port = ReceivePort();

Future<void> initNotificationListener() async {
  NotificationsListener.initialize(callbackHandle: _callback);

  IsolateNameServer.removePortNameMapping("_listener_");
  IsolateNameServer.registerPortWithName(port.sendPort, "_listener_");
  port.listen((message) => onData(message));

// don't use the default receivePort
  // NotificationsListener.receivePort.listen((evt) => onData(evt));

  bool? isR = await NotificationsListener.isRunning;
  print("""Service is ${isR! ? "not " : ""}aleary running""");
}

Future<bool> startListening() async {
  print("start listening");
  bool? hasPermission = await NotificationsListener.hasPermission;
  if (hasPermission == null || hasPermission == false) {
    print("no permission, so open settings");
    NotificationsListener.openPermissionSettings();
  }

  bool? isRunning = await NotificationsListener.isRunning;

  if (isRunning != null && isRunning == false) {
    await NotificationsListener.startService(
        foreground: true, title: "Listener Running", description: "Test");
  }

  while (await NotificationsListener.isRunning == false) {
    await Future.delayed(Duration(milliseconds: 100), () {});
  }
  return true;
}

Future<bool> stopListening() async {
  NotificationsListener.stopService();
  while (await NotificationsListener.isRunning == true) {
    await Future.delayed(Duration(milliseconds: 100), () {});
  }
  return true;
}

class AutoTransactionsPage extends StatefulWidget {
  const AutoTransactionsPage({Key? key}) : super(key: key);

  @override
  State<AutoTransactionsPage> createState() => _AutoTransactionsPageState();
}

class _AutoTransactionsPageState extends State<AutoTransactionsPage> {
  bool canReadNotifs =
      appStateSettings["AutoTransactions-canReadNotifs"] ?? false;
  String selectedAppName =
      appStateSettings["AutoTransactions-selectedAppName"] ?? "";
  String selectedAppPackageName =
      appStateSettings["AutoTransactions-selectedAppPackageName"] ?? "";
  String notificationTitleContains =
      appStateSettings["AutoTransactions-notificationTitleContains"] ?? "";
  String amountTransactionBefore =
      appStateSettings["AutoTransactions-amountTransactionBefore"] ?? "";
  String amountTransactionAfter =
      appStateSettings["AutoTransactions-amountTransactionAfter"] ?? "";
  String titleTransactionBefore =
      appStateSettings["AutoTransactions-titleTransactionBefore"] ?? "";
  String titleTransactionAfter =
      appStateSettings["AutoTransactions-titleTransactionAfter"] ?? "";

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        //Minimize keyboard when tap non interactive widget
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: PageFramework(
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
                  "Transactions can be created automatically based on your phones notifications. This can be useful when you get notifications or emails from your bank, and you want to automatically add these transactions.",
              fontSize: 14,
              maxLines: 10,
            ),
          ),
          SettingsContainerSwitch(
            onSwitched: (value) async {
              if (value == true) {
                await startListening();
                setState(() {
                  canReadNotifs = true;
                });
                updateSettings("AutoTransactions-canReadNotifs", true);
              } else {
                await stopListening();
                setState(() {
                  canReadNotifs = false;
                });
                updateSettings("AutoTransactions-canReadNotifs", false);
              }
            },
            title: "Read Notifications",
            description: "Enable or disable the notification listener",
            initialValue: canReadNotifs,
            icon: Icons.mark_unread_chat_alt_rounded,
          ),
          SizedBox(height: 15),
          IgnorePointer(
            ignoring: !canReadNotifs,
            child: AnimatedScale(
              duration: Duration(milliseconds: 300),
              scale: canReadNotifs ? 1 : 0.98,
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 300),
                opacity: canReadNotifs ? 1 : 0.4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2, left: 15),
                      child: TextFont(
                        text: "Configuration",
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: 10, left: 17, right: 10),
                      child: TextFont(
                        text: "Capitalization is NOT ignored.",
                        fontSize: 14,
                        maxLines: 10,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3, left: 20),
                      child: TextFont(
                        text:
                            "Only scan notifications where this title is included",
                        fontSize: 13,
                        maxLines: 10,
                      ),
                    ),
                    EnterTextButton(
                      title: "Notification Title Contains",
                      placeholder: "Notification title contains...",
                      defaultValue: "",
                      setSelectedText: (_) {},
                    ),
                    SizedBox(height: 7),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3, left: 20),
                      child: TextFont(
                        text:
                            "The amount of the transaction will be after this text",
                        fontSize: 13,
                        maxLines: 10,
                      ),
                    ),
                    EnterTextButton(
                      title:
                          "The amount of the transaction will be after this text",
                      placeholder: "Amount for transaction after...",
                      defaultValue: "",
                      setSelectedText: (_) {},
                    ),
                    SizedBox(height: 7),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3, left: 20),
                      child: TextFont(
                        text:
                            "The amount of the transaction will be before this text",
                        fontSize: 13,
                        maxLines: 10,
                      ),
                    ),
                    EnterTextButton(
                      title:
                          "The amount of the transaction will be before this text",
                      placeholder: "Amount for transaction before...",
                      defaultValue: "",
                      setSelectedText: (_) {},
                    ),
                    SizedBox(height: 7),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3, left: 20),
                      child: TextFont(
                        text:
                            "The title of the transaction will be after this text",
                        fontSize: 13,
                        maxLines: 10,
                      ),
                    ),
                    EnterTextButton(
                      title:
                          "The title of the transaction will be after this text",
                      placeholder: "Title of transaction after...",
                      defaultValue: "",
                      setSelectedText: (_) {},
                    ),
                    SizedBox(height: 7),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3, left: 20),
                      child: TextFont(
                        text:
                            "The title of the transaction will be before this text",
                        fontSize: 13,
                        maxLines: 10,
                      ),
                    ),
                    EnterTextButton(
                      title:
                          "The title of the transaction will be before this text",
                      placeholder: "Title of transaction before...",
                      defaultValue: "",
                      setSelectedText: (_) {},
                    ),
                    SizedBox(height: 13),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 13),
                      child: Button(
                        label: "Select Application",
                        onTap: () {
                          openBottomSheet(
                            context,
                            PopupFramework(
                              title: "Select Application",
                              child: FutureBuilder<List<AppInfo>>(
                                future:
                                    InstalledApps.getInstalledApps(true, true),
                                builder: (BuildContext buildContext,
                                    AsyncSnapshot<List<AppInfo>> snapshot) {
                                  if (snapshot.hasData &&
                                      snapshot.connectionState ==
                                          ConnectionState.done) {
                                    List<Widget> children = [];
                                    for (int i = 0;
                                        i < snapshot.data!.length;
                                        i++) {
                                      AppInfo app = snapshot.data![i];
                                      children.add(
                                        Tappable(
                                          borderRadius: 15,
                                          color: Colors.transparent,
                                          onTap: () {
                                            setState(() {
                                              selectedAppName = app.name!;
                                              selectedAppPackageName =
                                                  app.packageName!;
                                              Navigator.pop(context);
                                            });
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 7),
                                            child: Row(
                                              children: [
                                                CircleAvatar(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  child:
                                                      Image.memory(app.icon!),
                                                ),
                                                SizedBox(width: 15),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      TextFont(
                                                        text: app.name!,
                                                        fontSize: 16,
                                                      ),
                                                      SizedBox(height: 4),
                                                      TextFont(
                                                        text: app.packageName!,
                                                        fontSize: 14,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    return Column(
                                      children: children,
                                    );
                                  }
                                  return Center(
                                    child: Column(
                                      children: [
                                        SizedBox(height: 200),
                                        SizedBox(
                                          child: CircularProgressIndicator(),
                                          height: 50.0,
                                          width: 50.0,
                                        ),
                                        SizedBox(height: 200),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 20, bottom: 4, left: 15),
                      child: TextFont(
                        text: "Sample Notification",
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color:
                            Theme.of(context).colorScheme.lightDarkAccentHeavy,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.end,
                            children: [
                              TextFont(
                                text: selectedAppName,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                textColor:
                                    Theme.of(context).colorScheme.primary,
                              ),
                              SizedBox(width: 5),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 1),
                                child: TextFont(
                                  text: selectedAppPackageName,
                                  fontSize: 13,
                                  textColor:
                                      Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          TextFont(
                            text: "..." + notificationTitleContains + "...",
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            maxLines: 10,
                            textColor: Theme.of(context).colorScheme.secondary,
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
                            textColor: Theme.of(context).colorScheme.tertiary,
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
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
