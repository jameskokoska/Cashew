import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DateTimePickerLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  final MaterialLocalizations materialLocalizations;
  final int? customFirstDayOfWeekIndex;

  const DateTimePickerLocalizationsDelegate(
      {required this.materialLocalizations, this.customFirstDayOfWeekIndex});

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'en';

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      DateTimePickerLocalizations.load(
          locale, materialLocalizations, customFirstDayOfWeekIndex);

  @override
  bool shouldReload(DateTimePickerLocalizationsDelegate old) =>
      materialLocalizations != old.materialLocalizations;
}

class DateTimePickerLocalizations extends DefaultMaterialLocalizations {
  final MaterialLocalizations materialLocalizations;
  final int? customFirstDayOfWeekIndex;

  const DateTimePickerLocalizations({
    required this.materialLocalizations,
    this.customFirstDayOfWeekIndex,
  });

  static Future<MaterialLocalizations> load(
    Locale locale,
    MaterialLocalizations materialLocalizations,
    int? customFirstDayOfWeekIndex,
  ) {
    return SynchronousFuture<DateTimePickerLocalizations>(
      DateTimePickerLocalizations(
        materialLocalizations: materialLocalizations,
        customFirstDayOfWeekIndex: customFirstDayOfWeekIndex,
      ),
    );
  }

  static DateTimePickerLocalizationsDelegate createDelegate(
      MaterialLocalizations materialLocalizations) {
    return DateTimePickerLocalizationsDelegate(
      materialLocalizations: materialLocalizations,
    );
  }

  @override
  int get firstDayOfWeekIndex =>
      customFirstDayOfWeekIndex ?? materialLocalizations.firstDayOfWeekIndex;

  @override
  String get anteMeridiemAbbreviation =>
      materialLocalizations.anteMeridiemAbbreviation;

  @override
  String get postMeridiemAbbreviation =>
      materialLocalizations.postMeridiemAbbreviation;

  @override
  String get cancelButtonLabel => materialLocalizations.cancelButtonLabel;

  @override
  String get closeButtonLabel => materialLocalizations.closeButtonLabel;

  @override
  String get continueButtonLabel => materialLocalizations.continueButtonLabel;

  @override
  String get copyButtonLabel => materialLocalizations.copyButtonLabel;

  @override
  String get cutButtonLabel => materialLocalizations.cutButtonLabel;

  @override
  String get scanTextButtonLabel => materialLocalizations.scanTextButtonLabel;

  @override
  String get okButtonLabel => materialLocalizations.okButtonLabel;

  @override
  String get pasteButtonLabel => materialLocalizations.pasteButtonLabel;

  @override
  String get selectAllButtonLabel => materialLocalizations.selectAllButtonLabel;

  @override
  String get lookUpButtonLabel => materialLocalizations.lookUpButtonLabel;

  @override
  String get searchWebButtonLabel => materialLocalizations.searchWebButtonLabel;

  @override
  String get shareButtonLabel => materialLocalizations.shareButtonLabel;

  @override
  String get viewLicensesButtonLabel =>
      materialLocalizations.viewLicensesButtonLabel;

  @override
  String get timePickerHourModeAnnouncement =>
      materialLocalizations.timePickerHourModeAnnouncement;

  @override
  String get timePickerMinuteModeAnnouncement =>
      materialLocalizations.timePickerMinuteModeAnnouncement;

  @override
  String get modalBarrierDismissLabel =>
      materialLocalizations.modalBarrierDismissLabel;

  @override
  String get menuDismissLabel => materialLocalizations.menuDismissLabel;

  @override
  String get drawerLabel => materialLocalizations.drawerLabel;

  @override
  String get popupMenuLabel => materialLocalizations.popupMenuLabel;

  @override
  String get menuBarMenuLabel => materialLocalizations.menuBarMenuLabel;

  @override
  String get dialogLabel => materialLocalizations.dialogLabel;

  @override
  String get alertDialogLabel => materialLocalizations.alertDialogLabel;

  @override
  String get searchFieldLabel => materialLocalizations.searchFieldLabel;

  @override
  String get currentDateLabel => materialLocalizations.currentDateLabel;

  @override
  String get scrimLabel => materialLocalizations.scrimLabel;

  @override
  String get bottomSheetLabel => materialLocalizations.bottomSheetLabel;

  @override
  String scrimOnTapHint(String modalRouteContentName) =>
      materialLocalizations.scrimOnTapHint(modalRouteContentName);

  @override
  TimeOfDayFormat timeOfDayFormat({bool alwaysUse24HourFormat = false}) =>
      materialLocalizations.timeOfDayFormat(
          alwaysUse24HourFormat: alwaysUse24HourFormat);

  @override
  ScriptCategory get scriptCategory => materialLocalizations.scriptCategory;

  @override
  String formatDecimal(int number) =>
      materialLocalizations.formatDecimal(number);

  @override
  String formatHour(TimeOfDay timeOfDay,
          {bool alwaysUse24HourFormat = false}) =>
      materialLocalizations.formatHour(timeOfDay,
          alwaysUse24HourFormat: alwaysUse24HourFormat);

  @override
  String formatMinute(TimeOfDay timeOfDay) =>
      materialLocalizations.formatMinute(timeOfDay);

  @override
  String formatTimeOfDay(TimeOfDay timeOfDay,
          {bool alwaysUse24HourFormat = false}) =>
      materialLocalizations.formatTimeOfDay(timeOfDay,
          alwaysUse24HourFormat: alwaysUse24HourFormat);

  @override
  String formatYear(DateTime date) => materialLocalizations.formatYear(date);

  @override
  String formatCompactDate(DateTime date) =>
      materialLocalizations.formatCompactDate(date);

  @override
  String formatShortDate(DateTime date) =>
      materialLocalizations.formatShortDate(date);

  @override
  String formatMediumDate(DateTime date) =>
      materialLocalizations.formatMediumDate(date);

  @override
  String formatFullDate(DateTime date) =>
      materialLocalizations.formatFullDate(date);

  @override
  String formatMonthYear(DateTime date) =>
      materialLocalizations.formatMonthYear(date);

  @override
  String formatShortMonthDay(DateTime date) =>
      materialLocalizations.formatShortMonthDay(date);

  @override
  DateTime? parseCompactDate(String? inputString) =>
      materialLocalizations.parseCompactDate(inputString);

  @override
  List<String> get narrowWeekdays => materialLocalizations.narrowWeekdays;

  @override
  String get dateSeparator => materialLocalizations.dateSeparator;

  @override
  String get dateHelpText => materialLocalizations.dateHelpText;

  @override
  String get selectYearSemanticsLabel =>
      materialLocalizations.selectYearSemanticsLabel;

  @override
  String get unspecifiedDate => materialLocalizations.unspecifiedDate;

  @override
  String get unspecifiedDateRange => materialLocalizations.unspecifiedDateRange;

  @override
  String get dateInputLabel => materialLocalizations.dateInputLabel;

  @override
  String get dateRangeStartLabel => materialLocalizations.dateRangeStartLabel;

  @override
  String get dateRangeEndLabel => materialLocalizations.dateRangeEndLabel;

  @override
  String dateRangeStartDateSemanticLabel(String formattedDate) =>
      materialLocalizations.dateRangeStartDateSemanticLabel(formattedDate);

  @override
  String dateRangeEndDateSemanticLabel(String formattedDate) =>
      materialLocalizations.dateRangeEndDateSemanticLabel(formattedDate);

  @override
  String get invalidDateFormatLabel =>
      materialLocalizations.invalidDateFormatLabel;

  @override
  String get invalidDateRangeLabel =>
      materialLocalizations.invalidDateRangeLabel;

  @override
  String get dateOutOfRangeLabel => materialLocalizations.dateOutOfRangeLabel;

  @override
  String get saveButtonLabel => materialLocalizations.saveButtonLabel;

  @override
  String get datePickerHelpText => materialLocalizations.datePickerHelpText;

  @override
  String get dateRangePickerHelpText =>
      materialLocalizations.dateRangePickerHelpText;

  @override
  String get calendarModeButtonLabel =>
      materialLocalizations.calendarModeButtonLabel;

  @override
  String get inputDateModeButtonLabel =>
      materialLocalizations.inputDateModeButtonLabel;

  @override
  String get timePickerDialHelpText =>
      materialLocalizations.timePickerDialHelpText;

  @override
  String get timePickerInputHelpText =>
      materialLocalizations.timePickerInputHelpText;

  @override
  String get timePickerHourLabel => materialLocalizations.timePickerHourLabel;

  @override
  String get timePickerMinuteLabel =>
      materialLocalizations.timePickerMinuteLabel;

  @override
  String get invalidTimeLabel => materialLocalizations.invalidTimeLabel;

  @override
  String get dialModeButtonLabel => materialLocalizations.dialModeButtonLabel;

  @override
  String get inputTimeModeButtonLabel =>
      materialLocalizations.inputTimeModeButtonLabel;

  @override
  String get signedInLabel => materialLocalizations.signedInLabel;

  @override
  String get hideAccountsLabel => materialLocalizations.hideAccountsLabel;

  @override
  String get showAccountsLabel => materialLocalizations.showAccountsLabel;

  @override
  String get expandedIconTapHint => materialLocalizations.expandedIconTapHint;

  @override
  String get collapsedIconTapHint => materialLocalizations.collapsedIconTapHint;

  @override
  String get expansionTileExpandedHint =>
      materialLocalizations.expansionTileExpandedHint;

  @override
  String get expansionTileCollapsedHint =>
      materialLocalizations.expansionTileCollapsedHint;

  @override
  String get expansionTileExpandedTapHint =>
      materialLocalizations.expansionTileExpandedTapHint;

  @override
  String get expansionTileCollapsedTapHint =>
      materialLocalizations.expansionTileCollapsedTapHint;

  @override
  String get expandedHint => materialLocalizations.expandedHint;

  @override
  String get collapsedHint => materialLocalizations.collapsedHint;
}
