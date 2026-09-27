// lib/features/connect/connect_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/ble/device_status.dart';
import '../../core/router/app_router.dart';
import 'connect_provider.dart';

class ConnectScreen extends ConsumerWidget {
  const ConnectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectState = ref.watch(connectProvider);
    final statusAsync = ref.watch(deviceStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect Device'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.go(AppRoutes.settings),
          ),
        ],
      ),
      body: connectState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorState(error: e.toString()),
        data: (state) => _ConnectBody(
          connectState: state,
          statusAsync: statusAsync,
          ref: ref,
        ),
      ),
    );
  }
}

class _ConnectBody extends StatelessWidget {
  final ConnectState connectState;
  final AsyncValue<DeviceStatus> statusAsync;
  final WidgetRef ref;

  const _ConnectBody({
    required this.connectState,
    required this.statusAsync,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          _DeviceIcon(state: connectState),
          const SizedBox(height: 24),
          Text(
            _headline(connectState),
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _subtitle(connectState),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Status card
          if (connectState == ConnectState.connected)
            statusAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
              data: (s) => _StatusCard(status: s),
            ),

          const SizedBox(height: 32),

          // Action buttons
          _ActionButtons(state: connectState, ref: ref),

          // Navigation to next steps
          if (connectState == ConnectState.connected) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Text('Next steps',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                )),
            const SizedBox(height: 12),
            _NextStepTile(
              icon: Icons.tune,
              label: 'Calibrate',
              subtitle: 'Run a 20-second calibration routine',
              onTap: () => context.go(AppRoutes.calibrate),
            ),
            _NextStepTile(
              icon: Icons.play_circle_outline,
              label: 'New session',
              subtitle: 'Start a knee-extension recording',
              onTap: () => context.go(AppRoutes.newSession),
            ),
            _NextStepTile(
              icon: Icons.wifi,
              label: 'Sync sessions',
              subtitle: 'Download saved recordings from device',
              onTap: () => context.go(AppRoutes.sync),
            ),
          ],
        ],
      ),
    );
  }

  String _headline(ConnectState s) => switch (s) {
        ConnectState.idle => 'Ready to scan',
        ConnectState.scanning => 'Scanning for KneeVib…',
        ConnectState.connected => 'Device connected',
        ConnectState.notFound => 'Device not found',
        ConnectState.failed => 'Connection failed',
        ConnectState.permDenied => 'Permission required',
      };

  String _subtitle(ConnectState s) => switch (s) {
        ConnectState.idle =>
          'Make sure the device is powered on and in range.',
        ConnectState.scanning => 'Looking for KneeVib nearby…',
        ConnectState.connected =>
          'KneeVib is connected and ready.',
        ConnectState.notFound =>
          'Could not find the device. Is it on and in range?',
        ConnectState.failed =>
          'An error occurred. Please try again.',
        ConnectState.permDenied =>
          'Bluetooth permission is required. Please grant it in Settings.',
      };
}

class _DeviceIcon extends StatelessWidget {
  final ConnectState state;
  const _DeviceIcon({required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isConnected = state == ConnectState.connected;
    final isError = state == ConnectState.notFound ||
        state == ConnectState.failed ||
        state == ConnectState.permDenied;

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: isConnected
            ? colorScheme.primaryContainer
            : isError
                ? colorScheme.errorContainer
                : colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      child: state == ConnectState.scanning
          ? const Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(strokeWidth: 3),
            )
          : Icon(
              isConnected ? Icons.bluetooth_connected : Icons.bluetooth,
              size: 52,
              color: isConnected
                  ? colorScheme.onPrimaryContainer
                  : isError
                      ? colorScheme.onErrorContainer
                      : colorScheme.onSurfaceVariant,
            ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final DeviceStatus status;
  const _StatusCard({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _StatusRow(
              label: 'State',
              value: status.state,
              valueColor: _stateColor(status.state, theme.colorScheme),
            ),
            const Divider(height: 20),
            _StatusRow(
              label: 'Battery',
              value: '${status.battery}%',
              trailing: LinearProgressIndicator(
                value: status.battery / 100,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const Divider(height: 20),
            _StatusRow(
              label: 'SD free',
              value: '${status.sdFreeMb} MB',
              valueColor:
                  status.isSdFull ? theme.colorScheme.error : null,
            ),
            if (status.lastSession.isNotEmpty) ...[
              const Divider(height: 20),
              _StatusRow(label: 'Last session', value: status.lastSession),
            ],
            if (status.missedSamples > 0) ...[
              const Divider(height: 20),
              _StatusRow(
                label: 'Missed samples',
                value: status.missedSamples.toString(),
                valueColor: theme.colorScheme.error,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color? _stateColor(String state, ColorScheme cs) => switch (state) {
        'IDLE' => cs.onSurface,
        'CALIBRATING' => cs.tertiary,
        'RECORDING' => cs.error,
        'SAVED' => cs.primary,
        'SYNC' => cs.secondary,
        _ => null,
      };
}

class _StatusRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final Widget? trailing;
  const _StatusRow(
      {required this.label,
      required this.value,
      this.valueColor,
      this.trailing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            )),
        if (trailing != null)
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.only(left: 16), child: trailing!))
        else
          Text(value,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor,
              )),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final ConnectState state;
  final WidgetRef ref;
  const _ActionButtons({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(connectProvider.notifier);
    return switch (state) {
      ConnectState.idle || ConnectState.notFound || ConnectState.failed =>
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: notifier.connect,
            icon: const Icon(Icons.bluetooth_searching),
            label: const Text('Scan for device'),
          ),
        ),
      ConnectState.scanning => SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: notifier.disconnect,
            child: const Text('Cancel'),
          ),
        ),
      ConnectState.connected => SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: notifier.disconnect,
            icon: const Icon(Icons.bluetooth_disabled),
            label: const Text('Disconnect'),
          ),
        ),
      ConnectState.permDenied => SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () {/* open app settings */},
            child: const Text('Open Settings'),
          ),
        ),
    };
  }
}

class _NextStepTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  const _NextStepTile(
      {required this.icon,
      required this.label,
      required this.subtitle,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: colorScheme.primary),
      title: Text(label),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;
  const _ErrorState({required this.error});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text('Error: $error',
            style: TextStyle(color: Theme.of(context).colorScheme.error)),
      ),
    );
  }
}
