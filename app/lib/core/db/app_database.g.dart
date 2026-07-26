// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
mixin _$ExerciseDaoMixin on DatabaseAccessor<AppDatabase> {
  $ExercisesTable get exercises => attachedDatabase.exercises;
  ExerciseDaoManager get managers => ExerciseDaoManager(this);
}

class ExerciseDaoManager {
  final _$ExerciseDaoMixin _db;
  ExerciseDaoManager(this._db);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db.attachedDatabase, _db.exercises);
}

class $AppMetaTable extends AppMeta with TableInfo<$AppMetaTable, AppMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppMetaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppMetaData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppMetaTable createAlias(String alias) {
    return $AppMetaTable(attachedDatabase, alias);
  }
}

class AppMetaData extends DataClass implements Insertable<AppMetaData> {
  final String key;
  final String value;
  const AppMetaData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppMetaCompanion toCompanion(bool nullToAbsent) {
    return AppMetaCompanion(key: Value(key), value: Value(value));
  }

  factory AppMetaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppMetaData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppMetaData copyWith({String? key, String? value}) =>
      AppMetaData(key: key ?? this.key, value: value ?? this.value);
  AppMetaData copyWithCompanion(AppMetaCompanion data) {
    return AppMetaData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppMetaData &&
          other.key == this.key &&
          other.value == this.value);
}

class AppMetaCompanion extends UpdateCompanion<AppMetaData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppMetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppMetaCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppMetaData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppMetaCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppMetaCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _onboardingDoneMeta = const VerificationMeta(
    'onboardingDone',
  );
  @override
  late final GeneratedColumn<bool> onboardingDone = GeneratedColumn<bool>(
    'onboarding_done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("onboarding_done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, json, onboardingDone];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    if (data.containsKey('onboarding_done')) {
      context.handle(
        _onboardingDoneMeta,
        onboardingDone.isAcceptableOrUnknown(
          data['onboarding_done']!,
          _onboardingDoneMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfileRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
      onboardingDone: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}onboarding_done'],
      )!,
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }
}

class UserProfileRow extends DataClass implements Insertable<UserProfileRow> {
  final int id;
  final String json;
  final bool onboardingDone;
  const UserProfileRow({
    required this.id,
    required this.json,
    required this.onboardingDone,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['json'] = Variable<String>(json);
    map['onboarding_done'] = Variable<bool>(onboardingDone);
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      id: Value(id),
      json: Value(json),
      onboardingDone: Value(onboardingDone),
    );
  }

  factory UserProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfileRow(
      id: serializer.fromJson<int>(json['id']),
      json: serializer.fromJson<String>(json['json']),
      onboardingDone: serializer.fromJson<bool>(json['onboardingDone']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'json': serializer.toJson<String>(json),
      'onboardingDone': serializer.toJson<bool>(onboardingDone),
    };
  }

  UserProfileRow copyWith({int? id, String? json, bool? onboardingDone}) =>
      UserProfileRow(
        id: id ?? this.id,
        json: json ?? this.json,
        onboardingDone: onboardingDone ?? this.onboardingDone,
      );
  UserProfileRow copyWithCompanion(UserProfilesCompanion data) {
    return UserProfileRow(
      id: data.id.present ? data.id.value : this.id,
      json: data.json.present ? data.json.value : this.json,
      onboardingDone: data.onboardingDone.present
          ? data.onboardingDone.value
          : this.onboardingDone,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfileRow(')
          ..write('id: $id, ')
          ..write('json: $json, ')
          ..write('onboardingDone: $onboardingDone')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, json, onboardingDone);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfileRow &&
          other.id == this.id &&
          other.json == this.json &&
          other.onboardingDone == this.onboardingDone);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfileRow> {
  final Value<int> id;
  final Value<String> json;
  final Value<bool> onboardingDone;
  const UserProfilesCompanion({
    this.id = const Value.absent(),
    this.json = const Value.absent(),
    this.onboardingDone = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String json,
    this.onboardingDone = const Value.absent(),
  }) : json = Value(json);
  static Insertable<UserProfileRow> custom({
    Expression<int>? id,
    Expression<String>? json,
    Expression<bool>? onboardingDone,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (json != null) 'json': json,
      if (onboardingDone != null) 'onboarding_done': onboardingDone,
    });
  }

  UserProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? json,
    Value<bool>? onboardingDone,
  }) {
    return UserProfilesCompanion(
      id: id ?? this.id,
      json: json ?? this.json,
      onboardingDone: onboardingDone ?? this.onboardingDone,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (onboardingDone.present) {
      map['onboarding_done'] = Variable<bool>(onboardingDone.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('id: $id, ')
          ..write('json: $json, ')
          ..write('onboardingDone: $onboardingDone')
          ..write(')'))
        .toString();
  }
}

class $ActivePlansTable extends ActivePlans
    with TableInfo<$ActivePlansTable, ActivePlanRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivePlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, json, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'active_plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActivePlanRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
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
  ActivePlanRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivePlanRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ActivePlansTable createAlias(String alias) {
    return $ActivePlansTable(attachedDatabase, alias);
  }
}

class ActivePlanRow extends DataClass implements Insertable<ActivePlanRow> {
  final String id;
  final String json;
  final DateTime createdAt;
  const ActivePlanRow({
    required this.id,
    required this.json,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['json'] = Variable<String>(json);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ActivePlansCompanion toCompanion(bool nullToAbsent) {
    return ActivePlansCompanion(
      id: Value(id),
      json: Value(json),
      createdAt: Value(createdAt),
    );
  }

  factory ActivePlanRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivePlanRow(
      id: serializer.fromJson<String>(json['id']),
      json: serializer.fromJson<String>(json['json']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'json': serializer.toJson<String>(json),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ActivePlanRow copyWith({String? id, String? json, DateTime? createdAt}) =>
      ActivePlanRow(
        id: id ?? this.id,
        json: json ?? this.json,
        createdAt: createdAt ?? this.createdAt,
      );
  ActivePlanRow copyWithCompanion(ActivePlansCompanion data) {
    return ActivePlanRow(
      id: data.id.present ? data.id.value : this.id,
      json: data.json.present ? data.json.value : this.json,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivePlanRow(')
          ..write('id: $id, ')
          ..write('json: $json, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, json, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivePlanRow &&
          other.id == this.id &&
          other.json == this.json &&
          other.createdAt == this.createdAt);
}

class ActivePlansCompanion extends UpdateCompanion<ActivePlanRow> {
  final Value<String> id;
  final Value<String> json;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ActivePlansCompanion({
    this.id = const Value.absent(),
    this.json = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivePlansCompanion.insert({
    required String id,
    required String json,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       json = Value(json),
       createdAt = Value(createdAt);
  static Insertable<ActivePlanRow> custom({
    Expression<String>? id,
    Expression<String>? json,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (json != null) 'json': json,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivePlansCompanion copyWith({
    Value<String>? id,
    Value<String>? json,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ActivePlansCompanion(
      id: id ?? this.id,
      json: json ?? this.json,
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
    if (json.present) {
      map['json'] = Variable<String>(json.value);
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
    return (StringBuffer('ActivePlansCompanion(')
          ..write('id: $id, ')
          ..write('json: $json, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlannedSessionsTable extends PlannedSessions
    with TableInfo<$PlannedSessionsTable, PlannedSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlannedSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<String> planId = GeneratedColumn<String>(
    'plan_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sequenceIndexMeta = const VerificationMeta(
    'sequenceIndex',
  );
  @override
  late final GeneratedColumn<int> sequenceIndex = GeneratedColumn<int>(
    'sequence_index',
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
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, planId, sequenceIndex, type, json];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'planned_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlannedSessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('plan_id')) {
      context.handle(
        _planIdMeta,
        planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta),
      );
    } else if (isInserting) {
      context.missing(_planIdMeta);
    }
    if (data.containsKey('sequence_index')) {
      context.handle(
        _sequenceIndexMeta,
        sequenceIndex.isAcceptableOrUnknown(
          data['sequence_index']!,
          _sequenceIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sequenceIndexMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlannedSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlannedSessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      planId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_id'],
      )!,
      sequenceIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence_index'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
    );
  }

  @override
  $PlannedSessionsTable createAlias(String alias) {
    return $PlannedSessionsTable(attachedDatabase, alias);
  }
}

class PlannedSessionRow extends DataClass
    implements Insertable<PlannedSessionRow> {
  final String id;
  final String planId;
  final int sequenceIndex;
  final String type;
  final String json;
  const PlannedSessionRow({
    required this.id,
    required this.planId,
    required this.sequenceIndex,
    required this.type,
    required this.json,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['plan_id'] = Variable<String>(planId);
    map['sequence_index'] = Variable<int>(sequenceIndex);
    map['type'] = Variable<String>(type);
    map['json'] = Variable<String>(json);
    return map;
  }

  PlannedSessionsCompanion toCompanion(bool nullToAbsent) {
    return PlannedSessionsCompanion(
      id: Value(id),
      planId: Value(planId),
      sequenceIndex: Value(sequenceIndex),
      type: Value(type),
      json: Value(json),
    );
  }

  factory PlannedSessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlannedSessionRow(
      id: serializer.fromJson<String>(json['id']),
      planId: serializer.fromJson<String>(json['planId']),
      sequenceIndex: serializer.fromJson<int>(json['sequenceIndex']),
      type: serializer.fromJson<String>(json['type']),
      json: serializer.fromJson<String>(json['json']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'planId': serializer.toJson<String>(planId),
      'sequenceIndex': serializer.toJson<int>(sequenceIndex),
      'type': serializer.toJson<String>(type),
      'json': serializer.toJson<String>(json),
    };
  }

  PlannedSessionRow copyWith({
    String? id,
    String? planId,
    int? sequenceIndex,
    String? type,
    String? json,
  }) => PlannedSessionRow(
    id: id ?? this.id,
    planId: planId ?? this.planId,
    sequenceIndex: sequenceIndex ?? this.sequenceIndex,
    type: type ?? this.type,
    json: json ?? this.json,
  );
  PlannedSessionRow copyWithCompanion(PlannedSessionsCompanion data) {
    return PlannedSessionRow(
      id: data.id.present ? data.id.value : this.id,
      planId: data.planId.present ? data.planId.value : this.planId,
      sequenceIndex: data.sequenceIndex.present
          ? data.sequenceIndex.value
          : this.sequenceIndex,
      type: data.type.present ? data.type.value : this.type,
      json: data.json.present ? data.json.value : this.json,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlannedSessionRow(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('sequenceIndex: $sequenceIndex, ')
          ..write('type: $type, ')
          ..write('json: $json')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, planId, sequenceIndex, type, json);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlannedSessionRow &&
          other.id == this.id &&
          other.planId == this.planId &&
          other.sequenceIndex == this.sequenceIndex &&
          other.type == this.type &&
          other.json == this.json);
}

class PlannedSessionsCompanion extends UpdateCompanion<PlannedSessionRow> {
  final Value<String> id;
  final Value<String> planId;
  final Value<int> sequenceIndex;
  final Value<String> type;
  final Value<String> json;
  final Value<int> rowid;
  const PlannedSessionsCompanion({
    this.id = const Value.absent(),
    this.planId = const Value.absent(),
    this.sequenceIndex = const Value.absent(),
    this.type = const Value.absent(),
    this.json = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlannedSessionsCompanion.insert({
    required String id,
    required String planId,
    required int sequenceIndex,
    required String type,
    required String json,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       planId = Value(planId),
       sequenceIndex = Value(sequenceIndex),
       type = Value(type),
       json = Value(json);
  static Insertable<PlannedSessionRow> custom({
    Expression<String>? id,
    Expression<String>? planId,
    Expression<int>? sequenceIndex,
    Expression<String>? type,
    Expression<String>? json,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (planId != null) 'plan_id': planId,
      if (sequenceIndex != null) 'sequence_index': sequenceIndex,
      if (type != null) 'type': type,
      if (json != null) 'json': json,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlannedSessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? planId,
    Value<int>? sequenceIndex,
    Value<String>? type,
    Value<String>? json,
    Value<int>? rowid,
  }) {
    return PlannedSessionsCompanion(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      sequenceIndex: sequenceIndex ?? this.sequenceIndex,
      type: type ?? this.type,
      json: json ?? this.json,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<String>(planId.value);
    }
    if (sequenceIndex.present) {
      map['sequence_index'] = Variable<int>(sequenceIndex.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlannedSessionsCompanion(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('sequenceIndex: $sequenceIndex, ')
          ..write('type: $type, ')
          ..write('json: $json, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutLogsTable extends WorkoutLogs
    with TableInfo<$WorkoutLogsTable, WorkoutLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
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
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    date,
    type,
    status,
    json,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutLogRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
    );
  }

  @override
  $WorkoutLogsTable createAlias(String alias) {
    return $WorkoutLogsTable(attachedDatabase, alias);
  }
}

class WorkoutLogRow extends DataClass implements Insertable<WorkoutLogRow> {
  final String id;
  final String sessionId;
  final String date;
  final String type;
  final String status;
  final String json;
  final DateTime completedAt;
  const WorkoutLogRow({
    required this.id,
    required this.sessionId,
    required this.date,
    required this.type,
    required this.status,
    required this.json,
    required this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['date'] = Variable<String>(date);
    map['type'] = Variable<String>(type);
    map['status'] = Variable<String>(status);
    map['json'] = Variable<String>(json);
    map['completed_at'] = Variable<DateTime>(completedAt);
    return map;
  }

  WorkoutLogsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutLogsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      date: Value(date),
      type: Value(type),
      status: Value(status),
      json: Value(json),
      completedAt: Value(completedAt),
    );
  }

  factory WorkoutLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutLogRow(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      date: serializer.fromJson<String>(json['date']),
      type: serializer.fromJson<String>(json['type']),
      status: serializer.fromJson<String>(json['status']),
      json: serializer.fromJson<String>(json['json']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'date': serializer.toJson<String>(date),
      'type': serializer.toJson<String>(type),
      'status': serializer.toJson<String>(status),
      'json': serializer.toJson<String>(json),
      'completedAt': serializer.toJson<DateTime>(completedAt),
    };
  }

  WorkoutLogRow copyWith({
    String? id,
    String? sessionId,
    String? date,
    String? type,
    String? status,
    String? json,
    DateTime? completedAt,
  }) => WorkoutLogRow(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    date: date ?? this.date,
    type: type ?? this.type,
    status: status ?? this.status,
    json: json ?? this.json,
    completedAt: completedAt ?? this.completedAt,
  );
  WorkoutLogRow copyWithCompanion(WorkoutLogsCompanion data) {
    return WorkoutLogRow(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      date: data.date.present ? data.date.value : this.date,
      type: data.type.present ? data.type.value : this.type,
      status: data.status.present ? data.status.value : this.status,
      json: data.json.present ? data.json.value : this.json,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutLogRow(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('json: $json, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sessionId, date, type, status, json, completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutLogRow &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.date == this.date &&
          other.type == this.type &&
          other.status == this.status &&
          other.json == this.json &&
          other.completedAt == this.completedAt);
}

class WorkoutLogsCompanion extends UpdateCompanion<WorkoutLogRow> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> date;
  final Value<String> type;
  final Value<String> status;
  final Value<String> json;
  final Value<DateTime> completedAt;
  final Value<int> rowid;
  const WorkoutLogsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.date = const Value.absent(),
    this.type = const Value.absent(),
    this.status = const Value.absent(),
    this.json = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutLogsCompanion.insert({
    required String id,
    required String sessionId,
    required String date,
    required String type,
    required String status,
    required String json,
    required DateTime completedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       date = Value(date),
       type = Value(type),
       status = Value(status),
       json = Value(json),
       completedAt = Value(completedAt);
  static Insertable<WorkoutLogRow> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? date,
    Expression<String>? type,
    Expression<String>? status,
    Expression<String>? json,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (date != null) 'date': date,
      if (type != null) 'type': type,
      if (status != null) 'status': status,
      if (json != null) 'json': json,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String>? date,
    Value<String>? type,
    Value<String>? status,
    Value<String>? json,
    Value<DateTime>? completedAt,
    Value<int>? rowid,
  }) {
    return WorkoutLogsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      date: date ?? this.date,
      type: type ?? this.type,
      status: status ?? this.status,
      json: json ?? this.json,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutLogsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('json: $json, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExercisesTable extends Exercises
    with TableInfo<$ExercisesTable, Exercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExercisesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _regionMeta = const VerificationMeta('region');
  @override
  late final GeneratedColumn<String> region = GeneratedColumn<String>(
    'region',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _regionsJsonMeta = const VerificationMeta(
    'regionsJson',
  );
  @override
  late final GeneratedColumn<String> regionsJson = GeneratedColumn<String>(
    'regions_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _jointsJsonMeta = const VerificationMeta(
    'jointsJson',
  );
  @override
  late final GeneratedColumn<String> jointsJson = GeneratedColumn<String>(
    'joints_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _musclesJsonMeta = const VerificationMeta(
    'musclesJson',
  );
  @override
  late final GeneratedColumn<String> musclesJson = GeneratedColumn<String>(
    'muscles_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _equipmentJsonMeta = const VerificationMeta(
    'equipmentJson',
  );
  @override
  late final GeneratedColumn<String> equipmentJson = GeneratedColumn<String>(
    'equipment_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _anatomyNoteMeta = const VerificationMeta(
    'anatomyNote',
  );
  @override
  late final GeneratedColumn<String> anatomyNote = GeneratedColumn<String>(
    'anatomy_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('excel'),
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cuesJsonMeta = const VerificationMeta(
    'cuesJson',
  );
  @override
  late final GeneratedColumn<String> cuesJson = GeneratedColumn<String>(
    'cues_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _nameEnMeta = const VerificationMeta('nameEn');
  @override
  late final GeneratedColumn<String> nameEn = GeneratedColumn<String>(
    'name_en',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    region,
    regionsJson,
    jointsJson,
    musclesJson,
    equipmentJson,
    anatomyNote,
    source,
    imagePath,
    cuesJson,
    nameEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<Exercise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
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
    if (data.containsKey('region')) {
      context.handle(
        _regionMeta,
        region.isAcceptableOrUnknown(data['region']!, _regionMeta),
      );
    }
    if (data.containsKey('regions_json')) {
      context.handle(
        _regionsJsonMeta,
        regionsJson.isAcceptableOrUnknown(
          data['regions_json']!,
          _regionsJsonMeta,
        ),
      );
    }
    if (data.containsKey('joints_json')) {
      context.handle(
        _jointsJsonMeta,
        jointsJson.isAcceptableOrUnknown(data['joints_json']!, _jointsJsonMeta),
      );
    }
    if (data.containsKey('muscles_json')) {
      context.handle(
        _musclesJsonMeta,
        musclesJson.isAcceptableOrUnknown(
          data['muscles_json']!,
          _musclesJsonMeta,
        ),
      );
    }
    if (data.containsKey('equipment_json')) {
      context.handle(
        _equipmentJsonMeta,
        equipmentJson.isAcceptableOrUnknown(
          data['equipment_json']!,
          _equipmentJsonMeta,
        ),
      );
    }
    if (data.containsKey('anatomy_note')) {
      context.handle(
        _anatomyNoteMeta,
        anatomyNote.isAcceptableOrUnknown(
          data['anatomy_note']!,
          _anatomyNoteMeta,
        ),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    }
    if (data.containsKey('cues_json')) {
      context.handle(
        _cuesJsonMeta,
        cuesJson.isAcceptableOrUnknown(data['cues_json']!, _cuesJsonMeta),
      );
    }
    if (data.containsKey('name_en')) {
      context.handle(
        _nameEnMeta,
        nameEn.isAcceptableOrUnknown(data['name_en']!, _nameEnMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Exercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Exercise(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      region: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}region'],
      )!,
      regionsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}regions_json'],
      )!,
      jointsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}joints_json'],
      )!,
      musclesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}muscles_json'],
      )!,
      equipmentJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipment_json'],
      )!,
      anatomyNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}anatomy_note'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      ),
      cuesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cues_json'],
      )!,
      nameEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_en'],
      ),
    );
  }

  @override
  $ExercisesTable createAlias(String alias) {
    return $ExercisesTable(attachedDatabase, alias);
  }
}

class Exercise extends DataClass implements Insertable<Exercise> {
  final int id;
  final String name;
  final String region;
  final String regionsJson;
  final String jointsJson;
  final String musclesJson;
  final String equipmentJson;
  final String? anatomyNote;
  final String source;

  /// 相对 asset 路径，如 assets/exercises/images/ek_pull-ups.svg；可空。
  final String? imagePath;
  final String cuesJson;
  final String? nameEn;
  const Exercise({
    required this.id,
    required this.name,
    required this.region,
    required this.regionsJson,
    required this.jointsJson,
    required this.musclesJson,
    required this.equipmentJson,
    this.anatomyNote,
    required this.source,
    this.imagePath,
    required this.cuesJson,
    this.nameEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['region'] = Variable<String>(region);
    map['regions_json'] = Variable<String>(regionsJson);
    map['joints_json'] = Variable<String>(jointsJson);
    map['muscles_json'] = Variable<String>(musclesJson);
    map['equipment_json'] = Variable<String>(equipmentJson);
    if (!nullToAbsent || anatomyNote != null) {
      map['anatomy_note'] = Variable<String>(anatomyNote);
    }
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    map['cues_json'] = Variable<String>(cuesJson);
    if (!nullToAbsent || nameEn != null) {
      map['name_en'] = Variable<String>(nameEn);
    }
    return map;
  }

  ExercisesCompanion toCompanion(bool nullToAbsent) {
    return ExercisesCompanion(
      id: Value(id),
      name: Value(name),
      region: Value(region),
      regionsJson: Value(regionsJson),
      jointsJson: Value(jointsJson),
      musclesJson: Value(musclesJson),
      equipmentJson: Value(equipmentJson),
      anatomyNote: anatomyNote == null && nullToAbsent
          ? const Value.absent()
          : Value(anatomyNote),
      source: Value(source),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      cuesJson: Value(cuesJson),
      nameEn: nameEn == null && nullToAbsent
          ? const Value.absent()
          : Value(nameEn),
    );
  }

  factory Exercise.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Exercise(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      region: serializer.fromJson<String>(json['region']),
      regionsJson: serializer.fromJson<String>(json['regionsJson']),
      jointsJson: serializer.fromJson<String>(json['jointsJson']),
      musclesJson: serializer.fromJson<String>(json['musclesJson']),
      equipmentJson: serializer.fromJson<String>(json['equipmentJson']),
      anatomyNote: serializer.fromJson<String?>(json['anatomyNote']),
      source: serializer.fromJson<String>(json['source']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      cuesJson: serializer.fromJson<String>(json['cuesJson']),
      nameEn: serializer.fromJson<String?>(json['nameEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'region': serializer.toJson<String>(region),
      'regionsJson': serializer.toJson<String>(regionsJson),
      'jointsJson': serializer.toJson<String>(jointsJson),
      'musclesJson': serializer.toJson<String>(musclesJson),
      'equipmentJson': serializer.toJson<String>(equipmentJson),
      'anatomyNote': serializer.toJson<String?>(anatomyNote),
      'source': serializer.toJson<String>(source),
      'imagePath': serializer.toJson<String?>(imagePath),
      'cuesJson': serializer.toJson<String>(cuesJson),
      'nameEn': serializer.toJson<String?>(nameEn),
    };
  }

  Exercise copyWith({
    int? id,
    String? name,
    String? region,
    String? regionsJson,
    String? jointsJson,
    String? musclesJson,
    String? equipmentJson,
    Value<String?> anatomyNote = const Value.absent(),
    String? source,
    Value<String?> imagePath = const Value.absent(),
    String? cuesJson,
    Value<String?> nameEn = const Value.absent(),
  }) => Exercise(
    id: id ?? this.id,
    name: name ?? this.name,
    region: region ?? this.region,
    regionsJson: regionsJson ?? this.regionsJson,
    jointsJson: jointsJson ?? this.jointsJson,
    musclesJson: musclesJson ?? this.musclesJson,
    equipmentJson: equipmentJson ?? this.equipmentJson,
    anatomyNote: anatomyNote.present ? anatomyNote.value : this.anatomyNote,
    source: source ?? this.source,
    imagePath: imagePath.present ? imagePath.value : this.imagePath,
    cuesJson: cuesJson ?? this.cuesJson,
    nameEn: nameEn.present ? nameEn.value : this.nameEn,
  );
  Exercise copyWithCompanion(ExercisesCompanion data) {
    return Exercise(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      region: data.region.present ? data.region.value : this.region,
      regionsJson: data.regionsJson.present
          ? data.regionsJson.value
          : this.regionsJson,
      jointsJson: data.jointsJson.present
          ? data.jointsJson.value
          : this.jointsJson,
      musclesJson: data.musclesJson.present
          ? data.musclesJson.value
          : this.musclesJson,
      equipmentJson: data.equipmentJson.present
          ? data.equipmentJson.value
          : this.equipmentJson,
      anatomyNote: data.anatomyNote.present
          ? data.anatomyNote.value
          : this.anatomyNote,
      source: data.source.present ? data.source.value : this.source,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      cuesJson: data.cuesJson.present ? data.cuesJson.value : this.cuesJson,
      nameEn: data.nameEn.present ? data.nameEn.value : this.nameEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Exercise(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('region: $region, ')
          ..write('regionsJson: $regionsJson, ')
          ..write('jointsJson: $jointsJson, ')
          ..write('musclesJson: $musclesJson, ')
          ..write('equipmentJson: $equipmentJson, ')
          ..write('anatomyNote: $anatomyNote, ')
          ..write('source: $source, ')
          ..write('imagePath: $imagePath, ')
          ..write('cuesJson: $cuesJson, ')
          ..write('nameEn: $nameEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    region,
    regionsJson,
    jointsJson,
    musclesJson,
    equipmentJson,
    anatomyNote,
    source,
    imagePath,
    cuesJson,
    nameEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Exercise &&
          other.id == this.id &&
          other.name == this.name &&
          other.region == this.region &&
          other.regionsJson == this.regionsJson &&
          other.jointsJson == this.jointsJson &&
          other.musclesJson == this.musclesJson &&
          other.equipmentJson == this.equipmentJson &&
          other.anatomyNote == this.anatomyNote &&
          other.source == this.source &&
          other.imagePath == this.imagePath &&
          other.cuesJson == this.cuesJson &&
          other.nameEn == this.nameEn);
}

class ExercisesCompanion extends UpdateCompanion<Exercise> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> region;
  final Value<String> regionsJson;
  final Value<String> jointsJson;
  final Value<String> musclesJson;
  final Value<String> equipmentJson;
  final Value<String?> anatomyNote;
  final Value<String> source;
  final Value<String?> imagePath;
  final Value<String> cuesJson;
  final Value<String?> nameEn;
  const ExercisesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.region = const Value.absent(),
    this.regionsJson = const Value.absent(),
    this.jointsJson = const Value.absent(),
    this.musclesJson = const Value.absent(),
    this.equipmentJson = const Value.absent(),
    this.anatomyNote = const Value.absent(),
    this.source = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.cuesJson = const Value.absent(),
    this.nameEn = const Value.absent(),
  });
  ExercisesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.region = const Value.absent(),
    this.regionsJson = const Value.absent(),
    this.jointsJson = const Value.absent(),
    this.musclesJson = const Value.absent(),
    this.equipmentJson = const Value.absent(),
    this.anatomyNote = const Value.absent(),
    this.source = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.cuesJson = const Value.absent(),
    this.nameEn = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Exercise> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? region,
    Expression<String>? regionsJson,
    Expression<String>? jointsJson,
    Expression<String>? musclesJson,
    Expression<String>? equipmentJson,
    Expression<String>? anatomyNote,
    Expression<String>? source,
    Expression<String>? imagePath,
    Expression<String>? cuesJson,
    Expression<String>? nameEn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (region != null) 'region': region,
      if (regionsJson != null) 'regions_json': regionsJson,
      if (jointsJson != null) 'joints_json': jointsJson,
      if (musclesJson != null) 'muscles_json': musclesJson,
      if (equipmentJson != null) 'equipment_json': equipmentJson,
      if (anatomyNote != null) 'anatomy_note': anatomyNote,
      if (source != null) 'source': source,
      if (imagePath != null) 'image_path': imagePath,
      if (cuesJson != null) 'cues_json': cuesJson,
      if (nameEn != null) 'name_en': nameEn,
    });
  }

  ExercisesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? region,
    Value<String>? regionsJson,
    Value<String>? jointsJson,
    Value<String>? musclesJson,
    Value<String>? equipmentJson,
    Value<String?>? anatomyNote,
    Value<String>? source,
    Value<String?>? imagePath,
    Value<String>? cuesJson,
    Value<String?>? nameEn,
  }) {
    return ExercisesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      region: region ?? this.region,
      regionsJson: regionsJson ?? this.regionsJson,
      jointsJson: jointsJson ?? this.jointsJson,
      musclesJson: musclesJson ?? this.musclesJson,
      equipmentJson: equipmentJson ?? this.equipmentJson,
      anatomyNote: anatomyNote ?? this.anatomyNote,
      source: source ?? this.source,
      imagePath: imagePath ?? this.imagePath,
      cuesJson: cuesJson ?? this.cuesJson,
      nameEn: nameEn ?? this.nameEn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (region.present) {
      map['region'] = Variable<String>(region.value);
    }
    if (regionsJson.present) {
      map['regions_json'] = Variable<String>(regionsJson.value);
    }
    if (jointsJson.present) {
      map['joints_json'] = Variable<String>(jointsJson.value);
    }
    if (musclesJson.present) {
      map['muscles_json'] = Variable<String>(musclesJson.value);
    }
    if (equipmentJson.present) {
      map['equipment_json'] = Variable<String>(equipmentJson.value);
    }
    if (anatomyNote.present) {
      map['anatomy_note'] = Variable<String>(anatomyNote.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (cuesJson.present) {
      map['cues_json'] = Variable<String>(cuesJson.value);
    }
    if (nameEn.present) {
      map['name_en'] = Variable<String>(nameEn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExercisesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('region: $region, ')
          ..write('regionsJson: $regionsJson, ')
          ..write('jointsJson: $jointsJson, ')
          ..write('musclesJson: $musclesJson, ')
          ..write('equipmentJson: $equipmentJson, ')
          ..write('anatomyNote: $anatomyNote, ')
          ..write('source: $source, ')
          ..write('imagePath: $imagePath, ')
          ..write('cuesJson: $cuesJson, ')
          ..write('nameEn: $nameEn')
          ..write(')'))
        .toString();
  }
}

class $AnatomyRowsTable extends AnatomyRows
    with TableInfo<$AnatomyRowsTable, AnatomyRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnatomyRowsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _tableKindMeta = const VerificationMeta(
    'tableKind',
  );
  @override
  late final GeneratedColumn<String> tableKind = GeneratedColumn<String>(
    'table_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, tableKind, json];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'anatomy_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<AnatomyRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('table_kind')) {
      context.handle(
        _tableKindMeta,
        tableKind.isAcceptableOrUnknown(data['table_kind']!, _tableKindMeta),
      );
    } else if (isInserting) {
      context.missing(_tableKindMeta);
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AnatomyRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnatomyRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      tableKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}table_kind'],
      )!,
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
    );
  }

  @override
  $AnatomyRowsTable createAlias(String alias) {
    return $AnatomyRowsTable(attachedDatabase, alias);
  }
}

class AnatomyRow extends DataClass implements Insertable<AnatomyRow> {
  final int id;
  final String tableKind;
  final String json;
  const AnatomyRow({
    required this.id,
    required this.tableKind,
    required this.json,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['table_kind'] = Variable<String>(tableKind);
    map['json'] = Variable<String>(json);
    return map;
  }

  AnatomyRowsCompanion toCompanion(bool nullToAbsent) {
    return AnatomyRowsCompanion(
      id: Value(id),
      tableKind: Value(tableKind),
      json: Value(json),
    );
  }

  factory AnatomyRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnatomyRow(
      id: serializer.fromJson<int>(json['id']),
      tableKind: serializer.fromJson<String>(json['tableKind']),
      json: serializer.fromJson<String>(json['json']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tableKind': serializer.toJson<String>(tableKind),
      'json': serializer.toJson<String>(json),
    };
  }

  AnatomyRow copyWith({int? id, String? tableKind, String? json}) => AnatomyRow(
    id: id ?? this.id,
    tableKind: tableKind ?? this.tableKind,
    json: json ?? this.json,
  );
  AnatomyRow copyWithCompanion(AnatomyRowsCompanion data) {
    return AnatomyRow(
      id: data.id.present ? data.id.value : this.id,
      tableKind: data.tableKind.present ? data.tableKind.value : this.tableKind,
      json: data.json.present ? data.json.value : this.json,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnatomyRow(')
          ..write('id: $id, ')
          ..write('tableKind: $tableKind, ')
          ..write('json: $json')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, tableKind, json);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnatomyRow &&
          other.id == this.id &&
          other.tableKind == this.tableKind &&
          other.json == this.json);
}

class AnatomyRowsCompanion extends UpdateCompanion<AnatomyRow> {
  final Value<int> id;
  final Value<String> tableKind;
  final Value<String> json;
  const AnatomyRowsCompanion({
    this.id = const Value.absent(),
    this.tableKind = const Value.absent(),
    this.json = const Value.absent(),
  });
  AnatomyRowsCompanion.insert({
    this.id = const Value.absent(),
    required String tableKind,
    required String json,
  }) : tableKind = Value(tableKind),
       json = Value(json);
  static Insertable<AnatomyRow> custom({
    Expression<int>? id,
    Expression<String>? tableKind,
    Expression<String>? json,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tableKind != null) 'table_kind': tableKind,
      if (json != null) 'json': json,
    });
  }

  AnatomyRowsCompanion copyWith({
    Value<int>? id,
    Value<String>? tableKind,
    Value<String>? json,
  }) {
    return AnatomyRowsCompanion(
      id: id ?? this.id,
      tableKind: tableKind ?? this.tableKind,
      json: json ?? this.json,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tableKind.present) {
      map['table_kind'] = Variable<String>(tableKind.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnatomyRowsCompanion(')
          ..write('id: $id, ')
          ..write('tableKind: $tableKind, ')
          ..write('json: $json')
          ..write(')'))
        .toString();
  }
}

class $FoodsTable extends Foods with TableInfo<$FoodsTable, Food> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
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
  static const VerificationMeta _rateMeta = const VerificationMeta('rate');
  @override
  late final GeneratedColumn<double> rate = GeneratedColumn<double>(
    'rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _macroHintMeta = const VerificationMeta(
    'macroHint',
  );
  @override
  late final GeneratedColumn<String> macroHint = GeneratedColumn<String>(
    'macro_hint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    category,
    rate,
    macroHint,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'foods';
  @override
  VerificationContext validateIntegrity(
    Insertable<Food> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
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
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('rate')) {
      context.handle(
        _rateMeta,
        rate.isAcceptableOrUnknown(data['rate']!, _rateMeta),
      );
    } else if (isInserting) {
      context.missing(_rateMeta);
    }
    if (data.containsKey('macro_hint')) {
      context.handle(
        _macroHintMeta,
        macroHint.isAcceptableOrUnknown(data['macro_hint']!, _macroHintMeta),
      );
    } else if (isInserting) {
      context.missing(_macroHintMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Food map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Food(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      rate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rate'],
      )!,
      macroHint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}macro_hint'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $FoodsTable createAlias(String alias) {
    return $FoodsTable(attachedDatabase, alias);
  }
}

class Food extends DataClass implements Insertable<Food> {
  final int id;
  final String name;
  final String category;
  final double rate;
  final String macroHint;
  final String? note;
  const Food({
    required this.id,
    required this.name,
    required this.category,
    required this.rate,
    required this.macroHint,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    map['rate'] = Variable<double>(rate);
    map['macro_hint'] = Variable<String>(macroHint);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  FoodsCompanion toCompanion(bool nullToAbsent) {
    return FoodsCompanion(
      id: Value(id),
      name: Value(name),
      category: Value(category),
      rate: Value(rate),
      macroHint: Value(macroHint),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory Food.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Food(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      rate: serializer.fromJson<double>(json['rate']),
      macroHint: serializer.fromJson<String>(json['macroHint']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'rate': serializer.toJson<double>(rate),
      'macroHint': serializer.toJson<String>(macroHint),
      'note': serializer.toJson<String?>(note),
    };
  }

  Food copyWith({
    int? id,
    String? name,
    String? category,
    double? rate,
    String? macroHint,
    Value<String?> note = const Value.absent(),
  }) => Food(
    id: id ?? this.id,
    name: name ?? this.name,
    category: category ?? this.category,
    rate: rate ?? this.rate,
    macroHint: macroHint ?? this.macroHint,
    note: note.present ? note.value : this.note,
  );
  Food copyWithCompanion(FoodsCompanion data) {
    return Food(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      rate: data.rate.present ? data.rate.value : this.rate,
      macroHint: data.macroHint.present ? data.macroHint.value : this.macroHint,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Food(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('rate: $rate, ')
          ..write('macroHint: $macroHint, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, category, rate, macroHint, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Food &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.rate == this.rate &&
          other.macroHint == this.macroHint &&
          other.note == this.note);
}

class FoodsCompanion extends UpdateCompanion<Food> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> category;
  final Value<double> rate;
  final Value<String> macroHint;
  final Value<String?> note;
  const FoodsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.rate = const Value.absent(),
    this.macroHint = const Value.absent(),
    this.note = const Value.absent(),
  });
  FoodsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String category,
    required double rate,
    required String macroHint,
    this.note = const Value.absent(),
  }) : name = Value(name),
       category = Value(category),
       rate = Value(rate),
       macroHint = Value(macroHint);
  static Insertable<Food> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? category,
    Expression<double>? rate,
    Expression<String>? macroHint,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (rate != null) 'rate': rate,
      if (macroHint != null) 'macro_hint': macroHint,
      if (note != null) 'note': note,
    });
  }

  FoodsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? category,
    Value<double>? rate,
    Value<String>? macroHint,
    Value<String?>? note,
  }) {
    return FoodsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      rate: rate ?? this.rate,
      macroHint: macroHint ?? this.macroHint,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (rate.present) {
      map['rate'] = Variable<double>(rate.value);
    }
    if (macroHint.present) {
      map['macro_hint'] = Variable<String>(macroHint.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoodsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('rate: $rate, ')
          ..write('macroHint: $macroHint, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $CardioItemsTable extends CardioItems
    with TableInfo<$CardioItemsTable, CardioItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardioItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kcalPerKgPerHourMeta = const VerificationMeta(
    'kcalPerKgPerHour',
  );
  @override
  late final GeneratedColumn<double> kcalPerKgPerHour = GeneratedColumn<double>(
    'kcal_per_kg_per_hour',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, kcalPerKgPerHour, category];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cardio_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardioItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
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
    if (data.containsKey('kcal_per_kg_per_hour')) {
      context.handle(
        _kcalPerKgPerHourMeta,
        kcalPerKgPerHour.isAcceptableOrUnknown(
          data['kcal_per_kg_per_hour']!,
          _kcalPerKgPerHourMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_kcalPerKgPerHourMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CardioItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardioItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kcalPerKgPerHour: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kcal_per_kg_per_hour'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
    );
  }

  @override
  $CardioItemsTable createAlias(String alias) {
    return $CardioItemsTable(attachedDatabase, alias);
  }
}

class CardioItem extends DataClass implements Insertable<CardioItem> {
  final int id;
  final String name;
  final double kcalPerKgPerHour;
  final String? category;
  const CardioItem({
    required this.id,
    required this.name,
    required this.kcalPerKgPerHour,
    this.category,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['kcal_per_kg_per_hour'] = Variable<double>(kcalPerKgPerHour);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    return map;
  }

  CardioItemsCompanion toCompanion(bool nullToAbsent) {
    return CardioItemsCompanion(
      id: Value(id),
      name: Value(name),
      kcalPerKgPerHour: Value(kcalPerKgPerHour),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
    );
  }

  factory CardioItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardioItem(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      kcalPerKgPerHour: serializer.fromJson<double>(json['kcalPerKgPerHour']),
      category: serializer.fromJson<String?>(json['category']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'kcalPerKgPerHour': serializer.toJson<double>(kcalPerKgPerHour),
      'category': serializer.toJson<String?>(category),
    };
  }

  CardioItem copyWith({
    int? id,
    String? name,
    double? kcalPerKgPerHour,
    Value<String?> category = const Value.absent(),
  }) => CardioItem(
    id: id ?? this.id,
    name: name ?? this.name,
    kcalPerKgPerHour: kcalPerKgPerHour ?? this.kcalPerKgPerHour,
    category: category.present ? category.value : this.category,
  );
  CardioItem copyWithCompanion(CardioItemsCompanion data) {
    return CardioItem(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      kcalPerKgPerHour: data.kcalPerKgPerHour.present
          ? data.kcalPerKgPerHour.value
          : this.kcalPerKgPerHour,
      category: data.category.present ? data.category.value : this.category,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardioItem(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kcalPerKgPerHour: $kcalPerKgPerHour, ')
          ..write('category: $category')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, kcalPerKgPerHour, category);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardioItem &&
          other.id == this.id &&
          other.name == this.name &&
          other.kcalPerKgPerHour == this.kcalPerKgPerHour &&
          other.category == this.category);
}

class CardioItemsCompanion extends UpdateCompanion<CardioItem> {
  final Value<int> id;
  final Value<String> name;
  final Value<double> kcalPerKgPerHour;
  final Value<String?> category;
  const CardioItemsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.kcalPerKgPerHour = const Value.absent(),
    this.category = const Value.absent(),
  });
  CardioItemsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required double kcalPerKgPerHour,
    this.category = const Value.absent(),
  }) : name = Value(name),
       kcalPerKgPerHour = Value(kcalPerKgPerHour);
  static Insertable<CardioItem> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<double>? kcalPerKgPerHour,
    Expression<String>? category,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (kcalPerKgPerHour != null) 'kcal_per_kg_per_hour': kcalPerKgPerHour,
      if (category != null) 'category': category,
    });
  }

  CardioItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<double>? kcalPerKgPerHour,
    Value<String?>? category,
  }) {
    return CardioItemsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      kcalPerKgPerHour: kcalPerKgPerHour ?? this.kcalPerKgPerHour,
      category: category ?? this.category,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kcalPerKgPerHour.present) {
      map['kcal_per_kg_per_hour'] = Variable<double>(kcalPerKgPerHour.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardioItemsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kcalPerKgPerHour: $kcalPerKgPerHour, ')
          ..write('category: $category')
          ..write(')'))
        .toString();
  }
}

class $FaqItemsTable extends FaqItems with TableInfo<$FaqItemsTable, FaqItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FaqItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _goalMeta = const VerificationMeta('goal');
  @override
  late final GeneratedColumn<String> goal = GeneratedColumn<String>(
    'goal',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questionMeta = const VerificationMeta(
    'question',
  );
  @override
  late final GeneratedColumn<String> question = GeneratedColumn<String>(
    'question',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _answerMeta = const VerificationMeta('answer');
  @override
  late final GeneratedColumn<String> answer = GeneratedColumn<String>(
    'answer',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, goal, question, answer];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'faq_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<FaqItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('goal')) {
      context.handle(
        _goalMeta,
        goal.isAcceptableOrUnknown(data['goal']!, _goalMeta),
      );
    } else if (isInserting) {
      context.missing(_goalMeta);
    }
    if (data.containsKey('question')) {
      context.handle(
        _questionMeta,
        question.isAcceptableOrUnknown(data['question']!, _questionMeta),
      );
    } else if (isInserting) {
      context.missing(_questionMeta);
    }
    if (data.containsKey('answer')) {
      context.handle(
        _answerMeta,
        answer.isAcceptableOrUnknown(data['answer']!, _answerMeta),
      );
    } else if (isInserting) {
      context.missing(_answerMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FaqItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FaqItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      goal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goal'],
      )!,
      question: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question'],
      )!,
      answer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}answer'],
      )!,
    );
  }

  @override
  $FaqItemsTable createAlias(String alias) {
    return $FaqItemsTable(attachedDatabase, alias);
  }
}

class FaqItem extends DataClass implements Insertable<FaqItem> {
  final int id;
  final String goal;
  final String question;
  final String answer;
  const FaqItem({
    required this.id,
    required this.goal,
    required this.question,
    required this.answer,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['goal'] = Variable<String>(goal);
    map['question'] = Variable<String>(question);
    map['answer'] = Variable<String>(answer);
    return map;
  }

  FaqItemsCompanion toCompanion(bool nullToAbsent) {
    return FaqItemsCompanion(
      id: Value(id),
      goal: Value(goal),
      question: Value(question),
      answer: Value(answer),
    );
  }

  factory FaqItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FaqItem(
      id: serializer.fromJson<int>(json['id']),
      goal: serializer.fromJson<String>(json['goal']),
      question: serializer.fromJson<String>(json['question']),
      answer: serializer.fromJson<String>(json['answer']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'goal': serializer.toJson<String>(goal),
      'question': serializer.toJson<String>(question),
      'answer': serializer.toJson<String>(answer),
    };
  }

  FaqItem copyWith({int? id, String? goal, String? question, String? answer}) =>
      FaqItem(
        id: id ?? this.id,
        goal: goal ?? this.goal,
        question: question ?? this.question,
        answer: answer ?? this.answer,
      );
  FaqItem copyWithCompanion(FaqItemsCompanion data) {
    return FaqItem(
      id: data.id.present ? data.id.value : this.id,
      goal: data.goal.present ? data.goal.value : this.goal,
      question: data.question.present ? data.question.value : this.question,
      answer: data.answer.present ? data.answer.value : this.answer,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FaqItem(')
          ..write('id: $id, ')
          ..write('goal: $goal, ')
          ..write('question: $question, ')
          ..write('answer: $answer')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, goal, question, answer);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FaqItem &&
          other.id == this.id &&
          other.goal == this.goal &&
          other.question == this.question &&
          other.answer == this.answer);
}

class FaqItemsCompanion extends UpdateCompanion<FaqItem> {
  final Value<int> id;
  final Value<String> goal;
  final Value<String> question;
  final Value<String> answer;
  const FaqItemsCompanion({
    this.id = const Value.absent(),
    this.goal = const Value.absent(),
    this.question = const Value.absent(),
    this.answer = const Value.absent(),
  });
  FaqItemsCompanion.insert({
    this.id = const Value.absent(),
    required String goal,
    required String question,
    required String answer,
  }) : goal = Value(goal),
       question = Value(question),
       answer = Value(answer);
  static Insertable<FaqItem> custom({
    Expression<int>? id,
    Expression<String>? goal,
    Expression<String>? question,
    Expression<String>? answer,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (goal != null) 'goal': goal,
      if (question != null) 'question': question,
      if (answer != null) 'answer': answer,
    });
  }

  FaqItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? goal,
    Value<String>? question,
    Value<String>? answer,
  }) {
    return FaqItemsCompanion(
      id: id ?? this.id,
      goal: goal ?? this.goal,
      question: question ?? this.question,
      answer: answer ?? this.answer,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (goal.present) {
      map['goal'] = Variable<String>(goal.value);
    }
    if (question.present) {
      map['question'] = Variable<String>(question.value);
    }
    if (answer.present) {
      map['answer'] = Variable<String>(answer.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FaqItemsCompanion(')
          ..write('id: $id, ')
          ..write('goal: $goal, ')
          ..write('question: $question, ')
          ..write('answer: $answer')
          ..write(')'))
        .toString();
  }
}

class $SplitTemplatesTable extends SplitTemplates
    with TableInfo<$SplitTemplatesTable, SplitTemplate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SplitTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, json];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'split_templates';
  @override
  VerificationContext validateIntegrity(
    Insertable<SplitTemplate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SplitTemplate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SplitTemplate(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
    );
  }

  @override
  $SplitTemplatesTable createAlias(String alias) {
    return $SplitTemplatesTable(attachedDatabase, alias);
  }
}

class SplitTemplate extends DataClass implements Insertable<SplitTemplate> {
  final String id;
  final String json;
  const SplitTemplate({required this.id, required this.json});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['json'] = Variable<String>(json);
    return map;
  }

  SplitTemplatesCompanion toCompanion(bool nullToAbsent) {
    return SplitTemplatesCompanion(id: Value(id), json: Value(json));
  }

  factory SplitTemplate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SplitTemplate(
      id: serializer.fromJson<String>(json['id']),
      json: serializer.fromJson<String>(json['json']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'json': serializer.toJson<String>(json),
    };
  }

  SplitTemplate copyWith({String? id, String? json}) =>
      SplitTemplate(id: id ?? this.id, json: json ?? this.json);
  SplitTemplate copyWithCompanion(SplitTemplatesCompanion data) {
    return SplitTemplate(
      id: data.id.present ? data.id.value : this.id,
      json: data.json.present ? data.json.value : this.json,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SplitTemplate(')
          ..write('id: $id, ')
          ..write('json: $json')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, json);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SplitTemplate &&
          other.id == this.id &&
          other.json == this.json);
}

class SplitTemplatesCompanion extends UpdateCompanion<SplitTemplate> {
  final Value<String> id;
  final Value<String> json;
  final Value<int> rowid;
  const SplitTemplatesCompanion({
    this.id = const Value.absent(),
    this.json = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SplitTemplatesCompanion.insert({
    required String id,
    required String json,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       json = Value(json);
  static Insertable<SplitTemplate> custom({
    Expression<String>? id,
    Expression<String>? json,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (json != null) 'json': json,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SplitTemplatesCompanion copyWith({
    Value<String>? id,
    Value<String>? json,
    Value<int>? rowid,
  }) {
    return SplitTemplatesCompanion(
      id: id ?? this.id,
      json: json ?? this.json,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SplitTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('json: $json, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DietRulesStoreTable extends DietRulesStore
    with TableInfo<$DietRulesStoreTable, DietRulesStoreData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DietRulesStoreTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, json];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'diet_rules_store';
  @override
  VerificationContext validateIntegrity(
    Insertable<DietRulesStoreData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DietRulesStoreData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DietRulesStoreData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
    );
  }

  @override
  $DietRulesStoreTable createAlias(String alias) {
    return $DietRulesStoreTable(attachedDatabase, alias);
  }
}

class DietRulesStoreData extends DataClass
    implements Insertable<DietRulesStoreData> {
  final int id;
  final String json;
  const DietRulesStoreData({required this.id, required this.json});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['json'] = Variable<String>(json);
    return map;
  }

  DietRulesStoreCompanion toCompanion(bool nullToAbsent) {
    return DietRulesStoreCompanion(id: Value(id), json: Value(json));
  }

  factory DietRulesStoreData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DietRulesStoreData(
      id: serializer.fromJson<int>(json['id']),
      json: serializer.fromJson<String>(json['json']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'json': serializer.toJson<String>(json),
    };
  }

  DietRulesStoreData copyWith({int? id, String? json}) =>
      DietRulesStoreData(id: id ?? this.id, json: json ?? this.json);
  DietRulesStoreData copyWithCompanion(DietRulesStoreCompanion data) {
    return DietRulesStoreData(
      id: data.id.present ? data.id.value : this.id,
      json: data.json.present ? data.json.value : this.json,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DietRulesStoreData(')
          ..write('id: $id, ')
          ..write('json: $json')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, json);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DietRulesStoreData &&
          other.id == this.id &&
          other.json == this.json);
}

class DietRulesStoreCompanion extends UpdateCompanion<DietRulesStoreData> {
  final Value<int> id;
  final Value<String> json;
  const DietRulesStoreCompanion({
    this.id = const Value.absent(),
    this.json = const Value.absent(),
  });
  DietRulesStoreCompanion.insert({
    this.id = const Value.absent(),
    required String json,
  }) : json = Value(json);
  static Insertable<DietRulesStoreData> custom({
    Expression<int>? id,
    Expression<String>? json,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (json != null) 'json': json,
    });
  }

  DietRulesStoreCompanion copyWith({Value<int>? id, Value<String>? json}) {
    return DietRulesStoreCompanion(id: id ?? this.id, json: json ?? this.json);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DietRulesStoreCompanion(')
          ..write('id: $id, ')
          ..write('json: $json')
          ..write(')'))
        .toString();
  }
}

class $YogaSequencesTable extends YogaSequences
    with TableInfo<$YogaSequencesTable, YogaSequence> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $YogaSequencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, json];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'yoga_sequences';
  @override
  VerificationContext validateIntegrity(
    Insertable<YogaSequence> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  YogaSequence map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return YogaSequence(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
    );
  }

  @override
  $YogaSequencesTable createAlias(String alias) {
    return $YogaSequencesTable(attachedDatabase, alias);
  }
}

class YogaSequence extends DataClass implements Insertable<YogaSequence> {
  final String id;
  final String json;
  const YogaSequence({required this.id, required this.json});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['json'] = Variable<String>(json);
    return map;
  }

  YogaSequencesCompanion toCompanion(bool nullToAbsent) {
    return YogaSequencesCompanion(id: Value(id), json: Value(json));
  }

  factory YogaSequence.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return YogaSequence(
      id: serializer.fromJson<String>(json['id']),
      json: serializer.fromJson<String>(json['json']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'json': serializer.toJson<String>(json),
    };
  }

  YogaSequence copyWith({String? id, String? json}) =>
      YogaSequence(id: id ?? this.id, json: json ?? this.json);
  YogaSequence copyWithCompanion(YogaSequencesCompanion data) {
    return YogaSequence(
      id: data.id.present ? data.id.value : this.id,
      json: data.json.present ? data.json.value : this.json,
    );
  }

  @override
  String toString() {
    return (StringBuffer('YogaSequence(')
          ..write('id: $id, ')
          ..write('json: $json')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, json);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is YogaSequence && other.id == this.id && other.json == this.json);
}

class YogaSequencesCompanion extends UpdateCompanion<YogaSequence> {
  final Value<String> id;
  final Value<String> json;
  final Value<int> rowid;
  const YogaSequencesCompanion({
    this.id = const Value.absent(),
    this.json = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  YogaSequencesCompanion.insert({
    required String id,
    required String json,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       json = Value(json);
  static Insertable<YogaSequence> custom({
    Expression<String>? id,
    Expression<String>? json,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (json != null) 'json': json,
      if (rowid != null) 'rowid': rowid,
    });
  }

  YogaSequencesCompanion copyWith({
    Value<String>? id,
    Value<String>? json,
    Value<int>? rowid,
  }) {
    return YogaSequencesCompanion(
      id: id ?? this.id,
      json: json ?? this.json,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('YogaSequencesCompanion(')
          ..write('id: $id, ')
          ..write('json: $json, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AppMetaTable appMeta = $AppMetaTable(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final $ActivePlansTable activePlans = $ActivePlansTable(this);
  late final $PlannedSessionsTable plannedSessions = $PlannedSessionsTable(
    this,
  );
  late final $WorkoutLogsTable workoutLogs = $WorkoutLogsTable(this);
  late final $ExercisesTable exercises = $ExercisesTable(this);
  late final $AnatomyRowsTable anatomyRows = $AnatomyRowsTable(this);
  late final $FoodsTable foods = $FoodsTable(this);
  late final $CardioItemsTable cardioItems = $CardioItemsTable(this);
  late final $FaqItemsTable faqItems = $FaqItemsTable(this);
  late final $SplitTemplatesTable splitTemplates = $SplitTemplatesTable(this);
  late final $DietRulesStoreTable dietRulesStore = $DietRulesStoreTable(this);
  late final $YogaSequencesTable yogaSequences = $YogaSequencesTable(this);
  late final ExerciseDao exerciseDao = ExerciseDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    appMeta,
    userProfiles,
    activePlans,
    plannedSessions,
    workoutLogs,
    exercises,
    anatomyRows,
    foods,
    cardioItems,
    faqItems,
    splitTemplates,
    dietRulesStore,
    yogaSequences,
  ];
}

typedef $$AppMetaTableCreateCompanionBuilder =
    AppMetaCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppMetaTableUpdateCompanionBuilder =
    AppMetaCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppMetaTableFilterComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppMetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppMetaTable,
          AppMetaData,
          $$AppMetaTableFilterComposer,
          $$AppMetaTableOrderingComposer,
          $$AppMetaTableAnnotationComposer,
          $$AppMetaTableCreateCompanionBuilder,
          $$AppMetaTableUpdateCompanionBuilder,
          (
            AppMetaData,
            BaseReferences<_$AppDatabase, $AppMetaTable, AppMetaData>,
          ),
          AppMetaData,
          PrefetchHooks Function()
        > {
  $$AppMetaTableTableManager(_$AppDatabase db, $AppMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppMetaCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) =>
                  AppMetaCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppMetaTable,
      AppMetaData,
      $$AppMetaTableFilterComposer,
      $$AppMetaTableOrderingComposer,
      $$AppMetaTableAnnotationComposer,
      $$AppMetaTableCreateCompanionBuilder,
      $$AppMetaTableUpdateCompanionBuilder,
      (AppMetaData, BaseReferences<_$AppDatabase, $AppMetaTable, AppMetaData>),
      AppMetaData,
      PrefetchHooks Function()
    >;
typedef $$UserProfilesTableCreateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<int> id,
      required String json,
      Value<bool> onboardingDone,
    });
typedef $$UserProfilesTableUpdateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<int> id,
      Value<String> json,
      Value<bool> onboardingDone,
    });

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
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

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get onboardingDone => $composableBuilder(
    column: $table.onboardingDone,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
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

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get onboardingDone => $composableBuilder(
    column: $table.onboardingDone,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);

  GeneratedColumn<bool> get onboardingDone => $composableBuilder(
    column: $table.onboardingDone,
    builder: (column) => column,
  );
}

class $$UserProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfilesTable,
          UserProfileRow,
          $$UserProfilesTableFilterComposer,
          $$UserProfilesTableOrderingComposer,
          $$UserProfilesTableAnnotationComposer,
          $$UserProfilesTableCreateCompanionBuilder,
          $$UserProfilesTableUpdateCompanionBuilder,
          (
            UserProfileRow,
            BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfileRow>,
          ),
          UserProfileRow,
          PrefetchHooks Function()
        > {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> json = const Value.absent(),
                Value<bool> onboardingDone = const Value.absent(),
              }) => UserProfilesCompanion(
                id: id,
                json: json,
                onboardingDone: onboardingDone,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String json,
                Value<bool> onboardingDone = const Value.absent(),
              }) => UserProfilesCompanion.insert(
                id: id,
                json: json,
                onboardingDone: onboardingDone,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfilesTable,
      UserProfileRow,
      $$UserProfilesTableFilterComposer,
      $$UserProfilesTableOrderingComposer,
      $$UserProfilesTableAnnotationComposer,
      $$UserProfilesTableCreateCompanionBuilder,
      $$UserProfilesTableUpdateCompanionBuilder,
      (
        UserProfileRow,
        BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfileRow>,
      ),
      UserProfileRow,
      PrefetchHooks Function()
    >;
typedef $$ActivePlansTableCreateCompanionBuilder =
    ActivePlansCompanion Function({
      required String id,
      required String json,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ActivePlansTableUpdateCompanionBuilder =
    ActivePlansCompanion Function({
      Value<String> id,
      Value<String> json,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$ActivePlansTableFilterComposer
    extends Composer<_$AppDatabase, $ActivePlansTable> {
  $$ActivePlansTableFilterComposer({
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

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ActivePlansTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivePlansTable> {
  $$ActivePlansTableOrderingComposer({
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

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ActivePlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivePlansTable> {
  $$ActivePlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ActivePlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActivePlansTable,
          ActivePlanRow,
          $$ActivePlansTableFilterComposer,
          $$ActivePlansTableOrderingComposer,
          $$ActivePlansTableAnnotationComposer,
          $$ActivePlansTableCreateCompanionBuilder,
          $$ActivePlansTableUpdateCompanionBuilder,
          (
            ActivePlanRow,
            BaseReferences<_$AppDatabase, $ActivePlansTable, ActivePlanRow>,
          ),
          ActivePlanRow,
          PrefetchHooks Function()
        > {
  $$ActivePlansTableTableManager(_$AppDatabase db, $ActivePlansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivePlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivePlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivePlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> json = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivePlansCompanion(
                id: id,
                json: json,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String json,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ActivePlansCompanion.insert(
                id: id,
                json: json,
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

typedef $$ActivePlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActivePlansTable,
      ActivePlanRow,
      $$ActivePlansTableFilterComposer,
      $$ActivePlansTableOrderingComposer,
      $$ActivePlansTableAnnotationComposer,
      $$ActivePlansTableCreateCompanionBuilder,
      $$ActivePlansTableUpdateCompanionBuilder,
      (
        ActivePlanRow,
        BaseReferences<_$AppDatabase, $ActivePlansTable, ActivePlanRow>,
      ),
      ActivePlanRow,
      PrefetchHooks Function()
    >;
typedef $$PlannedSessionsTableCreateCompanionBuilder =
    PlannedSessionsCompanion Function({
      required String id,
      required String planId,
      required int sequenceIndex,
      required String type,
      required String json,
      Value<int> rowid,
    });
typedef $$PlannedSessionsTableUpdateCompanionBuilder =
    PlannedSessionsCompanion Function({
      Value<String> id,
      Value<String> planId,
      Value<int> sequenceIndex,
      Value<String> type,
      Value<String> json,
      Value<int> rowid,
    });

class $$PlannedSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $PlannedSessionsTable> {
  $$PlannedSessionsTableFilterComposer({
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

  ColumnFilters<String> get planId => $composableBuilder(
    column: $table.planId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequenceIndex => $composableBuilder(
    column: $table.sequenceIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlannedSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlannedSessionsTable> {
  $$PlannedSessionsTableOrderingComposer({
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

  ColumnOrderings<String> get planId => $composableBuilder(
    column: $table.planId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequenceIndex => $composableBuilder(
    column: $table.sequenceIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlannedSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlannedSessionsTable> {
  $$PlannedSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get planId =>
      $composableBuilder(column: $table.planId, builder: (column) => column);

  GeneratedColumn<int> get sequenceIndex => $composableBuilder(
    column: $table.sequenceIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);
}

class $$PlannedSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlannedSessionsTable,
          PlannedSessionRow,
          $$PlannedSessionsTableFilterComposer,
          $$PlannedSessionsTableOrderingComposer,
          $$PlannedSessionsTableAnnotationComposer,
          $$PlannedSessionsTableCreateCompanionBuilder,
          $$PlannedSessionsTableUpdateCompanionBuilder,
          (
            PlannedSessionRow,
            BaseReferences<
              _$AppDatabase,
              $PlannedSessionsTable,
              PlannedSessionRow
            >,
          ),
          PlannedSessionRow,
          PrefetchHooks Function()
        > {
  $$PlannedSessionsTableTableManager(
    _$AppDatabase db,
    $PlannedSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlannedSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlannedSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlannedSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> planId = const Value.absent(),
                Value<int> sequenceIndex = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> json = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlannedSessionsCompanion(
                id: id,
                planId: planId,
                sequenceIndex: sequenceIndex,
                type: type,
                json: json,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String planId,
                required int sequenceIndex,
                required String type,
                required String json,
                Value<int> rowid = const Value.absent(),
              }) => PlannedSessionsCompanion.insert(
                id: id,
                planId: planId,
                sequenceIndex: sequenceIndex,
                type: type,
                json: json,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlannedSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlannedSessionsTable,
      PlannedSessionRow,
      $$PlannedSessionsTableFilterComposer,
      $$PlannedSessionsTableOrderingComposer,
      $$PlannedSessionsTableAnnotationComposer,
      $$PlannedSessionsTableCreateCompanionBuilder,
      $$PlannedSessionsTableUpdateCompanionBuilder,
      (
        PlannedSessionRow,
        BaseReferences<_$AppDatabase, $PlannedSessionsTable, PlannedSessionRow>,
      ),
      PlannedSessionRow,
      PrefetchHooks Function()
    >;
typedef $$WorkoutLogsTableCreateCompanionBuilder =
    WorkoutLogsCompanion Function({
      required String id,
      required String sessionId,
      required String date,
      required String type,
      required String status,
      required String json,
      required DateTime completedAt,
      Value<int> rowid,
    });
typedef $$WorkoutLogsTableUpdateCompanionBuilder =
    WorkoutLogsCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<String> date,
      Value<String> type,
      Value<String> status,
      Value<String> json,
      Value<DateTime> completedAt,
      Value<int> rowid,
    });

class $$WorkoutLogsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutLogsTable> {
  $$WorkoutLogsTableFilterComposer({
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

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkoutLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutLogsTable> {
  $$WorkoutLogsTableOrderingComposer({
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

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkoutLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutLogsTable> {
  $$WorkoutLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$WorkoutLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutLogsTable,
          WorkoutLogRow,
          $$WorkoutLogsTableFilterComposer,
          $$WorkoutLogsTableOrderingComposer,
          $$WorkoutLogsTableAnnotationComposer,
          $$WorkoutLogsTableCreateCompanionBuilder,
          $$WorkoutLogsTableUpdateCompanionBuilder,
          (
            WorkoutLogRow,
            BaseReferences<_$AppDatabase, $WorkoutLogsTable, WorkoutLogRow>,
          ),
          WorkoutLogRow,
          PrefetchHooks Function()
        > {
  $$WorkoutLogsTableTableManager(_$AppDatabase db, $WorkoutLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> json = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutLogsCompanion(
                id: id,
                sessionId: sessionId,
                date: date,
                type: type,
                status: status,
                json: json,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required String date,
                required String type,
                required String status,
                required String json,
                required DateTime completedAt,
                Value<int> rowid = const Value.absent(),
              }) => WorkoutLogsCompanion.insert(
                id: id,
                sessionId: sessionId,
                date: date,
                type: type,
                status: status,
                json: json,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkoutLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutLogsTable,
      WorkoutLogRow,
      $$WorkoutLogsTableFilterComposer,
      $$WorkoutLogsTableOrderingComposer,
      $$WorkoutLogsTableAnnotationComposer,
      $$WorkoutLogsTableCreateCompanionBuilder,
      $$WorkoutLogsTableUpdateCompanionBuilder,
      (
        WorkoutLogRow,
        BaseReferences<_$AppDatabase, $WorkoutLogsTable, WorkoutLogRow>,
      ),
      WorkoutLogRow,
      PrefetchHooks Function()
    >;
typedef $$ExercisesTableCreateCompanionBuilder =
    ExercisesCompanion Function({
      Value<int> id,
      required String name,
      Value<String> region,
      Value<String> regionsJson,
      Value<String> jointsJson,
      Value<String> musclesJson,
      Value<String> equipmentJson,
      Value<String?> anatomyNote,
      Value<String> source,
      Value<String?> imagePath,
      Value<String> cuesJson,
      Value<String?> nameEn,
    });
typedef $$ExercisesTableUpdateCompanionBuilder =
    ExercisesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> region,
      Value<String> regionsJson,
      Value<String> jointsJson,
      Value<String> musclesJson,
      Value<String> equipmentJson,
      Value<String?> anatomyNote,
      Value<String> source,
      Value<String?> imagePath,
      Value<String> cuesJson,
      Value<String?> nameEn,
    });

class $$ExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get regionsJson => $composableBuilder(
    column: $table.regionsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jointsJson => $composableBuilder(
    column: $table.jointsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get musclesJson => $composableBuilder(
    column: $table.musclesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equipmentJson => $composableBuilder(
    column: $table.equipmentJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get anatomyNote => $composableBuilder(
    column: $table.anatomyNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cuesJson => $composableBuilder(
    column: $table.cuesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get regionsJson => $composableBuilder(
    column: $table.regionsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jointsJson => $composableBuilder(
    column: $table.jointsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get musclesJson => $composableBuilder(
    column: $table.musclesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipmentJson => $composableBuilder(
    column: $table.equipmentJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get anatomyNote => $composableBuilder(
    column: $table.anatomyNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cuesJson => $composableBuilder(
    column: $table.cuesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get region =>
      $composableBuilder(column: $table.region, builder: (column) => column);

  GeneratedColumn<String> get regionsJson => $composableBuilder(
    column: $table.regionsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get jointsJson => $composableBuilder(
    column: $table.jointsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get musclesJson => $composableBuilder(
    column: $table.musclesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get equipmentJson => $composableBuilder(
    column: $table.equipmentJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get anatomyNote => $composableBuilder(
    column: $table.anatomyNote,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<String> get cuesJson =>
      $composableBuilder(column: $table.cuesJson, builder: (column) => column);

  GeneratedColumn<String> get nameEn =>
      $composableBuilder(column: $table.nameEn, builder: (column) => column);
}

class $$ExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExercisesTable,
          Exercise,
          $$ExercisesTableFilterComposer,
          $$ExercisesTableOrderingComposer,
          $$ExercisesTableAnnotationComposer,
          $$ExercisesTableCreateCompanionBuilder,
          $$ExercisesTableUpdateCompanionBuilder,
          (Exercise, BaseReferences<_$AppDatabase, $ExercisesTable, Exercise>),
          Exercise,
          PrefetchHooks Function()
        > {
  $$ExercisesTableTableManager(_$AppDatabase db, $ExercisesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> region = const Value.absent(),
                Value<String> regionsJson = const Value.absent(),
                Value<String> jointsJson = const Value.absent(),
                Value<String> musclesJson = const Value.absent(),
                Value<String> equipmentJson = const Value.absent(),
                Value<String?> anatomyNote = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<String> cuesJson = const Value.absent(),
                Value<String?> nameEn = const Value.absent(),
              }) => ExercisesCompanion(
                id: id,
                name: name,
                region: region,
                regionsJson: regionsJson,
                jointsJson: jointsJson,
                musclesJson: musclesJson,
                equipmentJson: equipmentJson,
                anatomyNote: anatomyNote,
                source: source,
                imagePath: imagePath,
                cuesJson: cuesJson,
                nameEn: nameEn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String> region = const Value.absent(),
                Value<String> regionsJson = const Value.absent(),
                Value<String> jointsJson = const Value.absent(),
                Value<String> musclesJson = const Value.absent(),
                Value<String> equipmentJson = const Value.absent(),
                Value<String?> anatomyNote = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<String> cuesJson = const Value.absent(),
                Value<String?> nameEn = const Value.absent(),
              }) => ExercisesCompanion.insert(
                id: id,
                name: name,
                region: region,
                regionsJson: regionsJson,
                jointsJson: jointsJson,
                musclesJson: musclesJson,
                equipmentJson: equipmentJson,
                anatomyNote: anatomyNote,
                source: source,
                imagePath: imagePath,
                cuesJson: cuesJson,
                nameEn: nameEn,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExercisesTable,
      Exercise,
      $$ExercisesTableFilterComposer,
      $$ExercisesTableOrderingComposer,
      $$ExercisesTableAnnotationComposer,
      $$ExercisesTableCreateCompanionBuilder,
      $$ExercisesTableUpdateCompanionBuilder,
      (Exercise, BaseReferences<_$AppDatabase, $ExercisesTable, Exercise>),
      Exercise,
      PrefetchHooks Function()
    >;
typedef $$AnatomyRowsTableCreateCompanionBuilder =
    AnatomyRowsCompanion Function({
      Value<int> id,
      required String tableKind,
      required String json,
    });
typedef $$AnatomyRowsTableUpdateCompanionBuilder =
    AnatomyRowsCompanion Function({
      Value<int> id,
      Value<String> tableKind,
      Value<String> json,
    });

class $$AnatomyRowsTableFilterComposer
    extends Composer<_$AppDatabase, $AnatomyRowsTable> {
  $$AnatomyRowsTableFilterComposer({
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

  ColumnFilters<String> get tableKind => $composableBuilder(
    column: $table.tableKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AnatomyRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $AnatomyRowsTable> {
  $$AnatomyRowsTableOrderingComposer({
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

  ColumnOrderings<String> get tableKind => $composableBuilder(
    column: $table.tableKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AnatomyRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AnatomyRowsTable> {
  $$AnatomyRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tableKind =>
      $composableBuilder(column: $table.tableKind, builder: (column) => column);

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);
}

class $$AnatomyRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AnatomyRowsTable,
          AnatomyRow,
          $$AnatomyRowsTableFilterComposer,
          $$AnatomyRowsTableOrderingComposer,
          $$AnatomyRowsTableAnnotationComposer,
          $$AnatomyRowsTableCreateCompanionBuilder,
          $$AnatomyRowsTableUpdateCompanionBuilder,
          (
            AnatomyRow,
            BaseReferences<_$AppDatabase, $AnatomyRowsTable, AnatomyRow>,
          ),
          AnatomyRow,
          PrefetchHooks Function()
        > {
  $$AnatomyRowsTableTableManager(_$AppDatabase db, $AnatomyRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnatomyRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnatomyRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnatomyRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> tableKind = const Value.absent(),
                Value<String> json = const Value.absent(),
              }) => AnatomyRowsCompanion(
                id: id,
                tableKind: tableKind,
                json: json,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String tableKind,
                required String json,
              }) => AnatomyRowsCompanion.insert(
                id: id,
                tableKind: tableKind,
                json: json,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AnatomyRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AnatomyRowsTable,
      AnatomyRow,
      $$AnatomyRowsTableFilterComposer,
      $$AnatomyRowsTableOrderingComposer,
      $$AnatomyRowsTableAnnotationComposer,
      $$AnatomyRowsTableCreateCompanionBuilder,
      $$AnatomyRowsTableUpdateCompanionBuilder,
      (
        AnatomyRow,
        BaseReferences<_$AppDatabase, $AnatomyRowsTable, AnatomyRow>,
      ),
      AnatomyRow,
      PrefetchHooks Function()
    >;
typedef $$FoodsTableCreateCompanionBuilder =
    FoodsCompanion Function({
      Value<int> id,
      required String name,
      required String category,
      required double rate,
      required String macroHint,
      Value<String?> note,
    });
typedef $$FoodsTableUpdateCompanionBuilder =
    FoodsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> category,
      Value<double> rate,
      Value<String> macroHint,
      Value<String?> note,
    });

class $$FoodsTableFilterComposer extends Composer<_$AppDatabase, $FoodsTable> {
  $$FoodsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get macroHint => $composableBuilder(
    column: $table.macroHint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FoodsTableOrderingComposer
    extends Composer<_$AppDatabase, $FoodsTable> {
  $$FoodsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get macroHint => $composableBuilder(
    column: $table.macroHint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FoodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoodsTable> {
  $$FoodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get rate =>
      $composableBuilder(column: $table.rate, builder: (column) => column);

  GeneratedColumn<String> get macroHint =>
      $composableBuilder(column: $table.macroHint, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$FoodsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FoodsTable,
          Food,
          $$FoodsTableFilterComposer,
          $$FoodsTableOrderingComposer,
          $$FoodsTableAnnotationComposer,
          $$FoodsTableCreateCompanionBuilder,
          $$FoodsTableUpdateCompanionBuilder,
          (Food, BaseReferences<_$AppDatabase, $FoodsTable, Food>),
          Food,
          PrefetchHooks Function()
        > {
  $$FoodsTableTableManager(_$AppDatabase db, $FoodsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<double> rate = const Value.absent(),
                Value<String> macroHint = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => FoodsCompanion(
                id: id,
                name: name,
                category: category,
                rate: rate,
                macroHint: macroHint,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String category,
                required double rate,
                required String macroHint,
                Value<String?> note = const Value.absent(),
              }) => FoodsCompanion.insert(
                id: id,
                name: name,
                category: category,
                rate: rate,
                macroHint: macroHint,
                note: note,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FoodsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FoodsTable,
      Food,
      $$FoodsTableFilterComposer,
      $$FoodsTableOrderingComposer,
      $$FoodsTableAnnotationComposer,
      $$FoodsTableCreateCompanionBuilder,
      $$FoodsTableUpdateCompanionBuilder,
      (Food, BaseReferences<_$AppDatabase, $FoodsTable, Food>),
      Food,
      PrefetchHooks Function()
    >;
typedef $$CardioItemsTableCreateCompanionBuilder =
    CardioItemsCompanion Function({
      Value<int> id,
      required String name,
      required double kcalPerKgPerHour,
      Value<String?> category,
    });
typedef $$CardioItemsTableUpdateCompanionBuilder =
    CardioItemsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<double> kcalPerKgPerHour,
      Value<String?> category,
    });

class $$CardioItemsTableFilterComposer
    extends Composer<_$AppDatabase, $CardioItemsTable> {
  $$CardioItemsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kcalPerKgPerHour => $composableBuilder(
    column: $table.kcalPerKgPerHour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CardioItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $CardioItemsTable> {
  $$CardioItemsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kcalPerKgPerHour => $composableBuilder(
    column: $table.kcalPerKgPerHour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CardioItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardioItemsTable> {
  $$CardioItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get kcalPerKgPerHour => $composableBuilder(
    column: $table.kcalPerKgPerHour,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);
}

class $$CardioItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CardioItemsTable,
          CardioItem,
          $$CardioItemsTableFilterComposer,
          $$CardioItemsTableOrderingComposer,
          $$CardioItemsTableAnnotationComposer,
          $$CardioItemsTableCreateCompanionBuilder,
          $$CardioItemsTableUpdateCompanionBuilder,
          (
            CardioItem,
            BaseReferences<_$AppDatabase, $CardioItemsTable, CardioItem>,
          ),
          CardioItem,
          PrefetchHooks Function()
        > {
  $$CardioItemsTableTableManager(_$AppDatabase db, $CardioItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardioItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardioItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardioItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> kcalPerKgPerHour = const Value.absent(),
                Value<String?> category = const Value.absent(),
              }) => CardioItemsCompanion(
                id: id,
                name: name,
                kcalPerKgPerHour: kcalPerKgPerHour,
                category: category,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required double kcalPerKgPerHour,
                Value<String?> category = const Value.absent(),
              }) => CardioItemsCompanion.insert(
                id: id,
                name: name,
                kcalPerKgPerHour: kcalPerKgPerHour,
                category: category,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CardioItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CardioItemsTable,
      CardioItem,
      $$CardioItemsTableFilterComposer,
      $$CardioItemsTableOrderingComposer,
      $$CardioItemsTableAnnotationComposer,
      $$CardioItemsTableCreateCompanionBuilder,
      $$CardioItemsTableUpdateCompanionBuilder,
      (
        CardioItem,
        BaseReferences<_$AppDatabase, $CardioItemsTable, CardioItem>,
      ),
      CardioItem,
      PrefetchHooks Function()
    >;
typedef $$FaqItemsTableCreateCompanionBuilder =
    FaqItemsCompanion Function({
      Value<int> id,
      required String goal,
      required String question,
      required String answer,
    });
typedef $$FaqItemsTableUpdateCompanionBuilder =
    FaqItemsCompanion Function({
      Value<int> id,
      Value<String> goal,
      Value<String> question,
      Value<String> answer,
    });

class $$FaqItemsTableFilterComposer
    extends Composer<_$AppDatabase, $FaqItemsTable> {
  $$FaqItemsTableFilterComposer({
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

  ColumnFilters<String> get goal => $composableBuilder(
    column: $table.goal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get question => $composableBuilder(
    column: $table.question,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get answer => $composableBuilder(
    column: $table.answer,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FaqItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $FaqItemsTable> {
  $$FaqItemsTableOrderingComposer({
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

  ColumnOrderings<String> get goal => $composableBuilder(
    column: $table.goal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get question => $composableBuilder(
    column: $table.question,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get answer => $composableBuilder(
    column: $table.answer,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FaqItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FaqItemsTable> {
  $$FaqItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get goal =>
      $composableBuilder(column: $table.goal, builder: (column) => column);

  GeneratedColumn<String> get question =>
      $composableBuilder(column: $table.question, builder: (column) => column);

  GeneratedColumn<String> get answer =>
      $composableBuilder(column: $table.answer, builder: (column) => column);
}

class $$FaqItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FaqItemsTable,
          FaqItem,
          $$FaqItemsTableFilterComposer,
          $$FaqItemsTableOrderingComposer,
          $$FaqItemsTableAnnotationComposer,
          $$FaqItemsTableCreateCompanionBuilder,
          $$FaqItemsTableUpdateCompanionBuilder,
          (FaqItem, BaseReferences<_$AppDatabase, $FaqItemsTable, FaqItem>),
          FaqItem,
          PrefetchHooks Function()
        > {
  $$FaqItemsTableTableManager(_$AppDatabase db, $FaqItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FaqItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FaqItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FaqItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> goal = const Value.absent(),
                Value<String> question = const Value.absent(),
                Value<String> answer = const Value.absent(),
              }) => FaqItemsCompanion(
                id: id,
                goal: goal,
                question: question,
                answer: answer,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String goal,
                required String question,
                required String answer,
              }) => FaqItemsCompanion.insert(
                id: id,
                goal: goal,
                question: question,
                answer: answer,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FaqItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FaqItemsTable,
      FaqItem,
      $$FaqItemsTableFilterComposer,
      $$FaqItemsTableOrderingComposer,
      $$FaqItemsTableAnnotationComposer,
      $$FaqItemsTableCreateCompanionBuilder,
      $$FaqItemsTableUpdateCompanionBuilder,
      (FaqItem, BaseReferences<_$AppDatabase, $FaqItemsTable, FaqItem>),
      FaqItem,
      PrefetchHooks Function()
    >;
typedef $$SplitTemplatesTableCreateCompanionBuilder =
    SplitTemplatesCompanion Function({
      required String id,
      required String json,
      Value<int> rowid,
    });
typedef $$SplitTemplatesTableUpdateCompanionBuilder =
    SplitTemplatesCompanion Function({
      Value<String> id,
      Value<String> json,
      Value<int> rowid,
    });

class $$SplitTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $SplitTemplatesTable> {
  $$SplitTemplatesTableFilterComposer({
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

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SplitTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $SplitTemplatesTable> {
  $$SplitTemplatesTableOrderingComposer({
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

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SplitTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SplitTemplatesTable> {
  $$SplitTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);
}

class $$SplitTemplatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SplitTemplatesTable,
          SplitTemplate,
          $$SplitTemplatesTableFilterComposer,
          $$SplitTemplatesTableOrderingComposer,
          $$SplitTemplatesTableAnnotationComposer,
          $$SplitTemplatesTableCreateCompanionBuilder,
          $$SplitTemplatesTableUpdateCompanionBuilder,
          (
            SplitTemplate,
            BaseReferences<_$AppDatabase, $SplitTemplatesTable, SplitTemplate>,
          ),
          SplitTemplate,
          PrefetchHooks Function()
        > {
  $$SplitTemplatesTableTableManager(
    _$AppDatabase db,
    $SplitTemplatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SplitTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SplitTemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SplitTemplatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> json = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SplitTemplatesCompanion(id: id, json: json, rowid: rowid),
          createCompanionCallback:
              ({
                required String id,
                required String json,
                Value<int> rowid = const Value.absent(),
              }) => SplitTemplatesCompanion.insert(
                id: id,
                json: json,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SplitTemplatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SplitTemplatesTable,
      SplitTemplate,
      $$SplitTemplatesTableFilterComposer,
      $$SplitTemplatesTableOrderingComposer,
      $$SplitTemplatesTableAnnotationComposer,
      $$SplitTemplatesTableCreateCompanionBuilder,
      $$SplitTemplatesTableUpdateCompanionBuilder,
      (
        SplitTemplate,
        BaseReferences<_$AppDatabase, $SplitTemplatesTable, SplitTemplate>,
      ),
      SplitTemplate,
      PrefetchHooks Function()
    >;
typedef $$DietRulesStoreTableCreateCompanionBuilder =
    DietRulesStoreCompanion Function({Value<int> id, required String json});
typedef $$DietRulesStoreTableUpdateCompanionBuilder =
    DietRulesStoreCompanion Function({Value<int> id, Value<String> json});

class $$DietRulesStoreTableFilterComposer
    extends Composer<_$AppDatabase, $DietRulesStoreTable> {
  $$DietRulesStoreTableFilterComposer({
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

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DietRulesStoreTableOrderingComposer
    extends Composer<_$AppDatabase, $DietRulesStoreTable> {
  $$DietRulesStoreTableOrderingComposer({
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

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DietRulesStoreTableAnnotationComposer
    extends Composer<_$AppDatabase, $DietRulesStoreTable> {
  $$DietRulesStoreTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);
}

class $$DietRulesStoreTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DietRulesStoreTable,
          DietRulesStoreData,
          $$DietRulesStoreTableFilterComposer,
          $$DietRulesStoreTableOrderingComposer,
          $$DietRulesStoreTableAnnotationComposer,
          $$DietRulesStoreTableCreateCompanionBuilder,
          $$DietRulesStoreTableUpdateCompanionBuilder,
          (
            DietRulesStoreData,
            BaseReferences<
              _$AppDatabase,
              $DietRulesStoreTable,
              DietRulesStoreData
            >,
          ),
          DietRulesStoreData,
          PrefetchHooks Function()
        > {
  $$DietRulesStoreTableTableManager(
    _$AppDatabase db,
    $DietRulesStoreTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DietRulesStoreTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DietRulesStoreTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DietRulesStoreTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> json = const Value.absent(),
              }) => DietRulesStoreCompanion(id: id, json: json),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String json}) =>
                  DietRulesStoreCompanion.insert(id: id, json: json),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DietRulesStoreTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DietRulesStoreTable,
      DietRulesStoreData,
      $$DietRulesStoreTableFilterComposer,
      $$DietRulesStoreTableOrderingComposer,
      $$DietRulesStoreTableAnnotationComposer,
      $$DietRulesStoreTableCreateCompanionBuilder,
      $$DietRulesStoreTableUpdateCompanionBuilder,
      (
        DietRulesStoreData,
        BaseReferences<_$AppDatabase, $DietRulesStoreTable, DietRulesStoreData>,
      ),
      DietRulesStoreData,
      PrefetchHooks Function()
    >;
typedef $$YogaSequencesTableCreateCompanionBuilder =
    YogaSequencesCompanion Function({
      required String id,
      required String json,
      Value<int> rowid,
    });
typedef $$YogaSequencesTableUpdateCompanionBuilder =
    YogaSequencesCompanion Function({
      Value<String> id,
      Value<String> json,
      Value<int> rowid,
    });

class $$YogaSequencesTableFilterComposer
    extends Composer<_$AppDatabase, $YogaSequencesTable> {
  $$YogaSequencesTableFilterComposer({
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

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );
}

class $$YogaSequencesTableOrderingComposer
    extends Composer<_$AppDatabase, $YogaSequencesTable> {
  $$YogaSequencesTableOrderingComposer({
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

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$YogaSequencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $YogaSequencesTable> {
  $$YogaSequencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);
}

class $$YogaSequencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $YogaSequencesTable,
          YogaSequence,
          $$YogaSequencesTableFilterComposer,
          $$YogaSequencesTableOrderingComposer,
          $$YogaSequencesTableAnnotationComposer,
          $$YogaSequencesTableCreateCompanionBuilder,
          $$YogaSequencesTableUpdateCompanionBuilder,
          (
            YogaSequence,
            BaseReferences<_$AppDatabase, $YogaSequencesTable, YogaSequence>,
          ),
          YogaSequence,
          PrefetchHooks Function()
        > {
  $$YogaSequencesTableTableManager(_$AppDatabase db, $YogaSequencesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$YogaSequencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$YogaSequencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$YogaSequencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> json = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => YogaSequencesCompanion(id: id, json: json, rowid: rowid),
          createCompanionCallback:
              ({
                required String id,
                required String json,
                Value<int> rowid = const Value.absent(),
              }) => YogaSequencesCompanion.insert(
                id: id,
                json: json,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$YogaSequencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $YogaSequencesTable,
      YogaSequence,
      $$YogaSequencesTableFilterComposer,
      $$YogaSequencesTableOrderingComposer,
      $$YogaSequencesTableAnnotationComposer,
      $$YogaSequencesTableCreateCompanionBuilder,
      $$YogaSequencesTableUpdateCompanionBuilder,
      (
        YogaSequence,
        BaseReferences<_$AppDatabase, $YogaSequencesTable, YogaSequence>,
      ),
      YogaSequence,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AppMetaTableTableManager get appMeta =>
      $$AppMetaTableTableManager(_db, _db.appMeta);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
  $$ActivePlansTableTableManager get activePlans =>
      $$ActivePlansTableTableManager(_db, _db.activePlans);
  $$PlannedSessionsTableTableManager get plannedSessions =>
      $$PlannedSessionsTableTableManager(_db, _db.plannedSessions);
  $$WorkoutLogsTableTableManager get workoutLogs =>
      $$WorkoutLogsTableTableManager(_db, _db.workoutLogs);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db, _db.exercises);
  $$AnatomyRowsTableTableManager get anatomyRows =>
      $$AnatomyRowsTableTableManager(_db, _db.anatomyRows);
  $$FoodsTableTableManager get foods =>
      $$FoodsTableTableManager(_db, _db.foods);
  $$CardioItemsTableTableManager get cardioItems =>
      $$CardioItemsTableTableManager(_db, _db.cardioItems);
  $$FaqItemsTableTableManager get faqItems =>
      $$FaqItemsTableTableManager(_db, _db.faqItems);
  $$SplitTemplatesTableTableManager get splitTemplates =>
      $$SplitTemplatesTableTableManager(_db, _db.splitTemplates);
  $$DietRulesStoreTableTableManager get dietRulesStore =>
      $$DietRulesStoreTableTableManager(_db, _db.dietRulesStore);
  $$YogaSequencesTableTableManager get yogaSequences =>
      $$YogaSequencesTableTableManager(_db, _db.yogaSequences);
}
