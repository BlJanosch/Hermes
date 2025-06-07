import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hermes/components/bottom_nav_bar.dart';
import 'package:hermes/components/erfolgcircle.dart';
import 'package:hermes/erfolg.dart';
import 'package:hermes/erfolgCollection.dart';
import 'package:hermes/userManager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hermes/pages/login.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

// Logging included
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
  ErfolgCollection _userErfolge = ErfolgCollection();
  ErfolgCollection _allErfolge = ErfolgCollection();

  @override
  void initState() {
    super.initState();
    try{
      UserManager.loadUserData().then((userData) {
      if (!mounted) return;
      setState(() {
        _username = userData['username'] ?? 'Unbekannt';
        _kmgelaufen = userData['kmgelaufen'] ?? 0.0;
        _hoehenmeter = userData['hoehenmeter'] ?? 0.0;
        _berge = userData['berge'] ?? 0;
      });
    });
    }
    catch (e) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Fehler beim Laden der Benutzerdaten'),
            content: Text('Fehler: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
    }
    _initErfolge();
  }

  Future<void> _initErfolge() async {
    try{
      await UserManager.checkErfolge(context);
      final erfolge = await UserManager.loadUserErfolge();
      if (mounted) {
        setState(() {
          _userErfolge.ergebnisse = erfolge;
        });
      }
      final allErfolge = await UserManager.loadAllErfolge(_userErfolge);
      if (mounted) {
        setState(() {
          _allErfolge.ergebnisse = allErfolge;
        });
      }
    }
    catch (e){
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Fehler beim Laden der Erfolge'),
            content: Text('Fehler: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),

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
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                prefs.setBool('isLoggedIn', false);
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
        title: Text(
          'Einstellungen',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu, color: Colors.white,),
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
                    style: TextStyle(fontSize: 24, color: Colors.white),
                    textAlign: TextAlign.left,
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
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
                        margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.10),
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
                            double itemHeight = itemWidth * 1.5;

                            return GridView.builder(
                              physics: AlwaysScrollableScrollPhysics(),
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
