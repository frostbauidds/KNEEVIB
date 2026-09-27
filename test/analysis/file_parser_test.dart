// test/analysis/file_parser_test.dart
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:kneevib/analysis/file_parser.dart';

void main() {
  group('parseVibBin', () {
    test('returns empty list for empty bytes', () {
      expect(parseVibBin([]), isEmpty);
    });

    test('ignores incomplete trailing record', () {
      // 10 bytes = 1 record, 5 extra = ignored
      final data = Uint8List(15);
      expect(parseVibBin(data), hasLength(1));
    });

    test('parses known record correctly', () {
      final bd = ByteData(10);
      bd.setUint32(0, 1000, Endian.little); // t_us = 1000
      bd.setInt16(4, 100, Endian.little);   // x = 100
      bd.setInt16(6, -50, Endian.little);   // y = -50
      bd.setInt16(8, 200, Endian.little);   // z = 200
      final records = parseVibBin(bd.buffer.asUint8List());
      expect(records, hasLength(1));
      expect(records.first.tUs, 1000);
      expect(records.first.x, 100);
      expect(records.first.y, -50);
      expect(records.first.z, 200);
    });

    test('parses multiple records', () {
      final bd = ByteData(30); // 3 records
      final records = parseVibBin(bd.buffer.asUint8List());
      expect(records, hasLength(3));
    });

    test('handles negative int16 values (two\'s complement)', () {
      final bd = ByteData(10);
      bd.setInt16(4, -32768, Endian.little);
      bd.setInt16(6, 32767, Endian.little);
      final r = parseVibBin(bd.buffer.asUint8List()).first;
      expect(r.x, -32768);
      expect(r.y, 32767);
    });
  });

  group('parseImuCsv', () {
    test('returns empty for empty string', () {
      expect(parseImuCsv(''), isEmpty);
    });

    test('skips header row', () {
      const csv =
          't_us,ax1,ay1,az1,gx1,gy1,gz1,ax2,ay2,az2,gx2,gy2,gz2,knee_deg,marker\n'
          '10000,0.1,0.2,9.8,1.0,2.0,3.0,0.1,0.2,9.8,1.0,2.0,3.0,45.5,0\n';
      final rows = parseImuCsv(csv);
      expect(rows, hasLength(1));
      expect(rows.first.tUs, 10000);
      expect(rows.first.kneeDeg, closeTo(45.5, 0.001));
      expect(rows.first.marker, 0);
    });

    test('skips malformed rows', () {
      const csv =
          't_us,ax1,ay1,az1,gx1,gy1,gz1,ax2,ay2,az2,gx2,gy2,gz2,knee_deg,marker\n'
          'bad,data\n'
          '10000,0.1,0.2,9.8,1.0,2.0,3.0,0.1,0.2,9.8,1.0,2.0,3.0,45.5,0\n';
      final rows = parseImuCsv(csv);
      expect(rows, hasLength(1));
    });

    test('parses all columns', () {
      const csv =
          't_us,ax1,ay1,az1,gx1,gy1,gz1,ax2,ay2,az2,gx2,gy2,gz2,knee_deg,marker\n'
          '5000,1.1,2.2,3.3,4.4,5.5,6.6,7.7,8.8,9.9,10.0,11.1,12.2,90.0,1\n';
      final row = parseImuCsv(csv).first;
      expect(row.ax1, closeTo(1.1, 0.001));
      expect(row.gz2, closeTo(12.2, 0.001));
      expect(row.kneeDeg, closeTo(90.0, 0.001));
      expect(row.marker, 1);
    });
  });

  group('parseMetaJson', () {
    test('parses all fields', () {
      const json = '''
{
  "participant_id": "P001",
  "side": "L",
  "date": "2024-01-01T10:00:00",
  "vib_sample_rate_hz": 1600,
  "imu_sample_rate_hz": 100,
  "missed_samples": 5,
  "calibration": {"offset_x": 0}
}
''';
      final meta = parseMetaJson(json);
      expect(meta.participantId, 'P001');
      expect(meta.side, 'L');
      expect(meta.vibSampleRateHz, 1600);
      expect(meta.missedSamples, 5);
    });

    test('uses defaults for missing fields', () {
      final meta = parseMetaJson('{}');
      expect(meta.participantId, '');
      expect(meta.vibSampleRateHz, 1600);
      expect(meta.missedSamples, 0);
    });
  });
}
