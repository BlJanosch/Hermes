import 'package:flutter/material.dart';
import 'package:hermes/components/bottom_nav_bar.dart';
import 'package:hermes/components/erfolgcircle.dart';
import 'package:hermes/components/nfc_reader.dart';
import 'package:hermes/erfolg.dart';
import 'package:hermes/erfolgCollection.dart';
import 'package:hermes/userManager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hermes/pages/login.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String _username = '';
  double _kmgelaufen = 0;
  double _hoehenmeter = 0;
  int _berge = 0;
  ErfolgCollection _userErfolge = new ErfolgCollection();
  ErfolgCollection _allErfolge = new ErfolgCollection();

  @override
  void initState() {
    super.initState();
    UserManager.loadUserData().then((userData) {
      setState(() {
      _username = userData['username'] ?? 'Unbekannt';
      _kmgelaufen = userData['kmgelaufen'] ?? 0.0;
      _hoehenmeter = userData['hoehenmeter'] ?? 0.0;
      _berge = userData['berge'] ?? 0;
      });
    });
    _initErfolge();
  }

  Future<void> _initErfolge() async {
    final erfolge = await UserManager.loadUserErfolge();
    setState(() {
      _userErfolge.ergebnisse = erfolge;
    });
    final allErfolge = await UserManager.loadAllErfolge(_userErfolge);
    setState(() {
      _allErfolge.ergebnisse = allErfolge;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.withOpacity(0.7),

      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF4A742F)),
              child: Text(
                'Menü',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Abmelden'),
              onTap: () async {
                Navigator.pop(context);
                // Cache resetten
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                prefs.setBool('isLoggedIn', false);
                // Abmelden
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()),
                  );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Mehr Einstellungen'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),

      appBar: AppBar(
        title: Text('Einstellungen'),
        backgroundColor: Colors.transparent,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openEndDrawer(); 
              },
            ),
          ),
        ],
      ),

      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 180,
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Name: $_username',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'km: ${_kmgelaufen.toStringAsFixed(2)} km',
                            style: TextStyle(fontSize: 13),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Höhenmeter: ${_hoehenmeter.toStringAsFixed(2)} km',
                            style: TextStyle(fontSize: 13),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Berge: $_berge',
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Color(0xFFBBA430),
                      child: Text(
                        _username.isNotEmpty ? _username[0].toUpperCase() : 'A',
                        style: TextStyle(fontSize: 32, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Erfolge",
                    style: TextStyle(fontSize: 24),
                    textAlign: TextAlign.left,
                  ),
                ),
                SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                  // Berechne die Anzahl der Spalten abhängig von der verfügbaren Breite
                  int crossAxisCount = 2;
                  double width = constraints.maxWidth;
                  if (width > 900) {
                    crossAxisCount = 6;
                  } else if (width > 700) {
                    crossAxisCount = 5;
                  } else if (width > 500) {
                    crossAxisCount = 4;
                  } else if (width > 350) {
                    crossAxisCount = 3;
                  }

                  return Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                      ),
                    ],
                    ),
                    child: LayoutBuilder(
                      builder: (context, gridConstraints) {
                      double itemWidth = (gridConstraints.maxWidth - (crossAxisCount - 1) * 25) / crossAxisCount;
                      double itemHeight = itemWidth * 1.5; // Verhältnis anpassen je nach Bedarf

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 25,
                        mainAxisSpacing: 0,
                        childAspectRatio: itemWidth / itemHeight,
                        ),
                        itemCount: _userErfolge.ergebnisse.length + _allErfolge.ergebnisse.length,
                        itemBuilder: (context, index) {
                        if (index < _userErfolge.ergebnisse.length) {
                          final erfolg = _userErfolge.ergebnisse[index];
                          return Erfolgcircle(
                          icon: Icons.check,
                          text: erfolg.name,
                          );
                        } else {
                          final erfolg = _allErfolge.ergebnisse[index - _userErfolge.ergebnisse.length];
                          return Erfolgcircle(
                          icon: Icons.lock_outline,
                          text: erfolg.name,
                          );
                        }
                        },
                      );
                      },
                    ),
                  );
                  },
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 10.0,
            left: 5,
            right: 5,
            child: MyBottomNavBar(currentIndex: 3),
          ),
        ],
      ),
    );
  }
}
