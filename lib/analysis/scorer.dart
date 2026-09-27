// lib/analysis/scorer.dart
// Scoring interface + prototype weighted-baseline implementation.

import 'data_models.dart';

// ---------------------------------------------------------------------------
// Scoring configuration (loaded from assets/scoring_config.json)
// ---------------------------------------------------------------------------
class ScoringConfig {
  final double rmsWeight;
  final double peakWeight;
  final double kurtosisWeight;
  final double burstCountWeight;
  final double burstAngleRangeWeight;
  final double greenMax;
  final double yellowMax;
  final double missedSamplesWarnPct;
  final int minRecordingSeconds;
  // Population fallback means (used when no baseline session exists)
  final double popRmsMean, popRmsStd;
  final double popKurtosisMean, popKurtosisStd;
  final double popBurstCountMean, popBurstCountStd;

  const ScoringConfig({
    this.rmsWeight = 0.25,
    this.peakWeight = 0.15,
    this.kurtosisWeight = 0.25,
    this.burstCountWeight = 0.20,
    this.burstAngleRangeWeight = 0.15,
    this.greenMax = 3.5,
    this.yellowMax = 6.5,
    this.missedSamplesWarnPct = 5.0,
    this.minRecordingSeconds = 30,
    this.popRmsMean = 1.0,
    this.popRmsStd = 0.3,
    this.popKurtosisMean = 3.0,
    this.popKurtosisStd = 1.5,
    this.popBurstCountMean = 5.0,
    this.popBurstCountStd = 3.0,
  });

  factory ScoringConfig.fromJson(Map<String, dynamic> j) {
    final f = j['features'] as Map<String, dynamic>? ?? {};
    final t = j['thresholds'] as Map<String, dynamic>? ?? {};
    final n = j['normalization'] as Map<String, dynamic>? ?? {};
    return ScoringConfig(
      rmsWeight: (f['rms_weight'] as num?)?.toDouble() ?? 0.25,
      peakWeight: (f['peak_weight'] as num?)?.toDouble() ?? 0.15,
      kurtosisWeight: (f['kurtosis_weight'] as num?)?.toDouble() ?? 0.25,
      burstCountWeight: (f['burst_count_weight'] as num?)?.toDouble() ?? 0.20,
      burstAngleRangeWeight:
          (f['burst_angle_range_weight'] as num?)?.toDouble() ?? 0.15,
      greenMax: (t['green_max'] as num?)?.toDouble() ?? 3.5,
      yellowMax: (t['yellow_max'] as num?)?.toDouble() ?? 6.5,
      missedSamplesWarnPct:
          (t['missed_samples_warn_pct'] as num?)?.toDouble() ?? 5.0,
      minRecordingSeconds: t['min_recording_seconds'] as int? ?? 30,
      popRmsMean: (n['population_rms_mean'] as num?)?.toDouble() ?? 1.0,
      popRmsStd: (n['population_rms_std'] as num?)?.toDouble() ?? 0.3,
      popKurtosisMean:
          (n['population_kurtosis_mean'] as num?)?.toDouble() ?? 3.0,
      popKurtosisStd:
          (n['population_kurtosis_std'] as num?)?.toDouble() ?? 1.5,
      popBurstCountMean:
          (n['population_burst_count_mean'] as num?)?.toDouble() ?? 5.0,
      popBurstCountStd:
          (n['population_burst_count_std'] as num?)?.toDouble() ?? 3.0,
    );
  }
}

// ---------------------------------------------------------------------------
// Abstract Scorer interface — swap in a TFLite model later.
// ---------------------------------------------------------------------------
abstract class Scorer {
  /// Compute a 0–10 roughness score for the given per-bend features.
  /// [baseline] is the features from the participant's FIRST session.
  /// Pass null to use population-level normalization.
  double score(
    List<BendFeatures> bends, {
    SessionAnalysisResult? baseline,
  });
}

// ---------------------------------------------------------------------------
// Prototype: weighted linear combination of z-scored features.
// ---------------------------------------------------------------------------
class WeightedBaseliner implements Scorer {
  final ScoringConfig config;

  const WeightedBaseliner(this.config);

  @override
  double score(
    List<BendFeatures> bends, {
    SessionAnalysisResult? baseline,
  }) {
    if (bends.isEmpty) return 0.0;

    // Aggregate session-level features
    final rms = _mean(bends.map((b) => b.rms).toList());
    final kurtosis = _mean(bends.map((b) => b.kurtosis).toList());
    final burstCount = _sum(bends.map((b) => b.burstCount.toDouble()).toList());

    // Normalise against baseline or population
    final normRms = baseline != null
        ? _safeDiv(rms - baseline.rmsRaw, config.popRmsStd)
        : _safeDiv(rms - config.popRmsMean, config.popRmsStd);

    final normKurt = baseline != null
        ? _safeDiv(kurtosis - baseline.kurtosis, config.popKurtosisStd)
        : _safeDiv(kurtosis - config.popKurtosisMean, config.popKurtosisStd);

    final normBurst = baseline != null
        ? _safeDiv(
            burstCount - baseline.vibBurstCount, config.popBurstCountStd)
        : _safeDiv(
            burstCount - config.popBurstCountMean, config.popBurstCountStd);

    // Weighted sum → map to 0–10 with sigmoid-like clamp
    final raw = config.rmsWeight * normRms.clamp(-3, 3) +
        config.kurtosisWeight * normKurt.clamp(-3, 3) +
        config.burstCountWeight * normBurst.clamp(-3, 3);

    // raw ∈ [-3, 3] → score ∈ [0, 10]
    final score = ((raw + 3.0) / 6.0 * 10.0).clamp(0.0, 10.0);
    return score;
  }

  static double _mean(List<double> v) =>
      v.isEmpty ? 0.0 : v.reduce((a, b) => a + b) / v.length;

  static double _sum(List<double> v) =>
      v.isEmpty ? 0.0 : v.reduce((a, b) => a + b);

  static double _safeDiv(double n, double d) => d == 0.0 ? 0.0 : n / d;
}
