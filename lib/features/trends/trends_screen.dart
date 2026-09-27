// lib/features/trends/trends_screen.dart
// Line chart: roughness score and range of motion over time, by participant.

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/config/app_providers.dart';
import '../../core/db/app_database.dart';

final _participantsProvider = FutureProvider<List<Participant>>((ref) async {
  return ref.watch(databaseProvider).getAllParticipants();
});

final _selectedParticipantProvider =
    StateProvider<String?>((ref) => null);

final _trendDataProvider = FutureProvider.family<
    List<(Session, SessionFeature)>, String>((ref, participantId) async {
  return ref.watch(databaseProvider).getTrendData(participantId);
});

class TrendsScreen extends ConsumerWidget {
  const TrendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participantsAsync = ref.watch(_participantsProvider);
    final selectedId = ref.watch(_selectedParticipantProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Trends')),
      body: Column(
        children: [
          // Participant picker
          participantsAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox.shrink(),
            data: (participants) {
              if (participants.isEmpty) return const SizedBox.shrink();
              final current = selectedId ?? participants.first.id;
              return Padding(
                padding: const EdgeInsets.all(16),
                child: DropdownButtonFormField<String>(
                  value: current,
                  decoration: const InputDecoration(
                    labelText: 'Participant',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  items: participants
                      .map((p) => DropdownMenuItem(
                            value: p.id,
                            child: Text(p.id),
                          ))
                      .toList(),
                  onChanged: (v) => ref
                      .read(_selectedParticipantProvider.notifier)
                      .state = v,
                ),
              );
            },
          ),

          // Charts
          if (selectedId != null || true)
            Expanded(
              child: _TrendCharts(
                participantId: selectedId ??
                    ref.watch(_participantsProvider).value?.firstOrNull?.id ??
                    '',
              ),
            ),
        ],
      ),
    );
  }
}

class _TrendCharts extends ConsumerWidget {
  final String participantId;
  const _TrendCharts({required this.participantId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(_trendDataProvider(participantId));

    return dataAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (data) {
        if (data.isEmpty) {
          return _EmptyTrends();
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _LineChart(
                data: data,
                title: 'Roughness Score',
                valueExtractor: (f) => f.roughnessScore,
                color: Colors.redAccent,
                minY: 0,
                maxY: 10,
              ),
              const SizedBox(height: 24),
              _LineChart(
                data: data,
                title: 'Range of Motion (°)',
                valueExtractor: (f) => f.rangeOfMotionDeg,
                color: Colors.blueAccent,
                minY: 0,
                maxY: 150,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LineChart extends StatelessWidget {
  final List<(Session, SessionFeature)> data;
  final String title;
  final double Function(SessionFeature) valueExtractor;
  final Color color;
  final double minY;
  final double maxY;

  const _LineChart({
    required this.data,
    required this.title,
    required this.valueExtractor,
    required this.color,
    required this.minY,
    required this.maxY,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Build points grouped by side
    final lPoints = <FlSpot>[];
    final rPoints = <FlSpot>[];

    for (int i = 0; i < data.length; i++) {
      final (session, features) = data[i];
      final x = session.recordedAt.millisecondsSinceEpoch.toDouble();
      final y = valueExtractor(features);
      if (session.side == 'L') {
        lPoints.add(FlSpot(x, y));
      } else {
        rPoints.add(FlSpot(x, y));
      }
    }

    // Use index-based x for simplicity
    final lSpots = [for (int i = 0; i < lPoints.length; i++) FlSpot(i.toDouble(), lPoints[i].y)];
    final rSpots = [for (int i = 0; i < rPoints.length; i++) FlSpot(i.toDouble(), rPoints[i].y)];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Row(children: [
              _Legend(color: Colors.blueAccent, label: 'Left'),
              const SizedBox(width: 16),
              _Legend(color: Colors.orangeAccent, label: 'Right'),
            ]),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  minY: minY,
                  maxY: maxY,
                  gridData: FlGridData(
                    drawVerticalLine: false,
                    horizontalInterval: (maxY - minY) / 5,
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        getTitlesWidget: (v, _) => Text(
                          v.toStringAsFixed(0),
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          final idx = v.toInt();
                          if (idx < 0 || idx >= lPoints.length) {
                            return const SizedBox.shrink();
                          }
                          final d = data
                              .where((e) => e.$1.side == 'L')
                              .elementAtOrNull(idx)
                              ?.$1
                              .recordedAt;
                          if (d == null) return const SizedBox.shrink();
                          return Text(
                            DateFormat('M/d').format(d),
                            style: const TextStyle(fontSize: 9),
                          );
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    if (lSpots.isNotEmpty)
                      LineChartBarData(
                        spots: lSpots,
                        isCurved: true,
                        color: Colors.blueAccent,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.blueAccent.withOpacity(0.1),
                        ),
                      ),
                    if (rSpots.isNotEmpty)
                      LineChartBarData(
                        spots: rSpots,
                        isCurved: true,
                        color: Colors.orangeAccent,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.orangeAccent.withOpacity(0.1),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      );
}

class _EmptyTrends extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.show_chart,
                  size: 80,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(height: 24),
              Text('No trend data yet',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Multiple sessions are needed to show trends.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
}
