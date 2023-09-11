import 'dart:io';

abstract class IRecentItem {
  const IRecentItem({
    required this.file,
    required this.mimeType,
    required this.timestamp,
  });

  final File file;
  final String mimeType;
  final DateTime timestamp;

  IRecentItem copyWith({ DateTime? timestamp });
}

abstract class IRecentDocuments {
  Future<List<IRecentItem>> read();
  Future<void> write(List<IRecentItem> list);
}
