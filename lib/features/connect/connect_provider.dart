// lib/features/connect/connect_provider.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ble/ble_service.dart';
import '../../core/ble/device_status.dart';
import '../../core/config/app_providers.dart';

enum ConnectState { idle, scanning, connected, failed, notFound, permDenied }

class ConnectNotifier extends AsyncNotifier<ConnectState> {
  StreamSubscription? _statusSub;
  DeviceStatus? _lastStatus;

  BleService get _ble => ref.read(bleServiceProvider);

  @override
  Future<ConnectState> build() async {
    ref.onDispose(() => _statusSub?.cancel());
    return ConnectState.idle;
  }

  DeviceStatus? get lastStatus => _lastStatus;

  Future<void> connect() async {
    state = const AsyncValue.data(ConnectState.scanning);
    _statusSub?.cancel();

    final result = await _ble.connectToDevice();

    switch (result) {
      case BleConnectResult.connected:
        _statusSub = _ble.statusStream.listen(
          (s) => _lastStatus = s,
          onError: (_) => state =
              const AsyncValue.data(ConnectState.idle),
        );
        // Request initial status
        await _ble.sendCommand('STATUS');
        state = const AsyncValue.data(ConnectState.connected);
      case BleConnectResult.notFound:
        state = const AsyncValue.data(ConnectState.notFound);
      case BleConnectResult.permissionDenied:
        state = const AsyncValue.data(ConnectState.permDenied);
      case BleConnectResult.failed:
        state = const AsyncValue.data(ConnectState.failed);
    }
  }

  Future<void> disconnect() async {
    await _ble.disconnect();
    _statusSub?.cancel();
    state = const AsyncValue.data(ConnectState.idle);
  }

  Stream<DeviceStatus> get statusStream => _ble.statusStream;
}

final connectProvider =
    AsyncNotifierProvider<ConnectNotifier, ConnectState>(ConnectNotifier.new);

final deviceStatusProvider = StreamProvider<DeviceStatus>((ref) {
  final ble = ref.watch(bleServiceProvider);
  return ble.statusStream;
});
