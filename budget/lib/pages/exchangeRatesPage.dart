import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/pages/aboutPage.dart';
import 'package:budget/struct/currencyFunctions.dart';
import 'package:budget/widgets/fadeIn.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/noResults.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/openPopup.dart';
import 'package:budget/widgets/selectAmount.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:budget/main.dart';
import 'package:provider/provider.dart';
import '../functions.dart';
import 'package:budget/struct/settings.dart';

class ExchangeRates extends StatefulWidget {
  const ExchangeRates({super.key});

  @override
  State<ExchangeRates> createState() => _ExchangeRatesState();
}

class _ExchangeRatesState extends State<ExchangeRates> {
  String searchCurrenciesText = "";

  @override
  Widget build(BuildContext context) {
    Map<dynamic, dynamic> currencyExchange =
        appStateSettings["cachedCurrencyExchange"];
    if (currencyExchange.keys.length <= 0) {
      for (String key in currenciesJSON.keys) {
        currencyExchange[key] = 1;
      }
    } else {
      for (String key in [...currencyExchange.keys]) {
        if (currenciesJSON.keys.contains(key) == false) {
          currencyExchange.remove(key);
        }
      }
    }
    Map<dynamic, dynamic> currencyExchangeFiltered = {};
    if (searchCurrenciesText == "") {
      currencyExchangeFiltered = currencyExchange;
    } else {
      for (String key in currencyExchange.keys) {
        String? currencyCountry = currenciesJSON[key]?["CountryName"];
        String? currencyName = currenciesJSON[key]?["Currency"];
        if ((searchCurrenciesText.trim() == "" ||
            key.toLowerCase().contains(searchCurrenciesText.toLowerCase()) ||
            (currencyCountry != null &&
                currencyCountry
                    .toLowerCase()
                    .contains(searchCurrenciesText.toLowerCase())) ||
            (currencyName != null &&
                currencyName
                    .toLowerCase()
                    .contains(searchCurrenciesText.toLowerCase())))) {
          currencyExchangeFiltered[key] = currencyExchange[key];
        }
      }
    }

    return PageFramework(
      horizontalPadding: getHorizontalPaddingConstrained(context),
      dragDownToDismiss: true,
      title: "exchange-rates".tr(),
      actions: [
        IconButton(
          padding: EdgeInsets.all(15),
          tooltip: "info".tr(),
          onPressed: () {
            openPopup(
              context,
              title: "exchange-rate-notice".tr(),
              description: "exchange-rate-notice-description".tr() +
                  "\n\n" +
                  "tap-for-custom-exchange-rate".tr(),
              icon: appStateSettings["outlinedIcons"]
                  ? Icons.info_outlined
                  : Icons.info_outline_rounded,
              onCancel: () {
                Navigator.pop(context);
              },
              onCancelLabel: "ok".tr(),
            );
          },
          icon: Icon(
            appStateSettings["outlinedIcons"]
                ? Icons.info_outlined
                : Icons.info_outline_rounded,
          ),
        ),
      ],
      slivers: [
        SliverToBoxAdapter(
          child: AboutInfoBox(
            title: "exchange-rates-api".tr(),
            link: "https://github.com/fawazahmed0/currency-api",
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: TextInput(
              labelText: "search-currencies-placeholder".tr(),
              icon: appStateSettings["outlinedIcons"]
                  ? Icons.search_outlined
                  : Icons.search_rounded,
              onChanged: (value) {
                setState(() {
                  searchCurrenciesText = value;
                });
              },
              autoFocus: false,
              padding: EdgeInsets.symmetric(horizontal: 15),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 5),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 17),
              child: TextFont(
                text: "tap-for-custom-exchange-rate".tr(),
                maxLines: 2,
                fontSize: 13,
                textColor: getColor(context, "textLight"),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 7),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 5),
              child: TextFont(
                text: "1 " +
                    Provider.of<AllWallets>(context)
                        .indexedByPk[appStateSettings["selectedWalletPk"]]!
                        .currency
                        .toString()
                        .allCaps,
                maxLines: 2,
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        currencyExchangeFiltered.keys.length == 0
            ? SliverToBoxAdapter(
                child: NoResults(message: "no-currencies-found".tr()),
              )
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    String key = currencyExchangeFiltered.keys
                        .toList()[index]
                        .toString();
                    return ScaledAnimatedSwitcher(
                      keyToWatch: (appStateSettings["customCurrencyAmounts"]
                              ?[key])
                          .toString(),
                      key: ValueKey(key),
                      child: Tappable(
                        onTap: () async {
                          await openBottomSheet(
                            context,
                            SetCustomCurrency(currencyKey: key),
                          );
                          setState(() {});
                        },
                        color: appStateSettings["customCurrencyAmounts"]
                                    ?[key] ==
                                null
                            ? Colors.transparent
                            : Theme.of(context).colorScheme.secondaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            children: [
                              TextFont(
                                text: "",
                                maxLines: 3,
                                richTextSpan: [
                                  TextSpan(
                                    text: " = " +
                                        (1 /
                                                ((amountRatioToPrimaryCurrency(
                                                    Provider.of<AllWallets>(
                                                        context),
                                                    key))))
                                            .toStringAsFixed(14),
                                    style: TextStyle(
                                      color: getColor(context, "black"),
                                      fontFamily: appStateSettings["font"],
                                      fontFamilyFallback: ['Inter'],
                                      fontSize: 16,
                                    ),
                                  ),
                                  TextSpan(
                                    text: " " + key.allCaps,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: appStateSettings["font"],
                                      fontFamilyFallback: ['Inter'],
                                      color: getColor(context, "black"),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: currencyExchangeFiltered.keys.length,
                ),
              ),
      ],
    );
  }
}

class SetCustomCurrency extends StatefulWidget {
  const SetCustomCurrency({required this.currencyKey, super.key});
  final String currencyKey;

  @override
  State<SetCustomCurrency> createState() => _SetCustomCurrencyState();
}

class _SetCustomCurrencyState extends State<SetCustomCurrency> {
  @override
  Widget build(BuildContext context) {
    return PopupFramework(
      title: "set-currency".tr(),
      subtitle: "1 " +
          Provider.of<AllWallets>(context)
              .indexedByPk[appStateSettings["selectedWalletPk"]]!
              .currency
              .toString()
              .allCaps +
          " = ",
      child: SelectAmountValue(
        allowZero: true,
        setSelectedAmount: (amount, amountString) {
          Map<dynamic, dynamic> customCurrencyAmountsMap =
              appStateSettings["customCurrencyAmounts"];
          if (amount == 0 || amountString == "") {
            customCurrencyAmountsMap.remove(widget.currencyKey);
          } else {
            customCurrencyAmountsMap[widget.currencyKey] = amount;
          }
          updateSettings("customCurrencyAmounts", customCurrencyAmountsMap,
              updateGlobalState: false);
        },
        amountPassed: appStateSettings["customCurrencyAmounts"]
                    ?[widget.currencyKey] ==
                null
            ? ""
            : removeTrailingZeroes(appStateSettings["customCurrencyAmounts"]
                        ?[widget.currencyKey]
                    .toString() ??
                "0"),
        suffix: " " + widget.currencyKey.allCaps,
        nextLabel: "set-amount".tr(),
        next: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}

String? originalExchangeRatesBeforeOpenString;
void checkIfExchangeRateChangeBefore() {
  originalExchangeRatesBeforeOpenString =
      appStateSettings["customCurrencyAmounts"].toString();
}

bool checkIfExchangeRateChangeAfter() {
  // print(originalExchangeRatesBeforeOpenString);
  // print(appStateSettings["customCurrencyAmounts"].toString());
  if (originalExchangeRatesBeforeOpenString != null &&
      originalExchangeRatesBeforeOpenString !=
          appStateSettings["customCurrencyAmounts"].toString()) {
    print("There was a change to the custom currencies!");
    // Reset global state because currencies need to be reloaded
    appStateKey.currentState?.refreshAppState();
    originalExchangeRatesBeforeOpenString = null;
    return true;
  } else {
    return false;
  }
}
