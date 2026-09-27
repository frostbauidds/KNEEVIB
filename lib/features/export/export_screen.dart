// lib/features/export/export_screen.dart
// Zip a session's files and share; optionally POST to a configurable server URL.

import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:dio/dio.dart';

import '../../core/config/app_providers.dart';
import '../../core/db/app_database.dart';

class ExportScreen extends ConsumerStatefulWidget {
  final int sessionId;
  const ExportScreen({super.key, required this.sessionId});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  bool _exporting = false;
  bool _uploading = false;
  String? _status;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uploadEnabled = ref.watch(exportUploadEnabledProvider);
    final serverUrl = ref.watch(exportServerUrlProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Export Session')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: theme.colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.privacy_tip_outlined,
                        color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Export includes only the raw recording files '
                        'and computed features. No personal data.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Share as zip
            Text('Share as zip', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _exporting ? null : _exportZip,
                icon: _exporting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.share_outlined),
                label: const Text('Share zip'),
              ),
            ),
            const SizedBox(height: 32),

            // Upload section
            Text('Upload to server', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Enable upload'),
              subtitle: const Text('Off by default. No data leaves the phone unless you enable this.'),
              value: uploadEnabled,
              onChanged: (v) =>
                  ref.read(exportUploadEnabledProvider.notifier).state = v,
              contentPadding: EdgeInsets.zero,
            ),
            if (uploadEnabled) ...[
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Server URL',
                  hintText: 'https://your-server.example.com/upload',
                  prefixIcon: Icon(Icons.cloud_upload_outlined),
                ),
                onChanged: (v) =>
                    ref.read(exportServerUrlProvider.notifier).state = v,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed:
                      _uploading || serverUrl.isEmpty ? null : _upload,
                  icon: _uploading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.cloud_upload_outlined),
                  label: const Text('Upload to server'),
                ),
              ),
            ],

            // Status / error
            if (_status != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.check_circle_outline,
                      color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(_status!,
                          style: TextStyle(color: theme.colorScheme.primary))),
                ],
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.error_outline,
                      color: theme.colorScheme.error),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(_error!,
                          style: TextStyle(color: theme.colorScheme.error))),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<String?> _buildZip() async {
    final db = ref.read(databaseProvider);
    final sessions = await db.getAllSessions();
    final session = sessions.firstWhere((s) => s.id == widget.sessionId);

    if (session.localPath == null) {
      setState(() => _error = 'Session files not found on device.');
      return null;
    }

    final dir = Directory(session.localPath!);
    if (!await dir.exists()) {
      setState(() => _error = 'Session directory missing.');
      return null;
    }

    final tmpDir = await getTemporaryDirectory();
    final zipPath =
        p.join(tmpDir.path, '${session.name}.zip');
    final encoder = ZipFileEncoder();
    encoder.create(zipPath);
    await for (final entity in dir.list()) {
      if (entity is File) {
        encoder.addFile(entity);
      }
    }
    encoder.close();
    return zipPath;
  }

  Future<void> _exportZip() async {
    setState(() {
      _exporting = true;
      _status = null;
      _error = null;
    });
    try {
      final zipPath = await _buildZip();
      if (zipPath == null) return;
      await Share.shareXFiles([XFile(zipPath)],
          text: 'KneeVib session export');
      setState(() => _status = 'Shared successfully.');
    } catch (e) {
      setState(() => _error = 'Export failed: $e');
    } finally {
      setState(() => _exporting = false);
    }
  }

  Future<void> _upload() async {
    final serverUrl = ref.read(exportServerUrlProvider);
    setState(() {
      _uploading = true;
      _status = null;
      _error = null;
    });
    try {
      final zipPath = await _buildZip();
      if (zipPath == null) return;

      final dio = Dio();
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(zipPath,
            filename: p.basename(zipPath)),
      });
      await dio.post(serverUrl, data: formData);
      setState(() => _status = 'Uploaded to $serverUrl.');
    } catch (e) {
      setState(() => _error = 'Upload failed: $e');
    } finally {
      setState(() => _uploading = false);
    }
  }
}
