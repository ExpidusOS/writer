import 'dart:io';
import 'package:libtokyo_flutter/libtokyo.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mime_type/mime_type.dart';
import 'package:provider/provider.dart';
import 'package:writer/logic.dart';
import 'package:writer/widgets.dart';

class DocumentsView extends StatelessWidget {
  const DocumentsView({ super.key });

  void _onNavPush(BuildContext context, int i) {
    switch (i) {
      case 1:
        showDialog(
          context: context,
          builder: (context) {
            String? name;
            Format? format;
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.documentName),
              content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextField(
                          decoration: InputDecoration(
                            icon: const Icon(Icons.file),
                            hintText: AppLocalizations.of(context)!.documentNameField,
                            border: const UnderlineInputBorder(),
                          ),
                          onChanged: (value) =>
                            setState(() {
                              name = value;
                            }),
                          onSubmitted: (value) =>
                            setState(() {
                              if (name != null && format != null) {
                                Navigator.pop(context, {
                                  'name': name,
                                  'format': format,
                                });
                              }
                            }),
                        ),
                        DropdownButton(
                          hint: Text(AppLocalizations.of(context)!.documentNameType),
                          items: FormatManager.of(context, listen: false).formats.map(
                            (value) => DropdownMenuItem(value: value, child: Text(value.prettyName))
                          ).toList(),
                          value: format,
                          isExpanded: true,
                          onChanged: (value) =>
                            setState(() {
                              format = value;
                            }),
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(AppLocalizations.of(context)!.documentNameCancel),
                            ),
                            TextButton(
                              onPressed:
                                name != null && format != null
                                  ? () =>
                                      Navigator.pop(context, {
                                        'name': name,
                                        'format': format,
                                      })
                                  : null,
                              child: Text(AppLocalizations.of(context)!.documentNameEnter),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ).then((result) {
          if (result != null) {
            print(result);
          }
        }).catchError((error, stack) => reportError(error, trace: stack));
        break;
      case 2:
        openFile(
          acceptedTypeGroups: [
            XTypeGroup(
              label: AppLocalizations.of(context)!.formatAll,
              extensions: FormatManager.of(context, listen: false).formats.map((e) => e.ext).toList(),
            ),
            XTypeGroup(
              label: AppLocalizations.of(context)!.formatRaw,
              extensions: FormatManager.of(context, listen: false).rawFormats.map((e) => e.ext).toList(),
            ),
            XTypeGroup(
              label: AppLocalizations.of(context)!.formatRich,
              extensions: FormatManager.of(context, listen: false).richFormats.map((e) => e.ext).toList(),
            ),
            XTypeGroup(
              label: AppLocalizations.of(context)!.formatCode,
              extensions: FormatManager.of(context, listen: false).codeFormats.map((e) => e.ext).toList(),
            ),
          ],
        ).then((file) async {
          if (file != null) {
            final recentDocuments = Provider.of<IRecentDocuments>(context, listen: false);
            final list = await recentDocuments.read();
            final item = recentDocuments.create(
              file: File(file!.path),
              mimeType: mime(file!.path)!,
            );

            final i = list.indexWhere((e) => e.file == item.file);
            if (i == -1) list.insert(0, item);
            else list[i] = item;
            await recentDocuments.write(list);

            Navigator.pushNamed(
              context,
              '/editor',
              arguments: {
                'path': item.file.path,
              },
            );
          }
        }).catchError((error, stack) => reportError(error, trace: stack));
        break;
      case 3:
        Navigator.pushNamed(
          context,
          '/settings'
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final destinations = [
      NavigationDestination(
        icon: const Icon(Icons.home),
        label: AppLocalizations.of(context)!.viewDocuments,
      ),
      NavigationDestination(
        icon: const Icon(Icons.fileCirclePlus),
        label: AppLocalizations.of(context)!.actionNew,
      ),
      NavigationDestination(
        icon: const Icon(Icons.filePen),
        label: AppLocalizations.of(context)!.actionOpen,
      ),
      NavigationDestination(
        icon: const Icon(Icons.gears),
        label: AppLocalizations.of(context)!.viewSettings,
      ),
    ];

    return Scaffold(
      windowBar: WindowBar.shouldShow(context) ? WindowBar(
        leading: Image.asset('assets/imgs/icon.png'),
        title: Text(AppLocalizations.of(context)!.applicationTitle),
      ) : null,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.viewDocuments),
      ),
      drawer: Breakpoints.small.isActive(context)
        ? Drawer(
            child: ListView(
              children: destinations
                .asMap().map(
                  (i, value) =>
                    MapEntry(
                      i,
                      ListTile(
                        title: Text(value.label),
                        leading: value.icon,
                        onTap: () => _onNavPush(context, i),
                      )
                    )
                )
                .values.toList(),
            ),
          )
        : null,
      body: AdaptiveLayout(
        internalAnimations: false,
        primaryNavigation: SlotLayout(
          config: <Breakpoint, SlotLayoutConfig>{
            Breakpoints.medium: SlotLayout.from(
              key: const Key('navMedium'),
              builder: (context) =>
                NavigationRailTheme(
                  data: Theme.of(context).navigationRailTheme.copyWith(
                    elevation: AppBarTheme.of(context).elevation ?? Theme.of(context).appBarTheme.elevation ?? 4,
                  ),
                  child: AdaptiveScaffold.standardNavigationRail(
                    destinations: destinations
                      .map((_) => AdaptiveScaffold.toRailDestination(_))
                      .toList(),
                    selectedIndex: 0,
                    selectedLabelTextStyle: Theme.of(context).textTheme.bodyLarge,
                    unSelectedLabelTextStyle: Theme.of(context).textTheme.bodyLarge,
                    selectedIconTheme: IconTheme.of(context).copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    unselectedIconTheme: IconTheme.of(context).copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onDestinationSelected: (i) => _onNavPush(context, i),
                  ),
                ),
            ),
            Breakpoints.large: SlotLayout.from(
              key: const Key('navLarge'),
              builder: (context) =>
                NavigationRailTheme(
                  data: Theme.of(context).navigationRailTheme.copyWith(
                    elevation: AppBarTheme.of(context).elevation ?? Theme.of(context).appBarTheme.elevation ?? 4,
                  ),
                  child: AdaptiveScaffold.standardNavigationRail(
                    destinations: destinations
                      .map((_) => AdaptiveScaffold.toRailDestination(_))
                      .toList(),
                    selectedIndex: 0,
                    selectedLabelTextStyle: Theme.of(context).textTheme.bodyLarge,
                    unSelectedLabelTextStyle: Theme.of(context).textTheme.bodyLarge,
                    selectedIconTheme: IconTheme.of(context).copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    unselectedIconTheme: IconTheme.of(context).copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onDestinationSelected: (i) => _onNavPush(context, i),
                    width: 230,
                    extended: true,
                  ),
                ),
            ),
          },
        ),
        body: SlotLayout(
          config: <Breakpoint, SlotLayoutConfig?>{
            Breakpoints.standard: SlotLayout.from(
              key: const Key('body'),
              builder: (context) =>
                Column(
                  children: [
                    const RecentDocumentsList(),
                  ],
                ),
            ),
          },
        ),
      ),
    );
  }
}
