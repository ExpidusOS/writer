import 'package:libtokyo_flutter/libtokyo.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:writer/logic.dart';
import 'document_item.dart';

class RecentDocumentsList extends StatefulWidget {
  const RecentDocumentsList({
    super.key,
    this.recentDocuments = const LinuxRecentDocuments(),
  });

  final IRecentDocuments recentDocuments;

  @override
  State<RecentDocumentsList> createState() => _RecentDocumentsListState();
}

class _RecentDocumentsListState extends State<RecentDocumentsList> {
  final List<IRecentItem> _items = [];

  @override
  void initState() {
    super.initState();

    widget.recentDocuments.read()
      .then((items) {
        setState(() {
          _items.clear();
          _items.addAll(items);
        });
      })
      .catchError((error, stack) => reportError(error, trace: stack));
  }

  @override
  Widget build(BuildContext context) =>
    _items.isEmpty
      ? const SizedBox()
      : Padding(
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
                  children: _items.map(
                    (value) =>
                      TextButton(
                        child: DocumentIcon(path: value.file.path),
                        onPressed: () {
                          final i = _items.indexWhere((e) => e.file.path == value.file.path);
                          _items.removeAt(i);
                          _items.insert(0, value.copyWith(
                            timestamp: DateTime.now(),
                          ));

                          setState(() {
                            widget.recentDocuments.write(_items)
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
