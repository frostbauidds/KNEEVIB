// lib/analysis/dsp.dart
// Digital signal processing: band-pass filter (20–500 Hz) for vibration data.
// Uses a 4th-order Butterworth IIR implemented as cascaded biquad sections.
// Pure Dart — safe to run in an Isolate.

import 'dart:math' as math;

// ---------------------------------------------------------------------------
// Simple biquad IIR filter (Direct Form II Transposed)
// ---------------------------------------------------------------------------
class _Biquad {
  final double b0, b1, b2, a1, a2;
  double _z1 = 0.0, _z2 = 0.0;

  _Biquad(this.b0, this.b1, this.b2, this.a1, this.a2);

  double process(double x) {
    final y = b0 * x + _z1;
    _z1 = b1 * x - a1 * y + _z2;
    _z2 = b2 * x - a2 * y;
    return y;
  }

  void reset() {
    _z1 = 0.0;
    _z2 = 0.0;
  }
}

// ---------------------------------------------------------------------------
// Butterworth band-pass filter design (analog → bilinear transform).
// For simplicity we use two 2nd-order stages (LP + HP chain).
// This gives a practical 20–500 Hz band-pass at fs ≈ 1600 Hz.
//
// Pre-computed coefficients for fs = 1600 Hz, fLow = 20 Hz, fHigh = 500 Hz
// using standard bilinear transformation.
// ---------------------------------------------------------------------------

class BandPassFilter {
  late final List<_Biquad> _stages;

  BandPassFilter({double fs = 1600.0, double fLow = 20.0, double fHigh = 500.0}) {
    _stages = _butterworth4thBandPass(fs, fLow, fHigh);
  }

  List<double> apply(List<double> input) {
    // Reset filter state for each new signal
    for (final s in _stages) s.reset();
    return input.map((x) {
      double y = x;
      for (final s in _stages) y = s.process(y);
      return y;
    }).toList();
  }

  static List<_Biquad> _butterworth4thBandPass(
      double fs, double fLow, double fHigh) {
    // Two 2nd-order Butterworth sections (HP + LP cascade)
    final hp = _highPassBiquad(fs, fLow);
    final lp = _lowPassBiquad(fs, fHigh);
    return [hp, lp];
  }

  static _Biquad _highPassBiquad(double fs, double fc) {
    final wc = 2.0 * math.pi * fc / fs;
    final k = math.tan(wc / 2.0);
    final norm = 1.0 / (1.0 + math.sqrt(2.0) * k + k * k);
    return _Biquad(
      norm,
      -2.0 * norm,
      norm,
      2.0 * (k * k - 1.0) * norm,
      (1.0 - math.sqrt(2.0) * k + k * k) * norm,
    );
  }

  static _Biquad _lowPassBiquad(double fs, double fc) {
    final wc = 2.0 * math.pi * fc / fs;
    final k = math.tan(wc / 2.0);
    final norm = 1.0 / (1.0 + math.sqrt(2.0) * k + k * k);
    return _Biquad(
      k * k * norm,
      2.0 * k * k * norm,
      k * k * norm,
      2.0 * (k * k - 1.0) * norm,
      (1.0 - math.sqrt(2.0) * k + k * k) * norm,
    );
  }
}

// ---------------------------------------------------------------------------
// Stat helpers (pure functions, testable)
// ---------------------------------------------------------------------------

double computeRms(List<double> values) {
  if (values.isEmpty) return 0.0;
  double sum = 0.0;
  for (final v in values) sum += v * v;
  return math.sqrt(sum / values.length);
}

double computePeak(List<double> values) {
  if (values.isEmpty) return 0.0;
  double peak = 0.0;
  for (final v in values) {
    final abs = v.abs();
    if (abs > peak) peak = abs;
  }
  return peak;
}

/// Excess kurtosis (Gaussian = 0).
double computeKurtosis(List<double> values) {
  if (values.length < 4) return 0.0;
  final n = values.length.toDouble();
  final mean = values.reduce((a, b) => a + b) / n;
  double m2 = 0.0, m4 = 0.0;
  for (final v in values) {
    final d = v - mean;
    final d2 = d * d;
    m2 += d2;
    m4 += d2 * d2;
  }
  m2 /= n;
  m4 /= n;
  if (m2 == 0.0) return 0.0;
  return (m4 / (m2 * m2)) - 3.0;
}

double computeMean(List<double> values) {
  if (values.isEmpty) return 0.0;
  return values.reduce((a, b) => a + b) / values.length;
}

double computeStd(List<double> values) {
  if (values.length < 2) return 0.0;
  final mean = computeMean(values);
  double sum = 0.0;
  for (final v in values) {
    final d = v - mean;
    sum += d * d;
  }
  return math.sqrt(sum / values.length);
}

/// Count samples above (mean + k*sigma) threshold.
int countBursts(List<double> values, {required List<double> baseline, double k = 3.0}) {
  final mean = computeMean(baseline);
  final std = computeStd(baseline);
  final threshold = mean + k * std;
  int count = 0;
  for (final v in values) {
    if (v.abs() > threshold) count++;
  }
  return count;
}
