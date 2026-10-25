// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TransactionsTableTable extends TransactionsTable
    with TableInfo<$TransactionsTableTable, TransactionsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bankMeta = const VerificationMeta('bank');
  @override
  late final GeneratedColumn<String> bank = GeneratedColumn<String>(
    'bank',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fromWalletMeta = const VerificationMeta(
    'fromWallet',
  );
  @override
  late final GeneratedColumn<String> fromWallet = GeneratedColumn<String>(
    'from_wallet',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toWalletMeta = const VerificationMeta(
    'toWallet',
  );
  @override
  late final GeneratedColumn<String> toWallet = GeneratedColumn<String>(
    'to_wallet',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawTextMeta = const VerificationMeta(
    'rawText',
  );
  @override
  late final GeneratedColumn<String> rawText = GeneratedColumn<String>(
    'raw_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<DateTime> time = GeneratedColumn<DateTime>(
    'time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bank,
    fromWallet,
    toWallet,
    amount,
    type,
    category,
    rawText,
    time,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('bank')) {
      context.handle(
        _bankMeta,
        bank.isAcceptableOrUnknown(data['bank']!, _bankMeta),
      );
    } else if (isInserting) {
      context.missing(_bankMeta);
    }
    if (data.containsKey('from_wallet')) {
      context.handle(
        _fromWalletMeta,
        fromWallet.isAcceptableOrUnknown(data['from_wallet']!, _fromWalletMeta),
      );
    }
    if (data.containsKey('to_wallet')) {
      context.handle(
        _toWalletMeta,
        toWallet.isAcceptableOrUnknown(data['to_wallet']!, _toWalletMeta),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('raw_text')) {
      context.handle(
        _rawTextMeta,
        rawText.isAcceptableOrUnknown(data['raw_text']!, _rawTextMeta),
      );
    } else if (isInserting) {
      context.missing(_rawTextMeta);
    }
    if (data.containsKey('time')) {
      context.handle(
        _timeMeta,
        time.isAcceptableOrUnknown(data['time']!, _timeMeta),
      );
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      bank: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bank'],
      )!,
      fromWallet: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_wallet'],
      ),
      toWallet: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_wallet'],
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      rawText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_text'],
      )!,
      time: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}time'],
      )!,
    );
  }

  @override
  $TransactionsTableTable createAlias(String alias) {
    return $TransactionsTableTable(attachedDatabase, alias);
  }
}

class TransactionsTableData extends DataClass
    implements Insertable<TransactionsTableData> {
  final String id;
  final String bank;
  final String? fromWallet;
  final String? toWallet;
  final int amount;
  final String type;
  final String category;
  final String rawText;
  final DateTime time;
  const TransactionsTableData({
    required this.id,
    required this.bank,
    this.fromWallet,
    this.toWallet,
    required this.amount,
    required this.type,
    required this.category,
    required this.rawText,
    required this.time,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['bank'] = Variable<String>(bank);
    if (!nullToAbsent || fromWallet != null) {
      map['from_wallet'] = Variable<String>(fromWallet);
    }
    if (!nullToAbsent || toWallet != null) {
      map['to_wallet'] = Variable<String>(toWallet);
    }
    map['amount'] = Variable<int>(amount);
    map['type'] = Variable<String>(type);
    map['category'] = Variable<String>(category);
    map['raw_text'] = Variable<String>(rawText);
    map['time'] = Variable<DateTime>(time);
    return map;
  }

  TransactionsTableCompanion toCompanion(bool nullToAbsent) {
    return TransactionsTableCompanion(
      id: Value(id),
      bank: Value(bank),
      fromWallet: fromWallet == null && nullToAbsent
          ? const Value.absent()
          : Value(fromWallet),
      toWallet: toWallet == null && nullToAbsent
          ? const Value.absent()
          : Value(toWallet),
      amount: Value(amount),
      type: Value(type),
      category: Value(category),
      rawText: Value(rawText),
      time: Value(time),
    );
  }

  factory TransactionsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionsTableData(
      id: serializer.fromJson<String>(json['id']),
      bank: serializer.fromJson<String>(json['bank']),
      fromWallet: serializer.fromJson<String?>(json['fromWallet']),
      toWallet: serializer.fromJson<String?>(json['toWallet']),
      amount: serializer.fromJson<int>(json['amount']),
      type: serializer.fromJson<String>(json['type']),
      category: serializer.fromJson<String>(json['category']),
      rawText: serializer.fromJson<String>(json['rawText']),
      time: serializer.fromJson<DateTime>(json['time']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bank': serializer.toJson<String>(bank),
      'fromWallet': serializer.toJson<String?>(fromWallet),
      'toWallet': serializer.toJson<String?>(toWallet),
      'amount': serializer.toJson<int>(amount),
      'type': serializer.toJson<String>(type),
      'category': serializer.toJson<String>(category),
      'rawText': serializer.toJson<String>(rawText),
      'time': serializer.toJson<DateTime>(time),
    };
  }

  TransactionsTableData copyWith({
    String? id,
    String? bank,
    Value<String?> fromWallet = const Value.absent(),
    Value<String?> toWallet = const Value.absent(),
    int? amount,
    String? type,
    String? category,
    String? rawText,
    DateTime? time,
  }) => TransactionsTableData(
    id: id ?? this.id,
    bank: bank ?? this.bank,
    fromWallet: fromWallet.present ? fromWallet.value : this.fromWallet,
    toWallet: toWallet.present ? toWallet.value : this.toWallet,
    amount: amount ?? this.amount,
    type: type ?? this.type,
    category: category ?? this.category,
    rawText: rawText ?? this.rawText,
    time: time ?? this.time,
  );
  TransactionsTableData copyWithCompanion(TransactionsTableCompanion data) {
    return TransactionsTableData(
      id: data.id.present ? data.id.value : this.id,
      bank: data.bank.present ? data.bank.value : this.bank,
      fromWallet: data.fromWallet.present
          ? data.fromWallet.value
          : this.fromWallet,
      toWallet: data.toWallet.present ? data.toWallet.value : this.toWallet,
      amount: data.amount.present ? data.amount.value : this.amount,
      type: data.type.present ? data.type.value : this.type,
      category: data.category.present ? data.category.value : this.category,
      rawText: data.rawText.present ? data.rawText.value : this.rawText,
      time: data.time.present ? data.time.value : this.time,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsTableData(')
          ..write('id: $id, ')
          ..write('bank: $bank, ')
          ..write('fromWallet: $fromWallet, ')
          ..write('toWallet: $toWallet, ')
          ..write('amount: $amount, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('rawText: $rawText, ')
          ..write('time: $time')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bank,
    fromWallet,
    toWallet,
    amount,
    type,
    category,
    rawText,
    time,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionsTableData &&
          other.id == this.id &&
          other.bank == this.bank &&
          other.fromWallet == this.fromWallet &&
          other.toWallet == this.toWallet &&
          other.amount == this.amount &&
          other.type == this.type &&
          other.category == this.category &&
          other.rawText == this.rawText &&
          other.time == this.time);
}

class TransactionsTableCompanion
    extends UpdateCompanion<TransactionsTableData> {
  final Value<String> id;
  final Value<String> bank;
  final Value<String?> fromWallet;
  final Value<String?> toWallet;
  final Value<int> amount;
  final Value<String> type;
  final Value<String> category;
  final Value<String> rawText;
  final Value<DateTime> time;
  final Value<int> rowid;
  const TransactionsTableCompanion({
    this.id = const Value.absent(),
    this.bank = const Value.absent(),
    this.fromWallet = const Value.absent(),
    this.toWallet = const Value.absent(),
    this.amount = const Value.absent(),
    this.type = const Value.absent(),
    this.category = const Value.absent(),
    this.rawText = const Value.absent(),
    this.time = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsTableCompanion.insert({
    required String id,
    required String bank,
    this.fromWallet = const Value.absent(),
    this.toWallet = const Value.absent(),
    required int amount,
    required String type,
    required String category,
    required String rawText,
    required DateTime time,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       bank = Value(bank),
       amount = Value(amount),
       type = Value(type),
       category = Value(category),
       rawText = Value(rawText),
       time = Value(time);
  static Insertable<TransactionsTableData> custom({
    Expression<String>? id,
    Expression<String>? bank,
    Expression<String>? fromWallet,
    Expression<String>? toWallet,
    Expression<int>? amount,
    Expression<String>? type,
    Expression<String>? category,
    Expression<String>? rawText,
    Expression<DateTime>? time,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bank != null) 'bank': bank,
      if (fromWallet != null) 'from_wallet': fromWallet,
      if (toWallet != null) 'to_wallet': toWallet,
      if (amount != null) 'amount': amount,
      if (type != null) 'type': type,
      if (category != null) 'category': category,
      if (rawText != null) 'raw_text': rawText,
      if (time != null) 'time': time,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? bank,
    Value<String?>? fromWallet,
    Value<String?>? toWallet,
    Value<int>? amount,
    Value<String>? type,
    Value<String>? category,
    Value<String>? rawText,
    Value<DateTime>? time,
    Value<int>? rowid,
  }) {
    return TransactionsTableCompanion(
      id: id ?? this.id,
      bank: bank ?? this.bank,
      fromWallet: fromWallet ?? this.fromWallet,
      toWallet: toWallet ?? this.toWallet,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      rawText: rawText ?? this.rawText,
      time: time ?? this.time,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bank.present) {
      map['bank'] = Variable<String>(bank.value);
    }
    if (fromWallet.present) {
      map['from_wallet'] = Variable<String>(fromWallet.value);
    }
    if (toWallet.present) {
      map['to_wallet'] = Variable<String>(toWallet.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (rawText.present) {
      map['raw_text'] = Variable<String>(rawText.value);
    }
    if (time.present) {
      map['time'] = Variable<DateTime>(time.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsTableCompanion(')
          ..write('id: $id, ')
          ..write('bank: $bank, ')
          ..write('fromWallet: $fromWallet, ')
          ..write('toWallet: $toWallet, ')
          ..write('amount: $amount, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('rawText: $rawText, ')
          ..write('time: $time, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotificationLogsTableTable extends NotificationLogsTable
    with TableInfo<$NotificationLogsTableTable, NotificationLogsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationLogsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _packageNameMeta = const VerificationMeta(
    'packageName',
  );
  @override
  late final GeneratedColumn<String> packageName = GeneratedColumn<String>(
    'package_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawTextMeta = const VerificationMeta(
    'rawText',
  );
  @override
  late final GeneratedColumn<String> rawText = GeneratedColumn<String>(
    'raw_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<int> timestamp = GeneratedColumn<int>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fingerprintMeta = const VerificationMeta(
    'fingerprint',
  );
  @override
  late final GeneratedColumn<String> fingerprint = GeneratedColumn<String>(
    'fingerprint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    packageName,
    title,
    rawText,
    timestamp,
    fingerprint,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notification_logs_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<NotificationLogsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('package_name')) {
      context.handle(
        _packageNameMeta,
        packageName.isAcceptableOrUnknown(
          data['package_name']!,
          _packageNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_packageNameMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('raw_text')) {
      context.handle(
        _rawTextMeta,
        rawText.isAcceptableOrUnknown(data['raw_text']!, _rawTextMeta),
      );
    } else if (isInserting) {
      context.missing(_rawTextMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('fingerprint')) {
      context.handle(
        _fingerprintMeta,
        fingerprint.isAcceptableOrUnknown(
          data['fingerprint']!,
          _fingerprintMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fingerprintMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NotificationLogsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotificationLogsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      packageName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_name'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      rawText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_text'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timestamp'],
      )!,
      fingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fingerprint'],
      )!,
    );
  }

  @override
  $NotificationLogsTableTable createAlias(String alias) {
    return $NotificationLogsTableTable(attachedDatabase, alias);
  }
}

class NotificationLogsTableData extends DataClass
    implements Insertable<NotificationLogsTableData> {
  final int id;
  final String packageName;
  final String title;
  final String rawText;
  final int timestamp;
  final String fingerprint;
  const NotificationLogsTableData({
    required this.id,
    required this.packageName,
    required this.title,
    required this.rawText,
    required this.timestamp,
    required this.fingerprint,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['package_name'] = Variable<String>(packageName);
    map['title'] = Variable<String>(title);
    map['raw_text'] = Variable<String>(rawText);
    map['timestamp'] = Variable<int>(timestamp);
    map['fingerprint'] = Variable<String>(fingerprint);
    return map;
  }

  NotificationLogsTableCompanion toCompanion(bool nullToAbsent) {
    return NotificationLogsTableCompanion(
      id: Value(id),
      packageName: Value(packageName),
      title: Value(title),
      rawText: Value(rawText),
      timestamp: Value(timestamp),
      fingerprint: Value(fingerprint),
    );
  }

  factory NotificationLogsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotificationLogsTableData(
      id: serializer.fromJson<int>(json['id']),
      packageName: serializer.fromJson<String>(json['packageName']),
      title: serializer.fromJson<String>(json['title']),
      rawText: serializer.fromJson<String>(json['rawText']),
      timestamp: serializer.fromJson<int>(json['timestamp']),
      fingerprint: serializer.fromJson<String>(json['fingerprint']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'packageName': serializer.toJson<String>(packageName),
      'title': serializer.toJson<String>(title),
      'rawText': serializer.toJson<String>(rawText),
      'timestamp': serializer.toJson<int>(timestamp),
      'fingerprint': serializer.toJson<String>(fingerprint),
    };
  }

  NotificationLogsTableData copyWith({
    int? id,
    String? packageName,
    String? title,
    String? rawText,
    int? timestamp,
    String? fingerprint,
  }) => NotificationLogsTableData(
    id: id ?? this.id,
    packageName: packageName ?? this.packageName,
    title: title ?? this.title,
    rawText: rawText ?? this.rawText,
    timestamp: timestamp ?? this.timestamp,
    fingerprint: fingerprint ?? this.fingerprint,
  );
  NotificationLogsTableData copyWithCompanion(
    NotificationLogsTableCompanion data,
  ) {
    return NotificationLogsTableData(
      id: data.id.present ? data.id.value : this.id,
      packageName: data.packageName.present
          ? data.packageName.value
          : this.packageName,
      title: data.title.present ? data.title.value : this.title,
      rawText: data.rawText.present ? data.rawText.value : this.rawText,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      fingerprint: data.fingerprint.present
          ? data.fingerprint.value
          : this.fingerprint,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotificationLogsTableData(')
          ..write('id: $id, ')
          ..write('packageName: $packageName, ')
          ..write('title: $title, ')
          ..write('rawText: $rawText, ')
          ..write('timestamp: $timestamp, ')
          ..write('fingerprint: $fingerprint')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, packageName, title, rawText, timestamp, fingerprint);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationLogsTableData &&
          other.id == this.id &&
          other.packageName == this.packageName &&
          other.title == this.title &&
          other.rawText == this.rawText &&
          other.timestamp == this.timestamp &&
          other.fingerprint == this.fingerprint);
}

class NotificationLogsTableCompanion
    extends UpdateCompanion<NotificationLogsTableData> {
  final Value<int> id;
  final Value<String> packageName;
  final Value<String> title;
  final Value<String> rawText;
  final Value<int> timestamp;
  final Value<String> fingerprint;
  const NotificationLogsTableCompanion({
    this.id = const Value.absent(),
    this.packageName = const Value.absent(),
    this.title = const Value.absent(),
    this.rawText = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.fingerprint = const Value.absent(),
  });
  NotificationLogsTableCompanion.insert({
    this.id = const Value.absent(),
    required String packageName,
    required String title,
    required String rawText,
    required int timestamp,
    required String fingerprint,
  }) : packageName = Value(packageName),
       title = Value(title),
       rawText = Value(rawText),
       timestamp = Value(timestamp),
       fingerprint = Value(fingerprint);
  static Insertable<NotificationLogsTableData> custom({
    Expression<int>? id,
    Expression<String>? packageName,
    Expression<String>? title,
    Expression<String>? rawText,
    Expression<int>? timestamp,
    Expression<String>? fingerprint,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (packageName != null) 'package_name': packageName,
      if (title != null) 'title': title,
      if (rawText != null) 'raw_text': rawText,
      if (timestamp != null) 'timestamp': timestamp,
      if (fingerprint != null) 'fingerprint': fingerprint,
    });
  }

  NotificationLogsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? packageName,
    Value<String>? title,
    Value<String>? rawText,
    Value<int>? timestamp,
    Value<String>? fingerprint,
  }) {
    return NotificationLogsTableCompanion(
      id: id ?? this.id,
      packageName: packageName ?? this.packageName,
      title: title ?? this.title,
      rawText: rawText ?? this.rawText,
      timestamp: timestamp ?? this.timestamp,
      fingerprint: fingerprint ?? this.fingerprint,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (packageName.present) {
      map['package_name'] = Variable<String>(packageName.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (rawText.present) {
      map['raw_text'] = Variable<String>(rawText.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<int>(timestamp.value);
    }
    if (fingerprint.present) {
      map['fingerprint'] = Variable<String>(fingerprint.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationLogsTableCompanion(')
          ..write('id: $id, ')
          ..write('packageName: $packageName, ')
          ..write('title: $title, ')
          ..write('rawText: $rawText, ')
          ..write('timestamp: $timestamp, ')
          ..write('fingerprint: $fingerprint')
          ..write(')'))
        .toString();
  }
}

class $PendingTransactionsTableTable extends PendingTransactionsTable
    with
        TableInfo<
          $PendingTransactionsTableTable,
          PendingTransactionsTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingTransactionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bankMeta = const VerificationMeta('bank');
  @override
  late final GeneratedColumn<String> bank = GeneratedColumn<String>(
    'bank',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawTextMeta = const VerificationMeta(
    'rawText',
  );
  @override
  late final GeneratedColumn<String> rawText = GeneratedColumn<String>(
    'raw_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<DateTime> time = GeneratedColumn<DateTime>(
    'time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pendingMeta = const VerificationMeta(
    'pending',
  );
  @override
  late final GeneratedColumn<bool> pending = GeneratedColumn<bool>(
    'pending',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pending" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _fromWalletMeta = const VerificationMeta(
    'fromWallet',
  );
  @override
  late final GeneratedColumn<String> fromWallet = GeneratedColumn<String>(
    'from_wallet',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toWalletMeta = const VerificationMeta(
    'toWallet',
  );
  @override
  late final GeneratedColumn<String> toWallet = GeneratedColumn<String>(
    'to_wallet',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bank,
    amount,
    category,
    type,
    rawText,
    time,
    pending,
    fromWallet,
    toWallet,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_transactions_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingTransactionsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('bank')) {
      context.handle(
        _bankMeta,
        bank.isAcceptableOrUnknown(data['bank']!, _bankMeta),
      );
    } else if (isInserting) {
      context.missing(_bankMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('raw_text')) {
      context.handle(
        _rawTextMeta,
        rawText.isAcceptableOrUnknown(data['raw_text']!, _rawTextMeta),
      );
    } else if (isInserting) {
      context.missing(_rawTextMeta);
    }
    if (data.containsKey('time')) {
      context.handle(
        _timeMeta,
        time.isAcceptableOrUnknown(data['time']!, _timeMeta),
      );
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    if (data.containsKey('pending')) {
      context.handle(
        _pendingMeta,
        pending.isAcceptableOrUnknown(data['pending']!, _pendingMeta),
      );
    }
    if (data.containsKey('from_wallet')) {
      context.handle(
        _fromWalletMeta,
        fromWallet.isAcceptableOrUnknown(data['from_wallet']!, _fromWalletMeta),
      );
    }
    if (data.containsKey('to_wallet')) {
      context.handle(
        _toWalletMeta,
        toWallet.isAcceptableOrUnknown(data['to_wallet']!, _toWalletMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingTransactionsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingTransactionsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      bank: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bank'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      rawText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_text'],
      )!,
      time: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}time'],
      )!,
      pending: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending'],
      )!,
      fromWallet: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_wallet'],
      ),
      toWallet: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_wallet'],
      ),
    );
  }

  @override
  $PendingTransactionsTableTable createAlias(String alias) {
    return $PendingTransactionsTableTable(attachedDatabase, alias);
  }
}

class PendingTransactionsTableData extends DataClass
    implements Insertable<PendingTransactionsTableData> {
  final String id;
  final String bank;
  final int amount;
  final String category;
  final String type;
  final String rawText;
  final DateTime time;
  final bool pending;
  final String? fromWallet;
  final String? toWallet;
  const PendingTransactionsTableData({
    required this.id,
    required this.bank,
    required this.amount,
    required this.category,
    required this.type,
    required this.rawText,
    required this.time,
    required this.pending,
    this.fromWallet,
    this.toWallet,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['bank'] = Variable<String>(bank);
    map['amount'] = Variable<int>(amount);
    map['category'] = Variable<String>(category);
    map['type'] = Variable<String>(type);
    map['raw_text'] = Variable<String>(rawText);
    map['time'] = Variable<DateTime>(time);
    map['pending'] = Variable<bool>(pending);
    if (!nullToAbsent || fromWallet != null) {
      map['from_wallet'] = Variable<String>(fromWallet);
    }
    if (!nullToAbsent || toWallet != null) {
      map['to_wallet'] = Variable<String>(toWallet);
    }
    return map;
  }

  PendingTransactionsTableCompanion toCompanion(bool nullToAbsent) {
    return PendingTransactionsTableCompanion(
      id: Value(id),
      bank: Value(bank),
      amount: Value(amount),
      category: Value(category),
      type: Value(type),
      rawText: Value(rawText),
      time: Value(time),
      pending: Value(pending),
      fromWallet: fromWallet == null && nullToAbsent
          ? const Value.absent()
          : Value(fromWallet),
      toWallet: toWallet == null && nullToAbsent
          ? const Value.absent()
          : Value(toWallet),
    );
  }

  factory PendingTransactionsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingTransactionsTableData(
      id: serializer.fromJson<String>(json['id']),
      bank: serializer.fromJson<String>(json['bank']),
      amount: serializer.fromJson<int>(json['amount']),
      category: serializer.fromJson<String>(json['category']),
      type: serializer.fromJson<String>(json['type']),
      rawText: serializer.fromJson<String>(json['rawText']),
      time: serializer.fromJson<DateTime>(json['time']),
      pending: serializer.fromJson<bool>(json['pending']),
      fromWallet: serializer.fromJson<String?>(json['fromWallet']),
      toWallet: serializer.fromJson<String?>(json['toWallet']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bank': serializer.toJson<String>(bank),
      'amount': serializer.toJson<int>(amount),
      'category': serializer.toJson<String>(category),
      'type': serializer.toJson<String>(type),
      'rawText': serializer.toJson<String>(rawText),
      'time': serializer.toJson<DateTime>(time),
      'pending': serializer.toJson<bool>(pending),
      'fromWallet': serializer.toJson<String?>(fromWallet),
      'toWallet': serializer.toJson<String?>(toWallet),
    };
  }

  PendingTransactionsTableData copyWith({
    String? id,
    String? bank,
    int? amount,
    String? category,
    String? type,
    String? rawText,
    DateTime? time,
    bool? pending,
    Value<String?> fromWallet = const Value.absent(),
    Value<String?> toWallet = const Value.absent(),
  }) => PendingTransactionsTableData(
    id: id ?? this.id,
    bank: bank ?? this.bank,
    amount: amount ?? this.amount,
    category: category ?? this.category,
    type: type ?? this.type,
    rawText: rawText ?? this.rawText,
    time: time ?? this.time,
    pending: pending ?? this.pending,
    fromWallet: fromWallet.present ? fromWallet.value : this.fromWallet,
    toWallet: toWallet.present ? toWallet.value : this.toWallet,
  );
  PendingTransactionsTableData copyWithCompanion(
    PendingTransactionsTableCompanion data,
  ) {
    return PendingTransactionsTableData(
      id: data.id.present ? data.id.value : this.id,
      bank: data.bank.present ? data.bank.value : this.bank,
      amount: data.amount.present ? data.amount.value : this.amount,
      category: data.category.present ? data.category.value : this.category,
      type: data.type.present ? data.type.value : this.type,
      rawText: data.rawText.present ? data.rawText.value : this.rawText,
      time: data.time.present ? data.time.value : this.time,
      pending: data.pending.present ? data.pending.value : this.pending,
      fromWallet: data.fromWallet.present
          ? data.fromWallet.value
          : this.fromWallet,
      toWallet: data.toWallet.present ? data.toWallet.value : this.toWallet,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingTransactionsTableData(')
          ..write('id: $id, ')
          ..write('bank: $bank, ')
          ..write('amount: $amount, ')
          ..write('category: $category, ')
          ..write('type: $type, ')
          ..write('rawText: $rawText, ')
          ..write('time: $time, ')
          ..write('pending: $pending, ')
          ..write('fromWallet: $fromWallet, ')
          ..write('toWallet: $toWallet')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bank,
    amount,
    category,
    type,
    rawText,
    time,
    pending,
    fromWallet,
    toWallet,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingTransactionsTableData &&
          other.id == this.id &&
          other.bank == this.bank &&
          other.amount == this.amount &&
          other.category == this.category &&
          other.type == this.type &&
          other.rawText == this.rawText &&
          other.time == this.time &&
          other.pending == this.pending &&
          other.fromWallet == this.fromWallet &&
          other.toWallet == this.toWallet);
}

class PendingTransactionsTableCompanion
    extends UpdateCompanion<PendingTransactionsTableData> {
  final Value<String> id;
  final Value<String> bank;
  final Value<int> amount;
  final Value<String> category;
  final Value<String> type;
  final Value<String> rawText;
  final Value<DateTime> time;
  final Value<bool> pending;
  final Value<String?> fromWallet;
  final Value<String?> toWallet;
  final Value<int> rowid;
  const PendingTransactionsTableCompanion({
    this.id = const Value.absent(),
    this.bank = const Value.absent(),
    this.amount = const Value.absent(),
    this.category = const Value.absent(),
    this.type = const Value.absent(),
    this.rawText = const Value.absent(),
    this.time = const Value.absent(),
    this.pending = const Value.absent(),
    this.fromWallet = const Value.absent(),
    this.toWallet = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PendingTransactionsTableCompanion.insert({
    required String id,
    required String bank,
    required int amount,
    required String category,
    required String type,
    required String rawText,
    required DateTime time,
    this.pending = const Value.absent(),
    this.fromWallet = const Value.absent(),
    this.toWallet = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       bank = Value(bank),
       amount = Value(amount),
       category = Value(category),
       type = Value(type),
       rawText = Value(rawText),
       time = Value(time);
  static Insertable<PendingTransactionsTableData> custom({
    Expression<String>? id,
    Expression<String>? bank,
    Expression<int>? amount,
    Expression<String>? category,
    Expression<String>? type,
    Expression<String>? rawText,
    Expression<DateTime>? time,
    Expression<bool>? pending,
    Expression<String>? fromWallet,
    Expression<String>? toWallet,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bank != null) 'bank': bank,
      if (amount != null) 'amount': amount,
      if (category != null) 'category': category,
      if (type != null) 'type': type,
      if (rawText != null) 'raw_text': rawText,
      if (time != null) 'time': time,
      if (pending != null) 'pending': pending,
      if (fromWallet != null) 'from_wallet': fromWallet,
      if (toWallet != null) 'to_wallet': toWallet,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PendingTransactionsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? bank,
    Value<int>? amount,
    Value<String>? category,
    Value<String>? type,
    Value<String>? rawText,
    Value<DateTime>? time,
    Value<bool>? pending,
    Value<String?>? fromWallet,
    Value<String?>? toWallet,
    Value<int>? rowid,
  }) {
    return PendingTransactionsTableCompanion(
      id: id ?? this.id,
      bank: bank ?? this.bank,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      type: type ?? this.type,
      rawText: rawText ?? this.rawText,
      time: time ?? this.time,
      pending: pending ?? this.pending,
      fromWallet: fromWallet ?? this.fromWallet,
      toWallet: toWallet ?? this.toWallet,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bank.present) {
      map['bank'] = Variable<String>(bank.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (rawText.present) {
      map['raw_text'] = Variable<String>(rawText.value);
    }
    if (time.present) {
      map['time'] = Variable<DateTime>(time.value);
    }
    if (pending.present) {
      map['pending'] = Variable<bool>(pending.value);
    }
    if (fromWallet.present) {
      map['from_wallet'] = Variable<String>(fromWallet.value);
    }
    if (toWallet.present) {
      map['to_wallet'] = Variable<String>(toWallet.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingTransactionsTableCompanion(')
          ..write('id: $id, ')
          ..write('bank: $bank, ')
          ..write('amount: $amount, ')
          ..write('category: $category, ')
          ..write('type: $type, ')
          ..write('rawText: $rawText, ')
          ..write('time: $time, ')
          ..write('pending: $pending, ')
          ..write('fromWallet: $fromWallet, ')
          ..write('toWallet: $toWallet, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WalletTableTable extends WalletTable
    with TableInfo<$WalletTableTable, WalletTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WalletTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bankMeta = const VerificationMeta('bank');
  @override
  late final GeneratedColumn<String> bank = GeneratedColumn<String>(
    'bank',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _balanceMeta = const VerificationMeta(
    'balance',
  );
  @override
  late final GeneratedColumn<int> balance = GeneratedColumn<int>(
    'balance',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, bank, balance, active];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wallet_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<WalletTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('bank')) {
      context.handle(
        _bankMeta,
        bank.isAcceptableOrUnknown(data['bank']!, _bankMeta),
      );
    } else if (isInserting) {
      context.missing(_bankMeta);
    }
    if (data.containsKey('balance')) {
      context.handle(
        _balanceMeta,
        balance.isAcceptableOrUnknown(data['balance']!, _balanceMeta),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WalletTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WalletTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      bank: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bank'],
      )!,
      balance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}balance'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
    );
  }

  @override
  $WalletTableTable createAlias(String alias) {
    return $WalletTableTable(attachedDatabase, alias);
  }
}

class WalletTableData extends DataClass implements Insertable<WalletTableData> {
  final String id;

  /// Nama wallet dari user
  final String name;

  /// Bank / Ewallet
  final String bank;

  /// Saldo sekarang
  final int balance;

  /// Masih digunakan
  final bool active;
  const WalletTableData({
    required this.id,
    required this.name,
    required this.bank,
    required this.balance,
    required this.active,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['bank'] = Variable<String>(bank);
    map['balance'] = Variable<int>(balance);
    map['active'] = Variable<bool>(active);
    return map;
  }

  WalletTableCompanion toCompanion(bool nullToAbsent) {
    return WalletTableCompanion(
      id: Value(id),
      name: Value(name),
      bank: Value(bank),
      balance: Value(balance),
      active: Value(active),
    );
  }

  factory WalletTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WalletTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      bank: serializer.fromJson<String>(json['bank']),
      balance: serializer.fromJson<int>(json['balance']),
      active: serializer.fromJson<bool>(json['active']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'bank': serializer.toJson<String>(bank),
      'balance': serializer.toJson<int>(balance),
      'active': serializer.toJson<bool>(active),
    };
  }

  WalletTableData copyWith({
    String? id,
    String? name,
    String? bank,
    int? balance,
    bool? active,
  }) => WalletTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    bank: bank ?? this.bank,
    balance: balance ?? this.balance,
    active: active ?? this.active,
  );
  WalletTableData copyWithCompanion(WalletTableCompanion data) {
    return WalletTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      bank: data.bank.present ? data.bank.value : this.bank,
      balance: data.balance.present ? data.balance.value : this.balance,
      active: data.active.present ? data.active.value : this.active,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WalletTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('bank: $bank, ')
          ..write('balance: $balance, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, bank, balance, active);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WalletTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.bank == this.bank &&
          other.balance == this.balance &&
          other.active == this.active);
}

class WalletTableCompanion extends UpdateCompanion<WalletTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> bank;
  final Value<int> balance;
  final Value<bool> active;
  final Value<int> rowid;
  const WalletTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.bank = const Value.absent(),
    this.balance = const Value.absent(),
    this.active = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WalletTableCompanion.insert({
    required String id,
    required String name,
    required String bank,
    this.balance = const Value.absent(),
    this.active = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       bank = Value(bank);
  static Insertable<WalletTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? bank,
    Expression<int>? balance,
    Expression<bool>? active,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (bank != null) 'bank': bank,
      if (balance != null) 'balance': balance,
      if (active != null) 'active': active,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WalletTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? bank,
    Value<int>? balance,
    Value<bool>? active,
    Value<int>? rowid,
  }) {
    return WalletTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      bank: bank ?? this.bank,
      balance: balance ?? this.balance,
      active: active ?? this.active,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (bank.present) {
      map['bank'] = Variable<String>(bank.value);
    }
    if (balance.present) {
      map['balance'] = Variable<int>(balance.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WalletTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('bank: $bank, ')
          ..write('balance: $balance, ')
          ..write('active: $active, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WalletBalanceAdjustmentTableTable extends WalletBalanceAdjustmentTable
    with
        TableInfo<
          $WalletBalanceAdjustmentTableTable,
          WalletBalanceAdjustmentTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WalletBalanceAdjustmentTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _walletIdMeta = const VerificationMeta(
    'walletId',
  );
  @override
  late final GeneratedColumn<String> walletId = GeneratedColumn<String>(
    'wallet_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _walletNameMeta = const VerificationMeta(
    'walletName',
  );
  @override
  late final GeneratedColumn<String> walletName = GeneratedColumn<String>(
    'wallet_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _previousBalanceMeta = const VerificationMeta(
    'previousBalance',
  );
  @override
  late final GeneratedColumn<int> previousBalance = GeneratedColumn<int>(
    'previous_balance',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _newBalanceMeta = const VerificationMeta(
    'newBalance',
  );
  @override
  late final GeneratedColumn<int> newBalance = GeneratedColumn<int>(
    'new_balance',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    walletId,
    walletName,
    previousBalance,
    newBalance,
    note,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wallet_balance_adjustment_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<WalletBalanceAdjustmentTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('wallet_id')) {
      context.handle(
        _walletIdMeta,
        walletId.isAcceptableOrUnknown(data['wallet_id']!, _walletIdMeta),
      );
    } else if (isInserting) {
      context.missing(_walletIdMeta);
    }
    if (data.containsKey('wallet_name')) {
      context.handle(
        _walletNameMeta,
        walletName.isAcceptableOrUnknown(data['wallet_name']!, _walletNameMeta),
      );
    } else if (isInserting) {
      context.missing(_walletNameMeta);
    }
    if (data.containsKey('previous_balance')) {
      context.handle(
        _previousBalanceMeta,
        previousBalance.isAcceptableOrUnknown(
          data['previous_balance']!,
          _previousBalanceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_previousBalanceMeta);
    }
    if (data.containsKey('new_balance')) {
      context.handle(
        _newBalanceMeta,
        newBalance.isAcceptableOrUnknown(data['new_balance']!, _newBalanceMeta),
      );
    } else if (isInserting) {
      context.missing(_newBalanceMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WalletBalanceAdjustmentTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WalletBalanceAdjustmentTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      walletId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wallet_id'],
      )!,
      walletName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wallet_name'],
      )!,
      previousBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}previous_balance'],
      )!,
      newBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}new_balance'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $WalletBalanceAdjustmentTableTable createAlias(String alias) {
    return $WalletBalanceAdjustmentTableTable(attachedDatabase, alias);
  }
}

class WalletBalanceAdjustmentTableData extends DataClass
    implements Insertable<WalletBalanceAdjustmentTableData> {
  final String id;
  final String walletId;
  final String walletName;
  final int previousBalance;
  final int newBalance;
  final String note;
  final DateTime createdAt;
  const WalletBalanceAdjustmentTableData({
    required this.id,
    required this.walletId,
    required this.walletName,
    required this.previousBalance,
    required this.newBalance,
    required this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['wallet_id'] = Variable<String>(walletId);
    map['wallet_name'] = Variable<String>(walletName);
    map['previous_balance'] = Variable<int>(previousBalance);
    map['new_balance'] = Variable<int>(newBalance);
    map['note'] = Variable<String>(note);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  WalletBalanceAdjustmentTableCompanion toCompanion(bool nullToAbsent) {
    return WalletBalanceAdjustmentTableCompanion(
      id: Value(id),
      walletId: Value(walletId),
      walletName: Value(walletName),
      previousBalance: Value(previousBalance),
      newBalance: Value(newBalance),
      note: Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory WalletBalanceAdjustmentTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WalletBalanceAdjustmentTableData(
      id: serializer.fromJson<String>(json['id']),
      walletId: serializer.fromJson<String>(json['walletId']),
      walletName: serializer.fromJson<String>(json['walletName']),
      previousBalance: serializer.fromJson<int>(json['previousBalance']),
      newBalance: serializer.fromJson<int>(json['newBalance']),
      note: serializer.fromJson<String>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'walletId': serializer.toJson<String>(walletId),
      'walletName': serializer.toJson<String>(walletName),
      'previousBalance': serializer.toJson<int>(previousBalance),
      'newBalance': serializer.toJson<int>(newBalance),
      'note': serializer.toJson<String>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  WalletBalanceAdjustmentTableData copyWith({
    String? id,
    String? walletId,
    String? walletName,
    int? previousBalance,
    int? newBalance,
    String? note,
    DateTime? createdAt,
  }) => WalletBalanceAdjustmentTableData(
    id: id ?? this.id,
    walletId: walletId ?? this.walletId,
    walletName: walletName ?? this.walletName,
    previousBalance: previousBalance ?? this.previousBalance,
    newBalance: newBalance ?? this.newBalance,
    note: note ?? this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  WalletBalanceAdjustmentTableData copyWithCompanion(
    WalletBalanceAdjustmentTableCompanion data,
  ) {
    return WalletBalanceAdjustmentTableData(
      id: data.id.present ? data.id.value : this.id,
      walletId: data.walletId.present ? data.walletId.value : this.walletId,
      walletName: data.walletName.present
          ? data.walletName.value
          : this.walletName,
      previousBalance: data.previousBalance.present
          ? data.previousBalance.value
          : this.previousBalance,
      newBalance: data.newBalance.present
          ? data.newBalance.value
          : this.newBalance,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WalletBalanceAdjustmentTableData(')
          ..write('id: $id, ')
          ..write('walletId: $walletId, ')
          ..write('walletName: $walletName, ')
          ..write('previousBalance: $previousBalance, ')
          ..write('newBalance: $newBalance, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    walletId,
    walletName,
    previousBalance,
    newBalance,
    note,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WalletBalanceAdjustmentTableData &&
          other.id == this.id &&
          other.walletId == this.walletId &&
          other.walletName == this.walletName &&
          other.previousBalance == this.previousBalance &&
          other.newBalance == this.newBalance &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class WalletBalanceAdjustmentTableCompanion
    extends UpdateCompanion<WalletBalanceAdjustmentTableData> {
  final Value<String> id;
  final Value<String> walletId;
  final Value<String> walletName;
  final Value<int> previousBalance;
  final Value<int> newBalance;
  final Value<String> note;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const WalletBalanceAdjustmentTableCompanion({
    this.id = const Value.absent(),
    this.walletId = const Value.absent(),
    this.walletName = const Value.absent(),
    this.previousBalance = const Value.absent(),
    this.newBalance = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WalletBalanceAdjustmentTableCompanion.insert({
    required String id,
    required String walletId,
    required String walletName,
    required int previousBalance,
    required int newBalance,
    this.note = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       walletId = Value(walletId),
       walletName = Value(walletName),
       previousBalance = Value(previousBalance),
       newBalance = Value(newBalance),
       createdAt = Value(createdAt);
  static Insertable<WalletBalanceAdjustmentTableData> custom({
    Expression<String>? id,
    Expression<String>? walletId,
    Expression<String>? walletName,
    Expression<int>? previousBalance,
    Expression<int>? newBalance,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (walletId != null) 'wallet_id': walletId,
      if (walletName != null) 'wallet_name': walletName,
      if (previousBalance != null) 'previous_balance': previousBalance,
      if (newBalance != null) 'new_balance': newBalance,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WalletBalanceAdjustmentTableCompanion copyWith({
    Value<String>? id,
    Value<String>? walletId,
    Value<String>? walletName,
    Value<int>? previousBalance,
    Value<int>? newBalance,
    Value<String>? note,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return WalletBalanceAdjustmentTableCompanion(
      id: id ?? this.id,
      walletId: walletId ?? this.walletId,
      walletName: walletName ?? this.walletName,
      previousBalance: previousBalance ?? this.previousBalance,
      newBalance: newBalance ?? this.newBalance,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (walletId.present) {
      map['wallet_id'] = Variable<String>(walletId.value);
    }
    if (walletName.present) {
      map['wallet_name'] = Variable<String>(walletName.value);
    }
    if (previousBalance.present) {
      map['previous_balance'] = Variable<int>(previousBalance.value);
    }
    if (newBalance.present) {
      map['new_balance'] = Variable<int>(newBalance.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WalletBalanceAdjustmentTableCompanion(')
          ..write('id: $id, ')
          ..write('walletId: $walletId, ')
          ..write('walletName: $walletName, ')
          ..write('previousBalance: $previousBalance, ')
          ..write('newBalance: $newBalance, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MonthlyBudgetsTableTable extends MonthlyBudgetsTable
    with TableInfo<$MonthlyBudgetsTableTable, MonthlyBudgetsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MonthlyBudgetsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthlyLimitMeta = const VerificationMeta(
    'monthlyLimit',
  );
  @override
  late final GeneratedColumn<int> monthlyLimit = GeneratedColumn<int>(
    'monthly_limit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [category, monthlyLimit, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'monthly_budgets_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<MonthlyBudgetsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('monthly_limit')) {
      context.handle(
        _monthlyLimitMeta,
        monthlyLimit.isAcceptableOrUnknown(
          data['monthly_limit']!,
          _monthlyLimitMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_monthlyLimitMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {category};
  @override
  MonthlyBudgetsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MonthlyBudgetsTableData(
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      monthlyLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monthly_limit'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MonthlyBudgetsTableTable createAlias(String alias) {
    return $MonthlyBudgetsTableTable(attachedDatabase, alias);
  }
}

class MonthlyBudgetsTableData extends DataClass
    implements Insertable<MonthlyBudgetsTableData> {
  final String category;
  final int monthlyLimit;
  final DateTime updatedAt;
  const MonthlyBudgetsTableData({
    required this.category,
    required this.monthlyLimit,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['category'] = Variable<String>(category);
    map['monthly_limit'] = Variable<int>(monthlyLimit);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MonthlyBudgetsTableCompanion toCompanion(bool nullToAbsent) {
    return MonthlyBudgetsTableCompanion(
      category: Value(category),
      monthlyLimit: Value(monthlyLimit),
      updatedAt: Value(updatedAt),
    );
  }

  factory MonthlyBudgetsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MonthlyBudgetsTableData(
      category: serializer.fromJson<String>(json['category']),
      monthlyLimit: serializer.fromJson<int>(json['monthlyLimit']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'category': serializer.toJson<String>(category),
      'monthlyLimit': serializer.toJson<int>(monthlyLimit),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MonthlyBudgetsTableData copyWith({
    String? category,
    int? monthlyLimit,
    DateTime? updatedAt,
  }) => MonthlyBudgetsTableData(
    category: category ?? this.category,
    monthlyLimit: monthlyLimit ?? this.monthlyLimit,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MonthlyBudgetsTableData copyWithCompanion(MonthlyBudgetsTableCompanion data) {
    return MonthlyBudgetsTableData(
      category: data.category.present ? data.category.value : this.category,
      monthlyLimit: data.monthlyLimit.present
          ? data.monthlyLimit.value
          : this.monthlyLimit,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MonthlyBudgetsTableData(')
          ..write('category: $category, ')
          ..write('monthlyLimit: $monthlyLimit, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(category, monthlyLimit, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MonthlyBudgetsTableData &&
          other.category == this.category &&
          other.monthlyLimit == this.monthlyLimit &&
          other.updatedAt == this.updatedAt);
}

class MonthlyBudgetsTableCompanion
    extends UpdateCompanion<MonthlyBudgetsTableData> {
  final Value<String> category;
  final Value<int> monthlyLimit;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MonthlyBudgetsTableCompanion({
    this.category = const Value.absent(),
    this.monthlyLimit = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MonthlyBudgetsTableCompanion.insert({
    required String category,
    required int monthlyLimit,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : category = Value(category),
       monthlyLimit = Value(monthlyLimit),
       updatedAt = Value(updatedAt);
  static Insertable<MonthlyBudgetsTableData> custom({
    Expression<String>? category,
    Expression<int>? monthlyLimit,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (category != null) 'category': category,
      if (monthlyLimit != null) 'monthly_limit': monthlyLimit,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MonthlyBudgetsTableCompanion copyWith({
    Value<String>? category,
    Value<int>? monthlyLimit,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return MonthlyBudgetsTableCompanion(
      category: category ?? this.category,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (monthlyLimit.present) {
      map['monthly_limit'] = Variable<int>(monthlyLimit.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MonthlyBudgetsTableCompanion(')
          ..write('category: $category, ')
          ..write('monthlyLimit: $monthlyLimit, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MerchantCategoryRulesTableTable extends MerchantCategoryRulesTable
    with
        TableInfo<
          $MerchantCategoryRulesTableTable,
          MerchantCategoryRulesTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MerchantCategoryRulesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _merchantKeyMeta = const VerificationMeta(
    'merchantKey',
  );
  @override
  late final GeneratedColumn<String> merchantKey = GeneratedColumn<String>(
    'merchant_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _merchantNameMeta = const VerificationMeta(
    'merchantName',
  );
  @override
  late final GeneratedColumn<String> merchantName = GeneratedColumn<String>(
    'merchant_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    merchantKey,
    merchantName,
    category,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'merchant_category_rules_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<MerchantCategoryRulesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('merchant_key')) {
      context.handle(
        _merchantKeyMeta,
        merchantKey.isAcceptableOrUnknown(
          data['merchant_key']!,
          _merchantKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_merchantKeyMeta);
    }
    if (data.containsKey('merchant_name')) {
      context.handle(
        _merchantNameMeta,
        merchantName.isAcceptableOrUnknown(
          data['merchant_name']!,
          _merchantNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_merchantNameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {merchantKey};
  @override
  MerchantCategoryRulesTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MerchantCategoryRulesTableData(
      merchantKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}merchant_key'],
      )!,
      merchantName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}merchant_name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MerchantCategoryRulesTableTable createAlias(String alias) {
    return $MerchantCategoryRulesTableTable(attachedDatabase, alias);
  }
}

class MerchantCategoryRulesTableData extends DataClass
    implements Insertable<MerchantCategoryRulesTableData> {
  final String merchantKey;
  final String merchantName;
  final String category;
  final DateTime updatedAt;
  const MerchantCategoryRulesTableData({
    required this.merchantKey,
    required this.merchantName,
    required this.category,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['merchant_key'] = Variable<String>(merchantKey);
    map['merchant_name'] = Variable<String>(merchantName);
    map['category'] = Variable<String>(category);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MerchantCategoryRulesTableCompanion toCompanion(bool nullToAbsent) {
    return MerchantCategoryRulesTableCompanion(
      merchantKey: Value(merchantKey),
      merchantName: Value(merchantName),
      category: Value(category),
      updatedAt: Value(updatedAt),
    );
  }

  factory MerchantCategoryRulesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MerchantCategoryRulesTableData(
      merchantKey: serializer.fromJson<String>(json['merchantKey']),
      merchantName: serializer.fromJson<String>(json['merchantName']),
      category: serializer.fromJson<String>(json['category']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'merchantKey': serializer.toJson<String>(merchantKey),
      'merchantName': serializer.toJson<String>(merchantName),
      'category': serializer.toJson<String>(category),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MerchantCategoryRulesTableData copyWith({
    String? merchantKey,
    String? merchantName,
    String? category,
    DateTime? updatedAt,
  }) => MerchantCategoryRulesTableData(
    merchantKey: merchantKey ?? this.merchantKey,
    merchantName: merchantName ?? this.merchantName,
    category: category ?? this.category,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MerchantCategoryRulesTableData copyWithCompanion(
    MerchantCategoryRulesTableCompanion data,
  ) {
    return MerchantCategoryRulesTableData(
      merchantKey: data.merchantKey.present
          ? data.merchantKey.value
          : this.merchantKey,
      merchantName: data.merchantName.present
          ? data.merchantName.value
          : this.merchantName,
      category: data.category.present ? data.category.value : this.category,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MerchantCategoryRulesTableData(')
          ..write('merchantKey: $merchantKey, ')
          ..write('merchantName: $merchantName, ')
          ..write('category: $category, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(merchantKey, merchantName, category, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MerchantCategoryRulesTableData &&
          other.merchantKey == this.merchantKey &&
          other.merchantName == this.merchantName &&
          other.category == this.category &&
          other.updatedAt == this.updatedAt);
}

class MerchantCategoryRulesTableCompanion
    extends UpdateCompanion<MerchantCategoryRulesTableData> {
  final Value<String> merchantKey;
  final Value<String> merchantName;
  final Value<String> category;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MerchantCategoryRulesTableCompanion({
    this.merchantKey = const Value.absent(),
    this.merchantName = const Value.absent(),
    this.category = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MerchantCategoryRulesTableCompanion.insert({
    required String merchantKey,
    required String merchantName,
    required String category,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : merchantKey = Value(merchantKey),
       merchantName = Value(merchantName),
       category = Value(category),
       updatedAt = Value(updatedAt);
  static Insertable<MerchantCategoryRulesTableData> custom({
    Expression<String>? merchantKey,
    Expression<String>? merchantName,
    Expression<String>? category,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (merchantKey != null) 'merchant_key': merchantKey,
      if (merchantName != null) 'merchant_name': merchantName,
      if (category != null) 'category': category,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MerchantCategoryRulesTableCompanion copyWith({
    Value<String>? merchantKey,
    Value<String>? merchantName,
    Value<String>? category,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return MerchantCategoryRulesTableCompanion(
      merchantKey: merchantKey ?? this.merchantKey,
      merchantName: merchantName ?? this.merchantName,
      category: category ?? this.category,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (merchantKey.present) {
      map['merchant_key'] = Variable<String>(merchantKey.value);
    }
    if (merchantName.present) {
      map['merchant_name'] = Variable<String>(merchantName.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MerchantCategoryRulesTableCompanion(')
          ..write('merchantKey: $merchantKey, ')
          ..write('merchantName: $merchantName, ')
          ..write('category: $category, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TransactionsTableTable transactionsTable =
      $TransactionsTableTable(this);
  late final $NotificationLogsTableTable notificationLogsTable =
      $NotificationLogsTableTable(this);
  late final $PendingTransactionsTableTable pendingTransactionsTable =
      $PendingTransactionsTableTable(this);
  late final $WalletTableTable walletTable = $WalletTableTable(this);
  late final $WalletBalanceAdjustmentTableTable walletBalanceAdjustmentTable =
      $WalletBalanceAdjustmentTableTable(this);
  late final $MonthlyBudgetsTableTable monthlyBudgetsTable =
      $MonthlyBudgetsTableTable(this);
  late final $MerchantCategoryRulesTableTable merchantCategoryRulesTable =
      $MerchantCategoryRulesTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    transactionsTable,
    notificationLogsTable,
    pendingTransactionsTable,
    walletTable,
    walletBalanceAdjustmentTable,
    monthlyBudgetsTable,
    merchantCategoryRulesTable,
  ];
}

typedef $$TransactionsTableTableCreateCompanionBuilder =
    TransactionsTableCompanion Function({
      required String id,
      required String bank,
      Value<String?> fromWallet,
      Value<String?> toWallet,
      required int amount,
      required String type,
      required String category,
      required String rawText,
      required DateTime time,
      Value<int> rowid,
    });
typedef $$TransactionsTableTableUpdateCompanionBuilder =
    TransactionsTableCompanion Function({
      Value<String> id,
      Value<String> bank,
      Value<String?> fromWallet,
      Value<String?> toWallet,
      Value<int> amount,
      Value<String> type,
      Value<String> category,
      Value<String> rawText,
      Value<DateTime> time,
      Value<int> rowid,
    });

class $$TransactionsTableTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTableTable> {
  $$TransactionsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bank => $composableBuilder(
    column: $table.bank,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fromWallet => $composableBuilder(
    column: $table.fromWallet,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toWallet => $composableBuilder(
    column: $table.toWallet,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawText => $composableBuilder(
    column: $table.rawText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransactionsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTableTable> {
  $$TransactionsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bank => $composableBuilder(
    column: $table.bank,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromWallet => $composableBuilder(
    column: $table.fromWallet,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toWallet => $composableBuilder(
    column: $table.toWallet,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawText => $composableBuilder(
    column: $table.rawText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTableTable> {
  $$TransactionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bank =>
      $composableBuilder(column: $table.bank, builder: (column) => column);

  GeneratedColumn<String> get fromWallet => $composableBuilder(
    column: $table.fromWallet,
    builder: (column) => column,
  );

  GeneratedColumn<String> get toWallet =>
      $composableBuilder(column: $table.toWallet, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get rawText =>
      $composableBuilder(column: $table.rawText, builder: (column) => column);

  GeneratedColumn<DateTime> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);
}

class $$TransactionsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTableTable,
          TransactionsTableData,
          $$TransactionsTableTableFilterComposer,
          $$TransactionsTableTableOrderingComposer,
          $$TransactionsTableTableAnnotationComposer,
          $$TransactionsTableTableCreateCompanionBuilder,
          $$TransactionsTableTableUpdateCompanionBuilder,
          (
            TransactionsTableData,
            BaseReferences<
              _$AppDatabase,
              $TransactionsTableTable,
              TransactionsTableData
            >,
          ),
          TransactionsTableData,
          PrefetchHooks Function()
        > {
  $$TransactionsTableTableTableManager(
    _$AppDatabase db,
    $TransactionsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> bank = const Value.absent(),
                Value<String?> fromWallet = const Value.absent(),
                Value<String?> toWallet = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> rawText = const Value.absent(),
                Value<DateTime> time = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsTableCompanion(
                id: id,
                bank: bank,
                fromWallet: fromWallet,
                toWallet: toWallet,
                amount: amount,
                type: type,
                category: category,
                rawText: rawText,
                time: time,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String bank,
                Value<String?> fromWallet = const Value.absent(),
                Value<String?> toWallet = const Value.absent(),
                required int amount,
                required String type,
                required String category,
                required String rawText,
                required DateTime time,
                Value<int> rowid = const Value.absent(),
              }) => TransactionsTableCompanion.insert(
                id: id,
                bank: bank,
                fromWallet: fromWallet,
                toWallet: toWallet,
                amount: amount,
                type: type,
                category: category,
                rawText: rawText,
                time: time,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTableTable,
      TransactionsTableData,
      $$TransactionsTableTableFilterComposer,
      $$TransactionsTableTableOrderingComposer,
      $$TransactionsTableTableAnnotationComposer,
      $$TransactionsTableTableCreateCompanionBuilder,
      $$TransactionsTableTableUpdateCompanionBuilder,
      (
        TransactionsTableData,
        BaseReferences<
          _$AppDatabase,
          $TransactionsTableTable,
          TransactionsTableData
        >,
      ),
      TransactionsTableData,
      PrefetchHooks Function()
    >;
typedef $$NotificationLogsTableTableCreateCompanionBuilder =
    NotificationLogsTableCompanion Function({
      Value<int> id,
      required String packageName,
      required String title,
      required String rawText,
      required int timestamp,
      required String fingerprint,
    });
typedef $$NotificationLogsTableTableUpdateCompanionBuilder =
    NotificationLogsTableCompanion Function({
      Value<int> id,
      Value<String> packageName,
      Value<String> title,
      Value<String> rawText,
      Value<int> timestamp,
      Value<String> fingerprint,
    });

class $$NotificationLogsTableTableFilterComposer
    extends Composer<_$AppDatabase, $NotificationLogsTableTable> {
  $$NotificationLogsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawText => $composableBuilder(
    column: $table.rawText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotificationLogsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationLogsTableTable> {
  $$NotificationLogsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawText => $composableBuilder(
    column: $table.rawText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotificationLogsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationLogsTableTable> {
  $$NotificationLogsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get rawText =>
      $composableBuilder(column: $table.rawText, builder: (column) => column);

  GeneratedColumn<int> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => column,
  );
}

class $$NotificationLogsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotificationLogsTableTable,
          NotificationLogsTableData,
          $$NotificationLogsTableTableFilterComposer,
          $$NotificationLogsTableTableOrderingComposer,
          $$NotificationLogsTableTableAnnotationComposer,
          $$NotificationLogsTableTableCreateCompanionBuilder,
          $$NotificationLogsTableTableUpdateCompanionBuilder,
          (
            NotificationLogsTableData,
            BaseReferences<
              _$AppDatabase,
              $NotificationLogsTableTable,
              NotificationLogsTableData
            >,
          ),
          NotificationLogsTableData,
          PrefetchHooks Function()
        > {
  $$NotificationLogsTableTableTableManager(
    _$AppDatabase db,
    $NotificationLogsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationLogsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$NotificationLogsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$NotificationLogsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> packageName = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> rawText = const Value.absent(),
                Value<int> timestamp = const Value.absent(),
                Value<String> fingerprint = const Value.absent(),
              }) => NotificationLogsTableCompanion(
                id: id,
                packageName: packageName,
                title: title,
                rawText: rawText,
                timestamp: timestamp,
                fingerprint: fingerprint,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String packageName,
                required String title,
                required String rawText,
                required int timestamp,
                required String fingerprint,
              }) => NotificationLogsTableCompanion.insert(
                id: id,
                packageName: packageName,
                title: title,
                rawText: rawText,
                timestamp: timestamp,
                fingerprint: fingerprint,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotificationLogsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotificationLogsTableTable,
      NotificationLogsTableData,
      $$NotificationLogsTableTableFilterComposer,
      $$NotificationLogsTableTableOrderingComposer,
      $$NotificationLogsTableTableAnnotationComposer,
      $$NotificationLogsTableTableCreateCompanionBuilder,
      $$NotificationLogsTableTableUpdateCompanionBuilder,
      (
        NotificationLogsTableData,
        BaseReferences<
          _$AppDatabase,
          $NotificationLogsTableTable,
          NotificationLogsTableData
        >,
      ),
      NotificationLogsTableData,
      PrefetchHooks Function()
    >;
typedef $$PendingTransactionsTableTableCreateCompanionBuilder =
    PendingTransactionsTableCompanion Function({
      required String id,
      required String bank,
      required int amount,
      required String category,
      required String type,
      required String rawText,
      required DateTime time,
      Value<bool> pending,
      Value<String?> fromWallet,
      Value<String?> toWallet,
      Value<int> rowid,
    });
typedef $$PendingTransactionsTableTableUpdateCompanionBuilder =
    PendingTransactionsTableCompanion Function({
      Value<String> id,
      Value<String> bank,
      Value<int> amount,
      Value<String> category,
      Value<String> type,
      Value<String> rawText,
      Value<DateTime> time,
      Value<bool> pending,
      Value<String?> fromWallet,
      Value<String?> toWallet,
      Value<int> rowid,
    });

class $$PendingTransactionsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PendingTransactionsTableTable> {
  $$PendingTransactionsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bank => $composableBuilder(
    column: $table.bank,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawText => $composableBuilder(
    column: $table.rawText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pending => $composableBuilder(
    column: $table.pending,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fromWallet => $composableBuilder(
    column: $table.fromWallet,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toWallet => $composableBuilder(
    column: $table.toWallet,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingTransactionsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingTransactionsTableTable> {
  $$PendingTransactionsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bank => $composableBuilder(
    column: $table.bank,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawText => $composableBuilder(
    column: $table.rawText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pending => $composableBuilder(
    column: $table.pending,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromWallet => $composableBuilder(
    column: $table.fromWallet,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toWallet => $composableBuilder(
    column: $table.toWallet,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingTransactionsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingTransactionsTableTable> {
  $$PendingTransactionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bank =>
      $composableBuilder(column: $table.bank, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get rawText =>
      $composableBuilder(column: $table.rawText, builder: (column) => column);

  GeneratedColumn<DateTime> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);

  GeneratedColumn<bool> get pending =>
      $composableBuilder(column: $table.pending, builder: (column) => column);

  GeneratedColumn<String> get fromWallet => $composableBuilder(
    column: $table.fromWallet,
    builder: (column) => column,
  );

  GeneratedColumn<String> get toWallet =>
      $composableBuilder(column: $table.toWallet, builder: (column) => column);
}

class $$PendingTransactionsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingTransactionsTableTable,
          PendingTransactionsTableData,
          $$PendingTransactionsTableTableFilterComposer,
          $$PendingTransactionsTableTableOrderingComposer,
          $$PendingTransactionsTableTableAnnotationComposer,
          $$PendingTransactionsTableTableCreateCompanionBuilder,
          $$PendingTransactionsTableTableUpdateCompanionBuilder,
          (
            PendingTransactionsTableData,
            BaseReferences<
              _$AppDatabase,
              $PendingTransactionsTableTable,
              PendingTransactionsTableData
            >,
          ),
          PendingTransactionsTableData,
          PrefetchHooks Function()
        > {
  $$PendingTransactionsTableTableTableManager(
    _$AppDatabase db,
    $PendingTransactionsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingTransactionsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PendingTransactionsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PendingTransactionsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> bank = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> rawText = const Value.absent(),
                Value<DateTime> time = const Value.absent(),
                Value<bool> pending = const Value.absent(),
                Value<String?> fromWallet = const Value.absent(),
                Value<String?> toWallet = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingTransactionsTableCompanion(
                id: id,
                bank: bank,
                amount: amount,
                category: category,
                type: type,
                rawText: rawText,
                time: time,
                pending: pending,
                fromWallet: fromWallet,
                toWallet: toWallet,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String bank,
                required int amount,
                required String category,
                required String type,
                required String rawText,
                required DateTime time,
                Value<bool> pending = const Value.absent(),
                Value<String?> fromWallet = const Value.absent(),
                Value<String?> toWallet = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingTransactionsTableCompanion.insert(
                id: id,
                bank: bank,
                amount: amount,
                category: category,
                type: type,
                rawText: rawText,
                time: time,
                pending: pending,
                fromWallet: fromWallet,
                toWallet: toWallet,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingTransactionsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PendingTransactionsTableTable,
      PendingTransactionsTableData,
      $$PendingTransactionsTableTableFilterComposer,
      $$PendingTransactionsTableTableOrderingComposer,
      $$PendingTransactionsTableTableAnnotationComposer,
      $$PendingTransactionsTableTableCreateCompanionBuilder,
      $$PendingTransactionsTableTableUpdateCompanionBuilder,
      (
        PendingTransactionsTableData,
        BaseReferences<
          _$AppDatabase,
          $PendingTransactionsTableTable,
          PendingTransactionsTableData
        >,
      ),
      PendingTransactionsTableData,
      PrefetchHooks Function()
    >;
typedef $$WalletTableTableCreateCompanionBuilder =
    WalletTableCompanion Function({
      required String id,
      required String name,
      required String bank,
      Value<int> balance,
      Value<bool> active,
      Value<int> rowid,
    });
typedef $$WalletTableTableUpdateCompanionBuilder =
    WalletTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> bank,
      Value<int> balance,
      Value<bool> active,
      Value<int> rowid,
    });

class $$WalletTableTableFilterComposer
    extends Composer<_$AppDatabase, $WalletTableTable> {
  $$WalletTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bank => $composableBuilder(
    column: $table.bank,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WalletTableTableOrderingComposer
    extends Composer<_$AppDatabase, $WalletTableTable> {
  $$WalletTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bank => $composableBuilder(
    column: $table.bank,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WalletTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $WalletTableTable> {
  $$WalletTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get bank =>
      $composableBuilder(column: $table.bank, builder: (column) => column);

  GeneratedColumn<int> get balance =>
      $composableBuilder(column: $table.balance, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);
}

class $$WalletTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WalletTableTable,
          WalletTableData,
          $$WalletTableTableFilterComposer,
          $$WalletTableTableOrderingComposer,
          $$WalletTableTableAnnotationComposer,
          $$WalletTableTableCreateCompanionBuilder,
          $$WalletTableTableUpdateCompanionBuilder,
          (
            WalletTableData,
            BaseReferences<_$AppDatabase, $WalletTableTable, WalletTableData>,
          ),
          WalletTableData,
          PrefetchHooks Function()
        > {
  $$WalletTableTableTableManager(_$AppDatabase db, $WalletTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WalletTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WalletTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WalletTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> bank = const Value.absent(),
                Value<int> balance = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WalletTableCompanion(
                id: id,
                name: name,
                bank: bank,
                balance: balance,
                active: active,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String bank,
                Value<int> balance = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WalletTableCompanion.insert(
                id: id,
                name: name,
                bank: bank,
                balance: balance,
                active: active,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WalletTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WalletTableTable,
      WalletTableData,
      $$WalletTableTableFilterComposer,
      $$WalletTableTableOrderingComposer,
      $$WalletTableTableAnnotationComposer,
      $$WalletTableTableCreateCompanionBuilder,
      $$WalletTableTableUpdateCompanionBuilder,
      (
        WalletTableData,
        BaseReferences<_$AppDatabase, $WalletTableTable, WalletTableData>,
      ),
      WalletTableData,
      PrefetchHooks Function()
    >;
typedef $$WalletBalanceAdjustmentTableTableCreateCompanionBuilder =
    WalletBalanceAdjustmentTableCompanion Function({
      required String id,
      required String walletId,
      required String walletName,
      required int previousBalance,
      required int newBalance,
      Value<String> note,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$WalletBalanceAdjustmentTableTableUpdateCompanionBuilder =
    WalletBalanceAdjustmentTableCompanion Function({
      Value<String> id,
      Value<String> walletId,
      Value<String> walletName,
      Value<int> previousBalance,
      Value<int> newBalance,
      Value<String> note,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$WalletBalanceAdjustmentTableTableFilterComposer
    extends Composer<_$AppDatabase, $WalletBalanceAdjustmentTableTable> {
  $$WalletBalanceAdjustmentTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get walletId => $composableBuilder(
    column: $table.walletId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get walletName => $composableBuilder(
    column: $table.walletName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get previousBalance => $composableBuilder(
    column: $table.previousBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get newBalance => $composableBuilder(
    column: $table.newBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WalletBalanceAdjustmentTableTableOrderingComposer
    extends Composer<_$AppDatabase, $WalletBalanceAdjustmentTableTable> {
  $$WalletBalanceAdjustmentTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get walletId => $composableBuilder(
    column: $table.walletId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get walletName => $composableBuilder(
    column: $table.walletName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get previousBalance => $composableBuilder(
    column: $table.previousBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get newBalance => $composableBuilder(
    column: $table.newBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WalletBalanceAdjustmentTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $WalletBalanceAdjustmentTableTable> {
  $$WalletBalanceAdjustmentTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get walletId =>
      $composableBuilder(column: $table.walletId, builder: (column) => column);

  GeneratedColumn<String> get walletName => $composableBuilder(
    column: $table.walletName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get previousBalance => $composableBuilder(
    column: $table.previousBalance,
    builder: (column) => column,
  );

  GeneratedColumn<int> get newBalance => $composableBuilder(
    column: $table.newBalance,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$WalletBalanceAdjustmentTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WalletBalanceAdjustmentTableTable,
          WalletBalanceAdjustmentTableData,
          $$WalletBalanceAdjustmentTableTableFilterComposer,
          $$WalletBalanceAdjustmentTableTableOrderingComposer,
          $$WalletBalanceAdjustmentTableTableAnnotationComposer,
          $$WalletBalanceAdjustmentTableTableCreateCompanionBuilder,
          $$WalletBalanceAdjustmentTableTableUpdateCompanionBuilder,
          (
            WalletBalanceAdjustmentTableData,
            BaseReferences<
              _$AppDatabase,
              $WalletBalanceAdjustmentTableTable,
              WalletBalanceAdjustmentTableData
            >,
          ),
          WalletBalanceAdjustmentTableData,
          PrefetchHooks Function()
        > {
  $$WalletBalanceAdjustmentTableTableTableManager(
    _$AppDatabase db,
    $WalletBalanceAdjustmentTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WalletBalanceAdjustmentTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$WalletBalanceAdjustmentTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$WalletBalanceAdjustmentTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> walletId = const Value.absent(),
                Value<String> walletName = const Value.absent(),
                Value<int> previousBalance = const Value.absent(),
                Value<int> newBalance = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WalletBalanceAdjustmentTableCompanion(
                id: id,
                walletId: walletId,
                walletName: walletName,
                previousBalance: previousBalance,
                newBalance: newBalance,
                note: note,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String walletId,
                required String walletName,
                required int previousBalance,
                required int newBalance,
                Value<String> note = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => WalletBalanceAdjustmentTableCompanion.insert(
                id: id,
                walletId: walletId,
                walletName: walletName,
                previousBalance: previousBalance,
                newBalance: newBalance,
                note: note,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WalletBalanceAdjustmentTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WalletBalanceAdjustmentTableTable,
      WalletBalanceAdjustmentTableData,
      $$WalletBalanceAdjustmentTableTableFilterComposer,
      $$WalletBalanceAdjustmentTableTableOrderingComposer,
      $$WalletBalanceAdjustmentTableTableAnnotationComposer,
      $$WalletBalanceAdjustmentTableTableCreateCompanionBuilder,
      $$WalletBalanceAdjustmentTableTableUpdateCompanionBuilder,
      (
        WalletBalanceAdjustmentTableData,
        BaseReferences<
          _$AppDatabase,
          $WalletBalanceAdjustmentTableTable,
          WalletBalanceAdjustmentTableData
        >,
      ),
      WalletBalanceAdjustmentTableData,
      PrefetchHooks Function()
    >;
typedef $$MonthlyBudgetsTableTableCreateCompanionBuilder =
    MonthlyBudgetsTableCompanion Function({
      required String category,
      required int monthlyLimit,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$MonthlyBudgetsTableTableUpdateCompanionBuilder =
    MonthlyBudgetsTableCompanion Function({
      Value<String> category,
      Value<int> monthlyLimit,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$MonthlyBudgetsTableTableFilterComposer
    extends Composer<_$AppDatabase, $MonthlyBudgetsTableTable> {
  $$MonthlyBudgetsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monthlyLimit => $composableBuilder(
    column: $table.monthlyLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MonthlyBudgetsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MonthlyBudgetsTableTable> {
  $$MonthlyBudgetsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monthlyLimit => $composableBuilder(
    column: $table.monthlyLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MonthlyBudgetsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MonthlyBudgetsTableTable> {
  $$MonthlyBudgetsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get monthlyLimit => $composableBuilder(
    column: $table.monthlyLimit,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MonthlyBudgetsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MonthlyBudgetsTableTable,
          MonthlyBudgetsTableData,
          $$MonthlyBudgetsTableTableFilterComposer,
          $$MonthlyBudgetsTableTableOrderingComposer,
          $$MonthlyBudgetsTableTableAnnotationComposer,
          $$MonthlyBudgetsTableTableCreateCompanionBuilder,
          $$MonthlyBudgetsTableTableUpdateCompanionBuilder,
          (
            MonthlyBudgetsTableData,
            BaseReferences<
              _$AppDatabase,
              $MonthlyBudgetsTableTable,
              MonthlyBudgetsTableData
            >,
          ),
          MonthlyBudgetsTableData,
          PrefetchHooks Function()
        > {
  $$MonthlyBudgetsTableTableTableManager(
    _$AppDatabase db,
    $MonthlyBudgetsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MonthlyBudgetsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MonthlyBudgetsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MonthlyBudgetsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> category = const Value.absent(),
                Value<int> monthlyLimit = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MonthlyBudgetsTableCompanion(
                category: category,
                monthlyLimit: monthlyLimit,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String category,
                required int monthlyLimit,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => MonthlyBudgetsTableCompanion.insert(
                category: category,
                monthlyLimit: monthlyLimit,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MonthlyBudgetsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MonthlyBudgetsTableTable,
      MonthlyBudgetsTableData,
      $$MonthlyBudgetsTableTableFilterComposer,
      $$MonthlyBudgetsTableTableOrderingComposer,
      $$MonthlyBudgetsTableTableAnnotationComposer,
      $$MonthlyBudgetsTableTableCreateCompanionBuilder,
      $$MonthlyBudgetsTableTableUpdateCompanionBuilder,
      (
        MonthlyBudgetsTableData,
        BaseReferences<
          _$AppDatabase,
          $MonthlyBudgetsTableTable,
          MonthlyBudgetsTableData
        >,
      ),
      MonthlyBudgetsTableData,
      PrefetchHooks Function()
    >;
typedef $$MerchantCategoryRulesTableTableCreateCompanionBuilder =
    MerchantCategoryRulesTableCompanion Function({
      required String merchantKey,
      required String merchantName,
      required String category,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$MerchantCategoryRulesTableTableUpdateCompanionBuilder =
    MerchantCategoryRulesTableCompanion Function({
      Value<String> merchantKey,
      Value<String> merchantName,
      Value<String> category,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$MerchantCategoryRulesTableTableFilterComposer
    extends Composer<_$AppDatabase, $MerchantCategoryRulesTableTable> {
  $$MerchantCategoryRulesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get merchantKey => $composableBuilder(
    column: $table.merchantKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get merchantName => $composableBuilder(
    column: $table.merchantName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MerchantCategoryRulesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MerchantCategoryRulesTableTable> {
  $$MerchantCategoryRulesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get merchantKey => $composableBuilder(
    column: $table.merchantKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get merchantName => $composableBuilder(
    column: $table.merchantName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MerchantCategoryRulesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MerchantCategoryRulesTableTable> {
  $$MerchantCategoryRulesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get merchantKey => $composableBuilder(
    column: $table.merchantKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get merchantName => $composableBuilder(
    column: $table.merchantName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MerchantCategoryRulesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MerchantCategoryRulesTableTable,
          MerchantCategoryRulesTableData,
          $$MerchantCategoryRulesTableTableFilterComposer,
          $$MerchantCategoryRulesTableTableOrderingComposer,
          $$MerchantCategoryRulesTableTableAnnotationComposer,
          $$MerchantCategoryRulesTableTableCreateCompanionBuilder,
          $$MerchantCategoryRulesTableTableUpdateCompanionBuilder,
          (
            MerchantCategoryRulesTableData,
            BaseReferences<
              _$AppDatabase,
              $MerchantCategoryRulesTableTable,
              MerchantCategoryRulesTableData
            >,
          ),
          MerchantCategoryRulesTableData,
          PrefetchHooks Function()
        > {
  $$MerchantCategoryRulesTableTableTableManager(
    _$AppDatabase db,
    $MerchantCategoryRulesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MerchantCategoryRulesTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$MerchantCategoryRulesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MerchantCategoryRulesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> merchantKey = const Value.absent(),
                Value<String> merchantName = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MerchantCategoryRulesTableCompanion(
                merchantKey: merchantKey,
                merchantName: merchantName,
                category: category,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String merchantKey,
                required String merchantName,
                required String category,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => MerchantCategoryRulesTableCompanion.insert(
                merchantKey: merchantKey,
                merchantName: merchantName,
                category: category,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MerchantCategoryRulesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MerchantCategoryRulesTableTable,
      MerchantCategoryRulesTableData,
      $$MerchantCategoryRulesTableTableFilterComposer,
      $$MerchantCategoryRulesTableTableOrderingComposer,
      $$MerchantCategoryRulesTableTableAnnotationComposer,
      $$MerchantCategoryRulesTableTableCreateCompanionBuilder,
      $$MerchantCategoryRulesTableTableUpdateCompanionBuilder,
      (
        MerchantCategoryRulesTableData,
        BaseReferences<
          _$AppDatabase,
          $MerchantCategoryRulesTableTable,
          MerchantCategoryRulesTableData
        >,
      ),
      MerchantCategoryRulesTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TransactionsTableTableTableManager get transactionsTable =>
      $$TransactionsTableTableTableManager(_db, _db.transactionsTable);
  $$NotificationLogsTableTableTableManager get notificationLogsTable =>
      $$NotificationLogsTableTableTableManager(_db, _db.notificationLogsTable);
  $$PendingTransactionsTableTableTableManager get pendingTransactionsTable =>
      $$PendingTransactionsTableTableTableManager(
        _db,
        _db.pendingTransactionsTable,
      );
  $$WalletTableTableTableManager get walletTable =>
      $$WalletTableTableTableManager(_db, _db.walletTable);
  $$WalletBalanceAdjustmentTableTableTableManager
  get walletBalanceAdjustmentTable =>
      $$WalletBalanceAdjustmentTableTableTableManager(
        _db,
        _db.walletBalanceAdjustmentTable,
      );
  $$MonthlyBudgetsTableTableTableManager get monthlyBudgetsTable =>
      $$MonthlyBudgetsTableTableTableManager(_db, _db.monthlyBudgetsTable);
  $$MerchantCategoryRulesTableTableTableManager
  get merchantCategoryRulesTable =>
      $$MerchantCategoryRulesTableTableTableManager(
        _db,
        _db.merchantCategoryRulesTable,
      );
}
