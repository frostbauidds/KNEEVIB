// lib/mock/mock_ble_service.dart
// Simulates the ESP32 BLE device for Demo Mode.

import 'dart:async';
import 'dart:math' as math;

import '../core/ble/ble_constants.dart';
import '../core/ble/ble_service.dart';
import '../core/ble/device_status.dart';

class MockBleService implements BleService {
  final _statusController = StreamController<DeviceStatus>.broadcast();
  bool _connected = false;
  String _state = kStateIdle;
  int _battery = 78;
  int _sdFree = 1240;
  String _lastSession = '20240101_P001_L';
  Timer? _recordingTimer;
  int _countdown = 0;

  @override
  Stream<DeviceStatus> get statusStream => _statusController.stream;

  @override
  bool get isConnected => _connected;

  @override
  Future<BleConnectResult> connectToDevice() async {
    await Future.delayed(const Duration(seconds: 2)); // simulate scan
    _connected = true;
    _pushStatus();
    return BleConnectResult.connected;
  }

  @override
  Future<void> disconnect() async {
    _connected = false;
    _recordingTimer?.cancel();
  }

  @override
  Future<void> sendCommand(String command) async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (command == kCmdStatus) {
      _pushStatus();
    } else if (command == kCmdCal) {
      _simulateCalibration();
    } else if (command.startsWith('START')) {
      _simulateRecording();
    } else if (command == kCmdSync) {
      _state = kStateSync;
      _pushStatus(ssid: 'KneeVib_AP', password: 'kneevib123');
    }
  }

  @override
  Future<DeviceStatus> requestStatus() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _pushStatus();
    return _currentStatus();
  }

  void _simulateCalibration() async {
    _state = kStateCalibrating;
    _pushStatus();
    await Future.delayed(const Duration(seconds: 20));
    _state = kStateIdle;
    _pushStatus();
  }

  void _simulateRecording() async {
    _state = kStateRecording;
    _pushStatus();
    // BLE is "off" during recording — no pushes for 60 s (compressed to 5 s)
    await Future.delayed(const Duration(seconds: 5));
    _state = kStateSaved;
    _lastSession =
        '${DateTime.now().toString().substring(0, 10).replaceAll('-', '')}_P001_L';
    _sdFree -= 2;
    _connected = false; // simulate BLE disconnect after recording
    _statusController.addError('disconnected');
    // Re-connect after 2 s
    await Future.delayed(const Duration(seconds: 2));
    _connected = true;
    _pushStatus();
  }

  void _pushStatus({String? ssid, String? password}) {
    _statusController.add(_currentStatus(ssid: ssid, password: password));
  }

  DeviceStatus _currentStatus({String? ssid, String? password}) =>
      DeviceStatus(
        state: _state,
        battery: _battery,
        sdFreeMb: _sdFree,
        lastSession: _lastSession,
        missedSamples: 0,
        ssid: ssid,
        password: password,
      );

  @override
  void dispose() {
    _statusController.close();
    _recordingTimer?.cancel();
  }
}
