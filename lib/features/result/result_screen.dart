// lib/features/result/result_screen.dart
// Shows roughness score, all metrics, and L vs R comparison.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/config/app_providers.dart';
import '../../core/db/app_database.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';

final _resultProvider =
    FutureProvider.family<(Session, SessionFeature?, Session?, SessionFeature?),
        int>((ref, sessionId) async {
  final db = ref.watch(databaseProvider);
  final sessions = await db.getAllSessions();
  final session = sessions.firstWhere((s) => s.id == sessionId);
  final features = await db.getFeaturesForSession(sessionId);

  // Find opposite side for comparison
  Session? opposite;
  SessionFeature? oppositeFeatures;
  final oppSide = session.side == 'L' ? 'R' : 'L';
  final oppSessions = sessions.where((s) =>
      s.participantId == session.participantId && s.side == oppSide);
  if (oppSessions.isNotEmpty) {
    opposite = oppSessions.last;
    oppositeFeatures = await db.getFeaturesForSession(opposite.id);
  }

  return (session, features, opposite, oppositeFeatures);
});

class ResultScreen extends ConsumerWidget {
  final int sessionId;
  const ResultScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultAsync = ref.watch(_resultProvider(sessionId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Result'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Export',
            onPressed: () =>
                context.go('${AppRoutes.export_}/$sessionId'),
          ),
        ],
      ),
      body: resultAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (data) {
          final (session, features, opposite, oppFeatures) = data;
          return _ResultBody(
            session: session,
            features: features,
            opposite: opposite,
            oppFeatures: oppFeatures,
            isDark: isDark,
          );
        },
      ),
    );
  }
}

class _ResultBody extends StatelessWidget {
  final Session session;
  final SessionFeature? features;
  final Session? opposite;
  final SessionFeature? oppFeatures;
  final bool isDark;

  const _ResultBody({
    required this.session,
    required this.features,
    this.opposite,
    this.oppFeatures,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(session.participantId,
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800)),
                      Text(
                        '${session.side == "L" ? "Left" : "Right"} knee · '
                        '${DateFormat("MMM d, yyyy").format(session.recordedAt)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Warning if not trustworthy
          if (features != null && !features!.isTrustworthy)
            _WarningBanner(note: features!.warningNote),

          // Score gauge
          if (features != null)
            _ScoreGauge(score: features!.roughnessScore, isDark: isDark)
          else
            _AnalysingCard(),

          const SizedBox(height: 16),

          // Metrics grid
          if (features != null) _MetricsGrid(f: features!),

          const SizedBox(height: 16),

          // L vs R comparison
          if (features != null && oppFeatures != null)
            _ComparisonCard(
              session: session,
              features: features!,
              opposite: opposite!,
              oppFeatures: oppFeatures!,
              isDark: isDark,
            ),
        ],
      ),
    );
  }
}

class _ScoreGauge extends StatelessWidget {
  final double score;
  final bool isDark;
  const _ScoreGauge({required this.score, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = ScoreColors.badge(score, isDark);
    final label = ScoreColors.label(score);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  score.toStringAsFixed(1),
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(' / 10',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      )),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: ScoreColors.badgeText(score),
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Prototype score — not a medical diagnosis',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),
            // Score bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: score / 10,
                minHeight: 12,
                backgroundColor:
                    theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Low roughness',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
                Text('High roughness',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  final SessionFeature f;
  const _MetricsGrid({required this.f});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text('Measurements',
              style: Theme.of(context).textTheme.titleMedium),
        ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.6,
          children: [
            _MetricCard(
                label: 'Max flexion',
                value: '${f.maxFlexionDeg.toStringAsFixed(1)}°'),
            _MetricCard(
                label: 'Range of motion',
                value: '${f.rangeOfMotionDeg.toStringAsFixed(1)}°'),
            _MetricCard(
                label: 'Avg bend time',
                value: '${f.avgBendTimeS.toStringAsFixed(1)} s'),
            _MetricCard(
                label: 'Vib burst count',
                value: f.vibBurstCount.toString()),
            _MetricCard(
                label: 'Burst angle range',
                value:
                    '${f.burstAngleMin.toStringAsFixed(0)}° – ${f.burstAngleMax.toStringAsFixed(0)}°'),
            _MetricCard(label: 'Bend count', value: f.bendCount.toString()),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  const _MetricCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                )),
            const SizedBox(height: 4),
            Text(value,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _ComparisonCard extends StatelessWidget {
  final Session session;
  final SessionFeature features;
  final Session opposite;
  final SessionFeature oppFeatures;
  final bool isDark;

  const _ComparisonCard({
    required this.session,
    required this.features,
    required this.opposite,
    required this.oppFeatures,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Left vs Right comparison',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _ComparisonRow(
              label: 'Roughness score',
              leftVal: features.roughnessScore.toStringAsFixed(1),
              rightVal: oppFeatures.roughnessScore.toStringAsFixed(1),
              leftIsSession: session.side == 'L',
              isDark: isDark,
            ),
            _ComparisonRow(
              label: 'Max flexion',
              leftVal: session.side == 'L'
                  ? '${features.maxFlexionDeg.toStringAsFixed(1)}°'
                  : '${oppFeatures.maxFlexionDeg.toStringAsFixed(1)}°',
              rightVal: session.side == 'R'
                  ? '${features.maxFlexionDeg.toStringAsFixed(1)}°'
                  : '${oppFeatures.maxFlexionDeg.toStringAsFixed(1)}°',
              leftIsSession: session.side == 'L',
              isDark: isDark,
            ),
            _ComparisonRow(
              label: 'Burst count',
              leftVal: session.side == 'L'
                  ? features.vibBurstCount.toString()
                  : oppFeatures.vibBurstCount.toString(),
              rightVal: session.side == 'R'
                  ? features.vibBurstCount.toString()
                  : oppFeatures.vibBurstCount.toString(),
              leftIsSession: session.side == 'L',
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  final String label;
  final String leftVal;
  final String rightVal;
  final bool leftIsSession;
  final bool isDark;
  const _ComparisonRow(
      {required this.label,
      required this.leftVal,
      required this.rightVal,
      required this.leftIsSession,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(label, style: theme.textTheme.bodyMedium),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: leftIsSession
                    ? cs.primaryContainer
                    : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text('L',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant)),
                  Text(leftVal,
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: !leftIsSession
                    ? cs.primaryContainer
                    : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text('R',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant)),
                  Text(rightVal,
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WarningBanner extends StatelessWidget {
  final String? note;
  const _WarningBanner({this.note});
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.warning_amber,
                color: Theme.of(context).colorScheme.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                note ?? 'Results may not be reliable for this session.',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalysingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(strokeWidth: 3),
              SizedBox(width: 20),
              Text('Analysing recording…'),
            ],
          ),
        ),
      );
}
