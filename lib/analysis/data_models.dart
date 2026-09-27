// lib/analysis/data_models.dart
// Raw data record types produced by the file parsers.

import 'dart:math' as math;

/// One record from vib.bin: ADXL345 sample at ~1600 Hz.
/// Binary layout: uint32 t_us | int16 x | int16 y | int16 z
class VibRecord {
  final int tUs;    // timestamp in microseconds
  final int x;      // raw counts (3.9 mg per count)
  final int y;
  final int z;

  const VibRecord({
    required this.tUs,
    required this.x,
    required this.y,
    required this.z,
  });

  /// Magnitude in mg units.
  double get magnitudeMg =>
      3.9 * math.sqrt((x * x + y * y + z * z).toDouble());
}

/// One row from imu.csv.
class ImuRow {
  final int tUs;
  final double ax1, ay1, az1, gx1, gy1, gz1;
  final double ax2, ay2, az2, gx2, gy2, gz2;
  final double kneeDeg;
  final int marker;

  const ImuRow({
    required this.tUs,
    required this.ax1, required this.ay1, required this.az1,
    required this.gx1, required this.gy1, required this.gz1,
    required this.ax2, required this.ay2, required this.az2,
    required this.gx2, required this.gy2, required this.gz2,
    required this.kneeDeg,
    required this.marker,
  });
}

/// Metadata from meta.json.
class SessionMeta {
  final String participantId;
  final String side;
  final String date;
  final int vibSampleRateHz;
  final int imuSampleRateHz;
  final int missedSamples;
  final Map<String, dynamic> calibration;

  const SessionMeta({
    required this.participantId,
    required this.side,
    required this.date,
    required this.vibSampleRateHz,
    required this.imuSampleRateHz,
    required this.missedSamples,
    required this.calibration,
  });

  factory SessionMeta.fromJson(Map<String, dynamic> j) => SessionMeta(
        participantId: j['participant_id'] as String? ?? '',
        side: j['side'] as String? ?? 'L',
        date: j['date'] as String? ?? '',
        vibSampleRateHz: j['vib_sample_rate_hz'] as int? ?? 1600,
        imuSampleRateHz: j['imu_sample_rate_hz'] as int? ?? 100,
        missedSamples: j['missed_samples'] as int? ?? 0,
        calibration: j['calibration'] as Map<String, dynamic>? ?? {},
      );
}

/// One extracted knee-extension bend.
class BendSegment {
  final int startIndex;   // index in ImuRow list
  final int endIndex;
  final List<double> anglesDeg;
  final List<double> vibMagnitudes; // aligned vib magnitudes per IMU sample

  const BendSegment({
    required this.startIndex,
    required this.endIndex,
    required this.anglesDeg,
    required this.vibMagnitudes,
  });

  double get durationS =>
      (anglesDeg.length / 100.0); // approximate at 100 Hz IMU

  double get maxAngle =>
      anglesDeg.isEmpty ? 0 : anglesDeg.reduce((a, b) => a > b ? a : b);

  double get minAngle =>
      anglesDeg.isEmpty ? 0 : anglesDeg.reduce((a, b) => a < b ? a : b);

  double get rangeOfMotion => maxAngle - minAngle;
}

/// Per-bend analysis result.
class BendFeatures {
  final double rms;
  final double peak;
  final double kurtosis;
  final int burstCount;
  final double burstAngleMin;
  final double burstAngleMax;
  final double maxFlexionDeg;
  final double rangeOfMotionDeg;
  final double durationS;

  const BendFeatures({
    required this.rms,
    required this.peak,
    required this.kurtosis,
    required this.burstCount,
    required this.burstAngleMin,
    required this.burstAngleMax,
    required this.maxFlexionDeg,
    required this.rangeOfMotionDeg,
    required this.durationS,
  });
}

/// Final computed features for a whole session (aggregated across bends).
class SessionAnalysisResult {
  final double roughnessScore;      // 0–10
  final double maxFlexionDeg;
  final double rangeOfMotionDeg;
  final double avgBendTimeS;
  final int vibBurstCount;
  final double burstAngleMin;
  final double burstAngleMax;
  final double rmsRaw;
  final double peakRaw;
  final double kurtosis;
  final int bendCount;
  final bool isTrustworthy;
  final String? warningNote;
  final List<BendFeatures> perBend;

  const SessionAnalysisResult({
    required this.roughnessScore,
    required this.maxFlexionDeg,
    required this.rangeOfMotionDeg,
    required this.avgBendTimeS,
    required this.vibBurstCount,
    required this.burstAngleMin,
    required this.burstAngleMax,
    required this.rmsRaw,
    required this.peakRaw,
    required this.kurtosis,
    required this.bendCount,
    required this.isTrustworthy,
    this.warningNote,
    required this.perBend,
  });
}
