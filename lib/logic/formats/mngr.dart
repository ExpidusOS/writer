import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class FormatManager {
  const FormatManager();

  List<String> get extensions => ['md', 'txt'];

  static FormatManager of(BuildContext context, { bool listen = true }) =>
    Provider.of<FormatManager>(context, listen: listen);
}
