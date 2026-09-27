// test/analysis/bend_segmenter_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:kneevib/analysis/bend_segmenter.dart';
import 'package:kneevib/analysis/data_models.dart';
import 'dart:math' as math;

ImuRow _row(int tUs, double kneeDeg) => ImuRow(
      tUs: tUs,
      ax1: 0, ay1: 0, az1: 9.8, gx1: 0, gy1: 0, gz1: 0,
      ax2: 0, ay2: 0, az2: 9.8, gx2: 0, gy2: 0, gz2: 0,
      kneeDeg: kneeDeg,
      marker: 0,
    );

List<ImuRow> _generateBendSignal({
  int bendCount = 3,
  int samplesPerBend = 100,
  double maxAngle = 90.0,
}) {
  final rows = <ImuRow>[];
  int t = 0;
  for (int b = 0; b < bendCount; b++) {
    for (int i = 0; i < samplesPerBend; i++) {
      final phase = (i / samplesPerBend) * 2 * math.pi;
      final angle = maxAngle * 0.5 * (1 - math.cos(phase));
      rows.add(_row(t * 10000, angle));
      t++;
    }
  }
  return rows;
}

void main() {
  group('segmentBends', () {
    test('returns empty for too-short signal', () {
      final rows = [_row(0, 0.0), _row(10000, 45.0)];
      final vib = List<double>.filled(2, 0.0);
      expect(segmentBends(rows, vib), isEmpty);
    });

    test('detects expected number of bends in clean signal', () {
      final rows = _generateBendSignal(bendCount: 3, samplesPerBend: 100);
      final vib = List<double>.filled(rows.length, 0.1);
      final bends = segmentBends(rows, vib);
      // Should find ~3 bends (allow ±1 due to boundary effects)
      expect(bends.length, inInclusiveRange(2, 4));
    });

    test('each bend has non-zero range of motion', () {
      final rows = _generateBendSignal(bendCount: 2, samplesPerBend: 120);
      final vib = List<double>.filled(rows.length, 0.1);
      final bends = segmentBends(rows, vib);
      for (final bend in bends) {
        expect(bend.rangeOfMotion, greaterThan(0));
      }
    });

    test('rejects bends below minimum flexion threshold', () {
      // Tiny angle oscillation (< 10°)
      final rows = <ImuRow>[];
      for (int i = 0; i < 200; i++) {
        final phase = (i / 200) * 2 * math.pi;
        rows.add(_row(i * 10000, 2.0 * math.sin(phase)));
      }
      final vib = List<double>.filled(rows.length, 0.1);
      final bends = segmentBends(rows, vib,
          config: const BendSegmenterConfig(minFlexionDeg: 10));
      expect(bends, isEmpty);
    });

    test('bend angles list is non-empty for detected bends', () {
      final rows = _generateBendSignal(bendCount: 2, samplesPerBend: 150);
      final vib = List<double>.filled(rows.length, 0.2);
      final bends = segmentBends(rows, vib);
      for (final bend in bends) {
        expect(bend.anglesDeg, isNotEmpty);
        expect(bend.vibMagnitudes, isNotEmpty);
      }
    });
  });

  group('alignVibToImu', () {
    test('returns correct length', () {
      final imuRows = List.generate(10, (i) => _row(i * 10000, 0.0));
      final vibRecords = <VibRecord>[];
      final filtered = <double>[];
      final aligned = alignVibToImu(imuRows, vibRecords, filtered);
      expect(aligned, hasLength(imuRows.length));
    });

    test('all zeros for empty vib input', () {
      final imuRows = List.generate(5, (i) => _row(i * 10000, 0.0));
      final aligned = alignVibToImu(imuRows, [], []);
      expect(aligned.every((v) => v == 0.0), isTrue);
    });
  });
}
