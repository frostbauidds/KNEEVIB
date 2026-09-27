// lib/features/sync/sync_screen.dart
// Wi-Fi hotspot sync: shows SSID/password, lists sessions, downloads with progress bars.

import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../core/ble/ble_constants.dart';
import '../../core/config/app_providers.dart';
import '../../core/db/app_database.dart';
import '../../core/router/app_router.dart';
import '../../core/wifi/session_file.dart';
import '../../core/wifi/wifi_sync_service.dart';
import '../../analysis/analysis_engine.dart';
import '../../analysis/data_models.dart';
import '../../analysis/file_parser.dart';

enum _SyncPhase {
  sendingSync,
  showingHotspot,
  listing,
  downloading,
  done,
  failed,
}

class _DownloadState {
  final String sessionName;
  final Map<String, DownloadProgress> files;
  bool complete;

  _DownloadState(this.sessionName)
      : files = {},
        complete = false;

  double get fraction {
    if (files.isEmpty) return 0.0;
    return files.values
            .map((f) => f.fraction)
            .reduce((a, b) => a + b) /
        files.length;
  }
}

class SyncScreen extends ConsumerStatefulWidget {
  const SyncScreen({super.key});

  @override
  ConsumerState<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends ConsumerState<SyncScreen> {
  _SyncPhase _phase = _SyncPhase.sendingSync;
  String? _ssid;
  String? _password;
  List<RemoteSession> _sessions = [];
  final Map<String, _DownloadState> _downloads = {};
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _initSync();
  }

  Future<void> _initSync() async {
    final ble = ref.read(bleServiceProvider);
    try {
      await ble.sendCommand(kCmdSync);
      // Wait for status update with SSID/password
      final status =
          await ble.statusStream.firstWhere((s) => s.ssid != null).timeout(
                const Duration(seconds: 10),
              );
      setState(() {
        _ssid = status.ssid;
        _password = status.password;
        _phase = _SyncPhase.showingHotspot;
      });
    } catch (e) {
      setState(() {
        _errorMsg = 'Could not enter sync mode: $e';
        _phase = _SyncPhase.failed;
      });
    }
  }

  Future<void> _listSessions() async {
    setState(() => _phase = _SyncPhase.listing);
    try {
      final wifi = ref.read(wifiSyncServiceProvider);
      final sessions = await wifi.listSessions();
      setState(() {
        _sessions = sessions;
        _phase = _SyncPhase.downloading;
      });
    } catch (e) {
      setState(() {
        _errorMsg = 'Failed to list sessions: $e';
        _phase = _SyncPhase.failed;
      });
    }
  }

  Future<void> _downloadAll() async {
    final wifi = ref.read(wifiSyncServiceProvider);
    final db = ref.read(databaseProvider);
    final docsDir = await getApplicationDocumentsDirectory();

    for (final session in _sessions) {
      final dl = _DownloadState(session.name);
      setState(() => _downloads[session.name] = dl);

      final sessionDir =
          Directory(p.join(docsDir.path, 'sessions', session.name));
      await sessionDir.create(recursive: true);

      final filesToDownload = [kFileVib, kFileImu, kFileMeta];
      for (final file in filesToDownload) {
        try {
          final bytes = await wifi.downloadFile(
            session.name,
            file,
            onProgress: (received, total) {
              setState(() {
                dl.files[file] = DownloadProgress(
                  sessionName: session.name,
                  fileName: file,
                  received: received,
                  total: total,
                );
              });
            },
          );
          // Save to disk
          await File(p.join(sessionDir.path, file)).writeAsBytes(bytes);
        } catch (e) {
          setState(() => _errorMsg =
              'Failed to download $file from ${session.name}: $e');
        }
      }
      dl.complete = true;

      // Trigger analysis
      _analyseSession(session.name, sessionDir.path, db);
    }

    // Tell device to exit sync mode
    try {
      await wifi.done();
    } catch (_) {}

    setState(() => _phase = _SyncPhase.done);
  }

  Future<void> _analyseSession(
      String name, String dir, AppDatabase db) async {
    try {
      final vibFile = File(p.join(dir, kFileVib));
      final imuFile = File(p.join(dir, kFileImu));
      final metaFile = File(p.join(dir, kFileMeta));

      if (!await vibFile.exists() ||
          !await imuFile.exists() ||
          !await metaFile.exists()) return;

      final meta = parseMetaJson(await metaFile.readAsString());

      // Insert session record
      final sessionId = await db.insertSession(SessionsCompanion.insert(
        name: name,
        participantId: meta.participantId,
        side: meta.side,
        recordedAt: DateTime.parse(meta.date.isNotEmpty
            ? meta.date
            : DateTime.now().toIso8601String()),
        durationSeconds: 120,
        missedSamples: Value(meta.missedSamples),
        syncStatus: const Value('synced'),
        localPath: Value(dir),
        isAnalysed: const Value(false),
      ));

      // Build scoring config (default weights — production would load from assets)
      const scoringConfigJson = <String, dynamic>{
        'features': {
          'rms_weight': 0.25,
          'peak_weight': 0.15,
          'kurtosis_weight': 0.25,
          'burst_count_weight': 0.20,
          'burst_angle_range_weight': 0.15,
        },
        'thresholds': {
          'green_max': 3.5,
          'yellow_max': 6.5,
          'missed_samples_warn_pct': 5.0,
          'min_recording_seconds': 30,
        },
        'normalization': {},
      };

      final input = AnalysisInput(
        vibBytes: await vibFile.readAsBytes(),
        imuCsv: await imuFile.readAsString(),
        metaJson: await metaFile.readAsString(),
        scoringConfigJson: scoringConfigJson,
      );

      final result = await Isolate.run(() => runAnalysis(input));

      // Save features
      await db.insertFeatures(SessionFeaturesCompanion.insert(
        sessionId: sessionId,
        roughnessScore: result.roughnessScore,
        maxFlexionDeg: result.maxFlexionDeg,
        rangeOfMotionDeg: result.rangeOfMotionDeg,
        avgBendTimeS: result.avgBendTimeS,
        vibBurstCount: result.vibBurstCount,
        burstAngleMin: result.burstAngleMin,
        burstAngleMax: result.burstAngleMax,
        rmsRaw: result.rmsRaw,
        peakRaw: result.peakRaw,
        kurtosis: result.kurtosis,
        bendCount: result.bendCount,
        isTrustworthy: Value(result.isTrustworthy),
        warningNote: Value(result.warningNote),
        analysedAt: DateTime.now(),
      ));

      await db.updateSession(
        SessionsCompanion(
          id: Value(sessionId),
          isAnalysed: const Value(true),
        ),
      );
    } catch (e) {
      debugPrint('Analysis failed for $name: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Sync Sessions')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: switch (_phase) {
            _SyncPhase.sendingSync => const _LoadingView(
                message: 'Entering sync mode…'),
            _SyncPhase.showingHotspot => _HotspotView(
                ssid: _ssid ?? '',
                password: _password ?? '',
                onReady: _listSessions,
              ),
            _SyncPhase.listing =>
              const _LoadingView(message: 'Listing sessions…'),
            _SyncPhase.downloading => _DownloadView(
                sessions: _sessions,
                downloads: _downloads,
                onDownload: _downloadAll,
              ),
            _SyncPhase.done => _DoneView(
                onGoToSessions: () => context.go(AppRoutes.sessionsList),
              ),
            _SyncPhase.failed => _FailedView(
                error: _errorMsg ?? 'Unknown error',
                onRetry: () {
                  setState(() {
                    _phase = _SyncPhase.sendingSync;
                    _errorMsg = null;
                  });
                  _initSync();
                },
              ),
          },
        ),
      ),
    );
  }
}

// ─── Sub-views ────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  final String message;
  const _LoadingView({required this.message});
  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(message, style: Theme.of(context).textTheme.titleMedium),
        ],
      );
}

class _HotspotView extends StatelessWidget {
  final String ssid;
  final String password;
  final VoidCallback onReady;
  const _HotspotView(
      {required this.ssid, required this.password, required this.onReady});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.wifi, size: 64, color: colorScheme.primary),
        const SizedBox(height: 24),
        Text('Join the device hotspot',
            style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          'Go to Wi-Fi settings and connect to:',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        _HotspotCredential(label: 'Network name', value: ssid),
        const SizedBox(height: 8),
        _HotspotCredential(label: 'Password', value: password),
        const SizedBox(height: 8),
        Card(
          color: colorScheme.tertiaryContainer.withOpacity(0.5),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.warning_amber,
                    color: colorScheme.tertiary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'This network has no internet. '
                    'Some apps may warn about that — it\'s normal.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onReady,
            icon: const Icon(Icons.check),
            label: const Text('I\'ve joined the network'),
          ),
        ),
      ],
    );
  }
}

class _HotspotCredential extends StatelessWidget {
  final String label;
  final String value;
  const _HotspotCredential({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  )),
              Text(value,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontFamily: 'monospace')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () =>
                Clipboard.setData(ClipboardData(text: value)),
            tooltip: 'Copy',
          ),
        ],
      ),
    );
  }
}

class _DownloadView extends StatelessWidget {
  final List<RemoteSession> sessions;
  final Map<String, _DownloadState> downloads;
  final VoidCallback onDownload;
  const _DownloadView(
      {required this.sessions,
      required this.downloads,
      required this.onDownload});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasStarted = downloads.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${sessions.length} session(s) found',
            style: theme.textTheme.titleLarge),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            itemCount: sessions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final s = sessions[i];
              final dl = downloads[s.name];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.name,
                          style: theme.textTheme.titleMedium),
                      Text(s.date,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          )),
                      Text(
                          '${(s.sizeBytes / 1024 / 1024).toStringAsFixed(1)} MB',
                          style: theme.textTheme.bodySmall),
                      if (dl != null) ...[
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: dl.fraction,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        if (dl.complete)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Downloaded ✓',
                              style: TextStyle(
                                  color: theme.colorScheme.primary),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        if (!hasStarted)
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onDownload,
              icon: const Icon(Icons.download),
              label: const Text('Download all'),
            ),
          ),
      ],
    );
  }
}

class _DoneView extends StatelessWidget {
  final VoidCallback onGoToSessions;
  const _DoneView({required this.onGoToSessions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.check_circle_outline, size: 80, color: colorScheme.primary),
        const SizedBox(height: 24),
        Text('Sync complete!', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          'All sessions downloaded.\n\nRemember to switch back to your normal Wi-Fi network.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 48),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onGoToSessions,
            icon: const Icon(Icons.folder_open),
            label: const Text('View sessions'),
          ),
        ),
      ],
    );
  }
}

class _FailedView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _FailedView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.wifi_off, size: 80, color: cs.error),
        const SizedBox(height: 24),
        Text('Sync failed', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(error,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: cs.error)),
        const SizedBox(height: 48),
        FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
        ),
      ],
    );
  }
}
