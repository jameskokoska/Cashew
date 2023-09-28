import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/pages/aboutPage.dart';
import 'package:budget/struct/currencyFunctions.dart';
import 'package:budget/widgets/noResults.dart';
import 'package:budget/widgets/framework/pageFramework.dart';
import 'package:budget/widgets/openPopup.dart';
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
    Map<dynamic, dynamic> currencyExchangeFiltered = {};
    if (searchCurrenciesText == "") {
      currencyExchangeFiltered = currencyExchange;
    } else {
      for (String key in currencyExchange.keys) {
        String? currencyCountry = currenciesJSON[key]?["CountryName"];
        String? currencyName = currenciesJSON[key]?["currency"];
        if ((searchCurrenciesText.trim() == "" ||
                key
                    .toLowerCase()
                    .contains(searchCurrenciesText.toLowerCase()) ||
                (currencyCountry != null &&
                    currencyCountry
                        .toLowerCase()
                        .contains(searchCurrenciesText.toLowerCase())) ||
                (currencyName != null &&
                    currencyName
                        .toLowerCase()
                        .contains(searchCurrenciesText.toLowerCase()))) &&
            (currencyCountry != null || currencyName != null)) {
          currencyExchangeFiltered[key] = currencyExchange[key];
        }
      }
    }

    return PageFramework(
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
              description: "exchange-rate-notice-description".tr(),
              icon: Icons.info,
              onCancel: () {
                Navigator.pop(context);
              },
              onCancelLabel: "ok".tr(),
            );
          },
          icon: Icon(Icons.info),
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
              padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 10),
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
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        children: [
                          TextFont(
                            text: "",
                            maxLines: 3,
                            fontSize: 18,
                            richTextSpan: [
                              TextSpan(
                                text: " = " +
                                    (1 /
                                            ((amountRatioToPrimaryCurrency(
                                                    Provider.of<AllWallets>(
                                                        context),
                                                    key) ??
                                                1)))
                                        .toStringAsFixed(15),
                                style: TextStyle(
                                  color: getColor(context, "black"),
                                  fontFamily: appStateSettings["font"],
                                  fontFamilyFallback: ['Inter'],
                                ),
                              ),
                              TextSpan(
                                text: " " + key.allCaps,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: appStateSettings["font"],
                                  fontFamilyFallback: ['Inter'],
                                  color: getColor(context, "black"),
                                ),
                              ),
                            ],
                          ),
                        ],
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
