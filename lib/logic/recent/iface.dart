import 'dart:io';
import 'package:flutter/foundation.dart';

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

abstract class IRecentDocuments extends ChangeNotifier {
  Future<List<IRecentItem>> read();
  IRecentItem create({ required File file, required String mimeType });
  Future<void> write(List<IRecentItem> list);
}
