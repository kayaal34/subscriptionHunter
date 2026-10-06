// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SubscriptionTableTable extends SubscriptionTable
    with TableInfo<$SubscriptionTableTable, SubscriptionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubscriptionTableTable(this.attachedDatabase, [this._alias]);
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
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<BillingCycle, String>
  billingCycle = GeneratedColumn<String>(
    'billing_cycle',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<BillingCycle>($SubscriptionTableTable.$converterbillingCycle);
  @override
  late final GeneratedColumnWithTypeConverter<SubscriptionCategory, String>
  category =
      GeneratedColumn<String>(
        'category',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SubscriptionCategory>(
        $SubscriptionTableTable.$convertercategory,
      );
  static const VerificationMeta _anchorDateMeta = const VerificationMeta(
    'anchorDate',
  );
  @override
  late final GeneratedColumn<DateTime> anchorDate = GeneratedColumn<DateTime>(
    'anchor_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandColorMeta = const VerificationMeta(
    'brandColor',
  );
  @override
  late final GeneratedColumn<int> brandColor = GeneratedColumn<int>(
    'brand_color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _presetIdMeta = const VerificationMeta(
    'presetId',
  );
  @override
  late final GeneratedColumn<String> presetId = GeneratedColumn<String>(
    'preset_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _logoAssetMeta = const VerificationMeta(
    'logoAsset',
  );
  @override
  late final GeneratedColumn<String> logoAsset = GeneratedColumn<String>(
    'logo_asset',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _logoUrlMeta = const VerificationMeta(
    'logoUrl',
  );
  @override
  late final GeneratedColumn<String> logoUrl = GeneratedColumn<String>(
    'logo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _reminderEnabledMeta = const VerificationMeta(
    'reminderEnabled',
  );
  @override
  late final GeneratedColumn<bool> reminderEnabled = GeneratedColumn<bool>(
    'reminder_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reminder_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _reminderDaysBeforeMeta =
      const VerificationMeta('reminderDaysBefore');
  @override
  late final GeneratedColumn<int> reminderDaysBefore = GeneratedColumn<int>(
    'reminder_days_before',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _reminderHourMeta = const VerificationMeta(
    'reminderHour',
  );
  @override
  late final GeneratedColumn<int> reminderHour = GeneratedColumn<int>(
    'reminder_hour',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
  );
  static const VerificationMeta _reminderMinuteMeta = const VerificationMeta(
    'reminderMinute',
  );
  @override
  late final GeneratedColumn<int> reminderMinute = GeneratedColumn<int>(
    'reminder_minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    price,
    currencyCode,
    billingCycle,
    category,
    anchorDate,
    brandColor,
    presetId,
    logoAsset,
    logoUrl,
    notes,
    endDate,
    isArchived,
    reminderEnabled,
    reminderDaysBefore,
    reminderHour,
    reminderMinute,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subscriptions';
  @override
  VerificationContext validateIntegrity(
    Insertable<SubscriptionRow> instance, {
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
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('anchor_date')) {
      context.handle(
        _anchorDateMeta,
        anchorDate.isAcceptableOrUnknown(data['anchor_date']!, _anchorDateMeta),
      );
    } else if (isInserting) {
      context.missing(_anchorDateMeta);
    }
    if (data.containsKey('brand_color')) {
      context.handle(
        _brandColorMeta,
        brandColor.isAcceptableOrUnknown(data['brand_color']!, _brandColorMeta),
      );
    } else if (isInserting) {
      context.missing(_brandColorMeta);
    }
    if (data.containsKey('preset_id')) {
      context.handle(
        _presetIdMeta,
        presetId.isAcceptableOrUnknown(data['preset_id']!, _presetIdMeta),
      );
    }
    if (data.containsKey('logo_asset')) {
      context.handle(
        _logoAssetMeta,
        logoAsset.isAcceptableOrUnknown(data['logo_asset']!, _logoAssetMeta),
      );
    }
    if (data.containsKey('logo_url')) {
      context.handle(
        _logoUrlMeta,
        logoUrl.isAcceptableOrUnknown(data['logo_url']!, _logoUrlMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('reminder_enabled')) {
      context.handle(
        _reminderEnabledMeta,
        reminderEnabled.isAcceptableOrUnknown(
          data['reminder_enabled']!,
          _reminderEnabledMeta,
        ),
      );
    }
    if (data.containsKey('reminder_days_before')) {
      context.handle(
        _reminderDaysBeforeMeta,
        reminderDaysBefore.isAcceptableOrUnknown(
          data['reminder_days_before']!,
          _reminderDaysBeforeMeta,
        ),
      );
    }
    if (data.containsKey('reminder_hour')) {
      context.handle(
        _reminderHourMeta,
        reminderHour.isAcceptableOrUnknown(
          data['reminder_hour']!,
          _reminderHourMeta,
        ),
      );
    }
    if (data.containsKey('reminder_minute')) {
      context.handle(
        _reminderMinuteMeta,
        reminderMinute.isAcceptableOrUnknown(
          data['reminder_minute']!,
          _reminderMinuteMeta,
        ),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SubscriptionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubscriptionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      billingCycle: $SubscriptionTableTable.$converterbillingCycle.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}billing_cycle'],
        )!,
      ),
      category: $SubscriptionTableTable.$convertercategory.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}category'],
        )!,
      ),
      anchorDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}anchor_date'],
      )!,
      brandColor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}brand_color'],
      )!,
      presetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preset_id'],
      ),
      logoAsset: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logo_asset'],
      ),
      logoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logo_url'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      reminderEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reminder_enabled'],
      )!,
      reminderDaysBefore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_days_before'],
      )!,
      reminderHour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_hour'],
      )!,
      reminderMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_minute'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SubscriptionTableTable createAlias(String alias) {
    return $SubscriptionTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<BillingCycle, String, String>
  $converterbillingCycle = const EnumNameConverter<BillingCycle>(
    BillingCycle.values,
  );
  static JsonTypeConverter2<SubscriptionCategory, String, String>
  $convertercategory = const EnumNameConverter<SubscriptionCategory>(
    SubscriptionCategory.values,
  );
}

class SubscriptionRow extends DataClass implements Insertable<SubscriptionRow> {
  final String id;
  final String name;
  final double price;
  final String currencyCode;

  /// Stored as the enum's name, not its index, so reordering the enum cannot
  /// silently re-interpret existing rows.
  final BillingCycle billingCycle;
  final SubscriptionCategory category;
  final DateTime anchorDate;
  final int brandColor;
  final String? presetId;
  final String? logoAsset;
  final String? logoUrl;
  final String? notes;
  final DateTime? endDate;
  final bool isArchived;
  final bool reminderEnabled;
  final int reminderDaysBefore;
  final int reminderHour;
  final int reminderMinute;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SubscriptionRow({
    required this.id,
    required this.name,
    required this.price,
    required this.currencyCode,
    required this.billingCycle,
    required this.category,
    required this.anchorDate,
    required this.brandColor,
    this.presetId,
    this.logoAsset,
    this.logoUrl,
    this.notes,
    this.endDate,
    required this.isArchived,
    required this.reminderEnabled,
    required this.reminderDaysBefore,
    required this.reminderHour,
    required this.reminderMinute,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['price'] = Variable<double>(price);
    map['currency_code'] = Variable<String>(currencyCode);
    {
      map['billing_cycle'] = Variable<String>(
        $SubscriptionTableTable.$converterbillingCycle.toSql(billingCycle),
      );
    }
    {
      map['category'] = Variable<String>(
        $SubscriptionTableTable.$convertercategory.toSql(category),
      );
    }
    map['anchor_date'] = Variable<DateTime>(anchorDate);
    map['brand_color'] = Variable<int>(brandColor);
    if (!nullToAbsent || presetId != null) {
      map['preset_id'] = Variable<String>(presetId);
    }
    if (!nullToAbsent || logoAsset != null) {
      map['logo_asset'] = Variable<String>(logoAsset);
    }
    if (!nullToAbsent || logoUrl != null) {
      map['logo_url'] = Variable<String>(logoUrl);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    map['is_archived'] = Variable<bool>(isArchived);
    map['reminder_enabled'] = Variable<bool>(reminderEnabled);
    map['reminder_days_before'] = Variable<int>(reminderDaysBefore);
    map['reminder_hour'] = Variable<int>(reminderHour);
    map['reminder_minute'] = Variable<int>(reminderMinute);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SubscriptionTableCompanion toCompanion(bool nullToAbsent) {
    return SubscriptionTableCompanion(
      id: Value(id),
      name: Value(name),
      price: Value(price),
      currencyCode: Value(currencyCode),
      billingCycle: Value(billingCycle),
      category: Value(category),
      anchorDate: Value(anchorDate),
      brandColor: Value(brandColor),
      presetId: presetId == null && nullToAbsent
          ? const Value.absent()
          : Value(presetId),
      logoAsset: logoAsset == null && nullToAbsent
          ? const Value.absent()
          : Value(logoAsset),
      logoUrl: logoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(logoUrl),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      isArchived: Value(isArchived),
      reminderEnabled: Value(reminderEnabled),
      reminderDaysBefore: Value(reminderDaysBefore),
      reminderHour: Value(reminderHour),
      reminderMinute: Value(reminderMinute),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SubscriptionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubscriptionRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      price: serializer.fromJson<double>(json['price']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      billingCycle: $SubscriptionTableTable.$converterbillingCycle.fromJson(
        serializer.fromJson<String>(json['billingCycle']),
      ),
      category: $SubscriptionTableTable.$convertercategory.fromJson(
        serializer.fromJson<String>(json['category']),
      ),
      anchorDate: serializer.fromJson<DateTime>(json['anchorDate']),
      brandColor: serializer.fromJson<int>(json['brandColor']),
      presetId: serializer.fromJson<String?>(json['presetId']),
      logoAsset: serializer.fromJson<String?>(json['logoAsset']),
      logoUrl: serializer.fromJson<String?>(json['logoUrl']),
      notes: serializer.fromJson<String?>(json['notes']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      reminderEnabled: serializer.fromJson<bool>(json['reminderEnabled']),
      reminderDaysBefore: serializer.fromJson<int>(json['reminderDaysBefore']),
      reminderHour: serializer.fromJson<int>(json['reminderHour']),
      reminderMinute: serializer.fromJson<int>(json['reminderMinute']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'price': serializer.toJson<double>(price),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'billingCycle': serializer.toJson<String>(
        $SubscriptionTableTable.$converterbillingCycle.toJson(billingCycle),
      ),
      'category': serializer.toJson<String>(
        $SubscriptionTableTable.$convertercategory.toJson(category),
      ),
      'anchorDate': serializer.toJson<DateTime>(anchorDate),
      'brandColor': serializer.toJson<int>(brandColor),
      'presetId': serializer.toJson<String?>(presetId),
      'logoAsset': serializer.toJson<String?>(logoAsset),
      'logoUrl': serializer.toJson<String?>(logoUrl),
      'notes': serializer.toJson<String?>(notes),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'isArchived': serializer.toJson<bool>(isArchived),
      'reminderEnabled': serializer.toJson<bool>(reminderEnabled),
      'reminderDaysBefore': serializer.toJson<int>(reminderDaysBefore),
      'reminderHour': serializer.toJson<int>(reminderHour),
      'reminderMinute': serializer.toJson<int>(reminderMinute),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SubscriptionRow copyWith({
    String? id,
    String? name,
    double? price,
    String? currencyCode,
    BillingCycle? billingCycle,
    SubscriptionCategory? category,
    DateTime? anchorDate,
    int? brandColor,
    Value<String?> presetId = const Value.absent(),
    Value<String?> logoAsset = const Value.absent(),
    Value<String?> logoUrl = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<DateTime?> endDate = const Value.absent(),
    bool? isArchived,
    bool? reminderEnabled,
    int? reminderDaysBefore,
    int? reminderHour,
    int? reminderMinute,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => SubscriptionRow(
    id: id ?? this.id,
    name: name ?? this.name,
    price: price ?? this.price,
    currencyCode: currencyCode ?? this.currencyCode,
    billingCycle: billingCycle ?? this.billingCycle,
    category: category ?? this.category,
    anchorDate: anchorDate ?? this.anchorDate,
    brandColor: brandColor ?? this.brandColor,
    presetId: presetId.present ? presetId.value : this.presetId,
    logoAsset: logoAsset.present ? logoAsset.value : this.logoAsset,
    logoUrl: logoUrl.present ? logoUrl.value : this.logoUrl,
    notes: notes.present ? notes.value : this.notes,
    endDate: endDate.present ? endDate.value : this.endDate,
    isArchived: isArchived ?? this.isArchived,
    reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
    reminderHour: reminderHour ?? this.reminderHour,
    reminderMinute: reminderMinute ?? this.reminderMinute,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SubscriptionRow copyWithCompanion(SubscriptionTableCompanion data) {
    return SubscriptionRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      price: data.price.present ? data.price.value : this.price,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      billingCycle: data.billingCycle.present
          ? data.billingCycle.value
          : this.billingCycle,
      category: data.category.present ? data.category.value : this.category,
      anchorDate: data.anchorDate.present
          ? data.anchorDate.value
          : this.anchorDate,
      brandColor: data.brandColor.present
          ? data.brandColor.value
          : this.brandColor,
      presetId: data.presetId.present ? data.presetId.value : this.presetId,
      logoAsset: data.logoAsset.present ? data.logoAsset.value : this.logoAsset,
      logoUrl: data.logoUrl.present ? data.logoUrl.value : this.logoUrl,
      notes: data.notes.present ? data.notes.value : this.notes,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      reminderEnabled: data.reminderEnabled.present
          ? data.reminderEnabled.value
          : this.reminderEnabled,
      reminderDaysBefore: data.reminderDaysBefore.present
          ? data.reminderDaysBefore.value
          : this.reminderDaysBefore,
      reminderHour: data.reminderHour.present
          ? data.reminderHour.value
          : this.reminderHour,
      reminderMinute: data.reminderMinute.present
          ? data.reminderMinute.value
          : this.reminderMinute,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SubscriptionRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('price: $price, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('billingCycle: $billingCycle, ')
          ..write('category: $category, ')
          ..write('anchorDate: $anchorDate, ')
          ..write('brandColor: $brandColor, ')
          ..write('presetId: $presetId, ')
          ..write('logoAsset: $logoAsset, ')
          ..write('logoUrl: $logoUrl, ')
          ..write('notes: $notes, ')
          ..write('endDate: $endDate, ')
          ..write('isArchived: $isArchived, ')
          ..write('reminderEnabled: $reminderEnabled, ')
          ..write('reminderDaysBefore: $reminderDaysBefore, ')
          ..write('reminderHour: $reminderHour, ')
          ..write('reminderMinute: $reminderMinute, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    price,
    currencyCode,
    billingCycle,
    category,
    anchorDate,
    brandColor,
    presetId,
    logoAsset,
    logoUrl,
    notes,
    endDate,
    isArchived,
    reminderEnabled,
    reminderDaysBefore,
    reminderHour,
    reminderMinute,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubscriptionRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.price == this.price &&
          other.currencyCode == this.currencyCode &&
          other.billingCycle == this.billingCycle &&
          other.category == this.category &&
          other.anchorDate == this.anchorDate &&
          other.brandColor == this.brandColor &&
          other.presetId == this.presetId &&
          other.logoAsset == this.logoAsset &&
          other.logoUrl == this.logoUrl &&
          other.notes == this.notes &&
          other.endDate == this.endDate &&
          other.isArchived == this.isArchived &&
          other.reminderEnabled == this.reminderEnabled &&
          other.reminderDaysBefore == this.reminderDaysBefore &&
          other.reminderHour == this.reminderHour &&
          other.reminderMinute == this.reminderMinute &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SubscriptionTableCompanion extends UpdateCompanion<SubscriptionRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<double> price;
  final Value<String> currencyCode;
  final Value<BillingCycle> billingCycle;
  final Value<SubscriptionCategory> category;
  final Value<DateTime> anchorDate;
  final Value<int> brandColor;
  final Value<String?> presetId;
  final Value<String?> logoAsset;
  final Value<String?> logoUrl;
  final Value<String?> notes;
  final Value<DateTime?> endDate;
  final Value<bool> isArchived;
  final Value<bool> reminderEnabled;
  final Value<int> reminderDaysBefore;
  final Value<int> reminderHour;
  final Value<int> reminderMinute;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SubscriptionTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.price = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.billingCycle = const Value.absent(),
    this.category = const Value.absent(),
    this.anchorDate = const Value.absent(),
    this.brandColor = const Value.absent(),
    this.presetId = const Value.absent(),
    this.logoAsset = const Value.absent(),
    this.logoUrl = const Value.absent(),
    this.notes = const Value.absent(),
    this.endDate = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.reminderEnabled = const Value.absent(),
    this.reminderDaysBefore = const Value.absent(),
    this.reminderHour = const Value.absent(),
    this.reminderMinute = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubscriptionTableCompanion.insert({
    required String id,
    required String name,
    required double price,
    required String currencyCode,
    required BillingCycle billingCycle,
    required SubscriptionCategory category,
    required DateTime anchorDate,
    required int brandColor,
    this.presetId = const Value.absent(),
    this.logoAsset = const Value.absent(),
    this.logoUrl = const Value.absent(),
    this.notes = const Value.absent(),
    this.endDate = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.reminderEnabled = const Value.absent(),
    this.reminderDaysBefore = const Value.absent(),
    this.reminderHour = const Value.absent(),
    this.reminderMinute = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       price = Value(price),
       currencyCode = Value(currencyCode),
       billingCycle = Value(billingCycle),
       category = Value(category),
       anchorDate = Value(anchorDate),
       brandColor = Value(brandColor),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SubscriptionRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<double>? price,
    Expression<String>? currencyCode,
    Expression<String>? billingCycle,
    Expression<String>? category,
    Expression<DateTime>? anchorDate,
    Expression<int>? brandColor,
    Expression<String>? presetId,
    Expression<String>? logoAsset,
    Expression<String>? logoUrl,
    Expression<String>? notes,
    Expression<DateTime>? endDate,
    Expression<bool>? isArchived,
    Expression<bool>? reminderEnabled,
    Expression<int>? reminderDaysBefore,
    Expression<int>? reminderHour,
    Expression<int>? reminderMinute,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (price != null) 'price': price,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (billingCycle != null) 'billing_cycle': billingCycle,
      if (category != null) 'category': category,
      if (anchorDate != null) 'anchor_date': anchorDate,
      if (brandColor != null) 'brand_color': brandColor,
      if (presetId != null) 'preset_id': presetId,
      if (logoAsset != null) 'logo_asset': logoAsset,
      if (logoUrl != null) 'logo_url': logoUrl,
      if (notes != null) 'notes': notes,
      if (endDate != null) 'end_date': endDate,
      if (isArchived != null) 'is_archived': isArchived,
      if (reminderEnabled != null) 'reminder_enabled': reminderEnabled,
      if (reminderDaysBefore != null)
        'reminder_days_before': reminderDaysBefore,
      if (reminderHour != null) 'reminder_hour': reminderHour,
      if (reminderMinute != null) 'reminder_minute': reminderMinute,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubscriptionTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<double>? price,
    Value<String>? currencyCode,
    Value<BillingCycle>? billingCycle,
    Value<SubscriptionCategory>? category,
    Value<DateTime>? anchorDate,
    Value<int>? brandColor,
    Value<String?>? presetId,
    Value<String?>? logoAsset,
    Value<String?>? logoUrl,
    Value<String?>? notes,
    Value<DateTime?>? endDate,
    Value<bool>? isArchived,
    Value<bool>? reminderEnabled,
    Value<int>? reminderDaysBefore,
    Value<int>? reminderHour,
    Value<int>? reminderMinute,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SubscriptionTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      currencyCode: currencyCode ?? this.currencyCode,
      billingCycle: billingCycle ?? this.billingCycle,
      category: category ?? this.category,
      anchorDate: anchorDate ?? this.anchorDate,
      brandColor: brandColor ?? this.brandColor,
      presetId: presetId ?? this.presetId,
      logoAsset: logoAsset ?? this.logoAsset,
      logoUrl: logoUrl ?? this.logoUrl,
      notes: notes ?? this.notes,
      endDate: endDate ?? this.endDate,
      isArchived: isArchived ?? this.isArchived,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      createdAt: createdAt ?? this.createdAt,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (billingCycle.present) {
      map['billing_cycle'] = Variable<String>(
        $SubscriptionTableTable.$converterbillingCycle.toSql(
          billingCycle.value,
        ),
      );
    }
    if (category.present) {
      map['category'] = Variable<String>(
        $SubscriptionTableTable.$convertercategory.toSql(category.value),
      );
    }
    if (anchorDate.present) {
      map['anchor_date'] = Variable<DateTime>(anchorDate.value);
    }
    if (brandColor.present) {
      map['brand_color'] = Variable<int>(brandColor.value);
    }
    if (presetId.present) {
      map['preset_id'] = Variable<String>(presetId.value);
    }
    if (logoAsset.present) {
      map['logo_asset'] = Variable<String>(logoAsset.value);
    }
    if (logoUrl.present) {
      map['logo_url'] = Variable<String>(logoUrl.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (reminderEnabled.present) {
      map['reminder_enabled'] = Variable<bool>(reminderEnabled.value);
    }
    if (reminderDaysBefore.present) {
      map['reminder_days_before'] = Variable<int>(reminderDaysBefore.value);
    }
    if (reminderHour.present) {
      map['reminder_hour'] = Variable<int>(reminderHour.value);
    }
    if (reminderMinute.present) {
      map['reminder_minute'] = Variable<int>(reminderMinute.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('SubscriptionTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('price: $price, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('billingCycle: $billingCycle, ')
          ..write('category: $category, ')
          ..write('anchorDate: $anchorDate, ')
          ..write('brandColor: $brandColor, ')
          ..write('presetId: $presetId, ')
          ..write('logoAsset: $logoAsset, ')
          ..write('logoUrl: $logoUrl, ')
          ..write('notes: $notes, ')
          ..write('endDate: $endDate, ')
          ..write('isArchived: $isArchived, ')
          ..write('reminderEnabled: $reminderEnabled, ')
          ..write('reminderDaysBefore: $reminderDaysBefore, ')
          ..write('reminderHour: $reminderHour, ')
          ..write('reminderMinute: $reminderMinute, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SubscriptionTableTable subscriptionTable =
      $SubscriptionTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [subscriptionTable];
}

typedef $$SubscriptionTableTableCreateCompanionBuilder =
    SubscriptionTableCompanion Function({
      required String id,
      required String name,
      required double price,
      required String currencyCode,
      required BillingCycle billingCycle,
      required SubscriptionCategory category,
      required DateTime anchorDate,
      required int brandColor,
      Value<String?> presetId,
      Value<String?> logoAsset,
      Value<String?> logoUrl,
      Value<String?> notes,
      Value<DateTime?> endDate,
      Value<bool> isArchived,
      Value<bool> reminderEnabled,
      Value<int> reminderDaysBefore,
      Value<int> reminderHour,
      Value<int> reminderMinute,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SubscriptionTableTableUpdateCompanionBuilder =
    SubscriptionTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<double> price,
      Value<String> currencyCode,
      Value<BillingCycle> billingCycle,
      Value<SubscriptionCategory> category,
      Value<DateTime> anchorDate,
      Value<int> brandColor,
      Value<String?> presetId,
      Value<String?> logoAsset,
      Value<String?> logoUrl,
      Value<String?> notes,
      Value<DateTime?> endDate,
      Value<bool> isArchived,
      Value<bool> reminderEnabled,
      Value<int> reminderDaysBefore,
      Value<int> reminderHour,
      Value<int> reminderMinute,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SubscriptionTableTableFilterComposer
    extends Composer<_$AppDatabase, $SubscriptionTableTable> {
  $$SubscriptionTableTableFilterComposer({
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

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<BillingCycle, BillingCycle, String>
  get billingCycle => $composableBuilder(
    column: $table.billingCycle,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<
    SubscriptionCategory,
    SubscriptionCategory,
    String
  >
  get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get anchorDate => $composableBuilder(
    column: $table.anchorDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get brandColor => $composableBuilder(
    column: $table.brandColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get presetId => $composableBuilder(
    column: $table.presetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get logoAsset => $composableBuilder(
    column: $table.logoAsset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get logoUrl => $composableBuilder(
    column: $table.logoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderDaysBefore => $composableBuilder(
    column: $table.reminderDaysBefore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderHour => $composableBuilder(
    column: $table.reminderHour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderMinute => $composableBuilder(
    column: $table.reminderMinute,
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
}

class $$SubscriptionTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SubscriptionTableTable> {
  $$SubscriptionTableTableOrderingComposer({
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

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get billingCycle => $composableBuilder(
    column: $table.billingCycle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get anchorDate => $composableBuilder(
    column: $table.anchorDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get brandColor => $composableBuilder(
    column: $table.brandColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get presetId => $composableBuilder(
    column: $table.presetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get logoAsset => $composableBuilder(
    column: $table.logoAsset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get logoUrl => $composableBuilder(
    column: $table.logoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderDaysBefore => $composableBuilder(
    column: $table.reminderDaysBefore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderHour => $composableBuilder(
    column: $table.reminderHour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderMinute => $composableBuilder(
    column: $table.reminderMinute,
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
}

class $$SubscriptionTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubscriptionTableTable> {
  $$SubscriptionTableTableAnnotationComposer({
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

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<BillingCycle, String> get billingCycle =>
      $composableBuilder(
        column: $table.billingCycle,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<SubscriptionCategory, String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<DateTime> get anchorDate => $composableBuilder(
    column: $table.anchorDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get brandColor => $composableBuilder(
    column: $table.brandColor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get presetId =>
      $composableBuilder(column: $table.presetId, builder: (column) => column);

  GeneratedColumn<String> get logoAsset =>
      $composableBuilder(column: $table.logoAsset, builder: (column) => column);

  GeneratedColumn<String> get logoUrl =>
      $composableBuilder(column: $table.logoUrl, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderDaysBefore => $composableBuilder(
    column: $table.reminderDaysBefore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderHour => $composableBuilder(
    column: $table.reminderHour,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderMinute => $composableBuilder(
    column: $table.reminderMinute,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SubscriptionTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubscriptionTableTable,
          SubscriptionRow,
          $$SubscriptionTableTableFilterComposer,
          $$SubscriptionTableTableOrderingComposer,
          $$SubscriptionTableTableAnnotationComposer,
          $$SubscriptionTableTableCreateCompanionBuilder,
          $$SubscriptionTableTableUpdateCompanionBuilder,
          (
            SubscriptionRow,
            BaseReferences<
              _$AppDatabase,
              $SubscriptionTableTable,
              SubscriptionRow
            >,
          ),
          SubscriptionRow,
          PrefetchHooks Function()
        > {
  $$SubscriptionTableTableTableManager(
    _$AppDatabase db,
    $SubscriptionTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubscriptionTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubscriptionTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubscriptionTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<BillingCycle> billingCycle = const Value.absent(),
                Value<SubscriptionCategory> category = const Value.absent(),
                Value<DateTime> anchorDate = const Value.absent(),
                Value<int> brandColor = const Value.absent(),
                Value<String?> presetId = const Value.absent(),
                Value<String?> logoAsset = const Value.absent(),
                Value<String?> logoUrl = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<bool> reminderEnabled = const Value.absent(),
                Value<int> reminderDaysBefore = const Value.absent(),
                Value<int> reminderHour = const Value.absent(),
                Value<int> reminderMinute = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SubscriptionTableCompanion(
                id: id,
                name: name,
                price: price,
                currencyCode: currencyCode,
                billingCycle: billingCycle,
                category: category,
                anchorDate: anchorDate,
                brandColor: brandColor,
                presetId: presetId,
                logoAsset: logoAsset,
                logoUrl: logoUrl,
                notes: notes,
                endDate: endDate,
                isArchived: isArchived,
                reminderEnabled: reminderEnabled,
                reminderDaysBefore: reminderDaysBefore,
                reminderHour: reminderHour,
                reminderMinute: reminderMinute,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required double price,
                required String currencyCode,
                required BillingCycle billingCycle,
                required SubscriptionCategory category,
                required DateTime anchorDate,
                required int brandColor,
                Value<String?> presetId = const Value.absent(),
                Value<String?> logoAsset = const Value.absent(),
                Value<String?> logoUrl = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<bool> reminderEnabled = const Value.absent(),
                Value<int> reminderDaysBefore = const Value.absent(),
                Value<int> reminderHour = const Value.absent(),
                Value<int> reminderMinute = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SubscriptionTableCompanion.insert(
                id: id,
                name: name,
                price: price,
                currencyCode: currencyCode,
                billingCycle: billingCycle,
                category: category,
                anchorDate: anchorDate,
                brandColor: brandColor,
                presetId: presetId,
                logoAsset: logoAsset,
                logoUrl: logoUrl,
                notes: notes,
                endDate: endDate,
                isArchived: isArchived,
                reminderEnabled: reminderEnabled,
                reminderDaysBefore: reminderDaysBefore,
                reminderHour: reminderHour,
                reminderMinute: reminderMinute,
                createdAt: createdAt,
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

typedef $$SubscriptionTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubscriptionTableTable,
      SubscriptionRow,
      $$SubscriptionTableTableFilterComposer,
      $$SubscriptionTableTableOrderingComposer,
      $$SubscriptionTableTableAnnotationComposer,
      $$SubscriptionTableTableCreateCompanionBuilder,
      $$SubscriptionTableTableUpdateCompanionBuilder,
      (
        SubscriptionRow,
        BaseReferences<_$AppDatabase, $SubscriptionTableTable, SubscriptionRow>,
      ),
      SubscriptionRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SubscriptionTableTableTableManager get subscriptionTable =>
      $$SubscriptionTableTableTableManager(_db, _db.subscriptionTable);
}
