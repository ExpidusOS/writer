import 'package:libtokyo_flutter/libtokyo.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:writer/logic.dart';
import 'package:writer/widgets.dart';

class DocumentsView extends StatelessWidget {
  const DocumentsView({ super.key });

  @override
  Widget build(BuildContext context) =>
    Scaffold(
      windowBar: WindowBar.shouldShow(context) ? WindowBar(
        leading: Image.asset('assets/imgs/icon.png'),
        title: Text(AppLocalizations.of(context)!.applicationTitle),
      ) : null,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.viewDocuments),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => <PopupMenuEntry>[
              PopupMenuItem(
                value: 'new',
                child: Text(AppLocalizations.of(context)!.actionNew),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          const RecentDocumentsList(),
        ],
      ),
    );
}
