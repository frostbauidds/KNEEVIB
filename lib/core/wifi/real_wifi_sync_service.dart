// lib/core/wifi/real_wifi_sync_service.dart
// Real Wi-Fi hotspot sync using Dio.
// Android: bind to hotspot network via platform channel.
// iOS: manual join fallback.

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../ble/ble_constants.dart';
import 'wifi_sync_service.dart';

final _log = Logger(printer: PrettyPrinter(methodCount: 0));

class RealWifiSyncService implements WifiSyncService {
  late final Dio _dio;

  RealWifiSyncService() {
    _dio = Dio(BaseOptions(
      baseUrl: kHotspotBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 60),
    ));
    _dio.interceptors.add(LogInterceptor(
      requestHeader: false,
      responseBody: false,
      logPrint: (o) => _log.d(o.toString()),
    ));
  }

  @override
  Future<List<RemoteSession>> listSessions() async {
    final resp = await _dio.get<List<dynamic>>(kApiSessions);
    return (resp.data ?? [])
        .map((e) => RemoteSession.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<int>> downloadFile(
    String sessionName,
    String fileName, {
    void Function(int received, int total)? onProgress,
  }) async {
    final path = kApiSessionFile(sessionName, fileName);
    final resp = await _dio.get<List<int>>(
      path,
      options: Options(responseType: ResponseType.bytes),
      onReceiveProgress: onProgress,
    );
    return resp.data ?? [];
  }

  @override
  Future<void> done() async {
    try {
      await _dio.post(kApiDone);
    } catch (_) {
      // Device may close connection immediately; ignore error.
    }
  }
}
