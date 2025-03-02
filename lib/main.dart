import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_localizations.dart';
import 'app_localizations_delegate.dart';
import 'l10n.dart';
import 'settings.dart';
import 'welcome.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isDarkMode = prefs.getBool('darkMode') ?? false;
  String languageCode = prefs.getString('language') ?? 'de';
  runApp(MyApp(isDarkMode: isDarkMode, locale: Locale(languageCode)));
}

class MyApp extends StatefulWidget {
  final bool isDarkMode;
  final Locale locale;

  const MyApp({super.key, required this.isDarkMode, required this.locale});

  @override
  _MyAppState createState() => _MyAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>()!;
    state.setLocale(newLocale);
  }
}

class _MyAppState extends State<MyApp> {
  late bool _isDarkMode;
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
    _locale = widget.locale;
  }

  void _toggleDarkMode(bool value) {
    setState(() {
      _isDarkMode = value;
      _saveDarkModeSetting(value);
    });
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  _saveDarkModeSetting(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkMode', value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      supportedLocales: L10n.all,
      localizationsDelegates: [
        const AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: Welcome(
        toggleDarkMode: _toggleDarkMode,
        isDarkMode: _isDarkMode,
      ),
      routes: {
        '/settings': (context) => SettingsPage(
          toggleDarkMode: _toggleDarkMode,
          isDarkMode: _isDarkMode,
        ),
      },
    );
  }
}