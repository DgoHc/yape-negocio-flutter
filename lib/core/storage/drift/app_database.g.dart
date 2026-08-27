// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PaymentsTableTable extends PaymentsTable
    with TableInfo<$PaymentsTableTable, Payment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _externalIdMeta = const VerificationMeta(
    'externalId',
  );
  @override
  late final GeneratedColumn<String> externalId = GeneratedColumn<String>(
    'external_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('S/'),
  );
  static const VerificationMeta _senderNameMeta = const VerificationMeta(
    'senderName',
  );
  @override
  late final GeneratedColumn<String> senderName = GeneratedColumn<String>(
    'sender_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _operationNumberMeta = const VerificationMeta(
    'operationNumber',
  );
  @override
  late final GeneratedColumn<String> operationNumber = GeneratedColumn<String>(
    'operation_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rawTextMeta = const VerificationMeta(
    'rawText',
  );
  @override
  late final GeneratedColumn<String> rawText = GeneratedColumn<String>(
    'raw_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    externalId,
    amount,
    currency,
    senderName,
    createdAt,
    isSynced,
    operationNumber,
    rawText,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<Payment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('external_id')) {
      context.handle(
        _externalIdMeta,
        externalId.isAcceptableOrUnknown(data['external_id']!, _externalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_externalIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('sender_name')) {
      context.handle(
        _senderNameMeta,
        senderName.isAcceptableOrUnknown(data['sender_name']!, _senderNameMeta),
      );
    } else if (isInserting) {
      context.missing(_senderNameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('operation_number')) {
      context.handle(
        _operationNumberMeta,
        operationNumber.isAcceptableOrUnknown(
          data['operation_number']!,
          _operationNumberMeta,
        ),
      );
    }
    if (data.containsKey('raw_text')) {
      context.handle(
        _rawTextMeta,
        rawText.isAcceptableOrUnknown(data['raw_text']!, _rawTextMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Payment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Payment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      externalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      senderName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      operationNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_number'],
      ),
      rawText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_text'],
      ),
    );
  }

  @override
  $PaymentsTableTable createAlias(String alias) {
    return $PaymentsTableTable(attachedDatabase, alias);
  }
}

class Payment extends DataClass implements Insertable<Payment> {
  final int id;
  final String externalId;
  final double amount;
  final String currency;
  final String senderName;
  final DateTime createdAt;
  final bool isSynced;
  final String? operationNumber;
  final String? rawText;
  const Payment({
    required this.id,
    required this.externalId,
    required this.amount,
    required this.currency,
    required this.senderName,
    required this.createdAt,
    required this.isSynced,
    this.operationNumber,
    this.rawText,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['external_id'] = Variable<String>(externalId);
    map['amount'] = Variable<double>(amount);
    map['currency'] = Variable<String>(currency);
    map['sender_name'] = Variable<String>(senderName);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_synced'] = Variable<bool>(isSynced);
    if (!nullToAbsent || operationNumber != null) {
      map['operation_number'] = Variable<String>(operationNumber);
    }
    if (!nullToAbsent || rawText != null) {
      map['raw_text'] = Variable<String>(rawText);
    }
    return map;
  }

  PaymentsTableCompanion toCompanion(bool nullToAbsent) {
    return PaymentsTableCompanion(
      id: Value(id),
      externalId: Value(externalId),
      amount: Value(amount),
      currency: Value(currency),
      senderName: Value(senderName),
      createdAt: Value(createdAt),
      isSynced: Value(isSynced),
      operationNumber: operationNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(operationNumber),
      rawText: rawText == null && nullToAbsent
          ? const Value.absent()
          : Value(rawText),
    );
  }

  factory Payment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Payment(
      id: serializer.fromJson<int>(json['id']),
      externalId: serializer.fromJson<String>(json['externalId']),
      amount: serializer.fromJson<double>(json['amount']),
      currency: serializer.fromJson<String>(json['currency']),
      senderName: serializer.fromJson<String>(json['senderName']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      operationNumber: serializer.fromJson<String?>(json['operationNumber']),
      rawText: serializer.fromJson<String?>(json['rawText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'externalId': serializer.toJson<String>(externalId),
      'amount': serializer.toJson<double>(amount),
      'currency': serializer.toJson<String>(currency),
      'senderName': serializer.toJson<String>(senderName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'operationNumber': serializer.toJson<String?>(operationNumber),
      'rawText': serializer.toJson<String?>(rawText),
    };
  }

  Payment copyWith({
    int? id,
    String? externalId,
    double? amount,
    String? currency,
    String? senderName,
    DateTime? createdAt,
    bool? isSynced,
    Value<String?> operationNumber = const Value.absent(),
    Value<String?> rawText = const Value.absent(),
  }) => Payment(
    id: id ?? this.id,
    externalId: externalId ?? this.externalId,
    amount: amount ?? this.amount,
    currency: currency ?? this.currency,
    senderName: senderName ?? this.senderName,
    createdAt: createdAt ?? this.createdAt,
    isSynced: isSynced ?? this.isSynced,
    operationNumber: operationNumber.present
        ? operationNumber.value
        : this.operationNumber,
    rawText: rawText.present ? rawText.value : this.rawText,
  );
  Payment copyWithCompanion(PaymentsTableCompanion data) {
    return Payment(
      id: data.id.present ? data.id.value : this.id,
      externalId: data.externalId.present
          ? data.externalId.value
          : this.externalId,
      amount: data.amount.present ? data.amount.value : this.amount,
      currency: data.currency.present ? data.currency.value : this.currency,
      senderName: data.senderName.present
          ? data.senderName.value
          : this.senderName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      operationNumber: data.operationNumber.present
          ? data.operationNumber.value
          : this.operationNumber,
      rawText: data.rawText.present ? data.rawText.value : this.rawText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Payment(')
          ..write('id: $id, ')
          ..write('externalId: $externalId, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('senderName: $senderName, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('operationNumber: $operationNumber, ')
          ..write('rawText: $rawText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    externalId,
    amount,
    currency,
    senderName,
    createdAt,
    isSynced,
    operationNumber,
    rawText,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Payment &&
          other.id == this.id &&
          other.externalId == this.externalId &&
          other.amount == this.amount &&
          other.currency == this.currency &&
          other.senderName == this.senderName &&
          other.createdAt == this.createdAt &&
          other.isSynced == this.isSynced &&
          other.operationNumber == this.operationNumber &&
          other.rawText == this.rawText);
}

class PaymentsTableCompanion extends UpdateCompanion<Payment> {
  final Value<int> id;
  final Value<String> externalId;
  final Value<double> amount;
  final Value<String> currency;
  final Value<String> senderName;
  final Value<DateTime> createdAt;
  final Value<bool> isSynced;
  final Value<String?> operationNumber;
  final Value<String?> rawText;
  const PaymentsTableCompanion({
    this.id = const Value.absent(),
    this.externalId = const Value.absent(),
    this.amount = const Value.absent(),
    this.currency = const Value.absent(),
    this.senderName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.operationNumber = const Value.absent(),
    this.rawText = const Value.absent(),
  });
  PaymentsTableCompanion.insert({
    this.id = const Value.absent(),
    required String externalId,
    required double amount,
    this.currency = const Value.absent(),
    required String senderName,
    this.createdAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.operationNumber = const Value.absent(),
    this.rawText = const Value.absent(),
  }) : externalId = Value(externalId),
       amount = Value(amount),
       senderName = Value(senderName);
  static Insertable<Payment> custom({
    Expression<int>? id,
    Expression<String>? externalId,
    Expression<double>? amount,
    Expression<String>? currency,
    Expression<String>? senderName,
    Expression<DateTime>? createdAt,
    Expression<bool>? isSynced,
    Expression<String>? operationNumber,
    Expression<String>? rawText,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (externalId != null) 'external_id': externalId,
      if (amount != null) 'amount': amount,
      if (currency != null) 'currency': currency,
      if (senderName != null) 'sender_name': senderName,
      if (createdAt != null) 'created_at': createdAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (operationNumber != null) 'operation_number': operationNumber,
      if (rawText != null) 'raw_text': rawText,
    });
  }

  PaymentsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? externalId,
    Value<double>? amount,
    Value<String>? currency,
    Value<String>? senderName,
    Value<DateTime>? createdAt,
    Value<bool>? isSynced,
    Value<String?>? operationNumber,
    Value<String?>? rawText,
  }) {
    return PaymentsTableCompanion(
      id: id ?? this.id,
      externalId: externalId ?? this.externalId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      senderName: senderName ?? this.senderName,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
      operationNumber: operationNumber ?? this.operationNumber,
      rawText: rawText ?? this.rawText,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (externalId.present) {
      map['external_id'] = Variable<String>(externalId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (senderName.present) {
      map['sender_name'] = Variable<String>(senderName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (operationNumber.present) {
      map['operation_number'] = Variable<String>(operationNumber.value);
    }
    if (rawText.present) {
      map['raw_text'] = Variable<String>(rawText.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsTableCompanion(')
          ..write('id: $id, ')
          ..write('externalId: $externalId, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('senderName: $senderName, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('operationNumber: $operationNumber, ')
          ..write('rawText: $rawText')
          ..write(')'))
        .toString();
  }
}

class $DevicesTableTable extends DevicesTable
    with TableInfo<$DevicesTableTable, Device> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevicesTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _aliasMeta = const VerificationMeta('alias');
  @override
  late final GeneratedColumn<String> alias = GeneratedColumn<String>(
    'alias',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isApprovedMeta = const VerificationMeta(
    'isApproved',
  );
  @override
  late final GeneratedColumn<bool> isApproved = GeneratedColumn<bool>(
    'is_approved',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_approved" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastConnectedAtMeta = const VerificationMeta(
    'lastConnectedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastConnectedAt =
      GeneratedColumn<DateTime>(
        'last_connected_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uuid,
    alias,
    isApproved,
    lastConnectedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'devices_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<Device> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('alias')) {
      context.handle(
        _aliasMeta,
        alias.isAcceptableOrUnknown(data['alias']!, _aliasMeta),
      );
    } else if (isInserting) {
      context.missing(_aliasMeta);
    }
    if (data.containsKey('is_approved')) {
      context.handle(
        _isApprovedMeta,
        isApproved.isAcceptableOrUnknown(data['is_approved']!, _isApprovedMeta),
      );
    }
    if (data.containsKey('last_connected_at')) {
      context.handle(
        _lastConnectedAtMeta,
        lastConnectedAt.isAcceptableOrUnknown(
          data['last_connected_at']!,
          _lastConnectedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Device map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Device(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      alias: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alias'],
      )!,
      isApproved: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_approved'],
      )!,
      lastConnectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_connected_at'],
      ),
    );
  }

  @override
  $DevicesTableTable createAlias(String alias) {
    return $DevicesTableTable(attachedDatabase, alias);
  }
}

class Device extends DataClass implements Insertable<Device> {
  final int id;
  final String uuid;
  final String alias;
  final bool isApproved;
  final DateTime? lastConnectedAt;
  const Device({
    required this.id,
    required this.uuid,
    required this.alias,
    required this.isApproved,
    this.lastConnectedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['alias'] = Variable<String>(alias);
    map['is_approved'] = Variable<bool>(isApproved);
    if (!nullToAbsent || lastConnectedAt != null) {
      map['last_connected_at'] = Variable<DateTime>(lastConnectedAt);
    }
    return map;
  }

  DevicesTableCompanion toCompanion(bool nullToAbsent) {
    return DevicesTableCompanion(
      id: Value(id),
      uuid: Value(uuid),
      alias: Value(alias),
      isApproved: Value(isApproved),
      lastConnectedAt: lastConnectedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastConnectedAt),
    );
  }

  factory Device.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Device(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      alias: serializer.fromJson<String>(json['alias']),
      isApproved: serializer.fromJson<bool>(json['isApproved']),
      lastConnectedAt: serializer.fromJson<DateTime?>(json['lastConnectedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'alias': serializer.toJson<String>(alias),
      'isApproved': serializer.toJson<bool>(isApproved),
      'lastConnectedAt': serializer.toJson<DateTime?>(lastConnectedAt),
    };
  }

  Device copyWith({
    int? id,
    String? uuid,
    String? alias,
    bool? isApproved,
    Value<DateTime?> lastConnectedAt = const Value.absent(),
  }) => Device(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    alias: alias ?? this.alias,
    isApproved: isApproved ?? this.isApproved,
    lastConnectedAt: lastConnectedAt.present
        ? lastConnectedAt.value
        : this.lastConnectedAt,
  );
  Device copyWithCompanion(DevicesTableCompanion data) {
    return Device(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      alias: data.alias.present ? data.alias.value : this.alias,
      isApproved: data.isApproved.present
          ? data.isApproved.value
          : this.isApproved,
      lastConnectedAt: data.lastConnectedAt.present
          ? data.lastConnectedAt.value
          : this.lastConnectedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Device(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('alias: $alias, ')
          ..write('isApproved: $isApproved, ')
          ..write('lastConnectedAt: $lastConnectedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, uuid, alias, isApproved, lastConnectedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Device &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.alias == this.alias &&
          other.isApproved == this.isApproved &&
          other.lastConnectedAt == this.lastConnectedAt);
}

class DevicesTableCompanion extends UpdateCompanion<Device> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> alias;
  final Value<bool> isApproved;
  final Value<DateTime?> lastConnectedAt;
  const DevicesTableCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.alias = const Value.absent(),
    this.isApproved = const Value.absent(),
    this.lastConnectedAt = const Value.absent(),
  });
  DevicesTableCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required String alias,
    this.isApproved = const Value.absent(),
    this.lastConnectedAt = const Value.absent(),
  }) : uuid = Value(uuid),
       alias = Value(alias);
  static Insertable<Device> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? alias,
    Expression<bool>? isApproved,
    Expression<DateTime>? lastConnectedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (alias != null) 'alias': alias,
      if (isApproved != null) 'is_approved': isApproved,
      if (lastConnectedAt != null) 'last_connected_at': lastConnectedAt,
    });
  }

  DevicesTableCompanion copyWith({
    Value<int>? id,
    Value<String>? uuid,
    Value<String>? alias,
    Value<bool>? isApproved,
    Value<DateTime?>? lastConnectedAt,
  }) {
    return DevicesTableCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      alias: alias ?? this.alias,
      isApproved: isApproved ?? this.isApproved,
      lastConnectedAt: lastConnectedAt ?? this.lastConnectedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (alias.present) {
      map['alias'] = Variable<String>(alias.value);
    }
    if (isApproved.present) {
      map['is_approved'] = Variable<bool>(isApproved.value);
    }
    if (lastConnectedAt.present) {
      map['last_connected_at'] = Variable<DateTime>(lastConnectedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevicesTableCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('alias: $alias, ')
          ..write('isApproved: $isApproved, ')
          ..write('lastConnectedAt: $lastConnectedAt')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTableTable extends SyncQueueTable
    with TableInfo<$SyncQueueTableTable, SyncQueueTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _actionTypeMeta = const VerificationMeta(
    'actionType',
  );
  @override
  late final GeneratedColumn<String> actionType = GeneratedColumn<String>(
    'action_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastAttemptAtMeta = const VerificationMeta(
    'lastAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAttemptAt =
      GeneratedColumn<DateTime>(
        'last_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    actionType,
    payload,
    status,
    retryCount,
    lastAttemptAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('action_type')) {
      context.handle(
        _actionTypeMeta,
        actionType.isAcceptableOrUnknown(data['action_type']!, _actionTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_actionTypeMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('last_attempt_at')) {
      context.handle(
        _lastAttemptAtMeta,
        lastAttemptAt.isAcceptableOrUnknown(
          data['last_attempt_at']!,
          _lastAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      actionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action_type'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      lastAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_attempt_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SyncQueueTableTable createAlias(String alias) {
    return $SyncQueueTableTable(attachedDatabase, alias);
  }
}

class SyncQueueTableData extends DataClass
    implements Insertable<SyncQueueTableData> {
  final int id;
  final String actionType;
  final String payload;
  final String status;
  final int retryCount;
  final DateTime? lastAttemptAt;
  final DateTime createdAt;
  const SyncQueueTableData({
    required this.id,
    required this.actionType,
    required this.payload,
    required this.status,
    required this.retryCount,
    this.lastAttemptAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['action_type'] = Variable<String>(actionType);
    map['payload'] = Variable<String>(payload);
    map['status'] = Variable<String>(status);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastAttemptAt != null) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SyncQueueTableCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueTableCompanion(
      id: Value(id),
      actionType: Value(actionType),
      payload: Value(payload),
      status: Value(status),
      retryCount: Value(retryCount),
      lastAttemptAt: lastAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptAt),
      createdAt: Value(createdAt),
    );
  }

  factory SyncQueueTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueTableData(
      id: serializer.fromJson<int>(json['id']),
      actionType: serializer.fromJson<String>(json['actionType']),
      payload: serializer.fromJson<String>(json['payload']),
      status: serializer.fromJson<String>(json['status']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastAttemptAt: serializer.fromJson<DateTime?>(json['lastAttemptAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'actionType': serializer.toJson<String>(actionType),
      'payload': serializer.toJson<String>(payload),
      'status': serializer.toJson<String>(status),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastAttemptAt': serializer.toJson<DateTime?>(lastAttemptAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SyncQueueTableData copyWith({
    int? id,
    String? actionType,
    String? payload,
    String? status,
    int? retryCount,
    Value<DateTime?> lastAttemptAt = const Value.absent(),
    DateTime? createdAt,
  }) => SyncQueueTableData(
    id: id ?? this.id,
    actionType: actionType ?? this.actionType,
    payload: payload ?? this.payload,
    status: status ?? this.status,
    retryCount: retryCount ?? this.retryCount,
    lastAttemptAt: lastAttemptAt.present
        ? lastAttemptAt.value
        : this.lastAttemptAt,
    createdAt: createdAt ?? this.createdAt,
  );
  SyncQueueTableData copyWithCompanion(SyncQueueTableCompanion data) {
    return SyncQueueTableData(
      id: data.id.present ? data.id.value : this.id,
      actionType: data.actionType.present
          ? data.actionType.value
          : this.actionType,
      payload: data.payload.present ? data.payload.value : this.payload,
      status: data.status.present ? data.status.value : this.status,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      lastAttemptAt: data.lastAttemptAt.present
          ? data.lastAttemptAt.value
          : this.lastAttemptAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueTableData(')
          ..write('id: $id, ')
          ..write('actionType: $actionType, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    actionType,
    payload,
    status,
    retryCount,
    lastAttemptAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueTableData &&
          other.id == this.id &&
          other.actionType == this.actionType &&
          other.payload == this.payload &&
          other.status == this.status &&
          other.retryCount == this.retryCount &&
          other.lastAttemptAt == this.lastAttemptAt &&
          other.createdAt == this.createdAt);
}

class SyncQueueTableCompanion extends UpdateCompanion<SyncQueueTableData> {
  final Value<int> id;
  final Value<String> actionType;
  final Value<String> payload;
  final Value<String> status;
  final Value<int> retryCount;
  final Value<DateTime?> lastAttemptAt;
  final Value<DateTime> createdAt;
  const SyncQueueTableCompanion({
    this.id = const Value.absent(),
    this.actionType = const Value.absent(),
    this.payload = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SyncQueueTableCompanion.insert({
    this.id = const Value.absent(),
    required String actionType,
    required String payload,
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : actionType = Value(actionType),
       payload = Value(payload);
  static Insertable<SyncQueueTableData> custom({
    Expression<int>? id,
    Expression<String>? actionType,
    Expression<String>? payload,
    Expression<String>? status,
    Expression<int>? retryCount,
    Expression<DateTime>? lastAttemptAt,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (actionType != null) 'action_type': actionType,
      if (payload != null) 'payload': payload,
      if (status != null) 'status': status,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastAttemptAt != null) 'last_attempt_at': lastAttemptAt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SyncQueueTableCompanion copyWith({
    Value<int>? id,
    Value<String>? actionType,
    Value<String>? payload,
    Value<String>? status,
    Value<int>? retryCount,
    Value<DateTime?>? lastAttemptAt,
    Value<DateTime>? createdAt,
  }) {
    return SyncQueueTableCompanion(
      id: id ?? this.id,
      actionType: actionType ?? this.actionType,
      payload: payload ?? this.payload,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (actionType.present) {
      map['action_type'] = Variable<String>(actionType.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastAttemptAt.present) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueTableCompanion(')
          ..write('id: $id, ')
          ..write('actionType: $actionType, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SecondaryNumbersTableTable extends SecondaryNumbersTable
    with TableInfo<$SecondaryNumbersTableTable, SecondaryNumbersTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SecondaryNumbersTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _phoneNumberMeta = const VerificationMeta(
    'phoneNumber',
  );
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
    'phone_number',
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
    requiredDuringInsert: false,
    defaultValue: const Constant('whatsapp'),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, phoneNumber, type, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'secondary_numbers_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<SecondaryNumbersTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('phone_number')) {
      context.handle(
        _phoneNumberMeta,
        phoneNumber.isAcceptableOrUnknown(
          data['phone_number']!,
          _phoneNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_phoneNumberMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SecondaryNumbersTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SecondaryNumbersTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      phoneNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_number'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SecondaryNumbersTableTable createAlias(String alias) {
    return $SecondaryNumbersTableTable(attachedDatabase, alias);
  }
}

class SecondaryNumbersTableData extends DataClass
    implements Insertable<SecondaryNumbersTableData> {
  final int id;
  final String phoneNumber;
  final String type;
  final DateTime createdAt;
  const SecondaryNumbersTableData({
    required this.id,
    required this.phoneNumber,
    required this.type,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['phone_number'] = Variable<String>(phoneNumber);
    map['type'] = Variable<String>(type);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SecondaryNumbersTableCompanion toCompanion(bool nullToAbsent) {
    return SecondaryNumbersTableCompanion(
      id: Value(id),
      phoneNumber: Value(phoneNumber),
      type: Value(type),
      createdAt: Value(createdAt),
    );
  }

  factory SecondaryNumbersTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SecondaryNumbersTableData(
      id: serializer.fromJson<int>(json['id']),
      phoneNumber: serializer.fromJson<String>(json['phoneNumber']),
      type: serializer.fromJson<String>(json['type']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'phoneNumber': serializer.toJson<String>(phoneNumber),
      'type': serializer.toJson<String>(type),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SecondaryNumbersTableData copyWith({
    int? id,
    String? phoneNumber,
    String? type,
    DateTime? createdAt,
  }) => SecondaryNumbersTableData(
    id: id ?? this.id,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    type: type ?? this.type,
    createdAt: createdAt ?? this.createdAt,
  );
  SecondaryNumbersTableData copyWithCompanion(
    SecondaryNumbersTableCompanion data,
  ) {
    return SecondaryNumbersTableData(
      id: data.id.present ? data.id.value : this.id,
      phoneNumber: data.phoneNumber.present
          ? data.phoneNumber.value
          : this.phoneNumber,
      type: data.type.present ? data.type.value : this.type,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SecondaryNumbersTableData(')
          ..write('id: $id, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('type: $type, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, phoneNumber, type, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SecondaryNumbersTableData &&
          other.id == this.id &&
          other.phoneNumber == this.phoneNumber &&
          other.type == this.type &&
          other.createdAt == this.createdAt);
}

class SecondaryNumbersTableCompanion
    extends UpdateCompanion<SecondaryNumbersTableData> {
  final Value<int> id;
  final Value<String> phoneNumber;
  final Value<String> type;
  final Value<DateTime> createdAt;
  const SecondaryNumbersTableCompanion({
    this.id = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.type = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SecondaryNumbersTableCompanion.insert({
    this.id = const Value.absent(),
    required String phoneNumber,
    this.type = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : phoneNumber = Value(phoneNumber);
  static Insertable<SecondaryNumbersTableData> custom({
    Expression<int>? id,
    Expression<String>? phoneNumber,
    Expression<String>? type,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (type != null) 'type': type,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SecondaryNumbersTableCompanion copyWith({
    Value<int>? id,
    Value<String>? phoneNumber,
    Value<String>? type,
    Value<DateTime>? createdAt,
  }) {
    return SecondaryNumbersTableCompanion(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SecondaryNumbersTableCompanion(')
          ..write('id: $id, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('type: $type, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $UserProfilesTableTable extends UserProfilesTable
    with TableInfo<$UserProfilesTableTable, UserProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
    'local_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
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
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _businessTypeMeta = const VerificationMeta(
    'businessType',
  );
  @override
  late final GeneratedColumn<String> businessType = GeneratedColumn<String>(
    'business_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notificationCodeMeta = const VerificationMeta(
    'notificationCode',
  );
  @override
  late final GeneratedColumn<String> notificationCode = GeneratedColumn<String>(
    'notification_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trialStartDateMeta = const VerificationMeta(
    'trialStartDate',
  );
  @override
  late final GeneratedColumn<DateTime> trialStartDate =
      GeneratedColumn<DateTime>(
        'trial_start_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _trialEndDateMeta = const VerificationMeta(
    'trialEndDate',
  );
  @override
  late final GeneratedColumn<DateTime> trialEndDate = GeneratedColumn<DateTime>(
    'trial_end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subscriptionStartDateMeta =
      const VerificationMeta('subscriptionStartDate');
  @override
  late final GeneratedColumn<DateTime> subscriptionStartDate =
      GeneratedColumn<DateTime>(
        'subscription_start_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _subscriptionEndDateMeta =
      const VerificationMeta('subscriptionEndDate');
  @override
  late final GeneratedColumn<DateTime> subscriptionEndDate =
      GeneratedColumn<DateTime>(
        'subscription_end_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isSubscribedMeta = const VerificationMeta(
    'isSubscribed',
  );
  @override
  late final GeneratedColumn<bool> isSubscribed = GeneratedColumn<bool>(
    'is_subscribed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_subscribed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _subscriptionPlanMeta = const VerificationMeta(
    'subscriptionPlan',
  );
  @override
  late final GeneratedColumn<String> subscriptionPlan = GeneratedColumn<String>(
    'subscription_plan',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    id,
    name,
    email,
    phone,
    uuid,
    businessType,
    notificationCode,
    trialStartDate,
    trialEndDate,
    subscriptionStartDate,
    subscriptionEndDate,
    isSubscribed,
    subscriptionPlan,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    }
    if (data.containsKey('business_type')) {
      context.handle(
        _businessTypeMeta,
        businessType.isAcceptableOrUnknown(
          data['business_type']!,
          _businessTypeMeta,
        ),
      );
    }
    if (data.containsKey('notification_code')) {
      context.handle(
        _notificationCodeMeta,
        notificationCode.isAcceptableOrUnknown(
          data['notification_code']!,
          _notificationCodeMeta,
        ),
      );
    }
    if (data.containsKey('trial_start_date')) {
      context.handle(
        _trialStartDateMeta,
        trialStartDate.isAcceptableOrUnknown(
          data['trial_start_date']!,
          _trialStartDateMeta,
        ),
      );
    }
    if (data.containsKey('trial_end_date')) {
      context.handle(
        _trialEndDateMeta,
        trialEndDate.isAcceptableOrUnknown(
          data['trial_end_date']!,
          _trialEndDateMeta,
        ),
      );
    }
    if (data.containsKey('subscription_start_date')) {
      context.handle(
        _subscriptionStartDateMeta,
        subscriptionStartDate.isAcceptableOrUnknown(
          data['subscription_start_date']!,
          _subscriptionStartDateMeta,
        ),
      );
    }
    if (data.containsKey('subscription_end_date')) {
      context.handle(
        _subscriptionEndDateMeta,
        subscriptionEndDate.isAcceptableOrUnknown(
          data['subscription_end_date']!,
          _subscriptionEndDateMeta,
        ),
      );
    }
    if (data.containsKey('is_subscribed')) {
      context.handle(
        _isSubscribedMeta,
        isSubscribed.isAcceptableOrUnknown(
          data['is_subscribed']!,
          _isSubscribedMeta,
        ),
      );
    }
    if (data.containsKey('subscription_plan')) {
      context.handle(
        _subscriptionPlanMeta,
        subscriptionPlan.isAcceptableOrUnknown(
          data['subscription_plan']!,
          _subscriptionPlanMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  UserProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfile(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_id'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      ),
      businessType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_type'],
      ),
      notificationCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notification_code'],
      ),
      trialStartDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}trial_start_date'],
      ),
      trialEndDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}trial_end_date'],
      ),
      subscriptionStartDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}subscription_start_date'],
      ),
      subscriptionEndDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}subscription_end_date'],
      ),
      isSubscribed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_subscribed'],
      )!,
      subscriptionPlan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subscription_plan'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $UserProfilesTableTable createAlias(String alias) {
    return $UserProfilesTableTable(attachedDatabase, alias);
  }
}

class UserProfile extends DataClass implements Insertable<UserProfile> {
  final int localId;
  final String? id;
  final String name;
  final String? email;
  final String? phone;
  final String? uuid;
  final String? businessType;
  final String? notificationCode;
  final DateTime? trialStartDate;
  final DateTime? trialEndDate;
  final DateTime? subscriptionStartDate;
  final DateTime? subscriptionEndDate;
  final bool isSubscribed;
  final String? subscriptionPlan;
  final DateTime createdAt;
  const UserProfile({
    required this.localId,
    this.id,
    required this.name,
    this.email,
    this.phone,
    this.uuid,
    this.businessType,
    this.notificationCode,
    this.trialStartDate,
    this.trialEndDate,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
    required this.isSubscribed,
    this.subscriptionPlan,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<int>(localId);
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<String>(id);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || uuid != null) {
      map['uuid'] = Variable<String>(uuid);
    }
    if (!nullToAbsent || businessType != null) {
      map['business_type'] = Variable<String>(businessType);
    }
    if (!nullToAbsent || notificationCode != null) {
      map['notification_code'] = Variable<String>(notificationCode);
    }
    if (!nullToAbsent || trialStartDate != null) {
      map['trial_start_date'] = Variable<DateTime>(trialStartDate);
    }
    if (!nullToAbsent || trialEndDate != null) {
      map['trial_end_date'] = Variable<DateTime>(trialEndDate);
    }
    if (!nullToAbsent || subscriptionStartDate != null) {
      map['subscription_start_date'] = Variable<DateTime>(
        subscriptionStartDate,
      );
    }
    if (!nullToAbsent || subscriptionEndDate != null) {
      map['subscription_end_date'] = Variable<DateTime>(subscriptionEndDate);
    }
    map['is_subscribed'] = Variable<bool>(isSubscribed);
    if (!nullToAbsent || subscriptionPlan != null) {
      map['subscription_plan'] = Variable<String>(subscriptionPlan);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UserProfilesTableCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesTableCompanion(
      localId: Value(localId),
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      name: Value(name),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      uuid: uuid == null && nullToAbsent ? const Value.absent() : Value(uuid),
      businessType: businessType == null && nullToAbsent
          ? const Value.absent()
          : Value(businessType),
      notificationCode: notificationCode == null && nullToAbsent
          ? const Value.absent()
          : Value(notificationCode),
      trialStartDate: trialStartDate == null && nullToAbsent
          ? const Value.absent()
          : Value(trialStartDate),
      trialEndDate: trialEndDate == null && nullToAbsent
          ? const Value.absent()
          : Value(trialEndDate),
      subscriptionStartDate: subscriptionStartDate == null && nullToAbsent
          ? const Value.absent()
          : Value(subscriptionStartDate),
      subscriptionEndDate: subscriptionEndDate == null && nullToAbsent
          ? const Value.absent()
          : Value(subscriptionEndDate),
      isSubscribed: Value(isSubscribed),
      subscriptionPlan: subscriptionPlan == null && nullToAbsent
          ? const Value.absent()
          : Value(subscriptionPlan),
      createdAt: Value(createdAt),
    );
  }

  factory UserProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfile(
      localId: serializer.fromJson<int>(json['localId']),
      id: serializer.fromJson<String?>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String?>(json['email']),
      phone: serializer.fromJson<String?>(json['phone']),
      uuid: serializer.fromJson<String?>(json['uuid']),
      businessType: serializer.fromJson<String?>(json['businessType']),
      notificationCode: serializer.fromJson<String?>(json['notificationCode']),
      trialStartDate: serializer.fromJson<DateTime?>(json['trialStartDate']),
      trialEndDate: serializer.fromJson<DateTime?>(json['trialEndDate']),
      subscriptionStartDate: serializer.fromJson<DateTime?>(
        json['subscriptionStartDate'],
      ),
      subscriptionEndDate: serializer.fromJson<DateTime?>(
        json['subscriptionEndDate'],
      ),
      isSubscribed: serializer.fromJson<bool>(json['isSubscribed']),
      subscriptionPlan: serializer.fromJson<String?>(json['subscriptionPlan']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<int>(localId),
      'id': serializer.toJson<String?>(id),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String?>(email),
      'phone': serializer.toJson<String?>(phone),
      'uuid': serializer.toJson<String?>(uuid),
      'businessType': serializer.toJson<String?>(businessType),
      'notificationCode': serializer.toJson<String?>(notificationCode),
      'trialStartDate': serializer.toJson<DateTime?>(trialStartDate),
      'trialEndDate': serializer.toJson<DateTime?>(trialEndDate),
      'subscriptionStartDate': serializer.toJson<DateTime?>(
        subscriptionStartDate,
      ),
      'subscriptionEndDate': serializer.toJson<DateTime?>(subscriptionEndDate),
      'isSubscribed': serializer.toJson<bool>(isSubscribed),
      'subscriptionPlan': serializer.toJson<String?>(subscriptionPlan),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  UserProfile copyWith({
    int? localId,
    Value<String?> id = const Value.absent(),
    String? name,
    Value<String?> email = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> uuid = const Value.absent(),
    Value<String?> businessType = const Value.absent(),
    Value<String?> notificationCode = const Value.absent(),
    Value<DateTime?> trialStartDate = const Value.absent(),
    Value<DateTime?> trialEndDate = const Value.absent(),
    Value<DateTime?> subscriptionStartDate = const Value.absent(),
    Value<DateTime?> subscriptionEndDate = const Value.absent(),
    bool? isSubscribed,
    Value<String?> subscriptionPlan = const Value.absent(),
    DateTime? createdAt,
  }) => UserProfile(
    localId: localId ?? this.localId,
    id: id.present ? id.value : this.id,
    name: name ?? this.name,
    email: email.present ? email.value : this.email,
    phone: phone.present ? phone.value : this.phone,
    uuid: uuid.present ? uuid.value : this.uuid,
    businessType: businessType.present ? businessType.value : this.businessType,
    notificationCode: notificationCode.present
        ? notificationCode.value
        : this.notificationCode,
    trialStartDate: trialStartDate.present
        ? trialStartDate.value
        : this.trialStartDate,
    trialEndDate: trialEndDate.present ? trialEndDate.value : this.trialEndDate,
    subscriptionStartDate: subscriptionStartDate.present
        ? subscriptionStartDate.value
        : this.subscriptionStartDate,
    subscriptionEndDate: subscriptionEndDate.present
        ? subscriptionEndDate.value
        : this.subscriptionEndDate,
    isSubscribed: isSubscribed ?? this.isSubscribed,
    subscriptionPlan: subscriptionPlan.present
        ? subscriptionPlan.value
        : this.subscriptionPlan,
    createdAt: createdAt ?? this.createdAt,
  );
  UserProfile copyWithCompanion(UserProfilesTableCompanion data) {
    return UserProfile(
      localId: data.localId.present ? data.localId.value : this.localId,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      phone: data.phone.present ? data.phone.value : this.phone,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      businessType: data.businessType.present
          ? data.businessType.value
          : this.businessType,
      notificationCode: data.notificationCode.present
          ? data.notificationCode.value
          : this.notificationCode,
      trialStartDate: data.trialStartDate.present
          ? data.trialStartDate.value
          : this.trialStartDate,
      trialEndDate: data.trialEndDate.present
          ? data.trialEndDate.value
          : this.trialEndDate,
      subscriptionStartDate: data.subscriptionStartDate.present
          ? data.subscriptionStartDate.value
          : this.subscriptionStartDate,
      subscriptionEndDate: data.subscriptionEndDate.present
          ? data.subscriptionEndDate.value
          : this.subscriptionEndDate,
      isSubscribed: data.isSubscribed.present
          ? data.isSubscribed.value
          : this.isSubscribed,
      subscriptionPlan: data.subscriptionPlan.present
          ? data.subscriptionPlan.value
          : this.subscriptionPlan,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfile(')
          ..write('localId: $localId, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('uuid: $uuid, ')
          ..write('businessType: $businessType, ')
          ..write('notificationCode: $notificationCode, ')
          ..write('trialStartDate: $trialStartDate, ')
          ..write('trialEndDate: $trialEndDate, ')
          ..write('subscriptionStartDate: $subscriptionStartDate, ')
          ..write('subscriptionEndDate: $subscriptionEndDate, ')
          ..write('isSubscribed: $isSubscribed, ')
          ..write('subscriptionPlan: $subscriptionPlan, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    id,
    name,
    email,
    phone,
    uuid,
    businessType,
    notificationCode,
    trialStartDate,
    trialEndDate,
    subscriptionStartDate,
    subscriptionEndDate,
    isSubscribed,
    subscriptionPlan,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfile &&
          other.localId == this.localId &&
          other.id == this.id &&
          other.name == this.name &&
          other.email == this.email &&
          other.phone == this.phone &&
          other.uuid == this.uuid &&
          other.businessType == this.businessType &&
          other.notificationCode == this.notificationCode &&
          other.trialStartDate == this.trialStartDate &&
          other.trialEndDate == this.trialEndDate &&
          other.subscriptionStartDate == this.subscriptionStartDate &&
          other.subscriptionEndDate == this.subscriptionEndDate &&
          other.isSubscribed == this.isSubscribed &&
          other.subscriptionPlan == this.subscriptionPlan &&
          other.createdAt == this.createdAt);
}

class UserProfilesTableCompanion extends UpdateCompanion<UserProfile> {
  final Value<int> localId;
  final Value<String?> id;
  final Value<String> name;
  final Value<String?> email;
  final Value<String?> phone;
  final Value<String?> uuid;
  final Value<String?> businessType;
  final Value<String?> notificationCode;
  final Value<DateTime?> trialStartDate;
  final Value<DateTime?> trialEndDate;
  final Value<DateTime?> subscriptionStartDate;
  final Value<DateTime?> subscriptionEndDate;
  final Value<bool> isSubscribed;
  final Value<String?> subscriptionPlan;
  final Value<DateTime> createdAt;
  const UserProfilesTableCompanion({
    this.localId = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.uuid = const Value.absent(),
    this.businessType = const Value.absent(),
    this.notificationCode = const Value.absent(),
    this.trialStartDate = const Value.absent(),
    this.trialEndDate = const Value.absent(),
    this.subscriptionStartDate = const Value.absent(),
    this.subscriptionEndDate = const Value.absent(),
    this.isSubscribed = const Value.absent(),
    this.subscriptionPlan = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  UserProfilesTableCompanion.insert({
    this.localId = const Value.absent(),
    this.id = const Value.absent(),
    required String name,
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.uuid = const Value.absent(),
    this.businessType = const Value.absent(),
    this.notificationCode = const Value.absent(),
    this.trialStartDate = const Value.absent(),
    this.trialEndDate = const Value.absent(),
    this.subscriptionStartDate = const Value.absent(),
    this.subscriptionEndDate = const Value.absent(),
    this.isSubscribed = const Value.absent(),
    this.subscriptionPlan = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<UserProfile> custom({
    Expression<int>? localId,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? email,
    Expression<String>? phone,
    Expression<String>? uuid,
    Expression<String>? businessType,
    Expression<String>? notificationCode,
    Expression<DateTime>? trialStartDate,
    Expression<DateTime>? trialEndDate,
    Expression<DateTime>? subscriptionStartDate,
    Expression<DateTime>? subscriptionEndDate,
    Expression<bool>? isSubscribed,
    Expression<String>? subscriptionPlan,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (uuid != null) 'uuid': uuid,
      if (businessType != null) 'business_type': businessType,
      if (notificationCode != null) 'notification_code': notificationCode,
      if (trialStartDate != null) 'trial_start_date': trialStartDate,
      if (trialEndDate != null) 'trial_end_date': trialEndDate,
      if (subscriptionStartDate != null)
        'subscription_start_date': subscriptionStartDate,
      if (subscriptionEndDate != null)
        'subscription_end_date': subscriptionEndDate,
      if (isSubscribed != null) 'is_subscribed': isSubscribed,
      if (subscriptionPlan != null) 'subscription_plan': subscriptionPlan,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  UserProfilesTableCompanion copyWith({
    Value<int>? localId,
    Value<String?>? id,
    Value<String>? name,
    Value<String?>? email,
    Value<String?>? phone,
    Value<String?>? uuid,
    Value<String?>? businessType,
    Value<String?>? notificationCode,
    Value<DateTime?>? trialStartDate,
    Value<DateTime?>? trialEndDate,
    Value<DateTime?>? subscriptionStartDate,
    Value<DateTime?>? subscriptionEndDate,
    Value<bool>? isSubscribed,
    Value<String?>? subscriptionPlan,
    Value<DateTime>? createdAt,
  }) {
    return UserProfilesTableCompanion(
      localId: localId ?? this.localId,
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      uuid: uuid ?? this.uuid,
      businessType: businessType ?? this.businessType,
      notificationCode: notificationCode ?? this.notificationCode,
      trialStartDate: trialStartDate ?? this.trialStartDate,
      trialEndDate: trialEndDate ?? this.trialEndDate,
      subscriptionStartDate:
          subscriptionStartDate ?? this.subscriptionStartDate,
      subscriptionEndDate: subscriptionEndDate ?? this.subscriptionEndDate,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (businessType.present) {
      map['business_type'] = Variable<String>(businessType.value);
    }
    if (notificationCode.present) {
      map['notification_code'] = Variable<String>(notificationCode.value);
    }
    if (trialStartDate.present) {
      map['trial_start_date'] = Variable<DateTime>(trialStartDate.value);
    }
    if (trialEndDate.present) {
      map['trial_end_date'] = Variable<DateTime>(trialEndDate.value);
    }
    if (subscriptionStartDate.present) {
      map['subscription_start_date'] = Variable<DateTime>(
        subscriptionStartDate.value,
      );
    }
    if (subscriptionEndDate.present) {
      map['subscription_end_date'] = Variable<DateTime>(
        subscriptionEndDate.value,
      );
    }
    if (isSubscribed.present) {
      map['is_subscribed'] = Variable<bool>(isSubscribed.value);
    }
    if (subscriptionPlan.present) {
      map['subscription_plan'] = Variable<String>(subscriptionPlan.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesTableCompanion(')
          ..write('localId: $localId, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('uuid: $uuid, ')
          ..write('businessType: $businessType, ')
          ..write('notificationCode: $notificationCode, ')
          ..write('trialStartDate: $trialStartDate, ')
          ..write('trialEndDate: $trialEndDate, ')
          ..write('subscriptionStartDate: $subscriptionStartDate, ')
          ..write('subscriptionEndDate: $subscriptionEndDate, ')
          ..write('isSubscribed: $isSubscribed, ')
          ..write('subscriptionPlan: $subscriptionPlan, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PaymentsTableTable paymentsTable = $PaymentsTableTable(this);
  late final $DevicesTableTable devicesTable = $DevicesTableTable(this);
  late final $SyncQueueTableTable syncQueueTable = $SyncQueueTableTable(this);
  late final $SecondaryNumbersTableTable secondaryNumbersTable =
      $SecondaryNumbersTableTable(this);
  late final $UserProfilesTableTable userProfilesTable =
      $UserProfilesTableTable(this);
  late final PaymentDao paymentDao = PaymentDao(this as AppDatabase);
  late final DeviceDao deviceDao = DeviceDao(this as AppDatabase);
  late final SyncDao syncDao = SyncDao(this as AppDatabase);
  late final SecondaryNumberDao secondaryNumberDao = SecondaryNumberDao(
    this as AppDatabase,
  );
  late final UserProfileDao userProfileDao = UserProfileDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    paymentsTable,
    devicesTable,
    syncQueueTable,
    secondaryNumbersTable,
    userProfilesTable,
  ];
}

typedef $$PaymentsTableTableCreateCompanionBuilder =
    PaymentsTableCompanion Function({
      Value<int> id,
      required String externalId,
      required double amount,
      Value<String> currency,
      required String senderName,
      Value<DateTime> createdAt,
      Value<bool> isSynced,
      Value<String?> operationNumber,
      Value<String?> rawText,
    });
typedef $$PaymentsTableTableUpdateCompanionBuilder =
    PaymentsTableCompanion Function({
      Value<int> id,
      Value<String> externalId,
      Value<double> amount,
      Value<String> currency,
      Value<String> senderName,
      Value<DateTime> createdAt,
      Value<bool> isSynced,
      Value<String?> operationNumber,
      Value<String?> rawText,
    });

class $$PaymentsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTableTable> {
  $$PaymentsTableTableFilterComposer({
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

  ColumnFilters<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderName => $composableBuilder(
    column: $table.senderName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operationNumber => $composableBuilder(
    column: $table.operationNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawText => $composableBuilder(
    column: $table.rawText,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PaymentsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTableTable> {
  $$PaymentsTableTableOrderingComposer({
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

  ColumnOrderings<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderName => $composableBuilder(
    column: $table.senderName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operationNumber => $composableBuilder(
    column: $table.operationNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawText => $composableBuilder(
    column: $table.rawText,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PaymentsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTableTable> {
  $$PaymentsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get senderName => $composableBuilder(
    column: $table.senderName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get operationNumber => $composableBuilder(
    column: $table.operationNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawText =>
      $composableBuilder(column: $table.rawText, builder: (column) => column);
}

class $$PaymentsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentsTableTable,
          Payment,
          $$PaymentsTableTableFilterComposer,
          $$PaymentsTableTableOrderingComposer,
          $$PaymentsTableTableAnnotationComposer,
          $$PaymentsTableTableCreateCompanionBuilder,
          $$PaymentsTableTableUpdateCompanionBuilder,
          (
            Payment,
            BaseReferences<_$AppDatabase, $PaymentsTableTable, Payment>,
          ),
          Payment,
          PrefetchHooks Function()
        > {
  $$PaymentsTableTableTableManager(_$AppDatabase db, $PaymentsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> externalId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> senderName = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<String?> operationNumber = const Value.absent(),
                Value<String?> rawText = const Value.absent(),
              }) => PaymentsTableCompanion(
                id: id,
                externalId: externalId,
                amount: amount,
                currency: currency,
                senderName: senderName,
                createdAt: createdAt,
                isSynced: isSynced,
                operationNumber: operationNumber,
                rawText: rawText,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String externalId,
                required double amount,
                Value<String> currency = const Value.absent(),
                required String senderName,
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<String?> operationNumber = const Value.absent(),
                Value<String?> rawText = const Value.absent(),
              }) => PaymentsTableCompanion.insert(
                id: id,
                externalId: externalId,
                amount: amount,
                currency: currency,
                senderName: senderName,
                createdAt: createdAt,
                isSynced: isSynced,
                operationNumber: operationNumber,
                rawText: rawText,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PaymentsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentsTableTable,
      Payment,
      $$PaymentsTableTableFilterComposer,
      $$PaymentsTableTableOrderingComposer,
      $$PaymentsTableTableAnnotationComposer,
      $$PaymentsTableTableCreateCompanionBuilder,
      $$PaymentsTableTableUpdateCompanionBuilder,
      (Payment, BaseReferences<_$AppDatabase, $PaymentsTableTable, Payment>),
      Payment,
      PrefetchHooks Function()
    >;
typedef $$DevicesTableTableCreateCompanionBuilder =
    DevicesTableCompanion Function({
      Value<int> id,
      required String uuid,
      required String alias,
      Value<bool> isApproved,
      Value<DateTime?> lastConnectedAt,
    });
typedef $$DevicesTableTableUpdateCompanionBuilder =
    DevicesTableCompanion Function({
      Value<int> id,
      Value<String> uuid,
      Value<String> alias,
      Value<bool> isApproved,
      Value<DateTime?> lastConnectedAt,
    });

class $$DevicesTableTableFilterComposer
    extends Composer<_$AppDatabase, $DevicesTableTable> {
  $$DevicesTableTableFilterComposer({
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

  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alias => $composableBuilder(
    column: $table.alias,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isApproved => $composableBuilder(
    column: $table.isApproved,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastConnectedAt => $composableBuilder(
    column: $table.lastConnectedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DevicesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DevicesTableTable> {
  $$DevicesTableTableOrderingComposer({
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

  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alias => $composableBuilder(
    column: $table.alias,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isApproved => $composableBuilder(
    column: $table.isApproved,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastConnectedAt => $composableBuilder(
    column: $table.lastConnectedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DevicesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DevicesTableTable> {
  $$DevicesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get alias =>
      $composableBuilder(column: $table.alias, builder: (column) => column);

  GeneratedColumn<bool> get isApproved => $composableBuilder(
    column: $table.isApproved,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastConnectedAt => $composableBuilder(
    column: $table.lastConnectedAt,
    builder: (column) => column,
  );
}

class $$DevicesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DevicesTableTable,
          Device,
          $$DevicesTableTableFilterComposer,
          $$DevicesTableTableOrderingComposer,
          $$DevicesTableTableAnnotationComposer,
          $$DevicesTableTableCreateCompanionBuilder,
          $$DevicesTableTableUpdateCompanionBuilder,
          (Device, BaseReferences<_$AppDatabase, $DevicesTableTable, Device>),
          Device,
          PrefetchHooks Function()
        > {
  $$DevicesTableTableTableManager(_$AppDatabase db, $DevicesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DevicesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DevicesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DevicesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<String> alias = const Value.absent(),
                Value<bool> isApproved = const Value.absent(),
                Value<DateTime?> lastConnectedAt = const Value.absent(),
              }) => DevicesTableCompanion(
                id: id,
                uuid: uuid,
                alias: alias,
                isApproved: isApproved,
                lastConnectedAt: lastConnectedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uuid,
                required String alias,
                Value<bool> isApproved = const Value.absent(),
                Value<DateTime?> lastConnectedAt = const Value.absent(),
              }) => DevicesTableCompanion.insert(
                id: id,
                uuid: uuid,
                alias: alias,
                isApproved: isApproved,
                lastConnectedAt: lastConnectedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DevicesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DevicesTableTable,
      Device,
      $$DevicesTableTableFilterComposer,
      $$DevicesTableTableOrderingComposer,
      $$DevicesTableTableAnnotationComposer,
      $$DevicesTableTableCreateCompanionBuilder,
      $$DevicesTableTableUpdateCompanionBuilder,
      (Device, BaseReferences<_$AppDatabase, $DevicesTableTable, Device>),
      Device,
      PrefetchHooks Function()
    >;
typedef $$SyncQueueTableTableCreateCompanionBuilder =
    SyncQueueTableCompanion Function({
      Value<int> id,
      required String actionType,
      required String payload,
      Value<String> status,
      Value<int> retryCount,
      Value<DateTime?> lastAttemptAt,
      Value<DateTime> createdAt,
    });
typedef $$SyncQueueTableTableUpdateCompanionBuilder =
    SyncQueueTableCompanion Function({
      Value<int> id,
      Value<String> actionType,
      Value<String> payload,
      Value<String> status,
      Value<int> retryCount,
      Value<DateTime?> lastAttemptAt,
      Value<DateTime> createdAt,
    });

class $$SyncQueueTableTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTableTable> {
  $$SyncQueueTableTableFilterComposer({
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

  ColumnFilters<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTableTable> {
  $$SyncQueueTableTableOrderingComposer({
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

  ColumnOrderings<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTableTable> {
  $$SyncQueueTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SyncQueueTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueTableTable,
          SyncQueueTableData,
          $$SyncQueueTableTableFilterComposer,
          $$SyncQueueTableTableOrderingComposer,
          $$SyncQueueTableTableAnnotationComposer,
          $$SyncQueueTableTableCreateCompanionBuilder,
          $$SyncQueueTableTableUpdateCompanionBuilder,
          (
            SyncQueueTableData,
            BaseReferences<
              _$AppDatabase,
              $SyncQueueTableTable,
              SyncQueueTableData
            >,
          ),
          SyncQueueTableData,
          PrefetchHooks Function()
        > {
  $$SyncQueueTableTableTableManager(
    _$AppDatabase db,
    $SyncQueueTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> actionType = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SyncQueueTableCompanion(
                id: id,
                actionType: actionType,
                payload: payload,
                status: status,
                retryCount: retryCount,
                lastAttemptAt: lastAttemptAt,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String actionType,
                required String payload,
                Value<String> status = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SyncQueueTableCompanion.insert(
                id: id,
                actionType: actionType,
                payload: payload,
                status: status,
                retryCount: retryCount,
                lastAttemptAt: lastAttemptAt,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueTableTable,
      SyncQueueTableData,
      $$SyncQueueTableTableFilterComposer,
      $$SyncQueueTableTableOrderingComposer,
      $$SyncQueueTableTableAnnotationComposer,
      $$SyncQueueTableTableCreateCompanionBuilder,
      $$SyncQueueTableTableUpdateCompanionBuilder,
      (
        SyncQueueTableData,
        BaseReferences<_$AppDatabase, $SyncQueueTableTable, SyncQueueTableData>,
      ),
      SyncQueueTableData,
      PrefetchHooks Function()
    >;
typedef $$SecondaryNumbersTableTableCreateCompanionBuilder =
    SecondaryNumbersTableCompanion Function({
      Value<int> id,
      required String phoneNumber,
      Value<String> type,
      Value<DateTime> createdAt,
    });
typedef $$SecondaryNumbersTableTableUpdateCompanionBuilder =
    SecondaryNumbersTableCompanion Function({
      Value<int> id,
      Value<String> phoneNumber,
      Value<String> type,
      Value<DateTime> createdAt,
    });

class $$SecondaryNumbersTableTableFilterComposer
    extends Composer<_$AppDatabase, $SecondaryNumbersTableTable> {
  $$SecondaryNumbersTableTableFilterComposer({
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

  ColumnFilters<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SecondaryNumbersTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SecondaryNumbersTableTable> {
  $$SecondaryNumbersTableTableOrderingComposer({
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

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SecondaryNumbersTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SecondaryNumbersTableTable> {
  $$SecondaryNumbersTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SecondaryNumbersTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SecondaryNumbersTableTable,
          SecondaryNumbersTableData,
          $$SecondaryNumbersTableTableFilterComposer,
          $$SecondaryNumbersTableTableOrderingComposer,
          $$SecondaryNumbersTableTableAnnotationComposer,
          $$SecondaryNumbersTableTableCreateCompanionBuilder,
          $$SecondaryNumbersTableTableUpdateCompanionBuilder,
          (
            SecondaryNumbersTableData,
            BaseReferences<
              _$AppDatabase,
              $SecondaryNumbersTableTable,
              SecondaryNumbersTableData
            >,
          ),
          SecondaryNumbersTableData,
          PrefetchHooks Function()
        > {
  $$SecondaryNumbersTableTableTableManager(
    _$AppDatabase db,
    $SecondaryNumbersTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SecondaryNumbersTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$SecondaryNumbersTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SecondaryNumbersTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> phoneNumber = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SecondaryNumbersTableCompanion(
                id: id,
                phoneNumber: phoneNumber,
                type: type,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String phoneNumber,
                Value<String> type = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SecondaryNumbersTableCompanion.insert(
                id: id,
                phoneNumber: phoneNumber,
                type: type,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SecondaryNumbersTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SecondaryNumbersTableTable,
      SecondaryNumbersTableData,
      $$SecondaryNumbersTableTableFilterComposer,
      $$SecondaryNumbersTableTableOrderingComposer,
      $$SecondaryNumbersTableTableAnnotationComposer,
      $$SecondaryNumbersTableTableCreateCompanionBuilder,
      $$SecondaryNumbersTableTableUpdateCompanionBuilder,
      (
        SecondaryNumbersTableData,
        BaseReferences<
          _$AppDatabase,
          $SecondaryNumbersTableTable,
          SecondaryNumbersTableData
        >,
      ),
      SecondaryNumbersTableData,
      PrefetchHooks Function()
    >;
typedef $$UserProfilesTableTableCreateCompanionBuilder =
    UserProfilesTableCompanion Function({
      Value<int> localId,
      Value<String?> id,
      required String name,
      Value<String?> email,
      Value<String?> phone,
      Value<String?> uuid,
      Value<String?> businessType,
      Value<String?> notificationCode,
      Value<DateTime?> trialStartDate,
      Value<DateTime?> trialEndDate,
      Value<DateTime?> subscriptionStartDate,
      Value<DateTime?> subscriptionEndDate,
      Value<bool> isSubscribed,
      Value<String?> subscriptionPlan,
      Value<DateTime> createdAt,
    });
typedef $$UserProfilesTableTableUpdateCompanionBuilder =
    UserProfilesTableCompanion Function({
      Value<int> localId,
      Value<String?> id,
      Value<String> name,
      Value<String?> email,
      Value<String?> phone,
      Value<String?> uuid,
      Value<String?> businessType,
      Value<String?> notificationCode,
      Value<DateTime?> trialStartDate,
      Value<DateTime?> trialEndDate,
      Value<DateTime?> subscriptionStartDate,
      Value<DateTime?> subscriptionEndDate,
      Value<bool> isSubscribed,
      Value<String?> subscriptionPlan,
      Value<DateTime> createdAt,
    });

class $$UserProfilesTableTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTableTable> {
  $$UserProfilesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessType => $composableBuilder(
    column: $table.businessType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notificationCode => $composableBuilder(
    column: $table.notificationCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get trialStartDate => $composableBuilder(
    column: $table.trialStartDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get trialEndDate => $composableBuilder(
    column: $table.trialEndDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get subscriptionStartDate => $composableBuilder(
    column: $table.subscriptionStartDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get subscriptionEndDate => $composableBuilder(
    column: $table.subscriptionEndDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSubscribed => $composableBuilder(
    column: $table.isSubscribed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subscriptionPlan => $composableBuilder(
    column: $table.subscriptionPlan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProfilesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTableTable> {
  $$UserProfilesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessType => $composableBuilder(
    column: $table.businessType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notificationCode => $composableBuilder(
    column: $table.notificationCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get trialStartDate => $composableBuilder(
    column: $table.trialStartDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get trialEndDate => $composableBuilder(
    column: $table.trialEndDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get subscriptionStartDate => $composableBuilder(
    column: $table.subscriptionStartDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get subscriptionEndDate => $composableBuilder(
    column: $table.subscriptionEndDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSubscribed => $composableBuilder(
    column: $table.isSubscribed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subscriptionPlan => $composableBuilder(
    column: $table.subscriptionPlan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfilesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTableTable> {
  $$UserProfilesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get businessType => $composableBuilder(
    column: $table.businessType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notificationCode => $composableBuilder(
    column: $table.notificationCode,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get trialStartDate => $composableBuilder(
    column: $table.trialStartDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get trialEndDate => $composableBuilder(
    column: $table.trialEndDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get subscriptionStartDate => $composableBuilder(
    column: $table.subscriptionStartDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get subscriptionEndDate => $composableBuilder(
    column: $table.subscriptionEndDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSubscribed => $composableBuilder(
    column: $table.isSubscribed,
    builder: (column) => column,
  );

  GeneratedColumn<String> get subscriptionPlan => $composableBuilder(
    column: $table.subscriptionPlan,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$UserProfilesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfilesTableTable,
          UserProfile,
          $$UserProfilesTableTableFilterComposer,
          $$UserProfilesTableTableOrderingComposer,
          $$UserProfilesTableTableAnnotationComposer,
          $$UserProfilesTableTableCreateCompanionBuilder,
          $$UserProfilesTableTableUpdateCompanionBuilder,
          (
            UserProfile,
            BaseReferences<_$AppDatabase, $UserProfilesTableTable, UserProfile>,
          ),
          UserProfile,
          PrefetchHooks Function()
        > {
  $$UserProfilesTableTableTableManager(
    _$AppDatabase db,
    $UserProfilesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<String?> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> uuid = const Value.absent(),
                Value<String?> businessType = const Value.absent(),
                Value<String?> notificationCode = const Value.absent(),
                Value<DateTime?> trialStartDate = const Value.absent(),
                Value<DateTime?> trialEndDate = const Value.absent(),
                Value<DateTime?> subscriptionStartDate = const Value.absent(),
                Value<DateTime?> subscriptionEndDate = const Value.absent(),
                Value<bool> isSubscribed = const Value.absent(),
                Value<String?> subscriptionPlan = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => UserProfilesTableCompanion(
                localId: localId,
                id: id,
                name: name,
                email: email,
                phone: phone,
                uuid: uuid,
                businessType: businessType,
                notificationCode: notificationCode,
                trialStartDate: trialStartDate,
                trialEndDate: trialEndDate,
                subscriptionStartDate: subscriptionStartDate,
                subscriptionEndDate: subscriptionEndDate,
                isSubscribed: isSubscribed,
                subscriptionPlan: subscriptionPlan,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<String?> id = const Value.absent(),
                required String name,
                Value<String?> email = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> uuid = const Value.absent(),
                Value<String?> businessType = const Value.absent(),
                Value<String?> notificationCode = const Value.absent(),
                Value<DateTime?> trialStartDate = const Value.absent(),
                Value<DateTime?> trialEndDate = const Value.absent(),
                Value<DateTime?> subscriptionStartDate = const Value.absent(),
                Value<DateTime?> subscriptionEndDate = const Value.absent(),
                Value<bool> isSubscribed = const Value.absent(),
                Value<String?> subscriptionPlan = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => UserProfilesTableCompanion.insert(
                localId: localId,
                id: id,
                name: name,
                email: email,
                phone: phone,
                uuid: uuid,
                businessType: businessType,
                notificationCode: notificationCode,
                trialStartDate: trialStartDate,
                trialEndDate: trialEndDate,
                subscriptionStartDate: subscriptionStartDate,
                subscriptionEndDate: subscriptionEndDate,
                isSubscribed: isSubscribed,
                subscriptionPlan: subscriptionPlan,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProfilesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfilesTableTable,
      UserProfile,
      $$UserProfilesTableTableFilterComposer,
      $$UserProfilesTableTableOrderingComposer,
      $$UserProfilesTableTableAnnotationComposer,
      $$UserProfilesTableTableCreateCompanionBuilder,
      $$UserProfilesTableTableUpdateCompanionBuilder,
      (
        UserProfile,
        BaseReferences<_$AppDatabase, $UserProfilesTableTable, UserProfile>,
      ),
      UserProfile,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PaymentsTableTableTableManager get paymentsTable =>
      $$PaymentsTableTableTableManager(_db, _db.paymentsTable);
  $$DevicesTableTableTableManager get devicesTable =>
      $$DevicesTableTableTableManager(_db, _db.devicesTable);
  $$SyncQueueTableTableTableManager get syncQueueTable =>
      $$SyncQueueTableTableTableManager(_db, _db.syncQueueTable);
  $$SecondaryNumbersTableTableTableManager get secondaryNumbersTable =>
      $$SecondaryNumbersTableTableTableManager(_db, _db.secondaryNumbersTable);
  $$UserProfilesTableTableTableManager get userProfilesTable =>
      $$UserProfilesTableTableTableManager(_db, _db.userProfilesTable);
}

mixin _$PaymentDaoMixin on DatabaseAccessor<AppDatabase> {
  $PaymentsTableTable get paymentsTable => attachedDatabase.paymentsTable;
  PaymentDaoManager get managers => PaymentDaoManager(this);
}

class PaymentDaoManager {
  final _$PaymentDaoMixin _db;
  PaymentDaoManager(this._db);
  $$PaymentsTableTableTableManager get paymentsTable =>
      $$PaymentsTableTableTableManager(_db.attachedDatabase, _db.paymentsTable);
}

mixin _$DeviceDaoMixin on DatabaseAccessor<AppDatabase> {
  $DevicesTableTable get devicesTable => attachedDatabase.devicesTable;
  DeviceDaoManager get managers => DeviceDaoManager(this);
}

class DeviceDaoManager {
  final _$DeviceDaoMixin _db;
  DeviceDaoManager(this._db);
  $$DevicesTableTableTableManager get devicesTable =>
      $$DevicesTableTableTableManager(_db.attachedDatabase, _db.devicesTable);
}

mixin _$SyncDaoMixin on DatabaseAccessor<AppDatabase> {
  $SyncQueueTableTable get syncQueueTable => attachedDatabase.syncQueueTable;
  SyncDaoManager get managers => SyncDaoManager(this);
}

class SyncDaoManager {
  final _$SyncDaoMixin _db;
  SyncDaoManager(this._db);
  $$SyncQueueTableTableTableManager get syncQueueTable =>
      $$SyncQueueTableTableTableManager(
        _db.attachedDatabase,
        _db.syncQueueTable,
      );
}

mixin _$SecondaryNumberDaoMixin on DatabaseAccessor<AppDatabase> {
  $SecondaryNumbersTableTable get secondaryNumbersTable =>
      attachedDatabase.secondaryNumbersTable;
  SecondaryNumberDaoManager get managers => SecondaryNumberDaoManager(this);
}

class SecondaryNumberDaoManager {
  final _$SecondaryNumberDaoMixin _db;
  SecondaryNumberDaoManager(this._db);
  $$SecondaryNumbersTableTableTableManager get secondaryNumbersTable =>
      $$SecondaryNumbersTableTableTableManager(
        _db.attachedDatabase,
        _db.secondaryNumbersTable,
      );
}

mixin _$UserProfileDaoMixin on DatabaseAccessor<AppDatabase> {
  $UserProfilesTableTable get userProfilesTable =>
      attachedDatabase.userProfilesTable;
  UserProfileDaoManager get managers => UserProfileDaoManager(this);
}

class UserProfileDaoManager {
  final _$UserProfileDaoMixin _db;
  UserProfileDaoManager(this._db);
  $$UserProfilesTableTableTableManager get userProfilesTable =>
      $$UserProfilesTableTableTableManager(
        _db.attachedDatabase,
        _db.userProfilesTable,
      );
}
