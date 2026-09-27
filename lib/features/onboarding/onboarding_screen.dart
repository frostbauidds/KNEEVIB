// lib/features/onboarding/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/router/app_router.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  bool _consentGiven = false;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // Logo / icon
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.monitor_heart_outlined,
                    size: 52,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'KneeVib',
                style: theme.textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Knee movement monitoring companion',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),

              // How it works
              _SectionCard(
                icon: Icons.info_outline,
                title: 'How it works',
                body: 'This app connects to a wearable knee sensor. '
                    'You run a short guided leg-extension test, '
                    'then download the recording to see a movement quality score.',
              ),
              const SizedBox(height: 12),

              // Disclaimer
              _SectionCard(
                icon: Icons.warning_amber_outlined,
                iconColor: Colors.orange,
                title: 'Important disclaimer',
                body: 'KneeVib is a screening aid only.\n\n'
                    'It does NOT diagnose medical conditions and is NOT a substitute '
                    'for professional medical advice, diagnosis, or treatment.\n\n'
                    'Always consult a qualified healthcare professional.',
                highlighted: true,
              ),
              const SizedBox(height: 12),

              // Privacy
              _SectionCard(
                icon: Icons.lock_outline,
                title: 'Privacy',
                body: 'This app uses anonymous participant IDs only — no names. '
                    'All data stays on your device unless you choose to export it.',
              ),
              const SizedBox(height: 24),

              // Consent checkbox
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => setState(() => _consentGiven = !_consentGiven),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _consentGiven,
                        onChanged: (v) =>
                            setState(() => _consentGiven = v ?? false),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            'I understand that KneeVib is a screening aid and '
                            'not a medical diagnostic tool. I consent to data '
                            'being stored locally on this device.',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Continue button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _consentGiven && !_loading ? _onContinue : null,
                  icon: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.arrow_forward),
                  label: const Text('Get started'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onContinue() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('consent_given', true);
    if (mounted) context.go(AppRoutes.connect);
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String body;
  final bool highlighted;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.body,
    this.iconColor,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: highlighted ? colorScheme.errorContainer.withOpacity(0.3) : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon,
                    color: iconColor ?? colorScheme.primary, size: 22),
                const SizedBox(width: 8),
                Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 8),
            Text(body, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
