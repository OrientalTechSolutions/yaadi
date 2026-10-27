// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vault_database.dart';

// ignore_for_file: type=lint
class $ItemsTable extends Items with TableInfo<$ItemsTable, ItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ItemKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ItemKind>($ItemsTable.$converterkind);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ItemCategory, String> category =
      GeneratedColumn<String>(
        'category',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ItemCategory>($ItemsTable.$convertercategory);
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountIsFixedMeta = const VerificationMeta(
    'amountIsFixed',
  );
  @override
  late final GeneratedColumn<bool> amountIsFixed = GeneratedColumn<bool>(
    'amount_is_fixed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("amount_is_fixed" IN (0, 1))',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<LocalDate?, String> scheduledOn =
      GeneratedColumn<String>(
        'scheduled_on',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<LocalDate?>($ItemsTable.$converterscheduledOnn);
  @override
  late final GeneratedColumnWithTypeConverter<LocalDate?, String> dueOn =
      GeneratedColumn<String>(
        'due_on',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<LocalDate?>($ItemsTable.$converterdueOnn);
  static const VerificationMeta _dueMinuteMeta = const VerificationMeta(
    'dueMinute',
  );
  @override
  late final GeneratedColumn<int> dueMinute = GeneratedColumn<int>(
    'due_minute',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Recurrence, String> recurrence =
      GeneratedColumn<String>(
        'recurrence',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('{"type":"none"}'),
      ).withConverter<Recurrence>($ItemsTable.$converterrecurrence);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 1000),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referenceMeta = const VerificationMeta(
    'reference',
  );
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
    'reference',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 40),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ItemStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ItemStatus>($ItemsTable.$converterstatus);
  @override
  late final GeneratedColumnWithTypeConverter<LocalDate?, String> snoozedUntil =
      GeneratedColumn<String>(
        'snoozed_until',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<LocalDate?>($ItemsTable.$convertersnoozedUntiln);
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    title,
    category,
    amountMinor,
    currency,
    amountIsFixed,
    scheduledOn,
    dueOn,
    dueMinute,
    recurrence,
    notes,
    reference,
    status,
    snoozedUntil,
    completedAt,
    revision,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('amount_is_fixed')) {
      context.handle(
        _amountIsFixedMeta,
        amountIsFixed.isAcceptableOrUnknown(
          data['amount_is_fixed']!,
          _amountIsFixedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountIsFixedMeta);
    }
    if (data.containsKey('due_minute')) {
      context.handle(
        _dueMinuteMeta,
        dueMinute.isAcceptableOrUnknown(data['due_minute']!, _dueMinuteMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('reference')) {
      context.handle(
        _referenceMeta,
        reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
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
  ItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kind: $ItemsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      category: $ItemsTable.$convertercategory.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}category'],
        )!,
      ),
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      ),
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      ),
      amountIsFixed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}amount_is_fixed'],
      )!,
      scheduledOn: $ItemsTable.$converterscheduledOnn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}scheduled_on'],
        ),
      ),
      dueOn: $ItemsTable.$converterdueOnn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}due_on'],
        ),
      ),
      dueMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}due_minute'],
      ),
      recurrence: $ItemsTable.$converterrecurrence.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}recurrence'],
        )!,
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      reference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference'],
      ),
      status: $ItemsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      snoozedUntil: $ItemsTable.$convertersnoozedUntiln.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}snoozed_until'],
        ),
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at'],
      ),
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ItemsTable createAlias(String alias) {
    return $ItemsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ItemKind, String, String> $converterkind =
      const EnumNameConverter<ItemKind>(ItemKind.values);
  static JsonTypeConverter2<ItemCategory, String, String> $convertercategory =
      const EnumNameConverter<ItemCategory>(ItemCategory.values);
  static TypeConverter<LocalDate, String> $converterscheduledOn =
      const LocalDateConverter();
  static TypeConverter<LocalDate?, String?> $converterscheduledOnn =
      NullAwareTypeConverter.wrap($converterscheduledOn);
  static TypeConverter<LocalDate, String> $converterdueOn =
      const LocalDateConverter();
  static TypeConverter<LocalDate?, String?> $converterdueOnn =
      NullAwareTypeConverter.wrap($converterdueOn);
  static TypeConverter<Recurrence, String> $converterrecurrence =
      const RecurrenceConverter();
  static JsonTypeConverter2<ItemStatus, String, String> $converterstatus =
      const EnumNameConverter<ItemStatus>(ItemStatus.values);
  static TypeConverter<LocalDate, String> $convertersnoozedUntil =
      const LocalDateConverter();
  static TypeConverter<LocalDate?, String?> $convertersnoozedUntiln =
      NullAwareTypeConverter.wrap($convertersnoozedUntil);
}

class ItemRow extends DataClass implements Insertable<ItemRow> {
  final String id;
  final ItemKind kind;
  final String title;
  final ItemCategory category;
  final int? amountMinor;
  final String? currency;
  final bool amountIsFixed;
  final LocalDate? scheduledOn;
  final LocalDate? dueOn;
  final int? dueMinute;
  final Recurrence recurrence;
  final String? notes;
  final String? reference;
  final ItemStatus status;
  final LocalDate? snoozedUntil;
  final int? completedAt;
  final int revision;
  final int createdAt;
  final int updatedAt;
  const ItemRow({
    required this.id,
    required this.kind,
    required this.title,
    required this.category,
    this.amountMinor,
    this.currency,
    required this.amountIsFixed,
    this.scheduledOn,
    this.dueOn,
    this.dueMinute,
    required this.recurrence,
    this.notes,
    this.reference,
    required this.status,
    this.snoozedUntil,
    this.completedAt,
    required this.revision,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['kind'] = Variable<String>($ItemsTable.$converterkind.toSql(kind));
    }
    map['title'] = Variable<String>(title);
    {
      map['category'] = Variable<String>(
        $ItemsTable.$convertercategory.toSql(category),
      );
    }
    if (!nullToAbsent || amountMinor != null) {
      map['amount_minor'] = Variable<int>(amountMinor);
    }
    if (!nullToAbsent || currency != null) {
      map['currency'] = Variable<String>(currency);
    }
    map['amount_is_fixed'] = Variable<bool>(amountIsFixed);
    if (!nullToAbsent || scheduledOn != null) {
      map['scheduled_on'] = Variable<String>(
        $ItemsTable.$converterscheduledOnn.toSql(scheduledOn),
      );
    }
    if (!nullToAbsent || dueOn != null) {
      map['due_on'] = Variable<String>(
        $ItemsTable.$converterdueOnn.toSql(dueOn),
      );
    }
    if (!nullToAbsent || dueMinute != null) {
      map['due_minute'] = Variable<int>(dueMinute);
    }
    {
      map['recurrence'] = Variable<String>(
        $ItemsTable.$converterrecurrence.toSql(recurrence),
      );
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || reference != null) {
      map['reference'] = Variable<String>(reference);
    }
    {
      map['status'] = Variable<String>(
        $ItemsTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || snoozedUntil != null) {
      map['snoozed_until'] = Variable<String>(
        $ItemsTable.$convertersnoozedUntiln.toSql(snoozedUntil),
      );
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(completedAt);
    }
    map['revision'] = Variable<int>(revision);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  ItemsCompanion toCompanion(bool nullToAbsent) {
    return ItemsCompanion(
      id: Value(id),
      kind: Value(kind),
      title: Value(title),
      category: Value(category),
      amountMinor: amountMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(amountMinor),
      currency: currency == null && nullToAbsent
          ? const Value.absent()
          : Value(currency),
      amountIsFixed: Value(amountIsFixed),
      scheduledOn: scheduledOn == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledOn),
      dueOn: dueOn == null && nullToAbsent
          ? const Value.absent()
          : Value(dueOn),
      dueMinute: dueMinute == null && nullToAbsent
          ? const Value.absent()
          : Value(dueMinute),
      recurrence: Value(recurrence),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      reference: reference == null && nullToAbsent
          ? const Value.absent()
          : Value(reference),
      status: Value(status),
      snoozedUntil: snoozedUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(snoozedUntil),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      revision: Value(revision),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemRow(
      id: serializer.fromJson<String>(json['id']),
      kind: $ItemsTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      title: serializer.fromJson<String>(json['title']),
      category: $ItemsTable.$convertercategory.fromJson(
        serializer.fromJson<String>(json['category']),
      ),
      amountMinor: serializer.fromJson<int?>(json['amountMinor']),
      currency: serializer.fromJson<String?>(json['currency']),
      amountIsFixed: serializer.fromJson<bool>(json['amountIsFixed']),
      scheduledOn: serializer.fromJson<LocalDate?>(json['scheduledOn']),
      dueOn: serializer.fromJson<LocalDate?>(json['dueOn']),
      dueMinute: serializer.fromJson<int?>(json['dueMinute']),
      recurrence: serializer.fromJson<Recurrence>(json['recurrence']),
      notes: serializer.fromJson<String?>(json['notes']),
      reference: serializer.fromJson<String?>(json['reference']),
      status: $ItemsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      snoozedUntil: serializer.fromJson<LocalDate?>(json['snoozedUntil']),
      completedAt: serializer.fromJson<int?>(json['completedAt']),
      revision: serializer.fromJson<int>(json['revision']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(
        $ItemsTable.$converterkind.toJson(kind),
      ),
      'title': serializer.toJson<String>(title),
      'category': serializer.toJson<String>(
        $ItemsTable.$convertercategory.toJson(category),
      ),
      'amountMinor': serializer.toJson<int?>(amountMinor),
      'currency': serializer.toJson<String?>(currency),
      'amountIsFixed': serializer.toJson<bool>(amountIsFixed),
      'scheduledOn': serializer.toJson<LocalDate?>(scheduledOn),
      'dueOn': serializer.toJson<LocalDate?>(dueOn),
      'dueMinute': serializer.toJson<int?>(dueMinute),
      'recurrence': serializer.toJson<Recurrence>(recurrence),
      'notes': serializer.toJson<String?>(notes),
      'reference': serializer.toJson<String?>(reference),
      'status': serializer.toJson<String>(
        $ItemsTable.$converterstatus.toJson(status),
      ),
      'snoozedUntil': serializer.toJson<LocalDate?>(snoozedUntil),
      'completedAt': serializer.toJson<int?>(completedAt),
      'revision': serializer.toJson<int>(revision),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  ItemRow copyWith({
    String? id,
    ItemKind? kind,
    String? title,
    ItemCategory? category,
    Value<int?> amountMinor = const Value.absent(),
    Value<String?> currency = const Value.absent(),
    bool? amountIsFixed,
    Value<LocalDate?> scheduledOn = const Value.absent(),
    Value<LocalDate?> dueOn = const Value.absent(),
    Value<int?> dueMinute = const Value.absent(),
    Recurrence? recurrence,
    Value<String?> notes = const Value.absent(),
    Value<String?> reference = const Value.absent(),
    ItemStatus? status,
    Value<LocalDate?> snoozedUntil = const Value.absent(),
    Value<int?> completedAt = const Value.absent(),
    int? revision,
    int? createdAt,
    int? updatedAt,
  }) => ItemRow(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    title: title ?? this.title,
    category: category ?? this.category,
    amountMinor: amountMinor.present ? amountMinor.value : this.amountMinor,
    currency: currency.present ? currency.value : this.currency,
    amountIsFixed: amountIsFixed ?? this.amountIsFixed,
    scheduledOn: scheduledOn.present ? scheduledOn.value : this.scheduledOn,
    dueOn: dueOn.present ? dueOn.value : this.dueOn,
    dueMinute: dueMinute.present ? dueMinute.value : this.dueMinute,
    recurrence: recurrence ?? this.recurrence,
    notes: notes.present ? notes.value : this.notes,
    reference: reference.present ? reference.value : this.reference,
    status: status ?? this.status,
    snoozedUntil: snoozedUntil.present ? snoozedUntil.value : this.snoozedUntil,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    revision: revision ?? this.revision,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ItemRow copyWithCompanion(ItemsCompanion data) {
    return ItemRow(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      title: data.title.present ? data.title.value : this.title,
      category: data.category.present ? data.category.value : this.category,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      amountIsFixed: data.amountIsFixed.present
          ? data.amountIsFixed.value
          : this.amountIsFixed,
      scheduledOn: data.scheduledOn.present
          ? data.scheduledOn.value
          : this.scheduledOn,
      dueOn: data.dueOn.present ? data.dueOn.value : this.dueOn,
      dueMinute: data.dueMinute.present ? data.dueMinute.value : this.dueMinute,
      recurrence: data.recurrence.present
          ? data.recurrence.value
          : this.recurrence,
      notes: data.notes.present ? data.notes.value : this.notes,
      reference: data.reference.present ? data.reference.value : this.reference,
      status: data.status.present ? data.status.value : this.status,
      snoozedUntil: data.snoozedUntil.present
          ? data.snoozedUntil.value
          : this.snoozedUntil,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      revision: data.revision.present ? data.revision.value : this.revision,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemRow(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('amountIsFixed: $amountIsFixed, ')
          ..write('scheduledOn: $scheduledOn, ')
          ..write('dueOn: $dueOn, ')
          ..write('dueMinute: $dueMinute, ')
          ..write('recurrence: $recurrence, ')
          ..write('notes: $notes, ')
          ..write('reference: $reference, ')
          ..write('status: $status, ')
          ..write('snoozedUntil: $snoozedUntil, ')
          ..write('completedAt: $completedAt, ')
          ..write('revision: $revision, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    title,
    category,
    amountMinor,
    currency,
    amountIsFixed,
    scheduledOn,
    dueOn,
    dueMinute,
    recurrence,
    notes,
    reference,
    status,
    snoozedUntil,
    completedAt,
    revision,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemRow &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.title == this.title &&
          other.category == this.category &&
          other.amountMinor == this.amountMinor &&
          other.currency == this.currency &&
          other.amountIsFixed == this.amountIsFixed &&
          other.scheduledOn == this.scheduledOn &&
          other.dueOn == this.dueOn &&
          other.dueMinute == this.dueMinute &&
          other.recurrence == this.recurrence &&
          other.notes == this.notes &&
          other.reference == this.reference &&
          other.status == this.status &&
          other.snoozedUntil == this.snoozedUntil &&
          other.completedAt == this.completedAt &&
          other.revision == this.revision &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ItemsCompanion extends UpdateCompanion<ItemRow> {
  final Value<String> id;
  final Value<ItemKind> kind;
  final Value<String> title;
  final Value<ItemCategory> category;
  final Value<int?> amountMinor;
  final Value<String?> currency;
  final Value<bool> amountIsFixed;
  final Value<LocalDate?> scheduledOn;
  final Value<LocalDate?> dueOn;
  final Value<int?> dueMinute;
  final Value<Recurrence> recurrence;
  final Value<String?> notes;
  final Value<String?> reference;
  final Value<ItemStatus> status;
  final Value<LocalDate?> snoozedUntil;
  final Value<int?> completedAt;
  final Value<int> revision;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const ItemsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.title = const Value.absent(),
    this.category = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.amountIsFixed = const Value.absent(),
    this.scheduledOn = const Value.absent(),
    this.dueOn = const Value.absent(),
    this.dueMinute = const Value.absent(),
    this.recurrence = const Value.absent(),
    this.notes = const Value.absent(),
    this.reference = const Value.absent(),
    this.status = const Value.absent(),
    this.snoozedUntil = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemsCompanion.insert({
    required String id,
    required ItemKind kind,
    required String title,
    required ItemCategory category,
    this.amountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    required bool amountIsFixed,
    this.scheduledOn = const Value.absent(),
    this.dueOn = const Value.absent(),
    this.dueMinute = const Value.absent(),
    this.recurrence = const Value.absent(),
    this.notes = const Value.absent(),
    this.reference = const Value.absent(),
    required ItemStatus status,
    this.snoozedUntil = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.revision = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       kind = Value(kind),
       title = Value(title),
       category = Value(category),
       amountIsFixed = Value(amountIsFixed),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ItemRow> custom({
    Expression<String>? id,
    Expression<String>? kind,
    Expression<String>? title,
    Expression<String>? category,
    Expression<int>? amountMinor,
    Expression<String>? currency,
    Expression<bool>? amountIsFixed,
    Expression<String>? scheduledOn,
    Expression<String>? dueOn,
    Expression<int>? dueMinute,
    Expression<String>? recurrence,
    Expression<String>? notes,
    Expression<String>? reference,
    Expression<String>? status,
    Expression<String>? snoozedUntil,
    Expression<int>? completedAt,
    Expression<int>? revision,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (title != null) 'title': title,
      if (category != null) 'category': category,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currency != null) 'currency': currency,
      if (amountIsFixed != null) 'amount_is_fixed': amountIsFixed,
      if (scheduledOn != null) 'scheduled_on': scheduledOn,
      if (dueOn != null) 'due_on': dueOn,
      if (dueMinute != null) 'due_minute': dueMinute,
      if (recurrence != null) 'recurrence': recurrence,
      if (notes != null) 'notes': notes,
      if (reference != null) 'reference': reference,
      if (status != null) 'status': status,
      if (snoozedUntil != null) 'snoozed_until': snoozedUntil,
      if (completedAt != null) 'completed_at': completedAt,
      if (revision != null) 'revision': revision,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemsCompanion copyWith({
    Value<String>? id,
    Value<ItemKind>? kind,
    Value<String>? title,
    Value<ItemCategory>? category,
    Value<int?>? amountMinor,
    Value<String?>? currency,
    Value<bool>? amountIsFixed,
    Value<LocalDate?>? scheduledOn,
    Value<LocalDate?>? dueOn,
    Value<int?>? dueMinute,
    Value<Recurrence>? recurrence,
    Value<String?>? notes,
    Value<String?>? reference,
    Value<ItemStatus>? status,
    Value<LocalDate?>? snoozedUntil,
    Value<int?>? completedAt,
    Value<int>? revision,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return ItemsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      category: category ?? this.category,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      amountIsFixed: amountIsFixed ?? this.amountIsFixed,
      scheduledOn: scheduledOn ?? this.scheduledOn,
      dueOn: dueOn ?? this.dueOn,
      dueMinute: dueMinute ?? this.dueMinute,
      recurrence: recurrence ?? this.recurrence,
      notes: notes ?? this.notes,
      reference: reference ?? this.reference,
      status: status ?? this.status,
      snoozedUntil: snoozedUntil ?? this.snoozedUntil,
      completedAt: completedAt ?? this.completedAt,
      revision: revision ?? this.revision,
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
    if (kind.present) {
      map['kind'] = Variable<String>(
        $ItemsTable.$converterkind.toSql(kind.value),
      );
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(
        $ItemsTable.$convertercategory.toSql(category.value),
      );
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (amountIsFixed.present) {
      map['amount_is_fixed'] = Variable<bool>(amountIsFixed.value);
    }
    if (scheduledOn.present) {
      map['scheduled_on'] = Variable<String>(
        $ItemsTable.$converterscheduledOnn.toSql(scheduledOn.value),
      );
    }
    if (dueOn.present) {
      map['due_on'] = Variable<String>(
        $ItemsTable.$converterdueOnn.toSql(dueOn.value),
      );
    }
    if (dueMinute.present) {
      map['due_minute'] = Variable<int>(dueMinute.value);
    }
    if (recurrence.present) {
      map['recurrence'] = Variable<String>(
        $ItemsTable.$converterrecurrence.toSql(recurrence.value),
      );
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $ItemsTable.$converterstatus.toSql(status.value),
      );
    }
    if (snoozedUntil.present) {
      map['snoozed_until'] = Variable<String>(
        $ItemsTable.$convertersnoozedUntiln.toSql(snoozedUntil.value),
      );
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('amountIsFixed: $amountIsFixed, ')
          ..write('scheduledOn: $scheduledOn, ')
          ..write('dueOn: $dueOn, ')
          ..write('dueMinute: $dueMinute, ')
          ..write('recurrence: $recurrence, ')
          ..write('notes: $notes, ')
          ..write('reference: $reference, ')
          ..write('status: $status, ')
          ..write('snoozedUntil: $snoozedUntil, ')
          ..write('completedAt: $completedAt, ')
          ..write('revision: $revision, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CompletionsTable extends Completions
    with TableInfo<$CompletionsTable, CompletionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompletionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES items (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<LocalDate, String> occurrenceOn =
      GeneratedColumn<String>(
        'occurrence_on',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LocalDate>($CompletionsTable.$converteroccurrenceOn);
  static const VerificationMeta _occurrenceMinuteMeta = const VerificationMeta(
    'occurrenceMinute',
  );
  @override
  late final GeneratedColumn<int> occurrenceMinute = GeneratedColumn<int>(
    'occurrence_minute',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CompletionOutcome, String>
  outcome = GeneratedColumn<String>(
    'outcome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<CompletionOutcome>($CompletionsTable.$converteroutcome);
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<int> recordedAt = GeneratedColumn<int>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    itemId,
    occurrenceOn,
    occurrenceMinute,
    outcome,
    amountMinor,
    currency,
    recordedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'completions';
  @override
  VerificationContext validateIntegrity(
    Insertable<CompletionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('occurrence_minute')) {
      context.handle(
        _occurrenceMinuteMeta,
        occurrenceMinute.isAcceptableOrUnknown(
          data['occurrence_minute']!,
          _occurrenceMinuteMeta,
        ),
      );
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CompletionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CompletionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      occurrenceOn: $CompletionsTable.$converteroccurrenceOn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}occurrence_on'],
        )!,
      ),
      occurrenceMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}occurrence_minute'],
      ),
      outcome: $CompletionsTable.$converteroutcome.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}outcome'],
        )!,
      ),
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      ),
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      ),
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recorded_at'],
      )!,
    );
  }

  @override
  $CompletionsTable createAlias(String alias) {
    return $CompletionsTable(attachedDatabase, alias);
  }

  static TypeConverter<LocalDate, String> $converteroccurrenceOn =
      const LocalDateConverter();
  static JsonTypeConverter2<CompletionOutcome, String, String>
  $converteroutcome = const EnumNameConverter<CompletionOutcome>(
    CompletionOutcome.values,
  );
}

class CompletionRow extends DataClass implements Insertable<CompletionRow> {
  final String id;
  final String itemId;
  final LocalDate occurrenceOn;
  final int? occurrenceMinute;
  final CompletionOutcome outcome;
  final int? amountMinor;
  final String? currency;
  final int recordedAt;
  const CompletionRow({
    required this.id,
    required this.itemId,
    required this.occurrenceOn,
    this.occurrenceMinute,
    required this.outcome,
    this.amountMinor,
    this.currency,
    required this.recordedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['item_id'] = Variable<String>(itemId);
    {
      map['occurrence_on'] = Variable<String>(
        $CompletionsTable.$converteroccurrenceOn.toSql(occurrenceOn),
      );
    }
    if (!nullToAbsent || occurrenceMinute != null) {
      map['occurrence_minute'] = Variable<int>(occurrenceMinute);
    }
    {
      map['outcome'] = Variable<String>(
        $CompletionsTable.$converteroutcome.toSql(outcome),
      );
    }
    if (!nullToAbsent || amountMinor != null) {
      map['amount_minor'] = Variable<int>(amountMinor);
    }
    if (!nullToAbsent || currency != null) {
      map['currency'] = Variable<String>(currency);
    }
    map['recorded_at'] = Variable<int>(recordedAt);
    return map;
  }

  CompletionsCompanion toCompanion(bool nullToAbsent) {
    return CompletionsCompanion(
      id: Value(id),
      itemId: Value(itemId),
      occurrenceOn: Value(occurrenceOn),
      occurrenceMinute: occurrenceMinute == null && nullToAbsent
          ? const Value.absent()
          : Value(occurrenceMinute),
      outcome: Value(outcome),
      amountMinor: amountMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(amountMinor),
      currency: currency == null && nullToAbsent
          ? const Value.absent()
          : Value(currency),
      recordedAt: Value(recordedAt),
    );
  }

  factory CompletionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CompletionRow(
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String>(json['itemId']),
      occurrenceOn: serializer.fromJson<LocalDate>(json['occurrenceOn']),
      occurrenceMinute: serializer.fromJson<int?>(json['occurrenceMinute']),
      outcome: $CompletionsTable.$converteroutcome.fromJson(
        serializer.fromJson<String>(json['outcome']),
      ),
      amountMinor: serializer.fromJson<int?>(json['amountMinor']),
      currency: serializer.fromJson<String?>(json['currency']),
      recordedAt: serializer.fromJson<int>(json['recordedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'itemId': serializer.toJson<String>(itemId),
      'occurrenceOn': serializer.toJson<LocalDate>(occurrenceOn),
      'occurrenceMinute': serializer.toJson<int?>(occurrenceMinute),
      'outcome': serializer.toJson<String>(
        $CompletionsTable.$converteroutcome.toJson(outcome),
      ),
      'amountMinor': serializer.toJson<int?>(amountMinor),
      'currency': serializer.toJson<String?>(currency),
      'recordedAt': serializer.toJson<int>(recordedAt),
    };
  }

  CompletionRow copyWith({
    String? id,
    String? itemId,
    LocalDate? occurrenceOn,
    Value<int?> occurrenceMinute = const Value.absent(),
    CompletionOutcome? outcome,
    Value<int?> amountMinor = const Value.absent(),
    Value<String?> currency = const Value.absent(),
    int? recordedAt,
  }) => CompletionRow(
    id: id ?? this.id,
    itemId: itemId ?? this.itemId,
    occurrenceOn: occurrenceOn ?? this.occurrenceOn,
    occurrenceMinute: occurrenceMinute.present
        ? occurrenceMinute.value
        : this.occurrenceMinute,
    outcome: outcome ?? this.outcome,
    amountMinor: amountMinor.present ? amountMinor.value : this.amountMinor,
    currency: currency.present ? currency.value : this.currency,
    recordedAt: recordedAt ?? this.recordedAt,
  );
  CompletionRow copyWithCompanion(CompletionsCompanion data) {
    return CompletionRow(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      occurrenceOn: data.occurrenceOn.present
          ? data.occurrenceOn.value
          : this.occurrenceOn,
      occurrenceMinute: data.occurrenceMinute.present
          ? data.occurrenceMinute.value
          : this.occurrenceMinute,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CompletionRow(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('occurrenceOn: $occurrenceOn, ')
          ..write('occurrenceMinute: $occurrenceMinute, ')
          ..write('outcome: $outcome, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('recordedAt: $recordedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    itemId,
    occurrenceOn,
    occurrenceMinute,
    outcome,
    amountMinor,
    currency,
    recordedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompletionRow &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.occurrenceOn == this.occurrenceOn &&
          other.occurrenceMinute == this.occurrenceMinute &&
          other.outcome == this.outcome &&
          other.amountMinor == this.amountMinor &&
          other.currency == this.currency &&
          other.recordedAt == this.recordedAt);
}

class CompletionsCompanion extends UpdateCompanion<CompletionRow> {
  final Value<String> id;
  final Value<String> itemId;
  final Value<LocalDate> occurrenceOn;
  final Value<int?> occurrenceMinute;
  final Value<CompletionOutcome> outcome;
  final Value<int?> amountMinor;
  final Value<String?> currency;
  final Value<int> recordedAt;
  final Value<int> rowid;
  const CompletionsCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.occurrenceOn = const Value.absent(),
    this.occurrenceMinute = const Value.absent(),
    this.outcome = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CompletionsCompanion.insert({
    required String id,
    required String itemId,
    required LocalDate occurrenceOn,
    this.occurrenceMinute = const Value.absent(),
    required CompletionOutcome outcome,
    this.amountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    required int recordedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       itemId = Value(itemId),
       occurrenceOn = Value(occurrenceOn),
       outcome = Value(outcome),
       recordedAt = Value(recordedAt);
  static Insertable<CompletionRow> custom({
    Expression<String>? id,
    Expression<String>? itemId,
    Expression<String>? occurrenceOn,
    Expression<int>? occurrenceMinute,
    Expression<String>? outcome,
    Expression<int>? amountMinor,
    Expression<String>? currency,
    Expression<int>? recordedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (occurrenceOn != null) 'occurrence_on': occurrenceOn,
      if (occurrenceMinute != null) 'occurrence_minute': occurrenceMinute,
      if (outcome != null) 'outcome': outcome,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currency != null) 'currency': currency,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CompletionsCompanion copyWith({
    Value<String>? id,
    Value<String>? itemId,
    Value<LocalDate>? occurrenceOn,
    Value<int?>? occurrenceMinute,
    Value<CompletionOutcome>? outcome,
    Value<int?>? amountMinor,
    Value<String?>? currency,
    Value<int>? recordedAt,
    Value<int>? rowid,
  }) {
    return CompletionsCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      occurrenceOn: occurrenceOn ?? this.occurrenceOn,
      occurrenceMinute: occurrenceMinute ?? this.occurrenceMinute,
      outcome: outcome ?? this.outcome,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      recordedAt: recordedAt ?? this.recordedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (occurrenceOn.present) {
      map['occurrence_on'] = Variable<String>(
        $CompletionsTable.$converteroccurrenceOn.toSql(occurrenceOn.value),
      );
    }
    if (occurrenceMinute.present) {
      map['occurrence_minute'] = Variable<int>(occurrenceMinute.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(
        $CompletionsTable.$converteroutcome.toSql(outcome.value),
      );
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<int>(recordedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompletionsCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('occurrenceOn: $occurrenceOn, ')
          ..write('occurrenceMinute: $occurrenceMinute, ')
          ..write('outcome: $outcome, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsEntriesTable extends SettingsEntries
    with TableInfo<$SettingsEntriesTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsEntriesTable(this.attachedDatabase, [this._alias]);
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
  $SettingsEntriesTable createAlias(String alias) {
    return $SettingsEntriesTable(attachedDatabase, alias);
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

  SettingsEntriesCompanion toCompanion(bool nullToAbsent) {
    return SettingsEntriesCompanion(key: Value(key), value: Value(value));
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
  SettingRow copyWithCompanion(SettingsEntriesCompanion data) {
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

class SettingsEntriesCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsEntriesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsEntriesCompanion.insert({
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

  SettingsEntriesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsEntriesCompanion(
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
    return (StringBuffer('SettingsEntriesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$VaultDatabase extends GeneratedDatabase {
  _$VaultDatabase(QueryExecutor e) : super(e);
  $VaultDatabaseManager get managers => $VaultDatabaseManager(this);
  late final $ItemsTable items = $ItemsTable(this);
  late final $CompletionsTable completions = $CompletionsTable(this);
  late final $SettingsEntriesTable settingsEntries = $SettingsEntriesTable(
    this,
  );
  late final Index itemsStatusDue = Index(
    'items_status_due',
    'CREATE INDEX items_status_due ON items (status, due_on)',
  );
  late final Index completionsOccurrence = Index(
    'completions_occurrence',
    'CREATE UNIQUE INDEX completions_occurrence ON completions (item_id, occurrence_on, coalesce(occurrence_minute, -1))',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    items,
    completions,
    settingsEntries,
    itemsStatusDue,
    completionsOccurrence,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('completions', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ItemsTableCreateCompanionBuilder = ItemsCompanion Function({
  required String id,
  required ItemKind kind,
  required String title,
  required ItemCategory category,
  Value<int?> amountMinor,
  Value<String?> currency,
  required bool amountIsFixed,
  Value<LocalDate?> scheduledOn,
  Value<LocalDate?> dueOn,
  Value<int?> dueMinute,
  Value<Recurrence> recurrence,
  Value<String?> notes,
  Value<String?> reference,
  required ItemStatus status,
  Value<LocalDate?> snoozedUntil,
  Value<int?> completedAt,
  Value<int> revision,
  required int createdAt,
  required int updatedAt,
  Value<int> rowid,
});
typedef $$ItemsTableUpdateCompanionBuilder = ItemsCompanion Function({
  Value<String> id,
  Value<ItemKind> kind,
  Value<String> title,
  Value<ItemCategory> category,
  Value<int?> amountMinor,
  Value<String?> currency,
  Value<bool> amountIsFixed,
  Value<LocalDate?> scheduledOn,
  Value<LocalDate?> dueOn,
  Value<int?> dueMinute,
  Value<Recurrence> recurrence,
  Value<String?> notes,
  Value<String?> reference,
  Value<ItemStatus> status,
  Value<LocalDate?> snoozedUntil,
  Value<int?> completedAt,
  Value<int> revision,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int> rowid,
});

final class $$ItemsTableReferences
    extends BaseReferences<_$VaultDatabase, $ItemsTable, ItemRow> {
  $$ItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CompletionsTable, List<CompletionRow>>
  _completionsRefsTable(_$VaultDatabase db) => MultiTypedResultKey.fromTable(
    db.completions,
    aliasName: 'items__id__completions__item_id',
  );

  $$CompletionsTableProcessedTableManager get completionsRefs {
    final manager = $$CompletionsTableTableManager(
      $_db,
      $_db.completions,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_completionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ItemsTableFilterComposer
    extends Composer<_$VaultDatabase, $ItemsTable> {
  $$ItemsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<ItemKind, ItemKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ItemCategory, ItemCategory, String>
  get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get amountIsFixed => $composableBuilder(
    column: $table.amountIsFixed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LocalDate?, LocalDate, String>
  get scheduledOn => $composableBuilder(
    column: $table.scheduledOn,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<LocalDate?, LocalDate, String> get dueOn =>
      $composableBuilder(
        column: $table.dueOn,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get dueMinute => $composableBuilder(
    column: $table.dueMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Recurrence, Recurrence, String>
  get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ItemStatus, ItemStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<LocalDate?, LocalDate, String>
  get snoozedUntil => $composableBuilder(
    column: $table.snoozedUntil,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> completionsRefs(
    Expression<bool> Function($$CompletionsTableFilterComposer f) f,
  ) {
    final $$CompletionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.completions,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompletionsTableFilterComposer(
            $db: $db,
            $table: $db.completions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ItemsTableOrderingComposer
    extends Composer<_$VaultDatabase, $ItemsTable> {
  $$ItemsTableOrderingComposer({
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

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get amountIsFixed => $composableBuilder(
    column: $table.amountIsFixed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduledOn => $composableBuilder(
    column: $table.scheduledOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dueOn => $composableBuilder(
    column: $table.dueOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dueMinute => $composableBuilder(
    column: $table.dueMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get snoozedUntil => $composableBuilder(
    column: $table.snoozedUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ItemsTableAnnotationComposer
    extends Composer<_$VaultDatabase, $ItemsTable> {
  $$ItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ItemKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ItemCategory, String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<bool> get amountIsFixed => $composableBuilder(
    column: $table.amountIsFixed,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<LocalDate?, String> get scheduledOn =>
      $composableBuilder(
        column: $table.scheduledOn,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<LocalDate?, String> get dueOn =>
      $composableBuilder(column: $table.dueOn, builder: (column) => column);

  GeneratedColumn<int> get dueMinute =>
      $composableBuilder(column: $table.dueMinute, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Recurrence, String> get recurrence =>
      $composableBuilder(
        column: $table.recurrence,
        builder: (column) => column,
      );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ItemStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LocalDate?, String> get snoozedUntil =>
      $composableBuilder(
        column: $table.snoozedUntil,
        builder: (column) => column,
      );

  GeneratedColumn<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> completionsRefs<T extends Object>(
    Expression<T> Function($$CompletionsTableAnnotationComposer a) f,
  ) {
    final $$CompletionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.completions,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompletionsTableAnnotationComposer(
            $db: $db,
            $table: $db.completions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ItemsTableTableManager
    extends
        RootTableManager<
          _$VaultDatabase,
          $ItemsTable,
          ItemRow,
          $$ItemsTableFilterComposer,
          $$ItemsTableOrderingComposer,
          $$ItemsTableAnnotationComposer,
          $$ItemsTableCreateCompanionBuilder,
          $$ItemsTableUpdateCompanionBuilder,
          (ItemRow, $$ItemsTableReferences),
          ItemRow,
          PrefetchHooks Function({bool completionsRefs})
        > {
  $$ItemsTableTableManager(_$VaultDatabase db, $ItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<ItemKind> kind = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<ItemCategory> category = const Value.absent(),
                Value<int?> amountMinor = const Value.absent(),
                Value<String?> currency = const Value.absent(),
                Value<bool> amountIsFixed = const Value.absent(),
                Value<LocalDate?> scheduledOn = const Value.absent(),
                Value<LocalDate?> dueOn = const Value.absent(),
                Value<int?> dueMinute = const Value.absent(),
                Value<Recurrence> recurrence = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> reference = const Value.absent(),
                Value<ItemStatus> status = const Value.absent(),
                Value<LocalDate?> snoozedUntil = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemsCompanion(
                id: id,
                kind: kind,
                title: title,
                category: category,
                amountMinor: amountMinor,
                currency: currency,
                amountIsFixed: amountIsFixed,
                scheduledOn: scheduledOn,
                dueOn: dueOn,
                dueMinute: dueMinute,
                recurrence: recurrence,
                notes: notes,
                reference: reference,
                status: status,
                snoozedUntil: snoozedUntil,
                completedAt: completedAt,
                revision: revision,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required ItemKind kind,
                required String title,
                required ItemCategory category,
                Value<int?> amountMinor = const Value.absent(),
                Value<String?> currency = const Value.absent(),
                required bool amountIsFixed,
                Value<LocalDate?> scheduledOn = const Value.absent(),
                Value<LocalDate?> dueOn = const Value.absent(),
                Value<int?> dueMinute = const Value.absent(),
                Value<Recurrence> recurrence = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> reference = const Value.absent(),
                required ItemStatus status,
                Value<LocalDate?> snoozedUntil = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<int> revision = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ItemsCompanion.insert(
                id: id,
                kind: kind,
                title: title,
                category: category,
                amountMinor: amountMinor,
                currency: currency,
                amountIsFixed: amountIsFixed,
                scheduledOn: scheduledOn,
                dueOn: dueOn,
                dueMinute: dueMinute,
                recurrence: recurrence,
                notes: notes,
                reference: reference,
                status: status,
                snoozedUntil: snoozedUntil,
                completedAt: completedAt,
                revision: revision,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ItemsTable, ItemRow>(table),
                  $$ItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({completionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (completionsRefs) db.completions],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (completionsRefs)
                    await $_getPrefetchedDataByColumns<
                      ItemRow,
                      $ItemsTable,
                      CompletionRow,
                      $CompletionsTable
                    >(
                      currentTable: table,
                      referencedTable: $$ItemsTableReferences
                          ._completionsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ItemsTableReferences(db, table, p0).completionsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'item_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$VaultDatabase,
      $ItemsTable,
      ItemRow,
      $$ItemsTableFilterComposer,
      $$ItemsTableOrderingComposer,
      $$ItemsTableAnnotationComposer,
      $$ItemsTableCreateCompanionBuilder,
      $$ItemsTableUpdateCompanionBuilder,
      (ItemRow, $$ItemsTableReferences),
      ItemRow,
      PrefetchHooks Function({bool completionsRefs})
    >;
typedef $$CompletionsTableCreateCompanionBuilder =
    CompletionsCompanion Function({
      required String id,
      required String itemId,
      required LocalDate occurrenceOn,
      Value<int?> occurrenceMinute,
      required CompletionOutcome outcome,
      Value<int?> amountMinor,
      Value<String?> currency,
      required int recordedAt,
      Value<int> rowid,
    });
typedef $$CompletionsTableUpdateCompanionBuilder =
    CompletionsCompanion Function({
      Value<String> id,
      Value<String> itemId,
      Value<LocalDate> occurrenceOn,
      Value<int?> occurrenceMinute,
      Value<CompletionOutcome> outcome,
      Value<int?> amountMinor,
      Value<String?> currency,
      Value<int> recordedAt,
      Value<int> rowid,
    });

final class $$CompletionsTableReferences
    extends BaseReferences<_$VaultDatabase, $CompletionsTable, CompletionRow> {
  $$CompletionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ItemsTable _itemIdTable(_$VaultDatabase db) =>
      db.items.createAlias('completions__item_id__items__id');

  $$ItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<String>('item_id')!;

    final manager = $$ItemsTableTableManager(
      $_db,
      $_db.items,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CompletionsTableFilterComposer
    extends Composer<_$VaultDatabase, $CompletionsTable> {
  $$CompletionsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<LocalDate, LocalDate, String>
  get occurrenceOn => $composableBuilder(
    column: $table.occurrenceOn,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get occurrenceMinute => $composableBuilder(
    column: $table.occurrenceMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CompletionOutcome, CompletionOutcome, String>
  get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ItemsTableFilterComposer get itemId {
    final $$ItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableFilterComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompletionsTableOrderingComposer
    extends Composer<_$VaultDatabase, $CompletionsTable> {
  $$CompletionsTableOrderingComposer({
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

  ColumnOrderings<String> get occurrenceOn => $composableBuilder(
    column: $table.occurrenceOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get occurrenceMinute => $composableBuilder(
    column: $table.occurrenceMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ItemsTableOrderingComposer get itemId {
    final $$ItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableOrderingComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompletionsTableAnnotationComposer
    extends Composer<_$VaultDatabase, $CompletionsTable> {
  $$CompletionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LocalDate, String> get occurrenceOn =>
      $composableBuilder(
        column: $table.occurrenceOn,
        builder: (column) => column,
      );

  GeneratedColumn<int> get occurrenceMinute => $composableBuilder(
    column: $table.occurrenceMinute,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<CompletionOutcome, String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<int> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );

  $$ItemsTableAnnotationComposer get itemId {
    final $$ItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompletionsTableTableManager
    extends
        RootTableManager<
          _$VaultDatabase,
          $CompletionsTable,
          CompletionRow,
          $$CompletionsTableFilterComposer,
          $$CompletionsTableOrderingComposer,
          $$CompletionsTableAnnotationComposer,
          $$CompletionsTableCreateCompanionBuilder,
          $$CompletionsTableUpdateCompanionBuilder,
          (CompletionRow, $$CompletionsTableReferences),
          CompletionRow,
          PrefetchHooks Function({bool itemId})
        > {
  $$CompletionsTableTableManager(_$VaultDatabase db, $CompletionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompletionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompletionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompletionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<LocalDate> occurrenceOn = const Value.absent(),
                Value<int?> occurrenceMinute = const Value.absent(),
                Value<CompletionOutcome> outcome = const Value.absent(),
                Value<int?> amountMinor = const Value.absent(),
                Value<String?> currency = const Value.absent(),
                Value<int> recordedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompletionsCompanion(
                id: id,
                itemId: itemId,
                occurrenceOn: occurrenceOn,
                occurrenceMinute: occurrenceMinute,
                outcome: outcome,
                amountMinor: amountMinor,
                currency: currency,
                recordedAt: recordedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String itemId,
                required LocalDate occurrenceOn,
                Value<int?> occurrenceMinute = const Value.absent(),
                required CompletionOutcome outcome,
                Value<int?> amountMinor = const Value.absent(),
                Value<String?> currency = const Value.absent(),
                required int recordedAt,
                Value<int> rowid = const Value.absent(),
              }) => CompletionsCompanion.insert(
                id: id,
                itemId: itemId,
                occurrenceOn: occurrenceOn,
                occurrenceMinute: occurrenceMinute,
                outcome: outcome,
                amountMinor: amountMinor,
                currency: currency,
                recordedAt: recordedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CompletionsTable, CompletionRow>(table),
                  $$CompletionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({itemId = false}) {
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
                    if (itemId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.itemId,
                        referencedTable: $$CompletionsTableReferences
                            ._itemIdTable(db),
                        referencedColumn: $$CompletionsTableReferences
                            ._itemIdTable(db)
                            .id,
                      ) as T;
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

typedef $$CompletionsTableProcessedTableManager =
    ProcessedTableManager<
      _$VaultDatabase,
      $CompletionsTable,
      CompletionRow,
      $$CompletionsTableFilterComposer,
      $$CompletionsTableOrderingComposer,
      $$CompletionsTableAnnotationComposer,
      $$CompletionsTableCreateCompanionBuilder,
      $$CompletionsTableUpdateCompanionBuilder,
      (CompletionRow, $$CompletionsTableReferences),
      CompletionRow,
      PrefetchHooks Function({bool itemId})
    >;
typedef $$SettingsEntriesTableCreateCompanionBuilder =
    SettingsEntriesCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SettingsEntriesTableUpdateCompanionBuilder =
    SettingsEntriesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SettingsEntriesTableFilterComposer
    extends Composer<_$VaultDatabase, $SettingsEntriesTable> {
  $$SettingsEntriesTableFilterComposer({
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

class $$SettingsEntriesTableOrderingComposer
    extends Composer<_$VaultDatabase, $SettingsEntriesTable> {
  $$SettingsEntriesTableOrderingComposer({
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

class $$SettingsEntriesTableAnnotationComposer
    extends Composer<_$VaultDatabase, $SettingsEntriesTable> {
  $$SettingsEntriesTableAnnotationComposer({
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

class $$SettingsEntriesTableTableManager
    extends
        RootTableManager<
          _$VaultDatabase,
          $SettingsEntriesTable,
          SettingRow,
          $$SettingsEntriesTableFilterComposer,
          $$SettingsEntriesTableOrderingComposer,
          $$SettingsEntriesTableAnnotationComposer,
          $$SettingsEntriesTableCreateCompanionBuilder,
          $$SettingsEntriesTableUpdateCompanionBuilder,
          (
            SettingRow,
            BaseReferences<_$VaultDatabase, $SettingsEntriesTable, SettingRow>,
          ),
          SettingRow,
          PrefetchHooks Function()
        > {
  $$SettingsEntriesTableTableManager(
    _$VaultDatabase db,
    $SettingsEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsEntriesCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SettingsEntriesCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsEntriesTable, SettingRow>(table),
                  BaseReferences<
                    _$VaultDatabase,
                    $SettingsEntriesTable,
                    SettingRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$VaultDatabase,
      $SettingsEntriesTable,
      SettingRow,
      $$SettingsEntriesTableFilterComposer,
      $$SettingsEntriesTableOrderingComposer,
      $$SettingsEntriesTableAnnotationComposer,
      $$SettingsEntriesTableCreateCompanionBuilder,
      $$SettingsEntriesTableUpdateCompanionBuilder,
      (
        SettingRow,
        BaseReferences<_$VaultDatabase, $SettingsEntriesTable, SettingRow>,
      ),
      SettingRow,
      PrefetchHooks Function()
    >;

class $VaultDatabaseManager {
  final _$VaultDatabase _db;
  $VaultDatabaseManager(this._db);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db, _db.items);
  $$CompletionsTableTableManager get completions =>
      $$CompletionsTableTableManager(_db, _db.completions);
  $$SettingsEntriesTableTableManager get settingsEntries =>
      $$SettingsEntriesTableTableManager(_db, _db.settingsEntries);
}
