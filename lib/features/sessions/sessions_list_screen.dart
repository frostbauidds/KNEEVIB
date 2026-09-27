// lib/features/sessions/sessions_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/config/app_providers.dart';
import '../../core/db/app_database.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';

final _sessionsListProvider = FutureProvider<
    List<(Session, SessionFeature?)>>((ref) async {
  final db = ref.watch(databaseProvider);
  final sessions = await db.getAllSessions();
  final result = <(Session, SessionFeature?)>[];
  for (final s in sessions) {
    final f = await db.getFeaturesForSession(s.id);
    result.add((s, f));
  }
  return result;
});

class SessionsListScreen extends ConsumerWidget {
  const SessionsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(_sessionsListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Sessions')),
      body: sessionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (sessions) {
          if (sessions.isEmpty) {
            return _EmptyState();
          }
          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, i) {
              final (session, features) = sessions[i];
              return _SessionTile(
                session: session,
                features: features,
                isDark: isDark,
                onTap: () => context.go('${AppRoutes.result}/${session.id}'),
              );
            },
          );
        },
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final Session session;
  final SessionFeature? features;
  final bool isDark;
  final VoidCallback onTap;

  const _SessionTile({
    required this.session,
    required this.features,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateStr = DateFormat('MMM d, yyyy  HH:mm').format(session.recordedAt);
    final score = features?.roughnessScore;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Side indicator
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    session.side,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(session.participantId,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    Text(dateStr,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        )),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _SyncChip(status: session.syncStatus),
                        if (session.missedSamples > 0) ...[
                          const SizedBox(width: 6),
                          const _WarnChip(),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Score badge
              if (score != null)
                _ScoreBadge(score: score, isDark: isDark)
              else if (!session.isAnalysed)
                Icon(Icons.hourglass_empty,
                    color: colorScheme.onSurfaceVariant),

              const SizedBox(width: 4),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final double score;
  final bool isDark;
  const _ScoreBadge({required this.score, required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: ScoreColors.badge(score, isDark),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          score.toStringAsFixed(1),
          style: TextStyle(
            color: ScoreColors.badgeText(score),
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      );
}

class _SyncChip extends StatelessWidget {
  final String status;
  const _SyncChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (label, color) = switch (status) {
      'synced' => ('Synced', colorScheme.primary),
      'failed' => ('Failed', colorScheme.error),
      _ => ('Pending', colorScheme.onSurfaceVariant),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _WarnChip extends StatelessWidget {
  const _WarnChip();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('High missed samples',
            style: TextStyle(
                fontSize: 11,
                color: Colors.orange,
                fontWeight: FontWeight.w600)),
      );
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_open,
                size: 80,
                color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 24),
            Text('No sessions yet', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Record a session and sync it from the device to see it here.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
