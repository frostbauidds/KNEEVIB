// lib/features/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/config/app_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demoMode = ref.watch(demoModeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // ── Demo Mode ───────────────────────────────────────────────
          _SectionHeader(title: 'Development'),
          SwitchListTile(
            secondary: Icon(Icons.science_outlined,
                color: demoMode ? theme.colorScheme.tertiary : null),
            title: const Text('Demo Mode'),
            subtitle: Text(
              demoMode
                  ? 'Using simulated device data'
                  : 'Using real device (BLE + Wi-Fi)',
            ),
            value: demoMode,
            onChanged: (v) {
              ref.read(demoModeProvider.notifier).state = v;
            },
          ),
          if (demoMode)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                color: theme.colorScheme.tertiaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: theme.colorScheme.onTertiaryContainer),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Demo Mode is active. All BLE and Wi-Fi operations '
                          'are simulated. No real device is needed.',
                          style: TextStyle(
                              color: theme.colorScheme.onTertiaryContainer),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          const Divider(),

          // ── Privacy ─────────────────────────────────────────────────
          _SectionHeader(title: 'Privacy'),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Data storage'),
            subtitle: const Text('All data stays on this device unless exported.'),
          ),
          ListTile(
            leading: const Icon(Icons.no_accounts_outlined),
            title: const Text('No accounts or tracking'),
            subtitle: const Text('No login, no ads, no analytics.'),
          ),
          ListTile(
            leading: const Icon(Icons.badge_outlined),
            title: const Text('Anonymous IDs only'),
            subtitle: const Text('No names are stored anywhere.'),
          ),

          const Divider(),

          // ── About ───────────────────────────────────────────────────
          _SectionHeader(title: 'About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('KneeVib'),
            subtitle: const Text(
                'v0.1.0 — Smart India Hackathon prototype\n'
                'Screening aid only — not a medical device.'),
            isThreeLine: true,
          ),
          ListTile(
            leading: const Icon(Icons.warning_amber_outlined),
            title: const Text('Disclaimer'),
            subtitle: const Text(
                'This app is a prototype screening aid. '
                'It does NOT provide medical diagnoses. '
                'Always consult a qualified healthcare professional.'),
            isThreeLine: true,
          ),

          const Divider(),

          // ── Reset ───────────────────────────────────────────────────
          _SectionHeader(title: 'Reset'),
          ListTile(
            leading:
                Icon(Icons.restart_alt, color: theme.colorScheme.error),
            title: Text('Reset consent',
                style: TextStyle(color: theme.colorScheme.error)),
            subtitle: const Text(
                'Clear consent to show onboarding again on next launch.'),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('consent_given');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Consent reset. Restart the app.')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 0.8,
              ),
        ),
      );
}
