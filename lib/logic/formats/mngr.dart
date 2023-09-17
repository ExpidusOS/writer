import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'type.dart';

class FormatManager {
  const FormatManager();

  final List<Format> formats = const [];

  List<Format> get rawFormats => (formats.toList()..removeWhere((f) => f.rich || f.code)).toList();
  List<Format> get richFormats => (formats.toList()..retainWhere((f) => f.rich)).toList();
  List<Format> get codeFormats => (formats.toList()..retainWhere((f) => f.code)).toList();

  static FormatManager of(BuildContext context, { bool listen = true }) =>
    Provider.of<FormatManager>(context, listen: listen);
}
