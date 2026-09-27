// lib/analysis/file_parser.dart
// Parsers for vib.bin, imu.csv, and meta.json.
// All parsing is pure Dart — safe to run in an Isolate.

import 'dart:convert';
import 'dart:typed_data';

import 'data_models.dart';

// ---------------------------------------------------------------------------
// vib.bin parser
// Binary layout (little-endian): uint32 t_us | int16 x | int16 y | int16 z
// Record size = 10 bytes
// ---------------------------------------------------------------------------

const _kVibRecordBytes = 10;

List<VibRecord> parseVibBin(List<int> bytes) {
  final data = Uint8List.fromList(bytes);
  final bd = ByteData.sublistView(data);
  final count = data.length ~/ _kVibRecordBytes;
  final result = <VibRecord>[];

  for (int i = 0; i < count; i++) {
    final offset = i * _kVibRecordBytes;
    final tUs = bd.getUint32(offset, Endian.little);
    final x = bd.getInt16(offset + 4, Endian.little);
    final y = bd.getInt16(offset + 6, Endian.little);
    final z = bd.getInt16(offset + 8, Endian.little);
    result.add(VibRecord(tUs: tUs, x: x, y: y, z: z));
  }
  return result;
}

// ---------------------------------------------------------------------------
// imu.csv parser
// Header: t_us,ax1,ay1,az1,gx1,gy1,gz1,ax2,ay2,az2,gx2,gy2,gz2,knee_deg,marker
// ---------------------------------------------------------------------------

List<ImuRow> parseImuCsv(String csvContent) {
  final lines = csvContent.split('\n');
  if (lines.isEmpty) return [];

  final result = <ImuRow>[];
  // Skip header row
  for (int i = 1; i < lines.length; i++) {
    final line = lines[i].trim();
    if (line.isEmpty) continue;
    final parts = line.split(',');
    if (parts.length < 15) continue;
    try {
      result.add(ImuRow(
        tUs: int.parse(parts[0]),
        ax1: double.parse(parts[1]),
        ay1: double.parse(parts[2]),
        az1: double.parse(parts[3]),
        gx1: double.parse(parts[4]),
        gy1: double.parse(parts[5]),
        gz1: double.parse(parts[6]),
        ax2: double.parse(parts[7]),
        ay2: double.parse(parts[8]),
        az2: double.parse(parts[9]),
        gx2: double.parse(parts[10]),
        gy2: double.parse(parts[11]),
        gz2: double.parse(parts[12]),
        kneeDeg: double.parse(parts[13]),
        marker: int.parse(parts[14]),
      ));
    } catch (_) {
      // Skip malformed rows
    }
  }
  return result;
}

// ---------------------------------------------------------------------------
// meta.json parser
// ---------------------------------------------------------------------------

SessionMeta parseMetaJson(String jsonContent) {
  final map = jsonDecode(jsonContent) as Map<String, dynamic>;
  return SessionMeta.fromJson(map);
}
