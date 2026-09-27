// lib/core/config/app_providers.dart
// Root Riverpod providers — wire real vs mock implementations.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ble/ble_service.dart';
import '../ble/real_ble_service.dart';
import '../db/app_database.dart';
import '../wifi/wifi_sync_service.dart';
import '../wifi/real_wifi_sync_service.dart';
import '../../mock/mock_ble_service.dart';
import '../../mock/mock_wifi_sync_service.dart';
// ─── Demo mode ───────────────────────────────────────────────────────────────
final demoModeProvider = StateProvider<bool>((ref) => false);

// ─── Shared preferences ──────────────────────────────────────────────────────
final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});

// ─── Database ────────────────────────────────────────────────────────────────
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

// ─── BLE service ─────────────────────────────────────────────────────────────
final bleServiceProvider = Provider<BleService>((ref) {
  final demo = ref.watch(demoModeProvider);
  final service = demo ? MockBleService() : RealBleService();
  ref.onDispose(service.dispose);
  return service;
});

// ─── Wi-Fi sync service ───────────────────────────────────────────────────────
final wifiSyncServiceProvider = Provider<WifiSyncService>((ref) {
  final demo = ref.watch(demoModeProvider);
  return demo ? MockWifiSyncService() : RealWifiSyncService();
});

// ─── Export server URL ───────────────────────────────────────────────────────
final exportServerUrlProvider = StateProvider<String>((ref) => '');
final exportUploadEnabledProvider = StateProvider<bool>((ref) => false);

// ─── Consent given ───────────────────────────────────────────────────────────
final consentGivenProvider = Provider<bool>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return prefs.getBool('consent_given') ?? false;
});
