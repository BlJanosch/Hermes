import 'package:flutter/material.dart';
import 'package:hermes/components/bottom_nav_bar.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.withOpacity(0.7),
      appBar: AppBar(
        title: Text('Einstellungen'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(Icons.menu), // Drei-Striche-Menü
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            bottom: 10.0,
            left: 5,
            right: 5,
            child: MyBottomNavBar(currentIndex: 3,),
          ),
        ],
      ),
    );
  }
}