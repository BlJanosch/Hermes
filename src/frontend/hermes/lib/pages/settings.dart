import 'package:flutter/material.dart';
import 'package:hermes/components/bottom_nav_bar.dart';
import 'package:hermes/components/erfolgcircle.dart';
import 'package:hermes/erfolg.dart';
import 'package:hermes/erfolgCollection.dart';
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
    _loadUserData();
    _initErfolge();
  }

  Future<void> _initErfolge() async {
    await _loadUserErfolge();
    await _loadAllErfolge();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    // Mittels http request km und berge holen
    int? id = prefs.getInt('id');
    final url = Uri.parse('http://194.118.174.149:8080/user/datenabfrage?user_id=$id');
    final response = await http.get(url);
    final result = json.decode(response.body);
    print(result);
    final urlBerge = Uri.parse('http://194.118.174.149:8080/erfolg/erreichteziele?userID=$id');
    final responseBerge = await http.get(urlBerge);
    final resultBerge = json.decode(responseBerge.body);
    print(resultBerge.length);
    setState(() {
      _username = prefs.getString('username') ?? 'Unbekannt';
      _kmgelaufen = result['kmgelaufen'];
      _hoehenmeter = result['hoehenmeter'];
      _berge = resultBerge.length;
    });
  }

  Future<void> _loadUserErfolge() async {
    final prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt('id');
    final url = Uri.parse('http://194.118.174.149:8080/erfolg/get_erfolge?userID=$id');
    final response = await http.get(url);
    final result = json.decode(response.body);
    print(result);
    setState(() {
      _userErfolge.ergebnisse = (result as List)
        .map((e) => Erfolg.fromJson(e as Map<String, dynamic>))
        .toList();
    });
  }

  Future<void> _loadAllErfolge() async {
    final url = Uri.parse('http://194.118.174.149:8080/erfolg/get_allerfolge');
    final response = await http.get(url);
    final result = json.decode(response.body);
    print(result);
    for (int x = 0; x < result.length; x++) {
      final newErfolg = Erfolg.fromJson(result[x] as Map<String, dynamic>);

      final alreadyExists = _userErfolge.ergebnisse.any((e) => e.name == newErfolg.name);

      if (!alreadyExists) {
        _allErfolge.ergebnisse.add(newErfolg);
      }
    }

   setState(() {
      _allErfolge.ergebnisse = _allErfolge.ergebnisse;
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
