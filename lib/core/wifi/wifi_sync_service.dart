// lib/core/wifi/wifi_sync_service.dart
// Abstract interface for the Wi-Fi hotspot sync protocol.

import 'session_file.dart';

abstract class WifiSyncService {
  /// Fetch the list of sessions available on the device SD card.
  Future<List<RemoteSession>> listSessions();

  /// Download a single file from a session, reporting bytes received.
  /// [onProgress]: (received, total) in bytes.
  Future<List<int>> downloadFile(
    String sessionName,
    String fileName, {
    void Function(int received, int total)? onProgress,
  });

  /// Tell the device to leave sync mode and shut down the hotspot.
  Future<void> done();
}

/// Metadata for a session available on the ESP32 SD card.
class RemoteSession {
  final String name;
  final int sizeBytes;
  final String date;

  const RemoteSession({
    required this.name,
    required this.sizeBytes,
    required this.date,
  });

  factory RemoteSession.fromJson(Map<String, dynamic> json) => RemoteSession(
        name: json['name'] as String,
        sizeBytes: json['size_bytes'] as int,
        date: json['date'] as String,
      );
}
