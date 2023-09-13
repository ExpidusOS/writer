import 'package:libtokyo_flutter/libtokyo.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:writer/logic.dart';
import 'document_item.dart';

class RecentDocumentsList extends StatefulWidget {
  const RecentDocumentsList({
    super.key,
    this.recentDocuments,
  });

  final IRecentDocuments? recentDocuments;

  @override
  State<RecentDocumentsList> createState() => _RecentDocumentsListState();
}

class _RecentDocumentsListState extends State<RecentDocumentsList> {
  IRecentDocuments getRecentDocuments(BuildContext context, { bool listen = true })
    => widget.recentDocuments ?? Provider.of<IRecentDocuments>(context, listen: listen);

  @override
  Widget build(BuildContext context) =>
    FutureBuilder(
      future: getRecentDocuments(context).read(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final items = snapshot.data!;

          if (items.isEmpty) return const SizedBox();

          final fmtmngr = FormatManager.of(context);
          items.removeWhere((e) => fmtmngr.extensions.indexOf(path.extension(e.file.path).substring(1)) == -1);

          return Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.listRecent,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                SingleChildScrollView(
                  child: Row(
                    children: items.map(
                      (value) =>
                        TextButton(
                          child: DocumentIcon(path: value.file.path),
                          onPressed: () {
                            final i = items.indexWhere((e) => e.file.path == value.file.path);
                            items.removeAt(i);
                            items.insert(0, value.copyWith(
                              timestamp: DateTime.now(),
                            ));

                            setState(() {
                              getRecentDocuments(context, listen: false).write(items)
                                .catchError((error, stack) => reportError(error, trace: stack));
                            });

                            Navigator.pushNamed(
                              context,
                              '/editor',
                              arguments: {
                                'path': value.file.path,
                              },
                            );
                          },
                        )
                    ).toList(),
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          reportError(snapshot.error!);
          return const SizedBox();
        }

        return const CircularProgressIndicator();
      },
    );
}
