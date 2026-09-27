// lib/core/db/app_database.dart
// Drift SQLite database schema.

import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.drift.dart';

// ---------------------------------------------------------------------------
// Tables
// ---------------------------------------------------------------------------

class Sessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()(); // e.g. "20240101_P001_L"
  TextColumn get participantId => text()();
  TextColumn get side => text()(); // "L" or "R"
  DateTimeColumn get recordedAt => dateTime()();
  IntColumn get durationSeconds => integer()();
  IntColumn get missedSamples => integer().withDefault(const Constant(0))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  // 'pending' | 'synced' | 'failed'
  TextColumn get localPath => text().nullable()(); // path to folder on phone
  BoolColumn get isAnalysed => boolean().withDefault(const Constant(false))();
}

class SessionFeatures extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId =>
      integer().references(Sessions, #id, onDelete: KeyAction.cascade)();
  RealColumn get roughnessScore => real()(); // 0–10 prototype score
  RealColumn get maxFlexionDeg => real()();
  RealColumn get rangeOfMotionDeg => real()();
  RealColumn get avgBendTimeS => real()();
  IntColumn get vibBurstCount => integer()();
  RealColumn get burstAngleMin => real()();
  RealColumn get burstAngleMax => real()();
  RealColumn get rmsRaw => real()();
  RealColumn get peakRaw => real()();
  RealColumn get kurtosis => real()();
  IntColumn get bendCount => integer()();
  BoolColumn get isTrustworthy =>
      boolean().withDefault(const Constant(true))();
  TextColumn get warningNote => text().nullable()();
  DateTimeColumn get analysedAt => dateTime()();
}

class Participants extends Table {
  TextColumn get id => text()(); // e.g. "P001"
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Database
// ---------------------------------------------------------------------------

@DriftDatabase(tables: [Sessions, SessionFeatures, Participants])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
      );

  // --- Session queries ---

  Future<List<Session>> getAllSessions() =>
      (select(sessions)..orderBy([(s) => OrderingTerm.desc(s.recordedAt)]))
          .get();

  Future<List<Session>> getSessionsForParticipant(String participantId) =>
      (select(sessions)
            ..where((s) => s.participantId.equals(participantId))
            ..orderBy([(s) => OrderingTerm.asc(s.recordedAt)]))
          .get();

  Future<int> insertSession(SessionsCompanion session) =>
      into(sessions).insert(session);

  Future<bool> updateSession(SessionsCompanion session) =>
      update(sessions).replace(session);

  // --- Features ---

  Future<SessionFeature?> getFeaturesForSession(int sessionId) =>
      (select(sessionFeatures)
            ..where((f) => f.sessionId.equals(sessionId)))
          .getSingleOrNull();

  Future<int> insertFeatures(SessionFeaturesCompanion features) =>
      into(sessionFeatures).insert(features);

  // --- Participants ---

  Future<List<Participant>> getAllParticipants() =>
      select(participants).get();

  Future<void> insertParticipantIfAbsent(String id) async {
    await into(participants).insertOnConflictUpdate(
      ParticipantsCompanion.insert(id: id, createdAt: DateTime.now()),
    );
  }

  // --- Trend data ---

  Future<List<(Session, SessionFeature)>> getTrendData(
      String participantId) async {
    final rows = await (select(sessions)
          ..where((s) => s.participantId.equals(participantId))
          ..orderBy([(s) => OrderingTerm.asc(s.recordedAt)]))
        .get();
    final result = <(Session, SessionFeature)>[];
    for (final s in rows) {
      final f = await getFeaturesForSession(s.id);
      if (f != null) result.add((s, f));
    }
    return result;
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'kneevib_db');
}
