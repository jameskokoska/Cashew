import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

String globalAppName = "Cashew";

Map<String, Locale> supportedLocales = {
  "en": Locale("en"),
  "fr": Locale("fr"),
  "es": Locale("es"),
  "zh": Locale.fromSubtags(languageCode: "zh", scriptCode: "Hans"),
  "zh_Hant": Locale.fromSubtags(languageCode: "zh", scriptCode: "Hant"),
  "hi": Locale("hi"),
  "ar": Locale("ar"),
  "pt": Locale("pt"),
  "pt_PT": Locale.fromSubtags(languageCode: "pt", countryCode: "PT"),
  "ru": Locale("ru"),
  "ja": Locale("ja"),
  "de": Locale("de"),
  "ko": Locale("ko"),
  "tr": Locale("tr"),
  "it": Locale("it"),
  "vi": Locale("vi"),
  "pl": Locale("pl"),
  "nl": Locale("nl"),
  "th": Locale("th"),
  "cs": Locale("cs"),
  "bn": Locale("bn"),
  "da": Locale("da"),
  "fil": Locale("fil"),
  "fi": Locale("fi"),
  "el": Locale("el"),
  "gu": Locale("gu"),
  "he": Locale("he"),
  "hu": Locale("hu"),
  "id": Locale("id"),
  "ms": Locale("ms"),
  "ml": Locale("ml"),
  "mr": Locale("mr"),
  "no": Locale("no"),
  "fa": Locale("fa"),
  "ro": Locale("ro"),
  "sv": Locale("sv"),
  "ta": Locale("ta"),
  "te": Locale("te"),
  "uk": Locale("uk"),
  "ur": Locale("ur"),
  "sr": Locale("sr"),
  "sw": Locale("sw"),
  "bg": Locale("bg"),
  "sk": Locale("sk"),
  "mk": Locale("mk"),
};

// Fix loading of zh_Hant and other special script languages
// Within easy_localization, supported locale checks the codes properly to see if its supported
// ...LocaleExtension on Locale {
//      bool supports(Locale locale) {...
// For e.g. if system was fr_CA it would check the language code, since we support fr it is marked as supported!
// So it is safe to set useOnlyLangCode to false even when we only support language codes
// Since only the logic for RootBundleAssetLoader relies on useOnlyLangCode, no other functionality of easy_localization does!
class RootBundleAssetLoaderCustomLocaleLoader extends RootBundleAssetLoader {
  const RootBundleAssetLoaderCustomLocaleLoader();

  @override
  String getLocalePath(String basePath, Locale locale) {
    print("Initial Locale: " + locale.toString());

    if (supportedLocales["zh_Hant"] == locale) {
      locale = supportedLocales["zh_Hant"] ?? Locale(locale.languageCode);
    } else if (supportedLocales["pt_PT"] == locale) {
      locale = supportedLocales["pt_PT"] ?? Locale(locale.languageCode);
    } else {
      // We only support the language code right now
      // This implements EasyLocalization( useOnlyLangCode: true ... )
      locale = Locale(locale.languageCode);
    }

    //print("Set Locale: " + locale.toString());

    return '$basePath/${locale.toStringWithSeparator(separator: "-")}.json';
  }
}

// Language names can be found in
// /budget/assets/static/language-names.json
