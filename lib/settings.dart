import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n.dart';
import 'main.dart';
import 'app_localizations.dart';

class SettingsPage extends StatefulWidget {
  final Function(bool) toggleDarkMode;
  final bool isDarkMode;

  SettingsPage({required this.toggleDarkMode, required this.isDarkMode});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedMapStyle = 'Standard';
  late bool _isDarkMode;
  late String _selectedLanguage;
  late bool _isMetric;
  late String _selectedSpheroid;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
    _selectedLanguage = 'de'; // Initialize _selectedLanguage here
    _isMetric = true; // Initialize _isMetric here
    _selectedSpheroid = 'WGS84'; // Initialize _selectedSpheroid here
    _loadSettings();
  }

  void _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? widget.isDarkMode;
      _selectedLanguage = prefs.getString('language') ?? 'de';
      _isMetric = prefs.getBool('isMetric') ?? true;
      _selectedSpheroid = prefs.getString('spheroid') ?? 'WGS84';
      _selectedMapStyle = prefs.getString('mapStyle') ?? 'Standard';
    });
  }

  void _saveSettings(String mapStyle) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('mapStyle', mapStyle);
  }

  void _onToggleDarkMode(bool value) {
    setState(() {
      _isDarkMode = value;
    });
    widget.toggleDarkMode(value);
  }

  void _onLanguageChanged(String? language) async {
    if (language != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _selectedLanguage = language;
      });
      prefs.setString('language', language);
      // Restart the app or update the locale
      MyApp.setLocale(context, Locale(language));
    }
  }

  void _onToggleUnit(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isMetric = value;
    });
    prefs.setBool('isMetric', value);
  }

  void _onSpheroidChanged(String? spheroid) async {
    if (spheroid != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _selectedSpheroid = spheroid;
      });
      prefs.setString('spheroid', spheroid);
    }
  }

  void _resetSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    setState(() {
      _isDarkMode = widget.isDarkMode;
      _selectedLanguage = 'de';
      _isMetric = true;
      _selectedSpheroid = 'WGS84';
      _selectedMapStyle = 'Standard';
    });
    widget.toggleDarkMode(widget.isDarkMode);
    MyApp.setLocale(context, Locale('de'));
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(localizations.settingstitle)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: Text(localizations.darkMode),
              value: _isDarkMode,
              onChanged: _onToggleDarkMode,
              activeColor: Colors.amber[800],
            ),
            SwitchListTile(
              title: Text(localizations.unit),
              value: _isMetric,
              onChanged: _onToggleUnit,
              activeColor: Colors.amber[800],
            ),
            SizedBox(height: 20.0),
            Text(
              localizations.sellang,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Column(
              children: L10n.all.map((locale) {
                return RadioListTile<String>(
                  title: Text(L10n.getLanguageName(locale.languageCode)),
                  value: locale.languageCode,
                  groupValue: _selectedLanguage,
                  onChanged: _onLanguageChanged,
                  activeColor: Colors.amber[800],
                );
              }).toList(),
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  localizations.mapstyle,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                DropdownButton<String>(
                  value: _selectedMapStyle,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedMapStyle = newValue!;
                      _saveSettings(_selectedMapStyle);
                    });
                  },
                  items: <String>[
                    'Standard',
                    'Atlas',
                    'Mobile Atlas',
                    'OpenCycle',
                    'Transport',
                    'Transport Dark',
                    'Landscape',
                    'Outdoors',
                    'Spinal Map',
                    'Pioneer',
                    'Mapbox',
                    'Satellite Image'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(height: 25.0),
            Text(
              localizations.spheroid,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Column(
              children: [
                RadioListTile<String>(
                  title: Text('WGS84'),
                  value: 'WGS84',
                  groupValue: _selectedSpheroid,
                  onChanged: _onSpheroidChanged,
                  activeColor: Colors.amber[800],
                ),
                RadioListTile<String>(
                  title: Text('GRS80'),
                  value: 'GRS80',
                  groupValue: _selectedSpheroid,
                  onChanged: _onSpheroidChanged,
                  activeColor: Colors.amber[800],
                ),
                RadioListTile<String>(
                  title: Text('Bessel 1841'),
                  value: 'Bessel 1841',
                  groupValue: _selectedSpheroid,
                  onChanged: _onSpheroidChanged,
                  activeColor: Colors.amber[800],
                ),
                RadioListTile<String>(
                  title: Text('Krassowski 1940'),
                  value: 'Krassowski 1940',
                  groupValue: _selectedSpheroid,
                  onChanged: _onSpheroidChanged,
                  activeColor: Colors.amber[800],
                ),
                RadioListTile<String>(
                  title: Text('International 1924'),
                  value: 'International 1924',
                  groupValue: _selectedSpheroid,
                  onChanged: _onSpheroidChanged,
                  activeColor: Colors.amber[800],
                ),
                RadioListTile<String>(
                  title: Text('Clarke 1866'),
                  value: 'Clarke 1866',
                  groupValue: _selectedSpheroid,
                  onChanged: _onSpheroidChanged,
                  activeColor: Colors.amber[800],
                ),
                RadioListTile<String>(
                  title: Text('Everest 1830'),
                  value: 'Everest 1830',
                  groupValue: _selectedSpheroid,
                  onChanged: _onSpheroidChanged,
                  activeColor: Colors.amber[800],
                ),
                SizedBox(height: 30.0),
                ListTile(
                  title: Center(
                    child: TextButton(
                    onPressed: _resetSettings,
                    child: Text(
                      localizations.resettodefault,
                      style: TextStyle(color: Colors.amber[800]),
                    ),
                  ),
                ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}