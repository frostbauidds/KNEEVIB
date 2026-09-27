// lib/features/session/new_session_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/ble/ble_constants.dart';
import '../../core/config/app_providers.dart';
import '../../core/db/app_database.dart';
import '../../core/router/app_router.dart';

class NewSessionScreen extends ConsumerStatefulWidget {
  const NewSessionScreen({super.key});

  @override
  ConsumerState<NewSessionScreen> createState() => _NewSessionScreenState();
}

class _NewSessionScreenState extends ConsumerState<NewSessionScreen> {
  final _idController = TextEditingController();
  String _side = 'L';
  double _duration = 120;
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('New Session')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Participant ID
            Text('Participant ID', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _idController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                hintText: 'e.g. P001',
                prefixIcon: Icon(Icons.person_outline),
                helperText: 'Anonymous ID only — no names',
              ),
            ),
            const SizedBox(height: 24),

            // Knee side
            Text('Knee side', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                    value: 'L',
                    label: Text('Left'),
                    icon: Icon(Icons.arrow_back)),
                ButtonSegment(
                    value: 'R',
                    label: Text('Right'),
                    icon: Icon(Icons.arrow_forward)),
              ],
              selected: {_side},
              onSelectionChanged: (s) => setState(() => _side = s.first),
            ),
            const SizedBox(height: 24),

            // Duration
            Text('Duration: ${_duration.round()} seconds',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Slider(
              value: _duration,
              min: 60,
              max: 300,
              divisions: 8,
              label: '${_duration.round()} s',
              onChanged: (v) => setState(() => _duration = v),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('60 s',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant)),
                Text('5 min',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 8),

            // Info card
            Card(
              color: colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'The device will disconnect during recording. '
                        'The app will reconnect automatically when done.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Error
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(_error!,
                    style: TextStyle(color: colorScheme.error)),
              ),

            // Start button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _sending ? null : _startSession,
                icon: _sending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.fiber_manual_record),
                label: const Text('Start recording'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startSession() async {
    final pid = _idController.text.trim();
    if (pid.isEmpty) {
      setState(() => _error = 'Please enter a participant ID.');
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });

    try {
      final ble = ref.read(bleServiceProvider);
      final db = ref.read(databaseProvider);

      final cmd =
          kCmdStart(pid, _side, _duration.round());
      await ble.sendCommand(cmd);

      // Ensure participant exists in DB
      await db.insertParticipantIfAbsent(pid);

      if (mounted) {
        context.go(AppRoutes.sessionCountdown, extra: {
          'participantId': pid,
          'side': _side,
          'durationSeconds': _duration.round(),
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to start: $e';
        _sending = false;
      });
    }
  }
}
