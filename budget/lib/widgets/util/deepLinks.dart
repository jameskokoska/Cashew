import 'dart:async';

import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/addTransactionPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/globalSnackbar.dart';
import 'package:budget/widgets/importCSV.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/transactionEntry/transactionEntry.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:budget/struct/commonDateFormats.dart';

class InitializeDeepLinks extends StatelessWidget {
  const InitializeDeepLinks({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (getPlatform(ignoreEmulation: true) == PlatformOS.isAndroid) {
      return DeepLinks(child: child);
    } else if (kIsWeb) {
      return DeepLinksWeb(child: child);
    }
    return child;
  }
}

class DeepLinksWeb extends StatefulWidget {
  const DeepLinksWeb({required this.child, super.key});
  final Widget child;

  @override
  State<DeepLinksWeb> createState() => _DeepLinksWebState();
}

class _DeepLinksWebState extends State<DeepLinksWeb> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      executeAppLink(navigatorKey.currentContext, Uri.base);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class DeepLinks extends StatefulWidget {
  const DeepLinks({required this.child, super.key});
  final Widget child;

  @override
  State<DeepLinks> createState() => _DeepLinksState();
}

class _DeepLinksState extends State<DeepLinks> {
  AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> initDeepLinks() async {
    final appLink = await _appLinks.getInitialAppLink();
    if (appLink != null) {
      Future.delayed(Duration(milliseconds: 500), () {
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

executeAppLink(BuildContext? context, Uri uri) async {
  if (appStateSettings["hasOnboarded"] != true) return;

  String endPoint = getApiEndpoint(uri);
  Map<String, String> params = parseAppLink(uri);
  switch (endPoint) {
    case "addTransaction":
      if (context != null) {
        MainAndSubcategory mainAndSubCategory =
            await getMainAndSubcategoryFromParams(params);
        TransactionWallet? wallet = await getWalletFromParams(params);
        DateTime? dateCreated = await getDateTimeFromParams(params, context);
        double amount = getAmountFromParams(params);
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
          return;
        }

        String title = params["title"] ?? "";

        final int? rowId = await database.createOrUpdateTransaction(
          Transaction(
            transactionPk: "-1",
            name: title,
            amount: amount,
            note: params["notes"] ?? "",
            categoryFk: mainAndSubCategory.main?.categoryPk ?? "",
            subCategoryFk: mainAndSubCategory.sub?.categoryPk,
            walletFk: wallet?.walletPk ?? appStateSettings["selectedWalletPk"],
            dateCreated: dateCreated ?? DateTime.now(),
            income: amount > 0,
            paid: true,
            skipPaid: false,
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
        }
      }
      break;
    case "addTransactionRoute":
      if (context != null) {
        MainAndSubcategory mainAndSubCategory =
            await getMainAndSubcategoryFromParams(params);
        TransactionWallet? wallet = await getWalletFromParams(params);
        DateTime? dateCreated = await getDateTimeFromParams(params, context);
        double amount = getAmountFromParams(params);
        pushRoute(
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
      }

      break;
  }
}

double getAmountFromParams(Map<String, String> params) {
  return double.tryParse(params["amount"] ?? "0") ?? 0;
}

DateTime? getDateTimeFromParams(
    Map<String, String> params, BuildContext context) {
  DateTime? dateCreated;
  if (params.containsKey("date")) {
    try {
      dateCreated = DateTime.parse(params["date"] ?? "");
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
        result = tryDateFormatting(context, commonFormat, params["date"] ?? "");
        if (result != null) break;
      }
      dateCreated = result;
    }
  }

  return dateCreated;
}

Future<MainAndSubcategory> getMainAndSubcategoryFromParams(
    Map<String, String> params) async {
  MainAndSubcategory mainAndSubcategory = MainAndSubcategory();

  // Subcategory takes precedence
  if (params.containsKey("subcategory")) {
    TransactionCategory? subCategory = await database.getRelatingCategory(
        params["subcategory"] ?? "",
        onlySubCategories: true,
        limit: 1);
    if (subCategory?.mainCategoryPk != null) {
      mainAndSubcategory.main =
          await database.getCategory(subCategory!.mainCategoryPk!).$2;
      mainAndSubcategory.sub = subCategory;
      return mainAndSubcategory;
    }
  }

  if (params.containsKey("category")) {
    mainAndSubcategory.main = await database.getRelatingCategory(
        params["category"] ?? "",
        onlySubCategories: false,
        limit: 1);
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
    Map<String, String> params) async {
  if (params.containsKey("account")) {
    return await database.getRelatingWallet(params["account"] ?? "", limit: 1);
  } else {
    return null;
  }
}

String getApiEndpoint(Uri uri) {
  return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
}

Map<String, String> parseAppLink(Uri uri) {
  Map<String, String> params = {};

  uri.queryParameters.forEach((key, value) {
    params[key] = Uri.decodeComponent(value);
  });

  return params;
}
