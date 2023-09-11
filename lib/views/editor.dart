import 'package:libtokyo_flutter/libtokyo.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:writer/logic.dart';
import 'package:writer/widgets.dart';

class EditorView extends StatelessWidget {
  const EditorView({ super.key });

  @override
  Widget build(BuildContext context) {
    final args = (ModalRoute.of(context)!.settings.arguments ?? <String, String>{}) as Map;

    return Scaffold(
      windowBar: WindowBar.shouldShow(context) ? WindowBar(
        leading: Image.asset('assets/imgs/icon.png'),
        title: Text(AppLocalizations.of(context)!.applicationTitle),
      ) : null,
      appBar: AppBar(
        title: Text(args['path']),
      ),
    );
  }
}
