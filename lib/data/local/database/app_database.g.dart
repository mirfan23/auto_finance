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
        DriftSqlType.int,
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
  final int id;
  final String bank;
  final int amount;
  final String type;
  final String category;
  final String rawText;
  final DateTime time;
  const TransactionsTableData({
    required this.id,
    required this.bank,
    required this.amount,
    required this.type,
    required this.category,
    required this.rawText,
    required this.time,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['bank'] = Variable<String>(bank);
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
      id: serializer.fromJson<int>(json['id']),
      bank: serializer.fromJson<String>(json['bank']),
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
      'id': serializer.toJson<int>(id),
      'bank': serializer.toJson<String>(bank),
      'amount': serializer.toJson<int>(amount),
      'type': serializer.toJson<String>(type),
      'category': serializer.toJson<String>(category),
      'rawText': serializer.toJson<String>(rawText),
      'time': serializer.toJson<DateTime>(time),
    };
  }

  TransactionsTableData copyWith({
    int? id,
    String? bank,
    int? amount,
    String? type,
    String? category,
    String? rawText,
    DateTime? time,
  }) => TransactionsTableData(
    id: id ?? this.id,
    bank: bank ?? this.bank,
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
          ..write('amount: $amount, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('rawText: $rawText, ')
          ..write('time: $time')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, bank, amount, type, category, rawText, time);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionsTableData &&
          other.id == this.id &&
          other.bank == this.bank &&
          other.amount == this.amount &&
          other.type == this.type &&
          other.category == this.category &&
          other.rawText == this.rawText &&
          other.time == this.time);
}

class TransactionsTableCompanion
    extends UpdateCompanion<TransactionsTableData> {
  final Value<int> id;
  final Value<String> bank;
  final Value<int> amount;
  final Value<String> type;
  final Value<String> category;
  final Value<String> rawText;
  final Value<DateTime> time;
  const TransactionsTableCompanion({
    this.id = const Value.absent(),
    this.bank = const Value.absent(),
    this.amount = const Value.absent(),
    this.type = const Value.absent(),
    this.category = const Value.absent(),
    this.rawText = const Value.absent(),
    this.time = const Value.absent(),
  });
  TransactionsTableCompanion.insert({
    this.id = const Value.absent(),
    required String bank,
    required int amount,
    required String type,
    required String category,
    required String rawText,
    required DateTime time,
  }) : bank = Value(bank),
       amount = Value(amount),
       type = Value(type),
       category = Value(category),
       rawText = Value(rawText),
       time = Value(time);
  static Insertable<TransactionsTableData> custom({
    Expression<int>? id,
    Expression<String>? bank,
    Expression<int>? amount,
    Expression<String>? type,
    Expression<String>? category,
    Expression<String>? rawText,
    Expression<DateTime>? time,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bank != null) 'bank': bank,
      if (amount != null) 'amount': amount,
      if (type != null) 'type': type,
      if (category != null) 'category': category,
      if (rawText != null) 'raw_text': rawText,
      if (time != null) 'time': time,
    });
  }

  TransactionsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? bank,
    Value<int>? amount,
    Value<String>? type,
    Value<String>? category,
    Value<String>? rawText,
    Value<DateTime>? time,
  }) {
    return TransactionsTableCompanion(
      id: id ?? this.id,
      bank: bank ?? this.bank,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      rawText: rawText ?? this.rawText,
      time: time ?? this.time,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bank.present) {
      map['bank'] = Variable<String>(bank.value);
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsTableCompanion(')
          ..write('id: $id, ')
          ..write('bank: $bank, ')
          ..write('amount: $amount, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('rawText: $rawText, ')
          ..write('time: $time')
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
  late final GeneratedColumn<String> timestamp = GeneratedColumn<String>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    packageName,
    title,
    rawText,
    timestamp,
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
        DriftSqlType.string,
        data['${effectivePrefix}timestamp'],
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
  final String timestamp;
  const NotificationLogsTableData({
    required this.id,
    required this.packageName,
    required this.title,
    required this.rawText,
    required this.timestamp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['package_name'] = Variable<String>(packageName);
    map['title'] = Variable<String>(title);
    map['raw_text'] = Variable<String>(rawText);
    map['timestamp'] = Variable<String>(timestamp);
    return map;
  }

  NotificationLogsTableCompanion toCompanion(bool nullToAbsent) {
    return NotificationLogsTableCompanion(
      id: Value(id),
      packageName: Value(packageName),
      title: Value(title),
      rawText: Value(rawText),
      timestamp: Value(timestamp),
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
      timestamp: serializer.fromJson<String>(json['timestamp']),
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
      'timestamp': serializer.toJson<String>(timestamp),
    };
  }

  NotificationLogsTableData copyWith({
    int? id,
    String? packageName,
    String? title,
    String? rawText,
    String? timestamp,
  }) => NotificationLogsTableData(
    id: id ?? this.id,
    packageName: packageName ?? this.packageName,
    title: title ?? this.title,
    rawText: rawText ?? this.rawText,
    timestamp: timestamp ?? this.timestamp,
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
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotificationLogsTableData(')
          ..write('id: $id, ')
          ..write('packageName: $packageName, ')
          ..write('title: $title, ')
          ..write('rawText: $rawText, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, packageName, title, rawText, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationLogsTableData &&
          other.id == this.id &&
          other.packageName == this.packageName &&
          other.title == this.title &&
          other.rawText == this.rawText &&
          other.timestamp == this.timestamp);
}

class NotificationLogsTableCompanion
    extends UpdateCompanion<NotificationLogsTableData> {
  final Value<int> id;
  final Value<String> packageName;
  final Value<String> title;
  final Value<String> rawText;
  final Value<String> timestamp;
  const NotificationLogsTableCompanion({
    this.id = const Value.absent(),
    this.packageName = const Value.absent(),
    this.title = const Value.absent(),
    this.rawText = const Value.absent(),
    this.timestamp = const Value.absent(),
  });
  NotificationLogsTableCompanion.insert({
    this.id = const Value.absent(),
    required String packageName,
    required String title,
    required String rawText,
    required String timestamp,
  }) : packageName = Value(packageName),
       title = Value(title),
       rawText = Value(rawText),
       timestamp = Value(timestamp);
  static Insertable<NotificationLogsTableData> custom({
    Expression<int>? id,
    Expression<String>? packageName,
    Expression<String>? title,
    Expression<String>? rawText,
    Expression<String>? timestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (packageName != null) 'package_name': packageName,
      if (title != null) 'title': title,
      if (rawText != null) 'raw_text': rawText,
      if (timestamp != null) 'timestamp': timestamp,
    });
  }

  NotificationLogsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? packageName,
    Value<String>? title,
    Value<String>? rawText,
    Value<String>? timestamp,
  }) {
    return NotificationLogsTableCompanion(
      id: id ?? this.id,
      packageName: packageName ?? this.packageName,
      title: title ?? this.title,
      rawText: rawText ?? this.rawText,
      timestamp: timestamp ?? this.timestamp,
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
      map['timestamp'] = Variable<String>(timestamp.value);
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
          ..write('timestamp: $timestamp')
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
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    transactionsTable,
    notificationLogsTable,
  ];
}

typedef $$TransactionsTableTableCreateCompanionBuilder =
    TransactionsTableCompanion Function({
      Value<int> id,
      required String bank,
      required int amount,
      required String type,
      required String category,
      required String rawText,
      required DateTime time,
    });
typedef $$TransactionsTableTableUpdateCompanionBuilder =
    TransactionsTableCompanion Function({
      Value<int> id,
      Value<String> bank,
      Value<int> amount,
      Value<String> type,
      Value<String> category,
      Value<String> rawText,
      Value<DateTime> time,
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
  ColumnFilters<int> get id => $composableBuilder(
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
  ColumnOrderings<int> get id => $composableBuilder(
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
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bank =>
      $composableBuilder(column: $table.bank, builder: (column) => column);

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
                Value<int> id = const Value.absent(),
                Value<String> bank = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> rawText = const Value.absent(),
                Value<DateTime> time = const Value.absent(),
              }) => TransactionsTableCompanion(
                id: id,
                bank: bank,
                amount: amount,
                type: type,
                category: category,
                rawText: rawText,
                time: time,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String bank,
                required int amount,
                required String type,
                required String category,
                required String rawText,
                required DateTime time,
              }) => TransactionsTableCompanion.insert(
                id: id,
                bank: bank,
                amount: amount,
                type: type,
                category: category,
                rawText: rawText,
                time: time,
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
      required String timestamp,
    });
typedef $$NotificationLogsTableTableUpdateCompanionBuilder =
    NotificationLogsTableCompanion Function({
      Value<int> id,
      Value<String> packageName,
      Value<String> title,
      Value<String> rawText,
      Value<String> timestamp,
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

  ColumnFilters<String> get timestamp => $composableBuilder(
    column: $table.timestamp,
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

  ColumnOrderings<String> get timestamp => $composableBuilder(
    column: $table.timestamp,
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

  GeneratedColumn<String> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);
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
                Value<String> timestamp = const Value.absent(),
              }) => NotificationLogsTableCompanion(
                id: id,
                packageName: packageName,
                title: title,
                rawText: rawText,
                timestamp: timestamp,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String packageName,
                required String title,
                required String rawText,
                required String timestamp,
              }) => NotificationLogsTableCompanion.insert(
                id: id,
                packageName: packageName,
                title: title,
                rawText: rawText,
                timestamp: timestamp,
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TransactionsTableTableTableManager get transactionsTable =>
      $$TransactionsTableTableTableManager(_db, _db.transactionsTable);
  $$NotificationLogsTableTableTableManager get notificationLogsTable =>
      $$NotificationLogsTableTableTableManager(_db, _db.notificationLogsTable);
}
