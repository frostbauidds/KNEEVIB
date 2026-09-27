// lib/analysis/analysis_engine.dart
// Orchestrates the full analysis pipeline in a background Isolate.

import 'dart:convert';
import 'dart:isolate';
import 'dart:math' as math;

import 'bend_segmenter.dart';
import 'data_models.dart';
import 'dsp.dart';
import 'file_parser.dart';
import 'scorer.dart';

/// Input payload sent into the Isolate.
class AnalysisInput {
  final List<int> vibBytes;
  final String imuCsv;
  final String metaJson;
  final SessionAnalysisResult? baselineResult;
  final Map<String, dynamic> scoringConfigJson;

  const AnalysisInput({
    required this.vibBytes,
    required this.imuCsv,
    required this.metaJson,
    this.baselineResult,
    required this.scoringConfigJson,
  });
}

/// Run the full pipeline. Call via Isolate.run() to keep UI thread free.
Future<SessionAnalysisResult> runAnalysis(AnalysisInput input) async {
  // 1. Parse files
  final vibRecords = parseVibBin(input.vibBytes);
  final imuRows = parseImuCsv(input.imuCsv);
  final meta = parseMetaJson(input.metaJson);
  final config = ScoringConfig.fromJson(input.scoringConfigJson);

  // 2. Reliability check
  bool isTrustworthy = true;
  String? warningNote;

  final totalSamples = vibRecords.length + imuRows.length;
  final missedPct = totalSamples > 0
      ? (meta.missedSamples / (totalSamples + meta.missedSamples)) * 100
      : 0.0;

  if (missedPct > config.missedSamplesWarnPct) {
    isTrustworthy = false;
    warningNote =
        'High missed-sample rate (${missedPct.toStringAsFixed(1)}%). '
        'Results may be unreliable.';
  }

  final estDurationS = imuRows.length / meta.imuSampleRateHz;
  if (estDurationS < config.minRecordingSeconds) {
    isTrustworthy = false;
    warningNote =
        (warningNote ?? '') +
        ' Recording too short (${estDurationS.toStringAsFixed(0)} s). '
        'Minimum recommended: ${config.minRecordingSeconds} s.';
  }

  if (vibRecords.isEmpty || imuRows.isEmpty) {
    return SessionAnalysisResult(
      roughnessScore: 0.0,
      maxFlexionDeg: 0.0,
      rangeOfMotionDeg: 0.0,
      avgBendTimeS: 0.0,
      vibBurstCount: 0,
      burstAngleMin: 0.0,
      burstAngleMax: 0.0,
      rmsRaw: 0.0,
      peakRaw: 0.0,
      kurtosis: 0.0,
      bendCount: 0,
      isTrustworthy: false,
      warningNote: 'No data to analyse.',
      perBend: [],
    );
  }

  // 3. Compute vib magnitude and apply band-pass filter
  final rawMagnitudes = vibRecords
      .map((v) => 3.9 * math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z))
      .toList();

  final filter = BandPassFilter(
    fs: meta.vibSampleRateHz.toDouble(),
    fLow: 20.0,
    fHigh: 500.0,
  );
  final filteredVib = filter.apply(rawMagnitudes);

  // 4. Resting baseline: first 2 seconds (flat region before leg-extension)
  final restingSamples = math.min(
      meta.vibSampleRateHz * 2, filteredVib.length);
  final restingBaseline = filteredVib.sublist(0, restingSamples);

  // 5. Align vib to IMU time base
  final alignedVib = alignVibToImu(imuRows, vibRecords, filteredVib);

  // 6. Segment bends
  final bends = segmentBends(imuRows, alignedVib);

  // 7. Per-bend features
  final bendFeatures = <BendFeatures>[];
  for (final bend in bends) {
    final vib = bend.vibMagnitudes;
    final rms = computeRms(vib);
    final peak = computePeak(vib);
    final kurt = computeKurtosis(vib);
    final bursts = countBursts(vib, baseline: restingBaseline);

    // Burst angle range: find angles of burst samples
    double bAngleMin = double.infinity;
    double bAngleMax = double.negativeInfinity;
    final mean = computeMean(restingBaseline);
    final std = computeStd(restingBaseline);
    final threshold = mean + 3.0 * std;

    for (int i = 0; i < vib.length && i < bend.anglesDeg.length; i++) {
      if (vib[i] > threshold) {
        final a = bend.anglesDeg[i];
        if (a < bAngleMin) bAngleMin = a;
        if (a > bAngleMax) bAngleMax = a;
      }
    }
    if (bAngleMin == double.infinity) bAngleMin = 0.0;
    if (bAngleMax == double.negativeInfinity) bAngleMax = 0.0;

    bendFeatures.add(BendFeatures(
      rms: rms,
      peak: peak,
      kurtosis: kurt,
      burstCount: bursts,
      burstAngleMin: bAngleMin,
      burstAngleMax: bAngleMax,
      maxFlexionDeg: bend.maxAngle,
      rangeOfMotionDeg: bend.rangeOfMotion,
      durationS: bend.durationS,
    ));
  }

  // 8. Session-level aggregates
  double maxFlex = 0.0, totalRom = 0.0, totalDur = 0.0;
  int totalBursts = 0;
  double aggBAngleMin = double.infinity, aggBAngleMax = double.negativeInfinity;

  for (final b in bendFeatures) {
    if (b.maxFlexionDeg > maxFlex) maxFlex = b.maxFlexionDeg;
    totalRom += b.rangeOfMotionDeg;
    totalDur += b.durationS;
    totalBursts += b.burstCount;
    if (b.burstAngleMin < aggBAngleMin) aggBAngleMin = b.burstAngleMin;
    if (b.burstAngleMax > aggBAngleMax) aggBAngleMax = b.burstAngleMax;
  }

  final avgRom = bendFeatures.isEmpty ? 0.0 : totalRom / bendFeatures.length;
  final avgDur = bendFeatures.isEmpty ? 0.0 : totalDur / bendFeatures.length;
  final rmsRaw = computeRms(filteredVib);
  final peakRaw = computePeak(filteredVib);
  final kurtRaw = computeKurtosis(filteredVib);

  if (aggBAngleMin == double.infinity) aggBAngleMin = 0.0;
  if (aggBAngleMax == double.negativeInfinity) aggBAngleMax = 0.0;

  // 9. Score
  final scorer = WeightedBaseliner(config);
  final roughness = scorer.score(bendFeatures, baseline: input.baselineResult);

  return SessionAnalysisResult(
    roughnessScore: roughness,
    maxFlexionDeg: maxFlex,
    rangeOfMotionDeg: avgRom,
    avgBendTimeS: avgDur,
    vibBurstCount: totalBursts,
    burstAngleMin: aggBAngleMin,
    burstAngleMax: aggBAngleMax,
    rmsRaw: rmsRaw,
    peakRaw: peakRaw,
    kurtosis: kurtRaw,
    bendCount: bendFeatures.length,
    isTrustworthy: isTrustworthy,
    warningNote: warningNote?.trim(),
    perBend: bendFeatures,
  );
}
