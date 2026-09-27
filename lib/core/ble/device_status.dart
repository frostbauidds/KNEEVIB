// lib/core/ble/device_status.dart
import 'dart:convert';

/// Parsed representation of the Status JSON from the ESP32.
class DeviceStatus {
  final String state;
  final int battery;
  final int sdFreeMb;
  final String lastSession;
  final int missedSamples;
  final String? ssid;
  final String? password;

  const DeviceStatus({
    required this.state,
    required this.battery,
    required this.sdFreeMb,
    required this.lastSession,
    required this.missedSamples,
    this.ssid,
    this.password,
  });

  factory DeviceStatus.fromJson(Map<String, dynamic> json) => DeviceStatus(
        state: json['state'] as String? ?? 'IDLE',
        battery: json['battery'] as int? ?? 0,
        sdFreeMb: json['sd_free_mb'] as int? ?? 0,
        lastSession: json['last_session'] as String? ?? '',
        missedSamples: json['missed_samples'] as int? ?? 0,
        ssid: json['ssid'] as String?,
        password: json['password'] as String?,
      );

  factory DeviceStatus.fromJsonString(String raw) =>
      DeviceStatus.fromJson(jsonDecode(raw) as Map<String, dynamic>);

  DeviceStatus copyWith({
    String? state,
    int? battery,
    int? sdFreeMb,
    String? lastSession,
    int? missedSamples,
    String? ssid,
    String? password,
  }) =>
      DeviceStatus(
        state: state ?? this.state,
        battery: battery ?? this.battery,
        sdFreeMb: sdFreeMb ?? this.sdFreeMb,
        lastSession: lastSession ?? this.lastSession,
        missedSamples: missedSamples ?? this.missedSamples,
        ssid: ssid ?? this.ssid,
        password: password ?? this.password,
      );

  bool get isSdFull => sdFreeMb <= 0;

  @override
  String toString() =>
      'DeviceStatus(state=$state, battery=$battery%, sd=$sdFreeMb MB)';
}
