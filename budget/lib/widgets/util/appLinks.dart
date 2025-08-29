import 'dart:async';
import 'dart:convert';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/addEmailTemplate.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/pages/autoTransactionsPageEmail.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/struct/throttler.dart';
import 'package:budget/widgets/globalSnackbar.dart';
import 'package:budget/widgets/importCSV.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/transactionEntry/transactionEntry.dart';
import 'package:budget/widgets/transactionEntry/transactionLabel.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:budget/struct/commonDateFormats.dart';
import 'package:budget/widgets/tableEntry.dart';
import 'package:provider/provider.dart';

Throttler appLinksThrottler = Throttler(duration: Duration(milliseconds: 350));

class InitializeAppLinks extends StatelessWidget {
  const InitializeAppLinks({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return AppLinksWeb(child: child);
    } else {
      return AppLinksNative(child: child);
    }
  }
}

class AppLinksWeb extends StatefulWidget {
  const AppLinksWeb({required this.child, super.key});
  final Widget child;

  @override
  State<AppLinksWeb> createState() => _AppLinksWebState();
}

class _AppLinksWebState extends State<AppLinksWeb> {
  @override
  void initState() {
    super.initState();
    // This delay is required by the web app
    Future.delayed(Duration(milliseconds: 0), () {
      executeAppLink(navigatorKey.currentContext, Uri.base);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class AppLinksNative extends StatefulWidget {
  const AppLinksNative({required this.child, super.key});
  final Widget child;

  @override
  State<AppLinksNative> createState() => _AppLinksNativeState();
}

class _AppLinksNativeState extends State<AppLinksNative> {
  AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    initAppLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> initAppLinks() async {
    Uri? appLink = await _appLinks.getInitialLink();
    if (appLink != null) {
      // This delay may or may not be needed...
      // we need to make sure Material navigator is accessible by the context though!
      Future.delayed(Duration(milliseconds: 0), () {
        executeAppLink(navigatorKey.currentContext, appLink);
      });
    }

    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      executeAppLink(navigatorKey.currentContext, uri);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

// Supported params in order of parsing - some take precedence over others
//
// messageToParse (standalone, however supports date and dateCreated)
//
// JSON (standalone)
//
// subcategoryPk, subcategory (name), categoryPk, category (name),
// walletPk, account (name), wallet (name),
// date, dateCreated
// amount
// title, name
// notes, note
//
// Don't forget to update the README if this changed

Future<Transaction?> processAddTransactionFromParams(
    BuildContext context, Map<String, String?> params) async {
  MainAndSubcategory mainAndSubCategory =
      await getMainAndSubcategoryFromParams(params);
  TransactionWallet? wallet = await getWalletFromParams(params);
  String walletPk = wallet?.walletPk ?? appStateSettings["selectedWalletPk"];
  DateTime? dateCreated = await getDateTimeFromParams(params, context);
  double amount = getAmountFromParams(params);
  String title = params["title"] ?? params["name"] ?? "";
  String note = params["note"] ?? params["notes"] ?? "";

  if (mainAndSubCategory.main == null) {
    Future.delayed(Duration(milliseconds: 100), () {
      bottomSheetControllerGlobal.snapToExtent(0);
    });
    mainAndSubCategory = await selectCategorySequence(
      context,
      selectedCategory: null,
      setSelectedCategory: (_) {},
      selectedSubCategory: null,
      setSelectedSubCategory: (_) {},
      selectedIncomeInitial: null,
      allowReorder: false,
      extraWidgetBefore: Padding(
        padding: const EdgeInsetsDirectional.only(bottom: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: TableEntry(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 18),
                firstEntry: [
                  convertToMoney(
                      Provider.of<AllWallets>(context, listen: false), amount,
                      currencyKey:
                          Provider.of<AllWallets>(context, listen: false)
                              .indexedByPk[walletPk]
                              ?.currency),
                  if (dateCreated != null) getWordedDate(dateCreated),
                  if (title != "") title,
                  if (note != "") note,
                  if (wallet != null) wallet.name,
                ],
                headers: [
                  "amount".tr(),
                  if (dateCreated != null) "date".tr(),
                  if (title != "") "title".tr(),
                  if (note != "") "note".tr(),
                  if (wallet != null) "account".tr(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  if (mainAndSubCategory.main?.categoryPk == null) {
    openSnackbar(SnackbarMessage(
      title: "category-not-selected".tr(),
      description: "all-transactions-require-a-category".tr(),
      icon: appStateSettings["outlinedIcons"]
          ? Icons.warning_amber_outlined
          : Icons.warning_amber_rounded,
    ));
    return null;
  }

  final int? rowId = await database.createOrUpdateTransaction(
    Transaction(
      transactionPk: "-1",
      name: title,
      amount: amount,
      note: note,
      categoryFk: mainAndSubCategory.main?.categoryPk ?? "",
      subCategoryFk: mainAndSubCategory.sub?.categoryPk,
      walletFk: walletPk,
      dateCreated: dateCreated ?? DateTime.now(),
      income: amount > 0,
      paid: true,
      skipPaid: false,
      methodAdded: MethodAdded.appLink,
    ),
    insert: true,
  );
  if (title != "" && mainAndSubCategory.main != null) {
    await addAssociatedTitles(title, mainAndSubCategory.main!);
  }

  if (rowId != null) {
    final Transaction transactionJustAdded =
        await database.getTransactionFromRowId(rowId);
    flashTransaction(transactionJustAdded.transactionPk);
    openSnackbar(SnackbarMessage(
      title: "added-transaction".tr(),
      description: await getTransactionLabel(transactionJustAdded),
      icon: appStateSettings["outlinedIcons"]
          ? Icons.post_add_outlined
          : Icons.post_add_rounded,
    ));
    return transactionJustAdded;
  }
  return null;
}

Future processAddTransactionRouteFromParams(
    BuildContext context, Map<String, String?> params) async {
  MainAndSubcategory mainAndSubCategory =
      await getMainAndSubcategoryFromParams(params);
  TransactionWallet? wallet = await getWalletFromParams(params);
  DateTime? dateCreated = await getDateTimeFromParams(params, context);
  double amount = getAmountFromParams(params);
  // Add a delay so the keyboard can focus
  await Future.delayed(Duration(milliseconds: 50), () async {
    await pushRoute(
      context,
      AddTransactionPage(
        routesToPopAfterDelete: RoutesToPopAfterDelete.None,
        selectedAmount: amount,
        selectedCategory: mainAndSubCategory.main,
        selectedSubCategory: mainAndSubCategory.sub,
        selectedWallet: wallet,
        selectedDate: dateCreated,
        selectedTitle: params["title"],
        selectedNotes: params["notes"],
      ),
    );
  });
}

Future processMessageToParse(
    BuildContext context, Map<String, String?> params) async {
  String messageString = params["messageToParse"].toString();
  recentCapturedNotifications.insert(0, messageString);
  recentCapturedNotifications.take(50);
  dynamic result = await queueTransactionFromMessage(
    messageString,
    willPushRoute: true,
    dateTime: await getDateTimeFromParams(params, context),
  );
  if (result == false) {
    pushRoute(
      null,
      AddEmailTemplate(
        messagesList: recentCapturedNotifications,
      ),
    );
  }
}

Future executeAppLink(BuildContext? context, Uri uri,
    {Function(dynamic)? onDebug}) async {
  if (appStateSettings["hasOnboarded"] != true) return;
  if (!appLinksThrottler.canProceed()) return;
  String endPoint = getApiEndpoint(uri);
  Map<String, String> params = parseAppLink(uri);
  // Note these URIs must be unique from the launch from widget URIs!
  switch (endPoint) {
    case "addTransaction":
      if (context != null) {
        if (params["messageToParse"] != null &&
            appStateSettings["notificationScanningDebug"] == true) {
          processMessageToParse(context, params);
        } else if (params["JSON"] != null) {
          try {
            Map<String, dynamic> jsonData = json.decode(params["JSON"] ?? "");
            for (dynamic transactionObject in jsonData["transactions"]) {
              Map<String, String> currentObject = {};
              transactionObject.forEach((key, value) {
                currentObject[key] = value.toString();
              });
              dynamic res =
                  await processAddTransactionFromParams(context, currentObject);
              if (onDebug != null) onDebug(res);
            }
          } catch (e) {
            openSnackbar(SnackbarMessage(
              title: "error-parsing-json".tr(),
              description: e.toString(),
              icon: appStateSettings["outlinedIcons"]
                  ? Icons.warning_outlined
                  : Icons.warning_rounded,
            ));
          }
        } else {
          dynamic res = await processAddTransactionFromParams(context, params);
          if (onDebug != null) onDebug(res);
        }
      }
      break;
    case "addTransactionRoute":
      if (context != null) {
        if (params["messageToParse"] != null &&
            appStateSettings["notificationScanningDebug"] == true) {
          processMessageToParse(context, params);
        } else if (params["JSON"] != null) {
          try {
            Map<String, dynamic> jsonData = json.decode(params["JSON"] ?? "");
            for (dynamic transactionObject in jsonData["transactions"]) {
              Map<String, String> currentObject = {};
              transactionObject.forEach((key, value) {
                currentObject[key] = value.toString();
              });
              dynamic res = await processAddTransactionRouteFromParams(
                  context, currentObject);
              if (onDebug != null) onDebug(res);
            }
          } catch (e) {
            openSnackbar(SnackbarMessage(
              title: "error-parsing-json".tr(),
              description: e.toString(),
              icon: appStateSettings["outlinedIcons"]
                  ? Icons.warning_outlined
                  : Icons.warning_rounded,
            ));
          }
        } else {
          dynamic res =
              await processAddTransactionRouteFromParams(context, params);
          if (onDebug != null) onDebug(res);
        }
      }
      break;

    // Ensures we can see other pages of the Cashew website
    // Such as the FAQ
    // default:
    //   if (context != null)
    //     pushRoute(
    //       context,
    //       WebView(initialPageUri: uri),
    //     );
  }
}

// class WebView extends StatefulWidget {
//   const WebView({super.key, required this.initialPageUri});
//   final Uri initialPageUri;

//   @override
//   State<WebView> createState() => _WebViewState();
// }

// class _WebViewState extends State<WebView> {
//   late final WebViewController controller;

//   @override
//   void initState() {
//     super.initState();
//     controller = WebViewController()
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onPageStarted: (String url) {
//             loadingIndeterminateKey.currentState?.setVisibility(true);
//           },
//           onPageFinished: (String url) {
//             loadingIndeterminateKey.currentState?.setVisibility(false);
//           },
//           onNavigationRequest: (NavigationRequest request) {
//             if (request.url.startsWith('https://cashewapp.web.app/')) {
//               return NavigationDecision.navigate;
//             } else {
//               openUrl(request.url);
//               return NavigationDecision.prevent;
//             }
//           },
//         ),
//       )
//       ..loadRequest(
//         widget.initialPageUri,
//       );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(),
//       body: WebViewWidget(controller: controller),
//     );
//   }
// }

double getAmountFromParams(Map<String, String?> params) {
  return double.tryParse(params["amount"] ?? "0") ?? 0;
}

DateTime? getDateTimeFromParams(
    Map<String, String?> params, BuildContext context) {
  DateTime? dateCreated;
  String? dateToParse = params["date"] ?? params["dateCreated"];
  if (dateToParse != null) {
    try {
      dateCreated = DateTime.parse(dateToParse);
      dateCreated = DateTime(
        dateCreated.year,
        dateCreated.month,
        dateCreated.day,
        dateCreated.hour,
        dateCreated.minute,
        dateCreated.second,
      );
    } catch (e) {
      DateTime? result;
      for (String commonFormat in getCommonDateFormats()) {
        result = tryDateFormatting(context, commonFormat, dateToParse);
        if (result != null) break;
      }
      dateCreated = result;
    }
  }

  return dateCreated;
}

Future<MainAndSubcategory> getMainAndSubcategoryFromParams(
    Map<String, String?> params) async {
  MainAndSubcategory mainAndSubcategory = MainAndSubcategory();

  // Handle case where a category AND subcategory is passed in
  // Check for a main category, then find a subcategory in that main category
  // else use default subcategory takes precedence behavior
  if ((params.containsKey("category") || params.containsKey("categoryPk")) &&
      (params.containsKey("subcategory") ||
          params.containsKey("subcategoryPk"))) {
    if (params.containsKey("categoryPk")) {
      mainAndSubcategory.main = await database
          .getCategoryInstanceOrNull(params["categoryPk"].toString());
    }
    if (mainAndSubcategory.main == null && params.containsKey("category")) {
      mainAndSubcategory.main = await database.getRelatingCategory(
        params["category"] ?? "",
        onlySubCategories: false,
      );
    }
    if (mainAndSubcategory.main != null) {
      if (params.containsKey("subcategoryPk")) {
        mainAndSubcategory.sub = await database
            .getCategoryInstanceOrNull(params["subcategoryPk"].toString());
        // Try again if the subcategories main category is not the same
        if (mainAndSubcategory.sub?.mainCategoryPk !=
            mainAndSubcategory.main?.categoryPk) {
          mainAndSubcategory.sub = null;
        }
      }
      if (mainAndSubcategory.sub == null && params.containsKey("subcategory")) {
        mainAndSubcategory.sub = await database.getRelatingCategory(
          params["subcategory"] ?? "",
          onlySubCategories: true,
          mainCategoryPkMustBe: mainAndSubcategory.main?.categoryPk,
        );
      }
      // Return only if we found a subcategory (since this only runs with subcategory param)
      if (mainAndSubcategory.sub != null) {
        return mainAndSubcategory;
      }
    }
  }

  // Subcategory takes precedence
  if (params.containsKey("subcategoryPk")) {
    mainAndSubcategory.sub = await database
        .getCategoryInstanceOrNull(params["subcategoryPk"].toString());
  }
  if (mainAndSubcategory.sub == null && params.containsKey("subcategory")) {
    mainAndSubcategory.sub = await database.getRelatingCategory(
      params["subcategory"] ?? "",
      onlySubCategories: true,
    );
  }
  if (mainAndSubcategory.sub?.mainCategoryPk != null) {
    mainAndSubcategory.main =
        await database.getCategory(mainAndSubcategory.sub!.mainCategoryPk!).$2;
    return mainAndSubcategory;
  }

  if (params.containsKey("categoryPk")) {
    mainAndSubcategory.main = await database
        .getCategoryInstanceOrNull(params["categoryPk"].toString());
  }
  if (mainAndSubcategory.main == null && params.containsKey("category")) {
    mainAndSubcategory.main = await database.getRelatingCategory(
      params["category"] ?? "",
      onlySubCategories: false,
    );
  }
  if (mainAndSubcategory.main == null && params["title"] != null) {
    TransactionAssociatedTitleWithCategory? foundTitle = (await database
            .getSimilarAssociatedTitles(title: params["title"] ?? "", limit: 1))
        .firstOrNull;
    mainAndSubcategory.main = foundTitle?.category;
  }
  return mainAndSubcategory;
}

Future<TransactionWallet?> getWalletFromParams(
    Map<String, String?> params) async {
  TransactionWallet? result;
  if (params.containsKey("walletPk")) {
    result =
        await database.getWalletInstanceOrNull(params["walletPk"].toString());
  }
  if (result == null && params.containsKey("account")) {
    return await database.getRelatingWallet(params["account"] ?? "");
  }
  if (result == null && params.containsKey("wallet")) {
    return await database.getRelatingWallet(params["wallet"] ?? "");
  }
  return result;
}

String getApiEndpoint(Uri uri) {
  return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
}

Map<String, String> parseAppLink(Uri uri) {
  
  Map<String, String> params = {};
  uri.queryParameters.forEach((key, value) {
    params[key] = value;
  });

  return params;
}
