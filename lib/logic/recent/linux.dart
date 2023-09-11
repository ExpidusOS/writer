import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart';
import 'iface.dart';

class LinuxRecentItem implements IRecentItem {
  const LinuxRecentItem({
    required this.file,
    required this.mimeType,
    required this.timestamp,
  });

  final File file;
  final String mimeType;
  final DateTime timestamp;

  void build(XmlBuilder builder) {
    builder.element('RecentItem', nest: () {
      builder.element('URI', nest: () {
        builder.text(file.uri);
      });

      builder.element('Mime-Type', nest: () {
        builder.text(mimeType);
      });

      builder.element('Timestamp', nest: () {
        builder.text((timestamp.microsecondsSinceEpoch ~/ Duration.millisecondsPerSecond).toString());
      });
    });
  }

  @override
  String toString() => file.uri.toString();

  @override
  IRecentItem copyWith({ DateTime? timestamp }) =>
    LinuxRecentItem(
      file: file,
      mimeType: mimeType,
      timestamp: timestamp ?? this.timestamp,
    );
}

class LinuxRecentDocuments implements IRecentDocuments {
  const LinuxRecentDocuments();

  File _getFile() =>
    File('${Platform.environment["HOME"]}/.recently-used');

  @override
  Future<List<IRecentItem>> read() async {
    if (await _getFile().exists()) {
      final document = XmlDocument.parse(await _getFile().readAsString());
      return document.firstElementChild!.childElements.map(
        (el) =>
          LinuxRecentItem(
            file: File.fromUri(Uri.parse(el.getElement('URI')!.innerText)),
            mimeType: el.getElement('Mime-Type')!.innerText,
            timestamp: DateTime.fromMicrosecondsSinceEpoch(int.parse(el.getElement('Timestamp')!.innerText) * Duration.millisecondsPerSecond),
          )
      ).toList();
    }
    return [];
  }

  @override
  Future<void> write(List<IRecentItem> list) async {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0"');
    builder.element('RecentFiles', nest: () {
      for (final el in list) (el as LinuxRecentItem).build(builder);
    });

    final document = builder.buildDocument();
    await _getFile().writeAsString(document.toXmlString(pretty: true, indent: '  '));
  }
}
