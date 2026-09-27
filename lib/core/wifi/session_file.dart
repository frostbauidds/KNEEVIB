// lib/core/wifi/session_file.dart
// Download progress tracking model.

class DownloadProgress {
  final String sessionName;
  final String fileName;
  final int received;
  final int total;

  const DownloadProgress({
    required this.sessionName,
    required this.fileName,
    required this.received,
    required this.total,
  });

  double get fraction => total > 0 ? received / total : 0.0;

  bool get isComplete => received >= total && total > 0;
}
