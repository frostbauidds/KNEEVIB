// lib/core/ble/real_ble_service.dart
// Real BLE implementation using flutter_blue_plus.

import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:logger/logger.dart';

import 'ble_constants.dart';
import 'ble_service.dart';
import 'device_status.dart';

final _log = Logger(printer: PrettyPrinter(methodCount: 0));

class RealBleService implements BleService {
  BluetoothDevice? _device;
  BluetoothCharacteristic? _commandChar;
  BluetoothCharacteristic? _statusChar;
  StreamSubscription? _statusSub;
  StreamSubscription? _disconnectSub;

  final _statusController = StreamController<DeviceStatus>.broadcast();

  @override
  Stream<DeviceStatus> get statusStream => _statusController.stream;

  @override
  bool get isConnected =>
      _device != null &&
      _device!.isConnected;

  @override
  Future<BleConnectResult> connectToDevice() async {
    try {
      // Ensure BLE is on
      if (await FlutterBluePlus.adapterState.first != BluetoothAdapterState.on) {
        return BleConnectResult.permissionDenied;
      }

      // Scan for KneeVib device
      BluetoothDevice? found;
      final completer = Completer<BluetoothDevice?>();
      final scanSub = FlutterBluePlus.scanResults.listen((results) {
        for (final r in results) {
          if (r.device.platformName == kBleDeviceName) {
            completer.complete(r.device);
            break;
          }
        }
      });

      FlutterBluePlus.startScan(
        withNames: [kBleDeviceName],
        timeout: const Duration(seconds: 10),
      );

      found = await completer.future.timeout(
        const Duration(seconds: 12),
        onTimeout: () => null,
      );
      await scanSub.cancel();
      FlutterBluePlus.stopScan();

      if (found == null) return BleConnectResult.notFound;

      _device = found;
      await _device!.connect(timeout: const Duration(seconds: 10));

      // Discover services
      final services = await _device!.discoverServices();
      BluetoothService? kvService;
      for (final s in services) {
        if (s.uuid.toString().toUpperCase() ==
            kBleServiceUuid.toUpperCase()) {
          kvService = s;
          break;
        }
      }
      if (kvService == null) {
        await _device!.disconnect();
        return BleConnectResult.failed;
      }

      for (final c in kvService.characteristics) {
        final uuid = c.uuid.toString().toUpperCase();
        if (uuid == kBleCommandCharUuid.toUpperCase()) _commandChar = c;
        if (uuid == kBleStatusCharUuid.toUpperCase()) _statusChar = c;
      }

      // Subscribe to status notifications
      if (_statusChar != null) {
        await _statusChar!.setNotifyValue(true);
        _statusSub = _statusChar!.onValueReceived.listen((bytes) {
          try {
            final json = utf8.decode(bytes);
            final status = DeviceStatus.fromJsonString(json);
            _statusController.add(status);
          } catch (e) {
            _log.w('Failed to parse status JSON: $e');
          }
        });
      }

      // Listen for unexpected disconnects
      _disconnectSub = _device!.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _log.i('Device disconnected');
          _cleanup();
        }
      });

      _log.i('Connected to $_device');
      return BleConnectResult.connected;
    } catch (e) {
      _log.e('BLE connect error: $e');
      return BleConnectResult.failed;
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      await _device?.disconnect();
    } finally {
      _cleanup();
    }
  }

  void _cleanup() {
    _statusSub?.cancel();
    _disconnectSub?.cancel();
    _commandChar = null;
    _statusChar = null;
    _device = null;
  }

  @override
  Future<void> sendCommand(String command) async {
    if (_commandChar == null) throw StateError('Not connected');
    await _commandChar!.write(utf8.encode(command), withoutResponse: false);
    _log.d('BLE TX: $command');
  }

  @override
  Future<DeviceStatus> requestStatus() async {
    await sendCommand(kCmdStatus);
    return statusStream.first.timeout(const Duration(seconds: 5));
  }

  @override
  void dispose() {
    _statusController.close();
    _statusSub?.cancel();
    _disconnectSub?.cancel();
  }
}
