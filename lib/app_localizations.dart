// This file contains the AppLocalizations class (variable names) which is used to provide the app with different languages. intl_en.arb / intl_de.arb contain the translations.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'l10n/messages_all.dart';

class AppLocalizations {
  static Future<AppLocalizations> load(Locale locale) {
    final String name = locale.countryCode?.isEmpty ?? false ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      return AppLocalizations();
    });
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  String get settingstitle {
    return Intl.message(
      'Settings',
      name: 'settingstitle',
      desc: 'Title for the Settings page',
    );
  }

  String get darkMode {
    return Intl.message(
      'Dark Mode',
      name: 'dark_mode',
      desc: 'Label for the Dark Mode switch',
    );
  }

  String get language {
    return Intl.message(
      'Language',
      name: 'language',
      desc: 'Label for the language dropdown',
    );
  }

  String get map {
    return Intl.message(
      'Map',
      name: 'map',
      desc: 'Label for the map in the App Bar',
    );
  }

  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: 'Label for the settings in the App Bar',
    );
  }

  String get info {
    return Intl.message(
      'Info',
      name: 'info',
      desc: 'Label for the info in the App Bar',
    );
  }

  String get mapstyle {
    return Intl.message(
      'Map style',
      name: 'mapstyle',
      desc: 'Label for the map style selection',
    );
  }

  String get search {
    return Intl.message(
      'Search...',
      name: 'search',
      desc: 'Label for the search bar',
    );
  }

  String get searchactive {
    return Intl.message(
      'Activate search mode',
      name: 'search_mode_on',
      desc: 'Label for activating search mode',
    );
  }

  String get searchinactive {
    return Intl.message(
      'Deactivate search mode',
      name: 'search_mode_off',
      desc: 'Label for deactivating search mode',
    );
  }

  String get startpoint {
    return Intl.message(
      'Start point',
      name: 'startpoint',
      desc: 'Label for the start point',
    );
  }

  String get endpoint {
    return Intl.message(
      'Target point',
      name: 'endpoint',
      desc: 'Label for the end point',
    );
  }

  String get curpos {
    return Intl.message(
      'Current Position',
      name: 'curpos',
      desc: 'Label for the current position',
    );
  }

  String get uppos {
    return Intl.message(
      'Update Position',
      name: 'uppos',
      desc: 'Label for updating current position',
    );
  }

  String get clearinput {
    return Intl.message(
      'Clear Input',
      name: 'clearinput',
      desc: 'Label for the CLEAR INPUT Button',
    );
  }

  String get m {
    return Intl.message(
      'Meter',
      name: 'm',
      desc: 'Label for meter',
    );
  }

  String get km {
    return Intl.message(
      'Kilometer',
      name: 'km',
      desc: 'Label for kilometer',
    );
  }

  String get mi {
    return Intl.message(
      'Miles',
      name: 'mi',
      desc: 'Label for miles',
    );
  }

  String get linedistance {
    return Intl.message(
      'Distance',
      name: 'linedistance',
      desc: 'Label for polyline distance',
    );
  }

  String get distance {
    return Intl.message(
      'Direct Distance',
      name: 'distance',
      desc: 'Label for air distance',
    );
  }

  String get about {
    return Intl.message(
      'About',
      name: 'about',
      desc: 'Label for about the app',
    );
  }

  String get welcometitle {
    return Intl.message(
      'Welcome to Entitled Routes!',
      name: 'welcometitle',
      desc: 'Label for welcome title',
    );
  }

  String get functionstitle {
    return Intl.message(
      'Functions',
      name: 'functionstitle',
      desc: 'Label for functions title',
    );
  }

  String get func1 {
    return Intl.message(
      '- OpenStreetMap Basemap',
      name: 'func1'
    );
  }

  String get func2 {
    return Intl.message(
        '- Accessing and displaying the current position (Geolocation)',
        name: 'func2'
    );
  }

  String get func3 {
    return Intl.message(
        '- Search for places, adresses, POIs and coordinates (Geocoder)',
        name: 'func3'
    );
  }

  String get func4 {
    return Intl.message(
        '- Generating the shortest route between two points',
        name: 'func4'
    );
  }

  String get func5 {
    return Intl.message(
        '- Calculate direct distance between these two points',
        name: 'func5'
    );
  }

  String get func6 {
    return Intl.message(
        '- Saving settings to local storage and accessing after app restart',
        name: 'func6'
    );
  }

  String get func7 {
    return Intl.message(
        '- Dark mode for better readability',
        name: 'func7'
    );
  }

  String get func8 {
    return Intl.message(
        '- Multi language support (English, German)',
        name: 'func8'
    );
  }

  String get func9 {
    return Intl.message(
        '- Using metrical or imperial units',
        name: 'func9'
    );
  }

  String get func10 {
    return Intl.message(
        '- Selecting different map styles',
        name: 'func10'
    );
  }

  String get func11 {
    return Intl.message(
        '- Switching between different speriods',
        name: 'func11'
    );
  }

  String get dev {
    return Intl.message(
        'Developer',
        name: 'dev'
    );
  }

  String get unit {
    return Intl.message(
      'Use Metric Units',
      name: 'unit',
      desc: 'Label for the unit switch',
    );
  }

  String get spheroid {
    return Intl.message(
      'Spheroid',
      name: 'spheroid',
      desc: 'Label for the spheroid selection',
    );
  }

  String get sellang {
    return Intl.message(
      'Language',
      name: 'sellang',
      desc: 'Label for the language selection',
    );
  }

  String get resettodefault {
    return Intl.message(
      'Reset to Default',
      name: 'resettodefault',
      desc: 'Label for the reset app button',
    );
  }
}