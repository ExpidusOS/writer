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
          Icons.fileLines,
          size: 48,
        ),
        Text(Path.basename(path)),
      ],
    );
}
