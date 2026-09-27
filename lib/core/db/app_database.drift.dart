// dart format width=80
// ignore_for_file: type=lint
part of 'app_database.dart';

class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _participantIdMeta =
      const VerificationMeta('participantId');
  @override
  late final GeneratedColumn<String> participantId = GeneratedColumn<String>(
      'participant_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sideMeta = const VerificationMeta('side');
  @override
  late final GeneratedColumn<String> side = GeneratedColumn<String>(
      'side', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _recordedAtMeta =
      const VerificationMeta('recordedAt');
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
      'recorded_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _durationSecondsMeta =
      const VerificationMeta('durationSeconds');
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
      'duration_seconds', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _missedSamplesMeta =
      const VerificationMeta('missedSamples');
  @override
  late final GeneratedColumn<int> missedSamples = GeneratedColumn<int>(
      'missed_samples', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _localPathMeta =
      const VerificationMeta('localPath');
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
      'local_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isAnalysedMeta =
      const VerificationMeta('isAnalysed');
  @override
  late final GeneratedColumn<bool> isAnalysed = GeneratedColumn<bool>(
      'is_analysed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_analysed" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        participantId,
        side,
        recordedAt,
        durationSeconds,
        missedSamples,
        syncStatus,
        localPath,
        isAnalysed
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(Insertable<Session> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('participant_id')) {
      context.handle(
          _participantIdMeta,
          participantId.isAcceptableOrUnknown(
              data['participant_id']!, _participantIdMeta));
    } else if (isInserting) {
      context.missing(_participantIdMeta);
    }
    if (data.containsKey('side')) {
      context.handle(
          _sideMeta, side.isAcceptableOrUnknown(data['side']!, _sideMeta));
    } else if (isInserting) {
      context.missing(_sideMeta);
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
          _recordedAtMeta,
          recordedAt.isAcceptableOrUnknown(
              data['recorded_at']!, _recordedAtMeta));
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
          _durationSecondsMeta,
          durationSeconds.isAcceptableOrUnknown(
              data['duration_seconds']!, _durationSecondsMeta));
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('missed_samples')) {
      context.handle(
          _missedSamplesMeta,
          missedSamples.isAcceptableOrUnknown(
              data['missed_samples']!, _missedSamplesMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('local_path')) {
      context.handle(_localPathMeta,
          localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta));
    }
    if (data.containsKey('is_analysed')) {
      context.handle(
          _isAnalysedMeta,
          isAnalysed.isAcceptableOrUnknown(
              data['is_analysed']!, _isAnalysedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      participantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}participant_id'])!,
      side: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}side'])!,
      recordedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}recorded_at'])!,
      durationSeconds: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_seconds'])!,
      missedSamples: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}missed_samples'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      localPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_path']),
      isAnalysed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_analysed'])!,
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class Session extends DataClass implements Insertable<Session> {
  final int id;
  final String name;
  final String participantId;
  final String side;
  final DateTime recordedAt;
  final int durationSeconds;
  final int missedSamples;
  final String syncStatus;
  final String? localPath;
  final bool isAnalysed;
  const Session(
      {required this.id,
      required this.name,
      required this.participantId,
      required this.side,
      required this.recordedAt,
      required this.durationSeconds,
      required this.missedSamples,
      required this.syncStatus,
      this.localPath,
      required this.isAnalysed});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['participant_id'] = Variable<String>(participantId);
    map['side'] = Variable<String>(side);
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['missed_samples'] = Variable<int>(missedSamples);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || localPath != null) {
      map['local_path'] = Variable<String>(localPath);
    }
    map['is_analysed'] = Variable<bool>(isAnalysed);
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      name: Value(name),
      participantId: Value(participantId),
      side: Value(side),
      recordedAt: Value(recordedAt),
      durationSeconds: Value(durationSeconds),
      missedSamples: Value(missedSamples),
      syncStatus: Value(syncStatus),
      localPath: localPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPath),
      isAnalysed: Value(isAnalysed),
    );
  }

  factory Session.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      participantId: serializer.fromJson<String>(json['participantId']),
      side: serializer.fromJson<String>(json['side']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      missedSamples: serializer.fromJson<int>(json['missedSamples']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      localPath: serializer.fromJson<String?>(json['localPath']),
      isAnalysed: serializer.fromJson<bool>(json['isAnalysed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'participantId': serializer.toJson<String>(participantId),
      'side': serializer.toJson<String>(side),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'missedSamples': serializer.toJson<int>(missedSamples),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'localPath': serializer.toJson<String?>(localPath),
      'isAnalysed': serializer.toJson<bool>(isAnalysed),
    };
  }

  Session copyWith(
          {int? id,
          String? name,
          String? participantId,
          String? side,
          DateTime? recordedAt,
          int? durationSeconds,
          int? missedSamples,
          String? syncStatus,
          Value<String?> localPath = const Value.absent(),
          bool? isAnalysed}) =>
      Session(
        id: id ?? this.id,
        name: name ?? this.name,
        participantId: participantId ?? this.participantId,
        side: side ?? this.side,
        recordedAt: recordedAt ?? this.recordedAt,
        durationSeconds: durationSeconds ?? this.durationSeconds,
        missedSamples: missedSamples ?? this.missedSamples,
        syncStatus: syncStatus ?? this.syncStatus,
        localPath: localPath.present ? localPath.value : this.localPath,
        isAnalysed: isAnalysed ?? this.isAnalysed,
      );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      participantId: data.participantId.present
          ? data.participantId.value
          : this.participantId,
      side: data.side.present ? data.side.value : this.side,
      recordedAt:
          data.recordedAt.present ? data.recordedAt.value : this.recordedAt,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      missedSamples: data.missedSamples.present
          ? data.missedSamples.value
          : this.missedSamples,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      isAnalysed:
          data.isAnalysed.present ? data.isAnalysed.value : this.isAnalysed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('participantId: $participantId, ')
          ..write('side: $side, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('missedSamples: $missedSamples, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('localPath: $localPath, ')
          ..write('isAnalysed: $isAnalysed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, participantId, side, recordedAt,
      durationSeconds, missedSamples, syncStatus, localPath, isAnalysed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.name == this.name &&
          other.participantId == this.participantId &&
          other.side == this.side &&
          other.recordedAt == this.recordedAt &&
          other.durationSeconds == this.durationSeconds &&
          other.missedSamples == this.missedSamples &&
          other.syncStatus == this.syncStatus &&
          other.localPath == this.localPath &&
          other.isAnalysed == this.isAnalysed);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> participantId;
  final Value<String> side;
  final Value<DateTime> recordedAt;
  final Value<int> durationSeconds;
  final Value<int> missedSamples;
  final Value<String> syncStatus;
  final Value<String?> localPath;
  final Value<bool> isAnalysed;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.participantId = const Value.absent(),
    this.side = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.missedSamples = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.localPath = const Value.absent(),
    this.isAnalysed = const Value.absent(),
  });
  SessionsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String participantId,
    required String side,
    required DateTime recordedAt,
    required int durationSeconds,
    this.missedSamples = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.localPath = const Value.absent(),
    this.isAnalysed = const Value.absent(),
  })  : name = Value(name),
        participantId = Value(participantId),
        side = Value(side),
        recordedAt = Value(recordedAt),
        durationSeconds = Value(durationSeconds);
  static Insertable<Session> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? participantId,
    Expression<String>? side,
    Expression<DateTime>? recordedAt,
    Expression<int>? durationSeconds,
    Expression<int>? missedSamples,
    Expression<String>? syncStatus,
    Expression<String>? localPath,
    Expression<bool>? isAnalysed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (participantId != null) 'participant_id': participantId,
      if (side != null) 'side': side,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (missedSamples != null) 'missed_samples': missedSamples,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (localPath != null) 'local_path': localPath,
      if (isAnalysed != null) 'is_analysed': isAnalysed,
    });
  }

  SessionsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? participantId,
      Value<String>? side,
      Value<DateTime>? recordedAt,
      Value<int>? durationSeconds,
      Value<int>? missedSamples,
      Value<String>? syncStatus,
      Value<String?>? localPath,
      Value<bool>? isAnalysed}) {
    return SessionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      participantId: participantId ?? this.participantId,
      side: side ?? this.side,
      recordedAt: recordedAt ?? this.recordedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      missedSamples: missedSamples ?? this.missedSamples,
      syncStatus: syncStatus ?? this.syncStatus,
      localPath: localPath ?? this.localPath,
      isAnalysed: isAnalysed ?? this.isAnalysed,
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
    if (participantId.present) {
      map['participant_id'] = Variable<String>(participantId.value);
    }
    if (side.present) {
      map['side'] = Variable<String>(side.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (missedSamples.present) {
      map['missed_samples'] = Variable<int>(missedSamples.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (isAnalysed.present) {
      map['is_analysed'] = Variable<bool>(isAnalysed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('participantId: $participantId, ')
          ..write('side: $side, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('missedSamples: $missedSamples, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('localPath: $localPath, ')
          ..write('isAnalysed: $isAnalysed')
          ..write(')'))
        .toString();
  }
}

class $SessionFeaturesTable extends SessionFeatures
    with TableInfo<$SessionFeaturesTable, SessionFeature> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionFeaturesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
      'session_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES sessions (id) ON DELETE CASCADE'));
  static const VerificationMeta _roughnessScoreMeta =
      const VerificationMeta('roughnessScore');
  @override
  late final GeneratedColumn<double> roughnessScore = GeneratedColumn<double>(
      'roughness_score', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _maxFlexionDegMeta =
      const VerificationMeta('maxFlexionDeg');
  @override
  late final GeneratedColumn<double> maxFlexionDeg = GeneratedColumn<double>(
      'max_flexion_deg', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _rangeOfMotionDegMeta =
      const VerificationMeta('rangeOfMotionDeg');
  @override
  late final GeneratedColumn<double> rangeOfMotionDeg = GeneratedColumn<double>(
      'range_of_motion_deg', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _avgBendTimeSMeta =
      const VerificationMeta('avgBendTimeS');
  @override
  late final GeneratedColumn<double> avgBendTimeS = GeneratedColumn<double>(
      'avg_bend_time_s', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _vibBurstCountMeta =
      const VerificationMeta('vibBurstCount');
  @override
  late final GeneratedColumn<int> vibBurstCount = GeneratedColumn<int>(
      'vib_burst_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _burstAngleMinMeta =
      const VerificationMeta('burstAngleMin');
  @override
  late final GeneratedColumn<double> burstAngleMin = GeneratedColumn<double>(
      'burst_angle_min', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _burstAngleMaxMeta =
      const VerificationMeta('burstAngleMax');
  @override
  late final GeneratedColumn<double> burstAngleMax = GeneratedColumn<double>(
      'burst_angle_max', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _rmsRawMeta = const VerificationMeta('rmsRaw');
  @override
  late final GeneratedColumn<double> rmsRaw = GeneratedColumn<double>(
      'rms_raw', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _peakRawMeta =
      const VerificationMeta('peakRaw');
  @override
  late final GeneratedColumn<double> peakRaw = GeneratedColumn<double>(
      'peak_raw', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _kurtosisMeta =
      const VerificationMeta('kurtosis');
  @override
  late final GeneratedColumn<double> kurtosis = GeneratedColumn<double>(
      'kurtosis', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _bendCountMeta =
      const VerificationMeta('bendCount');
  @override
  late final GeneratedColumn<int> bendCount = GeneratedColumn<int>(
      'bend_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isTrustworthyMeta =
      const VerificationMeta('isTrustworthy');
  @override
  late final GeneratedColumn<bool> isTrustworthy = GeneratedColumn<bool>(
      'is_trustworthy', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_trustworthy" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _warningNoteMeta =
      const VerificationMeta('warningNote');
  @override
  late final GeneratedColumn<String> warningNote = GeneratedColumn<String>(
      'warning_note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _analysedAtMeta =
      const VerificationMeta('analysedAt');
  @override
  late final GeneratedColumn<DateTime> analysedAt = GeneratedColumn<DateTime>(
      'analysed_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        sessionId,
        roughnessScore,
        maxFlexionDeg,
        rangeOfMotionDeg,
        avgBendTimeS,
        vibBurstCount,
        burstAngleMin,
        burstAngleMax,
        rmsRaw,
        peakRaw,
        kurtosis,
        bendCount,
        isTrustworthy,
        warningNote,
        analysedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_features';
  @override
  VerificationContext validateIntegrity(Insertable<SessionFeature> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('roughness_score')) {
      context.handle(
          _roughnessScoreMeta,
          roughnessScore.isAcceptableOrUnknown(
              data['roughness_score']!, _roughnessScoreMeta));
    } else if (isInserting) {
      context.missing(_roughnessScoreMeta);
    }
    if (data.containsKey('max_flexion_deg')) {
      context.handle(
          _maxFlexionDegMeta,
          maxFlexionDeg.isAcceptableOrUnknown(
              data['max_flexion_deg']!, _maxFlexionDegMeta));
    } else if (isInserting) {
      context.missing(_maxFlexionDegMeta);
    }
    if (data.containsKey('range_of_motion_deg')) {
      context.handle(
          _rangeOfMotionDegMeta,
          rangeOfMotionDeg.isAcceptableOrUnknown(
              data['range_of_motion_deg']!, _rangeOfMotionDegMeta));
    } else if (isInserting) {
      context.missing(_rangeOfMotionDegMeta);
    }
    if (data.containsKey('avg_bend_time_s')) {
      context.handle(
          _avgBendTimeSMeta,
          avgBendTimeS.isAcceptableOrUnknown(
              data['avg_bend_time_s']!, _avgBendTimeSMeta));
    } else if (isInserting) {
      context.missing(_avgBendTimeSMeta);
    }
    if (data.containsKey('vib_burst_count')) {
      context.handle(
          _vibBurstCountMeta,
          vibBurstCount.isAcceptableOrUnknown(
              data['vib_burst_count']!, _vibBurstCountMeta));
    } else if (isInserting) {
      context.missing(_vibBurstCountMeta);
    }
    if (data.containsKey('burst_angle_min')) {
      context.handle(
          _burstAngleMinMeta,
          burstAngleMin.isAcceptableOrUnknown(
              data['burst_angle_min']!, _burstAngleMinMeta));
    } else if (isInserting) {
      context.missing(_burstAngleMinMeta);
    }
    if (data.containsKey('burst_angle_max')) {
      context.handle(
          _burstAngleMaxMeta,
          burstAngleMax.isAcceptableOrUnknown(
              data['burst_angle_max']!, _burstAngleMaxMeta));
    } else if (isInserting) {
      context.missing(_burstAngleMaxMeta);
    }
    if (data.containsKey('rms_raw')) {
      context.handle(_rmsRawMeta,
          rmsRaw.isAcceptableOrUnknown(data['rms_raw']!, _rmsRawMeta));
    } else if (isInserting) {
      context.missing(_rmsRawMeta);
    }
    if (data.containsKey('peak_raw')) {
      context.handle(_peakRawMeta,
          peakRaw.isAcceptableOrUnknown(data['peak_raw']!, _peakRawMeta));
    } else if (isInserting) {
      context.missing(_peakRawMeta);
    }
    if (data.containsKey('kurtosis')) {
      context.handle(_kurtosisMeta,
          kurtosis.isAcceptableOrUnknown(data['kurtosis']!, _kurtosisMeta));
    } else if (isInserting) {
      context.missing(_kurtosisMeta);
    }
    if (data.containsKey('bend_count')) {
      context.handle(_bendCountMeta,
          bendCount.isAcceptableOrUnknown(data['bend_count']!, _bendCountMeta));
    } else if (isInserting) {
      context.missing(_bendCountMeta);
    }
    if (data.containsKey('is_trustworthy')) {
      context.handle(
          _isTrustworthyMeta,
          isTrustworthy.isAcceptableOrUnknown(
              data['is_trustworthy']!, _isTrustworthyMeta));
    }
    if (data.containsKey('warning_note')) {
      context.handle(
          _warningNoteMeta,
          warningNote.isAcceptableOrUnknown(
              data['warning_note']!, _warningNoteMeta));
    }
    if (data.containsKey('analysed_at')) {
      context.handle(
          _analysedAtMeta,
          analysedAt.isAcceptableOrUnknown(
              data['analysed_at']!, _analysedAtMeta));
    } else if (isInserting) {
      context.missing(_analysedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionFeature map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionFeature(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}session_id'])!,
      roughnessScore: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}roughness_score'])!,
      maxFlexionDeg: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}max_flexion_deg'])!,
      rangeOfMotionDeg: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}range_of_motion_deg'])!,
      avgBendTimeS: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}avg_bend_time_s'])!,
      vibBurstCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}vib_burst_count'])!,
      burstAngleMin: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}burst_angle_min'])!,
      burstAngleMax: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}burst_angle_max'])!,
      rmsRaw: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}rms_raw'])!,
      peakRaw: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}peak_raw'])!,
      kurtosis: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}kurtosis'])!,
      bendCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}bend_count'])!,
      isTrustworthy: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_trustworthy'])!,
      warningNote: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}warning_note']),
      analysedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}analysed_at'])!,
    );
  }

  @override
  $SessionFeaturesTable createAlias(String alias) {
    return $SessionFeaturesTable(attachedDatabase, alias);
  }
}

class SessionFeature extends DataClass implements Insertable<SessionFeature> {
  final int id;
  final int sessionId;
  final double roughnessScore;
  final double maxFlexionDeg;
  final double rangeOfMotionDeg;
  final double avgBendTimeS;
  final int vibBurstCount;
  final double burstAngleMin;
  final double burstAngleMax;
  final double rmsRaw;
  final double peakRaw;
  final double kurtosis;
  final int bendCount;
  final bool isTrustworthy;
  final String? warningNote;
  final DateTime analysedAt;
  const SessionFeature(
      {required this.id,
      required this.sessionId,
      required this.roughnessScore,
      required this.maxFlexionDeg,
      required this.rangeOfMotionDeg,
      required this.avgBendTimeS,
      required this.vibBurstCount,
      required this.burstAngleMin,
      required this.burstAngleMax,
      required this.rmsRaw,
      required this.peakRaw,
      required this.kurtosis,
      required this.bendCount,
      required this.isTrustworthy,
      this.warningNote,
      required this.analysedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['roughness_score'] = Variable<double>(roughnessScore);
    map['max_flexion_deg'] = Variable<double>(maxFlexionDeg);
    map['range_of_motion_deg'] = Variable<double>(rangeOfMotionDeg);
    map['avg_bend_time_s'] = Variable<double>(avgBendTimeS);
    map['vib_burst_count'] = Variable<int>(vibBurstCount);
    map['burst_angle_min'] = Variable<double>(burstAngleMin);
    map['burst_angle_max'] = Variable<double>(burstAngleMax);
    map['rms_raw'] = Variable<double>(rmsRaw);
    map['peak_raw'] = Variable<double>(peakRaw);
    map['kurtosis'] = Variable<double>(kurtosis);
    map['bend_count'] = Variable<int>(bendCount);
    map['is_trustworthy'] = Variable<bool>(isTrustworthy);
    if (!nullToAbsent || warningNote != null) {
      map['warning_note'] = Variable<String>(warningNote);
    }
    map['analysed_at'] = Variable<DateTime>(analysedAt);
    return map;
  }

  SessionFeaturesCompanion toCompanion(bool nullToAbsent) {
    return SessionFeaturesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      roughnessScore: Value(roughnessScore),
      maxFlexionDeg: Value(maxFlexionDeg),
      rangeOfMotionDeg: Value(rangeOfMotionDeg),
      avgBendTimeS: Value(avgBendTimeS),
      vibBurstCount: Value(vibBurstCount),
      burstAngleMin: Value(burstAngleMin),
      burstAngleMax: Value(burstAngleMax),
      rmsRaw: Value(rmsRaw),
      peakRaw: Value(peakRaw),
      kurtosis: Value(kurtosis),
      bendCount: Value(bendCount),
      isTrustworthy: Value(isTrustworthy),
      warningNote: warningNote == null && nullToAbsent
          ? const Value.absent()
          : Value(warningNote),
      analysedAt: Value(analysedAt),
    );
  }

  factory SessionFeature.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionFeature(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      roughnessScore: serializer.fromJson<double>(json['roughnessScore']),
      maxFlexionDeg: serializer.fromJson<double>(json['maxFlexionDeg']),
      rangeOfMotionDeg: serializer.fromJson<double>(json['rangeOfMotionDeg']),
      avgBendTimeS: serializer.fromJson<double>(json['avgBendTimeS']),
      vibBurstCount: serializer.fromJson<int>(json['vibBurstCount']),
      burstAngleMin: serializer.fromJson<double>(json['burstAngleMin']),
      burstAngleMax: serializer.fromJson<double>(json['burstAngleMax']),
      rmsRaw: serializer.fromJson<double>(json['rmsRaw']),
      peakRaw: serializer.fromJson<double>(json['peakRaw']),
      kurtosis: serializer.fromJson<double>(json['kurtosis']),
      bendCount: serializer.fromJson<int>(json['bendCount']),
      isTrustworthy: serializer.fromJson<bool>(json['isTrustworthy']),
      warningNote: serializer.fromJson<String?>(json['warningNote']),
      analysedAt: serializer.fromJson<DateTime>(json['analysedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'roughnessScore': serializer.toJson<double>(roughnessScore),
      'maxFlexionDeg': serializer.toJson<double>(maxFlexionDeg),
      'rangeOfMotionDeg': serializer.toJson<double>(rangeOfMotionDeg),
      'avgBendTimeS': serializer.toJson<double>(avgBendTimeS),
      'vibBurstCount': serializer.toJson<int>(vibBurstCount),
      'burstAngleMin': serializer.toJson<double>(burstAngleMin),
      'burstAngleMax': serializer.toJson<double>(burstAngleMax),
      'rmsRaw': serializer.toJson<double>(rmsRaw),
      'peakRaw': serializer.toJson<double>(peakRaw),
      'kurtosis': serializer.toJson<double>(kurtosis),
      'bendCount': serializer.toJson<int>(bendCount),
      'isTrustworthy': serializer.toJson<bool>(isTrustworthy),
      'warningNote': serializer.toJson<String?>(warningNote),
      'analysedAt': serializer.toJson<DateTime>(analysedAt),
    };
  }

  SessionFeature copyWith(
          {int? id,
          int? sessionId,
          double? roughnessScore,
          double? maxFlexionDeg,
          double? rangeOfMotionDeg,
          double? avgBendTimeS,
          int? vibBurstCount,
          double? burstAngleMin,
          double? burstAngleMax,
          double? rmsRaw,
          double? peakRaw,
          double? kurtosis,
          int? bendCount,
          bool? isTrustworthy,
          Value<String?> warningNote = const Value.absent(),
          DateTime? analysedAt}) =>
      SessionFeature(
        id: id ?? this.id,
        sessionId: sessionId ?? this.sessionId,
        roughnessScore: roughnessScore ?? this.roughnessScore,
        maxFlexionDeg: maxFlexionDeg ?? this.maxFlexionDeg,
        rangeOfMotionDeg: rangeOfMotionDeg ?? this.rangeOfMotionDeg,
        avgBendTimeS: avgBendTimeS ?? this.avgBendTimeS,
        vibBurstCount: vibBurstCount ?? this.vibBurstCount,
        burstAngleMin: burstAngleMin ?? this.burstAngleMin,
        burstAngleMax: burstAngleMax ?? this.burstAngleMax,
        rmsRaw: rmsRaw ?? this.rmsRaw,
        peakRaw: peakRaw ?? this.peakRaw,
        kurtosis: kurtosis ?? this.kurtosis,
        bendCount: bendCount ?? this.bendCount,
        isTrustworthy: isTrustworthy ?? this.isTrustworthy,
        warningNote: warningNote.present ? warningNote.value : this.warningNote,
        analysedAt: analysedAt ?? this.analysedAt,
      );
  SessionFeature copyWithCompanion(SessionFeaturesCompanion data) {
    return SessionFeature(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      roughnessScore: data.roughnessScore.present
          ? data.roughnessScore.value
          : this.roughnessScore,
      maxFlexionDeg: data.maxFlexionDeg.present
          ? data.maxFlexionDeg.value
          : this.maxFlexionDeg,
      rangeOfMotionDeg: data.rangeOfMotionDeg.present
          ? data.rangeOfMotionDeg.value
          : this.rangeOfMotionDeg,
      avgBendTimeS: data.avgBendTimeS.present
          ? data.avgBendTimeS.value
          : this.avgBendTimeS,
      vibBurstCount: data.vibBurstCount.present
          ? data.vibBurstCount.value
          : this.vibBurstCount,
      burstAngleMin: data.burstAngleMin.present
          ? data.burstAngleMin.value
          : this.burstAngleMin,
      burstAngleMax: data.burstAngleMax.present
          ? data.burstAngleMax.value
          : this.burstAngleMax,
      rmsRaw: data.rmsRaw.present ? data.rmsRaw.value : this.rmsRaw,
      peakRaw: data.peakRaw.present ? data.peakRaw.value : this.peakRaw,
      kurtosis: data.kurtosis.present ? data.kurtosis.value : this.kurtosis,
      bendCount: data.bendCount.present ? data.bendCount.value : this.bendCount,
      isTrustworthy: data.isTrustworthy.present
          ? data.isTrustworthy.value
          : this.isTrustworthy,
      warningNote:
          data.warningNote.present ? data.warningNote.value : this.warningNote,
      analysedAt:
          data.analysedAt.present ? data.analysedAt.value : this.analysedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionFeature(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('roughnessScore: $roughnessScore, ')
          ..write('maxFlexionDeg: $maxFlexionDeg, ')
          ..write('rangeOfMotionDeg: $rangeOfMotionDeg, ')
          ..write('avgBendTimeS: $avgBendTimeS, ')
          ..write('vibBurstCount: $vibBurstCount, ')
          ..write('burstAngleMin: $burstAngleMin, ')
          ..write('burstAngleMax: $burstAngleMax, ')
          ..write('rmsRaw: $rmsRaw, ')
          ..write('peakRaw: $peakRaw, ')
          ..write('kurtosis: $kurtosis, ')
          ..write('bendCount: $bendCount, ')
          ..write('isTrustworthy: $isTrustworthy, ')
          ..write('warningNote: $warningNote, ')
          ..write('analysedAt: $analysedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      sessionId,
      roughnessScore,
      maxFlexionDeg,
      rangeOfMotionDeg,
      avgBendTimeS,
      vibBurstCount,
      burstAngleMin,
      burstAngleMax,
      rmsRaw,
      peakRaw,
      kurtosis,
      bendCount,
      isTrustworthy,
      warningNote,
      analysedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionFeature &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.roughnessScore == this.roughnessScore &&
          other.maxFlexionDeg == this.maxFlexionDeg &&
          other.rangeOfMotionDeg == this.rangeOfMotionDeg &&
          other.avgBendTimeS == this.avgBendTimeS &&
          other.vibBurstCount == this.vibBurstCount &&
          other.burstAngleMin == this.burstAngleMin &&
          other.burstAngleMax == this.burstAngleMax &&
          other.rmsRaw == this.rmsRaw &&
          other.peakRaw == this.peakRaw &&
          other.kurtosis == this.kurtosis &&
          other.bendCount == this.bendCount &&
          other.isTrustworthy == this.isTrustworthy &&
          other.warningNote == this.warningNote &&
          other.analysedAt == this.analysedAt);
}

class SessionFeaturesCompanion extends UpdateCompanion<SessionFeature> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<double> roughnessScore;
  final Value<double> maxFlexionDeg;
  final Value<double> rangeOfMotionDeg;
  final Value<double> avgBendTimeS;
  final Value<int> vibBurstCount;
  final Value<double> burstAngleMin;
  final Value<double> burstAngleMax;
  final Value<double> rmsRaw;
  final Value<double> peakRaw;
  final Value<double> kurtosis;
  final Value<int> bendCount;
  final Value<bool> isTrustworthy;
  final Value<String?> warningNote;
  final Value<DateTime> analysedAt;
  const SessionFeaturesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.roughnessScore = const Value.absent(),
    this.maxFlexionDeg = const Value.absent(),
    this.rangeOfMotionDeg = const Value.absent(),
    this.avgBendTimeS = const Value.absent(),
    this.vibBurstCount = const Value.absent(),
    this.burstAngleMin = const Value.absent(),
    this.burstAngleMax = const Value.absent(),
    this.rmsRaw = const Value.absent(),
    this.peakRaw = const Value.absent(),
    this.kurtosis = const Value.absent(),
    this.bendCount = const Value.absent(),
    this.isTrustworthy = const Value.absent(),
    this.warningNote = const Value.absent(),
    this.analysedAt = const Value.absent(),
  });
  SessionFeaturesCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required double roughnessScore,
    required double maxFlexionDeg,
    required double rangeOfMotionDeg,
    required double avgBendTimeS,
    required int vibBurstCount,
    required double burstAngleMin,
    required double burstAngleMax,
    required double rmsRaw,
    required double peakRaw,
    required double kurtosis,
    required int bendCount,
    this.isTrustworthy = const Value.absent(),
    this.warningNote = const Value.absent(),
    required DateTime analysedAt,
  })  : sessionId = Value(sessionId),
        roughnessScore = Value(roughnessScore),
        maxFlexionDeg = Value(maxFlexionDeg),
        rangeOfMotionDeg = Value(rangeOfMotionDeg),
        avgBendTimeS = Value(avgBendTimeS),
        vibBurstCount = Value(vibBurstCount),
        burstAngleMin = Value(burstAngleMin),
        burstAngleMax = Value(burstAngleMax),
        rmsRaw = Value(rmsRaw),
        peakRaw = Value(peakRaw),
        kurtosis = Value(kurtosis),
        bendCount = Value(bendCount),
        analysedAt = Value(analysedAt);
  static Insertable<SessionFeature> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<double>? roughnessScore,
    Expression<double>? maxFlexionDeg,
    Expression<double>? rangeOfMotionDeg,
    Expression<double>? avgBendTimeS,
    Expression<int>? vibBurstCount,
    Expression<double>? burstAngleMin,
    Expression<double>? burstAngleMax,
    Expression<double>? rmsRaw,
    Expression<double>? peakRaw,
    Expression<double>? kurtosis,
    Expression<int>? bendCount,
    Expression<bool>? isTrustworthy,
    Expression<String>? warningNote,
    Expression<DateTime>? analysedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (roughnessScore != null) 'roughness_score': roughnessScore,
      if (maxFlexionDeg != null) 'max_flexion_deg': maxFlexionDeg,
      if (rangeOfMotionDeg != null) 'range_of_motion_deg': rangeOfMotionDeg,
      if (avgBendTimeS != null) 'avg_bend_time_s': avgBendTimeS,
      if (vibBurstCount != null) 'vib_burst_count': vibBurstCount,
      if (burstAngleMin != null) 'burst_angle_min': burstAngleMin,
      if (burstAngleMax != null) 'burst_angle_max': burstAngleMax,
      if (rmsRaw != null) 'rms_raw': rmsRaw,
      if (peakRaw != null) 'peak_raw': peakRaw,
      if (kurtosis != null) 'kurtosis': kurtosis,
      if (bendCount != null) 'bend_count': bendCount,
      if (isTrustworthy != null) 'is_trustworthy': isTrustworthy,
      if (warningNote != null) 'warning_note': warningNote,
      if (analysedAt != null) 'analysed_at': analysedAt,
    });
  }

  SessionFeaturesCompanion copyWith(
      {Value<int>? id,
      Value<int>? sessionId,
      Value<double>? roughnessScore,
      Value<double>? maxFlexionDeg,
      Value<double>? rangeOfMotionDeg,
      Value<double>? avgBendTimeS,
      Value<int>? vibBurstCount,
      Value<double>? burstAngleMin,
      Value<double>? burstAngleMax,
      Value<double>? rmsRaw,
      Value<double>? peakRaw,
      Value<double>? kurtosis,
      Value<int>? bendCount,
      Value<bool>? isTrustworthy,
      Value<String?>? warningNote,
      Value<DateTime>? analysedAt}) {
    return SessionFeaturesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      roughnessScore: roughnessScore ?? this.roughnessScore,
      maxFlexionDeg: maxFlexionDeg ?? this.maxFlexionDeg,
      rangeOfMotionDeg: rangeOfMotionDeg ?? this.rangeOfMotionDeg,
      avgBendTimeS: avgBendTimeS ?? this.avgBendTimeS,
      vibBurstCount: vibBurstCount ?? this.vibBurstCount,
      burstAngleMin: burstAngleMin ?? this.burstAngleMin,
      burstAngleMax: burstAngleMax ?? this.burstAngleMax,
      rmsRaw: rmsRaw ?? this.rmsRaw,
      peakRaw: peakRaw ?? this.peakRaw,
      kurtosis: kurtosis ?? this.kurtosis,
      bendCount: bendCount ?? this.bendCount,
      isTrustworthy: isTrustworthy ?? this.isTrustworthy,
      warningNote: warningNote ?? this.warningNote,
      analysedAt: analysedAt ?? this.analysedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (roughnessScore.present) {
      map['roughness_score'] = Variable<double>(roughnessScore.value);
    }
    if (maxFlexionDeg.present) {
      map['max_flexion_deg'] = Variable<double>(maxFlexionDeg.value);
    }
    if (rangeOfMotionDeg.present) {
      map['range_of_motion_deg'] = Variable<double>(rangeOfMotionDeg.value);
    }
    if (avgBendTimeS.present) {
      map['avg_bend_time_s'] = Variable<double>(avgBendTimeS.value);
    }
    if (vibBurstCount.present) {
      map['vib_burst_count'] = Variable<int>(vibBurstCount.value);
    }
    if (burstAngleMin.present) {
      map['burst_angle_min'] = Variable<double>(burstAngleMin.value);
    }
    if (burstAngleMax.present) {
      map['burst_angle_max'] = Variable<double>(burstAngleMax.value);
    }
    if (rmsRaw.present) {
      map['rms_raw'] = Variable<double>(rmsRaw.value);
    }
    if (peakRaw.present) {
      map['peak_raw'] = Variable<double>(peakRaw.value);
    }
    if (kurtosis.present) {
      map['kurtosis'] = Variable<double>(kurtosis.value);
    }
    if (bendCount.present) {
      map['bend_count'] = Variable<int>(bendCount.value);
    }
    if (isTrustworthy.present) {
      map['is_trustworthy'] = Variable<bool>(isTrustworthy.value);
    }
    if (warningNote.present) {
      map['warning_note'] = Variable<String>(warningNote.value);
    }
    if (analysedAt.present) {
      map['analysed_at'] = Variable<DateTime>(analysedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionFeaturesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('roughnessScore: $roughnessScore, ')
          ..write('maxFlexionDeg: $maxFlexionDeg, ')
          ..write('rangeOfMotionDeg: $rangeOfMotionDeg, ')
          ..write('avgBendTimeS: $avgBendTimeS, ')
          ..write('vibBurstCount: $vibBurstCount, ')
          ..write('burstAngleMin: $burstAngleMin, ')
          ..write('burstAngleMax: $burstAngleMax, ')
          ..write('rmsRaw: $rmsRaw, ')
          ..write('peakRaw: $peakRaw, ')
          ..write('kurtosis: $kurtosis, ')
          ..write('bendCount: $bendCount, ')
          ..write('isTrustworthy: $isTrustworthy, ')
          ..write('warningNote: $warningNote, ')
          ..write('analysedAt: $analysedAt')
          ..write(')'))
        .toString();
  }
}

class $ParticipantsTable extends Participants
    with TableInfo<$ParticipantsTable, Participant> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ParticipantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'participants';
  @override
  VerificationContext validateIntegrity(Insertable<Participant> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Participant map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Participant(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ParticipantsTable createAlias(String alias) {
    return $ParticipantsTable(attachedDatabase, alias);
  }
}

class Participant extends DataClass implements Insertable<Participant> {
  final String id;
  final DateTime createdAt;
  const Participant({required this.id, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ParticipantsCompanion toCompanion(bool nullToAbsent) {
    return ParticipantsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
    );
  }

  factory Participant.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Participant(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Participant copyWith({String? id, DateTime? createdAt}) => Participant(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
      );
  Participant copyWithCompanion(ParticipantsCompanion data) {
    return Participant(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Participant(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Participant &&
          other.id == this.id &&
          other.createdAt == this.createdAt);
}

class ParticipantsCompanion extends UpdateCompanion<Participant> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ParticipantsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ParticipantsCompanion.insert({
    required String id,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        createdAt = Value(createdAt);
  static Insertable<Participant> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ParticipantsCompanion copyWith(
      {Value<String>? id, Value<DateTime>? createdAt, Value<int>? rowid}) {
    return ParticipantsCompanion(
      id: id ?? this.id,
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
    return (StringBuffer('ParticipantsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $SessionFeaturesTable sessionFeatures =
      $SessionFeaturesTable(this);
  late final $ParticipantsTable participants = $ParticipantsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [sessions, sessionFeatures, participants];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('sessions',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('session_features', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$SessionsTableCreateCompanionBuilder = SessionsCompanion Function({
  Value<int> id,
  required String name,
  required String participantId,
  required String side,
  required DateTime recordedAt,
  required int durationSeconds,
  Value<int> missedSamples,
  Value<String> syncStatus,
  Value<String?> localPath,
  Value<bool> isAnalysed,
});
typedef $$SessionsTableUpdateCompanionBuilder = SessionsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> participantId,
  Value<String> side,
  Value<DateTime> recordedAt,
  Value<int> durationSeconds,
  Value<int> missedSamples,
  Value<String> syncStatus,
  Value<String?> localPath,
  Value<bool> isAnalysed,
});

final class $$SessionsTableReferences
    extends BaseReferences<_$AppDatabase, $SessionsTable, Session> {
  $$SessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SessionFeaturesTable, List<SessionFeature>>
      _sessionFeaturesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.sessionFeatures,
              aliasName: 'sessions__id__session_features__session_id');

  $$SessionFeaturesTableProcessedTableManager get sessionFeaturesRefs {
    final manager =
        $$SessionFeaturesTableTableManager($_db, $_db.sessionFeatures)
            .filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_sessionFeaturesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get participantId => $composableBuilder(
      column: $table.participantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get side => $composableBuilder(
      column: $table.side, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get missedSamples => $composableBuilder(
      column: $table.missedSamples, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isAnalysed => $composableBuilder(
      column: $table.isAnalysed, builder: (column) => ColumnFilters(column));

  Expression<bool> sessionFeaturesRefs(
      Expression<bool> Function($$SessionFeaturesTableFilterComposer f) f) {
    final $$SessionFeaturesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sessionFeatures,
        getReferencedColumn: (t) => t.sessionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionFeaturesTableFilterComposer(
              $db: $db,
              $table: $db.sessionFeatures,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get participantId => $composableBuilder(
      column: $table.participantId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get side => $composableBuilder(
      column: $table.side, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get missedSamples => $composableBuilder(
      column: $table.missedSamples,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isAnalysed => $composableBuilder(
      column: $table.isAnalysed, builder: (column) => ColumnOrderings(column));
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
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

  GeneratedColumn<String> get participantId => $composableBuilder(
      column: $table.participantId, builder: (column) => column);

  GeneratedColumn<String> get side =>
      $composableBuilder(column: $table.side, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds, builder: (column) => column);

  GeneratedColumn<int> get missedSamples => $composableBuilder(
      column: $table.missedSamples, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<bool> get isAnalysed => $composableBuilder(
      column: $table.isAnalysed, builder: (column) => column);

  Expression<T> sessionFeaturesRefs<T extends Object>(
      Expression<T> Function($$SessionFeaturesTableAnnotationComposer a) f) {
    final $$SessionFeaturesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sessionFeatures,
        getReferencedColumn: (t) => t.sessionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionFeaturesTableAnnotationComposer(
              $db: $db,
              $table: $db.sessionFeatures,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SessionsTable,
    Session,
    $$SessionsTableFilterComposer,
    $$SessionsTableOrderingComposer,
    $$SessionsTableAnnotationComposer,
    $$SessionsTableCreateCompanionBuilder,
    $$SessionsTableUpdateCompanionBuilder,
    (Session, $$SessionsTableReferences),
    Session,
    PrefetchHooks Function({bool sessionFeaturesRefs})> {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> participantId = const Value.absent(),
            Value<String> side = const Value.absent(),
            Value<DateTime> recordedAt = const Value.absent(),
            Value<int> durationSeconds = const Value.absent(),
            Value<int> missedSamples = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<String?> localPath = const Value.absent(),
            Value<bool> isAnalysed = const Value.absent(),
          }) =>
              SessionsCompanion(
            id: id,
            name: name,
            participantId: participantId,
            side: side,
            recordedAt: recordedAt,
            durationSeconds: durationSeconds,
            missedSamples: missedSamples,
            syncStatus: syncStatus,
            localPath: localPath,
            isAnalysed: isAnalysed,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String participantId,
            required String side,
            required DateTime recordedAt,
            required int durationSeconds,
            Value<int> missedSamples = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<String?> localPath = const Value.absent(),
            Value<bool> isAnalysed = const Value.absent(),
          }) =>
              SessionsCompanion.insert(
            id: id,
            name: name,
            participantId: participantId,
            side: side,
            recordedAt: recordedAt,
            durationSeconds: durationSeconds,
            missedSamples: missedSamples,
            syncStatus: syncStatus,
            localPath: localPath,
            isAnalysed: isAnalysed,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$SessionsTable, Session>(table),
                    $$SessionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({sessionFeaturesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (sessionFeaturesRefs) db.sessionFeatures
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (sessionFeaturesRefs)
                    await $_getPrefetchedData<Session, $SessionsTable,
                            SessionFeature>(
                        currentTable: table,
                        referencedTable: $$SessionsTableReferences
                            ._sessionFeaturesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SessionsTableReferences(db, table, p0)
                                .sessionFeaturesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.sessionId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SessionsTable,
    Session,
    $$SessionsTableFilterComposer,
    $$SessionsTableOrderingComposer,
    $$SessionsTableAnnotationComposer,
    $$SessionsTableCreateCompanionBuilder,
    $$SessionsTableUpdateCompanionBuilder,
    (Session, $$SessionsTableReferences),
    Session,
    PrefetchHooks Function({bool sessionFeaturesRefs})>;
typedef $$SessionFeaturesTableCreateCompanionBuilder = SessionFeaturesCompanion
    Function({
  Value<int> id,
  required int sessionId,
  required double roughnessScore,
  required double maxFlexionDeg,
  required double rangeOfMotionDeg,
  required double avgBendTimeS,
  required int vibBurstCount,
  required double burstAngleMin,
  required double burstAngleMax,
  required double rmsRaw,
  required double peakRaw,
  required double kurtosis,
  required int bendCount,
  Value<bool> isTrustworthy,
  Value<String?> warningNote,
  required DateTime analysedAt,
});
typedef $$SessionFeaturesTableUpdateCompanionBuilder = SessionFeaturesCompanion
    Function({
  Value<int> id,
  Value<int> sessionId,
  Value<double> roughnessScore,
  Value<double> maxFlexionDeg,
  Value<double> rangeOfMotionDeg,
  Value<double> avgBendTimeS,
  Value<int> vibBurstCount,
  Value<double> burstAngleMin,
  Value<double> burstAngleMax,
  Value<double> rmsRaw,
  Value<double> peakRaw,
  Value<double> kurtosis,
  Value<int> bendCount,
  Value<bool> isTrustworthy,
  Value<String?> warningNote,
  Value<DateTime> analysedAt,
});

final class $$SessionFeaturesTableReferences extends BaseReferences<
    _$AppDatabase, $SessionFeaturesTable, SessionFeature> {
  $$SessionFeaturesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias('session_features__session_id__sessions__id');

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$SessionsTableTableManager($_db, $_db.sessions)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SessionFeaturesTableFilterComposer
    extends Composer<_$AppDatabase, $SessionFeaturesTable> {
  $$SessionFeaturesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get roughnessScore => $composableBuilder(
      column: $table.roughnessScore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get maxFlexionDeg => $composableBuilder(
      column: $table.maxFlexionDeg, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get rangeOfMotionDeg => $composableBuilder(
      column: $table.rangeOfMotionDeg,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get avgBendTimeS => $composableBuilder(
      column: $table.avgBendTimeS, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get vibBurstCount => $composableBuilder(
      column: $table.vibBurstCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get burstAngleMin => $composableBuilder(
      column: $table.burstAngleMin, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get burstAngleMax => $composableBuilder(
      column: $table.burstAngleMax, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get rmsRaw => $composableBuilder(
      column: $table.rmsRaw, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get peakRaw => $composableBuilder(
      column: $table.peakRaw, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get kurtosis => $composableBuilder(
      column: $table.kurtosis, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bendCount => $composableBuilder(
      column: $table.bendCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isTrustworthy => $composableBuilder(
      column: $table.isTrustworthy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get warningNote => $composableBuilder(
      column: $table.warningNote, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get analysedAt => $composableBuilder(
      column: $table.analysedAt, builder: (column) => ColumnFilters(column));

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.sessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionsTableFilterComposer(
              $db: $db,
              $table: $db.sessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SessionFeaturesTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionFeaturesTable> {
  $$SessionFeaturesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get roughnessScore => $composableBuilder(
      column: $table.roughnessScore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get maxFlexionDeg => $composableBuilder(
      column: $table.maxFlexionDeg,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get rangeOfMotionDeg => $composableBuilder(
      column: $table.rangeOfMotionDeg,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get avgBendTimeS => $composableBuilder(
      column: $table.avgBendTimeS,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get vibBurstCount => $composableBuilder(
      column: $table.vibBurstCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get burstAngleMin => $composableBuilder(
      column: $table.burstAngleMin,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get burstAngleMax => $composableBuilder(
      column: $table.burstAngleMax,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get rmsRaw => $composableBuilder(
      column: $table.rmsRaw, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get peakRaw => $composableBuilder(
      column: $table.peakRaw, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get kurtosis => $composableBuilder(
      column: $table.kurtosis, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bendCount => $composableBuilder(
      column: $table.bendCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isTrustworthy => $composableBuilder(
      column: $table.isTrustworthy,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get warningNote => $composableBuilder(
      column: $table.warningNote, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get analysedAt => $composableBuilder(
      column: $table.analysedAt, builder: (column) => ColumnOrderings(column));

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.sessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionsTableOrderingComposer(
              $db: $db,
              $table: $db.sessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SessionFeaturesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionFeaturesTable> {
  $$SessionFeaturesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get roughnessScore => $composableBuilder(
      column: $table.roughnessScore, builder: (column) => column);

  GeneratedColumn<double> get maxFlexionDeg => $composableBuilder(
      column: $table.maxFlexionDeg, builder: (column) => column);

  GeneratedColumn<double> get rangeOfMotionDeg => $composableBuilder(
      column: $table.rangeOfMotionDeg, builder: (column) => column);

  GeneratedColumn<double> get avgBendTimeS => $composableBuilder(
      column: $table.avgBendTimeS, builder: (column) => column);

  GeneratedColumn<int> get vibBurstCount => $composableBuilder(
      column: $table.vibBurstCount, builder: (column) => column);

  GeneratedColumn<double> get burstAngleMin => $composableBuilder(
      column: $table.burstAngleMin, builder: (column) => column);

  GeneratedColumn<double> get burstAngleMax => $composableBuilder(
      column: $table.burstAngleMax, builder: (column) => column);

  GeneratedColumn<double> get rmsRaw =>
      $composableBuilder(column: $table.rmsRaw, builder: (column) => column);

  GeneratedColumn<double> get peakRaw =>
      $composableBuilder(column: $table.peakRaw, builder: (column) => column);

  GeneratedColumn<double> get kurtosis =>
      $composableBuilder(column: $table.kurtosis, builder: (column) => column);

  GeneratedColumn<int> get bendCount =>
      $composableBuilder(column: $table.bendCount, builder: (column) => column);

  GeneratedColumn<bool> get isTrustworthy => $composableBuilder(
      column: $table.isTrustworthy, builder: (column) => column);

  GeneratedColumn<String> get warningNote => $composableBuilder(
      column: $table.warningNote, builder: (column) => column);

  GeneratedColumn<DateTime> get analysedAt => $composableBuilder(
      column: $table.analysedAt, builder: (column) => column);

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.sessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionsTableAnnotationComposer(
              $db: $db,
              $table: $db.sessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SessionFeaturesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SessionFeaturesTable,
    SessionFeature,
    $$SessionFeaturesTableFilterComposer,
    $$SessionFeaturesTableOrderingComposer,
    $$SessionFeaturesTableAnnotationComposer,
    $$SessionFeaturesTableCreateCompanionBuilder,
    $$SessionFeaturesTableUpdateCompanionBuilder,
    (SessionFeature, $$SessionFeaturesTableReferences),
    SessionFeature,
    PrefetchHooks Function({bool sessionId})> {
  $$SessionFeaturesTableTableManager(
      _$AppDatabase db, $SessionFeaturesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionFeaturesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionFeaturesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionFeaturesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> sessionId = const Value.absent(),
            Value<double> roughnessScore = const Value.absent(),
            Value<double> maxFlexionDeg = const Value.absent(),
            Value<double> rangeOfMotionDeg = const Value.absent(),
            Value<double> avgBendTimeS = const Value.absent(),
            Value<int> vibBurstCount = const Value.absent(),
            Value<double> burstAngleMin = const Value.absent(),
            Value<double> burstAngleMax = const Value.absent(),
            Value<double> rmsRaw = const Value.absent(),
            Value<double> peakRaw = const Value.absent(),
            Value<double> kurtosis = const Value.absent(),
            Value<int> bendCount = const Value.absent(),
            Value<bool> isTrustworthy = const Value.absent(),
            Value<String?> warningNote = const Value.absent(),
            Value<DateTime> analysedAt = const Value.absent(),
          }) =>
              SessionFeaturesCompanion(
            id: id,
            sessionId: sessionId,
            roughnessScore: roughnessScore,
            maxFlexionDeg: maxFlexionDeg,
            rangeOfMotionDeg: rangeOfMotionDeg,
            avgBendTimeS: avgBendTimeS,
            vibBurstCount: vibBurstCount,
            burstAngleMin: burstAngleMin,
            burstAngleMax: burstAngleMax,
            rmsRaw: rmsRaw,
            peakRaw: peakRaw,
            kurtosis: kurtosis,
            bendCount: bendCount,
            isTrustworthy: isTrustworthy,
            warningNote: warningNote,
            analysedAt: analysedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int sessionId,
            required double roughnessScore,
            required double maxFlexionDeg,
            required double rangeOfMotionDeg,
            required double avgBendTimeS,
            required int vibBurstCount,
            required double burstAngleMin,
            required double burstAngleMax,
            required double rmsRaw,
            required double peakRaw,
            required double kurtosis,
            required int bendCount,
            Value<bool> isTrustworthy = const Value.absent(),
            Value<String?> warningNote = const Value.absent(),
            required DateTime analysedAt,
          }) =>
              SessionFeaturesCompanion.insert(
            id: id,
            sessionId: sessionId,
            roughnessScore: roughnessScore,
            maxFlexionDeg: maxFlexionDeg,
            rangeOfMotionDeg: rangeOfMotionDeg,
            avgBendTimeS: avgBendTimeS,
            vibBurstCount: vibBurstCount,
            burstAngleMin: burstAngleMin,
            burstAngleMax: burstAngleMax,
            rmsRaw: rmsRaw,
            peakRaw: peakRaw,
            kurtosis: kurtosis,
            bendCount: bendCount,
            isTrustworthy: isTrustworthy,
            warningNote: warningNote,
            analysedAt: analysedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$SessionFeaturesTable, SessionFeature>(table),
                    $$SessionFeaturesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (sessionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.sessionId,
                    referencedTable:
                        $$SessionFeaturesTableReferences._sessionIdTable(db),
                    referencedColumn:
                        $$SessionFeaturesTableReferences._sessionIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$SessionFeaturesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SessionFeaturesTable,
    SessionFeature,
    $$SessionFeaturesTableFilterComposer,
    $$SessionFeaturesTableOrderingComposer,
    $$SessionFeaturesTableAnnotationComposer,
    $$SessionFeaturesTableCreateCompanionBuilder,
    $$SessionFeaturesTableUpdateCompanionBuilder,
    (SessionFeature, $$SessionFeaturesTableReferences),
    SessionFeature,
    PrefetchHooks Function({bool sessionId})>;
typedef $$ParticipantsTableCreateCompanionBuilder = ParticipantsCompanion
    Function({
  required String id,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$ParticipantsTableUpdateCompanionBuilder = ParticipantsCompanion
    Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$ParticipantsTableFilterComposer
    extends Composer<_$AppDatabase, $ParticipantsTable> {
  $$ParticipantsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$ParticipantsTableOrderingComposer
    extends Composer<_$AppDatabase, $ParticipantsTable> {
  $$ParticipantsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ParticipantsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ParticipantsTable> {
  $$ParticipantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ParticipantsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ParticipantsTable,
    Participant,
    $$ParticipantsTableFilterComposer,
    $$ParticipantsTableOrderingComposer,
    $$ParticipantsTableAnnotationComposer,
    $$ParticipantsTableCreateCompanionBuilder,
    $$ParticipantsTableUpdateCompanionBuilder,
    (
      Participant,
      BaseReferences<_$AppDatabase, $ParticipantsTable, Participant>
    ),
    Participant,
    PrefetchHooks Function()> {
  $$ParticipantsTableTableManager(_$AppDatabase db, $ParticipantsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ParticipantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ParticipantsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ParticipantsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ParticipantsCompanion(
            id: id,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ParticipantsCompanion.insert(
            id: id,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ParticipantsTable, Participant>(table),
                    BaseReferences<_$AppDatabase, $ParticipantsTable,
                        Participant>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ParticipantsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ParticipantsTable,
    Participant,
    $$ParticipantsTableFilterComposer,
    $$ParticipantsTableOrderingComposer,
    $$ParticipantsTableAnnotationComposer,
    $$ParticipantsTableCreateCompanionBuilder,
    $$ParticipantsTableUpdateCompanionBuilder,
    (
      Participant,
      BaseReferences<_$AppDatabase, $ParticipantsTable, Participant>
    ),
    Participant,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$SessionFeaturesTableTableManager get sessionFeatures =>
      $$SessionFeaturesTableTableManager(_db, _db.sessionFeatures);
  $$ParticipantsTableTableManager get participants =>
      $$ParticipantsTableTableManager(_db, _db.participants);
}
