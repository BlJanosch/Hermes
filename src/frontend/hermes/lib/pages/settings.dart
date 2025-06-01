import 'package:flutter/material.dart';
import 'package:hermes/components/bottom_nav_bar.dart';
import 'package:hermes/components/erfolgcircle.dart';
import 'package:hermes/erfolg.dart';
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
  double _berge = 0;
  List<Erfolg> _erfolge = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadErfolge();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    // Mittels http request km und berge holen
    int? id = prefs.getInt('id');
    final url = Uri.parse('http://194.118.174.149:8080/user/datenabfrage?user_id=$id');
    final response = await http.get(url);
    final result = json.decode(response.body);
    print(result);
    setState(() {
      _username = prefs.getString('username') ?? 'Unbekannt';
      _kmgelaufen = result['kmgelaufen'];
      _hoehenmeter = result['hoehenmeter'];
      // Mit Berge noch machen
    });
  }

  Future<void> _loadErfolge() async {
    final prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt('id');
    final url = Uri.parse('http://194.118.174.149:8080/erfolg/get_erfolge?userID=1'); // auf $id ändern
    final response = await http.get(url);
    final result = json.decode(response.body);
    print(result);
    setState(() {
      _erfolge = (result as List)
        .map((e) => Erfolg.fromJson(e as Map<String, dynamic>))
        .toList();
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
                            'km: $_kmgelaufen km',
                            style: TextStyle(fontSize: 13),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Höhenmeter: $_hoehenmeter km',
                            style: TextStyle(fontSize: 13),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Berge: 7',
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
                Container(
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
                  child: Column(
                    children: [
                      GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 25,
                      mainAxisSpacing: 20,
                      children: _erfolge.map((erfolg) {
                        return Erfolgcircle(
                        icon: Icons.check,
                        text: erfolg.name,
                        );
                      }).toList(),
                      ),
                    ],
                  ),
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
