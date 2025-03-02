import 'package:flutter/material.dart';
import 'map.dart';
import 'info.dart';
import 'settings.dart';
import 'app_localizations.dart';

class Welcome extends StatefulWidget {
  final Function(bool) toggleDarkMode;
  final bool isDarkMode;

  Welcome({required this.toggleDarkMode, required this.isDarkMode});

  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  int _selectedIndex = 1;

  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      InfoPage(),
      MapPage(),
      SettingsPage(
        toggleDarkMode: widget.toggleDarkMode,
        isDarkMode: widget.isDarkMode,
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: localizations.info,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: localizations.map,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: localizations.settings,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}