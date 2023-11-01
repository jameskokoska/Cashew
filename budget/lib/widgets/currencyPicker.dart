import 'package:budget/colors.dart';
import 'package:budget/functions.dart';
import 'package:budget/main.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/noResults.dart';
import 'package:budget/widgets/tappable.dart';
import 'package:budget/widgets/textInput.dart';
import 'package:budget/widgets/textWidgets.dart';
import 'package:budget/widgets/viewAllTransactionsButton.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class CurrencyPicker extends StatefulWidget {
  const CurrencyPicker({
    super.key,
    required this.onSelected,
    this.extraButton,
    this.onHasFocus,
    this.initialCurrency,
    this.padding,
  });
  final Function(String) onSelected;
  final Widget? extraButton;
  final Function? onHasFocus;
  final String? initialCurrency;
  final EdgeInsets? padding;

  @override
  State<CurrencyPicker> createState() => _CurrencyPickerState();
}

class _CurrencyPickerState extends State<CurrencyPicker> {
  bool viewAll = false;
  String? selectedCurrency = null;
  String? searchText = "";
  Map<String, dynamic> currencies = {};
  late String? initialCurrency = widget.initialCurrency;
  List<String> popularCurrenciesLocal = popularCurrencies;

  @override
  void initState() {
    super.initState();
    if (widget.initialCurrency == null) {
      setState(() {
        selectedCurrency = getDevicesDefaultCurrencyCode();
      });
    } else {
      setState(() {
        selectedCurrency = widget.initialCurrency;
        if (!popularCurrencies.contains(widget.initialCurrency) &&
            selectedCurrency != "") {
          popularCurrenciesLocal =
              popularCurrencies.sublist(0, popularCurrencies.length - 1);
          popularCurrenciesLocal.insert(0, widget.initialCurrency!);
        }
      });
    }

    populateCurrencies();
  }

  void populateCurrencies() {
    Future.delayed(Duration(milliseconds: 0), () async {
      setState(() {
        currencies = currenciesJSON;
        searchText = "";
      });
    });
  }

  void searchCurrencies(String searchTerm) async {
    if (searchTerm == "") {
      populateCurrencies();
    } else {
      Map<String, dynamic> outCurrencies = {};
      for (String key in currenciesJSON.keys) {
        dynamic currency = currenciesJSON[key];
        if ((currency["CountryName"] != null &&
                currency["CountryName"]
                    .toLowerCase()
                    .contains(searchTerm.toLowerCase())) ||
            (currency["Currency"] != null &&
                currency["Currency"]
                    .toLowerCase()
                    .contains(searchTerm.toLowerCase())) ||
            (currency["Code"] != null &&
                currency["Code"]
                    .toLowerCase()
                    .contains(searchTerm.toLowerCase()))) {
          outCurrencies[key] = currency;
        }
      }
      setState(() {
        currencies = outCurrencies;
        searchText = searchTerm;
      });
    }
  }

  void onSelected(currency) {
    setState(() {
      selectedCurrency = currency;
    });
    if (!popularCurrencies.contains(currency) && selectedCurrency != "") {
      setState(() {
        popularCurrenciesLocal =
            popularCurrencies.sublist(0, popularCurrencies.length - 1);
        popularCurrenciesLocal.insert(0, currency);
      });
    }
    widget.onSelected(currency);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ?? EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Focus(
                  onFocusChange: (hasFocus) {
                    if (hasFocus && widget.onHasFocus != null)
                      widget.onHasFocus!();
                  },
                  child: TextInput(
                    labelText: "search-currencies-placeholder".tr(),
                    icon: appStateSettings["outlinedIcons"]
                        ? Icons.search_outlined
                        : Icons.search_rounded,
                    onChanged: (text) {
                      searchCurrencies(text);
                    },
                    padding: widget.extraButton != null
                        ? EdgeInsets.only(left: 18)
                        : EdgeInsets.zero,
                  ),
                ),
              ),
              if (widget.extraButton != null) widget.extraButton!,
            ],
          ),
          SizedBox(height: 12),
          searchText != "" || viewAll == true
              ? SizedBox.shrink()
              : Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  alignment: WrapAlignment.center,
                  runAlignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    for (String currencyKey in popularCurrenciesLocal)
                      CurrencyItem(
                        currencyKey: currencyKey,
                        selected: selectedCurrency == currencyKey,
                        onSelected: onSelected,
                      )
                  ],
                ),
          searchText != "" || viewAll == true
              ? SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: LowKeyButton(
                    onTap: () {
                      setState(() {
                        viewAll = true;
                      });
                    },
                    text: "view-all-currencies".tr(),
                  ),
                ),
          currencies.length <= 0
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: NoResults(
                    message: "no-currencies-found".tr(),
                  ),
                )
              : SizedBox.shrink(),
          searchText == "" && viewAll == false
              ? SizedBox.shrink()
              : Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  alignment: WrapAlignment.center,
                  runAlignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    for (String currencyKey in currencies.keys)
                      CurrencyItem(
                        currencyKey: currencyKey,
                        selected: selectedCurrency == currencyKey,
                        onSelected: onSelected,
                      )
                  ],
                ),
          currencies.length < 9 && currencies.length > 0
              ? SizedBox(
                  height: 180,
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }
}

class CurrencyItem extends StatelessWidget {
  const CurrencyItem({
    super.key,
    required this.currencyKey,
    required this.selected,
    required this.onSelected,
  });
  final String currencyKey;
  final bool selected;
  final Function(String) onSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 500),
      child: Tappable(
        key: ValueKey(selected),
        onTap: () {
          onSelected(currencyKey);
        },
        borderRadius: 15,
        color: selected
            ? Theme.of(context).colorScheme.secondaryContainer
            : appStateSettings["materialYou"]
                ? dynamicPastel(
                    context, Theme.of(context).colorScheme.secondaryContainer,
                    amountLight: 0.4, amountDark: 0.6)
                : getColor(context, "lightDarkAccent"),
        child: AnimatedContainer(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              width: appStateSettings["materialYou"] ? 2 : 0,
              color: appStateSettings["materialYou"] == true && selected
                  ? Theme.of(context).colorScheme.secondary
                  : Colors.transparent,
            ),
          ),
          duration: Duration(milliseconds: 450),
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: 100, minHeight: 100),
            child: Padding(
              padding: const EdgeInsets.all(13),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (currenciesJSON[currencyKey]?["NotKnown"] != true)
                    TextFont(
                      text: currencyKey.toUpperCase(),
                      fontSize: 18,
                    ),
                  TextFont(
                    text: currenciesJSON[currencyKey]?["Symbol"] == null ||
                            currenciesJSON[currencyKey]?["Symbol"] == ""
                        ? (currenciesJSON[currencyKey]?["Code"]
                                .toString()
                                .allCaps ??
                            "")
                        : (currenciesJSON[currencyKey]?["Symbol"] ?? ""),
                    autoSizeText: true,
                    maxFontSize: 50,
                    fontSize: currenciesJSON[currencyKey]?["NotKnown"] == true
                        ? 20
                        : 25,
                    fontWeight: FontWeight.bold,
                  ),
                  if (((currenciesJSON[currencyKey]?["CountryName"] == null ||
                              currenciesJSON[currencyKey]?["CountryName"] ==
                                  "") &&
                          (currenciesJSON[currencyKey]?["Currency"] == null ||
                              currenciesJSON[currencyKey]?["Currency"] ==
                                  "")) ==
                      false)
                    TextFont(
                      text: currenciesJSON[currencyKey]?["CountryName"] ??
                          (currenciesJSON[currencyKey]["Currency"])
                              .toString()
                              .capitalizeFirst ??
                          "",
                      autoSizeText: true,
                      maxFontSize: 50,
                      fontSize: 10,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
