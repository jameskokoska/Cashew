import 'package:budget/struct/settings.dart';
import 'dart:convert';
import 'package:animations/animations.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/main.dart';
import 'package:budget/pages/subscriptionsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/widgets/globalSnackBar.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/openSnackbar.dart';
import 'package:budget/widgets/restartApp.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:universal_html/src/html.dart'
    hide Navigator, Platform, Clipboard, Animation;
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:universal_io/io.dart';
import 'package:universal_html/html.dart' as html;
import 'package:budget/struct/settings.dart';

Future<bool> getExchangeRates() async {
  print("Getting exchange rates for current wallets");
  // List<String?> uniqueCurrencies =
  //     await database.getUniqueCurrenciesFromWallets();
  Map<dynamic, dynamic> cachedCurrencyExchange =
      appStateSettings["cachedCurrencyExchange"];
  try {
    Uri url = Uri.parse(
        "https://cdn.jsdelivr.net/gh/fawazahmed0/currency-api@1/latest/currencies/usd.min.json");
    dynamic response = await http.get(url);
    if (response.statusCode == 200) {
      cachedCurrencyExchange = json.decode(response.body)?["usd"];
    }
  } catch (e) {
    print(e.toString());
  }
  // print(cachedCurrencyExchange);
  updateSettings("cachedCurrencyExchange", cachedCurrencyExchange,
      updateGlobalState: true);
  return true;
}

double? amountRatioToPrimaryCurrencyGivenPk(
    AllWallets allWallets, int walletPk) {
  return amountRatioToPrimaryCurrency(
      allWallets, allWallets.indexedByPk[walletPk]?.currency);
}

double? amountRatioToPrimaryCurrency(
    AllWallets allWallets, String? walletCurrency) {
  if (walletCurrency == null) {
    return 0;
  }
  if (appStateSettings["cachedCurrencyExchange"][walletCurrency] == null) {
    return 0;
  }
  if (allWallets.indexedByPk[appStateSettings["selectedWallet"]]?.currency ==
      walletCurrency) {
    return 1;
  }
  double exchangeRateFromUSDToTarget = appStateSettings[
              "cachedCurrencyExchange"]
          [allWallets.indexedByPk[appStateSettings["selectedWallet"]]?.currency]
      .toDouble();
  double exchangeRateFromCurrentToUSD =
      1 / appStateSettings["cachedCurrencyExchange"][walletCurrency].toDouble();
  return exchangeRateFromUSDToTarget * exchangeRateFromCurrentToUSD;
}

double? amountRatioFromToCurrency(
    String walletCurrencyBefore, String walletCurrencyAfter) {
  if (appStateSettings["cachedCurrencyExchange"][walletCurrencyBefore] ==
          null ||
      appStateSettings["cachedCurrencyExchange"][walletCurrencyAfter] == null) {
    return null;
  }
  double exchangeRateFromUSDToTarget =
      appStateSettings["cachedCurrencyExchange"][walletCurrencyAfter]
          .toDouble();
  double exchangeRateFromCurrentToUSD = 1 /
      appStateSettings["cachedCurrencyExchange"][walletCurrencyBefore]
          .toDouble();
  return exchangeRateFromUSDToTarget * exchangeRateFromCurrentToUSD;
}

// assume selected wallets currency
String getCurrencyString(AllWallets allWallets, {String? currencyKey}) {
  String? selectedWalletCurrency =
      allWallets.indexedByPk[appStateSettings["selectedWallet"]]?.currency;
  return currencyKey != null &&
          currenciesJSON[currencyKey] != null &&
          currenciesJSON[currencyKey]["Symbol"] != null
      ? currenciesJSON[currencyKey]["Symbol"]
      : selectedWalletCurrency == null
          ? ""
          : currenciesJSON[selectedWalletCurrency]["Symbol"];
}
