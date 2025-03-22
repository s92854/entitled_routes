// Welcome page with the bottom navigation bar; loading the pages InfoPage, MapPage, and SettingsPage when clicking on the specified icon

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
  // Index of the selected page (which page is displayed when opening the app)
  int _selectedIndex = 1; // 1 = MapPage

  late List<Widget> _widgetOptions;

  // Initialize the pages and darkMode
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

  // Function for changing the page
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Load the AppLocalizations (translations)
    final localizations = AppLocalizations.of(context);

    // Welcome-UI; Bottom Navigation Bar with the pages InfoPage, MapPage, and SettingsPage
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