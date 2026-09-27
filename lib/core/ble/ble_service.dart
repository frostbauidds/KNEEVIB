// lib/core/ble/ble_service.dart
// Abstract interface for BLE operations.
// Real implementation uses flutter_blue_plus; Mock implementation returns
// synthetic data for Demo Mode.

import 'device_status.dart';

/// Result of a connect attempt.
enum BleConnectResult { connected, notFound, permissionDenied, failed }

/// Abstract BLE service interface.
abstract class BleService {
  /// Stream of status updates pushed by the device (notify characteristic).
  Stream<DeviceStatus> get statusStream;

  /// Whether the device is currently connected.
  bool get isConnected;

  /// Scan for the KneeVib device and connect to it.
  Future<BleConnectResult> connectToDevice();

  /// Disconnect from the device.
  Future<void> disconnect();

  /// Send a UTF-8 command string to the command characteristic.
  Future<void> sendCommand(String command);

  /// Convenience: send STATUS and return the first parsed response.
  Future<DeviceStatus> requestStatus();

  /// Dispose resources.
  void dispose();
}
