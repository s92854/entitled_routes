// Info page with information about the app

import 'package:flutter/material.dart';
import 'app_localizations.dart';

class InfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Load the AppLocalizations (translations)
    final localizations = AppLocalizations.of(context);

    // Info-UI; List of information; loading some information from the AppLocalizations
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(localizations.about)),
        backgroundColor: Colors.amber[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.welcometitle,
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.0),
              Text(
                localizations.functionstitle,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                localizations.func1,
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 5.0),
              Text(
                localizations.func2,
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 5.0),
              Text(
                localizations.func3,
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 5.0),
              Text(
                localizations.func4,
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 5.0),
              Text(
                localizations.func5,
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 5.0),
              Text(
                localizations.func6,
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 5.0),
              Text(
                localizations.func7,
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 5.0),
              Text(
                localizations.func8,
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 5.0),
              Text(
                localizations.func9,
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 5.0),
              Text(
                localizations.func10,
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 5.0),
              Text(
                localizations.func11,
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 20.0),
              Text(
                localizations.dev,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                'Nico Haupt',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 5.0),
              Text(
                'Mail: s92854@bht-berlin.de',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 20.0),
              Text(
                'Version:',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                '1.0.0',
                style: TextStyle(fontSize: 16.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}