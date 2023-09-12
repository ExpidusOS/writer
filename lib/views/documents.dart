import 'package:libtokyo_flutter/libtokyo.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:writer/logic.dart';
import 'package:writer/widgets.dart';

class DocumentsView extends StatelessWidget {
  const DocumentsView({ super.key });

  void _onNavPush(int i) {
    print(i);
  }

  @override
  Widget build(BuildContext context) {
    final destinations = [
      NavigationDestination(
        icon: const Icon(Icons.home),
        label: AppLocalizations.of(context)!.viewDocuments,
      ),
      NavigationDestination(
        icon: const Icon(Symbols.note_add),
        label: AppLocalizations.of(context)!.actionNew,
      ),
      NavigationDestination(
        icon: const Icon(Icons.settings),
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
                        onTap: () => _onNavPush(i),
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
                    onDestinationSelected: _onNavPush,
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
                    onDestinationSelected: _onNavPush,
                    width: 215,
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
