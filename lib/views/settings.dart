import 'package:libtokyo_flutter/libtokyo.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/logic.dart';
import 'package:writer/main.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({ super.key });

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late SharedPreferences preferences;
  bool optInErrorReporting = false;
  ColorScheme colorScheme = ColorScheme.night;

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((prefs) => setState(() {
      preferences = prefs;
      _loadSettings();
    })).catchError((error, trace) {
      reportError(error, trace: trace);
    });
  }

  void _loadSettings() {
    optInErrorReporting = preferences.getBool(WriterSettings.optInErrorReporting.name) ?? false;
    colorScheme = ColorScheme.values.asNameMap()[preferences.getString(WriterSettings.colorScheme.name) ?? 'night']!;
  }

  @override
  Widget build(BuildContext context) =>
    Scaffold(
      windowBar: WindowBar.shouldShow(context) ? WindowBar(
        leading: Image.asset('assets/imgs/icon.png'),
        title: Text(AppLocalizations.of(context)!.applicationTitle),
      ) : null,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.viewSettings),
      ),
      body: ListTileTheme(
        tileColor: Theme.of(context).cardTheme.color
          ?? Theme.of(context).cardColor,
        shape: Theme.of(context).cardTheme.shape,
        contentPadding: Theme.of(context).cardTheme.margin,
        child: ListView(
          children: [
            ListTile(
              title: Text(AppLocalizations.of(context)!.settingsTheme),
              onTap: () =>
                showDialog<ColorScheme>(
                  context: context,
                  builder: (context) =>
                    Dialog(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView(
                          children: [
                            RadioListTile(
                              title: const Text('Storm'), // TODO: i18n
                              value: ColorScheme.storm,
                              groupValue: colorScheme,
                              onChanged: (value) => Navigator.pop(context, value),
                            ),
                            RadioListTile(
                              title: const Text('Night'), // TODO: i18n
                              value: ColorScheme.night,
                              groupValue: colorScheme,
                              onChanged: (value) => Navigator.pop(context, value),
                            ),
                            RadioListTile(
                              title: const Text('Moon'), // TODO: i18n
                              value: ColorScheme.moon,
                              groupValue: colorScheme,
                              onChanged: (value) => Navigator.pop(context, value),
                            ),
                            RadioListTile(
                              title: const Text('Day'), // TODO: i18n
                              value: ColorScheme.day,
                              groupValue: colorScheme,
                              onChanged: (value) => Navigator.pop(context, value),
                            ),
                          ],
                        ),
                      ),
                    ),
                ).then((value) {
                  if (value != null) {
                    preferences.setString(
                      WriterSettings.colorScheme.name,
                      value.name
                    );

                    setState(() {
                      colorScheme = value;
                      WriterApp.reload(context);
                    });
                  }
                }),
            ),
            ...(const String.fromEnvironment('SENTRY_DSN', defaultValue: '').isNotEmpty ? [
              SwitchListTile(
                title: Text(AppLocalizations.of(context)!.settingsOptInErrorReportingTitle),
                subtitle: Text(AppLocalizations.of(context)!.settingsOptInErrorReportingSubtitle),
                value: optInErrorReporting,
                onChanged: (value) {
                  preferences.setBool(
                    WriterSettings.optInErrorReporting.name,
                    value);

                  setState(() {
                    optInErrorReporting = value;
                  });
                }
              ),
            ] : []),
            ListTile(
              title: Text(AppLocalizations.of(context)!.settingsRestore),
              onTap: () {
                preferences.clear();

                setState(() {
                  _loadSettings();
                  WriterApp.reload(context);
                });
              },
            ),
            const Divider(),
            ListTile(
              title: Text(AppLocalizations.of(context)!.viewPrivacy),
              onTap: () =>
                Navigator.pushNamed(context, '/privacy'),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.viewAbout),
              onTap: () =>
                Navigator.pushNamed(context, '/about'),
            ),
          ],
        ),
      ),
    );
}
