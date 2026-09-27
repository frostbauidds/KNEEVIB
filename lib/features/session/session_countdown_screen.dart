// lib/features/session/session_countdown_screen.dart
// Shows the countdown while BLE is off (device is recording).
// Auto-reconnects and polls for SAVED state.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/ble/ble_constants.dart';
import '../../core/ble/ble_service.dart';
import '../../core/ble/device_status.dart';
import '../../core/config/app_providers.dart';
import '../../core/router/app_router.dart';

enum _CdState { counting, reconnecting, saved, failed }

class SessionCountdownScreen extends ConsumerStatefulWidget {
  final String participantId;
  final String side;
  final int durationSeconds;

  const SessionCountdownScreen({
    super.key,
    required this.participantId,
    required this.side,
    required this.durationSeconds,
  });

  @override
  ConsumerState<SessionCountdownScreen> createState() =>
      _SessionCountdownScreenState();
}

class _SessionCountdownScreenState
    extends ConsumerState<SessionCountdownScreen>
    with TickerProviderStateMixin {
  _CdState _state = _CdState.counting;
  int _remaining = 0;
  Timer? _countdownTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const _maxReconnects = 10;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _remaining = widget.durationSeconds;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _reconnectTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remaining <= 0) {
        t.cancel();
        _beginReconnect();
      } else {
        setState(() => _remaining--);
      }
    });
  }

  Future<void> _beginReconnect() async {
    setState(() {
      _state = _CdState.reconnecting;
      _reconnectAttempts = 0;
    });
    _tryReconnect();
  }

  Future<void> _tryReconnect() async {
    if (_reconnectAttempts >= _maxReconnects) {
      setState(() => _state = _CdState.failed);
      return;
    }
    _reconnectAttempts++;

    final ble = ref.read(bleServiceProvider);
    final result = await ble.connectToDevice();
    if (result == BleConnectResult.connected) {
      // Poll for SAVED state
      _pollForSaved(ble);
    } else {
      // Wait 3 s then retry
      _reconnectTimer =
          Timer(const Duration(seconds: 3), _tryReconnect);
    }
  }

  Future<void> _pollForSaved(BleService ble) async {
    DeviceStatus? status;
    for (int i = 0; i < 30; i++) {
      try {
        status = await ble.requestStatus();
        if (status.state == kStateSaved) {
          if (mounted) setState(() => _state = _CdState.saved);
          return;
        }
      } catch (_) {}
      await Future.delayed(const Duration(seconds: 2));
    }
    if (mounted) setState(() => _state = _CdState.failed);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: switch (_state) {
            _CdState.counting => _buildCounting(theme),
            _CdState.reconnecting => _buildReconnecting(theme),
            _CdState.saved => _buildSaved(theme, colorScheme),
            _CdState.failed => _buildFailed(theme, colorScheme),
          },
        ),
      ),
    );
  }

  Widget _buildCounting(ThemeData theme) {
    final mins = _remaining ~/ 60;
    final secs = _remaining % 60;
    final timeStr =
        mins > 0 ? '${mins}m ${secs.toString().padLeft(2, '0')}s' : '${secs}s';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Pulsing record dot
        AnimatedBuilder(
          animation: _pulseController,
          builder: (_, __) => Icon(
            Icons.fiber_manual_record,
            color: Color.lerp(
              theme.colorScheme.error,
              theme.colorScheme.errorContainer,
              _pulseController.value,
            ),
            size: 40,
          ),
        ),
        const SizedBox(height: 24),
        Text('Recording…', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          '${widget.participantId} · ${widget.side == "L" ? "Left" : "Right"} knee',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 48),
        Text(timeStr,
            style: theme.textTheme.displayLarge
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text('remaining',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            )),
        const SizedBox(height: 48),
        Card(
          color: theme.colorScheme.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.info_outline),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Bluetooth is off during recording. '
                    'Do not close the app.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReconnecting(ThemeData theme) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 32),
          Text('Reconnecting to device…',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            'Attempt $_reconnectAttempts of $_maxReconnects',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );

  Widget _buildSaved(ThemeData theme, ColorScheme cs) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 80, color: cs.primary),
          const SizedBox(height: 24),
          Text('Session saved!', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'The recording is saved to the SD card.\n'
            'Go to Sync to download it to your phone.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => context.go(AppRoutes.sync),
              icon: const Icon(Icons.wifi),
              label: const Text('Sync now'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.go(AppRoutes.sessionsList),
              child: const Text('View sessions'),
            ),
          ),
        ],
      );

  Widget _buildFailed(ThemeData theme, ColorScheme cs) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: cs.error),
          const SizedBox(height: 24),
          Text('Could not reconnect', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'The session may still be saved on the SD card. '
            'Try reconnecting manually from the Device screen.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => context.go(AppRoutes.connect),
              icon: const Icon(Icons.bluetooth),
              label: const Text('Go to Device'),
            ),
          ),
        ],
      );
}
