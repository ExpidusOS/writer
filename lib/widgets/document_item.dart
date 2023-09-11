import 'package:path/path.dart' as Path;
import 'package:libtokyo_flutter/libtokyo.dart';
import 'package:writer/logic.dart';

class DocumentIcon extends StatelessWidget {
  const DocumentIcon({
    super.key,
    required this.path,
  });

  final String path;

  @override
  Widget build(BuildContext context) =>
    Column(
      children: [
        Icon(
          Icons.short_text,
          size: 106,
        ),
        Text(Path.basename(path)),
      ],
    );
}
