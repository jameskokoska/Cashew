import 'package:budget/struct/settings.dart';
import 'dart:convert';
import 'package:budget/database/tables.dart';
import 'package:budget/main.dart';
import 'package:http/http.dart' as http;

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
  updateSettings(
    "cachedCurrencyExchange",
    cachedCurrencyExchange,
    updateGlobalState:
        appStateSettings["cachedCurrencyExchange"].keys.length <= 0,
  );
  return true;
}

double amountRatioToPrimaryCurrencyGivenPk(
    AllWallets allWallets, String walletPk) {
  if (allWallets.indexedByPk[walletPk] == null) return 1;
  return amountRatioToPrimaryCurrency(
      allWallets, allWallets.indexedByPk[walletPk]?.currency);
}

double amountRatioToPrimaryCurrency(
    AllWallets allWallets, String? walletCurrency) {
  if (walletCurrency == null) {
    return 1;
  }
  if (allWallets.indexedByPk[appStateSettings["selectedWalletPk"]]?.currency ==
      walletCurrency) {
    return 1;
  }
  if (allWallets.indexedByPk[appStateSettings["selectedWalletPk"]] == null) {
    return 1;
  }

  double exchangeRateFromUSDToTarget = getCurrencyExchangeRate(
      allWallets.indexedByPk[appStateSettings["selectedWalletPk"]]?.currency);
  double exchangeRateFromCurrentToUSD =
      1 / getCurrencyExchangeRate(walletCurrency);
  return exchangeRateFromUSDToTarget * exchangeRateFromCurrentToUSD;
}

double? amountRatioFromToCurrency(
    String walletCurrencyBefore, String walletCurrencyAfter) {
  double exchangeRateFromUSDToTarget =
      getCurrencyExchangeRate(walletCurrencyAfter);
  double exchangeRateFromCurrentToUSD =
      1 / getCurrencyExchangeRate(walletCurrencyBefore);
  return exchangeRateFromUSDToTarget * exchangeRateFromCurrentToUSD;
}

// assume selected wallets currency
String getCurrencyString(AllWallets allWallets, {String? currencyKey}) {
  String? selectedWalletCurrency =
      allWallets.indexedByPk[appStateSettings["selectedWalletPk"]]?.currency;
  return currencyKey != null && currenciesJSON[currencyKey] != null
      ? (currenciesJSON[currencyKey]?["Symbol"] ?? "")
      : selectedWalletCurrency == null
          ? ""
          : (currenciesJSON[selectedWalletCurrency]?["Symbol"] ?? "");
}

double getCurrencyExchangeRate(String? currencyKey) {
  if (currencyKey == null || currencyKey == "") return 1;
  if (appStateSettings["customCurrencyAmounts"]?[currencyKey] != null) {
    return appStateSettings["customCurrencyAmounts"][currencyKey].toDouble();
  } else if (appStateSettings["cachedCurrencyExchange"]?[currencyKey] != null) {
    return appStateSettings["cachedCurrencyExchange"][currencyKey].toDouble();
  } else {
    return 1;
  }
}

double budgetAmountToPrimaryCurrency(AllWallets allWallets, Budget budget) {
  return budget.amount *
      (amountRatioToPrimaryCurrencyGivenPk(allWallets, budget.walletFk));
}

double objectiveAmountToPrimaryCurrency(
    AllWallets allWallets, Objective objective) {
  return objective.amount *
      (amountRatioToPrimaryCurrencyGivenPk(allWallets, objective.walletFk));
}

double categoryBudgetLimitToPrimaryCurrency(
    AllWallets allWallets, CategoryBudgetLimit limit) {
  return limit.amount *
      (amountRatioToPrimaryCurrencyGivenPk(allWallets, limit.walletFk));
}

// Positive (input)
double getAmountRatioWalletTransferTo(AllWallets allWallets, String walletToPk,
    {String? enteredAmountWalletPk}) {
  return amountRatioFromToCurrency(
        allWallets
            .indexedByPk[
                enteredAmountWalletPk ?? appStateSettings["selectedWalletPk"]]!
            .currency!,
        allWallets.indexedByPk[walletToPk]!.currency!,
      ) ??
      1;
}

// Negative (output)
double getAmountRatioWalletTransferFrom(
    AllWallets allWallets, String walletFromPk,
    {String? enteredAmountWalletPk}) {
  return -1 *
      (amountRatioFromToCurrency(
            allWallets
                .indexedByPk[enteredAmountWalletPk ??
                    appStateSettings["selectedWalletPk"]]!
                .currency!,
            allWallets.indexedByPk[walletFromPk]!.currency!,
          ) ??
          1);
}
