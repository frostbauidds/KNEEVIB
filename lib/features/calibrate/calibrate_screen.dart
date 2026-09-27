// lib/features/calibrate/calibrate_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/ble/ble_constants.dart';
import '../../core/config/app_providers.dart';
import '../../core/router/app_router.dart';

enum _CalStep { instructions, calibrating, done, error }

class CalibrateScreen extends ConsumerStatefulWidget {
  const CalibrateScreen({super.key});

  @override
  ConsumerState<CalibrateScreen> createState() => _CalibrateScreenState();
}

class _CalibrateScreenState extends ConsumerState<CalibrateScreen>
    with TickerProviderStateMixin {
  _CalStep _step = _CalStep.instructions;
  int _elapsed = 0;
  Timer? _timer;
  late AnimationController _progressController;

  static const _calDuration = 20;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _calDuration),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Calibrate')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: switch (_step) {
              _CalStep.instructions => _InstructionsView(onStart: _startCal),
              _CalStep.calibrating =>
                _CalibratingView(elapsed: _elapsed, controller: _progressController),
              _CalStep.done => _DoneView(
                  onNext: () => context.go(AppRoutes.newSession),
                  onRepeat: () =>
                      setState(() => _step = _CalStep.instructions),
                ),
              _CalStep.error => _CalErrorView(onRetry: () =>
                  setState(() => _step = _CalStep.instructions)),
            },
          ),
        ),
      ),
    );
  }

  Future<void> _startCal() async {
    final ble = ref.read(bleServiceProvider);
    try {
      await ble.sendCommand(kCmdCal);
    } catch (e) {
      setState(() => _step = _CalStep.error);
      return;
    }

    setState(() {
      _step = _CalStep.calibrating;
      _elapsed = 0;
    });
    _progressController.reset();
    _progressController.forward();

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _elapsed++);
      if (_elapsed >= _calDuration) {
        t.cancel();
        setState(() => _step = _CalStep.done);
      }
    });
  }
}

// ─── Sub-views ────────────────────────────────────────────────────────────────

class _InstructionsView extends StatelessWidget {
  final VoidCallback onStart;
  const _InstructionsView({required this.onStart});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      key: const ValueKey('instructions'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.accessibility_new,
            size: 64, color: theme.colorScheme.primary),
        const SizedBox(height: 24),
        Text('Before you begin', style: theme.textTheme.titleLarge),
        const SizedBox(height: 16),
        _Step(num: '1', text: 'Make sure the wearable is fitted correctly on the knee.'),
        _Step(num: '2', text: 'Sit in a chair with your back straight.'),
        _Step(num: '3', text: 'Extend your leg fully and hold still for 5 seconds.'),
        _Step(num: '4', text: 'Slowly bend your knee as far as comfortable.'),
        _Step(num: '5', text: 'Straighten again slowly.'),
        const SizedBox(height: 8),
        Text(
          'The whole routine takes about 20 seconds.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onStart,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start calibration'),
          ),
        ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  final String num;
  final String text;
  const _Step({required this.num, required this.text});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            child: Text(num,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Text(text,
                  style: Theme.of(context).textTheme.bodyLarge)),
        ],
      ),
    );
  }
}

class _CalibratingView extends StatelessWidget {
  final int elapsed;
  final AnimationController controller;
  const _CalibratingView(
      {required this.elapsed, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remaining = 20 - elapsed;
    final phaseText = elapsed < 5
        ? 'Hold still with leg extended…'
        : elapsed < 15
            ? 'Slowly bend your knee…'
            : 'Straighten your leg slowly…';

    return Column(
      key: const ValueKey('calibrating'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(alignment: Alignment.center, children: [
          SizedBox(
            width: 180,
            height: 180,
            child: AnimatedBuilder(
              animation: controller,
              builder: (_, __) => CircularProgressIndicator(
                value: controller.value,
                strokeWidth: 10,
                strokeCap: StrokeCap.round,
              ),
            ),
          ),
          Column(
            children: [
              Text(
                '$remaining',
                style: theme.textTheme.displayLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text('seconds',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  )),
            ],
          ),
        ]),
        const SizedBox(height: 40),
        Text(phaseText,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text('Stay still and breathe normally.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center),
      ],
    );
  }
}

class _DoneView extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onRepeat;
  const _DoneView({required this.onNext, required this.onRepeat});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      key: const ValueKey('done'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.check_circle_outline,
            size: 80, color: theme.colorScheme.primary),
        const SizedBox(height: 24),
        Text('Calibration complete!', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          'The device is now calibrated and ready to record.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 48),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onNext,
            icon: const Icon(Icons.play_circle_outline),
            label: const Text('Start a session'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onRepeat,
            child: const Text('Repeat calibration'),
          ),
        ),
      ],
    );
  }
}

class _CalErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _CalErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      key: const ValueKey('cal_error'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline,
            size: 80, color: theme.colorScheme.error),
        const SizedBox(height: 24),
        Text('Calibration failed', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          'Could not send the calibration command. '
          'Make sure the device is connected.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge,
        ),
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
