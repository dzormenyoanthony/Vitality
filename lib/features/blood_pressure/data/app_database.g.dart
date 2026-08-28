// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ReadingsTable extends Readings with TableInfo<$ReadingsTable, Reading> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _systolicMeta = const VerificationMeta(
    'systolic',
  );
  @override
  late final GeneratedColumn<int> systolic = GeneratedColumn<int>(
    'systolic',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _diastolicMeta = const VerificationMeta(
    'diastolic',
  );
  @override
  late final GeneratedColumn<int> diastolic = GeneratedColumn<int>(
    'diastolic',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pulseMeta = const VerificationMeta('pulse');
  @override
  late final GeneratedColumn<int> pulse = GeneratedColumn<int>(
    'pulse',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
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
  static const VerificationMeta _measurementContextMeta =
      const VerificationMeta('measurementContext');
  @override
  late final GeneratedColumn<String> measurementContext =
      GeneratedColumn<String>(
        'measurement_context',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _measurementContextsMeta =
      const VerificationMeta('measurementContexts');
  @override
  late final GeneratedColumn<String> measurementContexts =
      GeneratedColumn<String>(
        'measurement_contexts',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _bodyPositionMeta = const VerificationMeta(
    'bodyPosition',
  );
  @override
  late final GeneratedColumn<String> bodyPosition = GeneratedColumn<String>(
    'body_position',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cuffArmMeta = const VerificationMeta(
    'cuffArm',
  );
  @override
  late final GeneratedColumn<String> cuffArm = GeneratedColumn<String>(
    'cuff_arm',
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
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _sourceReportIdMeta = const VerificationMeta(
    'sourceReportId',
  );
  @override
  late final GeneratedColumn<int> sourceReportId = GeneratedColumn<int>(
    'source_report_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
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
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    systolic,
    diastolic,
    pulse,
    timestamp,
    notes,
    measurementContext,
    measurementContexts,
    bodyPosition,
    cuffArm,
    source,
    sourceReportId,
    createdAt,
    updatedAt,
    remoteId,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'readings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Reading> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('systolic')) {
      context.handle(
        _systolicMeta,
        systolic.isAcceptableOrUnknown(data['systolic']!, _systolicMeta),
      );
    } else if (isInserting) {
      context.missing(_systolicMeta);
    }
    if (data.containsKey('diastolic')) {
      context.handle(
        _diastolicMeta,
        diastolic.isAcceptableOrUnknown(data['diastolic']!, _diastolicMeta),
      );
    } else if (isInserting) {
      context.missing(_diastolicMeta);
    }
    if (data.containsKey('pulse')) {
      context.handle(
        _pulseMeta,
        pulse.isAcceptableOrUnknown(data['pulse']!, _pulseMeta),
      );
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('measurement_context')) {
      context.handle(
        _measurementContextMeta,
        measurementContext.isAcceptableOrUnknown(
          data['measurement_context']!,
          _measurementContextMeta,
        ),
      );
    }
    if (data.containsKey('measurement_contexts')) {
      context.handle(
        _measurementContextsMeta,
        measurementContexts.isAcceptableOrUnknown(
          data['measurement_contexts']!,
          _measurementContextsMeta,
        ),
      );
    }
    if (data.containsKey('body_position')) {
      context.handle(
        _bodyPositionMeta,
        bodyPosition.isAcceptableOrUnknown(
          data['body_position']!,
          _bodyPositionMeta,
        ),
      );
    }
    if (data.containsKey('cuff_arm')) {
      context.handle(
        _cuffArmMeta,
        cuffArm.isAcceptableOrUnknown(data['cuff_arm']!, _cuffArmMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('source_report_id')) {
      context.handle(
        _sourceReportIdMeta,
        sourceReportId.isAcceptableOrUnknown(
          data['source_report_id']!,
          _sourceReportIdMeta,
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
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
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
  Reading map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reading(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      systolic: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}systolic'],
      )!,
      diastolic: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}diastolic'],
      )!,
      pulse: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pulse'],
      ),
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      measurementContext: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}measurement_context'],
      ),
      measurementContexts: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}measurement_contexts'],
      ),
      bodyPosition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body_position'],
      ),
      cuffArm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cuff_arm'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      sourceReportId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_report_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $ReadingsTable createAlias(String alias) {
    return $ReadingsTable(attachedDatabase, alias);
  }
}

class Reading extends DataClass implements Insertable<Reading> {
  final int id;
  final int systolic;
  final int diastolic;
  final int? pulse;
  final DateTime timestamp;
  final String? notes;

  /// Deprecated single-value column, kept only so v3 data survives the
  /// migration to [measurementContexts] below — no longer written to.
  final String? measurementContext;

  /// Comma-separated [MeasurementContext] names — same lightweight
  /// approach as [Reminders.daysOfWeek] rather than a join table, since
  /// this is just a small set of tags.
  final String? measurementContexts;
  final String? bodyPosition;
  final String? cuffArm;

  /// [ReadingSource] name — 'manual' (default) or 'importedReport'
  /// (PROJECT_SPEC.md §12, §33).
  final String source;

  /// The originating [SavedReports.id], set only when [source] is
  /// 'importedReport'.
  final int? sourceReportId;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// The Firestore document id once this row has been synced
  /// (PROJECT_SPEC.md §21-22) — `null` until the first successful push.
  final String? remoteId;

  /// Soft-delete marker: set instead of a hard SQL delete so the sync
  /// layer can propagate the deletion to Firestore before the local row
  /// is actually removed. Rows with this set are filtered out of every
  /// read query.
  final DateTime? deletedAt;
  const Reading({
    required this.id,
    required this.systolic,
    required this.diastolic,
    this.pulse,
    required this.timestamp,
    this.notes,
    this.measurementContext,
    this.measurementContexts,
    this.bodyPosition,
    this.cuffArm,
    required this.source,
    this.sourceReportId,
    required this.createdAt,
    required this.updatedAt,
    this.remoteId,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['systolic'] = Variable<int>(systolic);
    map['diastolic'] = Variable<int>(diastolic);
    if (!nullToAbsent || pulse != null) {
      map['pulse'] = Variable<int>(pulse);
    }
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || measurementContext != null) {
      map['measurement_context'] = Variable<String>(measurementContext);
    }
    if (!nullToAbsent || measurementContexts != null) {
      map['measurement_contexts'] = Variable<String>(measurementContexts);
    }
    if (!nullToAbsent || bodyPosition != null) {
      map['body_position'] = Variable<String>(bodyPosition);
    }
    if (!nullToAbsent || cuffArm != null) {
      map['cuff_arm'] = Variable<String>(cuffArm);
    }
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || sourceReportId != null) {
      map['source_report_id'] = Variable<int>(sourceReportId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  ReadingsCompanion toCompanion(bool nullToAbsent) {
    return ReadingsCompanion(
      id: Value(id),
      systolic: Value(systolic),
      diastolic: Value(diastolic),
      pulse: pulse == null && nullToAbsent
          ? const Value.absent()
          : Value(pulse),
      timestamp: Value(timestamp),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      measurementContext: measurementContext == null && nullToAbsent
          ? const Value.absent()
          : Value(measurementContext),
      measurementContexts: measurementContexts == null && nullToAbsent
          ? const Value.absent()
          : Value(measurementContexts),
      bodyPosition: bodyPosition == null && nullToAbsent
          ? const Value.absent()
          : Value(bodyPosition),
      cuffArm: cuffArm == null && nullToAbsent
          ? const Value.absent()
          : Value(cuffArm),
      source: Value(source),
      sourceReportId: sourceReportId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceReportId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Reading.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reading(
      id: serializer.fromJson<int>(json['id']),
      systolic: serializer.fromJson<int>(json['systolic']),
      diastolic: serializer.fromJson<int>(json['diastolic']),
      pulse: serializer.fromJson<int?>(json['pulse']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      notes: serializer.fromJson<String?>(json['notes']),
      measurementContext: serializer.fromJson<String?>(
        json['measurementContext'],
      ),
      measurementContexts: serializer.fromJson<String?>(
        json['measurementContexts'],
      ),
      bodyPosition: serializer.fromJson<String?>(json['bodyPosition']),
      cuffArm: serializer.fromJson<String?>(json['cuffArm']),
      source: serializer.fromJson<String>(json['source']),
      sourceReportId: serializer.fromJson<int?>(json['sourceReportId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'systolic': serializer.toJson<int>(systolic),
      'diastolic': serializer.toJson<int>(diastolic),
      'pulse': serializer.toJson<int?>(pulse),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'notes': serializer.toJson<String?>(notes),
      'measurementContext': serializer.toJson<String?>(measurementContext),
      'measurementContexts': serializer.toJson<String?>(measurementContexts),
      'bodyPosition': serializer.toJson<String?>(bodyPosition),
      'cuffArm': serializer.toJson<String?>(cuffArm),
      'source': serializer.toJson<String>(source),
      'sourceReportId': serializer.toJson<int?>(sourceReportId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'remoteId': serializer.toJson<String?>(remoteId),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Reading copyWith({
    int? id,
    int? systolic,
    int? diastolic,
    Value<int?> pulse = const Value.absent(),
    DateTime? timestamp,
    Value<String?> notes = const Value.absent(),
    Value<String?> measurementContext = const Value.absent(),
    Value<String?> measurementContexts = const Value.absent(),
    Value<String?> bodyPosition = const Value.absent(),
    Value<String?> cuffArm = const Value.absent(),
    String? source,
    Value<int?> sourceReportId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<String?> remoteId = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Reading(
    id: id ?? this.id,
    systolic: systolic ?? this.systolic,
    diastolic: diastolic ?? this.diastolic,
    pulse: pulse.present ? pulse.value : this.pulse,
    timestamp: timestamp ?? this.timestamp,
    notes: notes.present ? notes.value : this.notes,
    measurementContext: measurementContext.present
        ? measurementContext.value
        : this.measurementContext,
    measurementContexts: measurementContexts.present
        ? measurementContexts.value
        : this.measurementContexts,
    bodyPosition: bodyPosition.present ? bodyPosition.value : this.bodyPosition,
    cuffArm: cuffArm.present ? cuffArm.value : this.cuffArm,
    source: source ?? this.source,
    sourceReportId: sourceReportId.present
        ? sourceReportId.value
        : this.sourceReportId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Reading copyWithCompanion(ReadingsCompanion data) {
    return Reading(
      id: data.id.present ? data.id.value : this.id,
      systolic: data.systolic.present ? data.systolic.value : this.systolic,
      diastolic: data.diastolic.present ? data.diastolic.value : this.diastolic,
      pulse: data.pulse.present ? data.pulse.value : this.pulse,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      notes: data.notes.present ? data.notes.value : this.notes,
      measurementContext: data.measurementContext.present
          ? data.measurementContext.value
          : this.measurementContext,
      measurementContexts: data.measurementContexts.present
          ? data.measurementContexts.value
          : this.measurementContexts,
      bodyPosition: data.bodyPosition.present
          ? data.bodyPosition.value
          : this.bodyPosition,
      cuffArm: data.cuffArm.present ? data.cuffArm.value : this.cuffArm,
      source: data.source.present ? data.source.value : this.source,
      sourceReportId: data.sourceReportId.present
          ? data.sourceReportId.value
          : this.sourceReportId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Reading(')
          ..write('id: $id, ')
          ..write('systolic: $systolic, ')
          ..write('diastolic: $diastolic, ')
          ..write('pulse: $pulse, ')
          ..write('timestamp: $timestamp, ')
          ..write('notes: $notes, ')
          ..write('measurementContext: $measurementContext, ')
          ..write('measurementContexts: $measurementContexts, ')
          ..write('bodyPosition: $bodyPosition, ')
          ..write('cuffArm: $cuffArm, ')
          ..write('source: $source, ')
          ..write('sourceReportId: $sourceReportId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('remoteId: $remoteId, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    systolic,
    diastolic,
    pulse,
    timestamp,
    notes,
    measurementContext,
    measurementContexts,
    bodyPosition,
    cuffArm,
    source,
    sourceReportId,
    createdAt,
    updatedAt,
    remoteId,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reading &&
          other.id == this.id &&
          other.systolic == this.systolic &&
          other.diastolic == this.diastolic &&
          other.pulse == this.pulse &&
          other.timestamp == this.timestamp &&
          other.notes == this.notes &&
          other.measurementContext == this.measurementContext &&
          other.measurementContexts == this.measurementContexts &&
          other.bodyPosition == this.bodyPosition &&
          other.cuffArm == this.cuffArm &&
          other.source == this.source &&
          other.sourceReportId == this.sourceReportId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.remoteId == this.remoteId &&
          other.deletedAt == this.deletedAt);
}

class ReadingsCompanion extends UpdateCompanion<Reading> {
  final Value<int> id;
  final Value<int> systolic;
  final Value<int> diastolic;
  final Value<int?> pulse;
  final Value<DateTime> timestamp;
  final Value<String?> notes;
  final Value<String?> measurementContext;
  final Value<String?> measurementContexts;
  final Value<String?> bodyPosition;
  final Value<String?> cuffArm;
  final Value<String> source;
  final Value<int?> sourceReportId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String?> remoteId;
  final Value<DateTime?> deletedAt;
  const ReadingsCompanion({
    this.id = const Value.absent(),
    this.systolic = const Value.absent(),
    this.diastolic = const Value.absent(),
    this.pulse = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.notes = const Value.absent(),
    this.measurementContext = const Value.absent(),
    this.measurementContexts = const Value.absent(),
    this.bodyPosition = const Value.absent(),
    this.cuffArm = const Value.absent(),
    this.source = const Value.absent(),
    this.sourceReportId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  ReadingsCompanion.insert({
    this.id = const Value.absent(),
    required int systolic,
    required int diastolic,
    this.pulse = const Value.absent(),
    required DateTime timestamp,
    this.notes = const Value.absent(),
    this.measurementContext = const Value.absent(),
    this.measurementContexts = const Value.absent(),
    this.bodyPosition = const Value.absent(),
    this.cuffArm = const Value.absent(),
    this.source = const Value.absent(),
    this.sourceReportId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.remoteId = const Value.absent(),
    this.deletedAt = const Value.absent(),
  }) : systolic = Value(systolic),
       diastolic = Value(diastolic),
       timestamp = Value(timestamp),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Reading> custom({
    Expression<int>? id,
    Expression<int>? systolic,
    Expression<int>? diastolic,
    Expression<int>? pulse,
    Expression<DateTime>? timestamp,
    Expression<String>? notes,
    Expression<String>? measurementContext,
    Expression<String>? measurementContexts,
    Expression<String>? bodyPosition,
    Expression<String>? cuffArm,
    Expression<String>? source,
    Expression<int>? sourceReportId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? remoteId,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (systolic != null) 'systolic': systolic,
      if (diastolic != null) 'diastolic': diastolic,
      if (pulse != null) 'pulse': pulse,
      if (timestamp != null) 'timestamp': timestamp,
      if (notes != null) 'notes': notes,
      if (measurementContext != null) 'measurement_context': measurementContext,
      if (measurementContexts != null)
        'measurement_contexts': measurementContexts,
      if (bodyPosition != null) 'body_position': bodyPosition,
      if (cuffArm != null) 'cuff_arm': cuffArm,
      if (source != null) 'source': source,
      if (sourceReportId != null) 'source_report_id': sourceReportId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (remoteId != null) 'remote_id': remoteId,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  ReadingsCompanion copyWith({
    Value<int>? id,
    Value<int>? systolic,
    Value<int>? diastolic,
    Value<int?>? pulse,
    Value<DateTime>? timestamp,
    Value<String?>? notes,
    Value<String?>? measurementContext,
    Value<String?>? measurementContexts,
    Value<String?>? bodyPosition,
    Value<String?>? cuffArm,
    Value<String>? source,
    Value<int?>? sourceReportId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String?>? remoteId,
    Value<DateTime?>? deletedAt,
  }) {
    return ReadingsCompanion(
      id: id ?? this.id,
      systolic: systolic ?? this.systolic,
      diastolic: diastolic ?? this.diastolic,
      pulse: pulse ?? this.pulse,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
      measurementContext: measurementContext ?? this.measurementContext,
      measurementContexts: measurementContexts ?? this.measurementContexts,
      bodyPosition: bodyPosition ?? this.bodyPosition,
      cuffArm: cuffArm ?? this.cuffArm,
      source: source ?? this.source,
      sourceReportId: sourceReportId ?? this.sourceReportId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      remoteId: remoteId ?? this.remoteId,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (systolic.present) {
      map['systolic'] = Variable<int>(systolic.value);
    }
    if (diastolic.present) {
      map['diastolic'] = Variable<int>(diastolic.value);
    }
    if (pulse.present) {
      map['pulse'] = Variable<int>(pulse.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (measurementContext.present) {
      map['measurement_context'] = Variable<String>(measurementContext.value);
    }
    if (measurementContexts.present) {
      map['measurement_contexts'] = Variable<String>(measurementContexts.value);
    }
    if (bodyPosition.present) {
      map['body_position'] = Variable<String>(bodyPosition.value);
    }
    if (cuffArm.present) {
      map['cuff_arm'] = Variable<String>(cuffArm.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (sourceReportId.present) {
      map['source_report_id'] = Variable<int>(sourceReportId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingsCompanion(')
          ..write('id: $id, ')
          ..write('systolic: $systolic, ')
          ..write('diastolic: $diastolic, ')
          ..write('pulse: $pulse, ')
          ..write('timestamp: $timestamp, ')
          ..write('notes: $notes, ')
          ..write('measurementContext: $measurementContext, ')
          ..write('measurementContexts: $measurementContexts, ')
          ..write('bodyPosition: $bodyPosition, ')
          ..write('cuffArm: $cuffArm, ')
          ..write('source: $source, ')
          ..write('sourceReportId: $sourceReportId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('remoteId: $remoteId, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $RemindersTable extends Reminders
    with TableInfo<$RemindersTable, ReminderRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hourMeta = const VerificationMeta('hour');
  @override
  late final GeneratedColumn<int> hour = GeneratedColumn<int>(
    'hour',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minuteMeta = const VerificationMeta('minute');
  @override
  late final GeneratedColumn<int> minute = GeneratedColumn<int>(
    'minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _daysOfWeekMeta = const VerificationMeta(
    'daysOfWeek',
  );
  @override
  late final GeneratedColumn<String> daysOfWeek = GeneratedColumn<String>(
    'days_of_week',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _quietHoursStartMinutesMeta =
      const VerificationMeta('quietHoursStartMinutes');
  @override
  late final GeneratedColumn<int> quietHoursStartMinutes = GeneratedColumn<int>(
    'quiet_hours_start_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quietHoursEndMinutesMeta =
      const VerificationMeta('quietHoursEndMinutes');
  @override
  late final GeneratedColumn<int> quietHoursEndMinutes = GeneratedColumn<int>(
    'quiet_hours_end_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
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
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    label,
    hour,
    minute,
    daysOfWeek,
    enabled,
    quietHoursStartMinutes,
    quietHoursEndMinutes,
    createdAt,
    updatedAt,
    remoteId,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReminderRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('hour')) {
      context.handle(
        _hourMeta,
        hour.isAcceptableOrUnknown(data['hour']!, _hourMeta),
      );
    } else if (isInserting) {
      context.missing(_hourMeta);
    }
    if (data.containsKey('minute')) {
      context.handle(
        _minuteMeta,
        minute.isAcceptableOrUnknown(data['minute']!, _minuteMeta),
      );
    } else if (isInserting) {
      context.missing(_minuteMeta);
    }
    if (data.containsKey('days_of_week')) {
      context.handle(
        _daysOfWeekMeta,
        daysOfWeek.isAcceptableOrUnknown(
          data['days_of_week']!,
          _daysOfWeekMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_daysOfWeekMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('quiet_hours_start_minutes')) {
      context.handle(
        _quietHoursStartMinutesMeta,
        quietHoursStartMinutes.isAcceptableOrUnknown(
          data['quiet_hours_start_minutes']!,
          _quietHoursStartMinutesMeta,
        ),
      );
    }
    if (data.containsKey('quiet_hours_end_minutes')) {
      context.handle(
        _quietHoursEndMinutesMeta,
        quietHoursEndMinutes.isAcceptableOrUnknown(
          data['quiet_hours_end_minutes']!,
          _quietHoursEndMinutesMeta,
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
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
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
  ReminderRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      hour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hour'],
      )!,
      minute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minute'],
      )!,
      daysOfWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}days_of_week'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      quietHoursStartMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quiet_hours_start_minutes'],
      ),
      quietHoursEndMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quiet_hours_end_minutes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }
}

class ReminderRow extends DataClass implements Insertable<ReminderRow> {
  final int id;
  final String label;
  final int hour;
  final int minute;
  final String daysOfWeek;
  final bool enabled;

  /// Optional silence window (minutes since midnight, 0-1439). When a
  /// reminder's fixed fire time falls inside this window, it's delivered
  /// silently (no sound/vibration) instead of not firing at all.
  final int? quietHoursStartMinutes;
  final int? quietHoursEndMinutes;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// The Firestore document id once this row has been synced
  /// (PROJECT_SPEC.md §21-22) — `null` until the first successful push.
  final String? remoteId;

  /// Soft-delete marker: set instead of a hard SQL delete so the sync
  /// layer can propagate the deletion to Firestore before the local row
  /// is actually removed. Rows with this set are filtered out of every
  /// read query.
  final DateTime? deletedAt;
  const ReminderRow({
    required this.id,
    required this.label,
    required this.hour,
    required this.minute,
    required this.daysOfWeek,
    required this.enabled,
    this.quietHoursStartMinutes,
    this.quietHoursEndMinutes,
    required this.createdAt,
    required this.updatedAt,
    this.remoteId,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['label'] = Variable<String>(label);
    map['hour'] = Variable<int>(hour);
    map['minute'] = Variable<int>(minute);
    map['days_of_week'] = Variable<String>(daysOfWeek);
    map['enabled'] = Variable<bool>(enabled);
    if (!nullToAbsent || quietHoursStartMinutes != null) {
      map['quiet_hours_start_minutes'] = Variable<int>(quietHoursStartMinutes);
    }
    if (!nullToAbsent || quietHoursEndMinutes != null) {
      map['quiet_hours_end_minutes'] = Variable<int>(quietHoursEndMinutes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      id: Value(id),
      label: Value(label),
      hour: Value(hour),
      minute: Value(minute),
      daysOfWeek: Value(daysOfWeek),
      enabled: Value(enabled),
      quietHoursStartMinutes: quietHoursStartMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(quietHoursStartMinutes),
      quietHoursEndMinutes: quietHoursEndMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(quietHoursEndMinutes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory ReminderRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderRow(
      id: serializer.fromJson<int>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      hour: serializer.fromJson<int>(json['hour']),
      minute: serializer.fromJson<int>(json['minute']),
      daysOfWeek: serializer.fromJson<String>(json['daysOfWeek']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      quietHoursStartMinutes: serializer.fromJson<int?>(
        json['quietHoursStartMinutes'],
      ),
      quietHoursEndMinutes: serializer.fromJson<int?>(
        json['quietHoursEndMinutes'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'label': serializer.toJson<String>(label),
      'hour': serializer.toJson<int>(hour),
      'minute': serializer.toJson<int>(minute),
      'daysOfWeek': serializer.toJson<String>(daysOfWeek),
      'enabled': serializer.toJson<bool>(enabled),
      'quietHoursStartMinutes': serializer.toJson<int?>(quietHoursStartMinutes),
      'quietHoursEndMinutes': serializer.toJson<int?>(quietHoursEndMinutes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'remoteId': serializer.toJson<String?>(remoteId),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  ReminderRow copyWith({
    int? id,
    String? label,
    int? hour,
    int? minute,
    String? daysOfWeek,
    bool? enabled,
    Value<int?> quietHoursStartMinutes = const Value.absent(),
    Value<int?> quietHoursEndMinutes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<String?> remoteId = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => ReminderRow(
    id: id ?? this.id,
    label: label ?? this.label,
    hour: hour ?? this.hour,
    minute: minute ?? this.minute,
    daysOfWeek: daysOfWeek ?? this.daysOfWeek,
    enabled: enabled ?? this.enabled,
    quietHoursStartMinutes: quietHoursStartMinutes.present
        ? quietHoursStartMinutes.value
        : this.quietHoursStartMinutes,
    quietHoursEndMinutes: quietHoursEndMinutes.present
        ? quietHoursEndMinutes.value
        : this.quietHoursEndMinutes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  ReminderRow copyWithCompanion(RemindersCompanion data) {
    return ReminderRow(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      hour: data.hour.present ? data.hour.value : this.hour,
      minute: data.minute.present ? data.minute.value : this.minute,
      daysOfWeek: data.daysOfWeek.present
          ? data.daysOfWeek.value
          : this.daysOfWeek,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      quietHoursStartMinutes: data.quietHoursStartMinutes.present
          ? data.quietHoursStartMinutes.value
          : this.quietHoursStartMinutes,
      quietHoursEndMinutes: data.quietHoursEndMinutes.present
          ? data.quietHoursEndMinutes.value
          : this.quietHoursEndMinutes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderRow(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('hour: $hour, ')
          ..write('minute: $minute, ')
          ..write('daysOfWeek: $daysOfWeek, ')
          ..write('enabled: $enabled, ')
          ..write('quietHoursStartMinutes: $quietHoursStartMinutes, ')
          ..write('quietHoursEndMinutes: $quietHoursEndMinutes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('remoteId: $remoteId, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    label,
    hour,
    minute,
    daysOfWeek,
    enabled,
    quietHoursStartMinutes,
    quietHoursEndMinutes,
    createdAt,
    updatedAt,
    remoteId,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderRow &&
          other.id == this.id &&
          other.label == this.label &&
          other.hour == this.hour &&
          other.minute == this.minute &&
          other.daysOfWeek == this.daysOfWeek &&
          other.enabled == this.enabled &&
          other.quietHoursStartMinutes == this.quietHoursStartMinutes &&
          other.quietHoursEndMinutes == this.quietHoursEndMinutes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.remoteId == this.remoteId &&
          other.deletedAt == this.deletedAt);
}

class RemindersCompanion extends UpdateCompanion<ReminderRow> {
  final Value<int> id;
  final Value<String> label;
  final Value<int> hour;
  final Value<int> minute;
  final Value<String> daysOfWeek;
  final Value<bool> enabled;
  final Value<int?> quietHoursStartMinutes;
  final Value<int?> quietHoursEndMinutes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String?> remoteId;
  final Value<DateTime?> deletedAt;
  const RemindersCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.hour = const Value.absent(),
    this.minute = const Value.absent(),
    this.daysOfWeek = const Value.absent(),
    this.enabled = const Value.absent(),
    this.quietHoursStartMinutes = const Value.absent(),
    this.quietHoursEndMinutes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  RemindersCompanion.insert({
    this.id = const Value.absent(),
    required String label,
    required int hour,
    required int minute,
    required String daysOfWeek,
    this.enabled = const Value.absent(),
    this.quietHoursStartMinutes = const Value.absent(),
    this.quietHoursEndMinutes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.remoteId = const Value.absent(),
    this.deletedAt = const Value.absent(),
  }) : label = Value(label),
       hour = Value(hour),
       minute = Value(minute),
       daysOfWeek = Value(daysOfWeek),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ReminderRow> custom({
    Expression<int>? id,
    Expression<String>? label,
    Expression<int>? hour,
    Expression<int>? minute,
    Expression<String>? daysOfWeek,
    Expression<bool>? enabled,
    Expression<int>? quietHoursStartMinutes,
    Expression<int>? quietHoursEndMinutes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? remoteId,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (hour != null) 'hour': hour,
      if (minute != null) 'minute': minute,
      if (daysOfWeek != null) 'days_of_week': daysOfWeek,
      if (enabled != null) 'enabled': enabled,
      if (quietHoursStartMinutes != null)
        'quiet_hours_start_minutes': quietHoursStartMinutes,
      if (quietHoursEndMinutes != null)
        'quiet_hours_end_minutes': quietHoursEndMinutes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (remoteId != null) 'remote_id': remoteId,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  RemindersCompanion copyWith({
    Value<int>? id,
    Value<String>? label,
    Value<int>? hour,
    Value<int>? minute,
    Value<String>? daysOfWeek,
    Value<bool>? enabled,
    Value<int?>? quietHoursStartMinutes,
    Value<int?>? quietHoursEndMinutes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String?>? remoteId,
    Value<DateTime?>? deletedAt,
  }) {
    return RemindersCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      enabled: enabled ?? this.enabled,
      quietHoursStartMinutes:
          quietHoursStartMinutes ?? this.quietHoursStartMinutes,
      quietHoursEndMinutes: quietHoursEndMinutes ?? this.quietHoursEndMinutes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      remoteId: remoteId ?? this.remoteId,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (hour.present) {
      map['hour'] = Variable<int>(hour.value);
    }
    if (minute.present) {
      map['minute'] = Variable<int>(minute.value);
    }
    if (daysOfWeek.present) {
      map['days_of_week'] = Variable<String>(daysOfWeek.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (quietHoursStartMinutes.present) {
      map['quiet_hours_start_minutes'] = Variable<int>(
        quietHoursStartMinutes.value,
      );
    }
    if (quietHoursEndMinutes.present) {
      map['quiet_hours_end_minutes'] = Variable<int>(
        quietHoursEndMinutes.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('hour: $hour, ')
          ..write('minute: $minute, ')
          ..write('daysOfWeek: $daysOfWeek, ')
          ..write('enabled: $enabled, ')
          ..write('quietHoursStartMinutes: $quietHoursStartMinutes, ')
          ..write('quietHoursEndMinutes: $quietHoursEndMinutes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('remoteId: $remoteId, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $SavedReportsTable extends SavedReports
    with TableInfo<$SavedReportsTable, SavedReportRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedReportsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _documentTypeMeta = const VerificationMeta(
    'documentType',
  );
  @override
  late final GeneratedColumn<String> documentType = GeneratedColumn<String>(
    'document_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reportDateMeta = const VerificationMeta(
    'reportDate',
  );
  @override
  late final GeneratedColumn<DateTime> reportDate = GeneratedColumn<DateTime>(
    'report_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pageCountMeta = const VerificationMeta(
    'pageCount',
  );
  @override
  late final GeneratedColumn<int> pageCount = GeneratedColumn<int>(
    'page_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ocrStatusMeta = const VerificationMeta(
    'ocrStatus',
  );
  @override
  late final GeneratedColumn<String> ocrStatus = GeneratedColumn<String>(
    'ocr_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _extractedReadingsJsonMeta =
      const VerificationMeta('extractedReadingsJson');
  @override
  late final GeneratedColumn<String> extractedReadingsJson =
      GeneratedColumn<String>(
        'extracted_readings_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _confirmedReadingsJsonMeta =
      const VerificationMeta('confirmedReadingsJson');
  @override
  late final GeneratedColumn<String> confirmedReadingsJson =
      GeneratedColumn<String>(
        'confirmed_readings_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPagePathsMeta = const VerificationMeta(
    'localPagePaths',
  );
  @override
  late final GeneratedColumn<String> localPagePaths = GeneratedColumn<String>(
    'local_page_paths',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storagePagePathsMeta = const VerificationMeta(
    'storagePagePaths',
  );
  @override
  late final GeneratedColumn<String> storagePagePaths = GeneratedColumn<String>(
    'storage_page_paths',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    requiredDuringInsert: false,
    defaultValue: const Constant('bpReport'),
  );
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
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
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    title,
    documentType,
    reportDate,
    pageCount,
    ocrStatus,
    extractedReadingsJson,
    confirmedReadingsJson,
    source,
    localPagePaths,
    storagePagePaths,
    category,
    provider,
    createdAt,
    updatedAt,
    remoteId,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_reports';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavedReportRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('document_type')) {
      context.handle(
        _documentTypeMeta,
        documentType.isAcceptableOrUnknown(
          data['document_type']!,
          _documentTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_documentTypeMeta);
    }
    if (data.containsKey('report_date')) {
      context.handle(
        _reportDateMeta,
        reportDate.isAcceptableOrUnknown(data['report_date']!, _reportDateMeta),
      );
    }
    if (data.containsKey('page_count')) {
      context.handle(
        _pageCountMeta,
        pageCount.isAcceptableOrUnknown(data['page_count']!, _pageCountMeta),
      );
    } else if (isInserting) {
      context.missing(_pageCountMeta);
    }
    if (data.containsKey('ocr_status')) {
      context.handle(
        _ocrStatusMeta,
        ocrStatus.isAcceptableOrUnknown(data['ocr_status']!, _ocrStatusMeta),
      );
    } else if (isInserting) {
      context.missing(_ocrStatusMeta);
    }
    if (data.containsKey('extracted_readings_json')) {
      context.handle(
        _extractedReadingsJsonMeta,
        extractedReadingsJson.isAcceptableOrUnknown(
          data['extracted_readings_json']!,
          _extractedReadingsJsonMeta,
        ),
      );
    }
    if (data.containsKey('confirmed_readings_json')) {
      context.handle(
        _confirmedReadingsJsonMeta,
        confirmedReadingsJson.isAcceptableOrUnknown(
          data['confirmed_readings_json']!,
          _confirmedReadingsJsonMeta,
        ),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('local_page_paths')) {
      context.handle(
        _localPagePathsMeta,
        localPagePaths.isAcceptableOrUnknown(
          data['local_page_paths']!,
          _localPagePathsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localPagePathsMeta);
    }
    if (data.containsKey('storage_page_paths')) {
      context.handle(
        _storagePagePathsMeta,
        storagePagePaths.isAcceptableOrUnknown(
          data['storage_page_paths']!,
          _storagePagePathsMeta,
        ),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
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
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
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
  SavedReportRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedReportRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      documentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_type'],
      )!,
      reportDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}report_date'],
      ),
      pageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_count'],
      )!,
      ocrStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ocr_status'],
      )!,
      extractedReadingsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extracted_readings_json'],
      )!,
      confirmedReadingsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}confirmed_readings_json'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      localPagePaths: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_page_paths'],
      )!,
      storagePagePaths: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}storage_page_paths'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $SavedReportsTable createAlias(String alias) {
    return $SavedReportsTable(attachedDatabase, alias);
  }
}

class SavedReportRow extends DataClass implements Insertable<SavedReportRow> {
  final int id;
  final String title;

  /// 'image' or 'pdf'.
  final String documentType;
  final DateTime? reportDate;
  final int pageCount;

  /// [OcrStatus] name.
  final String ocrStatus;
  final String extractedReadingsJson;
  final String confirmedReadingsJson;

  /// 'scan' or 'import'.
  final String source;

  /// Comma-separated local file paths for each page, in order.
  final String localPagePaths;

  /// Comma-separated Firebase Storage paths, once uploaded — `null` until
  /// the first successful push, same pattern as [Readings.remoteId].
  final String? storagePagePaths;

  /// [ReportCategory] name — defaults to 'bpReport' so rows saved before
  /// this column existed keep their original meaning after migration.
  final String category;

  /// Optional free-text clinician/lab name.
  final String? provider;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// The Firestore document id once this row's metadata has been synced.
  final String? remoteId;

  /// Soft-delete marker, same purpose as [Readings.deletedAt].
  final DateTime? deletedAt;
  const SavedReportRow({
    required this.id,
    required this.title,
    required this.documentType,
    this.reportDate,
    required this.pageCount,
    required this.ocrStatus,
    required this.extractedReadingsJson,
    required this.confirmedReadingsJson,
    required this.source,
    required this.localPagePaths,
    this.storagePagePaths,
    required this.category,
    this.provider,
    required this.createdAt,
    required this.updatedAt,
    this.remoteId,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['document_type'] = Variable<String>(documentType);
    if (!nullToAbsent || reportDate != null) {
      map['report_date'] = Variable<DateTime>(reportDate);
    }
    map['page_count'] = Variable<int>(pageCount);
    map['ocr_status'] = Variable<String>(ocrStatus);
    map['extracted_readings_json'] = Variable<String>(extractedReadingsJson);
    map['confirmed_readings_json'] = Variable<String>(confirmedReadingsJson);
    map['source'] = Variable<String>(source);
    map['local_page_paths'] = Variable<String>(localPagePaths);
    if (!nullToAbsent || storagePagePaths != null) {
      map['storage_page_paths'] = Variable<String>(storagePagePaths);
    }
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || provider != null) {
      map['provider'] = Variable<String>(provider);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  SavedReportsCompanion toCompanion(bool nullToAbsent) {
    return SavedReportsCompanion(
      id: Value(id),
      title: Value(title),
      documentType: Value(documentType),
      reportDate: reportDate == null && nullToAbsent
          ? const Value.absent()
          : Value(reportDate),
      pageCount: Value(pageCount),
      ocrStatus: Value(ocrStatus),
      extractedReadingsJson: Value(extractedReadingsJson),
      confirmedReadingsJson: Value(confirmedReadingsJson),
      source: Value(source),
      localPagePaths: Value(localPagePaths),
      storagePagePaths: storagePagePaths == null && nullToAbsent
          ? const Value.absent()
          : Value(storagePagePaths),
      category: Value(category),
      provider: provider == null && nullToAbsent
          ? const Value.absent()
          : Value(provider),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory SavedReportRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedReportRow(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      documentType: serializer.fromJson<String>(json['documentType']),
      reportDate: serializer.fromJson<DateTime?>(json['reportDate']),
      pageCount: serializer.fromJson<int>(json['pageCount']),
      ocrStatus: serializer.fromJson<String>(json['ocrStatus']),
      extractedReadingsJson: serializer.fromJson<String>(
        json['extractedReadingsJson'],
      ),
      confirmedReadingsJson: serializer.fromJson<String>(
        json['confirmedReadingsJson'],
      ),
      source: serializer.fromJson<String>(json['source']),
      localPagePaths: serializer.fromJson<String>(json['localPagePaths']),
      storagePagePaths: serializer.fromJson<String?>(json['storagePagePaths']),
      category: serializer.fromJson<String>(json['category']),
      provider: serializer.fromJson<String?>(json['provider']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'documentType': serializer.toJson<String>(documentType),
      'reportDate': serializer.toJson<DateTime?>(reportDate),
      'pageCount': serializer.toJson<int>(pageCount),
      'ocrStatus': serializer.toJson<String>(ocrStatus),
      'extractedReadingsJson': serializer.toJson<String>(extractedReadingsJson),
      'confirmedReadingsJson': serializer.toJson<String>(confirmedReadingsJson),
      'source': serializer.toJson<String>(source),
      'localPagePaths': serializer.toJson<String>(localPagePaths),
      'storagePagePaths': serializer.toJson<String?>(storagePagePaths),
      'category': serializer.toJson<String>(category),
      'provider': serializer.toJson<String?>(provider),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'remoteId': serializer.toJson<String?>(remoteId),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  SavedReportRow copyWith({
    int? id,
    String? title,
    String? documentType,
    Value<DateTime?> reportDate = const Value.absent(),
    int? pageCount,
    String? ocrStatus,
    String? extractedReadingsJson,
    String? confirmedReadingsJson,
    String? source,
    String? localPagePaths,
    Value<String?> storagePagePaths = const Value.absent(),
    String? category,
    Value<String?> provider = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<String?> remoteId = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => SavedReportRow(
    id: id ?? this.id,
    title: title ?? this.title,
    documentType: documentType ?? this.documentType,
    reportDate: reportDate.present ? reportDate.value : this.reportDate,
    pageCount: pageCount ?? this.pageCount,
    ocrStatus: ocrStatus ?? this.ocrStatus,
    extractedReadingsJson: extractedReadingsJson ?? this.extractedReadingsJson,
    confirmedReadingsJson: confirmedReadingsJson ?? this.confirmedReadingsJson,
    source: source ?? this.source,
    localPagePaths: localPagePaths ?? this.localPagePaths,
    storagePagePaths: storagePagePaths.present
        ? storagePagePaths.value
        : this.storagePagePaths,
    category: category ?? this.category,
    provider: provider.present ? provider.value : this.provider,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  SavedReportRow copyWithCompanion(SavedReportsCompanion data) {
    return SavedReportRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      documentType: data.documentType.present
          ? data.documentType.value
          : this.documentType,
      reportDate: data.reportDate.present
          ? data.reportDate.value
          : this.reportDate,
      pageCount: data.pageCount.present ? data.pageCount.value : this.pageCount,
      ocrStatus: data.ocrStatus.present ? data.ocrStatus.value : this.ocrStatus,
      extractedReadingsJson: data.extractedReadingsJson.present
          ? data.extractedReadingsJson.value
          : this.extractedReadingsJson,
      confirmedReadingsJson: data.confirmedReadingsJson.present
          ? data.confirmedReadingsJson.value
          : this.confirmedReadingsJson,
      source: data.source.present ? data.source.value : this.source,
      localPagePaths: data.localPagePaths.present
          ? data.localPagePaths.value
          : this.localPagePaths,
      storagePagePaths: data.storagePagePaths.present
          ? data.storagePagePaths.value
          : this.storagePagePaths,
      category: data.category.present ? data.category.value : this.category,
      provider: data.provider.present ? data.provider.value : this.provider,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedReportRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('documentType: $documentType, ')
          ..write('reportDate: $reportDate, ')
          ..write('pageCount: $pageCount, ')
          ..write('ocrStatus: $ocrStatus, ')
          ..write('extractedReadingsJson: $extractedReadingsJson, ')
          ..write('confirmedReadingsJson: $confirmedReadingsJson, ')
          ..write('source: $source, ')
          ..write('localPagePaths: $localPagePaths, ')
          ..write('storagePagePaths: $storagePagePaths, ')
          ..write('category: $category, ')
          ..write('provider: $provider, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('remoteId: $remoteId, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    documentType,
    reportDate,
    pageCount,
    ocrStatus,
    extractedReadingsJson,
    confirmedReadingsJson,
    source,
    localPagePaths,
    storagePagePaths,
    category,
    provider,
    createdAt,
    updatedAt,
    remoteId,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedReportRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.documentType == this.documentType &&
          other.reportDate == this.reportDate &&
          other.pageCount == this.pageCount &&
          other.ocrStatus == this.ocrStatus &&
          other.extractedReadingsJson == this.extractedReadingsJson &&
          other.confirmedReadingsJson == this.confirmedReadingsJson &&
          other.source == this.source &&
          other.localPagePaths == this.localPagePaths &&
          other.storagePagePaths == this.storagePagePaths &&
          other.category == this.category &&
          other.provider == this.provider &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.remoteId == this.remoteId &&
          other.deletedAt == this.deletedAt);
}

class SavedReportsCompanion extends UpdateCompanion<SavedReportRow> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> documentType;
  final Value<DateTime?> reportDate;
  final Value<int> pageCount;
  final Value<String> ocrStatus;
  final Value<String> extractedReadingsJson;
  final Value<String> confirmedReadingsJson;
  final Value<String> source;
  final Value<String> localPagePaths;
  final Value<String?> storagePagePaths;
  final Value<String> category;
  final Value<String?> provider;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String?> remoteId;
  final Value<DateTime?> deletedAt;
  const SavedReportsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.documentType = const Value.absent(),
    this.reportDate = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.ocrStatus = const Value.absent(),
    this.extractedReadingsJson = const Value.absent(),
    this.confirmedReadingsJson = const Value.absent(),
    this.source = const Value.absent(),
    this.localPagePaths = const Value.absent(),
    this.storagePagePaths = const Value.absent(),
    this.category = const Value.absent(),
    this.provider = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  SavedReportsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String documentType,
    this.reportDate = const Value.absent(),
    required int pageCount,
    required String ocrStatus,
    this.extractedReadingsJson = const Value.absent(),
    this.confirmedReadingsJson = const Value.absent(),
    required String source,
    required String localPagePaths,
    this.storagePagePaths = const Value.absent(),
    this.category = const Value.absent(),
    this.provider = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.remoteId = const Value.absent(),
    this.deletedAt = const Value.absent(),
  }) : title = Value(title),
       documentType = Value(documentType),
       pageCount = Value(pageCount),
       ocrStatus = Value(ocrStatus),
       source = Value(source),
       localPagePaths = Value(localPagePaths),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SavedReportRow> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? documentType,
    Expression<DateTime>? reportDate,
    Expression<int>? pageCount,
    Expression<String>? ocrStatus,
    Expression<String>? extractedReadingsJson,
    Expression<String>? confirmedReadingsJson,
    Expression<String>? source,
    Expression<String>? localPagePaths,
    Expression<String>? storagePagePaths,
    Expression<String>? category,
    Expression<String>? provider,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? remoteId,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (documentType != null) 'document_type': documentType,
      if (reportDate != null) 'report_date': reportDate,
      if (pageCount != null) 'page_count': pageCount,
      if (ocrStatus != null) 'ocr_status': ocrStatus,
      if (extractedReadingsJson != null)
        'extracted_readings_json': extractedReadingsJson,
      if (confirmedReadingsJson != null)
        'confirmed_readings_json': confirmedReadingsJson,
      if (source != null) 'source': source,
      if (localPagePaths != null) 'local_page_paths': localPagePaths,
      if (storagePagePaths != null) 'storage_page_paths': storagePagePaths,
      if (category != null) 'category': category,
      if (provider != null) 'provider': provider,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (remoteId != null) 'remote_id': remoteId,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  SavedReportsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? documentType,
    Value<DateTime?>? reportDate,
    Value<int>? pageCount,
    Value<String>? ocrStatus,
    Value<String>? extractedReadingsJson,
    Value<String>? confirmedReadingsJson,
    Value<String>? source,
    Value<String>? localPagePaths,
    Value<String?>? storagePagePaths,
    Value<String>? category,
    Value<String?>? provider,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String?>? remoteId,
    Value<DateTime?>? deletedAt,
  }) {
    return SavedReportsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      documentType: documentType ?? this.documentType,
      reportDate: reportDate ?? this.reportDate,
      pageCount: pageCount ?? this.pageCount,
      ocrStatus: ocrStatus ?? this.ocrStatus,
      extractedReadingsJson:
          extractedReadingsJson ?? this.extractedReadingsJson,
      confirmedReadingsJson:
          confirmedReadingsJson ?? this.confirmedReadingsJson,
      source: source ?? this.source,
      localPagePaths: localPagePaths ?? this.localPagePaths,
      storagePagePaths: storagePagePaths ?? this.storagePagePaths,
      category: category ?? this.category,
      provider: provider ?? this.provider,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      remoteId: remoteId ?? this.remoteId,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (documentType.present) {
      map['document_type'] = Variable<String>(documentType.value);
    }
    if (reportDate.present) {
      map['report_date'] = Variable<DateTime>(reportDate.value);
    }
    if (pageCount.present) {
      map['page_count'] = Variable<int>(pageCount.value);
    }
    if (ocrStatus.present) {
      map['ocr_status'] = Variable<String>(ocrStatus.value);
    }
    if (extractedReadingsJson.present) {
      map['extracted_readings_json'] = Variable<String>(
        extractedReadingsJson.value,
      );
    }
    if (confirmedReadingsJson.present) {
      map['confirmed_readings_json'] = Variable<String>(
        confirmedReadingsJson.value,
      );
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (localPagePaths.present) {
      map['local_page_paths'] = Variable<String>(localPagePaths.value);
    }
    if (storagePagePaths.present) {
      map['storage_page_paths'] = Variable<String>(storagePagePaths.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedReportsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('documentType: $documentType, ')
          ..write('reportDate: $reportDate, ')
          ..write('pageCount: $pageCount, ')
          ..write('ocrStatus: $ocrStatus, ')
          ..write('extractedReadingsJson: $extractedReadingsJson, ')
          ..write('confirmedReadingsJson: $confirmedReadingsJson, ')
          ..write('source: $source, ')
          ..write('localPagePaths: $localPagePaths, ')
          ..write('storagePagePaths: $storagePagePaths, ')
          ..write('category: $category, ')
          ..write('provider: $provider, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('remoteId: $remoteId, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ReadingsTable readings = $ReadingsTable(this);
  late final $RemindersTable reminders = $RemindersTable(this);
  late final $SavedReportsTable savedReports = $SavedReportsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    readings,
    reminders,
    savedReports,
  ];
}

typedef $$ReadingsTableCreateCompanionBuilder = ReadingsCompanion Function({
  Value<int> id,
  required int systolic,
  required int diastolic,
  Value<int?> pulse,
  required DateTime timestamp,
  Value<String?> notes,
  Value<String?> measurementContext,
  Value<String?> measurementContexts,
  Value<String?> bodyPosition,
  Value<String?> cuffArm,
  Value<String> source,
  Value<int?> sourceReportId,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<String?> remoteId,
  Value<DateTime?> deletedAt,
});
typedef $$ReadingsTableUpdateCompanionBuilder = ReadingsCompanion Function({
  Value<int> id,
  Value<int> systolic,
  Value<int> diastolic,
  Value<int?> pulse,
  Value<DateTime> timestamp,
  Value<String?> notes,
  Value<String?> measurementContext,
  Value<String?> measurementContexts,
  Value<String?> bodyPosition,
  Value<String?> cuffArm,
  Value<String> source,
  Value<int?> sourceReportId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String?> remoteId,
  Value<DateTime?> deletedAt,
});

class $$ReadingsTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingsTable> {
  $$ReadingsTableFilterComposer({
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

  ColumnFilters<int> get systolic => $composableBuilder(
    column: $table.systolic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get diastolic => $composableBuilder(
    column: $table.diastolic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pulse => $composableBuilder(
    column: $table.pulse,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get measurementContext => $composableBuilder(
    column: $table.measurementContext,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get measurementContexts => $composableBuilder(
    column: $table.measurementContexts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bodyPosition => $composableBuilder(
    column: $table.bodyPosition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cuffArm => $composableBuilder(
    column: $table.cuffArm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sourceReportId => $composableBuilder(
    column: $table.sourceReportId,
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

  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReadingsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingsTable> {
  $$ReadingsTableOrderingComposer({
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

  ColumnOrderings<int> get systolic => $composableBuilder(
    column: $table.systolic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get diastolic => $composableBuilder(
    column: $table.diastolic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pulse => $composableBuilder(
    column: $table.pulse,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get measurementContext => $composableBuilder(
    column: $table.measurementContext,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get measurementContexts => $composableBuilder(
    column: $table.measurementContexts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bodyPosition => $composableBuilder(
    column: $table.bodyPosition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cuffArm => $composableBuilder(
    column: $table.cuffArm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sourceReportId => $composableBuilder(
    column: $table.sourceReportId,
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

  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReadingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingsTable> {
  $$ReadingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get systolic =>
      $composableBuilder(column: $table.systolic, builder: (column) => column);

  GeneratedColumn<int> get diastolic =>
      $composableBuilder(column: $table.diastolic, builder: (column) => column);

  GeneratedColumn<int> get pulse =>
      $composableBuilder(column: $table.pulse, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get measurementContext => $composableBuilder(
    column: $table.measurementContext,
    builder: (column) => column,
  );

  GeneratedColumn<String> get measurementContexts => $composableBuilder(
    column: $table.measurementContexts,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bodyPosition => $composableBuilder(
    column: $table.bodyPosition,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cuffArm =>
      $composableBuilder(column: $table.cuffArm, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get sourceReportId => $composableBuilder(
    column: $table.sourceReportId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$ReadingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReadingsTable,
          Reading,
          $$ReadingsTableFilterComposer,
          $$ReadingsTableOrderingComposer,
          $$ReadingsTableAnnotationComposer,
          $$ReadingsTableCreateCompanionBuilder,
          $$ReadingsTableUpdateCompanionBuilder,
          (Reading, BaseReferences<_$AppDatabase, $ReadingsTable, Reading>),
          Reading,
          PrefetchHooks Function()
        > {
  $$ReadingsTableTableManager(_$AppDatabase db, $ReadingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> systolic = const Value.absent(),
                Value<int> diastolic = const Value.absent(),
                Value<int?> pulse = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> measurementContext = const Value.absent(),
                Value<String?> measurementContexts = const Value.absent(),
                Value<String?> bodyPosition = const Value.absent(),
                Value<String?> cuffArm = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int?> sourceReportId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => ReadingsCompanion(
                id: id,
                systolic: systolic,
                diastolic: diastolic,
                pulse: pulse,
                timestamp: timestamp,
                notes: notes,
                measurementContext: measurementContext,
                measurementContexts: measurementContexts,
                bodyPosition: bodyPosition,
                cuffArm: cuffArm,
                source: source,
                sourceReportId: sourceReportId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                remoteId: remoteId,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int systolic,
                required int diastolic,
                Value<int?> pulse = const Value.absent(),
                required DateTime timestamp,
                Value<String?> notes = const Value.absent(),
                Value<String?> measurementContext = const Value.absent(),
                Value<String?> measurementContexts = const Value.absent(),
                Value<String?> bodyPosition = const Value.absent(),
                Value<String?> cuffArm = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int?> sourceReportId = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<String?> remoteId = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => ReadingsCompanion.insert(
                id: id,
                systolic: systolic,
                diastolic: diastolic,
                pulse: pulse,
                timestamp: timestamp,
                notes: notes,
                measurementContext: measurementContext,
                measurementContexts: measurementContexts,
                bodyPosition: bodyPosition,
                cuffArm: cuffArm,
                source: source,
                sourceReportId: sourceReportId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                remoteId: remoteId,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReadingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReadingsTable,
      Reading,
      $$ReadingsTableFilterComposer,
      $$ReadingsTableOrderingComposer,
      $$ReadingsTableAnnotationComposer,
      $$ReadingsTableCreateCompanionBuilder,
      $$ReadingsTableUpdateCompanionBuilder,
      (Reading, BaseReferences<_$AppDatabase, $ReadingsTable, Reading>),
      Reading,
      PrefetchHooks Function()
    >;
typedef $$RemindersTableCreateCompanionBuilder = RemindersCompanion Function({
  Value<int> id,
  required String label,
  required int hour,
  required int minute,
  required String daysOfWeek,
  Value<bool> enabled,
  Value<int?> quietHoursStartMinutes,
  Value<int?> quietHoursEndMinutes,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<String?> remoteId,
  Value<DateTime?> deletedAt,
});
typedef $$RemindersTableUpdateCompanionBuilder = RemindersCompanion Function({
  Value<int> id,
  Value<String> label,
  Value<int> hour,
  Value<int> minute,
  Value<String> daysOfWeek,
  Value<bool> enabled,
  Value<int?> quietHoursStartMinutes,
  Value<int?> quietHoursEndMinutes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String?> remoteId,
  Value<DateTime?> deletedAt,
});

class $$RemindersTableFilterComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableFilterComposer({
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

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hour => $composableBuilder(
    column: $table.hour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minute => $composableBuilder(
    column: $table.minute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get daysOfWeek => $composableBuilder(
    column: $table.daysOfWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quietHoursStartMinutes => $composableBuilder(
    column: $table.quietHoursStartMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quietHoursEndMinutes => $composableBuilder(
    column: $table.quietHoursEndMinutes,
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

  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableOrderingComposer({
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

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hour => $composableBuilder(
    column: $table.hour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minute => $composableBuilder(
    column: $table.minute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get daysOfWeek => $composableBuilder(
    column: $table.daysOfWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quietHoursStartMinutes => $composableBuilder(
    column: $table.quietHoursStartMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quietHoursEndMinutes => $composableBuilder(
    column: $table.quietHoursEndMinutes,
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

  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get hour =>
      $composableBuilder(column: $table.hour, builder: (column) => column);

  GeneratedColumn<int> get minute =>
      $composableBuilder(column: $table.minute, builder: (column) => column);

  GeneratedColumn<String> get daysOfWeek => $composableBuilder(
    column: $table.daysOfWeek,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<int> get quietHoursStartMinutes => $composableBuilder(
    column: $table.quietHoursStartMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quietHoursEndMinutes => $composableBuilder(
    column: $table.quietHoursEndMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$RemindersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RemindersTable,
          ReminderRow,
          $$RemindersTableFilterComposer,
          $$RemindersTableOrderingComposer,
          $$RemindersTableAnnotationComposer,
          $$RemindersTableCreateCompanionBuilder,
          $$RemindersTableUpdateCompanionBuilder,
          (
            ReminderRow,
            BaseReferences<_$AppDatabase, $RemindersTable, ReminderRow>,
          ),
          ReminderRow,
          PrefetchHooks Function()
        > {
  $$RemindersTableTableManager(_$AppDatabase db, $RemindersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<int> hour = const Value.absent(),
                Value<int> minute = const Value.absent(),
                Value<String> daysOfWeek = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int?> quietHoursStartMinutes = const Value.absent(),
                Value<int?> quietHoursEndMinutes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => RemindersCompanion(
                id: id,
                label: label,
                hour: hour,
                minute: minute,
                daysOfWeek: daysOfWeek,
                enabled: enabled,
                quietHoursStartMinutes: quietHoursStartMinutes,
                quietHoursEndMinutes: quietHoursEndMinutes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                remoteId: remoteId,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String label,
                required int hour,
                required int minute,
                required String daysOfWeek,
                Value<bool> enabled = const Value.absent(),
                Value<int?> quietHoursStartMinutes = const Value.absent(),
                Value<int?> quietHoursEndMinutes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<String?> remoteId = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => RemindersCompanion.insert(
                id: id,
                label: label,
                hour: hour,
                minute: minute,
                daysOfWeek: daysOfWeek,
                enabled: enabled,
                quietHoursStartMinutes: quietHoursStartMinutes,
                quietHoursEndMinutes: quietHoursEndMinutes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                remoteId: remoteId,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RemindersTable,
      ReminderRow,
      $$RemindersTableFilterComposer,
      $$RemindersTableOrderingComposer,
      $$RemindersTableAnnotationComposer,
      $$RemindersTableCreateCompanionBuilder,
      $$RemindersTableUpdateCompanionBuilder,
      (
        ReminderRow,
        BaseReferences<_$AppDatabase, $RemindersTable, ReminderRow>,
      ),
      ReminderRow,
      PrefetchHooks Function()
    >;
typedef $$SavedReportsTableCreateCompanionBuilder =
    SavedReportsCompanion Function({
      Value<int> id,
      required String title,
      required String documentType,
      Value<DateTime?> reportDate,
      required int pageCount,
      required String ocrStatus,
      Value<String> extractedReadingsJson,
      Value<String> confirmedReadingsJson,
      required String source,
      required String localPagePaths,
      Value<String?> storagePagePaths,
      Value<String> category,
      Value<String?> provider,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<String?> remoteId,
      Value<DateTime?> deletedAt,
    });
typedef $$SavedReportsTableUpdateCompanionBuilder =
    SavedReportsCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String> documentType,
      Value<DateTime?> reportDate,
      Value<int> pageCount,
      Value<String> ocrStatus,
      Value<String> extractedReadingsJson,
      Value<String> confirmedReadingsJson,
      Value<String> source,
      Value<String> localPagePaths,
      Value<String?> storagePagePaths,
      Value<String> category,
      Value<String?> provider,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> remoteId,
      Value<DateTime?> deletedAt,
    });

class $$SavedReportsTableFilterComposer
    extends Composer<_$AppDatabase, $SavedReportsTable> {
  $$SavedReportsTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get documentType => $composableBuilder(
    column: $table.documentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get reportDate => $composableBuilder(
    column: $table.reportDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ocrStatus => $composableBuilder(
    column: $table.ocrStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extractedReadingsJson => $composableBuilder(
    column: $table.extractedReadingsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get confirmedReadingsJson => $composableBuilder(
    column: $table.confirmedReadingsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPagePaths => $composableBuilder(
    column: $table.localPagePaths,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storagePagePaths => $composableBuilder(
    column: $table.storagePagePaths,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
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

  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SavedReportsTableOrderingComposer
    extends Composer<_$AppDatabase, $SavedReportsTable> {
  $$SavedReportsTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get documentType => $composableBuilder(
    column: $table.documentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get reportDate => $composableBuilder(
    column: $table.reportDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ocrStatus => $composableBuilder(
    column: $table.ocrStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extractedReadingsJson => $composableBuilder(
    column: $table.extractedReadingsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get confirmedReadingsJson => $composableBuilder(
    column: $table.confirmedReadingsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPagePaths => $composableBuilder(
    column: $table.localPagePaths,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storagePagePaths => $composableBuilder(
    column: $table.storagePagePaths,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
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

  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SavedReportsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavedReportsTable> {
  $$SavedReportsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get documentType => $composableBuilder(
    column: $table.documentType,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get reportDate => $composableBuilder(
    column: $table.reportDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pageCount =>
      $composableBuilder(column: $table.pageCount, builder: (column) => column);

  GeneratedColumn<String> get ocrStatus =>
      $composableBuilder(column: $table.ocrStatus, builder: (column) => column);

  GeneratedColumn<String> get extractedReadingsJson => $composableBuilder(
    column: $table.extractedReadingsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get confirmedReadingsJson => $composableBuilder(
    column: $table.confirmedReadingsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get localPagePaths => $composableBuilder(
    column: $table.localPagePaths,
    builder: (column) => column,
  );

  GeneratedColumn<String> get storagePagePaths => $composableBuilder(
    column: $table.storagePagePaths,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$SavedReportsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavedReportsTable,
          SavedReportRow,
          $$SavedReportsTableFilterComposer,
          $$SavedReportsTableOrderingComposer,
          $$SavedReportsTableAnnotationComposer,
          $$SavedReportsTableCreateCompanionBuilder,
          $$SavedReportsTableUpdateCompanionBuilder,
          (
            SavedReportRow,
            BaseReferences<_$AppDatabase, $SavedReportsTable, SavedReportRow>,
          ),
          SavedReportRow,
          PrefetchHooks Function()
        > {
  $$SavedReportsTableTableManager(_$AppDatabase db, $SavedReportsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedReportsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedReportsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavedReportsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> documentType = const Value.absent(),
                Value<DateTime?> reportDate = const Value.absent(),
                Value<int> pageCount = const Value.absent(),
                Value<String> ocrStatus = const Value.absent(),
                Value<String> extractedReadingsJson = const Value.absent(),
                Value<String> confirmedReadingsJson = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> localPagePaths = const Value.absent(),
                Value<String?> storagePagePaths = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> provider = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => SavedReportsCompanion(
                id: id,
                title: title,
                documentType: documentType,
                reportDate: reportDate,
                pageCount: pageCount,
                ocrStatus: ocrStatus,
                extractedReadingsJson: extractedReadingsJson,
                confirmedReadingsJson: confirmedReadingsJson,
                source: source,
                localPagePaths: localPagePaths,
                storagePagePaths: storagePagePaths,
                category: category,
                provider: provider,
                createdAt: createdAt,
                updatedAt: updatedAt,
                remoteId: remoteId,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required String documentType,
                Value<DateTime?> reportDate = const Value.absent(),
                required int pageCount,
                required String ocrStatus,
                Value<String> extractedReadingsJson = const Value.absent(),
                Value<String> confirmedReadingsJson = const Value.absent(),
                required String source,
                required String localPagePaths,
                Value<String?> storagePagePaths = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> provider = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<String?> remoteId = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => SavedReportsCompanion.insert(
                id: id,
                title: title,
                documentType: documentType,
                reportDate: reportDate,
                pageCount: pageCount,
                ocrStatus: ocrStatus,
                extractedReadingsJson: extractedReadingsJson,
                confirmedReadingsJson: confirmedReadingsJson,
                source: source,
                localPagePaths: localPagePaths,
                storagePagePaths: storagePagePaths,
                category: category,
                provider: provider,
                createdAt: createdAt,
                updatedAt: updatedAt,
                remoteId: remoteId,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SavedReportsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavedReportsTable,
      SavedReportRow,
      $$SavedReportsTableFilterComposer,
      $$SavedReportsTableOrderingComposer,
      $$SavedReportsTableAnnotationComposer,
      $$SavedReportsTableCreateCompanionBuilder,
      $$SavedReportsTableUpdateCompanionBuilder,
      (
        SavedReportRow,
        BaseReferences<_$AppDatabase, $SavedReportsTable, SavedReportRow>,
      ),
      SavedReportRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ReadingsTableTableManager get readings =>
      $$ReadingsTableTableManager(_db, _db.readings);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db, _db.reminders);
  $$SavedReportsTableTableManager get savedReports =>
      $$SavedReportsTableTableManager(_db, _db.savedReports);
}
