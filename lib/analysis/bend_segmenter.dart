// lib/analysis/bend_segmenter.dart
// Splits the IMU knee_deg signal into individual bend segments.
// Pure Dart — safe to run in an Isolate.

import 'dart:math' as math;
import 'data_models.dart';

/// Configuration knobs for bend detection.
class BendSegmenterConfig {
  /// Minimum angle change (degrees) to qualify as a bend start.
  final double minFlexionDeg;
  /// Minimum number of IMU samples per bend segment.
  final int minSamples;
  /// Gap between bends (samples) before starting a new segment.
  final int gapSamples;

  const BendSegmenterConfig({
    this.minFlexionDeg = 10.0,
    this.minSamples = 20,
    this.gapSamples = 10,
  });
}

/// Splits the IMU rows into knee-bend segments.
///
/// Strategy:
/// 1. Smooth the knee_deg signal with a moving average.
/// 2. Find valleys (local minima in angle = full extension) and peaks
///    (local maxima = maximum flexion). A bend is a valley-to-peak-to-valley
///    triplet with sufficient range.
/// 3. For each bend, collect the aligned vibration magnitudes.
List<BendSegment> segmentBends(
  List<ImuRow> imuRows,
  List<double> filteredVibMagnitudes, {
  BendSegmenterConfig config = const BendSegmenterConfig(),
}) {
  if (imuRows.length < config.minSamples) return [];

  // Smooth angle signal
  final angles = imuRows.map((r) => r.kneeDeg).toList();
  final smoothed = _movingAverage(angles, 5);

  // Find all local extrema
  final extrema = _findExtrema(smoothed);

  // Pair consecutive valley → peak → valley as a bend
  final bends = <BendSegment>[];
  for (int i = 0; i + 2 < extrema.length; i++) {
    final a = extrema[i];
    final b = extrema[i + 1];
    final c = extrema[i + 2];

    // Expect valley → peak → valley pattern
    final isFlexion = a.isValley && b.isPeak && c.isValley;
    if (!isFlexion) continue;

    final range = b.angle - math.min(a.angle, c.angle);
    if (range < config.minFlexionDeg) continue;

    final segLen = c.index - a.index;
    if (segLen < config.minSamples) continue;

    final segAngles = angles.sublist(a.index, c.index + 1);
    final segVib = _safeSublist(filteredVibMagnitudes, a.index, c.index + 1);

    bends.add(BendSegment(
      startIndex: a.index,
      endIndex: c.index,
      anglesDeg: segAngles,
      vibMagnitudes: segVib,
    ));
  }
  return bends;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

List<double> _movingAverage(List<double> signal, int window) {
  final half = window ~/ 2;
  final result = List<double>.filled(signal.length, 0.0);
  for (int i = 0; i < signal.length; i++) {
    final start = math.max(0, i - half);
    final end = math.min(signal.length - 1, i + half);
    double sum = 0.0;
    for (int j = start; j <= end; j++) sum += signal[j];
    result[i] = sum / (end - start + 1);
  }
  return result;
}

class _Extremum {
  final int index;
  final double angle;
  final bool isPeak;
  bool get isValley => !isPeak;

  const _Extremum(this.index, this.angle, this.isPeak);
}

List<_Extremum> _findExtrema(List<double> signal) {
  final result = <_Extremum>[];
  for (int i = 1; i < signal.length - 1; i++) {
    final prev = signal[i - 1];
    final curr = signal[i];
    final next = signal[i + 1];
    if (curr > prev && curr > next) {
      result.add(_Extremum(i, curr, true));
    } else if (curr < prev && curr < next) {
      result.add(_Extremum(i, curr, false));
    }
  }
  return result;
}

List<double> _safeSublist(List<double> list, int start, int end) {
  final s = math.max(0, start);
  final e = math.min(list.length, end);
  if (s >= e) return [];
  return list.sublist(s, e);
}

/// Interpolate filtered vibration magnitudes onto the IMU time base.
/// vib is at ~1600 Hz, IMU is at ~100 Hz.
List<double> alignVibToImu(
  List<ImuRow> imuRows,
  List<VibRecord> vibRecords,
  List<double> filteredVib,
) {
  if (vibRecords.isEmpty || imuRows.isEmpty) {
    return List.filled(imuRows.length, 0.0);
  }

  final aligned = <double>[];
  int vi = 0;

  for (final row in imuRows) {
    // Advance vib index to bracket the current IMU timestamp
    while (vi < vibRecords.length - 1 &&
        vibRecords[vi + 1].tUs <= row.tUs) {
      vi++;
    }
    aligned.add(filteredVib.length > vi ? filteredVib[vi].abs() : 0.0);
  }
  return aligned;
}
