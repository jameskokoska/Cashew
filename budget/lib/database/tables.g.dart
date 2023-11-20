// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tables.dart';

// ignore_for_file: type=lint
class $WalletsTable extends Wallets
    with TableInfo<$WalletsTable, TransactionWallet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WalletsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _walletPkMeta =
      const VerificationMeta('walletPk');
  @override
  late final GeneratedColumn<String> walletPk = GeneratedColumn<String>(
      'wallet_pk', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => uuid.v4());
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _colourMeta = const VerificationMeta('colour');
  @override
  late final GeneratedColumn<String> colour = GeneratedColumn<String>(
      'colour', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _iconNameMeta =
      const VerificationMeta('iconName');
  @override
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
      'icon_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dateCreatedMeta =
      const VerificationMeta('dateCreated');
  @override
  late final GeneratedColumn<DateTime> dateCreated = GeneratedColumn<DateTime>(
      'date_created', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => new DateTime.now());
  static const VerificationMeta _dateTimeModifiedMeta =
      const VerificationMeta('dateTimeModified');
  @override
  late final GeneratedColumn<DateTime> dateTimeModified =
      GeneratedColumn<DateTime>('date_time_modified', aliasedName, true,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: Constant(DateTime.now()));
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
      'order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _decimalsMeta =
      const VerificationMeta('decimals');
  @override
  late final GeneratedColumn<int> decimals = GeneratedColumn<int>(
      'decimals', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: Constant(2));
  static const VerificationMeta _homePageWidgetDisplayMeta =
      const VerificationMeta('homePageWidgetDisplay');
  @override
  late final GeneratedColumnWithTypeConverter<List<HomePageWidgetDisplay>?,
      String> homePageWidgetDisplay = GeneratedColumn<String>(
          'home_page_widget_display', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant(null))
      .withConverter<List<HomePageWidgetDisplay>?>(
          $WalletsTable.$converterhomePageWidgetDisplayn);
  @override
  List<GeneratedColumn> get $columns => [
        walletPk,
        name,
        colour,
        iconName,
        dateCreated,
        dateTimeModified,
        order,
        currency,
        decimals,
        homePageWidgetDisplay
      ];
  @override
  String get aliasedName => _alias ?? 'wallets';
  @override
  String get actualTableName => 'wallets';
  @override
  VerificationContext validateIntegrity(Insertable<TransactionWallet> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('wallet_pk')) {
      context.handle(_walletPkMeta,
          walletPk.isAcceptableOrUnknown(data['wallet_pk']!, _walletPkMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('colour')) {
      context.handle(_colourMeta,
          colour.isAcceptableOrUnknown(data['colour']!, _colourMeta));
    }
    if (data.containsKey('icon_name')) {
      context.handle(_iconNameMeta,
          iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta));
    }
    if (data.containsKey('date_created')) {
      context.handle(
          _dateCreatedMeta,
          dateCreated.isAcceptableOrUnknown(
              data['date_created']!, _dateCreatedMeta));
    }
    if (data.containsKey('date_time_modified')) {
      context.handle(
          _dateTimeModifiedMeta,
          dateTimeModified.isAcceptableOrUnknown(
              data['date_time_modified']!, _dateTimeModifiedMeta));
    }
    if (data.containsKey('order')) {
      context.handle(
          _orderMeta, order.isAcceptableOrUnknown(data['order']!, _orderMeta));
    } else if (isInserting) {
      context.missing(_orderMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    }
    if (data.containsKey('decimals')) {
      context.handle(_decimalsMeta,
          decimals.isAcceptableOrUnknown(data['decimals']!, _decimalsMeta));
    }
    context.handle(
        _homePageWidgetDisplayMeta, const VerificationResult.success());
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {walletPk};
  @override
  TransactionWallet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionWallet(
      walletPk: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}wallet_pk'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      colour: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}colour']),
      iconName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon_name']),
      dateCreated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_created'])!,
      dateTimeModified: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}date_time_modified']),
      order: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order'])!,
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency']),
      decimals: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}decimals'])!,
      homePageWidgetDisplay: $WalletsTable.$converterhomePageWidgetDisplayn
          .fromSql(attachedDatabase.typeMapping.read(DriftSqlType.string,
              data['${effectivePrefix}home_page_widget_display'])),
    );
  }

  @override
  $WalletsTable createAlias(String alias) {
    return $WalletsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<HomePageWidgetDisplay>, String>
      $converterhomePageWidgetDisplay =
      const HomePageWidgetDisplayListInColumnConverter();
  static TypeConverter<List<HomePageWidgetDisplay>?, String?>
      $converterhomePageWidgetDisplayn =
      NullAwareTypeConverter.wrap($converterhomePageWidgetDisplay);
}

class TransactionWallet extends DataClass
    implements Insertable<TransactionWallet> {
  final String walletPk;
  final String name;
  final String? colour;
  final String? iconName;
  final DateTime dateCreated;
  final DateTime? dateTimeModified;
  final int order;
  final String? currency;
  final int decimals;
  final List<HomePageWidgetDisplay>? homePageWidgetDisplay;
  const TransactionWallet(
      {required this.walletPk,
      required this.name,
      this.colour,
      this.iconName,
      required this.dateCreated,
      this.dateTimeModified,
      required this.order,
      this.currency,
      required this.decimals,
      this.homePageWidgetDisplay});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['wallet_pk'] = Variable<String>(walletPk);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || colour != null) {
      map['colour'] = Variable<String>(colour);
    }
    if (!nullToAbsent || iconName != null) {
      map['icon_name'] = Variable<String>(iconName);
    }
    map['date_created'] = Variable<DateTime>(dateCreated);
    if (!nullToAbsent || dateTimeModified != null) {
      map['date_time_modified'] = Variable<DateTime>(dateTimeModified);
    }
    map['order'] = Variable<int>(order);
    if (!nullToAbsent || currency != null) {
      map['currency'] = Variable<String>(currency);
    }
    map['decimals'] = Variable<int>(decimals);
    if (!nullToAbsent || homePageWidgetDisplay != null) {
      final converter = $WalletsTable.$converterhomePageWidgetDisplayn;
      map['home_page_widget_display'] =
          Variable<String>(converter.toSql(homePageWidgetDisplay));
    }
    return map;
  }

  WalletsCompanion toCompanion(bool nullToAbsent) {
    return WalletsCompanion(
      walletPk: Value(walletPk),
      name: Value(name),
      colour:
          colour == null && nullToAbsent ? const Value.absent() : Value(colour),
      iconName: iconName == null && nullToAbsent
          ? const Value.absent()
          : Value(iconName),
      dateCreated: Value(dateCreated),
      dateTimeModified: dateTimeModified == null && nullToAbsent
          ? const Value.absent()
          : Value(dateTimeModified),
      order: Value(order),
      currency: currency == null && nullToAbsent
          ? const Value.absent()
          : Value(currency),
      decimals: Value(decimals),
      homePageWidgetDisplay: homePageWidgetDisplay == null && nullToAbsent
          ? const Value.absent()
          : Value(homePageWidgetDisplay),
    );
  }

  factory TransactionWallet.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionWallet(
      walletPk: serializer.fromJson<String>(json['walletPk']),
      name: serializer.fromJson<String>(json['name']),
      colour: serializer.fromJson<String?>(json['colour']),
      iconName: serializer.fromJson<String?>(json['iconName']),
      dateCreated: serializer.fromJson<DateTime>(json['dateCreated']),
      dateTimeModified:
          serializer.fromJson<DateTime?>(json['dateTimeModified']),
      order: serializer.fromJson<int>(json['order']),
      currency: serializer.fromJson<String?>(json['currency']),
      decimals: serializer.fromJson<int>(json['decimals']),
      homePageWidgetDisplay: serializer.fromJson<List<HomePageWidgetDisplay>?>(
          json['homePageWidgetDisplay']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'walletPk': serializer.toJson<String>(walletPk),
      'name': serializer.toJson<String>(name),
      'colour': serializer.toJson<String?>(colour),
      'iconName': serializer.toJson<String?>(iconName),
      'dateCreated': serializer.toJson<DateTime>(dateCreated),
      'dateTimeModified': serializer.toJson<DateTime?>(dateTimeModified),
      'order': serializer.toJson<int>(order),
      'currency': serializer.toJson<String?>(currency),
      'decimals': serializer.toJson<int>(decimals),
      'homePageWidgetDisplay': serializer
          .toJson<List<HomePageWidgetDisplay>?>(homePageWidgetDisplay),
    };
  }

  TransactionWallet copyWith(
          {String? walletPk,
          String? name,
          Value<String?> colour = const Value.absent(),
          Value<String?> iconName = const Value.absent(),
          DateTime? dateCreated,
          Value<DateTime?> dateTimeModified = const Value.absent(),
          int? order,
          Value<String?> currency = const Value.absent(),
          int? decimals,
          Value<List<HomePageWidgetDisplay>?> homePageWidgetDisplay =
              const Value.absent()}) =>
      TransactionWallet(
        walletPk: walletPk ?? this.walletPk,
        name: name ?? this.name,
        colour: colour.present ? colour.value : this.colour,
        iconName: iconName.present ? iconName.value : this.iconName,
        dateCreated: dateCreated ?? this.dateCreated,
        dateTimeModified: dateTimeModified.present
            ? dateTimeModified.value
            : this.dateTimeModified,
        order: order ?? this.order,
        currency: currency.present ? currency.value : this.currency,
        decimals: decimals ?? this.decimals,
        homePageWidgetDisplay: homePageWidgetDisplay.present
            ? homePageWidgetDisplay.value
            : this.homePageWidgetDisplay,
      );
  @override
  String toString() {
    return (StringBuffer('TransactionWallet(')
          ..write('walletPk: $walletPk, ')
          ..write('name: $name, ')
          ..write('colour: $colour, ')
          ..write('iconName: $iconName, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateTimeModified: $dateTimeModified, ')
          ..write('order: $order, ')
          ..write('currency: $currency, ')
          ..write('decimals: $decimals, ')
          ..write('homePageWidgetDisplay: $homePageWidgetDisplay')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(walletPk, name, colour, iconName, dateCreated,
      dateTimeModified, order, currency, decimals, homePageWidgetDisplay);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionWallet &&
          other.walletPk == this.walletPk &&
          other.name == this.name &&
          other.colour == this.colour &&
          other.iconName == this.iconName &&
          other.dateCreated == this.dateCreated &&
          other.dateTimeModified == this.dateTimeModified &&
          other.order == this.order &&
          other.currency == this.currency &&
          other.decimals == this.decimals &&
          other.homePageWidgetDisplay == this.homePageWidgetDisplay);
}

class WalletsCompanion extends UpdateCompanion<TransactionWallet> {
  final Value<String> walletPk;
  final Value<String> name;
  final Value<String?> colour;
  final Value<String?> iconName;
  final Value<DateTime> dateCreated;
  final Value<DateTime?> dateTimeModified;
  final Value<int> order;
  final Value<String?> currency;
  final Value<int> decimals;
  final Value<List<HomePageWidgetDisplay>?> homePageWidgetDisplay;
  final Value<int> rowid;
  const WalletsCompanion({
    this.walletPk = const Value.absent(),
    this.name = const Value.absent(),
    this.colour = const Value.absent(),
    this.iconName = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.dateTimeModified = const Value.absent(),
    this.order = const Value.absent(),
    this.currency = const Value.absent(),
    this.decimals = const Value.absent(),
    this.homePageWidgetDisplay = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WalletsCompanion.insert({
    this.walletPk = const Value.absent(),
    required String name,
    this.colour = const Value.absent(),
    this.iconName = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.dateTimeModified = const Value.absent(),
    required int order,
    this.currency = const Value.absent(),
    this.decimals = const Value.absent(),
    this.homePageWidgetDisplay = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : name = Value(name),
        order = Value(order);
  static Insertable<TransactionWallet> custom({
    Expression<String>? walletPk,
    Expression<String>? name,
    Expression<String>? colour,
    Expression<String>? iconName,
    Expression<DateTime>? dateCreated,
    Expression<DateTime>? dateTimeModified,
    Expression<int>? order,
    Expression<String>? currency,
    Expression<int>? decimals,
    Expression<String>? homePageWidgetDisplay,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (walletPk != null) 'wallet_pk': walletPk,
      if (name != null) 'name': name,
      if (colour != null) 'colour': colour,
      if (iconName != null) 'icon_name': iconName,
      if (dateCreated != null) 'date_created': dateCreated,
      if (dateTimeModified != null) 'date_time_modified': dateTimeModified,
      if (order != null) 'order': order,
      if (currency != null) 'currency': currency,
      if (decimals != null) 'decimals': decimals,
      if (homePageWidgetDisplay != null)
        'home_page_widget_display': homePageWidgetDisplay,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WalletsCompanion copyWith(
      {Value<String>? walletPk,
      Value<String>? name,
      Value<String?>? colour,
      Value<String?>? iconName,
      Value<DateTime>? dateCreated,
      Value<DateTime?>? dateTimeModified,
      Value<int>? order,
      Value<String?>? currency,
      Value<int>? decimals,
      Value<List<HomePageWidgetDisplay>?>? homePageWidgetDisplay,
      Value<int>? rowid}) {
    return WalletsCompanion(
      walletPk: walletPk ?? this.walletPk,
      name: name ?? this.name,
      colour: colour ?? this.colour,
      iconName: iconName ?? this.iconName,
      dateCreated: dateCreated ?? this.dateCreated,
      dateTimeModified: dateTimeModified ?? this.dateTimeModified,
      order: order ?? this.order,
      currency: currency ?? this.currency,
      decimals: decimals ?? this.decimals,
      homePageWidgetDisplay:
          homePageWidgetDisplay ?? this.homePageWidgetDisplay,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (walletPk.present) {
      map['wallet_pk'] = Variable<String>(walletPk.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (colour.present) {
      map['colour'] = Variable<String>(colour.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    if (dateCreated.present) {
      map['date_created'] = Variable<DateTime>(dateCreated.value);
    }
    if (dateTimeModified.present) {
      map['date_time_modified'] = Variable<DateTime>(dateTimeModified.value);
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (decimals.present) {
      map['decimals'] = Variable<int>(decimals.value);
    }
    if (homePageWidgetDisplay.present) {
      final converter = $WalletsTable.$converterhomePageWidgetDisplayn;
      map['home_page_widget_display'] =
          Variable<String>(converter.toSql(homePageWidgetDisplay.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WalletsCompanion(')
          ..write('walletPk: $walletPk, ')
          ..write('name: $name, ')
          ..write('colour: $colour, ')
          ..write('iconName: $iconName, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateTimeModified: $dateTimeModified, ')
          ..write('order: $order, ')
          ..write('currency: $currency, ')
          ..write('decimals: $decimals, ')
          ..write('homePageWidgetDisplay: $homePageWidgetDisplay, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, TransactionCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _categoryPkMeta =
      const VerificationMeta('categoryPk');
  @override
  late final GeneratedColumn<String> categoryPk = GeneratedColumn<String>(
      'category_pk', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => uuid.v4());
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _colourMeta = const VerificationMeta('colour');
  @override
  late final GeneratedColumn<String> colour = GeneratedColumn<String>(
      'colour', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _iconNameMeta =
      const VerificationMeta('iconName');
  @override
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
      'icon_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _emojiIconNameMeta =
      const VerificationMeta('emojiIconName');
  @override
  late final GeneratedColumn<String> emojiIconName = GeneratedColumn<String>(
      'emoji_icon_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dateCreatedMeta =
      const VerificationMeta('dateCreated');
  @override
  late final GeneratedColumn<DateTime> dateCreated = GeneratedColumn<DateTime>(
      'date_created', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => new DateTime.now());
  static const VerificationMeta _dateTimeModifiedMeta =
      const VerificationMeta('dateTimeModified');
  @override
  late final GeneratedColumn<DateTime> dateTimeModified =
      GeneratedColumn<DateTime>('date_time_modified', aliasedName, true,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: Constant(DateTime.now()));
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
      'order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _incomeMeta = const VerificationMeta('income');
  @override
  late final GeneratedColumn<bool> income = GeneratedColumn<bool>(
      'income', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("income" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _methodAddedMeta =
      const VerificationMeta('methodAdded');
  @override
  late final GeneratedColumnWithTypeConverter<MethodAdded?, int> methodAdded =
      GeneratedColumn<int>('method_added', aliasedName, true,
              type: DriftSqlType.int, requiredDuringInsert: false)
          .withConverter<MethodAdded?>($CategoriesTable.$convertermethodAddedn);
  static const VerificationMeta _mainCategoryPkMeta =
      const VerificationMeta('mainCategoryPk');
  @override
  late final GeneratedColumn<String> mainCategoryPk = GeneratedColumn<String>(
      'main_category_pk', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES categories (category_pk)'),
      defaultValue: const Constant(null));
  @override
  List<GeneratedColumn> get $columns => [
        categoryPk,
        name,
        colour,
        iconName,
        emojiIconName,
        dateCreated,
        dateTimeModified,
        order,
        income,
        methodAdded,
        mainCategoryPk
      ];
  @override
  String get aliasedName => _alias ?? 'categories';
  @override
  String get actualTableName => 'categories';
  @override
  VerificationContext validateIntegrity(
      Insertable<TransactionCategory> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('category_pk')) {
      context.handle(
          _categoryPkMeta,
          categoryPk.isAcceptableOrUnknown(
              data['category_pk']!, _categoryPkMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('colour')) {
      context.handle(_colourMeta,
          colour.isAcceptableOrUnknown(data['colour']!, _colourMeta));
    }
    if (data.containsKey('icon_name')) {
      context.handle(_iconNameMeta,
          iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta));
    }
    if (data.containsKey('emoji_icon_name')) {
      context.handle(
          _emojiIconNameMeta,
          emojiIconName.isAcceptableOrUnknown(
              data['emoji_icon_name']!, _emojiIconNameMeta));
    }
    if (data.containsKey('date_created')) {
      context.handle(
          _dateCreatedMeta,
          dateCreated.isAcceptableOrUnknown(
              data['date_created']!, _dateCreatedMeta));
    }
    if (data.containsKey('date_time_modified')) {
      context.handle(
          _dateTimeModifiedMeta,
          dateTimeModified.isAcceptableOrUnknown(
              data['date_time_modified']!, _dateTimeModifiedMeta));
    }
    if (data.containsKey('order')) {
      context.handle(
          _orderMeta, order.isAcceptableOrUnknown(data['order']!, _orderMeta));
    } else if (isInserting) {
      context.missing(_orderMeta);
    }
    if (data.containsKey('income')) {
      context.handle(_incomeMeta,
          income.isAcceptableOrUnknown(data['income']!, _incomeMeta));
    }
    context.handle(_methodAddedMeta, const VerificationResult.success());
    if (data.containsKey('main_category_pk')) {
      context.handle(
          _mainCategoryPkMeta,
          mainCategoryPk.isAcceptableOrUnknown(
              data['main_category_pk']!, _mainCategoryPkMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {categoryPk};
  @override
  TransactionCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionCategory(
      categoryPk: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_pk'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      colour: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}colour']),
      iconName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon_name']),
      emojiIconName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}emoji_icon_name']),
      dateCreated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_created'])!,
      dateTimeModified: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}date_time_modified']),
      order: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order'])!,
      income: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}income'])!,
      methodAdded: $CategoriesTable.$convertermethodAddedn.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.int, data['${effectivePrefix}method_added'])),
      mainCategoryPk: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}main_category_pk']),
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MethodAdded, int, int> $convertermethodAdded =
      const EnumIndexConverter<MethodAdded>(MethodAdded.values);
  static JsonTypeConverter2<MethodAdded?, int?, int?> $convertermethodAddedn =
      JsonTypeConverter2.asNullable($convertermethodAdded);
}

class TransactionCategory extends DataClass
    implements Insertable<TransactionCategory> {
  final String categoryPk;
  final String name;
  final String? colour;
  final String? iconName;
  final String? emojiIconName;
  final DateTime dateCreated;
  final DateTime? dateTimeModified;
  final int order;
  final bool income;
  final MethodAdded? methodAdded;
  final String? mainCategoryPk;
  const TransactionCategory(
      {required this.categoryPk,
      required this.name,
      this.colour,
      this.iconName,
      this.emojiIconName,
      required this.dateCreated,
      this.dateTimeModified,
      required this.order,
      required this.income,
      this.methodAdded,
      this.mainCategoryPk});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['category_pk'] = Variable<String>(categoryPk);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || colour != null) {
      map['colour'] = Variable<String>(colour);
    }
    if (!nullToAbsent || iconName != null) {
      map['icon_name'] = Variable<String>(iconName);
    }
    if (!nullToAbsent || emojiIconName != null) {
      map['emoji_icon_name'] = Variable<String>(emojiIconName);
    }
    map['date_created'] = Variable<DateTime>(dateCreated);
    if (!nullToAbsent || dateTimeModified != null) {
      map['date_time_modified'] = Variable<DateTime>(dateTimeModified);
    }
    map['order'] = Variable<int>(order);
    map['income'] = Variable<bool>(income);
    if (!nullToAbsent || methodAdded != null) {
      final converter = $CategoriesTable.$convertermethodAddedn;
      map['method_added'] = Variable<int>(converter.toSql(methodAdded));
    }
    if (!nullToAbsent || mainCategoryPk != null) {
      map['main_category_pk'] = Variable<String>(mainCategoryPk);
    }
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      categoryPk: Value(categoryPk),
      name: Value(name),
      colour:
          colour == null && nullToAbsent ? const Value.absent() : Value(colour),
      iconName: iconName == null && nullToAbsent
          ? const Value.absent()
          : Value(iconName),
      emojiIconName: emojiIconName == null && nullToAbsent
          ? const Value.absent()
          : Value(emojiIconName),
      dateCreated: Value(dateCreated),
      dateTimeModified: dateTimeModified == null && nullToAbsent
          ? const Value.absent()
          : Value(dateTimeModified),
      order: Value(order),
      income: Value(income),
      methodAdded: methodAdded == null && nullToAbsent
          ? const Value.absent()
          : Value(methodAdded),
      mainCategoryPk: mainCategoryPk == null && nullToAbsent
          ? const Value.absent()
          : Value(mainCategoryPk),
    );
  }

  factory TransactionCategory.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionCategory(
      categoryPk: serializer.fromJson<String>(json['categoryPk']),
      name: serializer.fromJson<String>(json['name']),
      colour: serializer.fromJson<String?>(json['colour']),
      iconName: serializer.fromJson<String?>(json['iconName']),
      emojiIconName: serializer.fromJson<String?>(json['emojiIconName']),
      dateCreated: serializer.fromJson<DateTime>(json['dateCreated']),
      dateTimeModified:
          serializer.fromJson<DateTime?>(json['dateTimeModified']),
      order: serializer.fromJson<int>(json['order']),
      income: serializer.fromJson<bool>(json['income']),
      methodAdded: $CategoriesTable.$convertermethodAddedn
          .fromJson(serializer.fromJson<int?>(json['methodAdded'])),
      mainCategoryPk: serializer.fromJson<String?>(json['mainCategoryPk']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'categoryPk': serializer.toJson<String>(categoryPk),
      'name': serializer.toJson<String>(name),
      'colour': serializer.toJson<String?>(colour),
      'iconName': serializer.toJson<String?>(iconName),
      'emojiIconName': serializer.toJson<String?>(emojiIconName),
      'dateCreated': serializer.toJson<DateTime>(dateCreated),
      'dateTimeModified': serializer.toJson<DateTime?>(dateTimeModified),
      'order': serializer.toJson<int>(order),
      'income': serializer.toJson<bool>(income),
      'methodAdded': serializer.toJson<int?>(
          $CategoriesTable.$convertermethodAddedn.toJson(methodAdded)),
      'mainCategoryPk': serializer.toJson<String?>(mainCategoryPk),
    };
  }

  TransactionCategory copyWith(
          {String? categoryPk,
          String? name,
          Value<String?> colour = const Value.absent(),
          Value<String?> iconName = const Value.absent(),
          Value<String?> emojiIconName = const Value.absent(),
          DateTime? dateCreated,
          Value<DateTime?> dateTimeModified = const Value.absent(),
          int? order,
          bool? income,
          Value<MethodAdded?> methodAdded = const Value.absent(),
          Value<String?> mainCategoryPk = const Value.absent()}) =>
      TransactionCategory(
        categoryPk: categoryPk ?? this.categoryPk,
        name: name ?? this.name,
        colour: colour.present ? colour.value : this.colour,
        iconName: iconName.present ? iconName.value : this.iconName,
        emojiIconName:
            emojiIconName.present ? emojiIconName.value : this.emojiIconName,
        dateCreated: dateCreated ?? this.dateCreated,
        dateTimeModified: dateTimeModified.present
            ? dateTimeModified.value
            : this.dateTimeModified,
        order: order ?? this.order,
        income: income ?? this.income,
        methodAdded: methodAdded.present ? methodAdded.value : this.methodAdded,
        mainCategoryPk:
            mainCategoryPk.present ? mainCategoryPk.value : this.mainCategoryPk,
      );
  @override
  String toString() {
    return (StringBuffer('TransactionCategory(')
          ..write('categoryPk: $categoryPk, ')
          ..write('name: $name, ')
          ..write('colour: $colour, ')
          ..write('iconName: $iconName, ')
          ..write('emojiIconName: $emojiIconName, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateTimeModified: $dateTimeModified, ')
          ..write('order: $order, ')
          ..write('income: $income, ')
          ..write('methodAdded: $methodAdded, ')
          ..write('mainCategoryPk: $mainCategoryPk')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      categoryPk,
      name,
      colour,
      iconName,
      emojiIconName,
      dateCreated,
      dateTimeModified,
      order,
      income,
      methodAdded,
      mainCategoryPk);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionCategory &&
          other.categoryPk == this.categoryPk &&
          other.name == this.name &&
          other.colour == this.colour &&
          other.iconName == this.iconName &&
          other.emojiIconName == this.emojiIconName &&
          other.dateCreated == this.dateCreated &&
          other.dateTimeModified == this.dateTimeModified &&
          other.order == this.order &&
          other.income == this.income &&
          other.methodAdded == this.methodAdded &&
          other.mainCategoryPk == this.mainCategoryPk);
}

class CategoriesCompanion extends UpdateCompanion<TransactionCategory> {
  final Value<String> categoryPk;
  final Value<String> name;
  final Value<String?> colour;
  final Value<String?> iconName;
  final Value<String?> emojiIconName;
  final Value<DateTime> dateCreated;
  final Value<DateTime?> dateTimeModified;
  final Value<int> order;
  final Value<bool> income;
  final Value<MethodAdded?> methodAdded;
  final Value<String?> mainCategoryPk;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.categoryPk = const Value.absent(),
    this.name = const Value.absent(),
    this.colour = const Value.absent(),
    this.iconName = const Value.absent(),
    this.emojiIconName = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.dateTimeModified = const Value.absent(),
    this.order = const Value.absent(),
    this.income = const Value.absent(),
    this.methodAdded = const Value.absent(),
    this.mainCategoryPk = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.categoryPk = const Value.absent(),
    required String name,
    this.colour = const Value.absent(),
    this.iconName = const Value.absent(),
    this.emojiIconName = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.dateTimeModified = const Value.absent(),
    required int order,
    this.income = const Value.absent(),
    this.methodAdded = const Value.absent(),
    this.mainCategoryPk = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : name = Value(name),
        order = Value(order);
  static Insertable<TransactionCategory> custom({
    Expression<String>? categoryPk,
    Expression<String>? name,
    Expression<String>? colour,
    Expression<String>? iconName,
    Expression<String>? emojiIconName,
    Expression<DateTime>? dateCreated,
    Expression<DateTime>? dateTimeModified,
    Expression<int>? order,
    Expression<bool>? income,
    Expression<int>? methodAdded,
    Expression<String>? mainCategoryPk,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (categoryPk != null) 'category_pk': categoryPk,
      if (name != null) 'name': name,
      if (colour != null) 'colour': colour,
      if (iconName != null) 'icon_name': iconName,
      if (emojiIconName != null) 'emoji_icon_name': emojiIconName,
      if (dateCreated != null) 'date_created': dateCreated,
      if (dateTimeModified != null) 'date_time_modified': dateTimeModified,
      if (order != null) 'order': order,
      if (income != null) 'income': income,
      if (methodAdded != null) 'method_added': methodAdded,
      if (mainCategoryPk != null) 'main_category_pk': mainCategoryPk,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith(
      {Value<String>? categoryPk,
      Value<String>? name,
      Value<String?>? colour,
      Value<String?>? iconName,
      Value<String?>? emojiIconName,
      Value<DateTime>? dateCreated,
      Value<DateTime?>? dateTimeModified,
      Value<int>? order,
      Value<bool>? income,
      Value<MethodAdded?>? methodAdded,
      Value<String?>? mainCategoryPk,
      Value<int>? rowid}) {
    return CategoriesCompanion(
      categoryPk: categoryPk ?? this.categoryPk,
      name: name ?? this.name,
      colour: colour ?? this.colour,
      iconName: iconName ?? this.iconName,
      emojiIconName: emojiIconName ?? this.emojiIconName,
      dateCreated: dateCreated ?? this.dateCreated,
      dateTimeModified: dateTimeModified ?? this.dateTimeModified,
      order: order ?? this.order,
      income: income ?? this.income,
      methodAdded: methodAdded ?? this.methodAdded,
      mainCategoryPk: mainCategoryPk ?? this.mainCategoryPk,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (categoryPk.present) {
      map['category_pk'] = Variable<String>(categoryPk.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (colour.present) {
      map['colour'] = Variable<String>(colour.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    if (emojiIconName.present) {
      map['emoji_icon_name'] = Variable<String>(emojiIconName.value);
    }
    if (dateCreated.present) {
      map['date_created'] = Variable<DateTime>(dateCreated.value);
    }
    if (dateTimeModified.present) {
      map['date_time_modified'] = Variable<DateTime>(dateTimeModified.value);
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    if (income.present) {
      map['income'] = Variable<bool>(income.value);
    }
    if (methodAdded.present) {
      final converter = $CategoriesTable.$convertermethodAddedn;
      map['method_added'] = Variable<int>(converter.toSql(methodAdded.value));
    }
    if (mainCategoryPk.present) {
      map['main_category_pk'] = Variable<String>(mainCategoryPk.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('categoryPk: $categoryPk, ')
          ..write('name: $name, ')
          ..write('colour: $colour, ')
          ..write('iconName: $iconName, ')
          ..write('emojiIconName: $emojiIconName, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateTimeModified: $dateTimeModified, ')
          ..write('order: $order, ')
          ..write('income: $income, ')
          ..write('methodAdded: $methodAdded, ')
          ..write('mainCategoryPk: $mainCategoryPk, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ObjectivesTable extends Objectives
    with TableInfo<$ObjectivesTable, Objective> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ObjectivesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _objectivePkMeta =
      const VerificationMeta('objectivePk');
  @override
  late final GeneratedColumn<String> objectivePk = GeneratedColumn<String>(
      'objective_pk', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => uuid.v4());
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
      'order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _colourMeta = const VerificationMeta('colour');
  @override
  late final GeneratedColumn<String> colour = GeneratedColumn<String>(
      'colour', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _dateCreatedMeta =
      const VerificationMeta('dateCreated');
  @override
  late final GeneratedColumn<DateTime> dateCreated = GeneratedColumn<DateTime>(
      'date_created', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => new DateTime.now());
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
      'end_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _dateTimeModifiedMeta =
      const VerificationMeta('dateTimeModified');
  @override
  late final GeneratedColumn<DateTime> dateTimeModified =
      GeneratedColumn<DateTime>('date_time_modified', aliasedName, true,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: Constant(DateTime.now()));
  static const VerificationMeta _iconNameMeta =
      const VerificationMeta('iconName');
  @override
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
      'icon_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _emojiIconNameMeta =
      const VerificationMeta('emojiIconName');
  @override
  late final GeneratedColumn<String> emojiIconName = GeneratedColumn<String>(
      'emoji_icon_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _incomeMeta = const VerificationMeta('income');
  @override
  late final GeneratedColumn<bool> income = GeneratedColumn<bool>(
      'income', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("income" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _pinnedMeta = const VerificationMeta('pinned');
  @override
  late final GeneratedColumn<bool> pinned = GeneratedColumn<bool>(
      'pinned', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("pinned" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _walletFkMeta =
      const VerificationMeta('walletFk');
  @override
  late final GeneratedColumn<String> walletFk = GeneratedColumn<String>(
      'wallet_fk', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES wallets (wallet_pk)'),
      defaultValue: const Constant("0"));
  @override
  List<GeneratedColumn> get $columns => [
        objectivePk,
        name,
        amount,
        order,
        colour,
        dateCreated,
        endDate,
        dateTimeModified,
        iconName,
        emojiIconName,
        income,
        pinned,
        walletFk
      ];
  @override
  String get aliasedName => _alias ?? 'objectives';
  @override
  String get actualTableName => 'objectives';
  @override
  VerificationContext validateIntegrity(Insertable<Objective> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('objective_pk')) {
      context.handle(
          _objectivePkMeta,
          objectivePk.isAcceptableOrUnknown(
              data['objective_pk']!, _objectivePkMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('order')) {
      context.handle(
          _orderMeta, order.isAcceptableOrUnknown(data['order']!, _orderMeta));
    } else if (isInserting) {
      context.missing(_orderMeta);
    }
    if (data.containsKey('colour')) {
      context.handle(_colourMeta,
          colour.isAcceptableOrUnknown(data['colour']!, _colourMeta));
    }
    if (data.containsKey('date_created')) {
      context.handle(
          _dateCreatedMeta,
          dateCreated.isAcceptableOrUnknown(
              data['date_created']!, _dateCreatedMeta));
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    }
    if (data.containsKey('date_time_modified')) {
      context.handle(
          _dateTimeModifiedMeta,
          dateTimeModified.isAcceptableOrUnknown(
              data['date_time_modified']!, _dateTimeModifiedMeta));
    }
    if (data.containsKey('icon_name')) {
      context.handle(_iconNameMeta,
          iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta));
    }
    if (data.containsKey('emoji_icon_name')) {
      context.handle(
          _emojiIconNameMeta,
          emojiIconName.isAcceptableOrUnknown(
              data['emoji_icon_name']!, _emojiIconNameMeta));
    }
    if (data.containsKey('income')) {
      context.handle(_incomeMeta,
          income.isAcceptableOrUnknown(data['income']!, _incomeMeta));
    }
    if (data.containsKey('pinned')) {
      context.handle(_pinnedMeta,
          pinned.isAcceptableOrUnknown(data['pinned']!, _pinnedMeta));
    }
    if (data.containsKey('wallet_fk')) {
      context.handle(_walletFkMeta,
          walletFk.isAcceptableOrUnknown(data['wallet_fk']!, _walletFkMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {objectivePk};
  @override
  Objective map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Objective(
      objectivePk: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}objective_pk'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      order: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order'])!,
      colour: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}colour']),
      dateCreated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_created'])!,
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_date']),
      dateTimeModified: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}date_time_modified']),
      iconName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon_name']),
      emojiIconName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}emoji_icon_name']),
      income: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}income'])!,
      pinned: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}pinned'])!,
      walletFk: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}wallet_fk'])!,
    );
  }

  @override
  $ObjectivesTable createAlias(String alias) {
    return $ObjectivesTable(attachedDatabase, alias);
  }
}

class Objective extends DataClass implements Insertable<Objective> {
  final String objectivePk;
  final String name;
  final double amount;
  final int order;
  final String? colour;
  final DateTime dateCreated;
  final DateTime? endDate;
  final DateTime? dateTimeModified;
  final String? iconName;
  final String? emojiIconName;
  final bool income;
  final bool pinned;
  final String walletFk;
  const Objective(
      {required this.objectivePk,
      required this.name,
      required this.amount,
      required this.order,
      this.colour,
      required this.dateCreated,
      this.endDate,
      this.dateTimeModified,
      this.iconName,
      this.emojiIconName,
      required this.income,
      required this.pinned,
      required this.walletFk});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['objective_pk'] = Variable<String>(objectivePk);
    map['name'] = Variable<String>(name);
    map['amount'] = Variable<double>(amount);
    map['order'] = Variable<int>(order);
    if (!nullToAbsent || colour != null) {
      map['colour'] = Variable<String>(colour);
    }
    map['date_created'] = Variable<DateTime>(dateCreated);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    if (!nullToAbsent || dateTimeModified != null) {
      map['date_time_modified'] = Variable<DateTime>(dateTimeModified);
    }
    if (!nullToAbsent || iconName != null) {
      map['icon_name'] = Variable<String>(iconName);
    }
    if (!nullToAbsent || emojiIconName != null) {
      map['emoji_icon_name'] = Variable<String>(emojiIconName);
    }
    map['income'] = Variable<bool>(income);
    map['pinned'] = Variable<bool>(pinned);
    map['wallet_fk'] = Variable<String>(walletFk);
    return map;
  }

  ObjectivesCompanion toCompanion(bool nullToAbsent) {
    return ObjectivesCompanion(
      objectivePk: Value(objectivePk),
      name: Value(name),
      amount: Value(amount),
      order: Value(order),
      colour:
          colour == null && nullToAbsent ? const Value.absent() : Value(colour),
      dateCreated: Value(dateCreated),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      dateTimeModified: dateTimeModified == null && nullToAbsent
          ? const Value.absent()
          : Value(dateTimeModified),
      iconName: iconName == null && nullToAbsent
          ? const Value.absent()
          : Value(iconName),
      emojiIconName: emojiIconName == null && nullToAbsent
          ? const Value.absent()
          : Value(emojiIconName),
      income: Value(income),
      pinned: Value(pinned),
      walletFk: Value(walletFk),
    );
  }

  factory Objective.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Objective(
      objectivePk: serializer.fromJson<String>(json['objectivePk']),
      name: serializer.fromJson<String>(json['name']),
      amount: serializer.fromJson<double>(json['amount']),
      order: serializer.fromJson<int>(json['order']),
      colour: serializer.fromJson<String?>(json['colour']),
      dateCreated: serializer.fromJson<DateTime>(json['dateCreated']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      dateTimeModified:
          serializer.fromJson<DateTime?>(json['dateTimeModified']),
      iconName: serializer.fromJson<String?>(json['iconName']),
      emojiIconName: serializer.fromJson<String?>(json['emojiIconName']),
      income: serializer.fromJson<bool>(json['income']),
      pinned: serializer.fromJson<bool>(json['pinned']),
      walletFk: serializer.fromJson<String>(json['walletFk']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'objectivePk': serializer.toJson<String>(objectivePk),
      'name': serializer.toJson<String>(name),
      'amount': serializer.toJson<double>(amount),
      'order': serializer.toJson<int>(order),
      'colour': serializer.toJson<String?>(colour),
      'dateCreated': serializer.toJson<DateTime>(dateCreated),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'dateTimeModified': serializer.toJson<DateTime?>(dateTimeModified),
      'iconName': serializer.toJson<String?>(iconName),
      'emojiIconName': serializer.toJson<String?>(emojiIconName),
      'income': serializer.toJson<bool>(income),
      'pinned': serializer.toJson<bool>(pinned),
      'walletFk': serializer.toJson<String>(walletFk),
    };
  }

  Objective copyWith(
          {String? objectivePk,
          String? name,
          double? amount,
          int? order,
          Value<String?> colour = const Value.absent(),
          DateTime? dateCreated,
          Value<DateTime?> endDate = const Value.absent(),
          Value<DateTime?> dateTimeModified = const Value.absent(),
          Value<String?> iconName = const Value.absent(),
          Value<String?> emojiIconName = const Value.absent(),
          bool? income,
          bool? pinned,
          String? walletFk}) =>
      Objective(
        objectivePk: objectivePk ?? this.objectivePk,
        name: name ?? this.name,
        amount: amount ?? this.amount,
        order: order ?? this.order,
        colour: colour.present ? colour.value : this.colour,
        dateCreated: dateCreated ?? this.dateCreated,
        endDate: endDate.present ? endDate.value : this.endDate,
        dateTimeModified: dateTimeModified.present
            ? dateTimeModified.value
            : this.dateTimeModified,
        iconName: iconName.present ? iconName.value : this.iconName,
        emojiIconName:
            emojiIconName.present ? emojiIconName.value : this.emojiIconName,
        income: income ?? this.income,
        pinned: pinned ?? this.pinned,
        walletFk: walletFk ?? this.walletFk,
      );
  @override
  String toString() {
    return (StringBuffer('Objective(')
          ..write('objectivePk: $objectivePk, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('order: $order, ')
          ..write('colour: $colour, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('endDate: $endDate, ')
          ..write('dateTimeModified: $dateTimeModified, ')
          ..write('iconName: $iconName, ')
          ..write('emojiIconName: $emojiIconName, ')
          ..write('income: $income, ')
          ..write('pinned: $pinned, ')
          ..write('walletFk: $walletFk')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      objectivePk,
      name,
      amount,
      order,
      colour,
      dateCreated,
      endDate,
      dateTimeModified,
      iconName,
      emojiIconName,
      income,
      pinned,
      walletFk);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Objective &&
          other.objectivePk == this.objectivePk &&
          other.name == this.name &&
          other.amount == this.amount &&
          other.order == this.order &&
          other.colour == this.colour &&
          other.dateCreated == this.dateCreated &&
          other.endDate == this.endDate &&
          other.dateTimeModified == this.dateTimeModified &&
          other.iconName == this.iconName &&
          other.emojiIconName == this.emojiIconName &&
          other.income == this.income &&
          other.pinned == this.pinned &&
          other.walletFk == this.walletFk);
}

class ObjectivesCompanion extends UpdateCompanion<Objective> {
  final Value<String> objectivePk;
  final Value<String> name;
  final Value<double> amount;
  final Value<int> order;
  final Value<String?> colour;
  final Value<DateTime> dateCreated;
  final Value<DateTime?> endDate;
  final Value<DateTime?> dateTimeModified;
  final Value<String?> iconName;
  final Value<String?> emojiIconName;
  final Value<bool> income;
  final Value<bool> pinned;
  final Value<String> walletFk;
  final Value<int> rowid;
  const ObjectivesCompanion({
    this.objectivePk = const Value.absent(),
    this.name = const Value.absent(),
    this.amount = const Value.absent(),
    this.order = const Value.absent(),
    this.colour = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.endDate = const Value.absent(),
    this.dateTimeModified = const Value.absent(),
    this.iconName = const Value.absent(),
    this.emojiIconName = const Value.absent(),
    this.income = const Value.absent(),
    this.pinned = const Value.absent(),
    this.walletFk = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ObjectivesCompanion.insert({
    this.objectivePk = const Value.absent(),
    required String name,
    required double amount,
    required int order,
    this.colour = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.endDate = const Value.absent(),
    this.dateTimeModified = const Value.absent(),
    this.iconName = const Value.absent(),
    this.emojiIconName = const Value.absent(),
    this.income = const Value.absent(),
    this.pinned = const Value.absent(),
    this.walletFk = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : name = Value(name),
        amount = Value(amount),
        order = Value(order);
  static Insertable<Objective> custom({
    Expression<String>? objectivePk,
    Expression<String>? name,
    Expression<double>? amount,
    Expression<int>? order,
    Expression<String>? colour,
    Expression<DateTime>? dateCreated,
    Expression<DateTime>? endDate,
    Expression<DateTime>? dateTimeModified,
    Expression<String>? iconName,
    Expression<String>? emojiIconName,
    Expression<bool>? income,
    Expression<bool>? pinned,
    Expression<String>? walletFk,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (objectivePk != null) 'objective_pk': objectivePk,
      if (name != null) 'name': name,
      if (amount != null) 'amount': amount,
      if (order != null) 'order': order,
      if (colour != null) 'colour': colour,
      if (dateCreated != null) 'date_created': dateCreated,
      if (endDate != null) 'end_date': endDate,
      if (dateTimeModified != null) 'date_time_modified': dateTimeModified,
      if (iconName != null) 'icon_name': iconName,
      if (emojiIconName != null) 'emoji_icon_name': emojiIconName,
      if (income != null) 'income': income,
      if (pinned != null) 'pinned': pinned,
      if (walletFk != null) 'wallet_fk': walletFk,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ObjectivesCompanion copyWith(
      {Value<String>? objectivePk,
      Value<String>? name,
      Value<double>? amount,
      Value<int>? order,
      Value<String?>? colour,
      Value<DateTime>? dateCreated,
      Value<DateTime?>? endDate,
      Value<DateTime?>? dateTimeModified,
      Value<String?>? iconName,
      Value<String?>? emojiIconName,
      Value<bool>? income,
      Value<bool>? pinned,
      Value<String>? walletFk,
      Value<int>? rowid}) {
    return ObjectivesCompanion(
      objectivePk: objectivePk ?? this.objectivePk,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      order: order ?? this.order,
      colour: colour ?? this.colour,
      dateCreated: dateCreated ?? this.dateCreated,
      endDate: endDate ?? this.endDate,
      dateTimeModified: dateTimeModified ?? this.dateTimeModified,
      iconName: iconName ?? this.iconName,
      emojiIconName: emojiIconName ?? this.emojiIconName,
      income: income ?? this.income,
      pinned: pinned ?? this.pinned,
      walletFk: walletFk ?? this.walletFk,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (objectivePk.present) {
      map['objective_pk'] = Variable<String>(objectivePk.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    if (colour.present) {
      map['colour'] = Variable<String>(colour.value);
    }
    if (dateCreated.present) {
      map['date_created'] = Variable<DateTime>(dateCreated.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (dateTimeModified.present) {
      map['date_time_modified'] = Variable<DateTime>(dateTimeModified.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    if (emojiIconName.present) {
      map['emoji_icon_name'] = Variable<String>(emojiIconName.value);
    }
    if (income.present) {
      map['income'] = Variable<bool>(income.value);
    }
    if (pinned.present) {
      map['pinned'] = Variable<bool>(pinned.value);
    }
    if (walletFk.present) {
      map['wallet_fk'] = Variable<String>(walletFk.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ObjectivesCompanion(')
          ..write('objectivePk: $objectivePk, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('order: $order, ')
          ..write('colour: $colour, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('endDate: $endDate, ')
          ..write('dateTimeModified: $dateTimeModified, ')
          ..write('iconName: $iconName, ')
          ..write('emojiIconName: $emojiIconName, ')
          ..write('income: $income, ')
          ..write('pinned: $pinned, ')
          ..write('walletFk: $walletFk, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _transactionPkMeta =
      const VerificationMeta('transactionPk');
  @override
  late final GeneratedColumn<String> transactionPk = GeneratedColumn<String>(
      'transaction_pk', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => uuid.v4());
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _categoryFkMeta =
      const VerificationMeta('categoryFk');
  @override
  late final GeneratedColumn<String> categoryFk = GeneratedColumn<String>(
      'category_fk', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES categories (category_pk)'));
  static const VerificationMeta _subCategoryFkMeta =
      const VerificationMeta('subCategoryFk');
  @override
  late final GeneratedColumn<String> subCategoryFk = GeneratedColumn<String>(
      'sub_category_fk', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES categories (category_pk)'),
      defaultValue: const Constant(null));
  static const VerificationMeta _walletFkMeta =
      const VerificationMeta('walletFk');
  @override
  late final GeneratedColumn<String> walletFk = GeneratedColumn<String>(
      'wallet_fk', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES wallets (wallet_pk)'),
      defaultValue: const Constant("0"));
  static const VerificationMeta _dateCreatedMeta =
      const VerificationMeta('dateCreated');
  @override
  late final GeneratedColumn<DateTime> dateCreated = GeneratedColumn<DateTime>(
      'date_created', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => new DateTime.now());
  static const VerificationMeta _dateTimeModifiedMeta =
      const VerificationMeta('dateTimeModified');
  @override
  late final GeneratedColumn<DateTime> dateTimeModified =
      GeneratedColumn<DateTime>('date_time_modified', aliasedName, true,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: Constant(DateTime.now()));
  static const VerificationMeta _originalDateDueMeta =
      const VerificationMeta('originalDateDue');
  @override
  late final GeneratedColumn<DateTime> originalDateDue =
      GeneratedColumn<DateTime>('original_date_due', aliasedName, true,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: Constant(DateTime.now()));
  static const VerificationMeta _incomeMeta = const VerificationMeta('income');
  @override
  late final GeneratedColumn<bool> income = GeneratedColumn<bool>(
      'income', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("income" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _periodLengthMeta =
      const VerificationMeta('periodLength');
  @override
  late final GeneratedColumn<int> periodLength = GeneratedColumn<int>(
      'period_length', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _reoccurrenceMeta =
      const VerificationMeta('reoccurrence');
  @override
  late final GeneratedColumnWithTypeConverter<BudgetReoccurence?, int>
      reoccurrence = GeneratedColumn<int>('reoccurrence', aliasedName, true,
              type: DriftSqlType.int, requiredDuringInsert: false)
          .withConverter<BudgetReoccurence?>(
              $TransactionsTable.$converterreoccurrencen);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
      'end_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _upcomingTransactionNotificationMeta =
      const VerificationMeta('upcomingTransactionNotification');
  @override
  late final GeneratedColumn<bool> upcomingTransactionNotification =
      GeneratedColumn<bool>(
          'upcoming_transaction_notification', aliasedName, true,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("upcoming_transaction_notification" IN (0, 1))'),
          defaultValue: const Constant(true));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumnWithTypeConverter<TransactionSpecialType?, int>
      type = GeneratedColumn<int>('type', aliasedName, true,
              type: DriftSqlType.int, requiredDuringInsert: false)
          .withConverter<TransactionSpecialType?>(
              $TransactionsTable.$convertertypen);
  static const VerificationMeta _paidMeta = const VerificationMeta('paid');
  @override
  late final GeneratedColumn<bool> paid = GeneratedColumn<bool>(
      'paid', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("paid" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAnotherFutureTransactionMeta =
      const VerificationMeta('createdAnotherFutureTransaction');
  @override
  late final GeneratedColumn<bool> createdAnotherFutureTransaction =
      GeneratedColumn<bool>(
          'created_another_future_transaction', aliasedName, true,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("created_another_future_transaction" IN (0, 1))'),
          defaultValue: const Constant(false));
  static const VerificationMeta _skipPaidMeta =
      const VerificationMeta('skipPaid');
  @override
  late final GeneratedColumn<bool> skipPaid = GeneratedColumn<bool>(
      'skip_paid', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("skip_paid" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _methodAddedMeta =
      const VerificationMeta('methodAdded');
  @override
  late final GeneratedColumnWithTypeConverter<MethodAdded?, int> methodAdded =
      GeneratedColumn<int>('method_added', aliasedName, true,
              type: DriftSqlType.int, requiredDuringInsert: false)
          .withConverter<MethodAdded?>(
              $TransactionsTable.$convertermethodAddedn);
  static const VerificationMeta _transactionOwnerEmailMeta =
      const VerificationMeta('transactionOwnerEmail');
  @override
  late final GeneratedColumn<String> transactionOwnerEmail =
      GeneratedColumn<String>('transaction_owner_email', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _transactionOriginalOwnerEmailMeta =
      const VerificationMeta('transactionOriginalOwnerEmail');
  @override
  late final GeneratedColumn<String> transactionOriginalOwnerEmail =
      GeneratedColumn<String>(
          'transaction_original_owner_email', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sharedKeyMeta =
      const VerificationMeta('sharedKey');
  @override
  late final GeneratedColumn<String> sharedKey = GeneratedColumn<String>(
      'shared_key', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sharedOldKeyMeta =
      const VerificationMeta('sharedOldKey');
  @override
  late final GeneratedColumn<String> sharedOldKey = GeneratedColumn<String>(
      'shared_old_key', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sharedStatusMeta =
      const VerificationMeta('sharedStatus');
  @override
  late final GeneratedColumnWithTypeConverter<SharedStatus?, int> sharedStatus =
      GeneratedColumn<int>('shared_status', aliasedName, true,
              type: DriftSqlType.int, requiredDuringInsert: false)
          .withConverter<SharedStatus?>(
              $TransactionsTable.$convertersharedStatusn);
  static const VerificationMeta _sharedDateUpdatedMeta =
      const VerificationMeta('sharedDateUpdated');
  @override
  late final GeneratedColumn<DateTime> sharedDateUpdated =
      GeneratedColumn<DateTime>('shared_date_updated', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _sharedReferenceBudgetPkMeta =
      const VerificationMeta('sharedReferenceBudgetPk');
  @override
  late final GeneratedColumn<String> sharedReferenceBudgetPk =
      GeneratedColumn<String>('shared_reference_budget_pk', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _objectiveFkMeta =
      const VerificationMeta('objectiveFk');
  @override
  late final GeneratedColumn<String> objectiveFk = GeneratedColumn<String>(
      'objective_fk', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES objectives (objective_pk)'));
  static const VerificationMeta _budgetFksExcludeMeta =
      const VerificationMeta('budgetFksExclude');
  @override
  late final GeneratedColumnWithTypeConverter<List<String>?, String>
      budgetFksExclude = GeneratedColumn<String>(
              'budget_fks_exclude', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<List<String>?>(
              $TransactionsTable.$converterbudgetFksExcluden);
  @override
  List<GeneratedColumn> get $columns => [
        transactionPk,
        name,
        amount,
        note,
        categoryFk,
        subCategoryFk,
        walletFk,
        dateCreated,
        dateTimeModified,
        originalDateDue,
        income,
        periodLength,
        reoccurrence,
        endDate,
        upcomingTransactionNotification,
        type,
        paid,
        createdAnotherFutureTransaction,
        skipPaid,
        methodAdded,
        transactionOwnerEmail,
        transactionOriginalOwnerEmail,
        sharedKey,
        sharedOldKey,
        sharedStatus,
        sharedDateUpdated,
        sharedReferenceBudgetPk,
        objectiveFk,
        budgetFksExclude
      ];
  @override
  String get aliasedName => _alias ?? 'transactions';
  @override
  String get actualTableName => 'transactions';
  @override
  VerificationContext validateIntegrity(Insertable<Transaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('transaction_pk')) {
      context.handle(
          _transactionPkMeta,
          transactionPk.isAcceptableOrUnknown(
              data['transaction_pk']!, _transactionPkMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    if (data.containsKey('category_fk')) {
      context.handle(
          _categoryFkMeta,
          categoryFk.isAcceptableOrUnknown(
              data['category_fk']!, _categoryFkMeta));
    } else if (isInserting) {
      context.missing(_categoryFkMeta);
    }
    if (data.containsKey('sub_category_fk')) {
      context.handle(
          _subCategoryFkMeta,
          subCategoryFk.isAcceptableOrUnknown(
              data['sub_category_fk']!, _subCategoryFkMeta));
    }
    if (data.containsKey('wallet_fk')) {
      context.handle(_walletFkMeta,
          walletFk.isAcceptableOrUnknown(data['wallet_fk']!, _walletFkMeta));
    }
    if (data.containsKey('date_created')) {
      context.handle(
          _dateCreatedMeta,
          dateCreated.isAcceptableOrUnknown(
              data['date_created']!, _dateCreatedMeta));
    }
    if (data.containsKey('date_time_modified')) {
      context.handle(
          _dateTimeModifiedMeta,
          dateTimeModified.isAcceptableOrUnknown(
              data['date_time_modified']!, _dateTimeModifiedMeta));
    }
    if (data.containsKey('original_date_due')) {
      context.handle(
          _originalDateDueMeta,
          originalDateDue.isAcceptableOrUnknown(
              data['original_date_due']!, _originalDateDueMeta));
    }
    if (data.containsKey('income')) {
      context.handle(_incomeMeta,
          income.isAcceptableOrUnknown(data['income']!, _incomeMeta));
    }
    if (data.containsKey('period_length')) {
      context.handle(
          _periodLengthMeta,
          periodLength.isAcceptableOrUnknown(
              data['period_length']!, _periodLengthMeta));
    }
    context.handle(_reoccurrenceMeta, const VerificationResult.success());
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    }
    if (data.containsKey('upcoming_transaction_notification')) {
      context.handle(
          _upcomingTransactionNotificationMeta,
          upcomingTransactionNotification.isAcceptableOrUnknown(
              data['upcoming_transaction_notification']!,
              _upcomingTransactionNotificationMeta));
    }
    context.handle(_typeMeta, const VerificationResult.success());
    if (data.containsKey('paid')) {
      context.handle(
          _paidMeta, paid.isAcceptableOrUnknown(data['paid']!, _paidMeta));
    }
    if (data.containsKey('created_another_future_transaction')) {
      context.handle(
          _createdAnotherFutureTransactionMeta,
          createdAnotherFutureTransaction.isAcceptableOrUnknown(
              data['created_another_future_transaction']!,
              _createdAnotherFutureTransactionMeta));
    }
    if (data.containsKey('skip_paid')) {
      context.handle(_skipPaidMeta,
          skipPaid.isAcceptableOrUnknown(data['skip_paid']!, _skipPaidMeta));
    }
    context.handle(_methodAddedMeta, const VerificationResult.success());
    if (data.containsKey('transaction_owner_email')) {
      context.handle(
          _transactionOwnerEmailMeta,
          transactionOwnerEmail.isAcceptableOrUnknown(
              data['transaction_owner_email']!, _transactionOwnerEmailMeta));
    }
    if (data.containsKey('transaction_original_owner_email')) {
      context.handle(
          _transactionOriginalOwnerEmailMeta,
          transactionOriginalOwnerEmail.isAcceptableOrUnknown(
              data['transaction_original_owner_email']!,
              _transactionOriginalOwnerEmailMeta));
    }
    if (data.containsKey('shared_key')) {
      context.handle(_sharedKeyMeta,
          sharedKey.isAcceptableOrUnknown(data['shared_key']!, _sharedKeyMeta));
    }
    if (data.containsKey('shared_old_key')) {
      context.handle(
          _sharedOldKeyMeta,
          sharedOldKey.isAcceptableOrUnknown(
              data['shared_old_key']!, _sharedOldKeyMeta));
    }
    context.handle(_sharedStatusMeta, const VerificationResult.success());
    if (data.containsKey('shared_date_updated')) {
      context.handle(
          _sharedDateUpdatedMeta,
          sharedDateUpdated.isAcceptableOrUnknown(
              data['shared_date_updated']!, _sharedDateUpdatedMeta));
    }
    if (data.containsKey('shared_reference_budget_pk')) {
      context.handle(
          _sharedReferenceBudgetPkMeta,
          sharedReferenceBudgetPk.isAcceptableOrUnknown(
              data['shared_reference_budget_pk']!,
              _sharedReferenceBudgetPkMeta));
    }
    if (data.containsKey('objective_fk')) {
      context.handle(
          _objectiveFkMeta,
          objectiveFk.isAcceptableOrUnknown(
              data['objective_fk']!, _objectiveFkMeta));
    }
    context.handle(_budgetFksExcludeMeta, const VerificationResult.success());
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {transactionPk};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      transactionPk: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}transaction_pk'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note'])!,
      categoryFk: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_fk'])!,
      subCategoryFk: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sub_category_fk']),
      walletFk: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}wallet_fk'])!,
      dateCreated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_created'])!,
      dateTimeModified: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}date_time_modified']),
      originalDateDue: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}original_date_due']),
      income: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}income'])!,
      periodLength: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}period_length']),
      reoccurrence: $TransactionsTable.$converterreoccurrencen.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.int, data['${effectivePrefix}reoccurrence'])),
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_date']),
      upcomingTransactionNotification: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}upcoming_transaction_notification']),
      type: $TransactionsTable.$convertertypen.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type'])),
      paid: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}paid'])!,
      createdAnotherFutureTransaction: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}created_another_future_transaction']),
      skipPaid: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}skip_paid'])!,
      methodAdded: $TransactionsTable.$convertermethodAddedn.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.int, data['${effectivePrefix}method_added'])),
      transactionOwnerEmail: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}transaction_owner_email']),
      transactionOriginalOwnerEmail: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}transaction_original_owner_email']),
      sharedKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}shared_key']),
      sharedOldKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}shared_old_key']),
      sharedStatus: $TransactionsTable.$convertersharedStatusn.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.int, data['${effectivePrefix}shared_status'])),
      sharedDateUpdated: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}shared_date_updated']),
      sharedReferenceBudgetPk: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}shared_reference_budget_pk']),
      objectiveFk: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}objective_fk']),
      budgetFksExclude: $TransactionsTable.$converterbudgetFksExcluden.fromSql(
          attachedDatabase.typeMapping.read(DriftSqlType.string,
              data['${effectivePrefix}budget_fks_exclude'])),
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<BudgetReoccurence, int, int>
      $converterreoccurrence =
      const EnumIndexConverter<BudgetReoccurence>(BudgetReoccurence.values);
  static JsonTypeConverter2<BudgetReoccurence?, int?, int?>
      $converterreoccurrencen =
      JsonTypeConverter2.asNullable($converterreoccurrence);
  static JsonTypeConverter2<TransactionSpecialType, int, int> $convertertype =
      const EnumIndexConverter<TransactionSpecialType>(
          TransactionSpecialType.values);
  static JsonTypeConverter2<TransactionSpecialType?, int?, int?>
      $convertertypen = JsonTypeConverter2.asNullable($convertertype);
  static JsonTypeConverter2<MethodAdded, int, int> $convertermethodAdded =
      const EnumIndexConverter<MethodAdded>(MethodAdded.values);
  static JsonTypeConverter2<MethodAdded?, int?, int?> $convertermethodAddedn =
      JsonTypeConverter2.asNullable($convertermethodAdded);
  static JsonTypeConverter2<SharedStatus, int, int> $convertersharedStatus =
      const EnumIndexConverter<SharedStatus>(SharedStatus.values);
  static JsonTypeConverter2<SharedStatus?, int?, int?> $convertersharedStatusn =
      JsonTypeConverter2.asNullable($convertersharedStatus);
  static TypeConverter<List<String>, String> $converterbudgetFksExclude =
      const StringListInColumnConverter();
  static TypeConverter<List<String>?, String?> $converterbudgetFksExcluden =
      NullAwareTypeConverter.wrap($converterbudgetFksExclude);
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final String transactionPk;
  final String name;
  final double amount;
  final String note;
  final String categoryFk;
  final String? subCategoryFk;
  final String walletFk;
  final DateTime dateCreated;
  final DateTime? dateTimeModified;
  final DateTime? originalDateDue;
  final bool income;
  final int? periodLength;
  final BudgetReoccurence? reoccurrence;
  final DateTime? endDate;
  final bool? upcomingTransactionNotification;
  final TransactionSpecialType? type;
  final bool paid;
  final bool? createdAnotherFutureTransaction;
  final bool skipPaid;
  final MethodAdded? methodAdded;
  final String? transactionOwnerEmail;
  final String? transactionOriginalOwnerEmail;
  final String? sharedKey;
  final String? sharedOldKey;
  final SharedStatus? sharedStatus;
  final DateTime? sharedDateUpdated;
  final String? sharedReferenceBudgetPk;
  final String? objectiveFk;
  final List<String>? budgetFksExclude;
  const Transaction(
      {required this.transactionPk,
      required this.name,
      required this.amount,
      required this.note,
      required this.categoryFk,
      this.subCategoryFk,
      required this.walletFk,
      required this.dateCreated,
      this.dateTimeModified,
      this.originalDateDue,
      required this.income,
      this.periodLength,
      this.reoccurrence,
      this.endDate,
      this.upcomingTransactionNotification,
      this.type,
      required this.paid,
      this.createdAnotherFutureTransaction,
      required this.skipPaid,
      this.methodAdded,
      this.transactionOwnerEmail,
      this.transactionOriginalOwnerEmail,
      this.sharedKey,
      this.sharedOldKey,
      this.sharedStatus,
      this.sharedDateUpdated,
      this.sharedReferenceBudgetPk,
      this.objectiveFk,
      this.budgetFksExclude});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['transaction_pk'] = Variable<String>(transactionPk);
    map['name'] = Variable<String>(name);
    map['amount'] = Variable<double>(amount);
    map['note'] = Variable<String>(note);
    map['category_fk'] = Variable<String>(categoryFk);
    if (!nullToAbsent || subCategoryFk != null) {
      map['sub_category_fk'] = Variable<String>(subCategoryFk);
    }
    map['wallet_fk'] = Variable<String>(walletFk);
    map['date_created'] = Variable<DateTime>(dateCreated);
    if (!nullToAbsent || dateTimeModified != null) {
      map['date_time_modified'] = Variable<DateTime>(dateTimeModified);
    }
    if (!nullToAbsent || originalDateDue != null) {
      map['original_date_due'] = Variable<DateTime>(originalDateDue);
    }
    map['income'] = Variable<bool>(income);
    if (!nullToAbsent || periodLength != null) {
      map['period_length'] = Variable<int>(periodLength);
    }
    if (!nullToAbsent || reoccurrence != null) {
      final converter = $TransactionsTable.$converterreoccurrencen;
      map['reoccurrence'] = Variable<int>(converter.toSql(reoccurrence));
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    if (!nullToAbsent || upcomingTransactionNotification != null) {
      map['upcoming_transaction_notification'] =
          Variable<bool>(upcomingTransactionNotification);
    }
    if (!nullToAbsent || type != null) {
      final converter = $TransactionsTable.$convertertypen;
      map['type'] = Variable<int>(converter.toSql(type));
    }
    map['paid'] = Variable<bool>(paid);
    if (!nullToAbsent || createdAnotherFutureTransaction != null) {
      map['created_another_future_transaction'] =
          Variable<bool>(createdAnotherFutureTransaction);
    }
    map['skip_paid'] = Variable<bool>(skipPaid);
    if (!nullToAbsent || methodAdded != null) {
      final converter = $TransactionsTable.$convertermethodAddedn;
      map['method_added'] = Variable<int>(converter.toSql(methodAdded));
    }
    if (!nullToAbsent || transactionOwnerEmail != null) {
      map['transaction_owner_email'] = Variable<String>(transactionOwnerEmail);
    }
    if (!nullToAbsent || transactionOriginalOwnerEmail != null) {
      map['transaction_original_owner_email'] =
          Variable<String>(transactionOriginalOwnerEmail);
    }
    if (!nullToAbsent || sharedKey != null) {
      map['shared_key'] = Variable<String>(sharedKey);
    }
    if (!nullToAbsent || sharedOldKey != null) {
      map['shared_old_key'] = Variable<String>(sharedOldKey);
    }
    if (!nullToAbsent || sharedStatus != null) {
      final converter = $TransactionsTable.$convertersharedStatusn;
      map['shared_status'] = Variable<int>(converter.toSql(sharedStatus));
    }
    if (!nullToAbsent || sharedDateUpdated != null) {
      map['shared_date_updated'] = Variable<DateTime>(sharedDateUpdated);
    }
    if (!nullToAbsent || sharedReferenceBudgetPk != null) {
      map['shared_reference_budget_pk'] =
          Variable<String>(sharedReferenceBudgetPk);
    }
    if (!nullToAbsent || objectiveFk != null) {
      map['objective_fk'] = Variable<String>(objectiveFk);
    }
    if (!nullToAbsent || budgetFksExclude != null) {
      final converter = $TransactionsTable.$converterbudgetFksExcluden;
      map['budget_fks_exclude'] =
          Variable<String>(converter.toSql(budgetFksExclude));
    }
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      transactionPk: Value(transactionPk),
      name: Value(name),
      amount: Value(amount),
      note: Value(note),
      categoryFk: Value(categoryFk),
      subCategoryFk: subCategoryFk == null && nullToAbsent
          ? const Value.absent()
          : Value(subCategoryFk),
      walletFk: Value(walletFk),
      dateCreated: Value(dateCreated),
      dateTimeModified: dateTimeModified == null && nullToAbsent
          ? const Value.absent()
          : Value(dateTimeModified),
      originalDateDue: originalDateDue == null && nullToAbsent
          ? const Value.absent()
          : Value(originalDateDue),
      income: Value(income),
      periodLength: periodLength == null && nullToAbsent
          ? const Value.absent()
          : Value(periodLength),
      reoccurrence: reoccurrence == null && nullToAbsent
          ? const Value.absent()
          : Value(reoccurrence),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      upcomingTransactionNotification:
          upcomingTransactionNotification == null && nullToAbsent
              ? const Value.absent()
              : Value(upcomingTransactionNotification),
      type: type == null && nullToAbsent ? const Value.absent() : Value(type),
      paid: Value(paid),
      createdAnotherFutureTransaction:
          createdAnotherFutureTransaction == null && nullToAbsent
              ? const Value.absent()
              : Value(createdAnotherFutureTransaction),
      skipPaid: Value(skipPaid),
      methodAdded: methodAdded == null && nullToAbsent
          ? const Value.absent()
          : Value(methodAdded),
      transactionOwnerEmail: transactionOwnerEmail == null && nullToAbsent
          ? const Value.absent()
          : Value(transactionOwnerEmail),
      transactionOriginalOwnerEmail:
          transactionOriginalOwnerEmail == null && nullToAbsent
              ? const Value.absent()
              : Value(transactionOriginalOwnerEmail),
      sharedKey: sharedKey == null && nullToAbsent
          ? const Value.absent()
          : Value(sharedKey),
      sharedOldKey: sharedOldKey == null && nullToAbsent
          ? const Value.absent()
          : Value(sharedOldKey),
      sharedStatus: sharedStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(sharedStatus),
      sharedDateUpdated: sharedDateUpdated == null && nullToAbsent
          ? const Value.absent()
          : Value(sharedDateUpdated),
      sharedReferenceBudgetPk: sharedReferenceBudgetPk == null && nullToAbsent
          ? const Value.absent()
          : Value(sharedReferenceBudgetPk),
      objectiveFk: objectiveFk == null && nullToAbsent
          ? const Value.absent()
          : Value(objectiveFk),
      budgetFksExclude: budgetFksExclude == null && nullToAbsent
          ? const Value.absent()
          : Value(budgetFksExclude),
    );
  }

  factory Transaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      transactionPk: serializer.fromJson<String>(json['transactionPk']),
      name: serializer.fromJson<String>(json['name']),
      amount: serializer.fromJson<double>(json['amount']),
      note: serializer.fromJson<String>(json['note']),
      categoryFk: serializer.fromJson<String>(json['categoryFk']),
      subCategoryFk: serializer.fromJson<String?>(json['subCategoryFk']),
      walletFk: serializer.fromJson<String>(json['walletFk']),
      dateCreated: serializer.fromJson<DateTime>(json['dateCreated']),
      dateTimeModified:
          serializer.fromJson<DateTime?>(json['dateTimeModified']),
      originalDateDue: serializer.fromJson<DateTime?>(json['originalDateDue']),
      income: serializer.fromJson<bool>(json['income']),
      periodLength: serializer.fromJson<int?>(json['periodLength']),
      reoccurrence: $TransactionsTable.$converterreoccurrencen
          .fromJson(serializer.fromJson<int?>(json['reoccurrence'])),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      upcomingTransactionNotification:
          serializer.fromJson<bool?>(json['upcomingTransactionNotification']),
      type: $TransactionsTable.$convertertypen
          .fromJson(serializer.fromJson<int?>(json['type'])),
      paid: serializer.fromJson<bool>(json['paid']),
      createdAnotherFutureTransaction:
          serializer.fromJson<bool?>(json['createdAnotherFutureTransaction']),
      skipPaid: serializer.fromJson<bool>(json['skipPaid']),
      methodAdded: $TransactionsTable.$convertermethodAddedn
          .fromJson(serializer.fromJson<int?>(json['methodAdded'])),
      transactionOwnerEmail:
          serializer.fromJson<String?>(json['transactionOwnerEmail']),
      transactionOriginalOwnerEmail:
          serializer.fromJson<String?>(json['transactionOriginalOwnerEmail']),
      sharedKey: serializer.fromJson<String?>(json['sharedKey']),
      sharedOldKey: serializer.fromJson<String?>(json['sharedOldKey']),
      sharedStatus: $TransactionsTable.$convertersharedStatusn
          .fromJson(serializer.fromJson<int?>(json['sharedStatus'])),
      sharedDateUpdated:
          serializer.fromJson<DateTime?>(json['sharedDateUpdated']),
      sharedReferenceBudgetPk:
          serializer.fromJson<String?>(json['sharedReferenceBudgetPk']),
      objectiveFk: serializer.fromJson<String?>(json['objectiveFk']),
      budgetFksExclude:
          serializer.fromJson<List<String>?>(json['budgetFksExclude']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'transactionPk': serializer.toJson<String>(transactionPk),
      'name': serializer.toJson<String>(name),
      'amount': serializer.toJson<double>(amount),
      'note': serializer.toJson<String>(note),
      'categoryFk': serializer.toJson<String>(categoryFk),
      'subCategoryFk': serializer.toJson<String?>(subCategoryFk),
      'walletFk': serializer.toJson<String>(walletFk),
      'dateCreated': serializer.toJson<DateTime>(dateCreated),
      'dateTimeModified': serializer.toJson<DateTime?>(dateTimeModified),
      'originalDateDue': serializer.toJson<DateTime?>(originalDateDue),
      'income': serializer.toJson<bool>(income),
      'periodLength': serializer.toJson<int?>(periodLength),
      'reoccurrence': serializer.toJson<int?>(
          $TransactionsTable.$converterreoccurrencen.toJson(reoccurrence)),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'upcomingTransactionNotification':
          serializer.toJson<bool?>(upcomingTransactionNotification),
      'type': serializer
          .toJson<int?>($TransactionsTable.$convertertypen.toJson(type)),
      'paid': serializer.toJson<bool>(paid),
      'createdAnotherFutureTransaction':
          serializer.toJson<bool?>(createdAnotherFutureTransaction),
      'skipPaid': serializer.toJson<bool>(skipPaid),
      'methodAdded': serializer.toJson<int?>(
          $TransactionsTable.$convertermethodAddedn.toJson(methodAdded)),
      'transactionOwnerEmail':
          serializer.toJson<String?>(transactionOwnerEmail),
      'transactionOriginalOwnerEmail':
          serializer.toJson<String?>(transactionOriginalOwnerEmail),
      'sharedKey': serializer.toJson<String?>(sharedKey),
      'sharedOldKey': serializer.toJson<String?>(sharedOldKey),
      'sharedStatus': serializer.toJson<int?>(
          $TransactionsTable.$convertersharedStatusn.toJson(sharedStatus)),
      'sharedDateUpdated': serializer.toJson<DateTime?>(sharedDateUpdated),
      'sharedReferenceBudgetPk':
          serializer.toJson<String?>(sharedReferenceBudgetPk),
      'objectiveFk': serializer.toJson<String?>(objectiveFk),
      'budgetFksExclude': serializer.toJson<List<String>?>(budgetFksExclude),
    };
  }

  Transaction copyWith(
          {String? transactionPk,
          String? name,
          double? amount,
          String? note,
          String? categoryFk,
          Value<String?> subCategoryFk = const Value.absent(),
          String? walletFk,
          DateTime? dateCreated,
          Value<DateTime?> dateTimeModified = const Value.absent(),
          Value<DateTime?> originalDateDue = const Value.absent(),
          bool? income,
          Value<int?> periodLength = const Value.absent(),
          Value<BudgetReoccurence?> reoccurrence = const Value.absent(),
          Value<DateTime?> endDate = const Value.absent(),
          Value<bool?> upcomingTransactionNotification = const Value.absent(),
          Value<TransactionSpecialType?> type = const Value.absent(),
          bool? paid,
          Value<bool?> createdAnotherFutureTransaction = const Value.absent(),
          bool? skipPaid,
          Value<MethodAdded?> methodAdded = const Value.absent(),
          Value<String?> transactionOwnerEmail = const Value.absent(),
          Value<String?> transactionOriginalOwnerEmail = const Value.absent(),
          Value<String?> sharedKey = const Value.absent(),
          Value<String?> sharedOldKey = const Value.absent(),
          Value<SharedStatus?> sharedStatus = const Value.absent(),
          Value<DateTime?> sharedDateUpdated = const Value.absent(),
          Value<String?> sharedReferenceBudgetPk = const Value.absent(),
          Value<String?> objectiveFk = const Value.absent(),
          Value<List<String>?> budgetFksExclude = const Value.absent()}) =>
      Transaction(
        transactionPk: transactionPk ?? this.transactionPk,
        name: name ?? this.name,
        amount: amount ?? this.amount,
        note: note ?? this.note,
        categoryFk: categoryFk ?? this.categoryFk,
        subCategoryFk:
            subCategoryFk.present ? subCategoryFk.value : this.subCategoryFk,
        walletFk: walletFk ?? this.walletFk,
        dateCreated: dateCreated ?? this.dateCreated,
        dateTimeModified: dateTimeModified.present
            ? dateTimeModified.value
            : this.dateTimeModified,
        originalDateDue: originalDateDue.present
            ? originalDateDue.value
            : this.originalDateDue,
        income: income ?? this.income,
        periodLength:
            periodLength.present ? periodLength.value : this.periodLength,
        reoccurrence:
            reoccurrence.present ? reoccurrence.value : this.reoccurrence,
        endDate: endDate.present ? endDate.value : this.endDate,
        upcomingTransactionNotification: upcomingTransactionNotification.present
            ? upcomingTransactionNotification.value
            : this.upcomingTransactionNotification,
        type: type.present ? type.value : this.type,
        paid: paid ?? this.paid,
        createdAnotherFutureTransaction: createdAnotherFutureTransaction.present
            ? createdAnotherFutureTransaction.value
            : this.createdAnotherFutureTransaction,
        skipPaid: skipPaid ?? this.skipPaid,
        methodAdded: methodAdded.present ? methodAdded.value : this.methodAdded,
        transactionOwnerEmail: transactionOwnerEmail.present
            ? transactionOwnerEmail.value
            : this.transactionOwnerEmail,
        transactionOriginalOwnerEmail: transactionOriginalOwnerEmail.present
            ? transactionOriginalOwnerEmail.value
            : this.transactionOriginalOwnerEmail,
        sharedKey: sharedKey.present ? sharedKey.value : this.sharedKey,
        sharedOldKey:
            sharedOldKey.present ? sharedOldKey.value : this.sharedOldKey,
        sharedStatus:
            sharedStatus.present ? sharedStatus.value : this.sharedStatus,
        sharedDateUpdated: sharedDateUpdated.present
            ? sharedDateUpdated.value
            : this.sharedDateUpdated,
        sharedReferenceBudgetPk: sharedReferenceBudgetPk.present
            ? sharedReferenceBudgetPk.value
            : this.sharedReferenceBudgetPk,
        objectiveFk: objectiveFk.present ? objectiveFk.value : this.objectiveFk,
        budgetFksExclude: budgetFksExclude.present
            ? budgetFksExclude.value
            : this.budgetFksExclude,
      );
  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('transactionPk: $transactionPk, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('note: $note, ')
          ..write('categoryFk: $categoryFk, ')
          ..write('subCategoryFk: $subCategoryFk, ')
          ..write('walletFk: $walletFk, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateTimeModified: $dateTimeModified, ')
          ..write('originalDateDue: $originalDateDue, ')
          ..write('income: $income, ')
          ..write('periodLength: $periodLength, ')
          ..write('reoccurrence: $reoccurrence, ')
          ..write('endDate: $endDate, ')
          ..write(
              'upcomingTransactionNotification: $upcomingTransactionNotification, ')
          ..write('type: $type, ')
          ..write('paid: $paid, ')
          ..write(
              'createdAnotherFutureTransaction: $createdAnotherFutureTransaction, ')
          ..write('skipPaid: $skipPaid, ')
          ..write('methodAdded: $methodAdded, ')
          ..write('transactionOwnerEmail: $transactionOwnerEmail, ')
          ..write(
              'transactionOriginalOwnerEmail: $transactionOriginalOwnerEmail, ')
          ..write('sharedKey: $sharedKey, ')
          ..write('sharedOldKey: $sharedOldKey, ')
          ..write('sharedStatus: $sharedStatus, ')
          ..write('sharedDateUpdated: $sharedDateUpdated, ')
          ..write('sharedReferenceBudgetPk: $sharedReferenceBudgetPk, ')
          ..write('objectiveFk: $objectiveFk, ')
          ..write('budgetFksExclude: $budgetFksExclude')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        transactionPk,
        name,
        amount,
        note,
        categoryFk,
        subCategoryFk,
        walletFk,
        dateCreated,
        dateTimeModified,
        originalDateDue,
        income,
        periodLength,
        reoccurrence,
        endDate,
        upcomingTransactionNotification,
        type,
        paid,
        createdAnotherFutureTransaction,
        skipPaid,
        methodAdded,
        transactionOwnerEmail,
        transactionOriginalOwnerEmail,
        sharedKey,
        sharedOldKey,
        sharedStatus,
        sharedDateUpdated,
        sharedReferenceBudgetPk,
        objectiveFk,
        budgetFksExclude
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.transactionPk == this.transactionPk &&
          other.name == this.name &&
          other.amount == this.amount &&
          other.note == this.note &&
          other.categoryFk == this.categoryFk &&
          other.subCategoryFk == this.subCategoryFk &&
          other.walletFk == this.walletFk &&
          other.dateCreated == this.dateCreated &&
          other.dateTimeModified == this.dateTimeModified &&
          other.originalDateDue == this.originalDateDue &&
          other.income == this.income &&
          other.periodLength == this.periodLength &&
          other.reoccurrence == this.reoccurrence &&
          other.endDate == this.endDate &&
          other.upcomingTransactionNotification ==
              this.upcomingTransactionNotification &&
          other.type == this.type &&
          other.paid == this.paid &&
          other.createdAnotherFutureTransaction ==
              this.createdAnotherFutureTransaction &&
          other.skipPaid == this.skipPaid &&
          other.methodAdded == this.methodAdded &&
          other.transactionOwnerEmail == this.transactionOwnerEmail &&
          other.transactionOriginalOwnerEmail ==
              this.transactionOriginalOwnerEmail &&
          other.sharedKey == this.sharedKey &&
          other.sharedOldKey == this.sharedOldKey &&
          other.sharedStatus == this.sharedStatus &&
          other.sharedDateUpdated == this.sharedDateUpdated &&
          other.sharedReferenceBudgetPk == this.sharedReferenceBudgetPk &&
          other.objectiveFk == this.objectiveFk &&
          other.budgetFksExclude == this.budgetFksExclude);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<String> transactionPk;
  final Value<String> name;
  final Value<double> amount;
  final Value<String> note;
  final Value<String> categoryFk;
  final Value<String?> subCategoryFk;
  final Value<String> walletFk;
  final Value<DateTime> dateCreated;
  final Value<DateTime?> dateTimeModified;
  final Value<DateTime?> originalDateDue;
  final Value<bool> income;
  final Value<int?> periodLength;
  final Value<BudgetReoccurence?> reoccurrence;
  final Value<DateTime?> endDate;
  final Value<bool?> upcomingTransactionNotification;
  final Value<TransactionSpecialType?> type;
  final Value<bool> paid;
  final Value<bool?> createdAnotherFutureTransaction;
  final Value<bool> skipPaid;
  final Value<MethodAdded?> methodAdded;
  final Value<String?> transactionOwnerEmail;
  final Value<String?> transactionOriginalOwnerEmail;
  final Value<String?> sharedKey;
  final Value<String?> sharedOldKey;
  final Value<SharedStatus?> sharedStatus;
  final Value<DateTime?> sharedDateUpdated;
  final Value<String?> sharedReferenceBudgetPk;
  final Value<String?> objectiveFk;
  final Value<List<String>?> budgetFksExclude;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.transactionPk = const Value.absent(),
    this.name = const Value.absent(),
    this.amount = const Value.absent(),
    this.note = const Value.absent(),
    this.categoryFk = const Value.absent(),
    this.subCategoryFk = const Value.absent(),
    this.walletFk = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.dateTimeModified = const Value.absent(),
    this.originalDateDue = const Value.absent(),
    this.income = const Value.absent(),
    this.periodLength = const Value.absent(),
    this.reoccurrence = const Value.absent(),
    this.endDate = const Value.absent(),
    this.upcomingTransactionNotification = const Value.absent(),
    this.type = const Value.absent(),
    this.paid = const Value.absent(),
    this.createdAnotherFutureTransaction = const Value.absent(),
    this.skipPaid = const Value.absent(),
    this.methodAdded = const Value.absent(),
    this.transactionOwnerEmail = const Value.absent(),
    this.transactionOriginalOwnerEmail = const Value.absent(),
    this.sharedKey = const Value.absent(),
    this.sharedOldKey = const Value.absent(),
    this.sharedStatus = const Value.absent(),
    this.sharedDateUpdated = const Value.absent(),
    this.sharedReferenceBudgetPk = const Value.absent(),
    this.objectiveFk = const Value.absent(),
    this.budgetFksExclude = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.transactionPk = const Value.absent(),
    required String name,
    required double amount,
    required String note,
    required String categoryFk,
    this.subCategoryFk = const Value.absent(),
    this.walletFk = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.dateTimeModified = const Value.absent(),
    this.originalDateDue = const Value.absent(),
    this.income = const Value.absent(),
    this.periodLength = const Value.absent(),
    this.reoccurrence = const Value.absent(),
    this.endDate = const Value.absent(),
    this.upcomingTransactionNotification = const Value.absent(),
    this.type = const Value.absent(),
    this.paid = const Value.absent(),
    this.createdAnotherFutureTransaction = const Value.absent(),
    this.skipPaid = const Value.absent(),
    this.methodAdded = const Value.absent(),
    this.transactionOwnerEmail = const Value.absent(),
    this.transactionOriginalOwnerEmail = const Value.absent(),
    this.sharedKey = const Value.absent(),
    this.sharedOldKey = const Value.absent(),
    this.sharedStatus = const Value.absent(),
    this.sharedDateUpdated = const Value.absent(),
    this.sharedReferenceBudgetPk = const Value.absent(),
    this.objectiveFk = const Value.absent(),
    this.budgetFksExclude = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : name = Value(name),
        amount = Value(amount),
        note = Value(note),
        categoryFk = Value(categoryFk);
  static Insertable<Transaction> custom({
    Expression<String>? transactionPk,
    Expression<String>? name,
    Expression<double>? amount,
    Expression<String>? note,
    Expression<String>? categoryFk,
    Expression<String>? subCategoryFk,
    Expression<String>? walletFk,
    Expression<DateTime>? dateCreated,
    Expression<DateTime>? dateTimeModified,
    Expression<DateTime>? originalDateDue,
    Expression<bool>? income,
    Expression<int>? periodLength,
    Expression<int>? reoccurrence,
    Expression<DateTime>? endDate,
    Expression<bool>? upcomingTransactionNotification,
    Expression<int>? type,
    Expression<bool>? paid,
    Expression<bool>? createdAnotherFutureTransaction,
    Expression<bool>? skipPaid,
    Expression<int>? methodAdded,
    Expression<String>? transactionOwnerEmail,
    Expression<String>? transactionOriginalOwnerEmail,
    Expression<String>? sharedKey,
    Expression<String>? sharedOldKey,
    Expression<int>? sharedStatus,
    Expression<DateTime>? sharedDateUpdated,
    Expression<String>? sharedReferenceBudgetPk,
    Expression<String>? objectiveFk,
    Expression<String>? budgetFksExclude,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (transactionPk != null) 'transaction_pk': transactionPk,
      if (name != null) 'name': name,
      if (amount != null) 'amount': amount,
      if (note != null) 'note': note,
      if (categoryFk != null) 'category_fk': categoryFk,
      if (subCategoryFk != null) 'sub_category_fk': subCategoryFk,
      if (walletFk != null) 'wallet_fk': walletFk,
      if (dateCreated != null) 'date_created': dateCreated,
      if (dateTimeModified != null) 'date_time_modified': dateTimeModified,
      if (originalDateDue != null) 'original_date_due': originalDateDue,
      if (income != null) 'income': income,
      if (periodLength != null) 'period_length': periodLength,
      if (reoccurrence != null) 'reoccurrence': reoccurrence,
      if (endDate != null) 'end_date': endDate,
      if (upcomingTransactionNotification != null)
        'upcoming_transaction_notification': upcomingTransactionNotification,
      if (type != null) 'type': type,
      if (paid != null) 'paid': paid,
      if (createdAnotherFutureTransaction != null)
        'created_another_future_transaction': createdAnotherFutureTransaction,
      if (skipPaid != null) 'skip_paid': skipPaid,
      if (methodAdded != null) 'method_added': methodAdded,
      if (transactionOwnerEmail != null)
        'transaction_owner_email': transactionOwnerEmail,
      if (transactionOriginalOwnerEmail != null)
        'transaction_original_owner_email': transactionOriginalOwnerEmail,
      if (sharedKey != null) 'shared_key': sharedKey,
      if (sharedOldKey != null) 'shared_old_key': sharedOldKey,
      if (sharedStatus != null) 'shared_status': sharedStatus,
      if (sharedDateUpdated != null) 'shared_date_updated': sharedDateUpdated,
      if (sharedReferenceBudgetPk != null)
        'shared_reference_budget_pk': sharedReferenceBudgetPk,
      if (objectiveFk != null) 'objective_fk': objectiveFk,
      if (budgetFksExclude != null) 'budget_fks_exclude': budgetFksExclude,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith(
      {Value<String>? transactionPk,
      Value<String>? name,
      Value<double>? amount,
      Value<String>? note,
      Value<String>? categoryFk,
      Value<String?>? subCategoryFk,
      Value<String>? walletFk,
      Value<DateTime>? dateCreated,
      Value<DateTime?>? dateTimeModified,
      Value<DateTime?>? originalDateDue,
      Value<bool>? income,
      Value<int?>? periodLength,
      Value<BudgetReoccurence?>? reoccurrence,
      Value<DateTime?>? endDate,
      Value<bool?>? upcomingTransactionNotification,
      Value<TransactionSpecialType?>? type,
      Value<bool>? paid,
      Value<bool?>? createdAnotherFutureTransaction,
      Value<bool>? skipPaid,
      Value<MethodAdded?>? methodAdded,
      Value<String?>? transactionOwnerEmail,
      Value<String?>? transactionOriginalOwnerEmail,
      Value<String?>? sharedKey,
      Value<String?>? sharedOldKey,
      Value<SharedStatus?>? sharedStatus,
      Value<DateTime?>? sharedDateUpdated,
      Value<String?>? sharedReferenceBudgetPk,
      Value<String?>? objectiveFk,
      Value<List<String>?>? budgetFksExclude,
      Value<int>? rowid}) {
    return TransactionsCompanion(
      transactionPk: transactionPk ?? this.transactionPk,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      categoryFk: categoryFk ?? this.categoryFk,
      subCategoryFk: subCategoryFk ?? this.subCategoryFk,
      walletFk: walletFk ?? this.walletFk,
      dateCreated: dateCreated ?? this.dateCreated,
      dateTimeModified: dateTimeModified ?? this.dateTimeModified,
      originalDateDue: originalDateDue ?? this.originalDateDue,
      income: income ?? this.income,
      periodLength: periodLength ?? this.periodLength,
      reoccurrence: reoccurrence ?? this.reoccurrence,
      endDate: endDate ?? this.endDate,
      upcomingTransactionNotification: upcomingTransactionNotification ??
          this.upcomingTransactionNotification,
      type: type ?? this.type,
      paid: paid ?? this.paid,
      createdAnotherFutureTransaction: createdAnotherFutureTransaction ??
          this.createdAnotherFutureTransaction,
      skipPaid: skipPaid ?? this.skipPaid,
      methodAdded: methodAdded ?? this.methodAdded,
      transactionOwnerEmail:
          transactionOwnerEmail ?? this.transactionOwnerEmail,
      transactionOriginalOwnerEmail:
          transactionOriginalOwnerEmail ?? this.transactionOriginalOwnerEmail,
      sharedKey: sharedKey ?? this.sharedKey,
      sharedOldKey: sharedOldKey ?? this.sharedOldKey,
      sharedStatus: sharedStatus ?? this.sharedStatus,
      sharedDateUpdated: sharedDateUpdated ?? this.sharedDateUpdated,
      sharedReferenceBudgetPk:
          sharedReferenceBudgetPk ?? this.sharedReferenceBudgetPk,
      objectiveFk: objectiveFk ?? this.objectiveFk,
      budgetFksExclude: budgetFksExclude ?? this.budgetFksExclude,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (transactionPk.present) {
      map['transaction_pk'] = Variable<String>(transactionPk.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (categoryFk.present) {
      map['category_fk'] = Variable<String>(categoryFk.value);
    }
    if (subCategoryFk.present) {
      map['sub_category_fk'] = Variable<String>(subCategoryFk.value);
    }
    if (walletFk.present) {
      map['wallet_fk'] = Variable<String>(walletFk.value);
    }
    if (dateCreated.present) {
      map['date_created'] = Variable<DateTime>(dateCreated.value);
    }
    if (dateTimeModified.present) {
      map['date_time_modified'] = Variable<DateTime>(dateTimeModified.value);
    }
    if (originalDateDue.present) {
      map['original_date_due'] = Variable<DateTime>(originalDateDue.value);
    }
    if (income.present) {
      map['income'] = Variable<bool>(income.value);
    }
    if (periodLength.present) {
      map['period_length'] = Variable<int>(periodLength.value);
    }
    if (reoccurrence.present) {
      final converter = $TransactionsTable.$converterreoccurrencen;
      map['reoccurrence'] = Variable<int>(converter.toSql(reoccurrence.value));
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (upcomingTransactionNotification.present) {
      map['upcoming_transaction_notification'] =
          Variable<bool>(upcomingTransactionNotification.value);
    }
    if (type.present) {
      final converter = $TransactionsTable.$convertertypen;
      map['type'] = Variable<int>(converter.toSql(type.value));
    }
    if (paid.present) {
      map['paid'] = Variable<bool>(paid.value);
    }
    if (createdAnotherFutureTransaction.present) {
      map['created_another_future_transaction'] =
          Variable<bool>(createdAnotherFutureTransaction.value);
    }
    if (skipPaid.present) {
      map['skip_paid'] = Variable<bool>(skipPaid.value);
    }
    if (methodAdded.present) {
      final converter = $TransactionsTable.$convertermethodAddedn;
      map['method_added'] = Variable<int>(converter.toSql(methodAdded.value));
    }
    if (transactionOwnerEmail.present) {
      map['transaction_owner_email'] =
          Variable<String>(transactionOwnerEmail.value);
    }
    if (transactionOriginalOwnerEmail.present) {
      map['transaction_original_owner_email'] =
          Variable<String>(transactionOriginalOwnerEmail.value);
    }
    if (sharedKey.present) {
      map['shared_key'] = Variable<String>(sharedKey.value);
    }
    if (sharedOldKey.present) {
      map['shared_old_key'] = Variable<String>(sharedOldKey.value);
    }
    if (sharedStatus.present) {
      final converter = $TransactionsTable.$convertersharedStatusn;
      map['shared_status'] = Variable<int>(converter.toSql(sharedStatus.value));
    }
    if (sharedDateUpdated.present) {
      map['shared_date_updated'] = Variable<DateTime>(sharedDateUpdated.value);
    }
    if (sharedReferenceBudgetPk.present) {
      map['shared_reference_budget_pk'] =
          Variable<String>(sharedReferenceBudgetPk.value);
    }
    if (objectiveFk.present) {
      map['objective_fk'] = Variable<String>(objectiveFk.value);
    }
    if (budgetFksExclude.present) {
      final converter = $TransactionsTable.$converterbudgetFksExcluden;
      map['budget_fks_exclude'] =
          Variable<String>(converter.toSql(budgetFksExclude.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('transactionPk: $transactionPk, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('note: $note, ')
          ..write('categoryFk: $categoryFk, ')
          ..write('subCategoryFk: $subCategoryFk, ')
          ..write('walletFk: $walletFk, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateTimeModified: $dateTimeModified, ')
          ..write('originalDateDue: $originalDateDue, ')
          ..write('income: $income, ')
          ..write('periodLength: $periodLength, ')
          ..write('reoccurrence: $reoccurrence, ')
          ..write('endDate: $endDate, ')
          ..write(
              'upcomingTransactionNotification: $upcomingTransactionNotification, ')
          ..write('type: $type, ')
          ..write('paid: $paid, ')
          ..write(
              'createdAnotherFutureTransaction: $createdAnotherFutureTransaction, ')
          ..write('skipPaid: $skipPaid, ')
          ..write('methodAdded: $methodAdded, ')
          ..write('transactionOwnerEmail: $transactionOwnerEmail, ')
          ..write(
              'transactionOriginalOwnerEmail: $transactionOriginalOwnerEmail, ')
          ..write('sharedKey: $sharedKey, ')
          ..write('sharedOldKey: $sharedOldKey, ')
          ..write('sharedStatus: $sharedStatus, ')
          ..write('sharedDateUpdated: $sharedDateUpdated, ')
          ..write('sharedReferenceBudgetPk: $sharedReferenceBudgetPk, ')
          ..write('objectiveFk: $objectiveFk, ')
          ..write('budgetFksExclude: $budgetFksExclude, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BudgetsTable extends Budgets with TableInfo<$BudgetsTable, Budget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _budgetPkMeta =
      const VerificationMeta('budgetPk');
  @override
  late final GeneratedColumn<String> budgetPk = GeneratedColumn<String>(
      'budget_pk', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => uuid.v4());
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _colourMeta = const VerificationMeta('colour');
  @override
  late final GeneratedColumn<String> colour = GeneratedColumn<String>(
      'colour', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
      'end_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _walletFksMeta =
      const VerificationMeta('walletFks');
  @override
  late final GeneratedColumnWithTypeConverter<List<String>?, String> walletFks =
      GeneratedColumn<String>('wallet_fks', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<List<String>?>($BudgetsTable.$converterwalletFksn);
  static const VerificationMeta _categoryFksMeta =
      const VerificationMeta('categoryFks');
  @override
  late final GeneratedColumnWithTypeConverter<List<String>?, String>
      categoryFks = GeneratedColumn<String>('category_fks', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<List<String>?>($BudgetsTable.$convertercategoryFksn);
  static const VerificationMeta _categoryFksExcludeMeta =
      const VerificationMeta('categoryFksExclude');
  @override
  late final GeneratedColumnWithTypeConverter<List<String>?, String>
      categoryFksExclude = GeneratedColumn<String>(
              'category_fks_exclude', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<List<String>?>(
              $BudgetsTable.$convertercategoryFksExcluden);
  static const VerificationMeta _incomeMeta = const VerificationMeta('income');
  @override
  late final GeneratedColumn<bool> income = GeneratedColumn<bool>(
      'income', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("income" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _addedTransactionsOnlyMeta =
      const VerificationMeta('addedTransactionsOnly');
  @override
  late final GeneratedColumn<bool> addedTransactionsOnly =
      GeneratedColumn<bool>('added_transactions_only', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("added_transactions_only" IN (0, 1))'),
          defaultValue: const Constant(false));
  static const VerificationMeta _periodLengthMeta =
      const VerificationMeta('periodLength');
  @override
  late final GeneratedColumn<int> periodLength = GeneratedColumn<int>(
      'period_length', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _reoccurrenceMeta =
      const VerificationMeta('reoccurrence');
  @override
  late final GeneratedColumnWithTypeConverter<BudgetReoccurence?, int>
      reoccurrence = GeneratedColumn<int>('reoccurrence', aliasedName, true,
              type: DriftSqlType.int, requiredDuringInsert: false)
          .withConverter<BudgetReoccurence?>(
              $BudgetsTable.$converterreoccurrencen);
  static const VerificationMeta _dateCreatedMeta =
      const VerificationMeta('dateCreated');
  @override
  late final GeneratedColumn<DateTime> dateCreated = GeneratedColumn<DateTime>(
      'date_created', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => new DateTime.now());
  static const VerificationMeta _dateTimeModifiedMeta =
      const VerificationMeta('dateTimeModified');
  @override
  late final GeneratedColumn<DateTime> dateTimeModified =
      GeneratedColumn<DateTime>('date_time_modified', aliasedName, true,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: Constant(DateTime.now()));
  static const VerificationMeta _pinnedMeta = const VerificationMeta('pinned');
  @override
  late final GeneratedColumn<bool> pinned = GeneratedColumn<bool>(
      'pinned', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("pinned" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
      'order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _walletFkMeta =
      const VerificationMeta('walletFk');
  @override
  late final GeneratedColumn<String> walletFk = GeneratedColumn<String>(
      'wallet_fk', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES wallets (wallet_pk)'),
      defaultValue: const Constant("0"));
  static const VerificationMeta _budgetTransactionFiltersMeta =
      const VerificationMeta('budgetTransactionFilters');
  @override
  late final GeneratedColumnWithTypeConverter<List<BudgetTransactionFilters>?,
      String> budgetTransactionFilters = GeneratedColumn<String>(
          'budget_transaction_filters', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant(null))
      .withConverter<List<BudgetTransactionFilters>?>(
          $BudgetsTable.$converterbudgetTransactionFiltersn);
  static const VerificationMeta _memberTransactionFiltersMeta =
      const VerificationMeta('memberTransactionFilters');
  @override
  late final GeneratedColumnWithTypeConverter<List<String>?, String>
      memberTransactionFilters = GeneratedColumn<String>(
              'member_transaction_filters', aliasedName, true,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant(null))
          .withConverter<List<String>?>(
              $BudgetsTable.$convertermemberTransactionFiltersn);
  static const VerificationMeta _sharedKeyMeta =
      const VerificationMeta('sharedKey');
  @override
  late final GeneratedColumn<String> sharedKey = GeneratedColumn<String>(
      'shared_key', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sharedOwnerMemberMeta =
      const VerificationMeta('sharedOwnerMember');
  @override
  late final GeneratedColumnWithTypeConverter<SharedOwnerMember?, int>
      sharedOwnerMember = GeneratedColumn<int>(
              'shared_owner_member', aliasedName, true,
              type: DriftSqlType.int, requiredDuringInsert: false)
          .withConverter<SharedOwnerMember?>(
              $BudgetsTable.$convertersharedOwnerMembern);
  static const VerificationMeta _sharedDateUpdatedMeta =
      const VerificationMeta('sharedDateUpdated');
  @override
  late final GeneratedColumn<DateTime> sharedDateUpdated =
      GeneratedColumn<DateTime>('shared_date_updated', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _sharedMembersMeta =
      const VerificationMeta('sharedMembers');
  @override
  late final GeneratedColumnWithTypeConverter<List<String>?, String>
      sharedMembers = GeneratedColumn<String>(
              'shared_members', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<List<String>?>($BudgetsTable.$convertersharedMembersn);
  static const VerificationMeta _sharedAllMembersEverMeta =
      const VerificationMeta('sharedAllMembersEver');
  @override
  late final GeneratedColumnWithTypeConverter<List<String>?, String>
      sharedAllMembersEver = GeneratedColumn<String>(
              'shared_all_members_ever', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<List<String>?>(
              $BudgetsTable.$convertersharedAllMembersEvern);
  static const VerificationMeta _isAbsoluteSpendingLimitMeta =
      const VerificationMeta('isAbsoluteSpendingLimit');
  @override
  late final GeneratedColumn<bool> isAbsoluteSpendingLimit =
      GeneratedColumn<bool>('is_absolute_spending_limit', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("is_absolute_spending_limit" IN (0, 1))'),
          defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        budgetPk,
        name,
        amount,
        colour,
        startDate,
        endDate,
        walletFks,
        categoryFks,
        categoryFksExclude,
        income,
        addedTransactionsOnly,
        periodLength,
        reoccurrence,
        dateCreated,
        dateTimeModified,
        pinned,
        order,
        walletFk,
        budgetTransactionFilters,
        memberTransactionFilters,
        sharedKey,
        sharedOwnerMember,
        sharedDateUpdated,
        sharedMembers,
        sharedAllMembersEver,
        isAbsoluteSpendingLimit
      ];
  @override
  String get aliasedName => _alias ?? 'budgets';
  @override
  String get actualTableName => 'budgets';
  @override
  VerificationContext validateIntegrity(Insertable<Budget> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('budget_pk')) {
      context.handle(_budgetPkMeta,
          budgetPk.isAcceptableOrUnknown(data['budget_pk']!, _budgetPkMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('colour')) {
      context.handle(_colourMeta,
          colour.isAcceptableOrUnknown(data['colour']!, _colourMeta));
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    } else if (isInserting) {
      context.missing(_endDateMeta);
    }
    context.handle(_walletFksMeta, const VerificationResult.success());
    context.handle(_categoryFksMeta, const VerificationResult.success());
    context.handle(_categoryFksExcludeMeta, const VerificationResult.success());
    if (data.containsKey('income')) {
      context.handle(_incomeMeta,
          income.isAcceptableOrUnknown(data['income']!, _incomeMeta));
    }
    if (data.containsKey('added_transactions_only')) {
      context.handle(
          _addedTransactionsOnlyMeta,
          addedTransactionsOnly.isAcceptableOrUnknown(
              data['added_transactions_only']!, _addedTransactionsOnlyMeta));
    }
    if (data.containsKey('period_length')) {
      context.handle(
          _periodLengthMeta,
          periodLength.isAcceptableOrUnknown(
              data['period_length']!, _periodLengthMeta));
    } else if (isInserting) {
      context.missing(_periodLengthMeta);
    }
    context.handle(_reoccurrenceMeta, const VerificationResult.success());
    if (data.containsKey('date_created')) {
      context.handle(
          _dateCreatedMeta,
          dateCreated.isAcceptableOrUnknown(
              data['date_created']!, _dateCreatedMeta));
    }
    if (data.containsKey('date_time_modified')) {
      context.handle(
          _dateTimeModifiedMeta,
          dateTimeModified.isAcceptableOrUnknown(
              data['date_time_modified']!, _dateTimeModifiedMeta));
    }
    if (data.containsKey('pinned')) {
      context.handle(_pinnedMeta,
          pinned.isAcceptableOrUnknown(data['pinned']!, _pinnedMeta));
    }
    if (data.containsKey('order')) {
      context.handle(
          _orderMeta, order.isAcceptableOrUnknown(data['order']!, _orderMeta));
    } else if (isInserting) {
      context.missing(_orderMeta);
    }
    if (data.containsKey('wallet_fk')) {
      context.handle(_walletFkMeta,
          walletFk.isAcceptableOrUnknown(data['wallet_fk']!, _walletFkMeta));
    }
    context.handle(
        _budgetTransactionFiltersMeta, const VerificationResult.success());
    context.handle(
        _memberTransactionFiltersMeta, const VerificationResult.success());
    if (data.containsKey('shared_key')) {
      context.handle(_sharedKeyMeta,
          sharedKey.isAcceptableOrUnknown(data['shared_key']!, _sharedKeyMeta));
    }
    context.handle(_sharedOwnerMemberMeta, const VerificationResult.success());
    if (data.containsKey('shared_date_updated')) {
      context.handle(
          _sharedDateUpdatedMeta,
          sharedDateUpdated.isAcceptableOrUnknown(
              data['shared_date_updated']!, _sharedDateUpdatedMeta));
    }
    context.handle(_sharedMembersMeta, const VerificationResult.success());
    context.handle(
        _sharedAllMembersEverMeta, const VerificationResult.success());
    if (data.containsKey('is_absolute_spending_limit')) {
      context.handle(
          _isAbsoluteSpendingLimitMeta,
          isAbsoluteSpendingLimit.isAcceptableOrUnknown(
              data['is_absolute_spending_limit']!,
              _isAbsoluteSpendingLimitMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {budgetPk};
  @override
  Budget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Budget(
      budgetPk: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}budget_pk'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      colour: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}colour']),
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date'])!,
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_date'])!,
      walletFks: $BudgetsTable.$converterwalletFksn.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}wallet_fks'])),
      categoryFks: $BudgetsTable.$convertercategoryFksn.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_fks'])),
      categoryFksExclude: $BudgetsTable.$convertercategoryFksExcluden.fromSql(
          attachedDatabase.typeMapping.read(DriftSqlType.string,
              data['${effectivePrefix}category_fks_exclude'])),
      income: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}income'])!,
      addedTransactionsOnly: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}added_transactions_only'])!,
      periodLength: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}period_length'])!,
      reoccurrence: $BudgetsTable.$converterreoccurrencen.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.int, data['${effectivePrefix}reoccurrence'])),
      dateCreated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_created'])!,
      dateTimeModified: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}date_time_modified']),
      pinned: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}pinned'])!,
      order: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order'])!,
      walletFk: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}wallet_fk'])!,
      budgetTransactionFilters: $BudgetsTable
          .$converterbudgetTransactionFiltersn
          .fromSql(attachedDatabase.typeMapping.read(DriftSqlType.string,
              data['${effectivePrefix}budget_transaction_filters'])),
      memberTransactionFilters: $BudgetsTable
          .$convertermemberTransactionFiltersn
          .fromSql(attachedDatabase.typeMapping.read(DriftSqlType.string,
              data['${effectivePrefix}member_transaction_filters'])),
      sharedKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}shared_key']),
      sharedOwnerMember: $BudgetsTable.$convertersharedOwnerMembern.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.int, data['${effectivePrefix}shared_owner_member'])),
      sharedDateUpdated: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}shared_date_updated']),
      sharedMembers: $BudgetsTable.$convertersharedMembersn.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}shared_members'])),
      sharedAllMembersEver: $BudgetsTable.$convertersharedAllMembersEvern
          .fromSql(attachedDatabase.typeMapping.read(DriftSqlType.string,
              data['${effectivePrefix}shared_all_members_ever'])),
      isAbsoluteSpendingLimit: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}is_absolute_spending_limit'])!,
    );
  }

  @override
  $BudgetsTable createAlias(String alias) {
    return $BudgetsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterwalletFks =
      const StringListInColumnConverter();
  static TypeConverter<List<String>?, String?> $converterwalletFksn =
      NullAwareTypeConverter.wrap($converterwalletFks);
  static TypeConverter<List<String>, String> $convertercategoryFks =
      const StringListInColumnConverter();
  static TypeConverter<List<String>?, String?> $convertercategoryFksn =
      NullAwareTypeConverter.wrap($convertercategoryFks);
  static TypeConverter<List<String>, String> $convertercategoryFksExclude =
      const StringListInColumnConverter();
  static TypeConverter<List<String>?, String?> $convertercategoryFksExcluden =
      NullAwareTypeConverter.wrap($convertercategoryFksExclude);
  static JsonTypeConverter2<BudgetReoccurence, int, int>
      $converterreoccurrence =
      const EnumIndexConverter<BudgetReoccurence>(BudgetReoccurence.values);
  static JsonTypeConverter2<BudgetReoccurence?, int?, int?>
      $converterreoccurrencen =
      JsonTypeConverter2.asNullable($converterreoccurrence);
  static TypeConverter<List<BudgetTransactionFilters>, String>
      $converterbudgetTransactionFilters =
      const BudgetTransactionFiltersListInColumnConverter();
  static TypeConverter<List<BudgetTransactionFilters>?, String?>
      $converterbudgetTransactionFiltersn =
      NullAwareTypeConverter.wrap($converterbudgetTransactionFilters);
  static TypeConverter<List<String>, String>
      $convertermemberTransactionFilters = const StringListInColumnConverter();
  static TypeConverter<List<String>?, String?>
      $convertermemberTransactionFiltersn =
      NullAwareTypeConverter.wrap($convertermemberTransactionFilters);
  static JsonTypeConverter2<SharedOwnerMember, int, int>
      $convertersharedOwnerMember =
      const EnumIndexConverter<SharedOwnerMember>(SharedOwnerMember.values);
  static JsonTypeConverter2<SharedOwnerMember?, int?, int?>
      $convertersharedOwnerMembern =
      JsonTypeConverter2.asNullable($convertersharedOwnerMember);
  static TypeConverter<List<String>, String> $convertersharedMembers =
      const StringListInColumnConverter();
  static TypeConverter<List<String>?, String?> $convertersharedMembersn =
      NullAwareTypeConverter.wrap($convertersharedMembers);
  static TypeConverter<List<String>, String> $convertersharedAllMembersEver =
      const StringListInColumnConverter();
  static TypeConverter<List<String>?, String?> $convertersharedAllMembersEvern =
      NullAwareTypeConverter.wrap($convertersharedAllMembersEver);
}

class Budget extends DataClass implements Insertable<Budget> {
  final String budgetPk;
  final String name;
  final double amount;
  final String? colour;
  final DateTime startDate;
  final DateTime endDate;
  final List<String>? walletFks;
  final List<String>? categoryFks;
  final List<String>? categoryFksExclude;
  final bool income;
  final bool addedTransactionsOnly;
  final int periodLength;
  final BudgetReoccurence? reoccurrence;
  final DateTime dateCreated;
  final DateTime? dateTimeModified;
  final bool pinned;
  final int order;
  final String walletFk;
  final List<BudgetTransactionFilters>? budgetTransactionFilters;
  final List<String>? memberTransactionFilters;
  final String? sharedKey;
  final SharedOwnerMember? sharedOwnerMember;
  final DateTime? sharedDateUpdated;
  final List<String>? sharedMembers;
  final List<String>? sharedAllMembersEver;
  final bool isAbsoluteSpendingLimit;
  const Budget(
      {required this.budgetPk,
      required this.name,
      required this.amount,
      this.colour,
      required this.startDate,
      required this.endDate,
      this.walletFks,
      this.categoryFks,
      this.categoryFksExclude,
      required this.income,
      required this.addedTransactionsOnly,
      required this.periodLength,
      this.reoccurrence,
      required this.dateCreated,
      this.dateTimeModified,
      required this.pinned,
      required this.order,
      required this.walletFk,
      this.budgetTransactionFilters,
      this.memberTransactionFilters,
      this.sharedKey,
      this.sharedOwnerMember,
      this.sharedDateUpdated,
      this.sharedMembers,
      this.sharedAllMembersEver,
      required this.isAbsoluteSpendingLimit});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['budget_pk'] = Variable<String>(budgetPk);
    map['name'] = Variable<String>(name);
    map['amount'] = Variable<double>(amount);
    if (!nullToAbsent || colour != null) {
      map['colour'] = Variable<String>(colour);
    }
    map['start_date'] = Variable<DateTime>(startDate);
    map['end_date'] = Variable<DateTime>(endDate);
    if (!nullToAbsent || walletFks != null) {
      final converter = $BudgetsTable.$converterwalletFksn;
      map['wallet_fks'] = Variable<String>(converter.toSql(walletFks));
    }
    if (!nullToAbsent || categoryFks != null) {
      final converter = $BudgetsTable.$convertercategoryFksn;
      map['category_fks'] = Variable<String>(converter.toSql(categoryFks));
    }
    if (!nullToAbsent || categoryFksExclude != null) {
      final converter = $BudgetsTable.$convertercategoryFksExcluden;
      map['category_fks_exclude'] =
          Variable<String>(converter.toSql(categoryFksExclude));
    }
    map['income'] = Variable<bool>(income);
    map['added_transactions_only'] = Variable<bool>(addedTransactionsOnly);
    map['period_length'] = Variable<int>(periodLength);
    if (!nullToAbsent || reoccurrence != null) {
      final converter = $BudgetsTable.$converterreoccurrencen;
      map['reoccurrence'] = Variable<int>(converter.toSql(reoccurrence));
    }
    map['date_created'] = Variable<DateTime>(dateCreated);
    if (!nullToAbsent || dateTimeModified != null) {
      map['date_time_modified'] = Variable<DateTime>(dateTimeModified);
    }
    map['pinned'] = Variable<bool>(pinned);
    map['order'] = Variable<int>(order);
    map['wallet_fk'] = Variable<String>(walletFk);
    if (!nullToAbsent || budgetTransactionFilters != null) {
      final converter = $BudgetsTable.$converterbudgetTransactionFiltersn;
      map['budget_transaction_filters'] =
          Variable<String>(converter.toSql(budgetTransactionFilters));
    }
    if (!nullToAbsent || memberTransactionFilters != null) {
      final converter = $BudgetsTable.$convertermemberTransactionFiltersn;
      map['member_transaction_filters'] =
          Variable<String>(converter.toSql(memberTransactionFilters));
    }
    if (!nullToAbsent || sharedKey != null) {
      map['shared_key'] = Variable<String>(sharedKey);
    }
    if (!nullToAbsent || sharedOwnerMember != null) {
      final converter = $BudgetsTable.$convertersharedOwnerMembern;
      map['shared_owner_member'] =
          Variable<int>(converter.toSql(sharedOwnerMember));
    }
    if (!nullToAbsent || sharedDateUpdated != null) {
      map['shared_date_updated'] = Variable<DateTime>(sharedDateUpdated);
    }
    if (!nullToAbsent || sharedMembers != null) {
      final converter = $BudgetsTable.$convertersharedMembersn;
      map['shared_members'] = Variable<String>(converter.toSql(sharedMembers));
    }
    if (!nullToAbsent || sharedAllMembersEver != null) {
      final converter = $BudgetsTable.$convertersharedAllMembersEvern;
      map['shared_all_members_ever'] =
          Variable<String>(converter.toSql(sharedAllMembersEver));
    }
    map['is_absolute_spending_limit'] = Variable<bool>(isAbsoluteSpendingLimit);
    return map;
  }

  BudgetsCompanion toCompanion(bool nullToAbsent) {
    return BudgetsCompanion(
      budgetPk: Value(budgetPk),
      name: Value(name),
      amount: Value(amount),
      colour:
          colour == null && nullToAbsent ? const Value.absent() : Value(colour),
      startDate: Value(startDate),
      endDate: Value(endDate),
      walletFks: walletFks == null && nullToAbsent
          ? const Value.absent()
          : Value(walletFks),
      categoryFks: categoryFks == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryFks),
      categoryFksExclude: categoryFksExclude == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryFksExclude),
      income: Value(income),
      addedTransactionsOnly: Value(addedTransactionsOnly),
      periodLength: Value(periodLength),
      reoccurrence: reoccurrence == null && nullToAbsent
          ? const Value.absent()
          : Value(reoccurrence),
      dateCreated: Value(dateCreated),
      dateTimeModified: dateTimeModified == null && nullToAbsent
          ? const Value.absent()
          : Value(dateTimeModified),
      pinned: Value(pinned),
      order: Value(order),
      walletFk: Value(walletFk),
      budgetTransactionFilters: budgetTransactionFilters == null && nullToAbsent
          ? const Value.absent()
          : Value(budgetTransactionFilters),
      memberTransactionFilters: memberTransactionFilters == null && nullToAbsent
          ? const Value.absent()
          : Value(memberTransactionFilters),
      sharedKey: sharedKey == null && nullToAbsent
          ? const Value.absent()
          : Value(sharedKey),
      sharedOwnerMember: sharedOwnerMember == null && nullToAbsent
          ? const Value.absent()
          : Value(sharedOwnerMember),
      sharedDateUpdated: sharedDateUpdated == null && nullToAbsent
          ? const Value.absent()
          : Value(sharedDateUpdated),
      sharedMembers: sharedMembers == null && nullToAbsent
          ? const Value.absent()
          : Value(sharedMembers),
      sharedAllMembersEver: sharedAllMembersEver == null && nullToAbsent
          ? const Value.absent()
          : Value(sharedAllMembersEver),
      isAbsoluteSpendingLimit: Value(isAbsoluteSpendingLimit),
    );
  }

  factory Budget.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Budget(
      budgetPk: serializer.fromJson<String>(json['budgetPk']),
      name: serializer.fromJson<String>(json['name']),
      amount: serializer.fromJson<double>(json['amount']),
      colour: serializer.fromJson<String?>(json['colour']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime>(json['endDate']),
      walletFks: serializer.fromJson<List<String>?>(json['walletFks']),
      categoryFks: serializer.fromJson<List<String>?>(json['categoryFks']),
      categoryFksExclude:
          serializer.fromJson<List<String>?>(json['categoryFksExclude']),
      income: serializer.fromJson<bool>(json['income']),
      addedTransactionsOnly:
          serializer.fromJson<bool>(json['addedTransactionsOnly']),
      periodLength: serializer.fromJson<int>(json['periodLength']),
      reoccurrence: $BudgetsTable.$converterreoccurrencen
          .fromJson(serializer.fromJson<int?>(json['reoccurrence'])),
      dateCreated: serializer.fromJson<DateTime>(json['dateCreated']),
      dateTimeModified:
          serializer.fromJson<DateTime?>(json['dateTimeModified']),
      pinned: serializer.fromJson<bool>(json['pinned']),
      order: serializer.fromJson<int>(json['order']),
      walletFk: serializer.fromJson<String>(json['walletFk']),
      budgetTransactionFilters:
          serializer.fromJson<List<BudgetTransactionFilters>?>(
              json['budgetTransactionFilters']),
      memberTransactionFilters:
          serializer.fromJson<List<String>?>(json['memberTransactionFilters']),
      sharedKey: serializer.fromJson<String?>(json['sharedKey']),
      sharedOwnerMember: $BudgetsTable.$convertersharedOwnerMembern
          .fromJson(serializer.fromJson<int?>(json['sharedOwnerMember'])),
      sharedDateUpdated:
          serializer.fromJson<DateTime?>(json['sharedDateUpdated']),
      sharedMembers: serializer.fromJson<List<String>?>(json['sharedMembers']),
      sharedAllMembersEver:
          serializer.fromJson<List<String>?>(json['sharedAllMembersEver']),
      isAbsoluteSpendingLimit:
          serializer.fromJson<bool>(json['isAbsoluteSpendingLimit']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'budgetPk': serializer.toJson<String>(budgetPk),
      'name': serializer.toJson<String>(name),
      'amount': serializer.toJson<double>(amount),
      'colour': serializer.toJson<String?>(colour),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime>(endDate),
      'walletFks': serializer.toJson<List<String>?>(walletFks),
      'categoryFks': serializer.toJson<List<String>?>(categoryFks),
      'categoryFksExclude':
          serializer.toJson<List<String>?>(categoryFksExclude),
      'income': serializer.toJson<bool>(income),
      'addedTransactionsOnly': serializer.toJson<bool>(addedTransactionsOnly),
      'periodLength': serializer.toJson<int>(periodLength),
      'reoccurrence': serializer.toJson<int?>(
          $BudgetsTable.$converterreoccurrencen.toJson(reoccurrence)),
      'dateCreated': serializer.toJson<DateTime>(dateCreated),
      'dateTimeModified': serializer.toJson<DateTime?>(dateTimeModified),
      'pinned': serializer.toJson<bool>(pinned),
      'order': serializer.toJson<int>(order),
      'walletFk': serializer.toJson<String>(walletFk),
      'budgetTransactionFilters': serializer
          .toJson<List<BudgetTransactionFilters>?>(budgetTransactionFilters),
      'memberTransactionFilters':
          serializer.toJson<List<String>?>(memberTransactionFilters),
      'sharedKey': serializer.toJson<String?>(sharedKey),
      'sharedOwnerMember': serializer.toJson<int?>(
          $BudgetsTable.$convertersharedOwnerMembern.toJson(sharedOwnerMember)),
      'sharedDateUpdated': serializer.toJson<DateTime?>(sharedDateUpdated),
      'sharedMembers': serializer.toJson<List<String>?>(sharedMembers),
      'sharedAllMembersEver':
          serializer.toJson<List<String>?>(sharedAllMembersEver),
      'isAbsoluteSpendingLimit':
          serializer.toJson<bool>(isAbsoluteSpendingLimit),
    };
  }

  Budget copyWith(
          {String? budgetPk,
          String? name,
          double? amount,
          Value<String?> colour = const Value.absent(),
          DateTime? startDate,
          DateTime? endDate,
          Value<List<String>?> walletFks = const Value.absent(),
          Value<List<String>?> categoryFks = const Value.absent(),
          Value<List<String>?> categoryFksExclude = const Value.absent(),
          bool? income,
          bool? addedTransactionsOnly,
          int? periodLength,
          Value<BudgetReoccurence?> reoccurrence = const Value.absent(),
          DateTime? dateCreated,
          Value<DateTime?> dateTimeModified = const Value.absent(),
          bool? pinned,
          int? order,
          String? walletFk,
          Value<List<BudgetTransactionFilters>?> budgetTransactionFilters =
              const Value.absent(),
          Value<List<String>?> memberTransactionFilters = const Value.absent(),
          Value<String?> sharedKey = const Value.absent(),
          Value<SharedOwnerMember?> sharedOwnerMember = const Value.absent(),
          Value<DateTime?> sharedDateUpdated = const Value.absent(),
          Value<List<String>?> sharedMembers = const Value.absent(),
          Value<List<String>?> sharedAllMembersEver = const Value.absent(),
          bool? isAbsoluteSpendingLimit}) =>
      Budget(
        budgetPk: budgetPk ?? this.budgetPk,
        name: name ?? this.name,
        amount: amount ?? this.amount,
        colour: colour.present ? colour.value : this.colour,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        walletFks: walletFks.present ? walletFks.value : this.walletFks,
        categoryFks: categoryFks.present ? categoryFks.value : this.categoryFks,
        categoryFksExclude: categoryFksExclude.present
            ? categoryFksExclude.value
            : this.categoryFksExclude,
        income: income ?? this.income,
        addedTransactionsOnly:
            addedTransactionsOnly ?? this.addedTransactionsOnly,
        periodLength: periodLength ?? this.periodLength,
        reoccurrence:
            reoccurrence.present ? reoccurrence.value : this.reoccurrence,
        dateCreated: dateCreated ?? this.dateCreated,
        dateTimeModified: dateTimeModified.present
            ? dateTimeModified.value
            : this.dateTimeModified,
        pinned: pinned ?? this.pinned,
        order: order ?? this.order,
        walletFk: walletFk ?? this.walletFk,
        budgetTransactionFilters: budgetTransactionFilters.present
            ? budgetTransactionFilters.value
            : this.budgetTransactionFilters,
        memberTransactionFilters: memberTransactionFilters.present
            ? memberTransactionFilters.value
            : this.memberTransactionFilters,
        sharedKey: sharedKey.present ? sharedKey.value : this.sharedKey,
        sharedOwnerMember: sharedOwnerMember.present
            ? sharedOwnerMember.value
            : this.sharedOwnerMember,
        sharedDateUpdated: sharedDateUpdated.present
            ? sharedDateUpdated.value
            : this.sharedDateUpdated,
        sharedMembers:
            sharedMembers.present ? sharedMembers.value : this.sharedMembers,
        sharedAllMembersEver: sharedAllMembersEver.present
            ? sharedAllMembersEver.value
            : this.sharedAllMembersEver,
        isAbsoluteSpendingLimit:
            isAbsoluteSpendingLimit ?? this.isAbsoluteSpendingLimit,
      );
  @override
  String toString() {
    return (StringBuffer('Budget(')
          ..write('budgetPk: $budgetPk, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('colour: $colour, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('walletFks: $walletFks, ')
          ..write('categoryFks: $categoryFks, ')
          ..write('categoryFksExclude: $categoryFksExclude, ')
          ..write('income: $income, ')
          ..write('addedTransactionsOnly: $addedTransactionsOnly, ')
          ..write('periodLength: $periodLength, ')
          ..write('reoccurrence: $reoccurrence, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateTimeModified: $dateTimeModified, ')
          ..write('pinned: $pinned, ')
          ..write('order: $order, ')
          ..write('walletFk: $walletFk, ')
          ..write('budgetTransactionFilters: $budgetTransactionFilters, ')
          ..write('memberTransactionFilters: $memberTransactionFilters, ')
          ..write('sharedKey: $sharedKey, ')
          ..write('sharedOwnerMember: $sharedOwnerMember, ')
          ..write('sharedDateUpdated: $sharedDateUpdated, ')
          ..write('sharedMembers: $sharedMembers, ')
          ..write('sharedAllMembersEver: $sharedAllMembersEver, ')
          ..write('isAbsoluteSpendingLimit: $isAbsoluteSpendingLimit')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        budgetPk,
        name,
        amount,
        colour,
        startDate,
        endDate,
        walletFks,
        categoryFks,
        categoryFksExclude,
        income,
        addedTransactionsOnly,
        periodLength,
        reoccurrence,
        dateCreated,
        dateTimeModified,
        pinned,
        order,
        walletFk,
        budgetTransactionFilters,
        memberTransactionFilters,
        sharedKey,
        sharedOwnerMember,
        sharedDateUpdated,
        sharedMembers,
        sharedAllMembersEver,
        isAbsoluteSpendingLimit
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Budget &&
          other.budgetPk == this.budgetPk &&
          other.name == this.name &&
          other.amount == this.amount &&
          other.colour == this.colour &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.walletFks == this.walletFks &&
          other.categoryFks == this.categoryFks &&
          other.categoryFksExclude == this.categoryFksExclude &&
          other.income == this.income &&
          other.addedTransactionsOnly == this.addedTransactionsOnly &&
          other.periodLength == this.periodLength &&
          other.reoccurrence == this.reoccurrence &&
          other.dateCreated == this.dateCreated &&
          other.dateTimeModified == this.dateTimeModified &&
          other.pinned == this.pinned &&
          other.order == this.order &&
          other.walletFk == this.walletFk &&
          other.budgetTransactionFilters == this.budgetTransactionFilters &&
          other.memberTransactionFilters == this.memberTransactionFilters &&
          other.sharedKey == this.sharedKey &&
          other.sharedOwnerMember == this.sharedOwnerMember &&
          other.sharedDateUpdated == this.sharedDateUpdated &&
          other.sharedMembers == this.sharedMembers &&
          other.sharedAllMembersEver == this.sharedAllMembersEver &&
          other.isAbsoluteSpendingLimit == this.isAbsoluteSpendingLimit);
}

class BudgetsCompanion extends UpdateCompanion<Budget> {
  final Value<String> budgetPk;
  final Value<String> name;
  final Value<double> amount;
  final Value<String?> colour;
  final Value<DateTime> startDate;
  final Value<DateTime> endDate;
  final Value<List<String>?> walletFks;
  final Value<List<String>?> categoryFks;
  final Value<List<String>?> categoryFksExclude;
  final Value<bool> income;
  final Value<bool> addedTransactionsOnly;
  final Value<int> periodLength;
  final Value<BudgetReoccurence?> reoccurrence;
  final Value<DateTime> dateCreated;
  final Value<DateTime?> dateTimeModified;
  final Value<bool> pinned;
  final Value<int> order;
  final Value<String> walletFk;
  final Value<List<BudgetTransactionFilters>?> budgetTransactionFilters;
  final Value<List<String>?> memberTransactionFilters;
  final Value<String?> sharedKey;
  final Value<SharedOwnerMember?> sharedOwnerMember;
  final Value<DateTime?> sharedDateUpdated;
  final Value<List<String>?> sharedMembers;
  final Value<List<String>?> sharedAllMembersEver;
  final Value<bool> isAbsoluteSpendingLimit;
  final Value<int> rowid;
  const BudgetsCompanion({
    this.budgetPk = const Value.absent(),
    this.name = const Value.absent(),
    this.amount = const Value.absent(),
    this.colour = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.walletFks = const Value.absent(),
    this.categoryFks = const Value.absent(),
    this.categoryFksExclude = const Value.absent(),
    this.income = const Value.absent(),
    this.addedTransactionsOnly = const Value.absent(),
    this.periodLength = const Value.absent(),
    this.reoccurrence = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.dateTimeModified = const Value.absent(),
    this.pinned = const Value.absent(),
    this.order = const Value.absent(),
    this.walletFk = const Value.absent(),
    this.budgetTransactionFilters = const Value.absent(),
    this.memberTransactionFilters = const Value.absent(),
    this.sharedKey = const Value.absent(),
    this.sharedOwnerMember = const Value.absent(),
    this.sharedDateUpdated = const Value.absent(),
    this.sharedMembers = const Value.absent(),
    this.sharedAllMembersEver = const Value.absent(),
    this.isAbsoluteSpendingLimit = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BudgetsCompanion.insert({
    this.budgetPk = const Value.absent(),
    required String name,
    required double amount,
    this.colour = const Value.absent(),
    required DateTime startDate,
    required DateTime endDate,
    this.walletFks = const Value.absent(),
    this.categoryFks = const Value.absent(),
    this.categoryFksExclude = const Value.absent(),
    this.income = const Value.absent(),
    this.addedTransactionsOnly = const Value.absent(),
    required int periodLength,
    this.reoccurrence = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.dateTimeModified = const Value.absent(),
    this.pinned = const Value.absent(),
    required int order,
    this.walletFk = const Value.absent(),
    this.budgetTransactionFilters = const Value.absent(),
    this.memberTransactionFilters = const Value.absent(),
    this.sharedKey = const Value.absent(),
    this.sharedOwnerMember = const Value.absent(),
    this.sharedDateUpdated = const Value.absent(),
    this.sharedMembers = const Value.absent(),
    this.sharedAllMembersEver = const Value.absent(),
    this.isAbsoluteSpendingLimit = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : name = Value(name),
        amount = Value(amount),
        startDate = Value(startDate),
        endDate = Value(endDate),
        periodLength = Value(periodLength),
        order = Value(order);
  static Insertable<Budget> custom({
    Expression<String>? budgetPk,
    Expression<String>? name,
    Expression<double>? amount,
    Expression<String>? colour,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<String>? walletFks,
    Expression<String>? categoryFks,
    Expression<String>? categoryFksExclude,
    Expression<bool>? income,
    Expression<bool>? addedTransactionsOnly,
    Expression<int>? periodLength,
    Expression<int>? reoccurrence,
    Expression<DateTime>? dateCreated,
    Expression<DateTime>? dateTimeModified,
    Expression<bool>? pinned,
    Expression<int>? order,
    Expression<String>? walletFk,
    Expression<String>? budgetTransactionFilters,
    Expression<String>? memberTransactionFilters,
    Expression<String>? sharedKey,
    Expression<int>? sharedOwnerMember,
    Expression<DateTime>? sharedDateUpdated,
    Expression<String>? sharedMembers,
    Expression<String>? sharedAllMembersEver,
    Expression<bool>? isAbsoluteSpendingLimit,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (budgetPk != null) 'budget_pk': budgetPk,
      if (name != null) 'name': name,
      if (amount != null) 'amount': amount,
      if (colour != null) 'colour': colour,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (walletFks != null) 'wallet_fks': walletFks,
      if (categoryFks != null) 'category_fks': categoryFks,
      if (categoryFksExclude != null)
        'category_fks_exclude': categoryFksExclude,
      if (income != null) 'income': income,
      if (addedTransactionsOnly != null)
        'added_transactions_only': addedTransactionsOnly,
      if (periodLength != null) 'period_length': periodLength,
      if (reoccurrence != null) 'reoccurrence': reoccurrence,
      if (dateCreated != null) 'date_created': dateCreated,
      if (dateTimeModified != null) 'date_time_modified': dateTimeModified,
      if (pinned != null) 'pinned': pinned,
      if (order != null) 'order': order,
      if (walletFk != null) 'wallet_fk': walletFk,
      if (budgetTransactionFilters != null)
        'budget_transaction_filters': budgetTransactionFilters,
      if (memberTransactionFilters != null)
        'member_transaction_filters': memberTransactionFilters,
      if (sharedKey != null) 'shared_key': sharedKey,
      if (sharedOwnerMember != null) 'shared_owner_member': sharedOwnerMember,
      if (sharedDateUpdated != null) 'shared_date_updated': sharedDateUpdated,
      if (sharedMembers != null) 'shared_members': sharedMembers,
      if (sharedAllMembersEver != null)
        'shared_all_members_ever': sharedAllMembersEver,
      if (isAbsoluteSpendingLimit != null)
        'is_absolute_spending_limit': isAbsoluteSpendingLimit,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BudgetsCompanion copyWith(
      {Value<String>? budgetPk,
      Value<String>? name,
      Value<double>? amount,
      Value<String?>? colour,
      Value<DateTime>? startDate,
      Value<DateTime>? endDate,
      Value<List<String>?>? walletFks,
      Value<List<String>?>? categoryFks,
      Value<List<String>?>? categoryFksExclude,
      Value<bool>? income,
      Value<bool>? addedTransactionsOnly,
      Value<int>? periodLength,
      Value<BudgetReoccurence?>? reoccurrence,
      Value<DateTime>? dateCreated,
      Value<DateTime?>? dateTimeModified,
      Value<bool>? pinned,
      Value<int>? order,
      Value<String>? walletFk,
      Value<List<BudgetTransactionFilters>?>? budgetTransactionFilters,
      Value<List<String>?>? memberTransactionFilters,
      Value<String?>? sharedKey,
      Value<SharedOwnerMember?>? sharedOwnerMember,
      Value<DateTime?>? sharedDateUpdated,
      Value<List<String>?>? sharedMembers,
      Value<List<String>?>? sharedAllMembersEver,
      Value<bool>? isAbsoluteSpendingLimit,
      Value<int>? rowid}) {
    return BudgetsCompanion(
      budgetPk: budgetPk ?? this.budgetPk,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      colour: colour ?? this.colour,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      walletFks: walletFks ?? this.walletFks,
      categoryFks: categoryFks ?? this.categoryFks,
      categoryFksExclude: categoryFksExclude ?? this.categoryFksExclude,
      income: income ?? this.income,
      addedTransactionsOnly:
          addedTransactionsOnly ?? this.addedTransactionsOnly,
      periodLength: periodLength ?? this.periodLength,
      reoccurrence: reoccurrence ?? this.reoccurrence,
      dateCreated: dateCreated ?? this.dateCreated,
      dateTimeModified: dateTimeModified ?? this.dateTimeModified,
      pinned: pinned ?? this.pinned,
      order: order ?? this.order,
      walletFk: walletFk ?? this.walletFk,
      budgetTransactionFilters:
          budgetTransactionFilters ?? this.budgetTransactionFilters,
      memberTransactionFilters:
          memberTransactionFilters ?? this.memberTransactionFilters,
      sharedKey: sharedKey ?? this.sharedKey,
      sharedOwnerMember: sharedOwnerMember ?? this.sharedOwnerMember,
      sharedDateUpdated: sharedDateUpdated ?? this.sharedDateUpdated,
      sharedMembers: sharedMembers ?? this.sharedMembers,
      sharedAllMembersEver: sharedAllMembersEver ?? this.sharedAllMembersEver,
      isAbsoluteSpendingLimit:
          isAbsoluteSpendingLimit ?? this.isAbsoluteSpendingLimit,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (budgetPk.present) {
      map['budget_pk'] = Variable<String>(budgetPk.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (colour.present) {
      map['colour'] = Variable<String>(colour.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (walletFks.present) {
      final converter = $BudgetsTable.$converterwalletFksn;
      map['wallet_fks'] = Variable<String>(converter.toSql(walletFks.value));
    }
    if (categoryFks.present) {
      final converter = $BudgetsTable.$convertercategoryFksn;
      map['category_fks'] =
          Variable<String>(converter.toSql(categoryFks.value));
    }
    if (categoryFksExclude.present) {
      final converter = $BudgetsTable.$convertercategoryFksExcluden;
      map['category_fks_exclude'] =
          Variable<String>(converter.toSql(categoryFksExclude.value));
    }
    if (income.present) {
      map['income'] = Variable<bool>(income.value);
    }
    if (addedTransactionsOnly.present) {
      map['added_transactions_only'] =
          Variable<bool>(addedTransactionsOnly.value);
    }
    if (periodLength.present) {
      map['period_length'] = Variable<int>(periodLength.value);
    }
    if (reoccurrence.present) {
      final converter = $BudgetsTable.$converterreoccurrencen;
      map['reoccurrence'] = Variable<int>(converter.toSql(reoccurrence.value));
    }
    if (dateCreated.present) {
      map['date_created'] = Variable<DateTime>(dateCreated.value);
    }
    if (dateTimeModified.present) {
      map['date_time_modified'] = Variable<DateTime>(dateTimeModified.value);
    }
    if (pinned.present) {
      map['pinned'] = Variable<bool>(pinned.value);
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    if (walletFk.present) {
      map['wallet_fk'] = Variable<String>(walletFk.value);
    }
    if (budgetTransactionFilters.present) {
      final converter = $BudgetsTable.$converterbudgetTransactionFiltersn;
      map['budget_transaction_filters'] =
          Variable<String>(converter.toSql(budgetTransactionFilters.value));
    }
    if (memberTransactionFilters.present) {
      final converter = $BudgetsTable.$convertermemberTransactionFiltersn;
      map['member_transaction_filters'] =
          Variable<String>(converter.toSql(memberTransactionFilters.value));
    }
    if (sharedKey.present) {
      map['shared_key'] = Variable<String>(sharedKey.value);
    }
    if (sharedOwnerMember.present) {
      final converter = $BudgetsTable.$convertersharedOwnerMembern;
      map['shared_owner_member'] =
          Variable<int>(converter.toSql(sharedOwnerMember.value));
    }
    if (sharedDateUpdated.present) {
      map['shared_date_updated'] = Variable<DateTime>(sharedDateUpdated.value);
    }
    if (sharedMembers.present) {
      final converter = $BudgetsTable.$convertersharedMembersn;
      map['shared_members'] =
          Variable<String>(converter.toSql(sharedMembers.value));
    }
    if (sharedAllMembersEver.present) {
      final converter = $BudgetsTable.$convertersharedAllMembersEvern;
      map['shared_all_members_ever'] =
          Variable<String>(converter.toSql(sharedAllMembersEver.value));
    }
    if (isAbsoluteSpendingLimit.present) {
      map['is_absolute_spending_limit'] =
          Variable<bool>(isAbsoluteSpendingLimit.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetsCompanion(')
          ..write('budgetPk: $budgetPk, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('colour: $colour, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('walletFks: $walletFks, ')
          ..write('categoryFks: $categoryFks, ')
          ..write('categoryFksExclude: $categoryFksExclude, ')
          ..write('income: $income, ')
          ..write('addedTransactionsOnly: $addedTransactionsOnly, ')
          ..write('periodLength: $periodLength, ')
          ..write('reoccurrence: $reoccurrence, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateTimeModified: $dateTimeModified, ')
          ..write('pinned: $pinned, ')
          ..write('order: $order, ')
          ..write('walletFk: $walletFk, ')
          ..write('budgetTransactionFilters: $budgetTransactionFilters, ')
          ..write('memberTransactionFilters: $memberTransactionFilters, ')
          ..write('sharedKey: $sharedKey, ')
          ..write('sharedOwnerMember: $sharedOwnerMember, ')
          ..write('sharedDateUpdated: $sharedDateUpdated, ')
          ..write('sharedMembers: $sharedMembers, ')
          ..write('sharedAllMembersEver: $sharedAllMembersEver, ')
          ..write('isAbsoluteSpendingLimit: $isAbsoluteSpendingLimit, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoryBudgetLimitsTable extends CategoryBudgetLimits
    with TableInfo<$CategoryBudgetLimitsTable, CategoryBudgetLimit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoryBudgetLimitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _categoryLimitPkMeta =
      const VerificationMeta('categoryLimitPk');
  @override
  late final GeneratedColumn<String> categoryLimitPk = GeneratedColumn<String>(
      'category_limit_pk', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => uuid.v4());
  static const VerificationMeta _categoryFkMeta =
      const VerificationMeta('categoryFk');
  @override
  late final GeneratedColumn<String> categoryFk = GeneratedColumn<String>(
      'category_fk', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES categories (category_pk)'));
  static const VerificationMeta _budgetFkMeta =
      const VerificationMeta('budgetFk');
  @override
  late final GeneratedColumn<String> budgetFk = GeneratedColumn<String>(
      'budget_fk', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES budgets (budget_pk)'));
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _dateTimeModifiedMeta =
      const VerificationMeta('dateTimeModified');
  @override
  late final GeneratedColumn<DateTime> dateTimeModified =
      GeneratedColumn<DateTime>('date_time_modified', aliasedName, true,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: Constant(DateTime.now()));
  static const VerificationMeta _walletFkMeta =
      const VerificationMeta('walletFk');
  @override
  late final GeneratedColumn<String> walletFk = GeneratedColumn<String>(
      'wallet_fk', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES wallets (wallet_pk)'),
      defaultValue: const Constant("0"));
  @override
  List<GeneratedColumn> get $columns => [
        categoryLimitPk,
        categoryFk,
        budgetFk,
        amount,
        dateTimeModified,
        walletFk
      ];
  @override
  String get aliasedName => _alias ?? 'category_budget_limits';
  @override
  String get actualTableName => 'category_budget_limits';
  @override
  VerificationContext validateIntegrity(
      Insertable<CategoryBudgetLimit> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('category_limit_pk')) {
      context.handle(
          _categoryLimitPkMeta,
          categoryLimitPk.isAcceptableOrUnknown(
              data['category_limit_pk']!, _categoryLimitPkMeta));
    }
    if (data.containsKey('category_fk')) {
      context.handle(
          _categoryFkMeta,
          categoryFk.isAcceptableOrUnknown(
              data['category_fk']!, _categoryFkMeta));
    } else if (isInserting) {
      context.missing(_categoryFkMeta);
    }
    if (data.containsKey('budget_fk')) {
      context.handle(_budgetFkMeta,
          budgetFk.isAcceptableOrUnknown(data['budget_fk']!, _budgetFkMeta));
    } else if (isInserting) {
      context.missing(_budgetFkMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('date_time_modified')) {
      context.handle(
          _dateTimeModifiedMeta,
          dateTimeModified.isAcceptableOrUnknown(
              data['date_time_modified']!, _dateTimeModifiedMeta));
    }
    if (data.containsKey('wallet_fk')) {
      context.handle(_walletFkMeta,
          walletFk.isAcceptableOrUnknown(data['wallet_fk']!, _walletFkMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {categoryLimitPk};
  @override
  CategoryBudgetLimit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryBudgetLimit(
      categoryLimitPk: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}category_limit_pk'])!,
      categoryFk: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_fk'])!,
      budgetFk: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}budget_fk'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      dateTimeModified: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}date_time_modified']),
      walletFk: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}wallet_fk'])!,
    );
  }

  @override
  $CategoryBudgetLimitsTable createAlias(String alias) {
    return $CategoryBudgetLimitsTable(attachedDatabase, alias);
  }
}

class CategoryBudgetLimit extends DataClass
    implements Insertable<CategoryBudgetLimit> {
  final String categoryLimitPk;
  final String categoryFk;
  final String budgetFk;
  final double amount;
  final DateTime? dateTimeModified;
  final String walletFk;
  const CategoryBudgetLimit(
      {required this.categoryLimitPk,
      required this.categoryFk,
      required this.budgetFk,
      required this.amount,
      this.dateTimeModified,
      required this.walletFk});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['category_limit_pk'] = Variable<String>(categoryLimitPk);
    map['category_fk'] = Variable<String>(categoryFk);
    map['budget_fk'] = Variable<String>(budgetFk);
    map['amount'] = Variable<double>(amount);
    if (!nullToAbsent || dateTimeModified != null) {
      map['date_time_modified'] = Variable<DateTime>(dateTimeModified);
    }
    map['wallet_fk'] = Variable<String>(walletFk);
    return map;
  }

  CategoryBudgetLimitsCompanion toCompanion(bool nullToAbsent) {
    return CategoryBudgetLimitsCompanion(
      categoryLimitPk: Value(categoryLimitPk),
      categoryFk: Value(categoryFk),
      budgetFk: Value(budgetFk),
      amount: Value(amount),
      dateTimeModified: dateTimeModified == null && nullToAbsent
          ? const Value.absent()
          : Value(dateTimeModified),
      walletFk: Value(walletFk),
    );
  }

  factory CategoryBudgetLimit.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryBudgetLimit(
      categoryLimitPk: serializer.fromJson<String>(json['categoryLimitPk']),
      categoryFk: serializer.fromJson<String>(json['categoryFk']),
      budgetFk: serializer.fromJson<String>(json['budgetFk']),
      amount: serializer.fromJson<double>(json['amount']),
      dateTimeModified:
          serializer.fromJson<DateTime?>(json['dateTimeModified']),
      walletFk: serializer.fromJson<String>(json['walletFk']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'categoryLimitPk': serializer.toJson<String>(categoryLimitPk),
      'categoryFk': serializer.toJson<String>(categoryFk),
      'budgetFk': serializer.toJson<String>(budgetFk),
      'amount': serializer.toJson<double>(amount),
      'dateTimeModified': serializer.toJson<DateTime?>(dateTimeModified),
      'walletFk': serializer.toJson<String>(walletFk),
    };
  }

  CategoryBudgetLimit copyWith(
          {String? categoryLimitPk,
          String? categoryFk,
          String? budgetFk,
          double? amount,
          Value<DateTime?> dateTimeModified = const Value.absent(),
          String? walletFk}) =>
      CategoryBudgetLimit(
        categoryLimitPk: categoryLimitPk ?? this.categoryLimitPk,
        categoryFk: categoryFk ?? this.categoryFk,
        budgetFk: budgetFk ?? this.budgetFk,
        amount: amount ?? this.amount,
        dateTimeModified: dateTimeModified.present
            ? dateTimeModified.value
            : this.dateTimeModified,
        walletFk: walletFk ?? this.walletFk,
      );
  @override
  String toString() {
    return (StringBuffer('CategoryBudgetLimit(')
          ..write('categoryLimitPk: $categoryLimitPk, ')
          ..write('categoryFk: $categoryFk, ')
          ..write('budgetFk: $budgetFk, ')
          ..write('amount: $amount, ')
          ..write('dateTimeModified: $dateTimeModified, ')
          ..write('walletFk: $walletFk')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(categoryLimitPk, categoryFk, budgetFk, amount,
      dateTimeModified, walletFk);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryBudgetLimit &&
          other.categoryLimitPk == this.categoryLimitPk &&
          other.categoryFk == this.categoryFk &&
          other.budgetFk == this.budgetFk &&
          other.amount == this.amount &&
          other.dateTimeModified == this.dateTimeModified &&
          other.walletFk == this.walletFk);
}

class CategoryBudgetLimitsCompanion
    extends UpdateCompanion<CategoryBudgetLimit> {
  final Value<String> categoryLimitPk;
  final Value<String> categoryFk;
  final Value<String> budgetFk;
  final Value<double> amount;
  final Value<DateTime?> dateTimeModified;
  final Value<String> walletFk;
  final Value<int> rowid;
  const CategoryBudgetLimitsCompanion({
    this.categoryLimitPk = const Value.absent(),
    this.categoryFk = const Value.absent(),
    this.budgetFk = const Value.absent(),
    this.amount = const Value.absent(),
    this.dateTimeModified = const Value.absent(),
    this.walletFk = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoryBudgetLimitsCompanion.insert({
    this.categoryLimitPk = const Value.absent(),
    required String categoryFk,
    required String budgetFk,
    required double amount,
    this.dateTimeModified = const Value.absent(),
    this.walletFk = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : categoryFk = Value(categoryFk),
        budgetFk = Value(budgetFk),
        amount = Value(amount);
  static Insertable<CategoryBudgetLimit> custom({
    Expression<String>? categoryLimitPk,
    Expression<String>? categoryFk,
    Expression<String>? budgetFk,
    Expression<double>? amount,
    Expression<DateTime>? dateTimeModified,
    Expression<String>? walletFk,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (categoryLimitPk != null) 'category_limit_pk': categoryLimitPk,
      if (categoryFk != null) 'category_fk': categoryFk,
      if (budgetFk != null) 'budget_fk': budgetFk,
      if (amount != null) 'amount': amount,
      if (dateTimeModified != null) 'date_time_modified': dateTimeModified,
      if (walletFk != null) 'wallet_fk': walletFk,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoryBudgetLimitsCompanion copyWith(
      {Value<String>? categoryLimitPk,
      Value<String>? categoryFk,
      Value<String>? budgetFk,
      Value<double>? amount,
      Value<DateTime?>? dateTimeModified,
      Value<String>? walletFk,
      Value<int>? rowid}) {
    return CategoryBudgetLimitsCompanion(
      categoryLimitPk: categoryLimitPk ?? this.categoryLimitPk,
      categoryFk: categoryFk ?? this.categoryFk,
      budgetFk: budgetFk ?? this.budgetFk,
      amount: amount ?? this.amount,
      dateTimeModified: dateTimeModified ?? this.dateTimeModified,
      walletFk: walletFk ?? this.walletFk,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (categoryLimitPk.present) {
      map['category_limit_pk'] = Variable<String>(categoryLimitPk.value);
    }
    if (categoryFk.present) {
      map['category_fk'] = Variable<String>(categoryFk.value);
    }
    if (budgetFk.present) {
      map['budget_fk'] = Variable<String>(budgetFk.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (dateTimeModified.present) {
      map['date_time_modified'] = Variable<DateTime>(dateTimeModified.value);
    }
    if (walletFk.present) {
      map['wallet_fk'] = Variable<String>(walletFk.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoryBudgetLimitsCompanion(')
          ..write('categoryLimitPk: $categoryLimitPk, ')
          ..write('categoryFk: $categoryFk, ')
          ..write('budgetFk: $budgetFk, ')
          ..write('amount: $amount, ')
          ..write('dateTimeModified: $dateTimeModified, ')
          ..write('walletFk: $walletFk, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AssociatedTitlesTable extends AssociatedTitles
    with TableInfo<$AssociatedTitlesTable, TransactionAssociatedTitle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssociatedTitlesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _associatedTitlePkMeta =
      const VerificationMeta('associatedTitlePk');
  @override
  late final GeneratedColumn<String> associatedTitlePk =
      GeneratedColumn<String>('associated_title_pk', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          clientDefault: () => uuid.v4());
  static const VerificationMeta _categoryFkMeta =
      const VerificationMeta('categoryFk');
  @override
  late final GeneratedColumn<String> categoryFk = GeneratedColumn<String>(
      'category_fk', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES categories (category_pk)'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _dateCreatedMeta =
      const VerificationMeta('dateCreated');
  @override
  late final GeneratedColumn<DateTime> dateCreated = GeneratedColumn<DateTime>(
      'date_created', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => new DateTime.now());
  static const VerificationMeta _dateTimeModifiedMeta =
      const VerificationMeta('dateTimeModified');
  @override
  late final GeneratedColumn<DateTime> dateTimeModified =
      GeneratedColumn<DateTime>('date_time_modified', aliasedName, true,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: Constant(DateTime.now()));
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
      'order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isExactMatchMeta =
      const VerificationMeta('isExactMatch');
  @override
  late final GeneratedColumn<bool> isExactMatch = GeneratedColumn<bool>(
      'is_exact_match', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_exact_match" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        associatedTitlePk,
        categoryFk,
        title,
        dateCreated,
        dateTimeModified,
        order,
        isExactMatch
      ];
  @override
  String get aliasedName => _alias ?? 'associated_titles';
  @override
  String get actualTableName => 'associated_titles';
  @override
  VerificationContext validateIntegrity(
      Insertable<TransactionAssociatedTitle> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('associated_title_pk')) {
      context.handle(
          _associatedTitlePkMeta,
          associatedTitlePk.isAcceptableOrUnknown(
              data['associated_title_pk']!, _associatedTitlePkMeta));
    }
    if (data.containsKey('category_fk')) {
      context.handle(
          _categoryFkMeta,
          categoryFk.isAcceptableOrUnknown(
              data['category_fk']!, _categoryFkMeta));
    } else if (isInserting) {
      context.missing(_categoryFkMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('date_created')) {
      context.handle(
          _dateCreatedMeta,
          dateCreated.isAcceptableOrUnknown(
              data['date_created']!, _dateCreatedMeta));
    }
    if (data.containsKey('date_time_modified')) {
      context.handle(
          _dateTimeModifiedMeta,
          dateTimeModified.isAcceptableOrUnknown(
              data['date_time_modified']!, _dateTimeModifiedMeta));
    }
    if (data.containsKey('order')) {
      context.handle(
          _orderMeta, order.isAcceptableOrUnknown(data['order']!, _orderMeta));
    } else if (isInserting) {
      context.missing(_orderMeta);
    }
    if (data.containsKey('is_exact_match')) {
      context.handle(
          _isExactMatchMeta,
          isExactMatch.isAcceptableOrUnknown(
              data['is_exact_match']!, _isExactMatchMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {associatedTitlePk};
  @override
  TransactionAssociatedTitle map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionAssociatedTitle(
      associatedTitlePk: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}associated_title_pk'])!,
      categoryFk: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_fk'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      dateCreated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_created'])!,
      dateTimeModified: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}date_time_modified']),
      order: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order'])!,
      isExactMatch: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_exact_match'])!,
    );
  }

  @override
  $AssociatedTitlesTable createAlias(String alias) {
    return $AssociatedTitlesTable(attachedDatabase, alias);
  }
}

class TransactionAssociatedTitle extends DataClass
    implements Insertable<TransactionAssociatedTitle> {
  final String associatedTitlePk;
  final String categoryFk;
  final String title;
  final DateTime dateCreated;
  final DateTime? dateTimeModified;
  final int order;
  final bool isExactMatch;
  const TransactionAssociatedTitle(
      {required this.associatedTitlePk,
      required this.categoryFk,
      required this.title,
      required this.dateCreated,
      this.dateTimeModified,
      required this.order,
      required this.isExactMatch});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['associated_title_pk'] = Variable<String>(associatedTitlePk);
    map['category_fk'] = Variable<String>(categoryFk);
    map['title'] = Variable<String>(title);
    map['date_created'] = Variable<DateTime>(dateCreated);
    if (!nullToAbsent || dateTimeModified != null) {
      map['date_time_modified'] = Variable<DateTime>(dateTimeModified);
    }
    map['order'] = Variable<int>(order);
    map['is_exact_match'] = Variable<bool>(isExactMatch);
    return map;
  }

  AssociatedTitlesCompanion toCompanion(bool nullToAbsent) {
    return AssociatedTitlesCompanion(
      associatedTitlePk: Value(associatedTitlePk),
      categoryFk: Value(categoryFk),
      title: Value(title),
      dateCreated: Value(dateCreated),
      dateTimeModified: dateTimeModified == null && nullToAbsent
          ? const Value.absent()
          : Value(dateTimeModified),
      order: Value(order),
      isExactMatch: Value(isExactMatch),
    );
  }

  factory TransactionAssociatedTitle.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionAssociatedTitle(
      associatedTitlePk: serializer.fromJson<String>(json['associatedTitlePk']),
      categoryFk: serializer.fromJson<String>(json['categoryFk']),
      title: serializer.fromJson<String>(json['title']),
      dateCreated: serializer.fromJson<DateTime>(json['dateCreated']),
      dateTimeModified:
          serializer.fromJson<DateTime?>(json['dateTimeModified']),
      order: serializer.fromJson<int>(json['order']),
      isExactMatch: serializer.fromJson<bool>(json['isExactMatch']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'associatedTitlePk': serializer.toJson<String>(associatedTitlePk),
      'categoryFk': serializer.toJson<String>(categoryFk),
      'title': serializer.toJson<String>(title),
      'dateCreated': serializer.toJson<DateTime>(dateCreated),
      'dateTimeModified': serializer.toJson<DateTime?>(dateTimeModified),
      'order': serializer.toJson<int>(order),
      'isExactMatch': serializer.toJson<bool>(isExactMatch),
    };
  }

  TransactionAssociatedTitle copyWith(
          {String? associatedTitlePk,
          String? categoryFk,
          String? title,
          DateTime? dateCreated,
          Value<DateTime?> dateTimeModified = const Value.absent(),
          int? order,
          bool? isExactMatch}) =>
      TransactionAssociatedTitle(
        associatedTitlePk: associatedTitlePk ?? this.associatedTitlePk,
        categoryFk: categoryFk ?? this.categoryFk,
        title: title ?? this.title,
        dateCreated: dateCreated ?? this.dateCreated,
        dateTimeModified: dateTimeModified.present
            ? dateTimeModified.value
            : this.dateTimeModified,
        order: order ?? this.order,
        isExactMatch: isExactMatch ?? this.isExactMatch,
      );
  @override
  String toString() {
    return (StringBuffer('TransactionAssociatedTitle(')
          ..write('associatedTitlePk: $associatedTitlePk, ')
          ..write('categoryFk: $categoryFk, ')
          ..write('title: $title, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateTimeModified: $dateTimeModified, ')
          ..write('order: $order, ')
          ..write('isExactMatch: $isExactMatch')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(associatedTitlePk, categoryFk, title,
      dateCreated, dateTimeModified, order, isExactMatch);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionAssociatedTitle &&
          other.associatedTitlePk == this.associatedTitlePk &&
          other.categoryFk == this.categoryFk &&
          other.title == this.title &&
          other.dateCreated == this.dateCreated &&
          other.dateTimeModified == this.dateTimeModified &&
          other.order == this.order &&
          other.isExactMatch == this.isExactMatch);
}

class AssociatedTitlesCompanion
    extends UpdateCompanion<TransactionAssociatedTitle> {
  final Value<String> associatedTitlePk;
  final Value<String> categoryFk;
  final Value<String> title;
  final Value<DateTime> dateCreated;
  final Value<DateTime?> dateTimeModified;
  final Value<int> order;
  final Value<bool> isExactMatch;
  final Value<int> rowid;
  const AssociatedTitlesCompanion({
    this.associatedTitlePk = const Value.absent(),
    this.categoryFk = const Value.absent(),
    this.title = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.dateTimeModified = const Value.absent(),
    this.order = const Value.absent(),
    this.isExactMatch = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssociatedTitlesCompanion.insert({
    this.associatedTitlePk = const Value.absent(),
    required String categoryFk,
    required String title,
    this.dateCreated = const Value.absent(),
    this.dateTimeModified = const Value.absent(),
    required int order,
    this.isExactMatch = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : categoryFk = Value(categoryFk),
        title = Value(title),
        order = Value(order);
  static Insertable<TransactionAssociatedTitle> custom({
    Expression<String>? associatedTitlePk,
    Expression<String>? categoryFk,
    Expression<String>? title,
    Expression<DateTime>? dateCreated,
    Expression<DateTime>? dateTimeModified,
    Expression<int>? order,
    Expression<bool>? isExactMatch,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (associatedTitlePk != null) 'associated_title_pk': associatedTitlePk,
      if (categoryFk != null) 'category_fk': categoryFk,
      if (title != null) 'title': title,
      if (dateCreated != null) 'date_created': dateCreated,
      if (dateTimeModified != null) 'date_time_modified': dateTimeModified,
      if (order != null) 'order': order,
      if (isExactMatch != null) 'is_exact_match': isExactMatch,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssociatedTitlesCompanion copyWith(
      {Value<String>? associatedTitlePk,
      Value<String>? categoryFk,
      Value<String>? title,
      Value<DateTime>? dateCreated,
      Value<DateTime?>? dateTimeModified,
      Value<int>? order,
      Value<bool>? isExactMatch,
      Value<int>? rowid}) {
    return AssociatedTitlesCompanion(
      associatedTitlePk: associatedTitlePk ?? this.associatedTitlePk,
      categoryFk: categoryFk ?? this.categoryFk,
      title: title ?? this.title,
      dateCreated: dateCreated ?? this.dateCreated,
      dateTimeModified: dateTimeModified ?? this.dateTimeModified,
      order: order ?? this.order,
      isExactMatch: isExactMatch ?? this.isExactMatch,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (associatedTitlePk.present) {
      map['associated_title_pk'] = Variable<String>(associatedTitlePk.value);
    }
    if (categoryFk.present) {
      map['category_fk'] = Variable<String>(categoryFk.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (dateCreated.present) {
      map['date_created'] = Variable<DateTime>(dateCreated.value);
    }
    if (dateTimeModified.present) {
      map['date_time_modified'] = Variable<DateTime>(dateTimeModified.value);
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    if (isExactMatch.present) {
      map['is_exact_match'] = Variable<bool>(isExactMatch.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssociatedTitlesCompanion(')
          ..write('associatedTitlePk: $associatedTitlePk, ')
          ..write('categoryFk: $categoryFk, ')
          ..write('title: $title, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateTimeModified: $dateTimeModified, ')
          ..write('order: $order, ')
          ..write('isExactMatch: $isExactMatch, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _settingsPkMeta =
      const VerificationMeta('settingsPk');
  @override
  late final GeneratedColumn<int> settingsPk = GeneratedColumn<int>(
      'settings_pk', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _settingsJSONMeta =
      const VerificationMeta('settingsJSON');
  @override
  late final GeneratedColumn<String> settingsJSON = GeneratedColumn<String>(
      'settings_j_s_o_n', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateUpdatedMeta =
      const VerificationMeta('dateUpdated');
  @override
  late final GeneratedColumn<DateTime> dateUpdated = GeneratedColumn<DateTime>(
      'date_updated', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => new DateTime.now());
  @override
  List<GeneratedColumn> get $columns => [settingsPk, settingsJSON, dateUpdated];
  @override
  String get aliasedName => _alias ?? 'app_settings';
  @override
  String get actualTableName => 'app_settings';
  @override
  VerificationContext validateIntegrity(Insertable<AppSetting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('settings_pk')) {
      context.handle(
          _settingsPkMeta,
          settingsPk.isAcceptableOrUnknown(
              data['settings_pk']!, _settingsPkMeta));
    }
    if (data.containsKey('settings_j_s_o_n')) {
      context.handle(
          _settingsJSONMeta,
          settingsJSON.isAcceptableOrUnknown(
              data['settings_j_s_o_n']!, _settingsJSONMeta));
    } else if (isInserting) {
      context.missing(_settingsJSONMeta);
    }
    if (data.containsKey('date_updated')) {
      context.handle(
          _dateUpdatedMeta,
          dateUpdated.isAcceptableOrUnknown(
              data['date_updated']!, _dateUpdatedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {settingsPk};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      settingsPk: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}settings_pk'])!,
      settingsJSON: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}settings_j_s_o_n'])!,
      dateUpdated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_updated'])!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final int settingsPk;
  final String settingsJSON;
  final DateTime dateUpdated;
  const AppSetting(
      {required this.settingsPk,
      required this.settingsJSON,
      required this.dateUpdated});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['settings_pk'] = Variable<int>(settingsPk);
    map['settings_j_s_o_n'] = Variable<String>(settingsJSON);
    map['date_updated'] = Variable<DateTime>(dateUpdated);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      settingsPk: Value(settingsPk),
      settingsJSON: Value(settingsJSON),
      dateUpdated: Value(dateUpdated),
    );
  }

  factory AppSetting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      settingsPk: serializer.fromJson<int>(json['settingsPk']),
      settingsJSON: serializer.fromJson<String>(json['settingsJSON']),
      dateUpdated: serializer.fromJson<DateTime>(json['dateUpdated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'settingsPk': serializer.toJson<int>(settingsPk),
      'settingsJSON': serializer.toJson<String>(settingsJSON),
      'dateUpdated': serializer.toJson<DateTime>(dateUpdated),
    };
  }

  AppSetting copyWith(
          {int? settingsPk, String? settingsJSON, DateTime? dateUpdated}) =>
      AppSetting(
        settingsPk: settingsPk ?? this.settingsPk,
        settingsJSON: settingsJSON ?? this.settingsJSON,
        dateUpdated: dateUpdated ?? this.dateUpdated,
      );
  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('settingsPk: $settingsPk, ')
          ..write('settingsJSON: $settingsJSON, ')
          ..write('dateUpdated: $dateUpdated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(settingsPk, settingsJSON, dateUpdated);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.settingsPk == this.settingsPk &&
          other.settingsJSON == this.settingsJSON &&
          other.dateUpdated == this.dateUpdated);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<int> settingsPk;
  final Value<String> settingsJSON;
  final Value<DateTime> dateUpdated;
  const AppSettingsCompanion({
    this.settingsPk = const Value.absent(),
    this.settingsJSON = const Value.absent(),
    this.dateUpdated = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.settingsPk = const Value.absent(),
    required String settingsJSON,
    this.dateUpdated = const Value.absent(),
  }) : settingsJSON = Value(settingsJSON);
  static Insertable<AppSetting> custom({
    Expression<int>? settingsPk,
    Expression<String>? settingsJSON,
    Expression<DateTime>? dateUpdated,
  }) {
    return RawValuesInsertable({
      if (settingsPk != null) 'settings_pk': settingsPk,
      if (settingsJSON != null) 'settings_j_s_o_n': settingsJSON,
      if (dateUpdated != null) 'date_updated': dateUpdated,
    });
  }

  AppSettingsCompanion copyWith(
      {Value<int>? settingsPk,
      Value<String>? settingsJSON,
      Value<DateTime>? dateUpdated}) {
    return AppSettingsCompanion(
      settingsPk: settingsPk ?? this.settingsPk,
      settingsJSON: settingsJSON ?? this.settingsJSON,
      dateUpdated: dateUpdated ?? this.dateUpdated,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (settingsPk.present) {
      map['settings_pk'] = Variable<int>(settingsPk.value);
    }
    if (settingsJSON.present) {
      map['settings_j_s_o_n'] = Variable<String>(settingsJSON.value);
    }
    if (dateUpdated.present) {
      map['date_updated'] = Variable<DateTime>(dateUpdated.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('settingsPk: $settingsPk, ')
          ..write('settingsJSON: $settingsJSON, ')
          ..write('dateUpdated: $dateUpdated')
          ..write(')'))
        .toString();
  }
}

class $ScannerTemplatesTable extends ScannerTemplates
    with TableInfo<$ScannerTemplatesTable, ScannerTemplate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScannerTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _scannerTemplatePkMeta =
      const VerificationMeta('scannerTemplatePk');
  @override
  late final GeneratedColumn<String> scannerTemplatePk =
      GeneratedColumn<String>('scanner_template_pk', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          clientDefault: () => uuid.v4());
  static const VerificationMeta _dateCreatedMeta =
      const VerificationMeta('dateCreated');
  @override
  late final GeneratedColumn<DateTime> dateCreated = GeneratedColumn<DateTime>(
      'date_created', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => new DateTime.now());
  static const VerificationMeta _dateTimeModifiedMeta =
      const VerificationMeta('dateTimeModified');
  @override
  late final GeneratedColumn<DateTime> dateTimeModified =
      GeneratedColumn<DateTime>('date_time_modified', aliasedName, true,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: Constant(DateTime.now()));
  static const VerificationMeta _templateNameMeta =
      const VerificationMeta('templateName');
  @override
  late final GeneratedColumn<String> templateName = GeneratedColumn<String>(
      'template_name', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _containsMeta =
      const VerificationMeta('contains');
  @override
  late final GeneratedColumn<String> contains = GeneratedColumn<String>(
      'contains', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _titleTransactionBeforeMeta =
      const VerificationMeta('titleTransactionBefore');
  @override
  late final GeneratedColumn<String> titleTransactionBefore =
      GeneratedColumn<String>('title_transaction_before', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _titleTransactionAfterMeta =
      const VerificationMeta('titleTransactionAfter');
  @override
  late final GeneratedColumn<String> titleTransactionAfter =
      GeneratedColumn<String>('title_transaction_after', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _amountTransactionBeforeMeta =
      const VerificationMeta('amountTransactionBefore');
  @override
  late final GeneratedColumn<String> amountTransactionBefore =
      GeneratedColumn<String>('amount_transaction_before', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _amountTransactionAfterMeta =
      const VerificationMeta('amountTransactionAfter');
  @override
  late final GeneratedColumn<String> amountTransactionAfter =
      GeneratedColumn<String>('amount_transaction_after', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _defaultCategoryFkMeta =
      const VerificationMeta('defaultCategoryFk');
  @override
  late final GeneratedColumn<String> defaultCategoryFk =
      GeneratedColumn<String>('default_category_fk', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: true,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'REFERENCES categories (category_pk)'));
  static const VerificationMeta _walletFkMeta =
      const VerificationMeta('walletFk');
  @override
  late final GeneratedColumn<String> walletFk = GeneratedColumn<String>(
      'wallet_fk', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES wallets (wallet_pk)'),
      defaultValue: const Constant("0"));
  static const VerificationMeta _ignoreMeta = const VerificationMeta('ignore');
  @override
  late final GeneratedColumn<bool> ignore = GeneratedColumn<bool>(
      'ignore', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("ignore" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        scannerTemplatePk,
        dateCreated,
        dateTimeModified,
        templateName,
        contains,
        titleTransactionBefore,
        titleTransactionAfter,
        amountTransactionBefore,
        amountTransactionAfter,
        defaultCategoryFk,
        walletFk,
        ignore
      ];
  @override
  String get aliasedName => _alias ?? 'scanner_templates';
  @override
  String get actualTableName => 'scanner_templates';
  @override
  VerificationContext validateIntegrity(Insertable<ScannerTemplate> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('scanner_template_pk')) {
      context.handle(
          _scannerTemplatePkMeta,
          scannerTemplatePk.isAcceptableOrUnknown(
              data['scanner_template_pk']!, _scannerTemplatePkMeta));
    }
    if (data.containsKey('date_created')) {
      context.handle(
          _dateCreatedMeta,
          dateCreated.isAcceptableOrUnknown(
              data['date_created']!, _dateCreatedMeta));
    }
    if (data.containsKey('date_time_modified')) {
      context.handle(
          _dateTimeModifiedMeta,
          dateTimeModified.isAcceptableOrUnknown(
              data['date_time_modified']!, _dateTimeModifiedMeta));
    }
    if (data.containsKey('template_name')) {
      context.handle(
          _templateNameMeta,
          templateName.isAcceptableOrUnknown(
              data['template_name']!, _templateNameMeta));
    } else if (isInserting) {
      context.missing(_templateNameMeta);
    }
    if (data.containsKey('contains')) {
      context.handle(_containsMeta,
          contains.isAcceptableOrUnknown(data['contains']!, _containsMeta));
    } else if (isInserting) {
      context.missing(_containsMeta);
    }
    if (data.containsKey('title_transaction_before')) {
      context.handle(
          _titleTransactionBeforeMeta,
          titleTransactionBefore.isAcceptableOrUnknown(
              data['title_transaction_before']!, _titleTransactionBeforeMeta));
    } else if (isInserting) {
      context.missing(_titleTransactionBeforeMeta);
    }
    if (data.containsKey('title_transaction_after')) {
      context.handle(
          _titleTransactionAfterMeta,
          titleTransactionAfter.isAcceptableOrUnknown(
              data['title_transaction_after']!, _titleTransactionAfterMeta));
    } else if (isInserting) {
      context.missing(_titleTransactionAfterMeta);
    }
    if (data.containsKey('amount_transaction_before')) {
      context.handle(
          _amountTransactionBeforeMeta,
          amountTransactionBefore.isAcceptableOrUnknown(
              data['amount_transaction_before']!,
              _amountTransactionBeforeMeta));
    } else if (isInserting) {
      context.missing(_amountTransactionBeforeMeta);
    }
    if (data.containsKey('amount_transaction_after')) {
      context.handle(
          _amountTransactionAfterMeta,
          amountTransactionAfter.isAcceptableOrUnknown(
              data['amount_transaction_after']!, _amountTransactionAfterMeta));
    } else if (isInserting) {
      context.missing(_amountTransactionAfterMeta);
    }
    if (data.containsKey('default_category_fk')) {
      context.handle(
          _defaultCategoryFkMeta,
          defaultCategoryFk.isAcceptableOrUnknown(
              data['default_category_fk']!, _defaultCategoryFkMeta));
    } else if (isInserting) {
      context.missing(_defaultCategoryFkMeta);
    }
    if (data.containsKey('wallet_fk')) {
      context.handle(_walletFkMeta,
          walletFk.isAcceptableOrUnknown(data['wallet_fk']!, _walletFkMeta));
    }
    if (data.containsKey('ignore')) {
      context.handle(_ignoreMeta,
          ignore.isAcceptableOrUnknown(data['ignore']!, _ignoreMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {scannerTemplatePk};
  @override
  ScannerTemplate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScannerTemplate(
      scannerTemplatePk: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}scanner_template_pk'])!,
      dateCreated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_created'])!,
      dateTimeModified: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}date_time_modified']),
      templateName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}template_name'])!,
      contains: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}contains'])!,
      titleTransactionBefore: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}title_transaction_before'])!,
      titleTransactionAfter: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}title_transaction_after'])!,
      amountTransactionBefore: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}amount_transaction_before'])!,
      amountTransactionAfter: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}amount_transaction_after'])!,
      defaultCategoryFk: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}default_category_fk'])!,
      walletFk: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}wallet_fk'])!,
      ignore: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}ignore'])!,
    );
  }

  @override
  $ScannerTemplatesTable createAlias(String alias) {
    return $ScannerTemplatesTable(attachedDatabase, alias);
  }
}

class ScannerTemplate extends DataClass implements Insertable<ScannerTemplate> {
  final String scannerTemplatePk;
  final DateTime dateCreated;
  final DateTime? dateTimeModified;
  final String templateName;
  final String contains;
  final String titleTransactionBefore;
  final String titleTransactionAfter;
  final String amountTransactionBefore;
  final String amountTransactionAfter;
  final String defaultCategoryFk;
  final String walletFk;
  final bool ignore;
  const ScannerTemplate(
      {required this.scannerTemplatePk,
      required this.dateCreated,
      this.dateTimeModified,
      required this.templateName,
      required this.contains,
      required this.titleTransactionBefore,
      required this.titleTransactionAfter,
      required this.amountTransactionBefore,
      required this.amountTransactionAfter,
      required this.defaultCategoryFk,
      required this.walletFk,
      required this.ignore});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['scanner_template_pk'] = Variable<String>(scannerTemplatePk);
    map['date_created'] = Variable<DateTime>(dateCreated);
    if (!nullToAbsent || dateTimeModified != null) {
      map['date_time_modified'] = Variable<DateTime>(dateTimeModified);
    }
    map['template_name'] = Variable<String>(templateName);
    map['contains'] = Variable<String>(contains);
    map['title_transaction_before'] = Variable<String>(titleTransactionBefore);
    map['title_transaction_after'] = Variable<String>(titleTransactionAfter);
    map['amount_transaction_before'] =
        Variable<String>(amountTransactionBefore);
    map['amount_transaction_after'] = Variable<String>(amountTransactionAfter);
    map['default_category_fk'] = Variable<String>(defaultCategoryFk);
    map['wallet_fk'] = Variable<String>(walletFk);
    map['ignore'] = Variable<bool>(ignore);
    return map;
  }

  ScannerTemplatesCompanion toCompanion(bool nullToAbsent) {
    return ScannerTemplatesCompanion(
      scannerTemplatePk: Value(scannerTemplatePk),
      dateCreated: Value(dateCreated),
      dateTimeModified: dateTimeModified == null && nullToAbsent
          ? const Value.absent()
          : Value(dateTimeModified),
      templateName: Value(templateName),
      contains: Value(contains),
      titleTransactionBefore: Value(titleTransactionBefore),
      titleTransactionAfter: Value(titleTransactionAfter),
      amountTransactionBefore: Value(amountTransactionBefore),
      amountTransactionAfter: Value(amountTransactionAfter),
      defaultCategoryFk: Value(defaultCategoryFk),
      walletFk: Value(walletFk),
      ignore: Value(ignore),
    );
  }

  factory ScannerTemplate.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScannerTemplate(
      scannerTemplatePk: serializer.fromJson<String>(json['scannerTemplatePk']),
      dateCreated: serializer.fromJson<DateTime>(json['dateCreated']),
      dateTimeModified:
          serializer.fromJson<DateTime?>(json['dateTimeModified']),
      templateName: serializer.fromJson<String>(json['templateName']),
      contains: serializer.fromJson<String>(json['contains']),
      titleTransactionBefore:
          serializer.fromJson<String>(json['titleTransactionBefore']),
      titleTransactionAfter:
          serializer.fromJson<String>(json['titleTransactionAfter']),
      amountTransactionBefore:
          serializer.fromJson<String>(json['amountTransactionBefore']),
      amountTransactionAfter:
          serializer.fromJson<String>(json['amountTransactionAfter']),
      defaultCategoryFk: serializer.fromJson<String>(json['defaultCategoryFk']),
      walletFk: serializer.fromJson<String>(json['walletFk']),
      ignore: serializer.fromJson<bool>(json['ignore']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'scannerTemplatePk': serializer.toJson<String>(scannerTemplatePk),
      'dateCreated': serializer.toJson<DateTime>(dateCreated),
      'dateTimeModified': serializer.toJson<DateTime?>(dateTimeModified),
      'templateName': serializer.toJson<String>(templateName),
      'contains': serializer.toJson<String>(contains),
      'titleTransactionBefore':
          serializer.toJson<String>(titleTransactionBefore),
      'titleTransactionAfter': serializer.toJson<String>(titleTransactionAfter),
      'amountTransactionBefore':
          serializer.toJson<String>(amountTransactionBefore),
      'amountTransactionAfter':
          serializer.toJson<String>(amountTransactionAfter),
      'defaultCategoryFk': serializer.toJson<String>(defaultCategoryFk),
      'walletFk': serializer.toJson<String>(walletFk),
      'ignore': serializer.toJson<bool>(ignore),
    };
  }

  ScannerTemplate copyWith(
          {String? scannerTemplatePk,
          DateTime? dateCreated,
          Value<DateTime?> dateTimeModified = const Value.absent(),
          String? templateName,
          String? contains,
          String? titleTransactionBefore,
          String? titleTransactionAfter,
          String? amountTransactionBefore,
          String? amountTransactionAfter,
          String? defaultCategoryFk,
          String? walletFk,
          bool? ignore}) =>
      ScannerTemplate(
        scannerTemplatePk: scannerTemplatePk ?? this.scannerTemplatePk,
        dateCreated: dateCreated ?? this.dateCreated,
        dateTimeModified: dateTimeModified.present
            ? dateTimeModified.value
            : this.dateTimeModified,
        templateName: templateName ?? this.templateName,
        contains: contains ?? this.contains,
        titleTransactionBefore:
            titleTransactionBefore ?? this.titleTransactionBefore,
        titleTransactionAfter:
            titleTransactionAfter ?? this.titleTransactionAfter,
        amountTransactionBefore:
            amountTransactionBefore ?? this.amountTransactionBefore,
        amountTransactionAfter:
            amountTransactionAfter ?? this.amountTransactionAfter,
        defaultCategoryFk: defaultCategoryFk ?? this.defaultCategoryFk,
        walletFk: walletFk ?? this.walletFk,
        ignore: ignore ?? this.ignore,
      );
  @override
  String toString() {
    return (StringBuffer('ScannerTemplate(')
          ..write('scannerTemplatePk: $scannerTemplatePk, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateTimeModified: $dateTimeModified, ')
          ..write('templateName: $templateName, ')
          ..write('contains: $contains, ')
          ..write('titleTransactionBefore: $titleTransactionBefore, ')
          ..write('titleTransactionAfter: $titleTransactionAfter, ')
          ..write('amountTransactionBefore: $amountTransactionBefore, ')
          ..write('amountTransactionAfter: $amountTransactionAfter, ')
          ..write('defaultCategoryFk: $defaultCategoryFk, ')
          ..write('walletFk: $walletFk, ')
          ..write('ignore: $ignore')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      scannerTemplatePk,
      dateCreated,
      dateTimeModified,
      templateName,
      contains,
      titleTransactionBefore,
      titleTransactionAfter,
      amountTransactionBefore,
      amountTransactionAfter,
      defaultCategoryFk,
      walletFk,
      ignore);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScannerTemplate &&
          other.scannerTemplatePk == this.scannerTemplatePk &&
          other.dateCreated == this.dateCreated &&
          other.dateTimeModified == this.dateTimeModified &&
          other.templateName == this.templateName &&
          other.contains == this.contains &&
          other.titleTransactionBefore == this.titleTransactionBefore &&
          other.titleTransactionAfter == this.titleTransactionAfter &&
          other.amountTransactionBefore == this.amountTransactionBefore &&
          other.amountTransactionAfter == this.amountTransactionAfter &&
          other.defaultCategoryFk == this.defaultCategoryFk &&
          other.walletFk == this.walletFk &&
          other.ignore == this.ignore);
}

class ScannerTemplatesCompanion extends UpdateCompanion<ScannerTemplate> {
  final Value<String> scannerTemplatePk;
  final Value<DateTime> dateCreated;
  final Value<DateTime?> dateTimeModified;
  final Value<String> templateName;
  final Value<String> contains;
  final Value<String> titleTransactionBefore;
  final Value<String> titleTransactionAfter;
  final Value<String> amountTransactionBefore;
  final Value<String> amountTransactionAfter;
  final Value<String> defaultCategoryFk;
  final Value<String> walletFk;
  final Value<bool> ignore;
  final Value<int> rowid;
  const ScannerTemplatesCompanion({
    this.scannerTemplatePk = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.dateTimeModified = const Value.absent(),
    this.templateName = const Value.absent(),
    this.contains = const Value.absent(),
    this.titleTransactionBefore = const Value.absent(),
    this.titleTransactionAfter = const Value.absent(),
    this.amountTransactionBefore = const Value.absent(),
    this.amountTransactionAfter = const Value.absent(),
    this.defaultCategoryFk = const Value.absent(),
    this.walletFk = const Value.absent(),
    this.ignore = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScannerTemplatesCompanion.insert({
    this.scannerTemplatePk = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.dateTimeModified = const Value.absent(),
    required String templateName,
    required String contains,
    required String titleTransactionBefore,
    required String titleTransactionAfter,
    required String amountTransactionBefore,
    required String amountTransactionAfter,
    required String defaultCategoryFk,
    this.walletFk = const Value.absent(),
    this.ignore = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : templateName = Value(templateName),
        contains = Value(contains),
        titleTransactionBefore = Value(titleTransactionBefore),
        titleTransactionAfter = Value(titleTransactionAfter),
        amountTransactionBefore = Value(amountTransactionBefore),
        amountTransactionAfter = Value(amountTransactionAfter),
        defaultCategoryFk = Value(defaultCategoryFk);
  static Insertable<ScannerTemplate> custom({
    Expression<String>? scannerTemplatePk,
    Expression<DateTime>? dateCreated,
    Expression<DateTime>? dateTimeModified,
    Expression<String>? templateName,
    Expression<String>? contains,
    Expression<String>? titleTransactionBefore,
    Expression<String>? titleTransactionAfter,
    Expression<String>? amountTransactionBefore,
    Expression<String>? amountTransactionAfter,
    Expression<String>? defaultCategoryFk,
    Expression<String>? walletFk,
    Expression<bool>? ignore,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (scannerTemplatePk != null) 'scanner_template_pk': scannerTemplatePk,
      if (dateCreated != null) 'date_created': dateCreated,
      if (dateTimeModified != null) 'date_time_modified': dateTimeModified,
      if (templateName != null) 'template_name': templateName,
      if (contains != null) 'contains': contains,
      if (titleTransactionBefore != null)
        'title_transaction_before': titleTransactionBefore,
      if (titleTransactionAfter != null)
        'title_transaction_after': titleTransactionAfter,
      if (amountTransactionBefore != null)
        'amount_transaction_before': amountTransactionBefore,
      if (amountTransactionAfter != null)
        'amount_transaction_after': amountTransactionAfter,
      if (defaultCategoryFk != null) 'default_category_fk': defaultCategoryFk,
      if (walletFk != null) 'wallet_fk': walletFk,
      if (ignore != null) 'ignore': ignore,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScannerTemplatesCompanion copyWith(
      {Value<String>? scannerTemplatePk,
      Value<DateTime>? dateCreated,
      Value<DateTime?>? dateTimeModified,
      Value<String>? templateName,
      Value<String>? contains,
      Value<String>? titleTransactionBefore,
      Value<String>? titleTransactionAfter,
      Value<String>? amountTransactionBefore,
      Value<String>? amountTransactionAfter,
      Value<String>? defaultCategoryFk,
      Value<String>? walletFk,
      Value<bool>? ignore,
      Value<int>? rowid}) {
    return ScannerTemplatesCompanion(
      scannerTemplatePk: scannerTemplatePk ?? this.scannerTemplatePk,
      dateCreated: dateCreated ?? this.dateCreated,
      dateTimeModified: dateTimeModified ?? this.dateTimeModified,
      templateName: templateName ?? this.templateName,
      contains: contains ?? this.contains,
      titleTransactionBefore:
          titleTransactionBefore ?? this.titleTransactionBefore,
      titleTransactionAfter:
          titleTransactionAfter ?? this.titleTransactionAfter,
      amountTransactionBefore:
          amountTransactionBefore ?? this.amountTransactionBefore,
      amountTransactionAfter:
          amountTransactionAfter ?? this.amountTransactionAfter,
      defaultCategoryFk: defaultCategoryFk ?? this.defaultCategoryFk,
      walletFk: walletFk ?? this.walletFk,
      ignore: ignore ?? this.ignore,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (scannerTemplatePk.present) {
      map['scanner_template_pk'] = Variable<String>(scannerTemplatePk.value);
    }
    if (dateCreated.present) {
      map['date_created'] = Variable<DateTime>(dateCreated.value);
    }
    if (dateTimeModified.present) {
      map['date_time_modified'] = Variable<DateTime>(dateTimeModified.value);
    }
    if (templateName.present) {
      map['template_name'] = Variable<String>(templateName.value);
    }
    if (contains.present) {
      map['contains'] = Variable<String>(contains.value);
    }
    if (titleTransactionBefore.present) {
      map['title_transaction_before'] =
          Variable<String>(titleTransactionBefore.value);
    }
    if (titleTransactionAfter.present) {
      map['title_transaction_after'] =
          Variable<String>(titleTransactionAfter.value);
    }
    if (amountTransactionBefore.present) {
      map['amount_transaction_before'] =
          Variable<String>(amountTransactionBefore.value);
    }
    if (amountTransactionAfter.present) {
      map['amount_transaction_after'] =
          Variable<String>(amountTransactionAfter.value);
    }
    if (defaultCategoryFk.present) {
      map['default_category_fk'] = Variable<String>(defaultCategoryFk.value);
    }
    if (walletFk.present) {
      map['wallet_fk'] = Variable<String>(walletFk.value);
    }
    if (ignore.present) {
      map['ignore'] = Variable<bool>(ignore.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScannerTemplatesCompanion(')
          ..write('scannerTemplatePk: $scannerTemplatePk, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateTimeModified: $dateTimeModified, ')
          ..write('templateName: $templateName, ')
          ..write('contains: $contains, ')
          ..write('titleTransactionBefore: $titleTransactionBefore, ')
          ..write('titleTransactionAfter: $titleTransactionAfter, ')
          ..write('amountTransactionBefore: $amountTransactionBefore, ')
          ..write('amountTransactionAfter: $amountTransactionAfter, ')
          ..write('defaultCategoryFk: $defaultCategoryFk, ')
          ..write('walletFk: $walletFk, ')
          ..write('ignore: $ignore, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DeleteLogsTable extends DeleteLogs
    with TableInfo<$DeleteLogsTable, DeleteLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeleteLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _deleteLogPkMeta =
      const VerificationMeta('deleteLogPk');
  @override
  late final GeneratedColumn<String> deleteLogPk = GeneratedColumn<String>(
      'delete_log_pk', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => uuid.v4());
  static const VerificationMeta _entryPkMeta =
      const VerificationMeta('entryPk');
  @override
  late final GeneratedColumn<String> entryPk = GeneratedColumn<String>(
      'entry_pk', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumnWithTypeConverter<DeleteLogType, int> type =
      GeneratedColumn<int>('type', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<DeleteLogType>($DeleteLogsTable.$convertertype);
  static const VerificationMeta _dateTimeModifiedMeta =
      const VerificationMeta('dateTimeModified');
  @override
  late final GeneratedColumn<DateTime> dateTimeModified =
      GeneratedColumn<DateTime>('date_time_modified', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: Constant(DateTime.now()));
  @override
  List<GeneratedColumn> get $columns =>
      [deleteLogPk, entryPk, type, dateTimeModified];
  @override
  String get aliasedName => _alias ?? 'delete_logs';
  @override
  String get actualTableName => 'delete_logs';
  @override
  VerificationContext validateIntegrity(Insertable<DeleteLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('delete_log_pk')) {
      context.handle(
          _deleteLogPkMeta,
          deleteLogPk.isAcceptableOrUnknown(
              data['delete_log_pk']!, _deleteLogPkMeta));
    }
    if (data.containsKey('entry_pk')) {
      context.handle(_entryPkMeta,
          entryPk.isAcceptableOrUnknown(data['entry_pk']!, _entryPkMeta));
    } else if (isInserting) {
      context.missing(_entryPkMeta);
    }
    context.handle(_typeMeta, const VerificationResult.success());
    if (data.containsKey('date_time_modified')) {
      context.handle(
          _dateTimeModifiedMeta,
          dateTimeModified.isAcceptableOrUnknown(
              data['date_time_modified']!, _dateTimeModifiedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {deleteLogPk};
  @override
  DeleteLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeleteLog(
      deleteLogPk: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}delete_log_pk'])!,
      entryPk: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entry_pk'])!,
      type: $DeleteLogsTable.$convertertype.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type'])!),
      dateTimeModified: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}date_time_modified'])!,
    );
  }

  @override
  $DeleteLogsTable createAlias(String alias) {
    return $DeleteLogsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<DeleteLogType, int, int> $convertertype =
      const EnumIndexConverter<DeleteLogType>(DeleteLogType.values);
}

class DeleteLog extends DataClass implements Insertable<DeleteLog> {
  final String deleteLogPk;
  final String entryPk;
  final DeleteLogType type;
  final DateTime dateTimeModified;
  const DeleteLog(
      {required this.deleteLogPk,
      required this.entryPk,
      required this.type,
      required this.dateTimeModified});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['delete_log_pk'] = Variable<String>(deleteLogPk);
    map['entry_pk'] = Variable<String>(entryPk);
    {
      final converter = $DeleteLogsTable.$convertertype;
      map['type'] = Variable<int>(converter.toSql(type));
    }
    map['date_time_modified'] = Variable<DateTime>(dateTimeModified);
    return map;
  }

  DeleteLogsCompanion toCompanion(bool nullToAbsent) {
    return DeleteLogsCompanion(
      deleteLogPk: Value(deleteLogPk),
      entryPk: Value(entryPk),
      type: Value(type),
      dateTimeModified: Value(dateTimeModified),
    );
  }

  factory DeleteLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeleteLog(
      deleteLogPk: serializer.fromJson<String>(json['deleteLogPk']),
      entryPk: serializer.fromJson<String>(json['entryPk']),
      type: $DeleteLogsTable.$convertertype
          .fromJson(serializer.fromJson<int>(json['type'])),
      dateTimeModified: serializer.fromJson<DateTime>(json['dateTimeModified']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'deleteLogPk': serializer.toJson<String>(deleteLogPk),
      'entryPk': serializer.toJson<String>(entryPk),
      'type':
          serializer.toJson<int>($DeleteLogsTable.$convertertype.toJson(type)),
      'dateTimeModified': serializer.toJson<DateTime>(dateTimeModified),
    };
  }

  DeleteLog copyWith(
          {String? deleteLogPk,
          String? entryPk,
          DeleteLogType? type,
          DateTime? dateTimeModified}) =>
      DeleteLog(
        deleteLogPk: deleteLogPk ?? this.deleteLogPk,
        entryPk: entryPk ?? this.entryPk,
        type: type ?? this.type,
        dateTimeModified: dateTimeModified ?? this.dateTimeModified,
      );
  @override
  String toString() {
    return (StringBuffer('DeleteLog(')
          ..write('deleteLogPk: $deleteLogPk, ')
          ..write('entryPk: $entryPk, ')
          ..write('type: $type, ')
          ..write('dateTimeModified: $dateTimeModified')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(deleteLogPk, entryPk, type, dateTimeModified);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeleteLog &&
          other.deleteLogPk == this.deleteLogPk &&
          other.entryPk == this.entryPk &&
          other.type == this.type &&
          other.dateTimeModified == this.dateTimeModified);
}

class DeleteLogsCompanion extends UpdateCompanion<DeleteLog> {
  final Value<String> deleteLogPk;
  final Value<String> entryPk;
  final Value<DeleteLogType> type;
  final Value<DateTime> dateTimeModified;
  final Value<int> rowid;
  const DeleteLogsCompanion({
    this.deleteLogPk = const Value.absent(),
    this.entryPk = const Value.absent(),
    this.type = const Value.absent(),
    this.dateTimeModified = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DeleteLogsCompanion.insert({
    this.deleteLogPk = const Value.absent(),
    required String entryPk,
    required DeleteLogType type,
    this.dateTimeModified = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : entryPk = Value(entryPk),
        type = Value(type);
  static Insertable<DeleteLog> custom({
    Expression<String>? deleteLogPk,
    Expression<String>? entryPk,
    Expression<int>? type,
    Expression<DateTime>? dateTimeModified,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (deleteLogPk != null) 'delete_log_pk': deleteLogPk,
      if (entryPk != null) 'entry_pk': entryPk,
      if (type != null) 'type': type,
      if (dateTimeModified != null) 'date_time_modified': dateTimeModified,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DeleteLogsCompanion copyWith(
      {Value<String>? deleteLogPk,
      Value<String>? entryPk,
      Value<DeleteLogType>? type,
      Value<DateTime>? dateTimeModified,
      Value<int>? rowid}) {
    return DeleteLogsCompanion(
      deleteLogPk: deleteLogPk ?? this.deleteLogPk,
      entryPk: entryPk ?? this.entryPk,
      type: type ?? this.type,
      dateTimeModified: dateTimeModified ?? this.dateTimeModified,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (deleteLogPk.present) {
      map['delete_log_pk'] = Variable<String>(deleteLogPk.value);
    }
    if (entryPk.present) {
      map['entry_pk'] = Variable<String>(entryPk.value);
    }
    if (type.present) {
      final converter = $DeleteLogsTable.$convertertype;
      map['type'] = Variable<int>(converter.toSql(type.value));
    }
    if (dateTimeModified.present) {
      map['date_time_modified'] = Variable<DateTime>(dateTimeModified.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeleteLogsCompanion(')
          ..write('deleteLogPk: $deleteLogPk, ')
          ..write('entryPk: $entryPk, ')
          ..write('type: $type, ')
          ..write('dateTimeModified: $dateTimeModified, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$FinanceDatabase extends GeneratedDatabase {
  _$FinanceDatabase(QueryExecutor e) : super(e);
  late final $WalletsTable wallets = $WalletsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $ObjectivesTable objectives = $ObjectivesTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $BudgetsTable budgets = $BudgetsTable(this);
  late final $CategoryBudgetLimitsTable categoryBudgetLimits =
      $CategoryBudgetLimitsTable(this);
  late final $AssociatedTitlesTable associatedTitles =
      $AssociatedTitlesTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $ScannerTemplatesTable scannerTemplates =
      $ScannerTemplatesTable(this);
  late final $DeleteLogsTable deleteLogs = $DeleteLogsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        wallets,
        categories,
        objectives,
        transactions,
        budgets,
        categoryBudgetLimits,
        associatedTitles,
        appSettings,
        scannerTemplates,
        deleteLogs
      ];
}
