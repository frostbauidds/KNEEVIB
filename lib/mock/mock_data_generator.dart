// lib/mock/mock_data_generator.dart
// Generates synthetic vib.bin, imu.csv, and meta.json for Demo Mode.
// Produces two profiles: 'healthy' and 'worn' (arthritic-like).

import 'dart:math' as math;
import 'dart:typed_data';

class MockProfile {
  final String name;
  final double burstAmplitude;  // relative burst strength
  final double noiseLevel;
  final int bendCount;
  final double flexionDeg;

  const MockProfile({
    required this.name,
    required this.burstAmplitude,
    required this.noiseLevel,
    required this.bendCount,
    required this.flexionDeg,
  });
}

const healthyProfile = MockProfile(
  name: 'healthy',
  burstAmplitude: 0.8,
  noiseLevel: 0.05,
  bendCount: 8,
  flexionDeg: 110.0,
);

const wornProfile = MockProfile(
  name: 'worn',
  burstAmplitude: 3.5,
  noiseLevel: 0.15,
  bendCount: 8,
  flexionDeg: 85.0,
);

class MockDataGenerator {
  final math.Random _rng;

  MockDataGenerator([int? seed]) : _rng = math.Random(seed ?? 42);

  /// Generate vib.bin bytes for a profile.
  List<int> generateVibBin(MockProfile profile, {int durationS = 120}) {
    const fs = 1600; // Hz
    final count = fs * durationS;
    final data = ByteData(count * 10); // 10 bytes per record

    for (int i = 0; i < count; i++) {
      final tUs = (i * 1000000 ~/ fs);
      final noise = _gaussian() * profile.noiseLevel * 100;
      // Inject bursts at random
      final burst = _rng.nextDouble() < 0.002
          ? _gaussian() * profile.burstAmplitude * 300
          : 0.0;
      final x = (noise + burst).round().clamp(-32768, 32767);
      final y = (_gaussian() * profile.noiseLevel * 50).round().clamp(-32768, 32767);
      final z = (_gaussian() * profile.noiseLevel * 50).round().clamp(-32768, 32767);

      data.setUint32(i * 10, tUs, Endian.little);
      data.setInt16(i * 10 + 4, x, Endian.little);
      data.setInt16(i * 10 + 6, y, Endian.little);
      data.setInt16(i * 10 + 8, z, Endian.little);
    }
    return data.buffer.asUint8List();
  }

  /// Generate imu.csv content.
  String generateImuCsv(MockProfile profile, {int durationS = 120}) {
    const fs = 100; // Hz
    final count = fs * durationS;
    final bendPeriod = count ~/ profile.bendCount;

    final sb = StringBuffer();
    sb.writeln(
        't_us,ax1,ay1,az1,gx1,gy1,gz1,ax2,ay2,az2,gx2,gy2,gz2,knee_deg,marker');

    for (int i = 0; i < count; i++) {
      final tUs = i * 10000; // 100 Hz → 10 ms per sample
      final phase = (i % bendPeriod) / bendPeriod * 2 * math.pi;
      // Knee angle: sinusoidal bend from 0° to flexionDeg
      final kneeDeg =
          profile.flexionDeg * 0.5 * (1 - math.cos(phase));
      final n = _gaussian;

      sb.writeln(
          '$tUs,${n() * 0.1},${n() * 0.1},${9.8 + n() * 0.05},'
          '${n() * 5},${n() * 5},${n() * 5},'
          '${n() * 0.1},${n() * 0.1},${9.8 + n() * 0.05},'
          '${n() * 5},${n() * 5},${n() * 5},'
          '${kneeDeg.toStringAsFixed(2)},0');
    }
    return sb.toString();
  }

  /// Generate meta.json content.
  String generateMetaJson(MockProfile profile, String participantId, String side) {
    final now = DateTime.now().toIso8601String();
    return '''
{
  "participant_id": "$participantId",
  "side": "$side",
  "date": "$now",
  "vib_sample_rate_hz": 1600,
  "imu_sample_rate_hz": 100,
  "missed_samples": 0,
  "calibration": {
    "vib_zero_x": 0,
    "vib_zero_y": 0,
    "vib_zero_z": 0,
    "profile": "${profile.name}"
  }
}
''';
  }

  double _gaussian() {
    // Box-Muller transform
    final u1 = _rng.nextDouble();
    final u2 = _rng.nextDouble();
    return math.sqrt(-2.0 * math.log(u1 > 0 ? u1 : 1e-10)) *
        math.cos(2.0 * math.pi * u2);
  }
}
