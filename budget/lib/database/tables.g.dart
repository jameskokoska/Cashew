// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tables.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class TransactionWallet extends DataClass
    implements Insertable<TransactionWallet> {
  final int walletPk;
  final String name;
  final String? colour;
  final String? iconName;
  final DateTime dateCreated;
  final int order;
  TransactionWallet(
      {required this.walletPk,
      required this.name,
      this.colour,
      this.iconName,
      required this.dateCreated,
      required this.order});
  factory TransactionWallet.fromData(Map<String, dynamic> data,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return TransactionWallet(
      walletPk: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}wallet_pk'])!,
      name: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}name'])!,
      colour: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}colour']),
      iconName: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}icon_name']),
      dateCreated: const DateTimeType()
          .mapFromDatabaseResponse(data['${effectivePrefix}date_created'])!,
      order: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}order'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['wallet_pk'] = Variable<int>(walletPk);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || colour != null) {
      map['colour'] = Variable<String?>(colour);
    }
    if (!nullToAbsent || iconName != null) {
      map['icon_name'] = Variable<String?>(iconName);
    }
    map['date_created'] = Variable<DateTime>(dateCreated);
    map['order'] = Variable<int>(order);
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
      order: Value(order),
    );
  }

  factory TransactionWallet.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionWallet(
      walletPk: serializer.fromJson<int>(json['walletPk']),
      name: serializer.fromJson<String>(json['name']),
      colour: serializer.fromJson<String?>(json['colour']),
      iconName: serializer.fromJson<String?>(json['iconName']),
      dateCreated: serializer.fromJson<DateTime>(json['dateCreated']),
      order: serializer.fromJson<int>(json['order']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'walletPk': serializer.toJson<int>(walletPk),
      'name': serializer.toJson<String>(name),
      'colour': serializer.toJson<String?>(colour),
      'iconName': serializer.toJson<String?>(iconName),
      'dateCreated': serializer.toJson<DateTime>(dateCreated),
      'order': serializer.toJson<int>(order),
    };
  }

  TransactionWallet copyWith(
          {int? walletPk,
          String? name,
          String? colour,
          String? iconName,
          DateTime? dateCreated,
          int? order}) =>
      TransactionWallet(
        walletPk: walletPk ?? this.walletPk,
        name: name ?? this.name,
        colour: colour ?? this.colour,
        iconName: iconName ?? this.iconName,
        dateCreated: dateCreated ?? this.dateCreated,
        order: order ?? this.order,
      );
  @override
  String toString() {
    return (StringBuffer('TransactionWallet(')
          ..write('walletPk: $walletPk, ')
          ..write('name: $name, ')
          ..write('colour: $colour, ')
          ..write('iconName: $iconName, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('order: $order')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(walletPk, name, colour, iconName, dateCreated, order);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionWallet &&
          other.walletPk == this.walletPk &&
          other.name == this.name &&
          other.colour == this.colour &&
          other.iconName == this.iconName &&
          other.dateCreated == this.dateCreated &&
          other.order == this.order);
}

class WalletsCompanion extends UpdateCompanion<TransactionWallet> {
  final Value<int> walletPk;
  final Value<String> name;
  final Value<String?> colour;
  final Value<String?> iconName;
  final Value<DateTime> dateCreated;
  final Value<int> order;
  const WalletsCompanion({
    this.walletPk = const Value.absent(),
    this.name = const Value.absent(),
    this.colour = const Value.absent(),
    this.iconName = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.order = const Value.absent(),
  });
  WalletsCompanion.insert({
    this.walletPk = const Value.absent(),
    required String name,
    this.colour = const Value.absent(),
    this.iconName = const Value.absent(),
    this.dateCreated = const Value.absent(),
    required int order,
  })  : name = Value(name),
        order = Value(order);
  static Insertable<TransactionWallet> custom({
    Expression<int>? walletPk,
    Expression<String>? name,
    Expression<String?>? colour,
    Expression<String?>? iconName,
    Expression<DateTime>? dateCreated,
    Expression<int>? order,
  }) {
    return RawValuesInsertable({
      if (walletPk != null) 'wallet_pk': walletPk,
      if (name != null) 'name': name,
      if (colour != null) 'colour': colour,
      if (iconName != null) 'icon_name': iconName,
      if (dateCreated != null) 'date_created': dateCreated,
      if (order != null) 'order': order,
    });
  }

  WalletsCompanion copyWith(
      {Value<int>? walletPk,
      Value<String>? name,
      Value<String?>? colour,
      Value<String?>? iconName,
      Value<DateTime>? dateCreated,
      Value<int>? order}) {
    return WalletsCompanion(
      walletPk: walletPk ?? this.walletPk,
      name: name ?? this.name,
      colour: colour ?? this.colour,
      iconName: iconName ?? this.iconName,
      dateCreated: dateCreated ?? this.dateCreated,
      order: order ?? this.order,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (walletPk.present) {
      map['wallet_pk'] = Variable<int>(walletPk.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (colour.present) {
      map['colour'] = Variable<String?>(colour.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String?>(iconName.value);
    }
    if (dateCreated.present) {
      map['date_created'] = Variable<DateTime>(dateCreated.value);
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
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
          ..write('order: $order')
          ..write(')'))
        .toString();
  }
}

class $WalletsTable extends Wallets
    with TableInfo<$WalletsTable, TransactionWallet> {
  final GeneratedDatabase _db;
  final String? _alias;
  $WalletsTable(this._db, [this._alias]);
  final VerificationMeta _walletPkMeta = const VerificationMeta('walletPk');
  @override
  late final GeneratedColumn<int?> walletPk = GeneratedColumn<int?>(
      'wallet_pk', aliasedName, false,
      type: const IntType(),
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT');
  final VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String?> name = GeneratedColumn<String?>(
      'name', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(),
      type: const StringType(),
      requiredDuringInsert: true);
  final VerificationMeta _colourMeta = const VerificationMeta('colour');
  @override
  late final GeneratedColumn<String?> colour = GeneratedColumn<String?>(
      'colour', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(),
      type: const StringType(),
      requiredDuringInsert: false);
  final VerificationMeta _iconNameMeta = const VerificationMeta('iconName');
  @override
  late final GeneratedColumn<String?> iconName = GeneratedColumn<String?>(
      'icon_name', aliasedName, true,
      type: const StringType(), requiredDuringInsert: false);
  final VerificationMeta _dateCreatedMeta =
      const VerificationMeta('dateCreated');
  @override
  late final GeneratedColumn<DateTime?> dateCreated =
      GeneratedColumn<DateTime?>('date_created', aliasedName, false,
          type: const IntType(),
          requiredDuringInsert: false,
          clientDefault: () => new DateTime.now());
  final VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int?> order = GeneratedColumn<int?>(
      'order', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [walletPk, name, colour, iconName, dateCreated, order];
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
    if (data.containsKey('order')) {
      context.handle(
          _orderMeta, order.isAcceptableOrUnknown(data['order']!, _orderMeta));
    } else if (isInserting) {
      context.missing(_orderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {walletPk};
  @override
  TransactionWallet map(Map<String, dynamic> data, {String? tablePrefix}) {
    return TransactionWallet.fromData(data,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $WalletsTable createAlias(String alias) {
    return $WalletsTable(_db, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final int transactionPk;
  final String name;
  final double amount;
  final String note;
  final int categoryFk;
  final int walletFk;
  final List<int>? labelFks;
  final DateTime dateCreated;
  final bool income;
  Transaction(
      {required this.transactionPk,
      required this.name,
      required this.amount,
      required this.note,
      required this.categoryFk,
      required this.walletFk,
      this.labelFks,
      required this.dateCreated,
      required this.income});
  factory Transaction.fromData(Map<String, dynamic> data, {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return Transaction(
      transactionPk: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}transaction_pk'])!,
      name: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}name'])!,
      amount: const RealType()
          .mapFromDatabaseResponse(data['${effectivePrefix}amount'])!,
      note: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}note'])!,
      categoryFk: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}category_fk'])!,
      walletFk: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}wallet_fk'])!,
      labelFks: $TransactionsTable.$converter0.mapToDart(const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}label_fks'])),
      dateCreated: const DateTimeType()
          .mapFromDatabaseResponse(data['${effectivePrefix}date_created'])!,
      income: const BoolType()
          .mapFromDatabaseResponse(data['${effectivePrefix}income'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['transaction_pk'] = Variable<int>(transactionPk);
    map['name'] = Variable<String>(name);
    map['amount'] = Variable<double>(amount);
    map['note'] = Variable<String>(note);
    map['category_fk'] = Variable<int>(categoryFk);
    map['wallet_fk'] = Variable<int>(walletFk);
    if (!nullToAbsent || labelFks != null) {
      final converter = $TransactionsTable.$converter0;
      map['label_fks'] = Variable<String?>(converter.mapToSql(labelFks));
    }
    map['date_created'] = Variable<DateTime>(dateCreated);
    map['income'] = Variable<bool>(income);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      transactionPk: Value(transactionPk),
      name: Value(name),
      amount: Value(amount),
      note: Value(note),
      categoryFk: Value(categoryFk),
      walletFk: Value(walletFk),
      labelFks: labelFks == null && nullToAbsent
          ? const Value.absent()
          : Value(labelFks),
      dateCreated: Value(dateCreated),
      income: Value(income),
    );
  }

  factory Transaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      transactionPk: serializer.fromJson<int>(json['transactionPk']),
      name: serializer.fromJson<String>(json['name']),
      amount: serializer.fromJson<double>(json['amount']),
      note: serializer.fromJson<String>(json['note']),
      categoryFk: serializer.fromJson<int>(json['categoryFk']),
      walletFk: serializer.fromJson<int>(json['walletFk']),
      labelFks: serializer.fromJson<List<int>?>(json['labelFks']),
      dateCreated: serializer.fromJson<DateTime>(json['dateCreated']),
      income: serializer.fromJson<bool>(json['income']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'transactionPk': serializer.toJson<int>(transactionPk),
      'name': serializer.toJson<String>(name),
      'amount': serializer.toJson<double>(amount),
      'note': serializer.toJson<String>(note),
      'categoryFk': serializer.toJson<int>(categoryFk),
      'walletFk': serializer.toJson<int>(walletFk),
      'labelFks': serializer.toJson<List<int>?>(labelFks),
      'dateCreated': serializer.toJson<DateTime>(dateCreated),
      'income': serializer.toJson<bool>(income),
    };
  }

  Transaction copyWith(
          {int? transactionPk,
          String? name,
          double? amount,
          String? note,
          int? categoryFk,
          int? walletFk,
          List<int>? labelFks,
          DateTime? dateCreated,
          bool? income}) =>
      Transaction(
        transactionPk: transactionPk ?? this.transactionPk,
        name: name ?? this.name,
        amount: amount ?? this.amount,
        note: note ?? this.note,
        categoryFk: categoryFk ?? this.categoryFk,
        walletFk: walletFk ?? this.walletFk,
        labelFks: labelFks ?? this.labelFks,
        dateCreated: dateCreated ?? this.dateCreated,
        income: income ?? this.income,
      );
  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('transactionPk: $transactionPk, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('note: $note, ')
          ..write('categoryFk: $categoryFk, ')
          ..write('walletFk: $walletFk, ')
          ..write('labelFks: $labelFks, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('income: $income')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(transactionPk, name, amount, note, categoryFk,
      walletFk, labelFks, dateCreated, income);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.transactionPk == this.transactionPk &&
          other.name == this.name &&
          other.amount == this.amount &&
          other.note == this.note &&
          other.categoryFk == this.categoryFk &&
          other.walletFk == this.walletFk &&
          other.labelFks == this.labelFks &&
          other.dateCreated == this.dateCreated &&
          other.income == this.income);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<int> transactionPk;
  final Value<String> name;
  final Value<double> amount;
  final Value<String> note;
  final Value<int> categoryFk;
  final Value<int> walletFk;
  final Value<List<int>?> labelFks;
  final Value<DateTime> dateCreated;
  final Value<bool> income;
  const TransactionsCompanion({
    this.transactionPk = const Value.absent(),
    this.name = const Value.absent(),
    this.amount = const Value.absent(),
    this.note = const Value.absent(),
    this.categoryFk = const Value.absent(),
    this.walletFk = const Value.absent(),
    this.labelFks = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.income = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.transactionPk = const Value.absent(),
    required String name,
    required double amount,
    required String note,
    required int categoryFk,
    required int walletFk,
    this.labelFks = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.income = const Value.absent(),
  })  : name = Value(name),
        amount = Value(amount),
        note = Value(note),
        categoryFk = Value(categoryFk),
        walletFk = Value(walletFk);
  static Insertable<Transaction> custom({
    Expression<int>? transactionPk,
    Expression<String>? name,
    Expression<double>? amount,
    Expression<String>? note,
    Expression<int>? categoryFk,
    Expression<int>? walletFk,
    Expression<List<int>?>? labelFks,
    Expression<DateTime>? dateCreated,
    Expression<bool>? income,
  }) {
    return RawValuesInsertable({
      if (transactionPk != null) 'transaction_pk': transactionPk,
      if (name != null) 'name': name,
      if (amount != null) 'amount': amount,
      if (note != null) 'note': note,
      if (categoryFk != null) 'category_fk': categoryFk,
      if (walletFk != null) 'wallet_fk': walletFk,
      if (labelFks != null) 'label_fks': labelFks,
      if (dateCreated != null) 'date_created': dateCreated,
      if (income != null) 'income': income,
    });
  }

  TransactionsCompanion copyWith(
      {Value<int>? transactionPk,
      Value<String>? name,
      Value<double>? amount,
      Value<String>? note,
      Value<int>? categoryFk,
      Value<int>? walletFk,
      Value<List<int>?>? labelFks,
      Value<DateTime>? dateCreated,
      Value<bool>? income}) {
    return TransactionsCompanion(
      transactionPk: transactionPk ?? this.transactionPk,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      categoryFk: categoryFk ?? this.categoryFk,
      walletFk: walletFk ?? this.walletFk,
      labelFks: labelFks ?? this.labelFks,
      dateCreated: dateCreated ?? this.dateCreated,
      income: income ?? this.income,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (transactionPk.present) {
      map['transaction_pk'] = Variable<int>(transactionPk.value);
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
      map['category_fk'] = Variable<int>(categoryFk.value);
    }
    if (walletFk.present) {
      map['wallet_fk'] = Variable<int>(walletFk.value);
    }
    if (labelFks.present) {
      final converter = $TransactionsTable.$converter0;
      map['label_fks'] = Variable<String?>(converter.mapToSql(labelFks.value));
    }
    if (dateCreated.present) {
      map['date_created'] = Variable<DateTime>(dateCreated.value);
    }
    if (income.present) {
      map['income'] = Variable<bool>(income.value);
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
          ..write('walletFk: $walletFk, ')
          ..write('labelFks: $labelFks, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('income: $income')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  final GeneratedDatabase _db;
  final String? _alias;
  $TransactionsTable(this._db, [this._alias]);
  final VerificationMeta _transactionPkMeta =
      const VerificationMeta('transactionPk');
  @override
  late final GeneratedColumn<int?> transactionPk = GeneratedColumn<int?>(
      'transaction_pk', aliasedName, false,
      type: const IntType(),
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT');
  final VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String?> name = GeneratedColumn<String?>(
      'name', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(),
      type: const StringType(),
      requiredDuringInsert: true);
  final VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double?> amount = GeneratedColumn<double?>(
      'amount', aliasedName, false,
      type: const RealType(), requiredDuringInsert: true);
  final VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String?> note = GeneratedColumn<String?>(
      'note', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(),
      type: const StringType(),
      requiredDuringInsert: true);
  final VerificationMeta _categoryFkMeta = const VerificationMeta('categoryFk');
  @override
  late final GeneratedColumn<int?> categoryFk = GeneratedColumn<int?>(
      'category_fk', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _walletFkMeta = const VerificationMeta('walletFk');
  @override
  late final GeneratedColumn<int?> walletFk = GeneratedColumn<int?>(
      'wallet_fk', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _labelFksMeta = const VerificationMeta('labelFks');
  @override
  late final GeneratedColumnWithTypeConverter<List<int>, String?> labelFks =
      GeneratedColumn<String?>('label_fks', aliasedName, true,
              type: const StringType(), requiredDuringInsert: false)
          .withConverter<List<int>>($TransactionsTable.$converter0);
  final VerificationMeta _dateCreatedMeta =
      const VerificationMeta('dateCreated');
  @override
  late final GeneratedColumn<DateTime?> dateCreated =
      GeneratedColumn<DateTime?>('date_created', aliasedName, false,
          type: const IntType(),
          requiredDuringInsert: false,
          clientDefault: () => new DateTime.now());
  final VerificationMeta _incomeMeta = const VerificationMeta('income');
  @override
  late final GeneratedColumn<bool?> income = GeneratedColumn<bool?>(
      'income', aliasedName, false,
      type: const BoolType(),
      requiredDuringInsert: false,
      defaultConstraints: 'CHECK (income IN (0, 1))',
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        transactionPk,
        name,
        amount,
        note,
        categoryFk,
        walletFk,
        labelFks,
        dateCreated,
        income
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
    if (data.containsKey('wallet_fk')) {
      context.handle(_walletFkMeta,
          walletFk.isAcceptableOrUnknown(data['wallet_fk']!, _walletFkMeta));
    } else if (isInserting) {
      context.missing(_walletFkMeta);
    }
    context.handle(_labelFksMeta, const VerificationResult.success());
    if (data.containsKey('date_created')) {
      context.handle(
          _dateCreatedMeta,
          dateCreated.isAcceptableOrUnknown(
              data['date_created']!, _dateCreatedMeta));
    }
    if (data.containsKey('income')) {
      context.handle(_incomeMeta,
          income.isAcceptableOrUnknown(data['income']!, _incomeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {transactionPk};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    return Transaction.fromData(data,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(_db, alias);
  }

  static TypeConverter<List<int>, String> $converter0 =
      const IntListInColumnConverter();
}

class TransactionCategory extends DataClass
    implements Insertable<TransactionCategory> {
  final int categoryPk;
  final String name;
  final String? colour;
  final String? iconName;
  final DateTime dateCreated;
  final int order;
  final bool income;
  final List<String>? smartLabels;
  TransactionCategory(
      {required this.categoryPk,
      required this.name,
      this.colour,
      this.iconName,
      required this.dateCreated,
      required this.order,
      required this.income,
      this.smartLabels});
  factory TransactionCategory.fromData(Map<String, dynamic> data,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return TransactionCategory(
      categoryPk: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}category_pk'])!,
      name: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}name'])!,
      colour: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}colour']),
      iconName: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}icon_name']),
      dateCreated: const DateTimeType()
          .mapFromDatabaseResponse(data['${effectivePrefix}date_created'])!,
      order: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}order'])!,
      income: const BoolType()
          .mapFromDatabaseResponse(data['${effectivePrefix}income'])!,
      smartLabels: $CategoriesTable.$converter0.mapToDart(const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}smart_labels'])),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['category_pk'] = Variable<int>(categoryPk);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || colour != null) {
      map['colour'] = Variable<String?>(colour);
    }
    if (!nullToAbsent || iconName != null) {
      map['icon_name'] = Variable<String?>(iconName);
    }
    map['date_created'] = Variable<DateTime>(dateCreated);
    map['order'] = Variable<int>(order);
    map['income'] = Variable<bool>(income);
    if (!nullToAbsent || smartLabels != null) {
      final converter = $CategoriesTable.$converter0;
      map['smart_labels'] = Variable<String?>(converter.mapToSql(smartLabels));
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
      dateCreated: Value(dateCreated),
      order: Value(order),
      income: Value(income),
      smartLabels: smartLabels == null && nullToAbsent
          ? const Value.absent()
          : Value(smartLabels),
    );
  }

  factory TransactionCategory.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionCategory(
      categoryPk: serializer.fromJson<int>(json['categoryPk']),
      name: serializer.fromJson<String>(json['name']),
      colour: serializer.fromJson<String?>(json['colour']),
      iconName: serializer.fromJson<String?>(json['iconName']),
      dateCreated: serializer.fromJson<DateTime>(json['dateCreated']),
      order: serializer.fromJson<int>(json['order']),
      income: serializer.fromJson<bool>(json['income']),
      smartLabels: serializer.fromJson<List<String>?>(json['smartLabels']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'categoryPk': serializer.toJson<int>(categoryPk),
      'name': serializer.toJson<String>(name),
      'colour': serializer.toJson<String?>(colour),
      'iconName': serializer.toJson<String?>(iconName),
      'dateCreated': serializer.toJson<DateTime>(dateCreated),
      'order': serializer.toJson<int>(order),
      'income': serializer.toJson<bool>(income),
      'smartLabels': serializer.toJson<List<String>?>(smartLabels),
    };
  }

  TransactionCategory copyWith(
          {int? categoryPk,
          String? name,
          String? colour,
          String? iconName,
          DateTime? dateCreated,
          int? order,
          bool? income,
          List<String>? smartLabels}) =>
      TransactionCategory(
        categoryPk: categoryPk ?? this.categoryPk,
        name: name ?? this.name,
        colour: colour ?? this.colour,
        iconName: iconName ?? this.iconName,
        dateCreated: dateCreated ?? this.dateCreated,
        order: order ?? this.order,
        income: income ?? this.income,
        smartLabels: smartLabels ?? this.smartLabels,
      );
  @override
  String toString() {
    return (StringBuffer('TransactionCategory(')
          ..write('categoryPk: $categoryPk, ')
          ..write('name: $name, ')
          ..write('colour: $colour, ')
          ..write('iconName: $iconName, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('order: $order, ')
          ..write('income: $income, ')
          ..write('smartLabels: $smartLabels')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(categoryPk, name, colour, iconName,
      dateCreated, order, income, smartLabels);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionCategory &&
          other.categoryPk == this.categoryPk &&
          other.name == this.name &&
          other.colour == this.colour &&
          other.iconName == this.iconName &&
          other.dateCreated == this.dateCreated &&
          other.order == this.order &&
          other.income == this.income &&
          other.smartLabels == this.smartLabels);
}

class CategoriesCompanion extends UpdateCompanion<TransactionCategory> {
  final Value<int> categoryPk;
  final Value<String> name;
  final Value<String?> colour;
  final Value<String?> iconName;
  final Value<DateTime> dateCreated;
  final Value<int> order;
  final Value<bool> income;
  final Value<List<String>?> smartLabels;
  const CategoriesCompanion({
    this.categoryPk = const Value.absent(),
    this.name = const Value.absent(),
    this.colour = const Value.absent(),
    this.iconName = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.order = const Value.absent(),
    this.income = const Value.absent(),
    this.smartLabels = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.categoryPk = const Value.absent(),
    required String name,
    this.colour = const Value.absent(),
    this.iconName = const Value.absent(),
    this.dateCreated = const Value.absent(),
    required int order,
    this.income = const Value.absent(),
    this.smartLabels = const Value.absent(),
  })  : name = Value(name),
        order = Value(order);
  static Insertable<TransactionCategory> custom({
    Expression<int>? categoryPk,
    Expression<String>? name,
    Expression<String?>? colour,
    Expression<String?>? iconName,
    Expression<DateTime>? dateCreated,
    Expression<int>? order,
    Expression<bool>? income,
    Expression<List<String>?>? smartLabels,
  }) {
    return RawValuesInsertable({
      if (categoryPk != null) 'category_pk': categoryPk,
      if (name != null) 'name': name,
      if (colour != null) 'colour': colour,
      if (iconName != null) 'icon_name': iconName,
      if (dateCreated != null) 'date_created': dateCreated,
      if (order != null) 'order': order,
      if (income != null) 'income': income,
      if (smartLabels != null) 'smart_labels': smartLabels,
    });
  }

  CategoriesCompanion copyWith(
      {Value<int>? categoryPk,
      Value<String>? name,
      Value<String?>? colour,
      Value<String?>? iconName,
      Value<DateTime>? dateCreated,
      Value<int>? order,
      Value<bool>? income,
      Value<List<String>?>? smartLabels}) {
    return CategoriesCompanion(
      categoryPk: categoryPk ?? this.categoryPk,
      name: name ?? this.name,
      colour: colour ?? this.colour,
      iconName: iconName ?? this.iconName,
      dateCreated: dateCreated ?? this.dateCreated,
      order: order ?? this.order,
      income: income ?? this.income,
      smartLabels: smartLabels ?? this.smartLabels,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (categoryPk.present) {
      map['category_pk'] = Variable<int>(categoryPk.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (colour.present) {
      map['colour'] = Variable<String?>(colour.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String?>(iconName.value);
    }
    if (dateCreated.present) {
      map['date_created'] = Variable<DateTime>(dateCreated.value);
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    if (income.present) {
      map['income'] = Variable<bool>(income.value);
    }
    if (smartLabels.present) {
      final converter = $CategoriesTable.$converter0;
      map['smart_labels'] =
          Variable<String?>(converter.mapToSql(smartLabels.value));
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
          ..write('dateCreated: $dateCreated, ')
          ..write('order: $order, ')
          ..write('income: $income, ')
          ..write('smartLabels: $smartLabels')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, TransactionCategory> {
  final GeneratedDatabase _db;
  final String? _alias;
  $CategoriesTable(this._db, [this._alias]);
  final VerificationMeta _categoryPkMeta = const VerificationMeta('categoryPk');
  @override
  late final GeneratedColumn<int?> categoryPk = GeneratedColumn<int?>(
      'category_pk', aliasedName, false,
      type: const IntType(),
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT');
  final VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String?> name = GeneratedColumn<String?>(
      'name', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(),
      type: const StringType(),
      requiredDuringInsert: true);
  final VerificationMeta _colourMeta = const VerificationMeta('colour');
  @override
  late final GeneratedColumn<String?> colour = GeneratedColumn<String?>(
      'colour', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(),
      type: const StringType(),
      requiredDuringInsert: false);
  final VerificationMeta _iconNameMeta = const VerificationMeta('iconName');
  @override
  late final GeneratedColumn<String?> iconName = GeneratedColumn<String?>(
      'icon_name', aliasedName, true,
      type: const StringType(), requiredDuringInsert: false);
  final VerificationMeta _dateCreatedMeta =
      const VerificationMeta('dateCreated');
  @override
  late final GeneratedColumn<DateTime?> dateCreated =
      GeneratedColumn<DateTime?>('date_created', aliasedName, false,
          type: const IntType(),
          requiredDuringInsert: false,
          clientDefault: () => new DateTime.now());
  final VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int?> order = GeneratedColumn<int?>(
      'order', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _incomeMeta = const VerificationMeta('income');
  @override
  late final GeneratedColumn<bool?> income = GeneratedColumn<bool?>(
      'income', aliasedName, false,
      type: const BoolType(),
      requiredDuringInsert: false,
      defaultConstraints: 'CHECK (income IN (0, 1))',
      defaultValue: const Constant(false));
  final VerificationMeta _smartLabelsMeta =
      const VerificationMeta('smartLabels');
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String?>
      smartLabels = GeneratedColumn<String?>('smart_labels', aliasedName, true,
              type: const StringType(), requiredDuringInsert: false)
          .withConverter<List<String>>($CategoriesTable.$converter0);
  @override
  List<GeneratedColumn> get $columns => [
        categoryPk,
        name,
        colour,
        iconName,
        dateCreated,
        order,
        income,
        smartLabels
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
    if (data.containsKey('date_created')) {
      context.handle(
          _dateCreatedMeta,
          dateCreated.isAcceptableOrUnknown(
              data['date_created']!, _dateCreatedMeta));
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
    context.handle(_smartLabelsMeta, const VerificationResult.success());
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {categoryPk};
  @override
  TransactionCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    return TransactionCategory.fromData(data,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(_db, alias);
  }

  static TypeConverter<List<String>, String> $converter0 =
      const StringListInColumnConverter();
}

class TransactionLabel extends DataClass
    implements Insertable<TransactionLabel> {
  final int label_pk;
  final String name;
  final int categoryFk;
  final DateTime dateCreated;
  final int order;
  TransactionLabel(
      {required this.label_pk,
      required this.name,
      required this.categoryFk,
      required this.dateCreated,
      required this.order});
  factory TransactionLabel.fromData(Map<String, dynamic> data,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return TransactionLabel(
      label_pk: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}label_pk'])!,
      name: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}name'])!,
      categoryFk: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}category_fk'])!,
      dateCreated: const DateTimeType()
          .mapFromDatabaseResponse(data['${effectivePrefix}date_created'])!,
      order: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}order'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['label_pk'] = Variable<int>(label_pk);
    map['name'] = Variable<String>(name);
    map['category_fk'] = Variable<int>(categoryFk);
    map['date_created'] = Variable<DateTime>(dateCreated);
    map['order'] = Variable<int>(order);
    return map;
  }

  LabelsCompanion toCompanion(bool nullToAbsent) {
    return LabelsCompanion(
      label_pk: Value(label_pk),
      name: Value(name),
      categoryFk: Value(categoryFk),
      dateCreated: Value(dateCreated),
      order: Value(order),
    );
  }

  factory TransactionLabel.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionLabel(
      label_pk: serializer.fromJson<int>(json['label_pk']),
      name: serializer.fromJson<String>(json['name']),
      categoryFk: serializer.fromJson<int>(json['categoryFk']),
      dateCreated: serializer.fromJson<DateTime>(json['dateCreated']),
      order: serializer.fromJson<int>(json['order']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'label_pk': serializer.toJson<int>(label_pk),
      'name': serializer.toJson<String>(name),
      'categoryFk': serializer.toJson<int>(categoryFk),
      'dateCreated': serializer.toJson<DateTime>(dateCreated),
      'order': serializer.toJson<int>(order),
    };
  }

  TransactionLabel copyWith(
          {int? label_pk,
          String? name,
          int? categoryFk,
          DateTime? dateCreated,
          int? order}) =>
      TransactionLabel(
        label_pk: label_pk ?? this.label_pk,
        name: name ?? this.name,
        categoryFk: categoryFk ?? this.categoryFk,
        dateCreated: dateCreated ?? this.dateCreated,
        order: order ?? this.order,
      );
  @override
  String toString() {
    return (StringBuffer('TransactionLabel(')
          ..write('label_pk: $label_pk, ')
          ..write('name: $name, ')
          ..write('categoryFk: $categoryFk, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('order: $order')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(label_pk, name, categoryFk, dateCreated, order);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionLabel &&
          other.label_pk == this.label_pk &&
          other.name == this.name &&
          other.categoryFk == this.categoryFk &&
          other.dateCreated == this.dateCreated &&
          other.order == this.order);
}

class LabelsCompanion extends UpdateCompanion<TransactionLabel> {
  final Value<int> label_pk;
  final Value<String> name;
  final Value<int> categoryFk;
  final Value<DateTime> dateCreated;
  final Value<int> order;
  const LabelsCompanion({
    this.label_pk = const Value.absent(),
    this.name = const Value.absent(),
    this.categoryFk = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.order = const Value.absent(),
  });
  LabelsCompanion.insert({
    this.label_pk = const Value.absent(),
    required String name,
    required int categoryFk,
    this.dateCreated = const Value.absent(),
    required int order,
  })  : name = Value(name),
        categoryFk = Value(categoryFk),
        order = Value(order);
  static Insertable<TransactionLabel> custom({
    Expression<int>? label_pk,
    Expression<String>? name,
    Expression<int>? categoryFk,
    Expression<DateTime>? dateCreated,
    Expression<int>? order,
  }) {
    return RawValuesInsertable({
      if (label_pk != null) 'label_pk': label_pk,
      if (name != null) 'name': name,
      if (categoryFk != null) 'category_fk': categoryFk,
      if (dateCreated != null) 'date_created': dateCreated,
      if (order != null) 'order': order,
    });
  }

  LabelsCompanion copyWith(
      {Value<int>? label_pk,
      Value<String>? name,
      Value<int>? categoryFk,
      Value<DateTime>? dateCreated,
      Value<int>? order}) {
    return LabelsCompanion(
      label_pk: label_pk ?? this.label_pk,
      name: name ?? this.name,
      categoryFk: categoryFk ?? this.categoryFk,
      dateCreated: dateCreated ?? this.dateCreated,
      order: order ?? this.order,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (label_pk.present) {
      map['label_pk'] = Variable<int>(label_pk.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (categoryFk.present) {
      map['category_fk'] = Variable<int>(categoryFk.value);
    }
    if (dateCreated.present) {
      map['date_created'] = Variable<DateTime>(dateCreated.value);
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LabelsCompanion(')
          ..write('label_pk: $label_pk, ')
          ..write('name: $name, ')
          ..write('categoryFk: $categoryFk, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('order: $order')
          ..write(')'))
        .toString();
  }
}

class $LabelsTable extends Labels
    with TableInfo<$LabelsTable, TransactionLabel> {
  final GeneratedDatabase _db;
  final String? _alias;
  $LabelsTable(this._db, [this._alias]);
  final VerificationMeta _label_pkMeta = const VerificationMeta('label_pk');
  @override
  late final GeneratedColumn<int?> label_pk = GeneratedColumn<int?>(
      'label_pk', aliasedName, false,
      type: const IntType(),
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT');
  final VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String?> name = GeneratedColumn<String?>(
      'name', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(),
      type: const StringType(),
      requiredDuringInsert: true);
  final VerificationMeta _categoryFkMeta = const VerificationMeta('categoryFk');
  @override
  late final GeneratedColumn<int?> categoryFk = GeneratedColumn<int?>(
      'category_fk', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _dateCreatedMeta =
      const VerificationMeta('dateCreated');
  @override
  late final GeneratedColumn<DateTime?> dateCreated =
      GeneratedColumn<DateTime?>('date_created', aliasedName, false,
          type: const IntType(),
          requiredDuringInsert: false,
          clientDefault: () => new DateTime.now());
  final VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int?> order = GeneratedColumn<int?>(
      'order', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [label_pk, name, categoryFk, dateCreated, order];
  @override
  String get aliasedName => _alias ?? 'labels';
  @override
  String get actualTableName => 'labels';
  @override
  VerificationContext validateIntegrity(Insertable<TransactionLabel> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('label_pk')) {
      context.handle(_label_pkMeta,
          label_pk.isAcceptableOrUnknown(data['label_pk']!, _label_pkMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category_fk')) {
      context.handle(
          _categoryFkMeta,
          categoryFk.isAcceptableOrUnknown(
              data['category_fk']!, _categoryFkMeta));
    } else if (isInserting) {
      context.missing(_categoryFkMeta);
    }
    if (data.containsKey('date_created')) {
      context.handle(
          _dateCreatedMeta,
          dateCreated.isAcceptableOrUnknown(
              data['date_created']!, _dateCreatedMeta));
    }
    if (data.containsKey('order')) {
      context.handle(
          _orderMeta, order.isAcceptableOrUnknown(data['order']!, _orderMeta));
    } else if (isInserting) {
      context.missing(_orderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {label_pk};
  @override
  TransactionLabel map(Map<String, dynamic> data, {String? tablePrefix}) {
    return TransactionLabel.fromData(data,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $LabelsTable createAlias(String alias) {
    return $LabelsTable(_db, alias);
  }
}

class Budget extends DataClass implements Insertable<Budget> {
  final int budgetPk;
  final String name;
  final double amount;
  final String colour;
  final DateTime startDate;
  final DateTime endDate;
  final List<int>? categoryFks;
  final bool allCategoryFks;
  final int periodLength;
  final BudgetReoccurence? reoccurrence;
  final DateTime dateCreated;
  final bool pinned;
  final int order;
  final int walletFk;
  Budget(
      {required this.budgetPk,
      required this.name,
      required this.amount,
      required this.colour,
      required this.startDate,
      required this.endDate,
      this.categoryFks,
      required this.allCategoryFks,
      required this.periodLength,
      this.reoccurrence,
      required this.dateCreated,
      required this.pinned,
      required this.order,
      required this.walletFk});
  factory Budget.fromData(Map<String, dynamic> data, {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return Budget(
      budgetPk: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}budget_pk'])!,
      name: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}name'])!,
      amount: const RealType()
          .mapFromDatabaseResponse(data['${effectivePrefix}amount'])!,
      colour: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}colour'])!,
      startDate: const DateTimeType()
          .mapFromDatabaseResponse(data['${effectivePrefix}start_date'])!,
      endDate: const DateTimeType()
          .mapFromDatabaseResponse(data['${effectivePrefix}end_date'])!,
      categoryFks: $BudgetsTable.$converter0.mapToDart(const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}category_fks'])),
      allCategoryFks: const BoolType()
          .mapFromDatabaseResponse(data['${effectivePrefix}all_category_fks'])!,
      periodLength: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}period_length'])!,
      reoccurrence: $BudgetsTable.$converter1.mapToDart(const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}reoccurrence'])),
      dateCreated: const DateTimeType()
          .mapFromDatabaseResponse(data['${effectivePrefix}date_created'])!,
      pinned: const BoolType()
          .mapFromDatabaseResponse(data['${effectivePrefix}pinned'])!,
      order: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}order'])!,
      walletFk: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}wallet_fk'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['budget_pk'] = Variable<int>(budgetPk);
    map['name'] = Variable<String>(name);
    map['amount'] = Variable<double>(amount);
    map['colour'] = Variable<String>(colour);
    map['start_date'] = Variable<DateTime>(startDate);
    map['end_date'] = Variable<DateTime>(endDate);
    if (!nullToAbsent || categoryFks != null) {
      final converter = $BudgetsTable.$converter0;
      map['category_fks'] = Variable<String?>(converter.mapToSql(categoryFks));
    }
    map['all_category_fks'] = Variable<bool>(allCategoryFks);
    map['period_length'] = Variable<int>(periodLength);
    if (!nullToAbsent || reoccurrence != null) {
      final converter = $BudgetsTable.$converter1;
      map['reoccurrence'] = Variable<int?>(converter.mapToSql(reoccurrence));
    }
    map['date_created'] = Variable<DateTime>(dateCreated);
    map['pinned'] = Variable<bool>(pinned);
    map['order'] = Variable<int>(order);
    map['wallet_fk'] = Variable<int>(walletFk);
    return map;
  }

  BudgetsCompanion toCompanion(bool nullToAbsent) {
    return BudgetsCompanion(
      budgetPk: Value(budgetPk),
      name: Value(name),
      amount: Value(amount),
      colour: Value(colour),
      startDate: Value(startDate),
      endDate: Value(endDate),
      categoryFks: categoryFks == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryFks),
      allCategoryFks: Value(allCategoryFks),
      periodLength: Value(periodLength),
      reoccurrence: reoccurrence == null && nullToAbsent
          ? const Value.absent()
          : Value(reoccurrence),
      dateCreated: Value(dateCreated),
      pinned: Value(pinned),
      order: Value(order),
      walletFk: Value(walletFk),
    );
  }

  factory Budget.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Budget(
      budgetPk: serializer.fromJson<int>(json['budgetPk']),
      name: serializer.fromJson<String>(json['name']),
      amount: serializer.fromJson<double>(json['amount']),
      colour: serializer.fromJson<String>(json['colour']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime>(json['endDate']),
      categoryFks: serializer.fromJson<List<int>?>(json['categoryFks']),
      allCategoryFks: serializer.fromJson<bool>(json['allCategoryFks']),
      periodLength: serializer.fromJson<int>(json['periodLength']),
      reoccurrence:
          serializer.fromJson<BudgetReoccurence?>(json['reoccurrence']),
      dateCreated: serializer.fromJson<DateTime>(json['dateCreated']),
      pinned: serializer.fromJson<bool>(json['pinned']),
      order: serializer.fromJson<int>(json['order']),
      walletFk: serializer.fromJson<int>(json['walletFk']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'budgetPk': serializer.toJson<int>(budgetPk),
      'name': serializer.toJson<String>(name),
      'amount': serializer.toJson<double>(amount),
      'colour': serializer.toJson<String>(colour),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime>(endDate),
      'categoryFks': serializer.toJson<List<int>?>(categoryFks),
      'allCategoryFks': serializer.toJson<bool>(allCategoryFks),
      'periodLength': serializer.toJson<int>(periodLength),
      'reoccurrence': serializer.toJson<BudgetReoccurence?>(reoccurrence),
      'dateCreated': serializer.toJson<DateTime>(dateCreated),
      'pinned': serializer.toJson<bool>(pinned),
      'order': serializer.toJson<int>(order),
      'walletFk': serializer.toJson<int>(walletFk),
    };
  }

  Budget copyWith(
          {int? budgetPk,
          String? name,
          double? amount,
          String? colour,
          DateTime? startDate,
          DateTime? endDate,
          List<int>? categoryFks,
          bool? allCategoryFks,
          int? periodLength,
          BudgetReoccurence? reoccurrence,
          DateTime? dateCreated,
          bool? pinned,
          int? order,
          int? walletFk}) =>
      Budget(
        budgetPk: budgetPk ?? this.budgetPk,
        name: name ?? this.name,
        amount: amount ?? this.amount,
        colour: colour ?? this.colour,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        categoryFks: categoryFks ?? this.categoryFks,
        allCategoryFks: allCategoryFks ?? this.allCategoryFks,
        periodLength: periodLength ?? this.periodLength,
        reoccurrence: reoccurrence ?? this.reoccurrence,
        dateCreated: dateCreated ?? this.dateCreated,
        pinned: pinned ?? this.pinned,
        order: order ?? this.order,
        walletFk: walletFk ?? this.walletFk,
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
          ..write('categoryFks: $categoryFks, ')
          ..write('allCategoryFks: $allCategoryFks, ')
          ..write('periodLength: $periodLength, ')
          ..write('reoccurrence: $reoccurrence, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('pinned: $pinned, ')
          ..write('order: $order, ')
          ..write('walletFk: $walletFk')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      budgetPk,
      name,
      amount,
      colour,
      startDate,
      endDate,
      categoryFks,
      allCategoryFks,
      periodLength,
      reoccurrence,
      dateCreated,
      pinned,
      order,
      walletFk);
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
          other.categoryFks == this.categoryFks &&
          other.allCategoryFks == this.allCategoryFks &&
          other.periodLength == this.periodLength &&
          other.reoccurrence == this.reoccurrence &&
          other.dateCreated == this.dateCreated &&
          other.pinned == this.pinned &&
          other.order == this.order &&
          other.walletFk == this.walletFk);
}

class BudgetsCompanion extends UpdateCompanion<Budget> {
  final Value<int> budgetPk;
  final Value<String> name;
  final Value<double> amount;
  final Value<String> colour;
  final Value<DateTime> startDate;
  final Value<DateTime> endDate;
  final Value<List<int>?> categoryFks;
  final Value<bool> allCategoryFks;
  final Value<int> periodLength;
  final Value<BudgetReoccurence?> reoccurrence;
  final Value<DateTime> dateCreated;
  final Value<bool> pinned;
  final Value<int> order;
  final Value<int> walletFk;
  const BudgetsCompanion({
    this.budgetPk = const Value.absent(),
    this.name = const Value.absent(),
    this.amount = const Value.absent(),
    this.colour = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.categoryFks = const Value.absent(),
    this.allCategoryFks = const Value.absent(),
    this.periodLength = const Value.absent(),
    this.reoccurrence = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.pinned = const Value.absent(),
    this.order = const Value.absent(),
    this.walletFk = const Value.absent(),
  });
  BudgetsCompanion.insert({
    this.budgetPk = const Value.absent(),
    required String name,
    required double amount,
    required String colour,
    required DateTime startDate,
    required DateTime endDate,
    this.categoryFks = const Value.absent(),
    required bool allCategoryFks,
    required int periodLength,
    this.reoccurrence = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.pinned = const Value.absent(),
    required int order,
    required int walletFk,
  })  : name = Value(name),
        amount = Value(amount),
        colour = Value(colour),
        startDate = Value(startDate),
        endDate = Value(endDate),
        allCategoryFks = Value(allCategoryFks),
        periodLength = Value(periodLength),
        order = Value(order),
        walletFk = Value(walletFk);
  static Insertable<Budget> custom({
    Expression<int>? budgetPk,
    Expression<String>? name,
    Expression<double>? amount,
    Expression<String>? colour,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<List<int>?>? categoryFks,
    Expression<bool>? allCategoryFks,
    Expression<int>? periodLength,
    Expression<BudgetReoccurence?>? reoccurrence,
    Expression<DateTime>? dateCreated,
    Expression<bool>? pinned,
    Expression<int>? order,
    Expression<int>? walletFk,
  }) {
    return RawValuesInsertable({
      if (budgetPk != null) 'budget_pk': budgetPk,
      if (name != null) 'name': name,
      if (amount != null) 'amount': amount,
      if (colour != null) 'colour': colour,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (categoryFks != null) 'category_fks': categoryFks,
      if (allCategoryFks != null) 'all_category_fks': allCategoryFks,
      if (periodLength != null) 'period_length': periodLength,
      if (reoccurrence != null) 'reoccurrence': reoccurrence,
      if (dateCreated != null) 'date_created': dateCreated,
      if (pinned != null) 'pinned': pinned,
      if (order != null) 'order': order,
      if (walletFk != null) 'wallet_fk': walletFk,
    });
  }

  BudgetsCompanion copyWith(
      {Value<int>? budgetPk,
      Value<String>? name,
      Value<double>? amount,
      Value<String>? colour,
      Value<DateTime>? startDate,
      Value<DateTime>? endDate,
      Value<List<int>?>? categoryFks,
      Value<bool>? allCategoryFks,
      Value<int>? periodLength,
      Value<BudgetReoccurence?>? reoccurrence,
      Value<DateTime>? dateCreated,
      Value<bool>? pinned,
      Value<int>? order,
      Value<int>? walletFk}) {
    return BudgetsCompanion(
      budgetPk: budgetPk ?? this.budgetPk,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      colour: colour ?? this.colour,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      categoryFks: categoryFks ?? this.categoryFks,
      allCategoryFks: allCategoryFks ?? this.allCategoryFks,
      periodLength: periodLength ?? this.periodLength,
      reoccurrence: reoccurrence ?? this.reoccurrence,
      dateCreated: dateCreated ?? this.dateCreated,
      pinned: pinned ?? this.pinned,
      order: order ?? this.order,
      walletFk: walletFk ?? this.walletFk,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (budgetPk.present) {
      map['budget_pk'] = Variable<int>(budgetPk.value);
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
    if (categoryFks.present) {
      final converter = $BudgetsTable.$converter0;
      map['category_fks'] =
          Variable<String?>(converter.mapToSql(categoryFks.value));
    }
    if (allCategoryFks.present) {
      map['all_category_fks'] = Variable<bool>(allCategoryFks.value);
    }
    if (periodLength.present) {
      map['period_length'] = Variable<int>(periodLength.value);
    }
    if (reoccurrence.present) {
      final converter = $BudgetsTable.$converter1;
      map['reoccurrence'] =
          Variable<int?>(converter.mapToSql(reoccurrence.value));
    }
    if (dateCreated.present) {
      map['date_created'] = Variable<DateTime>(dateCreated.value);
    }
    if (pinned.present) {
      map['pinned'] = Variable<bool>(pinned.value);
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    if (walletFk.present) {
      map['wallet_fk'] = Variable<int>(walletFk.value);
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
          ..write('categoryFks: $categoryFks, ')
          ..write('allCategoryFks: $allCategoryFks, ')
          ..write('periodLength: $periodLength, ')
          ..write('reoccurrence: $reoccurrence, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('pinned: $pinned, ')
          ..write('order: $order, ')
          ..write('walletFk: $walletFk')
          ..write(')'))
        .toString();
  }
}

class $BudgetsTable extends Budgets with TableInfo<$BudgetsTable, Budget> {
  final GeneratedDatabase _db;
  final String? _alias;
  $BudgetsTable(this._db, [this._alias]);
  final VerificationMeta _budgetPkMeta = const VerificationMeta('budgetPk');
  @override
  late final GeneratedColumn<int?> budgetPk = GeneratedColumn<int?>(
      'budget_pk', aliasedName, false,
      type: const IntType(),
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT');
  final VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String?> name = GeneratedColumn<String?>(
      'name', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(),
      type: const StringType(),
      requiredDuringInsert: true);
  final VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double?> amount = GeneratedColumn<double?>(
      'amount', aliasedName, false,
      type: const RealType(), requiredDuringInsert: true);
  final VerificationMeta _colourMeta = const VerificationMeta('colour');
  @override
  late final GeneratedColumn<String?> colour = GeneratedColumn<String?>(
      'colour', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(),
      type: const StringType(),
      requiredDuringInsert: true);
  final VerificationMeta _startDateMeta = const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime?> startDate = GeneratedColumn<DateTime?>(
      'start_date', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _endDateMeta = const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime?> endDate = GeneratedColumn<DateTime?>(
      'end_date', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _categoryFksMeta =
      const VerificationMeta('categoryFks');
  @override
  late final GeneratedColumnWithTypeConverter<List<int>, String?> categoryFks =
      GeneratedColumn<String?>('category_fks', aliasedName, true,
              type: const StringType(), requiredDuringInsert: false)
          .withConverter<List<int>>($BudgetsTable.$converter0);
  final VerificationMeta _allCategoryFksMeta =
      const VerificationMeta('allCategoryFks');
  @override
  late final GeneratedColumn<bool?> allCategoryFks = GeneratedColumn<bool?>(
      'all_category_fks', aliasedName, false,
      type: const BoolType(),
      requiredDuringInsert: true,
      defaultConstraints: 'CHECK (all_category_fks IN (0, 1))');
  final VerificationMeta _periodLengthMeta =
      const VerificationMeta('periodLength');
  @override
  late final GeneratedColumn<int?> periodLength = GeneratedColumn<int?>(
      'period_length', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _reoccurrenceMeta =
      const VerificationMeta('reoccurrence');
  @override
  late final GeneratedColumnWithTypeConverter<BudgetReoccurence?, int?>
      reoccurrence = GeneratedColumn<int?>('reoccurrence', aliasedName, true,
              type: const IntType(), requiredDuringInsert: false)
          .withConverter<BudgetReoccurence?>($BudgetsTable.$converter1);
  final VerificationMeta _dateCreatedMeta =
      const VerificationMeta('dateCreated');
  @override
  late final GeneratedColumn<DateTime?> dateCreated =
      GeneratedColumn<DateTime?>('date_created', aliasedName, false,
          type: const IntType(),
          requiredDuringInsert: false,
          clientDefault: () => new DateTime.now());
  final VerificationMeta _pinnedMeta = const VerificationMeta('pinned');
  @override
  late final GeneratedColumn<bool?> pinned = GeneratedColumn<bool?>(
      'pinned', aliasedName, false,
      type: const BoolType(),
      requiredDuringInsert: false,
      defaultConstraints: 'CHECK (pinned IN (0, 1))',
      defaultValue: const Constant(false));
  final VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int?> order = GeneratedColumn<int?>(
      'order', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _walletFkMeta = const VerificationMeta('walletFk');
  @override
  late final GeneratedColumn<int?> walletFk = GeneratedColumn<int?>(
      'wallet_fk', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        budgetPk,
        name,
        amount,
        colour,
        startDate,
        endDate,
        categoryFks,
        allCategoryFks,
        periodLength,
        reoccurrence,
        dateCreated,
        pinned,
        order,
        walletFk
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
    } else if (isInserting) {
      context.missing(_colourMeta);
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
    context.handle(_categoryFksMeta, const VerificationResult.success());
    if (data.containsKey('all_category_fks')) {
      context.handle(
          _allCategoryFksMeta,
          allCategoryFks.isAcceptableOrUnknown(
              data['all_category_fks']!, _allCategoryFksMeta));
    } else if (isInserting) {
      context.missing(_allCategoryFksMeta);
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
    } else if (isInserting) {
      context.missing(_walletFkMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {budgetPk};
  @override
  Budget map(Map<String, dynamic> data, {String? tablePrefix}) {
    return Budget.fromData(data,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $BudgetsTable createAlias(String alias) {
    return $BudgetsTable(_db, alias);
  }

  static TypeConverter<List<int>, String> $converter0 =
      const IntListInColumnConverter();
  static TypeConverter<BudgetReoccurence?, int> $converter1 =
      const EnumIndexConverter<BudgetReoccurence>(BudgetReoccurence.values);
}

abstract class _$FinanceDatabase extends GeneratedDatabase {
  _$FinanceDatabase(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  late final $WalletsTable wallets = $WalletsTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $LabelsTable labels = $LabelsTable(this);
  late final $BudgetsTable budgets = $BudgetsTable(this);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [wallets, transactions, categories, labels, budgets];
}
