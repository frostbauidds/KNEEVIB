// lib/mock/mock_wifi_sync_service.dart
// Simulates the ESP32 hotspot API for Demo Mode.

import 'dart:async';
import 'dart:math' as math;

import '../core/wifi/wifi_sync_service.dart';
import '../core/ble/ble_constants.dart';
import 'mock_data_generator.dart';

class MockWifiSyncService implements WifiSyncService {
  final _gen = MockDataGenerator();

  static final _mockSessions = [
    RemoteSession(
      name: '20240101_DEMO_L',
      sizeBytes: 1920000 + 144000 + 512, // vib + imu + meta
      date: '2024-01-01T10:00:00',
    ),
    RemoteSession(
      name: '20240115_DEMO_R',
      sizeBytes: 1920000 + 144000 + 512,
      date: '2024-01-15T14:30:00',
    ),
  ];

  @override
  Future<List<RemoteSession>> listSessions() async {
    await Future.delayed(const Duration(seconds: 1));
    return _mockSessions;
  }

  @override
  Future<List<int>> downloadFile(
    String sessionName,
    String fileName, {
    void Function(int received, int total)? onProgress,
  }) async {
    // Pick profile based on session name
    final profile =
        sessionName.contains('DEMO_L') ? healthyProfile : wornProfile;
    final participantId = 'DEMO';
    final side = sessionName.contains('_L') ? 'L' : 'R';

    List<int> bytes;
    if (fileName == kFileVib) {
      bytes = _gen.generateVibBin(profile, durationS: 10); // short for demo
    } else if (fileName == kFileImu) {
      bytes = _gen.generateImuCsv(profile, durationS: 10).codeUnits;
    } else if (fileName == kFileMeta) {
      bytes = _gen
          .generateMetaJson(profile, participantId, side)
          .codeUnits;
    } else {
      bytes = [];
    }

    // Simulate download progress
    const chunkSize = 4096;
    int received = 0;
    while (received < bytes.length) {
      await Future.delayed(const Duration(milliseconds: 50));
      received = math.min(received + chunkSize, bytes.length);
      onProgress?.call(received, bytes.length);
    }
    return bytes;
  }

  @override
  Future<void> done() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
