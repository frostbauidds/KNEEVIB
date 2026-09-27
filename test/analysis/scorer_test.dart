// test/analysis/scorer_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:kneevib/analysis/scorer.dart';
import 'package:kneevib/analysis/data_models.dart';

BendFeatures _bend({
  double rms = 1.0,
  double peak = 2.0,
  double kurtosis = 3.0,
  int bursts = 5,
}) =>
    BendFeatures(
      rms: rms,
      peak: peak,
      kurtosis: kurtosis,
      burstCount: bursts,
      burstAngleMin: 20,
      burstAngleMax: 60,
      maxFlexionDeg: 90,
      rangeOfMotionDeg: 80,
      durationS: 3.5,
    );

void main() {
  const config = ScoringConfig();
  final scorer = WeightedBaseliner(config);

  group('WeightedBaseliner', () {
    test('returns a score in [0, 10]', () {
      final score = scorer.score([_bend()]);
      expect(score, inInclusiveRange(0.0, 10.0));
    });

    test('returns 0 for empty bends', () {
      expect(scorer.score([]), 0.0);
    });

    test('higher RMS/kurtosis/bursts produces higher score without baseline', () {
      final normal = scorer.score([_bend(rms: 1.0, kurtosis: 3.0, bursts: 5)]);
      final elevated =
          scorer.score([_bend(rms: 5.0, kurtosis: 10.0, bursts: 50)]);
      expect(elevated, greaterThan(normal));
    });

    test('score stays in [0,10] for extreme inputs', () {
      final high =
          scorer.score([_bend(rms: 1000, kurtosis: 1000, bursts: 1000)]);
      expect(high, lessThanOrEqualTo(10.0));
      final low = scorer.score([_bend(rms: 0, kurtosis: 0, bursts: 0)]);
      expect(low, greaterThanOrEqualTo(0.0));
    });

    test('with baseline: score stays in [0,10]', () {
      final bends = [_bend(rms: 1.0, kurtosis: 3.0, bursts: 5)];
      final baselineResult = SessionAnalysisResult(
        roughnessScore: 5.0,
        maxFlexionDeg: 90,
        rangeOfMotionDeg: 80,
        avgBendTimeS: 3.5,
        vibBurstCount: 5,
        burstAngleMin: 20,
        burstAngleMax: 60,
        rmsRaw: 1.0,
        peakRaw: 2.0,
        kurtosis: 3.0,
        bendCount: 1,
        isTrustworthy: true,
        perBend: bends,
      );
      final score = scorer.score(bends, baseline: baselineResult);
      expect(score, inInclusiveRange(0.0, 10.0));
    });

    test('ScoringConfig.fromJson round-trips weights', () {
      final json = {
        'features': {
          'rms_weight': 0.30,
          'peak_weight': 0.10,
          'kurtosis_weight': 0.20,
          'burst_count_weight': 0.25,
          'burst_angle_range_weight': 0.15,
        },
        'thresholds': {
          'green_max': 4.0,
          'yellow_max': 7.0,
          'missed_samples_warn_pct': 3.0,
          'min_recording_seconds': 60,
        },
        'normalization': {},
      };
      final cfg = ScoringConfig.fromJson(json);
      expect(cfg.rmsWeight, closeTo(0.30, 0.001));
      expect(cfg.greenMax, closeTo(4.0, 0.001));
      expect(cfg.minRecordingSeconds, 60);
    });
  });
}
