// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ProvidersTable extends Providers
    with TableInfo<$ProvidersTable, ProviderRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProvidersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ProviderKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ProviderKind>($ProvidersTable.$converterkind);
  static const VerificationMeta _brandColorMeta = const VerificationMeta(
    'brandColor',
  );
  @override
  late final GeneratedColumn<String> brandColor = GeneratedColumn<String>(
    'brand_color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _logoAssetMeta = const VerificationMeta(
    'logoAsset',
  );
  @override
  late final GeneratedColumn<String> logoAsset = GeneratedColumn<String>(
    'logo_asset',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notificationPackageMeta =
      const VerificationMeta('notificationPackage');
  @override
  late final GeneratedColumn<String> notificationPackage =
      GeneratedColumn<String>(
        'notification_package',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    key,
    displayName,
    kind,
    brandColor,
    logoAsset,
    notificationPackage,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'providers';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProviderRow> instance, {
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
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('brand_color')) {
      context.handle(
        _brandColorMeta,
        brandColor.isAcceptableOrUnknown(data['brand_color']!, _brandColorMeta),
      );
    } else if (isInserting) {
      context.missing(_brandColorMeta);
    }
    if (data.containsKey('logo_asset')) {
      context.handle(
        _logoAssetMeta,
        logoAsset.isAcceptableOrUnknown(data['logo_asset']!, _logoAssetMeta),
      );
    } else if (isInserting) {
      context.missing(_logoAssetMeta);
    }
    if (data.containsKey('notification_package')) {
      context.handle(
        _notificationPackageMeta,
        notificationPackage.isAcceptableOrUnknown(
          data['notification_package']!,
          _notificationPackageMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  ProviderRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProviderRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      kind: $ProvidersTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      brandColor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand_color'],
      )!,
      logoAsset: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logo_asset'],
      )!,
      notificationPackage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notification_package'],
      ),
    );
  }

  @override
  $ProvidersTable createAlias(String alias) {
    return $ProvidersTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ProviderKind, String, String> $converterkind =
      const EnumNameConverter<ProviderKind>(ProviderKind.values);
}

class ProviderRow extends DataClass implements Insertable<ProviderRow> {
  final String key;
  final String displayName;
  final ProviderKind kind;
  final String brandColor;
  final String logoAsset;

  /// The Android package that sends transaction alerts. Null when the provider
  /// has no app, such as cash.
  final String? notificationPackage;
  const ProviderRow({
    required this.key,
    required this.displayName,
    required this.kind,
    required this.brandColor,
    required this.logoAsset,
    this.notificationPackage,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['display_name'] = Variable<String>(displayName);
    {
      map['kind'] = Variable<String>(
        $ProvidersTable.$converterkind.toSql(kind),
      );
    }
    map['brand_color'] = Variable<String>(brandColor);
    map['logo_asset'] = Variable<String>(logoAsset);
    if (!nullToAbsent || notificationPackage != null) {
      map['notification_package'] = Variable<String>(notificationPackage);
    }
    return map;
  }

  ProvidersCompanion toCompanion(bool nullToAbsent) {
    return ProvidersCompanion(
      key: Value(key),
      displayName: Value(displayName),
      kind: Value(kind),
      brandColor: Value(brandColor),
      logoAsset: Value(logoAsset),
      notificationPackage: notificationPackage == null && nullToAbsent
          ? const Value.absent()
          : Value(notificationPackage),
    );
  }

  factory ProviderRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProviderRow(
      key: serializer.fromJson<String>(json['key']),
      displayName: serializer.fromJson<String>(json['displayName']),
      kind: $ProvidersTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      brandColor: serializer.fromJson<String>(json['brandColor']),
      logoAsset: serializer.fromJson<String>(json['logoAsset']),
      notificationPackage: serializer.fromJson<String?>(
        json['notificationPackage'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'displayName': serializer.toJson<String>(displayName),
      'kind': serializer.toJson<String>(
        $ProvidersTable.$converterkind.toJson(kind),
      ),
      'brandColor': serializer.toJson<String>(brandColor),
      'logoAsset': serializer.toJson<String>(logoAsset),
      'notificationPackage': serializer.toJson<String?>(notificationPackage),
    };
  }

  ProviderRow copyWith({
    String? key,
    String? displayName,
    ProviderKind? kind,
    String? brandColor,
    String? logoAsset,
    Value<String?> notificationPackage = const Value.absent(),
  }) => ProviderRow(
    key: key ?? this.key,
    displayName: displayName ?? this.displayName,
    kind: kind ?? this.kind,
    brandColor: brandColor ?? this.brandColor,
    logoAsset: logoAsset ?? this.logoAsset,
    notificationPackage: notificationPackage.present
        ? notificationPackage.value
        : this.notificationPackage,
  );
  ProviderRow copyWithCompanion(ProvidersCompanion data) {
    return ProviderRow(
      key: data.key.present ? data.key.value : this.key,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      kind: data.kind.present ? data.kind.value : this.kind,
      brandColor: data.brandColor.present
          ? data.brandColor.value
          : this.brandColor,
      logoAsset: data.logoAsset.present ? data.logoAsset.value : this.logoAsset,
      notificationPackage: data.notificationPackage.present
          ? data.notificationPackage.value
          : this.notificationPackage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProviderRow(')
          ..write('key: $key, ')
          ..write('displayName: $displayName, ')
          ..write('kind: $kind, ')
          ..write('brandColor: $brandColor, ')
          ..write('logoAsset: $logoAsset, ')
          ..write('notificationPackage: $notificationPackage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    key,
    displayName,
    kind,
    brandColor,
    logoAsset,
    notificationPackage,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProviderRow &&
          other.key == this.key &&
          other.displayName == this.displayName &&
          other.kind == this.kind &&
          other.brandColor == this.brandColor &&
          other.logoAsset == this.logoAsset &&
          other.notificationPackage == this.notificationPackage);
}

class ProvidersCompanion extends UpdateCompanion<ProviderRow> {
  final Value<String> key;
  final Value<String> displayName;
  final Value<ProviderKind> kind;
  final Value<String> brandColor;
  final Value<String> logoAsset;
  final Value<String?> notificationPackage;
  final Value<int> rowid;
  const ProvidersCompanion({
    this.key = const Value.absent(),
    this.displayName = const Value.absent(),
    this.kind = const Value.absent(),
    this.brandColor = const Value.absent(),
    this.logoAsset = const Value.absent(),
    this.notificationPackage = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProvidersCompanion.insert({
    required String key,
    required String displayName,
    required ProviderKind kind,
    required String brandColor,
    required String logoAsset,
    this.notificationPackage = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       displayName = Value(displayName),
       kind = Value(kind),
       brandColor = Value(brandColor),
       logoAsset = Value(logoAsset);
  static Insertable<ProviderRow> custom({
    Expression<String>? key,
    Expression<String>? displayName,
    Expression<String>? kind,
    Expression<String>? brandColor,
    Expression<String>? logoAsset,
    Expression<String>? notificationPackage,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (displayName != null) 'display_name': displayName,
      if (kind != null) 'kind': kind,
      if (brandColor != null) 'brand_color': brandColor,
      if (logoAsset != null) 'logo_asset': logoAsset,
      if (notificationPackage != null)
        'notification_package': notificationPackage,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProvidersCompanion copyWith({
    Value<String>? key,
    Value<String>? displayName,
    Value<ProviderKind>? kind,
    Value<String>? brandColor,
    Value<String>? logoAsset,
    Value<String?>? notificationPackage,
    Value<int>? rowid,
  }) {
    return ProvidersCompanion(
      key: key ?? this.key,
      displayName: displayName ?? this.displayName,
      kind: kind ?? this.kind,
      brandColor: brandColor ?? this.brandColor,
      logoAsset: logoAsset ?? this.logoAsset,
      notificationPackage: notificationPackage ?? this.notificationPackage,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $ProvidersTable.$converterkind.toSql(kind.value),
      );
    }
    if (brandColor.present) {
      map['brand_color'] = Variable<String>(brandColor.value);
    }
    if (logoAsset.present) {
      map['logo_asset'] = Variable<String>(logoAsset.value);
    }
    if (notificationPackage.present) {
      map['notification_package'] = Variable<String>(notificationPackage.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProvidersCompanion(')
          ..write('key: $key, ')
          ..write('displayName: $displayName, ')
          ..write('kind: $kind, ')
          ..write('brandColor: $brandColor, ')
          ..write('logoAsset: $logoAsset, ')
          ..write('notificationPackage: $notificationPackage, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AccountsTable extends Accounts
    with TableInfo<$AccountsTable, AccountRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant<String>('local'),
  );
  static const VerificationMeta _providerKeyMeta = const VerificationMeta(
    'providerKey',
  );
  @override
  late final GeneratedColumn<String> providerKey = GeneratedColumn<String>(
    'provider_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES providers ("key")',
    ),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<AccountRole, String> role =
      GeneratedColumn<String>(
        'role',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<AccountRole>($AccountsTable.$converterrole);
  static const VerificationMeta _includeInSpendableMeta =
      const VerificationMeta('includeInSpendable');
  @override
  late final GeneratedColumn<bool> includeInSpendable = GeneratedColumn<bool>(
    'include_in_spendable',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("include_in_spendable" IN (0, 1))',
    ),
    defaultValue: const Constant<bool>(true),
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant<bool>(false),
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    providerKey,
    label,
    role,
    includeInSpendable,
    isArchived,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<AccountRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('provider_key')) {
      context.handle(
        _providerKeyMeta,
        providerKey.isAcceptableOrUnknown(
          data['provider_key']!,
          _providerKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_providerKeyMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('include_in_spendable')) {
      context.handle(
        _includeInSpendableMeta,
        includeInSpendable.isAcceptableOrUnknown(
          data['include_in_spendable']!,
          _includeInSpendableMeta,
        ),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AccountRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      providerKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_key'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      role: $AccountsTable.$converterrole.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}role'],
        )!,
      ),
      includeInSpendable: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}include_in_spendable'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AccountRole, String, String> $converterrole =
      const EnumNameConverter<AccountRole>(AccountRole.values);
}

class AccountRow extends DataClass implements Insertable<AccountRow> {
  final String id;
  final String userId;
  final String providerKey;
  final String label;
  final AccountRole role;

  /// False for money the user does not treat as available, such as a bond.
  final bool includeInSpendable;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Set when the row is soft deleted, so sync can carry the deletion.
  final DateTime? deletedAt;
  const AccountRow({
    required this.id,
    required this.userId,
    required this.providerKey,
    required this.label,
    required this.role,
    required this.includeInSpendable,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['provider_key'] = Variable<String>(providerKey);
    map['label'] = Variable<String>(label);
    {
      map['role'] = Variable<String>($AccountsTable.$converterrole.toSql(role));
    }
    map['include_in_spendable'] = Variable<bool>(includeInSpendable);
    map['is_archived'] = Variable<bool>(isArchived);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      userId: Value(userId),
      providerKey: Value(providerKey),
      label: Value(label),
      role: Value(role),
      includeInSpendable: Value(includeInSpendable),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory AccountRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      providerKey: serializer.fromJson<String>(json['providerKey']),
      label: serializer.fromJson<String>(json['label']),
      role: $AccountsTable.$converterrole.fromJson(
        serializer.fromJson<String>(json['role']),
      ),
      includeInSpendable: serializer.fromJson<bool>(json['includeInSpendable']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'providerKey': serializer.toJson<String>(providerKey),
      'label': serializer.toJson<String>(label),
      'role': serializer.toJson<String>(
        $AccountsTable.$converterrole.toJson(role),
      ),
      'includeInSpendable': serializer.toJson<bool>(includeInSpendable),
      'isArchived': serializer.toJson<bool>(isArchived),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  AccountRow copyWith({
    String? id,
    String? userId,
    String? providerKey,
    String? label,
    AccountRole? role,
    bool? includeInSpendable,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => AccountRow(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    providerKey: providerKey ?? this.providerKey,
    label: label ?? this.label,
    role: role ?? this.role,
    includeInSpendable: includeInSpendable ?? this.includeInSpendable,
    isArchived: isArchived ?? this.isArchived,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  AccountRow copyWithCompanion(AccountsCompanion data) {
    return AccountRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      providerKey: data.providerKey.present
          ? data.providerKey.value
          : this.providerKey,
      label: data.label.present ? data.label.value : this.label,
      role: data.role.present ? data.role.value : this.role,
      includeInSpendable: data.includeInSpendable.present
          ? data.includeInSpendable.value
          : this.includeInSpendable,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccountRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('providerKey: $providerKey, ')
          ..write('label: $label, ')
          ..write('role: $role, ')
          ..write('includeInSpendable: $includeInSpendable, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    providerKey,
    label,
    role,
    includeInSpendable,
    isArchived,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.providerKey == this.providerKey &&
          other.label == this.label &&
          other.role == this.role &&
          other.includeInSpendable == this.includeInSpendable &&
          other.isArchived == this.isArchived &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class AccountsCompanion extends UpdateCompanion<AccountRow> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> providerKey;
  final Value<String> label;
  final Value<AccountRole> role;
  final Value<bool> includeInSpendable;
  final Value<bool> isArchived;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.providerKey = const Value.absent(),
    this.label = const Value.absent(),
    this.role = const Value.absent(),
    this.includeInSpendable = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required String providerKey,
    required String label,
    required AccountRole role,
    this.includeInSpendable = const Value.absent(),
    this.isArchived = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       providerKey = Value(providerKey),
       label = Value(label),
       role = Value(role),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<AccountRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? providerKey,
    Expression<String>? label,
    Expression<String>? role,
    Expression<bool>? includeInSpendable,
    Expression<bool>? isArchived,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (providerKey != null) 'provider_key': providerKey,
      if (label != null) 'label': label,
      if (role != null) 'role': role,
      if (includeInSpendable != null)
        'include_in_spendable': includeInSpendable,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? providerKey,
    Value<String>? label,
    Value<AccountRole>? role,
    Value<bool>? includeInSpendable,
    Value<bool>? isArchived,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return AccountsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      providerKey: providerKey ?? this.providerKey,
      label: label ?? this.label,
      role: role ?? this.role,
      includeInSpendable: includeInSpendable ?? this.includeInSpendable,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (providerKey.present) {
      map['provider_key'] = Variable<String>(providerKey.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(
        $AccountsTable.$converterrole.toSql(role.value),
      );
    }
    if (includeInSpendable.present) {
      map['include_in_spendable'] = Variable<bool>(includeInSpendable.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('providerKey: $providerKey, ')
          ..write('label: $label, ')
          ..write('role: $role, ')
          ..write('includeInSpendable: $includeInSpendable, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BalanceSnapshotsTable extends BalanceSnapshots
    with TableInfo<$BalanceSnapshotsTable, BalanceSnapshotRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BalanceSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Money, int> balanceCents =
      GeneratedColumn<int>(
        'balance_cents',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<Money>($BalanceSnapshotsTable.$converterbalanceCents);
  @override
  late final GeneratedColumnWithTypeConverter<SnapshotSource, String> source =
      GeneratedColumn<String>(
        'source',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SnapshotSource>($BalanceSnapshotsTable.$convertersource);
  static const VerificationMeta _capturedAtMeta = const VerificationMeta(
    'capturedAt',
  );
  @override
  late final GeneratedColumn<DateTime> capturedAt = GeneratedColumn<DateTime>(
    'captured_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
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
    accountId,
    balanceCents,
    source,
    capturedAt,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'balance_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<BalanceSnapshotRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('captured_at')) {
      context.handle(
        _capturedAtMeta,
        capturedAt.isAcceptableOrUnknown(data['captured_at']!, _capturedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_capturedAtMeta);
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
  BalanceSnapshotRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BalanceSnapshotRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      balanceCents: $BalanceSnapshotsTable.$converterbalanceCents.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}balance_cents'],
        )!,
      ),
      source: $BalanceSnapshotsTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}source'],
        )!,
      ),
      capturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}captured_at'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $BalanceSnapshotsTable createAlias(String alias) {
    return $BalanceSnapshotsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Money, int, int> $converterbalanceCents =
      const MoneyConverter();
  static JsonTypeConverter2<SnapshotSource, String, String> $convertersource =
      const EnumNameConverter<SnapshotSource>(SnapshotSource.values);
}

class BalanceSnapshotRow extends DataClass
    implements Insertable<BalanceSnapshotRow> {
  final String id;
  final String accountId;
  final Money balanceCents;
  final SnapshotSource source;
  final DateTime capturedAt;
  final String? note;
  const BalanceSnapshotRow({
    required this.id,
    required this.accountId,
    required this.balanceCents,
    required this.source,
    required this.capturedAt,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['account_id'] = Variable<String>(accountId);
    {
      map['balance_cents'] = Variable<int>(
        $BalanceSnapshotsTable.$converterbalanceCents.toSql(balanceCents),
      );
    }
    {
      map['source'] = Variable<String>(
        $BalanceSnapshotsTable.$convertersource.toSql(source),
      );
    }
    map['captured_at'] = Variable<DateTime>(capturedAt);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  BalanceSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return BalanceSnapshotsCompanion(
      id: Value(id),
      accountId: Value(accountId),
      balanceCents: Value(balanceCents),
      source: Value(source),
      capturedAt: Value(capturedAt),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory BalanceSnapshotRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BalanceSnapshotRow(
      id: serializer.fromJson<String>(json['id']),
      accountId: serializer.fromJson<String>(json['accountId']),
      balanceCents: $BalanceSnapshotsTable.$converterbalanceCents.fromJson(
        serializer.fromJson<int>(json['balanceCents']),
      ),
      source: $BalanceSnapshotsTable.$convertersource.fromJson(
        serializer.fromJson<String>(json['source']),
      ),
      capturedAt: serializer.fromJson<DateTime>(json['capturedAt']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'accountId': serializer.toJson<String>(accountId),
      'balanceCents': serializer.toJson<int>(
        $BalanceSnapshotsTable.$converterbalanceCents.toJson(balanceCents),
      ),
      'source': serializer.toJson<String>(
        $BalanceSnapshotsTable.$convertersource.toJson(source),
      ),
      'capturedAt': serializer.toJson<DateTime>(capturedAt),
      'note': serializer.toJson<String?>(note),
    };
  }

  BalanceSnapshotRow copyWith({
    String? id,
    String? accountId,
    Money? balanceCents,
    SnapshotSource? source,
    DateTime? capturedAt,
    Value<String?> note = const Value.absent(),
  }) => BalanceSnapshotRow(
    id: id ?? this.id,
    accountId: accountId ?? this.accountId,
    balanceCents: balanceCents ?? this.balanceCents,
    source: source ?? this.source,
    capturedAt: capturedAt ?? this.capturedAt,
    note: note.present ? note.value : this.note,
  );
  BalanceSnapshotRow copyWithCompanion(BalanceSnapshotsCompanion data) {
    return BalanceSnapshotRow(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      balanceCents: data.balanceCents.present
          ? data.balanceCents.value
          : this.balanceCents,
      source: data.source.present ? data.source.value : this.source,
      capturedAt: data.capturedAt.present
          ? data.capturedAt.value
          : this.capturedAt,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BalanceSnapshotRow(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('balanceCents: $balanceCents, ')
          ..write('source: $source, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, accountId, balanceCents, source, capturedAt, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BalanceSnapshotRow &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.balanceCents == this.balanceCents &&
          other.source == this.source &&
          other.capturedAt == this.capturedAt &&
          other.note == this.note);
}

class BalanceSnapshotsCompanion extends UpdateCompanion<BalanceSnapshotRow> {
  final Value<String> id;
  final Value<String> accountId;
  final Value<Money> balanceCents;
  final Value<SnapshotSource> source;
  final Value<DateTime> capturedAt;
  final Value<String?> note;
  final Value<int> rowid;
  const BalanceSnapshotsCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.balanceCents = const Value.absent(),
    this.source = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BalanceSnapshotsCompanion.insert({
    required String id,
    required String accountId,
    required Money balanceCents,
    required SnapshotSource source,
    required DateTime capturedAt,
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       accountId = Value(accountId),
       balanceCents = Value(balanceCents),
       source = Value(source),
       capturedAt = Value(capturedAt);
  static Insertable<BalanceSnapshotRow> custom({
    Expression<String>? id,
    Expression<String>? accountId,
    Expression<int>? balanceCents,
    Expression<String>? source,
    Expression<DateTime>? capturedAt,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (balanceCents != null) 'balance_cents': balanceCents,
      if (source != null) 'source': source,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BalanceSnapshotsCompanion copyWith({
    Value<String>? id,
    Value<String>? accountId,
    Value<Money>? balanceCents,
    Value<SnapshotSource>? source,
    Value<DateTime>? capturedAt,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return BalanceSnapshotsCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      balanceCents: balanceCents ?? this.balanceCents,
      source: source ?? this.source,
      capturedAt: capturedAt ?? this.capturedAt,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (balanceCents.present) {
      map['balance_cents'] = Variable<int>(
        $BalanceSnapshotsTable.$converterbalanceCents.toSql(balanceCents.value),
      );
    }
    if (source.present) {
      map['source'] = Variable<String>(
        $BalanceSnapshotsTable.$convertersource.toSql(source.value),
      );
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BalanceSnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('balanceCents: $balanceCents, ')
          ..write('source: $source, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isEssentialMeta = const VerificationMeta(
    'isEssential',
  );
  @override
  late final GeneratedColumn<bool> isEssential = GeneratedColumn<bool>(
    'is_essential',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_essential" IN (0, 1))',
    ),
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    key,
    displayName,
    isEssential,
    icon,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryRow> instance, {
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
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('is_essential')) {
      context.handle(
        _isEssentialMeta,
        isEssential.isAcceptableOrUnknown(
          data['is_essential']!,
          _isEssentialMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_isEssentialMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  CategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      isEssential: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_essential'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class CategoryRow extends DataClass implements Insertable<CategoryRow> {
  final String key;
  final String displayName;

  /// Transport and food are essential. Dates are not. Drives which envelope a
  /// shortfall is allowed to hurt.
  final bool isEssential;
  final String icon;
  final int sortOrder;
  const CategoryRow({
    required this.key,
    required this.displayName,
    required this.isEssential,
    required this.icon,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['display_name'] = Variable<String>(displayName);
    map['is_essential'] = Variable<bool>(isEssential);
    map['icon'] = Variable<String>(icon);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      key: Value(key),
      displayName: Value(displayName),
      isEssential: Value(isEssential),
      icon: Value(icon),
      sortOrder: Value(sortOrder),
    );
  }

  factory CategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRow(
      key: serializer.fromJson<String>(json['key']),
      displayName: serializer.fromJson<String>(json['displayName']),
      isEssential: serializer.fromJson<bool>(json['isEssential']),
      icon: serializer.fromJson<String>(json['icon']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'displayName': serializer.toJson<String>(displayName),
      'isEssential': serializer.toJson<bool>(isEssential),
      'icon': serializer.toJson<String>(icon),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  CategoryRow copyWith({
    String? key,
    String? displayName,
    bool? isEssential,
    String? icon,
    int? sortOrder,
  }) => CategoryRow(
    key: key ?? this.key,
    displayName: displayName ?? this.displayName,
    isEssential: isEssential ?? this.isEssential,
    icon: icon ?? this.icon,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  CategoryRow copyWithCompanion(CategoriesCompanion data) {
    return CategoryRow(
      key: data.key.present ? data.key.value : this.key,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      isEssential: data.isEssential.present
          ? data.isEssential.value
          : this.isEssential,
      icon: data.icon.present ? data.icon.value : this.icon,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRow(')
          ..write('key: $key, ')
          ..write('displayName: $displayName, ')
          ..write('isEssential: $isEssential, ')
          ..write('icon: $icon, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(key, displayName, isEssential, icon, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRow &&
          other.key == this.key &&
          other.displayName == this.displayName &&
          other.isEssential == this.isEssential &&
          other.icon == this.icon &&
          other.sortOrder == this.sortOrder);
}

class CategoriesCompanion extends UpdateCompanion<CategoryRow> {
  final Value<String> key;
  final Value<String> displayName;
  final Value<bool> isEssential;
  final Value<String> icon;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.key = const Value.absent(),
    this.displayName = const Value.absent(),
    this.isEssential = const Value.absent(),
    this.icon = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String key,
    required String displayName,
    required bool isEssential,
    required String icon,
    required int sortOrder,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       displayName = Value(displayName),
       isEssential = Value(isEssential),
       icon = Value(icon),
       sortOrder = Value(sortOrder);
  static Insertable<CategoryRow> custom({
    Expression<String>? key,
    Expression<String>? displayName,
    Expression<bool>? isEssential,
    Expression<String>? icon,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (displayName != null) 'display_name': displayName,
      if (isEssential != null) 'is_essential': isEssential,
      if (icon != null) 'icon': icon,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? key,
    Value<String>? displayName,
    Value<bool>? isEssential,
    Value<String>? icon,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      key: key ?? this.key,
      displayName: displayName ?? this.displayName,
      isEssential: isEssential ?? this.isEssential,
      icon: icon ?? this.icon,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (isEssential.present) {
      map['is_essential'] = Variable<bool>(isEssential.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('key: $key, ')
          ..write('displayName: $displayName, ')
          ..write('isEssential: $isEssential, ')
          ..write('icon: $icon, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TxnsTable extends Txns with TableInfo<$TxnsTable, TxnRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TxnsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Money, int> amountCents =
      GeneratedColumn<int>(
        'amount_cents',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<Money>($TxnsTable.$converteramountCents);
  @override
  late final GeneratedColumnWithTypeConverter<TxnDirection, String> direction =
      GeneratedColumn<String>(
        'direction',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TxnDirection>($TxnsTable.$converterdirection);
  static const VerificationMeta _categoryKeyMeta = const VerificationMeta(
    'categoryKey',
  );
  @override
  late final GeneratedColumn<String> categoryKey = GeneratedColumn<String>(
    'category_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories ("key")',
    ),
  );
  static const VerificationMeta _merchantRawMeta = const VerificationMeta(
    'merchantRaw',
  );
  @override
  late final GeneratedColumn<String> merchantRaw = GeneratedColumn<String>(
    'merchant_raw',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TxnSource, String> source =
      GeneratedColumn<String>(
        'source',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TxnSource>($TxnsTable.$convertersource);
  static const VerificationMeta _categoryConfidenceMeta =
      const VerificationMeta('categoryConfidence');
  @override
  late final GeneratedColumn<double> categoryConfidence =
      GeneratedColumn<double>(
        'category_confidence',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant<double>(0),
      );
  static const VerificationMeta _userCorrectedMeta = const VerificationMeta(
    'userCorrected',
  );
  @override
  late final GeneratedColumn<bool> userCorrected = GeneratedColumn<bool>(
    'user_corrected',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("user_corrected" IN (0, 1))',
    ),
    defaultValue: const Constant<bool>(false),
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    accountId,
    amountCents,
    direction,
    categoryKey,
    merchantRaw,
    note,
    occurredAt,
    source,
    categoryConfidence,
    userCorrected,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'txns';
  @override
  VerificationContext validateIntegrity(
    Insertable<TxnRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('category_key')) {
      context.handle(
        _categoryKeyMeta,
        categoryKey.isAcceptableOrUnknown(
          data['category_key']!,
          _categoryKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_categoryKeyMeta);
    }
    if (data.containsKey('merchant_raw')) {
      context.handle(
        _merchantRawMeta,
        merchantRaw.isAcceptableOrUnknown(
          data['merchant_raw']!,
          _merchantRawMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('category_confidence')) {
      context.handle(
        _categoryConfidenceMeta,
        categoryConfidence.isAcceptableOrUnknown(
          data['category_confidence']!,
          _categoryConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('user_corrected')) {
      context.handle(
        _userCorrectedMeta,
        userCorrected.isAcceptableOrUnknown(
          data['user_corrected']!,
          _userCorrectedMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TxnRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TxnRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      amountCents: $TxnsTable.$converteramountCents.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}amount_cents'],
        )!,
      ),
      direction: $TxnsTable.$converterdirection.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}direction'],
        )!,
      ),
      categoryKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_key'],
      )!,
      merchantRaw: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}merchant_raw'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      source: $TxnsTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}source'],
        )!,
      ),
      categoryConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}category_confidence'],
      )!,
      userCorrected: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}user_corrected'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $TxnsTable createAlias(String alias) {
    return $TxnsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Money, int, int> $converteramountCents =
      const MoneyConverter();
  static JsonTypeConverter2<TxnDirection, String, String> $converterdirection =
      const EnumNameConverter<TxnDirection>(TxnDirection.values);
  static JsonTypeConverter2<TxnSource, String, String> $convertersource =
      const EnumNameConverter<TxnSource>(TxnSource.values);
}

class TxnRow extends DataClass implements Insertable<TxnRow> {
  final String id;
  final String accountId;

  /// Always positive. [direction] carries the sign.
  final Money amountCents;
  final TxnDirection direction;
  final String categoryKey;

  /// The source text the categorizer reads.
  final String? merchantRaw;
  final String? note;
  final DateTime occurredAt;
  final TxnSource source;
  final double categoryConfidence;

  /// 1 marks a row the user relabelled. These rows are the training set.
  final bool userCorrected;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const TxnRow({
    required this.id,
    required this.accountId,
    required this.amountCents,
    required this.direction,
    required this.categoryKey,
    this.merchantRaw,
    this.note,
    required this.occurredAt,
    required this.source,
    required this.categoryConfidence,
    required this.userCorrected,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['account_id'] = Variable<String>(accountId);
    {
      map['amount_cents'] = Variable<int>(
        $TxnsTable.$converteramountCents.toSql(amountCents),
      );
    }
    {
      map['direction'] = Variable<String>(
        $TxnsTable.$converterdirection.toSql(direction),
      );
    }
    map['category_key'] = Variable<String>(categoryKey);
    if (!nullToAbsent || merchantRaw != null) {
      map['merchant_raw'] = Variable<String>(merchantRaw);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    {
      map['source'] = Variable<String>(
        $TxnsTable.$convertersource.toSql(source),
      );
    }
    map['category_confidence'] = Variable<double>(categoryConfidence);
    map['user_corrected'] = Variable<bool>(userCorrected);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  TxnsCompanion toCompanion(bool nullToAbsent) {
    return TxnsCompanion(
      id: Value(id),
      accountId: Value(accountId),
      amountCents: Value(amountCents),
      direction: Value(direction),
      categoryKey: Value(categoryKey),
      merchantRaw: merchantRaw == null && nullToAbsent
          ? const Value.absent()
          : Value(merchantRaw),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      occurredAt: Value(occurredAt),
      source: Value(source),
      categoryConfidence: Value(categoryConfidence),
      userCorrected: Value(userCorrected),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory TxnRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TxnRow(
      id: serializer.fromJson<String>(json['id']),
      accountId: serializer.fromJson<String>(json['accountId']),
      amountCents: $TxnsTable.$converteramountCents.fromJson(
        serializer.fromJson<int>(json['amountCents']),
      ),
      direction: $TxnsTable.$converterdirection.fromJson(
        serializer.fromJson<String>(json['direction']),
      ),
      categoryKey: serializer.fromJson<String>(json['categoryKey']),
      merchantRaw: serializer.fromJson<String?>(json['merchantRaw']),
      note: serializer.fromJson<String?>(json['note']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      source: $TxnsTable.$convertersource.fromJson(
        serializer.fromJson<String>(json['source']),
      ),
      categoryConfidence: serializer.fromJson<double>(
        json['categoryConfidence'],
      ),
      userCorrected: serializer.fromJson<bool>(json['userCorrected']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'accountId': serializer.toJson<String>(accountId),
      'amountCents': serializer.toJson<int>(
        $TxnsTable.$converteramountCents.toJson(amountCents),
      ),
      'direction': serializer.toJson<String>(
        $TxnsTable.$converterdirection.toJson(direction),
      ),
      'categoryKey': serializer.toJson<String>(categoryKey),
      'merchantRaw': serializer.toJson<String?>(merchantRaw),
      'note': serializer.toJson<String?>(note),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'source': serializer.toJson<String>(
        $TxnsTable.$convertersource.toJson(source),
      ),
      'categoryConfidence': serializer.toJson<double>(categoryConfidence),
      'userCorrected': serializer.toJson<bool>(userCorrected),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  TxnRow copyWith({
    String? id,
    String? accountId,
    Money? amountCents,
    TxnDirection? direction,
    String? categoryKey,
    Value<String?> merchantRaw = const Value.absent(),
    Value<String?> note = const Value.absent(),
    DateTime? occurredAt,
    TxnSource? source,
    double? categoryConfidence,
    bool? userCorrected,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => TxnRow(
    id: id ?? this.id,
    accountId: accountId ?? this.accountId,
    amountCents: amountCents ?? this.amountCents,
    direction: direction ?? this.direction,
    categoryKey: categoryKey ?? this.categoryKey,
    merchantRaw: merchantRaw.present ? merchantRaw.value : this.merchantRaw,
    note: note.present ? note.value : this.note,
    occurredAt: occurredAt ?? this.occurredAt,
    source: source ?? this.source,
    categoryConfidence: categoryConfidence ?? this.categoryConfidence,
    userCorrected: userCorrected ?? this.userCorrected,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  TxnRow copyWithCompanion(TxnsCompanion data) {
    return TxnRow(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
      direction: data.direction.present ? data.direction.value : this.direction,
      categoryKey: data.categoryKey.present
          ? data.categoryKey.value
          : this.categoryKey,
      merchantRaw: data.merchantRaw.present
          ? data.merchantRaw.value
          : this.merchantRaw,
      note: data.note.present ? data.note.value : this.note,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      source: data.source.present ? data.source.value : this.source,
      categoryConfidence: data.categoryConfidence.present
          ? data.categoryConfidence.value
          : this.categoryConfidence,
      userCorrected: data.userCorrected.present
          ? data.userCorrected.value
          : this.userCorrected,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TxnRow(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('amountCents: $amountCents, ')
          ..write('direction: $direction, ')
          ..write('categoryKey: $categoryKey, ')
          ..write('merchantRaw: $merchantRaw, ')
          ..write('note: $note, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('source: $source, ')
          ..write('categoryConfidence: $categoryConfidence, ')
          ..write('userCorrected: $userCorrected, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    accountId,
    amountCents,
    direction,
    categoryKey,
    merchantRaw,
    note,
    occurredAt,
    source,
    categoryConfidence,
    userCorrected,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TxnRow &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.amountCents == this.amountCents &&
          other.direction == this.direction &&
          other.categoryKey == this.categoryKey &&
          other.merchantRaw == this.merchantRaw &&
          other.note == this.note &&
          other.occurredAt == this.occurredAt &&
          other.source == this.source &&
          other.categoryConfidence == this.categoryConfidence &&
          other.userCorrected == this.userCorrected &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class TxnsCompanion extends UpdateCompanion<TxnRow> {
  final Value<String> id;
  final Value<String> accountId;
  final Value<Money> amountCents;
  final Value<TxnDirection> direction;
  final Value<String> categoryKey;
  final Value<String?> merchantRaw;
  final Value<String?> note;
  final Value<DateTime> occurredAt;
  final Value<TxnSource> source;
  final Value<double> categoryConfidence;
  final Value<bool> userCorrected;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const TxnsCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.direction = const Value.absent(),
    this.categoryKey = const Value.absent(),
    this.merchantRaw = const Value.absent(),
    this.note = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.source = const Value.absent(),
    this.categoryConfidence = const Value.absent(),
    this.userCorrected = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TxnsCompanion.insert({
    required String id,
    required String accountId,
    required Money amountCents,
    required TxnDirection direction,
    required String categoryKey,
    this.merchantRaw = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime occurredAt,
    required TxnSource source,
    this.categoryConfidence = const Value.absent(),
    this.userCorrected = const Value.absent(),
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       accountId = Value(accountId),
       amountCents = Value(amountCents),
       direction = Value(direction),
       categoryKey = Value(categoryKey),
       occurredAt = Value(occurredAt),
       source = Value(source),
       updatedAt = Value(updatedAt);
  static Insertable<TxnRow> custom({
    Expression<String>? id,
    Expression<String>? accountId,
    Expression<int>? amountCents,
    Expression<String>? direction,
    Expression<String>? categoryKey,
    Expression<String>? merchantRaw,
    Expression<String>? note,
    Expression<DateTime>? occurredAt,
    Expression<String>? source,
    Expression<double>? categoryConfidence,
    Expression<bool>? userCorrected,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (amountCents != null) 'amount_cents': amountCents,
      if (direction != null) 'direction': direction,
      if (categoryKey != null) 'category_key': categoryKey,
      if (merchantRaw != null) 'merchant_raw': merchantRaw,
      if (note != null) 'note': note,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (source != null) 'source': source,
      if (categoryConfidence != null) 'category_confidence': categoryConfidence,
      if (userCorrected != null) 'user_corrected': userCorrected,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TxnsCompanion copyWith({
    Value<String>? id,
    Value<String>? accountId,
    Value<Money>? amountCents,
    Value<TxnDirection>? direction,
    Value<String>? categoryKey,
    Value<String?>? merchantRaw,
    Value<String?>? note,
    Value<DateTime>? occurredAt,
    Value<TxnSource>? source,
    Value<double>? categoryConfidence,
    Value<bool>? userCorrected,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return TxnsCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      amountCents: amountCents ?? this.amountCents,
      direction: direction ?? this.direction,
      categoryKey: categoryKey ?? this.categoryKey,
      merchantRaw: merchantRaw ?? this.merchantRaw,
      note: note ?? this.note,
      occurredAt: occurredAt ?? this.occurredAt,
      source: source ?? this.source,
      categoryConfidence: categoryConfidence ?? this.categoryConfidence,
      userCorrected: userCorrected ?? this.userCorrected,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(
        $TxnsTable.$converteramountCents.toSql(amountCents.value),
      );
    }
    if (direction.present) {
      map['direction'] = Variable<String>(
        $TxnsTable.$converterdirection.toSql(direction.value),
      );
    }
    if (categoryKey.present) {
      map['category_key'] = Variable<String>(categoryKey.value);
    }
    if (merchantRaw.present) {
      map['merchant_raw'] = Variable<String>(merchantRaw.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(
        $TxnsTable.$convertersource.toSql(source.value),
      );
    }
    if (categoryConfidence.present) {
      map['category_confidence'] = Variable<double>(categoryConfidence.value);
    }
    if (userCorrected.present) {
      map['user_corrected'] = Variable<bool>(userCorrected.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TxnsCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('amountCents: $amountCents, ')
          ..write('direction: $direction, ')
          ..write('categoryKey: $categoryKey, ')
          ..write('merchantRaw: $merchantRaw, ')
          ..write('note: $note, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('source: $source, ')
          ..write('categoryConfidence: $categoryConfidence, ')
          ..write('userCorrected: $userCorrected, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ObligationsTable extends Obligations
    with TableInfo<$ObligationsTable, ObligationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ObligationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant<String>('local'),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Money, int> amountCents =
      GeneratedColumn<int>(
        'amount_cents',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<Money>($ObligationsTable.$converteramountCents);
  @override
  late final GeneratedColumnWithTypeConverter<Cadence, String> cadence =
      GeneratedColumn<String>(
        'cadence',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Cadence>($ObligationsTable.$convertercadence);
  static const VerificationMeta _nextDueOnMeta = const VerificationMeta(
    'nextDueOn',
  );
  @override
  late final GeneratedColumn<DateTime> nextDueOn = GeneratedColumn<DateTime>(
    'next_due_on',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryKeyMeta = const VerificationMeta(
    'categoryKey',
  );
  @override
  late final GeneratedColumn<String> categoryKey = GeneratedColumn<String>(
    'category_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories ("key")',
    ),
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    label,
    amountCents,
    cadence,
    nextDueOn,
    categoryKey,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'obligations';
  @override
  VerificationContext validateIntegrity(
    Insertable<ObligationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('next_due_on')) {
      context.handle(
        _nextDueOnMeta,
        nextDueOn.isAcceptableOrUnknown(data['next_due_on']!, _nextDueOnMeta),
      );
    } else if (isInserting) {
      context.missing(_nextDueOnMeta);
    }
    if (data.containsKey('category_key')) {
      context.handle(
        _categoryKeyMeta,
        categoryKey.isAcceptableOrUnknown(
          data['category_key']!,
          _categoryKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_categoryKeyMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ObligationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ObligationRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      amountCents: $ObligationsTable.$converteramountCents.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}amount_cents'],
        )!,
      ),
      cadence: $ObligationsTable.$convertercadence.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}cadence'],
        )!,
      ),
      nextDueOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_due_on'],
      )!,
      categoryKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_key'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $ObligationsTable createAlias(String alias) {
    return $ObligationsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Money, int, int> $converteramountCents =
      const MoneyConverter();
  static JsonTypeConverter2<Cadence, String, String> $convertercadence =
      const EnumNameConverter<Cadence>(Cadence.values);
}

class ObligationRow extends DataClass implements Insertable<ObligationRow> {
  final String id;
  final String userId;
  final String label;
  final Money amountCents;
  final Cadence cadence;
  final DateTime nextDueOn;
  final String categoryKey;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const ObligationRow({
    required this.id,
    required this.userId,
    required this.label,
    required this.amountCents,
    required this.cadence,
    required this.nextDueOn,
    required this.categoryKey,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['label'] = Variable<String>(label);
    {
      map['amount_cents'] = Variable<int>(
        $ObligationsTable.$converteramountCents.toSql(amountCents),
      );
    }
    {
      map['cadence'] = Variable<String>(
        $ObligationsTable.$convertercadence.toSql(cadence),
      );
    }
    map['next_due_on'] = Variable<DateTime>(nextDueOn);
    map['category_key'] = Variable<String>(categoryKey);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  ObligationsCompanion toCompanion(bool nullToAbsent) {
    return ObligationsCompanion(
      id: Value(id),
      userId: Value(userId),
      label: Value(label),
      amountCents: Value(amountCents),
      cadence: Value(cadence),
      nextDueOn: Value(nextDueOn),
      categoryKey: Value(categoryKey),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory ObligationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ObligationRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      label: serializer.fromJson<String>(json['label']),
      amountCents: $ObligationsTable.$converteramountCents.fromJson(
        serializer.fromJson<int>(json['amountCents']),
      ),
      cadence: $ObligationsTable.$convertercadence.fromJson(
        serializer.fromJson<String>(json['cadence']),
      ),
      nextDueOn: serializer.fromJson<DateTime>(json['nextDueOn']),
      categoryKey: serializer.fromJson<String>(json['categoryKey']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'label': serializer.toJson<String>(label),
      'amountCents': serializer.toJson<int>(
        $ObligationsTable.$converteramountCents.toJson(amountCents),
      ),
      'cadence': serializer.toJson<String>(
        $ObligationsTable.$convertercadence.toJson(cadence),
      ),
      'nextDueOn': serializer.toJson<DateTime>(nextDueOn),
      'categoryKey': serializer.toJson<String>(categoryKey),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  ObligationRow copyWith({
    String? id,
    String? userId,
    String? label,
    Money? amountCents,
    Cadence? cadence,
    DateTime? nextDueOn,
    String? categoryKey,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => ObligationRow(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    label: label ?? this.label,
    amountCents: amountCents ?? this.amountCents,
    cadence: cadence ?? this.cadence,
    nextDueOn: nextDueOn ?? this.nextDueOn,
    categoryKey: categoryKey ?? this.categoryKey,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  ObligationRow copyWithCompanion(ObligationsCompanion data) {
    return ObligationRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      label: data.label.present ? data.label.value : this.label,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
      cadence: data.cadence.present ? data.cadence.value : this.cadence,
      nextDueOn: data.nextDueOn.present ? data.nextDueOn.value : this.nextDueOn,
      categoryKey: data.categoryKey.present
          ? data.categoryKey.value
          : this.categoryKey,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ObligationRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('label: $label, ')
          ..write('amountCents: $amountCents, ')
          ..write('cadence: $cadence, ')
          ..write('nextDueOn: $nextDueOn, ')
          ..write('categoryKey: $categoryKey, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    label,
    amountCents,
    cadence,
    nextDueOn,
    categoryKey,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ObligationRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.label == this.label &&
          other.amountCents == this.amountCents &&
          other.cadence == this.cadence &&
          other.nextDueOn == this.nextDueOn &&
          other.categoryKey == this.categoryKey &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class ObligationsCompanion extends UpdateCompanion<ObligationRow> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> label;
  final Value<Money> amountCents;
  final Value<Cadence> cadence;
  final Value<DateTime> nextDueOn;
  final Value<String> categoryKey;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const ObligationsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.label = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.cadence = const Value.absent(),
    this.nextDueOn = const Value.absent(),
    this.categoryKey = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ObligationsCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required String label,
    required Money amountCents,
    required Cadence cadence,
    required DateTime nextDueOn,
    required String categoryKey,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       label = Value(label),
       amountCents = Value(amountCents),
       cadence = Value(cadence),
       nextDueOn = Value(nextDueOn),
       categoryKey = Value(categoryKey),
       updatedAt = Value(updatedAt);
  static Insertable<ObligationRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? label,
    Expression<int>? amountCents,
    Expression<String>? cadence,
    Expression<DateTime>? nextDueOn,
    Expression<String>? categoryKey,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (label != null) 'label': label,
      if (amountCents != null) 'amount_cents': amountCents,
      if (cadence != null) 'cadence': cadence,
      if (nextDueOn != null) 'next_due_on': nextDueOn,
      if (categoryKey != null) 'category_key': categoryKey,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ObligationsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? label,
    Value<Money>? amountCents,
    Value<Cadence>? cadence,
    Value<DateTime>? nextDueOn,
    Value<String>? categoryKey,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return ObligationsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      label: label ?? this.label,
      amountCents: amountCents ?? this.amountCents,
      cadence: cadence ?? this.cadence,
      nextDueOn: nextDueOn ?? this.nextDueOn,
      categoryKey: categoryKey ?? this.categoryKey,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(
        $ObligationsTable.$converteramountCents.toSql(amountCents.value),
      );
    }
    if (cadence.present) {
      map['cadence'] = Variable<String>(
        $ObligationsTable.$convertercadence.toSql(cadence.value),
      );
    }
    if (nextDueOn.present) {
      map['next_due_on'] = Variable<DateTime>(nextDueOn.value);
    }
    if (categoryKey.present) {
      map['category_key'] = Variable<String>(categoryKey.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ObligationsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('label: $label, ')
          ..write('amountCents: $amountCents, ')
          ..write('cadence: $cadence, ')
          ..write('nextDueOn: $nextDueOn, ')
          ..write('categoryKey: $categoryKey, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IncomeExpectationsTable extends IncomeExpectations
    with TableInfo<$IncomeExpectationsTable, IncomeExpectationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IncomeExpectationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant<String>('local'),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Money, int> amountCents =
      GeneratedColumn<int>(
        'amount_cents',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<Money>($IncomeExpectationsTable.$converteramountCents);
  @override
  late final GeneratedColumnWithTypeConverter<Cadence, String> cadence =
      GeneratedColumn<String>(
        'cadence',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Cadence>($IncomeExpectationsTable.$convertercadence);
  static const VerificationMeta _nextExpectedOnMeta = const VerificationMeta(
    'nextExpectedOn',
  );
  @override
  late final GeneratedColumn<DateTime> nextExpectedOn =
      GeneratedColumn<DateTime>(
        'next_expected_on',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  late final GeneratedColumnWithTypeConverter<IncomeConfidence, String>
  confidence =
      GeneratedColumn<String>(
        'confidence',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<IncomeConfidence>(
        $IncomeExpectationsTable.$converterconfidence,
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    label,
    amountCents,
    cadence,
    nextExpectedOn,
    confidence,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'income_expectations';
  @override
  VerificationContext validateIntegrity(
    Insertable<IncomeExpectationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('next_expected_on')) {
      context.handle(
        _nextExpectedOnMeta,
        nextExpectedOn.isAcceptableOrUnknown(
          data['next_expected_on']!,
          _nextExpectedOnMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nextExpectedOnMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IncomeExpectationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IncomeExpectationRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      amountCents: $IncomeExpectationsTable.$converteramountCents.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}amount_cents'],
        )!,
      ),
      cadence: $IncomeExpectationsTable.$convertercadence.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}cadence'],
        )!,
      ),
      nextExpectedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_expected_on'],
      )!,
      confidence: $IncomeExpectationsTable.$converterconfidence.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}confidence'],
        )!,
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $IncomeExpectationsTable createAlias(String alias) {
    return $IncomeExpectationsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Money, int, int> $converteramountCents =
      const MoneyConverter();
  static JsonTypeConverter2<Cadence, String, String> $convertercadence =
      const EnumNameConverter<Cadence>(Cadence.values);
  static JsonTypeConverter2<IncomeConfidence, String, String>
  $converterconfidence = const EnumNameConverter<IncomeConfidence>(
    IncomeConfidence.values,
  );
}

class IncomeExpectationRow extends DataClass
    implements Insertable<IncomeExpectationRow> {
  final String id;
  final String userId;
  final String label;
  final Money amountCents;
  final Cadence cadence;
  final DateTime nextExpectedOn;
  final IncomeConfidence confidence;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const IncomeExpectationRow({
    required this.id,
    required this.userId,
    required this.label,
    required this.amountCents,
    required this.cadence,
    required this.nextExpectedOn,
    required this.confidence,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['label'] = Variable<String>(label);
    {
      map['amount_cents'] = Variable<int>(
        $IncomeExpectationsTable.$converteramountCents.toSql(amountCents),
      );
    }
    {
      map['cadence'] = Variable<String>(
        $IncomeExpectationsTable.$convertercadence.toSql(cadence),
      );
    }
    map['next_expected_on'] = Variable<DateTime>(nextExpectedOn);
    {
      map['confidence'] = Variable<String>(
        $IncomeExpectationsTable.$converterconfidence.toSql(confidence),
      );
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  IncomeExpectationsCompanion toCompanion(bool nullToAbsent) {
    return IncomeExpectationsCompanion(
      id: Value(id),
      userId: Value(userId),
      label: Value(label),
      amountCents: Value(amountCents),
      cadence: Value(cadence),
      nextExpectedOn: Value(nextExpectedOn),
      confidence: Value(confidence),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory IncomeExpectationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IncomeExpectationRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      label: serializer.fromJson<String>(json['label']),
      amountCents: $IncomeExpectationsTable.$converteramountCents.fromJson(
        serializer.fromJson<int>(json['amountCents']),
      ),
      cadence: $IncomeExpectationsTable.$convertercadence.fromJson(
        serializer.fromJson<String>(json['cadence']),
      ),
      nextExpectedOn: serializer.fromJson<DateTime>(json['nextExpectedOn']),
      confidence: $IncomeExpectationsTable.$converterconfidence.fromJson(
        serializer.fromJson<String>(json['confidence']),
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'label': serializer.toJson<String>(label),
      'amountCents': serializer.toJson<int>(
        $IncomeExpectationsTable.$converteramountCents.toJson(amountCents),
      ),
      'cadence': serializer.toJson<String>(
        $IncomeExpectationsTable.$convertercadence.toJson(cadence),
      ),
      'nextExpectedOn': serializer.toJson<DateTime>(nextExpectedOn),
      'confidence': serializer.toJson<String>(
        $IncomeExpectationsTable.$converterconfidence.toJson(confidence),
      ),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  IncomeExpectationRow copyWith({
    String? id,
    String? userId,
    String? label,
    Money? amountCents,
    Cadence? cadence,
    DateTime? nextExpectedOn,
    IncomeConfidence? confidence,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => IncomeExpectationRow(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    label: label ?? this.label,
    amountCents: amountCents ?? this.amountCents,
    cadence: cadence ?? this.cadence,
    nextExpectedOn: nextExpectedOn ?? this.nextExpectedOn,
    confidence: confidence ?? this.confidence,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  IncomeExpectationRow copyWithCompanion(IncomeExpectationsCompanion data) {
    return IncomeExpectationRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      label: data.label.present ? data.label.value : this.label,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
      cadence: data.cadence.present ? data.cadence.value : this.cadence,
      nextExpectedOn: data.nextExpectedOn.present
          ? data.nextExpectedOn.value
          : this.nextExpectedOn,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IncomeExpectationRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('label: $label, ')
          ..write('amountCents: $amountCents, ')
          ..write('cadence: $cadence, ')
          ..write('nextExpectedOn: $nextExpectedOn, ')
          ..write('confidence: $confidence, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    label,
    amountCents,
    cadence,
    nextExpectedOn,
    confidence,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IncomeExpectationRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.label == this.label &&
          other.amountCents == this.amountCents &&
          other.cadence == this.cadence &&
          other.nextExpectedOn == this.nextExpectedOn &&
          other.confidence == this.confidence &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class IncomeExpectationsCompanion
    extends UpdateCompanion<IncomeExpectationRow> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> label;
  final Value<Money> amountCents;
  final Value<Cadence> cadence;
  final Value<DateTime> nextExpectedOn;
  final Value<IncomeConfidence> confidence;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const IncomeExpectationsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.label = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.cadence = const Value.absent(),
    this.nextExpectedOn = const Value.absent(),
    this.confidence = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IncomeExpectationsCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required String label,
    required Money amountCents,
    required Cadence cadence,
    required DateTime nextExpectedOn,
    required IncomeConfidence confidence,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       label = Value(label),
       amountCents = Value(amountCents),
       cadence = Value(cadence),
       nextExpectedOn = Value(nextExpectedOn),
       confidence = Value(confidence),
       updatedAt = Value(updatedAt);
  static Insertable<IncomeExpectationRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? label,
    Expression<int>? amountCents,
    Expression<String>? cadence,
    Expression<DateTime>? nextExpectedOn,
    Expression<String>? confidence,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (label != null) 'label': label,
      if (amountCents != null) 'amount_cents': amountCents,
      if (cadence != null) 'cadence': cadence,
      if (nextExpectedOn != null) 'next_expected_on': nextExpectedOn,
      if (confidence != null) 'confidence': confidence,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IncomeExpectationsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? label,
    Value<Money>? amountCents,
    Value<Cadence>? cadence,
    Value<DateTime>? nextExpectedOn,
    Value<IncomeConfidence>? confidence,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return IncomeExpectationsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      label: label ?? this.label,
      amountCents: amountCents ?? this.amountCents,
      cadence: cadence ?? this.cadence,
      nextExpectedOn: nextExpectedOn ?? this.nextExpectedOn,
      confidence: confidence ?? this.confidence,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(
        $IncomeExpectationsTable.$converteramountCents.toSql(amountCents.value),
      );
    }
    if (cadence.present) {
      map['cadence'] = Variable<String>(
        $IncomeExpectationsTable.$convertercadence.toSql(cadence.value),
      );
    }
    if (nextExpectedOn.present) {
      map['next_expected_on'] = Variable<DateTime>(nextExpectedOn.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<String>(
        $IncomeExpectationsTable.$converterconfidence.toSql(confidence.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IncomeExpectationsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('label: $label, ')
          ..write('amountCents: $amountCents, ')
          ..write('cadence: $cadence, ')
          ..write('nextExpectedOn: $nextExpectedOn, ')
          ..write('confidence: $confidence, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EnvelopesTable extends Envelopes
    with TableInfo<$EnvelopesTable, EnvelopeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EnvelopesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant<String>('local'),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<EnvelopeShape, String> shape =
      GeneratedColumn<String>(
        'shape',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<EnvelopeShape>($EnvelopesTable.$convertershape);
  @override
  late final GeneratedColumnWithTypeConverter<Money, int> refillCents =
      GeneratedColumn<int>(
        'refill_cents',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<Money>($EnvelopesTable.$converterrefillCents);
  @override
  late final GeneratedColumnWithTypeConverter<Cadence, String> refillCadence =
      GeneratedColumn<String>(
        'refill_cadence',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Cadence>($EnvelopesTable.$converterrefillCadence);
  static const VerificationMeta _refillAnchorMeta = const VerificationMeta(
    'refillAnchor',
  );
  @override
  late final GeneratedColumn<String> refillAnchor = GeneratedColumn<String>(
    'refill_anchor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  allowBorrowFrom = GeneratedColumn<String>(
    'allow_borrow_from',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant<String>('[]'),
  ).withConverter<List<String>>($EnvelopesTable.$converterallowBorrowFrom);
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    label,
    shape,
    refillCents,
    refillCadence,
    refillAnchor,
    allowBorrowFrom,
    priority,
    sortOrder,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'envelopes';
  @override
  VerificationContext validateIntegrity(
    Insertable<EnvelopeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('refill_anchor')) {
      context.handle(
        _refillAnchorMeta,
        refillAnchor.isAcceptableOrUnknown(
          data['refill_anchor']!,
          _refillAnchorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_refillAnchorMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    } else if (isInserting) {
      context.missing(_priorityMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EnvelopeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EnvelopeRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      shape: $EnvelopesTable.$convertershape.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}shape'],
        )!,
      ),
      refillCents: $EnvelopesTable.$converterrefillCents.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}refill_cents'],
        )!,
      ),
      refillCadence: $EnvelopesTable.$converterrefillCadence.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}refill_cadence'],
        )!,
      ),
      refillAnchor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}refill_anchor'],
      )!,
      allowBorrowFrom: $EnvelopesTable.$converterallowBorrowFrom.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}allow_borrow_from'],
        )!,
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $EnvelopesTable createAlias(String alias) {
    return $EnvelopesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<EnvelopeShape, String, String> $convertershape =
      const EnumNameConverter<EnvelopeShape>(EnvelopeShape.values);
  static JsonTypeConverter2<Money, int, int> $converterrefillCents =
      const MoneyConverter();
  static JsonTypeConverter2<Cadence, String, String> $converterrefillCadence =
      const EnumNameConverter<Cadence>(Cadence.values);
  static TypeConverter<List<String>, String> $converterallowBorrowFrom =
      const StringListConverter();
}

class EnvelopeRow extends DataClass implements Insertable<EnvelopeRow> {
  final String id;
  final String userId;
  final String label;
  final EnvelopeShape shape;

  /// How much lands at each refill. 200000 is a PHP 2,000 weekly budget.
  final Money refillCents;
  final Cadence refillCadence;

  /// A weekday name for a weekly refill, or a day of month for a monthly one.
  final String refillAnchor;

  /// Envelopes this one may take from when it runs out. Drives the spill rule.
  final List<String> allowBorrowFrom;

  /// 1 is protected first when money is short.
  final int priority;
  final int sortOrder;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const EnvelopeRow({
    required this.id,
    required this.userId,
    required this.label,
    required this.shape,
    required this.refillCents,
    required this.refillCadence,
    required this.refillAnchor,
    required this.allowBorrowFrom,
    required this.priority,
    required this.sortOrder,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['label'] = Variable<String>(label);
    {
      map['shape'] = Variable<String>(
        $EnvelopesTable.$convertershape.toSql(shape),
      );
    }
    {
      map['refill_cents'] = Variable<int>(
        $EnvelopesTable.$converterrefillCents.toSql(refillCents),
      );
    }
    {
      map['refill_cadence'] = Variable<String>(
        $EnvelopesTable.$converterrefillCadence.toSql(refillCadence),
      );
    }
    map['refill_anchor'] = Variable<String>(refillAnchor);
    {
      map['allow_borrow_from'] = Variable<String>(
        $EnvelopesTable.$converterallowBorrowFrom.toSql(allowBorrowFrom),
      );
    }
    map['priority'] = Variable<int>(priority);
    map['sort_order'] = Variable<int>(sortOrder);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  EnvelopesCompanion toCompanion(bool nullToAbsent) {
    return EnvelopesCompanion(
      id: Value(id),
      userId: Value(userId),
      label: Value(label),
      shape: Value(shape),
      refillCents: Value(refillCents),
      refillCadence: Value(refillCadence),
      refillAnchor: Value(refillAnchor),
      allowBorrowFrom: Value(allowBorrowFrom),
      priority: Value(priority),
      sortOrder: Value(sortOrder),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory EnvelopeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EnvelopeRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      label: serializer.fromJson<String>(json['label']),
      shape: $EnvelopesTable.$convertershape.fromJson(
        serializer.fromJson<String>(json['shape']),
      ),
      refillCents: $EnvelopesTable.$converterrefillCents.fromJson(
        serializer.fromJson<int>(json['refillCents']),
      ),
      refillCadence: $EnvelopesTable.$converterrefillCadence.fromJson(
        serializer.fromJson<String>(json['refillCadence']),
      ),
      refillAnchor: serializer.fromJson<String>(json['refillAnchor']),
      allowBorrowFrom: serializer.fromJson<List<String>>(
        json['allowBorrowFrom'],
      ),
      priority: serializer.fromJson<int>(json['priority']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'label': serializer.toJson<String>(label),
      'shape': serializer.toJson<String>(
        $EnvelopesTable.$convertershape.toJson(shape),
      ),
      'refillCents': serializer.toJson<int>(
        $EnvelopesTable.$converterrefillCents.toJson(refillCents),
      ),
      'refillCadence': serializer.toJson<String>(
        $EnvelopesTable.$converterrefillCadence.toJson(refillCadence),
      ),
      'refillAnchor': serializer.toJson<String>(refillAnchor),
      'allowBorrowFrom': serializer.toJson<List<String>>(allowBorrowFrom),
      'priority': serializer.toJson<int>(priority),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  EnvelopeRow copyWith({
    String? id,
    String? userId,
    String? label,
    EnvelopeShape? shape,
    Money? refillCents,
    Cadence? refillCadence,
    String? refillAnchor,
    List<String>? allowBorrowFrom,
    int? priority,
    int? sortOrder,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => EnvelopeRow(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    label: label ?? this.label,
    shape: shape ?? this.shape,
    refillCents: refillCents ?? this.refillCents,
    refillCadence: refillCadence ?? this.refillCadence,
    refillAnchor: refillAnchor ?? this.refillAnchor,
    allowBorrowFrom: allowBorrowFrom ?? this.allowBorrowFrom,
    priority: priority ?? this.priority,
    sortOrder: sortOrder ?? this.sortOrder,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  EnvelopeRow copyWithCompanion(EnvelopesCompanion data) {
    return EnvelopeRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      label: data.label.present ? data.label.value : this.label,
      shape: data.shape.present ? data.shape.value : this.shape,
      refillCents: data.refillCents.present
          ? data.refillCents.value
          : this.refillCents,
      refillCadence: data.refillCadence.present
          ? data.refillCadence.value
          : this.refillCadence,
      refillAnchor: data.refillAnchor.present
          ? data.refillAnchor.value
          : this.refillAnchor,
      allowBorrowFrom: data.allowBorrowFrom.present
          ? data.allowBorrowFrom.value
          : this.allowBorrowFrom,
      priority: data.priority.present ? data.priority.value : this.priority,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EnvelopeRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('label: $label, ')
          ..write('shape: $shape, ')
          ..write('refillCents: $refillCents, ')
          ..write('refillCadence: $refillCadence, ')
          ..write('refillAnchor: $refillAnchor, ')
          ..write('allowBorrowFrom: $allowBorrowFrom, ')
          ..write('priority: $priority, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    label,
    shape,
    refillCents,
    refillCadence,
    refillAnchor,
    allowBorrowFrom,
    priority,
    sortOrder,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EnvelopeRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.label == this.label &&
          other.shape == this.shape &&
          other.refillCents == this.refillCents &&
          other.refillCadence == this.refillCadence &&
          other.refillAnchor == this.refillAnchor &&
          other.allowBorrowFrom == this.allowBorrowFrom &&
          other.priority == this.priority &&
          other.sortOrder == this.sortOrder &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class EnvelopesCompanion extends UpdateCompanion<EnvelopeRow> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> label;
  final Value<EnvelopeShape> shape;
  final Value<Money> refillCents;
  final Value<Cadence> refillCadence;
  final Value<String> refillAnchor;
  final Value<List<String>> allowBorrowFrom;
  final Value<int> priority;
  final Value<int> sortOrder;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const EnvelopesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.label = const Value.absent(),
    this.shape = const Value.absent(),
    this.refillCents = const Value.absent(),
    this.refillCadence = const Value.absent(),
    this.refillAnchor = const Value.absent(),
    this.allowBorrowFrom = const Value.absent(),
    this.priority = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EnvelopesCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required String label,
    required EnvelopeShape shape,
    required Money refillCents,
    required Cadence refillCadence,
    required String refillAnchor,
    this.allowBorrowFrom = const Value.absent(),
    required int priority,
    required int sortOrder,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       label = Value(label),
       shape = Value(shape),
       refillCents = Value(refillCents),
       refillCadence = Value(refillCadence),
       refillAnchor = Value(refillAnchor),
       priority = Value(priority),
       sortOrder = Value(sortOrder),
       updatedAt = Value(updatedAt);
  static Insertable<EnvelopeRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? label,
    Expression<String>? shape,
    Expression<int>? refillCents,
    Expression<String>? refillCadence,
    Expression<String>? refillAnchor,
    Expression<String>? allowBorrowFrom,
    Expression<int>? priority,
    Expression<int>? sortOrder,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (label != null) 'label': label,
      if (shape != null) 'shape': shape,
      if (refillCents != null) 'refill_cents': refillCents,
      if (refillCadence != null) 'refill_cadence': refillCadence,
      if (refillAnchor != null) 'refill_anchor': refillAnchor,
      if (allowBorrowFrom != null) 'allow_borrow_from': allowBorrowFrom,
      if (priority != null) 'priority': priority,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EnvelopesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? label,
    Value<EnvelopeShape>? shape,
    Value<Money>? refillCents,
    Value<Cadence>? refillCadence,
    Value<String>? refillAnchor,
    Value<List<String>>? allowBorrowFrom,
    Value<int>? priority,
    Value<int>? sortOrder,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return EnvelopesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      label: label ?? this.label,
      shape: shape ?? this.shape,
      refillCents: refillCents ?? this.refillCents,
      refillCadence: refillCadence ?? this.refillCadence,
      refillAnchor: refillAnchor ?? this.refillAnchor,
      allowBorrowFrom: allowBorrowFrom ?? this.allowBorrowFrom,
      priority: priority ?? this.priority,
      sortOrder: sortOrder ?? this.sortOrder,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (shape.present) {
      map['shape'] = Variable<String>(
        $EnvelopesTable.$convertershape.toSql(shape.value),
      );
    }
    if (refillCents.present) {
      map['refill_cents'] = Variable<int>(
        $EnvelopesTable.$converterrefillCents.toSql(refillCents.value),
      );
    }
    if (refillCadence.present) {
      map['refill_cadence'] = Variable<String>(
        $EnvelopesTable.$converterrefillCadence.toSql(refillCadence.value),
      );
    }
    if (refillAnchor.present) {
      map['refill_anchor'] = Variable<String>(refillAnchor.value);
    }
    if (allowBorrowFrom.present) {
      map['allow_borrow_from'] = Variable<String>(
        $EnvelopesTable.$converterallowBorrowFrom.toSql(allowBorrowFrom.value),
      );
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EnvelopesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('label: $label, ')
          ..write('shape: $shape, ')
          ..write('refillCents: $refillCents, ')
          ..write('refillCadence: $refillCadence, ')
          ..write('refillAnchor: $refillAnchor, ')
          ..write('allowBorrowFrom: $allowBorrowFrom, ')
          ..write('priority: $priority, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EnvelopeCategoriesTable extends EnvelopeCategories
    with TableInfo<$EnvelopeCategoriesTable, EnvelopeCategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EnvelopeCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _envelopeIdMeta = const VerificationMeta(
    'envelopeId',
  );
  @override
  late final GeneratedColumn<String> envelopeId = GeneratedColumn<String>(
    'envelope_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES envelopes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _categoryKeyMeta = const VerificationMeta(
    'categoryKey',
  );
  @override
  late final GeneratedColumn<String> categoryKey = GeneratedColumn<String>(
    'category_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories ("key")',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [envelopeId, categoryKey];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'envelope_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<EnvelopeCategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('envelope_id')) {
      context.handle(
        _envelopeIdMeta,
        envelopeId.isAcceptableOrUnknown(data['envelope_id']!, _envelopeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_envelopeIdMeta);
    }
    if (data.containsKey('category_key')) {
      context.handle(
        _categoryKeyMeta,
        categoryKey.isAcceptableOrUnknown(
          data['category_key']!,
          _categoryKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_categoryKeyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {envelopeId, categoryKey};
  @override
  EnvelopeCategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EnvelopeCategoryRow(
      envelopeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}envelope_id'],
      )!,
      categoryKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_key'],
      )!,
    );
  }

  @override
  $EnvelopeCategoriesTable createAlias(String alias) {
    return $EnvelopeCategoriesTable(attachedDatabase, alias);
  }
}

class EnvelopeCategoryRow extends DataClass
    implements Insertable<EnvelopeCategoryRow> {
  final String envelopeId;
  final String categoryKey;
  const EnvelopeCategoryRow({
    required this.envelopeId,
    required this.categoryKey,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['envelope_id'] = Variable<String>(envelopeId);
    map['category_key'] = Variable<String>(categoryKey);
    return map;
  }

  EnvelopeCategoriesCompanion toCompanion(bool nullToAbsent) {
    return EnvelopeCategoriesCompanion(
      envelopeId: Value(envelopeId),
      categoryKey: Value(categoryKey),
    );
  }

  factory EnvelopeCategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EnvelopeCategoryRow(
      envelopeId: serializer.fromJson<String>(json['envelopeId']),
      categoryKey: serializer.fromJson<String>(json['categoryKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'envelopeId': serializer.toJson<String>(envelopeId),
      'categoryKey': serializer.toJson<String>(categoryKey),
    };
  }

  EnvelopeCategoryRow copyWith({String? envelopeId, String? categoryKey}) =>
      EnvelopeCategoryRow(
        envelopeId: envelopeId ?? this.envelopeId,
        categoryKey: categoryKey ?? this.categoryKey,
      );
  EnvelopeCategoryRow copyWithCompanion(EnvelopeCategoriesCompanion data) {
    return EnvelopeCategoryRow(
      envelopeId: data.envelopeId.present
          ? data.envelopeId.value
          : this.envelopeId,
      categoryKey: data.categoryKey.present
          ? data.categoryKey.value
          : this.categoryKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EnvelopeCategoryRow(')
          ..write('envelopeId: $envelopeId, ')
          ..write('categoryKey: $categoryKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(envelopeId, categoryKey);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EnvelopeCategoryRow &&
          other.envelopeId == this.envelopeId &&
          other.categoryKey == this.categoryKey);
}

class EnvelopeCategoriesCompanion extends UpdateCompanion<EnvelopeCategoryRow> {
  final Value<String> envelopeId;
  final Value<String> categoryKey;
  final Value<int> rowid;
  const EnvelopeCategoriesCompanion({
    this.envelopeId = const Value.absent(),
    this.categoryKey = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EnvelopeCategoriesCompanion.insert({
    required String envelopeId,
    required String categoryKey,
    this.rowid = const Value.absent(),
  }) : envelopeId = Value(envelopeId),
       categoryKey = Value(categoryKey);
  static Insertable<EnvelopeCategoryRow> custom({
    Expression<String>? envelopeId,
    Expression<String>? categoryKey,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (envelopeId != null) 'envelope_id': envelopeId,
      if (categoryKey != null) 'category_key': categoryKey,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EnvelopeCategoriesCompanion copyWith({
    Value<String>? envelopeId,
    Value<String>? categoryKey,
    Value<int>? rowid,
  }) {
    return EnvelopeCategoriesCompanion(
      envelopeId: envelopeId ?? this.envelopeId,
      categoryKey: categoryKey ?? this.categoryKey,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (envelopeId.present) {
      map['envelope_id'] = Variable<String>(envelopeId.value);
    }
    if (categoryKey.present) {
      map['category_key'] = Variable<String>(categoryKey.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EnvelopeCategoriesCompanion(')
          ..write('envelopeId: $envelopeId, ')
          ..write('categoryKey: $categoryKey, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AllocationsTable extends Allocations
    with TableInfo<$AllocationsTable, AllocationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AllocationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _envelopeIdMeta = const VerificationMeta(
    'envelopeId',
  );
  @override
  late final GeneratedColumn<String> envelopeId = GeneratedColumn<String>(
    'envelope_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES envelopes (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Money, int> balanceCents =
      GeneratedColumn<int>(
        'balance_cents',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<Money>($AllocationsTable.$converterbalanceCents);
  static const VerificationMeta _periodStartMeta = const VerificationMeta(
    'periodStart',
  );
  @override
  late final GeneratedColumn<DateTime> periodStart = GeneratedColumn<DateTime>(
    'period_start',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
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
    id,
    envelopeId,
    balanceCents,
    periodStart,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'allocations';
  @override
  VerificationContext validateIntegrity(
    Insertable<AllocationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('envelope_id')) {
      context.handle(
        _envelopeIdMeta,
        envelopeId.isAcceptableOrUnknown(data['envelope_id']!, _envelopeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_envelopeIdMeta);
    }
    if (data.containsKey('period_start')) {
      context.handle(
        _periodStartMeta,
        periodStart.isAcceptableOrUnknown(
          data['period_start']!,
          _periodStartMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_periodStartMeta);
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AllocationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AllocationRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      envelopeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}envelope_id'],
      )!,
      balanceCents: $AllocationsTable.$converterbalanceCents.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}balance_cents'],
        )!,
      ),
      periodStart: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}period_start'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AllocationsTable createAlias(String alias) {
    return $AllocationsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Money, int, int> $converterbalanceCents =
      const MoneyConverter();
}

class AllocationRow extends DataClass implements Insertable<AllocationRow> {
  final String id;
  final String envelopeId;
  final Money balanceCents;
  final DateTime periodStart;
  final DateTime updatedAt;
  const AllocationRow({
    required this.id,
    required this.envelopeId,
    required this.balanceCents,
    required this.periodStart,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['envelope_id'] = Variable<String>(envelopeId);
    {
      map['balance_cents'] = Variable<int>(
        $AllocationsTable.$converterbalanceCents.toSql(balanceCents),
      );
    }
    map['period_start'] = Variable<DateTime>(periodStart);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AllocationsCompanion toCompanion(bool nullToAbsent) {
    return AllocationsCompanion(
      id: Value(id),
      envelopeId: Value(envelopeId),
      balanceCents: Value(balanceCents),
      periodStart: Value(periodStart),
      updatedAt: Value(updatedAt),
    );
  }

  factory AllocationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AllocationRow(
      id: serializer.fromJson<String>(json['id']),
      envelopeId: serializer.fromJson<String>(json['envelopeId']),
      balanceCents: $AllocationsTable.$converterbalanceCents.fromJson(
        serializer.fromJson<int>(json['balanceCents']),
      ),
      periodStart: serializer.fromJson<DateTime>(json['periodStart']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'envelopeId': serializer.toJson<String>(envelopeId),
      'balanceCents': serializer.toJson<int>(
        $AllocationsTable.$converterbalanceCents.toJson(balanceCents),
      ),
      'periodStart': serializer.toJson<DateTime>(periodStart),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AllocationRow copyWith({
    String? id,
    String? envelopeId,
    Money? balanceCents,
    DateTime? periodStart,
    DateTime? updatedAt,
  }) => AllocationRow(
    id: id ?? this.id,
    envelopeId: envelopeId ?? this.envelopeId,
    balanceCents: balanceCents ?? this.balanceCents,
    periodStart: periodStart ?? this.periodStart,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AllocationRow copyWithCompanion(AllocationsCompanion data) {
    return AllocationRow(
      id: data.id.present ? data.id.value : this.id,
      envelopeId: data.envelopeId.present
          ? data.envelopeId.value
          : this.envelopeId,
      balanceCents: data.balanceCents.present
          ? data.balanceCents.value
          : this.balanceCents,
      periodStart: data.periodStart.present
          ? data.periodStart.value
          : this.periodStart,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AllocationRow(')
          ..write('id: $id, ')
          ..write('envelopeId: $envelopeId, ')
          ..write('balanceCents: $balanceCents, ')
          ..write('periodStart: $periodStart, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, envelopeId, balanceCents, periodStart, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AllocationRow &&
          other.id == this.id &&
          other.envelopeId == this.envelopeId &&
          other.balanceCents == this.balanceCents &&
          other.periodStart == this.periodStart &&
          other.updatedAt == this.updatedAt);
}

class AllocationsCompanion extends UpdateCompanion<AllocationRow> {
  final Value<String> id;
  final Value<String> envelopeId;
  final Value<Money> balanceCents;
  final Value<DateTime> periodStart;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AllocationsCompanion({
    this.id = const Value.absent(),
    this.envelopeId = const Value.absent(),
    this.balanceCents = const Value.absent(),
    this.periodStart = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AllocationsCompanion.insert({
    required String id,
    required String envelopeId,
    required Money balanceCents,
    required DateTime periodStart,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       envelopeId = Value(envelopeId),
       balanceCents = Value(balanceCents),
       periodStart = Value(periodStart),
       updatedAt = Value(updatedAt);
  static Insertable<AllocationRow> custom({
    Expression<String>? id,
    Expression<String>? envelopeId,
    Expression<int>? balanceCents,
    Expression<DateTime>? periodStart,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (envelopeId != null) 'envelope_id': envelopeId,
      if (balanceCents != null) 'balance_cents': balanceCents,
      if (periodStart != null) 'period_start': periodStart,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AllocationsCompanion copyWith({
    Value<String>? id,
    Value<String>? envelopeId,
    Value<Money>? balanceCents,
    Value<DateTime>? periodStart,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AllocationsCompanion(
      id: id ?? this.id,
      envelopeId: envelopeId ?? this.envelopeId,
      balanceCents: balanceCents ?? this.balanceCents,
      periodStart: periodStart ?? this.periodStart,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (envelopeId.present) {
      map['envelope_id'] = Variable<String>(envelopeId.value);
    }
    if (balanceCents.present) {
      map['balance_cents'] = Variable<int>(
        $AllocationsTable.$converterbalanceCents.toSql(balanceCents.value),
      );
    }
    if (periodStart.present) {
      map['period_start'] = Variable<DateTime>(periodStart.value);
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
    return (StringBuffer('AllocationsCompanion(')
          ..write('id: $id, ')
          ..write('envelopeId: $envelopeId, ')
          ..write('balanceCents: $balanceCents, ')
          ..write('periodStart: $periodStart, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BorrowEventsTable extends BorrowEvents
    with TableInfo<$BorrowEventsTable, BorrowEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BorrowEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fromEnvelopeIdMeta = const VerificationMeta(
    'fromEnvelopeId',
  );
  @override
  late final GeneratedColumn<String> fromEnvelopeId = GeneratedColumn<String>(
    'from_envelope_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES envelopes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _toEnvelopeIdMeta = const VerificationMeta(
    'toEnvelopeId',
  );
  @override
  late final GeneratedColumn<String> toEnvelopeId = GeneratedColumn<String>(
    'to_envelope_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES envelopes (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Money, int> amountCents =
      GeneratedColumn<int>(
        'amount_cents',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<Money>($BorrowEventsTable.$converteramountCents);
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repaidAtMeta = const VerificationMeta(
    'repaidAt',
  );
  @override
  late final GeneratedColumn<DateTime> repaidAt = GeneratedColumn<DateTime>(
    'repaid_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fromEnvelopeId,
    toEnvelopeId,
    amountCents,
    occurredAt,
    repaidAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'borrow_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<BorrowEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('from_envelope_id')) {
      context.handle(
        _fromEnvelopeIdMeta,
        fromEnvelopeId.isAcceptableOrUnknown(
          data['from_envelope_id']!,
          _fromEnvelopeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fromEnvelopeIdMeta);
    }
    if (data.containsKey('to_envelope_id')) {
      context.handle(
        _toEnvelopeIdMeta,
        toEnvelopeId.isAcceptableOrUnknown(
          data['to_envelope_id']!,
          _toEnvelopeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_toEnvelopeIdMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('repaid_at')) {
      context.handle(
        _repaidAtMeta,
        repaidAt.isAcceptableOrUnknown(data['repaid_at']!, _repaidAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BorrowEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BorrowEventRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      fromEnvelopeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_envelope_id'],
      )!,
      toEnvelopeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_envelope_id'],
      )!,
      amountCents: $BorrowEventsTable.$converteramountCents.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}amount_cents'],
        )!,
      ),
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      repaidAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}repaid_at'],
      ),
    );
  }

  @override
  $BorrowEventsTable createAlias(String alias) {
    return $BorrowEventsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Money, int, int> $converteramountCents =
      const MoneyConverter();
}

class BorrowEventRow extends DataClass implements Insertable<BorrowEventRow> {
  final String id;
  final String fromEnvelopeId;
  final String toEnvelopeId;
  final Money amountCents;
  final DateTime occurredAt;
  final DateTime? repaidAt;
  const BorrowEventRow({
    required this.id,
    required this.fromEnvelopeId,
    required this.toEnvelopeId,
    required this.amountCents,
    required this.occurredAt,
    this.repaidAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['from_envelope_id'] = Variable<String>(fromEnvelopeId);
    map['to_envelope_id'] = Variable<String>(toEnvelopeId);
    {
      map['amount_cents'] = Variable<int>(
        $BorrowEventsTable.$converteramountCents.toSql(amountCents),
      );
    }
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    if (!nullToAbsent || repaidAt != null) {
      map['repaid_at'] = Variable<DateTime>(repaidAt);
    }
    return map;
  }

  BorrowEventsCompanion toCompanion(bool nullToAbsent) {
    return BorrowEventsCompanion(
      id: Value(id),
      fromEnvelopeId: Value(fromEnvelopeId),
      toEnvelopeId: Value(toEnvelopeId),
      amountCents: Value(amountCents),
      occurredAt: Value(occurredAt),
      repaidAt: repaidAt == null && nullToAbsent
          ? const Value.absent()
          : Value(repaidAt),
    );
  }

  factory BorrowEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BorrowEventRow(
      id: serializer.fromJson<String>(json['id']),
      fromEnvelopeId: serializer.fromJson<String>(json['fromEnvelopeId']),
      toEnvelopeId: serializer.fromJson<String>(json['toEnvelopeId']),
      amountCents: $BorrowEventsTable.$converteramountCents.fromJson(
        serializer.fromJson<int>(json['amountCents']),
      ),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      repaidAt: serializer.fromJson<DateTime?>(json['repaidAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fromEnvelopeId': serializer.toJson<String>(fromEnvelopeId),
      'toEnvelopeId': serializer.toJson<String>(toEnvelopeId),
      'amountCents': serializer.toJson<int>(
        $BorrowEventsTable.$converteramountCents.toJson(amountCents),
      ),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'repaidAt': serializer.toJson<DateTime?>(repaidAt),
    };
  }

  BorrowEventRow copyWith({
    String? id,
    String? fromEnvelopeId,
    String? toEnvelopeId,
    Money? amountCents,
    DateTime? occurredAt,
    Value<DateTime?> repaidAt = const Value.absent(),
  }) => BorrowEventRow(
    id: id ?? this.id,
    fromEnvelopeId: fromEnvelopeId ?? this.fromEnvelopeId,
    toEnvelopeId: toEnvelopeId ?? this.toEnvelopeId,
    amountCents: amountCents ?? this.amountCents,
    occurredAt: occurredAt ?? this.occurredAt,
    repaidAt: repaidAt.present ? repaidAt.value : this.repaidAt,
  );
  BorrowEventRow copyWithCompanion(BorrowEventsCompanion data) {
    return BorrowEventRow(
      id: data.id.present ? data.id.value : this.id,
      fromEnvelopeId: data.fromEnvelopeId.present
          ? data.fromEnvelopeId.value
          : this.fromEnvelopeId,
      toEnvelopeId: data.toEnvelopeId.present
          ? data.toEnvelopeId.value
          : this.toEnvelopeId,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      repaidAt: data.repaidAt.present ? data.repaidAt.value : this.repaidAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BorrowEventRow(')
          ..write('id: $id, ')
          ..write('fromEnvelopeId: $fromEnvelopeId, ')
          ..write('toEnvelopeId: $toEnvelopeId, ')
          ..write('amountCents: $amountCents, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('repaidAt: $repaidAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    fromEnvelopeId,
    toEnvelopeId,
    amountCents,
    occurredAt,
    repaidAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BorrowEventRow &&
          other.id == this.id &&
          other.fromEnvelopeId == this.fromEnvelopeId &&
          other.toEnvelopeId == this.toEnvelopeId &&
          other.amountCents == this.amountCents &&
          other.occurredAt == this.occurredAt &&
          other.repaidAt == this.repaidAt);
}

class BorrowEventsCompanion extends UpdateCompanion<BorrowEventRow> {
  final Value<String> id;
  final Value<String> fromEnvelopeId;
  final Value<String> toEnvelopeId;
  final Value<Money> amountCents;
  final Value<DateTime> occurredAt;
  final Value<DateTime?> repaidAt;
  final Value<int> rowid;
  const BorrowEventsCompanion({
    this.id = const Value.absent(),
    this.fromEnvelopeId = const Value.absent(),
    this.toEnvelopeId = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.repaidAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BorrowEventsCompanion.insert({
    required String id,
    required String fromEnvelopeId,
    required String toEnvelopeId,
    required Money amountCents,
    required DateTime occurredAt,
    this.repaidAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       fromEnvelopeId = Value(fromEnvelopeId),
       toEnvelopeId = Value(toEnvelopeId),
       amountCents = Value(amountCents),
       occurredAt = Value(occurredAt);
  static Insertable<BorrowEventRow> custom({
    Expression<String>? id,
    Expression<String>? fromEnvelopeId,
    Expression<String>? toEnvelopeId,
    Expression<int>? amountCents,
    Expression<DateTime>? occurredAt,
    Expression<DateTime>? repaidAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fromEnvelopeId != null) 'from_envelope_id': fromEnvelopeId,
      if (toEnvelopeId != null) 'to_envelope_id': toEnvelopeId,
      if (amountCents != null) 'amount_cents': amountCents,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (repaidAt != null) 'repaid_at': repaidAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BorrowEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? fromEnvelopeId,
    Value<String>? toEnvelopeId,
    Value<Money>? amountCents,
    Value<DateTime>? occurredAt,
    Value<DateTime?>? repaidAt,
    Value<int>? rowid,
  }) {
    return BorrowEventsCompanion(
      id: id ?? this.id,
      fromEnvelopeId: fromEnvelopeId ?? this.fromEnvelopeId,
      toEnvelopeId: toEnvelopeId ?? this.toEnvelopeId,
      amountCents: amountCents ?? this.amountCents,
      occurredAt: occurredAt ?? this.occurredAt,
      repaidAt: repaidAt ?? this.repaidAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fromEnvelopeId.present) {
      map['from_envelope_id'] = Variable<String>(fromEnvelopeId.value);
    }
    if (toEnvelopeId.present) {
      map['to_envelope_id'] = Variable<String>(toEnvelopeId.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(
        $BorrowEventsTable.$converteramountCents.toSql(amountCents.value),
      );
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (repaidAt.present) {
      map['repaid_at'] = Variable<DateTime>(repaidAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BorrowEventsCompanion(')
          ..write('id: $id, ')
          ..write('fromEnvelopeId: $fromEnvelopeId, ')
          ..write('toEnvelopeId: $toEnvelopeId, ')
          ..write('amountCents: $amountCents, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('repaidAt: $repaidAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings
    with TableInfo<$SettingsTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingRow> instance, {
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
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
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
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  final String key;
  final String value;
  const SettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory SettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(
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

  SettingRow copyWith({String? key, String? value}) =>
      SettingRow(key: key ?? this.key, value: value ?? this.value);
  SettingRow copyWithCompanion(SettingsCompanion data) {
    return SettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
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
      (other is SettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingRow> custom({
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

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
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
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$BaonDatabase extends GeneratedDatabase {
  _$BaonDatabase(QueryExecutor e) : super(e);
  $BaonDatabaseManager get managers => $BaonDatabaseManager(this);
  late final $ProvidersTable providers = $ProvidersTable(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $BalanceSnapshotsTable balanceSnapshots = $BalanceSnapshotsTable(
    this,
  );
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $TxnsTable txns = $TxnsTable(this);
  late final $ObligationsTable obligations = $ObligationsTable(this);
  late final $IncomeExpectationsTable incomeExpectations =
      $IncomeExpectationsTable(this);
  late final $EnvelopesTable envelopes = $EnvelopesTable(this);
  late final $EnvelopeCategoriesTable envelopeCategories =
      $EnvelopeCategoriesTable(this);
  late final $AllocationsTable allocations = $AllocationsTable(this);
  late final $BorrowEventsTable borrowEvents = $BorrowEventsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    providers,
    accounts,
    balanceSnapshots,
    categories,
    txns,
    obligations,
    incomeExpectations,
    envelopes,
    envelopeCategories,
    allocations,
    borrowEvents,
    settings,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'accounts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('balance_snapshots', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'accounts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('txns', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'envelopes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('envelope_categories', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'envelopes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('allocations', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'envelopes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('borrow_events', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'envelopes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('borrow_events', kind: UpdateKind.delete)],
    ),
  ]);
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$ProvidersTableCreateCompanionBuilder =
    ProvidersCompanion Function({
      required String key,
      required String displayName,
      required ProviderKind kind,
      required String brandColor,
      required String logoAsset,
      Value<String?> notificationPackage,
      Value<int> rowid,
    });
typedef $$ProvidersTableUpdateCompanionBuilder =
    ProvidersCompanion Function({
      Value<String> key,
      Value<String> displayName,
      Value<ProviderKind> kind,
      Value<String> brandColor,
      Value<String> logoAsset,
      Value<String?> notificationPackage,
      Value<int> rowid,
    });

final class $$ProvidersTableReferences
    extends BaseReferences<_$BaonDatabase, $ProvidersTable, ProviderRow> {
  $$ProvidersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AccountsTable, List<AccountRow>>
  _accountsRefsTable(_$BaonDatabase db) => MultiTypedResultKey.fromTable(
    db.accounts,
    aliasName: 'providers__key__accounts__provider_key',
  );

  $$AccountsTableProcessedTableManager get accountsRefs {
    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.providerKey.key.sqlEquals($_itemColumn<String>('key')!));

    final cache = $_typedResult.readTableOrNull(_accountsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProvidersTableFilterComposer
    extends Composer<_$BaonDatabase, $ProvidersTable> {
  $$ProvidersTableFilterComposer({
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

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ProviderKind, ProviderKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get brandColor => $composableBuilder(
    column: $table.brandColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get logoAsset => $composableBuilder(
    column: $table.logoAsset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notificationPackage => $composableBuilder(
    column: $table.notificationPackage,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> accountsRefs(
    Expression<bool> Function($$AccountsTableFilterComposer f) f,
  ) {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.key,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.providerKey,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProvidersTableOrderingComposer
    extends Composer<_$BaonDatabase, $ProvidersTable> {
  $$ProvidersTableOrderingComposer({
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

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brandColor => $composableBuilder(
    column: $table.brandColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get logoAsset => $composableBuilder(
    column: $table.logoAsset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notificationPackage => $composableBuilder(
    column: $table.notificationPackage,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProvidersTableAnnotationComposer
    extends Composer<_$BaonDatabase, $ProvidersTable> {
  $$ProvidersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ProviderKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get brandColor => $composableBuilder(
    column: $table.brandColor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get logoAsset =>
      $composableBuilder(column: $table.logoAsset, builder: (column) => column);

  GeneratedColumn<String> get notificationPackage => $composableBuilder(
    column: $table.notificationPackage,
    builder: (column) => column,
  );

  Expression<T> accountsRefs<T extends Object>(
    Expression<T> Function($$AccountsTableAnnotationComposer a) f,
  ) {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.key,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.providerKey,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProvidersTableTableManager
    extends
        RootTableManager<
          _$BaonDatabase,
          $ProvidersTable,
          ProviderRow,
          $$ProvidersTableFilterComposer,
          $$ProvidersTableOrderingComposer,
          $$ProvidersTableAnnotationComposer,
          $$ProvidersTableCreateCompanionBuilder,
          $$ProvidersTableUpdateCompanionBuilder,
          (ProviderRow, $$ProvidersTableReferences),
          ProviderRow,
          PrefetchHooks Function({bool accountsRefs})
        > {
  $$ProvidersTableTableManager(_$BaonDatabase db, $ProvidersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProvidersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProvidersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProvidersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<ProviderKind> kind = const Value.absent(),
                Value<String> brandColor = const Value.absent(),
                Value<String> logoAsset = const Value.absent(),
                Value<String?> notificationPackage = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProvidersCompanion(
                key: key,
                displayName: displayName,
                kind: kind,
                brandColor: brandColor,
                logoAsset: logoAsset,
                notificationPackage: notificationPackage,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String displayName,
                required ProviderKind kind,
                required String brandColor,
                required String logoAsset,
                Value<String?> notificationPackage = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProvidersCompanion.insert(
                key: key,
                displayName: displayName,
                kind: kind,
                brandColor: brandColor,
                logoAsset: logoAsset,
                notificationPackage: notificationPackage,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProvidersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({accountsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (accountsRefs) db.accounts],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (accountsRefs)
                    await $_getPrefetchedData<
                      ProviderRow,
                      $ProvidersTable,
                      AccountRow
                    >(
                      currentTable: table,
                      referencedTable: $$ProvidersTableReferences
                          ._accountsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ProvidersTableReferences(
                            db,
                            table,
                            p0,
                          ).accountsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.providerKey == item.key,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ProvidersTableProcessedTableManager =
    ProcessedTableManager<
      _$BaonDatabase,
      $ProvidersTable,
      ProviderRow,
      $$ProvidersTableFilterComposer,
      $$ProvidersTableOrderingComposer,
      $$ProvidersTableAnnotationComposer,
      $$ProvidersTableCreateCompanionBuilder,
      $$ProvidersTableUpdateCompanionBuilder,
      (ProviderRow, $$ProvidersTableReferences),
      ProviderRow,
      PrefetchHooks Function({bool accountsRefs})
    >;
typedef $$AccountsTableCreateCompanionBuilder =
    AccountsCompanion Function({
      required String id,
      Value<String> userId,
      required String providerKey,
      required String label,
      required AccountRole role,
      Value<bool> includeInSpendable,
      Value<bool> isArchived,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$AccountsTableUpdateCompanionBuilder =
    AccountsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> providerKey,
      Value<String> label,
      Value<AccountRole> role,
      Value<bool> includeInSpendable,
      Value<bool> isArchived,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$AccountsTableReferences
    extends BaseReferences<_$BaonDatabase, $AccountsTable, AccountRow> {
  $$AccountsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProvidersTable _providerKeyTable(_$BaonDatabase db) =>
      db.providers.createAlias('accounts__provider_key__providers__key');

  $$ProvidersTableProcessedTableManager get providerKey {
    final $_column = $_itemColumn<String>('provider_key')!;

    final manager = $$ProvidersTableTableManager(
      $_db,
      $_db.providers,
    ).filter((f) => f.key.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_providerKeyTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$BalanceSnapshotsTable, List<BalanceSnapshotRow>>
  _balanceSnapshotsRefsTable(_$BaonDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.balanceSnapshots,
        aliasName: 'accounts__id__balance_snapshots__account_id',
      );

  $$BalanceSnapshotsTableProcessedTableManager get balanceSnapshotsRefs {
    final manager = $$BalanceSnapshotsTableTableManager(
      $_db,
      $_db.balanceSnapshots,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _balanceSnapshotsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TxnsTable, List<TxnRow>> _txnsRefsTable(
    _$BaonDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.txns,
    aliasName: 'accounts__id__txns__account_id',
  );

  $$TxnsTableProcessedTableManager get txnsRefs {
    final manager = $$TxnsTableTableManager(
      $_db,
      $_db.txns,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_txnsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AccountsTableFilterComposer
    extends Composer<_$BaonDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AccountRole, AccountRole, String> get role =>
      $composableBuilder(
        column: $table.role,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get includeInSpendable => $composableBuilder(
    column: $table.includeInSpendable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProvidersTableFilterComposer get providerKey {
    final $$ProvidersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.providerKey,
      referencedTable: $db.providers,
      getReferencedColumn: (t) => t.key,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProvidersTableFilterComposer(
            $db: $db,
            $table: $db.providers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> balanceSnapshotsRefs(
    Expression<bool> Function($$BalanceSnapshotsTableFilterComposer f) f,
  ) {
    final $$BalanceSnapshotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.balanceSnapshots,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BalanceSnapshotsTableFilterComposer(
            $db: $db,
            $table: $db.balanceSnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> txnsRefs(
    Expression<bool> Function($$TxnsTableFilterComposer f) f,
  ) {
    final $$TxnsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.txns,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TxnsTableFilterComposer(
            $db: $db,
            $table: $db.txns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AccountsTableOrderingComposer
    extends Composer<_$BaonDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get includeInSpendable => $composableBuilder(
    column: $table.includeInSpendable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProvidersTableOrderingComposer get providerKey {
    final $$ProvidersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.providerKey,
      referencedTable: $db.providers,
      getReferencedColumn: (t) => t.key,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProvidersTableOrderingComposer(
            $db: $db,
            $table: $db.providers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$BaonDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AccountRole, String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<bool> get includeInSpendable => $composableBuilder(
    column: $table.includeInSpendable,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$ProvidersTableAnnotationComposer get providerKey {
    final $$ProvidersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.providerKey,
      referencedTable: $db.providers,
      getReferencedColumn: (t) => t.key,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProvidersTableAnnotationComposer(
            $db: $db,
            $table: $db.providers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> balanceSnapshotsRefs<T extends Object>(
    Expression<T> Function($$BalanceSnapshotsTableAnnotationComposer a) f,
  ) {
    final $$BalanceSnapshotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.balanceSnapshots,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BalanceSnapshotsTableAnnotationComposer(
            $db: $db,
            $table: $db.balanceSnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> txnsRefs<T extends Object>(
    Expression<T> Function($$TxnsTableAnnotationComposer a) f,
  ) {
    final $$TxnsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.txns,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TxnsTableAnnotationComposer(
            $db: $db,
            $table: $db.txns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AccountsTableTableManager
    extends
        RootTableManager<
          _$BaonDatabase,
          $AccountsTable,
          AccountRow,
          $$AccountsTableFilterComposer,
          $$AccountsTableOrderingComposer,
          $$AccountsTableAnnotationComposer,
          $$AccountsTableCreateCompanionBuilder,
          $$AccountsTableUpdateCompanionBuilder,
          (AccountRow, $$AccountsTableReferences),
          AccountRow,
          PrefetchHooks Function({
            bool providerKey,
            bool balanceSnapshotsRefs,
            bool txnsRefs,
          })
        > {
  $$AccountsTableTableManager(_$BaonDatabase db, $AccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> providerKey = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<AccountRole> role = const Value.absent(),
                Value<bool> includeInSpendable = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion(
                id: id,
                userId: userId,
                providerKey: providerKey,
                label: label,
                role: role,
                includeInSpendable: includeInSpendable,
                isArchived: isArchived,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> userId = const Value.absent(),
                required String providerKey,
                required String label,
                required AccountRole role,
                Value<bool> includeInSpendable = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion.insert(
                id: id,
                userId: userId,
                providerKey: providerKey,
                label: label,
                role: role,
                includeInSpendable: includeInSpendable,
                isArchived: isArchived,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AccountsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                providerKey = false,
                balanceSnapshotsRefs = false,
                txnsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (balanceSnapshotsRefs) db.balanceSnapshots,
                    if (txnsRefs) db.txns,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (providerKey) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.providerKey,
                                    referencedTable: $$AccountsTableReferences
                                        ._providerKeyTable(db),
                                    referencedColumn: $$AccountsTableReferences
                                        ._providerKeyTable(db)
                                        .key,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (balanceSnapshotsRefs)
                        await $_getPrefetchedData<
                          AccountRow,
                          $AccountsTable,
                          BalanceSnapshotRow
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._balanceSnapshotsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).balanceSnapshotsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (txnsRefs)
                        await $_getPrefetchedData<
                          AccountRow,
                          $AccountsTable,
                          TxnRow
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._txnsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(db, table, p0).txnsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$AccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$BaonDatabase,
      $AccountsTable,
      AccountRow,
      $$AccountsTableFilterComposer,
      $$AccountsTableOrderingComposer,
      $$AccountsTableAnnotationComposer,
      $$AccountsTableCreateCompanionBuilder,
      $$AccountsTableUpdateCompanionBuilder,
      (AccountRow, $$AccountsTableReferences),
      AccountRow,
      PrefetchHooks Function({
        bool providerKey,
        bool balanceSnapshotsRefs,
        bool txnsRefs,
      })
    >;
typedef $$BalanceSnapshotsTableCreateCompanionBuilder =
    BalanceSnapshotsCompanion Function({
      required String id,
      required String accountId,
      required Money balanceCents,
      required SnapshotSource source,
      required DateTime capturedAt,
      Value<String?> note,
      Value<int> rowid,
    });
typedef $$BalanceSnapshotsTableUpdateCompanionBuilder =
    BalanceSnapshotsCompanion Function({
      Value<String> id,
      Value<String> accountId,
      Value<Money> balanceCents,
      Value<SnapshotSource> source,
      Value<DateTime> capturedAt,
      Value<String?> note,
      Value<int> rowid,
    });

final class $$BalanceSnapshotsTableReferences
    extends
        BaseReferences<
          _$BaonDatabase,
          $BalanceSnapshotsTable,
          BalanceSnapshotRow
        > {
  $$BalanceSnapshotsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AccountsTable _accountIdTable(_$BaonDatabase db) =>
      db.accounts.createAlias('balance_snapshots__account_id__accounts__id');

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BalanceSnapshotsTableFilterComposer
    extends Composer<_$BaonDatabase, $BalanceSnapshotsTable> {
  $$BalanceSnapshotsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<Money, Money, int> get balanceCents =>
      $composableBuilder(
        column: $table.balanceCents,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<SnapshotSource, SnapshotSource, String>
  get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BalanceSnapshotsTableOrderingComposer
    extends Composer<_$BaonDatabase, $BalanceSnapshotsTable> {
  $$BalanceSnapshotsTableOrderingComposer({
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

  ColumnOrderings<int> get balanceCents => $composableBuilder(
    column: $table.balanceCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BalanceSnapshotsTableAnnotationComposer
    extends Composer<_$BaonDatabase, $BalanceSnapshotsTable> {
  $$BalanceSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Money, int> get balanceCents =>
      $composableBuilder(
        column: $table.balanceCents,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<SnapshotSource, String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BalanceSnapshotsTableTableManager
    extends
        RootTableManager<
          _$BaonDatabase,
          $BalanceSnapshotsTable,
          BalanceSnapshotRow,
          $$BalanceSnapshotsTableFilterComposer,
          $$BalanceSnapshotsTableOrderingComposer,
          $$BalanceSnapshotsTableAnnotationComposer,
          $$BalanceSnapshotsTableCreateCompanionBuilder,
          $$BalanceSnapshotsTableUpdateCompanionBuilder,
          (BalanceSnapshotRow, $$BalanceSnapshotsTableReferences),
          BalanceSnapshotRow,
          PrefetchHooks Function({bool accountId})
        > {
  $$BalanceSnapshotsTableTableManager(
    _$BaonDatabase db,
    $BalanceSnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BalanceSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BalanceSnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BalanceSnapshotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<Money> balanceCents = const Value.absent(),
                Value<SnapshotSource> source = const Value.absent(),
                Value<DateTime> capturedAt = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BalanceSnapshotsCompanion(
                id: id,
                accountId: accountId,
                balanceCents: balanceCents,
                source: source,
                capturedAt: capturedAt,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String accountId,
                required Money balanceCents,
                required SnapshotSource source,
                required DateTime capturedAt,
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BalanceSnapshotsCompanion.insert(
                id: id,
                accountId: accountId,
                balanceCents: balanceCents,
                source: source,
                capturedAt: capturedAt,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BalanceSnapshotsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({accountId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (accountId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.accountId,
                                referencedTable:
                                    $$BalanceSnapshotsTableReferences
                                        ._accountIdTable(db),
                                referencedColumn:
                                    $$BalanceSnapshotsTableReferences
                                        ._accountIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BalanceSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$BaonDatabase,
      $BalanceSnapshotsTable,
      BalanceSnapshotRow,
      $$BalanceSnapshotsTableFilterComposer,
      $$BalanceSnapshotsTableOrderingComposer,
      $$BalanceSnapshotsTableAnnotationComposer,
      $$BalanceSnapshotsTableCreateCompanionBuilder,
      $$BalanceSnapshotsTableUpdateCompanionBuilder,
      (BalanceSnapshotRow, $$BalanceSnapshotsTableReferences),
      BalanceSnapshotRow,
      PrefetchHooks Function({bool accountId})
    >;
typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      required String key,
      required String displayName,
      required bool isEssential,
      required String icon,
      required int sortOrder,
      Value<int> rowid,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<String> key,
      Value<String> displayName,
      Value<bool> isEssential,
      Value<String> icon,
      Value<int> sortOrder,
      Value<int> rowid,
    });

final class $$CategoriesTableReferences
    extends BaseReferences<_$BaonDatabase, $CategoriesTable, CategoryRow> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TxnsTable, List<TxnRow>> _txnsRefsTable(
    _$BaonDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.txns,
    aliasName: 'categories__key__txns__category_key',
  );

  $$TxnsTableProcessedTableManager get txnsRefs {
    final manager = $$TxnsTableTableManager(
      $_db,
      $_db.txns,
    ).filter((f) => f.categoryKey.key.sqlEquals($_itemColumn<String>('key')!));

    final cache = $_typedResult.readTableOrNull(_txnsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ObligationsTable, List<ObligationRow>>
  _obligationsRefsTable(_$BaonDatabase db) => MultiTypedResultKey.fromTable(
    db.obligations,
    aliasName: 'categories__key__obligations__category_key',
  );

  $$ObligationsTableProcessedTableManager get obligationsRefs {
    final manager = $$ObligationsTableTableManager(
      $_db,
      $_db.obligations,
    ).filter((f) => f.categoryKey.key.sqlEquals($_itemColumn<String>('key')!));

    final cache = $_typedResult.readTableOrNull(_obligationsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $EnvelopeCategoriesTable,
    List<EnvelopeCategoryRow>
  >
  _envelopeCategoriesRefsTable(_$BaonDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.envelopeCategories,
        aliasName: 'categories__key__envelope_categories__category_key',
      );

  $$EnvelopeCategoriesTableProcessedTableManager get envelopeCategoriesRefs {
    final manager = $$EnvelopeCategoriesTableTableManager(
      $_db,
      $_db.envelopeCategories,
    ).filter((f) => f.categoryKey.key.sqlEquals($_itemColumn<String>('key')!));

    final cache = $_typedResult.readTableOrNull(
      _envelopeCategoriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$BaonDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
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

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEssential => $composableBuilder(
    column: $table.isEssential,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> txnsRefs(
    Expression<bool> Function($$TxnsTableFilterComposer f) f,
  ) {
    final $$TxnsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.key,
      referencedTable: $db.txns,
      getReferencedColumn: (t) => t.categoryKey,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TxnsTableFilterComposer(
            $db: $db,
            $table: $db.txns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> obligationsRefs(
    Expression<bool> Function($$ObligationsTableFilterComposer f) f,
  ) {
    final $$ObligationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.key,
      referencedTable: $db.obligations,
      getReferencedColumn: (t) => t.categoryKey,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObligationsTableFilterComposer(
            $db: $db,
            $table: $db.obligations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> envelopeCategoriesRefs(
    Expression<bool> Function($$EnvelopeCategoriesTableFilterComposer f) f,
  ) {
    final $$EnvelopeCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.key,
      referencedTable: $db.envelopeCategories,
      getReferencedColumn: (t) => t.categoryKey,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnvelopeCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.envelopeCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$BaonDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
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

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEssential => $composableBuilder(
    column: $table.isEssential,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$BaonDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isEssential => $composableBuilder(
    column: $table.isEssential,
    builder: (column) => column,
  );

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> txnsRefs<T extends Object>(
    Expression<T> Function($$TxnsTableAnnotationComposer a) f,
  ) {
    final $$TxnsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.key,
      referencedTable: $db.txns,
      getReferencedColumn: (t) => t.categoryKey,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TxnsTableAnnotationComposer(
            $db: $db,
            $table: $db.txns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> obligationsRefs<T extends Object>(
    Expression<T> Function($$ObligationsTableAnnotationComposer a) f,
  ) {
    final $$ObligationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.key,
      referencedTable: $db.obligations,
      getReferencedColumn: (t) => t.categoryKey,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObligationsTableAnnotationComposer(
            $db: $db,
            $table: $db.obligations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> envelopeCategoriesRefs<T extends Object>(
    Expression<T> Function($$EnvelopeCategoriesTableAnnotationComposer a) f,
  ) {
    final $$EnvelopeCategoriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.key,
          referencedTable: $db.envelopeCategories,
          getReferencedColumn: (t) => t.categoryKey,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EnvelopeCategoriesTableAnnotationComposer(
                $db: $db,
                $table: $db.envelopeCategories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$BaonDatabase,
          $CategoriesTable,
          CategoryRow,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (CategoryRow, $$CategoriesTableReferences),
          CategoryRow,
          PrefetchHooks Function({
            bool txnsRefs,
            bool obligationsRefs,
            bool envelopeCategoriesRefs,
          })
        > {
  $$CategoriesTableTableManager(_$BaonDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<bool> isEssential = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                key: key,
                displayName: displayName,
                isEssential: isEssential,
                icon: icon,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String displayName,
                required bool isEssential,
                required String icon,
                required int sortOrder,
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                key: key,
                displayName: displayName,
                isEssential: isEssential,
                icon: icon,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                txnsRefs = false,
                obligationsRefs = false,
                envelopeCategoriesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (txnsRefs) db.txns,
                    if (obligationsRefs) db.obligations,
                    if (envelopeCategoriesRefs) db.envelopeCategories,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (txnsRefs)
                        await $_getPrefetchedData<
                          CategoryRow,
                          $CategoriesTable,
                          TxnRow
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._txnsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).txnsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryKey == item.key,
                              ),
                          typedResults: items,
                        ),
                      if (obligationsRefs)
                        await $_getPrefetchedData<
                          CategoryRow,
                          $CategoriesTable,
                          ObligationRow
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._obligationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).obligationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryKey == item.key,
                              ),
                          typedResults: items,
                        ),
                      if (envelopeCategoriesRefs)
                        await $_getPrefetchedData<
                          CategoryRow,
                          $CategoriesTable,
                          EnvelopeCategoryRow
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._envelopeCategoriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).envelopeCategoriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryKey == item.key,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$BaonDatabase,
      $CategoriesTable,
      CategoryRow,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (CategoryRow, $$CategoriesTableReferences),
      CategoryRow,
      PrefetchHooks Function({
        bool txnsRefs,
        bool obligationsRefs,
        bool envelopeCategoriesRefs,
      })
    >;
typedef $$TxnsTableCreateCompanionBuilder =
    TxnsCompanion Function({
      required String id,
      required String accountId,
      required Money amountCents,
      required TxnDirection direction,
      required String categoryKey,
      Value<String?> merchantRaw,
      Value<String?> note,
      required DateTime occurredAt,
      required TxnSource source,
      Value<double> categoryConfidence,
      Value<bool> userCorrected,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$TxnsTableUpdateCompanionBuilder =
    TxnsCompanion Function({
      Value<String> id,
      Value<String> accountId,
      Value<Money> amountCents,
      Value<TxnDirection> direction,
      Value<String> categoryKey,
      Value<String?> merchantRaw,
      Value<String?> note,
      Value<DateTime> occurredAt,
      Value<TxnSource> source,
      Value<double> categoryConfidence,
      Value<bool> userCorrected,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$TxnsTableReferences
    extends BaseReferences<_$BaonDatabase, $TxnsTable, TxnRow> {
  $$TxnsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AccountsTable _accountIdTable(_$BaonDatabase db) =>
      db.accounts.createAlias('txns__account_id__accounts__id');

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CategoriesTable _categoryKeyTable(_$BaonDatabase db) =>
      db.categories.createAlias('txns__category_key__categories__key');

  $$CategoriesTableProcessedTableManager get categoryKey {
    final $_column = $_itemColumn<String>('category_key')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.key.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryKeyTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TxnsTableFilterComposer extends Composer<_$BaonDatabase, $TxnsTable> {
  $$TxnsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<Money, Money, int> get amountCents =>
      $composableBuilder(
        column: $table.amountCents,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<TxnDirection, TxnDirection, String>
  get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get merchantRaw => $composableBuilder(
    column: $table.merchantRaw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TxnSource, TxnSource, String> get source =>
      $composableBuilder(
        column: $table.source,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get categoryConfidence => $composableBuilder(
    column: $table.categoryConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get userCorrected => $composableBuilder(
    column: $table.userCorrected,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableFilterComposer get categoryKey {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryKey,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.key,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TxnsTableOrderingComposer extends Composer<_$BaonDatabase, $TxnsTable> {
  $$TxnsTableOrderingComposer({
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

  ColumnOrderings<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get merchantRaw => $composableBuilder(
    column: $table.merchantRaw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get categoryConfidence => $composableBuilder(
    column: $table.categoryConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get userCorrected => $composableBuilder(
    column: $table.userCorrected,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableOrderingComposer get categoryKey {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryKey,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.key,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TxnsTableAnnotationComposer
    extends Composer<_$BaonDatabase, $TxnsTable> {
  $$TxnsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Money, int> get amountCents =>
      $composableBuilder(
        column: $table.amountCents,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<TxnDirection, String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<String> get merchantRaw => $composableBuilder(
    column: $table.merchantRaw,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<TxnSource, String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<double> get categoryConfidence => $composableBuilder(
    column: $table.categoryConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get userCorrected => $composableBuilder(
    column: $table.userCorrected,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableAnnotationComposer get categoryKey {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryKey,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.key,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TxnsTableTableManager
    extends
        RootTableManager<
          _$BaonDatabase,
          $TxnsTable,
          TxnRow,
          $$TxnsTableFilterComposer,
          $$TxnsTableOrderingComposer,
          $$TxnsTableAnnotationComposer,
          $$TxnsTableCreateCompanionBuilder,
          $$TxnsTableUpdateCompanionBuilder,
          (TxnRow, $$TxnsTableReferences),
          TxnRow,
          PrefetchHooks Function({bool accountId, bool categoryKey})
        > {
  $$TxnsTableTableManager(_$BaonDatabase db, $TxnsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TxnsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TxnsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TxnsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<Money> amountCents = const Value.absent(),
                Value<TxnDirection> direction = const Value.absent(),
                Value<String> categoryKey = const Value.absent(),
                Value<String?> merchantRaw = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<TxnSource> source = const Value.absent(),
                Value<double> categoryConfidence = const Value.absent(),
                Value<bool> userCorrected = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TxnsCompanion(
                id: id,
                accountId: accountId,
                amountCents: amountCents,
                direction: direction,
                categoryKey: categoryKey,
                merchantRaw: merchantRaw,
                note: note,
                occurredAt: occurredAt,
                source: source,
                categoryConfidence: categoryConfidence,
                userCorrected: userCorrected,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String accountId,
                required Money amountCents,
                required TxnDirection direction,
                required String categoryKey,
                Value<String?> merchantRaw = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required DateTime occurredAt,
                required TxnSource source,
                Value<double> categoryConfidence = const Value.absent(),
                Value<bool> userCorrected = const Value.absent(),
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TxnsCompanion.insert(
                id: id,
                accountId: accountId,
                amountCents: amountCents,
                direction: direction,
                categoryKey: categoryKey,
                merchantRaw: merchantRaw,
                note: note,
                occurredAt: occurredAt,
                source: source,
                categoryConfidence: categoryConfidence,
                userCorrected: userCorrected,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TxnsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({accountId = false, categoryKey = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (accountId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.accountId,
                                referencedTable: $$TxnsTableReferences
                                    ._accountIdTable(db),
                                referencedColumn: $$TxnsTableReferences
                                    ._accountIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (categoryKey) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.categoryKey,
                                referencedTable: $$TxnsTableReferences
                                    ._categoryKeyTable(db),
                                referencedColumn: $$TxnsTableReferences
                                    ._categoryKeyTable(db)
                                    .key,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TxnsTableProcessedTableManager =
    ProcessedTableManager<
      _$BaonDatabase,
      $TxnsTable,
      TxnRow,
      $$TxnsTableFilterComposer,
      $$TxnsTableOrderingComposer,
      $$TxnsTableAnnotationComposer,
      $$TxnsTableCreateCompanionBuilder,
      $$TxnsTableUpdateCompanionBuilder,
      (TxnRow, $$TxnsTableReferences),
      TxnRow,
      PrefetchHooks Function({bool accountId, bool categoryKey})
    >;
typedef $$ObligationsTableCreateCompanionBuilder =
    ObligationsCompanion Function({
      required String id,
      Value<String> userId,
      required String label,
      required Money amountCents,
      required Cadence cadence,
      required DateTime nextDueOn,
      required String categoryKey,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$ObligationsTableUpdateCompanionBuilder =
    ObligationsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> label,
      Value<Money> amountCents,
      Value<Cadence> cadence,
      Value<DateTime> nextDueOn,
      Value<String> categoryKey,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$ObligationsTableReferences
    extends BaseReferences<_$BaonDatabase, $ObligationsTable, ObligationRow> {
  $$ObligationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryKeyTable(_$BaonDatabase db) =>
      db.categories.createAlias('obligations__category_key__categories__key');

  $$CategoriesTableProcessedTableManager get categoryKey {
    final $_column = $_itemColumn<String>('category_key')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.key.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryKeyTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ObligationsTableFilterComposer
    extends Composer<_$BaonDatabase, $ObligationsTable> {
  $$ObligationsTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Money, Money, int> get amountCents =>
      $composableBuilder(
        column: $table.amountCents,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Cadence, Cadence, String> get cadence =>
      $composableBuilder(
        column: $table.cadence,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get nextDueOn => $composableBuilder(
    column: $table.nextDueOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryKey {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryKey,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.key,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ObligationsTableOrderingComposer
    extends Composer<_$BaonDatabase, $ObligationsTable> {
  $$ObligationsTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cadence => $composableBuilder(
    column: $table.cadence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextDueOn => $composableBuilder(
    column: $table.nextDueOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryKey {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryKey,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.key,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ObligationsTableAnnotationComposer
    extends Composer<_$BaonDatabase, $ObligationsTable> {
  $$ObligationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Money, int> get amountCents =>
      $composableBuilder(
        column: $table.amountCents,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Cadence, String> get cadence =>
      $composableBuilder(column: $table.cadence, builder: (column) => column);

  GeneratedColumn<DateTime> get nextDueOn =>
      $composableBuilder(column: $table.nextDueOn, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryKey {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryKey,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.key,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ObligationsTableTableManager
    extends
        RootTableManager<
          _$BaonDatabase,
          $ObligationsTable,
          ObligationRow,
          $$ObligationsTableFilterComposer,
          $$ObligationsTableOrderingComposer,
          $$ObligationsTableAnnotationComposer,
          $$ObligationsTableCreateCompanionBuilder,
          $$ObligationsTableUpdateCompanionBuilder,
          (ObligationRow, $$ObligationsTableReferences),
          ObligationRow,
          PrefetchHooks Function({bool categoryKey})
        > {
  $$ObligationsTableTableManager(_$BaonDatabase db, $ObligationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ObligationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ObligationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ObligationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<Money> amountCents = const Value.absent(),
                Value<Cadence> cadence = const Value.absent(),
                Value<DateTime> nextDueOn = const Value.absent(),
                Value<String> categoryKey = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ObligationsCompanion(
                id: id,
                userId: userId,
                label: label,
                amountCents: amountCents,
                cadence: cadence,
                nextDueOn: nextDueOn,
                categoryKey: categoryKey,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> userId = const Value.absent(),
                required String label,
                required Money amountCents,
                required Cadence cadence,
                required DateTime nextDueOn,
                required String categoryKey,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ObligationsCompanion.insert(
                id: id,
                userId: userId,
                label: label,
                amountCents: amountCents,
                cadence: cadence,
                nextDueOn: nextDueOn,
                categoryKey: categoryKey,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ObligationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({categoryKey = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (categoryKey) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.categoryKey,
                                referencedTable: $$ObligationsTableReferences
                                    ._categoryKeyTable(db),
                                referencedColumn: $$ObligationsTableReferences
                                    ._categoryKeyTable(db)
                                    .key,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ObligationsTableProcessedTableManager =
    ProcessedTableManager<
      _$BaonDatabase,
      $ObligationsTable,
      ObligationRow,
      $$ObligationsTableFilterComposer,
      $$ObligationsTableOrderingComposer,
      $$ObligationsTableAnnotationComposer,
      $$ObligationsTableCreateCompanionBuilder,
      $$ObligationsTableUpdateCompanionBuilder,
      (ObligationRow, $$ObligationsTableReferences),
      ObligationRow,
      PrefetchHooks Function({bool categoryKey})
    >;
typedef $$IncomeExpectationsTableCreateCompanionBuilder =
    IncomeExpectationsCompanion Function({
      required String id,
      Value<String> userId,
      required String label,
      required Money amountCents,
      required Cadence cadence,
      required DateTime nextExpectedOn,
      required IncomeConfidence confidence,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$IncomeExpectationsTableUpdateCompanionBuilder =
    IncomeExpectationsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> label,
      Value<Money> amountCents,
      Value<Cadence> cadence,
      Value<DateTime> nextExpectedOn,
      Value<IncomeConfidence> confidence,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$IncomeExpectationsTableFilterComposer
    extends Composer<_$BaonDatabase, $IncomeExpectationsTable> {
  $$IncomeExpectationsTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Money, Money, int> get amountCents =>
      $composableBuilder(
        column: $table.amountCents,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Cadence, Cadence, String> get cadence =>
      $composableBuilder(
        column: $table.cadence,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get nextExpectedOn => $composableBuilder(
    column: $table.nextExpectedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<IncomeConfidence, IncomeConfidence, String>
  get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IncomeExpectationsTableOrderingComposer
    extends Composer<_$BaonDatabase, $IncomeExpectationsTable> {
  $$IncomeExpectationsTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cadence => $composableBuilder(
    column: $table.cadence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextExpectedOn => $composableBuilder(
    column: $table.nextExpectedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IncomeExpectationsTableAnnotationComposer
    extends Composer<_$BaonDatabase, $IncomeExpectationsTable> {
  $$IncomeExpectationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Money, int> get amountCents =>
      $composableBuilder(
        column: $table.amountCents,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Cadence, String> get cadence =>
      $composableBuilder(column: $table.cadence, builder: (column) => column);

  GeneratedColumn<DateTime> get nextExpectedOn => $composableBuilder(
    column: $table.nextExpectedOn,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<IncomeConfidence, String> get confidence =>
      $composableBuilder(
        column: $table.confidence,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$IncomeExpectationsTableTableManager
    extends
        RootTableManager<
          _$BaonDatabase,
          $IncomeExpectationsTable,
          IncomeExpectationRow,
          $$IncomeExpectationsTableFilterComposer,
          $$IncomeExpectationsTableOrderingComposer,
          $$IncomeExpectationsTableAnnotationComposer,
          $$IncomeExpectationsTableCreateCompanionBuilder,
          $$IncomeExpectationsTableUpdateCompanionBuilder,
          (
            IncomeExpectationRow,
            BaseReferences<
              _$BaonDatabase,
              $IncomeExpectationsTable,
              IncomeExpectationRow
            >,
          ),
          IncomeExpectationRow,
          PrefetchHooks Function()
        > {
  $$IncomeExpectationsTableTableManager(
    _$BaonDatabase db,
    $IncomeExpectationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IncomeExpectationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IncomeExpectationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IncomeExpectationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<Money> amountCents = const Value.absent(),
                Value<Cadence> cadence = const Value.absent(),
                Value<DateTime> nextExpectedOn = const Value.absent(),
                Value<IncomeConfidence> confidence = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IncomeExpectationsCompanion(
                id: id,
                userId: userId,
                label: label,
                amountCents: amountCents,
                cadence: cadence,
                nextExpectedOn: nextExpectedOn,
                confidence: confidence,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> userId = const Value.absent(),
                required String label,
                required Money amountCents,
                required Cadence cadence,
                required DateTime nextExpectedOn,
                required IncomeConfidence confidence,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IncomeExpectationsCompanion.insert(
                id: id,
                userId: userId,
                label: label,
                amountCents: amountCents,
                cadence: cadence,
                nextExpectedOn: nextExpectedOn,
                confidence: confidence,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IncomeExpectationsTableProcessedTableManager =
    ProcessedTableManager<
      _$BaonDatabase,
      $IncomeExpectationsTable,
      IncomeExpectationRow,
      $$IncomeExpectationsTableFilterComposer,
      $$IncomeExpectationsTableOrderingComposer,
      $$IncomeExpectationsTableAnnotationComposer,
      $$IncomeExpectationsTableCreateCompanionBuilder,
      $$IncomeExpectationsTableUpdateCompanionBuilder,
      (
        IncomeExpectationRow,
        BaseReferences<
          _$BaonDatabase,
          $IncomeExpectationsTable,
          IncomeExpectationRow
        >,
      ),
      IncomeExpectationRow,
      PrefetchHooks Function()
    >;
typedef $$EnvelopesTableCreateCompanionBuilder =
    EnvelopesCompanion Function({
      required String id,
      Value<String> userId,
      required String label,
      required EnvelopeShape shape,
      required Money refillCents,
      required Cadence refillCadence,
      required String refillAnchor,
      Value<List<String>> allowBorrowFrom,
      required int priority,
      required int sortOrder,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$EnvelopesTableUpdateCompanionBuilder =
    EnvelopesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> label,
      Value<EnvelopeShape> shape,
      Value<Money> refillCents,
      Value<Cadence> refillCadence,
      Value<String> refillAnchor,
      Value<List<String>> allowBorrowFrom,
      Value<int> priority,
      Value<int> sortOrder,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$EnvelopesTableReferences
    extends BaseReferences<_$BaonDatabase, $EnvelopesTable, EnvelopeRow> {
  $$EnvelopesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $EnvelopeCategoriesTable,
    List<EnvelopeCategoryRow>
  >
  _envelopeCategoriesRefsTable(_$BaonDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.envelopeCategories,
        aliasName: 'envelopes__id__envelope_categories__envelope_id',
      );

  $$EnvelopeCategoriesTableProcessedTableManager get envelopeCategoriesRefs {
    final manager = $$EnvelopeCategoriesTableTableManager(
      $_db,
      $_db.envelopeCategories,
    ).filter((f) => f.envelopeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _envelopeCategoriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AllocationsTable, List<AllocationRow>>
  _allocationsRefsTable(_$BaonDatabase db) => MultiTypedResultKey.fromTable(
    db.allocations,
    aliasName: 'envelopes__id__allocations__envelope_id',
  );

  $$AllocationsTableProcessedTableManager get allocationsRefs {
    final manager = $$AllocationsTableTableManager(
      $_db,
      $_db.allocations,
    ).filter((f) => f.envelopeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_allocationsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BorrowEventsTable, List<BorrowEventRow>>
  _lentBorrowEventsTable(_$BaonDatabase db) => MultiTypedResultKey.fromTable(
    db.borrowEvents,
    aliasName: 'envelopes__id__borrow_events__from_envelope_id',
  );

  $$BorrowEventsTableProcessedTableManager get lentBorrowEvents {
    final manager = $$BorrowEventsTableTableManager(
      $_db,
      $_db.borrowEvents,
    ).filter((f) => f.fromEnvelopeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_lentBorrowEventsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BorrowEventsTable, List<BorrowEventRow>>
  _receivedBorrowEventsTable(_$BaonDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.borrowEvents,
        aliasName: 'envelopes__id__borrow_events__to_envelope_id',
      );

  $$BorrowEventsTableProcessedTableManager get receivedBorrowEvents {
    final manager = $$BorrowEventsTableTableManager(
      $_db,
      $_db.borrowEvents,
    ).filter((f) => f.toEnvelopeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _receivedBorrowEventsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EnvelopesTableFilterComposer
    extends Composer<_$BaonDatabase, $EnvelopesTable> {
  $$EnvelopesTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<EnvelopeShape, EnvelopeShape, String>
  get shape => $composableBuilder(
    column: $table.shape,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Money, Money, int> get refillCents =>
      $composableBuilder(
        column: $table.refillCents,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Cadence, Cadence, String> get refillCadence =>
      $composableBuilder(
        column: $table.refillCadence,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get refillAnchor => $composableBuilder(
    column: $table.refillAnchor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get allowBorrowFrom => $composableBuilder(
    column: $table.allowBorrowFrom,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> envelopeCategoriesRefs(
    Expression<bool> Function($$EnvelopeCategoriesTableFilterComposer f) f,
  ) {
    final $$EnvelopeCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.envelopeCategories,
      getReferencedColumn: (t) => t.envelopeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnvelopeCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.envelopeCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> allocationsRefs(
    Expression<bool> Function($$AllocationsTableFilterComposer f) f,
  ) {
    final $$AllocationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.allocations,
      getReferencedColumn: (t) => t.envelopeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AllocationsTableFilterComposer(
            $db: $db,
            $table: $db.allocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> lentBorrowEvents(
    Expression<bool> Function($$BorrowEventsTableFilterComposer f) f,
  ) {
    final $$BorrowEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.borrowEvents,
      getReferencedColumn: (t) => t.fromEnvelopeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BorrowEventsTableFilterComposer(
            $db: $db,
            $table: $db.borrowEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> receivedBorrowEvents(
    Expression<bool> Function($$BorrowEventsTableFilterComposer f) f,
  ) {
    final $$BorrowEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.borrowEvents,
      getReferencedColumn: (t) => t.toEnvelopeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BorrowEventsTableFilterComposer(
            $db: $db,
            $table: $db.borrowEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EnvelopesTableOrderingComposer
    extends Composer<_$BaonDatabase, $EnvelopesTable> {
  $$EnvelopesTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shape => $composableBuilder(
    column: $table.shape,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get refillCents => $composableBuilder(
    column: $table.refillCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refillCadence => $composableBuilder(
    column: $table.refillCadence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refillAnchor => $composableBuilder(
    column: $table.refillAnchor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get allowBorrowFrom => $composableBuilder(
    column: $table.allowBorrowFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EnvelopesTableAnnotationComposer
    extends Composer<_$BaonDatabase, $EnvelopesTable> {
  $$EnvelopesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumnWithTypeConverter<EnvelopeShape, String> get shape =>
      $composableBuilder(column: $table.shape, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Money, int> get refillCents =>
      $composableBuilder(
        column: $table.refillCents,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Cadence, String> get refillCadence =>
      $composableBuilder(
        column: $table.refillCadence,
        builder: (column) => column,
      );

  GeneratedColumn<String> get refillAnchor => $composableBuilder(
    column: $table.refillAnchor,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<String>, String> get allowBorrowFrom =>
      $composableBuilder(
        column: $table.allowBorrowFrom,
        builder: (column) => column,
      );

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> envelopeCategoriesRefs<T extends Object>(
    Expression<T> Function($$EnvelopeCategoriesTableAnnotationComposer a) f,
  ) {
    final $$EnvelopeCategoriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.envelopeCategories,
          getReferencedColumn: (t) => t.envelopeId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EnvelopeCategoriesTableAnnotationComposer(
                $db: $db,
                $table: $db.envelopeCategories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> allocationsRefs<T extends Object>(
    Expression<T> Function($$AllocationsTableAnnotationComposer a) f,
  ) {
    final $$AllocationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.allocations,
      getReferencedColumn: (t) => t.envelopeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AllocationsTableAnnotationComposer(
            $db: $db,
            $table: $db.allocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> lentBorrowEvents<T extends Object>(
    Expression<T> Function($$BorrowEventsTableAnnotationComposer a) f,
  ) {
    final $$BorrowEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.borrowEvents,
      getReferencedColumn: (t) => t.fromEnvelopeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BorrowEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.borrowEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> receivedBorrowEvents<T extends Object>(
    Expression<T> Function($$BorrowEventsTableAnnotationComposer a) f,
  ) {
    final $$BorrowEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.borrowEvents,
      getReferencedColumn: (t) => t.toEnvelopeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BorrowEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.borrowEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EnvelopesTableTableManager
    extends
        RootTableManager<
          _$BaonDatabase,
          $EnvelopesTable,
          EnvelopeRow,
          $$EnvelopesTableFilterComposer,
          $$EnvelopesTableOrderingComposer,
          $$EnvelopesTableAnnotationComposer,
          $$EnvelopesTableCreateCompanionBuilder,
          $$EnvelopesTableUpdateCompanionBuilder,
          (EnvelopeRow, $$EnvelopesTableReferences),
          EnvelopeRow,
          PrefetchHooks Function({
            bool envelopeCategoriesRefs,
            bool allocationsRefs,
            bool lentBorrowEvents,
            bool receivedBorrowEvents,
          })
        > {
  $$EnvelopesTableTableManager(_$BaonDatabase db, $EnvelopesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EnvelopesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EnvelopesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EnvelopesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<EnvelopeShape> shape = const Value.absent(),
                Value<Money> refillCents = const Value.absent(),
                Value<Cadence> refillCadence = const Value.absent(),
                Value<String> refillAnchor = const Value.absent(),
                Value<List<String>> allowBorrowFrom = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EnvelopesCompanion(
                id: id,
                userId: userId,
                label: label,
                shape: shape,
                refillCents: refillCents,
                refillCadence: refillCadence,
                refillAnchor: refillAnchor,
                allowBorrowFrom: allowBorrowFrom,
                priority: priority,
                sortOrder: sortOrder,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> userId = const Value.absent(),
                required String label,
                required EnvelopeShape shape,
                required Money refillCents,
                required Cadence refillCadence,
                required String refillAnchor,
                Value<List<String>> allowBorrowFrom = const Value.absent(),
                required int priority,
                required int sortOrder,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EnvelopesCompanion.insert(
                id: id,
                userId: userId,
                label: label,
                shape: shape,
                refillCents: refillCents,
                refillCadence: refillCadence,
                refillAnchor: refillAnchor,
                allowBorrowFrom: allowBorrowFrom,
                priority: priority,
                sortOrder: sortOrder,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EnvelopesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                envelopeCategoriesRefs = false,
                allocationsRefs = false,
                lentBorrowEvents = false,
                receivedBorrowEvents = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (envelopeCategoriesRefs) db.envelopeCategories,
                    if (allocationsRefs) db.allocations,
                    if (lentBorrowEvents) db.borrowEvents,
                    if (receivedBorrowEvents) db.borrowEvents,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (envelopeCategoriesRefs)
                        await $_getPrefetchedData<
                          EnvelopeRow,
                          $EnvelopesTable,
                          EnvelopeCategoryRow
                        >(
                          currentTable: table,
                          referencedTable: $$EnvelopesTableReferences
                              ._envelopeCategoriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EnvelopesTableReferences(
                                db,
                                table,
                                p0,
                              ).envelopeCategoriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.envelopeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (allocationsRefs)
                        await $_getPrefetchedData<
                          EnvelopeRow,
                          $EnvelopesTable,
                          AllocationRow
                        >(
                          currentTable: table,
                          referencedTable: $$EnvelopesTableReferences
                              ._allocationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EnvelopesTableReferences(
                                db,
                                table,
                                p0,
                              ).allocationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.envelopeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (lentBorrowEvents)
                        await $_getPrefetchedData<
                          EnvelopeRow,
                          $EnvelopesTable,
                          BorrowEventRow
                        >(
                          currentTable: table,
                          referencedTable: $$EnvelopesTableReferences
                              ._lentBorrowEventsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EnvelopesTableReferences(
                                db,
                                table,
                                p0,
                              ).lentBorrowEvents,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.fromEnvelopeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (receivedBorrowEvents)
                        await $_getPrefetchedData<
                          EnvelopeRow,
                          $EnvelopesTable,
                          BorrowEventRow
                        >(
                          currentTable: table,
                          referencedTable: $$EnvelopesTableReferences
                              ._receivedBorrowEventsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EnvelopesTableReferences(
                                db,
                                table,
                                p0,
                              ).receivedBorrowEvents,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.toEnvelopeId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$EnvelopesTableProcessedTableManager =
    ProcessedTableManager<
      _$BaonDatabase,
      $EnvelopesTable,
      EnvelopeRow,
      $$EnvelopesTableFilterComposer,
      $$EnvelopesTableOrderingComposer,
      $$EnvelopesTableAnnotationComposer,
      $$EnvelopesTableCreateCompanionBuilder,
      $$EnvelopesTableUpdateCompanionBuilder,
      (EnvelopeRow, $$EnvelopesTableReferences),
      EnvelopeRow,
      PrefetchHooks Function({
        bool envelopeCategoriesRefs,
        bool allocationsRefs,
        bool lentBorrowEvents,
        bool receivedBorrowEvents,
      })
    >;
typedef $$EnvelopeCategoriesTableCreateCompanionBuilder =
    EnvelopeCategoriesCompanion Function({
      required String envelopeId,
      required String categoryKey,
      Value<int> rowid,
    });
typedef $$EnvelopeCategoriesTableUpdateCompanionBuilder =
    EnvelopeCategoriesCompanion Function({
      Value<String> envelopeId,
      Value<String> categoryKey,
      Value<int> rowid,
    });

final class $$EnvelopeCategoriesTableReferences
    extends
        BaseReferences<
          _$BaonDatabase,
          $EnvelopeCategoriesTable,
          EnvelopeCategoryRow
        > {
  $$EnvelopeCategoriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $EnvelopesTable _envelopeIdTable(_$BaonDatabase db) => db.envelopes
      .createAlias('envelope_categories__envelope_id__envelopes__id');

  $$EnvelopesTableProcessedTableManager get envelopeId {
    final $_column = $_itemColumn<String>('envelope_id')!;

    final manager = $$EnvelopesTableTableManager(
      $_db,
      $_db.envelopes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_envelopeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CategoriesTable _categoryKeyTable(_$BaonDatabase db) => db.categories
      .createAlias('envelope_categories__category_key__categories__key');

  $$CategoriesTableProcessedTableManager get categoryKey {
    final $_column = $_itemColumn<String>('category_key')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.key.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryKeyTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EnvelopeCategoriesTableFilterComposer
    extends Composer<_$BaonDatabase, $EnvelopeCategoriesTable> {
  $$EnvelopeCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$EnvelopesTableFilterComposer get envelopeId {
    final $$EnvelopesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.envelopeId,
      referencedTable: $db.envelopes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnvelopesTableFilterComposer(
            $db: $db,
            $table: $db.envelopes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableFilterComposer get categoryKey {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryKey,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.key,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EnvelopeCategoriesTableOrderingComposer
    extends Composer<_$BaonDatabase, $EnvelopeCategoriesTable> {
  $$EnvelopeCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$EnvelopesTableOrderingComposer get envelopeId {
    final $$EnvelopesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.envelopeId,
      referencedTable: $db.envelopes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnvelopesTableOrderingComposer(
            $db: $db,
            $table: $db.envelopes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableOrderingComposer get categoryKey {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryKey,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.key,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EnvelopeCategoriesTableAnnotationComposer
    extends Composer<_$BaonDatabase, $EnvelopeCategoriesTable> {
  $$EnvelopeCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$EnvelopesTableAnnotationComposer get envelopeId {
    final $$EnvelopesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.envelopeId,
      referencedTable: $db.envelopes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnvelopesTableAnnotationComposer(
            $db: $db,
            $table: $db.envelopes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableAnnotationComposer get categoryKey {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryKey,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.key,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EnvelopeCategoriesTableTableManager
    extends
        RootTableManager<
          _$BaonDatabase,
          $EnvelopeCategoriesTable,
          EnvelopeCategoryRow,
          $$EnvelopeCategoriesTableFilterComposer,
          $$EnvelopeCategoriesTableOrderingComposer,
          $$EnvelopeCategoriesTableAnnotationComposer,
          $$EnvelopeCategoriesTableCreateCompanionBuilder,
          $$EnvelopeCategoriesTableUpdateCompanionBuilder,
          (EnvelopeCategoryRow, $$EnvelopeCategoriesTableReferences),
          EnvelopeCategoryRow,
          PrefetchHooks Function({bool envelopeId, bool categoryKey})
        > {
  $$EnvelopeCategoriesTableTableManager(
    _$BaonDatabase db,
    $EnvelopeCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EnvelopeCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EnvelopeCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EnvelopeCategoriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> envelopeId = const Value.absent(),
                Value<String> categoryKey = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EnvelopeCategoriesCompanion(
                envelopeId: envelopeId,
                categoryKey: categoryKey,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String envelopeId,
                required String categoryKey,
                Value<int> rowid = const Value.absent(),
              }) => EnvelopeCategoriesCompanion.insert(
                envelopeId: envelopeId,
                categoryKey: categoryKey,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EnvelopeCategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({envelopeId = false, categoryKey = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (envelopeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.envelopeId,
                                referencedTable:
                                    $$EnvelopeCategoriesTableReferences
                                        ._envelopeIdTable(db),
                                referencedColumn:
                                    $$EnvelopeCategoriesTableReferences
                                        ._envelopeIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (categoryKey) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.categoryKey,
                                referencedTable:
                                    $$EnvelopeCategoriesTableReferences
                                        ._categoryKeyTable(db),
                                referencedColumn:
                                    $$EnvelopeCategoriesTableReferences
                                        ._categoryKeyTable(db)
                                        .key,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EnvelopeCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$BaonDatabase,
      $EnvelopeCategoriesTable,
      EnvelopeCategoryRow,
      $$EnvelopeCategoriesTableFilterComposer,
      $$EnvelopeCategoriesTableOrderingComposer,
      $$EnvelopeCategoriesTableAnnotationComposer,
      $$EnvelopeCategoriesTableCreateCompanionBuilder,
      $$EnvelopeCategoriesTableUpdateCompanionBuilder,
      (EnvelopeCategoryRow, $$EnvelopeCategoriesTableReferences),
      EnvelopeCategoryRow,
      PrefetchHooks Function({bool envelopeId, bool categoryKey})
    >;
typedef $$AllocationsTableCreateCompanionBuilder =
    AllocationsCompanion Function({
      required String id,
      required String envelopeId,
      required Money balanceCents,
      required DateTime periodStart,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AllocationsTableUpdateCompanionBuilder =
    AllocationsCompanion Function({
      Value<String> id,
      Value<String> envelopeId,
      Value<Money> balanceCents,
      Value<DateTime> periodStart,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$AllocationsTableReferences
    extends BaseReferences<_$BaonDatabase, $AllocationsTable, AllocationRow> {
  $$AllocationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EnvelopesTable _envelopeIdTable(_$BaonDatabase db) =>
      db.envelopes.createAlias('allocations__envelope_id__envelopes__id');

  $$EnvelopesTableProcessedTableManager get envelopeId {
    final $_column = $_itemColumn<String>('envelope_id')!;

    final manager = $$EnvelopesTableTableManager(
      $_db,
      $_db.envelopes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_envelopeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AllocationsTableFilterComposer
    extends Composer<_$BaonDatabase, $AllocationsTable> {
  $$AllocationsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<Money, Money, int> get balanceCents =>
      $composableBuilder(
        column: $table.balanceCents,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get periodStart => $composableBuilder(
    column: $table.periodStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$EnvelopesTableFilterComposer get envelopeId {
    final $$EnvelopesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.envelopeId,
      referencedTable: $db.envelopes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnvelopesTableFilterComposer(
            $db: $db,
            $table: $db.envelopes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AllocationsTableOrderingComposer
    extends Composer<_$BaonDatabase, $AllocationsTable> {
  $$AllocationsTableOrderingComposer({
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

  ColumnOrderings<int> get balanceCents => $composableBuilder(
    column: $table.balanceCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get periodStart => $composableBuilder(
    column: $table.periodStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$EnvelopesTableOrderingComposer get envelopeId {
    final $$EnvelopesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.envelopeId,
      referencedTable: $db.envelopes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnvelopesTableOrderingComposer(
            $db: $db,
            $table: $db.envelopes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AllocationsTableAnnotationComposer
    extends Composer<_$BaonDatabase, $AllocationsTable> {
  $$AllocationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Money, int> get balanceCents =>
      $composableBuilder(
        column: $table.balanceCents,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get periodStart => $composableBuilder(
    column: $table.periodStart,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$EnvelopesTableAnnotationComposer get envelopeId {
    final $$EnvelopesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.envelopeId,
      referencedTable: $db.envelopes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnvelopesTableAnnotationComposer(
            $db: $db,
            $table: $db.envelopes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AllocationsTableTableManager
    extends
        RootTableManager<
          _$BaonDatabase,
          $AllocationsTable,
          AllocationRow,
          $$AllocationsTableFilterComposer,
          $$AllocationsTableOrderingComposer,
          $$AllocationsTableAnnotationComposer,
          $$AllocationsTableCreateCompanionBuilder,
          $$AllocationsTableUpdateCompanionBuilder,
          (AllocationRow, $$AllocationsTableReferences),
          AllocationRow,
          PrefetchHooks Function({bool envelopeId})
        > {
  $$AllocationsTableTableManager(_$BaonDatabase db, $AllocationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AllocationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AllocationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AllocationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> envelopeId = const Value.absent(),
                Value<Money> balanceCents = const Value.absent(),
                Value<DateTime> periodStart = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AllocationsCompanion(
                id: id,
                envelopeId: envelopeId,
                balanceCents: balanceCents,
                periodStart: periodStart,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String envelopeId,
                required Money balanceCents,
                required DateTime periodStart,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AllocationsCompanion.insert(
                id: id,
                envelopeId: envelopeId,
                balanceCents: balanceCents,
                periodStart: periodStart,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AllocationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({envelopeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (envelopeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.envelopeId,
                                referencedTable: $$AllocationsTableReferences
                                    ._envelopeIdTable(db),
                                referencedColumn: $$AllocationsTableReferences
                                    ._envelopeIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AllocationsTableProcessedTableManager =
    ProcessedTableManager<
      _$BaonDatabase,
      $AllocationsTable,
      AllocationRow,
      $$AllocationsTableFilterComposer,
      $$AllocationsTableOrderingComposer,
      $$AllocationsTableAnnotationComposer,
      $$AllocationsTableCreateCompanionBuilder,
      $$AllocationsTableUpdateCompanionBuilder,
      (AllocationRow, $$AllocationsTableReferences),
      AllocationRow,
      PrefetchHooks Function({bool envelopeId})
    >;
typedef $$BorrowEventsTableCreateCompanionBuilder =
    BorrowEventsCompanion Function({
      required String id,
      required String fromEnvelopeId,
      required String toEnvelopeId,
      required Money amountCents,
      required DateTime occurredAt,
      Value<DateTime?> repaidAt,
      Value<int> rowid,
    });
typedef $$BorrowEventsTableUpdateCompanionBuilder =
    BorrowEventsCompanion Function({
      Value<String> id,
      Value<String> fromEnvelopeId,
      Value<String> toEnvelopeId,
      Value<Money> amountCents,
      Value<DateTime> occurredAt,
      Value<DateTime?> repaidAt,
      Value<int> rowid,
    });

final class $$BorrowEventsTableReferences
    extends BaseReferences<_$BaonDatabase, $BorrowEventsTable, BorrowEventRow> {
  $$BorrowEventsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EnvelopesTable _fromEnvelopeIdTable(_$BaonDatabase db) => db.envelopes
      .createAlias('borrow_events__from_envelope_id__envelopes__id');

  $$EnvelopesTableProcessedTableManager get fromEnvelopeId {
    final $_column = $_itemColumn<String>('from_envelope_id')!;

    final manager = $$EnvelopesTableTableManager(
      $_db,
      $_db.envelopes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fromEnvelopeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $EnvelopesTable _toEnvelopeIdTable(_$BaonDatabase db) =>
      db.envelopes.createAlias('borrow_events__to_envelope_id__envelopes__id');

  $$EnvelopesTableProcessedTableManager get toEnvelopeId {
    final $_column = $_itemColumn<String>('to_envelope_id')!;

    final manager = $$EnvelopesTableTableManager(
      $_db,
      $_db.envelopes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_toEnvelopeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BorrowEventsTableFilterComposer
    extends Composer<_$BaonDatabase, $BorrowEventsTable> {
  $$BorrowEventsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<Money, Money, int> get amountCents =>
      $composableBuilder(
        column: $table.amountCents,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get repaidAt => $composableBuilder(
    column: $table.repaidAt,
    builder: (column) => ColumnFilters(column),
  );

  $$EnvelopesTableFilterComposer get fromEnvelopeId {
    final $$EnvelopesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fromEnvelopeId,
      referencedTable: $db.envelopes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnvelopesTableFilterComposer(
            $db: $db,
            $table: $db.envelopes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EnvelopesTableFilterComposer get toEnvelopeId {
    final $$EnvelopesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toEnvelopeId,
      referencedTable: $db.envelopes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnvelopesTableFilterComposer(
            $db: $db,
            $table: $db.envelopes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BorrowEventsTableOrderingComposer
    extends Composer<_$BaonDatabase, $BorrowEventsTable> {
  $$BorrowEventsTableOrderingComposer({
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

  ColumnOrderings<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get repaidAt => $composableBuilder(
    column: $table.repaidAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$EnvelopesTableOrderingComposer get fromEnvelopeId {
    final $$EnvelopesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fromEnvelopeId,
      referencedTable: $db.envelopes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnvelopesTableOrderingComposer(
            $db: $db,
            $table: $db.envelopes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EnvelopesTableOrderingComposer get toEnvelopeId {
    final $$EnvelopesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toEnvelopeId,
      referencedTable: $db.envelopes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnvelopesTableOrderingComposer(
            $db: $db,
            $table: $db.envelopes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BorrowEventsTableAnnotationComposer
    extends Composer<_$BaonDatabase, $BorrowEventsTable> {
  $$BorrowEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Money, int> get amountCents =>
      $composableBuilder(
        column: $table.amountCents,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get repaidAt =>
      $composableBuilder(column: $table.repaidAt, builder: (column) => column);

  $$EnvelopesTableAnnotationComposer get fromEnvelopeId {
    final $$EnvelopesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fromEnvelopeId,
      referencedTable: $db.envelopes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnvelopesTableAnnotationComposer(
            $db: $db,
            $table: $db.envelopes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EnvelopesTableAnnotationComposer get toEnvelopeId {
    final $$EnvelopesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toEnvelopeId,
      referencedTable: $db.envelopes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnvelopesTableAnnotationComposer(
            $db: $db,
            $table: $db.envelopes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BorrowEventsTableTableManager
    extends
        RootTableManager<
          _$BaonDatabase,
          $BorrowEventsTable,
          BorrowEventRow,
          $$BorrowEventsTableFilterComposer,
          $$BorrowEventsTableOrderingComposer,
          $$BorrowEventsTableAnnotationComposer,
          $$BorrowEventsTableCreateCompanionBuilder,
          $$BorrowEventsTableUpdateCompanionBuilder,
          (BorrowEventRow, $$BorrowEventsTableReferences),
          BorrowEventRow,
          PrefetchHooks Function({bool fromEnvelopeId, bool toEnvelopeId})
        > {
  $$BorrowEventsTableTableManager(_$BaonDatabase db, $BorrowEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BorrowEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BorrowEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BorrowEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> fromEnvelopeId = const Value.absent(),
                Value<String> toEnvelopeId = const Value.absent(),
                Value<Money> amountCents = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<DateTime?> repaidAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BorrowEventsCompanion(
                id: id,
                fromEnvelopeId: fromEnvelopeId,
                toEnvelopeId: toEnvelopeId,
                amountCents: amountCents,
                occurredAt: occurredAt,
                repaidAt: repaidAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String fromEnvelopeId,
                required String toEnvelopeId,
                required Money amountCents,
                required DateTime occurredAt,
                Value<DateTime?> repaidAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BorrowEventsCompanion.insert(
                id: id,
                fromEnvelopeId: fromEnvelopeId,
                toEnvelopeId: toEnvelopeId,
                amountCents: amountCents,
                occurredAt: occurredAt,
                repaidAt: repaidAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BorrowEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({fromEnvelopeId = false, toEnvelopeId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (fromEnvelopeId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.fromEnvelopeId,
                                    referencedTable:
                                        $$BorrowEventsTableReferences
                                            ._fromEnvelopeIdTable(db),
                                    referencedColumn:
                                        $$BorrowEventsTableReferences
                                            ._fromEnvelopeIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (toEnvelopeId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.toEnvelopeId,
                                    referencedTable:
                                        $$BorrowEventsTableReferences
                                            ._toEnvelopeIdTable(db),
                                    referencedColumn:
                                        $$BorrowEventsTableReferences
                                            ._toEnvelopeIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$BorrowEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$BaonDatabase,
      $BorrowEventsTable,
      BorrowEventRow,
      $$BorrowEventsTableFilterComposer,
      $$BorrowEventsTableOrderingComposer,
      $$BorrowEventsTableAnnotationComposer,
      $$BorrowEventsTableCreateCompanionBuilder,
      $$BorrowEventsTableUpdateCompanionBuilder,
      (BorrowEventRow, $$BorrowEventsTableReferences),
      BorrowEventRow,
      PrefetchHooks Function({bool fromEnvelopeId, bool toEnvelopeId})
    >;
typedef $$SettingsTableCreateCompanionBuilder =
    SettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SettingsTableUpdateCompanionBuilder =
    SettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SettingsTableFilterComposer
    extends Composer<_$BaonDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
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

class $$SettingsTableOrderingComposer
    extends Composer<_$BaonDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
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

class $$SettingsTableAnnotationComposer
    extends Composer<_$BaonDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
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

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$BaonDatabase,
          $SettingsTable,
          SettingRow,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (
            SettingRow,
            BaseReferences<_$BaonDatabase, $SettingsTable, SettingRow>,
          ),
          SettingRow,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$BaonDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$BaonDatabase,
      $SettingsTable,
      SettingRow,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (SettingRow, BaseReferences<_$BaonDatabase, $SettingsTable, SettingRow>),
      SettingRow,
      PrefetchHooks Function()
    >;

class $BaonDatabaseManager {
  final _$BaonDatabase _db;
  $BaonDatabaseManager(this._db);
  $$ProvidersTableTableManager get providers =>
      $$ProvidersTableTableManager(_db, _db.providers);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$BalanceSnapshotsTableTableManager get balanceSnapshots =>
      $$BalanceSnapshotsTableTableManager(_db, _db.balanceSnapshots);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$TxnsTableTableManager get txns => $$TxnsTableTableManager(_db, _db.txns);
  $$ObligationsTableTableManager get obligations =>
      $$ObligationsTableTableManager(_db, _db.obligations);
  $$IncomeExpectationsTableTableManager get incomeExpectations =>
      $$IncomeExpectationsTableTableManager(_db, _db.incomeExpectations);
  $$EnvelopesTableTableManager get envelopes =>
      $$EnvelopesTableTableManager(_db, _db.envelopes);
  $$EnvelopeCategoriesTableTableManager get envelopeCategories =>
      $$EnvelopeCategoriesTableTableManager(_db, _db.envelopeCategories);
  $$AllocationsTableTableManager get allocations =>
      $$AllocationsTableTableManager(_db, _db.allocations);
  $$BorrowEventsTableTableManager get borrowEvents =>
      $$BorrowEventsTableTableManager(_db, _db.borrowEvents);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
